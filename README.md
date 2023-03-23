# BCFLOps-contracts
- Solidity smart contracts of BC-FLOps
- BC-FLOps is Blockchain-Based Federated Learning Lifecycle Model

### Our smart contracts(light mode):
| contract                       | .sol file    | service                                                          |
|--------------------------------|--------------|------------------------------------------------------------------|
| Resource Kanban                | rk.sol       | registration and query for node & infrastructure                 |
| Task Kanban                    | tk.sol       | maintain FL Task status                                          |
| Market Maker                   | mm.sol       | margin pool management & profit distribution(use Token on chain) |
| Scatter Gather                 | sg.sol       | scatter & gather subtasks of margin contribution calculation     |
| Valuation Adjustment Mechanism | lp.sol       | long-term protocol of nodes(VAM as an example)                   |
| USDT-ERC20(mock for test)      | mockUSDT.sol | mock USDT(ERC20) for offchain test                               |

### Deployment 
- Deployment Chains 
	- mockUSDT.sol ==> mm.sol ==> lp.sol
	- tk.sol ==> sg.sol
	- rk.sol 
- For deployment chains with sequential requirements, subsequent files often contain the address of the previous contract! Remember to modify it!  
- For example (in mm.sol):
```solidity
    // This Address is our MockUSDT Token
    // Because of cyclic dependencies of MarketMaker & ScatterGather, please deploy MM firstly, and add SG Addr with func setSGAddr manually
    address public usdtAddress = 0x9D7f74d0C41E726EC95884E0e97Fa6129e3b5E99;
```
