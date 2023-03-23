// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract TaskKanban {
    struct Task {
        uint256 taskId;
        string docCid;
        address publisher;
        uint8 state; // 0 -> publish  1 -> training  2 -> stop
        string[] termsDocCid;
    }

    mapping(uint256 => Task) public tasks;

    event TaskAdded(uint256 indexed taskId, string cid, address owner);
    event TaskDocUpdated(uint256 indexed taskId, string cid, address owner);
    event TaskStateUpdate(uint256 indexed taskId, uint8 newsatete, address owner);
    event TaskTermDocUpdated(uint256 indexed taskId, uint256 termId, string cid);

    function publishTask(uint256 _taskId, string memory _cid) external {
        require(tasks[_taskId].taskId == 0, "Task with this taskId already exists.");
        string[] memory docCids;
        tasks[_taskId] = Task(_taskId, _cid, msg.sender, 0, docCids);

        emit TaskAdded(_taskId, _cid, msg.sender);
    }

    function getTaskPublisher(uint256 _taskId) external view returns (address) {
        if ( tasks[_taskId].taskId == 0 ){
            return address(0);
        }else {
            return tasks[_taskId].publisher;
        }
    }

    function commitTermDocCid(uint256 _taskId, uint256 _termId, string memory _termsDocCid) external {
        require(tasks[_taskId].publisher == msg.sender, "Only Task Publisher can commit TermDocCid");
        require(tasks[_taskId].termsDocCid.length == _termId-1, "Wrong TermId");
        tasks[_taskId].termsDocCid.push(_termsDocCid);

        emit TaskTermDocUpdated(_taskId, _termId, _termsDocCid);
    }

    function updateTaskDoc(uint256 _taskId, string memory _cid) external {
        // require(tasks[_taskId] != Task(0), "Task with this taskId does not exist.");
        require(tasks[_taskId].publisher == msg.sender, "Only the task publisher can update the task doc.");
        require(tasks[_taskId].state == 0, "Only the publishing Task can updata the task doc.");

        tasks[_taskId].docCid = _cid;

        emit TaskDocUpdated(_taskId, _cid, msg.sender);
    }

    function updateTaskState(uint256 _taskId, uint8 _state) external {
        // require(tasks[_taskId], "Task with this taskId does not exist.");
        require(tasks[_taskId].publisher == msg.sender, "Only the task publisher can update the task doc.");
        require(_state >= tasks[_taskId].state, "Task State Should be 'Publish -> Train -> Stop'");

        if (_state >= 3) {
            _state = 2;
        }
        tasks[_taskId].state = _state;

        emit TaskStateUpdate(_taskId, _state, msg.sender);
        
    }

}

