class myWarLord extends INVMonster;

var bool bRocketDir;

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
	Controller.GotoState('PlayerFlying');
	return true;
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	bMeleeFighter = (FRand() < 0.5);
}

function Step()
{
	PlaySound(sound'step1t', SLOT_Interact);
}

function Flap()
{
	PlaySound(sound'fly1WL', SLOT_Interact);
}

function SetMovementPhysics()
{
	Controller.GotoState('PlayerFlying');
}

singular function Falling()
{
	Controller.GotoState('PlayerFlying');
}

simulated function PlayDirectionalDeath(Vector HitLoc)
{
	if ( Physics == PHYS_Flying )
		PlayAnim('Dead2A');
	else
		PlayAnim('Dead1');
}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
	if ( Damage > 50 )
		Super.PlayTakeHit(HitLocation,Damage,DamageType);
}

simulated function PlayDirectionalHit(Vector HitLoc)
{
	local name Anim;
	local float frame,rate;

	if ( bShotAnim )
		return;

	GetAnimParams(0, Anim,frame,rate);

	if ( Anim == 'FDodgeUp' )
		return;
	TweenAnim('TakeHit', 0.05);
}

function RangedAttack(Actor A)
{
	if ( bShotAnim )
		return;
	else if ( Physics == PHYS_Flying )
		SetAnimAction('FlyFire');
	else
		SetAnimAction('Fire');
	bShotAnim = true;
}

function AltRangedAttack(Actor A)
{
    if(Physics == PHYS_Flying)
    {
	    SetPhysics(PHYS_Walking);
        Controller.GotoState('PlayerWalking');
	    return;
    }
    else if ( bShotAnim)
		return;

	SetAnimAction('Strike');
	bShotAnim = true;
	if(Controller.Target != none && MeleeDamageTarget(45, (45000.0 * Normal(Controller.Target.Location - Location))))
		PlaySound(sound'Threat1WL', SLOT_Talk);
}

function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Location + 0.5 * CollisionRadius * (X+Z-Y);
}

function FireProjectile()
{
	local vector FireStart,X,Y,Z,StartTrace;
	local rotator ProjRot,Aim;
	local float BestDist,BestAim;
	local SeekingRocketProj S;
	local Pawn Other;

	if(ROLE == ROLE_Authority && Controller != none)
	{
		GetAxes(Rotation,X,Y,Z);
		FireStart = GetFireStart(X,Y,Z);
		if ( !SavedFireProperties.bInitialized )
		{
			SavedFireProperties.AmmoClass = MyAmmo.Class;
			SavedFireProperties.ProjectileClass = MyAmmo.ProjectileClass;
			SavedFireProperties.WarnTargetPct = MyAmmo.WarnTargetPct;
			SavedFireProperties.MaxRange = MyAmmo.MaxRange;
			SavedFireProperties.bTossed = MyAmmo.bTossed;
			SavedFireProperties.bTrySplash = MyAmmo.bTrySplash;
			SavedFireProperties.bLeadTarget = MyAmmo.bLeadTarget;
			SavedFireProperties.bInstantHit = MyAmmo.bInstantHit;
			SavedFireProperties.bInitialized = true;
		}
		ProjRot = Controller.AdjustAim(SavedFireProperties,FireStart,600);
		if ( bRocketDir )
			ProjRot.Yaw += 3072;
		else
			ProjRot.Yaw -= 3072;
		bRocketDir = !bRocketDir;

		StartTrace = Location + EyePosition();
		Aim = GetViewRotation();
		Other = Controller.PickTarget(BestAim, BestDist, Vector(Aim), StartTrace, class'WarlordRocket'.default.LifeSpan*class'WarlordRocket'.default.Speed);
        S = Spawn(class'WarlordRocket',,,FireStart,ProjRot);
        S.Seeking = Other;
		PlaySound(FireSound,SLOT_Interact);
	}
}

defaultproperties
{
     bMeleeFighter=False
     bTryToWalk=True
     bBoss=True
     DodgeSkillAdjust=4.000000
     HitSound(0)=Sound'SkaarjPack_rc.WarLord.injur1WL'
     HitSound(1)=Sound'SkaarjPack_rc.WarLord.injur2WL'
     HitSound(2)=Sound'SkaarjPack_rc.WarLord.injur1WL'
     HitSound(3)=Sound'SkaarjPack_rc.WarLord.injur2WL'
     DeathSound(0)=Sound'SkaarjPack_rc.WarLord.DeathCry1WL'
     DeathSound(1)=Sound'SkaarjPack_rc.WarLord.DeathCry1WL'
     DeathSound(2)=Sound'SkaarjPack_rc.WarLord.DeathCry1WL'
     DeathSound(3)=Sound'SkaarjPack_rc.WarLord.DeathCry1WL'
     ChallengeSound(0)=Sound'SkaarjPack_rc.WarLord.acquire1WL'
     ChallengeSound(1)=Sound'SkaarjPack_rc.WarLord.roam1WL'
     ChallengeSound(2)=Sound'SkaarjPack_rc.WarLord.threat1WL'
     ChallengeSound(3)=Sound'SkaarjPack_rc.WarLord.breath1WL'
     FireSound=SoundGroup'WeaponSounds.RocketLauncher.RocketLauncherFire'
     AmmunitionClass=Class'SkaarjPack.WarlordAmmo'
     ScoringValue=10
     bCanFly=True
     MeleeRange=80.000000
     GroundSpeed=400.000000
     AirSpeed=500.000000
     Health=500
     MovementAnims(1)="RunF"
     MovementAnims(2)="RunF"
     MovementAnims(3)="RunF"
     TurnLeftAnim="Idle_Rest"
     TurnRightAnim="Idle_Rest"
     WalkAnims(1)="WalkF"
     WalkAnims(2)="WalkF"
     WalkAnims(3)="WalkF"
     AirAnims(0)="Fly"
     AirAnims(1)="Fly"
     AirAnims(2)="Fly"
     AirAnims(3)="Fly"
     TakeoffAnims(0)="Fly"
     TakeoffAnims(1)="Fly"
     TakeoffAnims(2)="Fly"
     TakeoffAnims(3)="Fly"
     AirStillAnim="Fly"
     TakeoffStillAnim="Fly"
     Mesh=VertMesh'SkaarjPack_rc.WarlordM'
     Skins(0)=FinalBlend'SkaarjPackSkins.Skins.JWarlord1'
     Skins(1)=FinalBlend'SkaarjPackSkins.Skins.JWarlord1'
     TransientSoundVolume=1.000000
     TransientSoundRadius=1500.000000
     CollisionRadius=47.000000
     CollisionHeight=78.000000
     Mass=300.000000
}
