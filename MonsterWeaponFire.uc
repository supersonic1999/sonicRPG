class MonsterWeaponFire extends WeaponFire;

event ModeDoFire()
{
    if(Weapon != none && Weapon.ROLE == ROLE_Authority && Weapon.Owner != none && INVMonster(Weapon.Owner) != none)
        INVMonster(Weapon.Owner).myFire();
}

defaultproperties
{
     FireRate=0.100000
}
