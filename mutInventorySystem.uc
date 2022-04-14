class mutInventorySystem extends Mutator
    config(InventorySystem);

const Version = 45;

struct BuyableStruct
{
    var class<MainInventoryItem> ItemClass;
    var int Second, Year, Amount;
};
struct Loot
{
    var class<MainInventoryItem> ItemClass;
    var int MaxLoot, Chance;
};
struct SkillVars
{
    var string SkillName, Description;
    var int SkillStartingLevel;
    var array<int> CLevelCap, SkillCap;
};
struct CombatLevelVars
{
    var localized string LevelUpMessage, OtherLevelUpMessage;
    var int SkillStartingLevel, SkillStartingXP, XPCap, PointsPerLevel;
    var float SkillXPIncrease;
};

var FileLog TempLog;

var protected CombatLevelVars CombatInfo;
var protected bool bJustInvasionSaved, bHasInteraction, bInvasionSaver;
var protected int Months[13], MonthsLY[13], Credits, DefaultSlots, DeleteAfter, DontDeleteCredits, SaveDataTime;
var protected array<int> Levels;

var int TotalLootChance;
var color YellowColor, RedColor, GreenColor, WhiteColor;
var float CreditPercentage, LootChance;

var array<Loot> LootableItems;
var array<SkillVars> Skills;
var array<class<ClassFile> > ClassesAvailable;
var array<class<MainInventoryItem> > ShopItems;
var array<string> WebDescString, WebDisplayText;

var config array<BuyableStruct> BuyableItems;
var config string RichestPlayer, RichestPlayerItems, HighestLevelPlayerName;
var config bool bReset, bAllowTrade, bLogTrade;
var config int LastSlots, RichestPlayerCredits, HighestLevelPlayerLevel;

static function CheckDataObjectValidity(InventoryPlayerDataObject data)
{
    local int i;

    if(data == none)
        return;

    for(i=0;i<data.Items.Length;i++)
    {
        if(data.Items[i] == none)
        {
             data.Items.Remove(i, 1);
             data.ItemsAmount.Remove(i, 1);
             i--;
        }
    }
    for(i=0;i<data.CompletedMissions.Length;i++)
    {
        if(data.CompletedMissions[i] == none)
        {
             data.CompletedMissions.Remove(i, 1);
             i--;
        }
    }
    for(i=0;i<default.Skills.length;i++)
        if(data.SkillLevel[i] < default.Skills[i].SkillStartingLevel)
            data.SkillLevel[i] = default.Skills[i].SkillStartingLevel;
    if(data.CombatLevel < default.CombatInfo.SkillStartingLevel)
        data.CombatLevel = default.CombatInfo.SkillStartingLevel;
    if(data.CurrentMission == none && data.MissionObjectSuccess.length > 0)
    {
        data.MissionObjectSuccess.Remove(0, data.MissionObjectSuccess.Length);
        data.CurrentMissionTimeLapsed = 0;
    }
}

static function CheckLevelUp(INVInventory INVInventory)
{
    local int Count, XP;
    local bool bLevelUp;
    local PlayerController Other;
    local Controller C;

    if(INVInventory == none || INVInventory.DataObject == none)
        return;

    Other = INVInventory.FindOwnerController();
    XP = GetCurrentXP(INVInventory.DataObject.CombatLevel);
    while(Count < 200 && INVInventory.DataObject.CombatXP >= XP)
    {
        INVInventory.DataObject.CombatXP -= XP;
        INVInventory.DataObject.CombatLevel++;
        XP = GetCurrentXP(INVInventory.DataObject.CombatLevel);
        Count++;
        bLevelUp = true;
    }
    if(bLevelUp && Other != none)
    {
        Other.ClientMessage(class'GameInfo'.static.MakeColorCode(default.GreenColor) $ default.CombatInfo.LevelUpMessage
                          @ INVInventory.DataObject.CombatLevel$".");
        for(C=INVInventory.Level.ControllerList;C!=none;C=C.NextController)
            if(C != Other && PlayerController(C) != none)
                PlayerController(C).ClientMessage(Other.PlayerReplicationInfo.PlayerName
                                                @ default.CombatInfo.OtherLevelUpMessage @ INVInventory.DataObject.CombatLevel);
    }
}

static simulated function int GetCurrentXP(int SkillLevel)
{
    local int XP, Num;

    if(default.CombatInfo.SkillXPIncrease != 0)
    {
        Num = default.CombatInfo.SkillStartingLevel;
        XP = default.CombatInfo.SkillStartingXP;
        while(Num < SkillLevel)
        {
            XP = XP * default.CombatInfo.SkillXPIncrease;
            Num++;
        }
        if(default.CombatInfo.XPCap > 0 && XP > default.CombatInfo.XPCap)
            return default.CombatInfo.XPCap;
    }
    else
    {
        if(SkillLevel >= default.Levels.Length)
            XP = default.Levels[default.Levels.Length-1];
        else
            XP = default.Levels[SkillLevel-1];
    }
    return XP;
}

static final function mutInventorySystem GetInventoryMutator(GameInfo G)
{
	local Mutator M;
	local mutInventorySystem INVMut;

    if(G != none && G.BaseMutator != none)
    	for(M=G.BaseMutator;M!= none&&INVMut==None;M=M.NextMutator)
    		INVMut = mutInventorySystem(M);
	return INVMut;
}

static simulated function int GetPointsAvaliable(INVInventory INVInventory)
{
    local int i, Points;

   	if(INVInventory == none)
   	    return 0;

    if(INVInventory.ROLE < ROLE_Authority)
    {
        Points = default.CombatInfo.PointsPerLevel * INVInventory.DataRep.CombatLevel;
        for(i=0;i<ArrayCount(INVInventory.DataRep.SkillLevel);i++)
            if(INVInventory.DataRep.SkillLevel[i] != default.Skills[i].SkillStartingLevel)
                Points -= (INVInventory.DataRep.SkillLevel[i] - default.Skills[i].SkillStartingLevel);
    }
    else
    {
        Points = default.CombatInfo.PointsPerLevel * INVInventory.DataObject.CombatLevel;
        for(i=0;i<ArrayCount(INVInventory.DataObject.SkillLevel);i++)
            if(INVInventory.DataObject.SkillLevel[i] != default.Skills[i].SkillStartingLevel)
                Points -= (INVInventory.DataObject.SkillLevel[i] - default.Skills[i].SkillStartingLevel);
    }
    return Points;
}

static simulated function INVInventory FindINVInventory(Controller Other)
{
    local Inventory Inv;
   	local INVInventory INVInventory;

    if(Other != none && Other.Pawn != none)
		INVInventory = INVInventory(Other.Pawn.FindInventoryType(class'INVInventory'));
	if(Other != none && INVInventory == none)
	{
        for(Inv = Other.Inventory; Inv != None; Inv = Inv.Inventory)
    	{
    		INVInventory = INVInventory(Inv);
    		if(INVInventory != None)
    			break;
    	}
	}
    return INVInventory;
}

static function int GetSecondsFromYearStart(LevelInfo Level)
{
    return Level.Second + (Level.Minute * 60) + (Level.Hour * 3600) + (Level.Day * 86400) + (default.Months[Level.Month-1] * 86400);
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	local int i;

    Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting("Inventory System", "SaveDataTime", default.WebDisplayText[i++], 1, 10, "Text", "3;0:999");
	PlayInfo.AddSetting("Inventory System", "Credits", default.WebDisplayText[i++], 50, 10, "Text", "6;0:999999");
	PlayInfo.AddSetting("Inventory System", "DefaultSlots", default.WebDisplayText[i++], 30, 10, "Text", "3;1:999");
	PlayInfo.AddSetting("Inventory System", "CreditPercentage", default.WebDisplayText[i++], 30, 10, "Text", "5;0:300");
	PlayInfo.AddSetting("Inventory System", "bReset", default.WebDisplayText[i++], 255, 10, "Check");
	PlayInfo.AddSetting("Inventory System", "bAllowTrade", default.WebDisplayText[i++], 255, 10, "Check");
	PlayInfo.AddSetting("Inventory System", "LootChance", default.WebDisplayText[i++], 50, 10, "Text", "3;0:100");
	PlayInfo.AddSetting("Inventory System", "DeleteAfter", default.WebDisplayText[i++], 50, 10, "Text", "3;0:365");
}

static function string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "SaveDataTime": return default.WebDescString[0];
		case "Credits": return default.WebDescString[1];
		case "DefaultSlots": return default.WebDescString[2];
		case "CreditPercentage": return default.WebDescString[3];
		case "bReset": return default.WebDescString[4];
		case "bAllowTrade":	return default.WebDescString[5];
		case "LootChance": return default.WebDescString[6];
		case "DeleteAfter":	return default.WebDescString[7];
	}
}

function PostBeginPlay()
{
    local InventoryRules GI;
    local InventoryPlayerDataObject DataObject;
    local GameRules SG, G;
    local int x, o, TimeNow, PlayerNetWorth;
    local bool bSaveSelf, bAlreadyThere;
    local array<string> PlayerNames;

    TempLog = Spawn(class'FileLog');
    if(bReset)
    {
		PlayerNames = class'InventoryPlayerDataObject'.static.GetPerObjectNames("InventorySystem",, 1000000);
		for(x=0; x<PlayerNames.length; x++)
		{
            DataObject = new(None, PlayerNames[x]) class'InventoryPlayerDataObject';
			DataObject.ClearConfig();
			DataObject = new(None, PlayerNames[x]) class'InventoryPlayerDataObject';
		}
		PlayerNames.Remove(0, PlayerNames.Length);
		RichestPlayer = "";
		RichestPlayerItems = "";
		HighestLevelPlayerName = "";
		HighestLevelPlayerLevel = 0;
		RichestPlayerCredits = 0;
		bReset = false;
		bSaveSelf = True;
    }
    else if(DeleteAfter > 0)//15/7/07
    {
        PlayerNames = class'InventoryPlayerDataObject'.static.GetPerObjectNames("InventorySystem",, 1000000);
        TimeNow = GetTime();
		for(x=0; x<PlayerNames.length; x++)
		{
			PlayerNetWorth = 0;
            DataObject = new(None, PlayerNames[x]) class'InventoryPlayerDataObject';
			for(o=0;o<DataObject.Items.Length;o++)
			    if(DataObject.Items[o] != none)
                    PlayerNetWorth += int(abs(DataObject.Items[o].default.BuyPrice)*DataObject.ItemsAmount[o]);
            PlayerNetWorth += DataObject.Credits;
			if(abs(TimeNow - DataObject.LastPlayed) >= DeleteAfter
            && PlayerNetWorth < DontDeleteCredits)
			{
			    DataObject.ClearConfig();
			    DataObject = new(None, PlayerNames[x]) class'InventoryPlayerDataObject';
                bSaveSelf = True;
			}
		}
        PlayerNames.Remove(0, PlayerNames.Length);
    }

    if(DefaultSlots < 0)
    {
        DefaultSlots = 0;
        bSaveSelf = True;
    }

    for(x=0;x<ShopItems.Length;x++)
    {
        for(o=0;o<BuyableItems.Length;o++)
        {
            if(BuyableItems[o].ItemClass != none
            && BuyableItems[o].ItemClass == ShopItems[x])
            {
                o = BuyableItems.Length;
                bAlreadyThere = true;
            }
        }
        if(!bAlreadyThere)
        {
            BuyableItems.Insert(BuyableItems.Length, 1);
            BuyableItems[BuyableItems.Length-1].ItemClass = ShopItems[x];
            bSaveSelf = True;
        }
        bAlreadyThere = false;
    }

    for(x=0;x<LootableItems.length;x++)
        TotalLootChance += LootableItems[x].Chance;

    if(Level != none && Level.Game != none && Invasion(Level.Game) != none)
        bInvasionSaver = True;
    else if(SaveDataTime > 0.0)
        SetTimer(SaveDataTime,True);

    if(LastSlots != DefaultSlots)
    {
        PlayerNames = class'InventoryPlayerDataObject'.static.GetPerObjectNames("InventorySystem",, 1000000);
		for(x=0; x<PlayerNames.length; x++)
		{
			DataObject = new(None, PlayerNames[x]) class'InventoryPlayerDataObject';
			DataObject.Slots += (DefaultSlots - LastSlots);
		}
        LastSlots = DefaultSlots;
        bSaveSelf = True;
    }

    GI = Spawn(class'InventoryRules');
    GI.INVMut = self;

	if(Level.Game.GameRulesModifiers != None)
		GI.NextGameRules = Level.Game.GameRulesModifiers;
	Level.Game.GameRulesModifiers = GI;

    if(Level.Game.GameRulesModifiers == none)
	{
		SG = Level.Game.Spawn(class'HealableDamageGameRules');
		Level.Game.GameRulesModifiers = SG;
	}
	else
	{
		for(G=Level.Game.GameRulesModifiers;G!=None;G=G.NextGameRules)
		{
			if(G.isA('HealableDamageGameRules'))
			{
				SG = HealableDamageGameRules(G);
				break;
			}
			if(G.NextGameRules == None)
			{
				SG = Level.Game.Spawn(class'HealableDamageGameRules');
				Level.Game.GameRulesModifiers.AddGameRules(SG);
				break;
			}
		}
	}
    if(bSaveSelf)
        SaveConfig();
    Super.PostBeginPlay();
}

function MatchStarting()
{
    local Mutator M, PrevM;

    for(M=Level.Game.BaseMutator;M!=none;M=M.NextMutator)
    {
        if(GetItemName(string(M.class)) ~= "TFAEmbed")
        {
            if(PrevM != none)
                PrevM.NextMutator = M.NextMutator;
            M.NextMutator = none;
            break;
        }
        PrevM = M;
    }
    super.MatchStarting();
}

function Timer()
{
    SaveData();
}

function GetServerDetails(out GameInfo.ServerResponseLine ServerState)
{
	local int i;

	Super.GetServerDetails(ServerState);

	i = ServerState.ServerInfo.Length;

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Richest Player";
	ServerState.ServerInfo[i++].Value = (RichestPlayer $ "(" $ string(RichestPlayerCredits) $ ")" $ "(" $ RichestPlayerItems $ ")");

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Starting Credits";
	ServerState.ServerInfo[i++].Value = string(Credits);

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Inventory Slots";
	ServerState.ServerInfo[i++].Value = string(DefaultSlots);

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Inventory Version";
	ServerState.ServerInfo[i++].Value = string(Version);

    ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Credit Percentage";
	ServerState.ServerInfo[i++].Value = int(CreditPercentage) $ "%";

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Trading";
	ServerState.ServerInfo[i++].Value = string(bAllowTrade);

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Looting Chance";
	ServerState.ServerInfo[i++].Value = int(LootChance) $ "%";

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Remove Stats After(days)";
	ServerState.ServerInfo[i++].Value = string(DeleteAfter);

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Highest Combat Level";
	ServerState.ServerInfo[i++].Value = (HighestLevelPlayerName $ "(" $ HighestLevelPlayerLevel $ ")");
}

simulated function int GetTime()
{
    local int i, DayYears;
    local bool bLeap;

    if(Level == none)
        return 0;

    for(i=0;i<(Level.Year-1)-2006;i++)
    {
        if(((2006+i) % 100) == 0)
            bLeap = (((2006+i) % 400) == 0);
        else
            bLeap = (((2006+i) % 4) == 0);

        if(bLeap)
            DayYears += MonthsLY[ArrayCount(MonthsLY)-1];
        else
            DayYears += Months[ArrayCount(Months)-1];
        bLeap = false;
    }
    if((Level.Year % 100) == 0)
        bLeap = ((Level.Year % 400) == 0);
    else
        bLeap = ((Level.Year % 4) == 0);

    if(bLeap)
        return DayYears + Level.Day + MonthsLY[Level.Month-1];
    return DayYears + Level.Day + Months[Level.Month-1];
}

//This spawns the interaction that allows you to press k to open the inventory.
simulated function Tick(float DeltaTime)
{
    local Controller P;
    local INVInventory INVInventory;
    local Inventory Inv;
    local PlayerController PC;
    local bool bChanged, bShopItem;
	local int SecFromStart, TempAdded1, TempAdded2, DaysOfMonth, TimeLapsed, x, o;

    super.Tick(DeltaTime);

	if(Level.NetMode != NM_DedicatedServer && !bHasInteraction)
	{
        PC = Level.GetLocalPlayerController();
		if(PC != None)
		{
            PC.Player.InteractionMaster.AddInteraction("SonicRPG45.InventoryInteraction", PC.Player);
			bHasInteraction = true;
		}
	}

    if(Role == ROLE_Authority)
    {
        if(bInvasionSaver
        && Level != none
        && Level.Game != none
        && Invasion(Level.Game) != none)
    	{
            if(!bJustInvasionSaved && !Invasion(Level.Game).bWaveInProgress)
            {
                SaveData();
                bJustInvasionSaved = true;
            }
            else if(bJustInvasionSaved && Invasion(Level.Game).bWaveInProgress)
                bJustInvasionSaved = false;
    	}

        SecFromStart = GetSecondsFromYearStart(Level);
        DaysOfMonth = Months[Level.Month];
        for(x=0;x<BuyableItems.Length;x++)
        {
            TempAdded1 = BuyableItems[x].Second + ((BuyableItems[x].Year - 2007) * 31536000);
            TempAdded2 = SecFromStart + ((Level.Year - 2007) * 31536000);
            TimeLapsed = TempAdded2 - TempAdded1;

            if(((BuyableItems[x].ItemClass != none
            && TimeLapsed >= BuyableItems[x].ItemClass.default.ItemRestockTime)
            || BuyableItems[x].Year <= 0) && BuyableItems[x].ItemClass.default.ShopAmount >= 0)
            {
                BuyableItems[x].Second = SecFromStart;
                BuyableItems[x].Year = Level.Year;

                for(o=0;o<ShopItems.Length;o++)
                {
                    if(BuyableItems[x].ItemClass != none
                    && BuyableItems[x].ItemClass == ShopItems[o])
                    {
                        bShopItem = True;
                        o = ShopItems.Length;
                    }
                }

                if(bShopItem && BuyableItems[x].Amount < BuyableItems[x].ItemClass.default.ShopAmount)
                    BuyableItems[x].Amount++;
                else if(!bShopItem || BuyableItems[x].Amount > BuyableItems[x].ItemClass.default.ShopAmount)
                {
                    BuyableItems[x].Amount--;
                    if(BuyableItems[x].Amount <= 0)
                        BuyableItems.Remove(x, 1);
                }

                bChanged = true;
                bShopItem = false;
            }
        }

        if(bChanged)
        {
            for(P=Level.ControllerList; P!=None; P=P.NextController)
            {
                if(P != none && P.bIsPlayer)
                {
                    if(P.Pawn != None)
                        INVInventory = INVInventory(P.Pawn.FindInventoryType(class'INVInventory'));
                    if(INVInventory == none)
                	{
                        for(Inv = P.Inventory; Inv != None; Inv = Inv.Inventory)
                    	{
                    		INVInventory = INVInventory(Inv);
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
}

function SaveData()
{
	local Controller C;
	local Inventory Inv;

	for(C = Level.ControllerList; C != None; C = C.NextController)
	{
		if(C.bIsPlayer && PlayerController(C) != none)
		{
    	    for(Inv = C.Inventory; Inv != None; Inv = Inv.Inventory)
    	    {
    		    if(INVInventory(Inv) != none && INVInventory(Inv).DataObject != none)
    		    {
    			    INVInventory(Inv).DataObject.SaveConfig();
    			    break;
    		    }
   		    }
		}
	}
	SaveConfig();
}

function FindRichestPlayer(InventoryPlayerDataObject Data)
{
    local int ItemCount, ItemPrice, i;

    if(Data == None)
        return;

    for(i=0;i<Data.Items.Length;i++)
    {
        ItemPrice += int(abs(Data.Items[i].default.BuyPrice)*Data.ItemsAmount[i]);
        ItemCount += Data.ItemsAmount[i];
    }

    if(RichestPlayer != "")
    {
    	if((Data.Credits + ItemPrice) > RichestPlayerCredits || string(Data.Name) == RichestPlayer)
    	{
            RichestPlayer = string(Data.Name);
            RichestPlayerCredits = (Data.Credits + ItemPrice);
            RichestPlayerItems = string(ItemCount);
    	}
    }
    else
    {
        RichestPlayer = string(Data.Name);
        RichestPlayerCredits = (Data.Credits + ItemPrice);
        RichestPlayerItems = string(ItemCount);
    }

    if(HighestLevelPlayerName != "")
    {
        if(Data.CombatLevel > HighestLevelPlayerLevel)
        {
            HighestLevelPlayerName = string(Data.Name);
            HighestLevelPlayerLevel = Data.CombatLevel;
        }
    }
    else
    {
        HighestLevelPlayerName = string(Data.Name);
        HighestLevelPlayerLevel = Data.CombatLevel;
    }
}

function ModifyPlayer(Pawn Other)
{
    super.ModifyPlayer(Other);
    myModifyPlayer(Other);
}

function myModifyPlayer(Pawn Other)
{
    local INVInventory INVInventory, myINVInventory;
    local InventoryPlayerDataObject Data;
    local Inventory Inv;
    local bool bNewPlayer;

	if(Other == none || Other.Controller == none
    || !Other.Controller.bIsPlayer
    || PlayerController(Other.Controller) == none)
	    return;

    INVInventory = INVInventory(Other.FindInventoryType(class'INVInventory'));
    if(INVInventory == none)
    {
        for(Inv = Other.Controller.Inventory; Inv != None; Inv = Inv.Inventory)
    	{
            INVInventory = INVInventory(Inv);
    		if(INVInventory != None)
    			break;

    		if(Inv.Inventory == None)
    		{
    			Inv.Inventory = None;
    			break;
    		}
    	}
	}
    if(INVInventory == none)
        foreach DynamicActors(class'INVInventory', myINVInventory)
            if(myINVInventory.Owner == Other
            || Other.Controller != none && myINVInventory.Owner == Other.Controller)
                INVInventory = myINVInventory;

    if(INVInventory != none)
        data = INVInventory.DataObject;
    else
    {
        data = InventoryPlayerDataObject(FindObject("Package." $ Other.PlayerReplicationInfo.PlayerName, class'InventoryPlayerDataObject'));
    	if(data == None)
    	    data = new(None, Other.PlayerReplicationInfo.PlayerName) class'InventoryPlayerDataObject';

    	if(data.OwnerID == "")
    	{
			data.OwnerID = PlayerController(Other.Controller).GetPlayerIDHash();
    	    data.Credits = Credits;
    	    data.Slots = DefaultSlots;
    	    data.LastPlayed = GetTime();
    	    data.SaveConfig();
    	    bNewPlayer = true;
    	}
    	else
    	{
            if((PlayerController(Other.Controller) != none && !(PlayerController(Other.Controller).GetPlayerIDHash() ~= data.OwnerID)))
        	{
        		Level.Game.ChangeName(Other.Controller, Other.PlayerReplicationInfo.PlayerName$"_Imposter", true);
        		if(string(data.Name) ~= Other.PlayerReplicationInfo.PlayerName)
        			Level.Game.ChangeName(Other.Controller, string(Rand(65000)), true);
        		myModifyPlayer(Other);
        		return;
        	}

        	if(data.Slots < DefaultSlots)
        	{
        	    data.Slots = DefaultSlots;
        	    data.SaveConfig();
        	}
    	}
	}

    if(INVInventory == none)
    {
        INVInventory = Spawn(class'INVInventory', Other,,, rot(0,0,0));
        INVInventory.Inventory = Other.Controller.Inventory;
        Other.Controller.Inventory = INVInventory;
    	if(bNewPlayer && INVInventory != none)
            INVInventory.StartNewMission(class'MissionHudClass'.default.DefaultMission);
	}
	CheckDataObjectValidity(data);
	INVInventory.DataObject = data;
	if(INVInventory.DataObject != none)
	{
        CheckLevelUp(INVInventory);
        INVInventory.DataObject.LastPlayed = GetTime();
        INVInventory.DataObject.CreateDataStruct(INVInventory.DataRep, false, true);
        if(INVInventory.DataObject.CurrentMission != none && INVInventory.DataObject.CurrentMission.static.GetDefaultTimeLimit() > 0)
            INVInventory.SetTimer(1,true);
    }
    INVInventory.MutINV = self;
    INVInventory.ServerCheckShopItems();
    INVInventory.SetOwner(Other);
    INVInventory.Instigator = Other;
    INVInventory.InitialUpdate(Other);

    FindRichestPlayer(Data);
    if(bAllowTrade)
        Other.GiveWeapon("SonicRPG45.TradeWeapon");
}

event PostLoadSavedGame()
{
	bHasInteraction = false;
}

function NotifyLogout(Controller Exiting)
{
	local Inventory Inv;
    local INVInventory INVInventory;

	if(Level.Game.bGameRestarted)
		return;

    if(Exiting != none && Exiting.Pawn != None)
        INVInventory = INVInventory(Exiting.Pawn.FindInventoryType(class'INVInventory'));
    if(Exiting != none && INVInventory == none)
    {
    	for(Inv = Exiting.Inventory; Inv != None; Inv = Inv.Inventory)
    	{
    		INVInventory = INVInventory(Inv);
    		if(INVInventory != None)
    			break;
    	}
	}

	if(INVInventory != None)
	{
		if(Exiting.IsA('PlayerController'))
            INVInventory.DataObject.SaveConfig();
        FindRichestPlayer(INVInventory.DataObject);
        INVInventory.Destroy();
	}
}

function DriverEnteredVehicle(Vehicle V, Pawn P)
{
	local Inventory Inv;
    local INVInventory INVInventory;

	if(V != none && V.Controller != none)
    {
    	for(Inv = V.Controller.Inventory; Inv != None; Inv = Inv.Inventory)
    	{
    		INVInventory = INVInventory(Inv);
    		if(INVInventory != None)
    			break;
    	}
	}

    if(P != none && INVInventory == None)
		INVInventory = INVInventory(P.FindInventoryType(class'INVInventory'));
	if(INVInventory != None)
	{
		INVInventory.ModifyVehicle(V);
		INVInventory.ClientModifyVehicle(V);
	}
	Super.DriverEnteredVehicle(V, P);
}

function DriverLeftVehicle(Vehicle V, Pawn P)
{
	local Inventory Inv;
    local INVInventory INVInventory;

	if(P != none && P.Controller != none)
    {
    	for(Inv = P.Controller.Inventory; Inv != None; Inv = Inv.Inventory)
    	{
    		INVInventory = INVInventory(Inv);
    		if(INVInventory != None)
    			break;
    	}
	}

    if(P != none && INVInventory == None)
		INVInventory = INVInventory(P.FindInventoryType(class'INVInventory'));
	if(INVInventory != None)
	{
		INVInventory.UnModifyVehicle(V);
		INVInventory.ClientUnModifyVehicle(V);
	}
	Super.DriverLeftVehicle(V, P);
}

function Destroyed()
{
	if(TempLog != none)
	    TempLog.Destroy();
	Super.Destroyed();
}

defaultproperties
{
     CombatInfo=(LevelUpMessage="Congratulations! Your combat level is now level",OtherLevelUpMessage="just leveled up and is now level",SkillStartingLevel=1,SkillStartingXP=40,XPCap=10000,PointsPerLevel=100)
     Months(1)=31
     Months(2)=59
     Months(3)=90
     Months(4)=120
     Months(5)=151
     Months(6)=181
     Months(7)=212
     Months(8)=243
     Months(9)=273
     Months(10)=304
     Months(11)=334
     Months(12)=365
     MonthsLY(1)=31
     MonthsLY(2)=60
     MonthsLY(3)=91
     MonthsLY(4)=121
     MonthsLY(5)=152
     MonthsLY(6)=182
     MonthsLY(7)=213
     MonthsLY(8)=244
     MonthsLY(9)=274
     MonthsLY(10)=305
     MonthsLY(11)=335
     MonthsLY(12)=366
     DefaultSlots=6
     DeleteAfter=90
     DontDeleteCredits=1000000
     SaveDataTime=300
     Levels(0)=1
     Levels(1)=2
     Levels(2)=3
     Levels(3)=4
     Levels(4)=5
     Levels(5)=6
     Levels(6)=7
     Levels(7)=8
     Levels(8)=9
     Levels(9)=10
     Levels(10)=12
     Levels(11)=15
     Levels(12)=20
     Levels(13)=23
     Levels(14)=25
     Levels(15)=30
     Levels(16)=35
     Levels(17)=40
     Levels(18)=45
     Levels(19)=50
     Levels(20)=55
     Levels(21)=61
     Levels(22)=64
     Levels(23)=66
     Levels(24)=72
     Levels(25)=79
     Levels(26)=86
     Levels(27)=91
     Levels(28)=94
     Levels(29)=102
     Levels(30)=111
     Levels(31)=120
     Levels(32)=130
     Levels(33)=140
     Levels(34)=151
     Levels(35)=170
     Levels(36)=190
     Levels(37)=220
     Levels(38)=255
     Levels(39)=300
     Levels(40)=340
     Levels(41)=410
     Levels(42)=500
     Levels(43)=550
     Levels(44)=610
     Levels(45)=730
     Levels(46)=850
     Levels(47)=980
     Levels(48)=1030
     Levels(49)=1150
     Levels(50)=1300
     Levels(51)=1420
     Levels(52)=1650
     Levels(53)=1820
     Levels(54)=1970
     Levels(55)=2200
     Levels(56)=2400
     Levels(57)=2650
     Levels(58)=2900
     Levels(59)=3250
     Levels(60)=3400
     Levels(61)=3500
     Levels(62)=3700
     Levels(63)=4000
     Levels(64)=4300
     Levels(65)=4650
     Levels(66)=4800
     Levels(67)=5150
     Levels(68)=5350
     Levels(69)=5550
     Levels(70)=5700
     Levels(71)=6200
     Levels(72)=6500
     Levels(73)=6810
     Levels(74)=7250
     Levels(75)=7550
     Levels(76)=7700
     Levels(77)=7800
     Levels(78)=7900
     Levels(79)=7950
     Levels(80)=8000
     YellowColor=(G=255,R=255,A=255)
     RedColor=(R=255,A=255)
     GreenColor=(G=255,A=255)
     WhiteColor=(B=255,G=255,R=255,A=255)
     CreditPercentage=20.000000
     LootChance=25.000000
     LootableItems(0)=(ItemClass=Class'sonicRPG45.MiniHealthInvItem',MaxLoot=20,Chance=2000)
     LootableItems(1)=(ItemClass=Class'sonicRPG45.HealthInvItem',MaxLoot=5,Chance=1000)
     LootableItems(2)=(ItemClass=Class'sonicRPG45.SuperHealthInvItem',MaxLoot=2,Chance=500)
     LootableItems(3)=(ItemClass=Class'sonicRPG45.ShieldInvItem',MaxLoot=5,Chance=1000)
     LootableItems(4)=(ItemClass=Class'sonicRPG45.SuperShieldInvItem',MaxLoot=2,Chance=500)
     LootableItems(5)=(ItemClass=Class'sonicRPG45.AdrenalineInvItem',MaxLoot=20,Chance=2000)
     LootableItems(6)=(ItemClass=Class'sonicRPG45.AdrenalineTwoInvItem',MaxLoot=5,Chance=1000)
     LootableItems(7)=(ItemClass=Class'sonicRPG45.AdrenalineThreeInvItem',MaxLoot=2,Chance=500)
     LootableItems(8)=(ItemClass=Class'sonicRPG45.LinkAmmoInvItem',MaxLoot=5,Chance=200)
     LootableItems(9)=(ItemClass=Class'sonicRPG45.RocketAmmoInvItem',MaxLoot=5,Chance=200)
     LootableItems(10)=(ItemClass=Class'sonicRPG45.ShockAmmoInvItem',MaxLoot=5,Chance=200)
     LootableItems(11)=(ItemClass=Class'sonicRPG45.LGunAmmoInvItem',MaxLoot=5,Chance=200)
     LootableItems(12)=(ItemClass=Class'sonicRPG45.FlakAmmoInvItem',MaxLoot=5,Chance=200)
     LootableItems(13)=(ItemClass=Class'sonicRPG45.AssaultAmmoInvItem',MaxLoot=5,Chance=200)
     LootableItems(14)=(ItemClass=Class'sonicRPG45.AVRiLAmmoInvItem',MaxLoot=5,Chance=200)
     LootableItems(15)=(ItemClass=Class'sonicRPG45.BioAmmoInvItem',MaxLoot=5,Chance=200)
     LootableItems(16)=(ItemClass=Class'sonicRPG45.CSniperAmmoInvItem',MaxLoot=5,Chance=200)
     LootableItems(17)=(ItemClass=Class'sonicRPG45.DDamageInvItem',MaxLoot=3,Chance=20)
     LootableItems(18)=(ItemClass=Class'sonicRPG45.GrenadeAmmoInvItem',MaxLoot=5,Chance=200)
     LootableItems(19)=(ItemClass=Class'sonicRPG45.MineAmmoInvItem',MaxLoot=5,Chance=200)
     LootableItems(20)=(ItemClass=Class'sonicRPG45.MiniAmmoInvItem',MaxLoot=5,Chance=200)
     LootableItems(21)=(ItemClass=Class'sonicRPG45.LuckyWepInvItem',MaxLoot=3,Chance=200)
     LootableItems(22)=(ItemClass=Class'sonicRPG45.VampireWepInvItem',MaxLoot=3,Chance=100)
     LootableItems(23)=(ItemClass=Class'sonicRPG45.VorpalWepInvItem',MaxLoot=1,Chance=3)
     LootableItems(24)=(ItemClass=Class'sonicRPG45.InfiniteWepInvItem',MaxLoot=1,Chance=5)
     LootableItems(25)=(ItemClass=Class'sonicRPG45.FreezeWepInvItem',MaxLoot=3,Chance=100)
     LootableItems(26)=(ItemClass=Class'sonicRPG45.KnockbackWepInvItem',MaxLoot=3,Chance=100)
     LootableItems(27)=(ItemClass=Class'sonicRPG45.SpeedWepInvItem',MaxLoot=3,Chance=100)
     LootableItems(28)=(ItemClass=Class'sonicRPG45.NullWepInvItem',MaxLoot=3,Chance=100)
     LootableItems(29)=(ItemClass=Class'sonicRPG45.PiercingWepInvItem',MaxLoot=3,Chance=100)
     LootableItems(30)=(ItemClass=Class'sonicRPG45.PenetratingWepInvItem',MaxLoot=3,Chance=100)
     LootableItems(31)=(ItemClass=Class'sonicRPG45.ReflectWepInvItem',MaxLoot=3,Chance=100)
     LootableItems(32)=(ItemClass=Class'sonicRPG45.RageWepInvItem',MaxLoot=1,Chance=50)
     LootableItems(33)=(ItemClass=Class'sonicRPG45.PoisonWepInvItem',MaxLoot=3,Chance=100)
     LootableItems(34)=(ItemClass=Class'sonicRPG45.ProtectionWepInvItem',MaxLoot=3,Chance=100)
     LootableItems(35)=(ItemClass=Class'sonicRPG45.ForceWepInvItem',MaxLoot=3,Chance=100)
     LootableItems(36)=(ItemClass=Class'sonicRPG45.EnergyWepInvItem',MaxLoot=1,Chance=50)
     LootableItems(37)=(ItemClass=Class'sonicRPG45.SturdyWepInvItem',MaxLoot=3,Chance=100)
     LootableItems(38)=(ItemClass=Class'sonicRPG45.SpeedGizmoCreator',MaxLoot=1,Chance=1)
     LootableItems(39)=(ItemClass=Class'sonicRPG45.JumpGizmoCreator',MaxLoot=1,Chance=1)
     LootableItems(40)=(ItemClass=Class'sonicRPG45.GhostGizmoCreator',MaxLoot=1,Chance=1)
     LootableItems(41)=(ItemClass=Class'sonicRPG45.SwimGizmoCreator',MaxLoot=1,Chance=2)
     LootableItems(42)=(ItemClass=Class'sonicRPG45.TarydiumCrystal',MaxLoot=20,Chance=4000)
     LootableItems(43)=(ItemClass=Class'sonicRPG45.AdrenalineCreator',MaxLoot=1,Chance=300)
     LootableItems(44)=(ItemClass=Class'sonicRPG45.AdrenalineTwoCreator',MaxLoot=1,Chance=200)
     LootableItems(45)=(ItemClass=Class'sonicRPG45.AdrenalineThreeCreator',MaxLoot=1,Chance=100)
     LootableItems(46)=(ItemClass=Class'sonicRPG45.MiniHealthCreator',MaxLoot=1,Chance=300)
     LootableItems(47)=(ItemClass=Class'sonicRPG45.HealthCreator',MaxLoot=1,Chance=200)
     LootableItems(48)=(ItemClass=Class'sonicRPG45.SuperHealthCreator',MaxLoot=1,Chance=100)
     LootableItems(49)=(ItemClass=Class'sonicRPG45.AmmoGizmoCreator',MaxLoot=1,Chance=3)
     LootableItems(50)=(ItemClass=Class'sonicRPG45.MetaPupaeCreator',MaxLoot=1,Chance=400)
     LootableItems(51)=(ItemClass=Class'sonicRPG45.MetaRazorFlyCreator',MaxLoot=1,Chance=450)
     LootableItems(52)=(ItemClass=Class'sonicRPG45.MetaGasbagCreator',MaxLoot=1,Chance=400)
     LootableItems(53)=(ItemClass=Class'sonicRPG45.MetaKrallCreator',MaxLoot=1,Chance=350)
     LootableItems(54)=(ItemClass=Class'sonicRPG45.MetaKrallEliteCreator',MaxLoot=1,Chance=250)
     LootableItems(55)=(ItemClass=Class'sonicRPG45.MetaBruteCreator',MaxLoot=1,Chance=300)
     LootableItems(56)=(ItemClass=Class'sonicRPG45.MetaBehemothCreator',MaxLoot=1,Chance=150)
     LootableItems(57)=(ItemClass=Class'sonicRPG45.MetaWarLordCreator',MaxLoot=1,Chance=50)
     LootableItems(58)=(ItemClass=Class'sonicRPG45.MetaSkaarjCreator',MaxLoot=1,Chance=100)
     LootableItems(59)=(ItemClass=Class'sonicRPG45.ChanceGizmoCreator',MaxLoot=1,Chance=1)
     LootableItems(60)=(ItemClass=Class'sonicRPG45.MegaHealthInvItem',MaxLoot=1,Chance=250)
     LootableItems(61)=(ItemClass=Class'sonicRPG45.UltimateHealthInvItem',MaxLoot=1,Chance=125)
     LootableItems(62)=(ItemClass=Class'sonicRPG45.MysteryBox',MaxLoot=1,Chance=125)
     LootableItems(63)=(ItemClass=Class'sonicRPG45.VehicleGoliathV1Creator',MaxLoot=1,Chance=1)
     LootableItems(64)=(ItemClass=Class'sonicRPG45.VehicleHellBenderV1Creator',MaxLoot=1,Chance=2)
     LootableItems(65)=(ItemClass=Class'sonicRPG45.VehicleMantaV1Creator',MaxLoot=1,Chance=1)
     LootableItems(66)=(ItemClass=Class'sonicRPG45.VehicleScorpionV1Creator',MaxLoot=1,Chance=2)
     LootableItems(67)=(ItemClass=Class'sonicRPG45.VehicleRaptorV1Creator',MaxLoot=1,Chance=1)
     Skills(0)=(SkillName="Creation",Description="This skill is used for creating items, the higher it is the better and more valuable items you can create.")
     Skills(1)=(SkillName="Refining",Description="This skill is used for refining tarydium crystals, the higher it gets the better refiners you can use to make better liquid tarydium.")
     Skills(2)=(SkillName="Metamorphosis",Description="Increasing this skill will allow you to use better metamorphosis items which transform you into a monster for a certain amount of time.")
     Skills(3)=(SkillName="Healing Knowledge",Description="The higher this is, the better healing items you can use like health packs, team heals or area of effect heals.")
     Skills(4)=(SkillName="Adrenal Knowledge",Description="The higher this is, the more advanced adrenaline increase items you can use like adrenaline pills, group pills or area of effect adrenaline boosts.")
     Skills(5)=(SkillName="Weapons Knowledge",Description="The higher this is, the better items you can use that effects weapons in some way.")
     Skills(6)=(SkillName="Defence Knowledge",Description="The higher this is, the higher level items you can use that need this skill like, traps or debuffs ect...")
     Skills(7)=(SkillName="Driving",Description="Your driving skill, the more you have the better vehicles you can own and drive.")
     ClassesAvailable(0)=Class'sonicRPG45.ClassFM'
     ClassesAvailable(1)=Class'sonicRPG45.ClassWS'
     ClassesAvailable(2)=Class'sonicRPG45.ClassAJ'
     ClassesAvailable(3)=Class'sonicRPG45.ClassDE'
     ShopItems(0)=Class'sonicRPG45.MiniHealthInvItem'
     ShopItems(1)=Class'sonicRPG45.HealthInvItem'
     ShopItems(2)=Class'sonicRPG45.SuperHealthInvItem'
     ShopItems(3)=Class'sonicRPG45.ShieldInvItem'
     ShopItems(4)=Class'sonicRPG45.SuperShieldInvItem'
     ShopItems(5)=Class'sonicRPG45.AdrenalineInvItem'
     ShopItems(6)=Class'sonicRPG45.AdrenalineTwoInvItem'
     ShopItems(7)=Class'sonicRPG45.AdrenalineThreeInvItem'
     ShopItems(8)=Class'sonicRPG45.LinkAmmoInvItem'
     ShopItems(9)=Class'sonicRPG45.RocketAmmoInvItem'
     ShopItems(10)=Class'sonicRPG45.ShockAmmoInvItem'
     ShopItems(11)=Class'sonicRPG45.LGunAmmoInvItem'
     ShopItems(12)=Class'sonicRPG45.FlakAmmoInvItem'
     ShopItems(13)=Class'sonicRPG45.AssaultAmmoInvItem'
     ShopItems(14)=Class'sonicRPG45.AVRiLAmmoInvItem'
     ShopItems(15)=Class'sonicRPG45.BioAmmoInvItem'
     ShopItems(16)=Class'sonicRPG45.CSniperAmmoInvItem'
     ShopItems(17)=Class'sonicRPG45.DDamageInvItem'
     ShopItems(18)=Class'sonicRPG45.GrenadeAmmoInvItem'
     ShopItems(19)=Class'sonicRPG45.MineAmmoInvItem'
     ShopItems(20)=Class'sonicRPG45.MiniAmmoInvItem'
     ShopItems(21)=Class'sonicRPG45.TarydiumRefinerGradeOne'
     ShopItems(22)=Class'sonicRPG45.TarydiumRefinerGradeTwo'
     ShopItems(23)=Class'sonicRPG45.TarydiumRefinerGradeThree'
     ShopItems(24)=Class'sonicRPG45.TarydiumRefinerGradeFour'
     ShopItems(25)=Class'sonicRPG45.AdrenalineCreator'
     ShopItems(26)=Class'sonicRPG45.MiniHealthCreator'
     ShopItems(27)=Class'sonicRPG45.MetaPupaeCreator'
     ShopItems(28)=Class'sonicRPG45.MetaReverseItem'
     ShopItems(29)=Class'sonicRPG45.AoEHeal'
     ShopItems(30)=Class'sonicRPG45.AoEHealL'
     ShopItems(31)=Class'sonicRPG45.AoEHeal2S'
     ShopItems(32)=Class'sonicRPG45.AoEHeal2L'
     ShopItems(33)=Class'sonicRPG45.AoEHeal3S'
     ShopItems(34)=Class'sonicRPG45.AoEHeal3L'
     ShopItems(35)=Class'sonicRPG45.AoEAdren'
     ShopItems(36)=Class'sonicRPG45.AoEAdrenL'
     ShopItems(37)=Class'sonicRPG45.AoEAdren2S'
     ShopItems(38)=Class'sonicRPG45.AoEAdren2L'
     ShopItems(39)=Class'sonicRPG45.AoEAdren3S'
     ShopItems(40)=Class'sonicRPG45.AoEAdren3L'
     ShopItems(41)=Class'sonicRPG45.LuckyWepInvItem'
     ShopItems(42)=Class'sonicRPG45.FreezeWepInvItem'
     ShopItems(43)=Class'sonicRPG45.SpeedWepInvItem'
     ShopItems(44)=Class'sonicRPG45.ReflectWepInvItem'
     ShopItems(45)=Class'sonicRPG45.PoisonWepInvItem'
     ShopItems(46)=Class'sonicRPG45.MetaPupae'
     ShopItems(47)=Class'sonicRPG45.MetaSkaarj'
     ShopItems(48)=Class'sonicRPG45.MetaBehemoth'
     ShopItems(49)=Class'sonicRPG45.MetaBrute'
     ShopItems(50)=Class'sonicRPG45.MetaWarLord'
     ShopItems(51)=Class'sonicRPG45.MetaRazorFly'
     ShopItems(52)=Class'sonicRPG45.MetaKrall'
     ShopItems(53)=Class'sonicRPG45.MetaKrallElite'
     ShopItems(54)=Class'sonicRPG45.MetaGasBag'
     ShopItems(55)=Class'sonicRPG45.MegaHealthInvItem'
     ShopItems(56)=Class'sonicRPG45.UltimateHealthInvItem'
     ShopItems(57)=Class'sonicRPG45.AoEShield'
     ShopItems(58)=Class'sonicRPG45.AoEShieldL'
     ShopItems(59)=Class'sonicRPG45.AoEShield2S'
     ShopItems(60)=Class'sonicRPG45.AoEShield2L'
     ShopItems(61)=Class'sonicRPG45.AoEShield3S'
     ShopItems(62)=Class'sonicRPG45.AoEShield3L'
     ShopItems(63)=Class'sonicRPG45.VehicleTeleporter'
     WebDescString(0)="This is the time that the items in your inventory will save."
     WebDescString(1)="Starting credits of a new player."
     WebDescString(2)="The amount of slots a player has in his inventory by default."
     WebDescString(3)="How much credits you get for killing a pawn. Based on thier default health divided by this."
     WebDescString(4)="Remove all the objects inside the InventorySystem.ini so all stats are back to default."
     WebDescString(5)="Allow Players To Trade With Other Players."
     WebDescString(6)="The chance of getting an item after killing a monster."
     WebDescString(7)="If anyone hasnt played in this many days it will remove thier stats thus saving space."
     WebDisplayText(0)="Auto Save Time (Seconds)"
     WebDisplayText(1)="Starting Credits"
     WebDisplayText(2)="Default Inventory Slots"
     WebDisplayText(3)="Credits Per Kill (%)"
     WebDisplayText(4)="Reset Player Stats Next Map?"
     WebDisplayText(5)="Allow Trading?"
     WebDisplayText(6)="Looting Chance (%)"
     WebDisplayText(7)="Delete Data After (DAYS)"
     bAllowTrade=True
     bLogTrade=True
     bAddToServerPackages=True
     GroupName="Inventory"
     FriendlyName="Inventory System V45"
     Description="This mutator add the inventory system to any gametype.||Made for UnrealInsanity.com servers and site."
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
