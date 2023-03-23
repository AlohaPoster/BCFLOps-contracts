// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TaskKanban {
    function getTaskPublisher(uint256 _taskId) external view returns (address) {}
}

contract ScatterGather {
     
    mapping(uint256 => mapping(uint256 => string)) public scatterDocCid;
    mapping(uint256 => mapping(uint256 => bytes32[])) public fedShapleyValueHash;
    mapping(uint256 => mapping(uint256 => string)) public fedShapleyValuesAvgHash;
    
    address private tkAddress = 0xf8e81D47203A594245E36C48e151709F0C19fBe8;

    event ScatterSubTask(uint256 indexed taskId, uint256 termId);
    event CommitSubTaskResult(uint256 indexed taskId, uint256 termId, address validator, bytes32 hash);
    event InvokeMarketMakerResult(uint256 indexed taskId, uint256 termId, uint256 totalAlloction);

    function getpublisher(uint256 _taskId) private view returns (address) {
        TaskKanban tk = TaskKanban(tkAddress);
        return tk.getTaskPublisher(_taskId);
    }

    // Off-Chain : shard
    function scatter(uint256 _taskId, uint256 _termId, string memory _scatterDocCid) external {
        require(msg.sender == getpublisher(_taskId), "Only task publisher can comit scatterResult");
        require(bytes(scatterDocCid[_taskId][_termId]).length == 0, "FedShapley for this Term does exist");
        scatterDocCid[_taskId][_termId] = _scatterDocCid;
        bytes32[] memory fsvhashs;
        fedShapleyValueHash[_taskId][_termId] = fsvhashs;
        emit ScatterSubTask(_taskId, _termId);
    }

    function commit(uint256 _taskId, uint256 _termId, bytes32 _fedshapleyHash) external {
        fedShapleyValueHash[_taskId][_termId].push(_fedshapleyHash);
        emit CommitSubTaskResult(_taskId, _termId, msg.sender, _fedshapleyHash);
    }

    function gather(uint256 _taskId, uint256 _termId, string memory _fedShapleyAvgHash) external {
        require(msg.sender == getpublisher(_taskId), "Only task publisher can commit gatherResult");
        fedShapleyValuesAvgHash[_taskId][_termId] = _fedShapleyAvgHash;
    }
}
