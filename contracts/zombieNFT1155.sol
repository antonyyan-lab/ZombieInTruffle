// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <=0.9.0;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Burnable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import {ERC1155Supply} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract ZombieNFT1155 is ERC1155, ERC1155Supply, Ownable, ERC1155Burnable {
    // Events
    event URIUpdated(string newURI);
    event TokenMinted(address indexed to, uint256 indexed id, uint256 amount);
    event BatchMinted(address indexed to, uint256[] ids, uint256[] amounts);

    constructor(address initialOwner, string memory uri_) ERC1155(uri_) Ownable(initialOwner) {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
        emit URIUpdated(newuri);
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        onlyOwner
    {
        require(account != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be positive");
        
        _mint(account, id, amount, data);
        emit TokenMinted(account, id, amount);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        require(to != address(0), "Cannot mint to zero address");
        require(ids.length == amounts.length, "Length mismatch");
        
        for(uint i = 0; i < amounts.length; i++) {
            require(amounts[i] > 0, "Amount must be positive");
        }
        
        _mintBatch(to, ids, amounts, data);
        emit BatchMinted(to, ids, amounts);
    }

    // View functions to check supply
    function exists(uint256 id) public view override returns (bool) {
        return totalSupply(id) > 0;
    }

    // Override required by Solidity
    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal override(ERC1155, ERC1155Supply) {
        super._update(from, to, ids, values);
    }
}
