class Metamorphosis extends MainInventoryItem;

var protected class<INVMonster> PawnClass;
var protected int StayChangedTime;
var string MonsterName;

static simulated function string GetDescription(Controller Other)
{
    return (default.Description @ "||This item will turn you into a" @ default.MonsterName @ "for" @ default.StayChangedTime
         @ "seconds, if you have atleast" @ default.RequiredSkillLevel @ "in Metamorphosis.");
}

static function bool ServerLeftClick(Controller Other, int x)
{
    local MetaInventory MetaInventory;
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory != none && INVInventory.DataObject != none
    && Other.Pawn != none && bAllowUse(Other))
    {
        MetaInventory = MetaInventory(Other.Pawn.FindInventoryType(class'MetaInventory'));
    	if(MetaInventory == none)
    	{
            MetaInventory = Other.Spawn(class'MetaInventory', Other,,, rot(0,0,0));
            MetaInventory.GiveTo(Other.Pawn);
        }
        if(MetaInventory.ChangeMonster(default.PawnClass, default.StayChangedTime))
             return super.ServerLeftClick(Other, x);
    }
    else if(Other != none && PlayerController(Other) != none)
        PlayerController(Other).ClientMessage("Your metamorphosis skill level isnt high enough to use this item."
                                            @ "It need to be atleast level" @ default.RequiredSkillLevel $ ".");
    return false;
}

defaultproperties
{
     PawnClass=Class'sonicRPG45.INVMonster'
     StayChangedTime=600
     MonsterName="Monster"
     Image=Texture'SonicRPGTEX46.Inventory.Pupae'
     Description="This item will transform you into a monster for a certain amount of time. You will have the abilities of the monster that you are transformed into like the speed, jump height and weapons, you wont be able to use the regular weapons like flak cannon but you will be granted a translocator and a trader, if trade is enabled."
     ItemName="Metamorphosis Item"
     RequiredSkillLevel=1
     RequiredSkillNum=2
     BuyPrice=-1000
     SellPrice=500
     ShopAmount=3
     ItemRestockTime=5
}
