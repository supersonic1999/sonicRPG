class TarydiumCrystal extends MainInventoryItem;

static function bool ServerLeftClick(Controller Other, int x);

defaultproperties
{
     Image=Texture'SonicRPGTEX46.Inventory.TarydiumCrystals'
     Description="A green Tarydium Crystal. This item can be used to make items."
     ItemName="Tarydium Crystal"
     BuyPrice=-20
     SellPrice=5
     bIsUsable=False
}
