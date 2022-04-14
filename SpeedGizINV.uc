class SpeedGizINV extends GizmoINV;

var float SpeedMultiplier;
var protected float SavedSpeed;

function EnableGiz()
{
    ChangeGroundSpeed(False);
    super.EnableGiz();
}

function DisableGiz()
{
    ChangeGroundSpeed(true);
    super.DisableGiz();
}

function ChangeGroundSpeed(bool bReset)
{
    if(!bReset)
    {
        SavedSpeed = Instigator.GroundSpeed;
        Instigator.GroundSpeed *= SpeedMultiplier;
    }
    else
        Instigator.GroundSpeed = SavedSpeed;
}

defaultproperties
{
     SpeedMultiplier=1.500000
}
