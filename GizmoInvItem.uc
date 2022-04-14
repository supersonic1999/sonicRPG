class GizmoInvItem extends MainInventoryItem;

var class<GizmoINV> GizmoINV;

static function ActivateMessage(Controller Other, int i)
{
    local Inventory Inv;

    if(Other == none || Other.Pawn == none)
        return;

	Inv = FindClassINV(Other);
    if(GizmoINV(Inv) != none)
    {
        if(bEnabled(Other))
            Other.Pawn.ClientMessage(GetInvItemName(Other) @ "deactivated");
        else
            Other.Pawn.ClientMessage(GetInvItemName(Other) @ "activated");
    }
}

static simulated function CantUseMessage(Controller Other, int i);

static simulated function bool bEnabled(Controller Other)
{
	local Inventory Inv;

    if(Other == none || Other.Pawn == none)
        return false;

    Inv = FindClassINV(Other);
    if(Inv != none && GizmoINV(Inv).bEnabled)
	    return True;
    return false;
}

static function Inventory FindClassINV(Controller Other)
{
    local Inventory Inv, myinv;

    if(default.GizmoINV == none || Other == none)
        return none;

    if(Other.Pawn != none)
        Inv = Other.Pawn.FindInventoryType(default.GizmoINV);
    if(Inv == none)
    {
        for(myinv = Other.Inventory; myinv != None; myinv = myinv.Inventory)
        {
            if(myinv.class == default.GizmoINV)
    		{
    		    Inv = myinv;
		        break;
		    }
        }
    }
    return Inv;
}

static function bool ServerLeftClick(Controller Other, int x)
{
    local Inventory Inv, myinv;

    if(Other == none || Other.Pawn == none)
        return false;

    if(bAllowUse(Other))
    {
        Inv = FindClassINV(Other);
        for(myinv = Other.Inventory; myinv != None; myinv = myinv.Inventory)
        {
    		if(GizmoINV(myinv) != none && myinv.class != default.GizmoINV && GizmoINV(myinv).bEnabled)
    		{
    			//GizmoINV(myinv).ActivateMessage(Other, x);
                GizmoINV(myinv).DisableGiz();
   			}
        }

        if(Inv != none)
        {
            Inv.Instigator = Other.Pawn;
            ActivateMessage(Other, x);
            if(bEnabled(Other))
                GizmoINV(Inv).DisableGiz();
            else
                GizmoINV(Inv).EnableGiz();
        }
        else
        {
            Inv = Other.Spawn(default.GizmoINV, Other);
            Inv.Instigator = Other.Pawn;
			Inv.Inventory = Other.Inventory;
            Other.Inventory = Inv;
            ActivateMessage(Other, x);
            GizmoINV(Inv).EnableGiz();
        }
    }
    else
        CantUseMessage(Other, x);
    return True;
}

static function DeletedItem(Controller Other)
{
    local Inventory Inv;

    if(Other == none || Other.Pawn == none)
        return;

    Inv = FindClassINV(Other);
    if(Inv != none && bEnabled(Other))
        GizmoINV(Inv).DisableGiz();
}

static function ModifyPlayer(Controller Other)
{
    local Inventory Inv;

    if(Other == none || Other.Pawn == none)
        return;

    Inv = FindClassINV(Other);
    if(Inv != none && bEnabled(Other))
    {
        Inv.Instigator = Other.Pawn;
        GizmoINV(Inv).EnableGiz();
    }
}

defaultproperties
{
     GizmoINV=Class'sonicRPG45.GizmoINV'
     Image=Texture'SonicRPGTEX46.Inventory.Gizmo'
     Description="Gizmos are items that you can turn on and off, similar to artifacts but are more advanced. You can only have 1 gizmo on at the same time because more then one would make you almost invulnerable. Most gizmos never run out."
     ItemName="Gizmo"
     BuyPrice=-1000000
     SellPrice=350000
     ShopAmount=1
     ItemRestockTime=86400
}
