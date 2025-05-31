// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MockUSDC} from "../src/MockUSDC.sol";
import {Vault} from "../src/Vault.sol";

contract VaultScript is Script {
    MockUSDC public usdc;
    Vault public vault;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        usdc = new MockUSDC();
        vault = new Vault(address(usdc));

        console.log("MockUSDC deployed at: ", address(usdc));
        console.log("Vault deployed at: ", address(vault));

        vm.stopBroadcast();
    }
}
