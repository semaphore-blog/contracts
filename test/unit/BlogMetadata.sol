pragma solidity 0.8.23;

import {SemaphoreFactory} from "src/SemaphoreFactory.sol";
import {SemaphoreFactoryTest} from "test/unit/utils.sol";
import {ISemaphore} from "@semaphore-protocol/contracts/interfaces/ISemaphore.sol";
import {ISemaphoreBlog} from "src/interfaces/ISemaphoreBlog.sol";

contract CreateAndJoinTest is SemaphoreFactoryTest {
    uint256 alicePk = 0xA11CE;
    uint256 bobPk = 0xB0B;
    address alice = vm.addr(alicePk);
    address bob = vm.addr(bobPk);

    function test_group_creator_should_be_able_to_set_metadata_uri() public {
        uint256 groupId = 1;
        string memory metadataUri = "ipfs://QmXyZ";
        address blog = _createGroup(groupId, alice);
        vm.prank(alice);
        ISemaphoreBlog(blog).setMetadataUri(metadataUri);
        string memory updatedMetadataUri = ISemaphoreBlog(blog).metadataUri();
        assertEq(updatedMetadataUri, metadataUri);
    }

    function test_non_creator_should_not_be_able_to_set_metadata_uri() public {
        uint256 groupId = 1;
        string memory metadataUri = "ipfs://QmXyZ";
        address blog = _createGroup(groupId, alice);
        vm.prank(bob);
        vm.expectRevert(ISemaphoreBlog.OnlyCreator.selector);
        ISemaphoreBlog(blog).setMetadataUri(metadataUri);
    }

    function test_group_creator_should_be_able_to_update_metadata_uri() public {
        uint256 groupId = 1;
        string memory metadataUri = "ipfs://QmXyZ";
        address blog = _createGroup(groupId, alice);
        vm.prank(alice);
        ISemaphoreBlog(blog).setMetadataUri(metadataUri);
        string memory updatedMetadataUri = "ipfs://QmUpdated";
        vm.prank(alice);
        ISemaphoreBlog(blog).setMetadataUri(updatedMetadataUri);
        string memory newMetadataUri = ISemaphoreBlog(blog).metadataUri();
        assertEq(newMetadataUri, updatedMetadataUri);
    }

    function test_multiple_groups_should_have_different_metadata_uris() public {
        uint256 groupId1 = 1;
        uint256 groupId2 = 2;
        string memory metadataUri1 = "ipfs://QmXyZ";
        string memory metadataUri2 = "ipfs://QmAbC";
        address blog1 = _createGroup(groupId1, alice);
        address blog2 = _createGroup(groupId2, bob);
        vm.prank(alice);
        ISemaphoreBlog(blog1).setMetadataUri(metadataUri1);
        vm.prank(bob);
        ISemaphoreBlog(blog2).setMetadataUri(metadataUri2);
        string memory updatedMetadataUri1 = ISemaphoreBlog(blog1).metadataUri();
        string memory updatedMetadataUri2 = ISemaphoreBlog(blog2).metadataUri();
        assertEq(updatedMetadataUri1, metadataUri1);
        assertEq(updatedMetadataUri2, metadataUri2);
    }
}
