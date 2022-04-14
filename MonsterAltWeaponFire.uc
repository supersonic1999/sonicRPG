class MonsterAltWeaponFire extends WeaponFire;

event ModeDoFire()
{
    if(Weapon != none && Weapon.ROLE == ROLE_Authority && Weapon.Owner != none && INVMonster(Weapon.Owner) != none)
        INVMonster(Weapon.Owner).myAltFire();
}

defaultproperties
{
     FireRate=0.100000
}
