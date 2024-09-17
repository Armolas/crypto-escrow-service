# Crypto Escrow Service on Stacks Blockchain

A decentralized smart contract for facilitating escrow transactions on the Stacks blockchain. This project allows users to securely engage in transactions by holding funds in escrow until the buyer confirms receipt of goods or services. The contract also supports arbitration in case of disputes.

## Features

- **Create Escrow**: Buyers can create an escrow by depositing funds.
- **Confirm Receipt**: Buyers can confirm receipt of goods/services, releasing funds to the seller.
- **Request Refund**: Buyers can request a refund if goods or services are not delivered.
- **Arbitrate Dispute**: An arbiter can resolve disputes between the buyer and seller.
- **Automatic Fund Transfer**: Funds are transferred automatically based on actions taken within the contract (confirmation, arbitration, or refund).

## How It Works

1. **Buyer** initiates an escrow by specifying the seller, arbiter, and deposit amount.
2. **Seller** provides the agreed-upon goods/services.
3. **Buyer** confirms receipt, releasing funds to the seller.
4. If there’s a dispute, the **arbiter** intervenes to settle the issue.
5. Funds are transferred based on the action: confirmation, arbitration, or refund request.

---

## Smart Contract Overview

The smart contract is designed to facilitate and manage escrows with the following components:

### Constants
- **Escrow Status**
  - `0`: Open
  - `1`: Completed (confirmed)
  - `2`: Refunded

---

### Data Maps and Variables

- **`escrow-contracts`**:  
  A map storing escrow information.  
  Key: `{id: uint}` (unique identifier for each escrow)  
  Value:  
  - `buyer`: The principal (address) of the buyer.
  - `seller`: The principal of the seller.
  - `arbiter`: The principal of the arbiter responsible for dispute resolution.
  - `amount`: The escrowed amount in STX.
  - `status`: The current status of the escrow (`0` = Open, `1` = Completed, `2` = Refunded).

- **`escrow-counter`**:  
  A counter that increments with each new escrow created, used to assign unique IDs to escrows.

---

### Private Functions

- **`(get-escrow (id uint))`**  
  Retrieves escrow data by its unique ID.  
  - **Params**:  
    `id` (uint): The unique identifier of the escrow.  
  - **Returns**:  
    The escrow data if found, or `none` if not found.

---

### Public Functions

#### 1. **`(create-escrow (seller principal) (arbiter principal) (amount uint))`**
   Creates a new escrow contract.

   - **Params**:
     - `seller` (principal): Address of the seller.
     - `arbiter` (principal): Address of the arbiter.
     - `amount` (uint): Amount in STX to be held in escrow.
   - **Returns**:  
     The unique ID of the created escrow.
   - **Actions**:
     - Checks if the buyer (tx-sender) has sufficient funds.
     - Ensures that the buyer, seller, and arbiter are different parties.
     - Stores the escrow information in the contract’s map.
     - Increments the `escrow-counter`.

#### 2. **`(confirm-receipt (id uint))`**
   Allows the buyer to confirm receipt of goods/services, releasing funds to the seller.

   - **Params**:
     - `id` (uint): The unique ID of the escrow.
   - **Returns**:  
     `ok true` if the transaction succeeds, or an error code if it fails.
   - **Actions**:
     - Ensures the buyer is the one confirming the receipt.
     - Transfers the escrowed amount to the seller.
     - Updates the escrow status to `1` (Completed).

#### 3. **`(request-refund (id uint))`**
   Allows the buyer to request a refund if goods or services are not received.

   - **Params**:
     - `id` (uint): The unique ID of the escrow.
   - **Returns**:  
     `ok true` if the refund is processed successfully, or an error code if it fails.
   - **Actions**:
     - Ensures only the buyer can request a refund.
     - Refunds the escrowed amount to the buyer.
     - Updates the escrow status to `2` (Refunded).

#### 4. **`(arbitrate (id uint) (decision uint))`**
   Allows the arbiter to resolve disputes by deciding whether to release funds to the seller or refund them to the buyer.

   - **Params**:
     - `id` (uint): The unique ID of the escrow.
     - `decision` (uint): `1` to release funds to the seller, `2` to refund the buyer.
   - **Returns**:  
     `ok true` if the arbitration is processed successfully, or an error code if it fails.
   - **Actions**:
     - Ensures only the assigned arbiter can arbitrate.
     - Ensures the decision is valid (`1` for releasing to the seller, `2` for refunding the buyer).
     - Transfers the funds based on the arbiter’s decision.
     - Updates the escrow status to the decision made (`1` = Released, `2` = Refunded).

---

## Error Codes

- **`u1`**: Unauthorized action (e.g., non-buyer attempting to confirm).
- **`u2`**: Transfer failure.
- **`u4`**: Only the buyer can request a refund.
- **`u5`**: Refund transfer failed.
- **`u7`**: Only the assigned arbiter can arbitrate disputes.
- **`u10`**: Escrow already completed.
- **`u11`**: Escrow already refunded.
- **`u12`**: Invalid status for arbitration.
- **`u13`**: Invalid decision (must be `1` or `2`).
- **`u404`**: Escrow not found.

---

## Getting Started

### Requirements

- **Stacks Blockchain**: You will need a local or testnet instance of the Stacks blockchain to deploy and interact with the contract.
- **Clarity**: The smart contract is written in Clarity, the Stacks blockchain’s language for smart contracts.

### Deployment

1. Clone the repository:
   ```bash
   git clone <repo-url>
   cd <repo-folder>

2. Deploy the contract using the Stacks CLI or your preferred development environment.

### Future Improvements

- Add a user-friendly front end to interact with the smart contract.
- Add more granular control over escrow conditions (e.g., time locks, multi-party agreements).
- Enhance security with multi-sig options for the arbiter.
