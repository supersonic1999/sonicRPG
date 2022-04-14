class InventoryImage extends InvImages;

event Opened(GUIComponent Sender)
{
    ContextMenu.OnOpen = OnOpen;
}

function bool OnOpen(GUIContextMenu Sender)
{
    local int i;
    local array<string> CArray;

    CArray = ExternalItemCopy.static.GetImageContextArray(MenuOwner.PlayerOwner(), ExternalItemCopy);
    if(ContextMenu == none || CArray.Length <= 0)
        return false;

    ContextMenu.ContextItems.length = CArray.Length;
    for(i=0;i<CArray.length;i++)
        ContextMenu.ContextItems[i] = CArray[i];
    return true;
}

function InternalOnClick(GUIContextMenu Sender, int Index)
{
    if(ExternalItemCopy != none)
        ExternalItemCopy.static.ImageContextClick(MenuOwner.PlayerOwner(), ExternalItemCopy, ContextMenu.ContextItems[Index]);
}

function OnEndDrag(GUIComponent Sender, bool bAccepted)
{
    local Inventory Inv;
    local PlayerController C;

    C = MenuOwner.PlayerOwner();
    if(C != none && C.Pawn != none)
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

    if(INVInventory != none && InvImages(Sender) != None)
        INVInventory.SwapItems(INVInventory.DataRep.Items[InvImages(Sender).DataRepNum], INVInventory.DataRep.Items[INVInventory.DragStartNum]);
}

defaultproperties
{
     Begin Object Class=GUIContextMenu Name=RCMenu
         OnSelect=InventoryImage.InternalOnClick
     End Object
     ContextMenu=GUIContextMenu'sonicRPG45.InventoryImage.RCMenu'

}
