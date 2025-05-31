// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MockUSDC} from "../src/MockUSDC.sol";
import {Vault} from "../src/Vault.sol";

contract VaultTest is Test {
    MockUSDC public usdc;
    Vault public vault;

    address public alice = makeAddr("Alice");
    address public bob = makeAddr("bob");
    address public charlie = makeAddr("charlie");

    function setUp() public {
        usdc = new MockUSDC();
        vault = new Vault(address(usdc));
    }
    
    function test_Deposit() public {
        vm.startPrank(alice);
        usdc.mint(alice, 1_000);
        usdc.approve(address(vault), 1_000);
        vault.deposit(1_000);
        assertEq(vault.balanceOf(alice), 1_000);

        vm.startPrank(bob);
        usdc.mint(bob, 2_000);
        usdc.approve(address(vault), 2_000);
        vault.deposit(2_000);
        assertEq(vault.balanceOf(bob), 2_000);
        vm.stopPrank();
    }

    function testScenario() public {
        // alice deposit 1_000_000
        vm.startPrank(alice);
        usdc.mint(alice, 1_000_000);
        usdc.approve(address(vault), 1_000_000);
        vault.deposit(1_000_000);
        assertEq(vault.balanceOf(alice), 1_000_000);
        vm.stopPrank();

        // bob deposit 2_000_000
        vm.startPrank(bob);
        usdc.mint(bob, 2_000_000);
        usdc.approve(address(vault), 2_000_000);
        vault.deposit(2_000_000);
        assertEq(vault.balanceOf(bob), 2_000_000);
        vm.stopPrank();

        // distribute yield 1_000_000
        usdc.mint(address(this),1_000_000);
        usdc.approve(address(vault), 1_000_000);
        vault.distributeYield(1_000_000);

        // charlie deposit 1_000_000    
        vm.startPrank(charlie);
        usdc.mint(charlie, 1_000_000);
        usdc.approve(address(vault), 1_000_000);
        vault.deposit(1_000_000);
        assertEq(vault.balanceOf(charlie), 750_000);
        vm.stopPrank();
        
        // alice withdraw 1_00_000
        vm.startPrank(alice);
        vault.withdraw(1_000_000);
        assertEq(usdc.balanceOf(alice), 1_333_333);
        vm.stopPrank();

        // bob withdraw 2_000_000
        vm.startPrank(bob);
        vault.withdraw(2_000_000);
        assertEq(usdc.balanceOf(bob), 2_666_666);
        vm.stopPrank();
        
        
    }
}