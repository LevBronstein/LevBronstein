/**
 *  LBBlendByAngSpeed
 *
 *  Creation date: 05.04.2016 20:54
 *  Copyright 2016, Windows7
 */
class LBBlendByAngSpeed extends AnimNodeBlendList;

var LbPawn p; 
var() float Accuracy;

var(Animation) float BlendTime;

function UpdateAngSpeed(float s)
{
    if (p!=none)
    {
        if (abs(s)>abs(Accuracy))
        {
            if (s<0)
                SetActiveChild(0, BlendTime);    
            else
                SetActiveChild(2, BlendTime);
        }
        else
        {
            SetActiveChild(1, BlendTime);     
        }
    }
    //`log("LBBlendByAngSpeed: s="@s);
}

event OnBecomeRelevant()
{
    if (LbPawn(SkelComponent.Owner) != none)
        p=LbPawn(SkelComponent.Owner);
    else
        p=none;
}    

defaultproperties
{
    bCallScriptEventOnBecomeRelevant = true
   
    CategoryDesc="LevBronstein"
    
    Children(0)=(Name="PositiveAngularSpeed")
    Children(1)=(Name="ZeroAngularSpeed")
    Children(2)=(Name="NegativeAngularSpeed")
    
    BlendTime=0.25
    
    Accuracy=0.8
}
