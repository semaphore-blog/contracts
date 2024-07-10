// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;
import "@semaphore-protocol/contracts/interfaces/ISemaphore.sol";

contract SemaphoreFactory {
    address public immutable semaphore; // Semaphore contract address
    mapping(uint256 => address) public creator; // Group ID to creator address

    event GroupCreated(uint256 groupId, address creator);

    constructor(address _semaphore) {
        semaphore = _semaphore;
    }

    /**
     * @notice Creates a new group in the Semaphore contract and sets the msg.sender as the creator.
     * @dev Calls the createGroup function in the Semaphore contract.
     * @return groupId The ID of the newly created group.
     */
    function createGroup() external returns (uint256 groupId) {
        groupId = ISemaphore(semaphore).createGroup(address(this));
        creator[groupId] = msg.sender;

        emit GroupCreated(groupId, msg.sender);
    }
}
