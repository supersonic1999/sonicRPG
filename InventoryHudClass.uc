class InventoryHudClass extends KMenuClass;

var Material ContextBGMat;
var array<ItemPosStruct> ItemPos, ArrowButtons;
var int IPage;
var sound NextPageSound;
var protected array<string> ContextArray;
var protected array<class<MainInventoryItem> > Items;
var protected array<int> ItemsAmount;
var protected bool bContextOpen, bContextOpened, bMouseInContext;
var protected float ContextPosY, ContextPosX, ContextBorder, ContextH, ContextW;
var protected int Limit;

protected function GetItemArray(InventoryInteraction InteractionOwner, Canvas Canvas, INVInventory INVInventory)
{
    Items.Length = INVInventory.DataRep.Items.length;
    Items = INVInventory.DataRep.Items;
    Items.Length = INVInventory.DataRep.ItemsAmount.length;
    ItemsAmount = INVInventory.DataRep.ItemsAmount;
    Limit = INVInventory.DataRep.Slots;
}

protected function GetImageContextArray(InventoryInteraction InteractionOwner, INVInventory INVInventory, int ItemNum)
{
    ContextArray = Items[ItemNum].static.GetImageContextArray(InteractionOwner.ViewportOwner.Actor, Items[ItemNum]);
}

protected function UseImageContextArray(InventoryInteraction InteractionOwner, Canvas Canvas, INVInventory INVInventory, int ContextNum, int ItemNum)
{
    Items[ItemNum].static.ImageContextClick(InteractionOwner.ViewportOwner.Actor, Items[ItemNum], ContextArray[ContextNum]);
}

protected function string GetHelpMenuString(InventoryInteraction InteractionOwner, class<MainInventoryItem> myItem)
{
    if(myItem != none)
        return myItem.static.GetInvItemName(InteractionOwner.ViewportOwner.Actor);
}

function bool KeyEvent(InventoryInteraction InteractionOwner, EInputKey Key, EInputAction Action, float Delta)
{
    local int i;
    local bool bIsValidClick;
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
        if(!bMouseInContext)
        {
            for(i=0;i<ItemPos.Length;i++)
            {
                if(IPage+i < Items.Length && Items[IPage+i] != none
                && TouchingImage ~= ItemPos[i].ImageTag)
                {
                    GetImageContextArray(InteractionOwner, class'mutInventorySystem'.static.FindINVInventory(InteractionOwner.ViewportOwner.Actor), IPage+i);
                    bContextOpen = true;
                    bContextOpened = false;
                    bIsValidClick = true;
                    InteractionOwner.bLeftClicked = false;
                    ContextPosY = InteractionOwner.ViewportOwner.WindowsMouseY;
                    ContextPosX = InteractionOwner.ViewportOwner.WindowsMouseX;
                    break;
                }
            }
        }
        if(bContextOpen && !bIsValidClick)
        {
            if(!bMouseInContext)
            {
                bContextOpen = false;
                bContextOpened = false;
                ContextArray.Length = 0;
            }
            return true;
        }
        else if(IPage-ItemPos.Length >= 0 && TouchingImage ~= "LeftScroll")
        {
            IPage -= ItemPos.Length;
            InteractionOwner.ViewportOwner.Actor.ClientPlaySound(NextPageSound,true,2);
        }
        else if(IPage+ItemPos.Length < Limit && TouchingImage ~= "RightScroll")
        {
            IPage += ItemPos.Length;
            InteractionOwner.ViewportOwner.Actor.ClientPlaySound(NextPageSound,true,2);
        }
    }
    return super.KeyEvent(InteractionOwner, Key, Action, Delta);
}

function string bTouchingImage(InventoryInteraction InteractionOwner)
{
    local int i;

    if(InteractionOwner == none || InteractionOwner.ViewportOwner == none)
        return "";

    if(bContextOpened)
    {
        for(i=0;i<ItemPos.Length;i++)
        {
            if(InteractionOwner.ViewportOwner.WindowsMouseX >= ContextPosX-InteractionOwner.ClipX*(ContextBorder/2)
            && InteractionOwner.ViewportOwner.WindowsMouseX <= (ContextPosX-InteractionOwner.ClipX*(ContextBorder/2))+ContextW
            && InteractionOwner.ViewportOwner.WindowsMouseY >= ContextPosY-InteractionOwner.ClipY*(ContextBorder/2)
            && InteractionOwner.ViewportOwner.WindowsMouseY <= (ContextPosY-InteractionOwner.ClipY*(ContextBorder/2))+ContextH)
                return "ContextMenu";
        }
    }
    for(i=0;i<ArrowButtons.Length;i++)
    {
        if(InteractionOwner.ViewportOwner.WindowsMouseX >= (InteractionOwner.ClipX*ArrowButtons[i].XTL)+(InteractionOwner.ClipX*WindowLocX)
        && InteractionOwner.ViewportOwner.WindowsMouseX <= (InteractionOwner.ClipX*(ArrowButtons[i].XTL+ArrowButtons[i].XH))+(InteractionOwner.ClipX*WindowLocX)
        && InteractionOwner.ViewportOwner.WindowsMouseY >= (InteractionOwner.ClipY*ArrowButtons[i].YTL)+(InteractionOwner.ClipY*WindowLocY)
        && InteractionOwner.ViewportOwner.WindowsMouseY <= (InteractionOwner.ClipY*(ArrowButtons[i].YTL+ArrowButtons[i].YH))+(InteractionOwner.ClipY*WindowLocY))
            return ArrowButtons[i].ImageTag;
    }
    for(i=0;i<ItemPos.Length;i++)
    {
        if(InteractionOwner.ViewportOwner.WindowsMouseX >= (InteractionOwner.ClipX*ItemPos[i].XTL)+(InteractionOwner.ClipX*WindowLocX)
        && InteractionOwner.ViewportOwner.WindowsMouseX <= (InteractionOwner.ClipX*(ItemPos[i].XTL+ItemPos[i].XH))+(InteractionOwner.ClipX*WindowLocX)
        && InteractionOwner.ViewportOwner.WindowsMouseY >= (InteractionOwner.ClipY*ItemPos[i].YTL)+(InteractionOwner.ClipY*WindowLocY)
        && InteractionOwner.ViewportOwner.WindowsMouseY <= (InteractionOwner.ClipY*(ItemPos[i].YTL+ItemPos[i].YH))+(InteractionOwner.ClipY*WindowLocY))
            return ItemPos[i].ImageTag;
    }
    return super.bTouchingImage(InteractionOwner);
}

function PostRender(InventoryInteraction InteractionOwner, Canvas Canvas, INVInventory INVInventory)
{
    super.PostRender(InteractionOwner, Canvas, INVInventory);
    GetItemArray(InteractionOwner, Canvas, INVInventory);
    DrawMainGUI(InteractionOwner, Canvas, INVInventory);
    bMouseInContext = false;
    if(bContextOpen)
        DrawContextMenu(InteractionOwner, Canvas, INVInventory);
}

protected function DrawMainGUI(InventoryInteraction InteractionOwner, Canvas Canvas, INVInventory INVInventory)
{
    local int i;
    local string HelpString;
    local float XL, YL;

    for(i=0;i<ItemPos.Length;i++)
    {
        Canvas.DrawColor = DefaultColor;
        SetPos(Canvas, Canvas.ClipX*ItemPos[i].XTL, Canvas.ClipY*ItemPos[i].YTL);
        Canvas.DrawTileStretched(Texture(EmptySlotImage), Canvas.ClipX*ItemPos[i].XH, Canvas.ClipY*ItemPos[i].YH);
        Canvas.SetDrawColor(255,255,255);
        if(IPage+i < Items.Length && Items[IPage+i] != none)
        {
            Items[IPage+i].static.DrawImage(InteractionOwner.ViewportOwner.Actor, Canvas,
                                            (Canvas.ClipY*ItemPos[i].YTL)+(Canvas.ClipY*WindowLocY),
                                            (Canvas.ClipX*ItemPos[i].XTL)+(Canvas.ClipX*WindowLocX),
                                            Canvas.ClipY*ItemPos[i].YH, Canvas.ClipX*ItemPos[i].XH);
            Canvas.SetPos((Canvas.ClipX*ItemPos[i].XTL)+(Canvas.ClipX*WindowLocX), (Canvas.ClipY*ItemPos[i].YTL)+(Canvas.ClipY*WindowLocY));
            if(ItemsAmount[IPage+i] >= 1000)
                Canvas.DrawText(int(ItemsAmount[IPage+i]/1000.0)$"K");
            else
                Canvas.DrawText(ItemsAmount[IPage+i]);
        }
    }
    SetPos(Canvas, Canvas.ClipX*ArrowButtons[0].XTL, Canvas.ClipY*ArrowButtons[0].YTL);
    if(IPage-ItemPos.Length < 0)
        Canvas.SetDrawColor(0,0,0,155);
    else Canvas.DrawColor = DefaultColor;
    Canvas.DrawRect(Texture(ArrowButtons[0].BGImage), Canvas.ClipX*ArrowButtons[0].XH, Canvas.ClipY*ArrowButtons[0].YH);
    SetPos(Canvas, Canvas.ClipX*ArrowButtons[1].XTL, Canvas.ClipY*ArrowButtons[1].YTL);
    if(IPage+ItemPos.Length >= Limit)
        Canvas.SetDrawColor(0,0,0,155);
    else Canvas.DrawColor = DefaultColor;
    Canvas.DrawRect(Texture(ArrowButtons[1].BGImage), Canvas.ClipX*ArrowButtons[1].XH, Canvas.ClipY*ArrowButtons[1].YH);
    for(i=0;i<ItemPos.Length;i++)
    {
        if(IPage+i < Items.Length && Items[IPage+i] != none
        && bTouchingImage(InteractionOwner) ~= ItemPos[i].ImageTag)
        {
            HelpString = GetHelpMenuString(InteractionOwner, Items[IPage+i]);
            Canvas.DrawColor = DefaultColor;
            Canvas.TextSize(HelpString, XL, YL);
            Canvas.SetPos(InteractionOwner.ViewportOwner.WindowsMouseX+8, InteractionOwner.ViewportOwner.WindowsMouseY+8);
            Canvas.DrawTileStretched(Texture(ContextBGMat), XL+4, YL+4);
            Canvas.SetDrawColor(255,255,255);
            Canvas.SetPos(InteractionOwner.ViewportOwner.WindowsMouseX+12, InteractionOwner.ViewportOwner.WindowsMouseY+12);
            Canvas.DrawTextClipped(HelpString);
        }
    }
}

protected function DrawContextMenu(InventoryInteraction InteractionOwner, Canvas Canvas, INVInventory INVInventory)
{
    local int i, x;
    local color NoAlphaColor;
    local float LastTextPos, XL, YL;

    NoAlphaColor = DefaultColor;
    NoAlphaColor.A = 255;
    Canvas.DrawColor = NoAlphaColor;
    ContextH = 0;
    ContextW = 0;
    for(i=0;i<ContextArray.Length;i++)
    {
        Canvas.TextSize(ContextArray[i], XL, YL);
        ContextH += YL;
        if(XL > ContextW)
            ContextW = XL;
    }
    ContextH += Canvas.ClipY*ContextBorder;
    ContextW += Canvas.ClipX*ContextBorder;
    Canvas.SetPos(ContextPosX-Canvas.ClipX*(ContextBorder/2), ContextPosY-Canvas.ClipY*(ContextBorder/2));
    Canvas.DrawTileStretched(Texture(ContextBGMat), ContextW, ContextH);
    if(InteractionOwner.ViewportOwner.WindowsMouseX >= ContextPosX-Canvas.ClipX*(ContextBorder/2)
    && InteractionOwner.ViewportOwner.WindowsMouseX <= (ContextPosX-Canvas.ClipX*(ContextBorder/2))+ContextW
    && InteractionOwner.ViewportOwner.WindowsMouseY >= ContextPosY-Canvas.ClipY*(ContextBorder/2)
    && InteractionOwner.ViewportOwner.WindowsMouseY <= (ContextPosY-Canvas.ClipY*(ContextBorder/2))+ContextH)
        bMouseInContext = true;
    for(i=0;i<ContextArray.Length;i++)
    {
        Canvas.DrawColor = InteractionOwner.WhiteColor;
        Canvas.TextSize(ContextArray[i], XL, YL);
        if(InteractionOwner.ViewportOwner.WindowsMouseX >= ContextPosX
        && InteractionOwner.ViewportOwner.WindowsMouseX <= ContextPosX+XL
        && InteractionOwner.ViewportOwner.WindowsMouseY >= ContextPosY+LastTextPos
        && InteractionOwner.ViewportOwner.WindowsMouseY <= ContextPosY+LastTextPos+YL)
        {
            Canvas.DrawColor = class'InventoryInteraction'.default.YellowColor;
            if(bContextOpened && InteractionOwner.bLeftClicked)
            {
                for(x=0;x<ItemPos.Length;x++)
                {
                    if(IPage+x < Items.Length && Items[IPage+x] != none
                    && ContextPosX >= (InteractionOwner.ClipX*ItemPos[x].XTL)+(InteractionOwner.ClipX*WindowLocX)
                    && ContextPosX <= (InteractionOwner.ClipX*(ItemPos[x].XTL+ItemPos[x].XH))+(InteractionOwner.ClipX*WindowLocX)
                    && ContextPosY >= (InteractionOwner.ClipY*ItemPos[x].YTL)+(InteractionOwner.ClipY*WindowLocY)
                    && ContextPosY <= (InteractionOwner.ClipY*(ItemPos[x].YTL+ItemPos[x].YH))+(InteractionOwner.ClipY*WindowLocY))
                    {
                        UseImageContextArray(InteractionOwner, Canvas, INVInventory, i, IPage+x);
                        bContextOpen = false;
                        bContextOpened = false;
                        return;
                    }
                }
            }
        }
        Canvas.SetPos(ContextPosX, ContextPosY+LastTextPos);
        Canvas.DrawText(ContextArray[i]);
        LastTextPos += YL;
    }
    bContextOpened = true;
}

function MenuToggled(InventoryInteraction InteractionOwner, bool bOpen)
{
    if(!bOpen)
    {
        bContextOpen = false;
        bContextOpened = false;
        bDragging = false;
        SaveConfig();
    }
}

defaultproperties
{
     ContextBGMat=Texture'2K4Menus.Controls.thinpipe_b'
     ItemPos(0)=(XTL=0.050000,XH=0.100000,YH=0.100000,ImageTag="1")
     ItemPos(1)=(XTL=0.160000,XH=0.100000,YH=0.100000,ImageTag="2")
     ItemPos(2)=(XTL=0.270000,XH=0.100000,YH=0.100000,ImageTag="3")
     ItemPos(3)=(XTL=0.050000,YTL=0.110000,XH=0.100000,YH=0.100000,ImageTag="4")
     ItemPos(4)=(XTL=0.160000,YTL=0.110000,XH=0.100000,YH=0.100000,ImageTag="5")
     ItemPos(5)=(XTL=0.270000,YTL=0.110000,XH=0.100000,YH=0.100000,ImageTag="6")
     ArrowButtons(0)=(YTL=0.060000,XH=0.050000,YH=0.100000,ImageTag="LeftScroll",BGImage=Texture'2K4Menus.NewControls.LeftMark')
     ArrowButtons(1)=(XTL=0.370000,YTL=0.060000,XH=0.050000,YH=0.100000,ImageTag="RightScroll",BGImage=Texture'2K4Menus.NewControls.RightMark')
     NextPageSound=Sound'2K4MenuSounds.Generic.msfxUp'
     ContextBorder=0.040000
     WindowLocH=0.220000
     WindowLocW=0.420000
     WindowLocX=0.290000
     WindowLocY=0.090000
}
