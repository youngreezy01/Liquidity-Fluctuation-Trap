// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@drosera-contracts/interfaces/ITrap.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract LiquidityFluctuationTrap is ITrap {
    address public constant LIQUIDITY_POOL = 0xFba1bc0E3d54D71Ba55da7C03c7f63D4641921B1;
    uint256 public constant THRESHOLD = 1e18;
    
    struct CollectOutput {
        uint256 liquidityBalance;
    }
    
    constructor() {}
    
    function collect() external view override returns (bytes memory) {
        uint256 bal = IERC20(LIQUIDITY_POOL).balanceOf(LIQUIDITY_POOL);
        return abi.encode(CollectOutput({liquidityBalance: bal}));
    }
    
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
    require(data.length > 0, "No data provided");
    
    // Decode as uint256 (not struct)
    uint256 current = abi.decode(data[0], (uint256));
    uint256 past = abi.decode(data[data.length - 1], (uint256));
    
    // Rising-edge detection
    if (past < THRESHOLD) {
        return (true, abi.encode(current)); // Encode uint256, not struct
    }
    
    return (false, bytes(""));
}
}
