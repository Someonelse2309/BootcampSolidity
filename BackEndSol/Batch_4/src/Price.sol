// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IAggregatorV3 {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

contract Price {
    address BTC_USD = 0x6ce185860a4963106506C203335A2910413708e9; // Quote Feed
    address USDC_USD = 0x50834F3163758fcC1Df9973b6e91f0F0F0434aD3; // Base Feed

    function getPrice() public view returns (uint256){
        ( , int256 basePrice, , ,) = IAggregatorV3(USDC_USD).latestRoundData();
        ( , int256 quotePrice, , ,) = IAggregatorV3(BTC_USD).latestRoundData();
        
        return uint256(quotePrice) * 1e6 / uint256(basePrice);
        
    }
    
}
