// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "@forge-std/Script.sol";
import {SimpleResponder} from "../src/SimpleResponder.sol";
import {LiquidityFluctuationTrap} from "../src/LiquidityFluctuationTrap.sol";

contract DeployScript is Script {
    function run() public {
        vm.startBroadcast();
        
        SimpleResponder responder = new SimpleResponder();
        console.log("SimpleResponder:", address(responder));
        
        LiquidityFluctuationTrap trap = new LiquidityFluctuationTrap();
        console.log("LiquidityFluctuationTrap:", address(trap));
        
        vm.stopBroadcast();
    }
}
