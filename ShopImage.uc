class ShopImage extends InvImages;

function InternalOnClick(GUIContextMenu Sender, int Index)
{
    local Inventory Inv;
    local PlayerController C;

    C = MenuOwner.PlayerOwner();
    if(Sender != none && ExternalItemCopy != none && C != None)
    {
        if(C.Pawn != none)
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

        if(INVInventory != none)
        {
            switch (Index)
            {
                case 0:
                    ExternalItemCopy.static.ShopClick(C, DataRepNum, 1);
                    break;
                case 1:
                    ExternalItemCopy.Static.ShopClick(C, DataRepNum, 5);
                    break;
                case 2:
                    INVInventory.XItemNum = DataRepNum;
                    INVInventory.bSellAmount = false;
                    if(!INVInventory.bAmountOpen)
                        C.ClientOpenMenu("SonicRPG45.AmountGUI");
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
}

defaultproperties
{
     Begin Object Class=GUIContextMenu Name=RCMenu
         ContextItems(0)="Buy 1 Item"
         ContextItems(1)="Buy 5 Items"
         ContextItems(2)="Buy x Items"
         ContextItems(3)="Information"
         OnSelect=ShopImage.InternalOnClick
     End Object
     ContextMenu=GUIContextMenu'sonicRPG45.ShopImage.RCMenu'

}
