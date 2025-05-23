
statemachine class MultiCompanionModEntity extends CEntity
{
	public editable var MODSCM : mod_scm;
	public editable var FOLLOWERDATA : mod_scm_saved_data;
	public editable var HAS_DATA : bool;

	timer function UpdateTick(dt : float, id : int)
	{
	}

	public function SetFollowerData(data : mod_scm_saved_data)
	{
		this.FOLLOWERDATA = data;
		this.HAS_DATA = true;
		
		LogChannel('ModSpawnCompanions', "I set the data: " + this.FOLLOWERDATA + ", " + data);
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
		AddTimer('UpdateTick', 0, true);
	}
	
	protected var dialogQueue : array<string>;
	
	timer function mod_scm_doDelayedDialogue(dt : float, id : int)
	{
		var dialogRes : string;
		var scene : CStoryScene;
		
		if(dialogQueue.Size() > 0)
		{
			dialogRes = dialogQueue[0];
			dialogQueue.Erase(0);
			
			scene = (CStoryScene)LoadResource(dialogRes, true);
			theGame.GetStorySceneSystem().PlayScene(scene, "Input");
		}
	}
	
	public function mod_scm_delayedDialogue(dialogRes : string, delay : float)
	{
		dialogQueue.PushBack(dialogRes);
		AddTimer('mod_scm_doDelayedDialogue', delay, false);
	}
}

//==================================================================================================================================================================================================================
//====
//====							Get SCM and SCMEntity Functions
//====
//==================================================================================================================================================================================================================

	function mod_scm_GetSCMEntity(optional dontspawn : bool) : MultiCompanionModEntity
	{
		var NPC : MultiCompanionModEntity;

	if(thePlayer.MODSCM_ENT)// && thePlayer.MODSCM_ENT.IsAlive())
	{
		return thePlayer.MODSCM_ENT;
	}
	else
	{
		NPC = (MultiCompanionModEntity)theGame.GetEntityByTag('MOD_SCM_ENT');
		if(!dontspawn)
		{
			if(!NPC) NPC = mod_scm_CreateSCMEntity();
			thePlayer.mod_scm_SET_SCM_ENT(NPC);
		}
		
		return NPC;
	}
}

function MCM_GetMCM() : mod_scm
{
	return mod_scm_GetSCM();
}

function mod_scm_GetSCM() : mod_scm
{
	var NPC : MultiCompanionModEntity;
	
	if(thePlayer.MODSCM)
	{
		return thePlayer.MODSCM;
	}
	else
	{
		NPC = mod_scm_GetSCMEntity();
		if(NPC)
		{
			if(!NPC.MODSCM)
			{
				NPC.MODSCM = new mod_scm in theGame;
				NPC.MODSCM.init();
			}
			thePlayer.mod_scm_SET_SCM(NPC.MODSCM);
			return NPC.MODSCM;
		}
		else
		{
			return thePlayer.mod_scm_CreateSCM();
		}
	}
}

function mod_scm_CreateSCMEntity() : MultiCompanionModEntity
{
	var template : CEntityTemplate;
	var pos : Vector;
	var rot : EulerAngles;
	var scm : MultiCompanionModEntity;
	
	LogChannel('ModSpawnCompanions', "Creating SCM Entity");
	
	pos = Vector(0, 0, 0);
	rot = EulerAngles(0, 0, 0);
	
	template = (CEntityTemplate) LoadResource("dlc/mod_spawn_companions/hack/npc/scmmod.w2ent", true);
	scm = (MultiCompanionModEntity) theGame.CreateEntity(template, pos, rot);

	if(scm)
	{
		scm.AddTag('MOD_SCM_ENT');
		LogSCM("Created SCM Entity!");
	}
	else
	{
		LogSCM("FAILED TO CREATE SCM ENTITY");
	}
	
	return scm;
}
