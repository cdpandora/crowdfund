// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Fund {

// @dev Crowdfunding contract

    address owner;
    uint256 projectBalance = address(this).balance;
    uint256 target;
    uint256 deadline = block.timestamp + 7 days;
    
    mapping(address => uint256) public donor;


    constructor (uint256 _target) {
        owner = msg.sender;
        target = _target;
    }

    event _deposit(uint256, string);
    event _withdraw(string);

    modifier onlyOwner() {
        require(msg.sender == owner, "You do not have permission");
        _;
    }

    function deposit() public payable {
        require(projectBalance < target, "Target reached");

        require(block.timestamp < deadline);
        require(msg.value >= 1e18, "You have to deposit 1 eth");
        projectBalance += msg.value;

        emit _deposit(msg.value, "deposit successful");
        donor[msg.sender] = msg.value;
    }

    function withdraw(address _to) public onlyOwner{
        (bool success,) = _to.call{value: projectBalance}("");
        require(success, "Withdrawal failed");
        emit _withdraw("Withdrawal successfull");
    }
    
}