class InventoryPlayerDataObject extends Object
	config(InventorySystem)
	PerObjectConfig;

const SkillAmount = 8;

var config string OwnerID;
var config int Slots, LastPlayed, CombatLevel, SkillLevel[SkillAmount], CurrentMissionTimeLapsed;
var config float CombatXP, Credits;
var config class<ClassFile> CharClass;
var config class<MissionFile> CurrentMission;
var config array<class<MainInventoryItem> > Items;
var config array<class<MissionFile> > CompletedMissions;
var config array<int> ItemsAmount, MissionObjectSuccess;

struct InventoryPlayerData
{
    var int Slots, CombatLevel, CurrentMissionTimeLapsed, SkillLevel[SkillAmount];
	var float CombatXP, Credits;
	var class<ClassFile> CharClass;
    var class<MissionFile> CurrentMission;
	var array<class<MainInventoryItem> > Items;
	var array<class<MissionFile> > CompletedMissions;
	var array<int> ItemsAmount, MissionObjectSuccess;
};

function CreateDataStruct(out InventoryPlayerData Data, bool bOnlyCredits, optional bool bUpdateSkills)
{
    local int i;

    Data.Credits = Credits;
	if(bOnlyCredits)
	    return;
    Data.Slots = Slots;
    Data.CombatLevel = CombatLevel;
    Data.CombatXP = CombatXP;
    Data.CurrentMissionTimeLapsed = CurrentMissionTimeLapsed;
    Data.CurrentMission = CurrentMission;
    Data.Items = Items;
	Data.CompletedMissions = CompletedMissions;
	Data.ItemsAmount = ItemsAmount;
    Data.MissionObjectSuccess = MissionObjectSuccess;
    Data.CharClass = CharClass;
    if(!bUpdateSkills)
        return;
    for(i=0;i<ArrayCount(SkillLevel);i++)
        Data.SkillLevel[i] = SkillLevel[i];
}

defaultproperties
{
}
