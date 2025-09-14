//SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import "../interfaces/IERC20.sol";
import "../utils/Ownable.sol";
import "../utils/ReentrancyGuard.sol";

error InvalidAddress(address account);
error InvalidAmount(uint256 balance, uint256 amount);
error InsufficientAllowance(address owner, address spender, uint256 amount);

contract ERC20 is IERC20, Ownable, ReentrancyGuard {
    string public name;
    string public symbol;
    uint256 public _totalSupply;
    uint256 public reward = 200;

    mapping(address holder => uint256 balance) private balances;
    mapping(address owner => mapping(address spender => uint256 approved)) private approved;

    constructor(string memory _name, string memory _symbol, uint256 totalSupply_) Ownable() {
        name = _name;
        symbol = _symbol;
        totalSupply_ = _totalSupply;
    }

    modifier validAddress(address account) {
        if (address(0) == account) revert InvalidAddress(account);
        _;
    }

    modifier validAmount(address from, uint256 amount) {
        uint256 balance = balances[from];
        if (balance < amount) revert InvalidAmount(balance, amount);
        _;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address holder) public view returns (uint256) {
        return balances[holder];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return approved[owner][spender];
    }

    function transfer(address to, uint256 amount) public nonReentract returns (bool) {
        bool success = safeTransfer(to, amount);
        return success; // consider adding a try catch
    }

    function safeTransfer(address to, uint256 amount)
        private
        validAddress(to)
        validAmount(msg.sender, amount)
        returns (bool)
    {
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function approve(address to, uint256 amount)
        public
        validAddress(to)
        validAmount(msg.sender, amount)
        returns (bool)
    {
        approved[msg.sender][to] += amount;
        emit Approval(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount)
        public
        validAmount(from, amount)
        nonReentract
        returns (bool)
    {
        bool success = safeTransferFrom(from, to, amount);
        return success; // consider adding a try catch
    }

    function safeTransferFrom(address from, address to, uint256 amount)
        private
        validAddress(from)
        validAddress(to)
        returns (bool)
    {
        if (approved[from][msg.sender] < amount) revert InsufficientAllowance(from, msg.sender, amount);
        balances[from] -= amount;
        approved[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function mine() public {
        balances[msg.sender] += reward;
    }
}
