class MissionHudClass extends KMenuClass;

var class<MissionFile> DefaultMission;
var sound NextPageSound;
var Material ScrollBlury, ScrollPressed, ScrollWatched, ContextBGMat;
var protected array<ItemPosStruct> ItemPos;
var protected array<string> ContextArray;
var protected array<class<MissionFile> > AvailableMissions;
var protected bool bContextOpen, bContextOpened, bMouseInContext;
var protected float ContextPosY, ContextPosX, ContextBorder, ScrollBarLocation, ItemLengthY[5], ItemLengthX[5], ContextW, ContextH;
var protected byte PItemNum, ContextNum;

function PostRender(InventoryInteraction InteractionOwner, Canvas Canvas, INVInventory INVInventory)
{
    super.PostRender(InteractionOwner, Canvas, INVInventory);
    DrawMainGUI(InteractionOwner, Canvas, INVInventory);
    bMouseInContext = false;
    if(bContextOpen)
        DrawContextMenu(InteractionOwner, Canvas, INVInventory);
}

protected function DrawMainGUI(InventoryInteraction InteractionOwner, Canvas Canvas, INVInventory INVInventory)
{
    local int i, x;
    local float LastPos, XL, YL, ScrollHeight;
    local color MissionColor;

    Canvas.DrawColor = DefaultColor;
    SetPos(Canvas, Canvas.ClipX*0.025, Canvas.ClipY*0.025);
    Canvas.DrawTileStretched(Texture(EmptySlotImage), Canvas.ClipX*0.275, Canvas.ClipY*0.15);
    LastPos = 0.035;
    MissionColor = InteractionOwner.WhiteColor;
    for(i=0;i<5;i++)
    {
        if(INVInventory.DataRep.CurrentMission == AvailableMissions[i+PItemNum])
            MissionColor = class'mutInventorySystem'.default.YellowColor;
        else
        {
            for(x=0;x<INVInventory.DataRep.CompletedMissions.Length;x++)
            {
                if(INVInventory.DataRep.CompletedMissions[x] == AvailableMissions[i+PItemNum])
                {
                    MissionColor = class'mutInventorySystem'.default.GreenColor;
                    x = INVInventory.DataRep.CompletedMissions.Length;
                }
            }
            if(MissionColor == InteractionOwner.WhiteColor)
                MissionColor = class'mutInventorySystem'.default.RedColor;
        }
        Canvas.DrawColor = MissionColor;
        SetPos(Canvas, Canvas.ClipX*0.035, Canvas.ClipY*LastPos);
        Canvas.DrawText(AvailableMissions[i+PItemNum].default.MissionName);
        Canvas.TextSize(AvailableMissions[i+PItemNum].default.MissionName, XL, YL);
        ItemLengthY[i] = YL;
        ItemLengthX[i] = XL;
        MissionColor = InteractionOwner.WhiteColor;
        LastPos += YL/Canvas.ClipY;
    }
    for(i=0;i<ItemPos.length;i++)
    {
        Canvas.DrawColor = DefaultColor;
        SetPos(Canvas, Canvas.ClipX*ItemPos[i].XTL, Canvas.ClipY*ItemPos[i].YTL);
        if(i == 2)
            Canvas.DrawTileStretched(Texture(ItemPos[i].BGImage), Canvas.ClipX*ItemPos[i].XH, Canvas.ClipY*ItemPos[i].YH);
        else
            Canvas.DrawRect(Texture(ItemPos[i].BGImage), Canvas.ClipX*ItemPos[i].XH, Canvas.ClipY*ItemPos[i].YH);
    }
    ScrollHeight = fMax(0.015, (ItemPos[2].YH)/AvailableMissions.length);
    SetPos(Canvas, Canvas.ClipX*ItemPos[2].XTL, Canvas.ClipY*(ItemPos[2].YTL+(((ItemPos[2].YH+ScrollHeight)/AvailableMissions.length)*PItemNum)));
    Canvas.DrawTileStretched(Texture(ScrollBlury), Canvas.ClipX*ItemPos[2].XH, Canvas.ClipY*ScrollHeight);
}

function bool KeyEvent(InventoryInteraction InteractionOwner, EInputKey Key, EInputAction Action, float Delta)
{
    local string TouchingImage;
    local bool bIsValidClick;
    local int i;
    local float LastPos;

    if(Key == IK_MouseWheelDown && PItemNum+5 < AvailableMissions.length
    && InteractionOwner.ViewportOwner.WindowsMouseX >= InteractionOwner.ClipX*0.025+(InteractionOwner.ClipX*WindowLocX)
    && InteractionOwner.ViewportOwner.WindowsMouseX <= (InteractionOwner.ClipX*0.025)+(InteractionOwner.ClipX*WindowLocX)+InteractionOwner.ClipX*0.275
    && InteractionOwner.ViewportOwner.WindowsMouseY >= InteractionOwner.ClipY*0.025+(InteractionOwner.ClipY*WindowLocY)
    && InteractionOwner.ViewportOwner.WindowsMouseY <= (InteractionOwner.ClipY*0.025)+(InteractionOwner.ClipY*WindowLocY)+InteractionOwner.ClipY*0.15)
    {
        bContextOpen = false;
        PItemNum++;
        InteractionOwner.ViewportOwner.Actor.ClientPlaySound(NextPageSound,true,2);
        return true;
    }
    else if(Key == IK_MouseWheelUp && PItemNum >= 1
    && InteractionOwner.ViewportOwner.WindowsMouseX >= InteractionOwner.ClipX*0.025+(InteractionOwner.ClipX*WindowLocX)
    && InteractionOwner.ViewportOwner.WindowsMouseX <= (InteractionOwner.ClipX*0.025)+(InteractionOwner.ClipX*WindowLocX)+InteractionOwner.ClipX*0.275
    && InteractionOwner.ViewportOwner.WindowsMouseY >= InteractionOwner.ClipY*0.025+(InteractionOwner.ClipY*WindowLocY)
    && InteractionOwner.ViewportOwner.WindowsMouseY <= (InteractionOwner.ClipY*0.025)+(InteractionOwner.ClipY*WindowLocY)+InteractionOwner.ClipY*0.15)
    {
        PItemNum--;
        bContextOpen = false;
        InteractionOwner.ViewportOwner.Actor.ClientPlaySound(NextPageSound,true,2);
        return true;
    }
    else if(Key == IK_LeftMouse)
    {
        TouchingImage = InteractionOwner.bTouchingImage();
        if(!bMouseInContext)
        {
            LastPos = 0.035;
            for(i=0;i<5;i++)
            {
                if(InteractionOwner.ViewportOwner.WindowsMouseX >= InteractionOwner.ClipX*0.035+(InteractionOwner.ClipX*WindowLocX)
                && InteractionOwner.ViewportOwner.WindowsMouseX <= InteractionOwner.ClipX*0.035+(InteractionOwner.ClipX*WindowLocX)+ItemLengthX[i]
                && InteractionOwner.ViewportOwner.WindowsMouseY >= InteractionOwner.ClipY*LastPos+(InteractionOwner.ClipY*WindowLocY)
                && InteractionOwner.ViewportOwner.WindowsMouseY <= InteractionOwner.ClipY*LastPos+(InteractionOwner.ClipY*WindowLocY)+ItemLengthY[i])
                {
                    GetImageContextArray(InteractionOwner, class'mutInventorySystem'.static.FindINVInventory(InteractionOwner.ViewportOwner.Actor), i+PItemNum);
                    bContextOpen = true;
                    bContextOpened = false;
                    bIsValidClick = true;
                    InteractionOwner.bLeftClicked = false;
                    ContextNum = i;
                    ContextPosY = InteractionOwner.ViewportOwner.WindowsMouseY;
                    ContextPosX = InteractionOwner.ViewportOwner.WindowsMouseX;
                    break;
                }
                LastPos += ItemLengthY[i]/InteractionOwner.ClipY;
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
        else if(TouchingImage ~= "UpArrow" && PItemNum >= 1)
        {
            bContextOpen = false;
            PItemNum--;
            InteractionOwner.ViewportOwner.Actor.ClientPlaySound(NextPageSound,true,2);
            return true;
        }
        else if(TouchingImage ~= "DownArrow" && PItemNum+5 < AvailableMissions.length)
        {
            bContextOpen = false;
            PItemNum++;
            InteractionOwner.ViewportOwner.Actor.ClientPlaySound(NextPageSound,true,2);
            return true;
        }
    }
    return super.KeyEvent(InteractionOwner, Key, Action, Delta);
}

protected function GetImageContextArray(InventoryInteraction InteractionOwner, INVInventory INVInventory, int ItemNum)
{
    ContextArray = AvailableMissions[ItemNum].static.GetImageContextArray(InteractionOwner.ViewportOwner.Actor);
}

protected function UseImageContextArray(InventoryInteraction InteractionOwner, Canvas Canvas, INVInventory INVInventory, int ItemNum)
{
    AvailableMissions[ContextNum+PItemNum].static.UseImageContextArray(InteractionOwner.ViewportOwner.Actor, ContextArray[ItemNum]);
}

protected function DrawContextMenu(InventoryInteraction InteractionOwner, Canvas Canvas, INVInventory INVInventory)
{
    local int i;
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
                UseImageContextArray(InteractionOwner, Canvas, INVInventory, i);
                bContextOpen = false;
                bContextOpened = false;
                return;
            }
        }
        Canvas.SetPos(ContextPosX, ContextPosY+LastTextPos);
        Canvas.DrawText(ContextArray[i]);
        LastTextPos += YL;
    }
    bContextOpened = true;
}

function string bTouchingImage(InventoryInteraction InteractionOwner)
{
    local int i;

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
    for(i=0;i<ItemPos.Length;i++)
    {
        if(InteractionOwner.ViewportOwner.WindowsMouseX >= (InteractionOwner.ClipX*ItemPos[i].XTL)+(InteractionOwner.ClipX*WindowLocX)
        && InteractionOwner.ViewportOwner.WindowsMouseX <= (InteractionOwner.ClipX*(ItemPos[i].XTL+ItemPos[i].XH))+(InteractionOwner.ClipX*WindowLocX)
        && InteractionOwner.ViewportOwner.WindowsMouseY >= (InteractionOwner.ClipY*ItemPos[i].YTL)+(InteractionOwner.ClipY*WindowLocY)
        && InteractionOwner.ViewportOwner.WindowsMouseY <= (InteractionOwner.ClipY*(ItemPos[i].YTL+ItemPos[i].YH))+(InteractionOwner.ClipY*WindowLocY))
            return ItemPos[i].ImageTag;
    }
    if(InteractionOwner.ViewportOwner.WindowsMouseX >= (InteractionOwner.ClipX*0.025)+(InteractionOwner.ClipX*WindowLocX)
    && InteractionOwner.ViewportOwner.WindowsMouseX <= (InteractionOwner.ClipX*(0.025+0.275))+(InteractionOwner.ClipX*WindowLocX)
    && InteractionOwner.ViewportOwner.WindowsMouseY >= (InteractionOwner.ClipY*0.025)+(InteractionOwner.ClipY*WindowLocY)
    && InteractionOwner.ViewportOwner.WindowsMouseY <= (InteractionOwner.ClipY*(0.025+0.15))+(InteractionOwner.ClipY*WindowLocY))
        return "MissionBG";
    return super.bTouchingImage(InteractionOwner);
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
     DefaultMission=Class'sonicRPG45.Mission030F'
     NextPageSound=Sound'2K4MenuSounds.Generic.msfxUp'
     ScrollBlury=Texture'2K4Menus.NewControls.ScrollGripBlurry'
     ScrollPressed=Texture'2K4Menus.NewControls.ScrollGripPressed'
     ScrollWatched=Texture'2K4Menus.NewControls.ScrollGripWatched'
     ContextBGMat=Texture'2K4Menus.Controls.thinpipe_b'
     ItemPos(0)=(XTL=0.300000,YTL=0.025000,XH=0.025000,YH=0.025000,ImageTag="UpArrow",BGImage=Texture'2K4Menus.NewControls.UpMark')
     ItemPos(1)=(XTL=0.300000,YTL=0.150000,XH=0.025000,YH=0.025000,ImageTag="DownArrow",BGImage=Texture'2K4Menus.NewControls.DownMark')
     ItemPos(2)=(XTL=0.300000,YTL=0.050000,XH=0.025000,YH=0.100000,ImageTag="ScrollSection",BGImage=Texture'2K4Menus.NewControls.NewTabBk')
     AvailableMissions(0)=Class'sonicRPG45.Mission030F'
     AvailableMissions(1)=Class'sonicRPG45.Mission031F'
     AvailableMissions(2)=Class'sonicRPG45.Mission032F'
     AvailableMissions(3)=Class'sonicRPG45.Mission033F'
     AvailableMissions(4)=Class'sonicRPG45.Mission011F'
     AvailableMissions(5)=Class'sonicRPG45.Mission001F'
     AvailableMissions(6)=Class'sonicRPG45.Mission002F'
     AvailableMissions(7)=Class'sonicRPG45.Mission003F'
     AvailableMissions(8)=Class'sonicRPG45.Mission004F'
     AvailableMissions(9)=Class'sonicRPG45.Mission009F'
     AvailableMissions(10)=Class'sonicRPG45.Mission014F'
     AvailableMissions(11)=Class'sonicRPG45.Mission005F'
     AvailableMissions(12)=Class'sonicRPG45.Mission010F'
     AvailableMissions(13)=Class'sonicRPG45.Mission006F'
     AvailableMissions(14)=Class'sonicRPG45.Mission007F'
     AvailableMissions(15)=Class'sonicRPG45.Mission008F'
     AvailableMissions(16)=Class'sonicRPG45.Mission027F'
     AvailableMissions(17)=Class'sonicRPG45.Mission016F'
     AvailableMissions(18)=Class'sonicRPG45.Mission017F'
     AvailableMissions(19)=Class'sonicRPG45.Mission018F'
     AvailableMissions(20)=Class'sonicRPG45.Mission019F'
     AvailableMissions(21)=Class'sonicRPG45.Mission025F'
     AvailableMissions(22)=Class'sonicRPG45.Mission028F'
     AvailableMissions(23)=Class'sonicRPG45.Mission020F'
     AvailableMissions(24)=Class'sonicRPG45.Mission026F'
     AvailableMissions(25)=Class'sonicRPG45.Mission021F'
     AvailableMissions(26)=Class'sonicRPG45.Mission023F'
     AvailableMissions(27)=Class'sonicRPG45.Mission024F'
     AvailableMissions(28)=Class'sonicRPG45.Mission012F'
     AvailableMissions(29)=Class'sonicRPG45.Mission013F'
     AvailableMissions(30)=Class'sonicRPG45.Mission015F'
     AvailableMissions(31)=Class'sonicRPG45.Mission029F'
     ContextBorder=0.040000
     WindowLocH=0.200000
     WindowLocW=0.350000
     WindowLocX=0.600000
     WindowLocY=0.200000
}
