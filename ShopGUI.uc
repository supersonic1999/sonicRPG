class ShopGUI extends FloatingWindow;

var Material EmptySlotImage;
var int Slots, CreditPrice;
var array<ShopImage> img, img2;
var array<GUILabel> img3;
var class<MainInventoryItem> Item;
var color LabelColour;

var automated GUILabel PageNum;
var automated GUIButton CloseWindowButton, NxtPage, PrvPage;

function OnOpen()
{
   	local int ShopNum;
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(INVInventory != None)
	{
        INVInventory.Shop = self;
        INVInventory.bShopOpen = true;
        INVInventory.ServerCheckShopItems();

        while(ShopNum < Slots)
        {
           CreateInventory();
           ShopNum++;
        }
        CheckDisable();
        UpdateImages();
    }
}

function OnClose(optional bool bCancelled)
{
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(INVInventory != None)
    {
        INVInventory.Shop = none;
        INVInventory.bShopOpen = false;
    }
}

function CreateInventory()
{
	local int i;
	local PlayerController P;

	P = PlayerOwner();

    if(img.length == 0)
    {
        img[0] = new class'ShopImage';
        img[0].WinTop = 0.075000;
        img[0].WinLeft = 0.075000;
        img[0].WinHeight = 0.125000;
        img[0].Image = EmptySlotImage;
        AppendComponent(img[0], true);

        img2[0] = new class'ShopImage';
        img2[0].WinTop = 0.075000;
        img2[0].WinLeft = 0.075000;
        img2[0].WinHeight = 0.125000;
        img2[0].ImageStyle = ISTY_Scaled;
        img2[0].OnRightClick = InternalOnRightClickOff;
        AppendComponent(img2[0], true);

        img3[0] = new class'GUILabel';
        img3[0].WinTop = 0.075000;
        img3[0].WinLeft = 0.075000;
        img3[0].TextColor = LabelColour;
        AppendComponent(img3[0], true);
        return;
    }

    i = img.Length;

    img[i] = new class'ShopImage';
    if(img[i-1].WinLeft != 0.675000)
    {
        img[i].WinTop = img[i-1].WinTop;
        img[i].WinLeft = img[i-1].WinLeft + 0.300000;
    }
    else
    {
        img[i].WinTop = img[i-1].WinTop + 0.150000;
        img[i].WinLeft = 0.075000;
    }
    img[i].WinHeight = 0.125000;
    img[i].Image = EmptySlotImage;
    AppendComponent(img[i], true);

    img2[i] = new class'ShopImage';
    if(img2[i-1].WinLeft != 0.675000)
    {
        img2[i].WinTop = img2[i-1].WinTop;
        img2[i].WinLeft = img2[i-1].WinLeft + 0.300000;
    }
    else
    {
        img2[i].WinTop = img2[i-1].WinTop + 0.150000;
        img2[i].WinLeft = 0.075000;
    }
    img2[i].WinHeight = 0.125000;
    img2[i].ImageStyle = ISTY_Scaled;
    img2[i].OnRightClick = InternalOnRightClickOff;
    AppendComponent(img2[i], true);

    img3[i] = new class'GUILabel';
    if(img3[i-1].WinLeft != 0.675000)
    {
        img3[i].WinTop = img3[i-1].WinTop;
        img3[i].WinLeft = img3[i-1].WinLeft + 0.300000;
    }
    else
    {
        img3[i].WinTop = img3[i-1].WinTop + 0.150000;
        img3[i].WinLeft = 0.075000;
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
    if(INVInventory != none)
    {
        if(INVInventory.PStart > 0 && INVInventory.PStart+1 > INVInventory.MutINV.BuyableItems.Length)
            INVInventory.PStart -= Slots;
        PageNum.Caption = "Page:" @ ((INVInventory.PStart / Slots)+1);
    }

    if(INVInventory != none && INVInventory.MutINV.BuyableItems.Length > 0)
    {
        for(i=0;i<img2.Length;i++)
        {
           if(INVInventory.MutINV.BuyableItems.Length-INVInventory.PStart > i)
           {
               img2[i].OnClick = LeftClick;
               img2[i].Image = INVInventory.MutInv.BuyableItems[i+INVInventory.PStart].ItemClass.default.Image;
               img2[i].ExternalItemCopy = INVInventory.MutInv.BuyableItems[i+INVInventory.PStart].ItemClass;
               img2[i].DataRepNum = i+INVInventory.PStart;
               img2[i].SetHint(INVInventory.MutInv.BuyableItems[i+INVInventory.PStart].ItemClass.static.GetInvItemName(C) @ "- Cost:" @ abs(INVInventory.MutInv.BuyableItems[i+INVInventory.PStart].ItemClass.default.BuyPrice));
               img2[i].OnRightClick = InternalOnRightClick;
               img3[i].Caption = string(INVInventory.MutINV.BuyableItems[i+INVInventory.PStart].Amount);
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
    local PlayerController C;

    C = PlayerOwner();
    if(!InvImages(Sender).bRightClick)
        C.ClientMessage("(" $InvImages(Sender).ExternalItemCopy.static.GetInvItemName(C) $ ")" @ "Cost:" @ abs(InvImages(Sender).ExternalItemCopy.default.BuyPrice));
    InvImages(Sender).bRightClick = false;
    return true;
}

function bool NextPge(GUIComponent Sender)
{
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(INVInventory.PStart+Slots < INVInventory.MutINV.BuyableItems.Length)
    {
        INVInventory.PStart += Slots;
        UpdateImages();
        CheckDisable();
    }
    return true;
}

function bool PrevPge(GUIComponent Sender)
{
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(INVInventory.PStart > 0)
    {
        INVInventory.PStart -= Slots;
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

    if(INVInventory.PStart <= 0)
        PrvPage.MenuStateChange(MSAT_Disabled);

    if(INVInventory.PStart > 0 && INVInventory.PStart+Slots < INVInventory.MutINV.BuyableItems.Length)
    {
        PrvPage.MenuStateChange(MSAT_Blurry);
        NxtPage.MenuStateChange(MSAT_Blurry);
    }

    if(INVInventory.PStart+Slots >= INVInventory.MutINV.BuyableItems.Length)
        NxtPage.MenuStateChange(MSAT_Disabled);
}

defaultproperties
{
     EmptySlotImage=Texture'2K4Menus.NewControls.ComboListDropdown'
     Slots=15
     LabelColour=(B=255,G=255,R=255,A=255)
     Begin Object Class=GUILabel Name=Page
         Caption="Page: 1"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.037500
         WinLeft=0.075000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     PageNum=GUILabel'sonicRPG45.ShopGUI.Page'

     Begin Object Class=GUIButton Name=CloseButton
         Caption="Close"
         WinTop=0.900000
         WinLeft=0.525000
         WinWidth=0.400000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=ShopGUI.XButtonClicked
         OnKeyEvent=CloseButton.InternalOnKeyEvent
     End Object
     CloseWindowButton=GUIButton'sonicRPG45.ShopGUI.CloseButton'

     Begin Object Class=GUIButton Name=Next
         Caption="Next"
         WinTop=0.850000
         WinLeft=0.075000
         WinWidth=0.400000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=ShopGUI.NextPge
         OnKeyEvent=Next.InternalOnKeyEvent
     End Object
     NxtPage=GUIButton'sonicRPG45.ShopGUI.Next'

     Begin Object Class=GUIButton Name=Prev
         Caption="Prev"
         WinTop=0.900000
         WinLeft=0.075000
         WinWidth=0.400000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=ShopGUI.PrevPge
         OnKeyEvent=Prev.InternalOnKeyEvent
     End Object
     PrvPage=GUIButton'sonicRPG45.ShopGUI.Prev'

     WindowName="Shop"
     bResizeWidthAllowed=False
     bResizeHeightAllowed=False
     DefaultLeft=300.000000
     DefaultTop=75.000000
     DefaultWidth=0.250000
     DefaultHeight=0.500000
     bAllowedAsLast=True
     WinTop=75.000000
     WinLeft=300.000000
     WinWidth=0.250000
}
