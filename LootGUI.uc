class LootGUI extends FloatingWindow;

var Material EmptySlotImage;
var int Slots;
var color LabelColour;
var array<GUILabel> img3;
var array<LootImage> img, img2;

var automated GUILabel PageNum;
var automated GUIButton CloseWindowButton, NxtPage, PrvPage;

function OnOpen()
{
   	local int Num;
   	local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(INVInventory != None)
    {
        INVInventory.Loot = self;
        INVInventory.bLootOpen = true;

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
        INVInventory.bLootOpen = false;
        INVInventory.Loot = none;
    }
}

function CreateInventory()
{
	local int i;
	local PlayerController P;

    P = PlayerOwner();

    if(img.length == 0)
    {
        img[0] = new class'LootImage';
        img[0].WinTop = 0.150000;
        img[0].WinLeft = 0.075000;
        img[0].Image = EmptySlotImage;
        AppendComponent(img[0], true);

        img2[0] = new class'LootImage';
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

    img[i] = new class'LootImage';
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

    img2[i] = new class'LootImage';
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
    INVInventory = class'mutInventorySystem'.static.FindINVInventory(C);
    if(INVInventory != None)
    {
        if(INVInventory.LStart > 0 && INVInventory.LStart+1 > INVInventory.LootedItems.Length)
            INVInventory.LStart -= Slots;
        PageNum.Caption = "Page:" @ ((INVInventory.LStart / Slots)+1);
    }

    if(INVInventory != none && INVInventory.LootedItems.Length > 0)
    {
        for(i=0;i<img2.Length;i++)
        {
           if(INVInventory.LootedItems.Length-INVInventory.LStart > i)
           {
               img2[i].OnClick = LeftClick;
               img2[i].Image = INVInventory.LootedItems[i+INVInventory.LStart].default.Image;
               img2[i].ExternalItemCopy = INVInventory.LootedItems[i+INVInventory.LStart];
               img2[i].DataRepNum = i+INVInventory.LStart;
               img2[i].SetHint(INVInventory.LootedItems[i+INVInventory.LStart].static.GetInvItemName(C));
               img2[i].OnRightClick = InternalOnRightClick;
               img3[i].Caption = string(INVInventory.LootedItemsAmount[i+INVInventory.LStart]);
               img3[i].bVisible = true;
           }
           else
           {
               img2[i].OnClick = None;
               img2[i].Image = None;
               img2[i].ExternalItemCopy = None;
               img2[i].SetHint("");
               img2[i].OnRightClick = InternalOnRightClickOff;
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

function bool LeftClick(GUIComponent Sender)
{
    if(!InvImages(Sender).bRightClick)
        PlayerOwner().ClientMessage(InvImages(Sender).ExternalItemCopy.static.GetInvItemName(PlayerOwner()));
    InvImages(Sender).bRightClick = false;
    return true;
}

function bool NextPge(GUIComponent Sender)
{
   	local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(INVInventory.LStart+Slots < INVInventory.LootedItems.Length)
    {
        INVInventory.LStart += Slots;
        UpdateImages();
        CheckDisable();
    }
    return true;
}

function bool PrevPge(GUIComponent Sender)
{
   	local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(INVInventory.LStart > 0)
    {
        INVInventory.LStart -= Slots;
        UpdateImages();
        CheckDisable();
        return true;
    }
    return false;
}

function CheckDisable()
{
   	local INVInventory INVInventory;

   	INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(INVInventory != none)
    {
        if(INVInventory.LStart <= 0)
            PrvPage.MenuStateChange(MSAT_Disabled);

        if(INVInventory.LStart > 0)
            PrvPage.MenuStateChange(MSAT_Blurry);

        if(INVInventory.LStart+Slots < INVInventory.LootedItems.Length)
            NxtPage.MenuStateChange(MSAT_Blurry);

        if(INVInventory.LStart+Slots >= INVInventory.LootedItems.Length)
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
     PageNum=GUILabel'sonicRPG45.LootGUI.Page'

     Begin Object Class=GUIButton Name=CloseButton
         Caption="Close"
         WinTop=0.800000
         WinLeft=0.525000
         WinWidth=0.400000
         WinHeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=LootGUI.XButtonClicked
         OnKeyEvent=CloseButton.InternalOnKeyEvent
     End Object
     CloseWindowButton=GUIButton'sonicRPG45.LootGUI.CloseButton'

     Begin Object Class=GUIButton Name=Next
         Caption="Next"
         WinTop=0.700000
         WinLeft=0.075000
         WinWidth=0.200000
         WinHeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=LootGUI.NextPge
         OnKeyEvent=Next.InternalOnKeyEvent
     End Object
     NxtPage=GUIButton'sonicRPG45.LootGUI.Next'

     Begin Object Class=GUIButton Name=Prev
         Caption="Prev"
         WinTop=0.700000
         WinLeft=0.275000
         WinWidth=0.200000
         WinHeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=LootGUI.PrevPge
         OnKeyEvent=Prev.InternalOnKeyEvent
     End Object
     PrvPage=GUIButton'sonicRPG45.LootGUI.Prev'

     WindowName="Loots"
     bResizeWidthAllowed=False
     bResizeHeightAllowed=False
     DefaultLeft=75.000000
     DefaultTop=350.000000
     DefaultWidth=0.250000
     DefaultHeight=0.250000
     bAllowedAsLast=True
     WinTop=350.000000
     WinLeft=75.000000
     WinWidth=0.250000
     WinHeight=0.250000
}
