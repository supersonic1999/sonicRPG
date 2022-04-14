class GhostGizmoInvItem extends GizmoInvItem;

static simulated function PostRender(Controller Other, Canvas Canvas)
{
    local GhostGizINV Inv;
    local Font TextFont;
    local string Text;
    local float XL, YL;

    if(Other == none || Other.Pawn == none)
        return;

	Inv = GhostGizINV(FindClassINV(Other));
	if(Inv == none || Inv.RepTimeSeconds >= (Inv.LastUseTime + Inv.RechargeTime))
	    return;

    if(Inv.RepTimeSeconds < (Inv.LastUseTime + Inv.StayGhostedTime))
        Text = ((Inv.LastUseTime + Inv.StayGhostedTime) - Inv.RepTimeSeconds) @ "seconds until disabled.";
    else
        Text = ((Inv.LastUseTime + Inv.RechargeTime) - Inv.RepTimeSeconds) @ "seconds until avaliable.";

    TextFont = Font(DynamicLoadObject("UT2003Fonts.jFontSmall", class'Font'));
    if(TextFont != None)
        Canvas.Font = TextFont;

    Canvas.FontScaleX = Canvas.ClipX / 1024.f;
	Canvas.FontScaleY = Canvas.ClipY / 768.f;
    XL = FMax(XL + 9.f * Canvas.FontScaleX, 135.f * Canvas.FontScaleX);
	Canvas.DrawColor = class'mutInventorySystem'.default.WhiteColor;
    Canvas.TextSize(Text, XL, YL);
    Canvas.SetPos(0, Canvas.ClipY * 0.3 - YL);
    Canvas.DrawText(Text);
}

static function ActivateMessage(Controller Other, int i)
{
    local GhostGizINV Inv;

    if(Other == none || Other.Pawn == none)
        return;

	Inv = GhostGizINV(FindClassINV(Other));
    if(Inv != none)
    {
        if(bEnabled(Other) && Inv.RepTimeSeconds >= (Inv.LastUseTime + Inv.StayGhostedTime))
            Other.Pawn.ClientMessage("You cant turn this item on for another" @ (Inv.LastUseTime + Inv.RechargeTime)-Inv.RepTimeSeconds @ "seconds.");
        else if(bEnabled(Other))
            Other.Pawn.ClientMessage(GetInvItemName(Other) @ "deactivated");
        else
            Other.Pawn.ClientMessage(GetInvItemName(Other) @ "activated");
    }
}

static simulated function string GetDescription(Controller Other)
{
    if(default.GizmoINV != none && class<GhostGizINV>(default.GizmoINV) != none)
    {
        return (default.Description @ "||This gizmo gives you ghost like properties when turned on, you cant be hit at all but it only lasts for"
             @ class<GhostGizINV>(default.GizmoINV).default.StayGhostedTime @ "seconds and must recharge after each use for"
             @ (class<GhostGizINV>(default.GizmoINV).default.RechargeTime - class<GhostGizINV>(default.GizmoINV).default.StayGhostedTime)
             @ "seconds.");
    }
    return default.Description;
}

static simulated function bool bEnabled(Controller Other)
{
	local GhostGizINV Inv;

    if(Other == none || Other.Pawn == none)
        return false;

    Inv = GhostGizINV(FindClassINV(Other));
    if(Inv != none && (Inv.bEnabled
    || Inv.RepTimeSeconds >= (Inv.LastUseTime + Inv.StayGhostedTime)
    && Inv.RepTimeSeconds < (Inv.LastUseTime + Inv.RechargeTime)))
	    return True;
    return false;
}

defaultproperties
{
     GizmoINV=Class'sonicRPG45.GhostGizINV'
     ItemName="Ghost Gizmo"
     bPostRender=True
}
