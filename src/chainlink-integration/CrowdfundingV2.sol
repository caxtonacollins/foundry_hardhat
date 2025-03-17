// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import { console } from "forge-std/Test.sol";
import "@chainlink/contracts/src/v0.8//shared/interfaces/AggregatorV3Interface.sol";
import "../../src/with-foundry/RewardToken.sol";
import "../../src/with-foundry/RewardNft.sol";

contract CrowdfundingV2 {
  address public Owner;
  uint256 public FUNDING_GOAL_IN_USD;
  uint256 public constant NFT_THRESHOLD = 1000;
  uint256 public totalFundsRaisedInUsd;
  bool public isFundingComplete;

  RewardToken public rewardToken;
  RewardNft public rewardNFT;
  uint256 public tokenRewardRate;

  // Contribution tracking
  mapping(address => uint256) public contributions;
  mapping(address => bool) public hasReceivedNFT;

  // Chainlink PriceFeed
  AggregatorV3Interface internal priceFeed;

  address public constant ETH_USD_ADDR = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
  // Events

  event ContributionReceived(address indexed contributor, uint256 amount);
  event TokenRewardSent(address indexed contributor, uint256 amount);
  event NFTRewardSent(address indexed contributor, uint256 tokenId);
  event FundsWithdrawn(address indexed projectOwner, uint256 amount);

  modifier onlyOwner() {
    require(Owner == msg.sender, "Only owner is allowed");
    _;
  }

  constructor(
    uint256 _tokenRewardRate,
    address _rewardToken,
    address _rewardNft,
    uint256 _fundingGoad
  ) {
    /**
     * Network: Sepolia
     * Data Feed: ETH/USD
     * Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
     */
    priceFeed = AggregatorV3Interface(ETH_USD_ADDR);
    Owner = msg.sender;
    rewardToken = RewardToken(_rewardToken);
    rewardNFT = RewardNft(_rewardNft);
    tokenRewardRate = _tokenRewardRate;
    FUNDING_GOAL_IN_USD = _fundingGoad;
  }

  // function to retrieve ETH price in USD with Chainlink priceFeed
  function getLatestPrice() public view returns (int256) {
    (
      ,
      // uint80 roundID
      int256 price, // uint256 startedAt
      // uint256 updatedAt
      ,
      ,
    ) = priceFeed.latestRoundData();

    require(price > 0, "Invalid price");
    return price; // Price has 8 decimals, e.g., 3000.00000000
  }

  // Function to convert ETH to USD using the latest price
  function convertEthToUsd(uint256 ethAmount) public view returns (uint256) {
    int256 latestPrice = getLatestPrice();
    uint256 usdAmount = (ethAmount * uint256(latestPrice)) / 1e18;
    return usdAmount;
  }

  function contribute() external payable {
    // console.log("Ether Value contribution___%s", msg.value);
    require(msg.value > 0, "Contribution must be greater than 0");
    require(!isFundingComplete, "Funding goal already reached");

    // Calculating the usd value of the contribution
    uint256 usdValue = convertEthToUsd(msg.value);

    // Check if the contribution exceeds the funding goal
    uint256 remainingGoalInUsd = FUNDING_GOAL_IN_USD - totalFundsRaisedInUsd;

    uint256 refundableAmount = 0;

    if (usdValue > remainingGoalInUsd) {
      // Caculatingg the remaining amount in Eth
      uint256 excessUsd = usdValue - remainingGoalInUsd;
      int256 latestPrice = getLatestPrice();
      require(latestPrice > 0, "Invalid price: price must be positive");
      refundableAmount = (excessUsd * 1e18) / uint256(latestPrice);
      console.log("Refundable Amount___%s", refundableAmount);
      usdValue = remainingGoalInUsd;
    }

    // Update contribution record and total funds raised
    contributions[msg.sender] += msg.value - refundableAmount;
    totalFundsRaisedInUsd += usdValue;

    // Refund excess contribution
    if (refundableAmount > 0) {
      (bool success,) = msg.sender.call{ value: refundableAmount }("");
      require(success, "Transfer failed");
    }

    // Check if funding goal is reached
    if (totalFundsRaisedInUsd >= FUNDING_GOAL_IN_USD) {
      isFundingComplete = true;
    }

    // Calculate and send token reward
    uint256 tokenReward = calculateReward(msg.value - refundableAmount);
    if (tokenReward > 0) {
      bool isTransferred = sendRewardToken(tokenReward, msg.sender);
      require(isTransferred, "Token transfer failed");
    }

    // Check and mint NFT if eligible
    if (checkNftEligibilty(msg.sender)) {
      bool isNftMinted = mintNft(msg.sender);
      require(isNftMinted, "NFT minting failed");
    }

    emit ContributionReceived(msg.sender, msg.value);
  }

  function checkNftEligibilty(address _address) private view returns (bool) {
    if (contributions[_address] >= NFT_THRESHOLD && !hasReceivedNFT[_address]) {
      return true;
    }
    return false;
  }

  function mintNft(address _contributor) private returns (bool) {
    require(checkNftEligibilty(_contributor), "Not eligible for NFT reward");
    uint256 tokenId = rewardNFT.mintNFT(_contributor);
    hasReceivedNFT[_contributor] = true;
    emit NFTRewardSent(_contributor, tokenId);
    return true;
  }

  function calculateReward(uint256 _value) private view returns (uint256) {
    uint256 tokenReward = (_value * tokenRewardRate) / 1 ether;

    return tokenReward;
  }

  function sendRewardToken(uint256 _amount, address _recipient) private returns (bool) {
    require(rewardToken.transferFrom(address(this), _recipient, _amount), "Token transfer failed");
    emit TokenRewardSent(_recipient, _amount);
    return true;
  }

  // function transferRefundableAmount(uint256 _amount, address _contributor) private {
  //   uint256 refundable = _determineIfAmountIsRefundable(_amount);
  //   if (refundable > 0) {
  //     (bool success,) = _contributor.call{ value: refundable }("");
  //     require(success, "Transfer failed");
  //   }
  // }

  function withdrawFunds() external {
    require(msg.sender == Owner, "Only project owner can withdraw");
    require(isFundingComplete, "Funding goal not yet reached");
    require(address(this).balance > 0, "No funds to withdraw");

    uint256 amount = address(this).balance;
    payable(Owner).transfer(amount);

    emit FundsWithdrawn(Owner, amount);
  }

  function getContribution(address contributor) external view returns (uint256) {
    return contributions[contributor];
  }
}
