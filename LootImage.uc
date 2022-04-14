class LootImage extends InvImages;

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

        switch(Index)
        {
            case 0:
                INVInventory.TakeLootedItem(INVInventory.LootedItems[DataRepNum]);
                break;
            case 1:
                INVInventory.DeleteNum = DataRepNum;
                INVInventory.RemoveInventoryItem = false;
                if(!INVInventory.bDeleteOpen)
                    C.ClientOpenMenu("SonicRPG45.DeleteGUI");
                break;
            case 2:
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
     Begin Object Class=GUIContextMenu Name=RCMenu
         ContextItems(0)="Add to inventory"
         ContextItems(1)="Remove"
         ContextItems(2)="Information"
         OnSelect=LootImage.InternalOnClick
     End Object
     ContextMenu=GUIContextMenu'sonicRPG45.LootImage.RCMenu'

}
