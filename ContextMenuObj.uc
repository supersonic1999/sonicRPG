class ContextMenuObj extends Actor;

var bool bContextOpen;
var protected float ContextPosY, ContextPosX, ContextH, ContextW;
var protected array<string> ContextString;

function DrawContextMenu(float X, float Y, float H, float W, float Border, array<string> ContextString,
                         InventoryInteraction InteractionOwner, Canvas Canvas, INVInventory INVInventory)
{
    ContextPosX = X;
    ContextPosY = Y;
    ContextH = H;
    ContextW = W;
    ContextString = ContextString;
}

function string bTouchingImage(InventoryInteraction InteractionOwner)
{
    local int i;

    for(i=0;i<ContextString.Length;i++)
    {
        if(InteractionOwner.ViewportOwner.WindowsMouseX >= ContextPosX
        && InteractionOwner.ViewportOwner.WindowsMouseX <= ContextPosX+ContextW
        && InteractionOwner.ViewportOwner.WindowsMouseY >= ContextPosY
        && InteractionOwner.ViewportOwner.WindowsMouseY <= ContextPosY+ContextH)
            return ContextString[i];
    }
    return "";
}

defaultproperties
{
}
