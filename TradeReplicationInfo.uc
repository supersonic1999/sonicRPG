class TradeReplicationInfo extends ReplicationInfo;

struct TradeStruct
{
   var class<MainInventoryItem> Items;
   var int Amount;
};
struct RepTradeStruct
{
   var class<MainInventoryItem> Items;
   var int Amount;
};
var array<TradeStruct> TradedItems;
var array<RepTradeStruct> RepTradedItems;
var int CreditsExchanged, OldCreditsExchanged;
var TradeReplicationInfo CurTrader;
var INVInventory myINVInventory;

replication
{
	reliable if(bNetDirty && Role==ROLE_Authority)
		CurTrader, CreditsExchanged, myINVInventory;
}

simulated event PostNetReceive()
{
    if(myINVInventory != none
    && CurTrader != none
    && CurTrader.myINVInventory != none
    && OldCreditsExchanged != CreditsExchanged)
    {
        OldCreditsExchanged = CreditsExchanged;
        CurTrader.myINVInventory.ClientbUpdateImages(true);
        myINVInventory.ClientbUpdateImages(true);
    }
    super.PostNetReceive();
}

function UpdateClientTradeArray()
{
    local int x;

    if(Role != ROLE_Authority || CurTrader == none || CurTrader.myINVInventory == none)
        return;

    if(TradedItems.length > 0)
    {
        for(x=0;x<TradedItems.length;x++)
        {
            myINVInventory.UpdateServerTradeArray(TradedItems[x].Items, TradedItems[x].Amount, x, TradedItems.Length);
            CurTrader.myINVInventory.UpdateRepServerTradeArray(TradedItems[x].Items, TradedItems[x].Amount, x, TradedItems.Length);
        }
    }
    else
    {
        myINVInventory.UpdateServerTradeArray(none, 0, 0, TradedItems.Length);
        CurTrader.myINVInventory.UpdateRepServerTradeArray(none, 0, 0, TradedItems.Length);
    }
    CurTrader.myINVInventory.ServerSetbAcceptedTrade(false);
}

function ServerChangeTradedItems(class<MainInventoryItem> Items, int Amount)
{
    local int i, x;
    local bool bHasItem, bHasTradedItem;
    local PlayerController Controller;

    if(Role != ROLE_Authority || Items == none
    || myINVInventory == none || myINVInventory.DataObject == none
    || CurTrader == none || CurTrader.myINVInventory == none
    || !myINVInventory.bTradeOpen)
        return;
    else if(!Items.default.bTradable)
    {
        Controller = myINVInventory.FindOwnerController();
        if(Controller != none)
            Controller.ClientMessage(myINVInventory.ItemUntradable);
        return;
    }

    for(i=0;i<myINVInventory.DataObject.Items.Length;i++)
    {
        if(myINVInventory.DataObject.Items[i] == Items)
        {
            bHasItem = True;
            break;
        }
    }

    if(!bHasItem)
        return;

    for(x=0;x<TradedItems.Length;x++)
    {
        if(TradedItems[x].Items == Items)
        {
            bHasTradedItem = True;
            break;
        }
    }

    if(!bHasTradedItem && Amount >= 0)
    {
        if(CurTrader.myINVInventory.DataObject.Items.Length + TradedItems.Length + 1 > CurTrader.myINVInventory.DataObject.Slots)
        {
            Controller = myINVInventory.FindOwnerController();
            if(Controller != none)
                Controller.ClientMessage(myINVInventory.TraderFull);
            return;
        }
        TradedItems.Insert(TradedItems.Length, 1);
        TradedItems[TradedItems.Length-1].Items = Items;
        TradedItems[TradedItems.Length-1].Amount = Min(myINVInventory.DataObject.ItemsAmount[i], Max(Amount, 1));
        UpdateClientTradeArray();
        return;
    }
    else if(bHasTradedItem)
    {
        if(Amount > 0 && TradedItems[x].Amount >= myINVInventory.DataObject.ItemsAmount[i])
        {
            Controller = myINVInventory.FindOwnerController();
            if(Controller != none)
                Controller.ClientMessage(myINVInventory.AlreadyAddedMax);
            return;
        }
        TradedItems[x].Amount = Min(TradedItems[x].Amount + Amount, myINVInventory.DataObject.ItemsAmount[i]);
        if(TradedItems[x].Amount <= 0)
            TradedItems.Remove(x, 1);
        UpdateClientTradeArray();
        return;
    }
}

function ServerChangeExchangedCredits(int ChangedCredits)
{
    if(Role != ROLE_Authority || myINVInventory == none || myINVInventory.DataObject == none)
        return;

    CreditsExchanged = Min(myINVInventory.DataObject.Credits, Max(CreditsExchanged + ChangedCredits, 0));
}

function Timer()
{
    if(myINVInventory != none
    && CurTrader != none
    && CurTrader.myINVInventory != none
    && !myINVInventory.bTradeOpen)
    {
        if(CurTrader.myINVInventory.Instigator != none)
            CurTrader.myINVInventory.Instigator.ClientMessage("Trade request sent to" @ myINVInventory.Instigator.GetHumanReadableName() @ "timed out.");
        myINVInventory.bTradeAvailable = false;
        CurTrader.CurTrader = none;
        CurTrader = none;
    }
    super.Timer();
}

simulated function Destroyed()
{
	CurTrader = none;
    myINVInventory = none;
	Super.Destroyed();
}

defaultproperties
{
     bNetNotify=True
}
