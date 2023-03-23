// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MM {
    function settlement(address _publisher, address[] memory _workers, uint256[] memory _alloction, uint256 _totalAlloc, bool _unlock) external {}
}

contract VAMContract {
    uint256 public startTriggerTime;
    uint256 public endTriggerTime;
    uint256 public expectAcc;

    address public trustTrigger;
    address public publisher;
    address[] public workers;
    uint256 public bonus;
    address private marketMakerAddress = 0x5e17b14ADd6c386305A32928F985b29bbA34Eff5;


    constructor(address _trustTrigger, uint256 _startTime, uint256 _endTime, uint256 _expectAcc, 
                address _publisher, address[] memory _workers, uint256 _bonus) {
        trustTrigger = _trustTrigger;
        startTriggerTime = _startTime;
        endTriggerTime = _endTime;
        publisher = _publisher;
        workers = _workers;
        bonus = _bonus;
        expectAcc = _expectAcc;
    }

    event Triggered(address indexed sender);

    function VAMSuccessContent() internal {
        MM marketMaker = MM(marketMakerAddress);
        uint256[] memory ones = new uint256[](workers.length);
        uint256 each_bonus = uint256(bonus/workers.length);
        for (uint256 i = 1; i < workers.length; i++) {
            ones[i] = each_bonus;
        }
        marketMaker.settlement(publisher, workers, ones, bonus, true);
    } 

    function Trigger(uint256 _acc) external {
        require(msg.sender == trustTrigger, "Only Trust Oracle/Validator can trigger VAM Contract");
        require(block.timestamp >= startTriggerTime, "To Early to trigger VAM Contract");
        require(block.timestamp <= endTriggerTime, "To Late to trigger VAM Contract");
        if (_acc >= expectAcc) {
            VAMSuccessContent();
            emit Triggered(msg.sender);
        }
    }
}
