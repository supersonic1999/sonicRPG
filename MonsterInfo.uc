class MonsterInfo extends Mutator;

struct Loot
{
    var class<MainInventoryItem> ItemClass;
    var int MaxLoot, Chance;
};
var array<Loot> LootableItems;

var int MaxCredits;

static function Pawn FindMonsterInfo(class<Pawn> PawnClass)
{
    return none;
}

defaultproperties
{
     LootableItems(0)=(ItemClass=Class'sonicRPG45.MiniHealthInvItem',MaxLoot=20,Chance=2000)
     LootableItems(1)=(ItemClass=Class'sonicRPG45.HealthInvItem',MaxLoot=5,Chance=1000)
     LootableItems(2)=(ItemClass=Class'sonicRPG45.SuperHealthInvItem',MaxLoot=2,Chance=500)
     LootableItems(3)=(ItemClass=Class'sonicRPG45.ShieldInvItem',MaxLoot=5,Chance=1000)
     LootableItems(4)=(ItemClass=Class'sonicRPG45.SuperShieldInvItem',MaxLoot=2,Chance=500)
     LootableItems(5)=(ItemClass=Class'sonicRPG45.AdrenalineInvItem',MaxLoot=20,Chance=2000)
     LootableItems(6)=(ItemClass=Class'sonicRPG45.AdrenalineTwoInvItem',MaxLoot=5,Chance=1000)
     LootableItems(7)=(ItemClass=Class'sonicRPG45.AdrenalineThreeInvItem',MaxLoot=2,Chance=500)
     LootableItems(8)=(ItemClass=Class'sonicRPG45.LinkAmmoInvItem',MaxLoot=5,Chance=200)
     LootableItems(9)=(ItemClass=Class'sonicRPG45.RocketAmmoInvItem',MaxLoot=5,Chance=200)
     LootableItems(10)=(ItemClass=Class'sonicRPG45.ShockAmmoInvItem',MaxLoot=5,Chance=200)
     LootableItems(11)=(ItemClass=Class'sonicRPG45.LGunAmmoInvItem',MaxLoot=5,Chance=200)
     LootableItems(12)=(ItemClass=Class'sonicRPG45.FlakAmmoInvItem',MaxLoot=5,Chance=200)
     LootableItems(13)=(ItemClass=Class'sonicRPG45.AssaultAmmoInvItem',MaxLoot=5,Chance=200)
     LootableItems(14)=(ItemClass=Class'sonicRPG45.AVRiLAmmoInvItem',MaxLoot=5,Chance=200)
     LootableItems(15)=(ItemClass=Class'sonicRPG45.BioAmmoInvItem',MaxLoot=5,Chance=200)
     LootableItems(16)=(ItemClass=Class'sonicRPG45.CSniperAmmoInvItem',MaxLoot=5,Chance=200)
     LootableItems(17)=(ItemClass=Class'sonicRPG45.DDamageInvItem',MaxLoot=3,Chance=20)
     LootableItems(18)=(ItemClass=Class'sonicRPG45.GrenadeAmmoInvItem',MaxLoot=5,Chance=200)
     LootableItems(19)=(ItemClass=Class'sonicRPG45.MineAmmoInvItem',MaxLoot=5,Chance=200)
     LootableItems(20)=(ItemClass=Class'sonicRPG45.MiniAmmoInvItem',MaxLoot=5,Chance=200)
     LootableItems(21)=(ItemClass=Class'sonicRPG45.LuckyWepInvItem',MaxLoot=3,Chance=10)
     LootableItems(22)=(ItemClass=Class'sonicRPG45.VampireWepInvItem',MaxLoot=3,Chance=10)
     LootableItems(23)=(ItemClass=Class'sonicRPG45.VorpalWepInvItem',MaxLoot=1,Chance=3)
     LootableItems(24)=(ItemClass=Class'sonicRPG45.InfiniteWepInvItem',MaxLoot=1,Chance=5)
     LootableItems(25)=(ItemClass=Class'sonicRPG45.FreezeWepInvItem',MaxLoot=3,Chance=10)
     LootableItems(26)=(ItemClass=Class'sonicRPG45.KnockbackWepInvItem',MaxLoot=3,Chance=10)
     LootableItems(27)=(ItemClass=Class'sonicRPG45.SpeedWepInvItem',MaxLoot=3,Chance=10)
     LootableItems(28)=(ItemClass=Class'sonicRPG45.NullWepInvItem',MaxLoot=3,Chance=10)
     LootableItems(29)=(ItemClass=Class'sonicRPG45.PiercingWepInvItem',MaxLoot=3,Chance=10)
     LootableItems(30)=(ItemClass=Class'sonicRPG45.PenetratingWepInvItem',MaxLoot=3,Chance=10)
     LootableItems(31)=(ItemClass=Class'sonicRPG45.ReflectWepInvItem',MaxLoot=3,Chance=10)
     LootableItems(32)=(ItemClass=Class'sonicRPG45.RageWepInvItem',MaxLoot=1,Chance=5)
     LootableItems(33)=(ItemClass=Class'sonicRPG45.PoisonWepInvItem',MaxLoot=3,Chance=10)
     LootableItems(34)=(ItemClass=Class'sonicRPG45.ProtectionWepInvItem',MaxLoot=3,Chance=10)
     LootableItems(35)=(ItemClass=Class'sonicRPG45.ForceWepInvItem',MaxLoot=3,Chance=10)
     LootableItems(36)=(ItemClass=Class'sonicRPG45.EnergyWepInvItem',MaxLoot=1,Chance=5)
     LootableItems(37)=(ItemClass=Class'sonicRPG45.SturdyWepInvItem',MaxLoot=3,Chance=10)
     LootableItems(38)=(ItemClass=Class'sonicRPG45.SpeedGizmoCreator',MaxLoot=1,Chance=1)
     LootableItems(39)=(ItemClass=Class'sonicRPG45.JumpGizmoCreator',MaxLoot=1,Chance=1)
     LootableItems(40)=(ItemClass=Class'sonicRPG45.GhostGizmoCreator',MaxLoot=1,Chance=1)
     LootableItems(41)=(ItemClass=Class'sonicRPG45.SwimGizmoCreator',MaxLoot=1,Chance=2)
     LootableItems(42)=(ItemClass=Class'sonicRPG45.TarydiumCrystal',MaxLoot=15,Chance=4000)
     LootableItems(43)=(ItemClass=Class'sonicRPG45.AdrenalineCreator',MaxLoot=1,Chance=50)
     LootableItems(44)=(ItemClass=Class'sonicRPG45.AdrenalineTwoCreator',MaxLoot=1,Chance=25)
     LootableItems(45)=(ItemClass=Class'sonicRPG45.AdrenalineThreeCreator',MaxLoot=1,Chance=10)
     LootableItems(46)=(ItemClass=Class'sonicRPG45.MiniHealthCreator',MaxLoot=1,Chance=50)
     LootableItems(47)=(ItemClass=Class'sonicRPG45.HealthCreator',MaxLoot=1,Chance=25)
     LootableItems(48)=(ItemClass=Class'sonicRPG45.SuperHealthCreator',MaxLoot=1,Chance=10)
     LootableItems(49)=(ItemClass=Class'sonicRPG45.AmmoGizmoCreator',MaxLoot=1,Chance=3)
     LootableItems(50)=(ItemClass=Class'sonicRPG45.MetaPupaeCreator',MaxLoot=1,Chance=400)
     LootableItems(51)=(ItemClass=Class'sonicRPG45.MetaRazorFlyCreator',MaxLoot=1,Chance=450)
     LootableItems(52)=(ItemClass=Class'sonicRPG45.MetaGasbagCreator',MaxLoot=1,Chance=400)
     LootableItems(53)=(ItemClass=Class'sonicRPG45.MetaKrallCreator',MaxLoot=1,Chance=350)
     LootableItems(54)=(ItemClass=Class'sonicRPG45.MetaKrallEliteCreator',MaxLoot=1,Chance=250)
     LootableItems(55)=(ItemClass=Class'sonicRPG45.MetaBruteCreator',MaxLoot=1,Chance=300)
     LootableItems(56)=(ItemClass=Class'sonicRPG45.MetaBehemothCreator',MaxLoot=1,Chance=150)
     LootableItems(57)=(ItemClass=Class'sonicRPG45.MetaWarLordCreator',MaxLoot=1,Chance=50)
     LootableItems(58)=(ItemClass=Class'sonicRPG45.MetaSkaarjCreator',MaxLoot=1,Chance=100)
     MaxCredits=100
}
