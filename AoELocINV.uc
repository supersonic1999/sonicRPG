class AoELocINV extends Emitter;

#exec OBJ LOAD FILE=EpicParticles.utx

var class<AoEItem> StaticActorOwner;

simulated function PostBeginPlay()
{
    Disable('Tick');
    super.PostBeginPlay();
}

function Timer()
{
    if(StaticActorOwner != none)
        StaticActorOwner.static.ServerActorTimer(self);
    super.Timer();
}

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter0
         StaticMesh=StaticMesh'ParticleMeshes.Complex.ExplosionRing'
         UseParticleColor=True
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.300000,Color=(B=56,G=137,R=197))
         ColorScale(2)=(RelativeTime=0.600000,Color=(B=7,G=177,R=186))
         ColorScale(3)=(RelativeTime=1.000000)
         FadeOutStartTime=1.000000
         FadeInEndTime=0.100000
         MaxParticles=1
         StartSpinRange=(Y=(Max=1.000000),Z=(Max=1.000000))
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.500000)
         StartSizeRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000))
         InitialParticlesPerSecond=50000.000000
         Texture=Texture'EpicParticles.Smoke.FlameGradient'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         InitialDelayRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(0)=MeshEmitter'sonicRPG45.AoELocINV.MeshEmitter0'

     bNoDelete=False
     Physics=PHYS_Falling
     RemoteRole=ROLE_DumbProxy
     LifeSpan=5.000000
     bCollideWorld=True
     bNotOnDedServer=False
}
