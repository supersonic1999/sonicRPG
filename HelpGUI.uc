class HelpGUI extends FloatingWindow;

var protected array<string> Content, Description;

var automated GUIButton CloseWindowButton;
var automated GUIScrollTextBox ItemDesc;

function OnOpen()
{
    local INVInventory INVInventory;
    local string ItemInformation;
    local int i;

   	INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    //Please dont change this. kthxbai.
    ItemInformation = "This is the official help faq for the inventory system made for UnrealInsanity.com servers and site.||You can buy credits and more pages from unrealinsanity.com for the unrealinsanity servers.||Credits:|Mysterial - making the RPG mutator that alot of the code was taken from.|Loplin - making a script that allows the inventory to connect to a remove database.|Joe_The_Monkey - making some images for the inventory including the class icons.|Sonic - for creating the inventory.|Testers - for helping test the inventory for bugs ect...";

    for(i=0;i<Content.length;i++)
        ItemInformation = (ItemInformation $ "||" $ class'GameInfo'.static.MakeColorCode(class'mutInventorySystem'.default.GreenColor) $ Content[i]
                        $ "|" $ class'GameInfo'.static.MakeColorCode(class'mutInventorySystem'.default.YellowColor) $ Description[i]);

    ItemDesc.SetContent(ItemInformation);
    if(INVInventory != None)
        INVInventory.bHelpOpen = true;
}

function OnClose(optional bool bCancelled)
{
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());
    if(INVInventory != none)
        INVInventory.bHelpOpen = false;
}

defaultproperties
{
     Content(0)="Q1. How do i bind a key to an item?"
     Content(1)="Q2. How do i use an item manually?"
     Content(2)="Q3. Do i keep my credits and items when i die or leave the server?"
     Content(3)="Q4. There are only 15 items, but ive heard about more, how can i get them?"
     Content(4)="Q5. Ive bought 7 different items from the shop but can only see 6, whats wrong?"
     Content(5)="Q6. How do i get credits?"
     Content(6)="Q7. I cant buy anything from the shop, why?"
     Content(7)="Q8. Ive found what i think is a bug, what shall i do?"
     Content(8)="Q9. How can i trade?"
     Content(9)="Q10. What can i trade?"
     Content(10)="Q11. How can i change the key that is pressed to accept a trade request?"
     Content(11)="Q12. How can i change the key that is pressed to open the inventory?"
     Content(12)="Q13. Why are there 2 options to get rid of items in my inventory?"
     Content(13)="Q14. An item in the shop hasnt restocked for ages, is it a bug or what?"
     Content(14)="Q15. How can i make items?"
     Content(15)="Q16. Is it possible to get rid of the Mission Tracker?"
     Content(16)="Q17. How can i rebind the key i have to hold to use the selected items 1-9?"
     Content(17)="Q18. How can i hide or show the class icons?"
     Content(18)="Q19. How can i hide or show the how key tray?"
     Description(0)="A1. To bind a key to use an item in the inventory do this command in the console: 'set input keyhere InvItem1' without the ' ', this command will use the item in slot 1 when you press the key you have bound it to, change the last number to change the item it will use."
     Description(1)="A2. To use an item manually first open the inventory menu then right click on the item you want to use and choose: Use , this will do what ever this item is meant to do and decrease how many you have by one if it worked."
     Description(2)="A3. Yes you do keep all your items and credits if you leave the server or die due to the automatic saving of them to a log file, which means that you could leave the server with 5000 credits and come back 5 months later and they would still be there unless the server admin had deleted them."
     Description(3)="A4. To see all the other items the shop has to offer, first open up the shop, then click the next of back buttons which will scroll you through the pages of the shop which keeps other items in, all these items work the same way in buying them as others and the writing near the top of the screen shows what page you are on."
     Description(4)="A5. It works the same way as the shop does to store other items on different pages, just click the next and prev button in the inventory to scroll through each page."
     Description(5)="A6. To get credits you must either damage a live player or tank or damage an AI (Monster, Bot ect...), the credits you get are based on the amount of damage that you do."
     Description(6)="A7. Some of the reasons why you cant buy are that you havent got enough credits to buy that item (The cost can be see by highlighting the mouse over the item you want, left clicking on the item or going into its information.) or you arent right clicking on the item and selecting one of the 3 buy options because left click just tells you what items it is and the price."
     Description(7)="A8. If you think you have found a bug either tell an admin, send an e-mail to Admin@UnrealInsanity.com or post on our forums at UnrealInsanity.com"
     Description(8)="A9. To trade you must first switch to the trader gun (default key is 0, which may need to be pressed more than once) then aim on a person by right clicking on them and to send them a request you must press left click, once that is done a trade request will be sent to them and if they accept it will open the trade menu."
     Description(9)="A10. You can trade inventory credits and items, but some items cant be traded."
     Description(10)="A11. To change the key to accept a trade offer you need to type: 'set input keyhere TradeMenu' in the console without the ' '."
     Description(11)="A12. Typing: 'set input keyhere InventoryMenu' in the console without the ' ' will change the key that opens the inventory to the key you specified."
     Description(12)="A13. There are 2 options to get rid of items, sell and destroy, the reason for that is that some items you will not be able to sell so you must either trade them to someone or destroy them."
     Description(13)="A14. Each item has its own individual restock time spanning from minutes to days, depending on the item. So if the item isnt in stock it might be worth buying it off of someone that already has it."
     Description(14)="A15. To make an item you first need to gather a few items, you need a item creator for the item you want to make and the crystals that are needed to create it(it says how many in the item), you also have to bare in mind that you need the right amount of creation points to make the item, if you havent got enough you cant make it. Once you have these things all you have to do is use the creator and it will take the crystals and turn them into the item you are making. (Crystals + Creator = Item - Crystals)"
     Description(15)="A16. Yes, just type 'ToggleMissionTracker' in the console or just cancel or complete your current mission since it will automatically dissapear if you have no mission active."
     Description(16)="A17. Type 'set input keyhere ItemHoldKey' in the console, replace keyhere with the key you want and remove the ''."
     Description(17)="A18. To hide or show the class icons on screen type: 'ToggleClassIcons' in the console."
     Description(18)="A19. To hide or show the hot key tray on screen type: 'ToggleHotKeyTray' in the console."
     Begin Object Class=GUIButton Name=CloseButton
         Caption="Close"
         WinTop=0.850000
         WinLeft=0.050000
         WinWidth=0.900000
         WinHeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=HelpGUI.XButtonClicked
         OnKeyEvent=CloseButton.InternalOnKeyEvent
     End Object
     CloseWindowButton=GUIButton'sonicRPG45.HelpGUI.CloseButton'

     Begin Object Class=GUIScrollTextBox Name=ItemDescription
         CharDelay=0.002500
         EOLDelay=0.500000
         OnCreateComponent=ItemDescription.InternalOnCreateComponent
         WinTop=0.100000
         WinLeft=0.050000
         WinWidth=0.900000
         WinHeight=0.700000
         bTabStop=False
         bNeverFocus=True
     End Object
     ItemDesc=GUIScrollTextBox'sonicRPG45.HelpGUI.ItemDescription'

     WindowName="Inventory Help Menu"
     bResizeWidthAllowed=False
     bResizeHeightAllowed=False
     DefaultLeft=0.350000
     DefaultTop=0.000000
     DefaultWidth=0.500000
     DefaultHeight=0.500000
     bAllowedAsLast=True
     WinTop=0.000000
     WinLeft=0.350000
     WinWidth=0.500000
}
