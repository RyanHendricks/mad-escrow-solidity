pragma solidity ^0.4.16;

// @title VeoEscrow -- trustless escrow smart contract for VEO<->ETH swaps
// @author ryanhendricks@gmail.com
/**
 *      This escrow contract uses a similar mechanism as the MAD escrow protocol.
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


contract VeoEscrow {

  // Party A is the Buyer and Party B is the seller.
  // The assignments are determined when calling initialize function
  address public partyA; //BUYER
  address public partyB; //SELLER

  // Quantity of ETH being transferred to seller as agreed
  // on by buyer and seller upon initiating the escrow contract.
  uint256 public purchaseAmountTotal;

  bool public initiated;
  bool public finalized;

  // Blocknumber at contract creation
  uint public createdBlock;

  // mutualEscrowAmount is the funds provided by BOTh
  // buyer and seller in excess of the funds used for
  // the actual trade/purchase
  // this value should equal the purchase amount
  uint256 public mutualEscrowAmount;

  // Required funding quantity to execute trade
  uint256 public partyArequiredFunding;
  uint256 public partyBrequiredFunding;

  // Buyer and seller current funding amounts
  uint256 public partyAFundedAmount;
  uint256 public partyBFundedAmount;

  // set to TRUE when BOTH buyer and seller
  // have funded contract in excess of respective requirements
  bool public escrowFullyFunded;
  
  // Once funded, both parties must finalize the trade/sale
  bool public partyAfinalize;
  bool public partyBfinalize;


  event Initiated(address buyer, address seller, uint escrow, uint block);

  // check to make sure contract not currently initiated
  modifier notInitiated() {
    require(initiated == false);
    _;
  }
  
  modifier onlyPartyA() {
    require(partyA == msg.sender);
    _;
  }

  modifier onlyPartyB() {
    require(partyB == msg.sender);
    _;
  }

  modifier bothParties() {
    require(partyA == msg.sender || partyB == msg.sender);
    _;
  }

  modifier isTrueSender() {
    require(msg.sender == tx.origin);
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
  constructor(VeoEscrow) {
    finalized = false;
    initiated = false;
    createdBlock = block.number;
    escrowFullyFunded = false;
  }

  /**
   * @dev Initiate the escrow contract and allow funds to be sent for escrow
   * @param _counterParty address of the other party for the trade
   * @param _purchaseAmount uint256 amount of ETH to be paid for VEO
   * @param _buyingNotSelling bool indicating whether initiator is buyer or seller
   */
  function Initiate(
    address _counterParty,
    uint256 _purchaseAmount,
    bool _buyingNotSelling // TRUE if Buyer; FALSE if seller;
  )
  notInitiated
  isTrueSender
  public returns
  (bool) {
    purchaseAmountTotal = _purchaseAmount;
    mutualEscrowAmount = _purchaseAmount * 3;

    if (_buyingNotSelling == true) {
      partyA = msg.sender; //Buyer
      partyB = _counterParty; //Seller
      partyArequiredFunding = _purchaseAmount * 2;
      partyBrequiredFunding = _purchaseAmount;

    } else if (_buyingNotSelling == false) {
      partyA = _counterParty; //Buyer
      partyB = msg.sender; //Seller
      partyArequiredFunding = _purchaseAmount;
      partyBrequiredFunding = _purchaseAmount * 2;

    } else {
      revert(); // Fallback
    }

    initiated = true;
    return true;


  }

  // fund contract function to be called by both parties when sending
  // ETH to the contract and also check if fully funded after funds received
  function fundContract()
  bothParties
  isTrueSender
  public payable returns (bool fullyFunded) {
    if (partyA == msg.sender && partyAFundedAmount < partyArequiredFunding) {
      uint256 amountA = partyAFundedAmount;
      partyAFundedAmount = amountA + msg.value;
    }

    else if (partyB == msg.sender && partyBFundedAmount < partyBrequiredFunding) {
      uint256 amountB = partyBFundedAmount;
      partyBFundedAmount = amountB + msg.value;
    } else {
        revert();
    }
    
    return checkFundingStatus();
  }


  // dev tool - delete for production
  function simulatefundContract(address _sender, uint _amount)
  public returns (bool fullyFunded) {
    if (_sender == partyA) {
      uint256 amountA = partyAFundedAmount;
      partyAFundedAmount = amountA + _amount;
    }

    if (_sender == partyB) {
      uint256 amountB = partyBFundedAmount;
      partyBFundedAmount = amountB + _amount;
    } 
    
    return checkFundingStatus();
  }

  // @dev internal function to check funding status
  // @dev if both buyer and seller have sent enough ETH
  //      as per required amounts than set escrowFullyFunded to true
  function checkFundingStatus() public returns(bool) {
    if (partyAFundedAmount > partyArequiredFunding && partyBFundedAmount > partyBrequiredFunding ) {
      escrowFullyFunded = true;
    }
    return(escrowFullyFunded);
  }
  
  // @dev Once fully funded, both parties must finalize the transaction
  // @dev and once both finalizations are received the funds are released accordingly
  function completeTrade() public returns (bool) {
    address _sender = msg.sender;
    if (_sender == partyA) {
      partyAfinalize = true;
    }
    if (_sender == partyB) {
      partyBfinalize = true;
    }
    if (partyBfinalize == true && partyAfinalize == true) {
        finalized = true;
        finalize();
    }
  }
    
    
    
    // Transfer both escrow excess funds back to buyer and seller
    // Then selfdestruct contract with remaining funds sent to the buyer to
    // protect the buyer from seller attempting to finalize prior to sending 
    // deliverable or having not funded their excess escrow requirement.
    function finalize() internal {
    if (finalized == true && partyBfinalize == true && partyBfinalize == true) {
        // partyB.transfer(partyAFundedAmount);
        // partyA.transfer(partyBFundedAmount);
        // partyA.transfer(address(this).balance);
        createdBlock = 1337;
    }

     
  }
  

}