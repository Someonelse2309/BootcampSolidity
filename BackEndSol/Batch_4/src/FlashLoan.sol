// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';

interface IAave {
    function supply(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
    function borrow(address asset, uint256 amount, uint256 interestRateMode, uint16 refferalCode, address onBehalfOf) external;
}

// BALANCER
interface IFlashloan {
    function flashLoan(address recipient, address[] memory tokens, uint256[] memory amounts, bytes calldata userData)  external;
}

contract FlashLoan {
    address uniSwapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address balancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    address AAVE = 0x794a61358D6845594F94dc1DB02A252b5b4814aD;

    address WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address USDC = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;

    function loopingSupply(uint256 supplyAmount, uint256 borrowAmount) external {
        IERC20(WETH).transferFrom(msg.sender, address(this), supplyAmount);

        address[] memory tokens = new address[](1);
        tokens[0] = USDC;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = borrowAmount;

        IFlashloan(balancerVault).flashLoan(address(this), tokens, amounts, abi.encode(supplyAmount, borrowAmount));
    }  

    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory data) external {
            (uint256 supplyAmount, uint256 borrowAmount) = abi.decode(data, (uint256,uint256));

            IERC20(USDC).approve(uniSwapRouter, borrowAmount);

            ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: USDC,
            tokenOut: WETH,
            fee: 3000,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: borrowAmount,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        uint256 outputWETH = ISwapRouter(uniSwapRouter).exactInputSingle(params);

        uint256 totalWETH = supplyAmount + outputWETH;

        IERC20(WETH).approve(AAVE,totalWETH);
        IAave(AAVE).supply(WETH, totalWETH, address(this), 0);

        IAave(AAVE).borrow(USDC, borrowAmount, 2, 0, address(this));

        IERC20(USDC).transfer(balancerVault, borrowAmount);

        }
}
