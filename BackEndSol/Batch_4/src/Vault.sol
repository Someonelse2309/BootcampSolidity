// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Vault is ERC20 {

    address public USDC;

    constructor(address _USDC) ERC20("Vault", "VAULT") {
        USDC = _USDC;
    }

    function deposit(uint256 amount) public {
        // Deposit Amount / Total asset * Total Share
        uint256 totalAset = IERC20(USDC).balanceOf(address(this));
        uint256 totalShare = totalSupply();
        uint256 share = 0;
        if (totalShare == 0) {
            share = amount;
        } else {
            share = amount * totalShare / totalAset;
        }
        _mint(msg.sender, share);
        IERC20(USDC).transferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 shares) public {
        // amount = shares * totalAsset / totalShares
        uint256 totalAsset = IERC20(USDC).balanceOf(address(this));
        uint256 totalShares = totalSupply();

        uint256 amount = shares * totalAsset / totalShares;

        _burn(msg.sender, shares);

        // transfer usdc from vault to msg.sender
        IERC20(USDC).transfer(msg.sender, amount);
    }

    function distributeYield(uint256 amount) public {
        IERC20(USDC).transferFrom(msg.sender, address(this), amount);
    }
}
