class TrainingTarydiumRefinerGradeOne extends TarydiumRefinerGradeOne;

static function bool ServerLeftClick(Controller Other, int x)
{
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory != none && INVInventory.DataObject != none
    && super.ServerLeftClick(Other, x))
    {
        INVInventory.ChangeItem(default.class, -1);
        INVInventory.DataObject.Items[INVInventory.DataObject.Items.Length] = class'TrainingMetaPupaeCreator';
        INVInventory.DataObject.ItemsAmount[INVInventory.DataObject.ItemsAmount.Length] = 1;
        INVInventory.ClientAddNewItem(class'TrainingMetaPupaeCreator', 1);
        INVInventory.ClientInventoryUpdateGUI();
        return true;
    }
    return false;
}

defaultproperties
{
     LooseChance=0.000000
     RefinedItemClass=Class'sonicRPG45.TrainingLiquidTarydiumGradeOne'
     ItemsNeeded=Class'sonicRPG45.TrainingTarydiumCrystal'
     AmountOfItemNeeded=45
     ItemName="Training Tarydium Refiner Grade 1"
     RequiredSkillLevel=0
     bSellable=False
     bTradable=False
     bDeletable=False
}
