// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Minimal test framework
contract Test {
    event log(string);
    
    function assertTrue(bool condition) internal pure {
        require(condition, "Assertion failed");
    }
    
    function assertFalse(bool condition) internal pure {
        require(!condition, "Assertion failed - expected false");
    }
    
    function assertEq(uint256 a, uint256 b) internal pure {
        require(a == b, "Not equal");
    }
}

import "../src/LiquidityFluctuationTrap.sol";
import "../src/SimpleResponder.sol";

contract LiquidityFluctuationTrapTest is Test {
    LiquidityFluctuationTrap trap;
    SimpleResponder responder;
    
    function setUp() public {
        trap = new LiquidityFluctuationTrap();
        responder = new SimpleResponder();
    }
    
    function testFallingEdgeDetection() public {
        bytes[] memory data = new bytes[](2);
        data[1] = abi.encode(1.5e18); // Past: ABOVE threshold
        data[0] = abi.encode(0.8e18); // Current: BELOW threshold
        
        (bool shouldTrigger, bytes memory response) = trap.shouldRespond(data);
        assertTrue(shouldTrigger); // ✅ Should trigger - fell from above to below
        
        uint256 responseValue = abi.decode(response, (uint256));
        assertEq(responseValue, 0.8e18);
    }
    
    function testNoTriggerWhenAlwaysBelow() public {
        bytes[] memory data = new bytes[](2);
        data[1] = abi.encode(0.5e18); // Past: BELOW threshold
        data[0] = abi.encode(0.8e18); // Current: BELOW threshold
        
        (bool shouldTrigger, ) = trap.shouldRespond(data);
        assertFalse(shouldTrigger); // ✅ Should NOT trigger - was already low
    }
    
    function testNoTriggerWhenAlwaysAbove() public {
        bytes[] memory data = new bytes[](2);
        data[1] = abi.encode(1.5e18); // Past: ABOVE threshold
        data[0] = abi.encode(1.2e18); // Current: ABOVE threshold
        
        (bool shouldTrigger, ) = trap.shouldRespond(data);
        assertFalse(shouldTrigger); // ✅ Should NOT trigger - still above
    }
    
    function testNoTriggerWithSingleSample() public {
        bytes[] memory data = new bytes[](1);
        data[0] = abi.encode(0.8e18);
        
        (bool shouldTrigger, ) = trap.shouldRespond(data);
        assertFalse(shouldTrigger); // ✅ Should NOT trigger - needs history
    }
    
    function testEmptyData() public {
        bytes[] memory data = new bytes[](0);
        
        (bool shouldTrigger, ) = trap.shouldRespond(data);
        assertFalse(shouldTrigger); // ✅ Should NOT trigger - empty data
    }
    
    function testRecoveredFromLow() public {
        bytes[] memory data = new bytes[](2);
        data[1] = abi.encode(0.5e18); // Past: BELOW threshold
        data[0] = abi.encode(1.5e18); // Current: ABOVE threshold (recovered)
        
        (bool shouldTrigger, ) = trap.shouldRespond(data);
        assertFalse(shouldTrigger); // ✅ Should NOT trigger - recovered
    }
}
