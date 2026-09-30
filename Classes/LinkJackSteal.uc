class LinkJackSteal extends Object;

static function bool IsStealEnabled(LinkFire Fire)
{
    local Mutator CurrentMutator;

    if (Fire == None || Fire.Level == None || Fire.Level.Game == None)
        return false;

    for (CurrentMutator = Fire.Level.Game.BaseMutator; CurrentMutator != None; CurrentMutator = CurrentMutator.NextMutator)
    {
        if (CurrentMutator.IsA('MutLinkJack'))
            return MutLinkJack(CurrentMutator).bEnableLinkSteal;
    }

    return false;
}

static function float GetStealDuration(LinkFire Fire)
{
    local Mutator CurrentMutator;

    if (Fire == None || Fire.Level == None || Fire.Level.Game == None)
        return 3.0;

    for (CurrentMutator = Fire.Level.Game.BaseMutator; CurrentMutator != None; CurrentMutator = CurrentMutator.NextMutator)
    {
        if (CurrentMutator.IsA('MutLinkJack'))
            return FClamp(MutLinkJack(CurrentMutator).LinkStealTime, 1.0, 3.0);
    }

    return 3.0;
}

static function bool IsStealableTarget(LinkFire Fire, Actor Other)
{
    return Fire != None && Other != Fire.Instigator && Pawn(Other) != None
        && Other.bProjTarget && Vehicle(Other) == None;
}

static function int ProcessSteal(LinkFire Fire, float DeltaTime, out Pawn StealTarget, out float StealTime, bool bHasStolen)
{
    local Weapon StolenWeapon;
    local Weapon StolenCopy;

    if (!IsStealEnabled(Fire))
    {
        StealTarget = None;
        StealTime = 0.0;
        return -1;
    }

    if (Fire.Instigator == None || Fire.Instigator.Role != ROLE_Authority || !Fire.bIsFiring
        || Fire.LockedPawn == None || Vehicle(Fire.LockedPawn) != None || Fire.Weapon == None)
    {
        StealTarget = None;
        StealTime = 0.0;
        return -1;
    }

    if (StealTarget != Fire.LockedPawn)
    {
        StealTarget = Fire.LockedPawn;
        StealTime = 0.0;
        return -1;
    }

    if (bHasStolen)
        return 1;

    StealTime += DeltaTime;
    if (StealTime < GetStealDuration(Fire))
        return 0;

    if (StealTarget.Weapon != None
        && !StealTarget.Weapon.IsA('LinkGun')
        && !StealTarget.Weapon.IsA('ImpactHammer')
        && !StealTarget.Weapon.IsA('ShieldGun'))
        StolenWeapon = StealTarget.Weapon;

    if (StolenWeapon != None)
    {
        StolenCopy = Fire.Weapon.Spawn(StolenWeapon.Class, Fire.Instigator);
        if (StolenCopy != None)
        {
            if (StealTarget.Weapon == StolenWeapon)
            {
                StealTarget.Weapon.StopFire(0);
                StealTarget.Weapon.StopFire(1);
            }

            StealTarget.DeleteInventory(StolenWeapon);
            if (StealTarget.Weapon == None && StealTarget.Controller != None)
                StealTarget.Controller.SwitchToBestWeapon();
            StolenCopy.GiveTo(Fire.Instigator);
            StolenWeapon.Destroy();
            if (StealTarget.Weapon != None && StealTarget.Controller != None)
                StealTarget.Controller.ClientSwitchToBestWeapon();
            Fire.Weapon.StopFire(Fire.ThisModeNum);
            return 1;
        }
    }
    else
    {
        Fire.Weapon.StopFire(Fire.ThisModeNum);
        return 1;
    }

    return 0;
}
