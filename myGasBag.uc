class myGasBag extends INVMonster;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if(Controller != none)
	    Controller.GotoState('PlayerFlying');
}

function RangedAttack(Actor A)
{
	if(bShotAnim)
		return;
	SetAnimAction('Belch');
	bShotAnim = true;
}

function AltRangedAttack(Actor A)
{
	if(bShotAnim)
		return;
	PlaySound(sound'twopunch1g',SLOT_Talk);
	if (FRand() < 0.5)
		SetAnimAction('TwoPunch');
	else
		SetAnimAction('Pound');
	bShotAnim = true;
}

function SetMovementPhysics()
{
	Controller.GotoState('PlayerFlying');
}

singular function Falling()
{
	Controller.GotoState('PlayerFlying');
}

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
	Controller.GotoState('PlayerFlying');
    return false;
}

simulated function PlayDirectionalDeath(Vector HitLoc)
{
	if ( FRand() < 0.5 )
		PlayAnim('Deflate',, 0.1);
	else
		PlayAnim('Dead2',, 0.1);
}

simulated function PlayDirectionalHit(Vector HitLoc)
{
	if ( FRand() < 0.6 )
		TweenAnim('TakeHit', 0.05);
	else
		TweenAnim('Hit2', 0.05);
}

function PlayVictory()
{
    PlaySound(sound'twopunch1g',SLOT_Interact);
	SetAnimAction('Pound');
}

function SpawnBelch()
{
	if(ROLE == ROLE_Authority)
        FireProjectile();
}

function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Location + 0.5*X;
}

function PunchDamageTarget()
{
	if(ROLE == ROLE_Authority && Controller.Target != none && MeleeDamageTarget(25, (39000 * Normal(Controller.Target.Location - Location))))
		PlaySound(sound'Hit1g', SLOT_Interact);
}

function PoundDamageTarget()
{
	if(ROLE == ROLE_Authority && Controller.Target != none && MeleeDamageTarget(35, (24000 * Normal(Controller.Target.Location - Location))))
		PlaySound(sound'Hit1g', SLOT_Interact);
}

defaultproperties
{
     bMeleeFighter=False
     DodgeSkillAdjust=4.000000
     HitSound(0)=Sound'SkaarjPack_rc.Gasbag.injur1g'
     HitSound(1)=Sound'SkaarjPack_rc.Gasbag.injur2g'
     HitSound(2)=Sound'SkaarjPack_rc.Gasbag.injur1g'
     HitSound(3)=Sound'SkaarjPack_rc.Gasbag.injur2g'
     DeathSound(0)=Sound'SkaarjPack_rc.Gasbag.death1g'
     DeathSound(1)=Sound'SkaarjPack_rc.Gasbag.death1g'
     DeathSound(2)=Sound'SkaarjPack_rc.Gasbag.death1g'
     DeathSound(3)=Sound'SkaarjPack_rc.Gasbag.death1g'
     ChallengeSound(0)=Sound'SkaarjPack_rc.Gasbag.yell2g'
     ChallengeSound(1)=Sound'SkaarjPack_rc.Gasbag.yell3g'
     ChallengeSound(2)=Sound'SkaarjPack_rc.Gasbag.nearby1g'
     ChallengeSound(3)=Sound'SkaarjPack_rc.Gasbag.yell2g'
     FireSound=Sound'SkaarjPack_rc.Gasbag.yell3g'
     AmmunitionClass=Class'SkaarjPack.GasbagAmmo'
     ScoringValue=4
     bCanFly=True
     AirSpeed=330.000000
     Health=150
     MovementAnims(0)="Float"
     MovementAnims(1)="Float"
     MovementAnims(2)="Float"
     MovementAnims(3)="Float"
     TurnLeftAnim="Idle_Rest"
     TurnRightAnim="Idle_Rest"
     CrouchAnims(0)="Idle_Rest"
     CrouchAnims(1)="Idle_Rest"
     CrouchAnims(2)="Idle_Rest"
     CrouchAnims(3)="Idle_Rest"
     AirAnims(0)="Float"
     AirAnims(1)="Float"
     AirAnims(2)="Float"
     AirAnims(3)="Float"
     TakeoffAnims(0)="Float"
     TakeoffAnims(1)="Float"
     TakeoffAnims(2)="Float"
     TakeoffAnims(3)="Float"
     LandAnims(0)="Float"
     LandAnims(1)="Float"
     LandAnims(2)="Float"
     LandAnims(3)="Float"
     DodgeAnims(0)="Float"
     DodgeAnims(1)="Float"
     DodgeAnims(2)="Float"
     DodgeAnims(3)="Float"
     AirStillAnim="Float"
     TakeoffStillAnim="Float"
     CrouchTurnRightAnim="Float"
     CrouchTurnLeftAnim="Float"
     IdleWeaponAnim="Grab"
     AmbientSound=Sound'SkaarjPack_rc.Gasbag.amb2g'
     Mesh=VertMesh'SkaarjPack_rc.GasBagM'
     Skins(0)=Texture'SkaarjPackSkins.Skins.GasBag1'
     Skins(1)=Texture'SkaarjPackSkins.Skins.GasBag2'
     CollisionRadius=47.000000
     CollisionHeight=36.000000
     Mass=120.000000
}
