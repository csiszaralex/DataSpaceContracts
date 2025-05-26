// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Transaction {
  address public from;
  address public to;
  bytes public data;
  uint256 public timestamp;
  bool public completed;

  event TransactionCompleted(
    address indexed from,
    address indexed to,
    bytes data
  );

  constructor(address _from, address _to, bytes memory _data) {
    from = _from;
    to = _to;
    data = _data;
    timestamp = block.timestamp;
    completed = false;
  }

  function completeTransaction() public {
    require(msg.sender == to, "Only recipient can complete transaction");
    require(!completed, "Transaction already completed");
    completed = true;
    emit TransactionCompleted(from, to, data);
  }
}
