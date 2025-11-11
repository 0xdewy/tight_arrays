// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.21;

import "forge-std/Test.sol";
import "../../src/Array.sol";

// Handler contract for fuzzing operations
contract ArrayHandler is Test {
    using Array for Array.Addresses;

    Array.Addresses arr;
    address[] public expected;

    function push(address a) external {
        arr.push(a);
        expected.push(a);
    }

    function pop() external {
        uint256 len = expected.length;
        vm.assume(len > 0);
        arr.pop();
        expected.pop();
    }

    function set(uint256 index, address a) external {
        uint256 len = expected.length;
        if (len == 0) return;
        index = bound(index, 0, len - 1);
        arr.set(index, a);
        expected[index] = a;
    }

    function append(address[] calldata addrs) external {
        // Bound the append size to prevent excessive gas usage in tests
        vm.assume(addrs.length <= 100);

        arr.append(addrs);
        for (uint256 i = 0; i < addrs.length; i++) {
            expected.push(addrs[i]);
        }
    }

    function slice(uint8 from, uint8 to) external {
        if (expected.length == 0) return;
        uint256 indexFrom = uint256(from);
        uint256 indexTo = uint256(to);
        indexFrom = bound(indexFrom, 0, expected.length - 1);
        indexTo = bound(indexTo, indexFrom, expected.length - 1);
        vm.assume(indexTo - indexFrom < 20); // Smaller for performance
        vm.assume(indexTo > indexFrom);

        address[] memory _slice = arr.slice(indexFrom, indexTo);

        // Verify slice matches expected manually
        for (uint256 i = 0; i < _slice.length; i++) {
            assertEq(_slice[i], expected[indexFrom + i], "Slice mismatch");
        }

        // Append slice to both arrays (simpler and maintains history)
        arr.append(_slice);
        for (uint256 i = indexFrom; i < indexTo; i++) {
            expected.push(expected[i]);
        }
    }

    // View functions for invariant checks
    function arrLength() external view returns (uint256 len) {
        assembly {
            len := sload(arr.slot)
        }
    }

    function expectedLength() external view returns (uint256 len) {
        len = expected.length;
    }

    function get(uint256 index) external view returns (address) {
        return arr.get(index);
    }
}

// Invariant test contract
contract ArrayInvariantTest is Test {
    ArrayHandler handler;

    function setUp() public {
        handler = new ArrayHandler();
        targetContract(address(handler));

        bytes4[] memory selectors = new bytes4[](5);
        selectors[0] = ArrayHandler.push.selector;
        selectors[1] = ArrayHandler.pop.selector;
        selectors[2] = ArrayHandler.set.selector;
        selectors[3] = ArrayHandler.append.selector;
        selectors[4] = ArrayHandler.slice.selector;

        targetSelector(FuzzSelector({addr: address(handler), selectors: selectors}));
    }

    function invariant_consistency() public view {
        uint256 len = handler.arrLength();
        uint256 expectedLen = handler.expectedLength();
        assertEq(len, expectedLen, "Array length mismatch");

        for (uint256 i = 0; i < len; i++) {
            address got = handler.get(i);
            address exp = handler.expected(i);
            assertEq(got, exp, "Array value mismatch");
        }
    }
}
