// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import { Test, console } from "forge-std/Test.sol";
import { CrowdfundingV2 } from "../src/chainlink-integration/CrowdfundingV2.sol";
import { RewardToken } from "../src/with-foundry/RewardToken.sol";
import { RewardNft } from "../src/with-foundry/RewardNft.sol";
import { AggregatorV3Interface } from
  "../lib/chainlink-local/lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract CrowdfundingTest is Test {
  // Crowdfunding contract state variables
  CrowdfundingV2 public crowdfundingV2;
  RewardToken public reward_token;
  RewardNft public reward_nft;
  uint256 public constant FUNDING_GOAL_IN_USD = 50 ether;
  uint256 public constant NFT_THRESHOLD = 5 ether;
  uint256 public totalFundsRaisedInUsd;
  bool public isFundingComplete;
  uint256 constant REWARD_RATE = 100;
  uint256 public constant _fundingGoal = 50000 * 1e18;

  // Addresses for testing
  address crowd_fundingV2_addr = address(this);
  address owner = vm.addr(1);
  address addr2 = vm.addr(2);
  address addr3 = vm.addr(3);
  address addr4 = vm.addr(4);
  address addr5 = vm.addr(5);
  AggregatorV3Interface priceFeed;

  event ContributionReceived(address indexed contributor, uint256 amount);
  event NFTRewardSent(address indexed receiver, uint256 Id);
  event TokenRewardSent(address indexed receiver, uint256 Amount);
  event FundsWithdrawn(address indexed receiver, uint256 Amount);

  address public constant ETH_USD_ADDR = 0x694AA1769357215DE4FAC081bf1f309aDC325306;

  function setUp() public {
    vm.startPrank(owner);

    reward_token = new RewardToken();
    reward_nft = new RewardNft("RewardNft", "RNFT", "ipfs://");

    crowdfundingV2 =
      new CrowdfundingV2(REWARD_RATE, address(reward_token), address(reward_nft), _fundingGoal);
    // console.log("cwd",  crowdfundingV2);

    // Transfer Reward tokens from owner to the contract
    reward_token.transfer(address(crowdfundingV2), 5000);

    // Approve the CrowdfundingV2 contract to spend tokens on behalf of the owner
    reward_token.approve(address(crowdfundingV2), 5000);

    vm.stopPrank();

    vm.deal(addr2, 100 ether);
    vm.deal(addr3, 100 ether);
    vm.deal(addr4, 100 ether);
    vm.deal(addr5, 100 ether);
  }

  function test_state_variables_at_deployment() public view {
    assertEq(reward_token.owner(), owner);
    assertEq(reward_nft.owner(), owner);
    assertEq(NFT_THRESHOLD, NFT_THRESHOLD);
    assertEq(crowdfundingV2.totalFundsRaisedInUsd(), 0);
    assertEq(crowdfundingV2.isFundingComplete(), false);
    assertEq(crowdfundingV2.Owner(), owner);
    assertEq(crowdfundingV2.FUNDING_GOAL_IN_USD(), _fundingGoal);
    assertEq(crowdfundingV2.tokenRewardRate(), REWARD_RATE);
  }

  function test_getLatestPrice() public view {
    int256 ethUSDPrice = crowdfundingV2.getLatestPrice();
    console.log("eth price = ", ethUSDPrice);
  }

  // Allow Eth contribution from users
  function test_contributionV2() public {
    assertEq(crowdfundingV2.isFundingComplete(), false);
    uint256 amount_to_contribute = 10 ether;

    // Getting initail balances
    uint256 initial_addr2_balance = addr2.balance;
    uint256 initial_crowdfundingV2_balance = address(crowdfundingV2).balance;
    uint256 initial_reward_token_balance = reward_token.balanceOf(crowd_fundingV2_addr);

    assertEq(initial_reward_token_balance, 5000);
    assertEq(initial_addr2_balance, 100 ether);
    assertEq(initial_crowdfundingV2_balance, 0);

    console.log("reward_token bal", reward_token.balanceOf(crowd_fundingV2_addr));

    vm.prank(addr2);
    crowdfundingV2.contribute{ value: amount_to_contribute }();

    // // Getting final balances
    //   uint256 final_addr2_balance = addr2.balance;
    // uint256 final_crowdfundingV2_balance = address(crowdfundingV2).balance;
    // uint256 final_reward_token_balance = reward_token.balanceOf(crowd_fundingV2_addr);

    // // Check that the contribution was recorded
    // uint256 contribution = crowdfundingV2.getContribution(addr2);
    // assertEq(contribution, amount_to_contribute, "Contribution not recorded correctly");

    // // Check that the CrowdfundingV2 contract received the ETH
    // assertEq(final_crowdfundingV2_balance, amount_to_contribute, "ETH not received by contract");
    // // Check that the contributor received the token reward
    // uint256 expectedTokens = (amount_to_contribute * REWARD_RATE) / 1 ether;
    // uint256 addr2TokenBalance = reward_token.balanceOf(addr2);
    // assertEq(addr2TokenBalance, expectedTokens, "Token reward not distributed correctly");

    // // Check that the CrowdfundingV2 contract's token balance decreased
    // assertEq(
    //   final_reward_token_balance,
    //   initial_reward_token_balance - expectedTokens,
    //   "Token balance not updated correctly"
    // );
  }
}
