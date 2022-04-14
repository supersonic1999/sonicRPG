class INVInventory extends Inventory
	DependsOn(InventoryPlayerDataObject)
    config(INVInventory);

//Object refrences.
var InventoryPlayerDataObject DataObject;
var InventoryPlayerDataObject.InventoryPlayerData DataRep;
var InventoryGUI GUI;
var ShopGUI Shop;
var TradeGUI Trade;
var LootGUI Loot;
var MissionGUI MissionGUI;
var InformationGUI Information;
var FloatingWindow Amount;
var MissionInfoGUI MissionInfoGUI;
var StatsGUI StatsGUI;

//Actor refrences.
var mutInventorySystem MutINV;
var TradeReplicationInfo TradeReplicationInfo;

struct ItemDelayStruct
{
    var float LastUsed;
    var class<MainInventoryItem> LastItemClass;
};
var array<ItemDelayStruct> ItemDelay;
var array<class<MainInventoryItem> > LootedItems;
var array<int> LootedItemsAmount;

var class<MainInventoryItem> InfoClass, CurrentItemSelected;
var class<MissionFile> MissionItem, OldCurrentMission;

var config class<MainInventoryItem> SelectedItems[10];
var protected config string PHPPass;

var protected string PlayerName;
var int PStart, IStart, LStart, DeleteNum, XItemNum, PageNum1, PageNum2, PageNum3, DragStartNum, ItemUserPage, PlayerSpawnTime;
var bool bShopOpen, bInventoryOpen, bAmountOpen, bInformationOpen, bDeleteOpen, bSellOpen, bHelpOpen, bSellAmount, bMissionOpen, bMissionEndOpen,
         bTradeOpen, bLootOpen, RemoveInventoryItem, OldbAcceptedTrade, bAcceptedTrade, bTradeAvailable, bUpdateImages, bMissionInfoOpen,
         bStatsGUIOpen;

var localized string ItemUnsellable, ItemUntradable, ItemOutOfStock, NoMoreSlots, TraderFull, AlreadyAddedMax, NotEnoughCredits,
                     MissionAlreadyCompleted, AlreadyHaveMission, ItemHasBeenUsed;

replication
{
	reliable if(bNetDirty && Role==ROLE_Authority)
		MutINV, DataRep, bTradeAvailable, bTradeOpen, TradeReplicationInfo, bAcceptedTrade, bUpdateImages, PlayerName;
	reliable if(Role==ROLE_Authority)
		ReplicateToClientSide, ClientCheckShopItems, ClientRemoveItem, ClientAddNewItem, ClientRemoveLootedItem, ClientAddNewLootItem,
        ClientUpdateGUI, UpdateRepServerTradeArray, ReplicateLootToClientSide, ReplicateCompletedMissions,
        ClientModifyVehicle, ClientUnModifyVehicle,ClientInventoryUpdateGUI, ClientLootUpdateGUI, ClientMissionInfoUpdate,
        UpdateServerTradeArray, CloseTrade, ClientSetVisibility, ReplicateMissionObjectSuccess, ReplicateStatsToClientSide;
	reliable if(Role<ROLE_Authority)
		ClientSetbAcceptedTrade, ServerLeftClick, SellItem, AddSkillPoints, SetClass, GetNewDestination,
        ServerCheckShopItems, ClientDataUpdate, ChangeTradeVar, AcceptTrade, SwapItems, RemoveLootedItem,
		ServerChangeTradedItems, ServerChangeExchangedCredits, ChangeItem, TakeLootedItem, StartNewMission,
        ServerSetbAcceptedTrade, ServerbUpdateImages, ServerOpenTrade, ServerResetTrade, EndCurrentMission;
}

//------------------------------------------------------------------------------
//DataObject replication Related Functions.
//------------------------------------------------------------------------------
function InitialUpdate(Pawn Other)
{
    local int x;

    if(Other == none || DataObject == none)
        return;

    PlayerName = Other.GetHumanReadableName();
    PlayerSpawnTime = Level.TimeSeconds;
    for(x=0;x<DataObject.Items.length;x++)
        ReplicateToClientSide(x, DataObject.Items[x], DataObject.ItemsAmount[x]);
    for(x=0;x<LootedItems.length;x++)
        ReplicateLootToClientSide(x, LootedItems[x], LootedItemsAmount[x]);
    for(x=0;x<DataObject.CompletedMissions.Length;x++)
        ReplicateCompletedMissions(x, DataObject.CompletedMissions[x]);
    for(x=0;x<DataObject.MissionObjectSuccess.Length;x++)
        ReplicateMissionObjectSuccess(x, DataObject.MissionObjectSuccess[x]);
}

simulated function ReplicateCompletedMissions(int x, class<MissionFile> CompletedMissionClass)
{
    if(CompletedMissionClass != none)
        DataRep.CompletedMissions[x] = CompletedMissionClass;
}

simulated function ReplicateMissionObjectSuccess(int x, int MissionObjectSuccessAmount)
{
    DataRep.MissionObjectSuccess[x] = MissionObjectSuccessAmount;
}

simulated function ReplicateToClientSide(int x, class<MainInventoryItem> myItem, int myItemAmount)
{
	if(myItem != none)
	{
        DataRep.Items[x] = myItem;
        DataRep.ItemsAmount[x] = myItemAmount;
    }
}

simulated function ClientAddNewItem(class<MainInventoryItem> myItem, int myItemAmount)
{
    if(myItem != none)
	{
        DataRep.Items[DataRep.Items.Length] = myItem;
        DataRep.ItemsAmount[DataRep.ItemsAmount.Length] = myItemAmount;
    }
}

simulated function ClientRemoveItem(int Num)
{
    DataRep.Items.Remove(Num, 1);
    DataRep.ItemsAmount.Remove(Num, 1);
}

simulated function ClientAddNewLootItem(class<MainInventoryItem> myItem, int myItemAmount)
{
    if(myItem != none)
	{
        LootedItems[LootedItems.Length] = myItem;
        LootedItemsAmount[LootedItemsAmount.Length] = myItemAmount;
    }
}

simulated function ClientRemoveLootedItem(int Num)
{
    LootedItems.Remove(Num, 1);
    LootedItemsAmount.Remove(Num, 1);
}

simulated function ReplicateLootToClientSide(int x, class<MainInventoryItem> myItem, int myItemAmount)
{
	if(myItem != none)
	{
        LootedItems[x] = myItem;
        LootedItemsAmount[x] = myItemAmount;
    }
}

simulated function ReplicateStatsToClientSide(int x, int myAmount)
{
    if(X >= 0 && x < ArrayCount(DataRep.SkillLevel))
        DataRep.SkillLevel[x] = myAmount;
    if(StatsGUI != none)
        StatsGUI.UpdateStats();
}
//------------------------------------------------------------------------------
//LibHttp functions.
//------------------------------------------------------------------------------
function CreateDBTable(string PlayerName, string OwnerID)
{
    local HttpSock socket;

    socket = spawn(class'HttpSock');
    socket.OnComplete = CreateDBOnComplete;
    socket.SetFormData("PlayerName", PlayerName);
    socket.setFormData("DO", "create");
    socket.SetFormData("OwnerID", OwnerID);
    socket.setFormData("Pass", PHPPass);
    socket.post("http://unrealinsanity.com/Scripts/UI.php");
}

function CreateDBOnComplete(HttpSock Sender)
{
    local FileLog flog;
    local int i;

    flog = spawn(class'FileLog');
    flog.OpenLog("MyLibHTTPExample", "html", true);
    for (i = 0; i < Sender.ReturnData.length; i++)
        flog.Logf(Sender.ReturnData[i]);
    flog.Destroy();
}
//------------------------------------------------------------------------------
//Inventory functions.
//------------------------------------------------------------------------------
function bool ServerLeftClick(Controller Other, int x)
{
    if(DataObject != none && DataObject.Items.Length > x)
        return DataObject.Items[x].static.ServerLeftClick(Other, x);
    return false;
}

function ServerCheckShopItems()
{
    local int x;

    if(MutINV != none)
        for(x=0;x<MutINV.BuyableItems.Length;x++)
            ClientCheckShopItems(MutINV.BuyableItems[x].ItemClass, x, MutINV.BuyableItems[x].Amount, MutINV.BuyableItems.Length);
}

simulated function ClientCheckShopItems(class<MainInventoryItem> Item, int i, int iAmount, int ItemLength)
{
    if(MutINV == none || Item == none)
        return;

    MutINV.BuyableItems.Length = ItemLength;
    MutINV.BuyableItems[i].ItemClass = Item;
    MutINV.BuyableItems[i].Amount = iAmount;
}

simulated function ClientUpdateGUI()
{
    if(Shop != None)
    {
        Shop.UpdateImages();
        Shop.CheckDisable();
    }
}

simulated function ClientInventoryUpdateGUI()
{
    if(GUI != None)
    {
        GUI.UpdateImages();
        GUI.CheckDisable();
    }
}

simulated function ClientMissionInfoUpdate()
{
    if(MissionInfoGUI != none)
        MissionInfoGUI.UpdateDescription();
}

simulated function ClientLootUpdateGUI()
{
    if(Loot != None)
    {
        Loot.UpdateImages();
        Loot.CheckDisable();
    }
}

simulated function int GetMissionPoints()
{
    local int i, Points;

    for(i=0;i<DataRep.CompletedMissions.Length;i++)
        if(DataRep.CompletedMissions[i] != none)
            Points += DataRep.CompletedMissions[i].static.GetDefaultMissionPointsAwarded();
    return Points;
}

simulated function String GetHumanReadableName()
{
	if(Instigator != none)
        return Instigator.GetHumanReadableName();
    else if(Owner != none)
        return Owner.GetHumanReadableName();
    return PlayerName;
}

function PlayerController FindOwnerController()
{
    if(Owner != none && Pawn(Owner) != none && Pawn(Owner).DrivenVehicle != none
    && Pawn(Owner).DrivenVehicle.Controller != none && PlayerController(Pawn(Owner).DrivenVehicle.Controller) != none)
        return PlayerController(Pawn(Owner).DrivenVehicle.Controller);
    else if(Owner != none && Pawn(Owner) != none && Pawn(Owner).Controller != none && PlayerController(Pawn(Owner).Controller) != none)
        return PlayerController(Pawn(Owner).Controller);
    else if(Owner != none && PlayerController(Owner) != none)
        return PlayerController(Owner);
    return none;
}

function AddSkillPoints(int Amount, byte SkillNum)
{
    local int Points;

    if(Amount <= 0 || DataObject == none || MutINV == none
    || SkillNum >= ArrayCount(DataObject.SkillLevel))
        return;

    Points = MutINV.static.GetPointsAvaliable(self);
    DataObject.SkillLevel[SkillNum] += Min(Amount, Max(Points, 0));
    ReplicateStatsToClientSide(SkillNum, DataObject.SkillLevel[SkillNum]);
}

function SetClass(class<ClassFile> myClass)
{
    local int i;
    local bool bValidClass;

    if(myClass == none || DataObject == none || DataObject.CharClass != none)
        return;

    for(i=0;i<class'mutInventorySystem'.default.ClassesAvailable.Length;i++)
    {
        if(myClass == class'mutInventorySystem'.default.ClassesAvailable[i])
        {
            bValidClass = true;
            break;
        }
    }
    if(bValidClass)
    {
        DataObject.CharClass = myClass;
        DataObject.CreateDataStruct(DataRep, false);
    }
}

function ChangeItem(class<MainInventoryItem> Item, int iAmount)
{
    local int i, x, o;
    local bool bContinue, bHasItem, bShopItem;
    local PlayerController C;

    if(Item == none || DataObject == none)
        return;
    else if(iAmount <= 0)
    {
        for(i=0;i<DataObject.Items.length;i++)
        {
            if(DataObject.Items[i] == Item)
            {
                bContinue = true;
                break;
            }
        }

        if(!bContinue)
            return;

        DataObject.ItemsAmount[i] += iAmount;
        if(DataObject.ItemsAmount[i] <= 0)
        {
            DataObject.Items[i].static.DeletedItem(FindOwnerController());
            DataObject.Items.Remove(i, 1);
            DataObject.ItemsAmount.Remove(i, 1);
            ClientRemoveItem(i);
        }
        else
            ReplicateToClientSide(i, Item, DataObject.ItemsAmount[i]);
        ClientInventoryUpdateGUI();
    }
    else if(MutINV != none)
    {
        if(DataObject.Credits + Item.default.BuyPrice < 0)
        {
            C = FindOwnerController();
            if(C != none)
                C.ClientMessage(NotEnoughCredits);
            return;
        }

        for(x=0;x<MutINV.BuyableItems.length;x++)
        {
            if(MutINV.BuyableItems[x].ItemClass == Item && MutINV.BuyableItems[x].Amount >= 1)
            {
                bContinue = true;
                break;
            }
        }

        if(!bContinue)
        {
            C = FindOwnerController();
            if(C != none)
                C.ClientMessage(ItemOutOfStock);
            return;
        }
        else
        {
            for(i=0;i<DataObject.Items.length;i++)
            {
                if(DataObject.Items[i] == Item)
                {
                    bHasItem = true;
                    break;
                }
            }

            if(bHasItem)
            {
                for(o=0;o<MutINV.ShopItems.Length;o++)
                {
                    if(MutINV.BuyableItems[x].ItemClass == MutINV.ShopItems[o])
                    {
                        bShopItem = true;
                        break;
                    }
                }

                iAmount = Min(Min(Max(DataObject.Credits / abs(Item.default.BuyPrice), 0), MutINV.BuyableItems[x].Amount), iAmount);
                DataObject.ItemsAmount[i] += iAmount;
                DataObject.Credits += (Item.default.BuyPrice * iAmount);
                DataObject.CreateDataStruct(DataRep, true);
                MutINV.BuyableItems[x].Amount -= iAmount;
                ReplicateToClientSide(i, Item, DataObject.ItemsAmount[i]);
                if(!bShopItem && MutINV.BuyableItems[x].Amount <= 0)
                    MutINV.BuyableItems.Remove(x, 1);
            }
            else if(DataObject.Items.Length < DataObject.Slots)
            {
                for(o=0;o<MutINV.ShopItems.Length;o++)
                {
                    if(MutINV.BuyableItems[x].ItemClass == MutINV.ShopItems[o])
                    {
                        bShopItem = true;
                        break;
                    }
                }

                iAmount = Min(Min(Max(DataObject.Credits / abs(Item.default.BuyPrice), 0), MutINV.BuyableItems[x].Amount), Max(iAmount, 1));
                DataObject.Items[DataObject.Items.Length] = Item;
                DataObject.ItemsAmount[DataObject.ItemsAmount.Length] = iAmount;
                DataObject.Credits += (Item.default.BuyPrice * iAmount);
                DataObject.CreateDataStruct(DataRep, true);
                MutINV.BuyableItems[x].Amount -= iAmount;
                ClientAddNewItem(Item, iAmount);
                if(!bShopItem && MutINV.BuyableItems[x].Amount <= 0)
                    MutINV.BuyableItems.Remove(x, 1);
            }
            else
            {
                C = FindOwnerController();
                if(C != none)
                    C.ClientMessage(NoMoreSlots);
                return;
            }
            ClientInventoryUpdateGUI();
            ClientDataUpdate();
        }
    }
}

function SellItem(class<MainInventoryItem> Item, int iAmount)
{
    local int i, x, o;
    local bool bIsInShop;
    local PlayerController C;

    if(Item == none || DataObject == none || MutINV == none || Level == none)
        return;
    else if(!Item.default.bSellable)
    {
        C = FindOwnerController();
        if(C != none)
            C.ClientMessage(ItemUnsellable);
        return;
    }

    for(x=0;x<MutINV.BuyableItems.length;x++)
    {
        if(MutINV.BuyableItems[x].ItemClass == Item)
        {
            bIsInShop = true;
            break;
        }
    }

    for(i=0;i<DataObject.Items.length;i++)
    {
        if(DataObject.Items[i] == Item)
        {
            iAmount = Max(Min(DataObject.ItemsAmount[i], iAmount), 1);
            if(bIsInShop)
                MutINV.BuyableItems[x].Amount += iAmount;
            else
            {
                MutINV.BuyableItems.Insert(MutINV.BuyableItems.Length, 1);
                MutINV.BuyableItems[MutINV.BuyableItems.Length-1].ItemClass = Item;
                MutINV.BuyableItems[MutINV.BuyableItems.Length-1].Amount = iAmount;
                MutINV.BuyableItems[MutINV.BuyableItems.Length-1].Second = class'mutInventorySystem'.static.GetSecondsFromYearStart(Level);
                MutINV.BuyableItems[MutINV.BuyableItems.Length-1].Year = Level.Year;
            }

            while(o < iAmount)
            {
                DataObject.Credits += Item.default.SellPrice;
                o++;
            }
            DataObject.CreateDataStruct(DataRep, true);
            DataObject.ItemsAmount[i] -= iAmount;
            if(DataObject.ItemsAmount[i] <= 0)
            {
                DataObject.Items[i].static.DeletedItem(FindOwnerController());
                DataObject.Items.Remove(i, 1);
                DataObject.ItemsAmount.Remove(i, 1);
                ClientRemoveItem(i);
            }
            else
                ReplicateToClientSide(i, DataObject.Items[i], DataObject.ItemsAmount[i]);
            ClientInventoryUpdateGUI();
            ClientDataUpdate();
            break;
        }
    }
}

function SwapItems(class<MainInventoryItem> Item1, class<MainInventoryItem> Item2)
{
    local int i, ItemInt1, ItemInt2, Item1SavedAmount;
    local bool bHasItem1, bHasItem2;

    if(Item1 == none || Item2 == none || DataObject == none || Item1 == Item2)
        return;

    for(i=0;i<DataObject.Items.length;i++)
    {
        if(Item1 == DataObject.Items[i])
        {
            bHasItem1 = true;
            ItemInt1 = i;
        }
        else if(Item2 == DataObject.Items[i])
        {
            bHasItem2 = true;
            ItemInt2 = i;
        }
    }

    if(!bHasItem1 || !bHasItem2)
        return;

    Item1SavedAmount = DataObject.ItemsAmount[ItemInt1];
    ReplicateToClientSide(ItemInt1, Item2, DataObject.ItemsAmount[ItemInt2]);
    ReplicateToClientSide(ItemInt2, Item1, Item1SavedAmount);
    DataObject.Items[ItemInt1] = Item2;
    DataObject.Items[ItemInt2] = Item1;
    DataObject.ItemsAmount[ItemInt1] = DataObject.ItemsAmount[ItemInt2];
    DataObject.ItemsAmount[ItemInt2] = Item1SavedAmount;
    ClientInventoryUpdateGUI();
}

function TakeLootedItem(class<MainInventoryItem> Item)
{
    local int i, x;
    local bool bContinue;
    local PlayerController C;

    if(Item == none || DataObject == none)
        return;

    for(i=0;i<LootedItems.length;i++)
    {
        if(LootedItems[i] == Item)
        {
            bContinue = true;
            break;
        }
    }

    if(!bContinue)
        return;

    for(x=0;x<DataObject.Items.Length;x++)
    {
        if(DataObject.Items[x] == Item)
        {
            if(DataObject.CurrentMission != none)
                DataObject.CurrentMission.static.PickedUpItem(FindOwnerController(), Item, LootedItemsAmount[i], "lootitem");
            DataObject.ItemsAmount[x] += LootedItemsAmount[i];
            LootedItems.Remove(i, 1);
            LootedItemsAmount.Remove(i, 1);
            ReplicateToClientSide(x, DataObject.Items[x], DataObject.ItemsAmount[x]);
            ClientRemoveLootedItem(i);
            ClientInventoryUpdateGUI();
            ClientLootUpdateGUI();
            return;
        }
    }

    if(DataObject.Items.Length < DataObject.Slots)
    {
        if(DataObject.CurrentMission != none)
            DataObject.CurrentMission.static.PickedUpItem(FindOwnerController(), Item, LootedItemsAmount[i], "lootitem");
        DataObject.Items[DataObject.Items.Length] = Item;
        DataObject.ItemsAmount[DataObject.ItemsAmount.Length] = LootedItemsAmount[i];
        ClientAddNewItem(Item, LootedItemsAmount[i]);
        ClientRemoveLootedItem(i);
        LootedItems.Remove(i, 1);
        LootedItemsAmount.Remove(i, 1);
        ClientInventoryUpdateGUI();
        ClientLootUpdateGUI();
    }
    else
    {
        C = FindOwnerController();
        if(C != none)
            C.ClientMessage(NoMoreSlots);
    }
}

function RemoveLootedItem(class<MainInventoryItem> Item)
{
    local int i;
    local bool bContinue;

    if(Item == none || DataObject == none)
        return;

    for(i=0;i<LootedItems.length;i++)
    {
        if(LootedItems[i] == Item)
        {
            bContinue = true;
            break;
        }
    }

    if(!bContinue)
        return;

    LootedItems.Remove(i, 1);
    LootedItemsAmount.Remove(i, 1);
    ClientRemoveLootedItem(i);
    ClientLootUpdateGUI();
}
//------------------------------------------------------------------------------
//Mission related functions.
//------------------------------------------------------------------------------
function Timer()
{
    if(DataObject != none && DataObject.CurrentMission != none)
        DataObject.CurrentMission.static.Timer(self);
}

function StartNewMission(class<MissionFile> Mission)
{
    local PlayerController C;
    local int i;

    C = FindOwnerController();
    if(C == none || Mission == none || DataObject == none)
        return;
    else if(DataObject.CurrentMission != none)
    {
        C.ClientMessage(AlreadyHaveMission);
        return;
    }

    for(i=0;i<DataObject.CompletedMissions.Length;i++)
    {
        if(DataObject.CompletedMissions[i] == Mission)
        {
            C.ClientMessage(MissionAlreadyCompleted);
            return;
        }
    }

    if(!Mission.static.bCanStartMission(C))
        return;

    DataObject.CurrentMission = Mission;
    DataObject.MissionObjectSuccess.Length = DataObject.CurrentMission.static.GetMissionObjectivesAmount(C);
    Mission.static.StartMission(C);
    for(i=0;i<DataObject.MissionObjectSuccess.Length;i++)
        ReplicateMissionObjectSuccess(i, DataObject.MissionObjectSuccess[i]);
    DataObject.CreateDataStruct(DataRep, false);
    ClientMissionInfoUpdate();
    if(DataObject.CurrentMission.static.GetDefaultTimeLimit() > 0)
        SetTimer(1,true);
}

function EndCurrentMission()
{
    local PlayerController C;

    if(DataObject == none || DataObject.CurrentMission == none)
        return;

    C = FindOwnerController();
    if(C == none)
        return;

    if(DataObject.CurrentMission.static.GetDefaultTimeLimit() > 0)
        SetTimer(0,false);
    DataObject.CurrentMission.static.EndMission(C);
}
//------------------------------------------------------------------------------
//Change related things.
//------------------------------------------------------------------------------
function ClientDataUpdate()
{
    local Controller P;
    local INVInventory INVInventory;
    local Inventory myInv;

    if(Level != none && Level.ControllerList != none)
    {
        for(P=Level.ControllerList; P!=None; P=P.NextController)
        {
            if(P != none && P.bIsPlayer)
            {
                if(P.Pawn != none)
                    INVInventory = INVInventory(P.Pawn.FindInventoryType(class'INVInventory'));
                if(P != none && INVInventory == none)
            	{
                    for(myInv = P.Inventory; myInv != None; myInv = myInv.Inventory)
                	{
                		INVInventory = INVInventory(myInv);
                		if(INVInventory != None)
                			break;
                	}
            	}

                if(INVInventory != None)
                {
                    INVInventory.ServerCheckShopItems();
                    INVInventory.ClientUpdateGUI();
                }
            }
        }
    }
}

function DropFrom(vector StartLocation)
{
	if(Instigator != none && Instigator.Controller != None)
		SetOwner(Instigator.Controller);
}

function bool GetNewDestination()
{
    if(DataObject != none && DataObject.CurrentMission != none
    && class<Mission031F>(DataObject.CurrentMission) != none
    && class<Mission031F>(DataObject.CurrentMission).static.PickDestination(FindOwnerController()))
        return true;
    return false;
}

function OwnerDied()
{
	local Controller C;

    if(DataObject != None)
        DataObject.SaveConfig();

	if(Instigator != None)
	{
        if(Instigator.Controller != none)
            C = Instigator.Controller;
		else if(C == none && Instigator.DrivenVehicle != none && Instigator.DrivenVehicle.Controller != none)
			C = Instigator.DrivenVehicle.Controller;
		Instigator.DeleteInventory(self);
		SetOwner(C);

	}
}

//------------------------------------------------------------------------------
//Trade functions.
//------------------------------------------------------------------------------
simulated function PostNetReceive()
{
    if(bUpdateImages)
    {
        if(Trade != none)
            Trade.UpdateImages();
        ServerbUpdateImages(false);
    }
    if(OldCurrentMission != DataRep.CurrentMission)
    {
        OldCurrentMission = DataRep.CurrentMission;
        if(MissionGUI != None)
            MissionGUI.FillContextMenu();
    }
    if(OldbAcceptedTrade != bAcceptedTrade)
    {
        OldbAcceptedTrade = bAcceptedTrade;
        if(!bAcceptedTrade && Trade != none)
            Trade.CancelTradeAccept();
        else
        {
            AcceptTrade();
            if(Trade != none)
                Trade.CheckDisable();
        }
    }
    if(StatsGUI != none)
        StatsGUI.UpdateStats();
    super.PostNetReceive();
}

simulated function Tick(float DeltaTime)
{
    local int i;

    if(Role<ROLE_Authority && ((Instigator != none && Instigator.Health <= 0 && Trade != none)
    || (TradeReplicationInfo != none && TradeReplicationInfo.CurTrader != none
    && TradeReplicationInfo.CurTrader.CurTrader == none && Trade != none)))
        Trade.xButtonClicked(none);
    if(Level.TimeSeconds >= PlayerSpawnTime + 1
    && DataObject != none && PlayerSpawnTime != -1)
    {
        PlayerSpawnTime = -1;
        for(i=0;i<DataObject.Items.length;i++)
            if(DataObject.Items[i] != none)
                DataObject.Items[i].static.ModifyPlayer(FindOwnerController());
    }
    super.Tick(DeltaTime);
}

simulated function ClientChangeTradedItems(class<MainInventoryItem> Items, int iAmount)
{
    ServerChangeTradedItems(Items, iAmount);
}

function ServerChangeTradedItems(class<MainInventoryItem> Items, int iAmount)
{
    if(TradeReplicationInfo != none)
        TradeReplicationInfo.ServerChangeTradedItems(Items, iAmount);
}

simulated function ClientChangeExchangedCredits(int ChangedCredits)
{
    ServerChangeExchangedCredits(ChangedCredits);
}

function ServerChangeExchangedCredits(int ChangedCredits)
{
    if(TradeReplicationInfo != none)
        TradeReplicationInfo.ServerChangeExchangedCredits(ChangedCredits);
}

simulated function ClientOpenTrade()
{
    ServerOpenTrade();
}

function ServerOpenTrade()
{
    local PlayerController C, PC;

    if(bTradeAvailable
    && TradeReplicationInfo != none
    && TradeReplicationInfo.CurTrader != none
    && TradeReplicationInfo.CurTrader.myINVInventory != none)
    {
        C = TradeReplicationInfo.CurTrader.myINVInventory.FindOwnerController();
        PC = FindOwnerController();
        if(PC != none && C != none)
        {
            PC.ClientOpenMenu("SonicRPG45.TradeGUI");
            C.ClientOpenMenu("SonicRPG45.TradeGUI");
        }
    }
}

//Dont manually call this function, its for UpdateClientTradeArray() to call.
simulated function UpdateServerTradeArray(class<MainInventoryItem> Items, int iAmount, int ArrayNum, int ArrayLength)
{
    if(TradeReplicationInfo == none)
        return;

    TradeReplicationInfo.TradedItems.Length = ArrayLength;
    if(Items != none)
    {
        TradeReplicationInfo.TradedItems[ArrayNum].Items = Items;
        TradeReplicationInfo.TradedItems[ArrayNum].Amount = iAmount;
    }
    if(ArrayNum >= ArrayLength-1)
    {
        ServerbUpdateImages(True);
        TradeReplicationInfo.CurTrader.myINVInventory.ServerbUpdateImages(True);
    }
}

simulated function UpdateRepServerTradeArray(class<MainInventoryItem> Items, int iAmount, int ArrayNum, int ArrayLength)
{
    if(TradeReplicationInfo == none)
        return;

    TradeReplicationInfo.RepTradedItems.Length = ArrayLength;
    if(Items != none)
    {
        TradeReplicationInfo.RepTradedItems[ArrayNum].Items = Items;
        TradeReplicationInfo.RepTradedItems[ArrayNum].Amount = iAmount;
    }
    if(ArrayNum >= ArrayLength-1)
    {
        ServerbUpdateImages(True);
        TradeReplicationInfo.CurTrader.myINVInventory.ServerbUpdateImages(True);
    }
}

simulated function ClientbUpdateImages(bool Update)
{
    ServerbUpdateImages(Update);
}

function ServerbUpdateImages(bool Update)
{
    bUpdateImages = Update;
}

function ChangeTradeVar(bool bOpen)
{
    if(TradeReplicationInfo == none || TradeReplicationInfo.CurTrader == none)
        return;

    bTradeOpen = bOpen;
    if(bTradeAvailable)
        TradeReplicationInfo.SetTimer(0.1,False);
    if(bTradeOpen)
        bTradeAvailable = false;
}

function EnableTrade(INVInventory INVInventory)
{
    if(ROLE != ROLE_Authority || INVInventory == none || INVInventory == self || bTradeAvailable
    || INVInventory.TradeReplicationInfo != none && INVInventory.TradeReplicationInfo.CurTrader != none
    || TradeReplicationInfo != none && TradeReplicationInfo.CurTrader != none)
        return;

    bTradeAvailable = true;

    if(INVInventory.TradeReplicationInfo == none)
        INVInventory.TradeReplicationInfo = Spawn(class'TradeReplicationInfo');
    if(TradeReplicationInfo == none)
        TradeReplicationInfo = Spawn(class'TradeReplicationInfo');

    INVInventory.TradeReplicationInfo.CurTrader = TradeReplicationInfo;
    INVInventory.TradeReplicationInfo.myINVInventory = INVInventory;
    TradeReplicationInfo.CurTrader = INVInventory.TradeReplicationInfo;
    TradeReplicationInfo.myINVInventory = self;

    TradeReplicationInfo.SetTimer(30,False);
}

simulated function ClientResetTrade()
{
    ServerResetTrade();
}

function ServerResetTrade()
{
    if(TradeReplicationInfo == none)
        return;

    ServerChangeExchangedCredits(-TradeReplicationInfo.CreditsExchanged);
    TradeReplicationInfo.TradedItems.Remove(0, TradeReplicationInfo.TradedItems.Length);
    TradeReplicationInfo.UpdateClientTradeArray();
    ServerSetbAcceptedTrade(false);
    ChangeTradeVar(false);
    TradeReplicationInfo.CurTrader = none;
}

simulated function CloseTrade()
{
    if(Trade != none)
        Trade.xButtonClicked(none);
}

singular function bool AcceptTrade()
{
    local int i, x, o, myTradedItems, TradersTradedItems;
    local bool bAlreadyHas;
    local PlayerController myPC, TradePC;

    if(DataObject != none
    && MutINV != none
    && TradeReplicationInfo != none
    && TradeReplicationInfo.CurTrader != none
    && TradeReplicationInfo.CurTrader.myINVInventory != none
    && TradeReplicationInfo.CurTrader.myINVInventory.bAcceptedTrade
    && TradeReplicationInfo.CurTrader.myINVInventory.DataObject != none)
    {
        if(MutINV.bLogTrade)
        {
            myPC = FindOwnerController();
            TradePC = TradeReplicationInfo.CurTrader.myINVInventory.FindOwnerController();
            if(myPC == none || TradePC == none || myPC.PlayerReplicationInfo == none || TradePC.PlayerReplicationInfo == none)
                return false;

            for(i=0;i<TradeReplicationInfo.TradedItems.Length;i++)
                myTradedItems += abs(TradeReplicationInfo.TradedItems[i].Items.default.BuyPrice);
            for(i=0;i<TradeReplicationInfo.CurTrader.TradedItems.Length;i++)
                TradersTradedItems += abs(TradeReplicationInfo.CurTrader.TradedItems[i].Items.default.BuyPrice);

            MutINV.TempLog.OpenLog("TradeLog");
            MutINV.TempLog.Logf("["$Level.Day$"/"$Level.Month$"/"$Level.Year$"]"$myPC.PlayerReplicationInfo.PlayerName @ "trades"
                       @ myTradedItems $ "(" $ TradeReplicationInfo.TradedItems.Length $ ")"
                       @ TradeReplicationInfo.CreditsExchanged
                       @ "to" @ TradePC.PlayerReplicationInfo.PlayerName @ "for"
                       @ TradersTradedItems $ "(" $ TradeReplicationInfo.CurTrader.TradedItems.Length $ ")"
                       @ TradeReplicationInfo.CurTrader.CreditsExchanged);
            MutINV.TempLog.CloseLog();
        }

        ServerSetbAcceptedTrade(false);
        DataObject.Credits += TradeReplicationInfo.CurTrader.CreditsExchanged;
        DataObject.Credits -= TradeReplicationInfo.CreditsExchanged;
        TradeReplicationInfo.CurTrader.myINVInventory.ServerSetbAcceptedTrade(false);
        TradeReplicationInfo.CurTrader.myINVInventory.DataObject.Credits -= TradeReplicationInfo.CurTrader.CreditsExchanged;
        TradeReplicationInfo.CurTrader.myINVInventory.DataObject.Credits += TradeReplicationInfo.CreditsExchanged;

        //Give trader my traded items.
        for(i=0;i<TradeReplicationInfo.TradedItems.Length;i++)
        {
            for(x=0;x<DataObject.Items.Length;x++)
            {
                if(DataObject.Items[x] == TradeReplicationInfo.TradedItems[i].Items)
                {
                    o = x;
                    x = DataObject.Items.Length;
                }
            }
            for(x=0;x<TradeReplicationInfo.CurTrader.myINVInventory.DataObject.Items.Length;x++)
            {
                if(TradeReplicationInfo.CurTrader.myINVInventory.DataObject.Items[x] == TradeReplicationInfo.TradedItems[i].Items)
                {
                    TradeReplicationInfo.CurTrader.myINVInventory.DataObject.ItemsAmount[x] += TradeReplicationInfo.TradedItems[i].Amount;
                    TradeReplicationInfo.CurTrader.myINVInventory.ReplicateToClientSide(x, TradeReplicationInfo.CurTrader.myINVInventory.DataObject.Items[x],
                                                                                        TradeReplicationInfo.CurTrader.myINVInventory.DataObject.ItemsAmount[x]);
                    bAlreadyHas = true;
                    x = TradeReplicationInfo.CurTrader.myINVInventory.DataObject.Items.Length;
                }
            }
            if(!bAlreadyHas)
            {
                TradeReplicationInfo.CurTrader.myINVInventory.DataObject.Items[TradeReplicationInfo.CurTrader.myINVInventory.DataObject.Items.Length] = TradeReplicationInfo.TradedItems[i].Items;
                TradeReplicationInfo.CurTrader.myINVInventory.DataObject.ItemsAmount[TradeReplicationInfo.CurTrader.myINVInventory.DataObject.ItemsAmount.Length] = TradeReplicationInfo.TradedItems[i].Amount;
                TradeReplicationInfo.CurTrader.myINVInventory.ClientAddNewItem(TradeReplicationInfo.TradedItems[i].Items, TradeReplicationInfo.TradedItems[i].Amount);
            }
            bAlreadyHas = false;
            DataObject.ItemsAmount[o] -= TradeReplicationInfo.TradedItems[i].Amount;
            if(DataObject.ItemsAmount[o] <= 0)
            {
                DataObject.Items[o].static.DeletedItem(FindOwnerController());
                DataObject.Items.Remove(o, 1);
                DataObject.ItemsAmount.Remove(o, 1);
                ClientRemoveItem(o);
            }
            else
                ReplicateToClientSide(o, DataObject.Items[o], DataObject.ItemsAmount[o]);
        }

        //Give me traders traded items.
        for(i=0;i<TradeReplicationInfo.CurTrader.TradedItems.Length;i++)
        {
            for(x=0;x<TradeReplicationInfo.CurTrader.myINVInventory.DataObject.Items.Length;x++)
            {
                if(TradeReplicationInfo.CurTrader.myINVInventory.DataObject.Items[x] == TradeReplicationInfo.CurTrader.TradedItems[i].Items)
                {
                    o = x;
                    x = TradeReplicationInfo.CurTrader.myINVInventory.DataObject.Items.Length;
                }
            }
            for(x=0;x<DataObject.Items.Length;x++)
            {
                if(DataObject.Items[x] == TradeReplicationInfo.CurTrader.TradedItems[i].Items)
                {
                    DataObject.ItemsAmount[x] += TradeReplicationInfo.CurTrader.TradedItems[i].Amount;
                    ReplicateToClientSide(x, DataObject.Items[x], DataObject.ItemsAmount[x]);
                    bAlreadyHas = true;
                    x = DataObject.Items.Length;
                }
            }
            if(!bAlreadyHas)
            {
                DataObject.Items[DataObject.Items.Length] = TradeReplicationInfo.CurTrader.TradedItems[i].Items;
                DataObject.ItemsAmount[DataObject.ItemsAmount.Length] = TradeReplicationInfo.CurTrader.TradedItems[i].Amount;
                ClientAddNewItem(TradeReplicationInfo.CurTrader.TradedItems[i].Items, TradeReplicationInfo.CurTrader.TradedItems[i].Amount);
            }
            bAlreadyHas = false;
            TradeReplicationInfo.CurTrader.myINVInventory.DataObject.ItemsAmount[o] -= TradeReplicationInfo.CurTrader.TradedItems[i].Amount;
            if(TradeReplicationInfo.CurTrader.myINVInventory.DataObject.ItemsAmount[o] <= 0)
            {
                TradeReplicationInfo.CurTrader.myINVInventory.DataObject.Items[o].static.DeletedItem(TradeReplicationInfo.CurTrader.myINVInventory.FindOwnerController());
                TradeReplicationInfo.CurTrader.myINVInventory.DataObject.Items.Remove(o, 1);
                TradeReplicationInfo.CurTrader.myINVInventory.DataObject.ItemsAmount.Remove(o, 1);
                TradeReplicationInfo.CurTrader.myINVInventory.ClientRemoveItem(o);
            }
            else
                TradeReplicationInfo.CurTrader.myINVInventory.ReplicateToClientSide(o, TradeReplicationInfo.CurTrader.myINVInventory.DataObject.Items[o],
                                                                                    TradeReplicationInfo.CurTrader.myINVInventory.DataObject.ItemsAmount[o]);
        }
        TradeReplicationInfo.CurTrader.myINVInventory.DataObject.CreateDataStruct(TradeReplicationInfo.CurTrader.myINVInventory.DataRep, false);
        DataObject.CreateDataStruct(DataRep, false);
        ClientInventoryUpdateGUI();
        TradeReplicationInfo.CurTrader.myINVInventory.ClientInventoryUpdateGUI();
        CloseTrade();
        return true;
    }
    return false;
}

simulated function ClientSetbAcceptedTrade(bool Accept)
{
    ServerSetbAcceptedTrade(Accept);
}

function ServerSetbAcceptedTrade(bool Accept)
{
    bAcceptedTrade = Accept;
    if(TradeReplicationInfo != none
    && TradeReplicationInfo.CurTrader != none
    && TradeReplicationInfo.CurTrader.myINVInventory != none
    && !TradeReplicationInfo.CurTrader.myINVInventory.bAcceptedTrade)
        TradeReplicationInfo.CurTrader.myINVInventory.ClientSetVisibility(Accept);
}

simulated function ClientSetVisibility(bool CanSee)
{
    if(Trade != none && Trade.AcceptedLabel != none && CanSee)
        Trade.AcceptedLabel.SetVisibility(CanSee);
}
//------------------------------------------------------------------------------
//End.
//------------------------------------------------------------------------------

simulated function Destroyed()
{
	if(TradeReplicationInfo != none)
        TradeReplicationInfo.Destroy();

    DataObject = none;
    GUI = none;
	Shop = none;
	Trade = none;
	Loot = none;
	Information = none;
	Amount = None;
	MissionGUI = none;
	MissionInfoGUI = none;
	StatsGUI = none;
	TradeReplicationInfo = none;
	MutINV = none;
	Super.Destroyed();
}

simulated function ModifyVehicle(Vehicle V)
{
    if(Owner == Instigator)
        SetOwner(V);
}

simulated function ClientModifyVehicle(Vehicle V)
{
    if(V != None)
        ModifyVehicle(V);
}

simulated function UnModifyVehicle(Vehicle V)
{
	if(Owner == V)
	    SetOwner(Instigator);
}

simulated function ClientUnModifyVehicle(Vehicle V)
{
	if(V != None)
        UnModifyVehicle(V);
}

defaultproperties
{
     ItemUnsellable="This item in unsellable."
     ItemUntradable="This item in untradable."
     ItemOutOfStock="This item is out of stock."
     NoMoreSlots="Inventory is full. You can buy more slots at UnrealInsanity.com."
     TraderFull="The other trader cannot hold any more items in thier inventory."
     AlreadyAddedMax="You've already added as much as you can of this item."
     NotEnoughCredits="Not enough credits."
     MissionAlreadyCompleted="You have already completed this mission."
     AlreadyHaveMission="You already have a mission."
     ItemHasBeenUsed="You used an item, you now have:"
     bOnlyRelevantToOwner=False
     bAlwaysRelevant=True
     bReplicateInstigator=True
     bNetNotify=True
}
