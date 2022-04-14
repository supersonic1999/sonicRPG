class AoEHeal extends AoEItem;

static function ServerActorTimer(AoELocINV AActor)
{
    local xPawn P;
    local Inventory Inv, DamageInv;
    local INVInventory INVInventory;
    local int BeforeHealth, ValidHealthGiven;

    if(AActor != none && Controller(AActor.Owner) != none)
    {
        foreach AActor.RadiusActors(class'xPawn', P, default.CollisionRadius)
        {
            if(P.Health > 0 && P.Controller != none
            && P.GetTeamNum() == Controller(AActor.Owner).GetTeamNum())
            {
                BeforeHealth = P.Health;
                if(P.GiveHealth(default.RegenAmount, P.SuperHealthMax)
                && !P.Controller.IsA('FriendlyMonsterController'))
                {
                    DamageInv = none;
                    for(Inv=P.Inventory;Inv!=none;Inv=Inv.Inventory)
                    {
                        if(Inv.IsA('HealableDamageInv'))
                        {
                            DamageInv = Inv;
                            break;
                        }
                    }
                	if(DamageInv != None)
                	{
                        ValidHealthGiven = Max(P.Health-BeforeHealth, 0);
                		if(ValidHealthGiven > 0)
                			DamageInv.SetPropertyText("Damage", string(int(DamageInv.GetPropertyText("Damage"))-ValidHealthGiven));

                		if(int(DamageInv.GetPropertyText("Damage")) > P.HealthMax - P.Health)
                			DamageInv.SetPropertyText("Damage", string(Max(0, P.HealthMax - P.Health)));
                		INVInventory = class'mutInventorySystem'.static.FindINVInventory(Controller(AActor.Owner));
               			if(INVInventory != none && Controller(AActor.Owner).Pawn != none
                        && P != Controller(AActor.Owner).Pawn
                        && FMax(ValidHealthGiven/4.f, 0) > 0.f)
                        {
                	        INVInventory.DataObject.CombatXP += FMax(ValidHealthGiven/4.f, 0);
                            INVInventory.DataObject.CreateDataStruct(INVInventory.DataRep, false);
                        }
                    }
                }
            }
        }
    }
}
static simulated function string GetDescription(Controller Other)
{
    return default.Description @ "You will need" @ default.RequiredSkillLevel @ "points in Health Knowledge to use this item.";
}

defaultproperties
{
     ItemTypeNum=2
     RegenAmount=2
     ItemActorClass=Class'sonicRPG45.AoEHealEmitter'
     ClassRequired=Class'sonicRPG45.ClassFM'
     Description="This item will heal your health if you are in its AoE until it runs out."
     ItemName="Aoe Heal Small 1"
     RequiredSkillLevel=3000
     RequiredSkillNum=3
}
