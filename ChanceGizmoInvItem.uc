class ChanceGizmoInvItem extends GizmoInvItem;

static simulated function string GetDescription(Controller Other)
{
    if(default.GizmoINV != none && class<GhostGizINV>(default.GizmoINV) != none)
        return (default.Description @ "||This gizmo increases the chance of getting an item from a monster by 25% when enabled.");
    return default.Description;
}

defaultproperties
{
     GizmoINV=Class'sonicRPG45.ChanceGizINV'
     ItemName="Chance Gizmo"
}
