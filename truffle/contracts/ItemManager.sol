// SPDX-License-Identifier: MIT 
pragma solidity 0.8.29;


import "./Ownable.sol";
import "./Item.sol";
contract ItemManager is Ownable{
    
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
