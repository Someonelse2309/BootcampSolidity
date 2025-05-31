// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';

import {Test, console} from "forge-std/Test.sol";
import {Swap} from "../src/Swap.sol";

contract SwapTest is Test {
    Swap public swap;
    address WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address USDC = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;

    function setUp() public {
        vm.createSelectFork("https://arb-mainnet.g.alchemy.com/v2/mgy_kXv3ErkPP66XBFt9chAsOcyul2Lu", 335106370);
        swap = new Swap();
    }

    function test_Swap() public {
        deal(WETH, address(this), 1e18);
        IERC20(WETH).approve(address(swap), 1e18);

        swap.swap(1e18);
        
        assertGt(IERC20(USDC).balanceOf(address(this)), 0);
        console.log("USDC Balance: ",IERC20(USDC).balanceOf(address(this)));
    }
    
}

