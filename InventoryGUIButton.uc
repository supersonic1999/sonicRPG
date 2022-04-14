class InventoryGUIButton extends GUIButton;

var InventoryGUI GUIOwner;

function OnDragEnter(GUIComponent Sender)
{
    if(Caption == "Next")
        GUIOwner.NextPge(Sender);
    else if(Caption == "Prev")
        GUIOwner.PrevPge(Sender);
}

defaultproperties
{
     bDropTarget=True
}
