class MutLinkJack extends Mutator
    config(LinkJack);

var() config float LinkStealTime;
var() config bool bEnableLinkSteal;
var localized string LinkStealTimeText;
var localized string LinkStealTimeDesc;
var localized string EnableLinkStealText;
var localized string EnableLinkStealDesc;
var string LinkGunClassName;
var string LinkGunPickupClassName;
var bool bWSUTBridgeActive;

function PreBeginPlay()
{
    StaticSaveConfig();
    InitializeWSUTBridge();
    Super.PreBeginPlay();
}

function Mutator FindWSUTMutator()
{
    local Mutator CurrentMutator;

    if (Level == None || Level.Game == None)
        return None;

    for (CurrentMutator = Level.Game.BaseMutator; CurrentMutator != None; CurrentMutator = CurrentMutator.NextMutator)
        if (InStr(Caps(string(CurrentMutator.Class)), ".MUTUTCOMP") != -1)
            return CurrentMutator;

    return None;
}

function InitializeWSUTBridge()
{
    local Mutator WSUTMutator;
    local class<Actor> BridgeHelperClass;
    local Actor BridgeHelper;
    local string BridgeWeaponName;
    local string BridgePickupName;
    local bool bUseEnhancedNetCode;

    LinkGunClassName = "LinkJack.LinkJackLinkGun";
    LinkGunPickupClassName = "LinkJack.LinkJackLinkGunPickup";
    bWSUTBridgeActive = false;

    WSUTMutator = FindWSUTMutator();
    if (WSUTMutator == None)
        return;

    bUseEnhancedNetCode = WSUTMutator.GetPropertyText("bEnableEnhancedNetCode") ~= "True";
    if (bUseEnhancedNetCode)
    {
        BridgeWeaponName = "LinkJack.LinkJackNewNetLinkGun";
        BridgePickupName = "LinkJack.LinkJackNewNetLinkGunPickup";
    }
    else
    {
        BridgeWeaponName = "LinkJack.LinkJackUTCompLinkGun";
        BridgePickupName = "LinkJack.LinkJackUTCompLinkGunPickup";
    }

    BridgeHelperClass = class<Actor>(DynamicLoadObject("LinkJack.LinkJackWSUTBridge", class'Class', true));
    if (BridgeHelperClass == None)
    {
        Log("LinkJack: WSUT detected but the unified bridge classes are unavailable.");
        return;
    }

    BridgeHelper = Spawn(BridgeHelperClass);
    if (BridgeHelper == None)
    {
        Log("LinkJack: WSUT detected but the unified mapping helper could not be spawned.");
        return;
    }

    LinkGunClassName = BridgeWeaponName;
    LinkGunPickupClassName = BridgePickupName;
    bWSUTBridgeActive = true;
    Log("LinkJack: WSUT LinkGun netcode bridge enabled.");
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
    Super.FillPlayInfo(PlayInfo);
    PlayInfo.AddSetting(default.RulesGroup, "LinkStealTime", default.LinkStealTimeText, 0, 1, "Text", "8;1:3");
    PlayInfo.AddSetting(default.RulesGroup, "bEnableLinkSteal", default.EnableLinkStealText, 0, 2, "Check");
}

static event string GetDescriptionText(string PropName)
{
    if (PropName == "LinkStealTime")
        return default.LinkStealTimeDesc;

    if (PropName == "bEnableLinkSteal")
        return default.EnableLinkStealDesc;

    return Super.GetDescriptionText(PropName);
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if (Other.Class == class'LinkGun')
    {
        ReplaceWith(Other, LinkGunClassName);
        return false;
    }

    if (Other.Class == class'LinkGunPickup')
    {
        ReplaceWith(Other, LinkGunPickupClassName);
        return false;
    }

    return true;
}

function string GetInventoryClassOverride(string InventoryClassName)
{
    if (InventoryClassName ~= "XWeapons.LinkGun")
        return LinkGunClassName;

    return Super.GetInventoryClassOverride(InventoryClassName);
}

defaultproperties
{
    LinkStealTime=1.000000
    bEnableLinkSteal=True
    LinkStealTimeText="Link Steal Time"
    LinkStealTimeDesc="Seconds the Link Gun beam must stay on a player before stealing a weapon."
    EnableLinkStealText="Enable Link Gun Stealing"
    EnableLinkStealDesc="Allow the Link Gun beam to steal one weapon after holding it on a player for the configured duration."
    GroupName="LinkJack"
    FriendlyName="LinkJack"
    Description="Adds Link Gun weapon stealing."
    bAddToServerPackages=True
}
