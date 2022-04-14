class MiniHealthInvItem extends MainInventoryItem;

var protected int HealthPlus;

static function bool ServerLeftClick(Controller Other, int x)
{
    if(Other.Pawn != none && Other.Pawn.Health < Other.Pawn.HealthMax && super.ServerLeftClick(Other, x)
    && Other.Pawn.GiveHealth(default.HealthPlus, Other.Pawn.HealthMax))
        return true;
    return false;
}

static simulated function string GetDescription(Controller Other)
{
    return (super.GetDescription(Other) @ "||This pack will increase your health by" @ default.HealthPlus
         @ "if you have" @ default.RequiredSkillLevel @ "in Healing Knowledge.");
}

static simulated function string GetItemInformation(Controller Other)
{
    return (super.GetItemInformation(Other) @ "|" $ "Health Increase:" @ default.HealthPlus);
}

defaultproperties
{
     HealthPlus=5
     Image=Texture'SonicRPGTEX46.Inventory.HealthPack'
     Description="This is a health pack, it is used to heal your self. It will not increase your health above your max."
     ItemName="Mini Health Pack"
     RequiredSkillLevel=200
     RequiredSkillNum=3
     BuyPrice=-4
     SellPrice=2
     ShopAmount=200
     ItemRestockTime=30
     ItemUseDelay=0.500000
}
