class MysteryBox extends MainInventoryItem;

var protected byte AmountOfItemsMAX;

static function bool ServerLeftClick(Controller Other, int o)
{
    local INVInventory INVInventory;
    local array<class<MainInventoryItem> > Items;
    local array<int> ItemsAmount;
    local bool bGivenItem;
    local int Chance, PickupAmount, i, x;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory == none || INVInventory.MutINV == none
    || INVInventory.DataObject == none || !super.ServerLeftClick(Other, o))
        return false;

    PickupAmount = Max(1, rand(default.AmountOfItemsMAX));
    for(x=0;x<PickupAmount;x++)
    {
        Chance = Max(1, rand(INVInventory.MutINV.TotalLootChance));
        for(i=0;i<INVInventory.MutINV.LootableItems.Length;i++)
    	{
            Chance -= INVInventory.MutINV.LootableItems[i].Chance;
    		if(Chance < 0)
    		{
    			Items[Items.Length] = INVInventory.MutINV.LootableItems[i].ItemClass;
    			ItemsAmount[ItemsAmount.length] = Max(1, rand(INVInventory.MutINV.LootableItems[i].MaxLoot));
    			break;
    		}
    	}
	}

    for(x=0;x<Items.Length;x++)
    {
        bGivenItem = false;
        for(i=0;i<INVInventory.DataObject.Items.Length;i++)
        {
            if(INVInventory.DataObject.Items[i] == Items[x])
            {
                INVInventory.DataObject.ItemsAmount[i] += ItemsAmount[x];
                INVInventory.ReplicateToClientSide(i, Items[x], INVInventory.DataObject.ItemsAmount[i]);
                bGivenItem = true;
                break;
            }
        }
        if(!bGivenItem)
        {
            for(i=0;i<INVInventory.LootedItems.Length;i++)
            {
                if(INVInventory.LootedItems[i] == Items[x])
                {
                    INVInventory.LootedItemsAmount[i] += ItemsAmount[x];
                    INVInventory.ReplicateLootToClientSide(i, Items[x], INVInventory.LootedItemsAmount[i]);
                    INVInventory.ClientLootUpdateGUI();
                    bGivenItem = true;
                    break;
                }
            }
            if(!bGivenItem)
            {
                INVInventory.LootedItems[INVInventory.LootedItems.Length] = Items[x];
                INVInventory.LootedItemsAmount[INVInventory.LootedItemsAmount.Length] = ItemsAmount[x];
                INVInventory.ClientAddNewLootItem(Items[x], ItemsAmount[x]);
                INVInventory.ClientLootUpdateGUI();
            }
        }
        if(PlayerController(Other) != none)
            PlayerController(Other).ClientMessage(class'GameInfo'.static.MakeColorCode(class'mutInventorySystem'.default.YellowColor)
                                                 $ "You picked up" @ ItemsAmount[x] @ Items[x].static.GetInvItemName(Other) @ "from a mystery box.");
    }
}

defaultproperties
{
     AmountOfItemsMAX=5
     Description="Will give you a random amount of items of a random type of item."
     ItemName="Mystery Box"
     BuyPrice=-1000
     SellPrice=500
     ShopAmount=3
     ItemRestockTime=600
     ItemRemoveTime=600
}
