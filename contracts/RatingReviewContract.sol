// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./OrderManagement.sol";

/**
 * @title Rating and Review Contract for BespokeLux Creation Hub
 * @dev Manages the submission of ratings and reviews for manufacturers by customers post-order fulfillment.
 * Requires integration with the Order Management Contract to ensure reviews pertain to completed orders.
 */
contract RatingReviewContract is AccessControl {
    bytes32 public constant CUSTOMER_ROLE = keccak256("CUSTOMER_ROLE");

    struct Review {
        uint256 orderId;
        address reviewer;
        uint8 rating; // Rating out of 5
        string comment;
    }

    // Map manufacturer address to a list of reviews
    mapping(address => Review[]) public reviews;

    // Order Management Contract Interface
    OrderManagement private orderManagement;

    event ReviewSubmitted(uint256 indexed orderId, address indexed reviewer, uint8 rating, string comment);

    /**
     * @notice Constructor sets the Order Management Contract address.
     * @param orderManagementAddress The address of the Order Management contract.
     */
    constructor(address orderManagementAddress) {
        require(orderManagementAddress != address(0), "RatingReviewContract: invalid order management address");
        orderManagement = OrderManagement(orderManagementAddress);
        _setupRole(CUSTOMER_ROLE, msg.sender);
    }

    /**
     * @notice Allows a customer to submit a review and rating for a completed order.
     * @dev Checks if the order is fulfilled and if the sender is the customer who placed the order.
     * @param orderId The ID of the order being reviewed.
     * @param rating The rating out of 5.
     * @param comment The text comment of the review.
     */
    function submitReview(uint256 orderId, uint8 rating, string memory comment) public onlyRole(CUSTOMER_ROLE) {
        require(rating > 0 && rating <= 5, "RatingReviewContract: Rating must be between 1 and 5");
        OrderManagement.Order memory order = orderManagement.getOrder(orderId);
        require(order.isFulfilled, "RatingReviewContract: Order not fulfilled");
        require(order.customer == msg.sender, "RatingReviewContract: Reviewer is not the order customer");

        address manufacturer = order.customer; // Assuming the manufacturer's address is stored on the order
        reviews[manufacturer].push(Review(orderId, msg.sender, rating, comment));
        emit ReviewSubmitted(orderId, msg.sender, rating, comment);
    }

    /**
     * @notice Retrieves all reviews for a specific manufacturer.
     * @param manufacturer The address of the manufacturer whose reviews are being queried.
     * @return A list of reviews for the manufacturer.
     */
    function getReviewsForManufacturer(address manufacturer) public view returns (Review[] memory) {
        return reviews[manufacturer];
    }
}
