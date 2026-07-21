// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TitanActivityDecoy {
    address public owner;
    uint256 public totalInteractions;
    uint256 public totalCeloRecycled;
    mapping(address => uint256) public userInteractions;
    
    event InteractionRecorded(address indexed user, uint256 count, uint256 celoSent);

    constructor(address _owner) {
        owner = _owner;
    }

    // 1. Regular low-gas interaction
    function ping() external {
        totalInteractions++;
        userInteractions[msg.sender]++;
        emit InteractionRecorded(msg.sender, totalInteractions, 0);
    }

    // 2. High-gas write loop (deliberately consumes gas to spend the CELO budget)
    function heavyPing(uint256 iterations) external {
        for (uint256 i = 0; i < iterations; i++) {
            totalInteractions++;
            userInteractions[msg.sender]++;
        }
        emit InteractionRecorded(msg.sender, totalInteractions, 0);
    }

    // 3. Value-bearing interaction: sends the CELO straight back to the master wallet (owner)
    function recycleCelo() external payable {
        require(msg.value > 0, "Must send CELO");
        totalInteractions++;
        userInteractions[msg.sender]++;
        totalCeloRecycled += msg.value;
        
        // Transfer the CELO straight back to the master wallet (owner)
        payable(owner).transfer(msg.value);
        
        emit InteractionRecorded(msg.sender, totalInteractions, msg.value);
    }
}
