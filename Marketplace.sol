// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarket is ReentrancyGuard{
    using Counters for Counters.Counter;
    Counters.Counter private _ItemId;
    Counters.Counter private _itemSold;
    address payable owner;
    uint listingPrice= 0.025 ether;

    constructor(){
        owner=payable(msg.sender);
    }

    struct MarketItem{
        uint ItemId;
        address nftContract;
        uint256 tokenId;
        address payable owner;
        address payable seller;
        uint256 price;
        bool sold;

    }
    mapping(uint=>MarketItem) private idToMarketItem;
    event MarketItemCreated(
        uint indexed ItemId,
        address indexed nftContract,
        uint256 indexed tokenURI,
        address payable owner,
        address payable seller,
        uint256 price,
        bool sold
    );

function getListingPrice() public view returns (uint256){
return listingPrice;
}

function createMarketItem(address nftContract,uint256 tokenId,uint256 price) public payable nonReentrant{
require(price > 0,"Price must be atleast 1 wei");
require(msg.value==listingPrice,"Price must be equal to Listing Price");

_ItemId.increment();
uint256 ItemId=_ItemId.current();

idToMarketItem[ItemId]= MarketItem(
ItemId,
nftContract,
tokenId,
payable(msg.sender),
payable(address(0)),
price,
false
);
IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

emit MarketItemCreated(
ItemId,
nftContract,
tokenId,
payable(msg.sender),
payable(address(0)),
price,
false
);
}
function createMarketSale(address nftContract,uint256 ItemId) public payable nonReentrant{
uint price= idToMarketItem[ItemId].price;
uint tokenId= idToMarketItem[ItemId].tokenId;
require(msg.value==price,"Please submit the asking price in order to complete purchase");
idToMarketItem[ItemId].seller.transfer(msg.value);
IERC721(nftContract).transferFrom(address(this),msg.sender,tokenId);
idToMarketItem[ItemId].owner=payable(msg.sender);
idToMarketItem[ItemId].sold=true;
_itemSold.increment();
payable(owner).transfer(listingPrice);
}

function fetchMarketItems() public view returns (MarketItem[] memory) {
      uint itemCount = _ItemId.current();

       uint unsoldItemCount = _ItemId.current() - _itemSold.current();
      uint currentIndex = 0;
      MarketItem[] memory items = new MarketItem[](unsoldItemCount);
       for (uint i = 0; i < itemCount; i++) {
        if (idToMarketItem[i + 1].owner == address(0)) {
          uint currentId =idToMarketItem[i + 1].ItemId;
          MarketItem storage currentItem = idToMarketItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }
     function fetchMyNFTs() public view returns (MarketItem[] memory) {
      uint totalItemCount = _ItemId.current();
      uint itemCount = 0;
      uint currentIndex = 0;

      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].owner == msg.sender) {
          itemCount += 1;
        }
      }

      MarketItem[] memory items = new MarketItem[](itemCount);
      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].owner == msg.sender) {
          uint currentId = i + 1;
          MarketItem storage currentItem = idToMarketItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }
      function fetchItemsListed() public view returns (MarketItem[] memory) {
      uint totalItemCount = _ItemId.current();
      uint itemCount = 0;
      uint currentIndex = 0;

      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].seller == msg.sender) {
          itemCount += 1;
        }
      }

      MarketItem[] memory items = new MarketItem[](itemCount);
      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].seller == msg.sender) {
          uint currentId = i + 1;
          MarketItem storage currentItem = idToMarketItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }
}
