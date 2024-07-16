pragma solidity 0.8.23;
import "forge-std/Test.sol";
import {SemaphoreFactory} from "src/SemaphoreFactory.sol";
import {ISemaphore} from "@semaphore-protocol/contracts/interfaces/ISemaphore.sol";
import {InvitationSigUtils} from "src/InvitationSigUtils.sol";

contract MockTest is Test {
    function _mockAndExpect(
        address _target,
        bytes memory _call,
        bytes memory _ret
    ) internal {
        vm.mockCall(_target, _call, _ret);
        vm.expectCall(_target, _call);
    }
}

contract SemaphoreFactoryTest is MockTest {
    address semaphore = address(1);
    SemaphoreFactory factory;

    function setUp() public {
        factory = new SemaphoreFactory(semaphore);
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
}
