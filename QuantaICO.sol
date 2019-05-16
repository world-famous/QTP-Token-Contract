pragma solidity ^0.4.19;

import "./QuantaToken.sol";
import "./SafeMath.sol";

/**
 * The contractName contract does this and that...
 */
contract QuantaICO {

	using SafeMath for uint256;

	QuantaToken qtp;
	uint256 public softcap = 800000000 * 1 ether; // 1000 ETH
	uint256 public  hardcap = 4000000000 * 1 ether; // 5000 ETH
	bool    public  reached = false;
	uint    public  startTime = 1541030400; //2018.11.1  0:00:00 UTC
	uint    public  endTime = 1543536000;   //2018.11.30 0:00:00 UTC
	uint256 public  rate = 800000;
	uint256 public  remain;
	address public  owner = 0x1234567890abcdef;
	address[] public invstors;

	mapping  (address => uint256)    public   investor_token;

	event BuyTokens(address indexed beneficiary, uint256 value, uint256 amount, uint time);
	event ManageICOResult();

	constructor (address token) public{
		qtp = QuantaToken(token);
		require (qtp.owner() == owner);
		remain = hardcap;
	}	

	modifier onlyOwner() {
	    require(msg.sender == owner);
	    _;
	}

	function () public payable  {
		buyTokens(msg.sender);
	}

	// low level token purchase function
	function buyTokens(address beneficiary) public payable  {
		buyTokens(beneficiary, msg.value);
	}

	function buyTokens(address beneficiary, uint256 weiAmount) internal {
		require(beneficiary != 0x0);
		require(validPurchase(weiAmount));

		// calculate token amount to be sent
		uint256 tokens = weiAmount.mul(rate);
		
		if(remain.sub(tokens) <= 0){
			reached = true;
			uint256 real = remain;
			remain = 0;
			uint256 refund = weiAmount - real.div(rate);
			beneficiary.transfer(refund);
			registerTokenToInvestor(beneficiary, real);
			emit BuyTokens(beneficiary, weiAmount.sub(refund), real, now);
		} else{
			remain = remain.sub(tokens);
			registerTokenToInvestor(beneficiary, tokens);
			emit BuyTokens(beneficiary, weiAmount, tokens, now);
		}

	}

	function registerTokenToInvestor(address beneficiary, uint256 tokenamount) internal {
		if(investor_token[beneficiary] > 0)
			invstors.push(beneficiary);
		investor_token[beneficiary] = investor_token[beneficiary] + tokenamount;
	}

	function transferTokenToInvestors() internal {
		for (uint i=0; i<invstors.length; i++) {
			qtp.transfer(invstors[i], investor_token[invstors[i]]);
		}
	}

	function refundFunds() internal {
		for (uint i=0; i<invstors.length; i++) {
			invstors[i].transfer(investor_token[invstors[i]].div(rate));
		}
	}

	function transferToken(address beneficiary, uint256 tokenamount) internal {
		qtp.transfer(beneficiary, tokenamount);
	}

	// send ether to the fund collection wallet
	// override to create custom fund forwarding mechanisms
	function forwardFunds(uint256 weiAmount) internal {
		owner.transfer(weiAmount);
	}

	function validPurchase(uint256 weiAmount) internal constant returns (bool) {
		bool withinPeriod = now <= endTime;
		bool nonZeroPurchase = weiAmount >= 0 ether;
		bool withinSale = reached ? false : true;
		return withinPeriod && nonZeroPurchase && withinSale;
	}

	// @return true if ICO has ended
	function hasEnded() public constant returns (bool) {
		bool outPeriod = now > endTime;
		bool outSale = reached ? true : false;
		return outPeriod || outSale;
	}

	// @return true if ICO has started
	function hasStarted() public constant returns (bool) {
		return now >= startTime;
	}

	function manageICOResult() public onlyOwner returns (bool) {
		require(now > endTime);
		if(hardcap - remain > softcap){
			transferTokenToInvestors();
			owner.transfer(address(this).balance);
			qtp.burn(remain);
			remain = 0;
		}else{
			refundFunds();
		}

		emit ManageICOResult();
		return true;
	}

	function kill() public onlyOwner{
        selfdestruct(owner);
    }

}
