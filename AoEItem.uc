class AoEItem extends MainInventoryItem;

var localized string TooManyAoEItemsAlready, SpawnedTooManyAoEItemsAlready;
var float ItemLastTime, CollisionHeight, CollisionRadius;
var byte ItemTypeNum;
var int ActorTimerTime, MaxAoEItems, MaxAoEPerPlayer, RegenAmount;
var class<AoELocINV> ItemActorClass;

static simulated function bool bAllowUse(Controller Other, optional bool bImageRender)
{
    local AoELocINV AActor;
    local int i, x;

    if(Other != none)
    {
        foreach Other.DynamicActors(class'AoELocINV', AActor)
        {
            if(AActor.StaticActorOwner != none
            && AActor.StaticActorOwner.default.ItemTypeNum == default.ItemTypeNum)
            {
                if(AActor.Owner == Other)
                    x++;
                i++;
                if(i >= default.MaxAoEItems)
                {
                    if(PlayerController(Other) != none && !bImageRender)
                        PlayerController(Other).ClientMessage(default.TooManyAoEItemsAlready);
                    return false;
                }
                else if(x >= default.MaxAoEPerPlayer && !bImageRender)
                {
                    if(PlayerController(Other) != none)
                        PlayerController(Other).ClientMessage(default.SpawnedTooManyAoEItemsAlready);
                    return false;
                }
            }
        }
    }
    return super.bAllowUse(Other, bImageRender);
}

static function bool ServerLeftClick(Controller Other, int x)
{
    local AoELocINV Item;

    if(Other != none && Other.Pawn != none
    && super.ServerLeftClick(Other, x))
    {
        Item = Other.Spawn(default.ItemActorClass, Other,, Other.Pawn.Location);
        Item.LifeSpan = default.ItemLastTime;
        Item.StaticActorOwner = default.class;
        Item.SetTimer(default.ActorTimerTime,true);
        return true;
    }
    return false;
}

static function ServerActorTimer(AoELocINV AActor);

static simulated function string GetItemInformation(Controller Other)
{
    return (super.GetItemInformation(Other) $ "|" $ "Regen Per Sec:" @ default.RegenAmount);
}

defaultproperties
{
     TooManyAoEItemsAlready="There are too many of this type of AoE item in the level already."
     SpawnedTooManyAoEItemsAlready="You have already made the maximum you can of this item."
     ItemLastTime=60.000000
     CollisionHeight=64.000000
     CollisionRadius=300.000000
     ActorTimerTime=1
     MaxAoEItems=10
     MaxAoEPerPlayer=2
     RegenAmount=1
     Image=Texture'SonicRPGTEX46.Inventory.AoEHealS'
     Description="This item will do something like heal in an area for a certain amount of time."
     ItemName="AoE Item"
     BuyPrice=-10
     SellPrice=5
     ShopAmount=1000
}
