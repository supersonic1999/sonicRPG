class Mission031F extends MissionFile;

var color ObjColor;
var protected int DistanceToGetReward;
var protected class<Monster> MonsterToSpawn;
var protected class<EscortController> MonsterEscortController;
var protected StaticMesh myStaticMesh;

static function int GetMissionObjectivesAmount(Controller Other)
{
    return 6;
}

static function array<string> GetImageContextArray(Controller Other)
{
    local array<string> ContextString;
    local INVInventory INVInventory;

    ContextString = super.GetImageContextArray(Other);
    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory == none)
        return ContextString;

    if(INVInventory.DataRep.CurrentMission == default.class)
        ContextString[ContextString.length] = "Get new Waypoint!";
	return ContextString;
}

static function bool UseImageContextArray(Controller Other, string ContextString)
{
    local INVInventory INVInventory;

    if(super.UseImageContextArray(Other, ContextString))
        return true;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory == none)
        return false;

    if(INVInventory.DataRep.CurrentMission == default.class && ContextString ~= "Get new Waypoint!")
        return INVInventory.GetNewDestination();
    return false;
}

static simulated function PostRender(InventoryInteraction InteractionOwner, Canvas Canvas)
{
	local EscortSM SMA;
	local vector ScreenPos, IndicatorPos, CamLoc;
	local rotator CamRot;
	local string DistanceText;
	local float XL, YL, tileX, tileY, width, height;

    if(InteractionOwner == none || Canvas == none)
        return;

    foreach InteractionOwner.ViewportOwner.Actor.DynamicActors(class'EscortSM', SMA)
        if(SMA.Owner == InteractionOwner.ViewportOwner.Actor)
            break;

    if(SMA == none)
        return;

	Canvas.DrawColor = default.ObjColor;
	Canvas.Style = 5;
	Canvas.GetCameraLocation(CamLoc, CamRot);
	if(class'HUD_Assault'.static.IsTargetInFrontOfPlayer(Canvas, SMA, ScreenPos, CamLoc, CamRot))
	{
    	Canvas.Style = 5;
    	DistanceText = "[" $ int(VSize(SMA.Location-CamLoc)*0.01875.f) $ "m]";
    	Canvas.Font = InteractionOwner.ViewportOwner.Actor.myHud.GetConsoleFont(Canvas);

    	Canvas.StrLen(DistanceText, XL, YL);
    	XL = XL*0.5;
    	YL = YL*0.5;
    	tileX	= 64.f * 0.45 * InteractionOwner.ViewportOwner.Actor.myHud.ResScaleX * 1.0 * InteractionOwner.ViewportOwner.Actor.myHud.HUDScale;
    	tileY	= 64.f * 0.45 * InteractionOwner.ViewportOwner.Actor.myHud.ResScaleY * 1.0 * InteractionOwner.ViewportOwner.Actor.myHud.HUDScale;

    	width	= FMax(tileX*0.5, XL);
    	height	= tileY*0.5 + YL*2;
    	class'HUD_Assault'.static.ClipScreenCoords(Canvas, ScreenPos.X, ScreenPos.Y, width, height);

    	IndicatorPos.X = ScreenPos.X;
    	IndicatorPos.Y = ScreenPos.Y - height + YL + tileY*0.5;
        Canvas.SetPos(IndicatorPos.X - tileX*0.5, IndicatorPos.Y - tileY*0.5);
    	Canvas.DrawTile( Texture'AS_FX_TX.HUD.OBJ_Status', tileX, tileY, 127.0, 127.0, 64, 64);

    	Canvas.SetPos(IndicatorPos.X - XL, IndicatorPos.Y + tileY*0.5 );
    	Canvas.DrawText(DistanceText, false);
    	ScreenPos = IndicatorPos;
	}
}

static function bool bCanStartMission(Controller Other)
{
    local Pawn P;
    local RPGStatsInv StatsInv;
    local Inventory Inv;
    local int x;

    if(Other == none
    || Other.Pawn == none
    || default.MonsterToSpawn == none
    || default.MonsterEscortController == none
    || !super.bCanStartMission(Other))
        return false;

    default.MonsterToSpawn.default.ControllerClass = default.MonsterEscortController;
    default.MonsterToSpawn.default.GroundSpeed = 440;
    default.MonsterToSpawn.default.Health = 150;
    default.MonsterToSpawn.default.HealthMax = 150;
    default.MonsterToSpawn.default.SuperHealthMax = 150;
    default.MonsterToSpawn.default.bCanJump = true;
    P = Other.Spawn(default.MonsterToSpawn, Other,, Other.Pawn.Location+(default.MonsterToSpawn.default.CollisionHeight+Other.Pawn.default.CollisionHeight)*vect(0,0,1.5));
    if(P != none)
    {
        for(Inv = Other.Inventory; Inv != None; Inv = Inv.Inventory)
		{
			StatsInv = RPGStatsInv(Inv);
			if (StatsInv != None)
				break;
		}
		if(StatsInv == None)
			StatsInv = RPGStatsInv(Other.Pawn.FindInventoryType(class'RPGStatsInv'));
		if (StatsInv != None)
		{
			for (x = 0; x < StatsInv.Data.Abilities.length; x++)
				StatsInv.Data.Abilities[x].static.ModifyPawn(P, StatsInv.Data.AbilityLevels[x]);
			if (P.Controller.Inventory == None)
				P.Controller.Inventory = StatsInv;
			else
			{
				for (Inv = P.Controller.Inventory; Inv.Inventory != None; Inv = Inv.Inventory)
				{}
				Inv.Inventory = StatsInv;
			}
		}
        EscortController(P.Controller).SetMaster(Other);
        return true;
    }
    return false;
}

static function StartMission(Controller Other)
{
    PickDestination(Other);
    super.StartMission(Other);
}

static function bool PickDestination(Controller Other)
{
    local float BestRating, RandNum;
    local EscortSM SMA;
    local NavigationPoint BestNav, N;
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory == none || INVInventory.Level == none
    || INVInventory.DataObject == none || Other.Pawn == none
    || INVInventory.DataObject.CurrentMission != default.class)
        return false;

    for(N=INVInventory.Level.NavigationPointList;N!=none;N=N.NextNavigationPoint)
    {
        RandNum = FRand();
        if(RandNum > BestRating)
        {
            BestRating = RandNum;
            BestNav = N;
        }
    }
    if(BestNav != none)
    {
        INVInventory.DataObject.MissionObjectSuccess[0] = BestNav.Location.X;
        INVInventory.DataObject.MissionObjectSuccess[1] = BestNav.Location.Y;
        INVInventory.DataObject.MissionObjectSuccess[2] = BestNav.Location.Z;
        INVInventory.DataObject.MissionObjectSuccess[3] = Other.Pawn.Location.X;
        INVInventory.DataObject.MissionObjectSuccess[4] = Other.Pawn.Location.Y;
        INVInventory.DataObject.MissionObjectSuccess[5] = Other.Pawn.Location.Z;
        foreach INVInventory.DynamicActors(class'EscortSM', SMA)
        {
            if(SMA.Owner == Other)
            {
                SMA.SetStaticMesh(default.myStaticMesh);
                SMA.SetLocation(BestNav.Location);
                SMA.SetRotation(rot(0,0,0));
                return true;
            }
        }
        SMA = Other.Spawn(class'EscortSM', Other,, BestNav.Location);
        //SMA.SetStaticMesh(default.myStaticMesh);
        SMA.SetRotation(rot(0,0,0));
        return true;
    }
    return false;
}

static function bool CheckMissionComplete(Controller Other)
{
    local Monster P;
    local INVInventory INVInventory;
    local vector NPLocation;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory != none && Other.Pawn != none)
    {
        NPLocation.X = INVInventory.DataObject.MissionObjectSuccess[0];
        NPLocation.Y = INVInventory.DataObject.MissionObjectSuccess[1];
        NPLocation.Z = INVInventory.DataObject.MissionObjectSuccess[2];
        foreach INVInventory.DynamicActors(class'Monster', P)
            if(P.class == default.MonsterToSpawn
            && P.Controller != none
            && P.Controller.class == default.MonsterEscortController
            && EscortController(P.Controller).Master == Other
            && VSize(P.Location - NPLocation) < 256)
                return true;
    }
    return false;
}

static function Timer(INVInventory INVInventory)
{
    local Controller M, C;
    local bool bMonsterAlive;
    local vector NPLocation;

    if(INVInventory != none && INVInventory.DataObject != none)
    {
        M = INVInventory.FindOwnerController();
        if(M != none && M.Pawn == none)
        {
            EndMission(M);
            return;
        }
        if(M != none)
        {
            NPLocation.X = INVInventory.DataObject.MissionObjectSuccess[0];
            NPLocation.Y = INVInventory.DataObject.MissionObjectSuccess[1];
            NPLocation.Z = INVInventory.DataObject.MissionObjectSuccess[2];
            for(C=INVInventory.Level.ControllerList;C!=none;C=C.NextController)
            {
                if(C.class == default.MonsterEscortController
                && EscortController(C).Master == M && C.Pawn != none)
                {
                    bMonsterAlive = true;
                    if(VSize(C.Pawn.Location - NPLocation) < 256)
                        EndMission(M);
                    return;
                }
            }
            if(!bMonsterAlive)
                EndMission(M);
        }
    }
}

static function EndMission(Controller Other)
{
    local INVInventory INVInventory;
    local Controller C;
    local EscortSM SMA;
    local vector StartVec, EndVec;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory != none && INVInventory.DataObject != none && Other.PlayerReplicationInfo != none)
    {
        if(PlayerController(Other) != none)
            PlayerController(Other).ClientMessage(class'GameInfo'.static.MakeColorCode(class'mutInventorySystem'.default.RedColor)$default.MissionEndedString);
        if(CheckMissionComplete(Other))
        {
            if(PlayerController(Other) != none)
                PlayerController(Other).ClientPlaySound(default.MissionCompletedSound,true,2);
            StartVec.X = INVInventory.DataObject.MissionObjectSuccess[3];
            StartVec.Y = INVInventory.DataObject.MissionObjectSuccess[4];
            StartVec.Z = INVInventory.DataObject.MissionObjectSuccess[5];
            EndVec.X = INVInventory.DataObject.MissionObjectSuccess[0];
            EndVec.Y = INVInventory.DataObject.MissionObjectSuccess[1];
            EndVec.Z = INVInventory.DataObject.MissionObjectSuccess[2];
            if(default.AwardedCredits > 0)
                INVInventory.DataObject.Credits += default.AwardedCredits*(VSize(StartVec-EndVec)/default.DistanceToGetReward);
            if(default.CombatXPRewarded > 0)
            {
                INVInventory.DataObject.CombatXP += default.CombatXPRewarded*(VSize(StartVec-EndVec)/default.DistanceToGetReward);
                class'mutInventorySystem'.static.CheckLevelUp(INVInventory);
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
            INVInventory.DataObject.CreateDataStruct(INVInventory.DataRep, false);
            INVInventory.ClientInventoryUpdateGUI();
            INVInventory.ClientMissionInfoUpdate();
            PickDestination(Other);
            return;
        }
        else if(PlayerController(Other) != none)
            PlayerController(Other).ClientPlaySound(default.MissionFailedSound,true,2);
        INVInventory.DataObject.MissionObjectSuccess.Remove(0, INVInventory.DataObject.MissionObjectSuccess.Length);
        INVInventory.DataObject.CurrentMissionTimeLapsed = 0;
        INVInventory.DataObject.CurrentMission = none;
        INVInventory.DataObject.CreateDataStruct(INVInventory.DataRep, false);
        INVInventory.ClientInventoryUpdateGUI();
        INVInventory.ClientMissionInfoUpdate();
        foreach INVInventory.DynamicActors(class'EscortSM', SMA)
        {
            if(SMA.Owner == Other)
            {
                SMA.Destroy();
                break;
            }
        }
        for(C=INVInventory.Level.ControllerList;C!=none;C=C.NextController)
        {
            if(C.class == default.MonsterEscortController
            && EscortController(C).Master == Other)
            {
                C.Pawn.Destroy();
                break;
            }
        }
        if(default.TimeLimit > 0)
            INVInventory.SetTimer(0,false);
    }
}

static simulated function array<string> GetHUDMissionText(INVInventory INVInventory)
{
    local array<string> TrackerArray;

    if(INVInventory == none)
    {
        TrackerArray[TrackerArray.length] = default.NoInfoString;
        return TrackerArray;
    }

    TrackerArray[TrackerArray.length] = "Escort the monster spawned, alive to the objective";
    if(TrackerArray.length == 0)
        TrackerArray[TrackerArray.length] = default.NoInfoString;
    return TrackerArray;
}

defaultproperties
{
     ObjColor=(G=255,R=255,A=128)
     DistanceToGetReward=5000
     MonsterToSpawn=Class'sonicRPG45.EscortNaliCow'
     MonsterEscortController=Class'sonicRPG45.EscortController'
     myStaticMesh=StaticMesh'VMStructures.CoreGroup.CoreShieldSM'
     bOnlyAnnounceToSelf=True
     bCanReplayMission=True
     MissionPointsNeeded=10
     TimeLimit=1
     CombatXPRewarded=20
     MissionName="Escort 1"
     MissionDifficulty="Varies"
     MissionBrief="For this mission you must escort a monster to a certain place on a map, you will get different rewards depending on how far it is away."
}
