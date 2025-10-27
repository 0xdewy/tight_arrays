# Tight Arrays

## Overview 

This library creates tightly packed arrays of any size, using 100% of the storage space available. It does this by storing values across 2 storage slots when necessary.

By default Solidity will try to fit as many array elements into a 256 bit storage as possible but it avoids storing values across 2 storage slots. For addresses/uint136-184 it is much more efficient to split the value across storage slots and reconstruct the value when needed.

## Usage

```solidity
contract YourContract {
    // import the Array type for your datatypes
    using Array for Array.Uint96;
    using Array for Array.Address;

    // declare array types in storage
    Array.Uint96 public array;
    Array.Address public addressArray;


    function example(uint96 val, uint96[] memory vals) public {
        // push a single item to the end of the array
        array.push(val);

        // remove last element from the array
        array.pop();

        // append another array onto the end of this array
        array.append(vals);

        // insert an item anywhere in the array
        array.set(5, val);

        // get an item from anywhere in the array
        uint96 elementFromArray = array.get(20);

        // get a range of elements from the array
        uint96[] memory elements = array.slice(5, 20);

        // same usage for all data types
        addressArray.push(msg.sender);
        addressArray.pop();
        // etc...

    }
}
```

## Gas Efficiency
This library generally adds 1-2% of gas overhead when ignoring storage savings, but since storage is such a large percentage of the gas costs, this library can save up to 45% on gas costs depending on the data size used

| Operation          | Normal Array | Packed Array | Percentage |
|--------------------|--------------|--------------|------------|
| Uint136 (100 vals) | 2,280,408    | 1,237,606    | -45.72%    |
| Address (100 vals) | 2,280,410    | 1,436,755    | -36.99%    |


The amount gas saved depends on how nicely the data fits into 256 bits by default. Best to use this library only with values that leave a large remainder:

| Bitsize | 256 % Bitsize |
|---------|---------------|
| 8       | 0             |
| 16      | 0             |
| 24      | 16            |
| 32      | 0             |
| 40      | 16            |
| 48      | 16            |
| 56      | 32            |
| 64      | 0             |
| 72      | 40            |
| 80      | 16            |
| 88      | 80            |
| 96      | 64            |
| 104     | 48            |
| 112     | 32            |
| 120     | 16            |
| 128     | 0             |
| 136     | 120           |
| 144     | 112           |
| 152     | 104           |
| 160     | 96            |
| 168     | 88            |
| 176     | 80            |
| 184     | 72            |
| 192     | 64            |
| 200     | 56            |
| 208     | 48            |
| 216     | 40            |
| 224     | 32            |
| 232     | 24            |
| 240     | 16            |
| 248     | 8             |
| 256     | 0             |



## Build

```shell
$ forge build
```

## Test

```shell
$ forge test
```

## Security

The code is tested but not audited. Please reach out if there is any interest in auditing the code, I'm happy to help. 

## Contributing

Contributions to the library are welcome. Please submit pull requests for any enhancements or to add more data types.

