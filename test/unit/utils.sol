pragma solidity 0.8.23;
import "forge-std/Test.sol";
import "forge-std/console.sol";
import {SemaphoreFactory} from "src/SemaphoreFactory.sol";
import {ISemaphore} from "@semaphore-protocol/contracts/interfaces/ISemaphore.sol";
import {InvitationSigUtils} from "src/InvitationSigUtils.sol";
import {ISemaphoreBlog} from "src/interfaces/ISemaphoreBlog.sol";

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

    function _createGroup(
        uint256 groupId,
        address creator
    ) internal returns (address blog) {
        blog = factory.computeAddress(
            keccak256(abi.encodePacked(creator, block.number)),
            creator
        );

        _mockAndExpect(
            semaphore,
            abi.encodeWithSelector(
                bytes4(keccak256("createGroup(address)")),
                blog
            ),
            abi.encode(groupId)
        );

        vm.prank(creator);
        factory.createGroup();
    }

    function _generate_invitation_code(
        address blog,
        uint256 signerPk,
        uint256 nonce,
        uint256 deadline
    ) internal view returns (uint8 v, bytes32 r, bytes32 s) {
        InvitationSigUtils.Invitation memory invitation = InvitationSigUtils
            .Invitation({
                groupId: ISemaphoreBlog(blog).groupId(),
                nonce: nonce,
                deadline: deadline
            });
        bytes32 structHash = InvitationSigUtils.getTypedDataHash(
            ISemaphoreBlog(blog).domainSeparator(),
            invitation
        );
        (v, r, s) = vm.sign(signerPk, structHash);
    }

    function _join(
        address blog,
        uint256 signerPk,
        uint256 identityCommitment,
        uint256 deadline,
        uint256 nonce
    ) internal {
        (uint8 v, bytes32 r, bytes32 s) = _generate_invitation_code(
            blog,
            signerPk,
            nonce,
            deadline
        );
        _mockAndExpect(
            semaphore,
            abi.encodeWithSelector(
                ISemaphore.addMember.selector,
                ISemaphoreBlog(blog).groupId(),
                identityCommitment
            ),
            abi.encode()
        );
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
