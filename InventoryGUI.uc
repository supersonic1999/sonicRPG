class InventoryGUI extends FloatingWindow;

var Material EmptySlotImage;
var int Slots;
var color LabelColour;
var array<GUILabel> img3;
var array<InventoryImage> img, img2;

var automated GUILabel PageNum;
var automated GUIButton MissionWindowButton, ShopWindowButton, NxtPage, PrvPage, HelpWindowButton, LootWindowButton, StatsWindowButton;

function OnOpen()
{
   	local int Num;
   	local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(INVInventory != None)
    {
        INVInventory.GUI = self;
        INVInventory.bInventoryOpen = true;

        while(Num < Slots)
        {
            CreateInventory();
            Num++;
        }
        UpdateImages();
        CheckDisable();
    }
}

function OnClose(optional bool bCancelled)
{
   	local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());
    if(INVInventory != none)
    {
        INVInventory.bInventoryOpen = false;
        INVInventory.GUI = none;
    }
}

function CreateInventory()
{
	local int i;
	local PlayerController P;

    P = PlayerOwner();

    InventoryGUIButton(NxtPage).GUIOwner = self;
    InventoryGUIButton(PrvPage).GUIOwner = self;

    if(img.length == 0)
    {
        img[0] = new class'InventoryImage';
        img[0].WinTop = 0.150000;
        img[0].WinLeft = 0.075000;
        img[0].Image = EmptySlotImage;
        AppendComponent(img[0], true);

        img2[0] = new class'InventoryImage';
        img2[0].WinTop = 0.150000;
        img2[0].WinLeft = 0.075000;
        img2[0].ImageStyle = ISTY_Scaled;
        img2[0].OnRightClick = InternalOnRightClickOff;
        AppendComponent(img2[0], true);

        img3[0] = new class'GUILabel';
        img3[0].WinTop = 0.150000;
        img3[0].WinLeft = 0.075000;
        img3[0].TextColor = LabelColour;
        AppendComponent(img3[0], true);
        return;
    }

    i = img.Length;

    img[i] = new class'InventoryImage';
    if(img[i-1].WinLeft != img[0].WinLeft + 0.600000)
    {
        img[i].WinTop = img[i-1].WinTop;
        img[i].WinLeft = img[i-1].WinLeft + 0.300000;
    }
    else
    {
        img[i].WinTop = img[i-1].WinTop + 0.300000;
        img[i].WinLeft = img[0].WinLeft;
    }
    img[i].Image = EmptySlotImage;
    AppendComponent(img[i], true);

    img2[i] = new class'InventoryImage';
    if(img2[i-1].WinLeft != img2[0].WinLeft + 0.600000)
    {
        img2[i].WinTop = img2[i-1].WinTop;
        img2[i].WinLeft = img2[i-1].WinLeft + 0.300000;
    }
    else
    {
        img2[i].WinTop = img2[i-1].WinTop + 0.300000;
        img2[i].WinLeft = img2[0].WinLeft;
    }
    img2[i].ImageStyle = ISTY_Scaled;
    img2[i].OnRightClick = InternalOnRightClickOff;
    AppendComponent(img2[i], true);

    img3[i] = new class'GUILabel';
    if(img3[i-1].WinLeft != img3[0].WinLeft + 0.600000)
    {
        img3[i].WinTop = img3[i-1].WinTop;
        img3[i].WinLeft = img3[i-1].WinLeft + 0.300000;
    }
    else
    {
        img3[i].WinTop = img3[i-1].WinTop + 0.300000;
        img3[i].WinLeft = img3[0].WinLeft;
    }
    img3[i].TextColor = LabelColour;
    AppendComponent(img3[i], true);
}

function UpdateImages()
{
    local int i;
   	local INVInventory INVInventory;
   	local PlayerController C;

    C = PlayerOwner();
    if(C != none)
        INVInventory = class'mutInventorySystem'.static.FindINVInventory(C);
    if(INVInventory != None)
        PageNum.Caption = "Page:" @ ((INVInventory.IStart / Slots)+1);

    if(INVInventory != none && INVInventory.DataRep.Items.length > 0)
    {
        for(i=0;i<img2.Length;i++)
        {
           if(INVInventory != none && i+INVInventory.IStart < INVInventory.DataRep.Items.length)
           {
               img2[i].OnClick = LeftClick;
               img2[i].Image = INVInventory.DataRep.Items[i+INVInventory.IStart].default.Image;
               img2[i].ExternalItemCopy = INVInventory.DataRep.Items[i+INVInventory.IStart];
               img2[i].DataRepNum = i+INVInventory.IStart;
               img2[i].SetHint(INVInventory.DataRep.Items[i+INVInventory.IStart].static.GetInvItemName(C));
               img2[i].OnRightClick = InternalOnRightClick;
               img2[i].OnBeginDrag = myOnBeginDrag;
               img2[i].bDropSource = true;
               img2[i].bDropTarget = true;
               img3[i].Caption = string(INVInventory.DataRep.ItemsAmount[i+INVInventory.IStart]);
               img3[i].bVisible = true;
           }
           else
           {
               img2[i].OnClick = None;
               img2[i].Image = None;
               img2[i].ExternalItemCopy = None;
               img2[i].SetHint("");
               img2[i].OnRightClick = InternalOnRightClickOff;
               img2[i].bDropSource = false;
               img2[i].bDropTarget = false;
               img3[i].bVisible = false;
           }
        }
    }
    else
    {
        img2[0].OnClick = None;
        img2[0].ExternalItemCopy = None;
        img2[0].Image = None;
        img2[0].SetHint("");
        img2[0].OnRightClick = InternalOnRightClickOff;
        img3[0].bVisible = false;
    }
}

function bool InternalOnRightClick(GUIComponent Sender)
{
    InvImages(Sender).bRightClick = True;
    return true;
}

function bool InternalOnRightClickOff(GUIComponent Sender)
{
    return false;
}

function bool myOnBeginDrag(GUIComponent Sender)
{
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(INVInventory != none && Sender != none && InventoryImage(Sender) != none)
        INVInventory.DragStartNum = InventoryImage(Sender).DataRepNum;
    return true;
}

function bool LeftClick(GUIComponent Sender)
{
    local PlayerController C;

    C = PlayerOwner();
    if(!InvImages(Sender).bRightClick)
        C.ClientMessage(InvImages(Sender).ExternalItemCopy.static.GetInvItemName(C));
    InvImages(Sender).bRightClick = false;
    return true;
}

function bool NextPge(GUIComponent Sender)
{
   	local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(INVInventory.IStart+Slots < INVInventory.DataRep.Slots)
    {
        INVInventory.IStart += Slots;
        UpdateImages();
        CheckDisable();
    }
    return true;
}

function bool PrevPge(GUIComponent Sender)
{
   	local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(INVInventory.IStart > 0)
    {
        INVInventory.IStart -= Slots;
        UpdateImages();
        CheckDisable();
        return true;
    }
    return false;
}

function bool OpenShopMenu(GUIComponent Sender)
{
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(INVInventory != none && !INVInventory.bShopOpen)
        Controller.OpenMenu("SonicRPG45.ShopGUI");
    return true;
}

function bool OpenHelpMenu(GUIComponent Sender)
{
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(INVInventory != none && !INVInventory.bHelpOpen)
        Controller.OpenMenu("SonicRPG45.HelpGUI");
    return true;
}

function bool OpenLootMenu(GUIComponent Sender)
{
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(INVInventory != none && !INVInventory.bLootOpen)
        Controller.OpenMenu("SonicRPG45.LootGUI");
    return true;
}

function bool OpenMissionMenu(GUIComponent Sender)
{
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(INVInventory != none && !INVInventory.bMissionOpen)
        Controller.OpenMenu("SonicRPG45.MissionGUI");
    return true;
}

function bool OpenStatsMenu(GUIComponent Sender)
{
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(INVInventory != none && !INVInventory.bStatsGUIOpen)
        Controller.OpenMenu("SonicRPG45.StatsGUI");
    return true;
}

function CheckDisable()
{
   	local INVInventory INVInventory;

   	INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(INVInventory != none)
    {
        if(INVInventory.IStart <= 0)
            PrvPage.MenuStateChange(MSAT_Disabled);

        if(INVInventory.IStart > 0)
            PrvPage.MenuStateChange(MSAT_Blurry);

        if(INVInventory.IStart+Slots < INVInventory.DataRep.Slots)
            NxtPage.MenuStateChange(MSAT_Blurry);

        if(INVInventory.IStart+Slots >= INVInventory.DataRep.Slots)
            NxtPage.MenuStateChange(MSAT_Disabled);
    }
}

defaultproperties
{
     EmptySlotImage=Texture'2K4Menus.NewControls.ComboListDropdown'
     Slots=6
     LabelColour=(B=255,G=255,R=255,A=255)
     Begin Object Class=GUILabel Name=Page
         Caption="Page: 1"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.075000
         WinLeft=0.075000
         WinHeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     PageNum=GUILabel'sonicRPG45.InventoryGUI.Page'

     Begin Object Class=GUIButton Name=MissionButton
         Caption="Mission"
         WinTop=0.800000
         WinLeft=0.475000
         WinWidth=0.300000
         WinHeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=InventoryGUI.OpenMissionMenu
         OnKeyEvent=MissionButton.InternalOnKeyEvent
     End Object
     MissionWindowButton=GUIButton'sonicRPG45.InventoryGUI.MissionButton'

     Begin Object Class=GUIButton Name=ShopButton
         Caption="Shop"
         WinTop=0.700000
         WinLeft=0.600000
         WinWidth=0.175000
         WinHeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=InventoryGUI.OpenShopMenu
         OnKeyEvent=ShopButton.InternalOnKeyEvent
     End Object
     ShopWindowButton=GUIButton'sonicRPG45.InventoryGUI.ShopButton'

     Begin Object Class=InventoryGUIButton Name=Next
         Caption="Next"
         WinTop=0.700000
         WinLeft=0.075000
         WinWidth=0.200000
         WinHeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=InventoryGUI.NextPge
         OnKeyEvent=Next.InternalOnKeyEvent
     End Object
     NxtPage=InventoryGUIButton'sonicRPG45.InventoryGUI.Next'

     Begin Object Class=InventoryGUIButton Name=Prev
         Caption="Prev"
         WinTop=0.800000
         WinLeft=0.075000
         WinWidth=0.200000
         WinHeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=InventoryGUI.PrevPge
         OnKeyEvent=Prev.InternalOnKeyEvent
     End Object
     PrvPage=InventoryGUIButton'sonicRPG45.InventoryGUI.Prev'

     Begin Object Class=GUIButton Name=Help
         Caption="Help"
         WinTop=0.800000
         WinLeft=0.775000
         WinWidth=0.175000
         WinHeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=InventoryGUI.OpenHelpMenu
         OnKeyEvent=Help.InternalOnKeyEvent
     End Object
     HelpWindowButton=GUIButton'sonicRPG45.InventoryGUI.Help'

     Begin Object Class=GUIButton Name=Loot
         Caption="Loot"
         WinTop=0.700000
         WinLeft=0.775000
         WinWidth=0.175000
         WinHeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=InventoryGUI.OpenLootMenu
         OnKeyEvent=Loot.InternalOnKeyEvent
     End Object
     LootWindowButton=GUIButton'sonicRPG45.InventoryGUI.Loot'

     Begin Object Class=GUIButton Name=Stats
         Caption="Stats"
         WinTop=0.700000
         WinLeft=0.400000
         WinWidth=0.200000
         WinHeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=InventoryGUI.OpenStatsMenu
         OnKeyEvent=Stats.InternalOnKeyEvent
     End Object
     StatsWindowButton=GUIButton'sonicRPG45.InventoryGUI.Stats'

     WindowName="Inventory"
     bResizeWidthAllowed=False
     bResizeHeightAllowed=False
     DefaultLeft=75.000000
     DefaultTop=75.000000
     DefaultWidth=0.250000
     DefaultHeight=0.250000
     bAllowedAsLast=True
     WinTop=75.000000
     WinLeft=75.000000
     WinWidth=0.250000
     WinHeight=0.250000
}
