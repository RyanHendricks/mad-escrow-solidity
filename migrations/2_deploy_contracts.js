var VeoEscrowNew = artifacts.require("./contracts/VeoEscrowNew.sol");
var MadEscrow = artifacts.require("./contracts/MadEscrow.sol");
var VeoEscrowV2 = artifacts.require("./contracts/VeoEscrowV2.sol");

module.exports = function deployContracts(deployer, network, accounts) {  

deployer.then(async () => {
  console.log("VeoEscrow deployment...");
  const buyer = accounts[0];
  const seller = accounts[1];
  const amount = 1;
  await deployer.deploy(VeoEscrowNew, buyer, seller, amount);
  await deployer.deploy(MadEscrow);
  await deployer.deploy(VeoEscrowV2, buyer, seller, amount);
  const VeoEscrowV2Instance = await VeoEscrowV2.deployed();
  const MadEscrowInstance = await MadEscrow.deployed();
  const VeoEscrowNewInstance = await VeoEscrowNew.deployed();
});
}
