class JumpGizmoInvItem extends GizmoInvItem;

static simulated function string GetDescription(Controller Other)
{
    if(default.GizmoINV != none && class<JumpGizINV>(default.GizmoINV) != none)
    {
        return (default.Description @ "||This gizmo increases your jump height be a factor of"
              @ class<JumpGizINV>(default.GizmoINV).default.JumpMultiplier) $ ".";
    }
    return default.Description;
}

defaultproperties
{
     GizmoINV=Class'sonicRPG45.JumpGizINV'
     ItemName="Jump Gizmo"
}
