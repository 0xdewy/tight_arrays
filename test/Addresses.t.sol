// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Array.sol";

contract TightAddressTest is Test {
    using Array for Array.Addresses;

    Array.Addresses internal arr;

    // ============================================Pop=======================================

    /// forge-config: default.allow_internal_expect_revert = true
    function test_pop_fuzz(address[50] calldata addrs) public {
        for (uint256 i = 0; i < addrs.length; i++) {
            arr.push(addrs[i]);
        }

        for (uint256 i = 0; i < addrs.length; i++) {
            assertEq(arr.slots.length, addrs.length - i);
            arr.pop();
        }

        assertEq(arr.slots.length, 0);
        // TODO: check everything is cleared in storage

        vm.expectRevert(Array.ArrayEmpty.selector);
        arr.pop();
    }

    // =================================Push=================================================
    function test_fuzz_push(address[50] calldata addrs) public {
        for (uint256 i = 0; i < addrs.length; i++) {
            arr.push(addrs[i]);
            assertEq(arr.get(i), addrs[i]);
        }
    }

    // ================================Append=================================================
    function test_append_fuzz(address[50] calldata _addrs) public {
        // Initialize arrays in memory
        uint256 lens = _addrs.length;
        address[] memory addrs = new address[](lens);
        for (uint160 i = 0; i < lens; i++) {
            addrs[i] = _addrs[i];
        }

        // Append 1st round
        arr.append(addrs);
        assertEq(arr.slots.length, lens);

        // Should copy list exactly
        for (uint256 i = 0; i < lens; i++) {
            assertEq(arr.get(i), addrs[i]);
        }

        // Append 2nd round
        // Length should be double original list
        arr.append(addrs);
        assertEq(arr.slots.length, lens * 2);

        for (uint256 i = lens; i < lens * 2; i++) {
            assertEq(arr.get(i), addrs[i % lens]);
        }
    }

    // =========================================Set=================================================

   

    function test_fuzz_set(address[2] calldata addrsA, address[2] calldata addrsB) public {
        assertEq(addrsA.length, addrsB.length);
        for (uint256 i = 0; i < addrsA.length; i++) {
            arr.push(addrsA[i]);
        }
        assertEq(arr.slots.length, addrsA.length);

        for (uint256 i = 0; i < addrsB.length; i++) {
            assertEq(arr.get(i), addrsA[i]);
            arr.set(i, addrsB[i]);
            assertEq(arr.get(i), addrsB[i]);
        }
        assertEq(arr.slots.length, addrsB.length);

        for (uint256 i = 0; i < addrsA.length; i++) {
            assertEq(arr.get(i), addrsB[i]);
            arr.set(i, addrsA[i]);
            assertEq(arr.get(i), addrsA[i]);
        }
        assertEq(arr.slots.length, addrsB.length);
    }

    // ===========================================Slice=============================================
    /// forge-config: default.allow_internal_expect_revert = true
    function test_fuzz_slice(address[50] calldata array, uint256 from, uint256 to) public {
        for (uint256 i = 0; i < array.length; i++) {
            arr.push(array[i]);
        }

        if (to > array.length) {
            vm.expectRevert(Array.OutOfBounds.selector);
        } else if (from >= to) {
            vm.expectRevert(Array.InvalidRange.selector);
        }

        // address
        address[] memory resAddrs = arr.slice(from, to);
        assertEq(resAddrs.length, to - from);

        for (uint256 i = 0; i < resAddrs.length; i++) {
            assertEq(resAddrs[i], array[from + i]);
        }
    }

    // ====================================Integration============================================
    /// forge-config: default.allow_internal_expect_revert = true
    function test_fuzz_all_functionality(address[30] calldata addrs, address a, address b) public {
        address[] memory _addrs = new address[](addrs.length);
        for (uint256 i = 0; i < addrs.length; i++) {
            _addrs[i] = addrs[i];
        }

        // push and append
        arr.push(a);
        assertEq(arr.slots.length, 1);
        assertEq(arr.get(0), a);

        arr.append(_addrs);
        assertEq(arr.slots.length, _addrs.length + 1);
        for (uint256 i = 0; i < _addrs.length; i++) {
            assertEq(arr.get(i + 1), _addrs[i]);
        }

        // remove last 1, and set all to address(0)
        arr.pop();
        assertEq(arr.slots.length, addrs.length);

        for (uint256 i = 0; i < addrs.length; i++) {
            arr.set(i, address(0));
            assertEq(arr.get(i), address(0));
        }
        assertEq(arr.slots.length, addrs.length);
        assertEq(_addrs.length, addrs.length);

        // Get all zero addresses
        address[] memory zeroAddrs = arr.slice(0, addrs.length);
        assertEq(zeroAddrs.length, addrs.length);
        assertEq(arr.slots.length, addrs.length);

        assertEq(_addrs.length, addrs.length);

        // Remove all addresses
        for (uint256 i = 0; i < addrs.length; i++) {
            arr.pop();
        }

        vm.expectRevert(Array.ArrayEmpty.selector);
        arr.pop();
        assertEq(arr.slots.length, 0);

        arr.push(b);
        assertEq(arr.get(0), b);
        assertEq(arr.slots.length, 1);
        arr.set(0, a);
        assertEq(arr.get(0), a);
    }
}
