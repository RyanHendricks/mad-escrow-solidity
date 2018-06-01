
const VeoEscrowNew = artifacts.require('VeoEscrowNew.sol');

contract('VeoEscrowNew', function(accounts) {
  let instance, amount, init, fnl, buyer, seller;

  
  beforeEach(async function() {
    instance = await VeoEscrowNew.deployed();

  });
  describe('When deployed', function() {
    it('should be initiated', async () => {
      const init = await instance.initiated.call();
      const fnl = await instance.finalized.call();
      assert.equal(init, true);
      assert.equal(fnl, false);
      console.log(`Initialized?: ${init}`);
    });
    it('should assign the parties involved and each should be different addresses', async () => {
      const buyer = await instance.buyer.call();
      const seller = await instance.seller.call();
      assert.equal(buyer, accounts[0]);
      assert.equal(seller, accounts[1]);
      assert.notEqual(buyer,seller);
      console.log(`Buyer: ${buyer}`);
      console.log(`Seller: ${seller}`);
    });
    it('should set the required funding amounts', async () => {
      assert.notEqual(await instance.buyerRequiredEscrow.call(),await instance.sellerRequiredEscrow.call());
      const sellerReq = await instance.sellerRequiredEscrow.call();
      const totalReq = await instance.totalEscrowAmount.call();
      const purchAmt = await instance.purchaseAmount.call();
      assert.equal(sellerReq.valueOf(), purchAmt.valueOf());
      console.log(`Payment to Seller (PMT): ${purchAmt.valueOf()}`);
      console.log(`Seller Escrow Funding Required (1 x PMT): ${sellerReq.valueOf()}`);
      console.log(`Total Escrow Funding to Finalize (3 x PMT): ${totalReq.valueOf()}`);
    });
    it('should allow buyer to fund required escrow amount', async () => {
      const buyer = accounts[0];
      const seller = accounts[1]
      await instance.sendTransaction({from:buyer,value:1});
      await instance.sendTransaction({from:seller,value:1});
      assert.equal(valueOf(await instance.buyerEscrowedFunds.call()), await instance.buyerEscrowedFunds.call());
      console.log(`Buyer required escrow funding: ${buyerReq.valueOf()}`);
      console.log(`Received funds from buyer: ${fundedBuyerinitial.valueOf()}`);
      console.log('Sending additional funding...');
      await instance.sendTransaction({from:buyer,value:1});
      await instance.sendTransaction({from:buyer,value:1});
      await instance.sendTransaction({from:buyer,value:1});
      await instance.sendTransaction({from:buyer,value:1});
      await instance.sendTransaction({from:buyer,value:2});
      const fundedBuyer = await instance.buyerEscrowedFunds.call();
      console.log(`Received funds from buyer: ${fundedBuyer.valueOf()}`);
      const buyerFunded = await instance.buyerHasFunded.call();
      assert.equal(buyerFunded,true);
      console.log(buyerFunded);
      assert.equal(fundedBuyerinitial.valueOf(),funds.valueOf());
    });
    it('should allow seller to fund required escrow', async () => {
      let buyerReq = await instance.buyerRequiredEscrow.call();
      let sellerReq = await instance.sellerRequiredEscrow.call();
      let buyerFunded = await instance.buyerHasFunded.call();
      let sellerFunded = await instance.sellerHasFunded.call();
      let buyerEscrowed = await instance.buyerEscrowedFunds.call();
      let sellerEscrowed = await instance.sellerEscrowedFunds.call();
      let fullyFunded = await instance.escrowFullyFunded.call();
      console.log(`Required Escrow - Buyer: ${buyerReq} Seller: ${sellerReq}`);
      console.log(`Funded Escrow? - Buyer: ${buyerEscrowed} Seller: ${sellerEscrowed}`);
      console.log(`Funded Escrow? - Buyer: ${buyerFunded} Seller: ${sellerFunded}`);
      console.log(`Escrow Fully Funded: ${fullyFunded}`);
      assert.equal(buyerFunded,sellerFunded);
      assert.notEqual(buyerReq,sellerReq);
      assert.equal(buyerEscrowed.valueOf(),sellerEscrowed.valueOf());
      const buyer = accounts[0];
      const seller = accounts[1];
      await instance.sendTransaction({from:accounts[0],value:6});
      // await instance.sendTransaction({from:accounts[1],value:3});
      buyerReq = await instance.buyerRequiredEscrow.call();
      sellerReq = await instance.sellerRequiredEscrow.call();
      buyerFunded = await instance.buyerHasFunded.call();
      sellerFunded = await instance.sellerHasFunded.call();
      buyerEscrowed = await instance.buyerEscrowedFunds.call();
      sellerEscrowed = await instance.sellerEscrowedFunds.call();
      fullyFunded = await instance.escrowFullyFunded.call();
      assert.notEqual(buyerFunded,sellerFunded);
      assert.notEqual(buyerEscrowed.valueOf(),sellerEscrowed.valueOf());
      console.log(`Required Escrow: - Buyer: ${buyerReq} Seller: ${sellerReq}`);
      console.log(`Funded Amount: - Buyer: ${buyerEscrowed} Seller: ${sellerEscrowed}`);
      console.log(`Funded Escrow? - Buyer: ${buyerFunded} Seller: ${sellerFunded}`);
      console.log(`Escrow Fully Funded: ${fullyFunded}`);
      await instance.sendTransaction({from:accounts[1],value:3});
      buyerReq = await instance.buyerRequiredEscrow.call();
      sellerReq = await instance.sellerRequiredEscrow.call();
      buyerFunded = await instance.buyerHasFunded.call();
      sellerFunded = await instance.sellerHasFunded.call();
      buyerEscrowed = await instance.buyerEscrowedFunds.call();
      sellerEscrowed = await instance.sellerEscrowedFunds.call();
      fullyFunded = await instance.escrowFullyFunded.call();
      assert.equal(buyerFunded,sellerFunded);
      assert.notEqual(buyerEscrowed.valueOf(),sellerEscrowed.valueOf());
      console.log(`Required Escrow: - Buyer: ${buyerReq} Seller: ${sellerReq}`);
      console.log(`Funded Amount: - Buyer: ${buyerEscrowed} Seller: ${sellerEscrowed}`);
      console.log(`Funded Escrow? - Buyer: ${buyerFunded} Seller: ${sellerFunded}`);
      console.log(`Escrow Fully Funded: ${fullyFunded}`);
      
  let buyerFinalized = await instance.buyerfinalized.call();
      let sellerFinalized = await instance.sellerfinalized.call();
      console.log(`sellerFinalized: ${sellerFinalized}, buyerFinalized: ${buyerFinalized}`)
      await instance.sendTransaction({from:accounts[0],value:6});
      await instance.sendTransaction({from:accounts[1],value:3});
      await instance.buyerFinalize.call({ from:accounts[0] });
      await instance.finalizeTrade.call();
      // await instance.sellerFinalize.call();
      buyerFinalized = await instance.buyerfinalized.call();
      sellerFinalized = await instance.sellerfinalized.call();
      console.log(`sellerFinalized: ${sellerFinalized}, buyerFinalized: ${buyerFinalized}`)
     
    });
    it('transfer escrow funds and handle remainder', async () => {

    });
  });
});
