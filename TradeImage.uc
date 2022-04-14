//------------------------------------------------------------------------------
//Bottom left trade images
//------------------------------------------------------------------------------
class TradeImage extends InvImages;

function InternalOnClick(GUIContextMenu Sender, int Index)
{
    local Inventory Inv;
    local PlayerController C;

    C = MenuOwner.PlayerOwner();
    if(Sender != none && ExternalItemCopy != none && C != None)
    {
        INVInventory = INVInventory(C.Pawn.FindInventoryType(class'INVInventory'));
        if(C != none && INVInventory == none)
    	{
            for(Inv = C.Inventory; Inv != None; Inv = Inv.Inventory)
        	{
        		INVInventory = INVInventory(Inv);
        		if(INVInventory != None)
        			break;
        	}
    	}

        switch(Index)
        {
            case 0:
                if(!INVInventory.DataRep.Items[DataRepNum].default.bTradable)
                {
                    if(C != none)
                        C.ClientMessage(INVInventory.ItemUntradable);
                    break;
                }
                INVInventory.ClientChangeTradedItems(INVInventory.DataRep.Items[DataRepNum], 1);
                INVInventory.TradeReplicationInfo.CurTrader.myINVInventory.ClientSetbAcceptedTrade(false);
                INVInventory.TradeReplicationInfo.CurTrader.myINVInventory.ClientbUpdateImages(True);
                INVInventory.Trade.UpdateImages();
                break;
            case 1:
                if(!INVInventory.DataRep.Items[DataRepNum].default.bTradable)
                {
                    if(C != none)
                        C.ClientMessage(INVInventory.ItemUntradable);
                    break;
                }
                INVInventory.ClientChangeTradedItems(INVInventory.DataRep.Items[DataRepNum], 5);
                INVInventory.TradeReplicationInfo.CurTrader.myINVInventory.ClientSetbAcceptedTrade(false);
                INVInventory.TradeReplicationInfo.CurTrader.myINVInventory.ClientbUpdateImages(True);
                INVInventory.Trade.UpdateImages();
                break;
            case 2:
                if(!INVInventory.DataRep.Items[DataRepNum].default.bTradable)
                {
                    if(C != none)
                        C.ClientMessage(INVInventory.ItemUntradable);
                    break;
                }
                INVInventory.XItemNum = DataRepNum;
                if(!INVInventory.bAmountOpen)
                    C.ClientOpenMenu("SonicRPG45.TradeAmountGUI");
                break;
            case 3:
                INVInventory.InfoClass = ExternalItemCopy;
                if(!INVInventory.bInformationOpen)
                    C.ClientOpenMenu("SonicRPG45.InformationGUI");
                else if(INVInventory.Information != none)
                    INVInventory.Information.OnOpen();
                break;
        }
    }
}

function int FindTradedItemAmount()
{
    local int i;
    local Inventory Inv;
    local PlayerController C;

    C = MenuOwner.PlayerOwner();
    INVInventory = INVInventory(C.Pawn.FindInventoryType(class'INVInventory'));
    if(C != none && INVInventory == none)
	{
        for(Inv = C.Inventory; Inv != None; Inv = Inv.Inventory)
    	{
    		INVInventory = INVInventory(Inv);
    		if(INVInventory != None)
    			break;
    	}
	}

    for(i=0;i<INVInventory.TradeReplicationInfo.TradedItems.length;i++)
        if(INVInventory.TradeReplicationInfo.TradedItems[i].Items == ExternalItemCopy)
            return INVInventory.TradeReplicationInfo.TradedItems[i].Amount;
    return 0;
}

defaultproperties
{
     WinWidth=0.125000
     WinHeight=0.125000
     Begin Object Class=GUIContextMenu Name=RCMenu
         ContextItems(0)="Trade 1"
         ContextItems(1)="Trade 5"
         ContextItems(2)="Trade x"
         ContextItems(3)="Information"
         OnSelect=TradeImage.InternalOnClick
     End Object
     ContextMenu=GUIContextMenu'sonicRPG45.TradeImage.RCMenu'

}
