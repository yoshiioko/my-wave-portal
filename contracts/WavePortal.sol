// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "hardhat/console.sol";

contract WavePortal {
    uint totalWaves;
    uint private seed;

    event NewWave(address indexed from, uint timestamp, string message);

    struct Wave {
        address waver;      // The address of the user who waved.
        string message;     // The message the user sent.
        uint timestamp;     // The timestamp when the user waved.
    }

    Wave[] waves;
    mapping(address => uint) public lastWavedAt;

    constructor() payable {
        console.log("Hi. I'm Adrian's smart contract that's used for his wave application!");

        seed = (block.timestamp + block.difficulty) % 100;
    }

    function wave(string calldata _message) public {
        require(lastWavedAt[msg.sender] + 15 minutes < block.timestamp, "Wait 15 minutes");

        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s has waved with message %s!", msg.sender, _message);

        waves.push(Wave(msg.sender, _message, block.timestamp));

        seed = (block.difficulty + block.timestamp + seed) % 100;
        console.log("Random # generated: %d", seed);

        if (seed < 50) {
            console.log("%s won!", msg.sender);

            uint prizeAmount = 0.0001 ether;
            require(address(this).balance >= prizeAmount, "Trying to withdraw more money than the contract has.");

            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract");
        }

        emit NewWave(msg.sender, block.timestamp, _message);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint) {
        console.log("We have %d total waves!", totalWaves);
        return totalWaves;
    }
}
