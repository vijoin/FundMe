// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {

    AggregatorV3Interface internal priceFeed;
    mapping(address => uint256) public addressToAmountFunded;
    address[] funders;
    address public owner;
    uint256 minimumUsd = 50;

    constructor() {
        // Kovan address
       priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
       owner = msg.sender;
    }

    function fund() public payable {
        uint256 _minimunUsd = minimumUsd * 10 ** 18;
        require(getConversionRate(msg.value) >= _minimunUsd, "You need to spend more ETH!");

        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getPrice() public view returns (uint256){
        (,int price,,,) = priceFeed.latestRoundData();
        return uint256(price * 10 ** 10 );
    }

    function getConversionRate(uint256 ethAmount) public view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / (10 * 10 ** 18 );
        return ethAmountInUsd;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only Owner can call this function");
        _;
    }

    function withdraw() payable onlyOwner public {
        payable(msg.sender).transfer(address(this).balance);

        // set mappings to 0
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        funders = new address[](0);
    }

    function setMinimum(uint256 _minimumAmount) public onlyOwner {
        minimumUsd = _minimumAmount;
    }


}