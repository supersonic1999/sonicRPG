class VehicleSummonItem extends MainInventoryItem;

var protected string VehicleClass, VehicleName;

static function OwnerDied(Controller Killer, Controller Killed)
{
    local Vehicle V;

    if(Killed != none && Killed.Level.Game != none)
    {
        for(V=Killed.Level.Game.VehicleList;V!=none;V=V.NextVehicle)
        {
            if(V.Inventory != none && VehicleTracker(V.Inventory) != none
            && VehicleTracker(V.Inventory).GetPlayerOwner() == Killed)
            {
                if(V.Driver != none)
                    V.EjectDriver();
                V.Destroy();
                break;
            }
        }
    }
}

static simulated function string GetItemInformation(Controller Other)
{
    local string Text;

    Text = super.GetItemInformation(Other);
    if(default.VehicleName != "")
        Text = (Text @ "|" $ "Vehicle:" @ default.VehicleName);
    return Text;
}

static simulated function bool bEnabled(Controller Other)
{
    local Vehicle V;

    if(Other == none || Other.Pawn == none
    || xPawn(Other.Pawn) == none || Other.Level.Game == none
    || super.bEnabled(Other))
        return true;

    for(V=Other.Level.Game.VehicleList;V!=none;V=V.NextVehicle)
        if(V.Inventory != none && VehicleTracker(V.Inventory) != none
        && VehicleTracker(V.Inventory).GetPlayerOwner() == Other)
            return true;
    return false;
}

static function bool ServerLeftClick(Controller Other, int x)
{
    local Vehicle V;
    local VehicleTracker VT;
    local INVInventory INVInventory;
    local int i;
    local bool bAlreadyUsed;
    local class<Vehicle> VClass;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory == none || INVInventory.DataObject == none)
        return false;

    if(!bEnabled(Other) && bAllowUse(Other))
    {
        VClass = class<Vehicle>(DynamicLoadObject(default.VehicleClass, class'Class', true));
        if(VClass == none)
            return false;

        V = Other.Spawn(VClass, Other,, Other.Pawn.Location, Other.Pawn.Rotation);
        if(V != none)
        {
            V.KDriverEnter(Other.Pawn);
            VT = Other.Spawn(class'VehicleTracker', V,, V.Location);
            VT.SetBase(V);
            VT.SetPlayerOwner(Other);
            VT.Inventory = V.Inventory;
            V.Inventory = VT;
        }
        for(i=0;i<INVInventory.ItemDelay.length;i++)
        {
            if(INVInventory.ItemDelay[i].LastItemClass == default.class)
            {
                INVInventory.ItemDelay[i].LastUsed = INVInventory.Level.TimeSeconds;
                bAlreadyUsed = true;
                break;
            }
        }
        if(!bAlreadyUsed)
        {
            INVInventory.ItemDelay.Insert(INVInventory.ItemDelay.length, 1);
            INVInventory.ItemDelay[INVInventory.ItemDelay.length-1].LastItemClass = default.class;
            INVInventory.ItemDelay[INVInventory.ItemDelay.length-1].LastUsed = INVInventory.Level.TimeSeconds;
        }
    }
    else OwnerDied(none, Other);
    return true;
}

defaultproperties
{
     VehicleClass="Engine.Vehicle"
     VehicleName="Vehicle"
     Image=Texture'SonicRPGTEX46.Inventory.SCORPION'
     Description="This item will spawn a vehicle for your personal use when you use this item. This is a permanent item."
     ItemName="Vehicle Item"
     RequiredSkillNum=7
     BuyPrice=-1000000
     SellPrice=500000
     ShopAmount=1
     ItemRestockTime=86400
     ItemRemoveTime=600
     ItemUseDelay=120.000000
     bNotifyCantUseYet=True
}
