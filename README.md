# PermitSwap Contract

## Overview

**PermitSwap** is a smart contract designed to facilitate token swaps between two parties using signed orders. This contract leverages the EIP-712 standard for structured data hashing and signing, ensuring domain separation and a secure signing mechanism. It allows users to exchange **ERC-20 tokens** with permit functionality in a simple, secure, and gas-efficient way.

## Key Features

- **EIP-712 Signature Validation**: Utilizes EIP-712 for signing and verifying swap orders, ensuring secure and tamper-proof data authentication.
- **ERC-20 Permit Support**: Enables token approvals via on-chain signatures, allowing seamless transactions without requiring gas for approval.
- **Customizable Order Matching**: Each swap is based on user-defined orders that include token details, amounts, and deadlines.
- **Full Validation Logic**: Ensures swap validity by verifying balances, order consistency, and token uniqueness.

## How It Works

1. **User Creates Signed Orders**: Both participants sign their respective swap orders using the EIP-712 standard.
2. **Contract Validates Orders**: The contract verifies the order details, signatures, token balances, and other constraints.
3. **Permit and Transfer**: The contract uses ERC-20 `permit` functionality to gain permission for transfers and executes the token exchange.
4. **Event Emitted**: Upon a successful swap, a `Swap` event is emitted with the details of the order IDs.

## Order Structure

The contract uses the following structure to define a swap order:

```solidity
struct Order {
    address owner;          // Creator of the swap order
    address tokenSell;      // Token the user wants to sell
    address tokenBuy;       // Token the user wants to buy
    uint256 orderId;        // Unique identifier for the order
    uint256 amountSell;     // Amount of tokens to sell
    uint256 amountBuy;      // Amount of tokens to buy
    uint256 deadline;       // Expiry timestamp of the order
}
```

Each order is also accompanied by a signature struct, which contains the components of the signed message:

```solidity
struct Signature {
    uint8 v;           // Recovery ID
    bytes32 r;         // Signature part R
    bytes32 s;         // Signature part S
}
```

## Example Workflow

1. **Two Users Prepare Orders:**
    - User A wants to exchange TokenAlpha for TokenBeta.
    - User B wants to exchange TokenBeta for TokenAlpha.
2. **Signatures Provided:** Both users sign their orders and provide them to the `PermitSwap` contract.
3. **Validation:** The contract validates that:
    - The sell and buy amounts match between the two orders.
    - Each token has sufficient balance and allowance.
    - The tokens being swapped are not identical.
4. **Token Exchange:** The contract executes the token transfers using `transferFrom`.
5. **Emit Event:** A `Swap` event is emitted with the IDs of the processed orders.

## Events

The contract emits the following event upon a successful swap:

```solidity
event Swap(uint256 orderId1, uint256 orderId2);
```

This provides transparency and traceability of all token swaps processed by the contract.

## Errors

The following custom errors are implemented for precise debugging:

- **InvalidAmounts**: The order sell and buy amounts are mismatched.
- **InvalidOwner**: The owner of the order is invalid or zero address.
- **InvalidTransfer**: Token transfer failed.
- **InvalidSignature**: Signature verification failed.
- **InvalidToken**: Token specified in the order is invalid.
- **IdenticalTokens**: The tokens being swapped are identical.
- **InvalidBalance**: Insufficient token balance to execute the order.

## Technical Details

- **Constructor Parameters:**
    - `_tokenAlpha`: Address of the `TokenAlpha` ERC-20 contract.
    - `_tokenBeta`: Address of the `TokenBeta` ERC-20 contract.
- **Dependencies:**
    - Uses `EIP712` for domain separation and structured data signing.
    - Uses `ECDSA` for signature recovery.
    - Relies on `ERC20Permit` for token approvals via signatures.

## Benefits

- **Gas Efficiency**: Eliminates the need for upfront `approve` calls by using `permit`.
- **User-Friendly**: Allows trades without requiring users to interact directly with each other's wallets.
- **Strong Security**: Implements thorough validation checks to prevent invalid swaps.

## Usage

This contract is ideal for DEXs (Decentralized Exchanges) or any scenario requiring simple and efficient peer-to-peer token swaps with minimal trust requirements.

---

Feel free to contribute or raise issues on this repository to improve the contract or its functionality!
