class TradeWeapon extends BallLauncher
    HideDropDown
	CacheExempt;

simulated function bool HasAmmo()
{
    return Super(Weapon).HasAmmo();
}

simulated function BringUp(optional Weapon PrevWeapon)
{
    Super(Weapon).BringUp(PrevWeapon);

    FireMode[0].bIsFiring = true;
    FireMode[0].bNowWaiting = true;
}

simulated function Weapon NextWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
	return Super(Weapon).NextWeapon(CurrentChoice,CurrentWeapon);
}

simulated function Weapon PrevWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
	return Super(Weapon).PrevWeapon(CurrentChoice,CurrentWeapon);
}

simulated function bool PutDown()
{
    return Super(Weapon).PutDown();
}

function bool BotFire(bool bFinished, optional name FiringMode)
{
	return false;
}

simulated function Tick(float dt)
{
    super(Weapon).Tick(dt);
}

function SetPassTarget( Pawn passTarg )
{
    PassTarget = passTarg;
    if ( PassTarget == None )
		Level.Game.GameReplicationInfo.FlagTarget = None;
    else
		Level.Game.GameReplicationInfo.FlagTarget = PassTarget.PlayerReplicationInfo;
    if ( PlayerController(Instigator.Controller) != None )
    {
        if ( passTarg != None )
            PlayerController(Instigator.Controller).ClientPlaySound(PassTargetLocked);
        else
            PlayerController(Instigator.Controller).ClientPlaySound(PassTargetLost);
    }
}

defaultproperties
{
     FireModeClass(0)=Class'sonicRPG45.BallShoot'
     FireModeClass(1)=Class'sonicRPG45.TraderTarget'
     bForceSwitch=False
     bNoVoluntarySwitch=False
     bNoInstagibReplace=False
     InventoryGroup=0
     ItemName="Trader"
}
