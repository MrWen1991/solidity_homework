// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./NftAuctionContract.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract NftAuctionFactoryV2 is Initializable, UUPSUpgradeable {
    address private admin;
    // nftAddress => tokenId => AuctionProxyAddress
    mapping(address => mapping(uint256 => address))private auctions;
    // proxyAddress => implAddress
    mapping(address => address) private proxyImplMap;

    ERC1967Proxy[] private proxys;

    // 避免槽冲突
    function initialize() public initializer {
        admin = msg.sender;
    }

    // 升级合约使用
    function _authorizeUpgrade(
        address newImplementation
    ) internal view override {
        require(msg.sender == admin, "Only admin can upgrade");
    }

    function createAuction(address _nftContract, uint256 _nftTokenId, uint256 _startPrice, uint256 _duration) public returns (address){
        NftAuctionContract auction = new NftAuctionContract();
        ERC1967Proxy proxy = new ERC1967Proxy(address(auction), abi.encodeWithSelector(bytes4(keccak256("initialize()"))));
        auctions[_nftContract][_nftTokenId] = address(proxy);
        proxyImplMap[address(proxy)] = address(auction);
//        proxy.initialize();
        proxys.push(proxy);
//        proxy.createAuction(_nftContract, _nftTokenId, _startPrice, _duration);
        return address(proxy);
    }

    function getAuction(address nftAddress, uint256 nftTokenId) public view returns (address,uint256) {
        return (auctions[nftAddress][nftTokenId], 0);
    }

    function getAuctions()public view returns(address[] memory){

        address[] memory auctionAddresses = new address[](proxys.length);
        if(proxys.length == 0 && proxys.length < 1000){
            return auctionAddresses;
        }

        for (uint i = 0; i < proxys.length; i++) {
            auctionAddresses[i] = address(proxys[i]);
        }
        return auctionAddresses;
    }
}