class myBrute extends INVMonster;

#exec OBJ LOAD FILE=SkaarjPackSkins.utx

//-----------------------------------------------------------------------------
// Brute variables.

var bool bLeftShot;

// Sounds
var(Sounds) sound Footstep[2];
var name MeleeAttack[4];

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
	if ( Damage > 15 )
		Super.PlayTakeHit(HitLocation,Damage,DamageType);
}

function RangedAttack(Actor A)
{
	if ( bShotAnim )
		return;
	if ( Controller.InLatentExecution(501) ) // LATENT_MOVETO
		return;
	else
		SetAnimAction('StillFire');

	Controller.bPreparingMove = true;
	Acceleration = vect(0,0,0);
	bShotAnim = true;
}

function AltRangedAttack(Actor A)
{
	if ( bShotAnim )
		return;
	PlaySound(sound'pwhip1br',SLOT_Talk);
	SetAnimAction(MeleeAttack[Rand(4)]);
	bShotAnim = true;
}

function WhipDamageTarget()
{
	if(ROLE == ROLE_Authority && Controller.Target != none && MeleeDamageTarget(35, 40000.0 * Normal(Controller.Target.Location - Location)))
		PlaySound(sound'pwhip1br', SLOT_Interact);
}

function SpawnLeftShot()
{
	if(ROLE != ROLE_Authority)
        return;
    bLeftShot = true;
	FireProjectile();
}

function SpawnRightShot()
{
    if(ROLE != ROLE_Authority)
        return;
    bLeftShot = false;
    FireProjectile();
}

function vector GetFireStart(vector X, vector Y, vector Z)
{
	if ( bLeftShot )
		return Location + CollisionRadius * ( X + 0.7 * Y + 0.4 * Z);
	else
		return Location + CollisionRadius * ( X - 0.7 * Y + 0.4 * Z);
}

function Step()
{
	PlaySound(FootStep[Rand(2)], SLOT_Interact);
}

defaultproperties
{
     Footstep(0)=Sound'SkaarjPack_rc.Brute.walk1br'
     Footstep(1)=Sound'SkaarjPack_rc.Brute.walk2br'
     MeleeAttack(0)="PistolWhip"
     MeleeAttack(1)="Punch"
     MeleeAttack(2)="PistolWhip"
     MeleeAttack(3)="Punch"
     bCanDodge=False
     HitSound(0)=Sound'SkaarjPack_rc.Brute.injur1br'
     HitSound(1)=Sound'SkaarjPack_rc.Brute.injur2br'
     HitSound(2)=Sound'SkaarjPack_rc.Brute.injur1br'
     HitSound(3)=Sound'SkaarjPack_rc.Brute.injur2br'
     DeathSound(0)=Sound'SkaarjPack_rc.Krall.death1k'
     DeathSound(1)=Sound'SkaarjPack_rc.Krall.death2k'
     DeathSound(2)=Sound'SkaarjPack_rc.Krall.death1k'
     DeathSound(3)=Sound'SkaarjPack_rc.Krall.death2k'
     ChallengeSound(0)=Sound'SkaarjPack_rc.Brute.yell1br'
     ChallengeSound(1)=Sound'SkaarjPack_rc.Brute.injur2br'
     ChallengeSound(2)=Sound'SkaarjPack_rc.Brute.nearby2br'
     ChallengeSound(3)=Sound'SkaarjPack_rc.Brute.yell2br'
     FireSound=SoundGroup'WeaponSounds.RocketLauncher.RocketLauncherFire'
     AmmunitionClass=Class'SkaarjPack.BruteAmmo'
     ScoringValue=5
     bCanStrafe=False
     MeleeRange=80.000000
     GroundSpeed=150.000000
     WaterSpeed=100.000000
     JumpZ=100.000000
     Health=220
     MovementAnims(0)="WalkF"
     MovementAnims(1)="WalkF"
     MovementAnims(2)="WalkF"
     MovementAnims(3)="WalkF"
     SwimAnims(0)="WalkF"
     SwimAnims(1)="WalkF"
     SwimAnims(2)="WalkF"
     SwimAnims(3)="WalkF"
     WalkAnims(1)="WalkF"
     WalkAnims(2)="WalkF"
     WalkAnims(3)="WalkF"
     IdleSwimAnim="WalkF"
     IdleWeaponAnim="CockGun"
     Mesh=VertMesh'SkaarjPack_rc.Brute1'
     Skins(0)=Texture'SkaarjPackSkins.Skins.jBrute1'
     Skins(1)=FinalBlend'XEffectMat.Shield.RedShell'
     TransientSoundVolume=0.700000
     TransientSoundRadius=800.000000
     CollisionRadius=47.000000
     CollisionHeight=52.000000
     Mass=400.000000
     Buoyancy=390.000000
     RotationRate=(Yaw=45000,Roll=0)
}
