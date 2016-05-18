/**
 *  LBActorController
 *
 *  Creation date: 15.05.2016 22:11
 *  Copyright 2016, Windows7
 */
class LBActorController extends LBMechanism;

struct NamedParam
{
    var() name ParamName; //The name of this parameter
    var() float ParamValue; //Current value of this parameter
    var() float ParamDefaultValue; //The default value of this parameter
    var() bool bClampValue; //Set to true, if the value shoul be always between Min and Max 
    var() float ValueMin;
    var() float ValueMax;
};

//fixed size in editor
var(Params) array<NamedParam> CurParamValues;

function float GetParamFloat(name param)
{
    local int i;
        
    for (i=0; i<CurParamValues.Length; i++)
    {
        if (CurParamValues[i].ParamName==param)
            return CurParamValues[i].ParamValue; 
    }
    
    LogError("Parameter name ("@param@") was not found!"); 
    return 0;   
}  

function SetParamFloat(name param, float value)
{
    local int i;
    
    for (i=0; i<CurParamValues.Length; i++)
    {
        if (CurParamValues[i].ParamName==param)
        {
            if (CurParamValues[i].bClampValue)
            {
                //А что, если значение, выходящее за пределы будет задано из редактора и не будет проверено в SetParamFloat?
                CurParamValues[i].ParamValue=fclamp(value, CurParamValues[i].ValueMin, CurParamValues[i].ValueMax);
            }
            else
                CurParamValues[i].ParamValue=value; 
            return;
        }
    }
    
    LogError("Parameter name ("@param@") was not found!");
}

defaultproperties
{
}
