/**
 *  LBParamInterpolator
 *
 *  Creation date: 30.03.2016 23:00
 *  Copyright 2016, Windows7
 */
class LBParamInterpolator extends LBMechanism;

struct PhaseParameter
{
    var() float PhaseValue;
    var() float PhaseLength;
};

struct ParameterFrame
{
        //CONSTANT!!!
    var() name ParameterName; //the name of the parameter
    var() array<PhaseParameter> KeyFrames; //array of phase parameters to be used as keyframes
    var() bool bDiscrete;
};

enum Time_Control
{
    RESET_ON_OVER,
    REVERSE_ON_OVER,
    STOP_ON_OVER
};

enum Time_Loop
{
    INFINITE,
    BETWEEN_T0_T1
};

enum Playback_Status
{
    PLAYBACK_ONTICK,
    PLAYBACK_MANUAL,
    PLAYBACK_PAUSE
};

var float t;
var(Timeline) float t0;
var(Timeline) float t1;
var(Timeline) float dt;
var(Playback) Playback_Status Playback; //current playback status
var(Playback) Time_Loop TimeFlow; // do we need to limit time between t0 and t1
var(Playback) Time_Control TimeManager; // what to do after timer reaches t1
var(ParamFrames) array<ParameterFrame> Params;
var array<float> CurParamValues;

function float CalcParamInTime(int param, float t)
{
    local int i;
    local int lastkey;
    local float ct;
    local float tt;
    local float res;
    
    if (Params.Length==0 ||Params[param].KeyFrames.Length==0)
        return 0; //когда что-то пошло не так
        
    ct=0;//Params[param].KeyFrames[0].PhaseLength;    
    lastkey=0;
    
    //нулевой phasevalue - значение по умолчанию, начинаем с первого
    //определяем промежуток времени, а по нему и необходимый параметр
    for (i=0; i<Params[param].KeyFrames.Length; i++)
    {
        ct=ct+Params[param].KeyFrames[i].PhaseLength;
     
        if (t<=ct)
        {
            lastkey=i+1; //firstcommand=i-1
            break;
        }     
    }
    
    //иначе переходит из состояния lastkey-1 в состояние lastkey
    //расстояние между lastkey-1 и lastkey равняется KeyFrames[lastkey-1].PhaseLength 
    //итого получаем процент отдаления от lastkey-1 к lastkey   
    tt=min(abs(t-ct), Params[param].KeyFrames[lastkey-1].PhaseLength);
    tt=1-(tt/Params[param].KeyFrames[lastkey-1].PhaseLength); //что, если PhaseLength=0?
    
    //если фазовый параметр в lastkey не является дискретным, то применяется интерполяция
    if(!Params[param].bDiscrete)
    {
        if (lastkey>=Params[param].KeyFrames.Length)
            res=Params[param].KeyFrames[Params[param].KeyFrames.Length-1].PhaseValue;
        else
            res=lerp(Params[param].KeyFrames[lastkey-1].PhaseValue, Params[param].KeyFrames[lastkey].PhaseValue, tt);
    }
    else
    {
        res=Params[param].KeyFrames[lastkey-1].PhaseValue;
    }

    CurParamValues[param]=res;
    return res;
}

function Initialize()
{
    CurParamValues.Length=Params.Length;
}

function FirstTickInit()
{
    super.FirstTickInit();
    
    Initialize();
}

event OwnerTick(float deltatime)
{
    FirstTickInit();
    if(benabled==false)
        return;
    
    if (Playback==PLAYBACK_ONTICK)
    { 
        Play(); 
    }  
  
    //`log("TestParam"@GetParamFloat('TestParam'));
}

function Play()
{
    PlayCurFrame();   
    IncreaseTime();     
}

//Plays even frame, just sets t equal to the parameter
function PlayFrame(float time)
{
   t=time;
   PlayCurFrame();  
}

function IncreaseTime()
{
    t=t+dt; 
    
    if (TimeManager==RESET_ON_OVER)
    {
        if (TimeFlow==BETWEEN_T0_T1)
        {
            if (t>t1)
            {
                 ResetTime();    
            }            
        }
        
    }
    else if (TimeManager==RESET_ON_OVER)
    {
        if (TimeFlow==BETWEEN_T0_T1)
        {
            if (t>t1 || t<t0)
            {
                ReverseTimeStep();  
            }            
        }    
    }
}

function DecreaseTime()
{
    t=t-dt;   
}

function ResetTime()
{
    t=t0;   
    dt=abs(dt);
}

function ReverseTimeStep()
{
    dt=-dt;
}

function PlayCurFrame()
{
    local int i;
    
    for(i=0;i<Params.Length;i++)
    {
        CalcParamInTime(i, t);  
    }
}

function SetParamFloat(name param, float value, optional int priority=0)
{
    
}    

function float GetParamFloat(name param)
{
    local int i;
    
    for (i=0; i<Params.Length; i++)
    {
        if (Params[i].ParameterName==param)
            return CurParamValues[i]; 
    }
}     
    
defaultproperties
{
}
