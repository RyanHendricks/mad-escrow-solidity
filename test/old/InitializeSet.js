const VeoEscrow = artifacts.require('VeoEscrow.sol');

contract('VeoEscrow - Buyer Initialize', function(accounts) {
  let instance, amount, init, fnl, buyer, seller;

  
  beforeEach(async function() {
    amount = 3;
    instance = await VeoEscrow.new();
    // await instance.Initiate(accounts[1], amount, 'true', { from: accounts[0] });
    

  });
  describe('Escrow contract end-to-end with buyer as initiator ', function() {
    it('should initiate the contract', async () => {
      await instance.Initiate(accounts[1], amount, 'true', { from: accounts[0] });
      const init = await instance.initiated.call();
      const fnl = await instance.finalized.call();
      assert.equal(init, true);
      assert.equal(fnl, false);
      console.log(`Initialized?: ${init}`);
    });
    it('should assign the parties involved and each should be different addresses', async () => {
      await instance.Initiate(accounts[1], amount, 'true', { from: accounts[0] });
      const buyer = await instance.partyA.call();
      const seller = await instance.partyB.call();
      assert.equal(buyer, accounts[0]);
      assert.equal(seller, accounts[1]);
      assert.notEqual(buyer,seller);
      console.log(`Buyer: ${buyer}`);
      console.log(`Seller: ${seller}`);
    });
    
  });
});
