// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract ResourceKanban {
    mapping(address => string) public clients;
    mapping(address => string) public validators;
    address private addrCA = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    
    
    function registerClient(address addrDevice, string memory idDevice) public {
        require(msg.sender == addrCA, "Only the Certificate Authority can register new Device");
        clients[addrDevice] = idDevice;
    }

    function registerValidators(address addrDevice, string memory idDevice) public {
        require(msg.sender == addrCA, "Only the Certificate Authority can register new Device");
        validators[addrDevice] = idDevice;
    }
}