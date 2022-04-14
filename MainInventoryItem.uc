class MainInventoryItem extends Object;

#exec OBJ LOAD FILE=UCGeneric.utx

var Material Image; //This is the image that is displayed.
var protected class<ClassFile> ClassRequired; //Class required to use this item.
var protected string Description, ItemName; //This is the description of the item, that appears in the information of the item.
var protected int RequiredSkillLevel, RequiredSkillNum;
var int BuyPrice, SellPrice, ShopAmount, ItemRestockTime, ItemRemoveTime;
//0=common
//1=uncommon
//2=unique
//3=rare
//4=epic
//5=legendary
var byte ItemType;
var float ItemUseDelay;
var bool bSellable, bTradable, bDeletable, bPostRender, bIsUsable, bNotifyCantUseYet;
var localized string WrongClassString, SkillIsntHighEnough, CantUseItemYet;

static function ActivateMessage(Controller Other, int i);

static function ModifyPlayer(Controller Other);

static function DeletedItem(Controller Other);

static function OwnerDied(Controller Killer, Controller Killed);

static simulated function PostRender(Controller Other, Canvas Canvas);

static simulated function bool bEnabled(Controller Other);

//This is what happens when you click the item in the inventory.
static simulated function bool OnClick(Controller Other, int x)
{
    local INVInventory INVInventory;

    if(!bAllowUse(Other))
        return false;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory != none)
        return INVInventory.ServerLeftClick(Other, x);
    return false;
}

static simulated function DrawImage(Controller Other, Canvas C, float T, float L, float H, float W)
{
    local color BeforeColor;

    if(Other == none || C == none)
        return;

    BeforeColor = C.DrawColor;
    if(!bAllowUse(Other, true))
        C.SetDrawColor(50,50,50);
    C.SetPos(L, T);
    C.DrawRect(Texture(default.Image), W, H);
    C.DrawColor = BeforeColor;
}

static simulated function array<string> GetImageContextArray(Controller Other, class<MainInventoryItem> Item)
{
    local array<string> ContextItems;

    if(Item == none)
        return ContextItems;

    if(Item.default.bIsUsable)
    {
        ContextItems[ContextItems.length] = "Use";
        ContextItems[ContextItems.length] = "Select Item";
    }
    ContextItems[ContextItems.length] = "Delete";
    if(Item.default.bSellable)
        ContextItems[ContextItems.length] = "Sell";
	ContextItems[ContextItems.length] = "Information";
    return ContextItems;
}

static simulated function ImageContextClick(Controller Other, class<MainInventoryItem> Item, string ContextString)
{
    local INVInventory INVInventory;
    local int i, x;
    local bool bValidItem;

    if(Item == none || Other == none)
        return;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory == none)
        return;

    for(i=0;i<INVInventory.DataRep.Items.Length;i++)
    {
        if(INVInventory.DataRep.Items[i] == Item)
        {
            x = i;
            break;
        }
    }

    if(Item.default.bIsUsable && ContextString == "Use")
        Item.Static.OnClick(Other, x);
    else if(Item.default.bIsUsable && ContextString == "Select Item")
    {
        for(i=0;i<ArrayCount(INVInventory.SelectedItems);i++)
        {
            for(x=0;x<INVInventory.DataRep.Items.Length;x++)
            {
                if(INVInventory.SelectedItems[i] == INVInventory.DataRep.Items[x])
                {
                    bValidItem = true;
                    x = INVInventory.DataRep.Items.length;
                }
            }
            if(!bValidItem)
                INVInventory.SelectedItems[i] = none;
            bValidItem = false;
            if(INVInventory.SelectedItems[i] == none)
            {
                INVInventory.SelectedItems[i] = Item;
                INVInventory.default.SelectedItems[i] = Item;
                break;
            }
        }
        INVInventory.StaticSaveConfig();
    }
    else if(Item.default.bDeletable && ContextString == "Delete")
    {
        INVInventory.DeleteNum = x;
        INVInventory.RemoveInventoryItem = true;
        if(!INVInventory.bDeleteOpen)
            PlayerController(Other).ClientOpenMenu("SonicRPG45.DeleteGUI");
    }
    else if(Item.default.bSellable && ContextString == "Sell")
    {
        INVInventory.XItemNum = x;
        INVInventory.bSellAmount = true;
        if(!INVInventory.bAmountOpen)
            PlayerController(Other).ClientOpenMenu("SonicRPG45.AmountGUI");
    }
    else if(ContextString == "Information")
    {
        INVInventory.InfoClass = Item;
        if(!INVInventory.bInformationOpen)
            PlayerController(Other).ClientOpenMenu("SonicRPG45.InformationGUI");
        else if(INVInventory.Information != none)
            INVInventory.Information.OnOpen();
    }
}

static simulated function int GetBuyPrice(Controller Other)
{
    return default.BuyPrice;
}

static simulated function int GetSellPrice(Controller Other)
{
    return default.SellPrice;
}

static simulated function bool bAllowUse(Controller Other, optional bool bImageRender)
{
    local INVInventory INVInventory;
    local int i;
    local class<ClassFile> myClass;

    if(!default.bIsUsable || Other == none)
        return false;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory == none)
        return false;
    else if(default.ClassRequired != none)
    {
        if(Other.Role == Role_Authority && INVInventory.DataObject != none)
            myClass = INVInventory.DataObject.CharClass;
        else if(INVInventory.DataObject == none)
            myClass = INVInventory.DataRep.CharClass;
        if(myClass == none || myClass != default.ClassRequired)
        {
            if(PlayerController(Other) != none && !bImageRender)
                PlayerController(Other).ClientMessage(default.WrongClassString);
            return false;
        }
    }
    if(default.RequiredSkillNum != 999)
    {
        if(Other.Role == Role_Authority && INVInventory.DataObject != none
        && INVInventory.DataObject.SkillLevel[default.RequiredSkillNum] < default.RequiredSkillLevel)
            i = 999;
        else if(INVInventory.DataObject == none && INVInventory.DataRep.SkillLevel[default.RequiredSkillNum] < default.RequiredSkillLevel)
            i = 999;
        if(i == 999)
        {
            if(PlayerController(Other) != none && !bImageRender)
                PlayerController(Other).ClientMessage(default.SkillIsntHighEnough);
            return false;
        }
    }


    for(i=0;i<INVInventory.ItemDelay.length;i++)
    {
        if(INVInventory.ItemDelay[i].LastItemClass == default.class
        && INVInventory.Level.TimeSeconds < INVInventory.ItemDelay[i].LastUsed+default.ItemUseDelay)
        {
            if(PlayerController(Other) != none && default.bNotifyCantUseYet && !bImageRender)
                PlayerController(Other).ClientMessage(default.CantUseItemYet);
            return false;
        }
    }
    return true;
}

static simulated function bool bAllowShopUse(Controller Other)
{
    return True;
}

static simulated function string GetInvItemName(Controller Other)
{
    return default.ItemName;
}

static simulated function string GetDescription(Controller Other)
{
    return default.Description;
}

static simulated function string GetItemInformation(Controller Other)
{
    local string Text;

    Text = ("Buy Price:" @ int(abs(default.BuyPrice)) @ "|"
         $ "Sell Price:" @ default.SellPrice @ "|"
         $ "Use Delay:" @ default.ItemUseDelay @ "|"
         $ "Sellable:" @ default.bSellable @ "|"
         $ "Tradable:" @ default.bTradable);
    if(default.ClassRequired != none)
        Text = (Text @ "|" $ "Class Needed:" @ default.ClassRequired.default.ClassName);
    if(default.RequiredSkillNum != 999)
        Text = (Text @ "|" $ "Skill Need:" @ default.RequiredSkillLevel);
    return Text;
}

//This is what happens when you click on an item in the shop.
static simulated function bool ShopClick(Controller Other, int x, int Amount)
{
    local INVInventory INVInventory;

    if(Other == none || !bAllowShopUse(Other))
        return false;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory != none && INVInventory.MutINV != none
    && INVInventory.MutINV.BuyableItems.length > x)
    {
        INVInventory.ChangeItem(INVInventory.MutINV.BuyableItems[x].ItemClass, Amount);
        return true;
    }
    return false;
}

//This is the function that is called when you click on an item in the inventory. This is called on the server.
static function bool ServerLeftClick(Controller Other, int x)
{
    local INVInventory INVInventory;
    local int i;
    local bool bAlreadyUsed;

    if(Other == none || !bAllowUse(Other))
        return false;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(Other);
    if(INVInventory != none && INVInventory.DataObject != none)
	{
        ActivateMessage(Other, x);
        for(i=0;i<INVInventory.ItemDelay.length;i++)
        {
            if(INVInventory.ItemDelay[i].LastItemClass == default.class)
            {
                INVInventory.ItemDelay[i].LastUsed = INVInventory.Level.TimeSeconds;
                bAlreadyUsed = true;
                break;
            }
        }
        if(!bAlreadyUsed)
        {
            INVInventory.ItemDelay.Insert(INVInventory.ItemDelay.length, 1);
            INVInventory.ItemDelay[INVInventory.ItemDelay.length-1].LastItemClass = default.class;
            INVInventory.ItemDelay[INVInventory.ItemDelay.length-1].LastUsed = INVInventory.Level.TimeSeconds;
        }
        INVInventory.ChangeItem(INVInventory.DataObject.Items[x], -1);
        return true;
 	}
    return false;
}

defaultproperties
{
     Image=Texture'SonicRPGTEX46.Inventory.LinkAmmo'
     Description="This is an item for the inventory that can be used for some purpose."
     ItemName="Inventory Item"
     RequiredSkillNum=999
     ShopAmount=10
     ItemRestockTime=60
     ItemRemoveTime=60
     ItemType=1
     ItemUseDelay=1.000000
     bSellable=True
     bTradable=True
     bDeletable=True
     bIsUsable=True
     WrongClassString="You arent the right class to use this item."
     SkillIsntHighEnough="Your skill isnt high enough to use this item."
     CantUseItemYet="You cant use this item yet, please wait."
}
