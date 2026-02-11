// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
    function token1() external view returns (address);
}

contract LiquidityFluctuationTrap is ITrap {
    address public constant LIQUIDITY_POOL = 0xFba1bc0E3d54D71Ba55da7C03c7f63D4641921B1;
    uint256 public constant THRESHOLD = 1e18; // 1 ETH worth of liquidity
    
    constructor() {}
    
    function collect() external view override returns (bytes memory) {
        // Try-catch for safety (Issue #2)
        try IUniswapV2Pair(LIQUIDITY_POOL).getReserves() returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32
        ) {
            // Sum both reserves as total liquidity (simplified)
            uint256 totalLiquidity = uint256(reserve0) + uint256(reserve1);
            return abi.encode(totalLiquidity);
        } catch {
            // Return empty bytes on failure (Issue #2)
            return bytes("");
        }
    }
    
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        // Planner-safety: No reverts (Issue #3)
        if (data.length < 1 || data[0].length != 32) {
            return (false, bytes(""));
        }
        
        // Decode current liquidity
        uint256 current = abi.decode(data[0], (uint256));
        
        // If no historical data, just check current
        if (data.length < 2 || data[1].length != 32) {
            // Falling-edge detection: trigger when current below threshold
            if (current < THRESHOLD) {
                return (true, abi.encode(current));
            }
            return (false, bytes(""));
        }
        
        // With historical data: check falling edge (Issue #4)
        uint256 past = abi.decode(data[1], (uint256));
        
        // Trigger when liquidity FALLS below threshold (past >= THRESHOLD && current < THRESHOLD)
        if (past >= THRESHOLD && current < THRESHOLD) {
            return (true, abi.encode(current));
        }
        
        return (false, bytes(""));
    }
    
    // Helper to check pool type (for debugging)
    function getPoolTokens() external view returns (address token0, address token1) {
        token0 = IUniswapV2Pair(LIQUIDITY_POOL).token0();
        token1 = IUniswapV2Pair(LIQUIDITY_POOL).token1();
    }
}
