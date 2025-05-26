// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Transactions.sol";
import {Participant} from "./utils.sol";

contract DataContract {
  address public owner;
  address public paymentToken;
  uint256 public baseFeePerParticipant;

  Participant[] public participants;
  mapping(address => bool) public isParticipant;
  address[] public transactionContracts;

  event TransactionCreated(
    address indexed from,
    address indexed to,
    address transactionAddress
  );
  event PaymentDistributed(address indexed to, uint256 amount);

  modifier onlyOwner() {
    require(msg.sender == owner, "Not contract owner");
    _;
  }

  constructor(
    Participant[] memory _participants,
    address _owner,
    address _paymentToken,
    uint256 _baseFeePerParticipant
  ) {
    owner = _owner;
    paymentToken = _paymentToken;
    baseFeePerParticipant = _baseFeePerParticipant;

    for (uint i = 0; i < _participants.length; i++) {
      participants.push(_participants[i]);
      isParticipant[_participants[i].account] = true;
    }
  }

  function getParticipants() public view returns (Participant[] memory) {
    return participants;
  }

  function getAllParticipants() public view returns (address[] memory) {
    address[] memory addrs = new address[](participants.length);
    for (uint i = 0; i < participants.length; i++) {
      addrs[i] = participants[i].account;
    }
    return addrs;
  }

  function processData(bytes memory data) public {
    require(isParticipant[msg.sender], "Unauthorized sender");

    for (uint i = 0; i < participants.length - 1; i++) {
      if (participants[i].account == msg.sender) {
        address to = participants[i + 1].account;
        Transaction txContract = new Transaction(msg.sender, to, data);
        transactionContracts.push(address(txContract));
        emit TransactionCreated(msg.sender, to, address(txContract));
        return;
      }
    }

    revert("Sender not part of processing chain or is the last participant");
  }

  function getAllTransactions() public view returns (address[] memory) {
    return transactionContracts;
  }

  function distributePayments() public onlyOwner {
    uint256 total = baseFeePerParticipant * participants.length;
    uint256 portion = total / participants.length;

    for (uint i = 0; i < participants.length; i++) {
      (bool success, ) = participants[i].account.call{value: portion}("");
      require(success, "Payment failed");
      emit PaymentDistributed(participants[i].account, portion);
    }
  }

  receive() external payable {}
}
