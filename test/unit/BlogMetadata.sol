pragma solidity 0.8.23;

import {SemaphoreFactory} from "src/SemaphoreFactory.sol";
import {SemaphoreFactoryTest} from "test/unit/utils.sol";
import {ISemaphore} from "@semaphore-protocol/contracts/interfaces/ISemaphore.sol";

contract CreateAndJoinTest is SemaphoreFactoryTest {
    uint256 alicePk = 0xA11CE;
    uint256 bobPk = 0xB0B;
    address alice = vm.addr(alicePk);
    address bob = vm.addr(bobPk);

    function test_group_creator_should_be_able_to_set_metadata_uri() public {
        uint256 groupId = 1;
        string memory metadataUri = "ipfs://QmXyZ";
        _createGroup(groupId, alice);
        vm.prank(alice);
        factory.setMetadataUri(groupId, metadataUri);
        string memory updatedMetadataUri = factory.metadataUri(groupId);
        assertEq(updatedMetadataUri, metadataUri);
    }

    function test_non_creator_should_not_be_able_to_set_metadata_uri() public {
        uint256 groupId = 1;
        string memory metadataUri = "ipfs://QmXyZ";
        _createGroup(groupId, alice);
        vm.prank(bob);
        vm.expectRevert(SemaphoreFactory.OnlyCreator.selector);
        factory.setMetadataUri(groupId, metadataUri);
    }

    function test_group_creator_should_be_able_to_update_metadata_uri() public {
        uint256 groupId = 1;
        string memory metadataUri = "ipfs://QmXyZ";
        _createGroup(groupId, alice);
        vm.prank(alice);
        factory.setMetadataUri(groupId, metadataUri);
        string memory updatedMetadataUri = "ipfs://QmUpdated";
        vm.prank(alice);
        factory.setMetadataUri(groupId, updatedMetadataUri);
        string memory newMetadataUri = factory.metadataUri(groupId);
        assertEq(newMetadataUri, updatedMetadataUri);
    }

    function test_multiple_groups_should_have_different_metadata_uris() public {
        uint256 groupId1 = 1;
        uint256 groupId2 = 2;
        string memory metadataUri1 = "ipfs://QmXyZ";
        string memory metadataUri2 = "ipfs://QmAbC";
        _createGroup(groupId1, alice);
        _createGroup(groupId2, alice);
        vm.prank(alice);
        factory.setMetadataUri(groupId1, metadataUri1);
        vm.prank(alice);
        factory.setMetadataUri(groupId2, metadataUri2);
        string memory updatedMetadataUri1 = factory.metadataUri(groupId1);
        string memory updatedMetadataUri2 = factory.metadataUri(groupId2);
        assertEq(updatedMetadataUri1, metadataUri1);
        assertEq(updatedMetadataUri2, metadataUri2);
    }
}
