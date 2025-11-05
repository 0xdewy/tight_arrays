// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/Array.sol";

contract TightUint96 is Test {
    using Array for Array.Uint96;

    Array.Uint96 internal arr;

    uint96[] internal uint96s;
    uint96 public constant CAFE = uint96(0xCAFE);
    uint96 public constant BEEF = uint96(0xBEEF);

    function test_gas_all_operations_1_96() public {
        {
            uint256 gas0 = gasleft();
            uint96s.push(CAFE);
            uint96 temp = uint96s[0];
            uint96s[0] = BEEF;
            uint96s[0] = temp;
            uint96s.pop();
            console.log("NORMAL: push/set/get/pop: ", gas0 - gasleft());
        }

        {
            uint256 gas1 = gasleft();
            arr.push(CAFE);
            uint96 temp = arr.get(0);
            arr.set(0, BEEF);
            arr.set(0, temp);
            arr.pop();
            console.log("PACKED: push/set/get/pop: ", gas1 - gasleft());
        }
    }

    function test_gas_all_operations_100() public {
        {
            uint256 gas0 = gasleft();
            for (uint256 i = 0; i < 100; i++) {
                uint96s.push(CAFE);
                uint96 temp = uint96s[0];
                uint96s[i] = BEEF;
                uint96s.pop();
                uint96s.push(temp);
            }
            uint96s.pop();
            console.log("NORMAL:  push/set/get/pop: ", gas0 - gasleft());
        }

        {
            uint256 gas1 = gasleft();
            for (uint256 i = 0; i < 100; i++) {
                arr.push(CAFE);
                uint96 temp = arr.get(i);
                arr.set(i, BEEF);
                arr.pop();
                arr.push(temp);
            }
            arr.pop();
            console.log("PACKED:  push/set/get/pop ", gas1 - gasleft());
        }
    }

    function test_gas_set_100() public {
        // set up array
        uint256 numberOfAddrs = 100;
        uint96[] memory normalArray = new uint96[](numberOfAddrs);
        for (uint256 i = 0; i < normalArray.length; i++) {
            uint96 val = uint96(i + 1);
            normalArray[i] = val;
        }

        uint256 gasBefore = gasleft();
        for (uint256 i = 0; i < normalArray.length; i++) {
            uint96s.push(normalArray[i]);
        }
        console.log("NORMAL: set 100: ", gasBefore - gasleft());

        uint256 gasBefore2 = gasleft();
        arr.append(normalArray);
        console.log("PACKED: set 100: ", gasBefore2 - gasleft());
    }
}
