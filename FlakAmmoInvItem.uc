class FlakAmmoInvItem extends MainInventoryItem;

var int AmmoPlus;
var class<Weapon> WeaponInv;

static function bool ServerLeftClick(Controller Other, int x)
{
	local Inventory WInv, i;

    if(Other != none && Other.Pawn != none)
        WInv = Other.Pawn.FindInventoryType(default.WeaponInv);
    if(Other != none && WInv == None)
    {
	    for(i=Other.Inventory; i!=None; i=i.Inventory)
	    {
            if(Weapon(i) != none
            && Weapon(i).InventoryGroup == default.WeaponInv.default.InventoryGroup
            && Weapon(i).IconCoords == default.WeaponInv.default.IconCoords)
            {
                WInv = i;
                break;
            }
        }
    }

    if(WInv != none && super.ServerLeftClick(Other, x)
    && Weapon(WInv).AddAmmo(default.AmmoPlus, 0))
        return true;
    return false;
}

static simulated function string GetItemInformation(Controller Other)
{
    return (super.GetItemInformation(Other) @ "|" $ "Ammo Increase:" @ default.AmmoPlus);
}

defaultproperties
{
     AmmoPlus=15
     WeaponInv=Class'XWeapons.FlakCannon'
     Image=Texture'SonicRPGTEX46.Inventory.FlakAmmo'
     Description="This is a standard ammo pack for the Unreal Tournament 2004 series guns.||Use of this ammo pack will result in an increase of ammo for the gun that it is for but it will not increase the guns ammo above its max.||Each one can only be used once before being depleted of its energy source or ammunition.||This item was once the item to have for the soldier of tomorrow but now has been surpassed by Toilet Duck(R) Mobile Sanitation Unit (MSU) for pure hygiene and a freshness for the soldier of today on the move."
     ItemName="Flak Cannon Ammo"
     BuyPrice=-50
     SellPrice=20
     ShopAmount=25
     ItemRestockTime=30
}
