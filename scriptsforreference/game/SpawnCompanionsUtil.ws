/*
Copyright © CD Projekt RED & Jamezo97 2017
*/

function MCM_VecToStringPrec(vec : Vector, precision : int) : string
{
	return FloatToStringPrec(vec.X, precision) + ", " + FloatToStringPrec(vec.Y, precision) + ", " + FloatToStringPrec(vec.Z, precision);
}

function MCM_EulerToStringPrec(vec : EulerAngles, precision : int) : string
{
	return FloatToStringPrec(vec.Pitch, precision) + ", " + FloatToStringPrec(vec.Yaw, precision) + ", " + FloatToStringPrec(vec.Roll, precision);
}

class mod_scm_NameMap
{
	private var keys : array<name>;
	private var values : array<name>;
	
	public function put(key : name, value : name)
	{
		var index : int;
		index = getKeyIndex(key);
		
		if(index >= 0)
		{
			values[index] = value;
		}
		else
		{
			keys.PushBack(key);
			values.PushBack(value);	
		}
	}
	
	public function containsKey(key : name) : bool
	{
		return getKeyIndex(key) >= 0;
	}
	
	public function get(key : name) : name
	{
		var index : int;
		
		index = getKeyIndex(key);
		
		if(index >= 0)
		{
			return values[index];
		}
		
		return '';
	}
	
	public function remove(key : name) : name
	{
		var index : int;
		var temp : name;
		
		index = getKeyIndex(key);
		
		if(index >= 0)
		{
			temp = values[index];
			
			keys.Erase(index);
			values.Erase(index);
		}
		
		return temp;
	}
	
	private function getKeyIndex(key : name) : int
	{
		var i, size : int;
		size = keys.Size();
		for(i = 0; i < size; i+=1)
		{
			if(keys[i] == key)
			{
				return i;
			}
		}
		return -1;
	}
}

struct SCMEntityEntry
{
	var path : String;
	var entName : String;
	var appearances : array<String>;
}

function LoadSCMData()
{
	var entries : array<SCMEntityEntry>;

	var data : C2dArray;
	var i : int;

	var lastDLCName, lastNPCType, lastResourceLoc : String;
	var DLCName, NPCType, ResourceLoc, Appearance : String;
	
	var lastSCMEntityStruct : SCMEntityEntry;
	
	data = LoadCSV("dlc\mod_spawn_companions\spawncompanions_ents.csv");
					
	for (i = 0; i < data.GetNumRows(); i += 1)
	{
		DLCName = data.GetValueAt(0, i);
		NPCType = data.GetValueAt(1, i);
		ResourceLoc = data.GetValueAt(2, i);
		Appearance = data.GetValueAt(3, i);
		
		if(StrLen(DLCName) > 0 || StrLen(NPCType) > 0 || StrLen(ResourceLoc) > 0)
		{
			lastSCMEntityStruct = SCMEntityEntry();
			lastSCMEntityStruct.path = ResourceLoc;
			lastSCMEntityStruct.entName = DLCName;
		}
		
		lastSCMEntityStruct.appearances.PushBack(Appearance);
	}
}

class mod_scm_NameMapper
{
	var nameMap : mod_scm_NameMap;
	private var nameMapCreated : bool; default nameMapCreated = false;
	
	private var keys : array<name>;
	private var values : array<name>;
	
	private var keysNice : array<name>;
	private var valuesNice : array<name>;
	
	private function put(key : name, value : name)
	{
		keys.PushBack(key);
		values.PushBack(value);
		//LogChannel('ModSpawnCompanions', "Mapped " + NameToString(key) + " to " + NameToString(value));
	}

	public function init()
	{
		if(!nameMapCreated)
		{
			nameMapCreated = true;
			nameMap = new mod_scm_NameMap in this;
			LogSCM("Creating name mappings...");
			populateNameMap();
			populateNiceNameMap();
			LogSCM("Finished creating name mappings");
		}
	}
	
	public function getNiceName(nam : name) : name
	{
		var i, sz : int;
		sz = valuesNice.Size();
		
		for(i = 0; i < sz; i+=1)
		{
			if(keysNice[i] == nam)
			{
				return valuesNice[i];
			}
		}
		return nam;
	}
	
	public function convert(nam : name) : name
	{
		var i, sz : int;
		sz = values.Size();
		
		LogChannel('ModSpawnCompanions', "Converting: " + NameToString(nam));
		
		for(i = 0; i < sz; i+=1)
		{
			if(keys[i] == nam)
			{
				LogChannel('ModSpawnCompanions', "Found: " + NameToString(values[i]));
				return values[i];
			}
		}
	
		LogChannel('ModSpawnCompanions', "Nothing Found");
		return nam;
	}
	
	private function p(value : name, optional key1, key2, key3, key4, key5, key6, key7, key8, key9, key10 : name)
	{
		put(value, value);
		if(key1 != '') put(key1, value);
		if(key2 != '') put(key2, value);
		if(key3 != '') put(key3, value);
		if(key4 != '') put(key4, value);
		if(key5 != '') put(key5, value);
		if(key6 != '') put(key6, value);
		if(key7 != '') put(key7, value);
		if(key8 != '') put(key8, value);
		if(key9 != '') put(key9, value);
		if(key10 != '') put(key10, value);
	}
	
	private function n(niceName : name, notNiceName : name)
	{
		keysNice.PushBack(notNiceName);
		valuesNice.PushBack(niceName);
	}
	
	private function populateNiceNameMap()
	{
                n('Avallach', 'avallach');
                n('Baron', 'baron');
		n('Bart', 'bart_the_troll');
                n('Cerys', 'becca');
		n('Ciri', 'cirilla');
                n('Corinne Tilly', 'dreamer_corine_tilly');
		n('Crach an Craite', 'crach_an_craite');
		n('Cyprian Wiley', 'cyprian_willey');
		n('Dandelion', 'dandelion');
                n('Dijkstra', 'dijkstra');
                n('Emhyr var Emreis', 'emhyr');
                n('Ermion', 'mousesack');
                n('Eskel', 'eskel');
                n('Fringilla Vigo', 'fringilla_vigo');
                n('Gaetan', 'mq1058_lynx_witcher');
		n('Graden', 'graden');
                n('Hattori', 'hattori');
                n('Hjalmar', 'hjalmar');
		n('Jad Karadin', 'sq106_tauler');
                n('Joachim von Gratz', 'von_gratz');
		n('Johnny', 'godling_johnny');
                n('Keira Metz', 'keira_metz');
                n('King of Beggars', 'king_beggar');
                n('Lambert', 'lambert');
                n('Letho', 'letho');
                n('Margarita', 'margarita');
                n('Mislav', 'q002_huntsman');
		n('Morvran Voorhis', 'voorhis');
                n('Philippa Eilhart', 'philippa_eilhart');
                n('Priscilla', 'pryscilla');
                n('Radovid', 'radovid');
                n('Rosa var Attre', 'rosa_var_attre');
                n('Salma', 'mh303_succbus_v2');
		n('Sasha', 'sq306_sacha');
                n('Tamara', 'tamara');
                n('Thaler', 'talar');
                n('Triss', 'triss');
		n('Udalryk', 'udalryk');
                n('Vernon Roche', 'vernon_roche');
                n('Ves', 'ves');
		n('Vesemir', 'vesemir');
                n('White Wolf', 'wolf_white_lvl3__alpha');
		n('Yennefer', 'yennefer');
		n('Zoltan Chivay', 'zoltan_chivay');

		n('Casimir', 'q603_demolition_dwarf_companion');
		n('Eveline', 'q603_circus_artist_companion');
		n('Ewald Borsodi', 'ewald');
		n('Gaunter O Dimm', 'mr_mirror_ep1');
                n('Iris', 'iris');
                n('Olgierd von Everec', 'olgierd');
		n('Quinto', 'q603_safecracker_companion');
		n('Shani', 'shani');
		
		n('Anna Henrietta', 'anna_henrietta');
		n('Baron Palmerin de Launfal', 'palmerin');
		n('Blacksmith', 'shop_17_belgard_wine_blacksmith');
		n('Damien', 'damien');
                n('Dettlaff', 'dettlaff_van_eretein_vampire');
                n('Guillaume', 'guillaume');
		n('Gregoire de Gorgon', 'sq701_gregoire');
                n('Lady of the Lake', 'mq7006_lady_of_the_lake');
		n('Majordomo', 'butler');
		n('Milton de Peyrac Peyran', 'milton_de_peyrac');
		n('Orianna', 'vampire_diva');
		n('Regis', 'regis_terzieff_vampire');
		n('Syanna', 'syanna');
		n('Vivienne', 'sq701_vivienne');
                n('Witch of Lynx Crag', 'mq7004_witch');
	}
	
	private function populateNameMap()
	{
                p('avallach', 'Avallach');
		p('baron', 'Baron');
		p('bart_the_troll', 'Bart');
		p('becca', 'Becca', 'cerys', 'Cerys');
                p('cirilla', 'Ciri');
		p('crach_an_craite', 'Crach an Craite');
		p('cyprian_willey', 'Cyprian Wiley');
		p('dandelion', 'Dandelion');
                p('dijkstra', 'Dijkstra');
                p('dreamer_corine_tilly', 'Corinne Tilly', 'corine_tilly', 'Corine', 'corine');
                p('emhyr', 'Emhyr var Emreis');
		p('eskel', 'Eskel');
                p('fringilla_vigo', 'Fringilla', 'fringilla');
		p('godling_johnny', 'Johnny');
		p('graden', 'Graden');
		p('hattori', 'Hattori');
		p('hjalmar', 'Hjalmar');
		p('keira_metz', 'Keira Metz', 'keira', 'Keira');
                p('king_beggar', 'King of Beggars');
                p('lambert', 'Lambert');
                p('letho', 'Letho');
                p('margarita', 'Margarita');
                p('mh303_succbus_v2', 'Salma', 'salma');
		p('mousesack', 'Mousesack', 'ermion', 'Ermion', 'druid', 'Druid');
		p('mq1058_lynx_witcher', 'Gaetan');
                p('philippa_eilhart', 'Philippa Eilhart', 'philippa', 'Philippa', 'eilhart', 'Eilhart');
                p('pryscilla', 'Priscilla');
                p('q002_huntsman', 'Mislav');
                p('radovid', 'Radovid', 'king', 'King');
                p('rosa_var_attre', 'Rosa var Attre');
		p('sq306_sacha', 'Sasha');
		p('sq106_tauler', 'Jad Karadin');
                p('talar', 'Thaler');
                p('tamara', 'Tamara');
                p('triss', 'Triss', 'merigold', 'Merigold');
		p('udalryk', 'Udalryk');
                p('vernon_roche', 'Vernon_Roche', 'roche', 'Roche');
                p('ves', 'Ves');
		p('vesemir', 'Vesemir');
		p('von_gratz', 'Joachim von Gratz');
		p('voorhis', 'Morvran Voorhis');
                p('wolf_white_lvl3__alpha', 'White Wolf');
		p('yennefer', 'Yennefer', 'yen', 'Yen');
		p('zoltan_chivay', 'Zoltan Chivay', 'zoltan', 'Zoltan');

		p('ewald', 'Ewald Borsodi');
                p('iris', 'Iris');
		p('mr_mirror_ep1', 'Gaunter O Dimm');
                p('olgierd', 'Olgierd von Everec');
		p('q603_circus_artist_companion', 'Eveline');
		p('q603_demolition_dwarf_companion', 'Casimir');
		p('q603_safecracker_companion', 'Quinto');
                p('shani', 'Shani');
		
		p('anna_henrietta', 'Anna Henrietta', 'henrietta', 'Henrietta');
                p('butler', 'Majordomo');
		p('damien', 'Damien');
		p('dettlaff_van_eretein_vampire', 'Dettlaff');
                p('guillaume', 'Guillaume');
		p('milton_de_peyrac', 'Milton de Peyrac Peyran');
		p('mq7006_lady_of_the_lake', 'Lady of the Lake', 'lady_of_the_lake');
                p('mq7004_witch', 'Witch of Lynx Crag', 'witch_of_lynx_crag', 'LynxWitch', 'lynxcrag');
                p('palmerin', 'Baron Palmerin de Launfal');
		p('regis_terzieff_vampire', 'Regis');
		p('shop_17_belgard_wine_blacksmith', 'Blacksmith');
		p('sq701_gregoire', 'Gregoire de Gorgon');
		p('sq701_vivienne', 'Vivienne');
		p('syanna', 'Syanna');
		p('vampire_diva', 'Orianna');
	}
}

/*class CAICompanionFollow extends IAIBaseAction
{
	editable inlined var params : CAICompanionFollowParams;
	
	default aiTreeName = "resdef:ai\scripted_actions/follow";

	function Init()
	{
		params = new CAICompanionFollowParams in this;
		params.moveType = MT_Sprint;
		params.OnCreated();
		customSteeringGraph = LoadSteeringGraph("gameplay/behaviors/npc/steering/action/follow_side_by_side.w2steer");
	}
	
	public function ReInit()
	{
		params.OnCreated();
	}
	
	editable var useCustomSteering : bool; default useCustomSteering = true;
	editable var customSteeringGraph : CMoveSteeringBehavior;
};

class CAICompanionFollowParams extends IAIActionParameters
{
	editable var targetTag : CName;
	editable var moveType : EMoveType;
	editable var keepDistance : bool;
	editable var followDistance : float;
	editable var moveSpeed : float;
	editable var followTargetSelection : bool;
	editable var teleportToCatchup : bool;
	editable var cachupDistance : float;
	editable var rotateToWhenAtTarget : bool;
	
	default targetTag = "PLAYER";
	default moveType = MT_Sprint;
	default keepDistance = true;
	default followDistance = 7.0;
	default moveSpeed = 2.5;
	default followTargetSelection = true;
	default teleportToCatchup = true;
	default cachupDistance = 30.0;
	default rotateToWhenAtTarget = true;
	
	hint rotateToWhenAtTarget = "After reaching the follow distance, NPC will rotate towards the targets";
	
	function Init()
	{
		super.Init();
	}
};*/
