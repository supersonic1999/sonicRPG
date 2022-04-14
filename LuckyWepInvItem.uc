class LuckyWepInvItem extends MainInventoryItem;

var protected class<RPGWeapon> MagicWeapon;
var protected config bool bAllowNegative;
var protected localized string BadWeaponMessage;

static function bool ServerLeftClick(Controller Other, int x)
{
    local Weapon Copy, ActiveWeapon, ActiveWeaponBase;
    local Mutator RPGMut, OtherMut;
    local Inventory Inv;
    local INVInventory INVInventory;
    local RPGStatsInv StatsInv;
    local class<RPGWeapon> WeaponClass;
    local int i, o;

    if(Other != none && Other.Pawn != none)
        INVInventory = INVInventory(Other.Pawn.FindInventoryType(class'INVInventory'));
    if(Other != none && INVInventory == none)
    {
    	for(Inv = Other.Inventory; Inv != None; Inv = Inv.Inventory)
    	{
    		INVInventory = INVInventory(Inv);
    		if(INVInventory != None)
    			break;
    	}
	}

    //WeaponClass = class<RPGWeapon>(DynamicLoadObject("DruidsRPG200.RW_NullEntropy", class'Class'));
    WeaponClass = default.MagicWeapon;
    if(INVInventory != none && WeaponClass != none
    && Other != none && Other.Pawn != none && Other.Pawn.Weapon != none
    && Other.Level != none && Other.Level.Game != none)
    {
        ActiveWeapon = Other.Pawn.Weapon;
        ActiveWeaponBase = Other.Pawn.Weapon;

        if(ActiveWeapon.IsA('RPGWeapon'))
    	{
    		if(RPGWeapon(ActiveWeapon).ModifiedWeapon != None)
    			ActiveWeapon = RPGWeapon(ActiveWeapon).ModifiedWeapon;
    		else
    		    return false;
    	}

        if(ActiveWeapon != none
        && (ActiveWeapon.AmmoCharge[0] <= 0
        || !WeaponClass.static.AllowedFor(ActiveWeapon.class, Other.Pawn)))
        {
            Other.Pawn.ClientMessage(default.BadWeaponMessage);
            return false;
        }

        if(Other.Level.Game.BaseMutator != none)
        {
            for(OtherMut=Other.Level.Game.BaseMutator;OtherMut!=none;OtherMut=OtherMut.NextMutator)
            {
                if(OtherMut.IsA('MutUT2004RPG'))
                {
                    RPGMut = OtherMut;
                    break;
                }
            }
        }
        if(RPGMut == None)
            return false;

    	if(ActiveWeapon != none && ActiveWeaponBase != none
        && super.ServerLeftClick(Other, x))
    	{
            for(Inv=Other.Pawn.Inventory;Inv!=none;Inv=Inv.Inventory)
            {
                if(Inv.IsA('RPGStatsInv'))
                {
                    StatsInv = RPGStatsInv(Inv);
                    break;
                }
            }
    		if (StatsInv != None)
    		{
    			for(i=0; i<StatsInv.OldRPGWeapons.length; i++)
    			{
    				if(ActiveWeaponBase == StatsInv.OldRPGWeapons[i].Weapon)
    				{
    					StatsInv.OldRPGWeapons.Remove(i, 1);
    					break;
    				}
    			}
    		}

            Copy = Other.spawn(WeaponClass, Other,,, rot(0,0,0));
            RPGWeapon(Copy).Generate(None);

            if(!default.bAllowNegative)
            {
                for(o=0; o<50; o++)
        		{
        			RPGWeapon(Copy).Generate(None);
        			if(RPGWeapon(Copy).Modifier > -1)
        				break;
        		}
    		}

            RPGWeapon(Copy).SetModifiedWeapon(Other.spawn(ActiveWeapon.class, Other,,, rot(0,0,0)), true);
            ActiveWeaponBase.Destroy();
        	Copy.GiveTo(Other.Pawn);
            return true;
        }
    }
    return false;
}

defaultproperties
{
     MagicWeapon=Class'DruidsRPG200.RW_EnhancedLuck'
     BadWeaponMessage="You cannot use this item on the weapon you are holding!"
     Image=Texture'SonicRPGTEX46.Inventory.Lucky'
     Description="This is a weapon maker, for any Unreal Tournameny 2004 Weapon.||It will transform the weapon you are holding into a special weapon with special stats.||It does allow negative weapons and with some weapon types it will transform into a opposite of what it should do, usually in a bad way."
     ItemName="Lucky Weapon Maker"
     BuyPrice=-200
     SellPrice=50
     ShopAmount=25
     ItemRestockTime=300
}
