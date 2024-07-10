// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;
import "@semaphore-protocol/contracts/interfaces/ISemaphore.sol";
import {InvitationSigUtils} from "./InvitationSigUtils.sol";

contract SemaphoreFactory {
    address public immutable semaphore; // Semaphore contract address
    mapping(uint256 => address) public creator; // Group ID to creator address
    mapping(uint256 => bool) public nonceUsed; // nonce to used status

    event GroupCreated(uint256 groupId, address creator);

    InvitationSigUtils public sigUtils;

    error InvalidInvitationSignature();

    constructor(address _semaphore) {
        semaphore = _semaphore;

        sigUtils = new InvitationSigUtils(
            keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                    ),
                    keccak256("SemaphoreFactory"),
                    keccak256("0.0.1"),
                    block.chainid,
                    address(this)
                )
            )
        );
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

    /**
     * @notice Allows a user to join a group using an invitation code.
     * @dev Verifies the signature of the invitation code and adds the user to the group.
     * @param _groupId The ID of the group.
     * @param _nonce The nonce of the invitation code.
     * @param _deadline The deadline of the invitation code. 0 means no deadline.
     * @param _identityCommitment The semaphore identity commitment of the user.
     * @param _v The recovery ID of the signature.
     * @param _r The R value of the signature.
     * @param _s The S value of the signature.
     */
    function joinWithInvitationCode(
        uint256 _groupId,
        uint256 _nonce,
        uint256 _deadline,
        uint256 _identityCommitment,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external {
        if (nonceUsed[_nonce]) revert InvalidInvitationSignature();
        nonceUsed[_nonce] = true;

        if (_deadline != 0 && block.timestamp > _deadline)
            revert InvalidInvitationSignature();

        InvitationSigUtils.Invitation memory invitation = InvitationSigUtils
            .Invitation({
                groupId: _groupId,
                nonce: _nonce,
                deadline: _deadline
            });

        bytes32 digest = sigUtils.getTypedDataHash(invitation);
        address signer = ecrecover(digest, _v, _r, _s);

        if (signer != creator[_groupId]) revert InvalidInvitationSignature();

        ISemaphore(semaphore).addMember(_groupId, _identityCommitment);
    }
}
