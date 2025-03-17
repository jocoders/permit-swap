// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {PermitSwap} from "../src/PermitSwap.sol";
import {TokenAlpha} from "../src/TokenAlpha.sol";
import {TokenBeta} from "../src/TokenBeta.sol";

import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract PermitSwapTest is Test {
    PermitSwap public permitSwap;
    TokenAlpha public tokenAlpha;
    TokenBeta public tokenBeta;

    uint256 INIT_AMOUNT = 10_000e18;
    uint256 orderId;
    uint256 public constant ALICE_PRIVATE_KEY = 0xa11ce;
    uint256 public constant BOB_PRIVATE_KEY = 0xb0b;

    address Alice;
    address Bob;
    uint256 alicePrivateKey;
    uint256 bobPrivateKey;

    bytes32 private constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    struct Transaction {
        address owner;
        address spender;
        uint256 value;
        uint256 nonce;
        uint256 deadline;
    }

    function setUp() public {
        tokenAlpha = new TokenAlpha();
        tokenBeta = new TokenBeta();
        permitSwap = new PermitSwap(address(tokenAlpha), address(tokenBeta));

        (address _alice, uint256 _alicePrivateKey) = makeAddrAndKey("alice");
        Alice = _alice;
        alicePrivateKey = _alicePrivateKey;
        tokenAlpha.mint(Alice, INIT_AMOUNT);
        tokenBeta.mint(Alice, INIT_AMOUNT);

        (address _bob, uint256 _bobPrivateKey) = makeAddrAndKey("bob");
        Bob = _bob;
        bobPrivateKey = _bobPrivateKey;
        tokenAlpha.mint(Bob, INIT_AMOUNT);
        tokenBeta.mint(Bob, INIT_AMOUNT);
    }

    function test_success_swap() public {
        uint256 TOKEN_SELL_1 = 99e18;
        uint256 TOKEN_BUY_1 = 133e18;

        (PermitSwap.Order memory order1, PermitSwap.Signature memory txSig1) = _createOrderAndTxSig(
            Alice,
            address(tokenAlpha),
            address(tokenBeta),
            TOKEN_SELL_1,
            TOKEN_BUY_1,
            block.timestamp + 1 days,
            alicePrivateKey,
            tokenAlpha.nonces(Alice)
        );

        (PermitSwap.Order memory order2, PermitSwap.Signature memory txSig2) = _createOrderAndTxSig(
            Bob,
            address(tokenBeta),
            address(tokenAlpha),
            TOKEN_BUY_1,
            TOKEN_SELL_1,
            block.timestamp + 1 days,
            bobPrivateKey,
            tokenBeta.nonces(Bob)
        );

        _validateSwap(order1, order2, txSig1, txSig2);
        // ------------------------------------------------------------

        uint256 TOKEN_SELL_2 = 129e18;
        uint256 TOKEN_BUY_2 = 77e18;

        (PermitSwap.Order memory order3, PermitSwap.Signature memory txSig3) = _createOrderAndTxSig(
            Bob,
            address(tokenAlpha),
            address(tokenBeta),
            TOKEN_SELL_2,
            TOKEN_BUY_2,
            block.timestamp + 1 days,
            bobPrivateKey,
            tokenAlpha.nonces(Bob)
        );

        (PermitSwap.Order memory order4, PermitSwap.Signature memory txSig4) = _createOrderAndTxSig(
            Alice,
            address(tokenBeta),
            address(tokenAlpha),
            TOKEN_BUY_2,
            TOKEN_SELL_2,
            block.timestamp + 1 days,
            alicePrivateKey,
            tokenBeta.nonces(Alice)
        );

        _validateSwap(order3, order4, txSig3, txSig4);
    }

    function test_failed_swap_invalid_amounts() public {
        uint256 TOKEN_SELL_1 = 99e18;
        uint256 TOKEN_BUY_1 = 133e18;

        (PermitSwap.Order memory order1, PermitSwap.Signature memory txSig1) = _createOrderAndTxSig(
            Alice,
            address(tokenAlpha),
            address(tokenBeta),
            TOKEN_SELL_1,
            TOKEN_BUY_1,
            block.timestamp + 1 days,
            alicePrivateKey,
            tokenAlpha.nonces(Alice)
        );

        (PermitSwap.Order memory order2, PermitSwap.Signature memory txSig2) = _createOrderAndTxSig(
            Bob,
            address(tokenBeta),
            address(tokenAlpha),
            TOKEN_SELL_1,
            TOKEN_BUY_1,
            block.timestamp + 1 days,
            bobPrivateKey,
            tokenBeta.nonces(Bob)
        );

        vm.expectRevert(PermitSwap.InvalidAmounts.selector);
        permitSwap.swap(order1, order2, txSig1, txSig2);
    }

    function test_failed_swap_invalid_owner() public {
        uint256 TOKEN_SELL_1 = 99e18;
        uint256 TOKEN_BUY_1 = 133e18;

        (PermitSwap.Order memory order1, PermitSwap.Signature memory txSig1) = _createOrderAndTxSig(
            address(0),
            address(tokenAlpha),
            address(tokenBeta),
            TOKEN_SELL_1,
            TOKEN_BUY_1,
            block.timestamp + 1 days,
            alicePrivateKey,
            tokenAlpha.nonces(Alice)
        );

        (PermitSwap.Order memory order2, PermitSwap.Signature memory txSig2) = _createOrderAndTxSig(
            address(0),
            address(tokenBeta),
            address(tokenAlpha),
            TOKEN_BUY_1,
            TOKEN_SELL_1,
            block.timestamp + 1 days,
            bobPrivateKey,
            tokenBeta.nonces(Bob)
        );

        vm.expectRevert(abi.encodeWithSelector(PermitSwap.InvalidOwner.selector, order1.orderId));
        permitSwap.swap(order1, order2, txSig1, txSig2);
    }

    function test_failed_swap_invalid_deadline() public {
        uint256 TOKEN_SELL_1 = 99e18;
        uint256 TOKEN_BUY_1 = 133e18;

        (PermitSwap.Order memory order1, PermitSwap.Signature memory txSig1) = _createOrderAndTxSig(
            Alice,
            address(tokenAlpha),
            address(tokenBeta),
            TOKEN_SELL_1,
            TOKEN_BUY_1,
            block.timestamp + 1 days,
            alicePrivateKey,
            tokenAlpha.nonces(Alice)
        );

        (PermitSwap.Order memory order2, PermitSwap.Signature memory txSig2) = _createOrderAndTxSig(
            Bob,
            address(tokenBeta),
            address(tokenAlpha),
            TOKEN_BUY_1,
            TOKEN_SELL_1,
            block.timestamp + 1 days,
            bobPrivateKey,
            tokenBeta.nonces(Bob)
        );

        vm.warp(block.timestamp + 2 days);

        vm.expectRevert(abi.encodeWithSelector(PermitSwap.OrderExpired.selector, order1.orderId));
        permitSwap.swap(order1, order2, txSig1, txSig2);
    }

    function test_failed_swap_invalid_same_tokens() public {
        uint256 TOKEN_SELL_1 = 99e18;
        uint256 TOKEN_BUY_1 = 133e18;

        (PermitSwap.Order memory order1, PermitSwap.Signature memory txSig1) = _createOrderAndTxSig(
            Alice,
            address(tokenAlpha),
            address(tokenAlpha),
            TOKEN_SELL_1,
            TOKEN_BUY_1,
            block.timestamp + 1 days,
            alicePrivateKey,
            tokenAlpha.nonces(Alice)
        );

        (PermitSwap.Order memory order2, PermitSwap.Signature memory txSig2) = _createOrderAndTxSig(
            Bob,
            address(tokenBeta),
            address(tokenBeta),
            TOKEN_BUY_1,
            TOKEN_SELL_1,
            block.timestamp + 1 days,
            bobPrivateKey,
            tokenBeta.nonces(Bob)
        );

        vm.expectRevert(abi.encodeWithSelector(PermitSwap.IdenticalTokens.selector, order1.orderId));
        permitSwap.swap(order1, order2, txSig1, txSig2);
    }

    function test_failed_swap_invalid_balance() public {
        uint256 TOKEN_SELL_1 = 99_000e18;
        uint256 TOKEN_BUY_1 = 133_000e18;

        (PermitSwap.Order memory order1, PermitSwap.Signature memory txSig1) = _createOrderAndTxSig(
            Alice,
            address(tokenAlpha),
            address(tokenBeta),
            TOKEN_SELL_1,
            TOKEN_BUY_1,
            block.timestamp + 1 days,
            alicePrivateKey,
            tokenAlpha.nonces(Alice)
        );

        (PermitSwap.Order memory order2, PermitSwap.Signature memory txSig2) = _createOrderAndTxSig(
            Bob,
            address(tokenBeta),
            address(tokenAlpha),
            TOKEN_BUY_1,
            TOKEN_SELL_1,
            block.timestamp + 1 days,
            bobPrivateKey,
            tokenBeta.nonces(Bob)
        );

        vm.expectRevert(abi.encodeWithSelector(PermitSwap.InvalidBalance.selector, order1.orderId, order1.tokenSell));
        permitSwap.swap(order1, order2, txSig1, txSig2);
    }

    function _createOrderAndTxSig(
        address owner,
        address tokenSell,
        address tokenBuy,
        uint256 amountSell,
        uint256 amountBuy,
        uint256 deadline,
        uint256 privateKey,
        uint256 nonce
    ) private returns (PermitSwap.Order memory order, PermitSwap.Signature memory txSig) {
        order = _createOrder(owner, tokenSell, tokenBuy, orderId++, amountSell, amountBuy, deadline, privateKey);
        txSig = _createTxSig(owner, address(permitSwap), tokenSell, amountSell, nonce, deadline, privateKey);
    }

    function _createOrder(
        address owner,
        address tokenSell,
        address tokenBuy,
        uint256 orderId,
        uint256 amountSell,
        uint256 amountBuy,
        uint256 deadline,
        uint256 privateKey
    ) private view returns (PermitSwap.Order memory _order) {
        _order = PermitSwap.Order({
            owner: owner,
            tokenSell: tokenSell,
            tokenBuy: tokenBuy,
            orderId: orderId,
            amountSell: amountSell,
            amountBuy: amountBuy,
            deadline: deadline
        });
    }

    function _createTxSig(
        address owner,
        address spender,
        address token,
        uint256 value,
        uint256 nonce,
        uint256 deadline,
        uint256 privateKey
    ) private view returns (PermitSwap.Signature memory _sig) {
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonce, deadline));
        bytes32 domainSeparator = ERC20Permit(token).DOMAIN_SEPARATOR(); // или tokenBeta.DOMAIN_SEPARATOR()
        bytes32 txHash = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, txHash);
        _sig = PermitSwap.Signature({v: v, r: r, s: s});
    }

    function _extractAlphaTxVRS(uint256 privateKey, bytes32 hash)
        private
        view
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                keccak256(bytes("TokenAlpha")),
                keccak256(bytes("1")),
                block.chainid,
                address(tokenAlpha)
            )
        );
        bytes32 structHash = keccak256(abi.encodePacked("\x19\x01", domainSeparator, hash));
        (v, r, s) = vm.sign(privateKey, structHash);
    }

    function _extractBetaTxVRS(uint256 privateKey, bytes32 hash) private view returns (uint8 v, bytes32 r, bytes32 s) {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                PERMIT_TYPEHASH, keccak256(bytes("TokenBeta")), keccak256(bytes("1")), block.chainid, address(tokenBeta)
            )
        );
        bytes32 structHash = keccak256(abi.encodePacked("\x19\x01", domainSeparator, hash));
        (v, r, s) = vm.sign(privateKey, structHash);
    }

    function _validateSwap(
        PermitSwap.Order memory order1,
        PermitSwap.Order memory order2,
        PermitSwap.Signature memory txSig1,
        PermitSwap.Signature memory txSig2
    ) private {
        uint256 user1SellBalanceBefore = _getBalance(order1.tokenSell, order1.owner);
        uint256 user1BuyBalanceBefore = _getBalance(order1.tokenBuy, order1.owner);

        uint256 user2SellBalanceBefore = _getBalance(order2.tokenSell, order2.owner);
        uint256 user2BuyBalanceBefore = _getBalance(order2.tokenBuy, order2.owner);

        permitSwap.swap(order1, order2, txSig1, txSig2);

        uint256 user1SellBalanceAfter = _getBalance(order1.tokenSell, order1.owner);
        uint256 user1BuyBalanceAfter = _getBalance(order1.tokenBuy, order1.owner);

        uint256 user2SellBalanceAfter = _getBalance(order2.tokenSell, order2.owner);
        uint256 user2BuyBalanceAfter = _getBalance(order2.tokenBuy, order2.owner);

        assertEq(user1SellBalanceAfter, user1SellBalanceBefore - order1.amountSell);
        assertEq(user1BuyBalanceAfter, user1BuyBalanceBefore + order1.amountBuy);

        assertEq(user2SellBalanceAfter, user2SellBalanceBefore - order2.amountSell);
        assertEq(user2BuyBalanceAfter, user2BuyBalanceBefore + order2.amountBuy);
    }

    function _getBalance(address token, address user) private view returns (uint256) {
        return ERC20Permit(token).balanceOf(user);
    }

    function _logAddress() internal {
        console.log("--------------------------------");
        console.log("address(tokenAlpha)", address(tokenAlpha));
        console.log("address(tokenBeta)", address(tokenBeta));
        console.log("address(permitSwap)", address(permitSwap));
        console.log("address(this)", address(this));
        console.log("--------------------------------");
        console.log("Alice", Alice);
        console.log("Bob", Bob);
        console.log("--------------------------------");
    }
}
