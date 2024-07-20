// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;
import "@semaphore-protocol/contracts/interfaces/ISemaphore.sol";
import {InvitationSigUtils} from "./InvitationSigUtils.sol";
import {ISemaphoreBlog} from "./interfaces/ISemaphoreBlog.sol";
import {SemaphoreBlog} from "./SemaphoreBlog.sol";

contract SemaphoreFactory {
    address public immutable semaphore; // Semaphore contract address
    event BlogCreated(uint256 groupId, address creator, address blog);

    error FailedToCreateBlog();

    constructor(address _semaphore) {
        semaphore = _semaphore;
    }

    /**
     * @notice Creates a new group in the Semaphore contract and sets the msg.sender as the creator.
     * @dev Calls the createGroup function in the Semaphore contract.
     * @return groupId The ID of the newly created group.
     * @return blog The address of the newly created blog contract.
     */
    function createGroup() external returns (uint256 groupId, address blog) {
        address blog;
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, block.number)); // one blog per block per creator
        bytes memory creationCode = getCreationCode(msg.sender);

        assembly {
            blog := create2(
                callvalue(),
                add(creationCode, 0x20),
                mload(creationCode),
                salt
            )
        }

        if (blog == address(0)) revert FailedToCreateBlog();

        groupId = ISemaphoreBlog(blog).groupId();
        emit BlogCreated(groupId, msg.sender, blog);
    }

    /**
     * @notice Returns the creation code for the SemaphoreBlog contract.
     * @dev Encodes the creation code for the SemaphoreBlog contract with the Semaphore address and creator address.
     * @param creator The address of the creator of the blog.
     * @return creationCode The creation code for the SemaphoreBlog contract.
     */
    function getCreationCode(
        address creator
    ) public view returns (bytes memory creationCode) {
        creationCode = abi.encodePacked(
            type(SemaphoreBlog).creationCode,
            abi.encode(semaphore, creator)
        );
    }

    /**
     * @notice Computes the address of a SemaphoreBlog contract.
     * @dev Computes the address of a SemaphoreBlog contract using the creator address and a salt.
     * @param salt The salt used to compute the address.
     * @param creator The address of the creator of the blog.
     * @return blog The address of the SemaphoreBlog contract.
     */
    function computeAddress(
        bytes32 salt,
        address creator
    ) external view returns (address) {
        bytes memory creationCode = getCreationCode(creator);
        return
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                bytes1(0xff),
                                address(this),
                                salt,
                                keccak256(creationCode)
                            )
                        )
                    )
                )
            );
    }
}
