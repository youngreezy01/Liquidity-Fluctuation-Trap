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
    address public constant LIQUIDITY_POOL = 0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc;
    uint256 public constant THRESHOLD = 1e18;
    
    constructor() {}
    
    function collect() external view override returns (bytes memory) {
        try IUniswapV2Pair(LIQUIDITY_POOL).getReserves() returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32
        ) {
            uint256 totalLiquidity = uint256(reserve0) + uint256(reserve1);
            return abi.encode(totalLiquidity);
        } catch {
            return bytes("");
        }
    }
    
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 1 || data[0].length != 32) return (false, bytes(""));
        
        uint256 current = abi.decode(data[0], (uint256));
        

        if (data.length < 2 || data[1].length != 32) {
        return (false, bytes("")); //
            }
        
        uint256 past = abi.decode(data[1], (uint256));
        if (past >= THRESHOLD && current < THRESHOLD) return (true, abi.encode(current));
        return (false, bytes(""));
    }
}
