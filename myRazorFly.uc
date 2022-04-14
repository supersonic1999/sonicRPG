class myRazorFly extends INVMonster;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	PlayAnim('Fly');
}

function SetMovementPhysics()
{
	Controller.GotoState('PlayerFlying');
	PlayAnim('Fly');
}

singular function Falling()
{
	Controller.GotoState('PlayerFlying');
}

function RangedAttack(Actor A)
{
    if ( bShotAnim )
        return;
    bShotAnim = true;
	PlayAnim('Shoot1');
	if (A != none && MeleeDamageTarget(50, (15000.0 * Normal(A.Location - Location))) )
		PlaySound(sound'injur1rf', SLOT_Talk);
}

function AltRangedAttack(Actor A)
{
    RangedAttack(A);
}

simulated function AnimEnd(int Channel)
{
	if ( bShotAnim )
		bShotAnim = false;
	LoopAnim('Fly',1,0.05);
}

simulated function PlayDirectionalDeath(Vector HitLoc)
{
	PlayAnim('Dead');
}

simulated function PlayDirectionalHit(Vector HitLoc)
{
	TweenAnim('TakeHit', 0.05);
}

defaultproperties
{
     bCanDodge=False
     bAlwaysStrafe=True
     HitSound(0)=Sound'SkaarjPack_rc.Razorfly.injur1rf'
     HitSound(1)=Sound'SkaarjPack_rc.Razorfly.injur2rf'
     HitSound(2)=Sound'SkaarjPack_rc.Razorfly.injur1rf'
     HitSound(3)=Sound'SkaarjPack_rc.Razorfly.injur2rf'
     DeathSound(0)=Sound'SkaarjPack_rc.Razorfly.death1rf'
     DeathSound(1)=Sound'SkaarjPack_rc.Razorfly.death1rf'
     DeathSound(2)=Sound'SkaarjPack_rc.Razorfly.death1rf'
     DeathSound(3)=Sound'SkaarjPack_rc.Razorfly.death1rf'
     bCanFly=True
     MeleeRange=150.000000
     AirSpeed=300.000000
     AccelRate=600.000000
     Health=35
     bPhysicsAnimUpdate=False
     AmbientSound=Sound'SkaarjPack_rc.Razorfly.buzz3rf'
     Mesh=VertMesh'SkaarjPack_rc.FlyM'
     Skins(0)=FinalBlend'SkaarjPackSkins.Skins.JFly1'
     Skins(1)=FinalBlend'SkaarjPackSkins.Skins.JFly1'
     CollisionRadius=18.000000
     CollisionHeight=11.000000
     RotationRate=(Pitch=6000,Yaw=65000,Roll=8192)
}
