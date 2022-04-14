class AmmoGizINV extends GizmoINV;

function EnableGiz()
{
    SetTimer(1,True);
    super.EnableGiz();
}

function DisableGiz()
{
    SetTimer(0.1,False);
    super.DisableGiz();
}

function Timer()
{
    local Weapon ActiveWeapon, ActiveWeaponBase;
    local INVInventory INVInventory;
    local class<FlakAmmoInvItem> Item;
    local int i;
    local bool bHasAmmo;

    super.Timer();

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Controller(Owner));
    if(INVInventory != none && INVInventory.DataObject != none && Owner != none
    && Controller(Owner).Pawn != none && Controller(Owner) != none && Controller(Owner).Pawn.Weapon != none)
    {
        ActiveWeapon = Controller(Owner).Pawn.Weapon;
        ActiveWeaponBase = Controller(Owner).Pawn.Weapon;

        if(RPGWeapon(ActiveWeapon) != None)
    	{
    		if(RPGWeapon(ActiveWeapon).ModifiedWeapon != None)
    			ActiveWeapon = RPGWeapon(ActiveWeapon).ModifiedWeapon;
    		else
    		    return;
    	}

        if(ActiveWeapon == none)
            return;

        for(i=0;i<INVInventory.DataObject.Items.Length;i++)
        {
            Item = class<FlakAmmoInvItem>(INVInventory.DataObject.Items[i]);
            if(Item != none && ActiveWeapon.class == Item.default.WeaponInv)
            {
                bHasAmmo = true;
                break;
            }
        }

        if(bHasAmmo && Item != none && ActiveWeapon.AmmoAmount(0)-Item.default.AmmoPlus <= 0)
            Item.static.ServerLeftClick(Controller(Owner), i);
    }
}

defaultproperties
{
}
