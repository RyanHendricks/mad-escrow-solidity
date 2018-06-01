const VeoEscrow = artifacts.require('VeoEscrow.sol');

contract('VeoEscrow - Fund Escrow', (accounts) => {
  let instance,
    amount,
    init,
    fnl,
    buyer,
    seller,
    mutualAMT,
    buyerRequiredAMT,
    sellerRequiredAMT,
    num,
    other,
    fundedSeller,
    fundedBuyer,
    fundedOther;


  beforeEach(async () => {
    amount = 3;
    instance = await VeoEscrow.new();
    await instance.Initiate(accounts[1], 1, 'true', { from: accounts[0] });

      const num = amount.valueOf();
      const buyer = accounts[0];
      const seller = accounts[1];
      const other = accounts[3];
      
    // await instance.Initiate(accounts[1], amount, 'true', { from: accounts[0] });
  });
  describe('Funding Test', () => {
    it('should only allow the buyer and seller to fund the contract', async () => {

      const num = amount.valueOf();
      const buyer = accounts[0];
      const seller = accounts[1];
      const other = accounts[3];
      await instance.sendTransaction({from:buyer,value:10000000000000000000});
      await instance.sendTransaction({from:seller,value:10000000000000000000});
      await instance.sendTransaction({from:other,value:10000000000000000000});
      const fundedSeller = await instance.fundedAmount.call(seller);
      const fundedBuyer = await instance.fundedAmount.call(buyer);
      const fundedOther = await instance.fundedAmount.call(other);
      assert.notEqual(fundedSeller.valueOf(), 0);
      assert.notEqual(fundedBuyer.valueOf(), 0);
      assert.equal(fundedOther.valueOf(), 0);
      console.log(`Buyer: ${buyer} - ${fundedBuyer.valueOf()}`);
      console.log(`Seller: ${seller} - ${fundedSeller.toNumber()}`);
      console.log(`Other: ${other} - ${fundedOther.toNumber()}`);
    });
    it('should not allow overfunding', async () => {
      await instance.sendTransaction({from:accounts[0],value:10000000000000000000});
      await instance.sendTransaction({from:accounts[0],value:10000000000000000000});
      await instance.sendTransaction({from:accounts[0],value:10000000000000000000});
      await instance.sendTransaction({from:accounts[0],value:10000000000000000000});
      await instance.sendTransaction({from:accounts[0],value:10000000000000000000});
      const fundedBuyer = await instance.fundedAmount.call(buyer);
      assert.notEqual(fundedBuyer,50000000000000000000)
    });
  });
});
