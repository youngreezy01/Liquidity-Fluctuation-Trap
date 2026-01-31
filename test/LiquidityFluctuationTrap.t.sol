// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "@forge-std/Test.sol";
import {LiquidityFluctuationTrap} from "../src/LiquidityFluctuationTrap.sol";
import {SimpleResponder} from "../src/SimpleResponder.sol";

contract LiquidityFluctuationTrapTest is Test {
    LiquidityFluctuationTrap trap;
    SimpleResponder responder;
    
    function setUp() public {
        responder = new SimpleResponder();
        trap = new LiquidityFluctuationTrap();
    }
    
    function testShouldRespondLogic() public {
        bytes[] memory data = new bytes[](2);
        data[1] = abi.encode(0.5 ether); // Past: below threshold
        data[0] = abi.encode(0.8 ether); // Current: below threshold
        
        (bool shouldTrigger, ) = trap.shouldRespond(data);
        assertTrue(shouldTrigger);
    }
    
    function testResponseCallback() public {
        vm.expectEmit(true, true, true, true);
        emit SimpleResponder.ResponseTriggered(1 ether, address(this), block.timestamp);
        responder.respondCallback(1 ether);
    }
}
