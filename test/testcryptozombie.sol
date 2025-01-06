// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/CryptoZombie.sol";
import "../contracts/ZombieNFT.sol";

contract TestCryptoZombie {
    uint constant COOLDOWN_TIME = 1 days;
    CryptoZombie cryptoZombie;
    ZombieNFT zombieNFT;
    
    // Events to verify
    event NewZombie(uint zombieId, string name, uint dna);
    event AttackResult(uint zombie, uint targetZombie, string result);

    // Run before each test
    function beforeEach() public {
        // Deploy NFT contract first
        zombieNFT = new ZombieNFT(address(this), "ZombieNFT", "ZNFT");
        
        // Deploy CryptoZombie and set NFT contract
        cryptoZombie = new CryptoZombie(address(this));
        cryptoZombie.setNFTContract(address(zombieNFT));
    }

    // Test zombie creation
    function testCreateFirstZombie() public {
        string memory zombieName = "TestZombie";
        cryptoZombie.createRandomZombie(zombieName);
        
        // Get the created zombie
        (string memory name, uint dna, uint32 level,,,) = cryptoZombie.getZombie(0);
        
        // Verify zombie attributes
        Assert.equal(name, zombieName, "Zombie name should match");
        Assert.equal(level, uint32(1), "Initial level should be 1");
        Assert.notEqual(dna, uint(0), "DNA should not be zero");
        
        // Verify NFT ownership
        Assert.equal(zombieNFT.ownerOf(0), address(this), "Should own the NFT");
    }

    // Test creating second zombie (should fail)
    function testFailCreateSecondZombie() public {
        cryptoZombie.createRandomZombie("First");
        
        // Try to create second zombie - should fail
        try cryptoZombie.createRandomZombie("Second") {
            Assert.fail("Should not be able to create second zombie");
        } catch Error(string memory reason) {
            Assert.equal(reason, "You already have zombie!", "Wrong error message");
        }
    }

    // Test zombie attack cooldown
    function testZombieAttackCooldown() public {
        // Create attacker zombie
        cryptoZombie.createRandomZombie("Attacker");
        
        // Create target zombie using helper contract
        TestHelper helper = new TestHelper();
        helper.createZombieHelper(cryptoZombie, zombieNFT);
        
        // Try to attack immediately (should fail due to cooldown)
        try cryptoZombie.attack(0, 1) {
            Assert.fail("Should not be able to attack during cooldown");
        } catch Error(string memory reason) {
            Assert.equal(reason, "Your zombie is not ready yet!", "Wrong error message");
        }
    }

    // Test level up functionality with cooldown period
    function testLevelUp() public {
        cryptoZombie.createRandomZombie("LevelTest");
        
        // Try to level up immediately - should fail due to cooldown
        try cryptoZombie.levelUp{value: 0.001 ether}(0) {
            Assert.fail("Should not be able to level up during cooldown");
        } catch Error(string memory reason) {
            Assert.equal(reason, "Your zombie is not ready yet!", "Wrong error message");
        }
        
        // Skip forward past cooldown time (done in JS tests, not possible in Solidity)
        // For Solidity tests, we'd need to create a new zombie after cooldown
        
        // Create new zombie after cooldown would be complete
        TestHelper helper = new TestHelper();
        helper.createZombieHelper(cryptoZombie, zombieNFT);
        
        // Get initial level
        (,, uint32 initialLevel,,,) = cryptoZombie.getZombie(1);
        
        // Level up with correct fee
        cryptoZombie.levelUp{value: 0.001 ether}(1);
        
        // Get new level
        (,, uint32 newLevel,,,) = cryptoZombie.getZombie(1);
        Assert.equal(newLevel, initialLevel + 1, "Level should increase by 1");
    }

    // Test name change (requires level 2)
    function testChangeName() public {
        cryptoZombie.createRandomZombie("Original");
        
        // Level up to level 2
        cryptoZombie.levelUp{value: 0.001 ether}(0);
        
        string memory newName = "Updated";
        cryptoZombie.changeName(0, newName);
        
        (string memory name,,,,,,) = cryptoZombie.getZombie(0);
        Assert.equal(name, newName, "Name should be updated");
    }
}

// Helper contract to create zombies from different addresses
contract TestHelper {
    function createZombieHelper(CryptoZombie _cryptoZombie, ZombieNFT _zombieNFT) public {
        // Approve NFT contract
        _zombieNFT.approve(address(_cryptoZombie), 1);
        
        // Create zombie
        _cryptoZombie.createRandomZombie("TargetZombie");
    }
}

