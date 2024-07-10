pragma solidity 0.8.23;

import {SemaphoreFactory} from "src/SemaphoreFactory.sol";
import {MockTest} from "test/unit/utils.sol";
import {ISemaphore} from "@semaphore-protocol/contracts/interfaces/ISemaphore.sol";
import {InvitationSigUtils} from "src/InvitationSigUtils.sol";

contract SemaphoreFactoryTest is MockTest {
    SemaphoreFactory factory;

    address semaphore = address(1);
    uint256 alicePk = 0xA11CE;
    uint256 bobPk = 0xB0B;
    address alice = vm.addr(alicePk);
    address bob = vm.addr(bobPk);

    function setUp() public {
        factory = new SemaphoreFactory(semaphore);
    }

    function test_createGroup() public {
        uint256 groupId = 1;
        _createGroup(groupId, alice);
        address creator = factory.creator(groupId);
        assertEq(creator, alice);
    }

    function test_join_with_invitation_code() public {
        uint256 groupId = 1;
        uint256 identityCommitment = 0x123;
        uint256 deadline = 0;
        uint256 nonce = 0;
        _createGroup(groupId, alice);
        _join(alicePk, groupId, identityCommitment, deadline, nonce);
    }

    function test_should_fail_to_join_after_deadline() public {
        uint256 groupId = 1;
        uint256 identityCommitment = 0x123;

        vm.warp(1000);
        uint256 deadline = block.timestamp - 1;
        uint256 nonce = 0;
        _createGroup(groupId, alice);
        (uint8 v, bytes32 r, bytes32 s) = _generate_invitation_code(
            alicePk,
            groupId,
            nonce,
            deadline
        );

        vm.expectRevert(SemaphoreFactory.InvalidInvitationSignature.selector);
        factory.joinWithInvitationCode(
            groupId,
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
        _createGroup(groupId, alice);
        (uint8 v, bytes32 r, bytes32 s) = _generate_invitation_code(
            bobPk,
            groupId,
            nonce,
            deadline
        );

        vm.expectRevert(SemaphoreFactory.InvalidInvitationSignature.selector);
        factory.joinWithInvitationCode(
            groupId,
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
        _createGroup(groupId, alice);
        _join(alicePk, groupId, identityCommitment, deadline, nonce);

        (uint8 v, bytes32 r, bytes32 s) = _generate_invitation_code(
            alicePk,
            groupId,
            nonce,
            deadline
        );

        vm.expectRevert(SemaphoreFactory.InvalidInvitationSignature.selector);
        factory.joinWithInvitationCode(
            groupId,
            nonce,
            deadline,
            identityCommitment,
            v,
            r,
            s
        );
    }

    function _join(
        uint256 signerPk,
        uint256 groupId,
        uint256 identityCommitment,
        uint256 deadline,
        uint256 nonce
    ) internal {
        (uint8 v, bytes32 r, bytes32 s) = _generate_invitation_code(
            signerPk,
            groupId,
            nonce,
            deadline
        );
        _mockAndExpect(
            semaphore,
            abi.encodeWithSelector(
                ISemaphore.addMember.selector,
                groupId,
                identityCommitment
            ),
            abi.encode()
        );
        factory.joinWithInvitationCode(
            groupId,
            nonce,
            deadline,
            identityCommitment,
            v,
            r,
            s
        );
    }

    function _generate_invitation_code(
        uint256 signerPk,
        uint256 groupId,
        uint256 nonce,
        uint256 deadline
    ) internal view returns (uint8 v, bytes32 r, bytes32 s) {
        InvitationSigUtils.Invitation memory invitation = InvitationSigUtils
            .Invitation({groupId: groupId, nonce: nonce, deadline: deadline});
        bytes32 structHash = factory.sigUtils().getTypedDataHash(invitation);
        (v, r, s) = vm.sign(signerPk, structHash);
    }

    function _createGroup(uint256 groupId, address creator) internal {
        _mockAndExpect(
            semaphore,
            abi.encodeWithSelector(
                bytes4(keccak256("createGroup(address)")),
                address(factory)
            ),
            abi.encode(groupId)
        );
        vm.prank(creator);
        factory.createGroup();
    }
}
