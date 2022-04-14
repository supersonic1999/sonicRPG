class TradeGUI extends FloatingWindow;

var Material EmptySlotImage;
var int Slots;
var bool bAccepted;
var color LabelColour;
var array<GUILabel> img3, img6, img9;
var array<TradeImage> img1, img2, img4, img5, img7, img8;

var automated GUILabel CreditsPLUS, CreditsMINUS, PageNum, Credits, CreditsName, SentName, RecievedName, CurrentName, AcceptedLabel;
var automated GUIButton CloseWindowButton, AcceptWindowButton, NxtPage1, NxtPage2, NxtPage3, PrvPage1, PrvPage2, PrvPage3, Plus, Minus;
var automated GUIImage CreditsBGPLUS, CreditsBGMINUS;
var automated GUINumericEdit CAdd;

function OnOpen()
{
    local int Num;
    local INVInventory INVInventory;

    super.OnOpen();

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(INVInventory != none)
    {
        INVInventory.ChangeTradeVar(true);
        INVInventory.Trade = self;

        while(Num < Slots)
        {
            CreateInventory(img1, img2, img3, 0.100000, 0.025000, 0.025000, 0.025000, class'TradeMainImage');
            CreateInventory(img4, img5, img6, 0.600000, 0.025000, 0.025000, 0.025000, class'TradeImage');
            CreateInventory(img7, img8, img9, 0.100000, 0.524000, 0.025000, 0.025000, class'TradeLastImage');
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
        INVInventory.Trade = none;
        INVInventory.ClientResetTrade();
    }
    super.OnClose(bCancelled);
}

function CreateInventory(out array<InvImages> Image1, out array<InvImages> Image2, out array<GUILabel> Image3,
                         float TopStart, float LeftStart, float RowVertSpace, float RowHorizontalSpace,
                         class<InvImages> Image)
{
	local PlayerController P;
	local int i;

    P = PlayerOwner();

    if(Image1.length == 0)
    {
        Image1[0] = new Image;
        Image1[0].WinTop = TopStart;
        Image1[0].WinLeft = LeftStart;
        Image1[0].Image = EmptySlotImage;
        AppendComponent(Image1[0], true);

        Image2[0] = new Image;
        Image2[0].WinTop = TopStart;
        Image2[0].WinLeft = LeftStart;
        Image2[0].ImageStyle = ISTY_Scaled;
        Image2[0].OnRightClick = InternalOnRightClickOff;
        AppendComponent(Image2[0], true);

        Image3[0] = new class'GUILabel';
        Image3[0].WinTop = TopStart;
        Image3[0].WinLeft = LeftStart;
        Image3[0].TextColor = LabelColour;
        AppendComponent(Image3[0], true);
        return;
    }

    i = Image1.Length;

    Image1[i] = new Image;
    if(int(Image1[i-1].WinLeft * 1000) != int((LeftStart + (RowHorizontalSpace * 2) + (Image1[0].WinWidth * 2)) * 1000))
    {
        Image1[i].WinTop = Image1[i-1].WinTop;
        Image1[i].WinLeft = Image1[i-1].WinLeft + (Image1[0].WinWidth + RowHorizontalSpace);
    }
    else
    {
        Image1[i].WinTop = Image1[i-1].WinTop + (Image1[0].WinHeight + RowVertSpace);
        Image1[i].WinLeft = LeftStart;
    }
    Image1[i].Image = EmptySlotImage;
    AppendComponent(Image1[i], true);

    Image2[i] = new Image;
    if(int(Image2[i-1].WinLeft * 1000) != int((LeftStart + (RowHorizontalSpace * 2) + (Image2[0].WinWidth * 2)) * 1000))
    {
        Image2[i].WinTop = Image2[i-1].WinTop;
        Image2[i].WinLeft = Image2[i-1].WinLeft + (Image2[0].WinWidth + RowHorizontalSpace);
    }
    else
    {
        Image2[i].WinTop = Image2[i-1].WinTop + (Image2[0].WinHeight + RowVertSpace);
        Image2[i].WinLeft = LeftStart;
    }
    Image2[i].ImageStyle = ISTY_Scaled;
    Image2[i].OnRightClick = InternalOnRightClickOff;
    AppendComponent(Image2[i], true);

    Image3[i] = new class'GUILabel';
    if(int(Image3[i-1].WinLeft * 1000) != int((LeftStart + (RowHorizontalSpace * 2) + (Image2[0].WinWidth * 2)) * 1000))
    {
        Image3[i].WinTop = Image3[i-1].WinTop;
        Image3[i].WinLeft = Image3[i-1].WinLeft + (Image2[0].WinWidth + RowHorizontalSpace);
    }
    else
    {
        Image3[i].WinTop = Image3[i-1].WinTop + (Image2[0].WinHeight + RowVertSpace);
        Image3[i].WinLeft = LeftStart;
    }
    Image3[i].TextColor = LabelColour;
    AppendComponent(Image3[i], true);
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
        CreditsPLUS.Caption = "Recieve" @ INVInventory.TradeReplicationInfo.CurTrader.CreditsExchanged;
        CreditsMINUS.Caption = "Send" @ INVInventory.TradeReplicationInfo.CreditsExchanged;
        Credits.Caption = "C" @ INVInventory.DataRep.Credits;
    }

    //Top left item.
    if(INVInventory != none && INVInventory.TradeReplicationInfo.TradedItems.Length > 0)
    {
        for(i=0;i<img2.Length;i++)
        {
           if(INVInventory.TradeReplicationInfo.TradedItems.Length-INVInventory.PageNum1 > i)
           {
               img2[i].Image = INVInventory.TradeReplicationInfo.TradedItems[i+INVInventory.PageNum1].Items.default.Image;
               img2[i].ExternalItemCopy = INVInventory.TradeReplicationInfo.TradedItems[i+INVInventory.PageNum1].Items;
               img2[i].DataRepNum = i+INVInventory.PageNum1;
               img2[i].SetHint(INVInventory.TradeReplicationInfo.TradedItems[i+INVInventory.PageNum1].Items.static.GetInvItemName(C));
               img2[i].OnRightClick = InternalOnRightClick;
               img2[i].bDropSource = true;
               img3[i].bDropTarget = true;
               img3[i].Caption = string(INVInventory.TradeReplicationInfo.TradedItems[i+INVInventory.PageNum1].Amount);
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
        img2[0].bDropSource = false;
        img2[0].bDropTarget = false;
        img3[0].bVisible = false;
    }

    //Bottom left items.
    if(INVInventory != none && INVInventory.DataRep.Items.Length > 0)
    {
        for(i=0;i<img5.Length;i++)
        {
           if(INVInventory.DataRep.Items.Length-INVInventory.PageNum2 > i)
           {
               img5[i].Image = INVInventory.DataRep.Items[i+INVInventory.PageNum2].default.Image;
               img5[i].ExternalItemCopy = INVInventory.DataRep.Items[i+INVInventory.PageNum2];
               img5[i].DataRepNum = i+INVInventory.PageNum2;
               img5[i].SetHint(INVInventory.DataRep.Items[i+INVInventory.PageNum2].static.GetInvItemName(C));
               img5[i].OnRightClick = InternalOnRightClick;
               img5[i].bDropSource = true;
               img6[i].bDropTarget = true;
               img6[i].Caption = string(INVInventory.DataRep.ItemsAmount[i+INVInventory.PageNum2]);
               img6[i].bVisible = true;
           }
           else
           {
               img5[i].OnClick = None;
               img5[i].Image = None;
               img5[i].ExternalItemCopy = None;
               img5[i].SetHint("");
               img5[i].OnRightClick = InternalOnRightClickOff;
               img5[i].bDropSource = false;
               img5[i].bDropTarget = false;
               img6[i].bVisible = false;
           }
        }
    }
    else
    {
        img5[0].OnClick = None;
        img5[0].ExternalItemCopy = None;
        img5[0].Image = None;
        img5[0].SetHint("");
        img5[0].OnRightClick = InternalOnRightClickOff;
        img5[0].bDropSource = false;
        img5[0].bDropTarget = false;
        img6[0].bVisible = false;
    }

    //Top right items.
    if(INVInventory != none && INVInventory.TradeReplicationInfo.RepTradedItems.Length > 0)
    {
        for(i=0;i<img8.Length;i++)
        {
           if(INVInventory.TradeReplicationInfo.RepTradedItems.Length-INVInventory.PageNum3 > i)
           {
               img8[i].Image = INVInventory.TradeReplicationInfo.RepTradedItems[i+INVInventory.PageNum3].Items.default.Image;
               img8[i].ExternalItemCopy = INVInventory.TradeReplicationInfo.RepTradedItems[i+INVInventory.PageNum3].Items;
               img8[i].DataRepNum = i+INVInventory.PageNum3;
               img8[i].SetHint(INVInventory.TradeReplicationInfo.RepTradedItems[i+INVInventory.PageNum3].Items.static.GetInvItemName(C));
               img8[i].OnRightClick = InternalOnRightClick;
               img8[i].bDropSource = true;
               img9[i].bDropTarget = true;
               img9[i].Caption = string(INVInventory.TradeReplicationInfo.RepTradedItems[i+INVInventory.PageNum3].Amount);
               img9[i].bVisible = true;
           }
           else
           {
               img8[i].OnClick = None;
               img8[i].Image = None;
               img8[i].ExternalItemCopy = None;
               img8[i].SetHint("");
               img8[i].OnRightClick = InternalOnRightClickOff;
               img8[i].bDropSource = false;
               img8[i].bDropTarget = false;
               img9[i].bVisible = false;
           }
        }
    }
    else
    {
        img8[0].OnClick = None;
        img8[0].ExternalItemCopy = None;
        img8[0].Image = None;
        img8[0].SetHint("");
        img8[0].OnRightClick = InternalOnRightClickOff;
        img8[0].bDropSource = false;
        img8[0].bDropTarget = false;
        img9[0].bVisible = false;
    }
    CheckDisable();
}

simulated function bool Accepted(GUIComponent Sender)
{
    class'mutInventorySystem'.static.FindINVInventory(PlayerOwner()).ClientSetbAcceptedTrade(true);
    return true;
}

simulated function bool Declined(GUIComponent Sender)
{
    return XButtonClicked(Sender);
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

function bool NextPge(GUIComponent Sender)
{
   	local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(Sender == NxtPage1 && INVInventory.PageNum1+Slots < INVInventory.DataRep.Slots)
    {
        INVInventory.PageNum1 += Slots;
        UpdateImages();
        CheckDisable();
    }
    else if(Sender == NxtPage2 && INVInventory.PageNum2+Slots < INVInventory.DataRep.Slots)
    {
        INVInventory.PageNum2 += Slots;
        UpdateImages();
        CheckDisable();
    }
    else if(Sender == NxtPage3 && INVInventory.PageNum3+Slots < INVInventory.DataRep.Slots)
    {
        INVInventory.PageNum3 += Slots;
        UpdateImages();
        CheckDisable();
    }
    return true;
}

function bool PrevPge(GUIComponent Sender)
{
   	local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(Sender == PrvPage1 && INVInventory.PageNum1 > 0)
    {
        INVInventory.PageNum1 -= Slots;
        UpdateImages();
        CheckDisable();
    }
    else if(Sender == PrvPage2 && INVInventory.PageNum2 > 0)
    {
        INVInventory.PageNum2 -= Slots;
        UpdateImages();
        CheckDisable();
    }
    else if(Sender == PrvPage3 && INVInventory.PageNum3 > 0)
    {
        INVInventory.PageNum3 -= Slots;
        UpdateImages();
        CheckDisable();
    }
    return true;
}

function bool ChangeCredits(GUIComponent Sender)
{
    local INVInventory INVInventory;

   	INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(INVInventory != none && Sender == Plus)
        INVInventory.ClientChangeExchangedCredits(int(CAdd.Value));
    else if(INVInventory != none && Sender == Minus)
        INVInventory.ClientChangeExchangedCredits(-int(CAdd.Value));
    return true;
}

function CancelTradeAccept()
{
   	local int i;

    for(i=0;i<img1.length;i++)
    {
        img1[i].MenuStateChange(MSAT_Blurry);
        img2[i].MenuStateChange(MSAT_Blurry);
        img3[i].MenuStateChange(MSAT_Blurry);
        img4[i].MenuStateChange(MSAT_Blurry);
        img5[i].MenuStateChange(MSAT_Blurry);
        img6[i].MenuStateChange(MSAT_Blurry);
        img7[i].MenuStateChange(MSAT_Blurry);
        img8[i].MenuStateChange(MSAT_Blurry);
        img9[i].MenuStateChange(MSAT_Blurry);
    }
    Minus.MenuStateChange(MSAT_Blurry);
    Plus.MenuStateChange(MSAT_Blurry);
    CAdd.MenuStateChange(MSAT_Blurry);
    AcceptWindowButton.MenuStateChange(MSAT_Blurry);
    class'mutInventorySystem'.static.FindINVInventory(PlayerOwner()).ClientSetbAcceptedTrade(false);
    AcceptedLabel.SetVisibility(false);
}

function CheckDisable()
{
   	local INVInventory INVInventory;
   	local int i;

   	INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(INVInventory != none && INVInventory.bAcceptedTrade)
    {
        for(i=0;i<img1.length;i++)
        {
            img1[i].MenuStateChange(MSAT_Disabled);
            img2[i].MenuStateChange(MSAT_Disabled);
            img3[i].MenuStateChange(MSAT_Disabled);
            img4[i].MenuStateChange(MSAT_Disabled);
            img5[i].MenuStateChange(MSAT_Disabled);
            img6[i].MenuStateChange(MSAT_Disabled);
            img7[i].MenuStateChange(MSAT_Disabled);
            img8[i].MenuStateChange(MSAT_Disabled);
            img9[i].MenuStateChange(MSAT_Disabled);
        }
        Minus.MenuStateChange(MSAT_Disabled);
        Plus.MenuStateChange(MSAT_Disabled);
        CAdd.MenuStateChange(MSAT_Disabled);
        AcceptWindowButton.MenuStateChange(MSAT_Disabled);
    }

    if(INVInventory != none)
    {
        if(INVInventory.PageNum1 <= 0)
            PrvPage1.MenuStateChange(MSAT_Disabled);

        if(INVInventory.PageNum1 > 0)
            PrvPage1.MenuStateChange(MSAT_Blurry);

        if(INVInventory.PageNum1+Slots < INVInventory.TradeReplicationInfo.TradedItems.Length)
            NxtPage1.MenuStateChange(MSAT_Blurry);

        if(INVInventory.PageNum1+Slots >= INVInventory.TradeReplicationInfo.TradedItems.Length)
            NxtPage1.MenuStateChange(MSAT_Disabled);

        if(INVInventory.PageNum2 <= 0)
            PrvPage2.MenuStateChange(MSAT_Disabled);

        if(INVInventory.PageNum2 > 0)
            PrvPage2.MenuStateChange(MSAT_Blurry);

        if(INVInventory.PageNum2+Slots < INVInventory.DataRep.Items.Length)
            NxtPage2.MenuStateChange(MSAT_Blurry);

        if(INVInventory.PageNum2+Slots >= INVInventory.DataRep.Items.Length)
            NxtPage2.MenuStateChange(MSAT_Disabled);

        if(INVInventory.PageNum3 <= 0)
            PrvPage3.MenuStateChange(MSAT_Disabled);

        if(INVInventory.PageNum3 > 0)
            PrvPage3.MenuStateChange(MSAT_Blurry);

        if(INVInventory.PageNum3+Slots < INVInventory.TradeReplicationInfo.CurTrader.TradedItems.Length)
            NxtPage3.MenuStateChange(MSAT_Blurry);

        if(INVInventory.PageNum3+Slots >= INVInventory.TradeReplicationInfo.CurTrader.TradedItems.Length)
            NxtPage3.MenuStateChange(MSAT_Disabled);
    }
}

defaultproperties
{
     EmptySlotImage=Texture'2K4Menus.NewControls.ComboListDropdown'
     Slots=6
     LabelColour=(B=255,G=255,R=255,A=255)
     Begin Object Class=GUILabel Name=Money
         Caption="Recieve 0"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.600000
         WinLeft=0.500000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     CreditsPLUS=GUILabel'sonicRPG45.TradeGUI.Money'

     Begin Object Class=GUILabel Name=Money2
         Caption="Send 0"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.680000
         WinLeft=0.500000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     CreditsMINUS=GUILabel'sonicRPG45.TradeGUI.Money2'

     Begin Object Class=GUILabel Name=ShownCreds
         Caption="C 0"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.820000
         WinLeft=0.500000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Credits=GUILabel'sonicRPG45.TradeGUI.ShownCreds'

     Begin Object Class=GUILabel Name=Name1
         Caption="Credits: Send / Recieve"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.550000
         WinLeft=0.500000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     CreditsName=GUILabel'sonicRPG45.TradeGUI.Name1'

     Begin Object Class=GUILabel Name=Name2
         Caption="Items To Be Sent"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.050000
         WinLeft=0.090000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     SentName=GUILabel'sonicRPG45.TradeGUI.Name2'

     Begin Object Class=GUILabel Name=Name3
         Caption="Items To Be Recieved"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.050000
         WinLeft=0.550000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     RecievedName=GUILabel'sonicRPG45.TradeGUI.Name3'

     Begin Object Class=GUILabel Name=Name4
         Caption="Available Items"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.550000
         WinLeft=0.100000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     CurrentName=GUILabel'sonicRPG45.TradeGUI.Name4'

     Begin Object Class=GUILabel Name=Accept
         Caption="Trader has accepted."
         TextColor=(B=255,G=255,R=255)
         WinTop=0.450000
         WinLeft=0.500000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         bVisible=False
     End Object
     AcceptedLabel=GUILabel'sonicRPG45.TradeGUI.Accept'

     Begin Object Class=GUIButton Name=DeclineButton
         Caption="Decline"
         WinTop=0.900000
         WinLeft=0.550000
         WinWidth=0.200000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=TradeGUI.Declined
         OnKeyEvent=DeclineButton.InternalOnKeyEvent
     End Object
     CloseWindowButton=GUIButton'sonicRPG45.TradeGUI.DeclineButton'

     Begin Object Class=GUIButton Name=AcceptButton
         Caption="Accept"
         WinTop=0.900000
         WinLeft=0.750000
         WinWidth=0.200000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=TradeGUI.Accepted
         OnKeyEvent=AcceptButton.InternalOnKeyEvent
     End Object
     AcceptWindowButton=GUIButton'sonicRPG45.TradeGUI.AcceptButton'

     Begin Object Class=GUIButton Name=Next1
         Caption="Next"
         WinTop=0.400000
         WinLeft=0.037500
         WinWidth=0.200000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=TradeGUI.NextPge
         OnKeyEvent=Next1.InternalOnKeyEvent
     End Object
     NxtPage1=GUIButton'sonicRPG45.TradeGUI.Next1'

     Begin Object Class=GUIButton Name=Next2
         Caption="Next"
         WinTop=0.900000
         WinLeft=0.037500
         WinWidth=0.200000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=TradeGUI.NextPge
         OnKeyEvent=Next2.InternalOnKeyEvent
     End Object
     NxtPage2=GUIButton'sonicRPG45.TradeGUI.Next2'

     Begin Object Class=GUIButton Name=Next3
         Caption="Next"
         WinTop=0.400000
         WinLeft=0.537500
         WinWidth=0.200000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=TradeGUI.NextPge
         OnKeyEvent=Next3.InternalOnKeyEvent
     End Object
     NxtPage3=GUIButton'sonicRPG45.TradeGUI.Next3'

     Begin Object Class=GUIButton Name=Prev1
         Caption="Prev"
         WinTop=0.400000
         WinLeft=0.237500
         WinWidth=0.200000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=TradeGUI.PrevPge
         OnKeyEvent=Prev1.InternalOnKeyEvent
     End Object
     PrvPage1=GUIButton'sonicRPG45.TradeGUI.Prev1'

     Begin Object Class=GUIButton Name=Prev2
         Caption="Prev"
         WinTop=0.900000
         WinLeft=0.237500
         WinWidth=0.200000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=TradeGUI.PrevPge
         OnKeyEvent=Prev2.InternalOnKeyEvent
     End Object
     PrvPage2=GUIButton'sonicRPG45.TradeGUI.Prev2'

     Begin Object Class=GUIButton Name=Prev3
         Caption="Prev"
         WinTop=0.400000
         WinLeft=0.737500
         WinWidth=0.200000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=TradeGUI.PrevPge
         OnKeyEvent=Prev3.InternalOnKeyEvent
     End Object
     PrvPage3=GUIButton'sonicRPG45.TradeGUI.Prev3'

     Begin Object Class=GUIButton Name=P1
         Caption="+"
         WinTop=0.750000
         WinLeft=0.860000
         WinWidth=0.060000
         WinHeight=0.060000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=TradeGUI.ChangeCredits
         OnKeyEvent=P1.InternalOnKeyEvent
     End Object
     Plus=GUIButton'sonicRPG45.TradeGUI.P1'

     Begin Object Class=GUIButton Name=m1
         Caption="-"
         WinTop=0.750000
         WinLeft=0.920000
         WinWidth=0.060000
         WinHeight=0.060000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=TradeGUI.ChangeCredits
         OnKeyEvent=m1.InternalOnKeyEvent
     End Object
     Minus=GUIButton'sonicRPG45.TradeGUI.m1'

     Begin Object Class=GUIImage Name=CImage
         Image=Texture'2K4Menus.NewControls.ComboListDropdown'
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.600000
         WinLeft=0.500000
         WinWidth=0.350000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     CreditsBGPLUS=GUIImage'sonicRPG45.TradeGUI.CImage'

     Begin Object Class=GUIImage Name=CImage2
         Image=Texture'2K4Menus.NewControls.ComboListDropdown'
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.680000
         WinLeft=0.500000
         WinWidth=0.350000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     CreditsBGMINUS=GUIImage'sonicRPG45.TradeGUI.CImage2'

     Begin Object Class=GUINumericEdit Name=CreditsAdd
         Value="10000"
         MinValue=1
         MaxValue=100000000
         WinTop=0.750000
         WinLeft=0.500000
         WinWidth=0.350000
         OnDeActivate=CreditsAdd.ValidateValue
     End Object
     CAdd=GUINumericEdit'sonicRPG45.TradeGUI.CreditsAdd'

     WindowName="Trade Menu"
     bResizeWidthAllowed=False
     bResizeHeightAllowed=False
     DefaultLeft=75.000000
     DefaultTop=75.000000
     DefaultWidth=0.500000
     DefaultHeight=0.500000
     bAllowedAsLast=True
     WinTop=75.000000
     WinLeft=75.000000
     WinWidth=0.500000
}
