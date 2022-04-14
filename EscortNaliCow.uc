class EscortNaliCow extends SMPNaliCow;

simulated event PostNetReceive();

simulated function Setup(xUtil.PlayerRecord rec, optional bool bLoadNow);

function bool SameSpeciesAs(Pawn P);

defaultproperties
{
     bNetNotify=False
}
