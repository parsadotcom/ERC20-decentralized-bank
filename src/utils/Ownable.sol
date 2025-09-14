//SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

error OnlyOwner(address sender);

contract Ownable {
    event TransferOwnership(address indexed oldOwner, address indexed newOwner);
    event RemoveOwnership(address indexed owner);

    address private owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (owner != msg.sender) revert OnlyOwner(msg.sender);
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        address oldOwner = owner;
        owner = newOwner;
        emit TransferOwnership(oldOwner, newOwner);
    }

    function removeOwnership() public onlyOwner {
        address oldOwner = owner;
        owner = address(0);
        emit RemoveOwnership(oldOwner);
    }
}
