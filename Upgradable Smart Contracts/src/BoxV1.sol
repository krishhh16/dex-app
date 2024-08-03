// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {UUPSUpgradeable} from "@openzeppelin/contracts-ownable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-ownable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-ownable/access/OwnableUpgradeable.sol";

contract BoxV1 is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    uint number;

    constructor() {
        _disableInitializers();
    }

    function _initialize() public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address newImplementation) internal override{}

    function getNumber() external view returns(uint) {
        return number;
    }

    function getVersion() external pure returns(uint) {
        return 1;
    }

    function setNumber(uint _num) external  {
        number = _num;
    }

}