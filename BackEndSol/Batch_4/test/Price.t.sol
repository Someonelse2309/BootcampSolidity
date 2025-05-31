// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Price} from "../src/Price.sol";

contract PriceTest is Test {
    Price public price;

    function setUp() public {
        vm.createSelectFork("https://arb-mainnet.g.alchemy.com/v2/mgy_kXv3ErkPP66XBFt9chAsOcyul2Lu", 335163635);
        price = new Price();
    }

    function test_GetPrice() public {
        uint256 outPrice = price.getPrice();
        console.log("Konversi harganya adalah: ",outPrice);
    }
}

