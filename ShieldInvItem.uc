class ShieldInvItem extends MainInventoryItem;

var int ShieldPlus;

static function bool ServerLeftClick(Controller Other, int x)
{
    if(Other != none && Other.Pawn != none
    && Other.Pawn.CanUseShield(default.ShieldPlus) > 0
    && super.ServerLeftClick(Other, x)
    && Other.Pawn.AddShieldStrength(default.ShieldPlus))
        return true;
    return false;
}

static simulated function string GetDescription(Controller Other)
{
    return (default.Description @ "||This shield pack will increase your shield by" @ default.ShieldPlus);
}

static simulated function string GetItemInformation(Controller Other)
{
    return (super.GetItemInformation(Other) @ "|" $ "Shield Increase:" @ default.ShieldPlus);
}

defaultproperties
{
     ShieldPlus=50
     Image=Texture'SonicRPGTEX46.Inventory.ShieldPack'
     Description="This is a shield pack it is used to increase your shield. It will not increase your shield above your max."
     ItemName="Shield Pack"
     BuyPrice=-30
     SellPrice=12
     ShopAmount=20
     ItemRestockTime=120
}
