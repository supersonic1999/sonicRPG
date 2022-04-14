class InvImages extends GUIImage;

//var protected class<MainInventoryItem> Item;
var class<MainInventoryItem> ExternalItemCopy;
var bool bRightClick;
var int DataRepNum;
var INVInventory INVInventory;

//simulated function SetItem(class<MainInventoryItem> myItem)
//{
//    local int i;
//
//    if(myItem == none)
//    {
//        Item = none;
//        ExternalItemCopy = none;
//        return;
//    }
//
//    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());
//    if(INVInventory == none)
//        return;
//
//    for(i=0;i<INVInventory.DataRep.Items.Length;i++)
//    {
//        if(INVInventory.DataRep.Items[i] == myItem)
//        {
//            Item = myItem;
//            ExternalItemCopy = myItem;
//            break;
//        }
//    }
//}

defaultproperties
{
     ImageStyle=ISTY_Stretched
     ImageRenderStyle=MSTY_Normal
     WinWidth=0.250000
     WinHeight=0.250000
     bBoundToParent=True
     bScaleToParent=True
     bAcceptsInput=True
     bCaptureMouse=True
     bNeverFocus=True
     Begin Object Class=GUIToolTip Name=GUIButtonToolTip
     End Object
     ToolTip=GUIToolTip'sonicRPG45.InvImages.GUIButtonToolTip'

     OnClickSound=CS_Click
}
