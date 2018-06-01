pragma solidity ^0.4.24;

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

  // Escrow parameters set at deployment
  address public buyer; //BUYER
  address public seller; //SELLER
  uint public purchaseAmount = 0; //Total paid by BUYER

  // escrow state
  bool public initiated = false;
  bool public finalized = false;

  // @dev Buyer required escrow funding (2x purchaseAmount)
  uint public buyerRequiredEscrow = 0;
  // @dev Seller required escrow funding (1x purchaseAmount)
  uint public sellerRequiredEscrow = 0;
  // @dev TOTAL required escrow funding (3x purchaseAmount)
  uint public totalEscrowAmount = 0;

  // @dev Buyer escrow funding received
  uint public buyerEscrowedFunds = 0;
  // @dev Seller escrow funding received
  uint public sellerEscrowedFunds = 0;

  // @notice This will be true when the buyer has sent 2x the purchaseAmount
  // @dev True when buyerEscrowedFunds >= buyerRequiredEscrow
  bool public buyerHasFunded = false;
  // @notice Has Seller sent required amount of ETH to escrow
  // @dev True when sellerEscrowedFunds >= sellerRequiredEscrow
  bool public sellerHasFunded = false;

  // @notice Has enough ETH been sent to escrow to meet escrow requirement
  // @dev True when both buyerHasFunded = true AND sellerHasFunded = true 
  bool public escrowFullyFunded = false;


  // Once FullyFunded, both parties must finalize the trade/sale
  bool public buyerfinalized = false;
  bool public sellerfinalized = false;

  event Terms(uint purchaseAmount, uint totalEscrowAmount, uint BuyerRequiredFunding, uint SellerRequiredFunding);
  event Initiated(address initiator, address buyer, address seller, uint tradeFundsforXfer);
  event FundsReceived(address sender, uint amount);
  event PartyFinalized(address party);
  event EscrowComplete(bool completed, uint buyerReceives, uint sellerReceives);


  /** Constructor
   * @param _buyer address of the buyer
   * @param _seller address of the seller
   * @param _purchaseAmount uint amount of ETH being paid to seller
   */
  function VeoEscrowNew(
    address _buyer,
    address _seller,
    uint _purchaseAmount
  ) public {
    // require _seller and _buyer to be non-zero and unique.
    require(_seller != address(0));
    require(_buyer != address(0));
    require(_buyer != _seller);

    // require the contract creator to be either _buyer or _seller
    require(msg.sender == _seller || msg.sender == _buyer);

    // require escrow amount to be non-zero
    require(_purchaseAmount > 0);
    
    // ensure variable seet to false
    escrowFullyFunded = false;

    // assign trade parties
    buyer = _buyer; //Buyer
    seller = _seller; //Seller

    // set state to initiated
    initiated = true;

    // set required funding amounts
    buyerRequiredEscrow = _purchaseAmount * 2;
    sellerRequiredEscrow = _purchaseAmount;
    totalEscrowAmount = _purchaseAmount * 3;
    purchaseAmount = _purchaseAmount;

    // assert that the required total is a sum of the parts
    assert(totalEscrowAmount == (buyerRequiredEscrow + sellerRequiredEscrow));
    
    // event emission
    emit Initiated(msg.sender, buyer, seller, _purchaseAmount);
    emit Terms(purchaseAmount, totalEscrowAmount, buyerRequiredEscrow, sellerRequiredEscrow);
  }

  /**
   * @dev fallback function to receive funds sent to this escrow contract
   * @dev this function then calls the internal fundContract() function
   */
  function() external payable {
    address _funder = msg.sender;
    uint _amount = msg.value;
    fundContract(_funder, _amount);
    emit FundsReceived(_funder, _amount);
  }

  /** @dev called internally to add received funds to the respective party balance
   *  @param _funder address that sent ETH to fund escrow
   *  @param _amount uint of ETH that was send by the _funder
   *  @dev if the _funder's respective balance is less than required the _amount is
   *       added to their EscrowedFunds balance
   *  @dev finally, the checkFundingStatus() function is called internally
   */
  function fundContract(address _funder, uint _amount) public {
    if (_funder == buyer && buyerEscrowedFunds <= buyerRequiredEscrow) {
      uint buyerCurrentFunds = buyerEscrowedFunds;
      buyerEscrowedFunds = buyerCurrentFunds + _amount;
    } 
    if (_funder == seller && sellerEscrowedFunds <= sellerRequiredEscrow) {
      uint sellerCurrentFunds = sellerEscrowedFunds;
      sellerEscrowedFunds = sellerCurrentFunds + _amount;
    }
    checkFundingStatus();
  }
  /**
   * @notice internal function to check funding status
   * @dev set respective party's funding status to true if
   * amount of funds received from said party is >= required funds 
   * @dev If both buyer and seller have sent enough ETH
   *      as per required amounts than set escrowFullyFunded to true
   */      
  function checkFundingStatus() internal {
    if (buyerEscrowedFunds >= buyerRequiredEscrow) {
      buyerHasFunded = true;
    }
    if (sellerEscrowedFunds >= sellerRequiredEscrow) {
      sellerHasFunded = true;
    }
    if (sellerHasFunded == true && buyerHasFunded == true) {
      escrowFullyFunded = true;
    } else {
      escrowFullyFunded = false;
    }
  }
  
  /**
   * @notice Once fully funded, both parties must finalize the transaction
   * @dev Once both finalizations are received the funds are released accordingly
   * @dev The logic works such that if one party finalizes the contract checks
   *      to see if the other party has already finalized.
   */
  function buyerFinalize() public {
    require(msg.sender == buyer);
    buyerfinalized = true;
    emit PartyFinalized(msg.sender);
    
    if (sellerfinalized == true) {
      return finalizeTrade();
    }
  }

  function sellerFinalize() public {
    require(msg.sender == seller);
    sellerfinalized = true;
    emit PartyFinalized(msg.sender);

    if (buyerfinalized == true) {
      finalizeTrade();
    }
  }

  /**
   * @dev finalizeTrade called internally to distribute the escrow funds
   */
  function finalizeTrade() internal {
    // require both parties to have funded the escrow as required
    require(sellerHasFunded == true);
    require(buyerHasFunded == true);

    // require both parties to have finalized the trade
    require(buyerfinalized == true);
    require(sellerfinalized == true);

    // require that the trade has not yet been finalized
    require(finalized == false);

    // Seller receives the purchaseAmount and their escrowed funds
    uint256 forSeller = purchaseAmount + sellerEscrowedFunds;

    // Buyer receives their escrowed funds minus the purchaseAmount
    uint256 forBuyer = buyerEscrowedFunds - purchaseAmount;

    // event emission
    emit EscrowComplete(finalized, forBuyer, forSeller);

    // transfer the funds
    seller.transfer(forSeller);
    buyer.transfer(forBuyer);

    // finalize the trade
    finalized = true;

    // destroy escrow contract to preserve anonymity and reduce chainwaste
    // NOTE: seller was chosen since VEO transaction fees are usually from their pocket
    // this value should be close to zero if not zero anyway
    selfdestruct(seller);


  }

}