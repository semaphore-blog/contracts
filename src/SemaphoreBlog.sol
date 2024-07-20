// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;
import "@semaphore-protocol/contracts/interfaces/ISemaphore.sol";
import {InvitationSigUtils} from "./InvitationSigUtils.sol";
import {ISemaphoreBlog} from "src/interfaces/ISemaphoreBlog.sol";

contract SemaphoreBlog is ISemaphoreBlog {
    address public immutable semaphore; // Semaphore contract address
    uint256 public immutable groupId; // semaphore group ID
    bytes32 public immutable domainSeparator; // EIP712 domain separator - used for invitation signature verification

    address public creator;
    string public metadataUri;

    mapping(uint256 => bool) public nonceUsed; // nonce to used status

    constructor(address _semaphore, address _creator) {
        semaphore = _semaphore;
        creator = _creator;

        groupId = ISemaphore(semaphore).createGroup(address(this));

        domainSeparator = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256("SemaphoreBlog"),
                keccak256("0.0.1"),
                block.chainid,
                address(this)
            )
        );
    }

    /**
     * @notice Allows a user to join a group using an invitation code.
     * @dev Verifies the signature of the invitation code and adds the user to the group.
     * @param _nonce The nonce of the invitation code.
     * @param _deadline The deadline of the invitation code. 0 means no deadline.
     * @param _identityCommitment The semaphore identity commitment of the user.
     * @param _v The recovery ID of the signature.
     * @param _r The R value of the signature.
     * @param _s The S value of the signature.
     */
    function joinWithInvitationCode(
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
            .Invitation({groupId: groupId, nonce: _nonce, deadline: _deadline});

        bytes32 digest = InvitationSigUtils.getTypedDataHash(
            domainSeparator,
            invitation
        );
        address signer = ecrecover(digest, _v, _r, _s);

        if (signer != creator) revert InvalidInvitationSignature();

        ISemaphore(semaphore).addMember(groupId, _identityCommitment);
    }

    /**
     * @notice Sets the metadata URI of a group.
     * @param _metadataUri The metadata URI.
     */
    function setMetadataUri(string calldata _metadataUri) external onlyCreator {
        emit MetadataUpdated(metadataUri, _metadataUri);
        metadataUri = _metadataUri;
    }

    modifier onlyCreator() {
        if (msg.sender != creator) revert OnlyCreator();
        _;
    }
}
