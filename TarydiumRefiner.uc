class TarydiumRefiner extends MainInventoryItem;

var protected float LooseChance; //Number between 0.0 - 1.0.
var protected class<MainInventoryItem> RefinedItemClass, ItemsNeeded;
var protected int AmountOfItemNeeded;

static function myActivateMessage(Controller Other, int Amount, int FinalAmount)
{
    local INVInventory INVInventory;
    local PlayerController C;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory != none)
    {
        C = INVInventory.FindOwnerController();
        if(C != none)
            C.ClientMessage(Amount @ default.ItemsNeeded.static.GetInvItemName(Other) $ "s have been refined into"
                          @ FinalAmount @ default.RefinedItemClass.static.GetInvItemName(Other));
    }
}

static function bool ServerLeftClick(Controller Other, int x)
{
    local INVInventory INVInventory;
    local int Amount, i, o;
    local float FinalAmount;
    local bool bContinue;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory != none && INVInventory.DataObject != none && default.ItemsNeeded != none
    && default.RefinedItemClass != none && bAllowUse(Other))
	{
        for(i=0;i<INVInventory.DataObject.Items.Length;i++)
        {
            if(INVInventory.DataObject.Items[i] == default.ItemsNeeded)
            {
                bContinue = true;
                break;
            }
        }

        if(!bContinue)
        {
            if(PlayerController(Other) != none)
                PlayerController(Other).ClientMessage("You have no" @ default.ItemsNeeded.static.GetInvItemName(Other));
            return false;
        }

        bContinue = false;
        for(o=0;o<INVInventory.DataObject.Items.Length;o++)
        {
            if(INVInventory.DataObject.Items[o] == default.RefinedItemClass)
            {
                bContinue = true;
                break;
            }
        }

        if(!bContinue && INVInventory.DataObject.Items.Length >= INVInventory.DataObject.Slots)
        {
            if(PlayerController(Other) != none)
                PlayerController(Other).ClientMessage(INVInventory.NoMoreSlots);
            return false;
        }

        Amount = Min(INVInventory.DataObject.ItemsAmount[i], default.AmountOfItemNeeded);
        FinalAmount = Amount - (Amount * (Frand()*default.LooseChance));
        myActivateMessage(Other, Amount, FinalAmount);
        INVInventory.ChangeItem(default.ItemsNeeded, -Amount);

        if(bContinue)
        {
            INVInventory.DataObject.ItemsAmount[o] += FinalAmount;
            INVInventory.ReplicateToClientSide(o, default.RefinedItemClass, INVInventory.DataObject.ItemsAmount[o]);
        }
        else
        {
            INVInventory.DataObject.Items[INVInventory.DataObject.Items.Length] = default.RefinedItemClass;
            INVInventory.DataObject.ItemsAmount[INVInventory.DataObject.ItemsAmount.Length] = FinalAmount;
            INVInventory.ClientAddNewItem(default.RefinedItemClass, FinalAmount);
        }
        if(INVInventory.DataObject.CurrentMission != none)
            INVInventory.DataObject.CurrentMission.static.PickedUpItem(Other, default.RefinedItemClass, FinalAmount, "refineditem");
        INVInventory.DataObject.CreateDataStruct(INVInventory.DataRep, false, true);
        INVInventory.ClientInventoryUpdateGUI();
        return true;
	}
    return false;
}

static simulated function string GetDescription(Controller Other)
{
    if(Other != none)
    {
        return (default.Description @ "||This refiner can convert a maximum of" @ default.AmountOfItemNeeded
             @ default.RefinedItemClass.static.GetInvItemName(Other) @ "to" @ default.AmountOfItemNeeded
             @ default.ItemsNeeded.static.GetInvItemName(Other) @ "with a a maximum of"
             @ (default.LooseChance*100) $ "% of the" @ default.AmountOfItemNeeded @ "lost." $ "||"
             $ "You need to have atleast level" @ default.RequiredSkillLevel @ "in refining to use this item.");
    }
    return default.Description;
}

defaultproperties
{
     ItemsNeeded=Class'sonicRPG45.TarydiumCrystal'
     AmountOfItemNeeded=100
     Image=Texture'SonicRPGTEX46.Inventory.Refiner1'
     Description="This item can convert Tarydium Crystals into Tarydium goop which is used to make items. NOTE: some crystals may be lost in the process."
     ItemName="Tarydium Refiner"
     RequiredSkillLevel=1
     RequiredSkillNum=1
     ShopAmount=1
}
