// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenAlpha is ERC20Permit {
    constructor() ERC20Permit("TokenAlpha") ERC20("TokenAlpha", "TAL") {}
}
