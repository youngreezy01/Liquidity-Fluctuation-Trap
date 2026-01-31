// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleResponder {
    event ResponseTriggered(uint256 liquidityAmount, address caller, uint256 timestamp);
    
    function respondCallback(uint256 amount) public {
        emit ResponseTriggered(amount, msg.sender, block.timestamp);
    }
}
