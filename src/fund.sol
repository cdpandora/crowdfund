// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Fund is ReentrancyGuard {

    // @dev Crowdfunding contract

    address owner;
    uint256 projectBalance = address(this).balance;
    uint256 target;
    uint256 deadline = block.timestamp + 7 days;
    bool fundStart;
    bool fundFailed;
    
    mapping(address => uint256) public donor;
    
    // @dev There are 3 teirs and depositors will be added based on 
    // how much contributed (gold, plat, diamond)
    // gold is 1 ether
    // plat is 2 ether
    // diamond is 4 ether

    mapping(address => Teirs) public _Teirs;

    event _deposit(uint256, string);
    event _withdraw(string);
    event _TeirUpgrade(Teirs);

    enum Teirs {
        None,
        Gold,
        Platinum,
        Diamond
    }

    constructor (uint256 _target) {
        owner = msg.sender;
        target = _target;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You do not have permission");
        _;
    }

    function deposit() external payable nonReentrant {

        address from = msg.sender;
        uint256 value = msg.value;
        // require target has not reached
        require(projectBalance < target, "Target reached");
        
        // dont allow deposits if they already have a teir
        require(_Teirs[from] == Teirs.None , "Already In a Teir");


        require(block.timestamp < deadline, "Deadline Passed");
        require(value >= 1e18, "You have to deposit at least 1 eth");



        projectBalance += value;


        // add to teirs
        if (value >= 1e18 && value < 2e18 ) {
            _Teirs[from] = Teirs.Gold;
        } else if (value >= 2e18 && value < 4e18) {
            _Teirs[from] = Teirs.Platinum;
        } else {
            _Teirs[from] = Teirs.Diamond;
        }

        donor[from] = value;
        fundStart = true;
        emit _deposit(value, "deposit successful");
    }

    function withdraw(address _to) external onlyOwner {
       require(projectBalance == target, "target not reached!");
        require(_to != address(0), "incorrect address");
        require(fundStart);

        (bool success,) = _to.call{value: projectBalance}("");
        require(success, "Withdrawal failed");

        emit _withdraw("Withdrawal successfull");
    }

    function claimRefund(uint256 amount) external nonReentrant {
        address _addr = msg.sender;
        require(amount > 0 && donor[_addr] >= amount, "Not Enough Balance");
        require(projectBalance < target, "Target reached");
        
        donor[_addr] -= amount;

        (bool success,) = _addr.call{value: amount}("");
        require(success);
    }


    function upgradeTeir() external payable nonReentrant {
        address sender = msg.sender;
        require(_Teirs[sender] != Teirs.Diamond, "Already Maxxed out");

        uint256 balanceBefore = donor[sender];
        uint256 balanceAfter = balanceBefore + msg.value;

        require(balanceAfter >= 2e18, "oops! Stuck, Send at least 2ether to pass Gold Teir");
        
        if (balanceAfter >= 2e18) {
            _Teirs[sender] = Teirs.Platinum;
        } else if (balanceAfter >= 4e18) {
            _Teirs[sender] = Teirs.Diamond;
        }
        
        donor[sender] += msg.value;

        emit _TeirUpgrade(_Teirs[sender]);
    }

    receive() external payable {
        
    }

}