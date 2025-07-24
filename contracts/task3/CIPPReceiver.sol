// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Client} from "@chainlink/contracts-ccip/contracts/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/contracts/applications/CCIPReceiver.sol";
import {NftAuctionContract} from "./NftAuctionContract.sol";
import {NftToken} from "./NftToken.sol";
import {NftAuctionFactory} from "./NftAuctionFactory.sol";
import {INftAuctionFactory} from "./INftAuctionFactory.sol";

contract CIPPReceiver is CCIPReceiver {
    INftAuctionFactory public factory;

    constructor(address _router, address  _factory) CCIPReceiver(_router) {
        factory = INftAuctionFactory(_factory) ;
    }

    function _ccipReceive(
        Client.Any2EVMMessage memory message
    ) internal override {
        // 解析消息
        (address auctionAddress, address nftTokenAddress, uint256 nftTokenId,uint256 amount) = abi.decode(message.data, (address, address, uint256, uint256));
        NftAuctionContract auction = factory.getAuction(auctionAddress);
        auction.placeBid(nftTokenId, amount, nftTokenAddress);
    }
}