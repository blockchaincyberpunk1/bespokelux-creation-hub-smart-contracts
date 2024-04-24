// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Product Catalog Contract for BespokeLux Creation Hub
 * @dev Manages a catalog of luxury products that can be personalized by customers.
 * Provides functionalities to add, update, and remove products from the catalog.
 */
contract ProductCatalog {
    struct Product {
        uint256 id;
        string name;
        string description;
        uint256 basePrice;  // Base price in wei
        bool isActive;
    }

    Product[] private products;
    uint256 private nextProductId = 0;

    // Mapping from product ID to their index in the products array
    mapping(uint256 => uint256) private productIndex;

    // Event declarations
    event ProductAdded(uint256 indexed productId, string name, uint256 basePrice);
    event ProductUpdated(uint256 indexed productId, string name, uint256 basePrice);
    event ProductDeactivated(uint256 indexed productId);

    /**
     * @notice Adds a new product to the catalog
     * @dev Emits a ProductAdded event on successful addition.
     * @param name The name of the product
     * @param description The description of the product
     * @param basePrice The base price of the product in wei
     */
    function addProduct(string memory name, string memory description, uint256 basePrice) public {
        products.push(Product(nextProductId, name, description, basePrice, true));
        productIndex[nextProductId] = products.length - 1;
        emit ProductAdded(nextProductId, name, basePrice);
        nextProductId++;
    }

    /**
     * @notice Updates an existing product's details
     * @dev Emits a ProductUpdated event on successful update.
     * @param productId The ID of the product to update
     * @param name New name of the product
     * @param description New description of the product
     * @param basePrice New base price of the product in wei
     */
    function updateProduct(uint256 productId, string memory name, string memory description, uint256 basePrice) public {
        require(productId < nextProductId, "ProductCatalog: Product does not exist");
        require(products[productIndex[productId]].isActive, "ProductCatalog: Product is not active");

        Product storage product = products[productIndex[productId]];
        product.name = name;
        product.description = description;
        product.basePrice = basePrice;
        emit ProductUpdated(productId, name, basePrice);
    }

    /**
     * @notice Deactivates a product from the catalog
     * @dev Emits a ProductDeactivated event on successful deactivation.
     * @param productId The ID of the product to deactivate
     */
    function deactivateProduct(uint256 productId) public {
        require(productId < nextProductId, "ProductCatalog: Product does not exist");
        require(products[productIndex[productId]].isActive, "ProductCatalog: Product already deactivated");

        Product storage product = products[productIndex[productId]];
        product.isActive = false;
        emit ProductDeactivated(productId);
    }

    /**
     * @notice Retrieves product details by ID
     * @param productId The ID of the product to retrieve
     * @return Product details including id, name, description, base price, and active status
     */
    function getProduct(uint256 productId) public view returns (Product memory) {
        require(productId < nextProductId, "ProductCatalog: Product does not exist");
        return products[productIndex[productId]];
    }
}
