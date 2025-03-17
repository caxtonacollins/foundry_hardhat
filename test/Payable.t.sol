// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import { Test, console } from "forge-std/Test.sol";
import { Payable, Funder } from "../src/Payable.sol";

error FunctionDoesNotExit();
error FailedToSendEth();

contract PayableTest is Test {
  Payable public payable_contract;
  Funder public funder_contract;
  address public owner = makeAddr("owner");
  address public addr1 = makeAddr("addr1");
  uint256 expected_initial_bal = 100 ether;
  uint256 expected_initial_addr1_bal = 0 ether;

  function setUp() public {
    vm.deal(owner, 100 ether);
    vm.deal(addr1, 100 ether);

    vm.prank(owner);

    payable_contract = new Payable();
    funder_contract = new Funder();
  }

  function test_constructor_test_owner() public view {
    assertEq(payable_contract.owner(), owner);
  }

  function test_deposit() public {
    uint256 initial_addr1_bal = address(addr1).balance;
    uint256 initial_payable_contract_bal = address(payable_contract).balance;
    uint256 deposit_amount = 1 ether;

    assertEq(initial_addr1_bal, expected_initial_bal);
    assertEq(initial_payable_contract_bal, expected_initial_addr1_bal);

    vm.startPrank(addr1);
    payable_contract.deposit{ value: deposit_amount }(deposit_amount);
    vm.stopPrank();

    uint256 final_addr1_bal = address(addr1).balance;
    uint256 final_contract_bal = address(payable_contract).balance;

    assertEq(
      final_addr1_bal,
      expected_initial_bal - deposit_amount,
      "Address1 balance should decrease by deposit amount"
    );

    assertEq(final_contract_bal, deposit_amount, "Contract balance should match deposit amount");
    assertEq(payable_contract.getInvestment(addr1), deposit_amount);
    assertEq(address(payable_contract).balance, deposit_amount);
  }

  function test_get_investment() public {
    uint256 initial_addr1_bal = address(addr1).balance;
    uint256 initial_payable_contract_bal = address(payable_contract).balance;
    uint256 deposit_amount = 2 ether;

    assertEq(initial_addr1_bal, expected_initial_bal);
    assertEq(initial_payable_contract_bal, expected_initial_addr1_bal);

    vm.prank(addr1);
    payable_contract.deposit{ value: deposit_amount }(deposit_amount);

    uint256 final_addr1_bal = address(addr1).balance;
    uint256 final_contract_bal = address(payable_contract).balance;

    assertEq(
      final_addr1_bal,
      expected_initial_bal - deposit_amount,
      "Address1 balance should decrease by deposit amount"
    );

    assertEq(final_contract_bal, deposit_amount, "Contract balance should match deposit amount");
    assertEq(payable_contract.getInvestment(addr1), deposit_amount);
  }

  function test_get_contract_balance() public view {
    uint256 initialBalance = address(payable_contract).balance / 1 ether;
    assertEq(
      payable_contract.getContractBalance(),
      initialBalance,
      "Contract balance must be equal to zero"
    );
  }

  function test_fallback() public payable {
    uint256 initial_payable_contract_bal = address(payable_contract).balance;
    address payable receiver = payable(address(payable_contract));
    uint256 _value = 3 ether;
    (bool success,) = receiver.call{ value: _value }(abi.encodeWithSignature(""));
    assertTrue(success, "Fallback failed oo, hmmm");
    assertEq(initial_payable_contract_bal + _value, _value);
    assertEq(payable_contract.counter(), 1, "Fallback counter should increase");
  }

  function test_eth_with_transfer() public payable {
    address payable receiver = payable(address(payable_contract));
    uint256 initial_balance = address(payable_contract).balance;
    assertEq(initial_balance, 0 ether);
    assertEq(expected_initial_bal, 100 ether);
    uint256 _value = 4 ether;

    vm.startPrank(addr1);
    funder_contract.sendWithTransfer{ value: _value }(receiver);
    vm.stopPrank();

    uint256 final_addr1_bal = address(addr1).balance;
    uint256 final_contract_bal = address(payable_contract).balance;

    assertEq(
      final_addr1_bal,
      expected_initial_bal - _value,
      "Address1 balance should decrease by deposit amount"
    );
    assertEq(final_contract_bal, _value, "Contract balance should match deposit amount");
    assertEq(
      address(payable_contract).balance,
      initial_balance + _value,
      "Current contract balance should increase"
    );
  }

  function test_send_with_send() public payable {
    address payable receiver = payable(address(payable_contract));
    uint256 initial_balance = address(payable_contract).balance;
    assertEq(initial_balance, 0 ether);
    assertEq(expected_initial_bal, 100 ether);

    uint256 _value = 5 ether;

    vm.startPrank(addr1);
    bool sent = funder_contract.sendWithSend{ value: _value }(receiver);
    vm.stopPrank();

    uint256 final_addr1_bal = address(addr1).balance;
    uint256 final_contract_bal = address(payable_contract).balance;

    assertEq(
      final_addr1_bal,
      expected_initial_bal - _value,
      "Address1 balance should decrease by deposit amount"
    );
    assertEq(final_contract_bal, _value, "Contract balance should match deposit amount");

    assertTrue(sent, "Transfer failed");
    assertEq(
      address(payable_contract).balance,
      initial_balance + _value,
      "Curren contract balance should increase"
    );
  }

  function test_send_with_call_deposit() public {
    uint256 initial_balance = address(payable_contract).balance;
    assertEq(expected_initial_bal, 100 ether);
    assertEq(initial_balance, 0 ether);

    uint256 _value = 6 ether;

    vm.startPrank(addr1);
    funder_contract.callDeposit{ value: _value }(payable(address(payable_contract)));
    vm.stopPrank();

    uint256 final_addr1_bal = address(addr1).balance;
    uint256 final_contract_bal = address(payable_contract).balance;

    assertEq(
      final_addr1_bal,
      expected_initial_bal - _value,
      "Address1 balance should decrease by deposit amount"
    );
    assertEq(final_contract_bal, _value, "Contract balance should match deposit amount");
    assertEq(
      payable_contract.getInvestment(address(funder_contract)),
      _value,
      "Investment should be recorded"
    );
  }
}
