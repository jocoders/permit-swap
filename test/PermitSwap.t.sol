// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {PermitSwap} from "../src/PermitSwap.sol";
import {TokenAlpha} from "../src/TokenAlpha.sol";
import {TokenBeta} from "../src/TokenBeta.sol";

contract PermitSwapTest is Test {
    PermitSwap public permitSwap;
    TokenAlpha public tokenAlpha;
    TokenBeta public tokenBeta;

    address public alice = makeAddr("Alice");
    address public bob = makeAddr("Bob");

    function setUp() public {
        tokenAlpha = new TokenAlpha();
        tokenBeta = new TokenBeta();
        permitSwap = new PermitSwap(address(tokenAlpha), address(tokenBeta));
    }

    function test_Swap() public {
        vm.startPrank(alice);
    }

    function _extractOrderVRS(address owner, bytes32 _hash) private returns (uint8 v, bytes32 r, bytes32 s) {
        // CHANGE IT!!!!!!
        bytes32 domainSeparator = keccak256(abi.encode(address(permitSwap)));

        bytes32 structHash = keccak256(abi.encodePacked("\x19\x01", domainSeparator, _hash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(owner, structHash);
    }

    function _extractAlphaTxVRS(address owner, bytes32 _hash) private returns (uint8 v, bytes32 r, bytes32 s) {
        // CHANGE IT!!!!!!
        bytes32 domainSeparator = keccak256(abi.encode(address(permitSwap)));
        bytes32 structHash = keccak256(abi.encodePacked("\x19\x01", domainSeparator, _hash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(owner, structHash);
    }

    function _extractBetaTxVRS(address owner, bytes32 _hash) private returns (uint8 v, bytes32 r, bytes32 s) {
        // CHANGE IT!!!!!!
        bytes32 domainSeparator = keccak256(abi.encode(address(permitSwap)));
        bytes32 structHash = keccak256(abi.encodePacked("\x19\x01", domainSeparator, _hash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(owner, structHash);
    }

    function _createOrderHash(
        address owner,
        address tokenSell,
        address tokenBuy,
        uint256 orderId,
        uint256 amountSell,
        uint256 amountBuy,
        uint256 deadline,
        uint256 nonce
    ) private returns (bytes32 _hash) {
        _hash = keccak256(
            abi.encode(
                permitSwap.ORDER_TYPEHASH, owner, tokenSell, tokenBuy, orderId, amountSell, amountBuy, deadline, nonce
            )
        );
    }

    function _createTxHash(address owner, address spender, uint256 value, uint256 deadline) returns (bytes32 _hash) {
        _hash = keccak256(abi.encode(permitSwap.PERMIT_TYPEHASH, owner, spender, value, deadline));
    }
}
