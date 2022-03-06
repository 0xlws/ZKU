//SPDX-License-Identifier: MIT

// set solidity compiler version
pragma solidity ^0.8.4;


contract SimpleUintStorage {
    // declare private state variable
    uint private number;

    // set value to the number variable with a setter function
    function setNumber(uint _number) public {
        number = _number;
    }

    // retrieve value from the number variable
    // with a public getter function
    function getNumber() public view returns (uint) {
        return number;
    }
}