// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol"; // 新增：SafeERC20库
import "@openzeppelin/contracts/access/Ownable.sol";
import {Client} from "@chainlink/contracts-ccip/contracts/libraries/Client.sol";
// import {CCIPReceiver} from "@chainlink/contracts-ccip/contracts/applications/CCIPReceiver.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "hardhat/console.sol";
//import {CCIPReceiver} from "../../.deps/npm/@chainlink/contracts-ccip/contracts/applications/CCIPReceiver.sol"; // 用于调试输出
import {CCIPReceiver} from "@chainlink/contracts-ccip/contracts/applications/CCIPReceiver.sol";

// 拍卖合约
contract NftAuctionContract is Initializable, UUPSUpgradeable {
    using SafeERC20 for IERC20;
    struct Auction{
        address seller;
        address highestBidder;
        uint256 highestBid;
        uint256 startPrice;
        uint256 duration;
        // 开始时间 > 0，则表示拍卖已经上架
        uint256 startTime;
        bool ended;
        // 拍卖代币 0x0000000000000000000000000000000000000000 ETH
        // 否则为其他代币
        address tokenAddress;
        address nftContract;
        uint256 nftTokenId;
    }

    mapping(address => mapping(uint256 => Auction))public auctions;
    Auction[] public allAuctions;

    // 代币兑换美元价格接口
    mapping(address => AggregatorV3Interface) public priceFeeds;

    // 不需要了
//     constructor() Ownable(msg.sender) CCIPReceiver(msg.sender){}

    address private admin;

     // initializer 修饰符来保证初始化逻辑只执行一次
    function initialize() public initializer {
        admin = msg.sender;
        __UUPSUpgradeable_init();
        console.log("NftAuctionContract initialized");
    }

    // 重写 UUPSUpgradeable 的 _authorizeUpgrade 函数
    function _authorizeUpgrade(
        address newImplementation
    ) internal view override {
        // 只有管理员可以升级合约
        require(msg.sender == admin, "Only admin can upgrade the contract");
    }

    fallback() external payable {
        // 接收以太币
    }

    receive() external payable {
        // 接收以太币
    }

    event AuctionCreated(address seller, address _nftContract, uint256 _nftTokenId);
    event BidPlaced(address sender, address _nftContract, uint256 _nftTokenId, uint256 amount);

    // 事件记录
    event MessageReceived(
        bytes32 indexed messageId, // The unique ID of the message.
        uint64 indexed sourceChainSelector, // The chain selector of the source chain.
        address sender, // The address of the sender from the source chain.
        string text // The text that was received.
    );

    // 任何用户可创建一场拍卖，仅当该NFT属于该用户自己时
    function createAuction(address _nftContract, uint256 _nftTokenId, uint256 _startPrice, uint256 _duration)public {
        // require(msg.sender == admin,"Only admin can create auction");

        require(auctions[_nftContract][_nftTokenId].startTime == 0, "Auction already exists");

        require(msg.sender == IERC721(_nftContract).ownerOf(_nftTokenId), "seller must be the owner of the NFT");

        require(address(this) == IERC721(_nftContract).getApproved(_nftTokenId), "NFT must be approved");

        // startPrice > 0
        require(_startPrice > 0, "startPrice must be greater than 0");

        // duration > 0
        require(_duration > 0, "duration must be greater than 0");

       auctions[_nftContract][_nftTokenId] = Auction({
            seller: msg.sender,
            startPrice: _startPrice,
            duration: _duration,
            nftContract: _nftContract,
            nftTokenId: _nftTokenId,
            highestBidder: address(0),
            highestBid: 0,
            ended: false,
            startTime: block.timestamp,
            tokenAddress: address(0)
        });

        allAuctions.push(auctions[_nftContract][_nftTokenId]);

        IERC721(_nftContract).transferFrom(msg.sender, address(this), _nftTokenId);

        emit AuctionCreated(msg.sender,_nftContract,_nftTokenId);
    }

    // place bid
    function placeBid(uint256 _nftTokenId, uint256 tokenAmount, address tokenAddress) public  payable{
        // check if auction exists
        Auction memory auction = auctions[tokenAddress][_nftTokenId];
        require(auction.startTime > 0, "Auction does not exist");
        require(auction.startTime + auction.duration > block.timestamp && block.timestamp >= auction.startTime, "Auction has already ended");
        require(!auction.ended, "Auction has already ended");

        uint256 highestBid;

        // convert to dollars
        if(auction.tokenAddress != address(0)){
            highestBid = auction.highestBid * uint(getChainlinkDataFeedLatestAnswer(auction.tokenAddress));
        }else{
            tokenAmount = msg.value;
            highestBid = auction.highestBid *uint(getChainlinkDataFeedLatestAnswer(address(0)));
        }

        uint256 placePrice = tokenAmount * uint(getChainlinkDataFeedLatestAnswer(tokenAddress));
        uint256 startPrice = auction.startPrice * uint(getChainlinkDataFeedLatestAnswer(address(0)));

        require(placePrice > highestBid && msg.value > startPrice, "Bid must be higher than the current bid");
        emit BidPlaced(msg.sender, tokenAddress, _nftTokenId, tokenAmount);

        // if tokenAddress != address(0) ,transfer ERC20 token from msg.sender to this contract
        if(auction.tokenAddress != address(0)){
            IERC20(tokenAddress).transferFrom(msg.sender, address(this), tokenAmount);
        }

        // refund previous highest bidder
        //  if tokenAddress != address(0)
        if(auction.highestBidder != address(0)){
            if(auction.tokenAddress != address(0)){
                IERC20(auction.tokenAddress).transferFrom(address(this),auction.highestBidder, auction.highestBid);
            }else{
                payable(auction.highestBidder).transfer(auction.highestBid);
            }
        }

        // update auction
        auction.highestBidder = msg.sender;
        auction.highestBid = tokenAmount;
        auction.tokenAddress = tokenAddress;
    }

    // end auction
    function endAuction(address _nftContract, uint256 _nftTokenId)public {

        Auction storage auction = auctions[_nftContract][_nftTokenId];
        require(auction.startTime > 0,"Auction not exist");

        require(msg.sender == auction.seller || msg.sender == admin,"Only seller or admin can end auction");

        // check auction duration
        require(block.timestamp >= auction.startTime + auction.duration, "Auction not ended yet");
        require(!auction.ended, "auction already ended");

        if(auction.highestBidder != address(0)){

            // transfer the balance to the seller
            // if  tokenAddress != address(0)
            if(auction.tokenAddress != address(0)){
                IERC20(auction.tokenAddress).transferFrom(address(this), auction.seller, auction.highestBid);
            }else{
                payable(auction.seller).transfer(address(this).balance);
            }

            // transfer nft to the winner
            IERC721(auction.nftContract).transferFrom(address(this),auction.highestBidder, auction.nftTokenId);

        }else{
            // no effictive bid,return nft to the seller
            IERC721(auction.nftContract).transferFrom(address(this), auction.seller, auction.nftTokenId);
        }

        auction.ended = true;
    }

    function setPriceFeedAddress(
        address _tokenAddress,
        address _dataFeed
    ) external {
        require(msg.sender == admin, "Only owner can set price feed address");
        priceFeeds[_tokenAddress] = AggregatorV3Interface(_dataFeed);
    }

    function getChainlinkDataFeedLatestAnswer(
        address _tokenAddress
    ) public view returns (int) {
        AggregatorV3Interface priceFeed = priceFeeds[_tokenAddress];
        // prettier-ignore
        (
            /* uint80 roundId */,
            int256 answer,
            /*uint256 startedAt*/,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return answer;
    }

}