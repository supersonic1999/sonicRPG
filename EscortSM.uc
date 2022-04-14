class EscortSM extends StaticMeshActor;

replication
{
	reliable if(ROLE==ROLE_Authority)
		SetClientSkin;
}

function PostBeginPlay()
{
    SetClientSkin(Owner);
    super.PostBeginPlay();
}

protected simulated function SetClientSkin(Actor myOwner)
{
    if(ROLE<ROLE_Authority && Level != none && Level.GetLocalPlayerController() == myOwner)
        Skins[0] = Shader'ONSstructureTextures.CoreEnergyShaderBlue';
}

function Tick(float DeltaTime)
{
    if(Owner == none)
        Destroy();
    super.Tick(DeltaTime);
}

defaultproperties
{
     StaticMesh=StaticMesh'VMStructures.CoreGroup.CoreShieldSM'
     bStatic=False
     bWorldGeometry=False
     bAlwaysRelevant=True
     DrawScale3D=(Z=10.000000)
     bUnlit=True
     bCollideActors=False
     bBlockActors=False
     bBlockKarma=False
     bNetInitial=True
}
