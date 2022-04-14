class GizmoINV extends Inventory;

var bool bEnabled;

replication
{
	reliable if(bNetDirty && Role==ROLE_Authority)
		bEnabled;
}

simulated function PostBeginPlay()
{
    Disable('Tick');
}

function EnableGiz()
{
    bEnabled = true;
}

function DisableGiz()
{
    bEnabled = false;
}

function Destroyed()
{
    DisableGiz();
    super.Destroyed();
}

defaultproperties
{
     bAlwaysRelevant=True
     bReplicateInstigator=True
}
