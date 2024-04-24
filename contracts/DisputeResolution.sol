// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./OrderManagement.sol";
import "./PaymentContract.sol";

/**
 * @title Dispute Resolution Contract for BespokeLux Creation Hub
 * @dev Manages and resolves disputes between customers and manufacturers.
 * Interacts with Order Management and Payment Contracts to enforce or reverse transactions based on dispute outcomes.
 */
contract DisputeResolution is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    struct Dispute {
        uint256 orderId;
        address complainant;
        string reason;
        bool resolved;
        bool decision; // true for customer, false for manufacturer
    }

    Dispute[] public disputes;
    OrderManagement private orderManagement;
    PaymentContract private paymentContract;

    // Mapping from order ID to dispute index for quick lookup
    mapping(uint256 => uint256) private orderDisputeIndex;

    event DisputeOpened(uint256 indexed disputeId, uint256 indexed orderId, address complainant);
    event DisputeResolved(uint256 indexed disputeId, uint256 indexed orderId, bool decision);

    /**
     * @notice Constructor to set Order Management and Payment Contract addresses.
     * @param orderManagementAddress The address of the Order Management contract.
     * @param paymentContractAddress The address of the Payment Contract.
     */
    constructor(address orderManagementAddress, address paymentContractAddress) {
        require(orderManagementAddress != address(0) && paymentContractAddress != address(0), "DisputeResolution: Invalid address");
        orderManagement = OrderManagement(orderManagementAddress);
        paymentContract = PaymentContract(paymentContractAddress);
        _setupRole(ADMIN_ROLE, msg.sender);
    }

    /**
     * @notice Opens a dispute for a specific order.
     * @param orderId The ID of the order that is being disputed.
     * @param reason The reason for the dispute.
     */
    function openDispute(uint256 orderId, string memory reason) public {
        OrderManagement.Order memory order = orderManagement.getOrder(orderId);
        require(msg.sender == order.customer || msg.sender == orderManagement.ADMIN_ROLE, "DisputeResolution: Unauthorized");
        require(orderDisputeIndex[orderId] == 0, "DisputeResolution: Dispute already exists for this order");

        disputes.push(Dispute(orderId, msg.sender, reason, false, false));
        uint256 disputeId = disputes.length - 1;
        orderDisputeIndex[orderId] = disputeId + 1; // +1 to differentiate from default value 0
        emit DisputeOpened(disputeId, orderId, msg.sender);
    }

    /**
     * @notice Resolves a dispute, deciding in favor of either the customer or manufacturer.
     * @dev Can only be called by an admin. Modifies the order and payment statuses accordingly.
     * @param disputeId The ID of the dispute to resolve.
     * @param decision The decision of the dispute (true for customer, false for manufacturer).
     */
    function resolveDispute(uint256 disputeId, bool decision) public onlyRole(ADMIN_ROLE) {
        Dispute storage dispute = disputes[disputeId];
        require(!dispute.resolved, "DisputeResolution: Already resolved");

        dispute.decision = decision;
        dispute.resolved = true;

        if (decision) {
            paymentContract.releasePayment(dispute.orderId);
        } else {
            // Additional logic if the decision is for the manufacturer (e.g., payment retention)
        }

        emit DisputeResolved(disputeId, dispute.orderId, decision);
    }

    /**
     * @notice Retrieves details about a specific dispute.
     * @param disputeId The ID of the dispute to query.
     * @return Details of the dispute including order ID, complainant, reason, resolved status, and decision.
     */
    function getDispute(uint256 disputeId) public view returns (Dispute memory) {
        return disputes[disputeId];
    }
}
