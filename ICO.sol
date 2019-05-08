pragma solidity ^0.5.0;

import "./ERC20.sol";

contract ICO {
    using SafeMath for uint;

    //設定三種狀態,ico開始前,ico開始後,ico結束後

    enum ICOState {INITIAL, START, END}

    address payable private owner = address(0);         //0.5.0版本後就不使用0x0了
    address public mTokenAddress = address(0);  //同上.
    uint256 mCaps = 0;                          //初期為0
    uint256 mCurrentFund = 0;                   //初期為0
    ICOState mICOState = ICOState.INITIAL;      //預設為before眾籌時期
    
    //合約持有者,即合約本身
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    //ico開始前
    //只要是處在這個狀態就不會碰觸到function
    modifier beforICOStart() {
        require(mICOState == ICOState.INITIAL);
        _;
    }

    //ico開始後
    modifier whenICOStart() {
        require(mICOState == ICOState.START);
        _;
    }

    //ico結束,之後
    modifier whenICOEnd() {
        require(mICOState == ICOState.END);
        _;
    }

    //ico這邊蒐集到的資訊,轉移到erc20上
    function setINFO() public {
        owner = msg.sender;                     //預設owner為msg.sender,用來管理ICO的時程
        string memory name = "Fubon Token";     //幣的token名
        uint8 decimals = 18;                    //同樣是18位(同等以太坊但可以自己轉大轉小token比值)
        string memory symbol = "FBT";           //幣的sybol
        uint256 totalSupply = 100000*(10**18);  //10萬顆fubon token,但最小也有小數點至18位的token
        mCaps = totalSupply;                    //還有多少token可以賣的變數
        mTokenAddress = address(new ERC20(name, decimals, symbol, totalSupply));

        //這段會扔進ERC20中constructor所對應的參數
        mICOState = ICOState.INITIAL;
    }
    /*
    constructor() public {
        owner = msg.sender;                     //預設owner為msg.sender,用來管理ICO的時程
        string memory name = "Fubon Token";     //幣的token名
        uint8 decimals = 18;                    //同樣是18位(同等以太坊但可以自己轉大轉小token比值)
        string memory symbol = "FBT";           //幣的sybol
        uint256 totalSupply = 100000*(10**18);  //10萬顆fubon token,但最小也有小數點至18位的token
        mCaps = totalSupply;                    //還有多少token可以賣的變數
        mTokenAddress = address(new ERC20(name, decimals, symbol, totalSupply));

        //這段會扔進ERC20中constructor所對應的參數
        mICOState = ICOState.INITIAL;
    }
    */
    
    //當開發者啟動此function時,就開始眾籌
    function startICO() public onlyOwner beforICOStart {
        mICOState = ICOState.START;
    }

    //啟動此function,結束眾籌
    function endICO() public onlyOwner whenICOStart {
        mICOState = ICOState.END;
        owner.transfer(address(this).balance);
        interface_ERC20(mTokenAddress).transfer(owner, mCaps.sub(mCurrentFund));
    }
    
    //當有外部帳戶來使用該function時,首先判斷是否眾籌已開始
    //開始之後確認該發訊人是否有傳送錢(msg.value),不然就不理會(require第一行)
    //確認當前的token還有沒有,不足就擋下                  （require第二行）

    function() external payable whenICOStart {
        require(msg.value > 0);
        require(mCaps >= mCurrentFund + msg.value);
        mCurrentFund = mCurrentFund.add(msg.value);
        interface_ERC20(mTokenAddress).transfer(msg.sender, msg.value);
    }


}