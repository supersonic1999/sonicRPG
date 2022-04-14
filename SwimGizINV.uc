class SwimGizINV extends GizmoINV;

var float SwimMultiplier;
var protected float SavedSpeed;

function EnableGiz()
{
    ChangeWaterSpeed(False);
    super.EnableGiz();
}

function DisableGiz()
{
    ChangeWaterSpeed(True);
    super.DisableGiz();
}

function ChangeWaterSpeed(bool bReset)
{
    if(!bReset)
    {
        SavedSpeed = Instigator.WaterSpeed;
        Instigator.WaterSpeed *= SwimMultiplier;
    }
    else
        Instigator.WaterSpeed = SavedSpeed;
}

defaultproperties
{
     SwimMultiplier=2.000000
}
