/*
Copyright © CD Projekt RED & Jamezo97 2017
*/

class mod_scm_SpawnPos
{
	/*
	AN_NMLandNovigrad 1
	AN_Skellige_ArdSkellig 2
	AN_Kaer_Morhen 3
	AN_Prologue_Village 4
	AN_Wyzima 5
	AN_Island_of_Myst 6
	AN_Spiral 7
	AN_Prologue_Village_Winter 8
	AN_Velen 9
	AN_CombatTestLevel 10
	AN_Bob 11
	*/

	public var Area : EAreaName;
	public var Position : Vector;
	public var Rotation : EulerAngles;
}

class mod_scm_SpawnCondition
{
	var factName : name;
	var shouldBeDisabled : bool;
	
	public function check() : bool
	{
		if(shouldBeDisabled)
		{
			return FactsQuerySum(factName) == 0;
		}
		else
		{
			return FactsQuerySum(factName) > 0;
		}
	}
}

class mod_scm_SpecialNPC
{
	public var Name : name; default Name = 'undefined';
	public var SpawnPos : mod_scm_SpawnPos;
	public var CustomDialog : string;
	public var HasCustomDialog : bool; default HasCustomDialog = false;
	public var IdleAnimation : name;
	public var HasIdleAnimation : bool; default HasIdleAnimation = false;
	public var FixIdleAnimInPos : bool; default FixIdleAnimInPos = false;
	public var IdleAnimationSpeed : float; default IdleAnimationSpeed = 1.0;

	public var spawnConditions : array<mod_scm_SpawnCondition>;
	private var spawnConditionAND : bool; default spawnConditionAND = false;
	
	public var HasNaughtyScene : bool;
	public var NaughtyScene : string;
	public var NaughtySceneRequirements : array<MCM_SFactCheck>;
	
	public function setNaughtyScene(naughtyScene : string) : mod_scm_SpecialNPC
	{
		this.NaughtyScene = naughtyScene;
		this.HasNaughtyScene = true;
		return this;
	}
	
	public function SatisfiesNaughtyRequirements() : bool
	{
		var i : int;
		
		if(NaughtySceneRequirements.Size() == 0) return true;
		
		for(i = NaughtySceneRequirements.Size()-1; i >= 0; i-=1)
		{
			if(!MCM_CheckFact(NaughtySceneRequirements[i]))
			{
				return false;
			}
		}
		
		return true;
	}
	
	public function AddNaughtySceneRequirement(factName : name, operator : EOperator, value : int) : mod_scm_SpecialNPC
	{
		var fact : MCM_SFactCheck;
		
		fact.factName = factName;
		fact.operator = operator;
		fact.value = value;
	
		NaughtySceneRequirements.PushBack(fact);
		return this;
	}
	
	public function setIdleAnim(in_idleAnimation : name, in_idleAnimationSpeed : float, optional fixNPCInPlace : bool) : mod_scm_SpecialNPC
	{
		this.IdleAnimation = in_idleAnimation;
		this.IdleAnimationSpeed = in_idleAnimationSpeed;
		this.FixIdleAnimInPos = fixNPCInPlace;
		this.HasIdleAnimation = true;
		return this;
	}
	
	public function setDefaultIdleAnim() : mod_scm_SpecialNPC
	{
		this.setIdleAnim('high_standing_bored_idle', 1.0, true);
		return this;
	}
	
	public function setDialogue(in_CustomDialog : string) : mod_scm_SpecialNPC
	{
		this.CustomDialog = in_CustomDialog;
		this.HasCustomDialog = true;
		return this;
	}
	
	public function addSpawnCondition(spawnFact : name, optional shouldBeDisabled : bool) : mod_scm_SpecialNPC
	{
		var cond : mod_scm_SpawnCondition;
		cond = new mod_scm_SpawnCondition in this;
		cond.factName = spawnFact;
		cond.shouldBeDisabled = shouldBeDisabled;
		
		spawnConditions.PushBack(cond);
		return this;
	}
	
	public function spawnConditionAND() : mod_scm_SpecialNPC
	{
		spawnConditionAND = true;
		return this;
	}
	
	public function areSpawnConditionsMet() : bool
	{
		var i, sz : int;
		
		sz = spawnConditions.Size();
		
		if(spawnConditionAND)
		{
			for(i = 0; i < sz; i+=1)
			{
				if(!spawnConditions[i].check())
				{
					return false;
				}
			}
			return true;
		}
		else
		{
			for(i = 0; i < sz; i+=1)
			{
				if(spawnConditions[i].check())
				{
					return true;
				}
			}
			return sz == 0;
		}
	}
}

class mod_scm_NPCChatElement
{
	public var entSpecialID : name;
	public var talkingID : int;
	public var talkingString : string;

	public var time : float;
	public var playedOnce : bool; default playedOnce = false;
}

//===========================================================================================
//
//				SpawnCompanionMod - Class
//
//===========================================================================================

class mod_scm_SpawnPositions
{	
	public var SpawnPos_novigrad_room1 : mod_scm_SpawnPos;
	public var SpawnPos_novigrad_room2 : mod_scm_SpawnPos;
	public var SpawnPos_novigrad_room3 : mod_scm_SpawnPos;
	public var SpawnPos_novigrad_room4 : mod_scm_SpawnPos;
        public var SpawnPos_novigrad_room4_2 : mod_scm_SpawnPos;
        public var SpawnPos_novigrad_room4_3 : mod_scm_SpawnPos;
	public var SpawnPos_novigrad_room_main : mod_scm_SpawnPos;
	public var SpawnPos_novigrad_room_main_desk : mod_scm_SpawnPos;
	public var SpawnPos_novigrad_room_main_desk_2 : mod_scm_SpawnPos;
	public var SpawnPos_novigrad_room_main_bed : mod_scm_SpawnPos;
	public var SpawnPos_novigrad_balcony : mod_scm_SpawnPos;
	public var SpawnPos_novigrad_passiflora : mod_scm_SpawnPos;
	public var SpawnPos_novigrad_passiflora_2 : mod_scm_SpawnPos;

	public var SpawnPos_vizima_emhyr : mod_scm_SpawnPos;

        public var SpawnPos_velen_baron : mod_scm_SpawnPos;
	public var SpawnPos_novigrad_bart_the_troll : mod_scm_SpawnPos;
	public var SpawnPos_novigrad_cyprian_willey : mod_scm_SpawnPos;
        public var SpawnPos_novigrad_dijkstra : mod_scm_SpawnPos;
	public var SpawnPos_oxenfurt_ewald : mod_scm_SpawnPos;
	public var SpawnPos_velen_godling_johnny : mod_scm_SpawnPos;
	public var SpawnPos_oxenfurt_graden : mod_scm_SpawnPos;
	public var SpawnPos_oxenfurt_q603_circus_artist_companion : mod_scm_SpawnPos;
	public var SpawnPos_oxenfurt_q603_demolition_dwarf_companion : mod_scm_SpawnPos;
	public var SpawnPos_oxenfurt_q603_safecracker_companion : mod_scm_SpawnPos;
        public var SpawnPos_novigrad_rosa_var_attre : mod_scm_SpawnPos;
        public var SpawnPos_oxenfurt_shani : mod_scm_SpawnPos;
	public var SpawnPos_novigrad_sq306_sacha : mod_scm_SpawnPos;
	public var SpawnPos_novigrad_sq106_tauler : mod_scm_SpawnPos;
        public var SpawnPos_novigrad_talar : mod_scm_SpawnPos;
        public var SpawnPos_oxenfurt_tamara : mod_scm_SpawnPos;
	public var SpawnPos_novigrad_vernon_roche : mod_scm_SpawnPos;
        public var SpawnPos_novigrad_ves : mod_scm_SpawnPos;
	public var SpawnPos_novigrad_von_gratz : mod_scm_SpawnPos;

        public var SpawnPos_skellige_becca : mod_scm_SpawnPos;
        public var SpawnPos_skellige_hjalmar : mod_scm_SpawnPos;
        public var SpawnPos_skellige_mousesack : mod_scm_SpawnPos;
	public var SpawnPos_skellige_udalryk : mod_scm_SpawnPos;

	public var SpawnPos_kaermorhen_eskel : mod_scm_SpawnPos;
	public var SpawnPos_kaermorhen_lambert : mod_scm_SpawnPos;
	public var SpawnPos_kaermorhen_letho : mod_scm_SpawnPos;
	public var SpawnPos_kaermorhen_mq1058_lynx_witcher : mod_scm_SpawnPos;

        public var SpawnPos_bob_cb_1 : mod_scm_SpawnPos;
        public var SpawnPos_bob_cb_2 : mod_scm_SpawnPos;
	public var SpawnPos_bob_cb_3 : mod_scm_SpawnPos;
	public var SpawnPos_bob_cb_4 : mod_scm_SpawnPos;
	public var SpawnPos_bob_anna_henrietta : mod_scm_SpawnPos;
	public var SpawnPos_bob_damien : mod_scm_SpawnPos;
        public var SpawnPos_bob_dandelion : mod_scm_SpawnPos;
	public var SpawnPos_bob_dettlaff_van_eretein_vampire : mod_scm_SpawnPos;
	public var SpawnPos_bob_eskel : mod_scm_SpawnPos;
        public var SpawnPos_bob_guillaume : mod_scm_SpawnPos;
        public var SpawnPos_bob_lambert : mod_scm_SpawnPos;
	public var SpawnPos_bob_palmerin : mod_scm_SpawnPos;
        public var SpawnPos_bob_regis_terzieff_vampire : mod_scm_SpawnPos;
	public var SpawnPos_bob_sq701_gregoire : mod_scm_SpawnPos;
	public var SpawnPos_bob_sq701_vivienne : mod_scm_SpawnPos;
        public var SpawnPos_bob_syanna : mod_scm_SpawnPos;
	public var SpawnPos_bob_vampire_diva : mod_scm_SpawnPos;
        public var SpawnPos_bob_wolf_white_lvl3__alpha : mod_scm_SpawnPos;
        public var SpawnPos_bob_zoltan_chivay : mod_scm_SpawnPos;
	
	private function createSpawnPos(Area : EAreaName, PosX, PosY, PosZ : float, rotYaw : float) : mod_scm_SpawnPos
	{
		var spawnPos : mod_scm_SpawnPos;
		
		spawnPos = new mod_scm_SpawnPos in this;
		
		spawnPos.Area = Area;
		
		spawnPos.Position.X = PosX;
		spawnPos.Position.Y = PosY;
		spawnPos.Position.Z = PosZ;
		
		spawnPos.Rotation.Pitch = 0;
		spawnPos.Rotation.Yaw = rotYaw;
		spawnPos.Rotation.Roll = 0;
		
		LogChannel('ModSpawnCompanions', "Creating SP at " + Area + ", " + spawnPos.Area + "(" + PosX + ", " + PosY + ", " + PosZ + ")");
		
		return spawnPos;
	}
	
	private var isInit : bool; default isInit = false;
	
	public function init()
	{
		if(isInit) return;
		isInit = true;
		
		LogChannel('ModSpawnCompanions', "Initing Spawn Pos Data");
		
		SpawnPos_novigrad_room1 = createSpawnPos(AN_NMLandNovigrad, 727.736365, 1726.319854, 9.728056, -35);
		SpawnPos_novigrad_room2 = createSpawnPos(AN_NMLandNovigrad, 734.089611, 1735.483765, 9.760729, 57);
		SpawnPos_novigrad_room3 = createSpawnPos(AN_NMLandNovigrad, 721.942200, 1727.023193, 9.718756, 155);
		SpawnPos_novigrad_room4 = createSpawnPos(AN_NMLandNovigrad, 726.228337, 1740.828369, 9.714056, -132);
                SpawnPos_novigrad_room4_2 = createSpawnPos(AN_NMLandNovigrad, 729.096817, 1740.648662, 9.726057, 100);
                SpawnPos_novigrad_room4_3 = createSpawnPos(AN_NMLandNovigrad, 726.778992, 1738.705444, 9.714057, 0);
		SpawnPos_novigrad_room_main = createSpawnPos(AN_NMLandNovigrad, 724.977478, 1726.077881, 14.338086, -10);
		SpawnPos_novigrad_room_main_desk = createSpawnPos(AN_NMLandNovigrad, 727.234215, 1726.299764, 14.353244, 2);
		SpawnPos_novigrad_room_main_desk_2 = createSpawnPos(AN_NMLandNovigrad, 726.982753, 1728.126377, 14.356086, 80);
		SpawnPos_novigrad_room_main_bed = createSpawnPos(AN_NMLandNovigrad, 724.078308, 1735.057861, 14.856245, -122);
                SpawnPos_novigrad_balcony = createSpawnPos(AN_NMLandNovigrad, 714.027978, 1728.698903, 14.418370, 102);
		SpawnPos_novigrad_passiflora = createSpawnPos(AN_NMLandNovigrad, 672.132467, 2108.476684, 33.474761, -134);
		SpawnPos_novigrad_passiflora_2 = createSpawnPos(AN_NMLandNovigrad, 672.352783, 2106.639275, 33.489258, -22);

		SpawnPos_vizima_emhyr = createSpawnPos(AN_Wyzima, 42.128335, 42.043871, 12.012916, 90);

                SpawnPos_velen_baron = createSpawnPos(AN_NMLandNovigrad, 155.404507, 181.296397, 36.909807, -32);
		SpawnPos_novigrad_bart_the_troll = createSpawnPos(AN_NMLandNovigrad, 669.914734, 1988.639526, 6.727913, -12);
		SpawnPos_novigrad_cyprian_willey = createSpawnPos(AN_NMLandNovigrad, 524.761714, 2163.231266, 41.201343, 110);
                SpawnPos_novigrad_dijkstra = createSpawnPos(AN_NMLandNovigrad, 662.637756, 1997.443970, 13.099773, -130);
		SpawnPos_oxenfurt_ewald = createSpawnPos(AN_NMLandNovigrad, 1714.547349, 975.954407, 6.591446, 54);
		SpawnPos_velen_godling_johnny = createSpawnPos(AN_NMLandNovigrad, 1374.879150, -591.690132, 1.753458, -96);
		SpawnPos_oxenfurt_graden = createSpawnPos(AN_NMLandNovigrad, 1689.164527, 1079.435801, 3.386596, 33);
		SpawnPos_oxenfurt_q603_circus_artist_companion = createSpawnPos(AN_NMLandNovigrad, 1713.100669, 975.822830, 6.605446, -55);
		SpawnPos_oxenfurt_q603_demolition_dwarf_companion = createSpawnPos(AN_NMLandNovigrad, 1712.657056, 977.479248, 6.604219, -126);
		SpawnPos_oxenfurt_q603_safecracker_companion = createSpawnPos(AN_NMLandNovigrad, 1716.070313, 979.185682, 6.554632, 143);
                SpawnPos_novigrad_rosa_var_attre = createSpawnPos(AN_NMLandNovigrad, 712.024308, 2075.259766, 31.110896, -20);
                SpawnPos_oxenfurt_shani = createSpawnPos(AN_NMLandNovigrad, 1673.070605, 966.000916, 8.188107, -64);
		SpawnPos_novigrad_sq306_sacha = createSpawnPos(AN_NMLandNovigrad, 671.006315, 2096.210674, 33.980740, -164);
		SpawnPos_novigrad_sq106_tauler = createSpawnPos(AN_NMLandNovigrad, 724.509923, 1966.627075, 27.067525, -16);
                SpawnPos_novigrad_talar = createSpawnPos(AN_NMLandNovigrad, 724.424136, 1731.624618, 4.658900, 56);
                SpawnPos_oxenfurt_tamara = createSpawnPos(AN_NMLandNovigrad, 1683.608521, 1081.809204, 8.504318, 90);
		SpawnPos_novigrad_vernon_roche = createSpawnPos(AN_NMLandNovigrad, 723.689417, 1732.126980, 4.662898, -122);
                SpawnPos_novigrad_ves = createSpawnPos(AN_NMLandNovigrad, 721.129802, 1732.536548, 14.319250, -127);
		SpawnPos_novigrad_von_gratz = createSpawnPos(AN_NMLandNovigrad, 713.986331, 1997.127231, 22.740892, 164);

                SpawnPos_skellige_becca = createSpawnPos(AN_Skellige_ArdSkellig, -164.014085, 677.695889, 94.338092, 196);
                SpawnPos_skellige_hjalmar = createSpawnPos(AN_Skellige_ArdSkellig, -161.361145, 669.377075, 94.389481, -136);
                SpawnPos_skellige_mousesack = createSpawnPos(AN_Skellige_ArdSkellig, 1005.938171, -41.338650, 54.169258, 182);
		SpawnPos_skellige_udalryk = createSpawnPos(AN_Skellige_ArdSkellig, -1649.368584, 1317.526504, 19.745729, -31);

		SpawnPos_kaermorhen_eskel = createSpawnPos(AN_Kaer_Morhen, 68.383664, 32.646006, 170.703784, -60);
		SpawnPos_kaermorhen_lambert = createSpawnPos(AN_Kaer_Morhen, 65.868919, 29.906057, 171.054801, -88);
		SpawnPos_kaermorhen_letho = createSpawnPos(AN_Kaer_Morhen, 70.009405, 36.813401, 170.682075, 182);
		SpawnPos_kaermorhen_mq1058_lynx_witcher = createSpawnPos(AN_Kaer_Morhen, 68.120238, 28.002935, 171.234796, -8);

                SpawnPos_bob_cb_1 = createSpawnPos(11, -399.387390, -804.238831, 39.942983, 60);
                SpawnPos_bob_cb_2 = createSpawnPos(11, -393.507426, -790.560181, 35.352479, 85);
		SpawnPos_bob_cb_3 = createSpawnPos(11, -395.614089, -792.158965, 35.355182, -9);
		SpawnPos_bob_cb_4 = createSpawnPos(11, -397.492719, -790.446582, 35.368892, -118);
                SpawnPos_bob_anna_henrietta = createSpawnPos(11, -817.380657, -1386.362871, 104.926890, -68);
		SpawnPos_bob_damien = createSpawnPos(11, -816.286011, -1387.687744, 104.840862, -25);
		SpawnPos_bob_dandelion = createSpawnPos(11, -397.202719, -790.437082, 35.340892, -97);
		SpawnPos_bob_dettlaff_van_eretein_vampire = createSpawnPos(11, -234.127968, -1289.035596, 7.409289, -27);
		SpawnPos_bob_eskel = createSpawnPos(11, -389.801415, -792.329370, 35.365510, 148);
                SpawnPos_bob_guillaume = createSpawnPos(11, -694.802979, -1171.144565, 163.112774, 90);
                SpawnPos_bob_lambert = createSpawnPos(11, -392.021757, -792.309226, 35.362575, -124);
		SpawnPos_bob_palmerin = createSpawnPos(11, -700.742488, -1194.261719, 163.796989, 78);
                SpawnPos_bob_regis_terzieff_vampire = createSpawnPos(11, -405.146151, -801.612620, 25.502795, -121);
                SpawnPos_bob_sq701_gregoire = createSpawnPos(11, -700.072144, -1181.914917, 163.049946, 36);
		SpawnPos_bob_sq701_vivienne = createSpawnPos(11, -694.996790, -1170.478049, 163.906921, 118);
		SpawnPos_bob_syanna = createSpawnPos(11, -673.604205, -1188.309555, 164.334944, 40);
		SpawnPos_bob_vampire_diva = createSpawnPos(11, -352.340146, -1443.926734, 87.978065, -128);
                SpawnPos_bob_wolf_white_lvl3__alpha = createSpawnPos(11, -353.704041, -808.596130, 30.300375, 0);
                SpawnPos_bob_zoltan_chivay = createSpawnPos(11, -395.606873, -788.703735, 35.355892, 149);
	}
}

//mod_scm_SpecialNPCDialogues
class mod_scm_SpecialNPCInfos
{
	private var infos : array<mod_scm_SpecialNPC>;
	private var spawnInfo : mod_scm_SpawnPositions;
	
	private var isInit : bool; default isInit = false;
	public function init()
	{
		if(isInit) return;
		isInit = true;
		
		spawnInfo = new mod_scm_SpawnPositions in this;
		spawnInfo.init();
		
		LogChannel('ModSpawnCompanions', "Initializing Special NPC Infos");
		initSpecialNPCs(spawnInfo);
	}
	
	public function getNPCInfo(nam : name) : mod_scm_SpecialNPC
	{
		var sz, i : int;
		sz = infos.Size();
		for(i = 0; i < sz; i+=1)
		{
			if(infos[i].Name == nam)
			{
				return infos[i];
			}
		}
		return NULL;
	}
	
	private function addNPCInfo(Name : name, SpawnPos : mod_scm_SpawnPos, optional usesCustomSpawnConditions : bool) : mod_scm_SpecialNPC
	{
		var info : mod_scm_SpecialNPC;
		
		LogChannel('ModSpawnCompanions', "Added NPC Info " + NameToString(Name) + ": " + SpawnPos.Area + " - (" + SpawnPos.Position.X + ", " + SpawnPos.Position.Y + ", " + SpawnPos.Position.Z + ")");
		
		info = new mod_scm_SpecialNPC in this;
		
		info.Name = Name;
		info.SpawnPos = SpawnPos;
		
		if(!usesCustomSpawnConditions)
		{
			info.addSpawnCondition('q502_ciri_dead').addSpawnCondition('q502_ciri_survives');
		}
		
		infos.PushBack(info);
		
		return info;
	}
	
	private function initSpecialNPCs(p : mod_scm_SpawnPositions)
	{
		var SpawnPos_Ciri : mod_scm_SpawnPos;
		var SpawnPos_Yennefer : mod_scm_SpawnPos;
                var SpawnPos_Triss : mod_scm_SpawnPos;
                var SpawnPos_Dandelion : mod_scm_SpawnPos;
		var SpawnPos_Eskel : mod_scm_SpawnPos;
		var SpawnPos_Keira : mod_scm_SpawnPos;
		var SpawnPos_Lambert : mod_scm_SpawnPos;
		var SpawnPos_Margarita : mod_scm_SpawnPos;
		var SpawnPos_Philippa : mod_scm_SpawnPos;
		var SpawnPos_Priscilla : mod_scm_SpawnPos;
		var SpawnPos_Zoltan : mod_scm_SpawnPos;
		var tmp : mod_scm_SpecialNPC;
		var ciri, yen, triss, shani, dandelion, eskel, keira_metz, lambert, margarita, philippa_eilhart, priscilla, zoltan_chivay : mod_scm_SpecialNPC;
		
		//Defaults
		SpawnPos_Ciri = p.SpawnPos_novigrad_balcony;
		SpawnPos_Yennefer = p.SpawnPos_novigrad_room_main_bed;
		SpawnPos_Triss = p.SpawnPos_novigrad_room_main_desk;
		SpawnPos_Dandelion = p.SpawnPos_novigrad_passiflora;
		SpawnPos_Eskel = p.SpawnPos_kaermorhen_eskel;
		SpawnPos_Keira = p.SpawnPos_novigrad_room_main;
		SpawnPos_Lambert = p.SpawnPos_kaermorhen_lambert;
		SpawnPos_Margarita = p.SpawnPos_novigrad_room4_3;
		SpawnPos_Philippa = p.SpawnPos_novigrad_room4;
		SpawnPos_Priscilla = p.SpawnPos_novigrad_room_main_desk_2;
		SpawnPos_Zoltan = p.SpawnPos_novigrad_passiflora_2;
		
		if(FactsQuerySum('q705_ciri_met'))
		{
			SpawnPos_Ciri = p.SpawnPos_novigrad_room_main_bed;
			SpawnPos_Yennefer = p.SpawnPos_bob_cb_2;
			SpawnPos_Triss = p.SpawnPos_bob_cb_3;
			SpawnPos_Dandelion = p.SpawnPos_bob_dandelion;
			SpawnPos_Eskel = p.SpawnPos_bob_eskel;
			SpawnPos_Lambert = p.SpawnPos_bob_lambert;
			SpawnPos_Margarita = p.SpawnPos_novigrad_room4;
			SpawnPos_Philippa = p.SpawnPos_novigrad_room_main_desk;
			SpawnPos_Zoltan = p.SpawnPos_bob_zoltan_chivay;
		}

                if(FactsQuerySum('q705_yen_first_met'))
		{
			SpawnPos_Ciri = p.SpawnPos_bob_cb_1;
                        SpawnPos_Triss = p.SpawnPos_bob_cb_2;
			SpawnPos_Dandelion = p.SpawnPos_bob_dandelion;
			SpawnPos_Eskel = p.SpawnPos_bob_eskel;
			SpawnPos_Keira = p.SpawnPos_bob_cb_3;
			SpawnPos_Lambert = p.SpawnPos_bob_lambert;
			SpawnPos_Margarita = p.SpawnPos_novigrad_room4;
			SpawnPos_Philippa = p.SpawnPos_novigrad_room_main_desk;
			SpawnPos_Zoltan = p.SpawnPos_bob_zoltan_chivay;
		}

                if(FactsQuerySum('q705_triss_house_met'))
		{
			SpawnPos_Ciri = p.SpawnPos_bob_cb_1;
			SpawnPos_Yennefer = p.SpawnPos_bob_cb_2;
                        SpawnPos_Triss = p.SpawnPos_novigrad_room_main_bed;
			SpawnPos_Dandelion = p.SpawnPos_bob_dandelion;
			SpawnPos_Eskel = p.SpawnPos_bob_eskel;
			SpawnPos_Keira = p.SpawnPos_bob_cb_3;
			SpawnPos_Lambert = p.SpawnPos_bob_lambert;
			SpawnPos_Margarita = p.SpawnPos_novigrad_room4;
			SpawnPos_Philippa = p.SpawnPos_novigrad_room_main_desk;
			SpawnPos_Zoltan = p.SpawnPos_bob_zoltan_chivay;
		}

                if(FactsQuerySum('q705_dand_intro'))
		{
			SpawnPos_Ciri = p.SpawnPos_bob_cb_3;
			SpawnPos_Yennefer = p.SpawnPos_bob_cb_2;
                        SpawnPos_Triss = p.SpawnPos_bob_cb_4;
			SpawnPos_Eskel = p.SpawnPos_bob_eskel;
			SpawnPos_Keira = p.SpawnPos_novigrad_room_main_desk_2;
			SpawnPos_Lambert = p.SpawnPos_bob_lambert;
			SpawnPos_Margarita = p.SpawnPos_novigrad_room4;
			SpawnPos_Philippa = p.SpawnPos_novigrad_room_main_desk;
			SpawnPos_Priscilla = p.SpawnPos_novigrad_room_main_bed;
			SpawnPos_Zoltan = p.SpawnPos_bob_zoltan_chivay;
		}
		
	        //Main
		ciri = addNPCInfo('cirilla', SpawnPos_Ciri, true).setDialogue("dlc\mod_spawn_companions\dialogue\ciriFollowWithHug.w2scene").setIdleAnim('lean_mw_fence_on_arms_jt_start_loop_01', 1.0, true)
                	.addSpawnCondition('q502_ciri_survives');
		yen = addNPCInfo('yennefer', SpawnPos_Yennefer).setDialogue("dlc\mod_spawn_companions\dialogue\yenneferFollowWithKiss.w2scene").setIdleAnim('high_lying_down_happy_idle', 1.0, true);
                triss = addNPCInfo('triss', SpawnPos_Triss).setDialogue("dlc\mod_spawn_companions\dialogue\trissFollowWithKiss.w2scene").setIdleAnim('high_sitting_proud_idle', 1.0, true);
                shani = addNPCInfo('shani', p.SpawnPos_oxenfurt_shani, true).setDialogue("dlc\mod_spawn_companions\dialogue\shaniFollowWithHug.w2scene").setIdleAnim('high_sitting_determined_idle', 1.0, true)
			.addSpawnCondition('q605_mirror_banished').addSpawnCondition('q605_mirror_won');

		if(FactsQuerySum('q705_ciri_met'))
                {
			ciri.setIdleAnim('high_lying_down_happy_idle', 1.0, true);
                        yen.setIdleAnim('q705_triss_lying_on_a_deckchair_idle', 1.0, true);
                        triss.setIdleAnim('high_sitting_determined_idle', 1.0, true);
			addNPCInfo('eskel', SpawnPos_Eskel).setIdleAnim('low_sitting_ground_leaning_back_bored_idle', 1.0, true);
			addNPCInfo('philippa_eilhart', SpawnPos_Philippa).setIdleAnim('high_sitting_proud_idle', 1.0, true);
			addNPCInfo('zoltan_chivay', SpawnPos_Zoltan).setIdleAnim('high_standing_determined_idle', 1.0, true);
		}

		if(FactsQuerySum('q705_yen_first_met'))
                {
			ciri.setIdleAnim('high_lying_down_happy_idle', 1.0, true);
                        triss.setIdleAnim('q705_triss_lying_on_a_deckchair_idle', 1.0, true);
			addNPCInfo('eskel', SpawnPos_Eskel).setIdleAnim('low_sitting_ground_leaning_back_bored_idle', 1.0, true);
			addNPCInfo('keira_metz', SpawnPos_Keira, true).setIdleAnim('high_sitting_determined_idle', 1.0, true);
			addNPCInfo('philippa_eilhart', SpawnPos_Philippa).setIdleAnim('high_sitting_proud_idle', 1.0, true);
			addNPCInfo('zoltan_chivay', SpawnPos_Zoltan).setIdleAnim('high_standing_determined_idle', 1.0, true);
		}

		if(FactsQuerySum('q705_triss_house_met'))
                {
			ciri.setIdleAnim('high_lying_down_happy_idle', 1.0, true);
                        yen.setIdleAnim('q705_triss_lying_on_a_deckchair_idle', 1.0, true);
			triss.setIdleAnim('high_lying_down_happy_idle', 1.0, true);
			addNPCInfo('eskel', SpawnPos_Eskel).setIdleAnim('low_sitting_ground_leaning_back_bored_idle', 1.0, true);
			addNPCInfo('keira_metz', SpawnPos_Keira, true).setIdleAnim('high_sitting_determined_idle', 1.0, true);
			addNPCInfo('philippa_eilhart', SpawnPos_Philippa).setIdleAnim('high_sitting_proud_idle', 1.0, true);
			addNPCInfo('zoltan_chivay', SpawnPos_Zoltan).setIdleAnim('high_standing_determined_idle', 1.0, true);
		}

		if(FactsQuerySum('q705_dand_intro'))
                {
			ciri.setIdleAnim('high_sitting_determined_idle', 1.0, true);
			yen.setIdleAnim('q705_triss_lying_on_a_deckchair_idle', 1.0, true);
			triss.setIdleAnim('high_sitting_determined_idle', 1.0, true);
			addNPCInfo('eskel', SpawnPos_Eskel).setIdleAnim('low_sitting_ground_leaning_back_bored_idle', 1.0, true);
			addNPCInfo('keira_metz', SpawnPos_Keira, true).setIdleAnim('high_sitting_determined_idle', 1.0, true);
			addNPCInfo('philippa_eilhart', SpawnPos_Philippa).setIdleAnim('high_sitting_proud_idle', 1.0, true);
			addNPCInfo('pryscilla', SpawnPos_Priscilla).setIdleAnim('high_lying_down_happy_idle', 1.0, true);
			addNPCInfo('zoltan_chivay', SpawnPos_Zoltan).setIdleAnim('high_standing_determined_idle', 1.0, true);
		}

		//Secondary
		addNPCInfo('anna_henrietta', p.SpawnPos_bob_anna_henrietta, true).setIdleAnim('high_sitting_determined_idle', 1.0, true)
			.addSpawnCondition('q705_henrietta_alive');
                addNPCInfo('avallach', p.SpawnPos_novigrad_room2).setIdleAnim('high_sitting_determined_idle', 1.0, true);
                addNPCInfo('baron', p.SpawnPos_velen_baron, true).setIdleAnim('high_sitting_chair_proud_idle', 1.0, true)
                	.addSpawnCondition('q107_anna_is_crazy');
		addNPCInfo('bart_the_troll', p.SpawnPos_novigrad_bart_the_troll).setDefaultIdleAnim();
                addNPCInfo('becca', p.SpawnPos_skellige_becca).setIdleAnim('high_sitting_proud_idle', 1.0, true);
		addNPCInfo('cyprian_willey', p.SpawnPos_novigrad_cyprian_willey, true).setIdleAnim('high_sitting_determined_idle', 1.0, true)
			.addSpawnCondition('q310_met_dudu_as_whoreson');
		addNPCInfo('damien', p.SpawnPos_bob_damien, true).setIdleAnim('high_standing_determined2_idle', 1.0, true)
			.addSpawnCondition('q705_henrietta_dead').addSpawnCondition('q705_henrietta_alive');
                addNPCInfo('dandelion', SpawnPos_Dandelion).setIdleAnim('high_sitting3_determined_idle', 1.0, true);
		addNPCInfo('dettlaff_van_eretein_vampire', p.SpawnPos_bob_dettlaff_van_eretein_vampire, true).setIdleAnim('high_sitting_determined_idle', 1.0, true)
			.addSpawnCondition('q704_syanna_dies_dettlaff_lives');
                addNPCInfo('dijkstra', p.SpawnPos_novigrad_dijkstra, true).setIdleAnim('high_standing_happy_idle', 1.0, true)
                	.addSpawnCondition('q310_dijkstras_other_leg').addSpawnCondition('mq3035_fdb_roche_talar_dead');
		addNPCInfo('emhyr', p.SpawnPos_vizima_emhyr, true).setIdleAnim('high_sitting_chair_proud_idle', 1.0, true)
			.addSpawnCondition('q505_nilfgaard_won');
		addNPCInfo('ewald', p.SpawnPos_oxenfurt_ewald, true).setIdleAnim('high_sitting_determined_idle', 1.0, true)
			.addSpawnCondition('q603_only_box');
		addNPCInfo('godling_johnny', p.SpawnPos_velen_godling_johnny).setDefaultIdleAnim();
		addNPCInfo('graden', p.SpawnPos_oxenfurt_graden).setIdleAnim('high_sitting_determined_idle', 1.0, true);
                addNPCInfo('guillaume', p.SpawnPos_bob_guillaume, true).setIdleAnim('high_standing_happy_idle', 1.0, true)
                	.addSpawnCondition('sq701_guillaume_pond_epilogue').addSpawnCondition('sq701_guillaume_egg_epilogue');
                addNPCInfo('hjalmar', p.SpawnPos_skellige_hjalmar).setDefaultIdleAnim();
                addNPCInfo('mousesack', p.SpawnPos_skellige_mousesack).setIdleAnim('high_standing_happy_idle', 1.0, true);
                addNPCInfo('olgierd', p.SpawnPos_novigrad_room1, true).setIdleAnim('high_standing_leaning_back_determined_idle', 1.0, true)
                	.addSpawnCondition('q605_mirror_banished');
		addNPCInfo('palmerin', p.SpawnPos_bob_palmerin, true).setIdleAnim('high_sitting3_determined_idle', 1.0, true)
			.addSpawnCondition('q705_henrietta_dead').addSpawnCondition('q705_henrietta_alive');
                addNPCInfo('pryscilla', SpawnPos_Priscilla).setIdleAnim('high_sitting_determined_idle', 1.0, true);
		addNPCInfo('q603_circus_artist_companion', p.SpawnPos_oxenfurt_q603_circus_artist_companion, true).setIdleAnim('high_sitting_determined_idle', 1.0, true)
			.addSpawnCondition('q605_mirror_banished').addSpawnCondition('q605_mirror_won');
		addNPCInfo('q603_demolition_dwarf_companion', p.SpawnPos_oxenfurt_q603_demolition_dwarf_companion, true).setIdleAnim('high_standing_determined_idle', 1.0, true)
			.addSpawnCondition('q603_safecracker_recruited').addSpawnCondition('q603_demo_dwarf_survived');
		addNPCInfo('q603_safecracker_companion', p.SpawnPos_oxenfurt_q603_safecracker_companion, true).setIdleAnim('high_standing_leaning_back2_determined_idle', 1.0, true)
			.addSpawnCondition('q603_demo_dwarf_recruited').addSpawnCondition('q603_safecracker_survived');
                addNPCInfo('regis_terzieff_vampire', p.SpawnPos_bob_regis_terzieff_vampire, true).setIdleAnim('regis_standing_hand_straight_gesture_think', 1.0, true)
			.addSpawnCondition('q705_ciri_met').addSpawnCondition('q705_dand_intro').addSpawnCondition('q705_triss_house_met').addSpawnCondition('q705_yen_first_met');
                addNPCInfo('sq701_vivienne', p.SpawnPos_bob_sq701_vivienne, true).setIdleAnim('high_sitting_determined_idle', 1.0, true)
                	.addSpawnCondition('sq701_guillaume_pond_epilogue').addSpawnCondition('sq701_guillaume_egg_epilogue');
                addNPCInfo('syanna', p.SpawnPos_bob_syanna, true).setIdleAnim('q705_syanna_sitting_on_windowsill_idle', 1.0, true)
                	.addSpawnCondition('q705_syanna_correct');
                addNPCInfo('talar', p.SpawnPos_novigrad_talar, true).setIdleAnim('low_sitting_leaning_determined_idle', 1.0, true)
                	.addSpawnCondition('q310_dijkstras_other_leg').addSpawnCondition('mq3035_fdb_dijkstra_dead');
		addNPCInfo('tamara', p.SpawnPos_oxenfurt_tamara).setDefaultIdleAnim();
		addNPCInfo('udalryk', p.SpawnPos_skellige_udalryk).setIdleAnim('high_sitting_determined_idle', 1.0, true);
		addNPCInfo('vampire_diva', p.SpawnPos_bob_vampire_diva, true).setIdleAnim('q703_oriana_custom_pose_idle', 1.0, true)
			.addSpawnCondition('q705_henrietta_dead').addSpawnCondition('q705_henrietta_alive');
                addNPCInfo('vernon_roche', p.SpawnPos_novigrad_vernon_roche, true).setIdleAnim('high_sitting_leaning_determined_idle', 1.0, true)
                	.addSpawnCondition('q310_dijkstras_other_leg').addSpawnCondition('mq3035_fdb_dijkstra_dead');
		addNPCInfo('ves', p.SpawnPos_novigrad_ves, true).setIdleAnim('high_standing_leaning_back_determined_idle', 1.0, true)
                	.addSpawnCondition('q310_dijkstras_other_leg').addSpawnCondition('mq3035_fdb_dijkstra_dead');
		addNPCInfo('von_gratz', p.SpawnPos_novigrad_von_gratz).setIdleAnim('high_standing_determined_gesture_autopsy_pick_up_inspect', 1.0, true);
                addNPCInfo('zoltan_chivay', SpawnPos_Zoltan).setIdleAnim('high_sitting_determined_idle', 1.0, true);
		
                //Witchers
		addNPCInfo('eskel', SpawnPos_Eskel).setIdleAnim('high_standing_leaning_determined_idle', 1.0, true);
                addNPCInfo('lambert', SpawnPos_Lambert, true).setIdleAnim('high_sitting_determined_idle', 1.0, true)
                	.addSpawnCondition('q403_geralt_saved_lambert').addSpawnCondition('q403_keira_saved_lambert');
		addNPCInfo('letho', p.SpawnPos_kaermorhen_letho, true).setIdleAnim('high_standing_leaning_back2_determined_idle', 1.0, true)
			.addSpawnCondition('sq102_letho_met');
		addNPCInfo('mq1058_lynx_witcher', p.SpawnPos_kaermorhen_mq1058_lynx_witcher, true).setIdleAnim('low_sitting_happy_idle', 1.0, true)
			.addSpawnCondition('mq1058_lynx_stash_opened');
		
		//Sorceresses
		addNPCInfo('fringilla_vigo', p.SpawnPos_novigrad_room4_2).setIdleAnim('high_sitting_determined_idle', 1.0, true);
                addNPCInfo('keira_metz', SpawnPos_Keira, true).setDefaultIdleAnim()
                	.addSpawnCondition('q310_keira_lambert_love');
                addNPCInfo('margarita', SpawnPos_Margarita).setDefaultIdleAnim();
                addNPCInfo('philippa_eilhart', SpawnPos_Philippa).setIdleAnim('high_standing_proud_idle', 1.0, true);
		
		//Others
		addNPCInfo('rosa_var_attre', p.SpawnPos_novigrad_rosa_var_attre).setIdleAnim('high_standing_aggressive_gesture_weight_shift_02', 1.0, true);
		addNPCInfo('sq701_gregoire', p.SpawnPos_bob_sq701_gregoire, true).setIdleAnim('high_standing_determined2_idle', 1.0, true)
			.addSpawnCondition('q705_henrietta_dead').addSpawnCondition('q705_henrietta_alive');
		addNPCInfo('sq306_sacha', p.SpawnPos_novigrad_sq306_sacha).setIdleAnim('high_sitting_determined_idle', 1.0, true);
		addNPCInfo('sq106_tauler', p.SpawnPos_novigrad_sq106_tauler).setIdleAnim('high_standing_leaning_back2_determined_idle', 1.0, true);
		
                //Pets
                addNPCInfo('wolf_white_lvl3__alpha', p.SpawnPos_bob_wolf_white_lvl3__alpha, true)
			.addSpawnCondition('q705_ciri_met').addSpawnCondition('q705_dand_intro').addSpawnCondition('q705_triss_house_met').addSpawnCondition('q705_yen_first_met');
				
		if(true)
		{
			yen.setNaughtyScene("dlc/mod_spawn_companions/naughty/yennefer/anywhere.w2scene");
			triss.setNaughtyScene("dlc/mod_spawn_companions/naughty/triss/anywhere.w2scene");
			ciri.setNaughtyScene("dlc/mod_spawn_companions/naughty/ciri/anywhere.w2scene");
			shani.setNaughtyScene("dlc/mod_spawn_companions/naughty/shani/anywhere.w2scene");
		}		
	}
	
	public function SpawnNPCs()
	{
		var i : int;
		var size : int;
		var npcInfo : mod_scm_SpecialNPC;
		var npc : CNewNPC;
		var areaInt : EAreaName;
		
		var distanceMeasuredSq : float;
		
		var vecNPCtoGeralt : Vector;
		var camAndVecDot : float;
		
		var npcsEnabled : bool;
		var pos : Vector;
		var rot : EulerAngles;

		var playerPos : Vector;
		
		playerPos = thePlayer.GetWorldPosition();

		areaInt = theGame.GetCommonMapManager().GetCurrentArea();
		
		size = infos.Size();

		for(i = 0; i < size; i+=1)
		{
			npcInfo = infos[i];
			
			npcsEnabled = mod_scm_CanSpecialNPCSpawn(npcInfo);
			
			npc = mod_scm_GetNPC(npcInfo.Name, ST_Special); //theGame.GetNPCByTag(npcInfo.UniqueTag);
			if(!npc)
			{
				if(npcInfo.SpawnPos.Area == areaInt && npcsEnabled && VecDistanceSquared(playerPos, npcInfo.SpawnPos.Position) < 2500)
				{
					LogChannel('ModSpawnCompanions', "Special NPC not in position. Spawning");
					pos = npcInfo.SpawnPos.Position;
					rot = npcInfo.SpawnPos.Rotation;
					
					npc = MCM_SpawnNPCParams(npcInfo.Name, '', '', false, true, 0, false);
					npc.TeleportWithRotation(pos, rot);
					
					if(npcInfo.HasIdleAnimation)
					{
						npc.GotoState('SCMPlayIdleAnim', true);
					}
				}
			}
			else if(npc.scmcc)
			{
				if(!npc.scmcc.IsFollowing())
				{
					distanceMeasuredSq = VecDistanceSquared(npcInfo.SpawnPos.Position, npc.GetWorldPosition());
					
					if(distanceMeasuredSq > 0.5)
					{
						distanceMeasuredSq = VecDistanceSquared(thePlayer.GetWorldPosition(), npc.GetWorldPosition());
						
						if(distanceMeasuredSq > 400)
						{
							vecNPCtoGeralt = VecNormalize(thePlayer.GetWorldPosition() - npc.GetWorldPosition());
							camAndVecDot = VecDot(vecNPCtoGeralt, theCamera.GetCameraDirection());
							
							if(camAndVecDot > 0.1)
							{
								if(npcInfo.SpawnPos.Area == areaInt && npcsEnabled)
								{
									pos = npcInfo.SpawnPos.Position;
									rot = npcInfo.SpawnPos.Rotation;
									
									npc.TeleportWithRotation(pos, rot);
									
									if(npc.GetCurrentStateName() != 'SCMPlayIdleAnim')
									{
										npc.GotoState('SCMPlayIdleAnim', true);
									}
								}
								else
								{
									((CEntity)npc).Destroy();
								}
							}
						}
					}
				}
			}
		}
	}
}

class mod_scm_NaughtyPoints
{
	var points : array<mod_scm_NaughtyPoint>;

	var isInit : bool; default isInit = false;
	
	public function init()
	{
		if(isInit) return;
		isInit = true;
		
	      /*AN_NMLandNovigrad 1
		AN_Skellige_ArdSkellig 2
		AN_Kaer_Morhen 3
		AN_Prologue_Village 4
		AN_Wyzima 5
		AN_Island_of_Myst 6
		AN_Spiral 7
		AN_Prologue_Village_Winter 8
		AN_Velen 9
		AN_CombatTestLevel 10*/

		addPoint(640.706, 1841.289, 19.80, 0, 106.10, 0, AN_NMLandNovigrad); //   ===   Hierarch Square, Triss's House		
		addPoint(723.969, 1734.220, 14.46, 0, 162.15, 0, AN_NMLandNovigrad); //   ===   Rosemary & Thyme, Main Room
		addPoint(726.158, 1724.137, 9.92, 0, -8.63, 0, AN_NMLandNovigrad); //   ===   Rosemary & Thyme, Guest Room 1
		addPoint(735.236, 1734.147, 9.95, 0, 67.63, 0, AN_NMLandNovigrad); //   ===   Rosemary & Thyme, Guest Room 2
		addPoint(692.808, 1918.036, 19.96, 0, -100.84, 0, AN_NMLandNovigrad); //   ===   The Kingfisher Inn, Locked Room
		addPoint(682.120, 1917.624, 19.80, 0, -94.58, 0, AN_NMLandNovigrad); //   ===   The Kingfisher Inn, Room 2
		addPoint(712.140, 2077.632, 40.96, 0, -128.72, 0, AN_NMLandNovigrad); //   ===   Var Attre Villa
		addPoint(658.565, 2103.303, 41.82, 0, 4.80, 0, AN_NMLandNovigrad); //   ===   Passiflora, Upstairs Room
		addPoint(189.979, 178.675, 37.40, 0, 18.60, 0, AN_NMLandNovigrad); //   ===   Crow's Perch, Ciri's Room
		addPoint(181.945, 191.720, 41.78, 0, -93.04, 0, AN_NMLandNovigrad); //   ===   Crow's Perch, Baron's Room
		addPoint(1671.590, 960.428, 8.22, 0, -36.4, 0, AN_NMLandNovigrad); //   ===   Oxenfurt, Shani's Clinic

		addPoint(-52.214, 595.942, 2.72, 0, 84.26, 0, AN_Skellige_ArdSkellig); //   ===   Kaer Trolde, Yen's Room

		addPoint(63.280, -3.248, 196.71, 0, 20.50, 0, AN_Kaer_Morhen); //   ===   Prologue Room
		addPoint(121.054, 35.239, 193.17, 0, -165.40, 0, AN_Kaer_Morhen); //   ===   Room 2

		addPoint(-400.166, -800.120, 35.44, 0, -135.87, 0, 11).AddRequirement('mq7024_bed_upgrade_start', EO_GreaterEqual, 1); //   ===   Corvo Bianco, Bedroom
		addPoint(-399.210, -804.168, 39.56, 0, 47.16, 0, 11).AddRequirement('mq7024_guest_room_start', EO_GreaterEqual, 1); //   ===   Corvo Bianco, Guest Room
		addPoint(-685.372, -1193.959, 163.67, 0, 22.39, 0, 11); //   ===   Beauclair Palace
		addPoint(-349.683, -1438.025, 89.43, 0, 26.90, 0, 11); //   ===   Orianna's Estate
	}
	
	public function GetClosestPoint(optional radius : float) : mod_scm_NaughtyPoint
	{
		var i : int;
		var dist : float;
		
		var bestDist : float;
		var bestPoint : mod_scm_NaughtyPoint;
		
		if(radius == 0)
		{
			radius = 100;
		}
		else
		{
			radius = radius*radius;
		}
		
		for(i = points.Size()-1; i >= 0; i-=1)
		{
			if(points[i].SatisfiesRequirements())
			{
				dist = points[i].GetDistanceSq();
				if(dist < radius && (dist <= bestDist || !bestPoint))
				{
					bestDist = dist;
					bestPoint = points[i];
				}
			}
		}
		
		return bestPoint;
	}
	
	private function addPoint(x, y, z, pitch, yaw, roll : float, level : int) : mod_scm_NaughtyPoint
	{
		var np : mod_scm_NaughtyPoint;
		
		np = new mod_scm_NaughtyPoint in this;
		
		np.pos = Vector(x, y, z);
		np.rot = EulerAngles(pitch, yaw, roll);
		np.level = level;
		
		points.PushBack(np);
		
		return np;
	}
}

class mod_scm_NaughtyPoint
{
	public editable var pos : Vector;
	public editable var rot : EulerAngles;
	public editable var level : int;
	public editable var factRequirements : array<MCM_SFactCheck>;
	
	public function AddActionPoint()
	{
		mod_scm_GetSCM().APManager.CreateActionPoint('mod_scm_sexap', pos.X, pos.Y, pos.Z, rot.Pitch, rot.Yaw, rot.Roll);
	}
	
	public function IsCloseToPoint(optional radius : float) : bool
	{
		if(radius == 0)
		{
			radius = 100; //10*10
		}
		else
		{
			radius = radius*radius;
		}
		
		return VecDistanceSquared(pos, thePlayer.GetWorldPosition()) <= radius;
	}
	
	public function SatisfiesRequirements() : bool
	{
		var i : int;
		var levelInt : int;
		
		levelInt = (int)theGame.GetCommonMapManager().GetCurrentArea();
		if(levelInt != level) return false;
		
		if(factRequirements.Size() == 0) return true;
		
		for(i = factRequirements.Size()-1; i >= 0; i-=1)
		{
			if(!MCM_CheckFact(factRequirements[i]))
			{
				return false;
			}
		}
		
		return true;
	}
	
	public function AddRequirement(factName : name, operator : EOperator, value : int) : mod_scm_NaughtyPoint
	{
		var fact : MCM_SFactCheck;
		
		fact.factName = factName;
		fact.operator = operator;
		fact.value = value;
	
		factRequirements.PushBack(fact);
		return this;
	}
	
	public function GetDistanceSq() : float
	{
		return VecDistanceSquared(pos, thePlayer.GetWorldPosition());
	}
}

class mod_scm_SpecialNPCDialogueClazzBase
{
	function create(entSpecialID : name, talkingID : int, time : float) : mod_scm_NPCChatElement
	{
		var chatElement : mod_scm_NPCChatElement;
		
		chatElement = new mod_scm_NPCChatElement in this;
		
		chatElement.entSpecialID = entSpecialID;
		chatElement.talkingID = talkingID;
		chatElement.talkingString = GetLocStringById(talkingID);
		chatElement.time = time;
		
		return chatElement;
	}
	
	public function isValid() : bool
	{
		return false;
	}
	
	public function perform()
	{
		
	}
}

class mod_scm_SpecialNPCOnelinersDefinition extends mod_scm_SpecialNPCDialogueClazzBase
{
	public var specialNPCName : name;
	public var oneliners : array<mod_scm_NPCChatElement>;
	public var preCombatOneLiners : array<mod_scm_NPCChatElement>;
	public var postCombatOneLiners : array<mod_scm_NPCChatElement>;
	
	public function add(talkingID : int, time : float)
	{
		oneliners.PushBack(create(specialNPCName, talkingID, time));
	}
	
	public function addPreC(talkingID : int, time : float)
	{
		preCombatOneLiners.PushBack(create(specialNPCName, talkingID, time));
	}
	
	public function addPostC(talkingID : int, time : float)
	{
		postCombatOneLiners.PushBack(create(specialNPCName, talkingID, time));
	}
	
	public function isValid() : bool
	{
		return mod_scm_GetNPC(specialNPCName, ST_Special, true);
	}
	
	public function perform()
	{
		//var npc : CNewNPC;
		
		//npc = mod_scm_GetNPC(specialNPCName, ST_Special);
		
		//if(npc && npc.scmcc)
		//{
			//npc.scmcc.activateMimics();
			MCM_GetMCM().DialogueManager.AddChat(oneliners[RandRange(oneliners.Size(), 0)]);
		//}
	}
}

class mod_scm_SpecialNPCConversationDefinition extends mod_scm_SpecialNPCDialogueClazzBase
{
	public var requiredNPCs : array<name>;
	public var eventType : int;
	public var dialogueLines : array<mod_scm_NPCChatElement>;
	private var chance : float; default chance = 1.0;
	public function r(nam : name) : mod_scm_SpecialNPCConversationDefinition
	{
		requiredNPCs.PushBack(nam);
		return this;
	}
	
	public function SetChance(chance : float)
	{
		
	}
	
	public function append(entSpecialID : name, talkingID : int, time : float)
	{
		dialogueLines.PushBack(create(entSpecialID, talkingID, time));
	}
	
	public function isValid() : bool
	{
		var sz, i : int;
		
		if(RandRange(1000, 0) / 1000 < chance)
		{
			sz = requiredNPCs.Size();
			
			for(i = 0; i < sz; i+=1)
			{
				if(!mod_scm_GetNPC(requiredNPCs[i], ST_Special, true))
				{
					return false;
				}
			}
			return true;
		}
		
		return false;
	}
	
	public function perform()
	{
		var sz, i : int;
		//var npc : CNewNPC;
		sz = dialogueLines.Size();
		
		for(i = 0; i < sz; i+=1)
		{
			MCM_GetMCM().DialogueManager.AddChat(dialogueLines[i]);
			//thePlayer.MODSCM_ENT.AddChat(dialogueLines[i]);
		}
	}
}

class mod_scm_SpecialNPCDialogues
{
	private var oneliners : array<mod_scm_SpecialNPCOnelinersDefinition>;
	private var conversations : array<mod_scm_SpecialNPCConversationDefinition>;
	
	public editable var talkingCoolDown : int; default talkingCoolDown = 0;
	
	private var GROUP_DEFAULT : int; default GROUP_DEFAULT = 0;
	
	private var isInit : bool; default isInit = false;
	public function init()
	{
		if(isInit) return;
		isInit = true;
		
		initNPCChats_1();
		initNPCChats_2();
		initNPCChats_3();
		initNPCChats_4();
		initNPCChats_5();
		initNPCChats_6();
		initNPCChats_7();
	}
	
	private function createOnelinerElement(nam : name) : mod_scm_SpecialNPCOnelinersDefinition
	{
		var element : mod_scm_SpecialNPCOnelinersDefinition;
		element = new mod_scm_SpecialNPCOnelinersDefinition in this;
		element.specialNPCName = nam;
		
		oneliners.PushBack(element);
		
		return element;
	}
	
	private function createConversationElement() : mod_scm_SpecialNPCConversationDefinition
	{
		var element : mod_scm_SpecialNPCConversationDefinition;
		element = new mod_scm_SpecialNPCConversationDefinition in this;
		
		conversations.PushBack(element);
		
		return element;
	}
	
	private function initNPCChats_1()
	{
		var ciri, yen : mod_scm_SpecialNPCOnelinersDefinition;
		var ciriYenConvo, geraltCiriConvo, geraltYenConvo : mod_scm_SpecialNPCConversationDefinition;

		ciri = createOnelinerElement('cirilla');
		ciri.add(1050806, 0.0); //Let's stay a bit longer.
		ciri.add(1202001, 0.0); //A garkain from Angren. I slew it. All by my lonesome.
		ciri.add(579428, 0.0); //You've much in common.
		ciri.add(320986, 0.0); //I like it when you smile.
		ciri.add(486627, 0.0); //Perhaps you'd care to wager?
		ciri.add(553630, 0.0); //We were right to come.
		ciri.add(497293, 0.0); //Easy. I believe you.
		ciri.add(497828, 0.0); //I didn't intend it to…
		ciri.add(498771, 0.0); //I never lose my way.
		ciri.add(498823, 0.0); //Hmm… not a bad idea.
		ciri.add(539848, 0.0); //Shall we?
		ciri.add(548880, 0.0); //Heh. Thanks a lot.
		ciri.add(549924, 0.0); //You know me. Nothing I like more than breaking rules.
		ciri.add(553394, 0.0); //Remember me training on the pendulum?
		ciri.add(553398, 0.0); //Those months at Kaer Morhen - they passed so quickly.
		ciri.add(557493, 0.0); //You'll see…
		ciri.add(559462, 0.0); //It's not that easy. I tried once, remember?
		ciri.add(558548, 0.0); //Of course.
		ciri.add(559074, 0.0); //Sometimes I wish I could be like them.
		ciri.add(559189, 0.0); //Haha, not what I meant.
		ciri.add(559289, 0.0); //Geralt, you know that's never been true.
		ciri.add(559326, 0.0); //You doubt it?
		ciri.add(559329, 0.0); //What do you mean?
		ciri.add(562408, 0.0); //I wish we'd spent more time together then.
		ciri.add(563183, 0.0); //Pfff. Very funny.
		ciri.add(563940, 0.0); //I'd rather not. Not yet, at least.
		ciri.add(572394, 0.0); //What? Hahahah.
		ciri.add(572945, 0.0); //I wonder what they're doing.
		ciri.add(578071, 0.0); //Mmm, splendid!
		ciri.add(578175, 0.0); //Who taught you that?
		ciri.add(578687, 0.0); //Almost managed to forget it was today.
		ciri.add(579282, 0.0); //You never gave me piggyback rides at Kaer Morhen, remember? Vesemir was the only one willing.
		ciri.add(579530, 0.0); //Ho-ho, I sense trouble…
		ciri.add(540694, 0.0); //Let's ferret on - see if we can't find something even more interesting.
		ciri.add(1065677, 0.0); //Perhaps this was not a good idea after all…
		ciri.add(585008, 0.0); //Ugh, that was horrible…
		ciri.add(1003641, 0.0); //It's… nice.
		ciri.add(1011369, 0.0); //I believe I qualify.
		ciri.add(1043844, 0.0); //I visited a city once that was very much like Novigrad.
		ciri.add(1059193, 0.0); //Speak for yourself.
		ciri.add(557501, 0.0); //Can we go?
		ciri.add(1060721, 0.0); //That went smoothly.
		ciri.add(1063166, 0.0); //Not this time.
		ciri.add(1072014, 0.0); //"A witcher can forget to eat, to drink, to breathe, even, but a witcher never, ever forgets to care for his blade."
		ciri.add(1074656, 0.0); //Seems to me you have a plan. Care to share it with us?
		ciri.add(1077577, 0.0); //Let's try it out, then.
		ciri.add(1127041, 0.0); //Tsk… a bit. But you can't let it bother you.
		ciri.add(321108, 0.0); //Too late now.
		ciri.add(548634, 0.0); //Suppose it can't kill me. Might as well try…
		ciri.add(1124126, 0.0); //Worked out nicely, don't you think?
		ciri.add(1202076, 0.0); //Nothing would make me happier.
		ciri.add(1202080, 0.0); //Ehh, I could stay right here forever.
		ciri.add(588605, 0.0); //Hardly a challenge.
		ciri.add(550197, 0.0); //Think I should go?
		ciri.add(557827, 0.0); //We'll soon find out.
		ciri.add(546737, 0.0); //We've done the hardest part. Only the pleasant bits left now.
		ciri.add(538454, 0.0); //Hmm… There!
		ciri.add(1058963, 0.0); //A bit different.
		ciri.add(571181, 0.0); //I understand…
		ciri.add(1058969, 0.0); //It was hard going at first.
		ciri.add(546694, 0.0); //Almost there.
		ciri.add(486531, 0.0); //They made an exception for me.
		ciri.add(486923, 0.0); //Not so much. A bit.
		ciri.add(480560, 0.0); //Agreed.
		ciri.add(560265, 0.0); //No. I wanted to go with you - that was my idea.
		ciri.add(560397, 0.0); //Do I have a choice?
		ciri.add(557446, 0.0); //When I was last in Novigrad I had my share of troubles…
		ciri.add(557377, 0.0); //Coming with?
		ciri.add(486986, 0.0); //Another chance to win.
		ciri.add(1003629, 0.0); //No point waiting to see if we'll get lucky.
		ciri.add(1011361, 0.0); //Even more so.
		ciri.add(1005337, 0.0); //What's the catch?
		ciri.add(588663, 0.0); //An oren for your thoughts.
		ciri.add(478864, 0.0); //You lead.
		ciri.add(550579, 0.0); //Time we were on our way.
		ciri.add(538450, 0.0); //I wish to thank her. She risked a lot.
		ciri.add(486332, 0.0); //Do they return?
		ciri.add(1202067, 0.0); //I can't say just yet. But I'm not willing to rule it out.
		ciri.add(1193652, 0.0); //Hehe. I know. Still had to try.
		ciri.add(561030, 0.0); //What do I do?
		ciri.add(320974, 0.0); //I know.
		ciri.add(1202037, 0.0); //Aahh, it's lovely here! I could stay forever…
		ciri.add(484690, 0.0); //Oh, yes… From very far away.
		ciri.add(1202047, 0.0); //Why not?
		ciri.add(1192636, 0.0); //Not at all. I'm doing what I ever wanted to do, being who I wanted to be. I believe that's one definition of happiness.
		ciri.add(549267, 0.0); //What's that?
		ciri.add(1192632, 0.0); //I'm still a long way from mastering anything. But I am trying. Anyway, I did learn from the best.
		ciri.add(1192640, 0.0); //Which aspect is that?
		ciri.add(1003398, 0.0); //I still do.
		ciri.add(578067, 0.0); //To be honest, I just wanted to go for a walk with you.
		ciri.add(577551, 0.0); //We really don't need to play hare and hounds.
		ciri.add(577677, 0.0); //Should we go?
		ciri.add(1074904, 0.0); //Shit!
		ciri.add(546255, 0.0); //Hmm… They'll weigh their words more carefully with you there.
		ciri.add(588672, 0.0); //We ought to rejoin them.
		ciri.add(577018, 0.0); //What creature was it?
		ciri.add(580934, 0.0); //You wouldn't believe me if I told you.
		ciri.add(1192652, 0.0); //Geralt… When they treat a woman differently in this world it hardly ever means better. Quite the opposite.
		ciri.add(486272, 0.0); //And you've seen him?
		ciri.add(550263, 0.0); //Ugh. Might've expected it…
		ciri.addPreC(558805, 0.0); //Geralt! On your left!
		ciri.addPostC(478533, 0.0); //Oof. That was close.



		yen = createOnelinerElement('yennefer');
		yen.add(420314, 0.0); //Geralt, we should go now.
		yen.add(528298, 0.0); //I'll hold you to that.
		yen.add(528304, 0.0); //Suddenly, I've an immense desire to drink.
		yen.add(528308, 0.0); //I'm too old to play the blushing bride… Unless you ask nicely.
		yen.add(528312, 0.0); //I'm still mad at you… I've tension to release.
		yen.add(170991, 0.0); //Lovely outfit. You look… dashing.
		yen.add(358846, 0.0); //Do you plan to compliment me all evening?
		yen.add(376363, 0.0); //Most likely.
		yen.add(390133, 0.0); //Thought you'd tend to that immediately.
		yen.add(420477, 0.0); //Geralt, I'd have nothing against you drinking yourself stupid if we had nothing important planned…
		yen.add(434362, 0.0); //Must say it suits you.
		yen.add(464335, 0.0); //Gladly.
		yen.add(478071, 0.0); //That's right.
		yen.add(479351, 0.0); //You're right.
		yen.add(506483, 0.0); //Geralt of Rivia, being romantic.
		yen.add(524235, 0.0); //I'll look at it later.
		yen.add(527265, 0.0); //Mhm. Why is that?
		yen.add(532217, 0.0); //Naturally. One's never too old to learn.
		yen.add(536406, 0.0); //Do you really wish to do this now, Geralt?
		yen.add(545981, 0.0); //Wouldn't count on it.
		yen.add(557093, 0.0); //Sufficiently suspicious, don't you think?
		yen.add(1071646, 0.0); //You've known many?
		yen.add(563616, 0.0); //True. Good decision.
		yen.add(563693, 0.0); //Of course.
		yen.add(584241, 0.0); //It's true.
		yen.add(1008464, 0.0); //I'm afraid you no longer have a choice.
		yen.add(1017806, 0.0); //Yes, we make a good team.
		yen.add(1018380, 0.0); //Truly?
		yen.add(1018456, 0.0); //Ahh… My, it's lovely.
		yen.add(1048306, 0.0); //Really - that's your excuse?
		yen.add(1049447, 0.0); //How did you imagine it?
		yen.add(1051808, 0.0); //I admire your optimism. Wish I shared it.
		yen.add(1051884, 0.0); //That's good enough for me.
		yen.add(1061216, 0.0); //Geralt… I'm sorry, but I'm in no mood for jests.
		yen.add(1061339, 0.0); //That's a relief.
		yen.add(1192418, 0.0); //Never change, Geralt. I beg you.
		yen.add(373165, 0.0); //That was not my intention.
		yen.add(389319, 0.0); //Good. You'll need to tell me more when we have some time.
		yen.add(464341, 0.0); //Well… We don't have to go…
		yen.add(464371, 0.0); //What would we do there for a week?
		yen.add(478502, 0.0); //I don't need a thing. I'm a sorceress, not a village herbalist.
		yen.add(480339, 0.0); //All right… I'll keep my fingers crossed.
		yen.add(480364, 0.0); //Fine… I can't force you.
		yen.add(498045, 0.0); //I'm sure you did. We'll say you won.
		yen.add(520691, 0.0); //I knew you'd be wary.
		yen.add(536337, 0.0); //I merely know when I can indulge my pride, and when I must swallow it.
		yen.add(563903, 0.0); //So?
		yen.add(589991, 0.0); //It's as you said - I've changed my style.
		yen.add(1003087, 0.0); //Ah yes, your famous amnesia…
		yen.add(1018232, 0.0); //Mhm… perhaps that will change now.
		yen.add(1051825, 0.0); //Nothing could be worse than Sodden was.
		yen.add(497953, 0.0); //Be careful.
		yen.add(497965, 0.0); //I mean merely that we should focus on what's most important at the moment.
		yen.add(506090, 0.0); //Is that so?
		yen.add(539457, 0.0); //Terribly sorry, but why must I hear this?
		yen.add(495200, 0.0); //Aha. And you thought I'd find this interesting because…?
		yen.add(532056, 0.0); //Later, Geralt.
		yen.add(560595, 0.0); //I was about to say... it's nice that you protect her. And you did the right thing to go with her.
		yen.add(538561, 0.0); //Geralt… I'm exhausted, hungry and upset. In other words, please let's leave the laughter for later.
		yen.add(537824, 0.0); //Mh. Later perhaps. For now, talk to me. Tell me a story.
		yen.add(498269, 0.0); //Geralt! You scared me!
		yen.add(1126981, 0.0); //You're still one of the prettiest witchers around in my book. Second only to Lambert.
		yen.add(559193, 0.0); //Don't worry. Simplicity has a charm all its own.
		yen.add(1051864, 0.0); //The answer I was hoping for.
		yen.add(522400, 0.0); //… or wield magic.
		yen.add(555183, 0.0); //Geralt… Look!
		yen.add(563168, 0.0); //That proves nothing. We must look around.
		yen.add(543823, 0.0); //Sometimes you really get on my nerves, you know?
		yen.add(554524, 0.0); //What? I thought you knew.
		yen.add(556038, 0.0); //Not one bit.
		yen.add(1056873, 0.0); //Oh, I shall. In due course.
		yen.add(1056877, 0.0); //Correct.
		yen.add(480797, 0.0); //You object?
		yen.add(1064438, 0.0); //Nor do I.
		yen.add(1059266, 0.0); //You promised Ciri you'd train with her.
		yen.add(1071634, 0.0); //Aha! So that's the way the wind blows…
		yen.add(1123906, 0.0); //Time to go.
		yen.add(579393, 0.0); //I'll gladly argue with you about this - some other time.
		yen.add(1047375, 0.0); //Geralt, don't twist my words.
		yen.add(506550, 0.0); //Amazing how a hobby can render a man mysterious, fascinating.
		yen.add(509974, 0.0); //Are you all right?
		yen.add(478771, 0.0); //So, where shall we start?
		yen.add(491935, 0.0); //You're right… Besides, trudging through mud in these heels would be murder.
		yen.add(478752, 0.0); //I don't need everyone to like me. I most value the opinions of those I care about. You, for example.
		yen.add(478487, 0.0); //Geralt, please. This is not the time to debate ethics.
		yen.add(480315, 0.0); //Perhaps we should reexamine what we've learned. We might've missed a clue that would push us forward…
		yen.add(1056627, 0.0); //Geralt, you know me. I'm rare to praise, but when I do, it is sincere.
		yen.add(1006619, 0.0); //It would depend on the situation.
		yen.add(1074424, 0.0); //You'll learn in due course.
		yen.add(1008366, 0.0); //Look. We must search the area.
		yen.add(1022545, 0.0); //It can't all be sweetness and light.
		yen.add(1009046, 0.0); //It shan't take long.
		yen.add(532775, 0.0); //I trust you have an explanation for this. A very good one.
		yen.add(560657, 0.0); //I'm afraid the situation looks grim.
		yen.add(582395, 0.0); //It's clearly in our nature.
		yen.add(539924, 0.0); //It seems someone was literally just here…
		yen.add(480855, 0.0); //This way.
		yen.add(1064190, 0.0); //I know what you're thinking…
		yen.add(482213, 0.0); //What was that?
		yen.add(480585, 0.0); //Mhm. I'm afraid you don't like home - the very concept of it.
		yen.addPreC(496776, 0.0); //Geralt watch out!



		ciriYenConvo = createConversationElement();
		ciriYenConvo.r('cirilla').r('yennefer'); //Required Actors
		ciriYenConvo.append('yennefer', 549067, 4.2); //Atlan Kerk's inclusion should do the trick. Remember the spell?
		ciriYenConvo.append('cirilla', 549069, 4.9); //I remember you teaching me. And to think I thought you an overbearing, cold shrew at the time.
		ciriYenConvo.append('yennefer', 549087, 0.0); //Now, now. This is no time to get soppy.

		geraltCiriConvo = createConversationElement();
		geraltCiriConvo.r('cirilla'); //Required Actors
		geraltCiriConvo.append('PLAYER', 1059699, 2.4); //Weren't the one to do the diving in that cave.
		geraltCiriConvo.append('cirilla', 1059701, 4.9); //Stop whining. You're a witcher, you've dived in murkier waters.
		geraltCiriConvo.append('PLAYER', 1060723, 0.0); //Yeah. Have to tell you about the time I hunted a zeugl.

		geraltCiriConvo = createConversationElement();
		geraltCiriConvo.r('cirilla'); //Required Actors
		geraltCiriConvo.append('PLAYER', 472314, 2.4); //Any witches or cunning women in the area?
		geraltCiriConvo.append('cirilla', 585879, 2.2); //Geraaalt, you're terrible.
		geraltCiriConvo.append('PLAYER', 585881, 0.0); //What'd I say?

		geraltCiriConvo = createConversationElement();
		geraltCiriConvo.r('cirilla'); //Required Actors
		geraltCiriConvo.append('PLAYER', 433518, 0.8); //Ciri!
		geraltCiriConvo.append('PLAYER', 158228, 1.4); //You all right?
		geraltCiriConvo.append('cirilla', 497880, 0.0); //Mhm. Yes. It's fine.

		geraltCiriConvo = createConversationElement();
		geraltCiriConvo.r('cirilla'); //Required Actors
		geraltCiriConvo.append('cirilla', 1077618, 2.8); //The Path awaits. Come on.
		geraltCiriConvo.append('PLAYER', 1050818, 0.0); //Yeah, let's get going.

		geraltCiriConvo = createConversationElement();
		geraltCiriConvo.r('cirilla'); //Required Actors
		geraltCiriConvo.append('PLAYER', 557928, 1.8); //Always getting into trouble…
		geraltCiriConvo.append('cirilla', 557930, 0.0); //I take after you.

		geraltCiriConvo = createConversationElement();
		geraltCiriConvo.r('cirilla'); //Required Actors
		geraltCiriConvo.append('PLAYER', 577548, 1.0); //Careful now.
		geraltCiriConvo.append('cirilla', 577549, 0.0); //This is no time for you to lecture me.

		geraltCiriConvo = createConversationElement();
		geraltCiriConvo.r('cirilla'); //Required Actors
		geraltCiriConvo.append('cirilla', 569484, 2.0); //That was… strange.
		geraltCiriConvo.append('PLAYER', 569485, 0.0); //To say the least.

		geraltCiriConvo = createConversationElement();
		geraltCiriConvo.r('cirilla'); //Required Actors
		geraltCiriConvo.append('cirilla', 578150, 2.8); //How exactly do you plan to catch anything?
		geraltCiriConvo.append('PLAYER', 578157, 0.0); //Heh, you'll see.

		geraltCiriConvo = createConversationElement();
		geraltCiriConvo.r('cirilla'); //Required Actors
		geraltCiriConvo.append('PLAYER', 560451, 3.4); //Ciri, didn't you have something to take care of?
		geraltCiriConvo.append('cirilla', 581716, 0.0); //Geralt, please. Not now.

		geraltCiriConvo = createConversationElement();
		geraltCiriConvo.r('cirilla'); //Required Actors
		geraltCiriConvo.append('PLAYER', 1002747, 0.0); //Stay calm.

		geraltCiriConvo = createConversationElement();
		geraltCiriConvo.r('cirilla'); //Required Actors
		geraltCiriConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.

		if(FactsQuerySum('mq7023_romance_yen'))
		{
		geraltYenConvo = createConversationElement();
		geraltYenConvo.r('yennefer'); //Required Actors
		geraltYenConvo.append('yennefer', 538508, 3.7); //Oh, decided to put in the effort… Thank you.
		geraltYenConvo.append('PLAYER', 538510, 2.2); //I get a gratuity for that?
		geraltYenConvo.append('yennefer', 538512, 0.0); //Later, perhaps…

		geraltYenConvo = createConversationElement();
		geraltYenConvo.r('yennefer'); //Required Actors
		geraltYenConvo.append('PLAYER', 1022538, 1.9); //I love you, Yen.
		geraltYenConvo.append('yennefer', 1022540, 0.0); //And I love you.

		geraltYenConvo = createConversationElement();
		geraltYenConvo.r('yennefer'); //Required Actors
		geraltYenConvo.append('PLAYER', 1123901, 2.2); //Yen, I adore you.
		geraltYenConvo.append('yennefer', 1123903, 0.0); //Hm. No points for creativity. But for your candor…

		geraltYenConvo = createConversationElement();
		geraltYenConvo.r('yennefer'); //Required Actors
		geraltYenConvo.append('PLAYER', 464305, 1.4); //You smell wonderful.
		geraltYenConvo.append('yennefer', 498041, 0.0); //Geralt… That's enough, hm?

		geraltYenConvo = createConversationElement();
		geraltYenConvo.r('yennefer'); //Required Actors
		geraltYenConvo.append('PLAYER', 165628, 2.1); //Didn't want to detract from your beauty.
		geraltYenConvo.append('yennefer', 434251, 0.0); //A man at a woman's side is an accessory - he should enhance her beauty. But I thank you for the compliment.

		geraltYenConvo = createConversationElement();
		geraltYenConvo.r('yennefer'); //Required Actors
		geraltYenConvo.append('PLAYER', 498062, 2.6); //You could stand to be nicer sometimes.
		geraltYenConvo.append('yennefer', 498064, 0.0); //I suppose… but then I wouldn't be the woman you fell in love with, would I?

		geraltYenConvo = createConversationElement();
		geraltYenConvo.r('yennefer'); //Required Actors
		geraltYenConvo.append('yennefer', 480602, 6.2); //I asked you once to move to Vengerberg for me. Remember? Was that ever a row…
		geraltYenConvo.append('PLAYER', 480604, 0.0); //Yeah… Those were the days…
		}

		geraltYenConvo = createConversationElement();
		geraltYenConvo.r('yennefer'); //Required Actors
		geraltYenConvo.append('PLAYER', 584211, 2.1); //Shh. Hear that?
		geraltYenConvo.append('yennefer', 480899, 0.0); //No… I may be inhumanly beautiful, but I don't have superhuman senses. Not like you.

		geraltYenConvo = createConversationElement();
		geraltYenConvo.r('yennefer'); //Required Actors
		geraltYenConvo.append('yennefer', 1074368, 2.4); //You think someone may wish to hurt me?
		geraltYenConvo.append('PLAYER', 1074370, 0.0); //Think I should warn off anyone who'd be dumb enough to try.

		geraltYenConvo = createConversationElement();
		geraltYenConvo.r('yennefer'); //Required Actors
		geraltYenConvo.append('PLAYER', 1002747, 0.0); //Stay calm.

		geraltYenConvo = createConversationElement();
		geraltYenConvo.r('yennefer'); //Required Actors
		geraltYenConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.
	}

	private function initNPCChats_2()
	{
		var triss, shani, anarietta : mod_scm_SpecialNPCOnelinersDefinition;
		var geraltTrissConvo, geraltShaniConvo, geraltAnnaConvo : mod_scm_SpecialNPCConversationDefinition;

		triss = createOnelinerElement('triss');
		triss.add(1123760, 0.0); //You always say that.
		triss.add(1123764, 0.0); //Ah, Geralt. You're so charming when you try to be funny.
		triss.add(1123768, 0.0); //Mhm. Sure.
		triss.add(364916, 0.0); //I think we're going the wrong way…
		triss.add(427029, 0.0); //Care to sit down for a spell?
		triss.add(429568, 0.0); //Is that necessary?
		triss.add(495258, 0.0); //True… But it's not an easy thing to say, is it?
		triss.add(430328, 0.0); //Like no one else.
		triss.add(435100, 0.0); //Oh, I'd love to see it all…
		triss.add(435182, 0.0); //Well? Hahaha. Come on!
		triss.add(455641, 0.0); //Leave it to me.
		triss.add(455721, 0.0); //Mhm. Soon.
		triss.add(490252, 0.0); //Sadly, no. I'm a sorceress, not a miracle worker.
		triss.add(456882, 0.0); //Actually… We've never needed either.
		triss.add(456927, 0.0); //That simple?
		triss.add(459081, 0.0); //Oh! Let's look around.
		triss.add(490216, 0.0); //Right… Could find something that'll help us…
		triss.add(480869, 0.0); //Maybe some other time.
		triss.add(487404, 0.0); //Yes. High time.
		triss.add(488461, 0.0); //So. What now?
		triss.add(489919, 0.0); //Yeah. But I also need to blow off some steam.
		triss.add(490163, 0.0); //No need. I'm fine.
		triss.add(490553, 0.0); //I didn't expect such devotion.
		triss.add(499792, 0.0); //We need to hurry.
		triss.add(490668, 0.0); //But you do have a history of amnesia.
		triss.add(490794, 0.0); //You can. Wouldn't recommend it, though.
		triss.add(490350, 0.0); //Nothing but dead ends… We'll need to make do…
		triss.add(495339, 0.0); //More precisely?
		triss.add(495416, 0.0); //If we learn anything, great. If not…
		triss.add(496463, 0.0); //Of something strong, I hope…
		triss.add(499790, 0.0); //I have, for one.
		triss.add(500220, 0.0); //Healthy attitude. Must've lived long.
		triss.add(500228, 0.0); //I think he just didn't have much of a choice…
		triss.add(555772, 0.0); //I wasn't sure at first… Ultimately, though, it's something I've always dreamed of.
		triss.add(496412, 0.0); //Geralt, you know me… I'm all for finding solutions. I don't give up easily…
		triss.add(578978, 0.0); //Weren't you supposed to be somewhere?
		triss.add(579417, 0.0); //That would probably be best.
		triss.add(580135, 0.0); //Really? That's... wonderful!
		triss.add(587187, 0.0); //You get everything?
		triss.add(587237, 0.0); //It's not that.
		triss.add(589907, 0.0); //Don't you dare. You look great.
		triss.add(590103, 0.0); //So? Learn anything?
		triss.add(1000754, 0.0); //Hahaha. Careful - that sounded like a compliment.
		triss.add(1000811, 0.0); //You're terrible, you know that?
		triss.add(1000818, 0.0); //Pfff, a witcher's compliments…
		triss.add(477672, 0.0); //Be on your guard. It could be something far more dangerous.
		triss.add(1013072, 0.0); //Don't need to worry about me.
		triss.add(1040502, 0.0); //Ah… yes… the good old days.
		triss.add(1041442, 0.0); //What're you doing?
		triss.add(1041474, 0.0); //Here's something.
		triss.add(1059255, 0.0); //Want the long or the short version?
		triss.add(1065644, 0.0); //I'm not so sure.
		triss.add(555358, 0.0); //Good idea. Let's go.
		triss.add(1075411, 0.0); //If you knew, you wouldn't be so sure.
		triss.add(1192582, 0.0); //I have my ways, Geralt. Hydromancy, for example.
		triss.add(554645, 0.0); //Don't trouble yourself.
		triss.add(1052059, 0.0); //Everything's ready. Let's get to work.
		triss.add(1063352, 0.0); //It's a trap, Geralt.
		triss.add(1123702, 0.0); //Unbelievable. You said something romantic! You, Geralt of Rivia!
		triss.add(1060322, 0.0); //Not exactly. Nothing even remotely satisfying. Such are the times.
		triss.add(545347, 0.0); //I sense strong magic.
		triss.add(1123690, 0.0); //And what do you think about?
		triss.add(456812, 0.0); //I won't disagree.
		triss.add(456908, 0.0); //Yes. Forgot you're not the type to settle down.
		triss.add(463362, 0.0); //Yes. Somewhere, over hill and dale…
		triss.add(545349, 0.0); //We have to get inside.
		triss.add(587194, 0.0); //Were you able to get everything we need?
		triss.add(555983, 0.0); //Come on.
		triss.add(491313, 0.0); //Stop. It doesn't befit a sorceress to blush.
		triss.add(489609, 0.0); //Geralt, I have a lot of things to take care of in town.
		triss.add(489725, 0.0); //I'll do everything I can, of course. Who might know more?
		triss.add(1000463, 0.0); //Geralt!
		triss.add(1008999, 0.0); //Seems so long ago… Probably because so much has changed.
		triss.add(1075398, 0.0); //Hm. So-so. Why do you ask?
		triss.add(439882, 0.0); //Or we're too late…
		triss.add(528839, 0.0); //Is that what you think?
		triss.add(1000666, 0.0); //You really think so?
		triss.add(1000670, 0.0); //Hahah. For a moment there I thought you were being sincere.
		triss.add(576616, 0.0); //Come on. We should hurry.
		triss.add(579026, 0.0); //Where'd you agree to meet?
		triss.add(581956, 0.0); //So did I. But I changed my mind.
		triss.add(499821, 0.0); //We settled on a full coin purse.
		triss.add(564248, 0.0); //I can't wait.
		triss.add(500250, 0.0); //Even if it's hard to swallow?
		triss.add(500254, 0.0); //Who knows… maybe one day…
		triss.add(496450, 0.0); //Ugh, fine. Never mind.
		triss.add(535743, 0.0); //You mean the Lodge?
		triss.add(563021, 0.0); //Of course. Even got an idea where you could start.
		triss.add(534224, 0.0); //There is an upside to all this.
		triss.add(534283, 0.0); //Though we could try to force our way through…
		triss.add(488695, 0.0); //Nice of you to worry… But I've made my decision, and I won't change it.
		triss.add(510820, 0.0); //Let's go find him.
		triss.add(1192544, 0.0); //And sadly, that's not far from the truth…
		triss.add(488320, 0.0); //Hope not.
		triss.add(562968, 0.0); //Ciri can handle herself… Gets it from you…
		triss.add(564225, 0.0); //So we've prepared… something special.
		triss.add(488666, 0.0); //This might come as a surprise to you, but shackles do have uses outside the bedroom.
		triss.add(1000779, 0.0); //Something you've been meaning to say to me?
		triss.add(1000835, 0.0); //Always? Guess I remember things a little differently…
		triss.add(587216, 0.0); //Oh my, certainly took my request to heart.
		triss.addPostC(380142, 0.0); //Think that's all of them… That was close.



		shani = createOnelinerElement('shani');
		shani.add(1097308, 0.0); //I studied medicine, not literature. I stopped believing in fairytales long ago.
		shani.add(1117203, 0.0); //A witcher never lets an opportunity pass, is that it?
		shani.add(1097375, 0.0); //What now?
		shani.add(1115489, 0.0); //The family hit on hard times. No coin to splurge on such luxuries.
		shani.add(1097480, 0.0); //Ugh, fine…
		shani.add(1097484, 0.0); //I promise.
		shani.add(1099208, 0.0); //You're actually quite amusing this way.
		shani.add(1099676, 0.0); //Righto. I'm sure we'll all have a splendid time.
		shani.add(1099743, 0.0); //Wondrous times.
		shani.add(1100198, 0.0); //No. What?
		shani.add(1101407, 0.0); //Oh, really?
		shani.add(1101429, 0.0); //Yes, we'd best not mention those.
		shani.add(1101433, 0.0); //I see.
		shani.add(1101435, 0.0); //But what?
		shani.add(1101439, 0.0); //I'll hold you to that.
		shani.add(1101524, 0.0); //Hmm, something specific in mind?
		shani.add(1101758, 0.0); //Do you need help?
		shani.add(1102612, 0.0); //Good idea.
		shani.add(1102811, 0.0); //What is?
		shani.add(1107884, 0.0); //Give me its essence.
		shani.add(1130721, 0.0); //Of course! Tell you what - I'll keep one handy.
		shani.add(1108852, 0.0); //I think you look charming.
		shani.add(1109798, 0.0); //I'll think about it.
		shani.add(1102091, 0.0); //An entire lifetime, more like.
		shani.add(1111907, 0.0); //What?
		shani.add(1113592, 0.0); //I'm… not sure I do.
		shani.add(1119280, 0.0); //Don't let me stop you.
		shani.add(1111954, 0.0); //I didn't say anything.
		shani.add(1112059, 0.0); //Hahaha! Only sometimes.
		shani.add(1112073, 0.0); //I've got a better idea.
		shani.add(1112154, 0.0); //Why not?
		shani.add(1113559, 0.0); //Huh. You're rather good at this.
		shani.add(1097258, 0.0); //Nice of you to offer, but I'd rather go with you, collect the sample myself.
		shani.add(1116106, 0.0); //What do you mean?
		shani.add(1116119, 0.0); //Is that so? Prove it.
		shani.add(1116240, 0.0); //So what went wrong?
		shani.add(1116448, 0.0); //Hahahaha! You're incorrigible.
		shani.add(1116452, 0.0); //What's going on now?
		shani.add(1119137, 0.0); //Right behind you.
		shani.add(1119377, 0.0); //Yes… yes, that's best.
		shani.add(1101415, 0.0); //I don't know if I should thank you or if that should make me… angry.
		shani.add(1109812, 0.0); //Mh. I never knew you to be such a gambler.
		shani.add(1130062, 0.0); //You do? How?
		shani.add(1130108, 0.0); //Someday, I'm sure.
		shani.add(1130279, 0.0); //Hm… I do that sometimes.
		shani.add(1112030, 0.0); //You seem to have enjoyed yourself. I'm glad.
		shani.add(1136512, 0.0); //Ask me now.
		shani.add(1136516, 0.0); //I should think so!
		shani.add(1137619, 0.0); //Don't let it bother you.
		shani.add(1137687, 0.0); //Come now, spit it out.
		shani.add(1104983, 0.0); //Thanks, Geralt.
		shani.add(1097296, 0.0); //This way.
		shani.add(1119052, 0.0); //Geralt! Are you all right?
		shani.add(1119121, 0.0); //What kind of beast would do that?
		shani.add(1119126, 0.0); //Does that mean anything?
		shani.add(1119103, 0.0); //Yes, some spirit, but that was it. Why do you ask?
		shani.add(1119109, 0.0); //Are you suggesting… the beast likes alcohol?
		shani.add(1119147, 0.0); //How? We don't even know what kind of monster it is.
		shani.add(1102553, 0.0); //Don't make excuses, Geralt. I'm not angry. A witcher has to ply his trade, follow his Path.
		shani.add(1117195, 0.0); //I don't believe that. You'd let the opportunity pass?
		shani.add(1107989, 0.0); //Here it is!
		shani.add(1115481, 0.0); //Shall we?
		shani.add(1115491, 0.0); //Ooh, that looks just a little too creepy for me…
		shani.add(1112302, 0.0); //Uh, all right. Seems we've no other option.
		shani.add(1121417, 0.0); //Yes, that's it.
		shani.add(1116134, 0.0); //Fine, fine. I'll stay out of your way.
		shani.add(1129224, 0.0); //Hm, that's quite the theory.
		shani.add(1115598, 0.0); //And what's that mean?
		shani.add(1117178, 0.0); //Really think so?
		shani.add(1114212, 0.0); //Ooh. Gorgeous.
		shani.add(1114220, 0.0); //That I cannot tell you.
		shani.add(1119302, 0.0); //So, how'd it compare?
		shani.add(1119323, 0.0); //Sounds interesting.
		shani.add(1132040, 0.0); //How did you know...?
		shani.add(1119336, 0.0); //Forgotten already?
		shani.add(1119340, 0.0); //Exactly…
		shani.add(1107894, 0.0); //Mhm. And I'm a Koviri duchess.
		shani.add(1108053, 0.0); //Who's this?
		shani.add(1115408, 0.0); //But that's necromancy! It's extraordinarily risky and involves higher magic.
		shani.add(1121442, 0.0); //I understand. Whose ghost is it?
		shani.add(1129240, 0.0); //Hahaha! No, that's not mine.
		shani.add(1126826, 0.0); //Always do. So don't worry.
		shani.add(1128283, 0.0); //Long story.
		shani.add(1119358, 0.0); //Sure, be glad to.
		shani.add(1130700, 0.0); //True. Nothing's changed in that sense.
		shani.add(1130725, 0.0); //I'm a medic. I tend to know what I'm doing when I prescribe something.
		shani.add(1108108, 0.0); //I liked some of that nonsense.
		shani.add(1128482, 0.0); //Is it worth searching outside?
		shani.add(1117199, 0.0); //I think you would've seized the opportunity.
		shani.add(1119056, 0.0); //Mh. Fine.
		shani.add(1097461, 0.0); //Hope so. But I'd still like to get some pure venom… once you've killed the monster.
		shani.add(1092448, 0.0); //I've tested the slime samples. I believe I'll be able to brew an antidote.
		shani.add(1127185, 0.0); //That can be arranged. They keep one in a storehouse at the academy. I can fetch it for you.
		shani.add(1108376, 0.0); //I should hope so. I'm a surgeon.
		shani.add(1108387, 0.0); //Not mine, silly. My friend's.
		shani.add(1108592, 0.0); //Change your mind?
		shani.add(1101425, 0.0); //Is there anything you do that's not fantastic?
		shani.add(1106728, 0.0); //How goes the search?
		shani.add(1119872, 0.0); //It was positively gripping.
		shani.add(1117136, 0.0); //I haven't managed to yet.



                anarietta = createOnelinerElement('anna_henrietta');
                anarietta.add(1166999, 0.0); //Naturally. But not here.
                anarietta.add(1168046, 0.0); //I fear you'd not have much use for any of the surprises we are likely to come upon.
                anarietta.add(1173215, 0.0); //Strange question.
                anarietta.add(1167100, 0.0); //First and foremost, we must remain calm.
                anarietta.add(1199346, 0.0); //What if something has happened to him…?
                anarietta.add(1199510, 0.0); //All clear? Then let's get to it.
                anarietta.add(1201732, 0.0); //Who wrote this drivel?!
                anarietta.add(1201595, 0.0); //Why ever would it be? I'm listening, what is it?
                anarietta.add(1201627, 0.0); //Not overtly. I was married to Raymund at the time, after all.
                anarietta.add(1201603, 0.0); //I understand. Understand and approve.
                anarietta.add(1179341, 0.0); //How… what creature can do such things?
                anarietta.add(1194324, 0.0); //And what do you propose to do?
                anarietta.add(1195171, 0.0); //You were to destroy him, not help him.
                anarietta.add(1157824, 0.0); //How did it end? Did you kill it?
                anarietta.add(1168753, 0.0); //Have you ever heard of anyone defeating such a vampire?
                anarietta.add(1174764, 0.0); //They were fortunate we happened by.
                anarietta.add(1171001, 0.0); //We shall know when we arrive. It's not far now.
                anarietta.add(1192250, 0.0); //Come, witcher.
                anarietta.add(1185354, 0.0); //An excellent wine. You've good taste.
                anarietta.add(1185346, 0.0); //Among the best in the world. Castel Ravello is famous for it.
                anarietta.add(1185342, 0.0); //Ah, yes, that sophisticated palate of his.
                anarietta.add(1171949, 0.0); //What now, witcher?
                anarietta.add(1199342, 0.0); //There's something I'd like to know… How can you be so damned calm?
                anarietta.add(1199286, 0.0); //Precisely what we shall do.
                anarietta.add(1185415, 0.0); //What do you mean?
                anarietta.add(1185610, 0.0); //What was the matter?
                anarietta.add(1197245, 0.0); //Never suspected you believed in such things.
                anarietta.add(1195603, 0.0); //Ah, how beautiful…
                anarietta.add(1197711, 0.0); //I do not even wish to comment…
                anarietta.add(1173552, 0.0); //Come, we must consider what to do.
                anarietta.add(1174171, 0.0); //Is this the only evidence we've found?
                anarietta.add(1200343, 0.0); //Geralt, where are you going? We've a job to do.
                anarietta.add(1200070, 0.0); //Made a fool? Whom by?
                anarietta.add(1195190, 0.0); //You're mistaken, you must be. This cannot be true.
                anarietta.add(1186778, 0.0); //What? You know him? Who is he?
                anarietta.add(1201494, 0.0); //Where is he now?
                anarietta.add(1173081, 0.0); //The fact that it did was no accident, I'm sure…
                anarietta.add(1149511, 0.0); //Is this all you have to say?
                anarietta.add(1187751, 0.0); //I trust you shall make good use of it.
                anarietta.add(1166336, 0.0); //I've a feeling we'll find something awry…
                anarietta.add(1209924, 0.0); //Witcher, hurry.
                anarietta.add(1185578, 0.0); //Lead on, witcher.
                anarietta.add(1189188, 0.0); //Geralt, we haven't the time, come…
                anarietta.add(1174893, 0.0); //Not much, but I've a good sense of the true nature of those I meet. I'd not survive a week at court otherwise.
                anarietta.add(1198530, 0.0); //I do not believe it.
                anarietta.add(1188976, 0.0); //I think… you may still get your chance.
                anarietta.add(1167037, 0.0); //The response we expected.
                anarietta.add(1161495, 0.0); //We must go to where the game is being held.
                anarietta.add(1199445, 0.0); //It's terribly skittish, true, but I'm sure you will find a way to earn its trust.
                anarietta.add(1161038, 0.0); //We've no time to lose!
                anarietta.add(1201713, 0.0); //Now that's just silly.
                anarietta.add(1194177, 0.0); //Hmm… I admit to being swayed, witcher. You may be right… Do you know anything about the blackmailer?
                anarietta.add(1170914, 0.0); //I hope you do not suppose we will sit on our ducal hiney and do nothing while our duchy is in grave danger?
                anarietta.add(1171833, 0.0); //We will travel incognito. We've no wish to give the court any reason to gossip…
                anarietta.add(1157810, 0.0); //He's held his post for years. There's never been a problem till now…
                anarietta.add(1199338, 0.0); //He's late…
                anarietta.add(1200045, 0.0); //So… so it is not him we seek, but his employer.
                anarietta.add(1176156, 0.0); //Few make me feel awkward, but in her presence, I sense anxiety, discomfort.
                anarietta.add(1185330, 0.0); //It… it could be something else altogether.
                anarietta.add(1186589, 0.0); //A propos, were you able to establish who kidnapped his beloved?



		if(FactsQuerySum('mq7023_romance_triss'))
		{
		geraltTrissConvo = createConversationElement();
		geraltTrissConvo.r('triss'); //Required Actors
		geraltTrissConvo.append('PLAYER', 1123676, 3.2); //Hm. There's a lighthouse not far from here, you know.
		geraltTrissConvo.append('triss', 1123679, 2.6); //Geralt! Are you suggesting we--?
		geraltTrissConvo.append('PLAYER', 1123681, 4.4); //No… well, at least not right now. Just wanted to say…
		geraltTrissConvo.append('PLAYER', 1123684, 0.0); //Wanted to say that since… since Novigrad, whenever I see the beam of a lighthouse, I feel good. Thinking of you.

		geraltTrissConvo = createConversationElement();
		geraltTrissConvo.r('triss'); //Required Actors
		geraltTrissConvo.append('triss', 421810, 2.7); //Come on, Geralt!
		geraltTrissConvo.append('PLAYER', 589984, 1.3); //Someone's in a good mood.
		geraltTrissConvo.append('triss', 589993, 1.0); //So?
		geraltTrissConvo.append('PLAYER', 589995, 0.0); //Nothing. Just, you look good when you're giddy.

		geraltTrissConvo = createConversationElement();
		geraltTrissConvo.r('triss'); //Required Actors
		geraltTrissConvo.append('PLAYER', 490665, 1.7); //Seem to be in your element.
		geraltTrissConvo.append('triss', 490666, 3.2); //Still remember my elements, how I use them?
		geraltTrissConvo.append('PLAYER', 490667, 0.0); //Come on, six months isn't that long. And it's not like I'm senile.

		geraltTrissConvo = createConversationElement();
		geraltTrissConvo.r('triss'); //Required Actors
		geraltTrissConvo.append('triss', 456771, 5.9); //Well, they say Kovir's lovely this time of year… But I prefer you.
		geraltTrissConvo.append('PLAYER', 456810, 0.0); //Haha, not surprised. I'm pretty lovely this time of year, too.

		geraltTrissConvo = createConversationElement();
		geraltTrissConvo.r('triss'); //Required Actors
		geraltTrissConvo.append('triss', 1123771, 1.9); //I love you, you know.
		geraltTrissConvo.append('PLAYER', 1123783, 0.0); //Love you too.

		geraltTrissConvo = createConversationElement();
		geraltTrissConvo.r('triss'); //Required Actors
		geraltTrissConvo.append('PLAYER', 555867, 8.4); //The life of a witcher, it's no fairytale. But I like being on the Path, sleeping under the stars, waking up with dew on my face…
		geraltTrissConvo.append('triss', 555874, 0.0); //You can set out on the Path whenever you want, for however long you want…
		}

		geraltTrissConvo = createConversationElement();
		geraltTrissConvo.r('triss'); //Required Actors
		geraltTrissConvo.append('PLAYER', 1003986, 2.4); //Don't go near this, Triss. It's too risky.
		geraltTrissConvo.append('triss', 380300, 0.0); //Geralt, remember, I can take care of myself.

		geraltTrissConvo = createConversationElement();
		geraltTrissConvo.r('triss'); //Required Actors
		geraltTrissConvo.append('triss', 381679, 4.9); //I must say, trickery and deceit - not your strong suits.
		geraltTrissConvo.append('PLAYER', 381681, 0.0); //True. I prefer straightforward solutions.

		geraltTrissConvo = createConversationElement();
		geraltTrissConvo.r('triss'); //Required Actors
		geraltTrissConvo.append('triss', 1064690, 1.2); //Geralt, those are--
		geraltTrissConvo.append('PLAYER', 1064692, 0.0); //I know who they are, Triss.

		geraltTrissConvo = createConversationElement();
		geraltTrissConvo.r('triss'); //Required Actors
		geraltTrissConvo.append('PLAYER', 1002747, 0.0); //Stay calm.

		geraltTrissConvo = createConversationElement();
		geraltTrissConvo.r('triss'); //Required Actors
		geraltTrissConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.

		geraltShaniConvo = createConversationElement();
		geraltShaniConvo.r('shani'); //Required Actors
		geraltShaniConvo.append('shani', 1111946, 1.4); //So who was it?
		geraltShaniConvo.append('PLAYER', 1108060, 4.8); //Hm. Could be a mage, a demon… or a djinn.
		geraltShaniConvo.append('shani', 1108068, 1.8); //You don't know?
		geraltShaniConvo.append('PLAYER', 1108070, 0.0); //He's very powerful - that's all I need to know.

		geraltShaniConvo = createConversationElement();
		geraltShaniConvo.r('shani'); //Required Actors
		geraltShaniConvo.append('shani', 1108130, 2.8); //It would do you good to be more relaxed sometimes.
		geraltShaniConvo.append('PLAYER', 1108132, 2.6); //Relaxed? So you think I'm uptight?
		geraltShaniConvo.append('shani', 1108134, 0.0); //What I mean is it would be nice from time to time if you could sit back and enjoy life, instead of going around solving everyone's problems.

		geraltShaniConvo = createConversationElement();
		geraltShaniConvo.r('shani'); //Required Actors
		geraltShaniConvo.append('shani', 1111912, 3.5); //Geralt. Care to explain what's going on here?
		geraltShaniConvo.append('PLAYER', 1121445, 4.6); //Shani, please. No use complaining. Just help me.
		geraltShaniConvo.append('shani', 1121447, 0.0); //I'm not complaining. I'm concerned.

		geraltShaniConvo = createConversationElement();
		geraltShaniConvo.r('shani'); //Required Actors
		geraltShaniConvo.append('PLAYER', 523426, 1.2); //Thanks for coming.
		geraltShaniConvo.append('shani', 1115412, 3.4); //Don't mention it. But I still don't like this…
		geraltShaniConvo.append('PLAYER', 465198, 0.0); //It's all right. It'll be over soon.

		geraltShaniConvo = createConversationElement();
		geraltShaniConvo.r('shani'); //Required Actors
		geraltShaniConvo.append('shani', 1097488, 1.8); //Be careful, Geralt.
		geraltShaniConvo.append('PLAYER', 1108590, 0.0); //Oh, I will be. Wouldn't want to give you even more work.

		geraltShaniConvo = createConversationElement();
		geraltShaniConvo.r('shani'); //Required Actors
		geraltShaniConvo.append('PLAYER', 496159, 4.5); //It's dangerous, there are risks involved. Understand that, don't you?
		geraltShaniConvo.append('shani', 1097262, 0.0); //I'm a big girl, Geralt. I can take care of myself. And you know I'll get my way, so don't try to talk me out of anything.

		geraltShaniConvo = createConversationElement();
		geraltShaniConvo.r('shani'); //Required Actors
		geraltShaniConvo.append('PLAYER', 1124111, 2.2); //Been a huge help already, Shani. Thanks.
		geraltShaniConvo.append('shani', 1125980, 0.0); //It was nothing, really. You'd have done the same for me.

		geraltShaniConvo = createConversationElement();
		geraltShaniConvo.r('shani'); //Required Actors
		geraltShaniConvo.append('PLAYER', 1002747, 0.0); //Stay calm.

		geraltShaniConvo = createConversationElement();
		geraltShaniConvo.r('shani'); //Required Actors
		geraltShaniConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.

		geraltAnnaConvo = createConversationElement();
		geraltAnnaConvo.r('anna_henrietta'); //Required Actors
		geraltAnnaConvo.append('PLAYER', 1002747, 0.0); //Stay calm.

		geraltAnnaConvo = createConversationElement();
		geraltAnnaConvo.r('anna_henrietta'); //Required Actors
		geraltAnnaConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.
	}

	private function initNPCChats_3()
	{
		var avallach, baron, cerys, damien, dandelion, dettlaff : mod_scm_SpecialNPCOnelinersDefinition;
		var geraltAvallachConvo, geraltBaronConvo, geraltCerysConvo, geraltDamienConvo, geraltDandelionConvo, geraltDettlaffConvo : mod_scm_SpecialNPCConversationDefinition;

                avallach = createOnelinerElement('avallach');
                avallach.add(532899, 0.0); //You humans have… hm, unusual tastes.
                avallach.add(565584, 0.0); //Such drastic means are not always necessary.
                avallach.add(565592, 0.0); //Brilliant deduction, bravo.
                avallach.add(534476, 0.0); //You clearly know there are many other worlds apart from the one where we now stand.
                avallach.add(569369, 0.0); //This is the place.
                avallach.add(584032, 0.0); //Not here, not now.
                avallach.add(538442, 0.0); //This way.
                avallach.add(530546, 0.0); //I trust you did not make a mess.
                avallach.add(1009410, 0.0); //Come, we must go.
                avallach.add(1047389, 0.0); //We must be careful they don't sense us.
                avallach.add(1022646, 0.0); //Appearances can be deceiving.
                avallach.add(454814, 0.0); //At last.
                avallach.add(559504, 0.0); //Let us hope.
                avallach.add(534067, 0.0); //I never doubted you would. But why did you? You might've just asked me.
                avallach.add(565521, 0.0); //I'd even call it a secret.
                avallach.add(534705, 0.0); //At times one must use reason, rather than blades.
                avallach.add(572978, 0.0); //Clearly to no effect.
                avallach.add(548524, 0.0); //As many as it takes.
                avallach.add(565548, 0.0); //Oh, I assure you, he's excellent at covering his tracks - though not terribly subtle.
                avallach.add(534154, 0.0); //Nothing you need worry about.
                avallach.add(539059, 0.0); //"How" matters not. What matters is I know - and I've an idea how to use this knowledge.
                avallach.add(534479, 0.0); //That is precisely one of the reasons why Ge'els abhors your world. Your senseless brutality.
                avallach.add(565632, 0.0); //They're linked by passages, hidden gateways that afford travel from one world to another.
                avallach.add(534514, 0.0); //Of course, few know of these gateways, even fewer can locate them.
                avallach.add(565798, 0.0); //That's our chance. Shall we go?
                avallach.add(572896, 0.0); //Supposed to?
                avallach.add(584740, 0.0); //It's possible. I lack your ward's talent. Zireael is the Lady of Time and Space, I merely know how to use this arcane knowledge to a limited degree.
                avallach.add(1042755, 0.0); //Mainly desert creatures able to survive months on end without water.
                avallach.add(1042761, 0.0); //Do you believe humanoids have a monopoly on destroying worlds?
                avallach.add(1042769, 0.0); //Or the bottom of a sea.
                avallach.add(1042777, 0.0); //That there are many different worlds, and even more forms of life.
                avallach.add(1010869, 0.0); //Ugh. What would it have changed?
                avallach.add(585964, 0.0); //Yes. He's righteous.
                avallach.add(1010909, 0.0); //I warned you it could happen.
                avallach.add(1023398, 0.0); //Shortly.
                avallach.add(1063146, 0.0); //You have done the thing most just.
                avallach.add(555589, 0.0); //You? No. Me? Naturally.
                avallach.add(561084, 0.0); //With a touch of help from the sorceresses.
                avallach.add(1000359, 0.0); //Nor yours.
                avallach.add(1000362, 0.0); //I shan't force her to do anything, if that's your question.
                avallach.add(1000351, 0.0); //We are the same… simply because we both firmly believe others are inferior.
                avallach.add(1000287, 0.0); //Know him? I reared him.
                avallach.add(1000291, 0.0); //No, Geralt. I began shaping him long before he was born.
                avallach.add(538002, 0.0); //I didn't mention many things. Fortunately, they're no longer important.
                avallach.add(538372, 0.0); //Did you, now?
                avallach.add(538376, 0.0); //Not at all.
                avallach.add(566019, 0.0); //You don't really expect me to confess my feelings to you, do you?
                avallach.add(538353, 0.0); //I know. You'd never let me within five hundred yards of Ciri otherwise.
                avallach.add(565964, 0.0); //It's not the only artifact to possess this power.
                avallach.add(559385, 0.0); //It's simple… which does not mean it will be easy to execute.
                avallach.add(559514, 0.0); //Time is short. If you wish to do something, brew your substances or whatnot… Do it now.
                avallach.add(539031, 0.0); //He was a devoted follower of our former king…
                avallach.add(565554, 0.0); //But I'm even better at uncovering them.
                avallach.add(565596, 0.0); //We do. In the land of the Aen Elle.
                avallach.add(565609, 0.0); //You don't recall? After all, you did travel with Eredin for some time.
                avallach.add(565614, 0.0); //The land of the Alder Folk. The world where we arrived centuries ago, a world that is now our home.
                avallach.add(1009380, 0.0); //No reason to tarry, come.
                avallach.add(1041857, 0.0); //I'm glad to know you appreciate it. Elven architecture is a bit more sophisticated than yours.
                avallach.add(312082, 0.0); //You shall see the truth. You will dream it.
                avallach.add(559177, 0.0); //We were discussing questions of a magic nature. Nothing of great interest to you.
                avallach.add(560273, 0.0); //Amusing. Zireael said the same thing, only at much higher volume.
                avallach.add(560400, 0.0); //Where are you going?
                avallach.add(559518, 0.0); //Never mind.
                avallach.add(559814, 0.0); //Fine. But don't dawdle excessively.
                avallach.add(549839, 0.0); //Nearby. Listen…



                baron = createOnelinerElement('baron');
                baron.add(408788, 0.0); //Good enough.
                baron.add(474868, 0.0); //You've learned something?
                baron.add(1058424, 0.0); //Well, what're you waitin' for?
                baron.add(1071733, 0.0); //What was that?
                baron.add(476788, 0.0); //Heheh. Right you are.
                baron.add(477027, 0.0); //Heheh, sharp you are.
                baron.add(1071467, 0.0); //Bloody hell, not now, Geralt! Let's do what we must.
                baron.add(405287, 0.0); //Ohh, you wouldn't know a good tale from a runny fart.
                baron.add(522421, 0.0); //Lass? We must go there at once, Geralt!
                baron.add(519626, 0.0); //Hah, right. More likely some mad old wenches making mincemeat of peasant minds.
                baron.add(487095, 0.0); //You have everythin'?
                baron.add(475212, 0.0); //In Vizima - now those were balls!
                baron.add(476956, 0.0); //Exactly.
                baron.add(356027, 0.0); //Ahhh, a topic for another time.
                baron.add(383919, 0.0); //You have my word.
                baron.add(471770, 0.0); //What for?
                baron.add(179796, 0.0); //Any who might've, they've been eating dirt long since.
                baron.add(381170, 0.0); //Try not to make a mess.
                baron.add(177424, 0.0); //Done pokin' around?
                baron.add(471699, 0.0); //Heh! What could possibly be so interesting about a doll, witcher?
                baron.add(475540, 0.0); //Doesn't it? Time's taken a bit of a toll, but overall, it continues to impress.
                baron.add(472312, 0.0); //None.
                baron.add(473944, 0.0); //That's another story.
                baron.add(473960, 0.0); //Yes, I knew.
                baron.add(474225, 0.0); //What?
                baron.add(367691, 0.0); //Into, fucking, what...?
                baron.add(474357, 0.0); //How?
                baron.add(474433, 0.0); //And the other way?
                baron.add(173441, 0.0); //No… Why would we?
                baron.add(367746, 0.0); //What's that mean?
                baron.add(535504, 0.0); //Look!
                baron.add(413992, 0.0); //Oh fuck…
                baron.add(384642, 0.0); //But… but what do you want to do with it?
                baron.add(413994, 0.0); //I'll wait with you.
                baron.add(1003502, 0.0); //I pay no heed to peasant babblin'.
                baron.add(390672, 0.0); //How'd she react?
                baron.add(403762, 0.0); //No, no, that's an entirely different story.
                baron.add(403498, 0.0); //I'm content that you finally see that.
                baron.add(474769, 0.0); //What do you mean?
                baron.add(405327, 0.0); //Aye… Though I feel something's not right with him.
                baron.add(476796, 0.0); //But then I thought - one tough cocker if he bested that lot of cutthroats. Man like him could prove useful…
                baron.add(476830, 0.0); //That's the spirit! We'll work well together - I can see that already.
                baron.add(476832, 0.0); //This way.
                baron.add(476943, 0.0); //Someone loses their way 'round here, he becomes damn hard to find.
                baron.add(474323, 0.0); //What? How?
                baron.add(474351, 0.0); //But how… how does it know?
                baron.add(403175, 0.0); //How on earth did she land there?!
                baron.add(402584, 0.0); //A pact? What the bloody hell?
                baron.add(487105, 0.0); //Meanin'?
                baron.add(1071678, 0.0); //Wolves… perhaps?
                baron.addPreC(531998, 0.0); //Bring it on, whoreson! Come here!



                cerys = createOnelinerElement('becca');
                cerys.add(501119, 0.0); //What's that?
                cerys.add(495357, 0.0); //Nothin', not a thing… Just got the impression she doesn't like to let you out of her sight.
                cerys.add(487950, 0.0); //Look, there they are.
                cerys.add(488316, 0.0); //Well? Know what it is?
                cerys.add(488399, 0.0); //Sounds unpleasant. Any way to defeat it?
                cerys.add(502100, 0.0); //And it's sure to give as good as it gets.
                cerys.add(488454, 0.0); //What's this other way?
                cerys.add(502154, 0.0); //Great! Let's try it!
                cerys.add(502140, 0.0); //Well maybe no one's thought up a trick that was good enough.
                cerys.add(493883, 0.0); //What d'you mean?
                cerys.add(495305, 0.0); //What?
                cerys.add(495299, 0.0); //Hmm… And what about the other method?
                cerys.add(495398, 0.0); //Just please don't tell me you have to consult Yennefer on such things as well.
                cerys.add(495408, 0.0); //If we fail to think of anythin', we can always try the witchers' way.
                cerys.add(495387, 0.0); //Nothin'. I've just noticed that… you're often of one mind.
                cerys.add(495391, 0.0); //Not that you're especially different… Seems to happen to all men…
                cerys.add(495432, 0.0); //Take a rowdy Skelliger, a brave knight or a tough witcher - you all end up wrapped around some woman's finger.
                cerys.add(495472, 0.0); //As long as my name's not Yennefer, no one would call you hen-pecked for that.
                cerys.add(495481, 0.0); //And remember, if we can't think of a good trick, we can still do it your way.
                cerys.add(495449, 0.0); //Good decision.
                cerys.add(375497, 0.0); //Let's look around.
                cerys.add(488722, 0.0); //Yes, I've a plan - one that just might work.
                cerys.add(485925, 0.0); //So do I…
                cerys.add(567552, 0.0); //Ever see anythin' like that?
                cerys.add(588247, 0.0); //The stuff of fairy tales, legends… But it seems to make sense, right?
                cerys.add(585921, 0.0); //But he's done with that now, right?
                cerys.add(588320, 0.0); //C'mon. We could find some clues there.
                cerys.add(569128, 0.0); //Knew there'd be trouble. It was all too calm.
                cerys.add(1070362, 0.0); //Might say he got his wish.
                cerys.add(569130, 0.0); //I really hope Hjalmar's doin' somethin' useful, not just lookin' for a fight.
                cerys.add(560891, 0.0); //Let's get to work. Search every nook, turn things upside down if need be.
                cerys.add(500712, 0.0); //I'm ready.
                cerys.add(588399, 0.0); //Argh, bygone days.
                cerys.add(1070375, 0.0); //No… It can't be!
                cerys.add(586925, 0.0); //Perhaps you're right.
                cerys.add(586929, 0.0); //I don't know. That doesn't mean I'm givin' up. I'd never do that.
                cerys.add(1070525, 0.0); //It's too soon to pass judgment. It could be a ruse, a plot to deceive us… You find anythin'?
                cerys.add(1070501, 0.0); //So? Find anythin'?
                cerys.add(1073277, 0.0); //Must say I envy you that.
                cerys.add(1060266, 0.0); //Have you found her?!
                cerys.add(1070535, 0.0); //It was her after all…
                cerys.add(585159, 0.0); //Our rivalry's one thing, but we share the same blood - that's what really counts.
                cerys.add(585168, 0.0); //I will.
                cerys.add(587843, 0.0); //He didn't expect to be pursued… Might not've managed to take everything.
                cerys.add(1073273, 0.0); //Think that important?
                cerys.add(1072808, 0.0); //We should take everythin' anyway. Never know what could be important.
                cerys.add(1065839, 0.0); //I'd 'ave made no such thing if you'd only trusted me.
                cerys.add(502317, 0.0); //I'm sure Yennefer must be growin' impatient…



                damien = createOnelinerElement('damien');
                damien.add(1168447, 0.0); //You know this how?
                damien.add(1168451, 0.0); //Do you mean to insinuate the investigation thus far has been sloppy?
                damien.add(1168543, 0.0); //So it seems.
                damien.add(1179345, 0.0); //Yet all are still brainless beasts.
                damien.add(1179595, 0.0); //Monsters driven by reason… A curious contention. What, then, do you intend to do?
                damien.add(1181609, 0.0); //Impossible. If so great is their power, why have they not killed or enslaved us all?
                damien.add(1181611, 0.0); //And they do not fear we shall wipe them out one day?
                damien.add(1181615, 0.0); //Then what can we do? Do you have a plan?
                damien.add(1157820, 0.0); //This vampire… have you ever faced its sort before?
                damien.add(1185775, 0.0); //True, you are not the most endearing of men.
                damien.add(1200318, 0.0); //Your plan puts you at great risk… but I sense you will handle it well. Let us go.
                damien.add(1151449, 0.0); //My duty lies with the city.
                damien.add(1176630, 0.0); //Hm. And what would that be?
                damien.add(1176634, 0.0); //How?
                damien.add(1180726, 0.0); //You've that luxury. I do not. I've sworn my loyalty to Her Grace.
                damien.add(1180765, 0.0); //Wait.
                damien.add(1151547, 0.0); //I've served in the Ducal Palace for years. I know its every corner. So yes, I am damn sure.
                damien.add(1184094, 0.0); //I apply a balm of arnica. I hardly feel it anymore.
                damien.add(1171453, 0.0); //You are certain of this?
                damien.add(1185793, 0.0); //At any rate, I see the effort you put forth. And I appreciate it.
                damien.add(1199280, 0.0); //You read my mind, witcher. I shall gather my men, surround the establishment. Not a mouse will squeeze through.
                damien.add(1151551, 0.0); //Honestly? I've no clue. Look, I've told you what I saw. What you do with it is no concern of mine.



                dandelion = createOnelinerElement('dandelion');
                dandelion.add(1177778, 0.0); //Sheesh, Geralt, you look like you've seen a ghost.
                dandelion.add(1046241, 0.0); //In negotiation, as in combat, the key is to find your opponent's weak spot and exploit it to the hilt.
                dandelion.add(1046013, 0.0); //I never mix business and pleasure.
                dandelion.add(1046900, 0.0); //You're pulling my leg.
                dandelion.add(565050, 0.0); //You have a great deal to learn… Glad to give you some advice if you want.
                dandelion.add(1024161, 0.0); //Knew I bought that wine for a reason…
                dandelion.add(1001599, 0.0); //Geralt, the only "buts" in this plan'll be the ones filling my seats! It'll work, you'll see!
                dandelion.add(1044770, 0.0); //Ah! Finally made it!
                dandelion.add(1025174, 0.0); //Knew you'd see the sense in it right away.
                dandelion.add(1044773, 0.0); //I never called it brilliant, but any kind of plan is better than none.
                dandelion.add(1045991, 0.0); //Did you not hear what's going on in there? We've gotta help Polly. Why do beautiful women always end up with such dicks?
                dandelion.add(1046230, 0.0); //Phew, never expected that to go so well.
                dandelion.add(1046323, 0.0); //Really? You'd go?
                dandelion.add(1046964, 0.0); //Are you crazy? Who do you think I am?
                dandelion.add(1001162, 0.0); //Now, what's eating you?
                dandelion.add(1001723, 0.0); //Ah, yes… Now I remember.
		dandelion.add(1046892, 0.0); //Very funny, Geralt. Shove it.
                dandelion.add(586835, 0.0); //What is that about?
		dandelion.add(1047698, 0.0); //I'll catch up to you.
                dandelion.add(1003515, 0.0); //So it's true - a woman's vanity knows no bounds.
                dandelion.add(462543, 0.0); //Argh, you and Ciri - like two water droplets. Never know what either of you are talking about.
		dandelion.add(564952, 0.0); //A shame, really, because it looks like you had a roaring good time.
                dandelion.add(564985, 0.0); //So, how do you feel? A bit numb, I bet.
		dandelion.add(565048, 0.0); //Oh, Geralt, how little you know about women… Did you really think you could have them both?
                dandelion.add(586809, 0.0); //Gave me enough material for a volume of ballads! And this one'll sell like hotcakes!
		dandelion.add(586856, 0.0); //Sheesh, what crawled into your britches and bit you?
                dandelion.add(587580, 0.0); //Didn't say much at all, to be honest.
		dandelion.add(487181, 0.0); //Weeell, I've certainly had my share of excitement for one day. A juicy roast and a soft bed with fluffy pillows - I think that's the least I'm owed…
                dandelion.add(489393, 0.0); //Got a bad feeling about this…
                dandelion.add(490232, 0.0); //I know, I know. But my gut can't be reasoned with, and no amount of sympathy I feel can silence it, blot it out.
                dandelion.add(1044384, 0.0); //Save it.
                dandelion.add(1044474, 0.0); //But a favor - that's different.
                dandelion.add(356424, 0.0); //Well… honestly never expected my art could move the hardened heart of a witcher.
                dandelion.add(1002526, 0.0); //I don't remember.
                dandelion.add(1046926, 0.0); //I've always been monogamous. Well, near enough. I just changed muses often.
                dandelion.add(1192304, 0.0); //Good. So Geralt, important to remember - if anyone asks, I'm not here.
                dandelion.add(1192312, 0.0); //I've heard some rumors, but I'd love a first-hand account. Does it have the makings of a ballad?
                dandelion.add(1208456, 0.0); //Recently, we discovered Novigrad's largest wine importer was a lying cheat.
                dandelion.add(1196068, 0.0); //Come on! It took me five bottles to start seeing double.
                dandelion.add(1194024, 0.0); //But I want to hear your side, first-hand. And I'll be honest - intend to use every last bit in a new ballad.
                dandelion.add(1194761, 0.0); //Everything's fine, great. Thanks to you, I'm with a woman I'm entirely devoted to, surrendered my heart to.
                dandelion.add(1194765, 0.0); //If you hadn't been there, Priscilla would've died a cruel death. And right about now I'd be drowning my sorrows in some dive with piss-stained walls.
                dandelion.add(1194773, 0.0); //All right, but… your loss.
                dandelion.add(1177787, 0.0); //Didn't stop me from risking my skin for you. In my book, friendship is all that matters. Well, friendship and love. And art. Oh, and wine…
                dandelion.add(1177970, 0.0); //Of course we are! How could you even think it was otherwise?
                dandelion.add(1184625, 0.0); //Consider it done…
                dandelion.add(1179734, 0.0); //Really? Maybe you should read it, then. It could be important…
                dandelion.add(1150364, 0.0); //But just so you know, it wasn't easy. In fact, it was pretty damn hard.
                dandelion.add(1044478, 0.0); //But… I have another idea.
                dandelion.add(1075546, 0.0); //Thanks for helping back then, Geralt. Meant a lot. Really.
                dandelion.add(1075552, 0.0); //Don't worry, I will. Give her a kiss, even - a bit from you, mostly from me!
                dandelion.add(571971, 0.0); //Glad to have some rabbit stew. But freezing my ass off to amass the ingredients? Did not sign up for that.
                dandelion.add(571973, 0.0); //I'll gather the herbs, spices. No stew is complete without some sun-drenched thyme and the aroma of rosemary…
                dandelion.add(531723, 0.0); //In fact, you look terrible! Like you could really use some rest!
                dandelion.add(490273, 0.0); //I'm just saying…
                dandelion.add(586882, 0.0); //Time will tell.
                dandelion.add(587430, 0.0); //Oo, guess you're no stranger to fury, either.
                dandelion.add(587367, 0.0); //She wasn't all that willing to talk about it. I didn't want to pry.
                dandelion.add(1045082, 0.0); //Find anything?
                dandelion.add(1036776, 0.0); //I beg to differ. Many a man's started out wanting to kill me, and ended up buying me a round.
                dandelion.add(1046271, 0.0); //So did I. Merely goes to show just how much we have yet to learn about women…
                dandelion.add(1046297, 0.0); //One swallow does not a summer make.
                dandelion.add(356414, 0.0); //Ugh. Witchers - not an ounce of sensitivity.
                dandelion.add(1046647, 0.0); //Well, I must admit, you have great taste!
                dandelion.add(529673, 0.0); //Didn't inform me. Imagine that.



                dettlaff = createOnelinerElement('dettlaff_van_eretein_vampire');
                dettlaff.add(1154704, 0.0); //Hm, I think not. You see, I've something to do still.
                dettlaff.add(1154634, 0.0); //Hmhmhmhm, is it as simple as that?
                dettlaff.add(1154708, 0.0); //Just one.
                dettlaff.add(1174791, 0.0); //It might want to apologize.
                dettlaff.add(1174796, 0.0); //For killing. Though at times there is no choice. When loved ones are at risk and require protection.
                dettlaff.add(1174806, 0.0); //You understand this… It must be why you and Regis are friends.
                dettlaff.add(1174808, 0.0); //If I understand you correctly, you would rather help a monster than kill it?
                dettlaff.add(1174816, 0.0); //Fond memories?
                dettlaff.add(1202664, 0.0); //They shall pay. For everything.
                dettlaff.add(1192507, 0.0); //Let us go, then.
                dettlaff.add(1183469, 0.0); //Witcher, what is this?
                dettlaff.add(1183556, 0.0); //That… is impossible.
                dettlaff.add(1197140, 0.0); //I shall be waiting.
                dettlaff.add(1165845, 0.0); //Wh… what? What nonsense is this?
                dettlaff.add(1183592, 0.0); //Hhhmm…
                dettlaff.add(1157382, 0.0); //What I had to do. What she deserved.
                dettlaff.add(1157399, 0.0); //No chance. I prefer to attack.
                dettlaff.add(1157401, 0.0); //I shall keep my distance. Believe me.
                dettlaff.add(1157310, 0.0); //Why?
                dettlaff.add(1157318, 0.0); //Brief and to the point… how refreshing.
                dettlaff.add(1157333, 0.0); //You understand nothing.
                dettlaff.add(1174802, 0.0); //These other solutions often come too late.
                dettlaff.add(1157369, 0.0); //Mhh.A shame.
                dettlaff.add(1157336, 0.0); //Let us be done with this.



                geraltAvallachConvo = createConversationElement();
		geraltAvallachConvo.r('avallach'); //Required Actors
		geraltAvallachConvo.append('PLAYER', 558387, 1.6); //Let's get these bastards.
		geraltAvallachConvo.append('avallach', 558388, 0.0); //With pleasure, Geralt. With pleasure.

                geraltAvallachConvo = createConversationElement();
		geraltAvallachConvo.r('avallach'); //Required Actors
		geraltAvallachConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.

                geraltBaronConvo = createConversationElement();
		geraltBaronConvo.r('baron'); //Required Actors
		geraltBaronConvo.append('PLAYER', 520912, 1.7); //In the mood for a round of gwent?
		geraltBaronConvo.append('baron', 520913, 0.0); //Haha! I'm always in the mood for gwent.

                geraltBaronConvo = createConversationElement();
		geraltBaronConvo.r('baron'); //Required Actors
		geraltBaronConvo.append('PLAYER', 515407, 1.2); //Gotta prepare.
		geraltBaronConvo.append('baron', 515428, 0.0); //Prepare, now? Will you shine your boots or trim your nails?

                geraltBaronConvo = createConversationElement();
		geraltBaronConvo.r('baron'); //Required Actors
		geraltBaronConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.

                geraltCerysConvo = createConversationElement();
		geraltCerysConvo.r('becca'); //Required Actors
		geraltCerysConvo.append('becca', 1064461, 3.2); //What is it about her? What is it that draws you?
		geraltCerysConvo.append('PLAYER', 1064463, 0.0); //Dunno… Maybe, uh, it's 'cause I've never chosen comfort and ease, the calm and the quiet…?

                geraltCerysConvo = createConversationElement();
		geraltCerysConvo.r('becca'); //Required Actors
		geraltCerysConvo.append('PLAYER', 584211, 2.1); //Shh. Hear that?
		geraltCerysConvo.append('becca', 560526, 0.0); //No, but I've no witcher senses at my disposal. You must hear the hair growin' on my head.

		geraltCerysConvo = createConversationElement();
		geraltCerysConvo.r('becca'); //Required Actors
		geraltCerysConvo.append('PLAYER', 1002747, 0.0); //Stay calm.

		geraltCerysConvo = createConversationElement();
		geraltCerysConvo.r('becca'); //Required Actors
		geraltCerysConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.

                geraltDamienConvo = createConversationElement();
		geraltDamienConvo.r('damien'); //Required Actors
		geraltDamienConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.

                geraltDandelionConvo = createConversationElement();
		geraltDandelionConvo.r('dandelion'); //Required Actors
		geraltDandelionConvo.append('PLAYER', 564856, 1.7); //Save it. I'm not in the mood...
		geraltDandelionConvo.append('dandelion', 564858, 3.2); //Well, I sure am. What'd you play?
		geraltDandelionConvo.append('dandelion', 564859, 4.1); //"Tame the fiend?" Or was it "Free the prince?"
		geraltDandelionConvo.append('PLAYER', 564923, 1.0); //Dandelionnnn…
		geraltDandelionConvo.append('dandelion', 564954, 0.0); //All right, all right. Sorry, don't often see you like this, couldn't resist…

                geraltDandelionConvo = createConversationElement();
		geraltDandelionConvo.r('dandelion'); //Required Actors
		geraltDandelionConvo.append('dandelion', 1044390, 11.4); //Just one hitch - I need coin. So… if you happen to get a break between drowners and ekimmu-jigs, maybe you could help an old friend out?
		geraltDandelionConvo.append('PLAYER', 1046817, 1.2); //Why not.
		geraltDandelionConvo.append('dandelion', 1046820, 0.0); //That's my boy.

                geraltDandelionConvo = createConversationElement();
		geraltDandelionConvo.r('dandelion'); //Required Actors
		geraltDandelionConvo.append('PLAYER', 565001, 3.6); //Got what I deserved… Should've known it was too good to be true…
		geraltDandelionConvo.append('dandelion', 565044, 0.0); //You certainly should have.

                geraltDandelionConvo = createConversationElement();
		geraltDandelionConvo.r('dandelion'); //Required Actors
		geraltDandelionConvo.append('dandelion', 1075546, 5.4); //Thanks for helping back then, Geralt. Meant a lot. Really.
		geraltDandelionConvo.append('PLAYER', 1075548, 0.0); //What're friends for…?

                geraltDandelionConvo = createConversationElement();
		geraltDandelionConvo.r('dandelion'); //Required Actors
		geraltDandelionConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.

                geraltDettlaffConvo = createConversationElement();
		geraltDettlaffConvo.r('dettlaff_van_eretein_vampire'); //Required Actors
		geraltDettlaffConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.
	}

	private function initNPCChats_4()
	{
		var dijkstra, ermion, eskel, ewald, guillaume, hjalmar : mod_scm_SpecialNPCOnelinersDefinition;
		var eskelLambertConvo, geraltDijkstraConvo, geraltErmionConvo, geraltEskelConvo, geraltEwaldConvo, geraltGuillaumeConvo, geraltHjalmarConvo : mod_scm_SpecialNPCConversationDefinition;

                dijkstra = createOnelinerElement('dijkstra');
                dijkstra.add(1073770, 0.0); //Later, Geralt.
                dijkstra.add(379139, 0.0); //Oh, that famous sarcasm… I'd missed it.
                dijkstra.add(376782, 0.0); //Got something?
                dijkstra.add(379247, 0.0); //Witchers know their monsters, spies know their men.
                dijkstra.add(487802, 0.0); //Geralt, would you be kind enough to tell me what you've learned? I'm terribly curious.
                dijkstra.add(376702, 0.0); //Sugar?! Geralt, I'm in no mood for jests.
                dijkstra.add(1064396, 0.0); //Ah, those witcher senses. Can't hide a damn thing from you lot.
                dijkstra.add(581884, 0.0); //Well mate, at least you tried.
		dijkstra.add(486613, 0.0); //I'm all ears.
                dijkstra.add(1070509, 0.0); //We're counting in you, Geralt.
                dijkstra.add(1073774, 0.0); //I'm not nervous - just cautious. A trait you ought to nurture as well.
                dijkstra.add(1011680, 0.0); //Ah, yes, sure.
                dijkstra.add(480235, 0.0); //Oh-hoo! That's quite the start, Geralt. What's it you want?
                dijkstra.add(486096, 0.0); //An ambush? What's this about?
                dijkstra.add(486134, 0.0); //Then it's settled.
                dijkstra.add(1067431, 0.0); //Provided, of course, you're not mistaken…
                dijkstra.add(1067578, 0.0); //Especially in light of our bloody aborted plan.
                dijkstra.add(1067464, 0.0); //Situation's changed, witcher. She's in a position now to foil my plans.
                dijkstra.add(579439, 0.0); //No. I was born ugly.
                dijkstra.add(586731, 0.0); //We'll talk later.
                dijkstra.add(580294, 0.0); //I adore love stories. Especially the ones that end happily ever after.
                dijkstra.add(379525, 0.0); //Strange… I had no idea he was in debt.
                dijkstra.add(432648, 0.0); //Take it you learned this by peering into a crystal ball?
                dijkstra.add(433027, 0.0); //Darling, when I'm able to make use of someone, I always do. It's convenient.
                dijkstra.add(461087, 0.0); //You can also count on my help.
                dijkstra.add(504990, 0.0); //Just a few.
                dijkstra.add(489248, 0.0); //Let's give him a chance to explain.
                dijkstra.add(550589, 0.0); //Sure, sure - then we'll talk. In private.
                dijkstra.add(383527, 0.0); //Just good.
                dijkstra.add(486480, 0.0); //Course I do.
                dijkstra.add(486541, 0.0); //Problems you might be able to help me with.
                dijkstra.add(420604, 0.0); //You are the worst liar I've ever known… Glad I don't need you to win a poker game for me.
                dijkstra.add(417640, 0.0); //See me smiling? I'm dead serious.
                dijkstra.add(363388, 0.0); //You're not exactly bursting with enthusiasm.
                dijkstra.add(378559, 0.0); //Lots of prior experience - worked with idiots my whole life.
                dijkstra.add(378939, 0.0); //Well? Learn anything?
                dijkstra.add(383238, 0.0); //Because?
                dijkstra.add(380201, 0.0); //How badly?
                dijkstra.add(496511, 0.0); //Well, well… Would've earned yourself a medal if I was in a position to bestow them.
                dijkstra.add(1065831, 0.0); //I draw it all from the flight patterns of birds.
                dijkstra.add(1065835, 0.0); //I've far worse qualities than that. Believe me.
                dijkstra.add(1067766, 0.0); //My lads'll make sure of that.
                dijkstra.add(1064930, 0.0); //It's why I'll make an excellent chancellor.
                dijkstra.add(1013639, 0.0); //I do. Gwent's like politics, just more honest.
                dijkstra.add(1064418, 0.0); //Oh, bollocks. That's a convenient excuse you lot try to hide behind every time the temperature rises.
                dijkstra.add(581854, 0.0); //If I say it's because I like you, want what's best for you, would you believe me?
                dijkstra.add(581858, 0.0); //Wise.
                dijkstra.add(1064350, 0.0); //Spare me, Geralt. Witchers're stripped of feeling, not one emotion in that body of yours. And I've an urgent matter to discuss.
                dijkstra.add(582121, 0.0); //No. She said she preferred women. So, I drank myself stupid and went out whorin'.
                dijkstra.add(489183, 0.0); //Good thing Happen's not here. He'd tan the hide on my arse for being so rude.
                dijkstra.add(515531, 0.0); //Hm. It would certainly explain how he had the nerve to break with the Big Four.
                dijkstra.add(515543, 0.0); //I don't… But you do.
                dijkstra.add(486543, 0.0); //Yeah… Might be able to help me, in fact.
                dijkstra.add(425019, 0.0); //I could never reveal my sources, to you or anyone else. It would be fucking unprofessional.
                dijkstra.add(426144, 0.0); //Huh? What's this?
                dijkstra.add(426154, 0.0); //Hmmm… Nah, worthless.
                dijkstra.add(379243, 0.0); //Happen has numerous flaws. He's pompous, pretentious, can be a real prick sometimes, ironic as that may sound… But his loyalty's beyond question.
                dijkstra.add(487999, 0.0); //Perhaps… I'd still prefer the whore, though.
                dijkstra.add(425313, 0.0); //Heard of beasts that are half-lion, half-eagle, maidens who're half-fish… But you'll never convince me there's such a thing as a half-truth.
                dijkstra.add(1002893, 0.0); //He's not been seen around town in some time.
                dijkstra.add(1000629, 0.0); //Oh yes, those famous witcher senses - finally getting some use out of them.
                dijkstra.add(579444, 0.0); //No, but I am helpin' the others set off. You know me… bleedin' heart and all.
                dijkstra.add(579432, 0.0); //I look forward to having friends in Kovir. Especially among King Tancred's entourage.
                dijkstra.add(581784, 0.0); //You're an arse.
                dijkstra.add(556913, 0.0); //Not a chance.
                dijkstra.add(1065922, 0.0); //Actually, yes. But not because I'm sensitive or it gives me a heartache, true.
                dijkstra.add(1067671, 0.0); //We can use Philippa without involving her, provided you help.
                dijkstra.add(1067770, 0.0); //If they're paid a tidy sum, they won't.



                ermion = createOnelinerElement('mousesack');
                ermion.add(479845, 0.0); //Only ignorant fools belittle their significance.
                ermion.add(479964, 0.0); //Wha… what was that?
                ermion.add(479841, 0.0); //Its appearance is exactly as described in the myths.
                ermion.add(480013, 0.0); //She has always been hot-headed.
                ermion.add(482243, 0.0); //So?
                ermion.add(482249, 0.0); //Hmm… Plausible, considering what happened to the wood.
                ermion.add(482389, 0.0); //Do you know upon whom?
                ermion.add(482260, 0.0); //Where to?
                ermion.add(482258, 0.0); //Yes? Is that it?
                ermion.add(348153, 0.0); //What?!
                ermion.add(482504, 0.0); //But could that truly be so important?
                ermion.add(482449, 0.0); //Huh?
                ermion.add(482438, 0.0); //Itself a strange occurrence for that time of year.
                ermion.add(522824, 0.0); //Our opponent is dangerous, and we know little about him.
                ermion.add(520454, 0.0); //Do you know we stand on a vast deposit of gas?
                ermion.add(545962, 0.0); //If need be, I could open cracks in the earth, create explosions. I would need to prepare, though.
                ermion.add(564562, 0.0); //Bah! 'Course it is! I am a hierophant, aren't I?
                ermion.add(559241, 0.0); //So they call him. Submerges for hours at a time.
                ermion.add(559243, 0.0); //None know how he does it. But I've my suspicions.
                ermion.add(559247, 0.0); //It's nothing personal. I couldn't stand his father or grandfather either.
                ermion.add(559257, 0.0); //Ugh! Gods protect us.
                ermion.add(572957, 0.0); //I regret I did not know him better.
                ermion.add(559826, 0.0); //Come, we should not stay here.
                ermion.add(559275, 0.0); //So, Clan Drummond will attack sooner then we expected, it seems.
                ermion.add(559233, 0.0); //Today? In Arinbjorn, doubtless.
                ermion.add(1002471, 0.0); //Aye, but I've not minded. Since time immemorial the druids have wandered betwixt the clans, keeping endless feuds in check.
                ermion.add(1002473, 0.0); //We care for equilibrium, the balance of all things, not just trout populations in streams. We're lucky the jarls always valued us as advisors.
                ermion.add(479785, 0.0); //Sailors from clan Dimun pulled it from the sea. Near the Njord Trench.
                ermion.add(479809, 0.0); //Of course I do. The myths tell me.
                ermion.add(482447, 0.0); //But… why?
                ermion.add(1002410, 0.0); //An Craite blood is good blood.
                ermion.add(465239, 0.0); //I could use a drink.
                ermion.add(321495, 0.0); //You know this hardly ends your struggle?
                ermion.add(566059, 0.0); //I can help you if you wish.



                eskel = createOnelinerElement('eskel');
                eskel.add(514020, 0.0); //I'm a simple witcher, Wolf. Don't fight dragons, don't fraternize with kings and don't sleep with sorceresses… Unlike some.
                eskel.add(514024, 0.0); //Shh! Hear that? Incoming!
                eskel.add(528108, 0.0); //Mock me all you want. You're just jealous.
                eskel.add(1047952, 0.0); //Heh, long story. Tell you another time.
                eskel.add(520697, 0.0); //You hardly need to. See, till now we had a great excuse not to take in apprentices. Seems we'll need to talk it over.
                eskel.add(447045, 0.0); //Yeah, Kovir's where the gold's to be made. Know how much they pay there for a drowner?
                eskel.add(465216, 0.0); //Think it over.
		eskel.add(514008, 0.0); //Same ol', same ol'. Another day, another drowner.
		eskel.add(518442, 0.0); //You're right. Takes a lotta champagne to wash down all that caviar. That is tough goin'.
		eskel.add(528454, 0.0); //Speak for yourself, funny bunny…
		eskel.add(519565, 0.0); //Done deal.
		eskel.add(519980, 0.0); //Suppose so. But you look the way I do, you gotta grab every chance you can get.
		eskel.add(1028458, 0.0); //Mh. A month of tracking, stalking, but I finally dropped the son of a bitch.
		eskel.add(1047877, 0.0); //Hm, not a bad idea. Gotta finish the autopsy first, though.
		eskel.add(1047902, 0.0); //Wanna do the honors?
		eskel.add(1047948, 0.0); //Lemme tell you, this sucker was fast. One second here, there the next, always in the shadows. Could barely see it.
		eskel.add(524163, 0.0); //Nothing I can do - been outvoted. Let's go.
		eskel.add(447077, 0.0); //Finicky, too. Specimen in question only went for young women from the upper classes.
		eskel.add(519974, 0.0); //My client threw a masquerade ball for the city's notables - to lure the vampire out of hiding. I was there, too, disguised. Lemme tell you, never had so much success with the ladies as I did that night.
		eskel.add(519963, 0.0); //Let's raise a mug to his memory - the least we can do.
		eskel.add(447194, 0.0); //He get caught ploughing somebody he shouldn't 'ave been?
		eskel.add(520628, 0.0); //Uh, sorry… looking to turn him into a witcher?
		eskel.add(520708, 0.0); //Might be surprised. Old man knows his stuff.
		eskel.add(528042, 0.0); //Bah… Scorpion's a war horse, a purebred Kaedweni. He'll be fine. Have I told you how I got him?
		eskel.add(446438, 0.0); //Mean you don't know?
		eskel.add(527920, 0.0); //And that, uh… doesn't bug you?
		eskel.add(527950, 0.0); //Oof… There'd be hell to pay.
		eskel.add(1047879, 0.0); //This one was quicker than most. Quicker and stronger. Wanna examine it thoroughly.
		eskel.add(535320, 0.0); //Ugh. I can't believe we're doing this.
		eskel.add(1060170, 0.0); //Geralt… Maybe you oughta…?
		eskel.add(1062876, 0.0); //I could prepare more of those witchers' traps. But I'd need all the lab equipment.
		eskel.add(566113, 0.0); //Our opinions count, too.
		eskel.add(1062956, 0.0); //Need some peace. Gotta prepare.
		eskel.add(1049082, 0.0); //Want to give it to Yennefer? Oughta be as good as new once you polish it a bit.
		eskel.add(519507, 0.0); //Hm… Had this craving for Mahakaman spirit a while now. Nothin' burns quite like it.
		eskel.add(527137, 0.0); //De ole hen she cackled, she cackled on de fence… de ole hen she cackled, an she ain't cackled sence.
		eskel.add(519554, 0.0); //Hold you to that.
		eskel.add(566126, 0.0); //Geralt, this is a problem. Don't dismiss it.
		eskel.add(518446, 0.0); //No doubt the most pleasant part… though I'm not sure it ain't the most dangerous, too.
		eskel.add(518432, 0.0); //Geralt, please… Cut the crap.
		eskel.add(518436, 0.0); //You're right… But most like a full purse, too. Don't have much to brag about in that domain either.
		eskel.add(527936, 0.0); //And they say people learn from their mistakes…
		eskel.add(527932, 0.0); //Right. Fine, never mind… Let's go.
		eskel.add(527946, 0.0); //We could've gone to Triss for help.
		eskel.add(533874, 0.0); //Debatable… Let's go.
		eskel.add(519503, 0.0); //Yeah. Sure.
		eskel.add(538406, 0.0); //Don't doubt that. But do we know what she's doing? She tell you how likely this is to work?
		eskel.add(538417, 0.0); //Understood. I'd prefer that, too.



                ewald = createOnelinerElement('ewald');
                ewald.add(1097402, 0.0); //Seems true what they say - "Sword or no sword, a witcher brings gore."
                ewald.add(1123970, 0.0); //Got any others?
                ewald.add(1097583, 0.0); //I've a plan.
                ewald.add(1096689, 0.0); //What's that matter?
                ewald.add(1101208, 0.0); //Something that was stolen from me.
                ewald.add(1101212, 0.0); //I've tried. Repeatedly.
                ewald.add(1123975, 0.0); //It's opportunity makes the thief, witcher. I speak from experience.
                ewald.add(1097638, 0.0); //But, not a fortress out there without a weakness. This one's no different.
                ewald.add(1097060, 0.0); //Let's start with the fact that one of 'em's a dwarf.
                ewald.add(1099472, 0.0); //Anything else?
                ewald.add(1098609, 0.0); //I'll tend to that.
                ewald.add(1115374, 0.0); //On our way, then.
                ewald.add(1099543, 0.0); //Seems my informer was wrong.
                ewald.add(1099541, 0.0); //At your service, mate.
                ewald.add(1124041, 0.0); //What now?
                ewald.add(1098919, 0.0); //On the contrary. I know all too well.
                ewald.add(1100704, 0.0); //As you wish. This way.
                ewald.add(1100573, 0.0); //Was I that bad?
                ewald.add(1100837, 0.0); //You ever have a basilisk hide or fiend horns and want a good price? Look for me at the auction house!
                ewald.add(1114325, 0.0); //Is that so?
                ewald.add(1107160, 0.0); //A right shite idea.
                ewald.add(1098771, 0.0); //Perhaps not.
                ewald.add(1099627, 0.0); //Are you mad? Any idea what'll happen?
                ewald.add(1100222, 0.0); //Ugh. Good work.
                ewald.add(1097066, 0.0); //I know it's in the vault.
                ewald.add(1097670, 0.0); //I'm fully aware of that.
                ewald.add(1124035, 0.0); //Hallowed words.
                ewald.add(1100320, 0.0); //So? Satisfied? Conscience still clear?



                guillaume = createOnelinerElement('guillaume');
                guillaume.add(1156584, 0.0); //The most beautiful among them.
                guillaume.add(1130820, 0.0); //I fear she has fallen victim to ill magic, and knows no one she could turn to for help.
                guillaume.add(1124183, 0.0); //I see - state matters take priority. Yet come see me forthwith should you have a change of heart.
                guillaume.add(1173308, 0.0); //Sometimes when you speak, I miss the meaning entirely.
                guillaume.add(1132160, 0.0); //Where to now?
                guillaume.add(1194568, 0.0); //Excellent idea.
                guillaume.add(1132283, 0.0); //I expected you to do well, but not that well.
                guillaume.add(1211289, 0.0); //Blast that kind of luck…
                guillaume.add(1210154, 0.0); //Good work!
                guillaume.add(1125455, 0.0); //Are you ready? May we go?
                guillaume.add(1125421, 0.0); //Perhaps you could find a clue within it.
                guillaume.add(1134656, 0.0); //In that case, we've no time to lose. Let us go.
                guillaume.add(1130704, 0.0); //That is not what I ask.
                guillaume.add(1189900, 0.0); //Do you mean to say she might in truth look different than she seems?
                guillaume.add(1189883, 0.0); //A bruxa?! You mean a… a vampiress?!
                guillaume.add(1173417, 0.0); //Ahh… When I first laid eyes on her, I finally understood what all those poems and ballads were trying to say.
                guillaume.add(1127921, 0.0); //Did you learn anything?
                guillaume.add(1187761, 0.0); //As you will.
                guillaume.add(1201930, 0.0); //I… I-I suppose so.
                guillaume.add(1187247, 0.0); //What?! This is not what we agreed!
                guillaume.add(1201038, 0.0); //What condition was this?
                guillaume.add(1200983, 0.0); //What now?
                guillaume.add(1211186, 0.0); //Free at last… as a bird.
                guillaume.add(1181798, 0.0); //My mother's invited us to afternoon tea tomorrow. She would like very much to meet you.
                guillaume.add(1201756, 0.0); //Ahhh…. Why mention it. It's such a minor a problem.



                hjalmar = createOnelinerElement('hjalmar');
                hjalmar.add(586823, 0.0); //Exactly!
                hjalmar.add(523316, 0.0); //Wait!
                hjalmar.add(523470, 0.0); //Our bards sing ballads about you. And my father told me of your adventures when I was a lad.
                hjalmar.add(523472, 0.0); //I remember it well - you needn't be a witcher to be a hero. Cold water and a salty breeze - those are a Skellige lad's potions!
                hjalmar.add(523454, 0.0); //Comin' with me?
                hjalmar.add(523458, 0.0); //Join us, Geralt.
                hjalmar.add(515486, 0.0); //I'm tellin' you, ploughin' enormous whoreson he is!
                hjalmar.add(515475, 0.0); //Can't believe I finally got the bastard.
                hjalmar.add(584630, 0.0); //Ehh, these wild men, live in the hills.
                hjalmar.add(583672, 0.0); //Don't sell your fish till they're in the boat, Wolf.
                hjalmar.add(329666, 0.0); //Hah! Can't wait to test a witcher's blade in battle!
                hjalmar.add(587010, 0.0); //We've no time for that. I know where to find the guilty.
                hjalmar.add(587049, 0.0); //Knew you'd not turn down an adventure!
                hjalmar.add(560037, 0.0); //Right, we're here.
                hjalmar.add(584924, 0.0); //They're not part of any clan. They've no wives nor children.
                hjalmar.add(587502, 0.0); //So now they must pay. In blood.
                hjalmar.add(587421, 0.0); //If it is, it's new to me as well.
                hjalmar.add(584978, 0.0); //Sword at the ready, witcher.
                hjalmar.add(418245, 0.0); //For what?
                hjalmar.add(587218, 0.0); //Crikey, you've a sniffer like a hound's.
                hjalmar.add(584164, 0.0); //Some kind of trial?
                hjalmar.add(1070893, 0.0); //Geralt, finish up your ferretin' already.
                hjalmar.add(584215, 0.0); //Ah, finally.
                hjalmar.add(587594, 0.0); //I'm countin' on it. Let's go!
                hjalmar.add(585022, 0.0); //Not afraid to die. Gotta give 'em that.
                hjalmar.add(563222, 0.0); //Who signed it?
                hjalmar.add(587703, 0.0); //You were right…
                hjalmar.add(587705, 0.0); //There's someone else behind it all, all the mayhem.
                hjalmar.add(584458, 0.0); //And I'll be on my guard.
                hjalmar.add(584442, 0.0); //C'mon. We're done here.
                hjalmar.add(1006037, 0.0); //Cerys'll take care of that.
                hjalmar.add(524342, 0.0); //I'd a debt to pay.
                hjalmar.add(524471, 0.0); //If you, or Ciri, or you and Ciri… if yous ever need help, the gates of Kaer Trolde stand open.
                hjalmar.add(572962, 0.0); //Ah, the courage of the man.
                hjalmar.add(583697, 0.0); //With my sis, of clan an Craite. Bravest lass the Isles ever made.
                hjalmar.add(1071123, 0.0); //Ahh, you can't win them all.
                hjalmar.add(584634, 0.0); //Aye. Without the sheep. They live off killin', eat only what they hunt, and they fight like no one else!
                hjalmar.add(1069102, 0.0); //Then they'll die for bein' idiots. Enough jabberin', already. Let's go.
                hjalmar.add(585871, 0.0); //Oy, Geralt, where you goin'?!
                hjalmar.add(587515, 0.0); //Won't be anyone to mourn them.
                hjalmar.add(584970, 0.0); //The gods don't concern me… Their followers do.
                hjalmar.add(587212, 0.0); //Look. Someone walked through it.
                hjalmar.add(585066, 0.0); //I saw them transform. With my own eyes.
                hjalmar.add(517924, 0.0); //And that might've spelled death for us all.
                hjalmar.add(517956, 0.0); //Let's get outta here.
                hjalmar.add(1055074, 0.0); //Hm. Believe you're right.
                hjalmar.add(518154, 0.0); //She's always liked competin' with me.
                hjalmar.add(516637, 0.0); //Very amusing, Geralt of Rivia.



                eskelLambertConvo = createConversationElement();
                eskelLambertConvo.r('eskel').r('lambert'); //Required Actors
		eskelLambertConvo.append('eskel', 524153, 2.0); //Or… we could have a drink.
		eskelLambertConvo.append('lambert', 524159, 1.8); //Sounds a lot better than the beams.
		eskelLambertConvo.append('PLAYER', 524161, 0.0); //Wouldn't mind a shot myself. Or two.

                eskelLambertConvo = createConversationElement();
		eskelLambertConvo.r('eskel').r('lambert'); //Required Actors
		eskelLambertConvo.append('PLAYER', 447071, 2.2); //Where'd you go while you were away, Eskel?
		eskelLambertConvo.append('eskel', 447073, 3.2); //Aldersberg. Hunted a higher vampire.
		eskelLambertConvo.append('lambert', 447075, 0.0); //Oh-ho-ho… Dangerous whoresons, those.

                geraltDijkstraConvo = createConversationElement();
		geraltDijkstraConvo.r('dijkstra'); //Required Actors
		geraltDijkstraConvo.append('dijkstra', 489820, 8.9); //Hahahah! Ah, Geralt… I should have you strangled, but I like you, you bastard.
		geraltDijkstraConvo.append('PLAYER', 489824, 0.0); //I like you too… you count without a county.

                geraltDijkstraConvo = createConversationElement();
		geraltDijkstraConvo.r('dijkstra'); //Required Actors
		geraltDijkstraConvo.append('PLAYER', 1067631, 3.4); //You're nosy. Starting to piss me off, you know?
		geraltDijkstraConvo.append('dijkstra', 1067659, 0.0); //I know. Forgive me, it comes with the job.

                geraltDijkstraConvo = createConversationElement();
		geraltDijkstraConvo.r('dijkstra'); //Required Actors
		geraltDijkstraConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.

                geraltErmionConvo = createConversationElement();
                geraltErmionConvo.r('mousesack'); //Required Actors
		geraltErmionConvo.append('mousesack', 564556, 3.9); //When doubts plague your mind, follow your instincts.
		geraltErmionConvo.append('mousesack', 564558, 6.8); //Should they steer you wrong and land you in muck, you'll land at peace with yourself. And that's most important.
		geraltErmionConvo.append('PLAYER', 564560, 0.0); //Good advice.

                geraltErmionConvo = createConversationElement();
                geraltErmionConvo.r('mousesack'); //Required Actors
		geraltErmionConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.

                geraltEskelConvo = createConversationElement();
		geraltEskelConvo.r('eskel'); //Required Actors
		geraltEskelConvo.append('PLAYER', 459879, 0.7); //Eskel.
		geraltEskelConvo.append('eskel', 1037258, 1.2); //Yes, Wolf?
		geraltEskelConvo.append('PLAYER', 1040320, 3.2); //Got the reward I promised you… Mahakaman spirit.
		geraltEskelConvo.append('eskel', 1040322, 0.0); //Hah! Lambert claimed you'd forget. Thanks, brother.

                geraltEskelConvo = createConversationElement();
		geraltEskelConvo.r('eskel'); //Required Actors
		geraltEskelConvo.append('PLAYER', 459875, 2.4); //Happen on any interesting contracts lately?
		geraltEskelConvo.append('eskel', 459877, 0.0); //Er, not lately. But about half a year back I slew a manticore in Creyden, in a forest. Quick son of a bitch, that one.

                geraltEskelConvo = createConversationElement();
		geraltEskelConvo.r('eskel'); //Required Actors
		geraltEskelConvo.append('eskel', 512159, 4.8); //Ah… Honestly can't see what all those dames see in you. You're a stick in the mud.
		geraltEskelConvo.append('PLAYER', 533872, 0.0); //Pretty damn handsome stick, though.

                geraltEskelConvo = createConversationElement();
                geraltEskelConvo.r('eskel'); //Required Actors
		geraltEskelConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.

                geraltEwaldConvo = createConversationElement();
                geraltEwaldConvo.r('ewald'); //Required Actors
		geraltEwaldConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.

		geraltGuillaumeConvo = createConversationElement();
                geraltGuillaumeConvo.r('guillaume'); //Required Actors
		geraltGuillaumeConvo.append('guillaume', 1157509, 4.8); //Oh, fair Vivienne. Thou hast doves' eyes within thy locks.
		geraltGuillaumeConvo.append('guillaume', 1157511, 2.7); //Thy lips are like a thread of scarlet.
		geraltGuillaumeConvo.append('guillaume', 1157513, 0.0); //Thy two breasts are like… Hm…

		geraltGuillaumeConvo = createConversationElement();
                geraltGuillaumeConvo.r('guillaume'); //Required Actors
		geraltGuillaumeConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.

                geraltHjalmarConvo = createConversationElement();
                geraltHjalmarConvo.r('hjalmar'); //Required Actors
		geraltHjalmarConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.
	}

	private function initNPCChats_5()
	{
		var keira, lambert, letho, olgierd, philippa : mod_scm_SpecialNPCOnelinersDefinition;
		var geraltKeiraConvo, geraltLambertConvo, geraltLethoConvo, geraltOlgierdConvo, geraltPhilippaConvo : mod_scm_SpecialNPCConversationDefinition;

                keira = createOnelinerElement('keira_metz');
                keira.add(410991, 0.0); //Oh really. Who?
                keira.add(445729, 0.0); //Whatever do you mean?
                keira.add(1060740, 0.0); //Geralt, are you all right?
                keira.add(328684, 0.0); //Yes, thanks for asking. How are you feeling? Sleep well?
                keira.add(337666, 0.0); //Oh, please… I merely seized an opportunity.
                keira.add(521575, 0.0); //There's nothing wrong with it.
                keira.add(1062994, 0.0); //Women only ever beautify themselves for their own satisfaction.
                keira.add(573763, 0.0); //There are times when a woman should simply not explain her decision. That goes doubly for sorceresses.
                keira.add(1052272, 0.0); //You'd never have managed without me, would you? Come, now, admit it.
                keira.add(1002506, 0.0); //Come now, who aside from you would know that?
                keira.add(589390, 0.0); //I would rather show you. But you must wait a bit.
                keira.add(1040088, 0.0); //I was wondering how long it would take you, Geralt.
                keira.add(1041472, 0.0); //Are you always like this? I'm beginning to feel sorry for Triss and Yen.
                keira.add(1059473, 0.0); //Geralt, what the hell is that?!
                keira.add(478101, 0.0); //Geralt, there are two types of men: those who see opportunity and take advantage, and those who forge the opportunities themselves.
                keira.add(1034976, 0.0); //Geralt!
                keira.add(521669, 0.0); //Geralt! You gave me quite a start!
                keira.add(1062989, 0.0); //If I'm to die today, I wish to look smashing for the occasion.
                keira.add(413679, 0.0); //Where?
                keira.add(355488, 0.0); //I can assure you I do, now more than ever.
                keira.add(475564, 0.0); //Huh. Horrid.
                keira.add(474793, 0.0); //I do wonder if the two of you will hit it off.
                keira.add(592857, 0.0); //A what?
                keira.add(1041997, 0.0); //Not sure I like any of this.
                keira.add(445638, 0.0); //All right, perhaps I wasn't completely honest, didn't quite toe the line. But I knew you'd manage - you're so manly and all…
                keira.add(1062124, 0.0); //I wonder how long ago that was…
                keira.add(1059486, 0.0); //Do you think it's a mind game of some sort?
                keira.add(1061006, 0.0); //Oof… Anything like that ever happen to you before?
                keira.add(1061010, 0.0); //Yes? And?
                keira.add(1003164, 0.0); //Let's go.
                keira.add(1052187, 0.0); //It's grown awfully quiet.
                keira.add(1053352, 0.0); //A bit like the calm before a storm…
                keira.add(591235, 0.0); //I've a bad feeling about this…
                keira.add(559833, 0.0); //Come on.
                keira.add(567674, 0.0); //I know, I know. We must go on.
                keira.add(1061452, 0.0); //Leave it to me.
                keira.add(1053401, 0.0); //Good thing I came with you.
                keira.add(1061188, 0.0); //Stop telling me what to do!
                keira.add(1040586, 0.0); //Simple, isn't it?
                keira.add(1040630, 0.0); //Splendid. Come, then.
                keira.add(557606, 0.0); //We're certain to find something here.
                keira.add(169895, 0.0); //Wait… Something just happened.
                keira.add(1029195, 0.0); //Ahah!
                keira.add(520984, 0.0); //Extremely. That's why they're so rare. I certainly couldn't build anything like it.
                keira.add(520988, 0.0); //Not the slightest.
                keira.add(520992, 0.0); //No. That is all.
                keira.add(521589, 0.0); //Never expected you'd take such an interest in my private life.
                keira.add(590073, 0.0); //I feel honored, truly.
                keira.add(445721, 0.0); //No. Strictly selfish ones.
                keira.add(1003242, 0.0); //Did you think yourself the only witcher a sorceress could possibly take an interest in?
                keira.add(454888, 0.0); //Yennefer was right. You do have some notion of what women want, how they think.
                keira.add(1042045, 0.0); //How about that, you changed your mind.
                keira.add(1042049, 0.0); //Hardly. Now focus.
                keira.add(565511, 0.0); //We're even now.
                keira.add(170308, 0.0); //Do I look like a dairy maid to you?
                keira.add(477035, 0.0); //You're up to something, Geralt. If I'm to help you, you must tell me what's going on. Who are you looking for?
                keira.add(475332, 0.0); //Nature stinks.
                keira.add(475274, 0.0); //It's nothing to sneeze at, but you've a knack for getting into trouble. I should probably ask for something more immediately deliverable.
                keira.add(477321, 0.0); //Yes, let's.
                keira.add(1051449, 0.0); //Certainly hope we haven't lost our way…
                keira.add(1041948, 0.0); //Geeeralt!
                keira.add(1041944, 0.0); //Thought you were in a hurry.
                keira.add(1041946, 0.0); //Well? Coming?
                keira.add(1051453, 0.0); //Oh, anything for a hot bath.
                keira.add(567216, 0.0); //Have you gone completely mad? We must leave here at once!
                keira.add(1041533, 0.0); //Very well. Let's move on. Perhaps we'll come across some clue, some trace left by this elf.
                keira.add(1062126, 0.0); //Terrible idea. What happened?
                keira.add(1034928, 0.0); //Must you touch everything?!
                keira.add(1051455, 0.0); //The sooner we can leave, the better.
                keira.add(1061928, 0.0); //I'm sorry. For getting ahead of myself. At times I forget…
                keira.add(557575, 0.0); //Why'd we even come…
                keira.add(1059690, 0.0); //Well?
                keira.add(520788, 0.0); //Ughh…
                keira.add(521465, 0.0); //And? It ended well?
                keira.add(521475, 0.0); //I actually regret not going there with you. Perhaps we can make up for that lost time now.
                keira.add(568084, 0.0); //Debatable… But let's not argue and ruin the mood.
                keira.add(590746, 0.0); //Ah! You may know about wine… but you remain quite unsophisticated otherwise.



                lambert = createOnelinerElement('lambert');
                lambert.add(1074630, 0.0); //Well, well, color me impressed. Where'd you learn them tricks?
                lambert.add(1062758, 0.0); //Great. Last thing we needed.
                lambert.add(528350, 0.0); //Right… Almost there.
                lambert.add(1058953, 0.0); //Whatever you want to do…
                lambert.add(1058955, 0.0); //You know, Vesemir's right. You do poke the damn hive, almost always. Fine. Let's go.
                lambert.add(529381, 0.0); //Well, well… Whaddaya know!
                lambert.add(1058923, 0.0); //Couldn't care less. I'm up for the challenge.
                lambert.add(528723, 0.0); //Hah! See 'im shit and run soon as he saw us?
                lambert.add(528856, 0.0); //Damn… Beautiful view.
                lambert.add(530505, 0.0); //Geralt, who do you take me for?
                lambert.add(531147, 0.0); //Yeah, useful sign, Axii. Saved my life a short while ago.
                lambert.add(551091, 0.0); //Woo. Damn.
                lambert.add(586518, 0.0); //Wanna talk about it?
                lambert.add(1059208, 0.0); //After you, sir.
                lambert.add(520577, 0.0); //Whoa! Hit a sore spot, I guess.
                lambert.add(1058259, 0.0); //Still don't. Thing is, got a certain matter to take care of.
                lambert.add(1075527, 0.0); //Hm. Maybe. But we'll talk about that later.
                lambert.add(1035490, 0.0); //Want the short version or the long one?
                lambert.add(1004791, 0.0); //Name of this brothel?
                lambert.add(582482, 0.0); //Think I know how to get in. Got a plan.
                lambert.add(528529, 0.0); //Yeah. I heard.
                lambert.add(528533, 0.0); //I call 'em like I see 'em. That's how I am.
                lambert.add(528598, 0.0); //Well… Might have more spring in my step with the famous White Wolf at my side. So… you ready?
                lambert.add(515364, 0.0); //Sure.
                lambert.add(529104, 0.0); //Exactly. Remember the way?
                lambert.add(529140, 0.0); //No, I got a boat moored there. You know, for fishing.
                lambert.add(529123, 0.0); //Lemme think… Yeah. Five days past.
                lambert.add(529195, 0.0); //Yeah. Something you don't like about it?
                lambert.add(1058899, 0.0); //Don't teach your grandma to suck eggs.
                lambert.add(529483, 0.0); //Course. The noble White Wolf never abandons a man in need. He's more saint than witcher!
                lambert.add(531087, 0.0); //Let's go.
                lambert.add(530509, 0.0); //Hah! Fair enough, but save the rest of your compliments for later. Let's get to work.
                lambert.add(595550, 0.0); //That disappointment I hear?
                lambert.add(447079, 0.0); //That's like me.
                lambert.add(447029, 0.0); //Uh, yeah. Contract in Lan Exeter. Not to boast, but a pretty lucrative one.
                lambert.add(532431, 0.0); //All right. I just don't get how that helps us.
                lambert.add(537661, 0.0); //So, everything's going smoothly.
                lambert.add(1059157, 0.0); //Any good looking women in that batch?
                lambert.add(550012, 0.0); //So what's our plan?
                lambert.add(320910, 0.0); //Don't think about it.
                lambert.add(1067619, 0.0); //Haven't had much time to prepare, so not much, honestly.
                lambert.add(572392, 0.0); //You know my opinion.
                lambert.add(1058957, 0.0); //Finally, something reasonable.
                lambert.add(1058930, 0.0); //And they call me grumpy…
                lambert.add(1058885, 0.0); //Hm, see you changed your mind. Good call.
                lambert.add(529621, 0.0); //The road beckons, my good man! Our companions await!
                lambert.add(595554, 0.0); //Mom always said I was different.
                lambert.add(564602, 0.0); //Do you seriously not know?
                lambert.add(528585, 0.0); //Right, no time to lose. The monstrosity awaits.
                lambert.add(524548, 0.0); //See that?
                lambert.add(1063039, 0.0); //Saw some arachas tracks around here a while back.
                lambert.add(1063047, 0.0); //Heheheh. Natural selection in action.
                lambert.add(530081, 0.0); //"He who returns with his medallion will prove himself worthy and may set off on the Path."
                lambert.add(531077, 0.0); //Let's move.
                lambert.add(527515, 0.0); //Oof, place reeks of mould…
                lambert.add(527516, 0.0); //Think you might've missed your calling.
                lambert.add(531113, 0.0); //If I remember Pappy Vesemir's lessons correctly, witchers kill monsters.
                lambert.add(551093, 0.0); //Going gets tough and you need help, you can count on me.
                lambert.add(1058889, 0.0); //Hey! Thought we were going straight to the cave?
                lambert.add(1035250, 0.0); //Vesemir'd chew you out for such recklessness.
                lambert.add(522534, 0.0); //You got something in mind, don't you. Come on, spit it out.
                lambert.add(519969, 0.0); //Knew the sorceress would see it my way.



                letho = createOnelinerElement('letho');
                letho.add(590678, 0.0); //Goddamn fools.
                letho.add(594071, 0.0); //You know how it is in this trade.
                letho.add(564298, 0.0); //Keep your eyes open.
                letho.add(1075956, 0.0); //Heh, no fun in that.
                letho.add(520473, 0.0); //Love these moments. The air before a battle - nothin' smells as sweet.
                letho.add(593738, 0.0); //Gotten real careful.
                letho.add(593827, 0.0); //Eat my own boot before I believe that.
                letho.add(590898, 0.0); //Yeah… Scum does usually float to the top.
                letho.add(321442, 0.0); //We managed.
                letho.add(520507, 0.0); //He always talk this much?
                letho.add(543272, 0.0); //Mean to say Merigold can conjure up more than a cloud of butterflies?
                letho.add(523723, 0.0); //We gonna try to kill him?
                letho.add(573029, 0.0); //Pansy.
                letho.add(593676, 0.0); //To the emperor - mercenaries. To themselves - bounty hunters. To me - ordinary sons of bitches.
                letho.add(593760, 0.0); //Gotta get rid of them. Coming?
                letho.add(593857, 0.0); //Yeah. Improvise.
                letho.add(593886, 0.0); //He was the only one knew I'd be here. Must've told them. Think me and him are due for a little chat…
                letho.add(593893, 0.0); //Come along. Sight of two witchers should loosen his tongue that much quicker.
                letho.add(594072, 0.0); //Drink with someone in the evening, check if he's robbed you in the morning.
                letho.add(594129, 0.0); //Was before Foltest kissed this world goodbye.
                letho.add(595606, 0.0); //I was stupid. Stupidity can cost you. But betrayal costs even more.
                letho.add(595026, 0.0); //I understand.
                letho.add(595099, 0.0); //From Metinna, I think. But he's hunted and killed everywhere from the far south to the Dragon Mountains.
                letho.add(595107, 0.0); //Ones he's done in sure weren't laughing.
                letho.add(590896, 0.0); //It's how they punish deadbeat debtors in the Nilfgaardian underworld.
                letho.add(595198, 0.0); //Don't know. But like I said, I've grown real careful.
                letho.add(590924, 0.0); //Got company?
                letho.add(595756, 0.0); //Really. How much?
                letho.add(591462, 0.0); //Why? Going somewhere?
                letho.add(596030, 0.0); //I had to risk it.
                letho.add(591549, 0.0); //Told you not to get involved.
                letho.add(596120, 0.0); //No, thanks. I'll be fine.
                letho.add(535946, 0.0); //Ah, some old friends.
                letho.add(546839, 0.0); //Remember our encounter with them at the Hanged Man's Tree?
                letho.add(549678, 0.0); //We'll thrash 'em again this time.
                letho.add(1062847, 0.0); //Count me in, too. Always believed attack is the best defense.
                letho.add(319901, 0.0); //And I'll behave, I promise.
                letho.add(465218, 0.0); //I will. I do my best thinking alone.
                letho.add(572960, 0.0); //Witchers never die in bed.
                letho.add(564504, 0.0); //You're welcome.
                letho.add(464413, 0.0); //Tough one.
                letho.add(590863, 0.0); //Make an exception for you.



                olgierd = createOnelinerElement('olgierd');
                olgierd.add(1117770, 0.0); //Geralt. Have you decided to play defender of the downtrodden?
		olgierd.add(1125117, 0.0); //Well, well… The witcher with the heart of gold.
		olgierd.add(1100665, 0.0); //A man must display some madness from time to time - helps him feel alive.
	        olgierd.add(1095154, 0.0); //So, any better?
                olgierd.add(1119499, 0.0); //You know what, though? It's good at last to taste something… real.
                olgierd.add(1126992, 0.0); //I cannot be certain, but I've my suspicions.
                olgierd.add(1101258, 0.0); //Was it a tough fight?
                olgierd.add(1101979, 0.0); //Hah! Cheeky as ever.
                olgierd.add(1103817, 0.0); //I assumed so.
                olgierd.add(1105748, 0.0); //Confident, aren't you? Proud, sure of your strengths, fearless…
                olgierd.add(1096321, 0.0); //I've no clue what it is. Only that it's deadly.
                olgierd.add(1096327, 0.0); //I'd not have bothered had my cook not become its victim. Ooh, the way she prepared game… Had no equal.
                olgierd.add(1126994, 0.0); //That's a dangerous man you've chosen to deal with, witcher.
                olgierd.add(1095745, 0.0); //Do you know what types of sculptures fetch the best prices?
                olgierd.add(1134727, 0.0); //What do you think of her?
                olgierd.add(1096174, 0.0); //Can't blame you. Contemporary art's become… superficial. And bland.
                olgierd.add(1096164, 0.0); //A jester. Good. I don't like men with no sense of humor. They bore me to death.
                olgierd.add(1095749, 0.0); //Agh… I used to like Votticelli. The life he could breathe into a chunk of cold stone…
                olgierd.add(1126022, 0.0); //As lifeless and boring as a boulder at the roadside.
                olgierd.add(1096346, 0.0); //Ah, a man of action - plain to see.
                olgierd.add(1096360, 0.0); //Well, we haven't a choice, now.
                olgierd.add(1125101, 0.0); //Now where were we?
                olgierd.add(1100663, 0.0); //Beh, "show"? Come, now.
                olgierd.add(1100721, 0.0); //The trick's to plough through that moment, go further, reach beyond what's known as possible.
                olgierd.add(1106801, 0.0); //Come.
                olgierd.add(1101137, 0.0); //Perhaps, perhaps not. Then again - why bother?
                olgierd.add(1101201, 0.0); //Hmmm, let me think.
                olgierd.add(1129013, 0.0); //Give you a hint - you're not the only one to fulfill wishes around here.
                olgierd.add(1114402, 0.0); //Very easy to say. But have you got any proof?
                olgierd.add(1106609, 0.0); //You've done well, witcher.
                olgierd.add(1106585, 0.0); //Is that all, or have you something else?
                olgierd.add(1101668, 0.0); //No?
                olgierd.add(1101672, 0.0); //Stones you've got. But I didn't think you'd have the stomach for a massacre.
                olgierd.add(1101689, 0.0); //Hah! Oh, sounds familiar. There you are, drinking, puffing on henbane… and then - Surprise! - heads rolling across the floor. And none know how or why!
                olgierd.add(1101718, 0.0); //No? Why not?
                olgierd.add(1107083, 0.0); //The kind noble witchers don't usually associate with.
                olgierd.add(1101949, 0.0); //Are you really interested?
                olgierd.add(1102011, 0.0); //Argh, what happened then, witcher, was one big stinkin' pile of shite.
                olgierd.add(1101965, 0.0); //You need something?
                olgierd.add(1101597, 0.0); //Yes. I should have.
                olgierd.add(1101636, 0.0); //Huh. It's progress.
                olgierd.add(1107009, 0.0); //The Ofieri believe one should only discuss important matters out of doors, with the gods as witnesses.
                olgierd.add(1101591, 0.0); //I'm in no mood for jests.
                olgierd.add(1103804, 0.0); //Strange choice of locale. Guessing there's a reason for it?
                olgierd.add(1103813, 0.0); //A witcher with aesthetic sensibility? Forgive my disbelief.
                olgierd.add(1103855, 0.0); //What is this?
                olgierd.add(1103902, 0.0); //What? How…?
                olgierd.add(1095158, 0.0); //This plonk could revive a corpse. An exquisitely rank vintage.
                olgierd.add(1119574, 0.0); //I don't know.
                olgierd.add(1119948, 0.0); //You needn't be.
                olgierd.add(1127988, 0.0); //Now, ready to listen, or do you still not give two shites about what I've got to say?
                olgierd.add(1096344, 0.0); //Let's rejoin the company, partake of some refreshment first.
                olgierd.add(1096654, 0.0); //But you change your mind, you come find me.
                olgierd.add(1125097, 0.0); //Anythin' else I might do for you?
                olgierd.add(1101955, 0.0); //Mhm. Commendable manners.
                olgierd.add(1102028, 0.0); //Hahaha! And folk say I've a heart of stone…
                olgierd.add(1102024, 0.0); //Isn't it? Truthfully, I'm surprised I retained any cheer in my soul.
                olgierd.add(1129100, 0.0); //Aren't you a nosy one.
                olgierd.add(1105768, 0.0); //I'd make a right good witcher. Problem is, I don't know the road to Kaer Morhen, and I doubt you'd give me a pendant.
                olgierd.add(1119542, 0.0); //Oh, I shall be, believe me.



                philippa = createOnelinerElement('philippa_eilhart');
                philippa.add(1069022, 0.0); //You needed merely to ask.
                philippa.add(541763, 0.0); //It appears I must do everything for you.
                philippa.add(554723, 0.0); //Is foreplay that important to you?
                philippa.add(1012954, 0.0); //Ahh, you see, Geralt, there are those who keep politics separate from their private lives, and those who do not.
                philippa.add(1070022, 0.0); //Geralt… Don't ask questions you know the answers to. It makes you look stupid.
                philippa.add(555071, 0.0); //So, onward?
                philippa.add(560064, 0.0); //Couldn't help notice the tension between you and Yennefer and Triss. It's very hard on Ciri, I think.
                philippa.add(555025, 0.0); //She's an adult, Geralt. You keep forgetting. She can decide for herself.
                philippa.add(414295, 0.0); //Wait, there's something here. Feel it?
                philippa.add(562138, 0.0); //Tuning into elven magic is just slightly more difficult than sniffing out a malodorous fiend.
                philippa.add(1070025, 0.0); //Eavesdropping on your conversation, naturally. With a good deal of interest… and a measure of wonder.
                philippa.add(1070045, 0.0); //You don't want my help - more's the pity. But I shall do what I can to make certain you don't fuck it up.
                philippa.add(1084600, 0.0); //Forgive me… I could not deny myself the pleasure.
                philippa.add(557192, 0.0); //Did I?
                philippa.add(559167, 0.0); //Even those of us who lack eyes for the moment.
                philippa.add(556997, 0.0); //I've been better.
                philippa.add(563537, 0.0); //You allow this? Do you truly believe his intentions are pure?
                philippa.add(1012908, 0.0); //Well? What is it?
                philippa.add(1012956, 0.0); //The more boring of the two.
                philippa.add(563335, 0.0); //Kings die, realms fall, but magic endures.
                philippa.add(1031237, 0.0); //I take it your mention of that deviant is purely coincidental?
                philippa.add(557046, 0.0); //You're not her type.
                philippa.add(1066320, 0.0); //We came here for a reason.
                philippa.add(520728, 0.0); //Ready.
                philippa.add(521646, 0.0); //There you are.
                philippa.add(554906, 0.0); //I'd sooner stick my head in a zeugl's spiky orifice. Thanks, but I've other plans.
                philippa.add(554950, 0.0); //Yennefer's wise to keep you out of politics. I'm afraid you'd not realize which way the wind was blowing if you pissed straight into it.
                philippa.add(554819, 0.0); //So she's not told you anything? What about personal plans?
                philippa.add(562076, 0.0); //A ridiculous bauble. Don't make me laugh.
                philippa.add(554553, 0.0); //At laaaast…
                philippa.add(554534, 0.0); //Not so fast. We've a matter to discuss.
                philippa.add(561099, 0.0); //But I wish to talk to you about the future. My future.
                philippa.add(529556, 0.0); //You may go. I know you've things to do. I shall find my own way back.
                philippa.add(505371, 0.0); //What?
                philippa.add(1067502, 0.0); //I'm content someone apart from myself has finally gotten the idea to rid the world of the degenerate.
                philippa.add(1070058, 0.0); //There is none.
                philippa.add(557211, 0.0); //You've something of a persecution complex.
                philippa.add(556437, 0.0); //I hadn't intended.
                philippa.add(1057740, 0.0); //I hope you don't plan to muck about in this carrion, now.
                philippa.add(561076, 0.0); //There are times I doubt you three realize how it looks.
                philippa.add(1057742, 0.0); //I say, look at this!
                philippa.add(562141, 0.0); //The scan's echo is strongest here.
                philippa.add(562434, 0.0); //Keep looking. It must be here.
                philippa.add(556701, 0.0); //Stop playing the jester and listen to me carefully.
                philippa.add(538591, 0.0); //Don't worry, it's only a matter of time in your case.



		geraltKeiraConvo = createConversationElement();
		geraltKeiraConvo.r('keira_metz'); //Required Actors
		geraltKeiraConvo.append('PLAYER', 1041440, 2.6); //You'd really worry about me if I went on alone?
		geraltKeiraConvo.append('keira_metz', 1041441, 3.0); //You?! I'd be concerned for myself!
		geraltKeiraConvo.append('PLAYER', 1047207, 1.8); //Come on, now…
		geraltKeiraConvo.append('keira_metz', 1041464, 0.0); //Very well, have it your way. How did I ever let you talk me into this ridiculous expedition?!

		geraltKeiraConvo = createConversationElement();
		geraltKeiraConvo.r('keira_metz'); //Required Actors
		geraltKeiraConvo.append('keira_metz', 589448, 2.0); //Know the fairytale about Cinderella?
		geraltKeiraConvo.append('PLAYER', 589450, 10.8); //Mhm. True story it's based on, too. A zeugl cropped up in a palace pond and ate Princess Cendrilla whole. Left behind one slipper, so…
		geraltKeiraConvo.append('keira_metz', 589452, 0.0); //I beg you, not another word about zeugls.

		geraltKeiraConvo = createConversationElement();
		geraltKeiraConvo.r('keira_metz'); //Required Actors
		geraltKeiraConvo.append('keira_metz', 1061930, 5.8); //My intuition's a fine instrument, witcher. Don't underestimate it.
		geraltKeiraConvo.append('keira_metz', 1061932, 0.0); //I've some veeery good feelings about you, for instance. In several domains.

		geraltKeiraConvo = createConversationElement();
		geraltKeiraConvo.r('keira_metz'); //Required Actors
		geraltKeiraConvo.append('PLAYER', 567225, 3.4); //If you're scared, turn back. I'm gonna go on.
		geraltKeiraConvo.append('keira_metz', 1041438, 0.0); //Stop it! That's emotional blackmail!

		geraltKeiraConvo = createConversationElement();
		geraltKeiraConvo.r('keira_metz'); //Required Actors
		geraltKeiraConvo.append('keira_metz', 568076, 4.0); //So, what do you think? Neckline too modest?
		geraltKeiraConvo.append('PLAYER', 590090, 0.0); //It's just right.

		geraltKeiraConvo = createConversationElement();
		geraltKeiraConvo.r('keira_metz'); //Required Actors
		geraltKeiraConvo.append('PLAYER', 1002747, 0.0); //Stay calm.

		geraltKeiraConvo = createConversationElement();
		geraltKeiraConvo.r('keira_metz'); //Required Actors
		geraltKeiraConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.

                geraltLambertConvo = createConversationElement();
                geraltLambertConvo.r('lambert'); //Required Actors
		geraltLambertConvo.append('PLAYER', 527427, 2.1); //Fog's thick as curdled milk…
		geraltLambertConvo.append('lambert', 529204, 1.6); //Never took you for a poet.
		geraltLambertConvo.append('PLAYER', 529206, 2.8); //Oh, but I am one. Wanna hear a limerick?
		geraltLambertConvo.append('lambert', 529208, 0.8); //Sure.
		geraltLambertConvo.append('PLAYER', 529210, 2.0); //Lambert, Lambert - what a prick.
                geraltLambertConvo.append('lambert', 529212, 0.0); //Not bad.

                geraltLambertConvo = createConversationElement();
                geraltLambertConvo.r('lambert'); //Required Actors
		geraltLambertConvo.append('lambert', 530930, 7.6); //What… what are you doing?! "Killing monsters." Haha, good one.
		geraltLambertConvo.append('PLAYER', 1140353, 0.0); //Fuck off.

                geraltLambertConvo = createConversationElement();
                geraltLambertConvo.r('lambert'); //Required Actors
		geraltLambertConvo.append('lambert', 528577, 2.4); //Thought you liked people with bitchy streaks.
		geraltLambertConvo.append('PLAYER', 528579, 0.0); //So long as they're women.

                geraltLambertConvo = createConversationElement();
                geraltLambertConvo.r('lambert'); //Required Actors
		geraltLambertConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.

                geraltLethoConvo = createConversationElement();
                geraltLethoConvo.r('letho'); //Required Actors
		geraltLethoConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.

                geraltOlgierdConvo = createConversationElement();
                geraltOlgierdConvo.r('olgierd'); //Required Actors
		geraltOlgierdConvo.append('olgierd', 1105742, 7.0); //The wise men of Oxenfurt claim there are no gods. After death, there is only the void.
		geraltOlgierdConvo.append('olgierd', 1105744, 0.0); //I've known this void already. Death holds no surprises.

                geraltOlgierdConvo = createConversationElement();
                geraltOlgierdConvo.r('olgierd'); //Required Actors
		geraltOlgierdConvo.append('PLAYER', 1111424, 1.4); //Got something for you.
		geraltOlgierdConvo.append('olgierd', 1111426, 0.0); //I love gifts, but I prefer to unwrap them in private.

                geraltOlgierdConvo = createConversationElement();
                geraltOlgierdConvo.r('olgierd'); //Required Actors
		geraltOlgierdConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.

		geraltPhilippaConvo = createConversationElement();
		geraltPhilippaConvo.r('philippa_eilhart'); //Required Actors
		geraltPhilippaConvo.append('PLAYER', 1002747, 0.0); //Stay calm.

		geraltPhilippaConvo = createConversationElement();
		geraltPhilippaConvo.r('philippa_eilhart'); //Required Actors
		geraltPhilippaConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.
	}

	private function initNPCChats_6()
	{
		var priscilla, regis, syanna, thaler, vernon, ves : mod_scm_SpecialNPCOnelinersDefinition;
		var geraltPriscillaConvo, geraltRegisConvo, geraltSyannaConvo, geraltThalerConvo, geraltVernonConvo, geraltVesConvo : mod_scm_SpecialNPCConversationDefinition;

                priscilla = createOnelinerElement('pryscilla');
                priscilla.add(418873, 0.0); //Come.
                priscilla.add(501988, 0.0); //He claimed he was helping someone. An urgent matter that couldn't wait, he said.
                priscilla.add(501996, 0.0); //Well he's not driven up in a gilded carriage laden with jewels, so I should think so.
                priscilla.add(1006520, 0.0); //Well… I very much doubt I could bear to have him around were it not so.
                priscilla.add(489649, 0.0); //Yes? And? Did you learn somethin'?
                priscilla.add(1006719, 0.0); //Certainly hope you're right. Though his type never forgives and rarely relents.
                priscilla.add(1073572, 0.0); //Where?!
                priscilla.add(1073576, 0.0); //That's not a nice jest.
                priscilla.add(479737, 0.0); //This… plan? What is it?
                priscilla.add(480572, 0.0); //I know this might sound strange but…. I can't be sure.
                priscilla.add(480610, 0.0); //No, he simply spoke about something other than himself.
                priscilla.add(479802, 0.0); //Hard to imagine a better actor than a doppler.
                priscilla.add(479415, 0.0); //Not a bad idea, but I doubt a few lines would suffice.
                priscilla.add(499456, 0.0); //It's sure to go quicker if you help me. You'll see, we'll have a grand time together.
                priscilla.add(499996, 0.0); //That'll do.
                priscilla.add(500026, 0.0); //Well, you must admit I'm better acquainted with the theater.
                priscilla.add(500070, 0.0); //Hidden message?
                priscilla.add(489617, 0.0); //Please… I shan't be any trouble.
                priscilla.add(489635, 0.0); //I know. As soon as the fighting starts, I'm to stand at a distance.
                priscilla.add(1045452, 0.0); //For me?
                priscilla.add(1045963, 0.0); //I certainly hope he's not gotten into trouble.
                priscilla.add(1048268, 0.0); //This was a stupid idea.
                priscilla.add(480574, 0.0); //It seems he'd been circling me for some time in various forms, trying to attract my attention…
                priscilla.add(499464, 0.0); //Good. I'll have more time to prepare.
                priscilla.add(500004, 0.0); //Any ideas for the plot?
                priscilla.add(499956, 0.0); //I've some ideas - perhaps you can choose.
                priscilla.add(1045787, 0.0); //You needn't mock.
                priscilla.add(502006, 0.0); //If trolls were devilishly intelligent and had a flair for crime, yeah, I'd agree.
                priscilla.add(1006509, 0.0); //Dandelion can be irritatin', I shan't deny it. Yet, I also know he can be fair and noble at times.



                regis = createOnelinerElement('regis_terzieff_vampire');
                regis.add(1176693, 0.0); //Charming.
                regis.add(1176713, 0.0); //Tsk, tsk. Once you're labeled a black sheep, it's so hard to shed that reputation.
	        regis.add(1151926, 0.0); //We must be close.
	        regis.add(1176512, 0.0); //I couldn't have put it better myself.
                regis.add(1176687, 0.0); //We should look around at least.
                regis.add(1178597, 0.0); //Anything in particular interest you?
                regis.add(1162467, 0.0); //Do I detect a note of sarcasm?
                regis.add(1155490, 0.0); //Your powers of deduction seem to have waned not one bit. I'm happy.
                regis.add(1159200, 0.0); //Hear that?
                regis.add(1198684, 0.0); //Really, now, Geralt, must you?
		regis.add(1170071, 0.0); //Right you are.
		regis.add(1189824, 0.0); //Not impossible. She would be safe there… and isolated. We must see.
		regis.add(1155993, 0.0); //Hm. Vampires can evade detection by the senses, and no divination magic works on us. Even the most precise megascope would be useless…
		regis.add(1182076, 0.0); //You might call him a… humanist. He saw us, vampires, as guests here, guests who owe their hosts, meaning you humans and the Elder Races, respect.
		regis.add(1178799, 0.0); //Hmm… Given that we lack the time to sleuth this out ourselves, permit me to summon some help.
		regis.add(1178610, 0.0); //Sadly, this is but a weak infusion rather than a proper distillate.
		regis.add(1178615, 0.0); //Now, what could Geralt of Rivia prefer to keep to himself?
		regis.add(1178675, 0.0); //I love a challenge! In that case, my ears are cocked - what must I do?
		regis.add(1192563, 0.0); //Oo, seems I certainly missed quite a bit while I was… absent!
		regis.add(1178760, 0.0); //As humans understand death - yes.
		regis.add(1178764, 0.0); //Hm. It's rather hard to explain. I felt something very unsettling. Something I cannot even name, for I did no reasoning.
		regis.add(1192933, 0.0); //Very true. One's outlook can indeed change much.
		regis.add(1178770, 0.0); //Starting all anew is a very broad concept. What exactly do you mean?
		regis.add(1192749, 0.0); //Not to worry, Geralt. Curiosity's a natural reaction under the circumstances. Apart from which, I've always valued that trait in you.
		regis.add(1179647, 0.0); //I don't recall much in particular. Really don't attach much importance to such things. It was mentioned to me, as an anecdote, no more…
		regis.add(1179655, 0.0); //Sorry, Geralt, I try not to clutter my mind with the details of every far-fetched tale I happen to hear.
		regis.add(1179664, 0.0); //What are your thoughts?
		regis.add(1166229, 0.0); //I sincerely doubt it. Ravens are devilishly intelligent creatures. And they've highly developed observational skills.
		regis.add(1180057, 0.0); //Correct. I told you there'd be danger.
		regis.add(1181745, 0.0); //We need not discuss it.
		regis.add(1181749, 0.0); //What would you have done?
		regis.add(1181603, 0.0); //This is important, Geralt. The slightest deviation could cost even a witcher dearly.
		regis.add(1174754, 0.0); //What did you see?
		regis.add(1182037, 0.0); //Why the uncertainty?
		regis.add(1182047, 0.0); //Did you see anything else?
		regis.add(1181865, 0.0); //Peculiar…
		regis.add(1174762, 0.0); //Hm. That would be even odder…
		regis.add(1173126, 0.0); //I considered it briefly, but ultimately concluded it would be terribly dull.
		regis.add(1184779, 0.0); //Come.
		regis.add(1161188, 0.0); //Perhaps… Yet perhaps also worth remembering.
		regis.add(1161195, 0.0); //Let's get to work.
		regis.add(1184785, 0.0); //I don't rightly know.
		regis.add(1161985, 0.0); //Who?
		regis.add(1161007, 0.0); //Whoever it is, it is someone new.
		regis.add(1170063, 0.0); //Geralt, as you rightly noted, we are vampires, not miracle workers.
		regis.add(1161082, 0.0); //Exactly.
		regis.add(1161312, 0.0); //Why is that?
		regis.add(1175888, 0.0); //That… is not exactly true.
		regis.add(1174853, 0.0); //Alone?
		regis.add(1198038, 0.0); //Well, it truly does seem the best option.
		regis.add(1149497, 0.0); //Are you upset?
		regis.add(1150326, 0.0); //Mh, yes, of course. The excuse you resort to whenever you'd rather not talk about something.
		regis.add(1196013, 0.0); //You know of our exceedingly long lifespans… They allow us plenty of time to change. I, for one, thank the gods for that.
		regis.add(1150953, 0.0); //I do not recall ever suggesting we ask her permission.
		regis.add(1176048, 0.0); //There, you see? I knew you'd think of something. Bravo.
		regis.add(1176072, 0.0); //I trust I've dispelled your doubts, then?
		regis.add(1151084, 0.0); //We must find him, first.
		regis.add(1151098, 0.0); //I don't know. You'll have to improvise, I suppose.
		regis.add(1176003, 0.0); //Certainly hope so. Now please tell me… what is it you intend to do?
		regis.add(1176078, 0.0); //Of course. Many hands make light work.
		regis.add(1179780, 0.0); //Not an easy choice. Understood.
		regis.add(1172284, 0.0); //We must put him down before he kills again.
		regis.add(1179266, 0.0); //As a rule, they don’t.
		regis.add(1173093, 0.0); //If we'd only arrived a bit earlier…
		regis.add(1175257, 0.0); //Pointless. That's no obstacle to a vampire.
		regis.add(1166083, 0.0); //I suggest we postpone any further discussion.
		regis.add(1150802, 0.0); //Not at all.
		regis.add(1176697, 0.0); //Perhaps not so much…
		regis.add(1177124, 0.0); //I shall do my utmost.
		regis.add(1171581, 0.0); //Then I invite you to join me for one. I'm certain to dig up a flask. Or two. Or three.
		regis.add(1159302, 0.0); //Indeed. The logical conclusion, Geralt.
		regis.add(1192668, 0.0); //Heh. Why not admit you're simply afraid of her reaction?
		regis.add(1177003, 0.0); //I cannot. At times one must abandon grand politics for a bit of simple pleasure. I believe this is one of those times.
		regis.add(1188452, 0.0); //You need not.
		regis.add(1186178, 0.0); //Some philosophers think empirical examination the sole path to knowledge.
		regis.add(1168989, 0.0); //Ah, this place is like a strong wine, Geralt. Good in small sips.
		regis.add(1174836, 0.0); //But I shall tell you all about her… some other day.
		regis.add(1174207, 0.0); //An exceptional conversation, don't you think? Vampires, a witcher and the duchess of Toussaint - my, my.
		regis.add(1180767, 0.0); //I fear we waste our time here. Come, Geralt.
		regis.add(1185998, 0.0); //It's not far now, Geralt.
		regis.add(1153708, 0.0); //I've looked into it already.
		regis.add(1175618, 0.0); //So be it. But try not to tarry.
		regis.add(1153716, 0.0); //Perhaps, I don't know. We must see for ourselves. Come.
		regis.add(1153188, 0.0); //Hm, well… I understand. I'll not mention it again.
		regis.add(1162238, 0.0); //Hm. It's somewhat more complex.
		regis.add(1157069, 0.0); //You believe it will be worth all this?
		regis.add(1193989, 0.0); //I… Hm. I'm not certain I know what to say.
		regis.add(1162276, 0.0); //Alas, just so. Thus I fear we must rely on my personal charm.
		regis.add(1176487, 0.0); //It's not much… but it is something.
		regis.add(1157267, 0.0); //Hm. A bit.
		regis.add(1179284, 0.0); //Perhaps they'll find one in the area. And I would hazard that a flock of ravens will spy any said creature faster than a solitary witcher would - with all due respect to your skills, my friend.
		regis.add(1178683, 0.0); //I prefer almost always to ask indirectly. It seems a test of intelligence - one you just passed.
		regis.add(1175885, 0.0); //That makes two of us. But worry not. I've thought it through very thoroughly. Details to follow, soon.
		regis.add(1181885, 0.0); //Perhaps we should have a chat with the lad, though I would expect no breakthroughs.
		regis.add(1187297, 0.0); //It seems you're having a rough go of it…
		regis.add(1175138, 0.0); //Even if he's not here, surely he's left behind some clue as to his whereabouts.
		regis.add(1157738, 0.0); //Indeed. I'm not certain why, but it reminds me of home. Our true home, from before the Conjunction of Spheres.
		regis.add(1172288, 0.0); //I told you. He's exceptional. He manages to bend them to his will, control them with his thoughts.
		regis.add(1174845, 0.0); //Do you mean to say your task now is to extract two women from the castle?
		regis.add(1164311, 0.0); //I believe he suspects something. He must. And he seeks to understand what happened.



                syanna = createOnelinerElement('syanna');
                syanna.add(1183501, 0.0); //What's your point?
                syanna.add(1162633, 0.0); //Felicitations, witcher. It seems you've won.
                syanna.add(1153256, 0.0); //Here it is!
                syanna.add(1153395, 0.0); //Mhm. Yet I still don't know why you even give a damn.
                syanna.add(1153542, 0.0); //And? Was she truly monstrous?
                syanna.add(1153562, 0.0); //You killed her, didn't you.
                syanna.add(1153513, 0.0); //Hm. Certainly. But you must gird yourself with patience.
                syanna.add(1153669, 0.0); //And who has it? Hm?
                syanna.add(1164392, 0.0); //She got what she deserved, as I see it. Always took what she wanted without asking.
                syanna.add(1153794, 0.0); //You know what they say about the "hair of the dog."
                syanna.add(1152176, 0.0); //What?
                syanna.add(1176749, 0.0); //It's a dog's life, I tell you…
                syanna.add(1175277, 0.0); //Any luck?
                syanna.add(1155764, 0.0); //That would never fit you. Give it to me.
                syanna.add(1164353, 0.0); //Yes, it shows.
                syanna.add(1164357, 0.0); //Women must love you.
                syanna.add(1153855, 0.0); //Well then - one step closer to our goal.
                syanna.add(1159242, 0.0); //I find myself wondering if you're just horribly discreet, or if those mutations completely scrubbed away your curiosity.
                syanna.add(1175393, 0.0); //Right, we've had our chat. Come.
                syanna.add(1159263, 0.0); //Like me?
                syanna.add(1197268, 0.0); //Careful. It is not to be trusted.
                syanna.add(1165125, 0.0); //Oh, Geralt, Geralt… and they call me cruel.
                syanna.add(1175510, 0.0); //No. At first I was simply intrigued. Do you know the story?
                syanna.add(1167257, 0.0); //You actually have a sense of humor.
                syanna.add(1167289, 0.0); //Well, well, aren't you full of surprises. What else are you hiding behind that gruff exterior?
                syanna.add(1167298, 0.0); //We must keep looking.
                syanna.add(1162421, 0.0); //So, do you like it here?
                syanna.add(1162429, 0.0); //A beau of old-fashioned tastes, eh? I like that.
                syanna.add(1165312, 0.0); //Do you really aim to concern yourself with that?
                syanna.add(1164326, 0.0); //Did you really travel all the way here for a contract?
                syanna.add(1164458, 0.0); //I don't believe it. You must have had another reason.
                syanna.add(1165142, 0.0); //Oh, yes. Visit Toussaint once, and you'll always long to return.
                syanna.add(1154006, 0.0); //Indeed. It's even taller than I remembered…
                syanna.add(1167337, 0.0); //Can you blame her? Men these days… dandies and fops, all.
                syanna.add(1175540, 0.0); //I've always had a way with ostensibly dangerous quiet types.
                syanna.add(1154729, 0.0); //Why ever would I have?
                syanna.add(1208616, 0.0); //No, I need you for a purpose far simpler.
                syanna.add(1154898, 0.0); //Did you wish to tell me something?
                syanna.add(1187221, 0.0); //Go, witcher. Or they'll give your medal to another. And that would be a shame.
                syanna.add(1208680, 0.0); //In that case, at last you've felt what so many women in this world feel at times.
                syanna.add(1155835, 0.0); //That may very well depend on you.
                syanna.add(1167212, 0.0); //Nothing beyond what you heard - for now.
                syanna.add(1162441, 0.0); //They were my right. My due.
                syanna.add(1162445, 0.0); //I do… and I regret nothing. One lives but once.
                syanna.add(1180111, 0.0); //I was praised for it as a little girl… Only for that, in fact.
                syanna.add(1154339, 0.0); //All right. Tell me.
                syanna.add(1186951, 0.0); //Then why do it at all?
                syanna.add(1187107, 0.0); //I probably will.
                syanna.add(1187157, 0.0); //Don't worry. I'll find a way.
                syanna.add(1187126, 0.0); //Why should I?
                syanna.add(1187211, 0.0); //Ahh, with all of us living happily ever after…
                syanna.add(1154042, 0.0); //It's time we moved on. Come.
                syanna.add(1167294, 0.0); //But, here we are chatting away when there's work to do!
                syanna.add(1154390, 0.0); //The home stretch.
                syanna.add(1157249, 0.0); //Perhaps he'll tell you himself.
                syanna.add(1197560, 0.0); //What…? But how?
                syanna.add(1162409, 0.0); //So… what exactly is happening in the city?
                syanna.add(1165322, 0.0); //Hey, there, in the trees! Some kind of camp?
                syanna.add(1183539, 0.0); //I've nothing to tell.
                syanna.add(1152576, 0.0); //So?
		syanna.addPreC(1176785, 0.0); //Be careful!



                thaler = createOnelinerElement('talar');
                thaler.add(1067603, 0.0); //Bravo. Bloody braaavo.
                thaler.add(1064589, 0.0); //Oh, he'll swallow that. Hook, line, sinker and a good bit of the rod as well!
                thaler.add(1064879, 0.0); //The Silver Lilies will bloom 'neath the rays of the Great Sun. So I'd say were I a poet.
                thaler.add(1064881, 0.0); //But I'm not, so all I'll say is there was no other fuckin' way.
                thaler.add(1064888, 0.0); //You're right on that account… We know you're bloody allergic to politics, decided to emphasize mages and whatnot…
                thaler.add(1064910, 0.0); //Wha… How? This is not what we ploughin' agreed!
                thaler.add(1064937, 0.0); //Bloody hell, bugger me sideways…
                thaler.add(1064865, 0.0); //You're mistaken.
                thaler.add(1067387, 0.0); //Right, true that. Just look at the ploughin' bastard - naught but skin and bones.
                thaler.add(1067572, 0.0); //Got to admit, you have a way with trolls. Ever thought of having children?
                thaler.add(1067591, 0.0); //Ugh, you've not changed a bit.
                thaler.add(1067595, 0.0); //Still tart as rotting rhubarb.
                thaler.add(1036482, 0.0); //Grassroots work. I hang about the area, watchin', listenin', askin' questions, and recruitin' new agents.
                thaler.add(1067704, 0.0); //Forgive me, mate. I ploughin' can't.
                thaler.add(1067706, 0.0); //See, were it just up to me, I'd spill it loud and proud. You're trustworthy, like no one else I know.
                thaler.add(1067708, 0.0); //But I'm not on my own, so blooming unilateral decisions are outta the question. Trap stays shut, I'm afraid.
                thaler.add(1067737, 0.0); //Picked the least suspicious profession.
                thaler.add(1067733, 0.0); //The fence thing - shite cover. Pissed too many folk off. I didn't need the attention.
                thaler.add(1067748, 0.0); //Thought about bein' an innkeep. You meet a lot of folk, you know, tossers mostly, but willlin' to talk about all sorts of things. Problem is, you're tied down like a mutt on a chain - one and the same yard all the time.
                thaler.add(1040305, 0.0); //Shite. Thought I'd covered me tracks. How'd you find it?
                thaler.add(1066612, 0.0); //Err, gimme a minute.
                thaler.add(1067599, 0.0); //Ah! Mean they've not forgotten me? That's nice.
                thaler.add(1067607, 0.0); //Though I am grateful you came to get me, Geralt.
                thaler.add(1067609, 0.0); //Must have a lot on your mind, all those monsters to kill…
                thaler.add(1067613, 0.0); //Huh? They tell you? Clowns.
                thaler.add(1067623, 0.0); //Sorry, mate. If they were mum, I've got to be mum.
                thaler.add(1067635, 0.0); //You sayin' the Black Ones have no use for cobblers?
                thaler.add(1067639, 0.0); //Brought fuck all, as I see it. Amateurs in uniform.
                thaler.add(1067641, 0.0); //And you'll not find a better cobbler than Thaler anywhere in the North!
                thaler.add(1067651, 0.0); //You doubt me?
                thaler.add(1067657, 0.0); //Ah, I see you've thought about this.
                thaler.add(1067677, 0.0); //Who takes an interest in cobblers? No one.
                thaler.add(1067681, 0.0); //Bollocks, mostly. But sometimes they'll say somethin' interestin'.
                thaler.add(1067685, 0.0); //That's all I'm willin' to say.
                thaler.add(1041089, 0.0); //Yeah, I do, most of the fuckin' time, thanks.
                thaler.add(1064186, 0.0); //Infernal fuckin' mess. We should sod off.
                thaler.add(1067553, 0.0); //Truth be told, you didn't have to kill 'em.
                thaler.add(1067557, 0.0); //Fuckin' hell, them? Don't even think about it. I'd kill myself with those idiots.
                thaler.add(1067559, 0.0); //But they were likeable as idiots go.
                thaler.add(507963, 0.0); //Meh, bit like a potato beetle. I keep quiet, stay outta trouble and live on fuckin' potatoes.
                thaler.add(1075419, 0.0); //If you won't ploughin' talk, least you can do is pour a round. Bloody suspense has made my throat dry.
                thaler.add(1064629, 0.0); //Ugh, well, the prick just popped our pumpkin.
		thaler.addPostC(1070682, 0.0); //That was fuckin' close!



                vernon = createOnelinerElement('vernon_roche');
                vernon.add(512771, 0.0); //Something's not right.
                vernon.add(490830, 0.0); //Laugh all you want. Temeria will rise again.
                vernon.add(499529, 0.0); //You jest, right? Who cares about the Scoia'tael anymore.
                vernon.add(1068374, 0.0); //I don't like this… But so be it, you certainly don't deserve to suffer as a result.
                vernon.add(1069054, 0.0); //I trust no one. Including you.
                vernon.add(1069050, 0.0); //Slippery little bugger. I'd have nothing to do with him were the circumstances any different.
                vernon.add(319889, 0.0); //I don't question his abilities. I simply don't trust him.
                vernon.add(559312, 0.0); //Think this through before it's too late.
                vernon.add(541126, 0.0); //Temeria – that's what matters.
                vernon.add(515647, 0.0); //I've heard of him. Though I'm not sure why you think he might be in my camp.
                vernon.add(512333, 0.0); //These birds, they're terribly talkative. I'll need to see them, you'll have to point them out--
                vernon.add(549294, 0.0); //I think he'd best explain.
                vernon.add(540681, 0.0); //Geralt. Come to think of it, I too wanted to ask a favor.
                vernon.add(1068110, 0.0); //Bollocks. She's prepared to die for me. That's not the problem.
                vernon.add(1068113, 0.0); //Know what distinguishes a soldier from a common swashbuckler?
                vernon.add(1068117, 0.0); //It's a serious question.
                vernon.add(1068145, 0.0); //War means death. Not only of for soldiers, for common folk, as well. You can't save them all. It's that simple.
                vernon.add(1068150, 0.0); //You were right to, are right to. But I have one ideal - a free Temeria. And I'm prepared to sacrifice anything for it.
                vernon.add(1068191, 0.0); //Thanks, Geralt. I'll owe you a favor.
                vernon.add(1068387, 0.0); //I will explain later..
                vernon.add(1065688, 0.0); //Retired intelligence operatives - we've a club.
                vernon.add(1065649, 0.0); //Not proud of it. Yet… I considered all the options and found none better.
                vernon.add(1065717, 0.0); //We've got to find him. And you're the best tracker around.
                vernon.add(321386, 0.0); //I can say I've seen it all now.
                vernon.add(1067587, 0.0); //Inspired you to do what?
                vernon.add(1069996, 0.0); //What?! And you didn't think it worth mentioning?!
                vernon.add(1064839, 0.0); //It's done. Though all did not go according to plan.
                vernon.add(1064892, 0.0); //I'm prepared to do anything for Temeria. Even whore myself out.
                vernon.add(564401, 0.0); //We'll think of something, right?
                vernon.add(1064620, 0.0); //What? Geralt, what're you saying?
                vernon.add(512767, 0.0); //My contact should be there.
                vernon.add(512766, 0.0); //The man we're due to meet is probably waiting already.
                vernon.add(1054599, 0.0); //What kind o' contribution you lookin' for?
                vernon.add(1065713, 0.0); //One of our co-conspirators ventured out to meet an informer. He's not returned, yet the plan's success hinges on what he's learned.
                vernon.add(1073786, 0.0); //The sooner you finish, the better.
                vernon.add(1074965, 0.0); //Will you bloody tell us what this is about?
                vernon.add(1067764, 0.0); //The bridge must be clear.
                vernon.add(1064799, 0.0); //All right?
                vernon.add(578331, 0.0); //Gladly.



                ves = createOnelinerElement('ves');
                ves.add(536186, 0.0); //I ought to give you a hiding for not asking my help. But I took it all out on Roche along the way.
                ves.add(559315, 0.0); //You might've forgotten what he did. I haven't.
                ves.add(1064904, 0.0); //What's that?
                ves.add(1064939, 0.0); //That was close. Very close.
                ves.add(1068278, 0.0); //I could not abandon them. They helped us.
                ves.add(1068363, 0.0); //What?!
                ves.add(520449, 0.0); //Deep as the dark abyss. Bottoms bristling with sharpened stakes.
                ves.add(321388, 0.0); //I still don't believe everything that happened.
                ves.add(564403, 0.0); //Definitely.
                ves.add(1068360, 0.0); //We don't take prisoners.
                ves.add(1066191, 0.0); //Not now, Geralt!
                ves.add(1070709, 0.0); //When I've a matter for you, I'll find you.
                ves.add(564397, 0.0); //Take care of the girl. Don't let anyone harm her.



		geraltPriscillaConvo = createConversationElement();
		geraltPriscillaConvo.r('pryscilla'); //Required Actors
		geraltPriscillaConvo.append('pryscilla', 501927, 5.8); //Don't be surprised. After all, doubt I could think of a more fitting subject for a ballad than a witcher's love for a sorceress…
		geraltPriscillaConvo.append('pryscilla', 501944, 0.0); //Or should I say - sorceresses?

		geraltPriscillaConvo = createConversationElement();
		geraltPriscillaConvo.r('pryscilla'); //Required Actors
		geraltPriscillaConvo.append('PLAYER', 1002747, 0.0); //Stay calm.

		geraltPriscillaConvo = createConversationElement();
		geraltPriscillaConvo.r('pryscilla'); //Required Actors
		geraltPriscillaConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.

		geraltRegisConvo = createConversationElement();
		geraltRegisConvo.r('regis_terzieff_vampire'); //Required Actors
		geraltRegisConvo.append('regis_terzieff_vampire', 1178723, 8.4); //If you were to die and be reborn as I was… in your new life, would you choose to be a witcher?
		geraltRegisConvo.append('PLAYER', 1178705, 2.4); //See, Regis…
		geraltRegisConvo.append('PLAYER', 1178711, 7.6); //I like being on the Path. Like picking up a lead, a trail… I like the tension right before a fight.
		geraltRegisConvo.append('PLAYER', 1178715, 5.8); //Yeah. Not something I think about much, but I like being a witcher.
		geraltRegisConvo.append('regis_terzieff_vampire', 1179383, 0.0); //Thank you for being honest. Honesty's an attribute of the truly brave - and thus a privilege of the very few.

		geraltRegisConvo = createConversationElement();
		geraltRegisConvo.r('regis_terzieff_vampire'); //Required Actors
		geraltRegisConvo.append('PLAYER', 1187913, 4.6); //Penny for your thoughts. Lemme guess - succubus twins?
		geraltRegisConvo.append('regis_terzieff_vampire', 1187915, 6.4); //No. I was thinking about… oh, how anything can look interesting when properly lit.
		geraltRegisConvo.append('PLAYER', 1187917, 2.2); //Even an old necrophage corpse?
		geraltRegisConvo.append('regis_terzieff_vampire', 1188983, 0.0); //You've not an ounce of refinement in you, have you?

		geraltRegisConvo = createConversationElement();
		geraltRegisConvo.r('regis_terzieff_vampire'); //Required Actors
		geraltRegisConvo.append('regis_terzieff_vampire', 1150291, 4.4); //Hm. How… how do your employers customarily react when you fail to meet their expectations?
		geraltRegisConvo.append('PLAYER', 1150293, 8.4); //Depends. Peasants cuss me out. Merchants demand I refund their deposit. Whereas nobles mostly just release their hounds.
		geraltRegisConvo.append('regis_terzieff_vampire', 1150295, 1.2); //And rulers?
		geraltRegisConvo.append('PLAYER', 1150297, 0.0); //Usually threaten me with the gallows.

		geraltRegisConvo = createConversationElement();
		geraltRegisConvo.r('regis_terzieff_vampire'); //Required Actors
		geraltRegisConvo.append('regis_terzieff_vampire', 1161316, 4.5); //Hm. Astute. Now that I think of it, I'm beginning to wonder if…
		geraltRegisConvo.append('PLAYER', 1161318, 3.2); //It's not one of your kind? Another vampire?
		geraltRegisConvo.append('regis_terzieff_vampire', 1170067, 0.0); //Precisely. The plot thickens.

		geraltRegisConvo = createConversationElement();
		geraltRegisConvo.r('regis_terzieff_vampire'); //Required Actors
		geraltRegisConvo.append('PLAYER', 1155088, 5.5); //Agreed to meet a vampire at a cemetery. How much more cliché can you get?
		geraltRegisConvo.append('regis_terzieff_vampire', 1155090, 0.0); //Hahaha. Nothing comes readily to mind.

		geraltRegisConvo = createConversationElement();
		geraltRegisConvo.r('regis_terzieff_vampire'); //Required Actors
		geraltRegisConvo.append('PLAYER', 1178677, 2.0); //Everyone's got some secret.
		geraltRegisConvo.append('regis_terzieff_vampire', 1178679, 0.0); //I agree wholeheartedly. I also believe it wise at times to share one's secrets, unburden oneself to those one can trust.

		geraltRegisConvo = createConversationElement();
		geraltRegisConvo.r('regis_terzieff_vampire'); //Required Actors
		geraltRegisConvo.append('regis_terzieff_vampire', 1181600, 5.0); //Are you certain you followed the formula? The proportions were exact, the brewing time precise?
		geraltRegisConvo.append('PLAYER', 1181605, 0.0); //Relax. Got some experience brewing potions.

		geraltRegisConvo = createConversationElement();
		geraltRegisConvo.r('regis_terzieff_vampire'); //Required Actors
		geraltRegisConvo.append('regis_terzieff_vampire', 1187858, 3.8); //How do you find my personal brew? Not too strong?
		geraltRegisConvo.append('PLAYER', 1187899, 0.0); //Just right.

		geraltRegisConvo = createConversationElement();
		geraltRegisConvo.r('regis_terzieff_vampire'); //Required Actors
		geraltRegisConvo.append('regis_terzieff_vampire', 1185918, 1.5); //Are you well, my friend?
		geraltRegisConvo.append('PLAYER', 423065, 0.0); //Just so happens I'm doing fine at the moment.

		geraltRegisConvo = createConversationElement();
		geraltRegisConvo.r('regis_terzieff_vampire'); //Required Actors
		geraltRegisConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.

		geraltSyannaConvo = createConversationElement();
		geraltSyannaConvo.r('syanna'); //Required Actors
		geraltSyannaConvo.append('syanna', 1166061, 3.4); //Does that not disgust you? Poking about in a rotting corpse?
		geraltSyannaConvo.append('PLAYER', 1166063, 3.3); //Compared to the time I fought a zeugl in Vizima's sewers, this…
		geraltSyannaConvo.append('PLAYER', 1166150, 0.0); //Ah, never mind. Don't feel like telling that story again.

		geraltSyannaConvo = createConversationElement();
		geraltSyannaConvo.r('syanna'); //Required Actors
		geraltSyannaConvo.append('syanna', 1162454, 1.5); //How do I look?
		geraltSyannaConvo.append('PLAYER', 464277, 0.0); //You look beautiful.

		geraltSyannaConvo = createConversationElement();
		geraltSyannaConvo.r('syanna'); //Required Actors
		geraltSyannaConvo.append('syanna', 1208676, 3.8); //Oh, my! No woman's ever treated you this way…
		geraltSyannaConvo.append('PLAYER', 1208678, 0.0); //Not that I recall, no.

		geraltSyannaConvo = createConversationElement();
		geraltSyannaConvo.r('syanna'); //Required Actors
		geraltSyannaConvo.append('PLAYER', 1002747, 0.0); //Stay calm.

		geraltSyannaConvo = createConversationElement();
		geraltSyannaConvo.r('syanna'); //Required Actors
		geraltSyannaConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.

                geraltThalerConvo = createConversationElement();
                geraltThalerConvo.r('talar'); //Required Actors
		geraltThalerConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.

                geraltVernonConvo = createConversationElement();
                geraltVernonConvo.r('vernon_roche'); //Required Actors
		geraltVernonConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.

		geraltVesConvo = createConversationElement();
		geraltVesConvo.r('ves'); //Required Actors
		geraltVesConvo.append('PLAYER', 1002747, 0.0); //Stay calm.

		geraltVesConvo = createConversationElement();
		geraltVesConvo.r('ves'); //Required Actors
		geraltVesConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.
	}

	private function initNPCChats_7()
	{
		var vesemir, vivienne, zoltan : mod_scm_SpecialNPCOnelinersDefinition;
		var geraltVesemirConvo, geraltVivienneConvo, geraltZoltanConvo : mod_scm_SpecialNPCConversationDefinition;

                vesemir = createOnelinerElement('vesemir');
		vesemir.add(1112517, 0.0); //Later, maybe… Once it's over, once things're calm again.
		vesemir.add(574100, 0.0); //John of Brugge lacks flair, true, but he's reliable. Not like the hogwash they print nowadays.
		vesemir.add(1044455, 0.0); //Hm. Fine, I suppose I'm partly to blame. But this has to end. Now.
		vesemir.add(163738, 0.0); //You all right?
		vesemir.add(416903, 0.0); //Was she nagging you about something?
		vesemir.add(343534, 0.0); //True to life, indeed.
		vesemir.add(572995, 0.0); //We'll find her.
		vesemir.add(1046292, 0.0); //She's always poked her nose in beehives. Courtly intrigues here, mages' conspiracies there. What do you expect?
		vesemir.add(572999, 0.0); //Didn't end well, did it? Your dream.
		vesemir.add(1046419, 0.0); //Hm! The things young folk get up to these days…
		vesemir.add(1028605, 0.0); //Wait - hear that?
		vesemir.add(576438, 0.0); //Because you can brew potions from their blood?
		vesemir.add(576442, 0.0); //Hmph. Did he know they eat the living as well?
		vesemir.add(331583, 0.0); //Hmph. Gotta believe something. It's what keeps us going.
		vesemir.add(168358, 0.0); //We going?
		vesemir.add(548505, 0.0); //Like I said - leads to the main road and ends there. Muddled.
		vesemir.add(343550, 0.0); //Mhm. Just remember - we'd rather not draw any attention.
		vesemir.add(596142, 0.0); //Things used to be simpler. Monsters were bad, humans good. Now, everything's all confused.
		vesemir.add(565111, 0.0); //Hm. It's always the same. Instead of sending for a professional, they try to do it themselves, only end up making matters worse.
		vesemir.add(565496, 0.0); //So, ready?
		vesemir.add(533298, 0.0); //Hear that? It's close.
		vesemir.add(565880, 0.0); //Geralt, we should stay out of it… just this once.
		vesemir.add(1046915, 0.0); //The kind one can't refuse?
		vesemir.add(526468, 0.0); //Glad you noticed.
		vesemir.add(532435, 0.0); //Yes. Don't like it one bit. But I suppose I have to trust you.
		vesemir.add(537446, 0.0); //Couldn't bear to part with it. Thought we might find a use for it one day. You know how old people are.
		vesemir.add(570861, 0.0); //Quiet. Listen.
		vesemir.add(522083, 0.0); //You know him?
		vesemir.add(520451, 0.0); //I started brewing some potions. Like to finish if you don't mind.
		vesemir.add(577554, 0.0); //Everything settled?
		vesemir.add(465164, 0.0); //If they bleed, they can die.
		vesemir.add(1062929, 0.0); //What's next?
		vesemir.add(522277, 0.0); //They'll expect to catch us by surprise - and they'll be sorely disappointed.
		vesemir.add(548089, 0.0); //Please. I'm not decrepit yet.
		vesemir.add(558370, 0.0); //Gotcha.
		vesemir.add(1046290, 0.0); //Be surprised if she wasn't in trouble.
		vesemir.add(1046355, 0.0); //Calm? With Yennefer? Hmph. Good luck.
		vesemir.add(573003, 0.0); //It was just a dream.
		vesemir.add(1046415, 0.0); //A-ha… I understand. Least I think I do. Maybe not entirely, but… perhaps that's for the best.
		vesemir.add(522350, 0.0); //Provided you got lucky.
		vesemir.add(1048277, 0.0); //My thoughts exactly. In a forest or the mountains, sure, but here? And near the main road?
		vesemir.add(416891, 0.0); //Yeah. Especially hard to forget this one.
		vesemir.add(353292, 0.0); //Do well not to point up my age. You're near a century old yourself.
		vesemir.add(565131, 0.0); //And how's that going?
		vesemir.add(526084, 0.0); //And your journey - how was it?
		vesemir.add(526244, 0.0); //Geralt… I understand she's a-- well, how do I put this? Emancipated, strong-willed woman… But do manners count for nothing?
		vesemir.add(526350, 0.0); //Aaaah… Now I see.
		vesemir.add(526439, 0.0); //Wish I knew.
		vesemir.add(519703, 0.0); //Not entirely. But I did learn something.
		vesemir.add(538007, 0.0); //Meaning you guessed?
		vesemir.add(522242, 0.0); //Yes…
		vesemir.add(566057, 0.0); //We've got the materials.
		vesemir.add(577482, 0.0); //We won't have time to do much else.
		vesemir.addPreC(533311, 0.0); //Watch out!



                vivienne = createOnelinerElement('sq701_vivienne');
		vivienne.add(1208517, 0.0); //The explanation is disappointing, I'm afraid. The fragrance I use, it's mixed by a sorceress.
		vivienne.add(1205086, 0.0); //How juvenile.
		vivienne.add(1132310, 0.0); //A what?
		vivienne.add(1160819, 0.0); //You mock me!
		vivienne.add(1186994, 0.0); //And you truly think you could do something like this for me?
		vivienne.add(1188108, 0.0); //So there is another?
		vivienne.add(1207067, 0.0); //I do not even wish to hear of it.
		vivienne.add(1207047, 0.0); //Consequences? What kind?
		vivienne.add(1197401, 0.0); //Come.
		vivienne.add(1206736, 0.0); //Might you explain the nature of the ritual, its exact course?
		vivienne.add(1201928, 0.0); //Are you quite finished? Is that all you wish to say?
		vivienne.add(1188104, 0.0); //And for a dream to come true there must be sacrifices. Very well. Let us go.
		vivienne.add(1150429, 0.0); //This is the place.
		vivienne.add(1150453, 0.0); //Will it do?
		vivienne.add(1150457, 0.0); //Now, what must I do?
		vivienne.add(1150459, 0.0); //Geralt! Look! Look!
		vivienne.add(1188158, 0.0); //I was clear. It is out of the question!
		vivienne.add(1201932, 0.0); //Is that an ultimatum?
		vivienne.add(1200532, 0.0); //Why?
		vivienne.add(1200678, 0.0); //I understand.
		vivienne.add(1200797, 0.0); //Oh, that's clearly rubbish.
		vivienne.add(1211189, 0.0); //Hah! I find you droll. I had not noticed before.
		vivienne.add(1189430, 0.0); //I don't like it.
		vivienne.add(1181794, 0.0); //I'm not at all fond of that chain you wear. It clashes horribly with my dress.
		vivienne.add(1201758, 0.0); //Personally, I like it.



                zoltan = createOnelinerElement('zoltan_chivay');
                zoltan.add(491419, 0.0); //Ah, reminds me of our days of yore, eh?
                zoltan.add(1038336, 0.0); //Ugh. Ehh, you've a soft heart after all, Geralt.
                zoltan.add(514003, 0.0); //Ooh, yes.
                zoltan.add(1039684, 0.0); //Oh, by the by, splendid job with that last one. Blood splatter nearly hit the ceilin'.
                zoltan.add(569547, 0.0); //Psst! Geralt! Over here!
                zoltan.add(496042, 0.0); //Ooh… not good.
                zoltan.add(491759, 0.0); //No, no, no! That's exactly what we're lookin' for!
                zoltan.add(497251, 0.0); //And you figure that's unnatural because…?
                zoltan.add(181704, 0.0); //Guess old flames never die.
                zoltan.add(491709, 0.0); //I'm pleased. That went well.
                zoltan.add(437364, 0.0); //A few bruises and a torn doublet…
                zoltan.add(526118, 0.0); //Sounds like you've found somethin' out…
                zoltan.add(437386, 0.0); //Ach, that makes it clear as crystal!
                zoltan.add(328286, 0.0); //Must ye always? This'll be true poetry, Geralt. You'll see.
                zoltan.add(512194, 0.0); //Fuck off, Geralt. Need to spill your guts to me, now.
		zoltan.add(496101, 0.0); //We've a wee problem, then…
		zoltan.add(496080, 0.0); //Hah! Like to know that meself! Maybe he could explain what the hell's goin' on!
		zoltan.add(489455, 0.0); //Heheh… I sorely regret not seein' that!
		zoltan.add(491812, 0.0); //Aye. Must've been in a great rush to leave it behind.
                zoltan.add(1042340, 0.0); //Back in Mahakam we'd send sowbuggers like that down the coalface with a bundle o' powder and a leaky lamp.
                zoltan.add(1037350, 0.0); //So… when're we gonna go noodlin' for catfish?
                zoltan.add(1042407, 0.0); //Ugh, uck, shite. Disgustin' fellow. To think I shook hands with 'im…
                zoltan.add(1042411, 0.0); //Ach, if ye say so…
                zoltan.add(1075771, 0.0); //Triss ought to know.
                zoltan.add(1041989, 0.0); //You know me, Geralt. I'm not prejudiced against anyone. Long as they pay.
                zoltan.add(561932, 0.0); //Ahh, understood, free hooch'll tempt any man. But Geralt… you realize this is a wee bit risky…?
                zoltan.add(561974, 0.0); //Don't get caught… It'd be a cryin' shame to waste that much Mahakaman…
                zoltan.add(1062194, 0.0); //Here we are.
                zoltan.add(1035072, 0.0); //You got them?
                zoltan.add(1038737, 0.0); //Fuck, bugger musta sold them!
                zoltan.add(1039177, 0.0); //You betcha!
                zoltan.add(561929, 0.0); //What should I do?
                zoltan.add(562668, 0.0); //Had to hold 'em back… through conventional means.
                zoltan.add(1074871, 0.0); //Plan to top that by brewin' some more Mahakaman mix. Shite's so volatile, ye need but glance at it to set it off like a flamin' fart. Very useful durin' sieges.
                zoltan.add(520435, 0.0); //I brought this Mahakaman mix - flammable as bone dry saltpeter and ploughin' sticks to anythin'.
                zoltan.add(522285, 0.0); //I never refuse.
                zoltan.add(502000, 0.0); //Tall… Fat… Dangerous as hell.
                zoltan.add(503815, 0.0); //I feel relieved.
                zoltan.add(486667, 0.0); //Wouldn't be so quick to assume. Got a feelin' it could be a decent fellow.
                zoltan.add(486321, 0.0); //Ehh, I suppose you're right.
                zoltan.add(578973, 0.0); //I might believe you if you showed me a pair of monogrammed batiste galligaskins.
                zoltan.add(575617, 0.0); //Your heart might, true… but the rest of your anatomy…
                zoltan.add(418594, 0.0); //Probably better off not. Things 'tween them took a turn for the strange at some point…
                zoltan.add(531747, 0.0); //Well, you've had a busy morn, then, haven't you…
                zoltan.add(495713, 0.0); //See her in your dreams?
                zoltan.add(491934, 0.0); //Keep forgettin' he's got that damn fool name.
                zoltan.add(181756, 0.0); //Argh, doubt it. Former pupil, and, well, the tales he told me 'bout her…
                zoltan.add(354883, 0.0); //Errr, not without reason… Never been much for elven women meself, but this one's exceptional. Dare say Francesca Findabair'd be jealous.
                zoltan.add(418802, 0.0); //You see… elven beauty's like a young Beauclair wine. Whereas I prefer vodka straight up.
                zoltan.add(499126, 0.0); //Sure you know me that well? Mark my words, she'll be playin' gwent with us in no time.
                zoltan.add(514002, 0.0); //She's his match, all right - maybe more.
                zoltan.add(503790, 0.0); //I, uh… just thought you might want to see…
                zoltan.add(1071547, 0.0); //Next time I mention card tradin', be sure and bop me in the head.
                zoltan.add(1038495, 0.0); //Hah, no man knows. You'll be the first to see it.
                zoltan.add(1039603, 0.0); //Heheheh. We'll wait and see.
                zoltan.add(1039669, 0.0); //I'd recommend a letter.
                zoltan.add(1041607, 0.0); //The exchange - we should do it right quick.
                zoltan.add(492056, 0.0); //No one knows the fruit of the fruit of the vine like Dandelion.
                zoltan.add(497130, 0.0); //Give 'im a chance, might not be that bad.
                zoltan.add(497206, 0.0); //That's what I'm countin' on.
                zoltan.add(1054680, 0.0); //Aye, aye, I'm all ears.
                zoltan.add(1055862, 0.0); //He is. You know 'im?
                zoltan.add(430649, 0.0); //Nah, you can have her.
                zoltan.add(499121, 0.0); //So. How'd you do? Learn much?
                zoltan.add(499220, 0.0); //What're you waitin' for? Let's have at it!
                zoltan.add(437380, 0.0); //What's she supposedly like, this lass?
                zoltan.add(437418, 0.0); //I think he fell in love.
                zoltan.add(499279, 0.0); //The laddie's head's on fire. Lassy's got him whirlin'.



		geraltVesemirConvo = createConversationElement();
		geraltVesemirConvo.r('vesemir'); //Required Actors
		geraltVesemirConvo.append('PLAYER', 533007, 1.1); //Got the buckthorn.
		geraltVesemirConvo.append('vesemir', 533008, 4.6); //Oughta work like a charm. Powerful scent.
		geraltVesemirConvo.append('PLAYER', 533091, 1.5); //More like stench.
		geraltVesemirConvo.append('vesemir', 565214, 0.0); //City boy. Rotting meat, manure, piss - standard smells of the countryside.

		geraltVesemirConvo = createConversationElement();
		geraltVesemirConvo.r('vesemir'); //Required Actors
		geraltVesemirConvo.append('vesemir', 565261, 7.6); //Remember Tretogor, hunting that zeugl in the trash heap? You spent half the next day bathing, scrubbing yourself.
		geraltVesemirConvo.append('PLAYER', 565216, 0.0); //How can I forget? You ever gonna stop bringing that up?

		geraltVesemirConvo = createConversationElement();
		geraltVesemirConvo.r('vesemir'); //Required Actors
		geraltVesemirConvo.append('vesemir', 1046237, 5.2); //Speaking of winter, and wintering - think you'll come this year?
		geraltVesemirConvo.append('PLAYER', 565621, 0.0); //Maybe. Might bring a guest.

		geraltVesemirConvo = createConversationElement();
		geraltVesemirConvo.r('vesemir'); //Required Actors
		geraltVesemirConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.

		geraltVivienneConvo = createConversationElement();
		geraltVivienneConvo.r('sq701_vivienne'); //Required Actors
		geraltVivienneConvo.append('sq701_vivienne', 1201907, 8.0); //I've heard there are beautiful flying sirens there. And mountains that rise out of the sea into the sky. Is any of it true?
		geraltVivienneConvo.append('PLAYER', 1201909, 0.0); //It all is, actually. Except you'll want to watch out for the sirens. As beautiful as they are dangerous.

		geraltVivienneConvo = createConversationElement();
		geraltVivienneConvo.r('sq701_vivienne'); //Required Actors
		geraltVivienneConvo.append('PLAYER', 1002747, 0.0); //Stay calm.

		geraltVivienneConvo = createConversationElement();
		geraltVivienneConvo.r('sq701_vivienne'); //Required Actors
		geraltVivienneConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.

                geraltZoltanConvo = createConversationElement();
                geraltZoltanConvo.r('zoltan_chivay'); //Required Actors
		geraltZoltanConvo.append('zoltan_chivay', 562677, 4.0); //By-the-by, goin' back with me, or got aught to do along the way?
		geraltZoltanConvo.append('PLAYER', 537208, 0.0); //Always up for a ride with you.

                geraltZoltanConvo = createConversationElement();
                geraltZoltanConvo.r('zoltan_chivay'); //Required Actors
		geraltZoltanConvo.append('PLAYER', 1062196, 1.8); //Thanks again for your help, Zoltan.
		geraltZoltanConvo.append('zoltan_chivay', 1062198, 0.0); //Always willin', mate.

                geraltZoltanConvo = createConversationElement();
                geraltZoltanConvo.r('zoltan_chivay'); //Required Actors
		geraltZoltanConvo.append('PLAYER', 562984, 0.0); //Let's get this over with.
	}
	
	public function UpdateDialogues()
	{
		var linerOrConvo, selected : int;
		var i, sz : int;
		
		var validTalks : array<mod_scm_SpecialNPCDialogueClazzBase>;
		
		linerOrConvo = RandRange(1000, 0);
		
		LogChannel('ModSpawnCompanions', "New Dialogue?");
		
		if(linerOrConvo < 940)
		{
			sz = oneliners.Size();
			for(i = 0; i < sz; i+=1)
			{
				if(oneliners[i].isValid())
				{
					validTalks.PushBack(oneliners[i]);
				}
			}
		}
		else
		{
			sz = conversations.Size();
			for(i = 0; i < sz; i+=1)
			{
				if(conversations[i].isValid())
				{
					validTalks.PushBack(conversations[i]);
				}
			}
		}
		
		if(validTalks.Size() > 0)
		{
			LogChannel('ModSpawnCompanions', "Trying to talk?");
			selected = RandRange(validTalks.Size(), 0);
			validTalks[selected].perform();
		}
		else
		LogChannel('ModSpawnCompanions', "No Valid Talks");
	
		/*
		var followingNPCs : array<CNewNPC>;
		var size : int;
		var i : int;
		
		var ciri : CNewNPC;
		var triss : CNewNPC;
		var yen : CNewNPC;
		
		var randInt : int;
		var thisMod : mod_scm;
		var chats : array<mod_scm_NPCChatElement>;
		var valids : int;
		
		thisMod = thePlayer.get_mod_scm();
		
		if(thisMod.talkingCoolDown > 0)
		{
			thisMod.talkingCoolDown -= 1;
		}
		else
		{
			randInt = RandRange(500, 0);
		
			LogChannel('ModSpawnCompanions', "Doing some talking, maybe: " + randInt);
			
			ciri = mod_scm_GetSpecialNPCIfFollowing('mod_scm_cirilla');
			triss = mod_scm_GetSpecialNPCIfFollowing('mod_scm_triss');
			yen = mod_scm_GetSpecialNPCIfFollowing('mod_scm_yennefer');

			if(randInt < 100)
			{
				LogChannel('ModSpawnCompanions', "Do random talk GO");
				
				valids = 1;
				if(ciri) valids += 1;
				if(triss) valids += 1;
				if(yen) valids += 1;
				
				if(ciri && RandRange(valids-=1, 0) == 0)
				{
					chats = thisMod.ciriChats;
					size = thisMod.ciriChatsSize;
				}
				else if(triss && RandRange(valids-=1, 0) == 0)
				{
					chats = thisMod.trissChats;
					size = thisMod.trissChatsSize;
				}
				else if(yen && RandRange(valids-=1, 0) == 0)
				{
					chats = thisMod.yenChats;
					size = thisMod.yenChatsSize;
				}

				if(size > 0)
				{
					randInt = RandRange(size, 0);
					thePlayer.mod_scm_QueueNPCChat(chats[randInt]);
					thisMod.talkingCoolDown = 8;
				}
				else
				{
					LogChannel('ModSpawnCompanions', "No text found");
				}
			}
			else if(randInt < 104)
			{
				randInt = RandRange(1, 0);
				
				switch(randInt)
				{
				case 0: {if(triss && yen){chats = thisMod.conversation_triss_yen;}} break;
				}
				
				if(chats.Size() > 0)
				{
					size = chats.Size();
					for(i = 0; i < size; i+=1)
					{
						thePlayer.mod_scm_QueueNPCChat(chats[i]);	
					}
					
					thisMod.talkingCoolDown = 10;
				}
			}
		}*/
	}
}
