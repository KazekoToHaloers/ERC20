pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./interface_ERC20.sol";

contract ERC20 is interface_ERC20{

	using SafeMath for uint256;


	string public name = "Mars";
	uint8 public decimals = 18;
	string public symbol = "Mar";


	uint256 private _totalSupply = 0;//發行10萬個token
	mapping(address => uint256) _balances;
	mapping(address => mapping(address => uint256)) _approve;

    
    constructor(string memory icoName,uint8 icoDecimals,string memory icoSymbol,uint256 icoTotalSupply) public {
        name = icoName;
        decimals = icoDecimals;
        symbol = icoSymbol;
        _totalSupply = icoTotalSupply;
        _balances[msg.sender] = _balances[msg.sender].add(_totalSupply);
        emit Transfer(address(this), msg.sender, _totalSupply);
    }
    


    //已發行的總幣數量
    //回傳總幣數量
    function totalSupply() external view returns (uint256){
    	return _totalSupply;
    }


	//詢問該address擁有多少token，成功回傳"餘額"
	//回傳balances[欲查詢的token持有者的address]
    function balanceOf(address tokenOwner) external view returns (uint256 balance){
    	return _balances[tokenOwner];
    }

	//address "to"代表"欲轉入token的目標"，"value"則是欲轉入的token數量,成功回傳"true"
    //msg.sender ---tokens--->to
    //msg.sender把tokens轉出去，所以會減少tokens
    //to把tokens轉進來，所以會增加tokens
    function transfer(address to, uint256 tokens) external returns (bool success){
    	_balances[msg.sender] = _balances[msg.sender].sub(tokens);
    	_balances[to] = _balances[msg.sender].add(tokens);
    	emit Transfer(msg.sender,to,tokens);
    	return true;

	    //return _tranfer(msg.sender,to,tokens);

    }
	//這邊會使用sub是因為我們有使用SafeMath，寫法有所改變，否則原本寫法應是_balances[msg.sender] -= tokens;
	//這邊會使用add是因為我們有使用SafeMath，寫法有所改變，否則原本寫法應是_balances[to] += tokens;



    //approve這個function，代表允許該spender，可以花費多少value的token
    //可以想像成母親這個月給你一萬元,你最高上限就只能用到1萬元。


	//tokenOwner -> spender -> tokens
	//合約人     允許   此人   使用    多少tokens
	//address => address => uint256
	//合約者  允許  此EOA  使用   多少tokens

	//msg.sender授權給spender可使用自己的tokens個Token
    function approve(address spender, uint256 tokens) external returns (bool success){
    	_approve[msg.sender][spender] = tokens;		//approve就是將msg.sender對到這個spender個數個tokens，
    	emit Approval(msg.sender,spender,tokens);
    	return true;

    }


    //allowance這個function，代表你可以從owner允許的spender手上的額度裡，調查還有多少餘額。
    //可以想像成爸爸使用這個allowance去調查媽媽給小孩一萬元，小孩花了2千元，爸爸就會看到餘額還剩8千。

    //那簡單來說，就只是回傳approve行為之後剩於的錢（也是餘額）。

    function allowance(address tokenOwner, address spender) external view returns (uint256 remaining){
    	return _approve[tokenOwner][spender];
    }


    //"from用戶"授權給msg.sender，把錢從"from用戶"轉到"to用戶"，成功回傳"true"
    function transferFrom(address from, address to, uint tokens) external returns (bool success){
    	_approve[from][msg.sender] = _approve[from][msg.sender].sub(tokens);
    	_balances[from] = _balances[from].sub(tokens);
    	_balances[to] = _balances[to].add(tokens);
    	emit Transfer(from,to,tokens);
    	return true;	
    	//return _tranfer(msg.sender,to,tokens);
    }
    /*
    function _transfer(address from,address to,uint256 tokens) internal returns (bool success){
    	_balances[from] = _balances[from].sub(tokens);
    	_balances[to] = _balances[to].add(tokens);
    	emit Transfer(from,to,tokens);
    	return true;	
    }
    */
    event Transfer(address indexed from, address indexed to, uint tokens);
    //Transfer就是把錢從from用戶轉到to用戶，然後為多少數量的token

    event Approval(address indexed owner, address indexed spender, uint tokens);
    //Approval就是"owner用戶"允許"spender用戶"，使用多少數量的token


}
