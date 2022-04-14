class MonsterWeapon extends Weapon;

simulated function bool HasAmmo()
{
    return true;
}

defaultproperties
{
     FireModeClass(0)=Class'sonicRPG45.MonsterWeaponFire'
     FireModeClass(1)=Class'sonicRPG45.MonsterAltWeaponFire'
     bCanThrow=False
     ItemName="Monster Weapon"
}
