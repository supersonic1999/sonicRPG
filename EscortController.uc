class EscortController extends FriendlyMonsterController;

var protected bool bMasterSet;

function SetMaster(Controller NewMaster)
{
    if(!bMasterSet)
    {
        Master = NewMaster;
        bMasterSet = true;
    }
    if(NewMaster != none && PlayerReplicationInfo == none)
	{
        PlayerReplicationInfo = spawn(class'PlayerReplicationInfo', self);
		PlayerReplicationInfo.PlayerName = NewMaster.PlayerReplicationInfo.PlayerName$"'s Escort";
		PlayerReplicationInfo.bIsSpectator = true;
		PlayerReplicationInfo.bBot = true;
		PlayerReplicationInfo.Team = NewMaster.PlayerReplicationInfo.Team;
		Pawn.PlayerReplicationInfo = PlayerReplicationInfo;
        if(Pawn.default.bNetNotify)
            PlayerReplicationInfo.RemoteRole = ROLE_None;
	}
}

function Tick(float DeltaTime)
{
    if(bMasterSet && (Master == none || Master.PlayerReplicationInfo == none || Master.PlayerReplicationInfo.bOnlySpectator
	|| (PlayerReplicationInfo != none && PlayerReplicationInfo.Team != Master.PlayerReplicationInfo.Team)))
        Pawn.Destroy();
    LastSeenTime = Level.TimeSeconds;
    super.Tick(DeltaTime);
}

function bool FindNewEnemy()
{
	return false;
}

function bool SetEnemy(Pawn NewEnemy, optional bool bThisIsNeverUsed)
{
	return false;
}

function ChangeEnemy(Pawn NewEnemy, bool bCanSeeNewEnemy);

function ExecuteWhatToDoNext()
{
	if(Master != none && Pawn != none)
	{
        if(Master.Pawn != none && VSize(Master.Pawn.Location - Pawn.Location) <= 2000)
        {
            GoalString = "Follow Master "$Master.PlayerReplicationInfo.PlayerName;
        	if(FindBestPathToward(Master.Pawn, false, Pawn.bCanPickupInventory))
        	{
        		if(Enemy != none)
        			GotoState('Fallback');
        		else
        			GotoState('Roaming');
       			return;
        	}
    	}
	}
	GoalString = "Wander or Camp at "$Level.TimeSeconds;
	WanderOrCamp(true);
}

defaultproperties
{
}
