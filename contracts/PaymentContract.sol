// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./OrderManagement.sol";

/**
 * @title Payment Contract for BespokeLux Creation Hub
 * @dev Manages escrow and payments for orders, ensuring funds are securely held and properly disbursed upon order completion.
 * Integrates with the Order Management Contract to handle payments correlated with order events.
 */
contract PaymentContract is AccessControl, ReentrancyGuard {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    OrderManagement private orderManagement;

    mapping(uint256 => uint256) public escrowBalances;

    // Event declarations
    event PaymentDeposited(uint256 indexed orderId, address indexed payer, uint256 amount);
    event PaymentReleased(uint256 indexed orderId, address indexed payee, uint256 amount);

    /**
     * @notice Constructor that sets the Order Management Contract address.
     * @param orderManagementAddress The address of the Order Management Contract.
     */
    constructor(address orderManagementAddress) {
        require(orderManagementAddress != address(0), "PaymentContract: invalid order management address");
        orderManagement = OrderManagement(orderManagementAddress);
        _setupRole(ADMIN_ROLE, msg.sender);
    }

    /**
     * @notice Deposits payment for an order into escrow.
     * @dev Requires that the caller is a customer with a valid order.
     * @param orderId The ID of the order for which the payment is being made.
     */
    function depositPayment(uint256 orderId) external payable nonReentrant {
        OrderManagement.Order memory order = orderManagement.getOrder(orderId);
        require(msg.sender == order.customer, "PaymentContract: Caller is not the order's customer");
        require(msg.value == order.price, "PaymentContract: Incorrect payment amount");
        require(!order.isFulfilled, "PaymentContract: Order already fulfilled");

        escrowBalances[orderId] += msg.value;
        emit PaymentDeposited(orderId, msg.sender, msg.value);
    }

    /**
     * @notice Releases the payment from escrow to the manufacturer upon order fulfillment.
     * @dev Can only be called by an admin after the order is marked as fulfilled.
     * @param orderId The ID of the order for which the payment is to be released.
     */
    function releasePayment(uint256 orderId) external onlyRole(ADMIN_ROLE) nonReentrant {
        OrderManagement.Order memory order = orderManagement.getOrder(orderId);
        require(order.isFulfilled, "PaymentContract: Order is not fulfilled");

        uint256 paymentAmount = escrowBalances[orderId];
        require(paymentAmount > 0, "PaymentContract: No funds to release");

        address payee = order.customer; // Assuming the manufacturer or an address is stored on the order
        escrowBalances[orderId] = 0;
        (bool sent, ) = payee.call{value: paymentAmount}("");
        require(sent, "PaymentContract: Failed to send Ether");

        emit PaymentReleased(orderId, payee, paymentAmount);
    }

    /**
     * @notice Returns the escrow balance for a specific order.
     * @param orderId The ID of the order to check the escrow balance for.
     * @return The amount of funds held in escrow for the order.
     */
    function getEscrowBalance(uint256 orderId) external view returns (uint256) {
        return escrowBalances[orderId];
    }
}
