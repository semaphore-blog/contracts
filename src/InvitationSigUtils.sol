// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

contract InvitationSigUtils {
    struct Invitation {
        uint256 groupId;
        uint256 nonce;
        uint256 deadline;
    }

    bytes32 public immutable DOMAIN_SEPARATOR;
    bytes32 public constant INVITATION_TYPEHASH =
        keccak256("Invitation(uint256 groupId,uint256 nonce,uint256 deadline)");

    constructor(bytes32 _DOMAIN_SEPARATOR) {
        DOMAIN_SEPARATOR = _DOMAIN_SEPARATOR;
    }

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

    function getTypedDataHash(
        Invitation memory _invitation
    ) public view returns (bytes32) {
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
