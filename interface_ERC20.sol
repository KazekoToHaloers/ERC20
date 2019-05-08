pragma solidity ^0.5.0;


interface interface_ERC20{


    function totalSupply() external view returns (uint256);

    function balanceOf(address tokenOwner) external view returns (uint256 balance);

    function transfer(address to, uint256 value) external returns (bool success);

    function approve(address spender, uint256 value) external returns (bool success);

    function allowance(address tokenOwner, address spender) external view returns (uint256 remaining);

    function transferFrom(address from, address to, uint value) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint value);
    //Transfer就是把錢從from用戶轉到to用戶，然後為多少數量的token

    event Approval(address indexed owner, address indexed spender, uint value);
    //Approval就是"owner用戶"允許"spender用戶"，使用多少數量的token


}