pragma solidity ^0.4.22;


contract VeoEscrow {

  address public buyer;
  address public seller;

  bool public initiated;
  bool public finalized;

  uint public sellerFunded;
  uint public buyerFunded;

  uint public sellerExpReceivable;
  uint public buyerExpReceivable;

  modifier notInitiated() {
    require(initiated == false);
    _;
  }

  modifier onlyBuyer() {
    require(buyer == msg.sender);
    _;
  }

  modifier onlySeller() {
    require(seller == msg.sender);
    _;
  }

  function VeoEscrow() {
    finalized = false;
    initiated = false;
  }

  function buyerInitiate(address _seller) public notInitiated {
    buyer = msg.sender;
    seller = _seller;
    initiated = true;
  }

  function sellerInitiate(address _buyer) public notInitiated {
    seller = msg.sender;
    buyer = _buyer;
    initiated = true;
  }
  
  function sellerAddETH(uint _expectedReceivable) public onlySeller payable {
    if (sellerFunded > 0) {
      revert();
    }
    sellerFunded = msg.value;
    sellerExpReceivable = _expectedReceivable;
  }

  function buyerAddETH(uint _expectedReceivable) public onlyBuyer payable {
    if (buyerFunded > 0) {
      revert();
    }
    buyerFunded = msg.value;
    buyerExpReceivable = _expectedReceivable;
  }

  function completeTrade() public {
    if (buyerFunded == 0 || sellerFunded == 0) {
      revert();
    }

    if (buyerFunded >= sellerExpReceivable && sellerFunded >= buyerExpReceivable) {  
      
      seller.transfer(sellerExpReceivable);
      buyer.transfer(buyerExpReceivable);
      seller.transfer(sellerFunded - buyerExpReceivable);
      buyer.transfer(sellerFunded - buyerExpReceivable);

    }

  }


}