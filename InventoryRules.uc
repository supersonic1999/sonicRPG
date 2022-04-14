class InventoryRules extends GameRules
    config(InventorySystem);

var mutInventorySystem INVMut;

function PostBeginPlay()
{
	SetTimer(Level.TimeDilation, true);
	Super.PostBeginPlay();
}

function INVInventory GetINVFor(Controller C, optional bool bMustBeOwner)
{
	local Inventory Inv;

	if(C.IsA('FriendlyMonsterController'))
	    C = FriendlyMonsterController(C).Master;
    for(Inv = C.Inventory; Inv != None; Inv = Inv.Inventory)
		if(INVInventory(Inv) != none && (!bMustBeOwner || Inv.Owner == C || Inv.Owner == C.Pawn
		|| (Vehicle(C.Pawn) != none && Inv.Owner == Vehicle(C.Pawn).Driver)))
			return INVInventory(Inv);

	if(C.Pawn != None)
	{
		Inv = C.Pawn.FindInventoryType(class'INVInventory');
		if(Inv != none && (!bMustBeOwner || Inv.Owner == C || Inv.Owner == C.Pawn
		|| (Vehicle(C.Pawn) != none && Inv.Owner == Vehicle(C.Pawn).Driver)))
			return INVInventory(Inv);
	}
	return None;
}

function int NetDamage(int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	local LinkGun HeadLG, LG;
	local Controller C;
	local INVInventory INVInventory, OtherInv;
	local int i, SuperReturn;
	local float myDamage;
	local array<INVInventory> Links;

//    if(injured.Controller.IsA('FriendlyMonsterController'))
//        Log(FindObject(injured.Controller.GetPropertyText("Master"), class'Controller'));
    SuperReturn = Super.NetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
    if(instigatedBy == none && DamageType.default.bSuperWeapon
    && Level != none && Level.Game != none && TeamGame(Level.Game) != none
    && TeamGame(Level.Game).FriendlyFireScale <= 0.0)
        return 0;
    else if(injured.Controller != none
    && injured.Controller.IsA('FriendlyMonsterController')
    && Injured.Controller.GetPropertyText("Master") != ""
    && instigatedBy != none && instigatedBy.Controller != none
    && injured.Controller.SameTeamAs(instigatedBy.Controller)
    && (Vehicle(instigatedBy) != none || (injured != none && injured.Health >= injured.HealthMax
    && RW_Healer(instigatedBy.Weapon) != none)
    || DamageType != class'AoEItemDT'))
	    return Damage * TeamGame(Level.Game).FriendlyFireScale;
    else if(injured == none || instigatedBy == none || injured.Controller == none
    || instigatedBy.Controller == none || INVMut == none || instigatedBy == injured
    || (!instigatedBy.Controller.bIsPlayer && !injured.Controller.IsA('FriendlyMonsterController')))
        return SuperReturn;

    INVInventory = GetINVFor(instigatedBy.Controller);

//    if(INVInventory != none && INVInventory.DataObject != none && INVInventory.DataObject.CurrentMission != none)
//        INVInventory.DataObject.CurrentMission.static.NetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);

    if(INVInventory != none && INVInventory.Instigator != none)
    {
//        if(FriendlyMonsterController(injured.Controller) != none && (RW_Healer(INVInventory.Instigator.Weapon) == none
//        || RW_Healer(INVInventory.Instigator.Weapon) != none && injured.Health >= injured.HealthMax))
//            return SuperReturn;

        myDamage = FMin(Damage, injured.Health);
        HeadLG = LinkGun(INVInventory.Instigator.Weapon);
		if(HeadLG == none && INVInventory.Instigator.Weapon != none && INVInventory.Instigator.Weapon.IsA('RPGWeapon'))
			HeadLG = LinkGun(RPGWeapon(INVInventory.Instigator.Weapon).ModifiedWeapon);

		if(HeadLG == None)
		{
            INVInventory.DataObject.Credits += (myDamage * (INVMut.CreditPercentage / 100));
            if(Monster(injured) != none)
                INVInventory.DataObject.CombatXP += (myDamage / injured.HealthMax * Monster(injured).ScoringValue);
            else
                INVInventory.DataObject.CombatXP += myDamage;
            INVInventory.MutINV.CheckLevelUp(INVInventory);
            INVInventory.DataObject.CreateDataStruct(INVInventory.DataRep, false, true);
        }
		else if(INVInventory.Instigator.Weapon != none)
		{
            Links[0] = INVInventory;
			for(C=Level.ControllerList; C!=None; C=C.NextController)
			{
                if(C.bIsPlayer && C.Pawn != none && C.Pawn.Weapon != None)
				{
                    LG = LinkGun(C.Pawn.Weapon);
                    if(LG == none && RPGWeapon(C.Pawn.Weapon) != None)
                        LG = LinkGun(RPGWeapon(C.Pawn.Weapon).ModifiedWeapon);
					if(LG != none && LG.LinkedTo(HeadLG))
					{
                        OtherInv = GetINVFor(C, false);
                        if(OtherInv != none)
                            Links[Links.length] = OtherInv;
					}
				}
			}

			for(i=0; i<Links.length; i++)
			{
                Links[i].DataObject.Credits += ((myDamage * (INVMut.CreditPercentage / 100)) / Links.length);
                if(Monster(injured) != none)
                    Links[i].DataObject.CombatXP += (myDamage / injured.HealthMax * Monster(injured).ScoringValue) / Links.length;
                else
                    Links[i].DataObject.CombatXP += myDamage / Links.length;
                Links[i].MutINV.CheckLevelUp(Links[i]);
                Links[i].DataObject.CreateDataStruct(Links[i].DataRep, false, true);
            }
		}
    }
    return SuperReturn;
}

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local Controller KilledController;
    local INVInventory INVInventory;
    local bool bAlreadyPrevented;

    bAlreadyPrevented = Super.PreventDeath(Killed, Killer, damageType, HitLocation);
    if(!bAlreadyPrevented)
    {
        if(Killed.Controller != None)
    		KilledController = Killed.Controller;
    	else if(Killed.DrivenVehicle != None && Killed.DrivenVehicle.Controller != None)
    		KilledController = Killed.DrivenVehicle.Controller;
        if(KilledController != none && PlayerController(KilledController) != none)
            INVInventory = GetINVFor(KilledController, true);

        if(INVInventory != none)
            INVInventory.OwnerDied();
    }
	return bAlreadyPrevented;
}

function bool HandleRestartGame()
{
	local Controller C;
	local Inventory Inv;

    if(INVMut != none)
	    INVMut.SaveData();

	for (C = Level.ControllerList; C != None; C = C.NextController)
		if(C.bIsPlayer)
			for (Inv = C.Inventory; Inv != None; Inv = Inv.Inventory)
				if (Inv.IsA('INVInventory'))
				{
					INVInventory(Inv).DataObject = None;
					Inv.Disable('Tick');
				}
	INVMut.SetTimer(0, false);
	return Super.HandleRestartGame();
}

function ScoreKill(Controller Killer, Controller Killed)
{
	local int i, Amount, Chance;
    local class<MainInventoryItem> Item;
	local INVInventory INVInventory, KilledINVInventory;
	local ChanceGizINV ChanceGIZ;

    Super.ScoreKill(Killer, Killed);

    if(Killed == none || Killer == none || Killer == Killed
    || Killed.Pawn == none || Killer.Pawn == none
    || INVMut == none || !Killer.bIsPlayer)
		return;

    INVInventory = GetINVFor(Killer);
	if(INVInventory != none && INVInventory.DataObject != none && INVInventory.DataObject.CurrentMission != none)
        INVInventory.DataObject.CurrentMission.static.ScoreKill(Killer, Killed);

    KilledINVInventory = GetINVFor(Killed);
    if(KilledINVInventory != none && KilledINVInventory.DataObject != none)
        for(i=0;i<KilledINVInventory.DataObject.Items.Length;i++)
            KilledINVInventory.DataObject.Items[i].static.OwnerDied(Killer, Killed);

    ChanceGIZ = ChanceGizINV(Killer.Pawn.FindInventoryType(class'ChanceGizINV'));
    if(INVInventory == none || INVInventory.DataObject == none
    || ChanceGIZ != none && frand() > ((INVMut.LootChance*1.25)/100)
    || ChanceGIZ == none && frand() > (INVMut.LootChance/100) || Killed.SameTeamAs(Killer))
        return;

    Chance = rand(INVMut.TotalLootChance);
	for(i=0;i<INVMut.LootableItems.Length;i++)
	{
        Chance -= INVMut.LootableItems[i].Chance;
		if(Chance < 0)
		{
			Item = INVMut.LootableItems[i].ItemClass;
			break;
		}
	}

    Amount = Max(rand(INVMut.LootableItems[i].MaxLoot), 1);

    if(PlayerController(Killer) != none)
        PlayerController(Killer).ClientMessage(class'GameInfo'.static.MakeColorCode(class'mutInventorySystem'.default.YellowColor)
                                             $ "You picked up" @ Amount @ Item.static.GetInvItemName(Killer) $ ".");

    for(i=0;i<INVInventory.DataObject.Items.Length;i++)
    {
        if(INVInventory.DataObject.Items[i] == Item)
        {
            INVInventory.DataObject.ItemsAmount[i] += Amount;
            INVInventory.ReplicateToClientSide(i, INVInventory.DataObject.Items[i], INVInventory.DataObject.ItemsAmount[i]);
            if(INVInventory.DataObject.CurrentMission != none)
                INVInventory.DataObject.CurrentMission.static.PickedUpItem(Killer, Item, Amount, "lootitem");
            return;
        }
    }

    for(i=0;i<INVInventory.LootedItems.Length;i++)
    {
        if(INVInventory.LootedItems[i] == Item)
        {
            INVInventory.LootedItemsAmount[i] += Amount;
            INVInventory.ReplicateLootToClientSide(i, INVInventory.LootedItems[i], INVInventory.LootedItemsAmount[i]);
            INVInventory.ClientLootUpdateGUI();
            return;
        }
    }
    INVInventory.LootedItems[INVInventory.LootedItems.Length] = Item;
    INVInventory.LootedItemsAmount[INVInventory.LootedItemsAmount.Length] = Amount;
    INVInventory.ClientAddNewLootItem(Item, Amount);
    INVInventory.ClientLootUpdateGUI();
}

function Timer()
{
	local Controller C;
	local Inventory Inv;

	if(Level.Game.bGameEnded)
		SetTimer(0, false);
	else if(Level.Game.ResetCountDown == 2)
		for (C = Level.ControllerList; C != None; C = C.NextController)
			if(C.bIsPlayer)
				for (Inv = C.Inventory; Inv != None; Inv = Inv.Inventory)
					if (Inv.IsA('INVInventory') && Inv.Owner != C && Inv.Owner != None)
					{
						Log("Resetting INVInventory: "$Inv);
						INVInventory(Inv).OwnerDied();
						break;
					}
}

defaultproperties
{
}
