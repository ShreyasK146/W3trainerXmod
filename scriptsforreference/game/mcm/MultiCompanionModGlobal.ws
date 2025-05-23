/*
Contains all globally accessible functions, excluding executable functions.
*/

enum ESCMSelectionType
{
	ST_Normal,
	ST_Special,
	ST_Both,
};

function MCM_GetAreaName() : EAreaName
{
    return theGame.GetCommonMapManager().GetCurrentArea();
}

function MCM_GameTimeSeconds() : int
{
    var gt : GameTime;
    gt = theGame.GetGameTime();
    return GameTimeSeconds(gt) + GameTimeMinutes(gt)*60 + GameTimeHours(gt)*3600;
}

function MCM_AreaToName(area : EAreaName) : String
{
    switch(area) {
        case AN_Prologue_Village: return "White Orchard";
        case AN_Wyzima: return "Royal Palace in Vizima";
        case AN_Velen: return "Velen";
        case AN_NMLandNovigrad: return "Velen | Oxenfurt | Novigrad";
        case AN_Skellige_ArdSkellig: return "The Skellige Isles";
        case AN_Kaer_Morhen: return "Kaer Morhen";
        case AN_Island_of_Myst: return "Island of Mists";
        case AN_Spiral: return "Spiral";
        case AN_Prologue_Village_Winter: return "Winter Village";
        case AN_CombatTestLevel: return "Test Level";
        case 11: return "The Duchy of Toussaint";
    }
    return "Undefined";
}

function MCM_NicifyName(nam : name) : name
{
    return MCM_GetMCM().nicifyName(nam);
}

function GetClosestActor() : CActor
{
	var actor : CActor;
	var actors : array<CActor>;
	var minDistance : float;
	var distance : float;
	var i : int;

	actors = GetActorsInRange( thePlayer, 1000, 99);
	
	if( actors.Size() )
	{
		for( i = 0; i < actors.Size(); i += 1 )
		{
			distance = VecDistance( actors[i].GetWorldPosition(), thePlayer.GetWorldPosition() );
			
			if( distance < minDistance || !minDistance )
			{
				minDistance = distance;
				actor = actors[i];
			}
		}
	}
	
	return actor;
}

struct MCM_SFactCheck
{
	var factName : name;
	var operator : EOperator;
	var value : int;
}

function MCM_CheckFact(fact : MCM_SFactCheck) : bool
{
	var value : int;
	var result : bool;
	value = FactsQuerySum(fact.factName);
	switch(fact.operator)
	{
		case EO_Equal: result = value == fact.value;
		case EO_NotEqual: result = value != fact.value;
		case EO_Less: result = value < fact.value;
		case EO_LessEqual: result = value <= fact.value;
		case EO_Greater: result = value > fact.value;
		case EO_GreaterEqual: result = value >= fact.value;
	}
	
	// LogSCM("Checking Fact: Is " + fact.factName + "(" + value + ") " + fact.operator + " than " + fact.value + " = " + result);
	
	return result;
}
