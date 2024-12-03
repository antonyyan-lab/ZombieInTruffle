const ZombieFactory = artifacts.require("ZombieFactory.sol");

module.exports = function(deployer, network, accounts) {
  // const deployerAddress = accounts[0];
  const deployerAddress = "0xC624181E929d986bF69A7F8FC7385f9750d2F6B9";
  deployer.deploy(ZombieFactory);
  // deployer.link(ConvertLib, MetaCoin);
  // deployer.deploy(MetaCoin);
};
