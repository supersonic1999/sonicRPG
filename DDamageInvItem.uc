class DDamageInvItem extends MainInventoryItem;

var protected int DDTime;

static function bool ServerLeftClick(Controller Other, int x)
{
    if(Other.Pawn != none
    && Other.Pawn.LightType == LT_None
    && !Other.Pawn.bDynamicLight
    && super.ServerLeftClick(Other, x))
    {
        Other.Pawn.EnableUDamage(default.DDTime);
        return true;
    }
    return false;
}

static simulated function string GetItemInformation(Controller Other)
{
    return (super.GetItemInformation(Other) @ "|" $ "DD Time:" @ default.DDTime);
}

defaultproperties
{
     DDTime=60
     Image=Texture'SonicRPGTEX46.Inventory.DDamage'
     Description="This is a Double Damage, it does literally what it says on the box, it doubles your damage."
     ItemName="Double Damage"
     BuyPrice=-250
     SellPrice=100
     ShopAmount=5
}
