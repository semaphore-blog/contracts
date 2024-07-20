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

    function test_createGroup() public {
        uint256 groupId = 1;
        address blog = _createGroup(groupId, alice);
        address creator = ISemaphoreBlog(blog).creator();
        assertEq(creator, alice);
    }

    function test_join_with_invitation_code() public {
        uint256 groupId = 1;
        uint256 identityCommitment = 0x123;
        uint256 deadline = 0;
        uint256 nonce = 0;
        address blog = _createGroup(groupId, alice);
        _join(blog, alicePk, identityCommitment, deadline, nonce);
    }

    function test_should_fail_to_join_after_deadline() public {
        uint256 groupId = 1;
        uint256 identityCommitment = 0x123;

        vm.warp(1000);
        uint256 deadline = block.timestamp - 1;
        uint256 nonce = 0;
        address blog = _createGroup(groupId, alice);
        (uint8 v, bytes32 r, bytes32 s) = _generate_invitation_code(
            blog,
            alicePk,
            nonce,
            deadline
        );

        vm.expectRevert(ISemaphoreBlog.InvalidInvitationSignature.selector);
        ISemaphoreBlog(blog).joinWithInvitationCode(
            nonce,
            deadline,
            identityCommitment,
            v,
            r,
            s
        );
    }

    function test_should_fail_to_join_with_invalid_signature() public {
        uint256 groupId = 1;
        uint256 identityCommitment = 0x123;
        uint256 deadline = 0;
        uint256 nonce = 0;
        address blog = _createGroup(groupId, alice);
        (uint8 v, bytes32 r, bytes32 s) = _generate_invitation_code(
            blog,
            bobPk,
            nonce,
            deadline
        );

        vm.expectRevert(ISemaphoreBlog.InvalidInvitationSignature.selector);
        ISemaphoreBlog(blog).joinWithInvitationCode(
            nonce,
            deadline,
            identityCommitment,
            v,
            r,
            s
        );
    }

    function test_should_fail_to_join_with_duplicate_nonce() public {
        uint256 groupId = 1;
        uint256 identityCommitment = 0x123;
        uint256 deadline = 0;
        uint256 nonce = 0;
        address blog = _createGroup(groupId, alice);
        _join(blog, alicePk, identityCommitment, deadline, nonce);

        (uint8 v, bytes32 r, bytes32 s) = _generate_invitation_code(
            blog,
            alicePk,
            nonce,
            deadline
        );

        vm.expectRevert(ISemaphoreBlog.InvalidInvitationSignature.selector);
        ISemaphoreBlog(blog).joinWithInvitationCode(
            nonce,
            deadline,
            identityCommitment,
            v,
            r,
            s
        );
    }
}
