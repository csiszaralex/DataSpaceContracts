// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./DataContract.sol";
import "./Transactions.sol";
import {Participant} from "./utils.sol";

contract ContractFactory {
  address[] public deployedContracts;
  address[] public deployedTransactions;

  event DataContractCreated(address indexed creator, address payable dataContract);
  event TransactionCreated(
    address indexed from,
    address indexed to,
    address transaction
  );

  function createDataContract(
    Participant[] memory participants,
    address paymentToken,
    uint256 baseFeePerParticipant
  ) public returns (address) {
    DataContract newContract = new DataContract(
      participants,
      msg.sender,
      paymentToken,
      baseFeePerParticipant
    );

    deployedContracts.push(address(newContract));
    emit DataContractCreated(msg.sender, payable(address(newContract)));
    return address(newContract);
  }

  function payParticipants(
    address payable dataContractAddress,
    bytes memory data
  ) public returns (address) {
    DataContract dc = DataContract(dataContractAddress);
    address[] memory participants = dc.getAllParticipants();

    for (uint i = 0; i < participants.length - 1; i++) {
      if (participants[i] == msg.sender) {
        address to = participants[i + 1];
        Transaction txContract = new Transaction(msg.sender, to, data);
        deployedTransactions.push(address(txContract));
        emit TransactionCreated(msg.sender, to, address(txContract));
        return address(txContract);
      }
    }

    revert("Sender is not in the participant chain or is the last participant");
  }

  function getAllContracts() public view returns (address[] memory) {
    return deployedContracts;
  }

  function getAllTransactions() public view returns (address[] memory) {
    return deployedTransactions;
  }
}
