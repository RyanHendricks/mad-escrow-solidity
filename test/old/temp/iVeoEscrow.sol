pragma solidity ^0.4.22;

contract IVeoEscrow {
  function partyA() public constant returns(address);
  function partyB() public constant returns(address);
  function purchaseAmountTotal() public constant returns(uint256);
  function initiated() public constant returns(bool);
  function finalized() public constant returns(bool);
  function createdBlock() public constant returns(uint);
  function mutualEscrowAmount() public constant returns(uint256);
  function requiredFunding() public constant returns(uint256);
  function fundedAmount() public constant returns(uint256);
  function escrowFullyFunded() public constant returns(bool);
  function partyAfinalized() public constant returns(bool);
  function partyBfinalized() public constant returns(bool);
  function Initiate(
    address _counterParty,
    uint256 _purchaseAmount,
    bool _initiaterIsBuyer  public;
  function fundContract() public payable returns (bool);
  function simulatefundContract(address _sender, uint _amount) public returns (bool fullyFunded);
  function completeTrade() public;
}
