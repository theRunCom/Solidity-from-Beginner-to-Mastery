// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Auction {
    // Data structures and state variables declaration
    struct Item {
        uint256 itemId;
        uint256[] itemTokens;
    }

    struct Person {
        uint256 remainingTokens;
        uint256 personId;
        address addr;
    }

    mapping(address => Person) public tokenDetails;
    Person[4] bidders;
    Item[3] public items;
    address[3] public winners;
    address public beneficiary;
    uint256 public bidderCount;

    // Constructor
    constructor() {
        beneficiary = msg.sender;
        items[0] = Item({itemId: 0, itemTokens: new uint256[](0)});
        items[1] = Item({itemId: 1, itemTokens: new uint256[](0)});
        items[2] = Item({itemId: 2, itemTokens: new uint256[](0)});
    }

    // Register bidder
    function register() public {
        require(bidderCount < bidders.length, "Auction: bidder limit reached");
        Person memory newBidder = Person({
            remainingTokens: 5,
            personId: bidderCount,
            addr: msg.sender
        });
        bidders[bidderCount] = newBidder;
        tokenDetails[msg.sender] = newBidder;
        bidderCount++;
    }

    // Modifier to restrict to only owner
    modifier onlyOwner() {
        require(msg.sender == beneficiary, "Auction: caller is not the owner");
        _;
    }

    // Bid function
    function bid(uint256 _itemId, uint256 _count) public {
        require(_itemId < items.length, "Auction: item does not exist");
        require(
            tokenDetails[msg.sender].remainingTokens >= _count,
            "Auction: not enough remaining tokens"
        );
        require(_count > 0, "Auction: number of tokens must be positive");

        tokenDetails[msg.sender].remainingTokens -= _count;
        bidders[tokenDetails[msg.sender].personId].remainingTokens = tokenDetails[msg.sender].remainingTokens;

        Item storage bidItem = items[_itemId];
        for (uint256 i = 0; i < _count; i++) {
            bidItem.itemTokens.push(tokenDetails[msg.sender].personId);
        }
    }

    // Reveal winners
    function revealWinners() public onlyOwner {
        for (uint256 id = 0; id < items.length; id++) {
            Item storage currentItem = items[id];
            if (currentItem.itemTokens.length != 0) {
                uint256 randomIndex = (block.number / currentItem.itemTokens.length) % currentItem.itemTokens.length;
                uint256 winnerId = currentItem.itemTokens[randomIndex];
                winners[id] = bidders[winnerId].addr;
            }
        }
    }

    // Get bidder details
    function getPersonDetails(uint256 id) public view returns (uint256, uint256, address) {
        require(id < bidderCount, "Auction: bidder does not exist");
        Person memory p = bidders[id];
        return (p.remainingTokens, p.personId, p.addr);
    }
}
