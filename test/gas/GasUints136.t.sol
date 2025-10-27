// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/Array.sol";

contract TightUint136 is Test {
    using Array for Array.Uint136;

    Array.Uint136 internal arr;

    uint136[] internal uint136s;
    uint136 public temp = uint136(0xBEEF);
    uint136 public temp2 = uint136(0xBEEF);
    uint136 public constant CAFE = uint136(0xCAFE);
    uint136 public constant BEEF = uint136(0xBEEF);

    function test_gas_all_operations_1() public {
        
        uint256 gas0 = gasleft();
        uint136s.push(CAFE);
        temp = uint136s[0];
        uint136s[0] = BEEF;
        uint136s.pop();
        console.log("NORMAL: push/set/get/pop: ", gas0 - gasleft());

        uint256 gas1 = gasleft();
        arr.push(CAFE);
        temp2 = arr.get(0);
        arr.set(0, BEEF);
        arr.pop();
        console.log("PACKED: push/set/get/pop: ", gas1 - gasleft());
    }


    function test_gas_all_operations_100() public {
        unchecked {
            uint256 gas0 = gasleft();
            for (uint256 i = 0; i < 100; i++) {
                uint136s.push(CAFE);
                temp = uint136s[0];
                uint136s[i] = BEEF;
            }
            uint136s.pop();
            console.log("NORMAL:  push/set/get/pop: ", gas0 - gasleft());

            uint256 gas1 = gasleft();
            for (uint256 i = 0; i < 100; i++) {
                arr.push(CAFE);
                temp2 = arr.get(i);
                arr.set(i, BEEF);
            }
            arr.pop();
            console.log("PACKED:  push/set/get/pop ", gas1 - gasleft());
        }
    }

    function test_gas_set_100() public {
        // set up array
        uint256 numberOfAddrs = 100;
        uint136[] memory normalArray = new uint136[](numberOfAddrs);
        for (uint256 i = 0; i < normalArray.length; i++) {
            uint136 val = uint136(i + 1);
            normalArray[i] = val;
        }

        uint256 gasBefore = gasleft();
        for (uint256 i = 0; i < normalArray.length; i++) {
            uint136s.push(normalArray[i]);
        }
        console.log("NORMAL: set 100: ", gasBefore - gasleft());

        uint256 gasBefore2 = gasleft();
        arr.append(normalArray);
        console.log("PACKED: set 100: ", gasBefore2 - gasleft());
    }
}
