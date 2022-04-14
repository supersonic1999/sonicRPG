class SwimGizmoInvItem extends GizmoInvItem;

static simulated function string GetDescription(Controller Other)
{
    if(default.GizmoINV != none && class<SwimGizINV>(default.GizmoINV) != none)
    {
        return (default.Description @ "||This gizmo increases your swimming speed by"
              @ class<SwimGizINV>(default.GizmoINV).default.SwimMultiplier
              @ "times, making you easily out maneuvour your opposition in water.");
    }
    return default.Description;
}

defaultproperties
{
     GizmoINV=Class'sonicRPG45.SwimGizINV'
     ItemName="Swim Gizmo"
     BuyPrice=-500000
     SellPrice=165000
}
