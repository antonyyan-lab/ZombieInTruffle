// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <=0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract KittyInterface {
  // make this function as virtual because it is implement from external contract. It is just
  // a interface only
  function getKitty(uint256 _id) external virtual view returns (
      bool isGestating,
      bool isReady,
      uint256 cooldownIndex,
      uint256 nextActionAt,
      uint256 siringWithId,
      uint256 birthTime,
      uint256 matronId,
      uint256 sireId,
      uint256 generation,
      uint256 genes
    );
}

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

  // From zombiefactory.sol
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

  // mapping (uint => address) public zombieToOwner;
  // mapping (address => uint) ownerZombieCount;

  // most of the cases, Zombie 0 = NFT #0 = zombies[0],
  // but we cannot take it for granted. Some accident may occur when create a new zombie.
  // so we need the mapping of NFT token to zombie Id in this contract.
  // e.g. tokenIdToZombie[0] = 10 means NFT #0 is Zombie #11
  // use getZombieId(tokenId) to retrieve zombie Id
  // zombieToTokenId is vice verse.
  // mapping (uint256 => uint) public tokenIdToZombie;
  mapping (uint => uint256) public zombieToTokenId;

  IZombieNFT nft; 

  event NewZombie(uint zombieId, string name, uint dna);

  function setNFTContract(address nftAddress) public onlyOwner() {
    nft = IZombieNFT(nftAddress);
  }

  function _createZombie(string memory _name, uint _dna) internal {
    uint256 _tokenId = nft.mintTo(msg.sender);
    zombies.push(Zombie(_name, _dna, 1, uint32(block.timestamp + cooldownTime), 0, 0));
    // tokenIdToZombie[_tokenId] = zombies.length - 1;
    zombieToTokenId[zombies.length - 1] = _tokenId;
    // uint id = zombies.length - 1;
    // zombieToOwner[id] = msg.sender;
    // ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1);
    // ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender]++;
    emit NewZombie(_tokenId, _name, _dna);
  }

  function createRandomZombie(string memory _name) public {
    // require(ownerZombieCount[msg.sender] == 0);
    require(nft.balanceOf(msg.sender) == 0);
    // Each player is allowed to create a random dna zombie when he doesn't have any zombie on hand.

    // Random a DNA string with "name"
    uint randDna = uint(keccak256(abi.encodePacked(_name))) % dnaModulus;
    randDna = randDna - randDna % 100;

    // Add a new Zombie with random DNA string
    _createZombie(_name, randDna);
  }

  // function getZombieId(uint256 _tokenId) public view returns(uint) {
  //   return tokenIdToZombie[_tokenId];
  // }

  // // zombiefeeding.sol
  // // Make this contract as abstract contract as not all functions
  // // in Kitty contract are implemented here
  // KittyInterface kittyContract;

  // modifier onlyOwnerOf(uint _zombieId) {
  //   require(msg.sender == zombieToOwner[_zombieId]);
  //   _;
  // }
  modifier onlyOwnerOf(uint _zombieId) {
    require(msg.sender == nft.ownerOf(uint256(zombieToTokenId[_zombieId])));
    _;
  }

  modifier isZombieReady(uint _zombieId) {
    // Zombie storage zombie = zombies[_zombieId];
    require(zombies[_zombieId].readyTime <= block.timestamp);
    _;
  }

  // function setKittyContractAddress(address _address) external onlyOwner {
  //   kittyContract = KittyInterface(_address);
  // }

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
    // _triggerCooldown(myZombie);
    myZombie.readyTime = uint32(block.timestamp + cooldownTime);
  }

  // function feedOnKitty(uint _zombieId, uint _kittyId) public {
  //   uint kittyDna;
  //   (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
  //   feedAndMultiply(_zombieId, kittyDna, "kitty");
  // }

  // zombiehelper.sol
  modifier aboveLevel(uint _level, uint _zombieId) {
    require(zombies[_zombieId].level >= _level);
    _;
  }


  // function withdraw() external onlyOwner {
  //   // To fix: "send" and "transfer" are only available for objects of type "address payable", not "address",
  //   // set _owner as address payable.
  //   // address = address only
  //   // address payable = address that can receive tokens
  //   // address _owner = owner();
  //   address payable _owner = payable(owner());
  //   _owner.transfer(address(this).balance);
  // }

  function setLevelUpFee(uint _fee) external onlyOwner {
    levelUpFee = _fee;
  }

  function levelUp(uint _zombieId) external payable {
    require(msg.value == levelUpFee);
    zombies[_zombieId].level = zombies[_zombieId].level++;
  }

  function changeName(uint _zombieId, string memory _newName) external aboveLevel(2, _zombieId) onlyOwnerOf(_zombieId) {
    zombies[_zombieId].name = _newName;
  }

  function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) onlyOwnerOf(_zombieId) {
    zombies[_zombieId].dna = _newDna;
  }

  // function getZombiesByOwner(address _owner) external view returns(uint[] memory) {
  //   uint[] memory result = new uint[](ownerZombieCount[_owner]);
  //   uint counter = 0;
  //   for (uint i = 0; i < zombies.length; i++) {
  //     if (zombieToOwner[i] == _owner) {
  //       result[counter] = i;
  //       counter++;
  //     }
  //   }
  //   return result;
  // }

  // zombieattack.sol
  function randMod(uint _modulus) internal returns(uint) {
    randNonce = randNonce++;
    return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % _modulus;
  }

  function attack(uint _zombieId, uint _targetId) external onlyOwnerOf(_zombieId) {
    require(_zombieId != _targetId);
    Zombie storage myZombie = zombies[_zombieId];
    Zombie storage enemyZombie = zombies[_targetId];
    uint rand = randMod(100);
    if (rand <= attackVictoryProbability) {
      myZombie.winCount = myZombie.winCount++;
      myZombie.level = myZombie.level++;
      enemyZombie.lossCount = enemyZombie.lossCount++;
      feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
    } else {
      myZombie.lossCount = myZombie.lossCount++;
      enemyZombie.winCount = enemyZombie.winCount++;
      _triggerCooldown(myZombie);
    }
  }
}

