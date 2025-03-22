// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {PermitSwap} from "../src/PermitSwap.sol";
import {TokenAlpha} from "../src/TokenAlpha.sol";
import {TokenBeta} from "../src/TokenBeta.sol";

contract PermitSwapScript is Script {
    function run() public {
        vm.startBroadcast();

        TokenAlpha tokenAlpha = new TokenAlpha();
        TokenBeta tokenBeta = new TokenBeta();
        PermitSwap permitSwap = new PermitSwap(address(tokenAlpha), address(tokenBeta));

        console.log("TokenAlpha deployed at:", address(tokenAlpha));
        console.log("TokenBeta deployed at:", address(tokenBeta));
        console.log("PermitSwap deployed at:", address(permitSwap));

        vm.stopBroadcast();
    }
}
