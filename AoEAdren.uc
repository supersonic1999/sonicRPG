class AoEAdren extends AoEItem;

static function ServerActorTimer(AoELocINV AActor)
{
    local xPawn P;
    local INVInventory INVInventory;
    local float BeforeAdren;

    if(AActor != none && Controller(AActor.Owner) != none)
    {
        foreach AActor.RadiusActors(class'xPawn', P, default.CollisionRadius)
        {
            if(P.Health > 0 && Monster(P) == none
            && AActor.Owner != none && P.Controller != none
            && P.Controller.Adrenaline < P.Controller.AdrenalineMax
            && P.GetTeamNum() == Controller(AActor.Owner).GetTeamNum())
            {
                BeforeAdren = P.Controller.Adrenaline;
                P.Controller.AwardAdrenaline(default.RegenAmount);
                INVInventory = class'mutInventorySystem'.static.FindINVInventory(Controller(AActor.Owner));
                if(INVInventory != none
                && Controller(AActor.Owner).Pawn != none
                && P != Controller(AActor.Owner).Pawn
                && FMax((P.Controller.Adrenaline-BeforeAdren)/2.f, 0) > 0.f
                && !P.Controller.IsA('FriendlyMonsterController'))
                {
                    INVInventory.DataObject.CombatXP += FMax((P.Controller.Adrenaline-BeforeAdren)/2.f, 0);
                    INVInventory.DataObject.CreateDataStruct(INVInventory.DataRep, false);
                }
            }
        }
    }
}

static simulated function string GetDescription(Controller Other)
{
    return default.Description @ "You will need" @ default.RequiredSkillLevel @ "points in Adren Knowledge to use this item.";
}

defaultproperties
{
     ItemTypeNum=1
     ItemActorClass=Class'sonicRPG45.AoEAdrenEmitter'
     Image=Texture'SonicRPGTEX46.Inventory.AoEAdrenS'
     ClassRequired=Class'sonicRPG45.ClassAJ'
     Description="This item will give you adrenaline if you are in its area until its effect runs out."
     ItemName="Aoe Adren Small 1"
     RequiredSkillLevel=3000
     RequiredSkillNum=4
}
