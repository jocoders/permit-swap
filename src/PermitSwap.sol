// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {TokenAlpha} from "./TokenAlpha.sol";
import {TokenBeta} from "./TokenBeta.sol";

/// @title PermitSwap Contract
/// @notice This contract facilitates token swaps between two orders using EIP-712 signatures for permit functionality.
/// @dev Inherits from EIP712 for domain separation and uses ECDSA for signature recovery.
contract PermitSwap is EIP712 {
    using ECDSA for bytes32;

    /// @notice Address of the TokenAlpha contract.
    address public immutable tokenAlpha;
    /// @notice Address of the TokenBeta contract.
    address public immutable tokenBeta;

    /// @notice Represents an order for a token swap.
    struct Order {
        address owner;
        address tokenSell;
        address tokenBuy;
        uint256 orderId;
        uint256 amountSell;
        uint256 amountBuy;
        uint256 deadline;
    }

    /// @notice Represents a signature for a transaction.
    struct Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    error InvalidAmounts(); // 0xd856fc5a
    error InvalidOwner(uint256 orderId); // 0x427be9f6
    error InvalidTransfer(uint256 orderId); // 0xef61ddaf
    error InvalidSignature(uint256 orderId); // 0x52bf9848
    error InvalidToken(uint256 orderId); // 0x925d6b18
    error IdenticalTokens(uint256 orderId); // 0x4811edad
    error InvalidBalance(uint256 orderId, address token); // 0x6a791864

    /// @notice Emitted when a swap is successfully executed.
    /// @param orderId1 The ID of the first order.
    /// @param orderId2 The ID of the second order.
    event Swap(uint256 orderId1, uint256 orderId2);

    /// @notice Initializes the PermitSwap contract with the given token addresses.
    /// @param _tokenAlpha Address of the TokenAlpha contract.
    /// @param _tokenBeta Address of the TokenBeta contract.
    constructor(address _tokenAlpha, address _tokenBeta) EIP712("PermitSwap", "1") {
        tokenAlpha = _tokenAlpha;
        tokenBeta = _tokenBeta;
    }

    /// @notice Executes a swap between two orders.
    /// @param order1 The first order.
    /// @param order2 The second order.
    /// @param txSig1 The signature for the first order.
    /// @param txSig2 The signature for the second order.
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

    /// @dev Validates two orders for a swap.
    /// @param order1 The first order.
    /// @param order2 The second order.
    function _validateOrders(Order calldata order1, Order calldata order2) private {
        require(order1.amountSell == order2.amountBuy && order1.amountBuy == order2.amountSell, InvalidAmounts());
        _validateOrder(order1);
        _validateOrder(order2);
    }

    /// @dev Validates a single order.
    /// @param order The order to validate.
    function _validateOrder(Order calldata order) private {
        require(order.owner != address(0), InvalidOwner(order.orderId));
        require(order.tokenSell != order.tokenBuy, IdenticalTokens(order.orderId));
        require(_isValidToken(order.tokenSell), InvalidToken(order.orderId));
        require(_isValidToken(order.tokenBuy), InvalidToken(order.orderId));
        require(
            _isValidBalance(order.tokenSell, order.owner, order.amountSell),
            InvalidBalance(order.orderId, order.tokenSell)
        );
    }

    /// @dev Checks if a token is valid for swapping.
    /// @param token The token address to check.
    /// @return True if the token is valid, false otherwise.
    function _isValidToken(address token) private view returns (bool) {
        return token == tokenAlpha || token == tokenBeta;
    }

    /// @dev Checks if an owner has a sufficient balance of a token.
    /// @param token The token address.
    /// @param owner The owner address.
    /// @param amount The amount to check.
    /// @return True if the balance is sufficient, false otherwise.
    function _isValidBalance(address token, address owner, uint256 amount) private view returns (bool) {
        return ERC20Permit(token).balanceOf(owner) >= amount;
    }
}
