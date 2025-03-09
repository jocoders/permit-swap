// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {PermitSwap} from "../src/PermitSwap.sol";
import {TokenAlpha} from "../src/TokenAlpha.sol";
import {TokenBeta} from "../src/TokenBeta.sol";

contract PermitSwapScript is Script {
    PermitSwap public permitSwap;
    TokenAlpha public tokenAlpha;
    TokenBeta public tokenBeta;

    function setUp() public {
        tokenAlpha = new TokenAlpha();
        tokenBeta = new TokenBeta();
    }

    function run() public {
        vm.startBroadcast();

        permitSwap = new PermitSwap(address(tokenAlpha), address(tokenBeta));

        vm.stopBroadcast();
    }
}
