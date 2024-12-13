const ZombieNFT = artifacts.require("ZombieNFT.sol");
const CryptoZombie = artifacts.require("CryptoZombie.sol");

module.exports = async function(deployer, network, accounts) {
  // const deployerAddress = "0xC624181E929d986bF69A7F8FC7385f9750d2F6B9";
  const deployerAddress = accounts[0];
  // const receiver1 = accounts[1];
  const nftName = "Zombie NFT";
  const nftSymbol = "ZFT";

  // const testNFTUri = {
  //   "name": "TFT #1",
  //   "description": "This is a NFTTest #1",
  //   "image": "https://abc.com/TFT1.png",
  //   "strength": 20
  // }
  await deployer.deploy(ZombieNFT, deployerAddress, nftName, nftSymbol)
  let nft = ZombieNFT.deployed()
  await deployer.deploy(CryptoZombie, deployerAddress)
  let game = CryptoZombie.deployed()

  // Game contract setttings
  // await game..setNFTContract(nft.address)
  // await game.setLevelUpFee(1)

  // await deployer.deploy(test721Contract, deployerAddress, nftName, nftSymbol);
  // let instance = await test721Contract.deployed();
  // await instance.mintTo(receiver1, testNFTUri);
};
