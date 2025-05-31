// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

import {Test, console} from "forge-std/Test.sol";

interface IAggregatorV3 {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

contract Reksadana is ERC20 {
    // Buat bikin error
    error ZeroAmount();
    error InsufficientShares();

    // Event ini kaya trigger, biasanya buat masukin ke database (data history)
    event Deposit(address user, uint256 amount, uint256 shares);
    event Withdraw(address user, uint256 shares, uint256 amount);


    address uniswapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

    // tokens
    address WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address USDC = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address WBTC = 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f;

    address USDC_USD = 0x50834F3163758fcC1Df9973b6e91f0F0F0434aD3;
    address WBTCFeed = 0x6ce185860a4963106506C203335A2910413708e9;
    address WETHFeed = 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612;

    constructor() ERC20("Reksadana", "RKSD") {}

    function totalAsset() public returns (uint256){
        (, int256 USDCPrice, , , ) = IAggregatorV3(USDC_USD).latestRoundData();

        (, int256 WBTCPrice, , , ) = IAggregatorV3(WBTCFeed).latestRoundData();
        uint256 WBTC_USD = uint256(WBTCPrice) * 1e6 / uint256(USDCPrice);

        (, int256 WETHPrice, , , ) = IAggregatorV3(WETHFeed).latestRoundData();
        uint256 WETH_USD = uint256(WETHPrice) * 1e6 / uint256(USDCPrice);

        uint256 totalWETHAsset = IERC20(WETH).balanceOf(address(this)) * WETH_USD / 1e18;
        uint256 totalWBTCAsset = IERC20(WBTC).balanceOf(address(this)) * WBTC_USD / 1e8;

        return totalWETHAsset + totalWBTCAsset; 
    }

    function deposit(uint256 amount) public {
        if (amount == 0) revert ZeroAmount();

        uint256 totalAssetRD = totalAsset();
        uint256 totalShare = totalSupply();
        uint256 share = 0;

        if (totalShare == 0){
            share = amount;
        } else {
            share = amount * totalShare / totalAssetRD;
        }

        // console.log("Smpe sini");
        IERC20(USDC).transferFrom(msg.sender, address(this), amount);
        // console.log("Smpe sini");
        _mint(msg.sender, share);
        
        uint256 amountIn = amount / 2;
        // console.log("Smpe sini");
        IERC20(USDC).approve(uniswapRouter, amountIn);
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: USDC,
            tokenOut: WETH,
            fee: 3000,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: amountIn,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });
        ISwapRouter(uniswapRouter).exactInputSingle(params);
        // console.log("Smpe sini");
        IERC20(USDC).approve(uniswapRouter, amountIn);
        params = ISwapRouter.ExactInputSingleParams({
            tokenIn: USDC,
            tokenOut: WBTC,
            fee: 3000,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: amountIn,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });
        // console.log("Smpe sini");
        ISwapRouter(uniswapRouter).exactInputSingle(params);

        emit Deposit(msg.sender, amount, share);
    }

    function withdraw(uint256 share) public {
        if (share == 0) revert ZeroAmount();
        if (share > balanceOf(msg.sender)) revert InsufficientShares();

        uint256 totalShare = totalSupply();
        uint256 PROPOTION_SCALED = 1e18;

        uint256 propotion = (share * PROPOTION_SCALED) / totalShare;

        uint256 swapWETH = propotion * IERC20(WETH).balanceOf(address(this)) / PROPOTION_SCALED ;  
        uint256 swapWBTC = propotion * IERC20(WBTC).balanceOf(address(this)) / PROPOTION_SCALED ;  

        _burn(msg.sender, share);

        IERC20(WETH).approve(uniswapRouter, swapWETH);
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: WETH,
            tokenOut: USDC,
            fee: 3000,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: swapWETH,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        IERC20(WBTC).approve(uniswapRouter, swapWBTC);
        params = ISwapRouter.ExactInputSingleParams({
            tokenIn: WBTC,
            tokenOut: USDC,
            fee: 3000,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: swapWBTC,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        uint256 amountUSDC = IERC20(USDC).balanceOf(address(this));
        IERC20(USDC).transfer(msg.sender,amountUSDC);

        emit Withdraw(msg.sender, share, amountUSDC);
    }
}
