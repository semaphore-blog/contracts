// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/**
 * @title InvitationSigUtils
 * @notice ERC712 signature utility for invitation codes
 */
library InvitationSigUtils {
    /**
     * @notice Invitation struct
     * @param groupId The ID of the group.
     * @param nonce The nonce of the invitation code. Must be unique for each invitation.
     * @param deadline The deadline of the invitation code. 0 means no deadline.
     */
    struct Invitation {
        uint256 groupId;
        uint256 nonce;
        uint256 deadline;
    }

    bytes32 public constant INVITATION_TYPEHASH =
        keccak256("Invitation(uint256 groupId,uint256 nonce,uint256 deadline)");

    /**
     * @notice Generates the hash of the invitation struct
     * @param _invitation The invitation struct
     * @return The hash of the invitation struct
     */
    function getStructHash(
        Invitation memory _invitation
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    INVITATION_TYPEHASH,
                    _invitation.groupId,
                    _invitation.nonce,
                    _invitation.deadline
                )
            );
    }

    /**
     * @notice Invitation struct type hash according to EIP712
     * @param DOMAIN_SEPARATOR The domain separator hash
     * @param _invitation The invitation struct
     * @return The hash of the invitation struct with the domain separator
     */
    function getTypedDataHash(
        bytes32 DOMAIN_SEPARATOR,
        Invitation memory _invitation
    ) external pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    getStructHash(_invitation)
                )
            );
    }
}
