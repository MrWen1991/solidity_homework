// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

/**  合约地址： 0xB4CC56DA4573743525566269d7BfA13C646A1cD2
     所有者：0x81fF524520bB852CF3466b680CC6d66a061a1E5A
*/
contract MyErc721 is ERC721Enumerable, Ownable{

    mapping(uint256 => string) private _tokenURIs;
    constructor(uint256 tokenId) ERC721("MyNFT", "MNFT") Ownable(msg.sender) {
    }

    function mint(address to, uint256 tokenId)public onlyOwner {
        _mint(to, tokenId);
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public  {
        address owner = ownerOf(tokenId); // 确保调用者是 token 的拥有者
        require(owner == msg.sender, "ERC721: caller is not the owner of the token");
        require(bytes(_tokenURI).length > 0, "ERC721: token URI must not be empty");
        _tokenURIs[tokenId] = _tokenURI;
        // emit URI(_tokenURI, tokenId); // 触发事件
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        return _tokenURIs[tokenId];
    }
}