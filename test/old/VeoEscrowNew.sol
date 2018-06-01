pragma solidity ^0.4.23;

// @title MadEscrow -- trustless escrow smart contract for VEO<->ETH swaps
// @author ryanhendricks@gmail.com
/**
 *      This escrow contract uses a similar mechanism as the MAD escrow protocol.
 *      https://pbs.twimg.com/media/DcsJhB7VQAA-kHx.jpg?name=orig
 *      www.particl.io
 *
 *      MAD = mutually assured destruction. The significance of this title is that
 *      both the buyer and seller are disincentivized to cheat since neither would
 *      be able to take actions that would harm the other party without also harming
 *      themselves to an equal extent.
 *
 *      Imagine this scenario:
 *      Buyer A wants to purchase some VEO from Seller B using ETH. Let's assume
 *      that the 2 parties agree to make the trade for 10 VEO in exchange for 5 ETH.
 *      Who sends first? or do they use an escrow service?
 *      Without a trusted third party one of the parties will be taking on a large risk.
 *
 *      The escrow contract eliminates the need for a 3rd party and works as follows:
 *      - BOTH Buyer A and Seller B deposit 5 ETH into the escrow contract.
 *      - Buyer A deposits an additional 5 ETH (or all 10 at once to save in txn fees).
 *      - Seller B sends the 10 VEO to Buyer A and Finalizes the escrow contract.
 *      - Buyer A confirms the receipt of VEO and also Finalizes the escrow contract.
 *      - Seller B receives their 5 ETH deposit and 5 ETH from Buyer A.
 *      - Buyer A receives their 5 ETH deposit.
 *      - If either party does not finalize then neither party receives any of the funds.
 *
 *      Now let's imagine that either the buyer or the seller has bad intentions.
 *      Since BOTH parties must sign off to finalize the escrow otherwise BOTH lose their
 *      funds in the escrow contract they are disincentivized from not doing the right thing.
 *      If Buyer A receives the VEO but doesn't finalize then they will have paid 2x the original
 *      amount agreed upon in trade.
 *      If Seller B doesn't send the VEO they will lose the amount they would have received for
 *      the VEO in addition to not getting paid.
 *
 *      
 */


contract VeoEscrowNew {


  address public buyer; //BUYER
  address public seller; //SELLER

  // contract state variables
  bool public initiated = false; 
  bool public finalized = false;
  bool public buyerHasFunded = false;
  bool public sellerHasFunded = false;
  bool public escrowFullyFunded = false;

  // Blocknumber at contract creation

  // purchaseAmount is the cost in ETH paid by the buyer
  // totalEscrowAmount is the funds provided by BOTH
  // buyer and seller including the funds used for
  // the actual trade/purchase
  // this value should equal 3x purchase amount
  uint public purchaseAmount = 0;
  uint public totalEscrowAmount = 0;
  uint public buyerRequiredEscrow = 0;
  uint public sellerRequiredEscrow = 0;
  uint public buyerEscrowedFunds = 0;
  uint public sellerEscrowedFunds = 0;
  
  // Once funded, both parties must finalize the trade/sale
  bool public buyerfinalized = false;
  bool public sellerfinalized = false;

  event Error(address error);
  event Terms(uint purchaseAmount, uint totalEscrowAmount, uint BuyerRequiredFunding, uint SellerRequiredFunding);
  event Initiated(address initiator, address buyer, address seller, uint tradeFundsforXfer);
  event FundsReceived(address sender, uint amount);
  event PartyFinalized(address party);
  event EscrowComplete(bool completed);

  // check to make sure contract not currently initiated
  modifier notInitiated() {
    require(initiated == false);
    _;
  }

  // check to ensure contract is fully funded
  // 1 - escrowFullyFunded bool should be true
  // 2 - the sum of all funds should not be less
  //     than three times the mutualEscrowAmount
  modifier isFullyFunded() {
    require(escrowFullyFunded == true);
    _;
  }



  // Constructor
  function VeoEscrowNew() public {
    
  }

  /**
   * @dev Initiate the escrow contract and allow funds to be sent for escrow
   *  _counterParty address of the other party for the trade
   *  _purchaseAmount uint256 amount of ETH to be paid for VEO
   *  _initiaterIsBuyer bool indicating whether initiator is buyer or seller
   */
  function buyerInitiate(address _seller, uint _purchaseAmount) notInitiated public {
    require(_seller != address(0));
    require(msg.sender != _seller);
    require(_purchaseAmount > 0);
    escrowFullyFunded = false;
    buyer = msg.sender; //Buyer
    seller = _seller; //Seller
    initiated = true;
    emit Initiated(msg.sender, buyer, seller, _purchaseAmount);
    setRequiredFunding(_purchaseAmount);
  }

  function sellerInitiate(address _buyer, uint _purchaseAmount) notInitiated public {
    require(_buyer != address(0));
    require(msg.sender != _buyer);
    escrowFullyFunded = false;
    seller = msg.sender; //Buyer
    buyer = _buyer; //Seller
    initiated = true;
    emit Initiated(msg.sender, buyer, seller, _purchaseAmount);
    setRequiredFunding(_purchaseAmount);
  }

  function setRequiredFunding(uint _purchaseAmount) internal {
    buyerRequiredEscrow = _purchaseAmount * 2;
    sellerRequiredEscrow = _purchaseAmount;
    totalEscrowAmount = _purchaseAmount * 3;
    purchaseAmount = _purchaseAmount;
    assert(totalEscrowAmount == (buyerRequiredEscrow + sellerRequiredEscrow));
    emit Terms(purchaseAmount, totalEscrowAmount, buyerRequiredEscrow, sellerRequiredEscrow);
  }


  function() external payable {
    address _funder = msg.sender;
    uint _amount = msg.value;
    fundContract(_funder, _amount);
    emit FundsReceived(_funder, _amount);
  }
  // fund contract function to be called by both parties when sending
  // ETH to the contract and also check if fully funded after funds received
  function fundContract(address _funder, uint _amount) internal {
    if (_funder == buyer && buyerEscrowedFunds <= buyerRequiredEscrow) {
      uint buyerCurrentFunds = buyerEscrowedFunds;
      buyerEscrowedFunds = buyerCurrentFunds + _amount;
    } 
    if (_funder == seller && sellerEscrowedFunds <= sellerRequiredEscrow) {
      uint sellerCurrentFunds = sellerEscrowedFunds;
      sellerEscrowedFunds = sellerCurrentFunds + _amount;
    }
    checkFundingStatus();


    // return checkFundingStatus();

  }
  // @dev internal function to check funding status
  // @dev if both buyer and seller have sent enough ETH
  //      as per required amounts than set escrowFullyFunded to true
  function checkFundingStatus() internal {
    if (buyerEscrowedFunds >= buyerRequiredEscrow) {
      buyerHasFunded = true;
    }
    if (sellerEscrowedFunds >= sellerRequiredEscrow) {
      sellerHasFunded = true;
    }
    if (sellerHasFunded == true && buyerHasFunded == true) {
      escrowFullyFunded = true;
      buyerfinalized = true;
    } else {
      escrowFullyFunded = false;
    }
  }
  
  // @dev Once fully funded, both parties must finalize the transaction
  // @dev and once both finalizations are received the funds are released accordingly
  function buyerFinalize() public {
    if (buyerHasFunded == true) {
    buyerfinalized = false;
    emit PartyFinalized(msg.sender);
    }
    if (sellerfinalized == true) {
      finalizeTrade();
    }
  }

  function sellerFinalize() public {
    sellerfinalized = true;
    emit PartyFinalized(msg.sender);
    if (buyerfinalized == true) {
      finalizeTrade();
    }
  }

  function finalizeTrade() public {
    require(sellerHasFunded == true);
    require(buyerHasFunded == true);
    require(address(this).balance >= totalEscrowAmount);
    require(finalized == false);
    emit EscrowComplete(finalized);
    seller.transfer(purchaseAmount + sellerEscrowedFunds);
    buyer.transfer(buyerEscrowedFunds - purchaseAmount);
    finalized = true;
    selfdestruct(seller);
  }

}