// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/Array.sol";

contract TightAddressGasTest is Test {
    using Array for Array.Addresses;

    Array.Addresses internal arr;

    address[] internal addrArr;
    address constant CAFE = address(0xCAFE);
    address constant BEEF = address(0xBEEF);
    address temp = address(0xC0FFEE);
    address temp2 = address(0xC0FFEE);

    function test_gas_all_operations_1_addr() public {
        uint256 gas0 = gasleft();
        addrArr.push(CAFE);
        temp = addrArr[0];
        addrArr[0] = BEEF;
        addrArr.pop();
        console.log("gas regular array push/set/get/pop: ", gas0 - gasleft());

        uint256 gas1 = gasleft();
        arr.push(CAFE);
        temp2 = arr.get(0);
        arr.set(0, BEEF);
        arr.pop();
        console.log("gas packed array push/set/get/pop: ", gas1 - gasleft());
    }

    function test_gas_all_operations_100_addr() public {
        unchecked {
            uint256 gas0 = gasleft();
            for (uint256 i = 0; i < 100; i++) {
                addrArr.push(CAFE);
                temp = addrArr[0];
                addrArr[i] = BEEF;
            }
            addrArr.pop();
            console.log("gas regular array push/set/get/pop: ", gas0 - gasleft());

            uint256 gas1 = gasleft();
            for (uint256 i = 0; i < 100; i++) {
                arr.push(CAFE);
                temp2 = arr.get(i);
                arr.set(i, BEEF);
            }
            arr.pop();
            console.log("gas packed array: push/set/get/pop ", gas1 - gasleft());
        }
    }

    function test_gas_set_100() public {
        // set up array
        uint256 numberOfAddrs = 100;
        address[] memory normalArray = new address[](numberOfAddrs);
        for (uint256 i = 0; i < normalArray.length; i++) {
            address addr = address(uint160(uint256(keccak256(abi.encodePacked(i)))));
            normalArray[i] = addr;
        }

        uint256 gasBefore = gasleft();
        for (uint256 i = 0; i < normalArray.length; i++) {
            addrArr.push(normalArray[i]);
        }
        console.log("gas used normal address array: ", gasBefore - gasleft());

        uint256 gasBefore2 = gasleft();
        arr.append(normalArray);
        console.log("gas used packed address array: ", gasBefore2 - gasleft());
    }
}
