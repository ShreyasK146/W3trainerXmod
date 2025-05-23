
class MCMSpawnData
{
	public saved var nam : name;
	public saved var niceName : name;
	public saved var appearance : name;
	public saved var level : int;
	public saved var scale : float;
	public saved var mortal : bool;
	public saved var isSpecial : bool;
	public saved var depotPathPrefix : String;
	
	public function equals(data : MCMSpawnData) : bool
	{
		return this.nam == 		data.nam && 
		this.niceName == 		data.niceName && 
		this.appearance == 		data.appearance && 
		this.level == 			data.level && 
		this.scale == 			data.scale && 
		this.mortal == 			data.mortal && 
		this.isSpecial == 		data.isSpecial && 
		this.depotPathPrefix == 	data.depotPathPrefix;
	}
	
	public function copyFrom(data : MCMSpawnData)
	{
		this.nam = data.nam;
		this.niceName = data.niceName;
		this.appearance = data.appearance;
		this.level = data.level;
		this.scale = data.scale;
		this.mortal = data.mortal;
		this.isSpecial = data.isSpecial;
		this.depotPathPrefix = data.depotPathPrefix;
	}
}

//Spawn an NPC from the given parameters
function MCM_SpawnNPCParams(nam : name, optional niceName : name, optional appearance : name, 
optional mortal : bool, optional isSpecial : bool, optional level : int, optional startFollowing : bool,
optional startPos : Vector, optional startRot : EulerAngles) : CNewNPC

{
    var data : MCMSpawnData = new MCMSpawnData in thePlayer;
    var npc : CNewNPC;

    data.nam = nam;
    data.niceName = niceName;
    data.appearance = appearance;
    data.level = level;
    data.mortal = mortal;
    data.isSpecial = isSpecial;

    npc = MCM_SpawnNPC(data, startFollowing, startPos, startRot);

    delete data;
    return npc;
}

//Spawn an NPC from the data object.
function MCM_SpawnNPC(data : MCMSpawnData, optional startFollowing : bool, optional startPos : Vector, optional startRot : EulerAngles) : CNewNPC
{
    	var npc : CNewNPC;
	var pos : Vector;
	var rot : EulerAngles;
	var template : CEntityTemplate;
	var taglist : array<name>;
	
	if(data.isSpecial)
	{
		npc = mod_scm_GetNPC(data.nam, ST_Special);
		if(npc)
		{
			mod_scm_RemoveNPC(npc);
		}
	}
	
	template = MCM_GetEntityTemplate(data.nam, data.depotPathPrefix);
	
	if(template)
	{
        //Data validation
		if(!IsNameValid(data.niceName))     data.niceName = mod_scm_GetSCM().nicifyName(data.nam);	
		if(!IsNameValid(data.appearance))   data.appearance = MCM_GetDefaultAppearance(data.nam);
		if(data.level < 1) data.level = GetWitcherPlayer().GetLevel();
			
		if(data.isSpecial) taglist.PushBack('GeraltsSpecialBFF');

		taglist.PushBack(data.nam);
		taglist.PushBack('GeraltsBFF');
		taglist.PushBack('mod_scm_dontinit');
		taglist.PushBack(theGame.params.TAG_NPC_IN_PARTY);
		
		if(startPos.X != 0 || startPos.Y != 0 || startPos.Z != 0)
		{
			pos = startPos;
		}
		else
		{
			pos = thePlayer.GetWorldPosition() + VecRingRand(1.0, 4.0);
		}
	
		npc = (CNewNPC)theGame.CreateEntity(template, pos, startRot, true, true, false, PM_Persist, taglist);
		
		MCM_AddSwordIfNeeded(npc);
		
		//Run our own custom initialization.
		npc.scmcc.onFirstSpawned(data);
		
		npc.scmcc.PostSpawnedInit();
        
		if(startFollowing) npc.scmcc.StartFollowing();
	}
    else
    {
        LogSCM("Warning: Failed to spawn npc " + data.nam + ". Template failed to load.");
    }
	
	return npc;
}

function mod_scm_RemoveNPC(npc : CNewNPC, optional dontTellPlayer : bool)
{
	var hud : CR4ScriptedHud;
	hud = (CR4ScriptedHud)theGame.GetHud();
	
	//If they were saying anything, remove it
	hud.HideOneliner(npc);
	
	npc.scmcc.StopFollowing(dontTellPlayer);
	// npc.scmcc.DestroyHorse();
	
	//Probably not necessary
	npc.RemoveTag( 'GeraltsBFF' );
	npc.RemoveTag( 'GeraltsSpecialBFF' );
	npc.Destroy();
}

function MCM_GetDefaultAppearance(nam : name) : name
{
	if(nam == 'cirilla')
	{
		return 'ciri';
	}
	else if(nam == 'keira_metz')
	{
		return 'keira_metz_sorceress';
	}
	else if(nam == 'shani')
	{
		return 'shani';
	}
	else if(nam == 'triss')
	{
		return 'triss';
	}
	else if(nam == 'yennefer')
	{
		return 'yennefer_travel_outfit';
	}
	
	return nam;
}

//==================================================================================================================================================================================================================
//====
//====							Spawning Functions
//====
//==================================================================================================================================================================================================================


function MCM_GetEntityTemplate(nam : name, depotPath : String) : CEntityTemplate
{
	var nts : string;
	var template : CEntityTemplate;
	
	nts = NameToString(nam);

    //If the spawn data includes a depot path, then try that first.
    /*if(StrLen(depotPath) > 0)
    {
        //Fix up the string if needed
        depotPath = StrReplaceAll(depotPath, "\\", "/");
        if(!StrEndsWith(depotPath, "/")) depotPath = depotPath + "/";

	if(!template) template = (CEntityTemplate)LoadResource(depotPath + nts + ".w2ent", true);
	if(template) return template;
    }*/
	//Vanilla
	if(!template) template = (CEntityTemplate)LoadResource("quests/main_npcs/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/secondary_npcs/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/main_npc/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/secondary_npc/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/animals/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/animals/boids/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/animals/horse/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/bandit/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/eternal_fire_priest/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/fistfighter/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/freyi_priestess/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/inquisition_soldier/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/naked_characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/nilfgaard_citizen/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/nilfgaard_prisoners/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/nilfgaard_soldier/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/nml_craftsman/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/nml_soldier/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/nml_villager/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/novigrad_citizen/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/novigrad_craftsman/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/novigrad_rogue/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/novigrad_soldier/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/prolog_craftsman/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/prolog_villager/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/prostitutes/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/redania_soldier/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/roche_soldier/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/scoiatael_soldier/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/skellige_clans/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/skellige_craftsmen/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/skellige_druid/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/skellige_pirate/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/skellige_villager/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/skellige_warrior/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/sorcerers/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/succubus/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/temeria_soldier/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/vampire_medic/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/crowd_npc/wild_hunt_lvl3/" + nts + ".w2ent", true);
	
	//HOS
	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/quests/main_npcs/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/quests/secondary_npcs/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/characters/npc_entities/main_npc/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/characters/npc_entities/secondary_npc/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/characters/npc_entities/animals/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/characters/npc_entities/animals/horse/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/characters/npc_entities/crowd_npc/q602_redanian_soldiers/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/characters/npc_entities/crowd_npc/q603_army_cook/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/characters/npc_entities/crowd_npc/q605/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/characters/npc_entities/crowd_npc/mq6003_tax_collector/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/characters/npc_entities/crowd_npc/mq6004_baker/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/characters/npc_entities/crowd_npc/mq6004_rose_fisstech_manufacturer/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/characters/npc_entities/crowd_npc/auction_house_guards/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/characters/npc_entities/crowd_npc/auction_participants/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/characters/npc_entities/crowd_npc/flaming_rose_guard/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/characters/npc_entities/crowd_npc/hakland_warrior/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/characters/npc_entities/crowd_npc/mirror_crowd/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/characters/npc_entities/crowd_npc/ofir_enchanter/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/characters/npc_entities/crowd_npc/olgierds_gang_members/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/characters/npc_entities/crowd_npc/wedding_guests/" + nts + ".w2ent", true);
	
	//B&W
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/main_npcs/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/secondary_npcs/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/characters/npc_entities/main_npc/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/characters/npc_entities/secondary_npc/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/characters/npc_entities/animals/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/characters/npc_entities/animals/horse/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/characters/npc_entities/crowd_npc/bob_background_crowd/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/characters/npc_entities/crowd_npc/bob_bandit/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/characters/npc_entities/crowd_npc/bob_citizen/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/characters/npc_entities/crowd_npc/bob_craftsman/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/characters/npc_entities/crowd_npc/bob_dyetrader/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/characters/npc_entities/crowd_npc/bob_guard/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/characters/npc_entities/crowd_npc/bob_knight/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/characters/npc_entities/crowd_npc/bob_nilfgaardian/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/characters/npc_entities/crowd_npc/bob_no_autohide/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/characters/npc_entities/crowd_npc/bob_vineyard/" + nts + ".w2ent", true);
	
	//DLC
	if(!template) template = (CEntityTemplate)LoadResource("dlc/dlc3/data/characters/" + nts + ".w2ent", true);

	if(!template) template = (CEntityTemplate)LoadResource("dlc/dlc7/data/characters/" + nts + ".w2ent", true);

	if(!template) template = (CEntityTemplate)LoadResource("dlc/dlc12/data/quest/quest_files/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/dlc12/data/characters/npc_entities/crowd_npc/" + nts + ".w2ent", true);

	if(!template) template = (CEntityTemplate)LoadResource("dlc/dlc15/data/quests/quest_files/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/dlc15/data/characters/npc_entities/secondary_npc/" + nts + ".w2ent", true);
	
	//Common NPCs
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/community_npcs/nml/custom/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/community_npcs/nml/regular/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/community_npcs/novigrad/guards/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/community_npcs/novigrad/nonhumans/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/community_npcs/novigrad/oxenfurt/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/community_npcs/novigrad/regular/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/community_npcs/novigrad/scoiatael/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/community_npcs/novigrad/questspecific/mh302_questgiver/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/community_npcs/novigrad/questspecific/th1003_lynx_set/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/community_npcs/prologue/regular/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/community_npcs/skellige/custom/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/community_npcs/skellige/regular/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/community_npcs/skellige/spikeroog/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/definitions/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/prologue/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/traveling_merchants/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/no_mans_land/bald_mountain/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/no_mans_land/barons_keep/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/no_mans_land/baron_village/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/no_mans_land/boat_maker_spot/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/no_mans_land/borrows/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/no_mans_land/glinsk/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/no_mans_land/midcotts/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/no_mans_land/mouth/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/no_mans_land/rudnik/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/no_mans_land/snots/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/novigrad/brothel_district/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/novigrad/citizen_district/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/novigrad/crematory/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/novigrad/fat_catch_inn/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/novigrad/market/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/novigrad/poor_district/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/novigrad/rich_district/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/novigrad/roche_camp/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/novigrad/scoiatael_camp/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/novigrad/suburbs/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/novigrad/temple_district/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/novigrad/toderas/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/novigrad/whitebridge/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/skellige/arinbjorn/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/skellige/blandare/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/skellige/brokvar/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/skellige/dimun/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/skellige/ferlund/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/skellige/freya/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/skellige/fyresdal/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/skellige/herbalist/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/skellige/holmestein/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/skellige/kaer_trolde/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/skellige/larvik/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/skellige/lugos_keep/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/skellige/rannvaig/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/skellige/tuiseach/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/community/shops_and_craftsmen/skellige/undvik/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/templates/characters/npcs/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/templates/characters/npcs/1handed_sword/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/templates/characters/npcs/test_enemies/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/templates/characters/presets/inquisition/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/templates/characters/presets/nilfgaard/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/templates/characters/presets/nml/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/templates/characters/presets/novigrad/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/templates/characters/presets/redania/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/templates/characters/presets/skellige/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/templates/characters/presets/skellige/tuirseach/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("gameplay/templates/characters/presets/wild_hunt/" + nts + ".w2ent", true);

	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/community/community_npcs/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/gameplay/templates/characters/presets/nml/ep1_bandits/" + nts + ".w2ent", true);

	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/gameplay/community/community_npcs/animals/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/gameplay/community/community_npcs/animals/horses/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/gameplay/community/community_npcs/bandits/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/gameplay/community/community_npcs/citizens/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/gameplay/community/community_npcs/citizens/beauclair/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/gameplay/community/community_npcs/corvo_bianco_nice/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/gameplay/community/community_npcs/craftsmen/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/gameplay/community/community_npcs/craftsmen/beauclair/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/gameplay/community/community_npcs/customs/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/gameplay/community/community_npcs/guards/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/gameplay/community/community_npcs/guards/beauclair/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/gameplay/community/community_npcs/infested_vineyard/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/gameplay/community/community_npcs/nilfgaardians/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/gameplay/community/community_npcs/prayers/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/gameplay/community/community_npcs/vineyard/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/gameplay/templates/presets/beauclair_guard/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/gameplay/templates/presets/knight_errant/" + nts + ".w2ent", true);
	
	//Special
	if(!template) template = (CEntityTemplate)LoadResource("quests/prologue/quest_files/q001_beggining/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/prologue/quest_files/q002_emhyr/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/prologue/quest_files/living_world/lw_prologue_cemetary_wraith/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_1/quest_files/q101_agent/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_1/quest_files/q101_agent/characters/scenes_characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_1/quest_files/q102_baron/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_1/quest_files/q103_daughter/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_1/quest_files/q104_mine/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_1/quest_files/q105_witches/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_1/quest_files/q201_pirates/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_1/quest_files/q202_giant/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_1/quest_files/q203_him/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_1/quest_files/q205_frozen_coast/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_1/quest_files/q301_dreamer/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_1/quest_files/q302_mafia/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_1/quest_files/q302_mafia/characters/whoreson_guards_replacer/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_1/quest_files/q303_treasure/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_1/quest_files/q304_dandelion/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_1/quest_files/q305_blanka/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_1/quest_files/q401_konsylium/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_2/quest_files/q106_tower/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_2/quest_files/q106_tower/characters/ghost_npc_body_parts/popiel/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_2/quest_files/q106_tower/characters/ghost_peasant_body_parts/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_2/quest_files/q107_swamps/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_2/quest_files/q108_eve/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_2/quest_files/q109_wrapup/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_2/quest_files/q206_berserkers/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_2/quest_files/q206_berserkers/characters/brans_sailors/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_2/quest_files/q206_berserkers/characters/cave_islanders/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_2/quest_files/q208_heroesmead/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_2/quest_files/q308_psycho/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_2/quest_files/q309_casablanca/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_2/quest_files/q402_ciri/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_2/quest_files/q403_battle/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_3/quest_files/q110_postbattle/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_3/quest_files/q111_imlerith/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_3/quest_files/q210_precanaris/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_3/quest_files/q310_pregeels/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_3/quest_files/q311_geels/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_3/quest_files/q501_eredin/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_3/quest_files/q501_eredin/characters/weak_skellige/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/part_3/quest_files/q502_avallach/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/epilogues/quest_files/q503_ciri_dead_new/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/epilogues/quest_files/q504_ciri_empress/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/epilogues/quest_files/q505_ciri_free/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/sidequests/no_mans_land/quest_files/sq101_keira/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/sidequests/no_mans_land/quest_files/sq102_letho/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/sidequests/no_mans_land/quest_files/sq104_werewolf/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/sidequests/no_mans_land/quest_files/sq106_killbill/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/sidequests/no_mans_land/quest_files/sq108_master_blacksmith/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/sidequests/skellige/quest_files/sq201_curse/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/sidequests/skellige/quest_files/sq202_yen/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/sidequests/skellige/quest_files/sq204_forest_spirit/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/sidequests/skellige/quest_files/sq205_alchemist/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/sidequests/skellige/quest_files/sq209_weregild/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/sidequests/skellige/quest_files/sq210_impossible_tower/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/sidequests/novigrad/quest_files/sq301_triss/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/sidequests/novigrad/quest_files/sq302_philippa/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/sidequests/novigrad/quest_files/sq303_brothel/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/sidequests/novigrad/quest_files/sq304_armorsmith/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/sidequests/novigrad/quest_files/sq305_scoiatael/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/sidequests/novigrad/quest_files/sq306_maverick/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/sidequests/novigrad/quest_files/sq310_dangerous_game/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/sidequests/novigrad/quest_files/sq312_ves/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/sidequests/novigrad/quest_files/sq315_talar/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/generic_quests/novigrad/quest_files/mh303_succubus/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/generic_quests/novigrad/quest_files/mh305_doppler/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/minor_quests/no_mans_land/quest_files/mq1060_devils_pit/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/minor_quests/skellige/quest_files/mq2013_bounty_hunter/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/minor_quests/skellige/quest_files/mq2038_shieldmaiden/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/minor_quests/novigrad/quest_files/mq3009_witch_hunter_raids/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("quests/minor_quests/novigrad/quest_files/mq3031_aging_romance/characters/" + nts + ".w2ent", true);

	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/quests/quest_files/q601_intro/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/quests/quest_files/q602_wedding/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/quests/quest_files/q603_bank/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/quests/quest_files/q604_mansion/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/quests/quest_files/q605_finale/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/quests/quest_files/mq6004_broken_rose/characters/" + nts + ".w2ent", true);

	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/main_quests/quest_files/q701_wine_festival/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/main_quests/quest_files/q702_hunt/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/main_quests/quest_files/q703_all_for_one/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/main_quests/quest_files/q703_all_for_one/characters/dun_tynne_bandits/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/main_quests/quest_files/q703_all_for_one/characters/dun_tynne_guards/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/main_quests/quest_files/q703_all_for_one/characters/dun_tynne_royal_guards/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/main_quests/quest_files/q703_all_for_one/characters/exchange_point_bandits/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/main_quests/quest_files/q703_all_for_one/characters/mandragora_nobles/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/main_quests/quest_files/q703_all_for_one/characters/mandragora_nobles/mage_viewers/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/main_quests/quest_files/q703_all_for_one/characters/mandragora_nobles/ofir_enchanter_files/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/main_quests/quest_files/q703_all_for_one/characters/pre_mandragora_bandits/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/main_quests/quest_files/q703_all_for_one/characters/wolves_encounterr/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/main_quests/quest_files/q704_truth/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/main_quests/quest_files/q704b_fairy_tale/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/main_quests/quest_files/q704b_fairy_tale/characters/minor/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/main_quests/quest_files/q705_epilog/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/sidequests/quest_files/sq701_tournament/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/sidequests/quest_files/sq701_tournament/characters/contestants/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/sidequests/quest_files/sq703_wine_wars/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/minor_quests/quest_files/cg700_card_game/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/minor_quests/quest_files/mq7002_stubborn_knight/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/minor_quests/quest_files/mq7004_bleeding_tree/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/minor_quests/quest_files/mq7006_the_paths_of_destiny/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/minor_quests/quest_files/mq7017_talking_horse/characters/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/minor_quests/quest_files/mq7018_last_one/characters/" + nts + ".w2ent", true);

	//Enemy Templates
	if(!template) template = (CEntityTemplate)LoadResource("living_world/enemy_templates/" + nts + ".w2ent", true);
	if(!template) template = (CEntityTemplate)LoadResource("living_world/treasure_hunting/th1003_lynx/characters/" + nts + ".w2ent", true);

	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/living_world/enemy_templates/" + nts + ".w2ent", true);

	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/living_world/enemy_templates/" + nts + ".w2ent", true);

	//Monsters
	if(!template) template = (CEntityTemplate)LoadResource("characters/npc_entities/monsters/" + nts + ".w2ent", true);

	if(!template) template = (CEntityTemplate)LoadResource("dlc/ep1/data/characters/npc_entities/monsters/" + nts + ".w2ent", true);

	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/characters/npc_entities/monsters/" + nts + ".w2ent", true);

	//Merchants
	if(!template) template = (CEntityTemplate)LoadResource("dlc/bob/data/living_world/merchants/" + nts + ".w2ent", true);

	//Last Resort
	if(!template) template = (CEntityTemplate)LoadResource(nam);
	
	return template;
}

function MCM_AddSwordIfNeeded(npc : CNewNPC)
{
	var humanComp : CR4HumanoidCombatComponent;
	var inventory : CInventoryComponent;
	var added : array<SItemUniqueId>;
	var equipped : bool;
	
	humanComp = (CR4HumanoidCombatComponent)npc.GetComponentByClassName('CR4HumanoidCombatComponent');
	
	if(humanComp)
	{
		inventory = (CInventoryComponent) npc.GetComponentByClassName('CInventoryComponent');
		
		if(inventory)
		{
			added = inventory.AddAnItem('NPC Short Steel Sword', 1);//NPC Skellige sword 2
		}
	}
}
/*
function mod_scm_SpawnNPCFromData(data : MCMSpawnData, optional startFollowing : bool) : CNewNPC
{
	return mod_scm_SpawnNPC(data.nam, data.niceName, data.appearance, data.mortal, data.isSpecial, data.level, startFollowing);
}
	
function mod_scm_SpawnNPC(nam : name, optional niceName : name, optional appearance : name, optional mortal : bool, optional isSpecial : bool, optional level : int, optional startFollowing : bool) : CNewNPC
{
	var npc : CNewNPC;
	var pos : Vector;
	var rot : EulerAngles;
	var template : CEntityTemplate;
	var taglist : array<CName>;
			
	LogChannel('ModSpawnCompanions', "Spawning With Params: Name=" + nam + ", NiceName=" + niceName + ", Appearance=" + appearance + ", Mortal=" + mortal + ", Special=" + isSpecial + ", Level=" + level + ", SF=" + startFollowing);
	
	nam = MCM_ConvertName(nam);
	
	if(isSpecial)
	{
		npc = mod_scm_GetNPC(nam, ST_Special);
		if(npc)
		{
			mod_scm_RemoveNPC(npc);
		}
	}
	
	template = MCM_GetEntityTemplate(nam);

	if(template)
	{
		if(!IsNameValid(niceName)) niceName = mod_scm_GetSCM().nicifyName(nam);
	
		if(!IsNameValid(appearance))
		{
			appearance = MCM_GetDefaultAppearance(nam);
		}
				
		if(level < 1) level = GetWitcherPlayer().GetLevel();
			
		LogChannel('ModSpawnCompanions', "Spawning: Name=" + nam + ", NiceName=" + niceName + ", Appearance=" + appearance + ", Mortal=" + mortal + ", Special=" + isSpecial + ", Level=" + level + ", SF=" + startFollowing);
	
		taglist.PushBack(nam);
		taglist.PushBack('GeraltsBFF');
		if(isSpecial) taglist.PushBack('GeraltsSpecialBFF');
		taglist.PushBack('mod_scm_dontinit'); //Used to make sure we can initialize the NPC first. Checked in the CNewNPC class (and removed if found)
		taglist.PushBack(theGame.params.TAG_NPC_IN_PARTY); //Make their actions appear in the left console thing (i.e. 'Triss hits drowner for 564')
		
		pos = thePlayer.GetWorldPosition() + VecRingRand(1.0, 4.0);
	
		npc = (CNewNPC)theGame.CreateEntity(template, pos, rot, true, true, false, PM_Persist, taglist);
		
		MCM_AddSwordIfNeeded(npc);
		
		//Run our own custom initialization.
		npc.scmcc.initFirstSpawned(nam, niceName, appearance, level, mortal, isSpecial);
	
		if(startFollowing) npc.scmcc.StartFollowing();
		
		npc.scmcc.PostSpawnedInit();
	}
	
	return npc;
}*/
