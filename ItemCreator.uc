class ItemCreator extends MainInventoryItem;

var class<MainInventoryItem> ItemToCreate, NeededItem;
var int AmountOfItemNeeded, AmountGiven;
var bool bDestroyOnUse;

static function myActivateMessage(Controller Other, int Amount)
{
    local INVInventory INVInventory;
    local PlayerController C;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory != none)
    {
        C = INVInventory.FindOwnerController();
        if(C != none)
            C.ClientMessage("You created" @ Amount @ default.ItemToCreate.static.GetInvItemName(Other)
                          @ "from" @ default.AmountOfItemNeeded @ default.NeededItem.static.GetInvItemName(Other));
    }
}

static simulated function string GetDescription(Controller Other)
{
    if(Other != none)
    {
        return (default.Description @ "||This creator is used to create" @ default.AmountGiven
             @ default.ItemToCreate.static.GetInvItemName(Other) $ "s each time its used, it needs" @ default.AmountOfItemNeeded
             @ default.NeededItem.static.GetInvItemName(Other) $ "s in order to create them." $ "||"
             $ "You need to have atleast level" @ default.RequiredSkillLevel @ "in creation to use this item.");
    }
    return default.Description;
}

static function bool ServerLeftClick(Controller Other, int x)
{
    local INVInventory INVInventory;
    local int o;
    local bool bHasItem, bContinue;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory != none && INVInventory.DataObject != none
    && default.ItemToCreate != none && default.NeededItem != none
    && Other.Level != none && Other.Level.Game != none && bAllowUse(Other))
	{
        for(o=0;o<INVInventory.DataObject.Items.Length;o++)
        {
            if(INVInventory.DataObject.Items[o] == default.NeededItem
            && INVInventory.DataObject.ItemsAmount[o] >= default.AmountOfItemNeeded)
            {
                bContinue = true;
                break;
            }
        }

        if(!bContinue)
        {
            if(PlayerController(Other) != none)
                PlayerController(Other).ClientMessage("You need atleast" @ default.AmountOfItemNeeded @ default.NeededItem.static.GetInvItemName(Other) $ "'s.");
            return false;
        }

        for(o=0;o<INVInventory.DataObject.Items.Length;o++)
        {
            if(INVInventory.DataObject.Items[o] == default.ItemToCreate)
            {
                bHasItem = true;
                break;
            }
        }

        if(bHasItem)
        {
            INVInventory.DataObject.ItemsAmount[o] += default.AmountGiven;
            INVInventory.ReplicateToClientSide(o, INVInventory.DataObject.Items[o], INVInventory.DataObject.ItemsAmount[o]);
        }
        else if(INVInventory.DataObject.Items.Length < INVInventory.DataObject.Slots)
        {
            INVInventory.DataObject.Items[INVInventory.DataObject.Items.Length] = default.ItemToCreate;
            INVInventory.DataObject.ItemsAmount[INVInventory.DataObject.ItemsAmount.Length] = default.AmountGiven;
            INVInventory.ClientAddNewItem(default.ItemToCreate, default.AmountGiven);
        }
        else
        {
            if(PlayerController(Other) != none)
                PlayerController(Other).ClientMessage(INVInventory.NoMoreSlots);
            return false;
        }
        if(default.bDestroyOnUse)
            INVInventory.ChangeItem(default.class, -1);
        if(INVInventory.DataObject.CurrentMission != none)
            INVInventory.DataObject.CurrentMission.static.PickedUpItem(Other, default.ItemToCreate, default.AmountGiven, "createditem");
        myActivateMessage(Other, default.AmountGiven);
        INVInventory.ChangeItem(default.NeededItem, -default.AmountOfItemNeeded);
        INVInventory.DataObject.CreateDataStruct(INVInventory.DataRep, false, true);
	}
}

defaultproperties
{
     ItemToCreate=Class'sonicRPG45.AdrenalineThreeInvItem'
     NeededItem=Class'sonicRPG45.LiquidTarydiumGradeThree'
     AmountOfItemNeeded=100
     AmountGiven=1
     Image=Texture'SonicRPGTEX46.Inventory.ShieldPack'
     Description="Creators are items that are used to make other items, they are worth keeping since they never run out and as long as you have the materials, you can keep producing free items."
     ItemName="Item Creator"
     RequiredSkillNum=0
     BuyPrice=-200
     SellPrice=100
     ShopAmount=1
     ItemRestockTime=600
}
