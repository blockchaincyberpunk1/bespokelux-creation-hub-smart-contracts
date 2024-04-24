// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title AccessControl for BespokeLux Creation Hub
 * @dev Manages role-based access control for the platform. Supports multiple roles.
 * The contract uses the AccessControl library from OpenZeppelin which provides an easier and secure way to handle roles.
 */
contract BespokeLuxAccessControl is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant CUSTOMER_ROLE = keccak256("CUSTOMER_ROLE");
    bytes32 public constant MANUFACTURER_ROLE = keccak256("MANUFACTURER_ROLE");

    /**
     * @dev Constructor that sets up the initial roles and grants `ADMIN_ROLE` to the deployer.
     */
    constructor() {
        _setupRole(ADMIN_ROLE, msg.sender);
        _setRoleAdmin(CUSTOMER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(MANUFACTURER_ROLE, ADMIN_ROLE);
    }

    /**
     * @dev Modifier to check if the caller has the admin role.
     */
    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "BespokeLuxAccessControl: Caller is not an admin");
        _;
    }

    /**
     * @dev Grants `role` to `account`. Only admins can grant roles.
     * @param role The role to be granted.
     * @param account The account that will receive the role.
     */
    function grantRole(bytes32 role, address account) public override onlyAdmin {
        super.grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`. Only admins can revoke roles.
     * @param role The role to be revoked.
     * @param account The account to be stripped of the role.
     */
    function revokeRole(bytes32 role, address account) public override onlyAdmin {
        super.revokeRole(role, account);
    }

    /**
     * @dev Adds a customer role to an `account`. Can only be called by an admin.
     * @param account The account that will be assigned the customer role.
     */
    function addCustomer(address account) public onlyAdmin {
        grantRole(CUSTOMER_ROLE, account);
    }

    /**
     * @dev Adds a manufacturer role to an `account`. Can only be called by an admin.
     * @param account The account that will be assigned the manufacturer role.
     */
    function addManufacturer(address account) public onlyAdmin {
        grantRole(MANUFACTURER_ROLE, account);
    }

    /**
     * @dev Checks if an `account` is an admin.
     * @param account The account to check.
     * @return bool Returns true if the `account` has the admin role.
     */
    function isAdmin(address account) public view returns (bool) {
        return hasRole(ADMIN_ROLE, account);
    }

    /**
     * @dev Checks if an `account` is a customer.
     * @param account The account to check.
     * @return bool Returns true if the `account` has the customer role.
     */
    function isCustomer(address account) public view returns (bool) {
        return hasRole(CUSTOMER_ROLE, account);
    }

    /**
     * @dev Checks if an `account` is a manufacturer.
     * @param account The account to check.
     * @return bool Returns true if the `account` has the manufacturer role.
     */
    function isManufacturer(address account) public view returns (bool) {
        return hasRole(MANUFACTURER_ROLE, account);
    }
}
