// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Array.sol";

contract UintTest is Test {
    using Array for Array.Uint88;
    using Array for Array.Uint96;
    using Array for Array.Uint136;
    using Array for Array.Uint144;
    using Array for Array.Uint152;
    using Array for Array.Uint160;

    Array.Uint88 internal arr88;
    Array.Uint96 internal arr96;
    Array.Uint136 internal arr136;
    Array.Uint144 internal arr144;
    Array.Uint152 internal arr152;
    Array.Uint160 internal arr160;

    // ============================================Pop=======================================
    /// forge-config: default.allow_internal_expect_revert = true
    function test_pop_fuzz(uint88[50] calldata uint88s) public {
        for (uint256 i = 0; i < uint88s.length; i++) {
            arr88.push(uint88s[i]);
        }

        for (uint256 i = 0; i < uint88s.length; i++) {
            assertEq(arr88.slots.length, uint88s.length - i);
            arr88.pop();
        }

        assertEq(arr88.slots.length, 0);
        vm.expectRevert(Array.ArrayEmpty.selector);
        arr88.pop();
    }

    // =================================Push=================================================
    /// forge-config: default.allow_internal_expect_revert = true
    function test_fuzz_push(uint88[50] calldata uint88s) public {
        vm.expectRevert(Array.OutOfBounds.selector);
        arr88.get(0);
        for (uint256 i = 0; i < uint88s.length; i++) {
            arr88.push(uint88s[i]);
            assertEq(arr88.get(i), uint88s[i]);
        }
    }

    // ================================Append=================================================
    function test_append_fuzz(uint88[50] calldata _uint88s) public {
        uint256 lens = _uint88s.length;
        uint88[] memory uint88s = new uint88[](lens);
        for (uint160 i = 0; i < lens; i++) {
            uint88s[i] = _uint88s[i];
        }

        // Append 1st round
        arr88.append(uint88s);
        assertEq(arr88.slots.length, lens);
        for (uint256 i = 0; i < lens; i++) {
            assertEq(arr88.get(i), uint88s[i]);
        }

        // Append 2nd round
        arr88.append(uint88s);
        assertEq(arr88.slots.length, lens * 2);
        for (uint256 i = lens; i < lens * 2; i++) {
            assertEq(arr88.get(i), uint88s[i % lens]);
        }
    }

    // =========================================Set=================================================

    /// forge-config: default.allow_internal_expect_revert = true
    function test_fuzz_set(uint88[20] calldata uint88s) public {
        assertEq(uint88s.length, uint88s.length);
        for (uint256 i = 0; i < uint88s.length; i++) {
            arr88.push(uint88s[i]);
        }

        vm.expectRevert(Array.OutOfBounds.selector);
        arr88.set(uint88s.length, uint88(10));

        for (uint256 i = 0; i < uint88s.length; i++) {
            arr88.set(i, uint88s[i]);
            assertEq(arr88.get(i), uint88s[i]);
        }
        assertEq(arr88.slots.length, uint88s.length);

        for (uint256 i = 0; i < uint88s.length; i++) {
            arr88.set(i, uint88s[i]);
            assertEq(arr88.get(i), uint88s[i]);
        }
        assertEq(arr88.slots.length, uint88s.length);
    }

    // ===========================================Slice=============================================
    /// forge-config: default.allow_internal_expect_revert = true
    function test_fuzz_slice(uint88[50] calldata uints88, uint256 from, uint256 to) public {
        for (uint256 i = 0; i < uints88.length; i++) {
            arr88.push(uints88[i]);
        }

        if (to > uints88.length) {
            vm.expectRevert(Array.OutOfBounds.selector);
        } else if (from >= to) {
            vm.expectRevert(Array.InvalidRange.selector);
        }

        // uint88
        uint88[] memory res24 = arr88.slice(from, to);
        assertEq(res24.length, to - from);

        for (uint256 i = 0; i < res24.length; i++) {
            assertEq(res24[i], uints88[from + i]);
        }
    }

    // ====================================Integration============================================
    function test_fuzz_uint96(uint96[4] calldata uints) public {
        // copy from calldata to memory
        uint96[] memory _uints = new uint96[](uints.length);
        for (uint256 i = 0; i < uints.length; i++) {
            _uints[i] = uints[i];
        }

        // append
        arr96.append(_uints);
        assertEq(_uints.length, arr96.slots.length);
        for (uint256 i = 0; i < uints.length; i++) {
            assertEq(_uints[i], arr96.get(i));
        }

        // pop/push
        arr96.pop();
        assertEq(_uints.length, arr96.slots.length + 1);
        arr96.push(_uints[_uints.length - 1]);
        assertEq(_uints.length, arr96.slots.length);

        // reverse array using set
        for (uint256 i = 0; i < uints.length; i++) {
            console.log("i: ", i);
            console.log(arr96.get(i));
            console.log(arr96.get(0));
            arr96.set(i, _uints[uints.length - 1 - i]);
            console.log(arr96.get(i));
            assertEq(arr96.get(i), _uints[uints.length - 1 - i], "failed to set reverse list");
        }


        // slice should maintain order/values
        uint96[] memory test = arr96.slice(0, _uints.length);
        assertEq(test.length, _uints.length, "slice length bug");
        console.log(arr96.get(0));
        console.log(arr96.get(1));
        for (uint256 i = 0; i < uints.length; i++) {
            assertEq(test[i], arr96.get(i), "slice/get mismatch");
            assertEq(test[i], _uints[uints.length - 1 - i]);
        }
    }

    function test_fuzz_uint136(uint136[70] calldata uints) public {
        // copy from calldata to memory
        uint136[] memory _uints = new uint136[](uints.length);
        for (uint256 i = 0; i < uints.length; i++) {
            _uints[i] = uints[i];
        }

        // append
        arr136.append(_uints);
        assertEq(_uints.length, arr136.slots.length);
        for (uint256 i = 0; i < uints.length; i++) {
            assertEq(_uints[i], arr136.get(i));
        }

        // pop/push
        arr136.pop();
        assertEq(_uints.length, arr136.slots.length + 1);
        arr136.push(type(uint136).max);
        assertEq(_uints.length, arr136.slots.length);

        // reverse array using set
        for (uint256 i = 0; i < uints.length; i++) {
            arr136.set(i, _uints[uints.length - 1 - i]);
            assertEq(arr136.get(i), _uints[uints.length - 1 - i]);
        }

        // slice should maintain order/values
        uint136[] memory test = arr136.slice(0, _uints.length);
        for (uint256 i = 0; i < uints.length; i++) {
            assertEq(test[i], _uints[uints.length - 1 - i]);
        }
    }

    function test_fuzz_uint144(uint144[70] calldata uints) public {
        // copy from calldata to memory
        uint144[] memory _uints = new uint144[](uints.length);
        for (uint256 i = 0; i < uints.length; i++) {
            _uints[i] = uints[i];
        }

        // append
        arr144.append(_uints);
        assertEq(_uints.length, arr144.slots.length);
        for (uint256 i = 0; i < uints.length; i++) {
            assertEq(_uints[i], arr144.get(i));
        }

        // pop/push
        arr144.pop();
        assertEq(_uints.length, arr144.slots.length + 1);
        arr144.push(type(uint144).max);
        assertEq(_uints.length, arr144.slots.length);

        // reverse array using set
        for (uint256 i = 0; i < uints.length; i++) {
            arr144.set(i, _uints[uints.length - 1 - i]);
            assertEq(arr144.get(i), _uints[uints.length - 1 - i]);
        }

        // slice should maintain order/values
        uint144[] memory test = arr144.slice(0, _uints.length);
        for (uint256 i = 0; i < uints.length; i++) {
            assertEq(test[i], _uints[uints.length - 1 - i]);
        }
    }

    function test_fuzz_uint152(uint152[70] calldata uints) public {
        // copy from calldata to memory
        uint152[] memory _uints = new uint152[](uints.length);
        for (uint256 i = 0; i < uints.length; i++) {
            _uints[i] = uints[i];
        }

        // append
        arr152.append(_uints);
        assertEq(_uints.length, arr152.slots.length);
        for (uint256 i = 0; i < uints.length; i++) {
            assertEq(_uints[i], arr152.get(i));
        }

        // pop/push
        arr152.pop();
        assertEq(_uints.length, arr152.slots.length + 1);
        arr152.push(type(uint152).max);
        assertEq(_uints.length, arr152.slots.length);

        // reverse array using set
        for (uint256 i = 0; i < uints.length; i++) {
            arr152.set(i, _uints[uints.length - 1 - i]);
            assertEq(arr152.get(i), _uints[uints.length - 1 - i]);
        }

        // slice should maintain order/values
        uint152[] memory test = arr152.slice(0, _uints.length);
        for (uint256 i = 0; i < uints.length; i++) {
            assertEq(test[i], _uints[uints.length - 1 - i]);
        }
    }

    function test_fuzz_uint160(uint160[70] calldata uints) public {
        // copy from calldata to memory
        uint160[] memory _uints = new uint160[](uints.length);
        for (uint256 i = 0; i < uints.length; i++) {
            _uints[i] = uints[i];
        }

        // append
        arr160.append(_uints);
        assertEq(_uints.length, arr160.slots.length);
        for (uint256 i = 0; i < uints.length; i++) {
            assertEq(_uints[i], arr160.get(i));
        }

        // pop/push
        arr160.pop();
        assertEq(_uints.length, arr160.slots.length + 1);
        arr160.push(type(uint160).max);
        assertEq(_uints.length, arr160.slots.length);

        // reverse array using set
        for (uint256 i = 0; i < uints.length; i++) {
            arr160.set(i, _uints[uints.length - 1 - i]);
            assertEq(arr160.get(i), _uints[uints.length - 1 - i]);
        }

        // slice should maintain order/values
        uint160[] memory test = arr160.slice(0, _uints.length);
        for (uint256 i = 0; i < uints.length; i++) {
            assertEq(test[i], _uints[uints.length - 1 - i]);
        }
    }
}
