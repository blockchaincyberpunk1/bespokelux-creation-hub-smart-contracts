// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title Audit Trail Contract for BespokeLux Creation Hub
 * @dev Logs critical actions across various platform contracts to enhance security, transparency, and facilitate monitoring.
 * It serves as a centralized log for actions like order placements, payments, disputes, and more.
 */
contract AuditTrailContract is AccessControl {
    bytes32 public constant AUDITOR_ROLE = keccak256("AUDITOR_ROLE");

    struct ActionLog {
        uint256 timestamp;
        string actionType;
        address initiator;
        string details;
    }

    // Array of all actions logged
    ActionLog[] private actionLogs;

    event ActionLogged(uint256 indexed logIndex, string actionType, address indexed initiator, string details);

    /**
     * @notice Constructor to set up the auditor role.
     */
    constructor() {
        _setupRole(AUDITOR_ROLE, msg.sender);
    }

    /**
     * @notice Logs a new action in the system.
     * @param actionType A string describing the type of action (e.g., "Order Placed", "Payment Released").
     * @param initiator The address of the user or contract that initiated the action.
     * @param details A string containing detailed information about the action.
     */
    function logAction(string memory actionType, address initiator, string memory details) public onlyRole(AUDITOR_ROLE) {
        actionLogs.push(ActionLog(block.timestamp, actionType, initiator, details));
        emit ActionLogged(actionLogs.length - 1, actionType, initiator, details);
    }

    /**
     * @notice Retrieves a specific log entry by its index.
     * @param logIndex The index of the log entry to retrieve.
     * @return A struct containing details about the action log (timestamp, actionType, initiator, details).
     */
    function getLogEntry(uint256 logIndex) public view returns (ActionLog memory) {
        require(logIndex < actionLogs.length, "AuditTrailContract: Log index out of range");
        return actionLogs[logIndex];
    }

    /**
     * @notice Retrieves all log entries.
     * @return An array of all logged actions.
     */
    function getAllLogs() public view returns (ActionLog[] memory) {
        return actionLogs;
    }
}
