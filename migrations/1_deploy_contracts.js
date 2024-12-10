// const CryptoZombie = artifacts.require("CryptoZombie.sol");

// const ZombieFactory = artifacts.require("zombiefactory.sol");
// const ZombieFeeding = artifacts.require("zombiefeeding.sol");
// const ZombieAttack = artifacts.require("zombieattack.sol");
// const ZombieHelper = artifacts.require("zombiehelper.sol");
// const ZombieOwnership = artifacts.require("zombieownership.sol");

const test721Contract = artifacts.require("test721.sol");

module.exports = async function(deployer, network, accounts) {
  // const deployerAddress = "0xC624181E929d986bF69A7F8FC7385f9750d2F6B9";
  const deployerAddress = accounts[0];
  const receiver1 = accounts[1];
  const nftName = "NFTTest";
  const nftSymbol = "TFT";

  const testNFTUri = {
    "name": "TFT #1",
    "description": "This is a NFTTest #1",
    "image": "https://abc.com/TFT1.png",
    "strength": 20
  }

  // await deployer.deploy(ZombieFactory, deployerAddress);
  // await deployer.deploy(ZombieFeeding);
  // await deployer.deploy(ZombieAttack);
  // await deployer.deploy(ZombieHelper);
  // await deployer.deploy(ZombieOwnership, nftName, nftSymbol);
  // await deployer.link(ConvertLib, MetaCoin);
  // deployer.deploy(MetaCoin);

  await deployer.deploy(test721Contract, deployerAddress, nftName, nftSymbol);
  let instance = await test721Contract.deployed();
  await instance.mintTo(receiver1, testNFTUri);
};
