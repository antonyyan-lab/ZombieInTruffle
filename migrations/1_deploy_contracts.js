const ZombieNFT1155 = artifacts.require("ZombieNFT1155.sol");
const ZombieNFT = artifacts.require("ZombieNFT.sol");
const CryptoZombie = artifacts.require("CryptoZombie.sol");

module.exports = async function(deployer, network, accounts) {
  const deployerAddress = accounts[0];

  await deployer.deploy(ZombieNFT1155, deployerAddress, "")
  let nft1155 = await ZombieNFT1155.deployed()

  console.log('The deployed NFT1155 Contracts is: ' + nft1155.address)

  // The following is for the deployment of ERC721 contract
  const nftName = "Zombie NFT";
  const nftSymbol = "ZFT";

  // Keep the follow for future deploy tokenURI for NFT
  // const testNFTUri = {
  //   "name": "TFT #1",
  //   "description": "This is a NFTTest #1",
  //   "image": "https://abc.com/TFT1.png",
  //   "strength": 20
  // }

  await deployer.deploy(ZombieNFT, deployerAddress, nftName, nftSymbol)
  let nft = await ZombieNFT.deployed()
  await deployer.deploy(CryptoZombie, deployerAddress)
  let game = await CryptoZombie.deployed()

  // Game contract setttings
  await game.setNFTContract(nft.address)
  console.log('NFT Contract is set to ' + nft.address + '.')

  // Create Zombies for accounts
  await game.createRandomZombie('zom1', {from: accounts[0]})
  await game.createRandomZombie('zom2', {from: accounts[1]})
  await game.createRandomZombie('zom3', {from: accounts[2]})
  await game.createRandomZombie('zom4', {from: accounts[3]})
  await game.createRandomZombie('zom5', {from: accounts[4]})
};
