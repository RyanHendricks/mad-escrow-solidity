pragma solidity ^0.4.23;

contract IVeoEscrowLive {
  function buyer() public constant returns(address);
  function seller() public constant returns(address);
  function purchaseAmount() public constant returns(uint);
  function initiated() public constant returns(bool);
  function finalized() public constant returns(bool);
  function buyerRequiredEscrow() public constant returns(uint);
  function sellerRequiredEscrow() public constant returns(uint);
  function totalEscrowAmount() public constant returns(uint);
  function buyerEscrowedFunds() public constant returns(uint);
  function sellerEscrowedFunds() public constant returns(uint);
  function buyerHasFunded() public constant returns(bool);
  function sellerHasFunded() public constant returns(bool);
  function escrowFullyFunded() public constant returns(bool);
  function buyerfinalized() public constant returns(bool);
  function sellerfinalized() public constant returns(bool);
  function fundContract(address _funder, uint _amount) public;
  function buyerFinalize() public;
  function sellerFinalize() public;
}