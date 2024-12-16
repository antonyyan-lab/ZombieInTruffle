// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <=0.9.0;

import "./zombieattack.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "./erc721.sol";
// import "./safemath.sol";

// Make this contract as abstract contract as not all functions
// in source contracts are implemented here
// abstract contract ZombieOwnership is ZombieAttack, ERC721 {
abstract contract ZombieOwnership is ZombieAttack {
// abstract contract ZombieOwnership is ZombieAttack {

  // constructor(string memory name_, string memory symbol_) {
  // }
  // using SafeMath for uint256;

  mapping (uint => address) zombieApprovals;

  // balanceOf(), ownerOf() in Openzeppelin has changed to pubic from external
  // Since we rewrite the content of the original functions here, we need to add "override" modifier
  function balanceOf(address _owner) external view returns (uint256) {
  // function balanceOf(address _owner) public view override returns (uin
    return ownerZombieCount[_owner];
  }

  function ownerOf(uint256 _tokenId) external view returns (address) {
  // function ownerOf(uint256 _tokenId) public view override returns (address) {
    return zombieToOwner[_tokenId];
  }

  // _transfer() in ERC721.sol is not virtual so it cannot be overrided.
  // Since we are just to records our zombies owner changes, we should modify 
  // our code not need to call _transfer().
  // function _transfer(address _from, address _to, uint256 _tokenId) private {
  //   ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
  //   ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].sub(1);
  //   zombieToOwner[_tokenId] = _to;
  //   emit Transfer(_from, _to, _tokenId);
  // }

  function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
  // function transferFrom(address _from, address _to, uint256 _tokenId) public virtual override {
      require (zombieToOwner[_tokenId] == msg.sender || zombieApprovals[_tokenId] == msg.sender);
      // Replace of calling _transfer() here
      // _transfer(_from, _to, _tokenId);
      ownerZombieCount[_to] = ownerZombieCount[_to]++;
      ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender]--;
      zombieToOwner[_tokenId] = _to;
      // emit Transfer(_from, _to, _tokenId);
    }

  function approve(address _approved, uint256 _tokenId) external payable onlyOwnerOf(_tokenId) {
  // function approve(address _approved, uint256 _tokenId) public virtual override onlyOwnerOf(_tokenId) {
      zombieApprovals[_tokenId] = _approved;
      // emit Approval(msg.sender, _approved, _tokenId);
    }

}
