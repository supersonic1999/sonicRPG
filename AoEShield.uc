class AoEShield extends AoEItem;

static function ServerActorTimer(AoELocINV AActor)
{
    local xPawn P;
    local INVInventory INVInventory;
    local float BeforeShield;

    if(AActor != none && Controller(AActor.Owner) != none)
    {
        foreach AActor.RadiusActors(class'xPawn', P, default.CollisionRadius)
        {
            BeforeShield = P.ShieldStrength;
            if(P.Health > 0 && Monster(P) == none && P.Controller != none
            && AActor.Owner != none && P.GetTeamNum() == Controller(AActor.Owner).GetTeamNum()
            && P.AddShieldStrength(default.RegenAmount))
            {
                INVInventory = class'mutInventorySystem'.static.FindINVInventory(Controller(AActor.Owner));
                if(INVInventory != none
                && Controller(AActor.Owner).Pawn != none
                && P != Controller(AActor.Owner).Pawn
                && FMax((P.ShieldStrength-BeforeShield)/4.f, 0) > 0.f
                && !P.Controller.IsA('FriendlyMonsterController'))
                {
                    INVInventory.DataObject.CombatXP += FMax((P.ShieldStrength-BeforeShield)/4.f, 0);
                    INVInventory.DataObject.CreateDataStruct(INVInventory.DataRep, false);
                }
            }
        }
    }
}

static simulated function string GetDescription(Controller Other)
{
    return default.Description @ "You will need" @ default.RequiredSkillLevel @ "points in Defence Knowledge to use this item.";
}

defaultproperties
{
     ItemTypeNum=3
     RegenAmount=2
     ItemActorClass=Class'sonicRPG45.AoEShieldEmitter'
     Image=Texture'SonicRPGTEX46.Inventory.AoEShieldS'
     ClassRequired=Class'sonicRPG45.ClassDE'
     Description="This item will repair your shield if you are in its area until its effect runs out."
     ItemName="Aoe Shield Small 1"
     RequiredSkillLevel=3000
     RequiredSkillNum=6
}
