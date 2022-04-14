class TradeSellAmountGUI extends FloatingWindow;

var automated GUILabel Label;
var automated GUINumericEdit InputBox;
var automated GUIButton CloseWindowButton, AcceptWindowButton;

function OnOpen()
{
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

	if(INVInventory != none)
	{
        INVInventory.bAmountOpen = true;
        INVInventory.Amount = self;
    }
}

function OnClose(optional bool bCancelled)
{
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(INVInventory != none)
    {
        INVInventory.bAmountOpen = false;
        INVInventory.Amount = none;
    }
}

function bool AcceptAmount(GUIComponent Sender)
{
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());
    INVInventory.ClientChangeTradedItems(INVInventory.DataRep.Items[INVInventory.XItemNum], -int(InputBox.Value));
    INVInventory.TradeReplicationInfo.CurTrader.myINVInventory.ClientSetbAcceptedTrade(false);
    INVInventory.TradeReplicationInfo.CurTrader.myINVInventory.ClientbUpdateImages(true);
    INVInventory.Trade.UpdateImages();
    return true;
}

function int FindTradedItemAmount()
{
    local int i;
    local Inventory Inv;
    local INVInventory INVInventory;

    INVInventory = INVInventory(PlayerOwner().Pawn.FindInventoryType(class'INVInventory'));
    if(PlayerOwner() != none && INVInventory == none)
	{
        for(Inv = PlayerOwner().Inventory; Inv != None; Inv = Inv.Inventory)
    	{
    		INVInventory = INVInventory(Inv);
    		if(INVInventory != None)
    			break;
    	}
	}

    for(i=0;i<INVInventory.TradeReplicationInfo.TradedItems.length;i++)
        if(INVInventory.TradeReplicationInfo.TradedItems[i].Items == INVInventory.DataRep.Items[INVInventory.XItemNum])
            return INVInventory.TradeReplicationInfo.TradedItems[i].Amount;
    return 0;
}

defaultproperties
{
     Begin Object Class=GUILabel Name=XNum
         Caption="X ="
         TextColor=(B=255,G=255,R=255)
         WinTop=0.300000
         WinLeft=0.075000
         WinHeight=0.250000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Label=GUILabel'sonicRPG45.TradeSellAmountGUI.XNum'

     Begin Object Class=GUINumericEdit Name=Box
         Value="1"
         MinValue=1
         WinTop=0.300000
         WinLeft=0.300000
         WinWidth=0.500000
         WinHeight=0.250000
         bBoundToParent=True
         bScaleToParent=True
         OnDeActivate=Box.ValidateValue
     End Object
     InputBox=GUINumericEdit'sonicRPG45.TradeSellAmountGUI.Box'

     Begin Object Class=GUIButton Name=CloseButton
         Caption="Close"
         WinTop=0.600000
         WinLeft=0.075000
         WinWidth=0.400000
         WinHeight=0.250000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=TradeSellAmountGUI.XButtonClicked
         OnKeyEvent=CloseButton.InternalOnKeyEvent
     End Object
     CloseWindowButton=GUIButton'sonicRPG45.TradeSellAmountGUI.CloseButton'

     Begin Object Class=GUIButton Name=AcceptButton
         Caption="Accept"
         WinTop=0.600000
         WinLeft=0.500000
         WinWidth=0.400000
         WinHeight=0.250000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=TradeSellAmountGUI.AcceptAmount
         OnKeyEvent=AcceptButton.InternalOnKeyEvent
     End Object
     AcceptWindowButton=GUIButton'sonicRPG45.TradeSellAmountGUI.AcceptButton'

     WindowName="X Amount"
     bResizeWidthAllowed=False
     bResizeHeightAllowed=False
     DefaultLeft=0.350000
     DefaultTop=0.450000
     DefaultWidth=0.150000
     DefaultHeight=0.050000
     bAllowedAsLast=True
     WinTop=0.500000
     WinLeft=0.500000
     WinWidth=0.150000
     WinHeight=0.050000
}
