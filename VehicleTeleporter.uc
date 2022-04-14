class VehicleTeleporter extends MainInventoryItem;

static function bool ServerLeftClick(Controller Other, int x)
{
    local Vehicle V;

    if(Other == none || Other.Pawn == none || !bAllowUse(Other))
        return false;

    for(V=Other.Level.Game.VehicleList;V!=none;V=V.NextVehicle)
    {
        if(V.Inventory != none && VehicleTracker(V.Inventory) != none
        && VehicleTracker(V.Inventory).GetPlayerOwner() == Other
        && super.ServerLeftClick(Other, x))
        {
            if(V.Driver != none)
                V.EjectDriver();
            V.KDriverEnter(Other.Pawn);
            break;
        }
    }
    return false;
}

defaultproperties
{
     Image=Texture'SonicRPGTEX46.Inventory.SCORPION'
     Description="This item will teleport you to your vehicle, if you have one."
     ItemName="Vehicle Teleporter"
     BuyPrice=-50
     SellPrice=20
}
