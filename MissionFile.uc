class MissionFile extends Object;

struct PawnKillStruct
{
    var array<class<Pawn> > KillClass;
    var int KillAmount;
    var string PawnName;
};
struct ItemRewardStruct
{
    var class<MainInventoryItem> ItemAwards;
    var int ItemAwardAmount;
};
struct ItemReq
{
    var class<MainInventoryItem> ItemNeed;
    var int ItemAmount;
    var bool bDeleteOnQuestEnd;
};
struct DeleteAtEndStruct
{
    var class<MainInventoryItem> DeleteItem;
    var int DeleteAmount;
    var bool bDeleteAll;
};

var protected array<DeleteAtEndStruct> DeleteOnEndItems;
var protected array<PawnKillStruct> PawnRequirements;
var protected array<ItemReq> ItemsRequired;
var protected array<ItemRewardStruct> ItemRewards;
var protected array<class<MissionFile> > CompletedMissionsToStart;
var protected bool bDebug, bOnlyAnnounceToSelf, bCanReplayMission;
var protected int AwardedCredits, MissionPointsNeeded, CombatLevelNeededToStart, SlotsNeededToStart, TimeLimit,
                  MissionPointsAwarded, CombatXPRewarded;

var string MissionName, MissionDifficulty;
var sound MissionCompletedSound, MissionFailedSound, MissionStartedSound;

var localized string MissionStartedString, MissionEndedString, DontMeetRequirements, MissionsRequired,
                     CreditsOnComplete, MissionAddedToLoot, MissionTimeAllottedString, MissionBrief,
                     MissionPointsNeededString, MissionPointsRewardedString, CollectItems, MissionRewards,
                     KillString, AnnounceMissionCompletePart, DescriptionString, MissionTimeLeft,
                     NoInformationString, CombatLevelNeededString, NoInfoString, NotEnoughSlotsToStart,
                     CombatLevelIsntHighEnough, CombatXPAwardedOnComplete;

static simulated function int GetDefaultTimeLimit()
{
    return default.TimeLimit;
}

static simulated function int GetDefaultMissionPointsAwarded()
{
    return default.MissionPointsAwarded;
}

static simulated function PostRender(InventoryInteraction InteractionOwner, Canvas Canvas);

static simulated function string GetDescription(Controller Other)
{
    local string Desc;
    local int i;
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory == none)
        return "";

    if(default.PawnRequirements.Length > 0)
    {
        Desc = (Desc $ "||" $ default.KillString);
        for(i=0;i<default.PawnRequirements.Length;i++)
        {
            Desc = (Desc $ "|" $ default.PawnRequirements[i].KillAmount @ default.PawnRequirements[i].PawnName);
            if(INVInventory.DataRep.CurrentMission != none && INVInventory.DataRep.CurrentMission == default.class)
                Desc = (Desc @ "(" $ INVInventory.DataRep.MissionObjectSuccess[i] $ ")");
        }
    }
    if(default.ItemsRequired.Length > 0)
    {
        Desc = (Desc $ "||" $ default.CollectItems);
        for(i=0;i<default.ItemsRequired.Length;i++)
        {
            Desc = (Desc $ "|" $ default.ItemsRequired[i].ItemAmount @ default.ItemsRequired[i].ItemNeed.static.GetInvItemName(Other));
            if(INVInventory.DataRep.CurrentMission != none && INVInventory.DataRep.CurrentMission == default.class)
                Desc = (Desc @ "(" $ INVInventory.DataRep.MissionObjectSuccess[i+default.PawnRequirements.Length] $ ")");
        }
    }
    if(default.AwardedCredits > 0)
        Desc = (Desc $ "||" $ default.CreditsOnComplete @ default.AwardedCredits);
    if(default.CombatXPRewarded > 0)
        Desc = (Desc $ "||" $ default.CombatXPAwardedOnComplete @ default.CombatXPRewarded);
    if(default.MissionPointsAwarded > 0)
        Desc = (Desc $ "|" $ default.MissionPointsRewardedString @ default.MissionPointsAwarded);
    if(default.CombatLevelNeededToStart > 0)
        Desc = (Desc $ "|" $ default.CombatLevelNeededString @ INVInventory.DataRep.CombatLevel);
    if(default.TimeLimit > 0)
    {
        Desc = (Desc $ "|" $ default.MissionTimeAllottedString @ default.TimeLimit);
        if(INVInventory.DataRep.CurrentMission != none && INVInventory.DataRep.CurrentMission == default.class)
            Desc = (Desc $ "|" $ default.MissionTimeLeft @ (default.TimeLimit - INVInventory.DataRep.CurrentMissionTimeLapsed));
    }
    if(default.ItemRewards.Length > 0)
    {
        Desc = (Desc $ "||" $ default.MissionRewards);
        for(i=0;i<default.ItemRewards.Length;i++)
            Desc = (Desc $ "|" $ default.ItemRewards[i].ItemAwardAmount @ default.ItemRewards[i].ItemAwards);
    }
    if(default.CompletedMissionsToStart.Length > 0)
    {
        Desc = (Desc $ "||" $ default.MissionsRequired);
        for(i=0;i<default.CompletedMissionsToStart.Length;i++)
            Desc = (Desc $ "|" $ default.CompletedMissionsToStart[i].default.MissionName);
    }
    if(default.MissionPointsNeeded > 0)
        Desc = (Desc $ "|" $ default.MissionPointsNeededString @ default.MissionPointsNeeded);

    if(default.MissionBrief != "")
        Desc = (default.MissionBrief $ "||" $ default.DescriptionString $ Desc);
    else if(Desc != "")
        Desc = (default.DescriptionString $ Desc);
    else if(Desc == "")
        Desc = default.NoInformationString;
    return Desc;
}

static function int GetMissionObjectivesAmount(Controller Other)
{
    return (default.PawnRequirements.Length + default.ItemsRequired.Length);
}

static function bool bCanStartMission(Controller Other)
{
    local INVInventory INVInventory;
    local int i, x;
    local bool bCompletedMission;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory != none && INVInventory.DataObject != none && INVInventory.DataObject.CurrentMission == none)
    {
        if(INVInventory.DataObject.CombatLevel < default.CombatLevelNeededToStart)
        {
            PlayerController(Other).ClientMessage(default.CombatLevelIsntHighEnough);
            return false;
        }
        if(INVInventory.DataObject.Items.Length + default.SlotsNeededToStart > INVInventory.DataObject.Slots)
        {
            PlayerController(Other).ClientMessage(default.NotEnoughSlotsToStart @ default.SlotsNeededToStart);
            return false;
        }
        if(default.CompletedMissionsToStart.Length > 0)
        {
            for(i=0;i<default.CompletedMissionsToStart.Length;i++)
            {
                for(x=0;x<INVInventory.DataObject.CompletedMissions.Length;x++)
                {
                    if(INVInventory.DataObject.CompletedMissions[x] == default.CompletedMissionsToStart[i])
                    {
                        bCompletedMission = true;
                        x = INVInventory.DataObject.CompletedMissions.Length;
                    }
                }
                if(!bCompletedMission)
                {
                    if(PlayerController(Other) != none)
                        PlayerController(Other).ClientMessage(default.DontMeetRequirements);
                    return false;
                }
                bCompletedMission = false;
            }
        }
        if(INVInventory.GetMissionPoints() >= default.MissionPointsNeeded)
            return true;
        else if(PlayerController(Other) != none)
            PlayerController(Other).ClientMessage(default.DontMeetRequirements);
    }
    return false;
}

static function StartMission(Controller Other)
{
    if(PlayerController(Other) != none)
    {
        PlayerController(Other).ClientMessage(class'GameInfo'.static.MakeColorCode(class'mutInventorySystem'.default.GreenColor)$default.MissionStartedString);
        PlayerController(Other).ClientPlaySound(default.MissionStartedSound,true,2);
    }
}

static function Timer(INVInventory INVInventory)
{
    if(INVInventory == none || INVInventory.DataObject == none)
        return;

    INVInventory.DataObject.CurrentMissionTimeLapsed++;
    if(GetDefaultTimeLimit() - INVInventory.DataObject.CurrentMissionTimeLapsed <= 0)
    {
        EndMission(INVInventory.FindOwnerController());
        INVInventory.SetTimer(0.0,false);
    }
    else
        INVInventory.DataObject.CreateDataStruct(INVInventory.DataRep, false);
}

static function EndMission(Controller Other)
{
    local INVInventory INVInventory;
    local int i, x;
    local bool bHasItem;
    local Controller C;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory != none && INVInventory.DataObject != none && Other.PlayerReplicationInfo != none)
    {
        if(PlayerController(Other) != none)
            PlayerController(Other).ClientMessage(class'GameInfo'.static.MakeColorCode(class'mutInventorySystem'.default.RedColor)$default.MissionEndedString);
        if(CheckMissionComplete(Other))
        {
            if(PlayerController(Other) != none)
                PlayerController(Other).ClientPlaySound(default.MissionCompletedSound,true,2);
            INVInventory.DataObject.Credits += default.AwardedCredits;
            if(default.CombatXPRewarded > 0)
            {
                INVInventory.DataObject.CombatXP += default.CombatXPRewarded;
                class'mutInventorySystem'.static.CheckLevelUp(INVInventory);
            }
            for(x=0;x<default.ItemsRequired.Length;x++)
            {
                if(default.ItemsRequired[x].bDeleteOnQuestEnd)
                {
                    for(i=0;i<INVInventory.DataObject.Items.Length;i++)
                    {
                        if(INVInventory.DataObject.Items[i] == default.ItemsRequired[x].ItemNeed)
                        {
                            INVInventory.DataObject.ItemsAmount[i] -= default.ItemsRequired[x].ItemAmount;
                            if(INVInventory.DataObject.ItemsAmount[i] <= 0)
                            {
                                INVInventory.DataObject.ItemsAmount.Remove(i, 1);
                                INVInventory.DataObject.Items.Remove(i, 1);
                            }
                            break;
                        }
                    }
                }
            }
            for(x=0;x<default.ItemRewards.Length;x++)
            {
                for(i=0;i<INVInventory.DataObject.Items.Length;i++)
                {
                    if(INVInventory.DataObject.Items[i] == default.ItemRewards[x].ItemAwards)
                    {
                        INVInventory.DataObject.ItemsAmount[i] += default.ItemRewards[x].ItemAwardAmount;
                        INVInventory.ReplicateToClientSide(i, INVInventory.DataObject.Items[i], INVInventory.DataObject.ItemsAmount[i]);
                        bHasItem = true;
                        break;
                    }
                }
                if(!bHasItem)
                {
                    if(INVInventory.DataObject.Items.Length + 1 <= INVInventory.DataObject.Slots)
                    {
                        INVInventory.DataObject.Items[INVInventory.DataObject.Items.Length] = default.ItemRewards[x].ItemAwards;
                        INVInventory.DataObject.ItemsAmount[INVInventory.DataObject.ItemsAmount.Length] = default.ItemRewards[x].ItemAwardAmount;
                        INVInventory.ClientAddNewItem(default.ItemRewards[x].ItemAwards, default.ItemRewards[x].ItemAwardAmount);
                    }
                    else
                    {
                        for(i=0;i<INVInventory.LootedItems.Length;i++)
                        {
                            if(INVInventory.LootedItems[i] == default.ItemRewards[x].ItemAwards)
                            {
                                INVInventory.LootedItemsAmount[i] += default.ItemRewards[x].ItemAwardAmount;
                                INVInventory.ReplicateLootToClientSide(i, INVInventory.LootedItems[i], INVInventory.LootedItemsAmount[i]);
                                break;
                            }
                        }
                        INVInventory.LootedItems[INVInventory.LootedItems.Length] = default.ItemRewards[x].ItemAwards;
                        INVInventory.LootedItemsAmount[INVInventory.LootedItemsAmount.Length] = default.ItemRewards[x].ItemAwardAmount;
                        INVInventory.ClientAddNewLootItem(default.ItemRewards[x].ItemAwards, default.ItemRewards[x].ItemAwardAmount);
                        if(PlayerController(Other) != none)
                            PlayerController(Other).ClientMessage(default.MissionAddedToLoot);
                    }
                }
                bHasItem = false;
            }
            if(!default.bCanReplayMission)
            {
                INVInventory.DataObject.CompletedMissions[INVInventory.DataObject.CompletedMissions.Length] = INVInventory.DataObject.CurrentMission;
                INVInventory.ReplicateCompletedMissions(INVInventory.DataObject.CompletedMissions.Length, INVInventory.DataObject.CurrentMission);
            }
            if(!default.bOnlyAnnounceToSelf)
                for(C=INVInventory.Level.ControllerList;C!=none;C=C.NextController)
                    if(PlayerController(C) != none && C != Other)
                        PlayerController(C).ClientMessage(Other.PlayerReplicationInfo.PlayerName @ default.AnnounceMissionCompletePart
                                                        @ INVInventory.DataObject.CurrentMission.default.MissionName $ ".");
        }
        else if(PlayerController(Other) != none)
            PlayerController(Other).ClientPlaySound(default.MissionFailedSound,true,2);
        for(i=0;i<INVInventory.DataObject.Items.Length;i++)
        {
            for(x=0;x<default.DeleteOnEndItems.Length;x++)
            {
                if(INVInventory.DataObject.Items[i] == default.DeleteOnEndItems[x].DeleteItem
                && (default.DeleteOnEndItems[x].DeleteAmount > 0
                || default.DeleteOnEndItems[x].bDeleteAll))
                {
                    if(default.DeleteOnEndItems[x].bDeleteAll)
                        INVInventory.ChangeItem(INVInventory.DataObject.Items[i], -INVInventory.DataObject.ItemsAmount[i]);
                    else
                        INVInventory.ChangeItem(INVInventory.DataObject.Items[i], -default.DeleteOnEndItems[x].DeleteAmount);
                    x = INVInventory.DataObject.Items.Length;
                    i--;
                }
            }
        }
        INVInventory.DataObject.MissionObjectSuccess.Remove(0, INVInventory.DataObject.MissionObjectSuccess.Length);
        INVInventory.DataObject.CurrentMissionTimeLapsed = 0;
        INVInventory.DataObject.CurrentMission = none;
        INVInventory.DataObject.CreateDataStruct(INVInventory.DataRep, false);
        INVInventory.ClientInventoryUpdateGUI();
        INVInventory.ClientMissionInfoUpdate();
        if(default.TimeLimit > 0)
            INVInventory.SetTimer(0,false);
    }
}

static function PickedUpItem(Controller Other, class<MainInventoryItem> Item, int Amount, string PickupType)
{
    local int i, x;
    local INVInventory INVInventory;

    if(Item == none)
		return;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory == none || INVInventory.DataObject == none)
        return;

    if(PickupType ~= "lootitem")
    {
        for(i=0;i<default.ItemsRequired.Length;i++)
        {
            x = i+default.PawnRequirements.Length;
            if(Item == default.ItemsRequired[i].ItemNeed)
            {
                INVInventory.DataObject.MissionObjectSuccess[x] += Amount;
                INVInventory.ReplicateMissionObjectSuccess(x, INVInventory.DataObject.MissionObjectSuccess[x]);
                INVInventory.ClientMissionInfoUpdate();
            }
        }
    }

    if(CheckMissionComplete(Other))
        EndMission(Other);
}

static simulated function array<string> GetHUDMissionText(INVInventory INVInventory)
{
    local int i;
    local array<string> TrackerArray;

    if(INVInventory == none)
    {
        TrackerArray[TrackerArray.length] = default.NoInfoString;
        return TrackerArray;
    }

    for(i=0;i<default.PawnRequirements.Length;i++)
        TrackerArray[TrackerArray.length] = (default.PawnRequirements[i].PawnName
      @ "("$INVInventory.DataRep.MissionObjectSuccess[i]$"/"$default.PawnRequirements[i].KillAmount$")");

    for(i=0;i<default.ItemsRequired.Length;i++)
        TrackerArray[TrackerArray.length] = (default.ItemsRequired[i].ItemNeed.static.GetInvItemName(none)
      @ "("$INVInventory.DataRep.MissionObjectSuccess[i+default.PawnRequirements.Length]$"/"$default.ItemsRequired[i].ItemAmount$")");

    if(TrackerArray.length == 0)
        TrackerArray[TrackerArray.length] = default.NoInfoString;
    return TrackerArray;
}

/*
0 = Kill
1 = Item
*/
protected function byte GetMissionObjectPos(byte Type, byte Num)
{
    if(Type == 0)
        return Num;
    else if(Type == 1)
        return Num+default.PawnRequirements.Length;
    return -1;
}

static function bool CheckMissionComplete(Controller Other)
{
    local int i;
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory == none || INVInventory.DataObject == none)
        return false;

    for(i=0;i<default.PawnRequirements.Length;i++)
        if(INVInventory.DataObject.MissionObjectSuccess[i] < default.PawnRequirements[i].KillAmount)
            return false;
    for(i=0;i<default.ItemsRequired.Length;i++)
        if(INVInventory.DataObject.MissionObjectSuccess[i+default.PawnRequirements.Length] < default.ItemsRequired[i].ItemAmount)
            return false;
    return true;
}

static function NetDamage(int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    if(CheckMissionComplete(instigatedBy.Controller))
        EndMission(instigatedBy.Controller);
}

static function ScoreKill(Controller Killer, Controller Killed)
{
    local int i, x;
    local INVInventory INVInventory;

    if(Killed == none || Killer == none || Killed.Pawn == none)
		return;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Killer);
    if(INVInventory == none || INVInventory.DataObject == none)
        return;

    for(i=0;i<default.PawnRequirements.Length;i++)
    {
        for(x=0;x<default.PawnRequirements[i].KillClass.Length;x++)
        {
            if(Killed.Pawn.class == default.PawnRequirements[i].KillClass[x])
            {
                INVInventory.DataObject.MissionObjectSuccess[i]++;
                INVInventory.ReplicateMissionObjectSuccess(i, INVInventory.DataObject.MissionObjectSuccess[i]);
                INVInventory.ClientMissionInfoUpdate();
            }
        }
    }

    if(CheckMissionComplete(Killer))
        EndMission(Killer);
}

static function array<string> GetImageContextArray(Controller Other)
{
    local array<string> ContextString;
    local int i;
    local bool bCompleted;
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory == none)
        return ContextString;

    for(i=0;i<INVInventory.DataRep.CompletedMissions.length;i++)
    {
        if(INVInventory.DataRep.CompletedMissions[i] == default.class)
        {
            bCompleted = true;
            break;
        }
    }
    if(!bCompleted)
        ContextString[ContextString.Length] = "Start Mission";
    if(INVInventory.DataRep.CurrentMission == default.class)
	    ContextString[ContextString.Length] = "End Mission";
	ContextString[ContextString.Length] = "Mission Information";
	return ContextString;
}

static function bool UseImageContextArray(Controller Other, string ContextString)
{
    local INVInventory INVInventory;
//    local bool bValid;
//    local int i;
//
//    for(i=0;i<class'MissionHudClass'.default.AvailableMissions;i++)
//        if(class'MissionHudClass'.default.AvailableMissions[i] == default.class)
//            bValid = true;
//    if(!bValid)
//        return false;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory == none)
        return false;

    if(ContextString ~= "Start Mission")
    {
        INVInventory.StartNewMission(default.class);
        return true;
    }
    else if(ContextString ~= "End Mission" && !INVInventory.bMissionEndOpen
    && default.class == INVInventory.DataRep.CurrentMission
    && PlayerController(Other) != none)
    {
        PlayerController(Other).ClientOpenMenu("SonicRPG45.MissionEndGUI");
        return true;
    }
    else if(ContextString ~= "Mission Information" && PlayerController(Other) != none)
    {
        INVInventory.MissionItem = default.class;
        if(!INVInventory.bMissionInfoOpen)
            PlayerController(Other).ClientOpenMenu("SonicRPG45.MissionInfoGUI");
        return true;
    }
    return false;
}

defaultproperties
{
     MissionPointsAwarded=1
     MissionName="Base Mission"
     MissionDifficulty="Easy."
     MissionCompletedSound=Sound'AnnouncerAssault.Generic.Objective_accomplished'
     MissionFailedSound=Sound'MenuSounds.denied1'
     MissionStartedSound=Sound'AssaultSounds.HumanShip.TargetCycle01'
     MissionStartedString="You started a new mission."
     MissionEndedString="Your mission was ended."
     DontMeetRequirements="You dont meet the requirements to start this mission."
     MissionsRequired="You need to complete these missions to start this one:"
     CreditsOnComplete="Credits awarded for completion:"
     MissionAddedToLoot="You dont have enough space in your inventory to hold your item reward so it was added to your loot."
     MissionTimeAllottedString="Time allotted to complete mission:"
     MissionPointsNeededString="Mission Points needed to start mission:"
     MissionPointsRewardedString="Mission Points rewarded for completion:"
     CollectItems="Collect:"
     MissionRewards="Item Rewards:"
     KillString="Kill:"
     AnnounceMissionCompletePart="has completed the mission:"
     DescriptionString="To complete this mission you have to:"
     MissionTimeLeft="Time left:"
     NoInformationString="No information."
     CombatLevelNeededString="Combat Level Needed:"
     NoInfoString="No Info"
     NotEnoughSlotsToStart="Not enough room in your inventory to start this mission, you need atleast this many slots empty:"
     CombatLevelIsntHighEnough="Your combat level isnt high enough to start this mission."
     CombatXPAwardedOnComplete="Combat XP awarded on completion:"
}
