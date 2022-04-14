//------------------------------------------------------------------------------
//Top left trade images
//------------------------------------------------------------------------------
class TradeMainImage extends InvImages;

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
                INVInventory.ClientChangeTradedItems(ExternalItemCopy, -1);
                INVInventory.TradeReplicationInfo.CurTrader.myINVInventory.ClientSetbAcceptedTrade(false);
                INVInventory.TradeReplicationInfo.CurTrader.myINVInventory.ClientbUpdateImages(True);
                INVInventory.Trade.UpdateImages();
                break;
            case 1:
                INVInventory.ClientChangeTradedItems(ExternalItemCopy, -5);
                INVInventory.TradeReplicationInfo.CurTrader.myINVInventory.ClientSetbAcceptedTrade(false);
                INVInventory.TradeReplicationInfo.CurTrader.myINVInventory.ClientbUpdateImages(True);
                INVInventory.Trade.UpdateImages();
                break;
            case 2:
                if(!INVInventory.bAmountOpen)
                {
                    INVInventory.XItemNum = DataRepNum;
                    C.ClientOpenMenu("SonicRPG45.TradeSellAmountGUI");
                }
                INVInventory.Trade.UpdateImages();
                INVInventory.TradeReplicationInfo.CurTrader.myINVInventory.Trade.UpdateImages();
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

defaultproperties
{
     WinWidth=0.125000
     WinHeight=0.125000
     Begin Object Class=GUIContextMenu Name=RCMenu
         ContextItems(0)="Remove 1"
         ContextItems(1)="Remove 5"
         ContextItems(2)="Remove x"
         ContextItems(3)="Information"
         OnSelect=TradeMainImage.InternalOnClick
     End Object
     ContextMenu=GUIContextMenu'sonicRPG45.TradeMainImage.RCMenu'

}
