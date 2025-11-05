// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.21;

import "forge-std/Test.sol";
import "../../src/Array.sol";

// Handler contract for fuzzing operations
contract ArrayHandler is Test {
    using Array for Array.Uint96;

    Array.Uint96 arr;
    uint96[] public expected;

    function push(uint96 a) external {
        arr.push(a);
        expected.push(a);
    }

    function pop() external {
        uint256 len = expected.length;
        vm.assume(len > 0);
        arr.pop();
        expected.pop();
    }

    function set(uint256 index, uint96 a) external {
        uint256 len = expected.length;
        if (len == 0) return;
        index = bound(index, 0, len - 1);
        arr.set(index, a);
        expected[index] = a;
    }

    function append(uint96[] calldata uints) external {
        // Bound the append size to prevent excessive gas usage in tests
        vm.assume(uints.length <= 1000);

        arr.append(uints);
        for (uint256 i = 0; i < uints.length; i++) {
            expected.push(uints[i]);
        }
    }

    function slice(uint indexFrom, uint indexTo) external {
      if (expected.length == 0) return;
      indexFrom = bound(indexFrom, 0, expected.length - 2);
      indexTo = bound(indexFrom, indexFrom, expected.length - 1);

      // append slice onto end of storage
      uint96[] memory _slice = arr.slice(indexFrom, indexTo);
      arr.append(_slice);

      for (uint i = indexFrom; i <= indexTo; i++) {
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

    function get(uint256 index) external view returns (uint96) {
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
            uint96 got = handler.get(i);
            uint96 exp = handler.expected(i);
            assertEq(got, exp, "Array value mismatch");
        }
    }
}
