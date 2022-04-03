// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
mapping(address => uint256) public balances;

uint256 public constant threshold = 1 ether;

event Stake(address indexed sender, uint256 amount);

function stake() public payable {
  balances[msg.sender] += msg.value;

  emit Stake(msg.sender, msg.value);
}

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value

uint256 public deadline = block.timestamp + 30 seconds;

modifier deadlineReached(bool requireReached) {
  uint256 timeRemaining = timeLeft();
  if(requireReached) {
    require(timeRemaining = 0, "Deadline is not reached yet");
  } else {
    require(timeRemaining > 0, "Deadline is already reached");
  }
  _;
}


modifier stakeNotCompleted() {
    bool completed = exampleExternalContract.completed();
    require(!completed, "staking process already completed");
    _;
  }


  function execute() public stakeNotCompleted deadlineReached(false) {
    uint256 contractBalance = address(this).balance;


// if the `threshold` was not met, allow everyone to call a `withdraw()` function
    require(contractBalance >= threshold, "Threshold not reached");

   (bool sent,) = address(exampleExternalContract).call{value: contractBalance}(abi.encodeWithSignature("complete()"));
    require(sent, "exampleExternalContract.complete failed");
  }


  // Add a `withdraw()` function to let users withdraw their balance

  function withdraw() public deadlineReached(true) stakeNotCompleted {
    uint256 userBalance = balances[msg.sender];

    require(userBalance > 0, "You don't have balance to withdraw");

    balances[msg.sender] = 0;

    (bool sent,) = msg.sender.call{value: userBalance}("");
    require(sent, "Failed to send user balance back to the user");
  }



  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
 function timeLeft() public view returns (uint256 timeleft) {
    if( block.timestamp >= deadline ) {
      return 0;
    } else {
      return deadline - block.timestamp;
    }
  }

  // Add the `receive()` special function that receives eth and calls stake()
 receive() {
       msg.value (this.balance);
}

}
