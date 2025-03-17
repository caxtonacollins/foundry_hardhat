// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Auction {
  struct Bid {
    bytes32 blindedBid;
    uint256 deposit;
  }
  // Contract deployer

  address payable internal owner;
  //Account to receive the highest bid
  address payable public beneficiary;
  //timestamp when the bidding phse ends
  uint256 public biddingEnd;
  //timestamp to reveal the bid
  uint256 public revealEnd;
  //true if auction is still active, false otherwise
  bool public ended;

  //All bids created for this auction
  mapping(address => Bid[]) public bids;

  address public highestBidder;
  uint256 public highestBid;

  mapping(address => uint256) pendingReturns;

  event AuctionEnded(address winner, uint256 highestBid);

  error TooEarly(uint256 time);
  error TooLate(uint256 time);
  error AuctionEndAlreadyCalled();

  modifier onlyBefore(uint256 time) {
    if (block.timestamp >= time) revert TooLate(block.timestamp - time);
    _;
  }

  modifier onlyAfter(uint256 time) {
    if (block.timestamp <= time) revert TooLate(time - block.timestamp);
    _;
  }

  constructor(uint256 _biddingDuration, uint256 _revealDuration, address payable _beneficiary) {
    biddingEnd = block.timestamp + _biddingDuration;
    revealEnd = block.timestamp + _revealDuration;
    beneficiary = _beneficiary;
  }

  function blindBid(uint256 value, bool fake) public pure returns (bytes32) {
    return keccak256(abi.encodePacked(value * (1 ether), fake));
  }

  function _placeBid(address bidder, uint256 value) internal returns (bool) {
    if (value <= highestBid) {
      return false;
    }
    if (highestBidder != address(0)) {
      pendingReturns[highestBidder] += highestBid;
    }
    highestBid = value;
    highestBidder = bidder;

    return true;
  }

  function bid(bytes32 _blindedBid) external payable onlyBefore(biddingEnd) {
    bids[msg.sender].push(Bid({ blindedBid: _blindedBid, deposit: msg.value }));
  }

  function reveal(uint256[] calldata values, bool[] calldata fakes)
    external
    onlyAfter(biddingEnd)
    onlyBefore(revealEnd)
  {
    uint256 length = bids[msg.sender].length;
    require(values.length == length);
    require(fakes.length == length);

    uint256 refund;
    for (uint256 i = 0; i < length; i++) {
      Bid storage bidToCheck = bids[msg.sender][i];
      (uint256 value, bool fake) = (values[i], fakes[i]);
      uint256 bigValue = value * (1 ether);
      if (bidToCheck.blindedBid != blindBid(value, fake)) {
        //Bid was not correctly revealed
        //Burn deposit
        continue;
      }
      refund += bidToCheck.deposit;

      //Bid should not be fake
      // deposited ether should not be less than proposed bid value
      if (!fake && bidToCheck.deposit >= bigValue) {
        if (_placeBid(msg.sender, bigValue)) refund -= bigValue;
      }

      //Delete bid
      bidToCheck.blindedBid = bytes32(0);
    }

    // Transfer remaining amount to caller after sbtracting bid amount
    payable(msg.sender).transfer(refund);
  }

  function withdraw() external {
    uint256 amount = pendingReturns[msg.sender];
    if (amount > 0) {
      pendingReturns[msg.sender] = 0;
      payable(msg.sender).transfer(amount);
    }
  }

  function endAuction() external onlyAfter(revealEnd) {
    if (ended) revert AuctionEndAlreadyCalled();
    emit AuctionEnded(highestBidder, highestBid);
    ended = true;
    beneficiary.transfer(highestBid);
  }

  fallback() external payable {
    revert();
  }

  receive() external payable {
    revert();
  }
}
