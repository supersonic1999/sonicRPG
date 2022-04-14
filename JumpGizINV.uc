class JumpGizINV extends GizmoINV;

var float JumpMultiplier;
var protected float SavedSpeed;

function EnableGiz()
{
    ChangeJumpZ(False);
    super.EnableGiz();
}

function DisableGiz()
{
    ChangeJumpZ(True);
    super.DisableGiz();
}

function ChangeJumpZ(bool bReset)
{
    if(!bReset)
    {
        SavedSpeed = Instigator.JumpZ;
        Instigator.JumpZ *= JumpMultiplier;
    }
    else
        Instigator.JumpZ = SavedSpeed;
}

defaultproperties
{
     JumpMultiplier=2.000000
}
