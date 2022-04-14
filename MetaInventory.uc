class MetaInventory extends Inventory;

function bool ChangeMonster(class<INVMonster> PawnClass, int StayChangedTime)
{
    local Pawn P, NewPawn;
    local Controller C;
    local Inventory Inv;
    local int i, BeforeHealth;
    local array<Inventory> SavedInvs;

    if(Owner != none && Owner.class == PawnClass
    && Level != none && Level.Game != none && !Level.Game.bGameEnded)
    {
        SetTimer(StayChangedTime, false);
        return true;
    }
    else if(PawnClass == none || Owner == none || Pawn(Owner) == none
    || Level == none || Level.Game == none || Level.Game.bGameEnded)
        return false;

    Owner.SetCollision(false,false,false);
    PawnClass.default.ControllerClass = none;
    NewPawn = Spawn(PawnClass,,, Owner.Location, Owner.Rotation);

	if(NewPawn != none)
	{
        P = Pawn(Owner);
        BeforeHealth = P.Health;
        C = Pawn(Owner).Controller;
        C.UnPossess();
        Level.Game.PreventDeath(P, none, class'DamageType', vect(0,0,0));
        for(Inv=P.Inventory;Inv!=none;Inv=Inv.Inventory)
            if(Inv == self || TransLauncher(Inv) != none || RPGArtifact(Inv) != none)
                SavedInvs[SavedInvs.Length] = Inv;
        for(i=0;i<SavedInvs.Length;i++)
            P.DeleteInventory(SavedInvs[i]);
        P.Destroy();
        C.Possess(NewPawn);
        for(i=0;i<SavedInvs.Length;i++)
            SavedInvs[i].GiveTo(NewPawn);
        Level.Game.SetPlayerDefaults(NewPawn);
        Level.Game.AddDefaultInventory(NewPawn);
        NewPawn.Health = BeforeHealth;
        SetTimer(StayChangedTime, false);
        return true;
    }
    else
        Level.Game.SetPlayerDefaults(Pawn(Owner));
    return false;
}

function Timer()
{
    local Pawn P;
    local Controller C;
    local Inventory Inv;
    local int i, BeforeHealth;
    local array<Inventory> SavedInvs;
    local vector myLoc;
    local rotator myRot;

    if(Level == none || Level.Game == none || Level.Game.bGameEnded
    || Owner == none || Pawn(Owner) == none)
        return;

    P = Pawn(Owner);
    BeforeHealth = P.Health;
    myLoc = Owner.Location;
    myRot = Owner.Rotation;
    C = Pawn(Owner).Controller;
    C.UnPossess();
    Level.Game.PreventDeath(P, none, class'DamageType', vect(0,0,0));
    for(Inv=P.Inventory;Inv!=none;Inv=Inv.Inventory)
        if(Inv == self || TransLauncher(Inv) != none || RPGArtifact(Inv) != none)
            SavedInvs[SavedInvs.Length] = Inv;
    for(i=0;i<SavedInvs.Length;i++)
        P.DeleteInventory(SavedInvs[i]);
    P.Destroy();
    Level.Game.RestartPlayer(C);
    C.Pawn.SetLocation(myLoc);
    C.Pawn.SetRotation(myRot);
    if(C.Pawn == none)
        Level.Game.RestartPlayer(C);
    for(i=0;i<SavedInvs.Length;i++)
        SavedInvs[i].GiveTo(C.Pawn);
    for(Inv=C.Pawn.Inventory;Inv!=none;Inv=Inv.Inventory)
    {
        if(Weapon(Inv) != none)
        {
            Weapon(Inv).ConsumeAmmo(0, Weapon(Inv).AmmoAmount(0), true);
            Weapon(Inv).ConsumeAmmo(1, Weapon(Inv).AmmoAmount(1), true);
        }
    }
    C.Pawn.Health = BeforeHealth;
    super.Timer();
}

defaultproperties
{
}
