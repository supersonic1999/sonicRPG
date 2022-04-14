class VehicleTracker extends Inventory;

var protected Controller PlayerOwner;
var protected bool bSetPlayerOwner;

simulated function PreBeginPlay()
{
    Disable('Tick');
}

function Controller GetPlayerOwner()
{
    return PlayerOwner;
}

function Tick(float DeltaTime)
{
    if(bSetPlayerOwner)
    {
        if(PlayerOwner == none && Owner != none)
        {
            Owner.Destroy();
            Destroy();
            Disable('Tick');
            return;
        }
        if(Owner == none)
        {
            Destroy();
            Disable('Tick');
        }
    }
    super.Tick(DeltaTime);
}

function SetPlayerOwner(Controller C)
{
    if(!bSetPlayerOwner)
    {
        bSetPlayerOwner = true;
        PlayerOwner = C;
        Enable('Tick');
    }
}

defaultproperties
{
}
