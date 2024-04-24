// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./ProductCatalog.sol";

/**
 * @title Order Management Contract for BespokeLux Creation Hub
 * @dev Handles the creation, tracking, and management of orders for personalized luxury products.
 * Relies on the Product Catalog Contract for product references and the Access Control Contract for role-based permissions.
 */
contract OrderManagement is AccessControl {
    // Define roles with specific access permissions
    bytes32 public constant CUSTOMER_ROLE = keccak256("CUSTOMER_ROLE");

    struct Order {
        uint256 orderId;
        address customer;
        uint256 productId;
        string customizationDetails;
        uint256 price;
        bool isFulfilled;
    }

    Order[] public orders;
    uint256 private nextOrderId = 0;

    ProductCatalog private catalog;

    // Event declarations
    event OrderPlaced(uint256 indexed orderId, address indexed customer, uint256 productId, uint256 price);
    event OrderFulfilled(uint256 indexed orderId, address indexed customer);

    /**
     * @notice Constructor that sets the Product Catalog Contract address.
     * @param catalogAddress The address of the Product Catalog Contract.
     */
    constructor(address catalogAddress) {
        require(catalogAddress != address(0), "OrderManagement: invalid catalog address");
        catalog = ProductCatalog(catalogAddress);
    }

    /**
     * @notice Places a new order for a product with specific customizations.
     * @dev Requires the caller to have the CUSTOMER_ROLE. Emits an OrderPlaced event.
     * @param productId The ID of the product being ordered.
     * @param customizationDetails Details of the customizations requested by the customer.
     * @param price Total price of the product including customizations.
     * @return The ID of the newly created order.
     */
    function placeOrder(uint256 productId, string memory customizationDetails, uint256 price) public onlyRole(CUSTOMER_ROLE) returns (uint256) {
        ProductCatalog.Product memory product = catalog.getProduct(productId);
        require(product.isActive, "OrderManagement: Product is not active");

        orders.push(Order(nextOrderId, msg.sender, productId, customizationDetails, price, false));
        emit OrderPlaced(nextOrderId, msg.sender, productId, price);
        return nextOrderId++;
    }

    /**
     * @notice Marks an order as fulfilled.
     * @dev Requires the caller to have the ADMIN_ROLE. Emits an OrderFulfilled event.
     * @param orderId The ID of the order to fulfill.
     */
    function fulfillOrder(uint256 orderId) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(orderId < nextOrderId, "OrderManagement: Order does not exist");
        Order storage order = orders[orderId];
        require(!order.isFulfilled, "OrderManagement: Order already fulfilled");

        order.isFulfilled = true;
        emit OrderFulfilled(orderId, order.customer);
    }

    /**
     * @notice Retrieves order details by ID.
     * @param orderId The ID of the order to retrieve.
     * @return Order details including orderId, customer, productId, customization details, price, and fulfillment status.
     */
    function getOrder(uint256 orderId) public view returns (Order memory) {
        require(orderId < nextOrderId, "OrderManagement: Order does not exist");
        return orders[orderId];
    }
}
