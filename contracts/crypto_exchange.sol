// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/*********************************************************************************************************************************************/
// To be noted --- 

/* This is a common smart contract template for centralized exchange, decentralized exchange and hybrid exchange.
   Contract for centralized exchange is compiled and deployed for demonstration purpose.
   Contracts for decentralized exchange and hybrid exchange are given below in commented out manner.
   Kindly uncomment the required template and use, as needed. Compilation and deployment process will be same for all. */

/*********************************************************************************************************************************************/

// 1. Smart contract for CentralizedExchange

contract CryptoExchange {
    address public owner;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;
    uint256 public tradeFee; // Fee in basis points (1/100th of a percentage)

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event TradeExecuted(address indexed user, address indexed token, uint256 amount, uint256 fee);
    event CheckBalance(string text, uint amount);

    constructor(uint256 _tradeFee) {
        owner = msg.sender;
        tradeFee = _tradeFee;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function deposit(address tokenAddress, uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount), "Transfer failed");

        balances[msg.sender] += amount;
        emit Deposit(msg.sender, amount);
    }

    function withdraw(address tokenAddress, uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        require(IERC20(tokenAddress).transfer(msg.sender, amount), "Transfer failed");
        
        emit Withdrawal(msg.sender, amount);
    }

    function setTradeFee(uint256 _tradeFee) external onlyOwner {
        tradeFee = _tradeFee;
    }

    function executeTrade(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 toAmount
    ) external {
        require(fromAmount > 0, "Amount must be greater than 0");
        uint256 fee = (fromAmount * tradeFee) / 10000; // Calculate the fee
        require(fromToken != toToken, "Cannot trade the same token");
        require(balances[msg.sender] >= fromAmount, "Insufficient balance");
        require(balances[address(this)] >= fee, "Insufficient exchange balance");

        balances[msg.sender] -= fromAmount;
        balances[address(this)] += fee;

        // Perform the actual token swap, this is highly simplified
        // In a real exchange, you would interact with the respective token contracts
        // and handle order matching, fees, and other complex logic

        emit TradeExecuted(msg.sender, toToken, toAmount, fee);
    }
    
    function getBalance(address user_account) external returns (uint){
       uint user_bal = user_account.balance;
       emit CheckBalance(user_bal);
       return (user_bal);
    }
}