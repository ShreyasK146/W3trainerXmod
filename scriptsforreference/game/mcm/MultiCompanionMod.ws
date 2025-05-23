//==================================================================================================================================================================================================================
//====
//====							Get NPC Functions
//====
//==================================================================================================================================================================================================================

function mod_scm_GetNPCs(out saveto : array<CNewNPC>, nam : name, optional type : ESCMSelectionType, optional mustBeFollowing : bool)
{
	var i, sz : int;
	var npcs : array<CNewNPC>;
	
	theGame.GetNPCsByTag(nam, npcs);
	sz = npcs.Size();
	
	for(i = 0; i < sz; i+=1)
	{
		if(npcs[i].scmcc && npcs[i].HasTag('GeraltsBFF') && (!mustBeFollowing || npcs[i].HasTag('mod_scm_IsFollowing')))
		{
			if(type == ST_Both)
			{
				saveto.PushBack(npcs[i]);
			}
			else if(type == ST_Special && npcs[i].scmcc.data.isSpecial)
			{
				saveto.PushBack(npcs[i]);
			}
			else if(type == ST_Normal && !npcs[i].scmcc.data.isSpecial)
			{
				saveto.PushBack(npcs[i]);
			}
		}
	}
}

function mod_scm_GetNPC(nam : name, optional type : ESCMSelectionType, optional mustBeFollowing : bool) : CNewNPC
{
	var i, sz : int;
	var npcs : array<CNewNPC>;
	
	theGame.GetNPCsByTag(nam, npcs);
	sz = npcs.Size();
	
	for(i = 0; i < sz; i+=1)
	{
		if(npcs[i].scmcc && npcs[i].HasTag('GeraltsBFF') && (!mustBeFollowing || npcs[i].HasTag('mod_scm_IsFollowing')))
		{
			if(type == ST_Both)
			{
				return npcs[i];
			}
			else if(type == ST_Special && npcs[i].scmcc.data.isSpecial)
			{
				return npcs[i];
			}
			else if(type == ST_Normal && !npcs[i].scmcc.data.isSpecial)
			{
				return npcs[i];
			}
		}
	}
	return NULL;
}
