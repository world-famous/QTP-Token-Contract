pragma solidity ^0.4.19;


import "./ERC20.sol";
import "./SafeMath.sol";

/**
 * The contractName contract does this and that...
 */
contract QuantaToken is ERC20 {

	using SafeMath for uint256;

	uint256  public  totalSupply = 10000000000 * 1 ether;

	mapping  (address => uint256)             public          _balances;
    mapping  (address => mapping (address => uint256)) public  _approvals;


    string   public  name = "QUANTAPROTOCOL";
    string   public  symbol = "QTP";
    uint256  public  decimals = 18;

    address  public  owner = 0x1234567890abcdef;

    event Mint(uint256 wad);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    

    constructor () public{
		_balances[owner] = totalSupply;
	}

	modifier onlyOwner() {
	    require(msg.sender == owner);
	    _;
	}

    function totalSupply() public constant returns (uint256) {
        return totalSupply;
    }
    function balanceOf(address src) public constant returns (uint256) {
        return _balances[src];
    }
    function allowance(address src, address guy) public constant returns (uint256) {
        return _approvals[src][guy];
    }
    
    function transfer(address dst, uint256 wad) public returns (bool) {
        assert(_balances[msg.sender] >= wad);
        
        _balances[msg.sender] = _balances[msg.sender].sub(wad);
        _balances[dst] = _balances[dst].add(wad);
        
        emit Transfer(msg.sender, dst, wad);
        
        return true;
    }
    
    function transferFrom(address src, address dst, uint256 wad) public returns (bool) {
        assert(_balances[src] >= wad);
        assert(_approvals[src][msg.sender] >= wad);
        
        _approvals[src][msg.sender] = _approvals[src][msg.sender].sub(wad);
        _balances[src] = _balances[src].sub(wad);
        _balances[dst] = _balances[dst].add(wad);
        
        emit Transfer(src, dst, wad);
        
        return true;
    }
    
    function approve(address guy, uint256 wad) public returns (bool) {
        _approvals[msg.sender][guy] = wad;
        
        emit Approval(msg.sender, guy, wad);
        
        return true;
    }

    function mint(uint256 wad) public onlyOwner {
        _balances[msg.sender] = _balances[msg.sender].add(wad);
        totalSupply = totalSupply.add(wad);
        emit Mint(wad);
    }

    function burn(uint256 wad) onlyOwner {
        _balances[msg.sender] = _balances[msg.sender].sub(wad);
        totalSupply = totalSupply.sub(wad);
    }
}
