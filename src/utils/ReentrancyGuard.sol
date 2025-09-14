//SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

error ReentrancyProblem(address caller);

contract ReentrancyGuard {
    bool locked;

    modifier nonReentract() {
        if (locked) revert ReentrancyProblem(msg.sender);
        locked = false;
        _;
        locked = false;
    }
}
