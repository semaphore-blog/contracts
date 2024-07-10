pragma solidity 0.8.23;
import "forge-std/Test.sol";

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
