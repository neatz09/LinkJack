class LinkJackWSUTBridge extends Info;

function Mutator FindWSUTMutator()
{
    local Mutator CurrentMutator;

    if (Level == None || Level.Game == None)
        return None;

    for (CurrentMutator = Level.Game.BaseMutator; CurrentMutator != None; CurrentMutator = CurrentMutator.NextMutator)
        if (MutUTComp(CurrentMutator) != None)
            return CurrentMutator;

    return None;
}

event PostBeginPlay()
{
    local MutUTComp WSUTMutator;

    Super.PostBeginPlay();
    WSUTMutator = MutUTComp(FindWSUTMutator());
    if (WSUTMutator == None)
    {
        Log("LinkJack: WSUT mapping helper could not find MutUTComp.");
        return;
    }

    if (WSUTMutator.bEnableEnhancedNetCode)
    {
        WSUTMutator.WeaponClasses[1] = class'LinkJackNewNetLinkGun';
        WSUTMutator.WeaponClassNames[1] = "LinkJackWSUT.LinkJackNewNetLinkGun";
        WSUTMutator.WeaponPickupClasses[1] = class'LinkJackNewNetLinkGunPickup';
        WSUTMutator.WeaponPickupClassNames[1] = "LinkJackWSUT.LinkJackNewNetLinkGunPickup";
        Log("LinkJack: WSUT NewNet LinkGun=" $ string(WSUTMutator.WeaponClasses[1]) $ " Pickup=" $ string(WSUTMutator.WeaponPickupClasses[1]));
    }
    else
    {
        WSUTMutator.WeaponClassesUTComp[1] = class'LinkJackUTCompLinkGun';
        WSUTMutator.WeaponClassNamesUTComp[1] = "LinkJackWSUT.LinkJackUTCompLinkGun";
        WSUTMutator.WeaponPickupClassesUTComp[1] = class'LinkJackUTCompLinkGunPickup';
        WSUTMutator.WeaponPickupClassNamesUTComp[1] = "LinkJackWSUT.LinkJackUTCompLinkGunPickup";
        Log("LinkJack: WSUT UTComp LinkGun=" $ string(WSUTMutator.WeaponClassesUTComp[1]) $ " Pickup=" $ string(WSUTMutator.WeaponPickupClassesUTComp[1]));
    }
}

defaultproperties
{
    RemoteRole=ROLE_None
}