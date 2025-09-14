//SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import "../interfaces/IERC20.sol";

error InvalidAmount(string message);
error DepositeFailed(address sender, uint256 amount);
error InsufficientBalance(address user, uint256 balance, uint256 amount);
error WithdrawlFailed(address sender, uint256 amount);

contract TokenBank {
    event Deposite(string indexed sender, uint256 amount);
    event Withdrawl(string indexed sender, uint256 amount);

    struct User {
        string username;
        uint256 balance;
        uint256 stacked;
    }

    mapping(address ethereumAddress => User userData) private users;

    IERC20 private token;

    constructor(address deployedToken) {
        token = IERC20(deployedToken);
    }

    function addUser(string memory _username) public {
        users[msg.sender] = User({username: _username, balance: 0, stacked: 0});
    }

    function deposite(uint256 amount) public {
      User storage user = users[msg.sender];
        if (amount == 0) revert InvalidAmount("Amount shouldn't be zero");
        bool success = token.transferFrom(msg.sender, address(this), amount);
        user.balance += amount;
        if (!success) revert DepositeFailed(msg.sender, amount);
        emit Deposite(user.username, amount);
    }

    function withdraw(uint256 amount) public {
        User storage user = users[msg.sender];
        if (user.balance < amount) {
            revert InsufficientBalance(msg.sender, user.balance, amount);
        }
        bool success = token.transfer(msg.sender, amount);
        if (!success) revert WithdrawlFailed(msg.sender, amount);
        user.balance -= amount;
        emit Withdrawl(user.username, amount);
    }

    function getBalance() public view returns (uint256) {
        return users[msg.sender].balance;
    }

    function getInfo() public view returns (User memory) {
        return users[msg.sender];
    }
}
