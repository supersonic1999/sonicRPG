class EscortTitan extends SMPTitan;

simulated event PostNetReceive();

simulated function Setup(xUtil.PlayerRecord rec, optional bool bLoadNow);

function bool SameSpeciesAs(Pawn P);

singular event BaseChange()
{
	if ( bInterpolating )
		return;
	if ( (base == None) && (Physics == PHYS_None) )
		SetPhysics(PHYS_Falling);
	else if ( Pawn(Base) != None )
	{
		if ( !Pawn(Base).bCanBeBaseForPawns )
		{
		JumpOffPawn();
		SetPhysics(PHYS_Falling);
		}
	}
}

defaultproperties
{
     bNetNotify=False
}
