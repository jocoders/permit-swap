// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title TokenAlpha Contract
/// @notice This contract implements an ERC20 token with permit functionality and ownership control.
/// @dev Inherits from ERC20Permit for permit functionality and Ownable2Step for ownership management.
contract TokenAlpha is ERC20Permit, Ownable2Step {
    /// @notice Initializes the TokenAlpha contract with the given name and symbol.
    /// @dev Sets the initial owner to the deployer of the contract.
    constructor() ERC20Permit("TokenAlpha") ERC20("TokenAlpha", "TAL") Ownable(msg.sender) {}

    /// @notice Mints new tokens to a specified address.
    /// @dev Only the owner can call this function.
    /// @param to The address to receive the minted tokens.
    /// @param amount The amount of tokens to mint.
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}

// Deployer: 0xE7234457734b5Fa98ac230Aa2e5bC9A2d17A1C27
// Deployed to: 0x2CbD45215911Bd022b5F3c13dFe55E2ddb4C7406
// Transaction hash: 0x33dfabfafb1ed3a84c42a8db60eeba579406b2c06c2ac09ad1a03ee5112776da
