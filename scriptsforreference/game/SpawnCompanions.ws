/*
Copyright © CD Projekt RED & Jamezo97 2017
*/

//Move these action points to stop corvo bianco npcs from spawning?
//q705_dandelion
//q705_ciri
//q705_yen
//q705_triss

function scm_fact(nam : name) : bool
{
	return FactsQuerySum(nam) >= 1;
}

//==================================================================================================================================================================================================================
//====
//====							Custom SCM Entity - For TIMERS and DIALOGUE
//====
//==================================================================================================================================================================================================================

//==================================================================================================================================================================================================================
//====
//====							Saved Data
//====
//==================================================================================================================================================================================================================

class mod_scm_saved_data_copy
{
	editable var followers : array<MCMSpawnData>;
}

class mod_scm_saved_data
{
	editable saved var followers : array<MCMSpawnData>;
	editable var SCM_Copy : mod_scm_saved_data_copy;
	
	public function copyFrom(data : mod_scm_saved_data)
	{
		var i, sz : int;
		var tmp : MCMSpawnData;
		
		sz = data.followers.Size();
		this.followers.Clear();
		
		for(i = 0; i < sz; i+=1)
		{
			tmp = new MCMSpawnData in theGame;
			tmp.copyFrom(data.followers[i]);
			this.followers.PushBack(tmp);
		}
	}
	
	public function AddCompanion(data : MCMSpawnData)
	{
		followers.PushBack(data);
	}
	
	public function RemoveCompanion(data : MCMSpawnData) : bool
	{
		var i, sz : int;
		
		sz = followers.Size();
		
		for(i = 0; i < sz; i+=1)
		{
			if(data.equals(followers[i]))
			{
				followers.Remove(followers[i]);
				return true;
			}
		}
		return false;
	}
	
	public function CountCompanions() : int
	{
		return followers.Size();
	}

	public function ClearCompanions()
	{
		followers.Clear();
	}
	
	public function CleanArray()
	{
		var newArr : array<MCMSpawnData>;
		var i, sz : int;
		
		sz = followers.Size();
		
		for(i = 0; i < sz; i+=1)
		{
			if(followers[i])
			{
				newArr.PushBack(followers[i]);
			}
		}
		
		followers = newArr;
	}
}

exec function DisableSpecialCombat(optional turnBackOn : bool)
{
	if(turnBackOn)
	{
		FactsSet('mod_scm_SpecialCombatOff', 0);
		thePlayer.DisplayHudMessage("Special Combat Turned ON");
	}
	else
	{
		FactsSet('mod_scm_SpecialCombatOff', 1);
		thePlayer.DisplayHudMessage("Special Combat Turned OFF");
	}
}

//==================================================================================================================================================================================================================
//====
//====							SpawnCompanionMod Main Class
//====
//==================================================================================================================================================================================================================

statemachine class mod_scm extends CObject
{
	default autoState = 'Idle';

	public var nameMapper : mod_scm_NameMapper;

	//public var specialNPCInfos : mod_scm_SpecialNPCInfos;
	public var specialNPCDialogues : mod_scm_SpecialNPCDialogues;
	
	public var BoatManager : MCM_BoatManager;
	public var APManager : MCM_ActionPointManager;
	public var NaughtyManager : MCM_NaughtyManager;
	public var DialogueManager : MCM_DialogueManager;
	public var ScaleManager : MCM_ScaleManager;
	public var AsyncActionManager : MCM_AsyncActionManager;
	public var MenuManager : MCM_MenuManager;
	public var EntityList : MCM_EntityList;
	public var JobManager : MCM_JobManager;
	public var NPCManager : MCM_NPCManager;

	//public var CameraDirector : MCM_CameraDirector;

	private var isInit : bool; default isInit = false;
	public function init()
	{
		if(isInit) return;
		isInit = true;
		this.GotoState('Idle');
		LogSCM("SCM Current State: " + this.GetCurrentStateName());

		nameMapper = new mod_scm_NameMapper in this;
		nameMapper.init();
		
		//specialNPCInfos = new mod_scm_SpecialNPCInfos in this;
		//specialNPCInfos.init();
		
		specialNPCDialogues = new mod_scm_SpecialNPCDialogues in this;
		specialNPCDialogues.init();

		BoatManager = new MCM_BoatManager in this;
		BoatManager.init();
		
		APManager = new MCM_ActionPointManager in this;
		APManager.init();
		
		NaughtyManager = new MCM_NaughtyManager in this;
		NaughtyManager.init();
		
		DialogueManager = new MCM_DialogueManager in this;
		DialogueManager.init();

		ScaleManager = new MCM_ScaleManager in this;
		ScaleManager.init();

		AsyncActionManager = new MCM_AsyncActionManager in this;
		AsyncActionManager.init();

		MenuManager = new MCM_MenuManager in this;
		MenuManager.init();

		EntityList = new MCM_EntityList in this;
		EntityList.init();

		JobManager = new MCM_JobManager in this;
		JobManager.init();

		NPCManager = new MCM_NPCManager in this;
		NPCManager.init();

		//CameraDirector = new MCM_CameraDirector in this;
		//CameraDirector.init();
		
		SCM_Copy = new mod_scm_saved_data_copy in this;

		this.lastGameTime = GameTimeToSeconds(theGame.GetGameTime());
	}

	public function ReloadData()
	{
		LogSCM("Reloading MCM");
		delete JobManager;
		JobManager = new MCM_JobManager in this;
		JobManager.init();

		delete NPCManager;
		NPCManager = new MCM_NPCManager in this;
		NPCManager.init();
	}

	event OnCustomInteraction(action : SInputAction)
	{
		var npc : CNewNPC;
		
		if(IsPressed(action))
		{
			npc = (CNewNPC)thePlayer.GetDisplayTarget();
			
			if(npc && npc.scmcc && npc.scmcc.data.isSpecial && !theGame.IsFocusModeActive())
			{
				LogChannel('ModSpawnCompanions', "CustomInteract");
				npc.scmcc.OnPlayerInteract();
			}
		}
	}
	
	//public var OPEN_MENU : SCMMenu;
	
	event OnSCMMenu(action : SInputAction)
	{
		if(IsPressed(action))
		{
			this.MenuManager.ToggleWindow();
		}
	}

	public var SCM_Copy : mod_scm_saved_data_copy;
	
	//Mimics
	
	var doRefreshMimicsNextStateChange : bool;
	
	public function RefreshMimicsNextStateChange()
	{
		doRefreshMimicsNextStateChange = true;
	}

	public function normalizeName(nam : name) : name
	{
		return nameMapper.convert(nam);
	}
	
	public function nicifyName(nam : name) : name
	{
		return nameMapper.getNiceName(nam);
	}
	
	//Timers
	
	public function timer1second()
	{
		
	}
	
	public function timer250msecond()
	{
		var npcs : array<CNewNPC>;
		var i, sz : int;
		var PlayerDisablesSpeed : bool;
		var time : int;
		
		PlayerDisablesSpeed = (thePlayer.IsSwimming() || thePlayer.IsDiving() || thePlayer.IsSailing() || thePlayer.IsOnBoat() || thePlayer.GetCurrentStateName() == 'PlayerDialogScene');
		
		theGame.GetNPCsByTag('GeraltsBFF', npcs);
		sz = npcs.Size();

		for(i = 0; i < npcs.Size(); i+=1)
		{
			if(npcs[i].scmcc)
			{
				npcs[i].scmcc.PlayerDisablesSpeed = PlayerDisablesSpeed;
				npcs[i].scmcc.UpdateQuick();
			}
		}
		
		if(doRefreshMimicsNextStateChange && thePlayer.GetCurrentStateName() == 'Exploration')
		{
			for(i = 0; i < npcs.Size(); i+=1)
			{
				if(npcs[i].scmcc)
				{
					npcs[i].scmcc.RefreshMimics();
				}
			}
		}

		time = GameTimeToSeconds(theGame.GetGameTime());
		//LogSCM("Time: " + time);
		if((time - lastGameTime) > 600)
		{
			LogSCM("Time JUMPED!");
			JobManager.onTimeJump();
		}

		lastGameTime = time;
	}
	
	var lastGameTime : int;

	var isMeditating : bool;

	var talkCoolDown : int; default talkCoolDown = 0;
	var specialCoolDown : int;
	
	public function timer4second()
	{
		var npcs : array<CNewNPC>;
		var i, sz : int;
		
		NPCManager.update();
		
		if(specialCoolDown > 0) specialCoolDown-=1;
		
		if(thePlayer.GetCurrentStateName() == 'Exploration')
		{
			if(talkCoolDown > 0) talkCoolDown-=1; 
			
			if(talkCoolDown == 0 && RandRange(100, 0) < 15 && mod_scm_ShouldSpecialNPCsTalk())
			{
				specialNPCDialogues.UpdateDialogues();
				talkCoolDown = 7;
			}
		}
		else
		{
			if(thePlayer.IsInCombat())
			{
				doSpecialCombatAnims();
			}
		}
		
		theGame.GetNPCsByTag('GeraltsBFF', npcs);
		sz = npcs.Size();

		for(i = 0; i < npcs.Size(); i+=1)
		{
			if(npcs[i].scmcc)
			{
				npcs[i].scmcc.update4Second();
			}
		}
	}
	
	private function doSpecialCombatAnims()// : int
	{
		var npcs : array<CNewNPC>;
		var i, sz : int;
		//var NPC : CNewNPC;
		//var maxTime : int;
		
		if(FactsQuerySum('mod_scm_SpecialCombatOff') > 0) return; //Disabled
		
		//maxTime = 0;
		mod_scm_GetNPCs(npcs, 'GeraltsSpecialBFF', ST_Special, false);
		
		LogChannel('ModSpawnCompanions', "Trying Special Combat Anims: " + npcs.Size());
		
		for(i = npcs.Size()-1; i >= 0; i-=1)
		{
			if(npcs[i] && npcs[i].scmcc)
			{
				if(npcs[i].scmcc.specialCountdown > 0)
				{
					npcs[i].scmcc.specialCountdown -= 1;
				}
				else
				{
					if(npcs[i].IsInCombat() && RandRange(100, 0) < 30)
					{
						LogChannel('ModSpawnCompanions', "Go Special Combat!");
						npcs[i].scmcc.specialCountdown = npcs[i].scmcc.doSpecialCombat();
						
						if(npcs[i].scmcc.specialCountdown > 0) break;
						//maxTime = 3;
					}
				}
			}
		}
		
		//return maxTime;
	}
	
	private function ensureCorrectFollowers()
	{
		var i, szAll, j, szNew : int;
		var allCompanions : array<CNewNPC>;
		var newCompanions : array<MCMSpawnData>;
		var npc : CNewNPC;
		var newNpc : MCMSpawnData;
		
		theGame.GetNPCsByTag('GeraltsBFF', allCompanions);
		newCompanions = GetWitcherPlayer().MODSCM_COMPANIONS.followers;
		
		//removeAllNPCs(); //Remove all NPCs
		szAll = allCompanions.Size();
		szNew = newCompanions.Size();
		
		for(i = 0; i < szNew; i+=1)
		{
			newNpc = newCompanions[i];

			for(j = 0; j < szAll; j+=1)
			{
				if(allCompanions[j] && allCompanions[j].scmcc && newNpc.equals(allCompanions[j].scmcc.data))
				{
					allCompanions[j] = NULL;
					j = -1; break;
				}
			}
			
			if(j != -1)
			{
				MCM_SpawnNPC(newNpc, true);
			}
		}

		for(j = 0; j < szAll; j+=1)
		{
			if(allCompanions[j])
			{
				allCompanions[j].Destroy();
			}
		}
	}
	
	private function removeAllNPCs()
	{
		var currentNPCs : array<CNewNPC>;
		var i, sz : int;
		theGame.GetNPCsByTag('GeraltsBFF', currentNPCs);
		sz = currentNPCs.Size();
		
		for(i = 0; i < sz; i+=1)
		{
			currentNPCs[i].Destroy();
		}
	}
	
	public function onWorldLoaded()
	{
		//Upon loading a world. do:
		//0 List ALL Companions 'GeraltsBFF'
		//1 Remove all non-following companions
		//2 Add following companions
		//3 Remove all remaining companions
	
		//var areaInt : EAreaName;
		//areaInt = theGame.GetCommonMapManager().GetCurrentArea();
		var i, szAll, j, szNew : int;
		var allCompanions : array<CNewNPC>;
		var newCompanions : array<MCMSpawnData>;
		var npc : CNewNPC;
		var newNpc : MCMSpawnData;
		var distSq : float;
		
		thePlayer.MODSCM_COMPANIONS.CleanArray();
		
		theGame.GetNPCsByTag('GeraltsBFF', allCompanions);
		newCompanions = thePlayer.MODSCM_COMPANIONS.followers; //mod_scm_followingCompanions;
		
		//removeAllNPCs(); //Remove all NPCs
		szAll = allCompanions.Size();
		szNew = newCompanions.Size();

		for(i = 0; i < szNew; i+=1)
		{
			newNpc = newCompanions[i];
			LogChannel('ModSpawnCompanions', "Follower : " + newNpc.nam + ", " + newNpc.niceName + ", " + newNpc.appearance + ", " + newNpc.level + ", " + newNpc.mortal + ", " + newNpc.isSpecial);

			for(j = 0; j < szAll; j+=1)
			{
				if(allCompanions[j] && allCompanions[j].scmcc && newNpc.equals(allCompanions[j].scmcc.data))
				{
					allCompanions[j].scmcc.StartFollowing(true);
					
					distSq = VecDistanceSquared(thePlayer.GetWorldPosition(), allCompanions[j].GetWorldPosition());
					
					if(distSq > 400)
					{
						allCompanions[j].scmcc.tpToPlayer();
					}
					
					allCompanions[j] = NULL;
					LogChannel('ModSpawnCompanions', "Follower already exists. TPing to player");
					j = -1; break;
				}
			}
			
			if(j != -1)
			{
				LogChannel('ModSpawnCompanions', "Follower does not exist. Spawning!");
				MCM_SpawnNPC(newNpc, true);
			}
		}
		
		for(j = 0; j < szAll; j+=1)
		{
			if(allCompanions[j])
			{
				LogChannel('ModSpawnCompanions', "Destroying remaining companion: " + allCompanions[j]);
				allCompanions[j].Destroy();
			}			
		}
	}

	public function addKilledEXP(exp: int)
	{
		//GetWitcherPlayer().AddPoints(EExperiencePoint, exp, false);
	}

	function registerListeners()
	{
		theInput.RegisterListener(this, 'OnSCMMenu', 'OpenMCMMenu');	
		theInput.RegisterListener(this, 'OnCustomInteraction', 'Talk');
	}

	function deregisterListeners()
	{
		theInput.UnregisterListener(this, 'OpenMCMMenu');
		theInput.UnregisterListener(this, 'Talk');
	}
}

state Idle in mod_scm {

	event OnEnterState(prevStateName : name)
	{
		super.OnEnterState(prevStateName);
		doPostStuff();
	}

	entry function doPostStuff()
	{
		var i : int;
		for(i = 1; i > 0; i-=1)
		{
			parent.deregisterListeners();
			parent.registerListeners();
			Sleep(1);
		}
	}
	
	event OnLeaveState(prevStateName : name)
	{
		super.OnLeaveState(prevStateName);
		parent.deregisterListeners();
	}
}

function MCM_ConvertName(nam : name) : name
{
	return mod_scm_GetSCM().normalizeName(nam);
}

function mod_scm_CanSpecialNPCSpawn(info : mod_scm_SpecialNPC) : bool
{
	if(scm_fact('mod_scm_disabled')) return false;
	if(info) return scm_fact('mod_scm_enabled') || info.areSpawnConditionsMet();
	return false;
}

function mod_scm_ShouldSpecialNPCsTalk() : bool
{
	return !scm_fact('mod_scm_talking_disabled');
}

function mod_scm_RmInvalidStationaryNPCs()
{
	var npcs : array<CNewNPC>;
	var size, i : int;
	
	theGame.GetNPCsByTag('GeraltsSpecialBFF', npcs);
	size = npcs.Size();
	for(i = 0; i < size; i+=1)
	{
		if(npcs[i].scmcc && !npcs[i].scmcc.IsFollowing() && !mod_scm_CanSpecialNPCSpawn(npcs[i].scmcc.info))
		{
			npcs[i].Destroy();
		}
	}	
}

function scmlog(str : string)
{
	LogChannel('ModSpawnCompanions', str);
}

//====================================================================================================================================
//				Console Commands
//====================================================================================================================================

function mod_scm_SortActorsByDistance(out npcs : array<CActor>, from : Vector, optional descending : bool, optional count : int)
{
	var sz, szi, i, j : int;
	var smallestDist : float;
	var smallestIndex : int;
	
	var tmpDist : float;
	var tmpNPC : CActor;
	
	//scmlog("Sorting array, V: " + from.X + "," + from.Y + ","+from.Z + ", Descending: " + descending + ", Count: " + count + "NpcCount: " + npcs.Size());
	
	if(count < 1) count = sz;
	
	sz = npcs.Size();
	szi = sz;
	
	if(count > 0 && count < szi) szi = count; 
	
	for(i = 0; i < szi; i+=1)
	{
		smallestIndex = -1;
		for(j = i; j < sz; j+=1)
		{
			tmpDist = VecDistanceSquared(from, npcs[j].GetWorldPosition());
			
			if((!descending && tmpDist < smallestDist) || (descending && tmpDist > smallestDist) || smallestIndex == -1)
			{
				smallestDist = tmpDist;
				smallestIndex = j;
			}
		}
		
		if(smallestIndex != -1 && smallestIndex != i)
		{
			tmpNPC = npcs[i];
			npcs[i] = npcs[smallestIndex];
			npcs[smallestIndex] = tmpNPC;
		}
	}
}

function mod_scm_SortByDistance(out npcs : array<CNewNPC>, from : Vector, optional descending : bool, optional count : int)
{
	var sz, szi, i, j : int;
	var smallestDist : float;
	var smallestIndex : int;
	
	var tmpDist : float;
	var tmpNPC : CNewNPC;
	
	//scmlog("Sorting array, V: " + from.X + "," + from.Y + ","+from.Z + ", Descending: " + descending + ", Count: " + count + "NpcCount: " + npcs.Size());
	
	if(count < 1) count = sz;
	
	sz = npcs.Size();
	szi = sz;
	
	if(count > 0 && count < szi) szi = count; 
	
	for(i = 0; i < szi; i+=1)
	{
		smallestIndex = -1;
		for(j = i; j < sz; j+=1)
		{
			tmpDist = VecDistanceSquared(from, npcs[j].GetWorldPosition());
			
			if((!descending && tmpDist < smallestDist) || (descending && tmpDist > smallestDist) || smallestIndex == -1)
			{
				smallestDist = tmpDist;
				smallestIndex = j;
			}
		}
		
		if(smallestIndex != -1 && smallestIndex != i)
		{
			tmpNPC = npcs[i];
			npcs[i] = npcs[smallestIndex];
			npcs[smallestIndex] = tmpNPC;
		}
	}
}

//man_ger_sword_heavyhit_front_rp

function mod_scm_PlayerSay(text : int, time : float)
{
	var chatElement : mod_scm_NPCChatElement;
	
	chatElement = new mod_scm_NPCChatElement in thePlayer;
	chatElement.entSpecialID = 'PLAYER';
	chatElement.talkingID = text;
	chatElement.talkingString = GetLocStringById(text);
	chatElement.time = time;

	LogSCM("Add " + chatElement + ", " + chatElement.talkingString);
	
	MCM_GetMCM().DialogueManager.AddChat(chatElement);
}

function mod_scm_PlayPlayerAnim(animName : name)
{
	if(thePlayer.ActionPlaySlotAnimationAsync('PLAYER_SLOT', animName, 0.2, 0.2))
	{
		LogSCM("PLAYED");
	}
	else
	{
		LogSCM("NAYED");
	}
}

exec function SwordFight()
{
	var npc : CNewNPC;
	npc = mod_scm_GetNPC('cirilla', ST_Both);

	npc.scmcc.PlayAnims2(
		'stand_mw_training_sword_jt_start',
		'stand_mw_training_sword_jt_loop_01',
		'stand_mw_training_sword_jt_loop_02',
		'stand_mw_training_sword_jt_loop_01',
		'stand_mw_training_sword_jt_loop_02',
		'stand_mw_training_sword_jt_stop');
}

exec function StartAttack()
{
	var npc : CNewNPC;
	npc = mod_scm_GetNPC('GeraltsBFF', ST_Special, false);
	
	LogChannel('ModSpawnCompanions', "Trying to attack");
	if(npc && npc.scmcc)
	{
		LogChannel('ModSpawnCompanions', "Starting Attacking");
		//npc.scmcc.StartAttacking();
	}
}

function LogSCM(message : string)
{
	LogChannel('ModSpawnCompanions', message);
}

function LogMCM(message : string)
{
	LogChannel('MultiCompanionMod', message);
}

function SetupSimpleSyncAnim(animName : name, master : CEntity, optional finalPos : Vector) : bool
{
		var masterDef : SAnimationSequenceDefinition;
		var masterSequencePart : SAnimationSequencePartDefinition;
		var syncInstance : CAnimationManualSlotSyncInstance;
		var instanceIndex, sequenceIndex, sz, i : int;
		var finisherAnim : bool;
		var actorMaster : CActor;
		var syncManager : W3SyncAnimationManager;
		
		syncManager = theGame.GetSyncAnimManager();
		
		LogSCM("Sync Manager: " + syncManager);
	
		syncInstance = syncManager.CreateNewSyncInstance(instanceIndex);
		
		{
			masterSequencePart.animation = animName;
			masterSequencePart.syncType = AMST_SyncBeginning;
			masterSequencePart.syncEventName = 'SyncEvent';
			masterSequencePart.shouldSlide = false;
			masterSequencePart.shouldRotate = false;
			masterSequencePart.blendInTime = 0;
			masterSequencePart.blendOutTime = 0;
			masterSequencePart.sequenceIndex = 0;
			if(finalPos.X != 0 || finalPos.Y != 0 || finalPos.Z != 0)
			{
				masterSequencePart.finalPosition = finalPos;
				masterSequencePart.shouldSlide = true;
			}
		
			masterDef.entity = master;
			masterDef.manualSlotName = 'GAMEPLAY_SLOT';
			masterDef.freezeAtEnd = true;
		}
		
		//thePlayer.BlockAction(EIAB_Interactions, 'SyncManager');
		//thePlayer.BlockAction(EIAB_FastTravel, 'SyncManager');
		
		sequenceIndex = syncInstance.RegisterMaster(masterDef);
		if(sequenceIndex == -1)
		{
			syncManager.RemoveSyncInstance(syncInstance);
			return false;
		}
		
		actorMaster = (CActor)master;
		
		if(actorMaster)
		{
			actorMaster.SignalGameplayEventParamInt('SetupSyncInstance', instanceIndex);
			actorMaster.SignalGameplayEventParamInt('SetupSequenceIndex', sequenceIndex);
			actorMaster.SignalGameplayEvent('PlaySyncedAnim');
		}
		
		return true;
	}
	
	exec function GiveSword(nam : name)
	{
		var npc : CNewNPC;
		var inventory : CInventoryComponent;
		var added : array<SItemUniqueId>;
		var equipped : bool;
		npc = mod_scm_GetNPC(nam, ST_Both);
		LogSCM("NPC: " + npc);
		
		if(npc)
		{
			inventory = (CInventoryComponent) npc.GetComponentByClassName('CInventoryComponent');
			LogSCM("Inventory: " + inventory);
			
			if(inventory)
			{
				added = inventory.AddAnItem('NPC Skellige sword 2', 1);
				//LogSCM("Added: " + added);
				LogSCM("Added: " + added.Size());
				
				if(added.Size() > 0)
				{
					equipped = npc.EquipItem(added[0], EES_SteelSword, false);
					//LogSCM("Equipped: " + equipped);
				}
			}
		}
	}
