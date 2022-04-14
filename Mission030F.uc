/*
Start Mission =                      Crystals & Refiner
Refine Crystals =                    Crystals - Refiner = Liquid Crystals & Creator
Use Creator to make pupae item =     Liquid Crystals - Creator = Credits & Pupae
*/
class Mission030F extends MissionFile;

static function int GetMissionObjectivesAmount(Controller Other)
{
    return 1;
}

static function PickedUpItem(Controller Other, class<MainInventoryItem> Item, int Amount, string PickupType)
{
    local INVInventory INVInventory;

    if(Item == none)
		return;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory == none || INVInventory.DataObject == none)
        return;

    if(PickupType ~= "refineditem" && Item == class'TrainingLiquidTarydiumGradeOne' && INVInventory.DataObject.MissionObjectSuccess[0] == 0)
    {
        INVInventory.DataObject.MissionObjectSuccess[0] = 1;
        INVInventory.ReplicateMissionObjectSuccess(0, 1);
        INVInventory.ClientMissionInfoUpdate();
    }
    else if(PickupType ~= "createditem" && Item == class'TrainingMetaPupae' && INVInventory.DataObject.MissionObjectSuccess[0] == 1)
    {
        INVInventory.DataObject.MissionObjectSuccess[0] = 2;
        INVInventory.ReplicateMissionObjectSuccess(0, 2);
        INVInventory.ClientMissionInfoUpdate();
    }
    super.PickedUpItem(Other, Item, Amount, PickupType);
}

static simulated function array<string> GetHUDMissionText(INVInventory INVInventory)
{
    local array<string> TrackerArray;

    if(INVInventory == none)
    {
        TrackerArray[TrackerArray.length] = default.NoInfoString;
        return TrackerArray;
    }

    if(INVInventory.DataRep.MissionObjectSuccess[0] == 0)
        TrackerArray[TrackerArray.length] = "-Open up your inventory by pressing K(default) find the refiner that was given to you and right click on it and click use, this will convert the crystals that you have into liquid crystals.";
    else if(INVInventory.DataRep.MissionObjectSuccess[0] == 1)
        TrackerArray[TrackerArray.length] = "-You have been given a pupae item creator, find it and use it like you did the refiner, this will convert the liquid crystals into an item, in this case its a pupae metamorphosis item. Usually you will need a certain creation level to use a creator, for this training mission you dont.";

    if(TrackerArray.length == 0)
        TrackerArray[TrackerArray.length] = default.NoInfoString;
    return TrackerArray;
}

static function bool CheckMissionComplete(Controller Other)
{
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory == none || INVInventory.DataObject == none)
        return false;

    if(INVInventory.DataObject.MissionObjectSuccess[0] != 2)
        return false;
    return true;
}

static function StartMission(Controller Other)
{
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory != none && INVInventory.DataObject != none
    && PlayerController(Other) != none)
    {
        super.StartMission(Other);
        INVInventory.DataObject.Items[INVInventory.DataObject.Items.Length] = class'TrainingTarydiumCrystal';
        INVInventory.DataObject.ItemsAmount[INVInventory.DataObject.ItemsAmount.Length] = 45;
        INVInventory.ClientAddNewItem(class'TrainingTarydiumCrystal', 45);
        INVInventory.DataObject.Items[INVInventory.DataObject.Items.Length] = class'TrainingTarydiumRefinerGradeOne';
        INVInventory.DataObject.ItemsAmount[INVInventory.DataObject.ItemsAmount.Length] = 1;
        INVInventory.ClientAddNewItem(class'TrainingTarydiumRefinerGradeOne', 1);
        INVInventory.ClientInventoryUpdateGUI();
    }
}

defaultproperties
{
     DeleteOnEndItems(0)=(DeleteItem=Class'sonicRPG45.TrainingTarydiumRefinerGradeOne',bDeleteAll=True)
     DeleteOnEndItems(1)=(DeleteItem=Class'sonicRPG45.TrainingTarydiumCrystal',bDeleteAll=True)
     DeleteOnEndItems(2)=(DeleteItem=Class'sonicRPG45.TrainingMetaPupaeCreator',bDeleteAll=True)
     DeleteOnEndItems(3)=(DeleteItem=Class'sonicRPG45.TrainingLiquidTarydiumGradeOne',bDeleteAll=True)
     SlotsNeededToStart=2
     MissionName="Training Mission 1"
     MissionDifficulty="Training"
     MissionBrief="This mission is to help you understand the basics of creating and refining for the inventory, it will take you through a few steps showing you how to do it."
}
