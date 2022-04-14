class LiquidTarydium extends MainInventoryItem;

static function bool ServerLeftClick(Controller Other, int x);

defaultproperties
{
     Image=Texture'SonicRPGTEX46.Inventory.LiquidTarydium1'
     Description="This item was once a solid Tarydium Crystal but has been refined to liquid to make it more valuable and more usefull.."
     ItemName="Liquid Tarydium"
     BuyPrice=-25
     SellPrice=5
     bIsUsable=False
}
