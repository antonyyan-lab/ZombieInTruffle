// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <=0.9.0;

// These files are dynamically created at test time
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/cryptozombie.sol";

contract TestCryptoZombie {
    //createRandomZombie
    function testCreateRandomZombie() public {
        CryptoZombie cryptoZombie = CryptoZombie(DeployedAddresses.CryptoZombie);

    }
}