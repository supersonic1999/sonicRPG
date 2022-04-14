class GhostGizINV extends GizmoINV;

var int LastUseTime, RechargeTime, StayGhostedTime, RepTimeSeconds;
var color GhostColor;
var protected array<ColorModifier> GhostSkins;
var protected array<Material> OldInstigatorSkins;
var protected Material OldInstigatorRepSkin;

replication
{
	reliable if(bNetDirty && Role==ROLE_Authority)
	    RepTimeSeconds,LastUseTime;
}

simulated function PostBeginPlay();

function EnableGiz()
{
    if(LastUseTime == 0 || RepTimeSeconds >= (LastUseTime + RechargeTime))
    {
        LastUseTime = Level.TimeSeconds;
        SetTimer(StayGhostedTime, False);
    }
    if(Instigator != none)
    {
	    RepTimeSeconds = Level.TimeSeconds;
        //ClientEnableGiz();
        //CreateGhostSkins();
        //OldInstigatorRepSkin = Instigator.RepSkin;
        //Instigator.RepSkin = None;
        //Instigator.Skins = GhostSkins;
	    Instigator.SetCollision(false);
	}
    super.EnableGiz();
}

//simulated function ClientEnableGiz()
//{
//    if(ROLE < ROLE_Authority)
//    {
//        CreateGhostSkins();
//        if(Instigator != none)
//	        Instigator.Skins = GhostSkins;
//	}
//}

function DisableGiz()
{
//   local int x;

    if(Instigator != none)
    {
        Instigator.SetCollision(true);
//        if(OldInstigatorRepSkin != none)
//            Instigator.RepSkin = OldInstigatorRepSkin;
//        if(OldInstigatorSkins.length > 0)
//            Instigator.Skins = OldInstigatorSkins;
    }
//	for(x=0;x<GhostSkins.length;x++)
//		Level.ObjectPool.FreeObject(GhostSkins[x]);
//	GhostSkins.length = 0;
//    ClientDisableGiz();
    super.DisableGiz();
}

//simulated function ClientDisableGiz()
//{
//    local int x;
//
//    if(ROLE < ROLE_Authority)
//    {
//        if(Instigator != none && OldInstigatorSkins.length > 0)
//            Instigator.Skins = OldInstigatorSkins;
//    	for(x=0;x<GhostSkins.length;x++)
//    		Level.ObjectPool.FreeObject(GhostSkins[x]);
//    	GhostSkins.length = 0;
//	}
//}
//
//simulated function CreateGhostSkins()
//{
//	local int x;
//
//    if(Instigator == none)
//        return;
//
//	OldInstigatorSkins = Instigator.Skins;
//	for (x = 0; x < Instigator.Skins.length; x++)
//	{
//		GhostSkins[x] = ColorModifier(Level.ObjectPool.AllocateObject(class'ColorModifier'));
//		GhostSkins[x].Material = Instigator.Skins[x];
//		GhostSkins[x].AlphaBlend = true;
//		GhostSkins[x].RenderTwoSided = true;
//		GhostSkins[x].Color = GhostColor;
//	}
//}

function Tick(float DeltaTime)
{
    if(ROLE == ROLE_Authority && Level.TimeSeconds < (LastUseTime + RechargeTime + 1) && Level.TimeSeconds > RepTimeSeconds)
        RepTimeSeconds = Level.TimeSeconds;
    super.Tick(DeltaTime);
}

function Timer()
{
    super.Timer();
    if(bEnabled)
        DisableGiz();
}

defaultproperties
{
     RechargeTime=30
     StayGhostedTime=20
     GhostColor=(B=255,G=255,R=255,A=64)
}
