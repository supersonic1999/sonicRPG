class ShopHudClass extends InventoryHudClass;

protected function GetItemArray(InventoryInteraction InteractionOwner, Canvas Canvas, INVInventory INVInventory)
{
    local int i;

    Items.length = INVInventory.MutINV.BuyableItems.length;
    ItemsAmount.length = INVInventory.MutINV.BuyableItems.length;
    for(i=0;i<INVInventory.MutINV.BuyableItems.length;i++)
    {
        Items[i] = INVInventory.MutINV.BuyableItems[i].ItemClass;
        ItemsAmount[i] = INVInventory.MutINV.BuyableItems[i].Amount;
    }
    Limit = INVInventory.MutINV.BuyableItems.Length;
}

protected function GetImageContextArray(InventoryInteraction InteractionOwner, INVInventory INVInventory, int ItemNum)
{
    ContextArray.length = 4;
    ContextArray[0] = "Buy 1 Item";
    ContextArray[1] = "Buy 5 Item";
    ContextArray[2] = "Buy x Item";
    ContextArray[3] = "Information";
}

protected function UseImageContextArray(InventoryInteraction InteractionOwner, Canvas Canvas, INVInventory INVInventory, int ContextNum, int ItemNum)
{
    if(ContextNum == 0)
        Items[ItemNum].static.ShopClick(InteractionOwner.ViewportOwner.Actor, ItemNum, 1);
    else if(ContextNum == 1)
        Items[ItemNum].Static.ShopClick(InteractionOwner.ViewportOwner.Actor, ItemNum, 5);
    else if(ContextNum == 2)
    {
        INVInventory.XItemNum = ItemNum;
        INVInventory.bSellAmount = false;
        if(!INVInventory.bAmountOpen)
            InteractionOwner.ViewportOwner.Actor.ClientOpenMenu("SonicRPG45.AmountGUI");
    }
    else if(ContextNum == 3)
    {
        INVInventory.InfoClass = Items[ItemNum];
        if(!INVInventory.bInformationOpen)
            InteractionOwner.ViewportOwner.Actor.ClientOpenMenu("SonicRPG45.InformationGUI");
        else if(INVInventory.Information != none)
            INVInventory.Information.OnOpen();
    }
}

protected function string GetHelpMenuString(InventoryInteraction InteractionOwner, class<MainInventoryItem> myItem)
{
    if(myItem != none)
        return myItem.static.GetInvItemName(InteractionOwner.ViewportOwner.Actor)$", Cost:"$int(abs(myItem.static.GetBuyPrice(InteractionOwner.ViewportOwner.Actor)));
}

defaultproperties
{
     ItemPos(0)=(XTL=0.000000,XH=0.060000,YH=0.060000)
     ItemPos(1)=(XTL=0.070000,XH=0.060000,YH=0.060000)
     ItemPos(2)=(XTL=0.140000,XH=0.060000,YH=0.060000)
     ItemPos(3)=(XTL=0.000000,YTL=0.070000,XH=0.060000,YH=0.060000)
     ItemPos(4)=(XTL=0.070000,YTL=0.070000,XH=0.060000,YH=0.060000)
     ItemPos(5)=(XTL=0.140000,YTL=0.070000,XH=0.060000,YH=0.060000)
     ItemPos(6)=(YTL=0.140000,XH=0.060000,YH=0.060000,ImageTag="7")
     ItemPos(7)=(XTL=0.070000,YTL=0.140000,XH=0.060000,YH=0.060000,ImageTag="8")
     ItemPos(8)=(XTL=0.140000,YTL=0.140000,XH=0.060000,YH=0.060000,ImageTag="9")
     ItemPos(9)=(YTL=0.210000,XH=0.060000,YH=0.060000,ImageTag="10")
     ItemPos(10)=(XTL=0.070000,YTL=0.210000,XH=0.060000,YH=0.060000,ImageTag="11")
     ItemPos(11)=(XTL=0.140000,YTL=0.210000,XH=0.060000,YH=0.060000,ImageTag="12")
     ItemPos(12)=(YTL=0.280000,XH=0.060000,YH=0.060000,ImageTag="13")
     ItemPos(13)=(XTL=0.070000,YTL=0.280000,XH=0.060000,YH=0.060000,ImageTag="14")
     ItemPos(14)=(XTL=0.140000,YTL=0.280000,XH=0.060000,YH=0.060000,ImageTag="15")
     ItemPos(15)=(YTL=0.350000,XH=0.060000,YH=0.060000,ImageTag="16")
     ItemPos(16)=(XTL=0.070000,YTL=0.350000,XH=0.060000,YH=0.060000,ImageTag="17")
     ItemPos(17)=(XTL=0.140000,YTL=0.350000,XH=0.060000,YH=0.060000,ImageTag="18")
     ArrowButtons(0)=(XTL=0.050000,YTL=0.420000)
     ArrowButtons(1)=(XTL=0.100000,YTL=0.420000)
     WindowLocH=0.520000
     WindowLocW=0.200000
     WindowLocX=0.700000
     WindowLocY=0.050000
}
