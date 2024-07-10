pragma solidity 0.8.23;

import {SemaphoreFactory} from "src/SemaphoreFactory.sol";
import {MockTest} from "test/unit/utils.sol";
import {ISemaphore} from "@semaphore-protocol/contracts/interfaces/ISemaphore.sol";

contract SemaphoreFactoryTest is MockTest {
    SemaphoreFactory factory;

    address semaphore = address(1);
    address creator1 = address(2);

    function setUp() public {
        factory = new SemaphoreFactory(semaphore);
    }

    function test_createGroup() public {
        uint256 groupId = 1;
        _mockAndExpect(
            semaphore,
            abi.encodeWithSelector(
                bytes4(keccak256("createGroup(address)")),
                address(factory)
            ),
            abi.encode(groupId)
        );
        vm.prank(creator1);
        factory.createGroup();

        address creator = factory.creator(groupId);
        assertEq(creator, creator1);
    }
}
