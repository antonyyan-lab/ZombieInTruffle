// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <=0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface IZombieNFT {
  function safeTransferFrom(address from, address to, uint256 tokenId) external;
  function transferFrom(address from, address to, uint256 tokenId) external;
  function ownerOf(uint256 tokenId) external view returns (address);
  function balanceOf(address owner) external view returns (uint256);
  function mintTo(address to) external returns (uint256);
}

// Contracts for Game Content
contract CryptoZombie is Ownable {
  constructor(address initialOwner) Ownable(initialOwner) {}

  uint dnaDigits = 16;
  uint dnaModulus = 10 ** dnaDigits;
  uint cooldownTime = 1 days;
  uint levelUpFee = 0.001 ether;
  uint randNonce = 0;
  uint attackVictoryProbability = 70;
 
  // Zombie's attributes 
  struct Zombie {
    string name;
    uint dna;
    uint32 level;
    uint32 readyTime;
    uint16 winCount;
    uint16 lossCount;
  }

  Zombie[] public zombies;

  // most of the cases, Zombie 0 = NFT #0 = zombies[0],
  // but we cannot take it for granted. Some accident may occur when create a new zombie.
  // so we need the mapping of NFT token to zombie Id in this contract.
  // e.g. tokenIdToZombie[0] = 10 means NFT #0 is Zombie #11
  // use getZombieId(tokenId) to retrieve zombie Id
  // zombieToTokenId is vice verse.
  mapping(uint => uint256) public zombieToTokenId;

  IZombieNFT nft; 

  event NewZombie(uint zombieId, string name, uint dna);
  event LeveledUp(uint zombieId, uint32 level);
  event NameChanged(uint zombieid, string name);
  event DNAChanged(uint zombieid, uint dna);
  event AttackResult(uint zombie, uint targetZombie, string result);

  modifier onlyOwnerOf(uint _zombieId) {
    require(msg.sender == nft.ownerOf(uint256(zombieToTokenId[_zombieId])), "You are not zombie's owner.");
    _;
  }

  modifier aboveLevel(uint _level, uint _zombieId) {
    require(zombies[_zombieId].level >= _level, string.concat("You zombie doesn't reach level ", Strings.toString(_level), "!"));
    _;
  }

  modifier isZombieReady(uint _zombieId) {
    require(zombies[_zombieId].readyTime <= block.timestamp, "Your zombie is not ready yet!");
    _;
  }


  function setNFTContract(address nftAddress) public onlyOwner() {
    nft = IZombieNFT(nftAddress);
  }

  function setLevelUpFee(uint _fee) external onlyOwner {
    levelUpFee = _fee;
  }

  function getBlockTime() public view returns(uint32) {
    return uint32(block.timestamp);
  }

  function getZombieToToken(uint zombieId) public view returns(uint256) {
    return zombieToTokenId[zombieId];
  }

  function getZombie(uint256 _zombieId) public view returns(Zombie memory) {
    return zombies[_zombieId];
  }

  function _createZombie(string memory _name, uint _dna) internal {
    uint256 _tokenId = nft.mintTo(msg.sender);
    zombies.push(Zombie(_name, _dna, 1, uint32(block.timestamp + cooldownTime), 0, 0));
    zombieToTokenId[zombies.length - 1] = _tokenId;
    emit NewZombie(_tokenId, _name, _dna);
  }

  function createRandomZombie(string memory _name) public {
    // Each player is allowed to create a random dna zombie when he doesn't have any zombie on hand.
    require(nft.balanceOf(msg.sender) == 0, "You already have zombie!");

    // Random a DNA string with "name"
    uint randDna = uint(keccak256(abi.encodePacked(_name))) % dnaModulus;
    randDna = randDna - randDna % 100;

    // Add a new Zombie with random DNA string
    _createZombie(_name, randDna);
  }

  function levelUp(uint _zombieId) external payable onlyOwnerOf(_zombieId) {
    require(msg.value == levelUpFee, "Please pay enough to level up your zombie!");
    zombies[_zombieId].level++;

    emit LeveledUp(_zombieId, zombies[_zombieId].level);
  }

  function changeName(uint _zombieId, string memory _newName) external aboveLevel(2, _zombieId) onlyOwnerOf(_zombieId) {
    zombies[_zombieId].name = _newName;
    emit NameChanged(_zombieId, zombies[_zombieId].name);
  }

  function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) onlyOwnerOf(_zombieId) {
    zombies[_zombieId].dna = _newDna;
    emit DNAChanged(_zombieId, zombies[_zombieId].dna);
  }

  function _triggerCooldown(Zombie storage _zombie) internal {
    _zombie.readyTime = uint32(block.timestamp + cooldownTime);
  }

  function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) internal onlyOwnerOf(_zombieId) isZombieReady(_zombieId) {
    Zombie storage myZombie = zombies[_zombieId];

    _targetDna = _targetDna % dnaModulus;
    uint newDna = (myZombie.dna + _targetDna) / 2;
    
    if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
      newDna = newDna - newDna % 100 + 99;
    }
    
    _createZombie("NoName", newDna);
    _triggerCooldown(myZombie);
  }

  function randMod(uint _modulus) internal returns(uint) {
    randNonce++;
    return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % _modulus;
  }

  function attack(uint _zombieId, uint _targetId) external onlyOwnerOf(_zombieId) {
    require(_zombieId != _targetId, "Zombie cannot attack itself!");
    Zombie storage myZombie = zombies[_zombieId];
    Zombie storage enemyZombie = zombies[_targetId];
    uint rand = randMod(100);
    if (rand <= attackVictoryProbability) {
      myZombie.winCount++;
      myZombie.level++;
      enemyZombie.lossCount++;
      feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
      emit AttackResult(_zombieId, _targetId, "You Win!");
    } else {
      myZombie.lossCount++;
      enemyZombie.winCount++;
      _triggerCooldown(myZombie);
      emit AttackResult(_zombieId, _targetId, "You Loss!");
    }
  }
}

