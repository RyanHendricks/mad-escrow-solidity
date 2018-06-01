const VeoEscrow = artifacts.require('VeoEscrow.sol');

contract('VeoEscrow - SetFundingRequirements', (accounts) => {
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
    // await instance.Initiate(accounts[1], amount, 'true', { from: accounts[0] });
  });
  describe('Funding Test', () => {
    it('should set required escrow amounts and total funding amount', async () => {
      await instance.Initiate(accounts[1], amount, 'true', { from: accounts[0] });
      const mutualAMT = await instance.mutualEscrowAmount.call();
      const buyerRequiredAMT = await instance.requiredFunding.call(await instance.partyA.call());
      const sellerRequiredAMT = await instance.requiredFunding.call(await instance.partyB.call());
      console.log(`Buyer Required Escrow: ${buyerRequiredAMT} || Seller Required Escrow: ${sellerRequiredAMT}`);
      console.log(`Total: ${mutualAMT}`);
      assert.equal(sellerRequiredAMT.valueOf(), amount);
      const num = amount.valueOf() * 2;
      assert.equal(buyerRequiredAMT.valueOf(), num);
    });
  });
});
