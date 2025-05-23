/*
Contains all console command functions
*/

exec function CallCompanion(optional nam : name, optional count : int)
{
	var npcs : array<CNewNPC>;
	var npc : CNewNPC;
	var i, sz : int;
	
	nam = MCM_ConvertName(nam);
	
	if(count < 1) count = 1;
	
	if(nam == '')
	{
		theGame.GetNPCsByTag('mod_scm_IsFollowing', npcs);
	}
	else
	{
		//Grab all types of NPCs by the given name, they must be following the player
		mod_scm_GetNPCs(npcs, nam, ST_Both, true);
	}
	
	LogChannel('ModSpawnCompanions', "Found " + npcs.Size() + " NPCs with name " + NameToString(nam));
	
	//If we found some NPCs, then sort up to 'count' by distance, in ascending order, and then TP those to the player
	if(npcs.Size() > 0)
	{
		if(count > npcs.Size()) count = npcs.Size();
	
		mod_scm_SortByDistance(npcs, thePlayer.GetWorldPosition(), true, count);
		
		for(i = 0; i < count; i+=1)
		{
			LogChannel('ModSpawnCompanions', "TPing NPC" + i + " of " + count);
			npcs[i].scmcc.tpToPlayer();
		}
	}
}

function _CallAllCompanions()
{
	var npcs : array<CNewNPC>;
	var i : int;
	
	theGame.GetNPCsByTag('GeraltsBFF', npcs);
	
	for(i = 0; i < npcs.Size(); i+=1)
	{
		if(npcs[i].scmcc.IsFollowing()/*.HasTag('mod_scm_IsFollowing')*/)
		{
			npcs[i].scmcc.tpToPlayer();
		}
	}
}

exec function CallAllCompanions()
{
	_CallAllCompanions();
}

function _RemoveSpecialCompanions()
{
	var npcname	: CNewNPC;
	var i : int;
	var npcs : array<CNewNPC>;
	
	theGame.GetNPCsByTag('GeraltsSpecialBFF', npcs);

	for(i = 0; i < npcs.Size(); i += 1)
	{
		npcname = npcs[i];
		
		if(npcname)
		{
			mod_scm_RemoveNPC(npcname);
		}
	}
}

exec function RemoveSpecialCompanions()
{
	_RemoveSpecialCompanions();
}

function _RemoveAllCompanions(optional includeSpecial : bool)
{
	var npc	: CNewNPC;
	var i, sz : int;
	var npcs : array<CNewNPC>;
	
	theGame.GetNPCsByTag('GeraltsBFF', npcs);

	sz = npcs.Size();
	
	for(i = 0; i < sz; i += 1)
	{
		npc = npcs[i];
		
		if(npc && npc.scmcc && (includeSpecial || !npc.scmcc.data.isSpecial))
		{
			mod_scm_RemoveNPC(npc);
		}
	}
	
	if(includeSpecial)
	{
		thePlayer.MODSCM_COMPANIONS.ClearCompanions();
		//thePlayer.mod_scm_clearArray();
	}
}

exec function RemoveAllCompanions(optional includeSpecial : bool)
{
	_RemoveAllCompanions(includeSpecial);
}

exec function RemoveCompanion(optional nam : name, optional count : int)
{
	var npcname : CNewNPC;
	var npcs : array<CNewNPC>;
	var i, size : int;
	var removed : int;
	var includeSpecial : bool;
	includeSpecial = true; //, optional includeSpecial : bool
	removed = 0;
	
	if(count < 1)
	{
		count = 1;
	}
	
	if(nam == '' || nam == 'all' || nam == 'ALL' || nam == '0' || nam == '1' || nam == '*' || nam == 'x' || nam == 'X')
	{
		theGame.GetNPCsByTag('GeraltsBFF', npcs);
		
		size = npcs.Size();
		
		if(count > size)
		{
			count = size;
		}
		
		mod_scm_SortByDistance(npcs, thePlayer.GetWorldPosition(), true, count);
		
		for(i = 0; i < size; i += 1)
		{
			npcname = npcs[i];
			
			if(npcname && npcname.scmcc)
			{
				if(npcname.scmcc.data.isSpecial) continue;
				
				mod_scm_RemoveNPC(npcname);
				removed+=1;
				if(removed == count) break;
			}
		}
		
		if(removed < count)
		{
			for(i = 0; i < size; i += 1)
			{
				npcname = npcs[i];
				
				if(npcname && npcname.scmcc && npcname.scmcc.data.isSpecial)
				{	
					mod_scm_RemoveNPC(npcname);
					removed+=1;
					if(removed == count) break;
				}
			}
		}
	}
	else
	{
		nam = MCM_ConvertName(nam);

		mod_scm_GetNPCs(npcs, nam, ST_Normal);
		size = npcs.Size();
		
		for(i = 0; i < size; i += 1)
		{
			if(!npcs[i].HasTag('GeraltsSpecialBFF'))
			{
				mod_scm_RemoveNPC(npcs[i]);
				removed += 1;
				if(removed == count) return;
			}
		}
		
		if(includeSpecial && removed < count)
		{
			npcs.Clear();
			mod_scm_GetNPCs(npcs, nam, ST_Special);
			size = npcs.Size();
			
			for(i = 0; i < size; i += 1)
			{
				mod_scm_RemoveNPC(npcs[i]);
				removed += 1;
				if(removed == count) return;
			}
		}
	}
}

exec function spawn2(nam : name, optional count : int, optional level : int, optional appearance : name)
{
	var npc : CNewNPC;
	var pos : Vector;
	var template : CEntityTemplate;
	var i, j : int;
	
	var stats : CCharacterStats;
	var abls : array<name>;
	var minHealth : float;
	var myHealth : float;
	
	nam = MCM_ConvertName(nam);
	
	template = MCM_GetEntityTemplate(nam);
	
	if(template)
	{
		if(count == 0)
		{
			count = 1;
		}
		
		if(level == 0)
		{
			level = GetWitcherPlayer().GetLevel();
		}
		
		minHealth = thePlayer.GetStatMax(BCS_Vitality);
		
		minHealth = minHealth * level * 5 / (GetWitcherPlayer().GetLevel());
		
		if(minHealth < 1) minHealth = 1;
		
		for(i = 0; i < count; i+=1)
		{
			pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
			npc = (CNewNPC)theGame.CreateEntity(template, pos);
			npc.SetLevel(level);
			npc.AddTag(nam);
			
			if(appearance)
			{
				npc.SetAppearance(appearance);
			}
			if(npc.UsesVitality())
			{
				myHealth = npc.GetStatMax(BCS_Vitality);
			}
			else
			{
				myHealth = npc.GetStatMax(BCS_Essence);
			}
			
			if(myHealth < minHealth)
			{
				if(npc.UsesVitality())
				{
					npc.ForceSetStat(BCS_Vitality, minHealth);
				}
				else
				{
					npc.ForceSetStat(BCS_Essence, minHealth);
				}
			}
		}
	}
}

exec function SpawnSpecialCompanion(nam : name, optional mortal : bool, optional level : int, optional appearance : name)
{
	MCM_SpawnNPCParams(MCM_ConvertName(nam), nam, appearance, mortal, true, level, true);
}

exec function SpawnCompanion(nam : name, optional count : int, optional mortal : bool, optional level : int, optional appearance : name)
{
	var i : int;
	
	nam = MCM_ConvertName(nam);

	if(count < 1) count = 1;
	
	for(i = 0; i < count; i+=1)
	{
		MCM_SpawnNPCParams(nam, , appearance, mortal, false, level, true);
	}
}

exec function ForceAllowAllNaughtyScenes(optional disable : bool)
{
	if(disable)
	{
		FactsSet('mod_scm_AllowAllNaughty', 0, -1);
	}
	else
	{
		FactsSet('mod_scm_AllowAllNaughty', 1, -1);
	}
}

exec function DisableCompanionTalking(on : bool)
{
	if(on)
	{
		FactsSet('mod_scm_talking_disabled', 1, -1);
	}
	else
	{
		FactsSet('mod_scm_talking_disabled', 0, -1);
	}
}

exec function ForceCompanionSpawning(on : bool)
{
	if(on)
	{
		FactsSet('mod_scm_enabled', 1, -1);
	}
	else
	{
		FactsSet('mod_scm_enabled', 0, -1);
		mod_scm_RmInvalidStationaryNPCs();
	}
}

exec function DisableCompanionSpawning(on : bool)
{
	if(on)
	{
		FactsSet('mod_scm_disabled', 1, -1);
		mod_scm_RmInvalidStationaryNPCs();
	}
	else
	{
		FactsSet('mod_scm_disabled', 0, -1);
	}
}

exec function EnableSCM(optional enable : bool)
{
	if(enable)
	{
		FactsSet('mod_scm_disabled', 0, -1);
		FactsSet('mod_scm_enabled', 1, -1);
	}
	else
	{
		FactsSet('mod_scm_disabled', 1, -1);
		FactsSet('mod_scm_enabled', 0, -1);
		mod_scm_RmInvalidStationaryNPCs();
	}
}

exec function SCMTestLots()
{
	var nams : array<name>;
	var i : int;
	
	nams.PushBack('cirilla');
	nams.PushBack('yennefer');
	nams.PushBack('triss');
	nams.PushBack('baron');
	nams.PushBack('becca');
	nams.PushBack('corina');
	nams.PushBack('crach_an_craite');
	nams.PushBack('dandelion');
	nams.PushBack('emhyr');
	nams.PushBack('eskel');
	nams.PushBack('fingilla_vigo');
	nams.PushBack('hjalmar');
	nams.PushBack('iris');
	nams.PushBack('keira_metz');
	nams.PushBack('lambert');
	nams.PushBack('letho');
	nams.PushBack('mousesack');
	nams.PushBack('olgierd');
	nams.PushBack('radovid');
	nams.PushBack('roche');
	nams.PushBack('shani');
	nams.PushBack('vesemir');
	nams.PushBack('zoltan_chivay');
	
	for(i = 0; i < nams.Size(); i+=1)
	{
		MCM_SpawnNPCParams(MCM_ConvertName(nams[i]), '', '', false, false, 0, true);
	}
}

exec function ResetScales()
{
	MCM_GetMCM().ScaleManager.ClearScales();
}

exec function SetScale(nam : name, optional scaleTo : float, optional count : int)
{
	var actors : array<CActor>;
	var tmp : CActor;
	var i : int;
	
	theGame.GetActorsByTag(MCM_ConvertName(nam), actors);//mod_scm_GetNPC(MCM_ConvertName(nam), ST_Special);
	
	if(actors.Size() == 0)
	{
		count = 1;
		
		if(nam == 'player' || nam == 'PLAYER')
		{
			actors.PushBack(thePlayer);
		}
		else if(nam == 'CLOSEST' || nam == 'closest')
		{
			tmp = GetClosestActor();
			LogSCM("Finding Closest: " + tmp);
			
			if(tmp)
			{
				actors.PushBack(tmp);
			}
		}
	}
	if(count == 0) count = 5000;
	
	if(scaleTo == 0) scaleTo = 1;
	
	for(i = actors.Size()-1; i>=0; i-=1)
	{
		if(actors[i])
		{
			count-=1;
			
			LogSCM("Found NPC To Scale");
		
			MCM_GetMCM().ScaleManager.SetScale(actors[i], scaleTo);
			
			if(count == 0) break;
		}
	}
}
