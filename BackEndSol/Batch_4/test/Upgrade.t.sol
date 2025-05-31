// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MockUSDCUpg} from "../src/MockUSDCUpg.sol";
import {MockUSDCUpgV2} from "../src/MockUSDCUpgV2.sol";
import {TransparentUpgradeableProxy} from
    "lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "lib/openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import {ITransparentUpgradeableProxy} from
    "lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";


contract UpgradeTest is Test {
    MockUSDCUpg public usdcUpgImplementation;
    MockUSDCUpgV2 public usdcUpgV2Implementation;
    address public MockUSDC;

    function setUp() public {
        usdcUpgImplementation = new MockUSDCUpg();
        usdcUpgV2Implementation = new MockUSDCUpgV2();

        MockUSDC = address(new TransparentUpgradeableProxy(address(usdcUpgImplementation), address(this), ""));
    }

    function test_Upgrade() public {
        address admin = MockUSDCUpg(MockUSDC).getAdmin();

        console.log("Admin: ", admin);
        console.log("Version: ", MockUSDCUpg(MockUSDC).version());

        ProxyAdmin(admin).upgradeAndCall(ITransparentUpgradeableProxy(MockUSDC), address(usdcUpgV2Implementation), "");
        
        console.log("New Version: ", MockUSDCUpg(MockUSDC).version());

    }

}