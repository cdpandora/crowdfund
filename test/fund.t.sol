pragma solidity ^0.8.13;

import {Test} from "../lib/forge-std/src/Test.sol";
import { Fund } from "../src/fund.sol";


contract testFund is Test { 
    Fund fund;
    address Alice = payable(address(1));
    address Bob = payable(address(2));
    address James = payable(address(3));
    address owner = payable(address(0x1));

    function setUp() public {
        fund = new Fund(10 ether);
    }

    function test_deposit() public {
        vm.deal(Alice, 1 ether);
        vm.prank(Alice);
        fund.deposit{value: 1 ether}();
        assertEq(address(fund).balance, 1 ether);
    }  

    function test_depositAfterDeadline() public {
        vm.deal(Alice, 1 ether);
        vm.prank(Alice);
        skip(8 days);
        vm.expectRevert();
        fund.deposit{value: 1 ether}();
    }

    function test_depositAfterTargetReached() public {
        vm.deal(Alice,5 ether);
        vm.prank(Alice);
        fund.deposit{value: 5 ether}();

        vm.deal(Bob, 5 ether);
        vm.prank(Bob);
        fund.deposit{value: 5 ether}();

        vm.deal(James, 1 ether);
        vm.prank(James);
        vm.expectRevert();
        fund.deposit{value: 1 ether}();
    }

    function test_withdraw() public {
        vm.deal(Alice,5 ether);
        vm.prank(Alice);
        fund.deposit{value: 5 ether}();

        vm.deal(Bob, 5 ether);
        vm.prank(Bob);
        fund.deposit{value: 5 ether}();

        fund.withdraw(owner);
        assertGt(address(owner).balance, 0);
    }

    function test_withdrawNotOwner() public {
        vm.deal(Alice,5 ether);
        vm.prank(Alice);
        fund.deposit{value: 5 ether}();

        vm.deal(Bob, 5 ether);
        vm.prank(Bob);
        fund.deposit{value: 5 ether}();

        vm.prank(James);
        vm.expectRevert();
        fund.withdraw(owner);
    }

} 