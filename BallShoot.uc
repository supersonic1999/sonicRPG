class BallShoot extends ProjectileFire;

var localized string HaveTrade, TraderHasTrade;

simulated function bool AllowFire()
{
    return true;
}

function ModeDoFire()
{
    local Inventory Inv;
    local INVInventory INVInventory, myINVInventory;

    Super.ModeDoFire();

    if(Pawn(Weapon.Owner) != none && BallLauncher(Weapon) != none && BallLauncher(Weapon).PassTarget != none)
    {
        INVInventory = INVInventory(BallLauncher(Weapon).PassTarget.FindInventoryType(class'INVInventory'));
        if(INVInventory == none && BallLauncher(Weapon).PassTarget.Controller != None)
        {
            for(Inv = BallLauncher(Weapon).PassTarget.Controller.Inventory; Inv != None; Inv = Inv.Inventory)
        	{
        		INVInventory = INVInventory(Inv);
        		if(INVInventory != None)
        			break;
        	}
        }

        if(INVInventory == none)
        {
            foreach Weapon.DynamicActors(class'INVInventory', INVInventory)
            {
                if(INVInventory.Owner == BallLauncher(Weapon).PassTarget || INVInventory.Instigator == BallLauncher(Weapon).PassTarget
                || INVInventory.Owner == BallLauncher(Weapon).PassTarget.Controller)
                    break;
                INVInventory = none;
            }
        }

        myINVInventory = INVInventory(Pawn(Weapon.Owner).FindInventoryType(class'INVInventory'));
        if(myINVInventory == none && Pawn(Weapon.Owner).Controller != None)
        {
            for(Inv = Pawn(Weapon.Owner).Controller.Inventory; Inv != None; Inv = Inv.Inventory)
        	{
        		myINVInventory = INVInventory(Inv);
        		if(myINVInventory != None)
        			break;
        	}
        }

        if(INVInventory != none && INVInventory.TradeReplicationInfo != none && INVInventory.TradeReplicationInfo.CurTrader != None)
            Pawn(BallLauncher(Weapon).Owner).ClientMessage(TraderHasTrade);
        else if(myINVInventory != none && myINVInventory.TradeReplicationInfo != none && myINVInventory.TradeReplicationInfo.CurTrader != None)
            Pawn(BallLauncher(Weapon).Owner).ClientMessage(HaveTrade);
        else if(INVInventory != none && myINVInventory != none
        && ((INVInventory.TradeReplicationInfo != none && INVInventory.TradeReplicationInfo.CurTrader == none
        && myINVInventory.TradeReplicationInfo != none && myINVInventory.TradeReplicationInfo.CurTrader == none)
        || INVInventory.TradeReplicationInfo == none
        || myINVInventory.TradeReplicationInfo == none))
        {
            Pawn(Weapon.Owner).ClientMessage("You sent a trade request to" @ BallLauncher(Weapon).PassTarget.GetHumanReadableName());
            BallLauncher(Weapon).PassTarget.ClientMessage(Pawn(Weapon.Owner).GetHumanReadableName() @ "wishes to trade with you. Press O to accept.");
            BallLauncher(Weapon).PassTarget = None;
            INVInventory.EnableTrade(myINVInventory);
        }
    }
}

defaultproperties
{
     HaveTrade="You already have a trade request from someone or have recently sent one."
     TraderHasTrade="Target already has a trade request from someone or has recently sent one."
     bWaitForRelease=True
     bModeExclusive=False
     FireSound=Sound'WeaponSounds.Misc.ballgun_launch'
     FireForce="ballgun_launch"
     FireRate=5.000000
     AmmoClass=Class'XWeapons.BallAmmo'
}
