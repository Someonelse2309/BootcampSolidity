// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Test, console} from "forge-std/Test.sol";
import {Lending} from "../src/Lending.sol";

contract LendingTest is Test {
    Lending public lending;
    address WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address USDC = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address AAVE = 0x794a61358D6845594F94dc1DB02A252b5b4814aD;

    function setUp() public {
        vm.createSelectFork("https://arb-mainnet.g.alchemy.com/v2/mgy_kXv3ErkPP66XBFt9chAsOcyul2Lu", 335163635);
        lending = new Lending();
    }

    function test_SupplyAndBorrow() public{
        // Deal ini buat inject uang dummy
        deal(WETH, address(this), 1e18);
        IERC20(WETH).approve(address(lending), 1e18);

        lending.supplyAndBorrow(1e18, 100e6);
        assertEq(IERC20(USDC).balanceOf(address(this)), 100e6);
    }
    
}

