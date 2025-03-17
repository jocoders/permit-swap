// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {TokenAlpha} from "./TokenAlpha.sol";
import {TokenBeta} from "./TokenBeta.sol";

contract PermitSwap is EIP712 {
    using ECDSA for bytes32;

    address public immutable tokenAlpha;
    address public immutable tokenBeta;

    struct Order {
        address owner;
        address tokenSell;
        address tokenBuy;
        uint256 orderId;
        uint256 amountSell;
        uint256 amountBuy;
        uint256 deadline;
    }

    struct Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    error InvalidAmounts();
    error InvalidOwner(uint256 orderId);
    error OrderExpired(uint256 orderId);
    error InvalidTransfer(uint256 orderId);
    error InvalidSignature(uint256 orderId);
    error InvalidToken(uint256 orderId);
    error IdenticalTokens(uint256 orderId);
    error InvalidBalance(uint256 orderId, address token);

    event Swap(uint256 orderId1, uint256 orderId2);

    bytes32 private constant ORDER_TYPEHASH = keccak256(
        "Order(address owner,address tokenSell,address tokenBuy,uint256 orderId,uint256 amountSell,uint256 amountBuy,uint256 deadline,uint256 nonce)"
    );

    constructor(address _tokenAlpha, address _tokenBeta) EIP712("PermitSwap", "1") {
        tokenAlpha = _tokenAlpha;
        tokenBeta = _tokenBeta;
    }

    function swap(Order calldata order1, Order calldata order2, Signature calldata txSig1, Signature calldata txSig2)
        public
    {
        _validateOrders(order1, order2);
        ERC20Permit(order1.tokenSell).permit(
            order1.owner, address(this), order1.amountSell, order1.deadline, txSig1.v, txSig1.r, txSig1.s
        );
        ERC20Permit(order2.tokenSell).permit(
            order2.owner, address(this), order2.amountSell, order2.deadline, txSig2.v, txSig2.r, txSig2.s
        );

        require(
            ERC20Permit(order1.tokenSell).transferFrom(order1.owner, order2.owner, order1.amountSell),
            InvalidTransfer(order1.orderId)
        );
        require(
            ERC20Permit(order2.tokenSell).transferFrom(order2.owner, order1.owner, order2.amountSell),
            InvalidTransfer(order2.orderId)
        );

        emit Swap(order1.orderId, order2.orderId);
    }

    function _validateOrders(Order calldata order1, Order calldata order2) private {
        require(order1.amountSell == order2.amountBuy && order1.amountBuy == order2.amountSell, InvalidAmounts());
        _validateOrder(order1);
        _validateOrder(order2);
    }

    function _validateOrder(Order calldata order) private {
        require(order.owner != address(0), InvalidOwner(order.orderId));
        require(order.deadline > block.timestamp, OrderExpired(order.orderId));
        require(order.tokenSell != order.tokenBuy, IdenticalTokens(order.orderId));
        require(_isValidToken(order.tokenSell), InvalidToken(order.orderId));
        require(_isValidToken(order.tokenBuy), InvalidToken(order.orderId));
        require(
            _isValidBalance(order.tokenSell, order.owner, order.amountSell),
            InvalidBalance(order.orderId, order.tokenSell)
        );
        require(
            _isValidBalance(order.tokenBuy, order.owner, order.amountBuy), InvalidBalance(order.orderId, order.tokenBuy)
        );
    }

    function _isValidToken(address token) private view returns (bool) {
        return token == tokenAlpha || token == tokenBeta;
    }

    function _isValidBalance(address token, address owner, uint256 amount) private view returns (bool) {
        return ERC20Permit(token).balanceOf(owner) >= amount;
    }
}
