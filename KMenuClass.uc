class KMenuClass extends Interactions
    config(INVInventory);

struct ItemPosStruct
{
    var float XTL, YTL, XH, YH;
    var string ImageTag;
    var Material BGImage;
};
var Material EmptySlotImage, BGMaterial;
var color DefaultColor;
var protected bool bDragging;
var protected float DragStartLocX, DragStartLocY, WindowLocH, WindowLocW;
var protected config float WindowLocX, WindowLocY;

function bool KeyEvent(InventoryInteraction InteractionOwner, EInputKey Key, EInputAction Action, float Delta)
{
    local string TouchingImage;

    if(Key == IK_LeftMouse)
    {
        if(bDragging)
        {
            bDragging = false;
            SaveConfig();
            return true;
        }
        TouchingImage = InteractionOwner.bTouchingImage();
        if(TouchingImage ~= "Background")
        {
            DragStartLocX = InteractionOwner.ViewportOwner.WindowsMouseX - InteractionOwner.ClipX*WindowLocX;
            DragStartLocY = InteractionOwner.ViewportOwner.WindowsMouseY - InteractionOwner.ClipY*WindowLocY;
            bDragging = true;
        }
        return true;
    }
    return false;
}

function PostRender(InventoryInteraction InteractionOwner, Canvas Canvas, INVInventory INVInventory)
{
    local color TempColor;

    if(HudCDeathMatch(InteractionOwner.ViewportOwner.Actor.myHud) != none)
    {
        TempColor = HudCDeathMatch(InteractionOwner.ViewportOwner.Actor.myHud).GetTeamColor(InteractionOwner.ViewportOwner.Actor.GetTeamNum());
        TempColor.A = 155;
        DefaultColor = TempColor;
    }
    else DefaultColor = default.DefaultColor;
    if(BGMaterial != none)
    {
        Canvas.SetPos(InteractionOwner.ClipX*WindowLocX, InteractionOwner.ClipY*WindowLocY);
        Canvas.DrawColor = DefaultColor;
        Canvas.DrawRect(Texture(BGMaterial), InteractionOwner.ClipX*WindowLocW, InteractionOwner.ClipY*WindowLocH);
    }
    if(bDragging || InteractionOwner.bTouchingImage() ~= "Background")
    {
        if(bDragging)
        {
            WindowLocX = (InteractionOwner.ViewportOwner.WindowsMouseX - DragStartLocX)/Canvas.ClipX;
            WindowLocY = (InteractionOwner.ViewportOwner.WindowsMouseY - DragStartLocY)/Canvas.ClipY;
        }
        InteractionOwner.ViewportOwner.SelectedCursor = 1;
    }
    else InteractionOwner.ViewportOwner.SelectedCursor = 0;
}

function MenuToggled(InventoryInteraction InteractionOwner, bool bOpen);

function string bTouchingImage(InventoryInteraction InteractionOwner)
{
    if(InteractionOwner.ViewportOwner.WindowsMouseX >= InteractionOwner.ClipX*WindowLocX
    && InteractionOwner.ViewportOwner.WindowsMouseX <= (InteractionOwner.ClipX*WindowLocX)+(InteractionOwner.ClipX*WindowLocW)
    && InteractionOwner.ViewportOwner.WindowsMouseY >= InteractionOwner.ClipY*WindowLocY
    && InteractionOwner.ViewportOwner.WindowsMouseY <= (InteractionOwner.ClipY*WindowLocY)+(InteractionOwner.ClipY*WindowLocH))
        return "Background";
    return "";
}

protected function SetPos(Canvas Canvas, float X, float Y)
{
	if(Canvas == none)
	    return;

    Canvas.CurX = X+(Canvas.ClipX*WindowLocX);
	Canvas.CurY = Y+(Canvas.ClipY*WindowLocY);
}

defaultproperties
{
     EmptySlotImage=Texture'2K4Menus.NewControls.ComboListDropdown'
     DefaultColor=(R=255,A=155)
     WindowLocH=0.400000
     WindowLocW=0.400000
     WindowLocX=0.500000
     WindowLocY=0.500000
}
