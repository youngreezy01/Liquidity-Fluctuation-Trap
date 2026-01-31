// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Minimal ITrap interface
interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract LiquidityFluctuationTrap is ITrap {
    address public constant LIQUIDITY_POOL = 0xFba1bc0E3d54D71Ba55da7C03c7f63D4641921B1;
    uint256 public constant THRESHOLD = 1e18;
    
    constructor() {}
    
    function collect() external view override returns (bytes memory) {
        uint256 bal = IERC20(LIQUIDITY_POOL).balanceOf(LIQUIDITY_POOL);
        return abi.encode(bal);
    }
    
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        require(data.length > 0, "No data");
        if (data[0].length == 0) return (false, bytes(""));
        
        uint256 current = abi.decode(data[0], (uint256));
        uint256 past = data.length > 1 && data[1].length > 0 
            ? abi.decode(data[1], (uint256))
            : current;
        
        if (past < THRESHOLD) return (true, abi.encode(current));
        return (false, bytes(""));
    }
}
