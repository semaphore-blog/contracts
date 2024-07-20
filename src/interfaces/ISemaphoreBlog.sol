// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

interface ISemaphoreBlog {
    // Events
    event MetadataUpdated(string oldMetadataUri, string newMetadataUri);

    // Errors
    error InvalidInvitationSignature();
    error OnlyCreator();

    // View functions
    function semaphore() external view returns (address);
    function groupId() external view returns (uint256);
    function domainSeparator() external view returns (bytes32);
    function creator() external view returns (address);
    function metadataUri() external view returns (string memory);
    function nonceUsed(uint256 _nonce) external view returns (bool);

    // Function to join with an invitation code
    function joinWithInvitationCode(
        uint256 _nonce,
        uint256 _deadline,
        uint256 _identityCommitment,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    // Function to set the metadata URI
    function setMetadataUri(string calldata _metadataUri) external;
}
