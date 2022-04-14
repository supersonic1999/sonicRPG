class MetaReverseItem extends MainInventoryItem;

static function bool ServerLeftClick(Controller Other, int x)
{
    local MetaInventory MetaInventory;

    if(Other.Pawn != none && INVMonster(Other.Pawn) != none)
    {
        MetaInventory = MetaInventory(Other.Pawn.FindInventoryType(class'MetaInventory'));
    	if(MetaInventory == none)
    	{
            MetaInventory = Other.Spawn(class'MetaInventory', Other,,, rot(0,0,0));
            MetaInventory.GiveTo(Other.Pawn);
        }
        if(MetaInventory != none)
            MetaInventory.SetTimer(0.1,false);
        return super.ServerLeftClick(Other, x);
    }
    return false;
}

defaultproperties
{
     Image=Texture'SonicRPGTEX46.Inventory.Pupae'
     Description="If you are have been turned into a monster by using a metamorphosis item, using this will transform you back to a player so that you dont have to wait for the monster timer to run out."
     ItemName="Metamorphosis Reversion"
     BuyPrice=-100
     SellPrice=40
     ShopAmount=100
     ItemRestockTime=30
}
