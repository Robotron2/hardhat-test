// SPDX-License-Identifier:MIT
pragma solidity ^0.8.30;
import "./interfaces/IUniswapV2Router.sol";
import "./interfaces/IERC20.sol";

contract UseSwap {
    address public uniswapRouter;
    address public owner;
    uint256 public swapCount;
    uint256 public swapCountToken;
    uint256 public liquidityCount;

    constructor(address _uniswapRouter) {
        uniswapRouter = _uniswapRouter;
        owner = msg.sender;
    }

    function handleSwap(uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline)
        external
    {
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountInMax);

        require(IERC20(path[0]).approve(uniswapRouter, amountInMax), "approve failed.");

        IUniswapV2Router(uniswapRouter).swapTokensForExactTokens(amountOut, amountInMax, path, to, deadline);

        swapCount += 1;
    }

    function handleSwapToken(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external {
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);

        require(IERC20(path[0]).approve(uniswapRouter, amountIn), "approve failed.");

        IUniswapV2Router(uniswapRouter).swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline);

        swapCountToken += 1;
    }

    function handleAddLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external {
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountADesired);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountBDesired);

        require(IERC20(tokenA).approve(uniswapRouter, amountADesired), "approve failed.");
        require(IERC20(tokenB).approve(uniswapRouter, amountBDesired), "approve failed.");

        IUniswapV2Router(uniswapRouter)
            .addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin, to, deadline);

        liquidityCount += 1;
    }
}
