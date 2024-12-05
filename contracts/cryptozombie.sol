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

contract CryptoZombie is Ownable {
  constructor(address initialOwner) Ownable(initialOwner) {}

  // From zombiefactory.sol
  uint dnaDigits = 16;
  uint dnaModulus = 10 ** dnaDigits;
  uint cooldownTime = 1 days;

  struct Zombie {
    string name;
    uint dna;
    uint32 level;
    uint32 readyTime;
    uint16 winCount;
    uint16 lossCount;
  }

  Zombie[] public zombies;

  mapping (uint => address) public zombieToOwner;
  mapping (address => uint) ownerZombieCount;

  event NewZombie(uint zombieId, string name, uint dna);

  function _createZombie(string memory _name, uint _dna) internal {
    // now is obsulate, use block.timestamp to replace
    zombies.push(Zombie(_name, _dna, 1, uint32(block.timestamp + cooldownTime), 0, 0));
    uint id = zombies.length - 1;
    zombieToOwner[id] = msg.sender;
    // ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1);
    ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender]++;
    emit NewZombie(id, _name, _dna);
  }

  function createRandomZombie(string memory _name) public {
    require(ownerZombieCount[msg.sender] == 0);
    // Each player is allowed to create a random dna zombie when he doesn't have any zombie on hand.

    // Random a DNA string with "name"
    uint randDna = uint(keccak256(abi.encodePacked(_name))) % dnaModulus;
    randDna = randDna - randDna % 100;

    // Add a new Zombie with random DNA string
    _createZombie(_name, randDna);
  }

  // zombiefeeding.sol
  // Make this contract as abstract contract as not all functions
  // in Kitty contract are implemented here
  KittyInterface kittyContract;

  modifier onlyOwnerOf(uint _zombieId) {
    require(msg.sender == zombieToOwner[_zombieId]);
    _;
  }

  modifier isZombieReady(uint _zombieId) {
    // Zombie storage zombie = zombies[_zombieId];
    require(zombies[_zombieId].readyTime <= block.timestamp);
    _;
  }

  function setKittyContractAddress(address _address) external onlyOwner {
    kittyContract = KittyInterface(_address);
  }

  function _triggerCooldown(Zombie storage _zombie) internal {
    _zombie.readyTime = uint32(block.timestamp + cooldownTime);
  }

//  Change to modifier
//   function _isReady(Zombie storage _zombie) internal view returns (bool) {
//     return (_zombie.readyTime <= block.timestamp);
//   }

  function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) internal onlyOwnerOf(_zombieId) isZombieReady(_zombieId) {
    Zombie storage myZombie = zombies[_zombieId];
    // require(_isReady(myZombie));
    _targetDna = _targetDna % dnaModulus;
    uint newDna = (myZombie.dna + _targetDna) / 2;
    if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
      newDna = newDna - newDna % 100 + 99;
    }
    _createZombie("NoName", newDna);
    // _triggerCooldown(myZombie);
    myZombie.readyTime = uint32(block.timestamp + cooldownTime);
  }

  function feedOnKitty(uint _zombieId, uint _kittyId) public {
    uint kittyDna;
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }
}

