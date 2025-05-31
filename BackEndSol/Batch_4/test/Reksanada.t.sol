// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Reksadana} from "../src/Reksadana.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ReksadanaTest is Test {
    Reksadana public reksadana;
    address WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address USDC = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address WBTC = 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f;

    function setUp() public {
        vm.createSelectFork("https://arb-mainnet.g.alchemy.com/v2/mgy_kXv3ErkPP66XBFt9chAsOcyul2Lu", 335163635);
        reksadana = new Reksadana();
    }

    function test_TotalAsset() public {
        deal(WBTC, address(reksadana), 1e8);
        deal(WETH, address(reksadana), 1e18);

        console.log("Total Asset: ", reksadana.totalAsset());
    }

    function test_Deposit() public {
        deal(USDC, address(this), 100e6);
        IERC20(USDC).approve(address(reksadana), 100e6);
        reksadana.deposit(100e6);

        console.log("total asset: ", reksadana.totalAsset());
        console.log("user share: ", IERC20(address(reksadana)).balanceOf(address(this)));
    }

    function test_Withdraw() public {
        deal(USDC, address(this), 100e6);
        IERC20(USDC).approve(address(reksadana), 100e6);
        reksadana.deposit(100e6);

        uint256 userShare = IERC20(address(reksadana)).balanceOf(address(this));
        reksadana.withdraw(userShare);

        console.log("user USDC: ", IERC20(USDC).balanceOf(address(this)));
        console.log("user share: ", IERC20(address(reksadana)).balanceOf(address(this)));
        assertEq(IERC20(address(reksadana)).balanceOf(address(this)), 0);
    }

    function test_Fail() public {
        deal(USDC, address(this), 100e6);
        IERC20(USDC).approve(address(reksadana), 100e6);
        reksadana.deposit(100e6);

        vm.expectRevert(Reksadana.ZeroAmount.selector);
        reksadana.deposit(0);

        uint256 userShare = IERC20(address(reksadana)).balanceOf(address(this));
        vm.expectRevert(Reksadana.InsufficientShares.selector);
        reksadana.withdraw(userShare + 1);

    }
}


