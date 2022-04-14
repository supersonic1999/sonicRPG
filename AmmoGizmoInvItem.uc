class AmmoGizmoInvItem extends GizmoInvItem;

var bool bAutoBuy;

static simulated function string GetDescription(Controller Other)
{
    if(default.GizmoINV != none && class<SpeedGizINV>(default.GizmoINV) != none)
        return (default.Description @ "||This gizmo will automatically restock your ammo for the gun you are holding if you have the ammo for it in your inventory");
    return default.Description;
}

static simulated function array<string> GetImageContextArray(Controller Other, class<MainInventoryItem> Item)
{
    local array<string> ContextItems;

    if(Item == none)
        return ContextItems;

    ContextItems = super.GetImageContextArray(Other, Item);
    if(default.bAutoBuy)
        ContextItems[ContextItems.length] = "Auto Buy Ammo: Yes";
    else
        ContextItems[ContextItems.length] = "Auto Buy Ammo: No";
    return ContextItems;
}

static simulated function ImageContextClick(Controller Other, class<MainInventoryItem> Item, string ContextString)
{
    if(default.bAutoBuy && ContextString == "Auto Buy Ammo: Yes")
    {

    }
    super.ImageContextClick(Other, Item, ContextString);
}

defaultproperties
{
     GizmoINV=Class'sonicRPG45.AmmoGizINV'
     ItemName="Ammo Restock Gizmo"
     BuyPrice=-200000
     SellPrice=60000
}
