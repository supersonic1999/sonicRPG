class LootHudClass extends InventoryHudClass;

protected function GetItemArray(InventoryInteraction InteractionOwner, Canvas Canvas, INVInventory INVInventory)
{
    Items.Length = INVInventory.LootedItems.length;
    Items = INVInventory.LootedItems;
    ItemsAmount.Length = INVInventory.LootedItemsAmount.length;
    ItemsAmount = INVInventory.LootedItemsAmount;
    Limit = INVInventory.LootedItems.length;
}

protected function GetImageContextArray(InventoryInteraction InteractionOwner, INVInventory INVInventory, int ItemNum)
{
    ContextArray.length = 3;
    ContextArray[0] = "Add to inventory";
    ContextArray[1] = "Remove";
    ContextArray[2] = "Information";
}

protected function UseImageContextArray(InventoryInteraction InteractionOwner, Canvas Canvas, INVInventory INVInventory, int ContextNum, int ItemNum)
{
    if(ContextNum == 0)
        INVInventory.TakeLootedItem(Items[ItemNum]);
    else if(ContextNum == 1)
    {
        INVInventory.DeleteNum = ItemNum;
        INVInventory.RemoveInventoryItem = false;
        if(!INVInventory.bDeleteOpen)
            InteractionOwner.ViewportOwner.GUIController.OpenMenu("SonicRPG45.DeleteGUI");
    }
    else if(ContextNum == 2)
    {
        INVInventory.InfoClass = Items[ItemNum];
        if(!INVInventory.bInformationOpen)
            InteractionOwner.ViewportOwner.GUIController.OpenMenu("SonicRPG45.InformationGUI");
        else if(INVInventory.Information != none)
            INVInventory.Information.OnOpen();
    }
}

defaultproperties
{
     ItemPos(0)=(XH=0.050000,YH=0.050000)
     ItemPos(1)=(XTL=0.110000,XH=0.050000,YH=0.050000)
     ItemPos(2)=(XTL=0.170000,XH=0.050000,YH=0.050000)
     ItemPos(3)=(YTL=0.060000,XH=0.050000,YH=0.050000)
     ItemPos(4)=(XTL=0.110000,YTL=0.060000,XH=0.050000,YH=0.050000)
     ItemPos(5)=(XTL=0.170000,YTL=0.060000,XH=0.050000,YH=0.050000)
     ItemPos(6)=(XTL=0.050000,YTL=0.120000,XH=0.050000,YH=0.050000,ImageTag="7")
     ItemPos(7)=(XTL=0.110000,YTL=0.120000,XH=0.050000,YH=0.050000,ImageTag="8")
     ItemPos(8)=(XTL=0.170000,YTL=0.120000,XH=0.050000,YH=0.050000,ImageTag="9")
     ArrowButtons(0)=(YTL=0.032500)
     ArrowButtons(1)=(XTL=0.220000,YTL=0.032500)
     WindowLocW=0.270000
     WindowLocX=0.000000
     WindowLocY=0.200000
}
