// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
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

contract ItemManager is Ownable{
    constructor() Ownable(msg.sender){

    }
    enum SupplyChainState{Created, Paid, Delivered}

    struct S_Item{
        Item _item;
        string _identifier;
        uint _itemPrice;
        ItemManager.SupplyChainState _state;
    }

    mapping (uint => S_Item) public items;
    uint ItemIndex;

    event SupplyChainStep(uint _itemIndex, uint _step, address _itemAddress);

    function createItem(string memory _identifier,  uint256 _itemPrice)  public onlyOwner {
        Item item = new Item(this, _itemPrice, ItemIndex);
        items[ItemIndex]._item = item;
        items[ItemIndex]._identifier = _identifier;
        items[ItemIndex]._itemPrice =_itemPrice ;
        items[ItemIndex]._state = SupplyChainState.Created;
        emit SupplyChainStep(ItemIndex, uint(items[ItemIndex]._state), address(item));
        ItemIndex++;
    } 

    function triggerPayment(uint _itemIndex) public payable {
        require(items[_itemIndex]._itemPrice >= msg.value, "Only full payments accepted");
        require(items[_itemIndex]._state == SupplyChainState.Created, "Items is further in the chain");
        items[_itemIndex]._state = SupplyChainState.Paid;
        emit SupplyChainStep(ItemIndex, uint(items[ItemIndex]._state), address(items[ItemIndex]._item));
    }
    
    function triggerDelivery(uint _itemIndex) public onlyOwner {
        require(items[_itemIndex]._state == SupplyChainState.Paid, "This item is not paid yet!");
        items[_itemIndex]._state = SupplyChainState.Delivered;

        emit SupplyChainStep(ItemIndex, uint(items[ItemIndex]._state), address(items[ItemIndex]._item));
    }
   
}