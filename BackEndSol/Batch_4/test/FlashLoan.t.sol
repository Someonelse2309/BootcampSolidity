// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {FlashLoan} from "../src/FlashLoan.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FlashLoanTest is Test {
    FlashLoan public flashLoan;

    address WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address USDC = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address AWETH = 0xe50fA9b3c56FfB159cB0FCA61F5c9D750e8128c8;

    function setUp() public{
        vm.createSelectFork("https://arb-mainnet.g.alchemy.com/v2/mgy_kXv3ErkPP66XBFt9chAsOcyul2Lu", 335163635);
        flashLoan = new FlashLoan();
    }

    function test_loopingSupply() public{
        //mock 1 ETH
        deal(WETH, address(this), 1e18);

        IERC20(WETH).approve(address(flashLoan), 1e18);

        //eksekusi looping sebesar supply 1 weth dan borrow 2350usdc
        flashLoan.loopingSupply(1e18, 2350e6);

        assertGt(IERC20(AWETH).balanceOf(address(flashLoan)), 1e18);
        console.log("aWeth balance", IERC20(AWETH).balanceOf(address(flashLoan)));
    }
}