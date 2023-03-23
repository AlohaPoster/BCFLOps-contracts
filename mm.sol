// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './interface/IERC20.sol';

contract MarketMaker {
    // Real USDT Token Contract Address : 0xdAC17F958D2ee523a2206206994597C13D831ec7
    // This Address is our MockUSDT Token
    // Because of cyclic dependencies of MarketMaker & ScatterGather, please deploy MM firstly, and add SG Addr with func setSGAddr manually
    address public usdtAddress = 0x9D7f74d0C41E726EC95884E0e97Fa6129e3b5E99;
    
    mapping(address => uint256) public usdtBalances;
    mapping(address => bool) public lockAddr;
    mapping(address => address) public allowSettlement;

    event LockAddr(address indexed owner);
    event SetAllowSettlement(address indexed owner, address contractAddress);
    event SettlementToken(address indexed owner, address _publisher, address[] workers, uint256[] weights, uint256 totalAlloction);

    function depositUSDT(uint256 _amount) external {
        IERC20 usdt = IERC20(usdtAddress);
        uint256 allowance = usdt.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Insufficient allowance for MarketMaker Contract");
        bool success = usdt.transferFrom(msg.sender, address(this), _amount);
        require(success, "USDT transfer failed");
        usdtBalances[msg.sender] += _amount;
    }

    function lockUSDT() external {
        require(usdtBalances[msg.sender] > 0, "This Addr does not lock USDT in MM Contract");
        lockAddr[msg.sender] = true;
        emit LockAddr(msg.sender);
    }

    function withdrawUSDT(uint256 _amount) external {
        require(usdtBalances[msg.sender] >= _amount, "Insufficient USDT balance");
        require(!lockAddr[msg.sender], "Locked Addr because of being in a FLTask");
        IERC20 usdt = IERC20(usdtAddress);
        bool success = usdt.transfer(msg.sender, _amount);
        require(success, "USDT transfer failed");
        usdtBalances[msg.sender] -= _amount;
    }

    function setAllow(address contractAddress) external {
        allowSettlement[msg.sender] = contractAddress;
        
        emit SetAllowSettlement(msg.sender, contractAddress);
    }

    function settlement(address _publisher, address[] memory _workers, uint256[] memory _alloction, uint256 _totalAlloc, bool _unlock) external {
        require(msg.sender == _publisher || allowSettlement[_publisher] == msg.sender, "Only Allowed Addr can Request Settlement");
        require(usdtBalances[_publisher] >=  _totalAlloc, "Task Publisher has insufficient USDT balance");
        for (uint256 i = 0; i < _workers.length; i++) {
            address recipient = _workers[i];
            uint256 amount = _alloction[i];
            usdtBalances[_publisher] -= amount;
            usdtBalances[recipient] += amount;
        }
        
        if (_unlock) {
            lockAddr[_publisher] = false;
        }

        emit SettlementToken(msg.sender, _publisher, _workers, _alloction, _totalAlloc);
    }
}