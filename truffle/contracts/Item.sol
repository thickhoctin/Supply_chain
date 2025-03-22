// SPDX-License-Identifier: MIT 
pragma solidity 0.8.29;

import "./ItemManager.sol";


contract Item {
    // This contract has 3 states: Created, Paid and Delivered
    uint public priceInWei;
    uint public pricePaid;
    uint public index;
    ItemManager parentContract;
    constructor (ItemManager _parentContract, uint _priceInWei, uint _index) {
        priceInWei = _priceInWei; 
        index = _index;
        parentContract = _parentContract;
    }

    receive() external payable {
        require(pricePaid == 0, "This item is paid already");
        require(priceInWei == msg.value, "Only full payments allowed");
        pricePaid += msg.value;
        (bool success,) = address(parentContract).call{value: msg.value}(abi.encodePacked(index));
        require(success, "The transaction wasn't successful, canceling");
    }

    fallback() external payable {

    }
}
