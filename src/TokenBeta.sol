// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title TokenBeta Contract
/// @notice This contract implements an ERC20 token with permit functionality and ownership control.
/// @dev Inherits from ERC20Permit for permit functionality and Ownable2Step for ownership management.
contract TokenBeta is ERC20Permit, Ownable2Step {
    /// @notice Initializes the TokenBeta contract with the given name and symbol.
    /// @dev Sets the initial owner to the deployer of the contract.
    constructor() ERC20Permit("TokenBeta") ERC20("TokenBeta", "TBT") Ownable(msg.sender) {}

    /// @notice Mints new tokens to a specified address.
    /// @dev Only the owner can call this function.
    /// @param to The address to receive the minted tokens.
    /// @param amount The amount of tokens to mint.
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}

// Deployer: 0xE7234457734b5Fa98ac230Aa2e5bC9A2d17A1C27
// Deployed to: 0x0eaA2CF4caC42e449757084C8a5B996ADc6e0897
// Transaction hash: 0x87dab0cac6e32dc2cc9cff37379ec2ef77936c65013b29ef60d9dd729648bc57
