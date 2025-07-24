// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NftToken is ERC721,Ownable {

    constructor() ERC721("NftToken", "NFT") Ownable(msg.sender) {
        mint(msg.sender,1);
    }

    function mint(address to, uint256 tokenId)public onlyOwner returns (bool){
        _mint(to,tokenId);
        return true;
    }

}