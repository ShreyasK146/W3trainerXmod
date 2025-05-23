/*
Contains all storyscene functions
*/

exec function MCM_FriendCombat(entName : name)
{
	var npc : CNewNPC;
	npc = mod_scm_GetNPC(MCM_ConvertName(entName), ST_Special);
	
	if(npc && npc.scmcc)
	{
		thePlayer.DisplayHudMessage("Sheathe your sword to end the fight");
		npc.scmcc.EnterFriendlyCombat(true);
	}
}

storyscene function mod_scm_enterFriendlyCombat(player: CStoryScenePlayer, entName : name)
{
	var npc : CNewNPC;
	npc = mod_scm_GetNPC(entName, ST_Special);
	
	if(npc && npc.scmcc)
	{
		thePlayer.DisplayHudMessage("Sheathe your sword to end the fight");
		npc.scmcc.EnterFriendlyCombat(true);
	}
}

storyscene function mod_scm_toggle_follow(player: CStoryScenePlayer, entityName : name, value : bool)
{
	var ent : CNewNPC;
	
	ent = mod_scm_GetNPC(entityName, ST_Special);
	
	LogChannel('ModSpawnCompanions', "Toggling " + NameToString(entityName) + " " + value);
	
	if(ent && ent.scmcc)
	{
		if(value)
		{
			ent.scmcc.StartFollowing();
		}
		else
		{
			ent.scmcc.StopFollowing();
		}
	}
	else
	{
		LogChannel('ModSpawnCompanions', "Entity " + NameToString(entityName) + " not found.");
	}
}

//Special script, which goes to new dialog script.
//I basically copied and pasted the default dialogues for ciri, yen and triss, and removed the greeting.
storyscene function mod_scm_normal_dialog(player: CStoryScenePlayer, dialogLoc : string)
{
	mod_scm_GetSCMEntity().mod_scm_delayedDialogue(dialogLoc, 0.05);
	//thePlayer.mod_scm_delayedDialogue(dialogLoc, 0.05);
}

storyscene function mod_scm_Naughty(player: CStoryScenePlayer, isFinished : bool)
{
	if(isFinished)
	{
		mod_scm_GetSCM().NaughtyManager.PostNaughty();
	}
	else
	{
		mod_scm_GetSCM().NaughtyManager.PreNaughty();
	}	
}

storyscene function mod_scm_doNaughty(player: CStoryScenePlayer, entName : name)
{
	mod_scm_GetSCM().NaughtyManager.PreNaughtyWith(entName);
}
