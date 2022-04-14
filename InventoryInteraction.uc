class InventoryInteraction extends Interaction;

#EXEC OBJ LOAD FILE=2K4Menus.utx

struct GUISelectionStruct
{
    var string Text, GUIStringMenu;
    var class<KMenuClass> KMenuFile;
    var KMenuClass KMenuRef;
};
struct ItemPosStruct
{
    var float XTL, YTL, XH, YH;
    var string ImageTag;
};

var protected mutInventorySystem MutINV;
var protected EInputKey KeyNum, TKeyNum, IKeyNum;
var protected byte GUIBaseSelected, TouchingLinkNum, ShortcutDragNum;
var protected rotator CharRotation;
var protected bool bDrawGUISelection, bDefaultBindings, bDefaultTradeBindings, bDefaultItemBindings, bDragging, CtrlPressed;
var protected array<GUISelectionStruct> GUISelectionInfo;

var Font TextFont;
var Material EmptySlotImage, GUISelectionImage;
var ItemPosStruct ShortcutTrayLoc[10];
var array<Material> MouseCursors;
var config bool bTrackerON, bShowClassIcons, bShowHotKeyTray;
var sound LinkClickSound;
var bool bLeftClicked;
var float ClipX, ClipY;
var color WhiteColor, YellowColor, TradeColor;
var localized string InventoryText, FirstInventoryText, LastInventoryText, TradeText,
                     FirstTradeText, LastTradeText, CreditsText, TrackerText;

event Initialized()
{
	local EInputKey key;
	local string tmp;
	local int i;

    if(ViewportOwner.Actor.Level.NetMode != NM_Client)
		foreach ViewportOwner.Actor.DynamicActors(class'mutInventorySystem', MutINV)
			break;

    for(i=0;i<GUISelectionInfo.length;i++)
        if(GUISelectionInfo[i].KMenuFile != none)
            GUISelectionInfo[i].KMenuRef = KMenuClass(ViewportOwner.Actor.Level.ObjectPool.AllocateObject(GUISelectionInfo[i].KMenuFile));

	for(key=IK_None;key<IK_OEMClear;key=EInputKey(key + 1))
	{
		tmp = ViewportOwner.Actor.ConsoleCommand("KEYNAME"@Key);
		tmp = ViewportOwner.Actor.ConsoleCommand("KEYBINDING"@tmp);
		if(tmp ~= "InventoryMenu")
			bDefaultBindings = false;
			KeyNum = Key;
		if(!bDefaultBindings)
			break;
	}

	for(key=IK_None;key<IK_OEMClear;key=EInputKey(key + 1))
	{
		tmp = ViewportOwner.Actor.ConsoleCommand("KEYNAME"@Key);
		tmp = ViewportOwner.Actor.ConsoleCommand("KEYBINDING"@tmp);
		if(tmp ~= "TradeMenu")
			bDefaultTradeBindings = false;
			TKeyNum = Key;
		if(!bDefaultTradeBindings)
			break;
	}

    for(key=IK_None;key<IK_OEMClear;key=EInputKey(key + 1))
	{
		tmp = ViewportOwner.Actor.ConsoleCommand("KEYNAME"@Key);
		tmp = ViewportOwner.Actor.ConsoleCommand("KEYBINDING"@tmp);
		if(tmp ~= "ItemHoldKey")
			bDefaultItemBindings = false;
			IKeyNum = Key;
		if(!bDefaultItemBindings)
			break;
	}
	TextFont = Font(DynamicLoadObject("UT2003Fonts.jFontSmall", class'Font'));
}

function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta)
{
    local string tmp, TouchingHUDString;
    local int i;
    local bool OtherKeyEvent, bValidItem;
    local class<MainInventoryItem> SavedSelection;
    local INVInventory INVInventory;

    if(ViewportOwner != none && ViewportOwner.Actor != none
    && (Action == IST_Press || Action == IST_Release))
    {
        tmp = ViewportOwner.Actor.ConsoleCommand("KEYNAME"@Key);
        tmp = ViewportOwner.Actor.ConsoleCommand("KEYBINDING"@tmp);
        if(!CtrlPressed && (tmp ~= "ItemHoldKey" || Key == IK_Ctrl) && Action == IST_Press)
            CtrlPressed = true;
        else if(CtrlPressed && (tmp ~= "ItemHoldKey" || Key == IK_Ctrl) && Action == IST_Release)
            CtrlPressed = false;
        else if(bDragging && Key == IK_LeftMouse && Action == IST_Release)
        {
            bDragging = false;
            INVInventory = FindINVInventory();
            if(INVInventory == none)
        		return super.KeyEvent(Key, Action, Delta);

            TouchingHUDString = bTouchingImage();
            if(TouchingHUDString == ShortcutTrayLoc[ShortcutDragNum].ImageTag)
                bValidItem = true;
            else
            {
                for(i=0;i<ArrayCount(ShortcutTrayLoc);i++)
                {
                    if(TouchingHUDString ~= ShortcutTrayLoc[i].ImageTag)
                    {
                        bValidItem = true;
                        break;
                    }
                }
                if(bValidItem)
                {
                    SavedSelection = INVInventory.SelectedItems[ShortcutDragNum];
                    INVInventory.SelectedItems[ShortcutDragNum] = INVInventory.SelectedItems[i];
                    INVInventory.SelectedItems[i] = SavedSelection;
                    INVInventory.SaveConfig();
                }
            }
            if(!bValidItem)
            {
                INVInventory.SelectedItems[ShortcutDragNum] = none;
                INVInventory.SaveConfig();
            }
            bValidItem = false;
        }
    }
    if(Action != IST_Press || ViewportOwner == none || ViewportOwner.Actor == none)
		return super.KeyEvent(Key, Action, Delta);

    INVInventory = FindINVInventory();
    if(INVInventory == none)
		return super.KeyEvent(Key, Action, Delta);

    tmp = ViewportOwner.Actor.ConsoleCommand("KEYNAME"@Key);
    tmp = ViewportOwner.Actor.ConsoleCommand("KEYBINDING"@tmp);

    if(CtrlPressed && Key-49 < ArrayCount(INVInventory.SelectedItems)
    && (Key == IK_1 || Key == IK_2 || Key == IK_3 || Key == IK_4 || Key == IK_5
    || Key == IK_6 || Key == IK_7 || Key == IK_8 || Key == IK_9 || Key == IK_0))
    {
        if(Key == IK_0
        && INVInventory.SelectedItems[9] != none
        && INVInventory.SelectedItems[9].default.bIsUsable)
        {
            for(i=0;i<INVInventory.DataRep.Items.length;i++)
            {
                if(INVInventory.SelectedItems[9] == INVInventory.DataRep.Items[i])
                {
                    bValidItem = true;
                    break;
                }
            }
            if(!bValidItem && INVInventory.SelectedItems[9] != none)
            {
                INVInventory.SelectedItems[9] = none;
                INVInventory.SaveConfig();
            }
            else if(bValidItem)
                INVInventory.DataRep.Items[i].static.OnClick(ViewportOwner.Actor, i);
            return true;
        }
        else if(Key != IK_0
        && INVInventory.SelectedItems[Key-49] != none
        && INVInventory.SelectedItems[Key-49].default.bIsUsable)
        {
            for(i=0;i<INVInventory.DataRep.Items.length;i++)
            {
                if(INVInventory.SelectedItems[Key-49] == INVInventory.DataRep.Items[i])
                {
                    bValidItem = true;
                    break;
                }
            }
            if(!bValidItem && INVInventory.SelectedItems[Key-49] != none)
            {
                INVInventory.SelectedItems[Key-49] = none;
                INVInventory.SaveConfig();
            }
            else if(bValidItem)
                INVInventory.DataRep.Items[i].static.OnClick(ViewportOwner.Actor, i);
            return true;
        }
    }
	else if(tmp ~= "InventoryMenu" || (bDrawGUISelection && Key == IK_Escape) || (bDefaultBindings && Key == IK_K))
	{
        if(INVInventory.DataRep.CharClass != none)
        {
            if(bDrawGUISelection && GUIBaseSelected < GUISelectionInfo.length
            && GUISelectionInfo[GUIBaseSelected].KMenuRef != none)
                GUISelectionInfo[GUIBaseSelected].KMenuRef.MenuToggled(self, false);
            bDrawGUISelection = !bDrawGUISelection;
    		CharRotation = ViewportOwner.Actor.Rotation;
    		if(Key == IK_Escape)
    		    return true;
		}
		else ViewportOwner.GUIController.OpenMenu("SonicRPG45.ClassSelectGUI");
	}
	else if(bDrawGUISelection)
    {
        if(GUIBaseSelected < GUISelectionInfo.Length && GUISelectionInfo[GUIBaseSelected].KMenuRef != none)
            OtherKeyEvent = GUISelectionInfo[GUIBaseSelected].KMenuRef.KeyEvent(self, Key, Action, Delta);
        if(Key == IK_LeftMouse)
        {
            bLeftClicked = true;
            return true;
		}
		return OtherKeyEvent;
    }
	else if(INVInventory.bTradeAvailable && (tmp ~= "TradeMenu" || (bDefaultTradeBindings && Key == IK_O)))
        INVInventory.ClientOpenTrade();
    else if(INVInventory.DataRep.Items.length > 0)
        for(i=0;i<INVInventory.DataRep.Items.Length;i++)
            if(tmp ~= ("InvItem" $ string(i+1)) && INVInventory.DataRep.ItemsAmount[i] > 0)
                INVInventory.DataRep.Items[i].static.OnClick(ViewportOwner.Actor, i);
	return super.KeyEvent(Key, Action, Delta);
}

function INVInventory FindINVInventory()
{
	local Inventory Inv;
	local INVInventory FoundINVInventory, SavedINVInventory;

    if(ViewportOwner == none || ViewportOwner.Actor == none)
        return none;

	for(Inv = ViewportOwner.Actor.Inventory; Inv != None; Inv = Inv.Inventory)
	{
        SavedINVInventory = INVInventory(Inv);
		if(SavedINVInventory != None)
			return SavedINVInventory;
		else if(Inv.Inventory == Inv)
		{
			Inv.Inventory = None;
			foreach ViewportOwner.Actor.DynamicActors(class'INVInventory', FoundINVInventory)
			{
                if(FoundINVInventory.Owner == ViewportOwner.Actor
                || ViewportOwner.Actor.Pawn != none && FoundINVInventory.Owner == ViewportOwner.Actor.Pawn)
				{
                    Inv.Inventory = FoundINVInventory;
					return FoundINVInventory;
				}
			}
		}
	}
}

function PostRender(Canvas Canvas)
{
	local array<string> TrackerTextArray, TrackerArrayParts;
    local float XL, YL, TrackerCurPos;
	local int i;
	local string TempText;
	local INVInventory INVInventory;

    if(ViewportOwner != none && ViewportOwner.Actor != none && bShowClassIcons)
        DrawClassIcons(Canvas);

    super.PostRender(Canvas);
    if(ViewportOwner == none || ViewportOwner.Actor == none
    || (ViewportOwner.Actor.myHud != none && ViewportOwner.Actor.myHud.bShowScoreBoard)
    || (ViewportOwner.Actor.myHud != none && ViewportOwner.Actor.myHud.bHideHUD))
        return;

    INVInventory = FindINVInventory();
    if(INVInventory == none)
        return;
    if(INVInventory.DataRep.CurrentMission != none)
        INVInventory.DataRep.CurrentMission.static.PostRender(self, Canvas);
    if(ViewportOwner.Actor.Pawn != none && ViewportOwner.Actor.Pawn.Health > 0
    && (ViewportOwner.Actor.myHud != none && ViewportOwner.Actor.myHud.bShowPersonalInfo))
    {
        if(INVInventory.DataRep.Items.Length > 0)
        {
            for(i=0;i<INVInventory.DataRep.Items.Length;i++)
                if(INVInventory.DataRep.Items[i] != none && INVInventory.DataRep.Items[i].default.bPostRender)
                    INVInventory.DataRep.Items[i].static.PostRender(ViewportOwner.Actor, Canvas);
            Canvas.Reset();
        }

        if(!bDefaultBindings)
            InventoryText = (FirstInventoryText @ GetFriendlyName(KeyNum) @ LastInventoryText);

        if(INVInventory.TradeReplicationInfo != none
        && INVInventory.TradeReplicationInfo.CurTrader != none
        && INVInventory.TradeReplicationInfo.CurTrader.Instigator != none)
        {
            if(!bDefaultTradeBindings)
                TradeText = (FirstTradeText @ GetFriendlyName(TKeyNum) @ LastTradeText @ INVInventory.TradeReplicationInfo.CurTrader.Instigator.GetHumanReadableName() $ "**");
            else
                TradeText = (default.TradeText @ INVInventory.TradeReplicationInfo.CurTrader.Instigator.GetHumanReadableName() $ "**");
        }
        else if(bDefaultTradeBindings)
            TradeText = default.TradeText @ "???**";
        else
            TradeText = (FirstTradeText @ GetFriendlyName(TKeyNum) @ LastTradeText @ "???**");

        if(TextFont != None)
            Canvas.Font = TextFont;

        Canvas.FontScaleX = Canvas.ClipX / 1024.f;
        Canvas.FontScaleY = Canvas.ClipY / 768.f;
    	Canvas.DrawColor = WhiteColor;
        Canvas.TextSize(InventoryText, XL, YL);
        Canvas.SetPos(Canvas.ClipX - XL - 1, Canvas.ClipY * 0.80 - YL * 1.25);
        Canvas.DrawText(InventoryText);

        Canvas.FontScaleX = Canvas.ClipX / 1024.f;
        Canvas.FontScaleY = Canvas.ClipY / 768.f;
        Canvas.DrawColor = WhiteColor;
        TempText = (default.CreditsText @ string(int(INVInventory.DataRep.Credits)));
        Canvas.TextSize(TempText, XL, YL);
        Canvas.SetPos(0, Canvas.ClipY * 0.89 - YL);
        Canvas.DrawText(TempText);

        TempText = ("LVL:" @ string(INVInventory.DataRep.CombatLevel));
        Canvas.bCenter = true;
        Canvas.SetPos(0, Canvas.ClipY * 0.10 - YL);
        Canvas.DrawText(TempText);
        TempText = (string(int(INVInventory.DataRep.CombatXP)) $ "/"
                 $ string(class'mutInventorySystem'.static.GetCurrentXP(INVInventory.DataRep.CombatLevel)));
        Canvas.SetPos(0, Canvas.ClipY * 0.13 - YL);
        Canvas.DrawText(TempText);
        Canvas.bCenter = false;

        if(INVInventory.DataRep.CurrentMission != none && bTrackerON)
        {
            TrackerCurPos = 0.15;
            Canvas.SetPos(0, Canvas.ClipY * TrackerCurPos);
            Canvas.DrawText(TrackerText);
            TrackerTextArray = INVInventory.DataRep.CurrentMission.static.GetHUDMissionText(INVInventory);

            for(i=0;i<TrackerTextArray.length;i++)
                Canvas.WrapStringToArray(TrackerTextArray[i], TrackerArrayParts, Canvas.ClipX * 0.3);

            for(i=0;i<TrackerArrayParts.length;i++)
            {
                TrackerCurPos += YL/Canvas.ClipY;
                Canvas.SetPos(0, Canvas.ClipY * TrackerCurPos);
                Canvas.DrawText(TrackerArrayParts[i]);
            }
        }
        if(bShowHotKeyTray)
            DrawSelectedItems(Canvas, INVInventory);
        if(INVInventory.bTradeAvailable)
        {
            Canvas.DrawColor = TradeColor;
            Canvas.TextSize(TradeText, XL, YL);
            Canvas.SetPos(Canvas.ClipX - XL - 1, Canvas.ClipY * 0.90 - YL * 1.25);
            Canvas.DrawText(TradeText);
        }
        Canvas.Reset();
    }

    if(bDrawGUISelection)
        DrawGUISelection(Canvas, INVInventory);
    if(bDragging)
    {
        Canvas.DrawColor = WhiteColor;
        Canvas.SetPos(ViewportOwner.WindowsMouseX, ViewportOwner.WindowsMouseY);
        Canvas.DrawRect(Texture(INVInventory.SelectedItems[ShortcutDragNum].default.Image),
                        Canvas.ClipX*ShortcutTrayLoc[ShortcutDragNum].XH, Canvas.ClipY*ShortcutTrayLoc[ShortcutDragNum].YH);
    }
    if(bDrawGUISelection && !ViewportOwner.GUIController.bActive)
    {
        Canvas.Style = 5;
        Canvas.DrawColor = WhiteColor;
        if(ViewportOwner.SelectedCursor > 0)
            Canvas.SetPos(ViewportOwner.WindowsMouseX-(MouseCursors[ViewportOwner.SelectedCursor].MaterialUSize()/2),
                          ViewportOwner.WindowsMouseY-(MouseCursors[ViewportOwner.SelectedCursor].MaterialVSize()/2));
        else
            Canvas.SetPos(ViewportOwner.WindowsMouseX, ViewportOwner.WindowsMouseY);
        Canvas.DrawIcon(Texture(MouseCursors[ViewportOwner.SelectedCursor]), 1);
        Canvas.Style = 1;
    }
    Canvas.Reset();
}

protected function DrawClassIcons(Canvas Canvas)
{
    local vector SavedPVector;
    local byte myTeam;
    local bool bAddedPawn;
    local int i;
    local float XL, YL;
    local string OtherName;
    local class<ClassFile> CFile;
    local array<INVInventory> PawnInventory;
    local array<xPawn> PawnPawn;
    local INVInventory OtherINVInventory;
    local xPawn P;

    if(Canvas == none)
        return;

    if(TextFont != None)
        Canvas.Font = TextFont;
    Canvas.DrawColor = WhiteColor;
    myTeam = ViewportOwner.Actor.GetTeamNum();
    foreach ViewportOwner.Actor.DynamicActors(class'xPawn', P)
    {
        SavedPVector = Canvas.WorldToScreen(P.Location);
        if(P.PlayerReplicationInfo == none || P.Health <= 0
        || (Vehicle(ViewportOwner.Actor.Pawn) != none && P == Vehicle(ViewportOwner.Actor.Pawn).Driver)
        || (Vehicle(ViewportOwner.Actor.Pawn) == none && P == ViewportOwner.Actor.Pawn
        || myTeam != P.GetTeamNum()) || !ViewportOwner.Actor.LineOfSightTo(P)
        || SavedPVector.X <= 0 || SavedPVector.X > Canvas.ClipX
        || SavedPVector.Y <= 0 || SavedPVector.Y > Canvas.ClipY
        || float(string(SavedPVector.Z)) >= 1)
            continue;

        CFile = none;
        OtherName = P.GetHumanReadableName();
        foreach ViewportOwner.Actor.DynamicActors(class'INVInventory', OtherINVInventory)
        {
            if(OtherINVInventory.Instigator == P
            || OtherINVInventory.Owner == P
            || OtherINVInventory.GetHumanReadableName() ~= OtherName)
            {
                CFile = OtherINVInventory.DataRep.CharClass;
                break;
            }
        }
        if(CFile == none)
            continue;
        for(i=0;i<PawnInventory.length;i++)
        {
            if(VSize(P.Location-ViewportOwner.Actor.Pawn.Location) > VSize(PawnPawn[i].Location-ViewportOwner.Actor.Pawn.Location))
            {
                PawnInventory.Insert(i, 1);
                PawnInventory[i] = OtherINVInventory;
                PawnPawn.Insert(i, 1);
                PawnPawn[i] = P;
                bAddedPawn = true;
                i = PawnInventory.length;
            }
        }
        if(!bAddedPawn)
        {
            PawnInventory[PawnInventory.length] = OtherINVInventory;
            PawnPawn[PawnPawn.length] = P;
        }
    }
    for(i=0;i<PawnInventory.length;i++)
    {
        SavedPVector = Canvas.WorldToScreen(PawnPawn[i].Location + PawnPawn[i].CollisionHeight * vect(0,0,1));
        Canvas.SetPos(SavedPVector.X-40, SavedPVector.Y-40);
        if(PawnInventory[i].DataRep.CharClass.default.ClassPicture != none)
            Canvas.DrawRect(Texture(PawnInventory[i].DataRep.CharClass.default.ClassPicture), 32, 32);
        else
            Canvas.DrawRect(Texture(EmptySlotImage), 32, 32);
        Canvas.FontScaleX = 0.75;
        Canvas.FontScaleY = 0.75;
        Canvas.TextSize(PawnInventory[i].DataRep.CombatLevel, XL, YL);
        Canvas.SetPos(SavedPVector.X-40, SavedPVector.Y-8-YL);
        Canvas.DrawText(PawnInventory[i].DataRep.CombatLevel);
    }
    Canvas.Reset();
}

protected function DrawSelectedItems(Canvas Canvas, INVInventory INVInventory)
{
    local int i, o;
    local bool bValidItem;
    local float XL, YL;
    local color TempColor;

    for(i=0;i<ArrayCount(INVInventory.SelectedItems);i++)
    {
        for(o=0;o<INVInventory.DataRep.Items.length;o++)
        {
            if(INVInventory.SelectedItems[i] == INVInventory.DataRep.Items[o])
            {
                bValidItem = true;
                break;
            }
        }
        if(!bValidItem && INVInventory.SelectedItems[i] != none)
        {
            INVInventory.SelectedItems[i] = none;
            INVInventory.SaveConfig();
        }
        Canvas.DrawColor = WhiteColor;
        Canvas.TextSize(i, XL, YL);
//        if(i == 0 || i == 2
//        || i == 4 || i == 6 || i == 8)
//            Canvas.SetPos(((Canvas.ClipX*ShortcutTrayLoc[i].XTL)-1)-XL, (Canvas.ClipY*(ShortcutTrayLoc[i].YTL+(ShortcutTrayLoc[i].YH/2)))-(YL/2));
//        else
//            Canvas.SetPos((Canvas.ClipX*ShortcutTrayLoc[i].XTL)+(Canvas.ClipX*ShortcutTrayLoc[i].XH)+1, (Canvas.ClipY*(ShortcutTrayLoc[i].YTL+(ShortcutTrayLoc[i].YH/2)))-(YL/2));
        if(i < 5)
            Canvas.SetPos((Canvas.ClipX*ShortcutTrayLoc[i].XTL)+(Canvas.ClipX*ShortcutTrayLoc[i].XH/2)-(XL/2), (Canvas.ClipY*ShortcutTrayLoc[i].YTL)-YL);
        else
            Canvas.SetPos((Canvas.ClipX*ShortcutTrayLoc[i].XTL)+(Canvas.ClipX*ShortcutTrayLoc[i].XH/2)-(XL/2), (Canvas.ClipY*(ShortcutTrayLoc[i].YTL+ShortcutTrayLoc[i].YH)));
        if(i+1 != 10)
            Canvas.DrawText(i+1);
        else
            Canvas.DrawText(0);

        if(HudCDeathMatch(ViewportOwner.Actor.myHud) != none)
        {
            TempColor = HudCDeathMatch(ViewportOwner.Actor.myHud).GetTeamColor(ViewportOwner.Actor.GetTeamNum());
            TempColor.A = 155;
            Canvas.DrawColor = TempColor;
        }
        else
            Canvas.SetDrawColor(0,0,0,155);
        Canvas.SetPos(Canvas.ClipX*ShortcutTrayLoc[i].XTL, Canvas.ClipY*ShortcutTrayLoc[i].YTL);
        Canvas.DrawTileStretched(Texture(EmptySlotImage), Canvas.ClipX*ShortcutTrayLoc[i].XH, Canvas.ClipY*ShortcutTrayLoc[i].YH);

        if(bValidItem && INVInventory.SelectedItems[i] != none)
        {
            if(!bDragging && bLeftClicked && bTouchingImage() ~= ShortcutTrayLoc[i].ImageTag)
            {
                ShortcutDragNum = i;
                bDragging = true;
            }
            Canvas.DrawColor = WhiteColor;
            INVInventory.DataRep.Items[o].static.DrawImage(ViewportOwner.Actor, Canvas,
                                                           Canvas.ClipY*ShortcutTrayLoc[i].YTL, Canvas.ClipX*ShortcutTrayLoc[i].XTL,
                                                           Canvas.ClipY*ShortcutTrayLoc[i].YH, Canvas.ClipX*ShortcutTrayLoc[i].XH);
            Canvas.SetPos(Canvas.ClipX*ShortcutTrayLoc[i].XTL,Canvas.ClipY*ShortcutTrayLoc[i].YTL);
            if(INVInventory.DataRep.ItemsAmount[o] >= 1000)
                Canvas.DrawText(int(INVInventory.DataRep.ItemsAmount[o]/1000.0)$"K");
            else
                Canvas.DrawText(INVInventory.DataRep.ItemsAmount[o]);
        }
        bValidItem = false;
    }
}

protected function DrawGUISelection(Canvas Canvas, INVInventory INVInventory)
{
    local int i;
    local float XH, YH, XL, YL;
    local bool bTouching;
    local color TempColor;

    ClipX = Canvas.ClipX;
    ClipY = Canvas.ClipY;
    Canvas.Reset();
    if(TextFont != none)
        Canvas.Font = TextFont;
    Canvas.FontScaleX = Canvas.ClipX / 1024.f;
	Canvas.FontScaleY = Canvas.ClipY / 768.f;

    if(HudCDeathMatch(ViewportOwner.Actor.myHud) != none)
    {
        TempColor = HudCDeathMatch(ViewportOwner.Actor.myHud).GetTeamColor(ViewportOwner.Actor.GetTeamNum());
        TempColor.A = 155;
        Canvas.DrawColor = TempColor;
    }
    else
        Canvas.SetDrawColor(0,0,0,155);
    Canvas.SetPos(Canvas.ClipX*0.3, Canvas.ClipY*0.3);
    Canvas.DrawTileJustified(GUISelectionImage, 1, Canvas.ClipX*0.4, Canvas.ClipY*0.4);
    for(i=0;i<GUISelectionInfo.Length;i++)
    {
        XH = (((Canvas.ClipX*0.4)/2.8)*cos(((360/GUISelectionInfo.Length)*(i+1))*Pi/180.0)+(Canvas.ClipX/2));
        YH = (-((Canvas.ClipX*0.4)/2.8)*sin(((360/GUISelectionInfo.Length)*(i+1))*Pi/180.0)+(Canvas.ClipY/2));
        Canvas.DrawColor = WhiteColor;
        Canvas.TextSize(GUISelectionInfo[i].Text, XL, YL);
        Canvas.SetPos(XH-(XL/2), YH-(YL/2));
        if(ViewportOwner.WindowsMouseX >= XH-(XL/2)
        && ViewportOwner.WindowsMouseX <= (XH-(XL/2))+XL
        && ViewportOwner.WindowsMouseY >= YH-(YL/2)
        && ViewportOwner.WindowsMouseY <= (YH-(YL/2))+YL)
        {
            Canvas.DrawColor = YellowColor;
            TouchingLinkNum = i;
            bTouching = true;
            if(bTouchingImage() ~= "MainLink" && bLeftClicked)
            {
                UsePressedText(i);
                ViewportOwner.Actor.ClientPlaySound(LinkClickSound,true,2);
                bLeftClicked = false;
            }
        }
        if(i == GUIBaseSelected)
            Canvas.DrawColor = YellowColor;
        Canvas.DrawText(GUISelectionInfo[i].Text);
    }
    if(!bTouching)
        TouchingLinkNum = 255;
    Canvas.DrawColor = WhiteColor;
    if(GUIBaseSelected < GUISelectionInfo.Length && GUISelectionInfo[GUIBaseSelected].KMenuRef != none)
        GUISelectionInfo[GUIBaseSelected].KMenuRef.PostRender(self, Canvas, INVInventory);
    bLeftClicked = false;
}

function string bTouchingImage()
{
    local int i;
    local string OtherString;

    if(GUIBaseSelected < GUISelectionInfo.Length && GUISelectionInfo[GUIBaseSelected].KMenuRef != none)
    {
        OtherString = GUISelectionInfo[GUIBaseSelected].KMenuRef.bTouchingImage(self);
        if(OtherString != "")
            return OtherString;
    }
    for(i=0;i<ArrayCount(ShortcutTrayLoc);i++)
        if(ViewportOwner.WindowsMouseX >= (ClipX*ShortcutTrayLoc[i].XTL)
        && ViewportOwner.WindowsMouseX <= (ClipX*(ShortcutTrayLoc[i].XTL+ShortcutTrayLoc[i].XH))
        && ViewportOwner.WindowsMouseY >= (ClipY*ShortcutTrayLoc[i].YTL)
        && ViewportOwner.WindowsMouseY <= (ClipY*(ShortcutTrayLoc[i].YTL+ShortcutTrayLoc[i].YH)))
            return ShortcutTrayLoc[i].ImageTag;
    if(TouchingLinkNum != 255)
        return "MainLink";
    return "";
}

protected function UsePressedText(byte Num)
{
    if(Num < GUISelectionInfo.Length && GUISelectionInfo[Num].KMenuFile == none)
    {
        if(GUISelectionInfo[Num].GUIStringMenu != "")
            ViewportOwner.GUIController.OpenMenu(GUISelectionInfo[Num].GUIStringMenu);
    }
    else if(GUIBaseSelected != Num)
        GUIBaseSelected = Num;
    else
        GUIBaseSelected = 255;
    if(Num < GUISelectionInfo.Length && GUISelectionInfo[Num].KMenuRef != none)
        GUISelectionInfo[Num].KMenuRef.MenuToggled(self, (Num!=255));
}

exec function ToggleMissionTracker()
{
    bTrackerON = !bTrackerON;
    SaveConfig();
}

exec function ToggleClassIcons()
{
    bShowClassIcons = !bShowClassIcons;
    SaveConfig();
}

exec function ToggleHotKeyTray()
{
    bShowHotKeyTray = !bShowHotKeyTray;
    SaveConfig();
}

event NotifyLevelChange()
{
	local INVInventory INVInventory;
	local int i;

    INVInventory = FindINVInventory();
    if(MutINV != none)
    {
        MutINV.SaveData();
        MutINV = none;
    }

    for(i=0;i<GUISelectionInfo.length;i++)
        if(GUISelectionInfo[i].KMenuRef != none)
            GUISelectionInfo[i].KMenuRef = none;

    if(INVInventory != none)
    {
        if(INVInventory.bInventoryOpen)
    		INVInventory.GUI.XButtonClicked(None);
    	if(INVInventory.bShopOpen)
    		INVInventory.Shop.XButtonClicked(None);
    	if(INVInventory.bAmountOpen)
    		INVInventory.Amount.XButtonClicked(None);
   		if(INVInventory.bTradeOpen)
   		    INVInventory.Trade.XButtonClicked(None);
	    if(INVInventory.bInformationOpen)
	        INVInventory.Information.XButtonClicked(None);
        if(INVInventory.bLootOpen)
            INVInventory.Loot.XButtonClicked(None);
    }
    Master.RemoveInteraction(self);
    super.NotifyLevelChange();
}

function Tick(float DeltaTime)
{
    if(bDrawGUISelection && ViewportOwner != none
    && ViewportOwner.Actor != none)
        ViewportOwner.Actor.ClientSetRotation(CharRotation);
}

defaultproperties
{
     GUIBaseSelected=255
     TouchingLinkNum=255
     bDefaultBindings=True
     bDefaultTradeBindings=True
     bDefaultItemBindings=True
     GUISelectionInfo(0)=(Text="Inventory",KMenuFile=Class'sonicRPG45.InventoryHudClass')
     GUISelectionInfo(1)=(Text="Shop",KMenuFile=Class'sonicRPG45.ShopHudClass')
     GUISelectionInfo(2)=(Text="Loot",KMenuFile=Class'sonicRPG45.LootHudClass')
     GUISelectionInfo(3)=(Text="Help",GUIStringMenu="SonicRPG45.HelpGUI")
     GUISelectionInfo(4)=(Text="Stats",GUIStringMenu="SonicRPG45.StatsGUI")
     GUISelectionInfo(5)=(Text="Mission",KMenuFile=Class'sonicRPG45.MissionHudClass')
     GUISelectionInfo(6)=(Text="Options")
     EmptySlotImage=Texture'2K4Menus.NewControls.ComboListDropdown'
     GUISelectionImage=Shader'2K4Hud.ZoomFX.RDM_OuterScopeShader'
     ShortcutTrayLoc(0)=(XTL=0.650000,YTL=0.090000,XH=0.050000,YH=0.050000,ImageTag="001")
     ShortcutTrayLoc(1)=(XTL=0.700000,YTL=0.090000,XH=0.050000,YH=0.050000,ImageTag="002")
     ShortcutTrayLoc(2)=(XTL=0.750000,YTL=0.090000,XH=0.050000,YH=0.050000,ImageTag="003")
     ShortcutTrayLoc(3)=(XTL=0.800000,YTL=0.090000,XH=0.050000,YH=0.050000,ImageTag="004")
     ShortcutTrayLoc(4)=(XTL=0.850000,YTL=0.090000,XH=0.050000,YH=0.050000,ImageTag="005")
     ShortcutTrayLoc(5)=(XTL=0.650000,YTL=0.140000,XH=0.050000,YH=0.050000,ImageTag="006")
     ShortcutTrayLoc(6)=(XTL=0.700000,YTL=0.140000,XH=0.050000,YH=0.050000,ImageTag="007")
     ShortcutTrayLoc(7)=(XTL=0.750000,YTL=0.140000,XH=0.050000,YH=0.050000,ImageTag="008")
     ShortcutTrayLoc(8)=(XTL=0.800000,YTL=0.140000,XH=0.050000,YH=0.050000,ImageTag="009")
     ShortcutTrayLoc(9)=(XTL=0.850000,YTL=0.140000,XH=0.050000,YH=0.050000,ImageTag="000")
     MouseCursors(0)=Texture'InterfaceContent.Menu.MouseCursor'
     MouseCursors(1)=Texture'InterfaceContent.Menu.SplitterCursor'
     MouseCursors(2)=Texture'InterfaceContent.Menu.SplitterCursor'
     MouseCursors(3)=Texture'InterfaceContent.Menu.SplitterCursorVert'
     MouseCursors(4)=Texture'InterfaceContent.Menu.SplitterCursor'
     MouseCursors(5)=Texture'InterfaceContent.Menu.SplitterCursor'
     MouseCursors(6)=Texture'InterfaceContent.Menu.MouseCursor'
     bTrackerON=True
     bShowClassIcons=True
     bShowHotKeyTray=True
     LinkClickSound=Sound'MenuSounds.selectK'
     WhiteColor=(B=255,G=255,R=255,A=255)
     YellowColor=(G=255,R=255,A=255)
     TradeColor=(R=255,A=255)
     InventoryText="Press K for inventory menu"
     FirstInventoryText="Press"
     LastInventoryText="for inventory menu"
     TradeText="**Press o to open trade with"
     FirstTradeText="**Press"
     LastTradeText="to open trade with"
     CreditsText="Credits:"
     TrackerText="Mission Tracker:"
     bVisible=True
     bRequiresTick=True
}
