class AdrenalineInvItem extends MainInventoryItem;

var protected int AdrenalinePlus;

static function bool ServerLeftClick(Controller Other, int x)
{
    if(Other.Adrenaline < Other.AdrenalineMax && super.ServerLeftClick(Other, x))
    {
        Other.AwardAdrenaline(default.AdrenalinePlus);
        return true;
    }
    return false;
}

static simulated function string GetDescription(Controller Other)
{
    return (default.Description @ "||This pill will increase your adrenaline by" @ default.AdrenalinePlus
         @ "if you have" @ default.RequiredSkillLevel @ "in Adrenaline Knowledge.");
}

static simulated function string GetItemInformation(Controller Other)
{
    return (super.GetItemInformation(Other) @ "|" $ "Adrenal Increase:" @ default.AdrenalinePlus);
}

defaultproperties
{
     AdrenalinePlus=1
     Image=Texture'SonicRPGTEX46.Inventory.Adrenaline1'
     Description="This is the an Adrenaline pill it is used to increase your adrenaline by a certain amount. It will not increase your adrenaline above your max."
     ItemName="Adrenaline x1"
     RequiredSkillLevel=200
     RequiredSkillNum=4
     BuyPrice=-4
     SellPrice=2
     ShopAmount=200
     ItemRestockTime=30
     ItemUseDelay=0.500000
}
