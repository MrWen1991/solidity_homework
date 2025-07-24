// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {NftAuctionContract} from "./NftAuctionContract.sol";

interface INftAuctionFactory{
    function createAuction(address _nftContract, uint256 _nftTokenId, uint256 _startPrice, uint256 _duration) external returns (NftAuctionContract);
    function getAuction(address _auction) external view returns (NftAuctionContract);
}