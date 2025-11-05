// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.21;

library Array {
    error OutOfBounds();
    error InvalidRange();
    error ArrayEmpty();

    // =========================================Get===================================================
    function get(Addresses storage arr, uint256 index) internal view returns (address addr) {
        uint256 slot;
        assembly {
            slot := arr.slot
        }
        addr = address(uint160(_get(slot, index, 160)));
    }

    function get(Uint88 storage arr, uint256 index) internal view returns (uint88 val) {
        uint256 slot;
        assembly {
            slot := arr.slot
        }
        val = uint88(_get(slot, index, 88));
    }

    function get(Uint96 storage arr, uint256 index) internal view returns (uint96 val) {
        uint256 slot;
        assembly {
            slot := arr.slot
        }
        val = uint96(_get(slot, index, 96));
    }

    function get(Uint136 storage arr, uint256 index) internal view returns (uint136 val) {
        uint256 slot;
        assembly {
            slot := arr.slot
        }
        val = uint136(_get(slot, index, 136));
    }

    function get(Uint144 storage arr, uint256 index) internal view returns (uint144 val) {
        uint256 slot;
        assembly {
            slot := arr.slot
        }
        val = uint144(_get(slot, index, 144));
    }

    function get(Uint152 storage arr, uint256 index) internal view returns (uint152 val) {
        uint256 slot;
        assembly {
            slot := arr.slot
        }
        val = uint152(_get(slot, index, 152));
    }

    function get(Uint160 storage arr, uint256 index) internal view returns (uint160 val) {
        uint256 slot;
        assembly {
            slot := arr.slot
        }
        val = uint160(_get(slot, index, 160));
    }

    // Get an address from the array
    function _get(uint256 arraySlot, uint256 index, uint256 bits) internal view returns (uint256 val) {
        assembly {
            let length := sload(arraySlot)

            if iszero(gt(length, index)) {
                mstore(0x00, 0xb4120f14) // OutOfBounds()
                revert(0x1c, 0x04)
            }

            let bitStart := mul(index, bits)
            let startSlot := div(bitStart, 256)
            let offset := mod(bitStart, 256)

            // Calculate storage spot for array
            mstore(0x0, arraySlot)
            let storageSlot := keccak256(0x0, 0x20)
            let storageSlotIndex := add(storageSlot, startSlot)

            let remainder := sub(256, bits)
            switch gt(offset, remainder)
            case 1 {
                // If the offset is greater than remainder, we need to get the address across two slots
                let sliceLength := sub(bits, sub(256, offset))
                let highBits := shr(sub(offset, sliceLength), shl(offset, sload(storageSlotIndex)))
                let lowBits := shr(sub(256, sliceLength), sload(add(storageSlotIndex, 1)))
                val := or(highBits, lowBits)
            }
            default {
                // If the offset is less than remainder the address is in this slot alone
                val := shr(sub(remainder, offset), sload(storageSlotIndex))
            }
        }
    }

    // ============================================PUSH================================================
    function push(Addresses storage arr, address addr) internal {
        uint256 slot;
        uint256 value;
        assembly {
            slot := arr.slot
            value := addr
        }

        _push(slot, value, 160);
    }

    function push(Uint88 storage arr, uint88 value) internal {
        uint256 slot;
        assembly {
            slot := arr.slot
        }

        _push(slot, uint256(value), 88);
    }

    function push(Uint96 storage arr, uint96 value) internal {
        uint256 slot;
        assembly {
            slot := arr.slot
        }

        _push(slot, uint256(value), 96);
    }

    function push(Uint136 storage arr, uint136 value) internal {
        uint256 slot;
        assembly {
            slot := arr.slot
        }

        _push(slot, uint256(value), 136);
    }

    function push(Uint144 storage arr, uint144 value) internal {
        uint256 slot;
        assembly {
            slot := arr.slot
        }

        _push(slot, uint256(value), 144);
    }

    function push(Uint152 storage arr, uint152 value) internal {
        uint256 slot;
        assembly {
            slot := arr.slot
        }

        _push(slot, uint256(value), 152);
    }

    function push(Uint160 storage arr, uint160 value) internal {
        uint256 slot;
        assembly {
            slot := arr.slot
        }

        _push(slot, uint256(value), 160);
    }

    // Push an address into the array
    function _push(uint256 arraySlot, uint256 value, uint256 bits) internal {
        assembly {
            let numItems := sload(arraySlot)
            let totalBitsUsed := mul(numItems, bits)
            let slotIndex := div(totalBitsUsed, 256)
            let offset := mod(totalBitsUsed, 256)

            // Calculate storage spot for array
            mstore(0x0, arraySlot)
            let storageSlot := keccak256(0x0, 0x20)
            let storageSlotIndex := add(storageSlot, slotIndex)

            let remainder := sub(256, bits)
            switch gt(offset, remainder)
            case 1 {
                // If the offset is greater than remainder, we need to split the address across two slots
                let sliceLength := sub(bits, sub(256, offset))
                sstore(storageSlotIndex, or(sload(storageSlotIndex), shr(sliceLength, value)))
                sstore(add(storageSlotIndex, 1), shl(sub(256, sliceLength), value))
            }
            default {
                // If the offset is less than remainder, we can fit the whole address in the slot
                sstore(storageSlotIndex, or(sload(storageSlotIndex), shl(sub(remainder, offset), value)))
            }
            // Increment array
            sstore(arraySlot, add(sload(arraySlot), 1)) // increment array length
        }
    }

    // ====================================Append=================================================
    function append(Addresses storage arr, address[] memory addrs) internal {
        uint256 pointer;
        uint256 slot;
        assembly {
            pointer := addrs
            slot := arr.slot
        }
        _append(slot, pointer, 160);
    }

    function append(Uint88 storage arr, uint88[] memory vals) internal {
        uint256 pointer;
        uint256 slot;
        assembly {
            pointer := vals
            slot := arr.slot
        }
        _append(slot, pointer, 88);
    }

    function append(Uint96 storage arr, uint96[] memory vals) internal {
        uint256 pointer;
        uint256 slot;
        assembly {
            pointer := vals
            slot := arr.slot
        }
        _append(slot, pointer, 96);
    }

    function append(Uint136 storage arr, uint136[] memory vals) internal {
        uint256 pointer;
        uint256 slot;
        assembly {
            pointer := vals
            slot := arr.slot
        }
        _append(slot, pointer, 136);
    }

    function append(Uint144 storage arr, uint144[] memory vals) internal {
        uint256 pointer;
        uint256 slot;
        assembly {
            pointer := vals
            slot := arr.slot
        }
        _append(slot, pointer, 144);
    }

    function append(Uint152 storage arr, uint152[] memory vals) internal {
        uint256 pointer;
        uint256 slot;
        assembly {
            pointer := vals
            slot := arr.slot
        }
        _append(slot, pointer, 152);
    }

    function append(Uint160 storage arr, uint160[] memory vals) internal {
        uint256 pointer;
        uint256 slot;
        assembly {
            pointer := vals
            slot := arr.slot
        }
        _append(slot, pointer, 160);
    }

    // Appends a list to storage, taking a pointer to where the list is in memory
    // arraySlot = storage slot of array
    // vals = memory start of new array
    // bits is the size of the data in the array
    function _append(uint256 arraySlot, uint256 vals, uint256 bits) internal {
        assembly {
            let arrayLen := sload(arraySlot)

            let bitsAtStart := mul(arrayLen, bits)
            let startSlot := div(bitsAtStart, 256)
            let offset := mod(bitsAtStart, 256)

            // calculate storage slot
            mstore(0x00, arraySlot)
            let storageSlot := keccak256(0x00, 0x20)
            let storageSlotIndex := add(storageSlot, startSlot)
            let cachedStorageValue := sload(storageSlotIndex)

            let numValsToAdd := mload(vals)
            let i := 0

            for {} lt(i, numValsToAdd) { i := add(i, 1) } {
                let value := mload(add(add(vals, 32), mul(i, 32)))
                let remainder := sub(256, bits)

                switch gt(offset, remainder)
                case 1 {
                    // If the offset is greater than remainder, we need to split the address across two slots
                    let sliceLength := sub(bits, sub(256, offset))
                    sstore(storageSlotIndex, or(cachedStorageValue, shr(sliceLength, value)))
                    storageSlotIndex := add(storageSlotIndex, 1)
                    cachedStorageValue := shl(sub(256, sliceLength), value)
                }
                default {
                    // If the offset is less than remainder, we can fit the whole address in the slot
                    cachedStorageValue := or(cachedStorageValue, shl(sub(remainder, offset), value))
                }

                offset := mod(add(offset, bits), 256)

                // If next offset is 0, update storage slot beforehand
                if iszero(offset) {
                    sstore(storageSlotIndex, cachedStorageValue)
                    storageSlotIndex := add(storageSlotIndex, 1)
                    cachedStorageValue := sload(storageSlotIndex)
                }
            }

            if gt(cachedStorageValue, 0) { sstore(storageSlotIndex, cachedStorageValue) }

            // Increment array
            sstore(arraySlot, add(numValsToAdd, arrayLen)) // increment array length
        }
    }

    // ==========================================Slice=================================================

    function slice(Addresses storage arr, uint256 fromIndex, uint256 toIndex)
        internal
        view
        returns (address[] memory addrs)
    {
        uint256 slot;
        assembly {
            slot := arr.slot
        }

        uint256 valPointer = _slice(slot, fromIndex, toIndex, 160);
        assembly {
            addrs := valPointer
        }
    }

    function slice(Uint88 storage arr, uint256 fromIndex, uint256 toIndex)
        internal
        view
        returns (uint88[] memory uints)
    {
        uint256 slot;
        assembly {
            slot := arr.slot
        }

        uint256 valPointer = _slice(slot, fromIndex, toIndex, 88);
        assembly {
            uints := valPointer
        }
    }

    function slice(Uint96 storage arr, uint256 fromIndex, uint256 toIndex)
        internal
        view
        returns (uint96[] memory uints)
    {
        uint256 slot;
        assembly {
            slot := arr.slot
        }

        uint256 valPointer = _slice(slot, fromIndex, toIndex, 96);
        assembly {
            uints := valPointer
        }
    }

    function slice(Uint136 storage arr, uint256 fromIndex, uint256 toIndex)
        internal
        view
        returns (uint136[] memory uints)
    {
        uint256 slot;
        assembly {
            slot := arr.slot
        }

        uint256 valPointer = _slice(slot, fromIndex, toIndex, 136);
        assembly {
            uints := valPointer
        }
    }

    function slice(Uint144 storage arr, uint256 fromIndex, uint256 toIndex)
        internal
        view
        returns (uint144[] memory uints)
    {
        uint256 slot;
        assembly {
            slot := arr.slot
        }

        uint256 valPointer = _slice(slot, fromIndex, toIndex, 144);
        assembly {
            uints := valPointer
        }
    }

    function slice(Uint152 storage arr, uint256 fromIndex, uint256 toIndex)
        internal
        view
        returns (uint152[] memory uints)
    {
        uint256 slot;
        assembly {
            slot := arr.slot
        }

        uint256 valPointer = _slice(slot, fromIndex, toIndex, 152);
        assembly {
            uints := valPointer
        }
    }

    function slice(Uint160 storage arr, uint256 fromIndex, uint256 toIndex)
        internal
        view
        returns (uint160[] memory uints)
    {
        uint256 slot;
        assembly {
            slot := arr.slot
        }

        uint256 valPointer = _slice(slot, fromIndex, toIndex, 160);
        assembly {
            uints := valPointer
        }
    }

    // Gets values starting at fromIndex..toIndex (does not include toIndex)
    function _slice(uint256 slot, uint256 fromIndex, uint256 toIndex, uint256 bitSize)
        internal
        view
        returns (uint256 pointer)
    {
        assembly {
            if gt(toIndex, sload(slot)) {
                mstore(0x00, 0xb4120f14) // OutOfBounds()
                revert(0x1c, 0x04)
            }

            if iszero(gt(toIndex, fromIndex)) {
                mstore(0x00, 0x561ce9bb) // InvalidRange()
                revert(0x1c, 0x04)
            }

            // calculate beginning of slice
            let numItems := sub(toIndex, fromIndex)
            let bitsAtStart := mul(fromIndex, bitSize)
            let startSlot := div(bitsAtStart, 256)
            let offset := mod(bitsAtStart, 256)

            // free enough memory for slice
            pointer := mload(0x40)
            mstore(pointer, numItems)
            let arrayEnd := add(pointer, mul(numItems, 32))
            mstore(0x40, add(arrayEnd, 32))

            // load storage at first value of slice
            mstore(0x00, slot)
            let storageSlot := keccak256(0x00, 0x20)
            let storageSlotIndex := add(storageSlot, startSlot)
            let cachedStorageValue := sload(storageSlotIndex)

            let arrayPtr := pointer
            let i := fromIndex
            // loop through storage and store each uint in memory
            for {} lt(i, toIndex) { i := add(i, 1) } {
                arrayPtr := add(arrayPtr, 32)
                let remainder := sub(256, bitSize)
                switch gt(offset, remainder)
                // value is stored across 2 slots
                case 1 {
                    // grab first part
                    let sliceLength := sub(bitSize, sub(256, offset))
                    let highBits := shr(sub(offset, sliceLength), shl(offset, cachedStorageValue))
                    // grab second part from next storage slot
                    storageSlotIndex := add(storageSlotIndex, 1)
                    cachedStorageValue := sload(storageSlotIndex)
                    let lowBits := shr(sub(256, sliceLength), cachedStorageValue)
                    mstore(arrayPtr, or(highBits, lowBits))
                }
                default { mstore(arrayPtr, shr(sub(remainder, offset), cachedStorageValue)) }

                // if offset is 0, we are done with this storage slot
                offset := mod(add(offset, bitSize), 256)
                if iszero(offset) {
                    storageSlotIndex := add(storageSlotIndex, 1)
                    cachedStorageValue := sload(storageSlotIndex)
                }
            }
        }
    }

    // ==========================================Pop=========================================

    function pop(Addresses storage arr) internal {
        uint256 slot;
        assembly {
            slot := arr.slot
        }

        _pop(slot, 160);
    }

    function pop(Uint88 storage arr) internal {
        uint256 slot;
        assembly {
            slot := arr.slot
        }

        _pop(slot, 88);
    }

    function pop(Uint96 storage arr) internal {
        uint256 slot;
        assembly {
            slot := arr.slot
        }

        _pop(slot, 96);
    }

    function pop(Uint136 storage arr) internal {
        uint256 slot;
        assembly {
            slot := arr.slot
        }

        _pop(slot, 136);
    }

    function pop(Uint144 storage arr) internal {
        uint256 slot;
        assembly {
            slot := arr.slot
        }

        _pop(slot, 144);
    }

    function pop(Uint152 storage arr) internal {
        uint256 slot;
        assembly {
            slot := arr.slot
        }

        _pop(slot, 152);
    }

    function pop(Uint160 storage arr) internal {
        uint256 slot;
        assembly {
            slot := arr.slot
        }

        _pop(slot, 160);
    }

    // remove the last item in the array from storage
    function _pop(uint256 slot, uint256 bitSize) internal {
        assembly {
            // Calculate storage spot for array
            mstore(0x0, slot)
            let storageSlot := keccak256(0x0, 0x20)
            let numItems := sload(slot)

            if iszero(numItems) {
                mstore(0x00, 0xf1364a74) // ArrayEmpty()
                revert(0x1c, 0x04)
            }

            // calculate offset
            let totalBitsUsed := mul(numItems, bitSize)
            let slotIndex := div(totalBitsUsed, 256)
            let offset := mod(totalBitsUsed, 256)

            let indexToPop := add(storageSlot, slotIndex)

            // TODO: make this same across all functions
            switch gt(offset, sub(bitSize, 1))
            // whole value exists in this slot
            case 1 {
                let rawSlotValue := sload(indexToPop)
                let sliceLength := add(bitSize, sub(256, offset))
                let newValue := shl(sliceLength, shr(sliceLength, rawSlotValue))
                sstore(indexToPop, newValue)
            }
            // The address to pop exists across two slots
            default {
                // The second slot can be zeroed out since nothing else should be there
                sstore(indexToPop, 0)

                let decrementedArraySlot := sub(indexToPop, 1)
                let RawSlotValue := sload(decrementedArraySlot)

                // Number of bits to trim off end of this slot
                let sliceLength := sub(bitSize, offset)
                let newValue := shl(sliceLength, shr(sliceLength, RawSlotValue))
                sstore(decrementedArraySlot, newValue)
            }
            // Decrement array length
            sstore(slot, sub(numItems, 1))
        }
    }

    // ======================================Set==========================================
    function set(Addresses storage arr, uint256 index, address value) internal {
        uint256 slot;
        assembly {
            slot := arr.slot
        }
        _set(slot, index, uint256(uint160(value)), 160);
    }

    function set(Uint88 storage arr, uint256 index, uint88 value) internal {
        uint256 slot;
        assembly {
            slot := arr.slot
        }
        _set(slot, index, uint256(value), 88);
    }

    function set(Uint96 storage arr, uint256 index, uint96 value) internal {
        uint256 slot;
        assembly {
            slot := arr.slot
        }
        _set(slot, index, uint256(value), 96);
    }

    function set(Uint136 storage arr, uint256 index, uint136 value) internal {
        uint256 slot;
        assembly {
            slot := arr.slot
        }
        _set(slot, index, uint256(value), 136);
    }

    function set(Uint144 storage arr, uint256 index, uint144 value) internal {
        uint256 slot;
        assembly {
            slot := arr.slot
        }
        _set(slot, index, uint256(value), 144);
    }

    function set(Uint152 storage arr, uint256 index, uint152 value) internal {
        uint256 slot;
        assembly {
            slot := arr.slot
        }
        _set(slot, index, uint256(value), 152);
    }

    function set(Uint160 storage arr, uint256 index, uint160 value) internal {
        uint256 slot;
        assembly {
            slot := arr.slot
        }
        _set(slot, index, uint256(value), 160);
    }

    
    function _set(uint256 slot, uint256 index, uint256 value, uint256 bitSize) internal {
    assembly {
        // revert if index >= length
        if iszero(lt(index, sload(slot))) {
            mstore(0x00, 0xb4120f14) // OutOfBounds()
            revert(0x1c, 0x04)
        }

        mstore(0x0, slot)

        // Calculate storage position
        let bitStart := mul(index, bitSize)
        let startSlot := div(bitStart, 256)
        let offset := mod(bitStart, 256)
        let storageSlot := keccak256(0x0, 0x20)
        let storageSlotIndex := add(storageSlot, startSlot)

        let bitsLeftInSlot := sub(256, offset)

        switch gt(bitSize, bitsLeftInSlot)
        // Value spans two slots - use edge clearing with shr/shl
        case 1 {
            // First slot: clear right edge and set first chunk
            let cleanedSlot1 := shl(bitsLeftInSlot, shr(bitsLeftInSlot, sload(storageSlotIndex)))
            let chunk2Size := sub(bitSize, bitsLeftInSlot)
            let chunk1 := shr(chunk2Size, value)
            sstore(storageSlotIndex, or(cleanedSlot1, chunk1))

            // Second slot: clear left edge and set second chunk  
            storageSlotIndex := add(storageSlotIndex, 1)
            let slot2 := sload(storageSlotIndex)
            let cleanedSlot2 := shr(chunk2Size, shl(chunk2Size, slot2))
            let chunk2 := shl(sub(256, chunk2Size), value)
            sstore(storageSlotIndex, or(cleanedSlot2, chunk2))
        }
        // Value fits in one slot 
        default {
            // use mask to clean slot
            let shiftSize := sub(bitsLeftInSlot, bitSize)
            let mask := shl(shiftSize, sub(shl(bitSize, 1), 1))
            let cleanedSlot := and(sload(storageSlotIndex), not(mask))
            let newValue := shl(shiftSize, value)
            sstore(storageSlotIndex, or(cleanedSlot, newValue))
        }
    }
}

    struct Addresses {
        uint256[] slots;
    }

    struct Uint88 {
        uint256[] slots;
    }

    struct Uint96 {
        uint256[] slots;
    }

    struct Uint136 {
        uint256[] slots;
    }

    struct Uint144 {
        uint256[] slots;
    }

    struct Uint152 {
        uint256[] slots;
    }

    struct Uint160 {
        uint256[] slots;
    }

    struct Uint168 {
        uint256[] slots;
    }

    struct Uint176 {
        uint256[] slots;
    }
}
