class SpeedGizmoInvItem extends GizmoInvItem;

static simulated function string GetDescription(Controller Other)
{
    if(default.GizmoINV != none && class<SpeedGizINV>(default.GizmoINV) != none)
    {
        return (default.Description @ "||This gizmo will multiply your running speed by"
              @ class<SpeedGizINV>(default.GizmoINV).default.SpeedMultiplier
              @ "making you able to out ran almost anyone when you have this active.");
    }
    return default.Description;
}

defaultproperties
{
     GizmoINV=Class'sonicRPG45.SpeedGizINV'
     ItemName="Speed Gizmo"
}
