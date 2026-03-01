// SPDX-License-Identifier:MIT
pragma solidity ^0.8.30;
import "./interfaces/IUniswapV2Router.sol";
import "./interfaces/IERC20.sol";

contract UseSwap {
    address public immutable uniswapRouter;
    address public immutable owner;

    uint256 public swapCount;
    uint256 public liquidityCount;

    constructor(address _uniswapRouter) {
        require(_uniswapRouter != address(0), "Invalid router");
        uniswapRouter = _uniswapRouter;
        owner = msg.sender;
    }

    receive() external payable {}

    /*//////////////////////////////////////////////////////////////
                        Swaps
    //////////////////////////////////////////////////////////////*/

    //swapTokensForExactTokens
    function handleSwap(uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline)
        external
    {
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountInMax);

        require(IERC20(path[0]).approve(uniswapRouter, amountInMax), "approve failed.");

        IUniswapV2Router(uniswapRouter).swapTokensForExactTokens(amountOut, amountInMax, path, to, deadline);

        swapCount += 1;
    }

    //swapExactTokensForToken
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

        swapCount += 1;
    }

    //swapETHForExactTokens
    function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint256 deadline)
        external
        payable
    {
        IUniswapV2Router(uniswapRouter).swapETHForExactTokens{value: msg.value}(amountOut, path, to, deadline);
        swapCount++;
    }

    //swapExactEthForTokens
    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline)
        external
        payable
    {
        require(path[0] != address(0), "Path must start with WETH");

        IUniswapV2Router(uniswapRouter).swapExactETHForTokens{value: msg.value}(amountOutMin, path, to, deadline);

        swapCount++;
    }

    //swapExactTokensForEth
    function swapExactTokensForEth(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external {
        // transferFrom
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountInMax);
        require(IERC20(path[0]).approve(uniswapRouter, amountInMax), "Approve failed");
        IUniswapV2Router(uniswapRouter).swapTokensForExactETH(amountOut, amountInMax, path, to, deadline);
        swapCount++;
    }

    /*//////////////////////////////////////////////////////////////
                        LIQUIDITY
    //////////////////////////////////////////////////////////////*/

    //addLiquidity
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

    //addLiquidityETH
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable {
        IERC20(token).transferFrom(msg.sender, address(this), amountTokenDesired);
        require(IERC20(token).approve(uniswapRouter, amountTokenDesired), "Approve failed");

        IUniswapV2Router(uniswapRouter).addLiquidityETH{value: msg.value}(
            token, amountTokenDesired, amountTokenMin, amountETHMin, to, deadline
        );
        liquidityCount++;
    }

    // Remove liquidity
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external {
        address pair = IUniswapV2Router(uniswapRouter).factory();
        IERC20(pair).transferFrom(msg.sender, address(this), liquidity);
        require(IERC20(pair).approve(uniswapRouter, liquidity), "Approve failed");

        IUniswapV2Router(uniswapRouter).removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
    }

    /*//////////////////////////////////////////////////////////////
                            VIEW HELPERS
    //////////////////////////////////////////////////////////////*/

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory) {
        return IUniswapV2Router(uniswapRouter).getAmountsOut(amountIn, path);
    }

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory) {
        return IUniswapV2Router(uniswapRouter).getAmountsIn(amountOut, path);
    }
}
