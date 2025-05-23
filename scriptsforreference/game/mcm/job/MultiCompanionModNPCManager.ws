
class MCM_NPCEntry
{
    public var npcName : name;

    public var idleAnimation : name;
    
    public var defaultAppearance : name;
    public var nakedAppearance : name;
    public var underwearAppearance : name;

    public var customDialogue : String;
    public var naughtyScene : String;
    public var naughtySceneRequirements : array<MCM_SFactCheck>;
    public var spawnEntries : array<MCM_NPCSpawnEntry>;
    
    public var manager : MCM_NPCManager;

    public function getSpawnEntryForLevel(level : EAreaName) : MCM_NPCSpawnEntry
    {
        var i : int;
        for(i = spawnEntries.Size()-1; i >= 0; i-=1) {
            if(spawnEntries[i].level == level)
            {
                return spawnEntries[i];
            }
        }
        return NULL;
    }

    public function newSpawnEntry(level : EAreaName) : MCM_NPCSpawnEntry
    {
        var npcEntry : MCM_NPCSpawnEntry;
        npcEntry = new MCM_NPCSpawnEntry in this;
        npcEntry.npcEntry = this;
        npcEntry.level = level;
        this.spawnEntries.PushBack(npcEntry);
        return npcEntry;
    }

    public function setAppearances(optional normal, naked, underwear : name) : MCM_NPCEntry
    {
        this.defaultAppearance = normal;
        this.nakedAppearance = naked;
        this.underwearAppearance = underwear;
        return this;
    }

    public function setIdleAnimation(idleAnimation : name) : MCM_NPCEntry
    {
        this.idleAnimation = idleAnimation;
        return this;
    }

    public function setDialogue(dialogueRes : String) : MCM_NPCEntry
    {
        this.customDialogue = dialogueRes;
        return this;
    }

    public function setNaughtyScene(naughtySceneRes : String) : MCM_NPCEntry
    {
        this.naughtyScene = naughtySceneRes;
        return this;
    }

    public function addNaughtySceneCondition(factName : name, operator : EOperator, value : int) : MCM_NPCEntry
	{
		var fact : MCM_SFactCheck;
		
		fact.factName = factName;
		fact.operator = operator;
		fact.value = value;
	
		naughtySceneRequirements.PushBack(fact);
		return this;
	}

    public function satisfiesNaughtyRequirements() : bool
	{
		var i : int;
		if(FactsQuerySum('mod_scm_AllowAllNaughty') >= 1) return true;
		if(naughtySceneRequirements.Size() == 0) return true;
		
		for(i = naughtySceneRequirements.Size()-1; i >= 0; i-=1)
		{
			if(!MCM_CheckFact(naughtySceneRequirements[i]))
			{
				return false;
			}
		}
		return true;
	}
}

class MCM_NPCSpawnEntry
{
    public var npcEntry : MCM_NPCEntry;
    public var scheduleName : name;
    public var level : EAreaName;
    public var defaultSpawnPosition : Vector;
    public var defaultSpawnRotation : EulerAngles;
    public var spawnRequirements : array<MCM_SFactCheck>;
    public var spawnFact : name;
    private var orConditions : bool;

    public var npcToHide : name;
    public var npcToHideFact : name;

    public function back() : MCM_NPCEntry
    {
        return npcEntry;
    }

    public function setSpawnPosition(position : Vector, optional rotation : EulerAngles) : MCM_NPCSpawnEntry
    {
        this.defaultSpawnPosition = position;
        this.defaultSpawnRotation = rotation;
        return this;
    }

    public function setSchedule(scheduleName : name) : MCM_NPCSpawnEntry
    {
        this.scheduleName = scheduleName;
        return this;
    }

    public function canSpawn() : bool
    {
	var i, sz : int;
        if(FactsQuerySum(this.spawnFact) >= 1) return false;
		if(FactsQuerySum('mod_scm_enabled') >= 1) return true;
		sz = spawnRequirements.Size();

        if(this.orConditions)
        {
            for(i = 0; i < sz; i+=1)
            {
                if(MCM_CheckFact(spawnRequirements[i]))
                {
                    return true;
                }
            }
            return sz==0;
        }
        else
        {
            for(i = 0; i < sz; i+=1)
            {
                if(!MCM_CheckFact(spawnRequirements[i]))
                {
                    return false;
                }
            }
            return true;
        }
    }

    public function setSpawnConditionsOr() : MCM_NPCSpawnEntry
    {
        this.orConditions = true;
        return this;
    }

    public function addSpawnCondition(factName : name, operator : EOperator, value : int) : MCM_NPCSpawnEntry
    {
	var fact : MCM_SFactCheck;
		
	fact.factName = factName;
	fact.operator = operator;
	fact.value = value;
	
	spawnRequirements.PushBack(fact);
	return this;
    }

    public function setSpawnFact(fact : name) : MCM_NPCSpawnEntry
    {
        var registry : MCM_NPCSpawnFactRegistry;
        this.spawnFact = fact;
        registry = this.npcEntry.manager.GetSpawnFactRegistry(this.level);
        registry.entries.PushBack(this);
        return this;
    }

    public function setVanillaNPCToHide(vanillaName : name, factCheck : name) : MCM_NPCSpawnEntry
    {
        this.npcToHide = vanillaName;
        this.npcToHideFact = factCheck;
        this.npcEntry.manager.registerHider(level, this);
        return this;
    }

    public function unhideOtherNPC()
    {
        var npc : CNewNPC;
        if(IsNameValid(this.npcToHide))
        {
            npc = theGame.GetNPCByTag(this.npcToHide);
            if(npc) {
                MCM_ShowNPC(npc);
            }
        }
    }

    public function hideOtherNPC()
    {
        var npc : CNewNPC;
        if(IsNameValid(this.npcToHide))
        {
            npc = theGame.GetNPCByTag(this.npcToHide);
            if(npc) {
                MCM_HideNPC(npc);
            }
        }
    }
}

class MCM_NPCSpawnFactRegistry
{
    public var level : EAreaName;
    public var levelName : String;
    public var entries : array<MCM_NPCSpawnEntry>;
}

class MCM_NPCManager
{
    private var isInit : bool; default isInit = false;
	public function init()
	{
	    if(isInit) return;
	    isInit = true;
            hiders.Grow(20);//Enough room to store all area enums
            InitSpecialNPCs();
	}

    var hiders : array<array<MCM_NPCSpawnEntry>>;
    
    function registerHider(area : EAreaName, spawnEntry : MCM_NPCSpawnEntry)
    {
        if(area < this.hiders.Size())
        {
            hiders[area].PushBack(spawnEntry);
        }
        else
        {
            LogSCM("Hider area("+area+") int("+((int)area)+") out of range(" + hiders.Size() + ")");
        }
    }

    public var spawnFactRegistries : array<MCM_NPCSpawnFactRegistry>;

    public function shouldHideOtherNPC(npc : CNewNPC) : bool
    {
        var level : EAreaName = MCM_GetAreaName();
        var i : int;
        var entries : array<MCM_NPCSpawnEntry>;

        if(level < hiders.Size())
        {
            entries = hiders[level];
            for(i = entries.Size()-1; i >= 0; i-=1)
            {
                if(npc.HasTag(entries[i].npcToHide) && FactsQuerySum(entries[i].npcToHideFact) > 0 && entries[i].canSpawn())
                {
                    return true;
                }
            }
        }
        return false;
    }

    private function createSFR(area : EAreaName) : MCM_NPCSpawnFactRegistry
    {
        var sfr : MCM_NPCSpawnFactRegistry;
        sfr = new MCM_NPCSpawnFactRegistry in this;
        sfr.level = area;
        sfr.levelName = MCM_AreaToName(area);
        spawnFactRegistries.PushBack(sfr);
        return sfr;
    }

    public function GetSpawnFactRegistry(area : EAreaName) : MCM_NPCSpawnFactRegistry
    {
        var i, sz : int;
        sz = this.spawnFactRegistries.Size();
        for(i = 0; i < sz; i+=1) {
            if(this.spawnFactRegistries[i].level == area) {
                return this.spawnFactRegistries[i];
            }
        }
        return createSFR(area);
    }

    private function GetNPCInWorld(npcEntry : MCM_NPCEntry) : CNewNPC
    {
        var npcs : array<CNewNPC>;
        var i : int;
        theGame.GetNPCsByTag('GeraltsBFF', npcs);
        for(i = npcs.Size()-1; i >= 0; i-=1)
        {
            if(npcs[i].HasTag(npcEntry.npcName))
            {
                if(npcs[i].scmcc)
                {
                    return npcs[i];
                } else { LogSCM("!!!!GeraltsBFF doesn't have SCMCC object!!!!"); }
            }
        }
        return NULL;
    }

    private function spawnNPC(npcEntry : MCM_NPCEntry, spawner : MCM_NPCSpawnEntry) : CNewNPC
    {
        var npc : CNewNPC;
        
        npc = MCM_SpawnNPCParams(npcEntry.npcName, /*nicename*/, npcEntry.defaultAppearance, false, true, GetWitcherPlayer().GetLevel(), false,
                                spawner.defaultSpawnPosition, spawner.defaultSpawnRotation);
        spawner.hideOtherNPC();
        return npc;
    }

    private function checkNPCState(npcEntry : MCM_NPCEntry, spawner : MCM_NPCSpawnEntry, npc : CNewNPC)
    {
        if(spawner.canSpawn())
        {
            if(theInput.GetContext() == 'Exploration')
            {
                if(IsNameValid(spawner.scheduleName))
                {
                    MCM_GetMCM().JobManager.assignWorker(npc, npcEntry.npcName, spawner.scheduleName);
                }
                else
                {
                    npc.TeleportWithRotation(spawner.defaultSpawnPosition, spawner.defaultSpawnRotation);
                }
            }
        }
        else
        {
            spawner.unhideOtherNPC();
            //The NPC shouldn't exist. Get rid of them
            npc.Destroy();
        }
    }

    private function destroyNpcIfNotSeen(npc : CNewNPC)
    {
        var dot : float;
        dot = VecDot(theCamera.GetCameraDirection(), (npc.GetWorldPosition() - thePlayer.GetWorldPosition())  );
        if(dot < -20)
        {
            LogSCM("Destroying NPC coz I looked away");
            npc.Destroy();
        }
    }

    private function shouldSpawn() : bool
    {
        return (FactsQuerySum('mod_scm_enabled') >= 1 || FactsQuerySum('mod_scm_disabled') == 0);
    }

    public function update()
    {
        var i : int;
        var npc : CNewNPC;
        var level : EAreaName = MCM_GetAreaName();
        var npcEntry : MCM_NPCEntry;
        var npcSpawner : MCM_NPCSpawnEntry;
        var shouldSpawn : bool;
        shouldSpawn = this.shouldSpawn();

        for(i = npcEntries.Size()-1; i>=0; i-=1)
        {
            npcEntry = npcEntries[i];
            npcSpawner = npcEntry.getSpawnEntryForLevel(level);
            if(npcSpawner)
            {
                npc = GetNPCInWorld(npcEntries[i]);
                if(!npc)
                {
                    if(shouldSpawn && npcSpawner.canSpawn())
                    {
                        npc = spawnNPC(npcEntry, npcSpawner);
                        npc.scmcc.justSpawned = true;
                    }
                    else
                    {
                        continue;
                    }
                }

                if(npc)
                {
                    if(!npc.scmcc.IsFollowing())
                    {
                        if(shouldSpawn)
                        {
                            checkNPCState(npcEntry, npcSpawner, npc);
                            npc.scmcc.justSpawned = false;
                        }
                        else
                        {
                            MCM_GetMCM().JobManager.cancelWorker(npc);
                            destroyNpcIfNotSeen(npc);
                        }
                    }
                }
                else
                {
                    LogSCM("!!!Couldn't spawn NPC: " + npcEntry + "!!!");
                }
            }
        }
    }

    private var npcEntries : array<MCM_NPCEntry>;

    public function GetNpcEntry(npcName : name) : MCM_NPCEntry
    {
        var i : int;
        for(i = npcEntries.Size()-1; i >= 0; i-=1)
        {
            if(npcEntries[i].npcName == npcName)
            {
                return npcEntries[i];
            }
        }
        return NULL;
    }

    private function NewNpcEntry(npcName : name) : MCM_NPCEntry
    {
        var npcEntry : MCM_NPCEntry;
        npcEntry = new MCM_NPCEntry in this;
        npcEntry.npcName = npcName;
        npcEntry.manager = this;
        npcEntries.PushBack(npcEntry);
        return npcEntry;
    }

//q705_ciri
//q705_dandelion
//q705_triss
//q705_yen

    private function InitSpecialNPCs()
    {
        
// enum EOperator
// {
// 	EO_Equal,
// 	EO_NotEqual,
// 	EO_Less,
// 	EO_LessEqual,
// 	EO_Greater,
// 	EO_GreaterEqual,
// }

	NewNpcEntry('anna_henrietta')

		.newSpawnEntry(11)
			.setSchedule('anarietta_1')
			.setSpawnPosition(Vector(-717.214, -1198.029, 164.183), EulerAngles(0, 212.0, 0))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_completed', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_henrietta_alive', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_BOB_Anna')
			.setVanillaNPCToHide('anna_henrietta', 'q705_completed')
			.back()

			.setAppearances('anna_henrietta', 'anna_henrietta', 'anna_henrietta');

	NewNpcEntry('avallach')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('avallach')
			.setSpawnPosition(Vector(733.074, 1736.485, 9.669))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_NOV_Avallach')
			.back()

			.setAppearances('avallach_uncloaked', 'avallach_uncloaked', 'avallach_uncloaked')
			.setDialogue("dlc\mod_spawn_companions\dialogue\avallachFollow.w2scene");

	NewNpcEntry('baron')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('baron')
			.setSpawnPosition(Vector(154.846, 183.357, 36.862), EulerAngles(0, -32.0, 0))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('q107_anna_is_crazy', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_NML_Baron')
			.back()

			.setAppearances('baron', 'baron', 'baron')
			.setDialogue("dlc\mod_spawn_companions\dialogue\baronFollow.w2scene");

	NewNpcEntry('bart_the_troll')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('bart')
			.setSpawnPosition(Vector(669.914, 1988.639, 6.727), EulerAngles(0, -12.0, 0))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_NOV_Bart')
			.back()

			.setAppearances('cave_troll_01', 'cave_troll_01', 'cave_troll_01');

	NewNpcEntry('palmerin')

		.newSpawnEntry(11)
			.setSchedule('palmerin')
			.setSpawnPosition(Vector(-701.767, -1192.466, 163.749), EulerAngles(0, 78.0, 0))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_completed', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_BOB_Palmerin')
			.back()

			.setAppearances('palmerin', 'palmerin', 'palmerin');

	NewNpcEntry('shop_17_belgard_wine_blacksmith')

		.newSpawnEntry(11)
			.setSchedule('blacksmith')
			.setSpawnPosition(Vector(-234.371, -1594.909, 50.166), EulerAngles(0, 107.0, 0))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_completed', EO_GreaterEqual, 1)
			.addSpawnCondition('sq703_completed', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_BOB_Blacksmith')
			.back()

			.setAppearances('__lw_belgard_wine_blacksmith', '__lw_belgard_wine_blacksmith', '__lw_belgard_wine_blacksmith');

	NewNpcEntry('q603_demolition_dwarf_companion')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('casimir')
			.setSpawnPosition(Vector(1714.175, 978.587, 6.513), EulerAngles(0, -126.0, 0))
			.addSpawnCondition('q603_safecracker_recruited', EO_GreaterEqual, 1)
			.addSpawnCondition('q603_demo_dwarf_survived', EO_GreaterEqual, 1)
			.setSpawnConditionsOr()
			.setSpawnFact('MCM_OXN_Casimir')
			.back()

			.setAppearances('casimir', 'casimir', 'casimir');

	NewNpcEntry('becca')

		.newSpawnEntry(AN_Skellige_ArdSkellig)
			.setSchedule('cerys')
			.setSpawnPosition(Vector(-164.166, 676.492, 94.349), EulerAngles(0, -144.0, 0))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('q203_cerys_saved', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_SKEL_Cerys')
			.setVanillaNPCToHide('becca', 'witcher3_game_finished')
			.back()

			.setAppearances('__q208_crown', '__q208_crown', '__q208_crown')
			.setDialogue("dlc\mod_spawn_companions\dialogue\cerysFollowWithKiss.w2scene")
			.setNaughtyScene("dlc/mod_spawn_companions/naughty/cerys/anywhere.w2scene");

	NewNpcEntry('cirilla')

		.newSpawnEntry(AN_Kaer_Morhen)
			.setSchedule('ciri')
			.setSpawnPosition(Vector(79.071, 15.051, 170.754))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('q502_ciri_dead', EO_LessEqual, 0)
			.setSpawnFact('MCM_KM_Ciri')
			.back()

		.newSpawnEntry(AN_Wyzima)
			.setSchedule('viz_main')
			.setSpawnPosition(Vector(11.624, 17.100, 11.652))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_ciri_empress', EO_GreaterEqual, 1)
			.addSpawnCondition('q502_ciri_dead', EO_LessEqual, 0)
			.setSpawnFact('MCM_VIZ_Ciri')
			.back()

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('novigrad_2')
			.setSpawnPosition(Vector(724.305, 1729.819, 14.208))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('q502_ciri_dead', EO_LessEqual, 0)
			.setSpawnFact('MCM_NOV_Ciri')
			.back()

		.newSpawnEntry(11)
			.setSchedule('ciri')
			.setSpawnPosition(Vector(-393.479, -798.528, 35.335))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_completed', EO_GreaterEqual, 1)
			.addSpawnCondition('mq7024_bed_upgraded', EO_GreaterEqual, 1)
			.addSpawnCondition('mq7024_guest_room_done', EO_GreaterEqual, 1)
			.addSpawnCondition('q502_ciri_dead', EO_LessEqual, 0)
			.setSpawnFact('MCM_BOB_Ciri')
			.setVanillaNPCToHide('q705_ciri', 'q705_ciri_met')
			.back()

			.setAppearances('ciri', '__q205_naked', '__q205_bandaged_naked')
			.setDialogue("dlc\mod_spawn_companions\dialogue\ciriFollowWithHug.w2scene")
			.setNaughtyScene("dlc/mod_spawn_companions/naughty/ciri/anywhere.w2scene");

	NewNpcEntry('cyprian_willey')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('cyprian')
			.setSpawnPosition(Vector(525.024, 2164.306, 41.228), EulerAngles(0, 110.0, 0))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('q310_met_dudu_as_whoreson', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_NOV_Cyprian')
			.back()

			.setAppearances('__q310_dudu', '__q310_dudu', '__q310_dudu');

	NewNpcEntry('damien')

		.newSpawnEntry(11)
			.setSchedule('damien_1')
			.setSpawnPosition(Vector(-716.847, -1200.163, 164.182), EulerAngles(0, -29.0, 0))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_completed', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_BOB_Damien')
			.setVanillaNPCToHide('damien', 'q705_completed')
			.back()

			.setAppearances('scars', 'scars', 'scars');

	NewNpcEntry('dandelion')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('dandelion')
			.setSpawnPosition(Vector(721.943, 1733.979, 4.640))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_NOV_Dandelion')
			.setVanillaNPCToHide('dandelion', 'witcher3_game_finished')
			.back()

		.newSpawnEntry(11)
			.setSchedule('dandelion_1')
			.setSpawnPosition(Vector(-400.532, -800.573, 39.133))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_completed', EO_GreaterEqual, 1)
			.addSpawnCondition('mq7024_bed_upgraded', EO_GreaterEqual, 1)
			.addSpawnCondition('mq7024_guest_room_done', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_BOB_Dandelion')
			.setVanillaNPCToHide('q705_dandelion', 'q705_dand_intro')
			.back()

			.setAppearances('dandelion', 'dandelion', 'dandelion')
			.setDialogue("dlc\mod_spawn_companions\dialogue\dandelionFollow.w2scene");

	NewNpcEntry('dettlaff_van_eretein_vampire')

		.newSpawnEntry(11)
			.setSchedule('dettlaff_1')
			.setSpawnPosition(Vector(-238.639, -1290.889, 7.466), EulerAngles(0, -27.0, 0))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_completed', EO_GreaterEqual, 1)
			.addSpawnCondition('q704_syanna_dies_dettlaff_lives', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_BOB_Dettlaff')
			.back()

			.setAppearances('dettlaff_vampire_morph', 'dettlaff_vampire_morph', 'dettlaff_vampire_morph');

	NewNpcEntry('dijkstra')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('dijkstra')
			.setSpawnPosition(Vector(662.536, 1997.408, 13.078), EulerAngles(0, -67.0, 0))
			.addSpawnCondition('q310_dijkstras_other_leg', EO_GreaterEqual, 1)
			.addSpawnCondition('mq3035_fdb_roche_talar_dead', EO_GreaterEqual, 1)
			.setSpawnConditionsOr()
			.setSpawnFact('MCM_NOV_Dijkstra')
			.back()

			.setAppearances('djikstra', '__q302_djikstra_bathhouse')
			.setDialogue("dlc\mod_spawn_companions\dialogue\dijkstraFollow.w2scene");

	NewNpcEntry('mousesack')

		.newSpawnEntry(AN_Skellige_ArdSkellig)
			.setSchedule('ermion')
			.setSpawnPosition(Vector(1004.491, -39.523, 54.139), EulerAngles(0, 182.0, 0))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_SKEL_Ermion')
			.back()

			.setAppearances('mousesack', 'mousesack', 'mousesack');

	NewNpcEntry('eskel')

		.newSpawnEntry(AN_Kaer_Morhen)
			.setSchedule('witchers')
			.setSpawnPosition(Vector(79.071, 15.051, 170.754))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_KM_Eskel')
			.back()

		.newSpawnEntry(11)
			.setSchedule('eskel')
			.setSpawnPosition(Vector(-390.356, -793.699, 35.335))
			.addSpawnCondition('q705_ciri_met', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_dand_intro', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_triss_house_met', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_yen_first_met', EO_GreaterEqual, 1)
			.setSpawnConditionsOr()
			.setSpawnFact('MCM_BOB_Eskel')
			.back()

			.setAppearances('eskel', 'eskel', 'eskel')
			.setDialogue("dlc\mod_spawn_companions\dialogue\eskelFollow.w2scene");

	NewNpcEntry('q603_circus_artist_companion')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('eveline')
			.setSpawnPosition(Vector(1712.177, 976.938, 6.589), EulerAngles(0, -55.0, 0))
			.addSpawnCondition('q605_mirror_won', EO_GreaterEqual, 1)
			.addSpawnCondition('q605_mirror_banished', EO_GreaterEqual, 1)
			.setSpawnConditionsOr()
			.setSpawnFact('MCM_OXN_Eveline')
			.back()

			.setAppearances('eveline_gallo', 'eveline_gallo', 'eveline_gallo');

	NewNpcEntry('ewald')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('ewald')
			.setSpawnPosition(Vector(1715.735, 977.432, 6.510), EulerAngles(0, 54.0, 0))
			.addSpawnCondition('q603_horst_killed', EO_GreaterEqual, 1)
			.addSpawnCondition('q603_only_box', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_OXN_Ewald')
			.back()

			.setAppearances('ewald_borsody', 'ewald_borsody', 'ewald_borsody');

	NewNpcEntry('fringilla_vigo')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('fringilla')
			.setSpawnPosition(Vector(683.872, 1915.019, 25.590), EulerAngles(0, -83.0, 0))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_NOV_Fringilla')
			.back()

			.setAppearances('fringilla', 'fringilla', 'fringilla');

	NewNpcEntry('mq1058_lynx_witcher')

		.newSpawnEntry(AN_Kaer_Morhen)
			.setSchedule('witchers')
			.setSpawnPosition(Vector(71.921, 36.594, 170.753))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('mq1058_lynx_stash_opened', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_KM_Gaetan')
			.back()

			.setAppearances('gaetan', 'gaetan', 'gaetan');

	NewNpcEntry('graden')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('graden')
			.setSpawnPosition(Vector(1688.516, 1080.366, 3.366), EulerAngles(0, 33.0, 0))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_OXN_Graden')
			.back()

			.setAppearances('__q103_graden', '__q103_graden', '__q103_graden');

	NewNpcEntry('sq106_tauler')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('jad')
			.setSpawnPosition(Vector(728.025, 1973.637, 26.930), EulerAngles(0, 14.0, 0))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('sq106_finished', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_NOV_Jad')
			.back()

			.setAppearances('__sq106_Tauler', '__sq106_Tauler', '__sq106_Tauler');

	NewNpcEntry('von_gratz')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('joachim')
			.setSpawnPosition(Vector(712.323, 1998.528, 22.752), EulerAngles(0, 164.0, 0))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_NOV_Joachim')
			.setVanillaNPCToHide('von_gratz', 'witcher3_game_finished')
			.back()

			.setAppearances('__q308_von_gratz', '__q308_von_gratz', '__q308_von_gratz');

	NewNpcEntry('godling_johnny')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('johnny')
			.setSpawnPosition(Vector(1373.470, -592.128, 1.764), EulerAngles(0, -96.0, 0))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_NML_Johnny')
			.back()

			.setAppearances('godling_boy', 'godling_boy', 'godling_boy');

	NewNpcEntry('sq701_gregoire')

		.newSpawnEntry(11)
			.setSchedule('gregoire')
			.setSpawnPosition(Vector(-700.518, -1180.665, 163.060), EulerAngles(0, 36.0, 0))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_completed', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_BOB_Gregoire')
			.back()

			.setAppearances('gregoire', 'gregoire', 'gregoire');

	NewNpcEntry('guillaume')

		.newSpawnEntry(11)
			.setSchedule('guillaume')
			.setSpawnPosition(Vector(-695.083, -1172.468, 163.059), EulerAngles(0, 100.0, 0))
			.addSpawnCondition('sq701_guillaume_pond_epilogue', EO_GreaterEqual, 1)
			.addSpawnCondition('sq701_guillaume_egg_epilogue', EO_GreaterEqual, 1)
			.setSpawnConditionsOr()
			.setSpawnFact('MCM_BOB_Guillaume')
			.back()

			.setAppearances('guillaume', 'guillaume', 'guillaume');

	NewNpcEntry('hattori')

		.newSpawnEntry(11)
			.setSchedule('hattori')
			.setSpawnPosition(Vector(-365.447, -812.378, 31.149), EulerAngles(0, -4.0, 0))
			.addSpawnCondition('q705_ciri_met', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_dand_intro', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_triss_house_met', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_yen_first_met', EO_GreaterEqual, 1)
			.setSpawnConditionsOr()
			.setSpawnFact('MCM_BOB_Hattori')
			.back()

			.setAppearances('__q304_hattori', '__q304_hattori', '__q304_hattori');

	NewNpcEntry('hjalmar')

		.newSpawnEntry(AN_Skellige_ArdSkellig)
			.setSchedule('hjalmar')
			.setSpawnPosition(Vector(-162.475, 669.257, 94.352), EulerAngles(0, -142.0, 0))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('q202_hjalmar_saved', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_SKEL_Hjalmar')
			.setVanillaNPCToHide('hjalmar', 'witcher3_game_finished')
			.back()

			.setAppearances('hjalmar', 'hjalmar', 'hjalmar')
			.setDialogue("dlc\mod_spawn_companions\dialogue\hjalmarFollow.w2scene");

	NewNpcEntry('keira_metz')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('novigrad_3')
			.setSpawnPosition(Vector(731.703, 1735.171, 9.704))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('q109_keira_defeated', EO_Equal, 0)
			.addSpawnCondition('q109_keira_to_radovid', EO_Equal, 0)
			.setSpawnFact('MCM_NOV_Keira')
			.back()

		.newSpawnEntry(11)
			.setSchedule('keira')
			.setSpawnPosition(Vector(-360.028, -830.800, 29.162))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_completed', EO_GreaterEqual, 1)
			.addSpawnCondition('q109_keira_defeated', EO_Equal, 0)
			.addSpawnCondition('q109_keira_to_radovid', EO_Equal, 0)
			.setSpawnFact('MCM_BOB_Keira')
			.back()

			.setAppearances('keira_metz_sorceress', 'naked', 'naked_lingerie')
			.setDialogue("dlc\mod_spawn_companions\dialogue\keiraFollowWithKiss.w2scene")
			.setNaughtyScene("dlc/mod_spawn_companions/naughty/keira/anywhere.w2scene");

	NewNpcEntry('king_beggar')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('bedlam')
			.setSpawnPosition(Vector(684.304, 1726.658, 6.551), EulerAngles(0, -156.0, 0))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_NOV_Bedlam')
			.setVanillaNPCToHide('king_beggar', 'witcher3_game_finished')
			.back()

			.setAppearances('francis_bedlam', 'francis_bedlam', 'francis_bedlam');

	NewNpcEntry('mq7006_lady_of_the_lake')

		.newSpawnEntry(11)
			.setSchedule('nymph')
			.setSpawnPosition(Vector(-959.640, -776.304, 62.301), EulerAngles(0, -68.0, 0))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_completed', EO_GreaterEqual, 1)
			.addSpawnCondition('mq7006_done', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_BOB_Nymph')
			.back()

			.setAppearances('sq701_forest_nymph', 'sq701_forest_nymph', 'sq701_forest_nymph');

	NewNpcEntry('lambert')

		.newSpawnEntry(AN_Kaer_Morhen)
			.setSchedule('witchers')
			.setSpawnPosition(Vector(79.071, 15.051, 170.754))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('q403_lambert_dead', EO_Equal, 0)
			.setSpawnFact('MCM_KM_Lambert')
			.back()

		.newSpawnEntry(11)
			.setSchedule('lambert')
			.setSpawnPosition(Vector(-359.413, -828.605, 29.162))
			.addSpawnCondition('q705_ciri_met', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_dand_intro', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_triss_house_met', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_yen_first_met', EO_GreaterEqual, 1)
			.setSpawnConditionsOr()
			.setSpawnFact('MCM_BOB_Lambert')
			.back()

			.setAppearances('lambert', 'lambert', 'lambert')
			.setDialogue("dlc\mod_spawn_companions\dialogue\lambertFollow.w2scene");

	NewNpcEntry('letho')

		.newSpawnEntry(AN_Kaer_Morhen)
			.setSchedule('witchers')
			.setSpawnPosition(Vector(79.071, 15.051, 170.754))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('sq102_letho_alive', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_KM_Letho')
			.back()

		.newSpawnEntry(11)
			.setSchedule('letho')
			.setSpawnPosition(Vector(-360.877, -826.342, 29.098))
			.addSpawnCondition('q705_ciri_met', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_dand_intro', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_triss_house_met', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_yen_first_met', EO_GreaterEqual, 1)
			.setSpawnConditionsOr()
			.setSpawnFact('MCM_BOB_Letho')
			.back()

			.setAppearances('letho', 'letho', 'letho')
			.setDialogue("dlc\mod_spawn_companions\dialogue\lethoFollow.w2scene");

	NewNpcEntry('butler')

		.newSpawnEntry(11)
			.setSchedule('majordomo')
			.setSpawnPosition(Vector(-358.194, -829.568, 29.267))
			.addSpawnCondition('q705_ciri_met', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_dand_intro', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_triss_house_met', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_yen_first_met', EO_GreaterEqual, 1)
			.setSpawnConditionsOr()
			.setSpawnFact('MCM_BOB_Majordomo')
			.setVanillaNPCToHide('butler', 'q705_completed')
			.back()

			.setAppearances('__mq7024_majordomus', '__mq7024_majordomus', '__mq7024_majordomus');

	NewNpcEntry('margarita')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('margarita')
			.setSpawnPosition(Vector(685.057, 1915.091, 25.576), EulerAngles(0, 96.0, 0))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_NOV_Margarita')
			.back()

			.setAppearances('margaritta', 'margaritta', 'margaritta');

	NewNpcEntry('q002_huntsman')

		.newSpawnEntry(AN_Prologue_Village)
			.setSchedule('mislav')
			.setSpawnPosition(Vector(-40.327, -106.563, 7.586), EulerAngles(0, -62.0, 0))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_WO_Mislav')
			.back()

			.setAppearances('__q002_huntsman', '__q002_huntsman', '__q002_huntsman');

	NewNpcEntry('olgierd')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('olgierd')
			.setSpawnPosition(Vector(728.814, 1727.538, 9.632))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('q605_mirror_banished', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_NOV_Olgierd')
			.back()

			.setAppearances('olgierd', 'olgierd', 'olgierd')
			.setDialogue("dlc\mod_spawn_companions\dialogue\olgierdFollow.w2scene");

	NewNpcEntry('vampire_diva')

		.newSpawnEntry(11)
			.setSchedule('orianna')
			.setSpawnPosition(Vector(-353.836, -1445.387, 87.988), EulerAngles(0, -128.0, 0))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_completed', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_BOB_Orianna')
			.back()

			.setAppearances('oriana', 'oriana', 'oriana');

	NewNpcEntry('philippa_eilhart')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('philippa')
			.setSpawnPosition(Vector(725.434, 1725.918, 14.267))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_NOV_Philippa')
			.back()

			.setAppearances('filippa', 'filippa', 'filippa');

	NewNpcEntry('pryscilla')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('priscilla')
			.setSpawnPosition(Vector(726.642, 1729.139, 14.259))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_NOV_Priscilla')
			.setVanillaNPCToHide('priscilla', 'witcher3_game_finished')
			.back()

			.setAppearances('pryscilla', 'pryscilla', 'pryscilla');

	NewNpcEntry('q603_safecracker_companion')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('quinto')
			.setSpawnPosition(Vector(1714.890, 980.054, 6.586), EulerAngles(0, 145.0, 0))
			.addSpawnCondition('q603_demo_dwarf_recruited', EO_GreaterEqual, 1)
			.addSpawnCondition('q603_safecracker_survived', EO_GreaterEqual, 1)
			.setSpawnConditionsOr()
			.setSpawnFact('MCM_OXN_Quinto')
			.back()

			.setAppearances('quinto', 'quinto', 'quinto');

	NewNpcEntry('regis_terzieff_vampire')

		.newSpawnEntry(11)
			.setSchedule('regis')
			.setSpawnPosition(Vector(-403.095, -801.763, 25.507))
			.addSpawnCondition('q705_ciri_met', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_dand_intro', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_triss_house_met', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_yen_first_met', EO_GreaterEqual, 1)
			.setSpawnConditionsOr()
			.setSpawnFact('MCM_BOB_Regis')
			.back()

			.setAppearances('regis_human', 'regis_human', 'regis_human')
			.setDialogue("dlc\mod_spawn_companions\dialogue\regisFollow.w2scene");

	NewNpcEntry('rosa_var_attre')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('rosa_var_attre')
			.setSpawnPosition(Vector(711.462, 2071.586, 31.116))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_NOV_Rosa')
			.back()

			.setAppearances('rosa_fancing', 'rosa_fancing', 'rosa_fancing');

	NewNpcEntry('mh303_succbus_v2')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('salma')
			.setSpawnPosition(Vector(560.237, 1704.321, 6.491), EulerAngles(0, -62.0, 0))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('mh303_done', EO_GreaterEqual, 1)
			.addSpawnCondition('mh303_succubus_spared', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_NOV_Salma')
			.back()

			.setAppearances('succubus_06', 'succubus_06', 'succubus_06');

	NewNpcEntry('shani')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('shani')
			.setSpawnPosition(Vector(1670.901, 965.386, 3.517))
			.addSpawnCondition('q605_mirror_won', EO_GreaterEqual, 1)
			.addSpawnCondition('q605_mirror_banished', EO_GreaterEqual, 1)
			.setSpawnConditionsOr()
			.setSpawnFact('MCM_OXN_Shani')
			.back()

		.newSpawnEntry(11)
			.setSchedule('shani')
			.setSpawnPosition(Vector(-398.938, -801.685, 39.132))
			.addSpawnCondition('q705_ciri_met', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_dand_intro', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_triss_house_met', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_yen_first_met', EO_GreaterEqual, 1)
			.setSpawnConditionsOr()
			.setSpawnFact('MCM_BOB_Shani')
			.back()

			.setAppearances('shani', 'shani_naked', 'shani_lingerie')
			.setDialogue("dlc\mod_spawn_companions\dialogue\shaniFollowWithKiss.w2scene")
			.setNaughtyScene("dlc/mod_spawn_companions/naughty/shani/anywhere.w2scene");

	NewNpcEntry('syanna')

		.newSpawnEntry(11)
			.setSchedule('syanna_1')
			.setSpawnPosition(Vector(-674.476, -1188.673, 164.239), EulerAngles(0, 40.0, 0))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_completed', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_syanna_correct', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_BOB_Syanna')
			.back()

			.setAppearances('syanna', 'syanna_naked', 'syanna_naked_cens')
			.setDialogue("dlc\mod_spawn_companions\dialogue\syannaFollowWithKiss.w2scene")
			.setNaughtyScene("dlc/mod_spawn_companions/naughty/syanna/anywhere.w2scene");

	NewNpcEntry('tamara')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('tamara')
			.setSpawnPosition(Vector(1684.589, 1083.145, 8.506), EulerAngles(0, 90.0, 0))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_OXN_Tamara')
			.back()

			.setAppearances('tamara', 'tamara', 'tamara');

	NewNpcEntry('talar')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('thaler')
			.setSpawnPosition(Vector(725.367, 1732.656, 4.636))
			.addSpawnCondition('q310_dijkstras_other_leg', EO_GreaterEqual, 1)
			.addSpawnCondition('mq3035_fdb_dijkstra_dead', EO_GreaterEqual, 1)
			.setSpawnConditionsOr()
			.setSpawnFact('MCM_NOV_Thaler')
			.back()

			.setAppearances('talar', 'talar', 'talar');

	NewNpcEntry('triss')

		.newSpawnEntry(AN_Kaer_Morhen)
			.setSchedule('triss')
			.setSpawnPosition(Vector(79.071, 15.051, 170.754))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_KM_Triss')
			.back()

		.newSpawnEntry(AN_Wyzima)
			.setSchedule('viz_main')
			.setSpawnPosition(Vector(11.624, 17.100, 11.652))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_ciri_empress', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_VIZ_Triss')
			.back()

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('novigrad_1')
			.setSpawnPosition(Vector(722.200, 1732.815, 14.243))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_NOV_Triss')
			.back()

		.newSpawnEntry(11)
			.setSchedule('triss')
			.setSpawnPosition(Vector(-392.213, -794.601, 35.335))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_completed', EO_GreaterEqual, 1)
			.addSpawnCondition('mq7024_bed_upgraded', EO_GreaterEqual, 1)
			.addSpawnCondition('mq7024_guest_room_done', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_BOB_Triss')
			.setVanillaNPCToHide('q705_triss', 'q705_triss_house_met')
			.back()

			.setAppearances('triss', 'triss_naked', 'triss_lingerie')
			.setDialogue("dlc\mod_spawn_companions\dialogue\trissFollowWithKiss.w2scene")
			.setNaughtyScene("dlc/mod_spawn_companions/naughty/triss/anywhere.w2scene");

	NewNpcEntry('udalryk')

		.newSpawnEntry(AN_Skellige_ArdSkellig)
			.setSchedule('udalryk')
			.setSpawnPosition(Vector(-1647.948, 1318.457, 19.269), EulerAngles(0, -31.0, 0))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_SKEL_Udalryk')
			.back()

			.setAppearances('__q203_eye_patch', '__q203_eye_patch', '__q203_eye_patch');

	NewNpcEntry('vernon_roche')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('vernon')
			.setSpawnPosition(Vector(724.281, 1733.442, 4.636))
			.addSpawnCondition('q310_dijkstras_other_leg', EO_GreaterEqual, 1)
			.addSpawnCondition('mq3035_fdb_dijkstra_dead', EO_GreaterEqual, 1)
			.setSpawnConditionsOr()
			.setSpawnFact('MCM_NOV_Vernon')
			.setVanillaNPCToHide('roche', 'witcher3_game_finished')
			.back()

			.setAppearances('roche', 'roche', 'roche')
			.setDialogue("dlc\mod_spawn_companions\dialogue\vernonFollow.w2scene");

	NewNpcEntry('ves')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('ves')
			.setSpawnPosition(Vector(722.670, 1727.399, 14.259))
			.addSpawnCondition('q310_dijkstras_other_leg', EO_GreaterEqual, 1)
			.addSpawnCondition('mq3035_fdb_dijkstra_dead', EO_GreaterEqual, 1)
			.setSpawnConditionsOr()
			.setSpawnFact('MCM_NOV_Ves')
			.back()

			.setAppearances('ves', 'ves', 'ves');

	NewNpcEntry('vesemir')

		.newSpawnEntry(AN_Kaer_Morhen)
			.setSchedule('vesemir')
			.setSpawnPosition(Vector(79.071, 15.051, 170.754))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('q403_vesemir_buried', EO_Equal, 0)
			.setSpawnFact('MCM_KM_Vesemir')
			.back()

			.setAppearances('vesemir', 'vesemir', 'vesemir')
			.setDialogue("dlc\mod_spawn_companions\dialogue\vesemirFollow.w2scene");

	NewNpcEntry('sq701_vivienne')

		.newSpawnEntry(11)
			.setSchedule('vivienne')
			.setSpawnPosition(Vector(-696.381, -1171.254, 163.059), EulerAngles(0, 118.0, 0))
			.addSpawnCondition('sq701_guillaume_pond_epilogue', EO_GreaterEqual, 1)
			.addSpawnCondition('sq701_guillaume_egg_epilogue', EO_GreaterEqual, 1)
			.setSpawnConditionsOr()
			.setSpawnFact('MCM_BOB_Vivienne')
			.back()

			.setAppearances('vivienne_de_tabris', 'vivienne_de_tabris_naked');

	NewNpcEntry('wolf_white_lvl3__alpha')

		.newSpawnEntry(11)
			.setSchedule('wolf')
			.setSpawnPosition(Vector(-353.704, -808.596, 30.300), EulerAngles(0, 0.0, 0))
			.addSpawnCondition('q705_ciri_met', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_dand_intro', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_triss_house_met', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_yen_first_met', EO_GreaterEqual, 1)
			.setSpawnConditionsOr()
			.setSpawnFact('MCM_BOB_Wolf')
			.back()

			.setAppearances('wolf_white_01', 'wolf_white_01', 'wolf_white_01');

	NewNpcEntry('yennefer')

		.newSpawnEntry(AN_Kaer_Morhen)
			.setSchedule('yennefer')
			.setSpawnPosition(Vector(79.071, 15.051, 170.754))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_KM_Yennefer')
			.back()

		.newSpawnEntry(AN_Wyzima)
			.setSchedule('viz_main')
			.setSpawnPosition(Vector(11.624, 17.100, 11.652))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_ciri_empress', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_VIZ_Yennefer')
			.back()

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('novigrad_1')
			.setSpawnPosition(Vector(725.623, 1735.522, 14.243))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_NOV_Yennefer')
			.back()

		.newSpawnEntry(11)
			.setSchedule('yennefer')
			.setSpawnPosition(Vector(-396.272, -798.108, 35.335))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_completed', EO_GreaterEqual, 1)
			.addSpawnCondition('mq7024_bed_upgraded', EO_GreaterEqual, 1)
			.addSpawnCondition('mq7024_guest_room_done', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_BOB_Yennefer')
			.setVanillaNPCToHide('q705_yen', 'q705_yen_first_met')
			.back()

			.setAppearances('yennefer_travel_outfit', 'yennefer_naked', 'yennefer_lingerie')
			.setDialogue("dlc\mod_spawn_companions\dialogue\yenneferFollowWithKiss.w2scene")
			.setNaughtyScene("dlc/mod_spawn_companions/naughty/yennefer/anywhere.w2scene");

	NewNpcEntry('zoltan_chivay')

		.newSpawnEntry(AN_NMLandNovigrad)
			.setSchedule('zoltan')
			.setSpawnPosition(Vector(722.598, 1739.539, 4.562))
			.addSpawnCondition('witcher3_game_finished', EO_GreaterEqual, 1)
			.setSpawnFact('MCM_NOV_Zoltan')
			.setVanillaNPCToHide('zoltan', 'witcher3_game_finished')
			.back()

		.newSpawnEntry(11)
			.setSchedule('zoltan')
			.setSpawnPosition(Vector(-399.885, -800.082, 39.132))
			.addSpawnCondition('q705_ciri_met', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_dand_intro', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_triss_house_met', EO_GreaterEqual, 1)
			.addSpawnCondition('q705_yen_first_met', EO_GreaterEqual, 1)
			.setSpawnConditionsOr()
			.setSpawnFact('MCM_BOB_Zoltan')
			.back()

			.setAppearances('zoltan', 'zoltan', 'zoltan')
			.setDialogue("dlc\mod_spawn_companions\dialogue\zoltanFollow.w2scene");

        LogSCM("Initialized Special NPC data: " + npcEntries.Size());
    }
}

function MCM_HideNPC(npc : CActor) {
    npc.SetHideInGame(false);
    npc.SetGameplayVisibility(false);
    npc.SetVisibility(false);
}

function MCM_ShowNPC(npc : CActor) {
    npc.SetHideInGame(true);
    npc.SetGameplayVisibility(true);
    npc.SetVisibility(true);
}

//Called during the same tick that the NPC is being spawned.
function MCM_IJustSpawned(npc : CNewNPC)
{
    //Hide the default NPCs that spawn around the world. Replace them with our own!
    if(MCM_GetMCM().NPCManager.shouldHideOtherNPC(npc))
    {
        MCM_HideNPC(npc);
    }
}
