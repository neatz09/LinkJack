class LinkJackLinkFire extends LinkFire;

var Pawn StealTarget;
var float StealTime;
var bool bHasStolen;

simulated function ModeTick(float DeltaTime)
{
    local int StealResult;

    Super.ModeTick(DeltaTime);
    StealResult = class'LinkJackSteal'.static.ProcessSteal(self, DeltaTime, StealTarget, StealTime, bHasStolen);
    if (StealResult < 0)
        bHasStolen = false;
    else if (StealResult > 0)
        bHasStolen = true;
}

function bool IsLinkable(Actor Other)
{
    if (!class'LinkJackSteal'.static.IsStealEnabled(self))
        return Super.IsLinkable(Other);

    return class'LinkJackSteal'.static.IsStealableTarget(self, Other);
}

defaultproperties
{
}
