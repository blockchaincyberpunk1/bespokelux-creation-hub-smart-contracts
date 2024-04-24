# BespokeLux Creation Hub dApp Smart Contracts

## Summary
The BespokeLux Creation Hub is an innovative decentralized platform designed to connect customers with luxury goods manufacturers for personalized products, using blockchain technology to ensure security, transparency, and efficiency in managing orders and payments. Below are the details of the smart contracts that facilitate the platform's functionality:

## Access Control Contract (AccessControl.sol)
- **Description**: Manages role-based permissions across the platform, ensuring secure access control for different functionalities.
- **Contract Path**: `contracts/AccessControl.sol`
- **Status**: In progress

## Product Catalog Contract (ProductCatalog.sol)
- **Description**: Handles the listing of products available for customization and purchase on the platform.
- **Contract Path**: `contracts/ProductCatalog.sol`
- **Status**: In progress

## Order Management Contract (OrderManagement.sol)
- **Description**: Central contract for creating, tracking, and updating orders.
- **Contract Path**: `contracts/OrderManagement.sol`
- **Status**: In progress

## Payment Contract (PaymentContract.sol)
- **Description**: Manages escrow and payments, ensuring funds are securely held and properly disbursed upon order completion.
- **Contract Path**: `contracts/PaymentContract.sol`
- **Status**: In progress

## Dispute Resolution Contract (DisputeResolution.sol)
- **Description**: Provides mechanisms for handling conflicts between customers and manufacturers, crucial for maintaining trust and service quality.
- **Contract Path**: `contracts/DisputeResolution.sol`
- **Status**: In progress

## Rating and Review Contract (RatingReviewContract.sol)
- **Description**: Enables customers to provide feedback on manufacturers post-order fulfillment, helping to maintain high standards and transparency.
- **Contract Path**: `contracts/RatingReviewContract.sol`
- **Status**: In progress

## Audit Trail Contract (AuditTrailContract.sol)
- **Description**: Logs all significant actions on the platform to enhance security and provide transparency for all transactions and changes.
- **Contract Path**: `contracts/AuditTrailContract.sol`
- **Status**: In progress

## Getting Started
To get started with the development or testing of these contracts:
1. Clone the repository to your local machine.
2. Ensure you have Node.js and npm installed.
3. Run `npm install` to install all dependencies.
4. Compile the contracts using `npx hardhat compile`.
5. Test the contracts using `npx hardhat test`.

## Contribution Guidelines
Contributions are welcome! Please ensure that your code adheres to the existing code standards and has passed all tests. Submit a pull request with detailed comments and documentation for any proposed changes.
