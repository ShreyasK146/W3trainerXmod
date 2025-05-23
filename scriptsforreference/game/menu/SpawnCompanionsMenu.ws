/*
class SCM_MenuTest extends SCMMenu_Elements
{
	protected function OnMenuCreated()
	{
		AddText('spawncompanions', true, "Spawn Companion", COLOUR_SUB_MENU);
		AddText('listcompanions', true, "List Companions", COLOUR_SUB_MENU);
		AddCounter('count', "Count: ", 50, 10, 75);
	}

	public function OnChange(element : SCMMenu_BaseElement)
	{
		switch(element.ID)
		{
			case 'spawncompanions': OpenSpawnCompanionSpecialMenu(); break;
			case 'listcompanions': OpenCompanionListSpecialMenu(); break;
		}
		window.UpdateAndRefresh();
	}

	var spawnSpecialMenu : SCMSpawnMenu;
	private function OpenSpawnCompanionSpecialMenu()
	{
		if(!this.spawnSpecialMenu)
		{
			this.spawnSpecialMenu = new SCMSpawnMenu in this;
			this.spawnSpecialMenu.COMPANION_TYPE = ST_Special;
		}
		this.window.OpenMenu(this.spawnSpecialMenu);
	}

	var listSpecialMenu : SCMMenuListCompanions;
	private function OpenCompanionListSpecialMenu()
	{
		if(!this.listSpecialMenu)
		{
			this.listSpecialMenu = new SCMMenuListCompanions in this;
			this.listSpecialMenu.COMPANION_TYPE = ST_Special;
		}
		this.window.OpenMenu(this.listSpecialMenu);
	}

	public function GetName() : String
	{
		return "Main Menu";
	}
}

	//public function AddText(id : name, clickable : bool, text : String, optional colour : String)
	//public function AddCounter(id : name, start, min, max : int)

//==================================================================================
//
//					MAIN MENU
//
//==================================================================================

class SCMMenuMain2 extends SCMMenu_Elements
{
	public function GetName() : String
	{
		return "Multi Companion Menu";
	}

	protected function OnMenuCreated()
	{
		AddText('spawnspecial', true, "Spawn Special Companion", COLOUR_SUB_MENU);
		AddText('listspecial', true, "List Special Companion", COLOUR_SUB_MENU);
		AddText('spacer1', false, "------------", COLOUR_DISABLED);
		AddText('spawnnormal', true, "Spawn Normal Companion", COLOUR_SUB_MENU);
		AddText('listnormal', true, "List Normal Companion", COLOUR_SUB_MENU);
		AddText('spacer2', false, "------------", COLOUR_DISABLED);
		AddText('spawnother', true, "Spawn Other", COLOUR_SUB_MENU);
		AddText('commands', true, "Commands", COLOUR_SUB_MENU);
		AddText('options', true, "Options", COLOUR_SUB_MENU);
		AddText('spacer3', false, "------------", COLOUR_DISABLED);
		AddText('close', true, "Close Menu", COLOUR_SUB_MENU_SPECIAL);
	}

	public function OnChange(element : SCMMenu_BaseElement)
	{
		switch(element.ID)
		{
			case 'spawnspecial': OpenSpawnCompanionSpecialMenu(); break;
			case 'listspecial': OpenCompanionListSpecialMenu(); break;
			case 'spawnnormal': OpenSpawnCompanionNormalMenu(); break;
			case 'listnormal': OpenCompanionListNormalMenu(); break;
			case 'spawnother': OpenSpawnOtherMenu(); break;
			case 'commands': OpenCommandsMenu(); break;
			case 'options': OpenOptionsMenu(); break;
			case 'close': window.CloseMenu(); break;
		}
	}

	public function selectLeft(optional rapid : bool)
	{
		if(!elements[selectedIndex].selectLeft(rapid))
		{
			if(elements[selectedIndex].ID == 'close')
			{
				window.CloseMenu();
			}
			else
			{
				window.PlayDeniedSound();
			}
		}
	}

	//:::Open Menu Functions:::

	var spawnOtherMenu : SCMSpawnOtherMenu;
	private function OpenSpawnOtherMenu()
	{
		if(!this.spawnOtherMenu) this.spawnOtherMenu = new SCMSpawnOtherMenu in this;
		this.window.OpenMenu(this.spawnOtherMenu);
	}

	var commandMenu : SCMCommandMenu;
	private function OpenCommandsMenu()
	{
		if(!this.commandMenu) this.commandMenu = new SCMCommandMenu in this;
		this.window.OpenMenu(this.commandMenu);
	}
	
	var optionsMenu : SCMOptionsMenu;
	private function OpenOptionsMenu()
	{
		if(!this.optionsMenu) this.optionsMenu = new SCMOptionsMenu in this;
		this.window.OpenMenu(this.optionsMenu);
	}
	
	var spawnSpecialMenu : SCMSpawnMenu2;
	private function OpenSpawnCompanionSpecialMenu()
	{
		if(!this.spawnSpecialMenu)
		{
			this.spawnSpecialMenu = new SCMSpawnMenu2 in this;
			this.spawnSpecialMenu.COMPANION_TYPE = ST_Special;
		}
		this.window.OpenMenu(this.spawnSpecialMenu);
	}

	var spawnNormalMenu : SCMSpawnMenu2;
	private function OpenSpawnCompanionNormalMenu()
	{
		if(!this.spawnNormalMenu)
		{
			this.spawnNormalMenu = new SCMSpawnMenu2 in this;
			this.spawnNormalMenu.COMPANION_TYPE = ST_Normal;
		}
		this.window.OpenMenu(this.spawnNormalMenu);
	}

	var listSpecialMenu : SCMMenuListCompanions;
	private function OpenCompanionListSpecialMenu()
	{
		if(!this.listSpecialMenu)
		{
			this.listSpecialMenu = new SCMMenuListCompanions in this;
			this.listSpecialMenu.COMPANION_TYPE = ST_Special;
		}
		this.window.OpenMenu(this.listSpecialMenu);
	}

	var listNormalMenu : SCMMenuListCompanions;
	private function OpenCompanionListNormalMenu()
	{
		if(!this.listNormalMenu)
		{
			this.listNormalMenu = new SCMMenuListCompanions in this;
			this.listNormalMenu.COMPANION_TYPE = ST_Normal;
		}
		this.window.OpenMenu(this.listNormalMenu);
	}
}

class SCMMenuMain extends SCMMenu_StringList
{
	protected function OnMenuCreated()
	{
		nl("Spawn Special Companion");
		nl("List Special Companions");
		nl("------------");
		nl("Spawn Normal Companion");
		nl("List Normal Companions");
		nl("------------");
		nl("Commands");
		nl("Options");
		nl("------------");
		nl("Close Menu");
	}
	
	public function IsValidSelection(index : int) : bool
	{
		switch(index)
		{
			case 2:
			case 5:
			case 8: return false;
		}
		return true;
	}

	public function GetColour(index : int) : String
	{
		switch(index)
		{
			case 2:
			case 5:
			case 8: return COLOUR_DISABLED;
			case 9: return COLOUR_SUB_MENU_SPECIAL;
		}
		return COLOUR_SUB_MENU;
	}
	
	public function GetName() : String
	{
		return "Multi Companion Menu";
	}
	
	public function selectLeft(optional rapid : bool)
	{
		if(this.selectedIndex == 6)
		{
			window.CloseMenu();
		}
		else
		{
			window.PlayDeniedSound();
		}
	}
		
	public function selectEnter(optional rapid : bool)
	{
		switch(selectedIndex)
		{
			case 0: OpenSpawnCompanionSpecialMenu(); break;
			case 1: OpenCompanionListSpecialMenu(); break;
			case 3: OpenSpawnCompanionNormalMenu(); break;
			case 4: OpenCompanionListNormalMenu(); break;
			case 6: OpenCommandsMenu(); break;
			case 7: OpenOptionsMenu(); break;
			case 9: window.CloseMenu(); break;
		}
	}

	//:::Open Menu Functions:::
	
	var commandMenu : SCMCommandMenu;
	private function OpenCommandsMenu()
	{
		if(!this.commandMenu) this.commandMenu = new SCMCommandMenu in this;
		this.window.OpenMenu(this.commandMenu);
	}
	
	var optionsMenu : SCMOptionsMenu;
	private function OpenOptionsMenu()
	{
		if(!this.optionsMenu) this.optionsMenu = new SCMOptionsMenu in this;
		this.window.OpenMenu(this.optionsMenu);
	}
	
	var spawnSpecialMenu : SCMSpawnMenu2;
	private function OpenSpawnCompanionSpecialMenu()
	{
		if(!this.spawnSpecialMenu)
		{
			this.spawnSpecialMenu = new SCMSpawnMenu2 in this;
			this.spawnSpecialMenu.COMPANION_TYPE = ST_Special;
		}
		this.window.OpenMenu(this.spawnSpecialMenu);
	}

	var spawnNormalMenu : SCMSpawnMenu2;
	private function OpenSpawnCompanionNormalMenu()
	{
		if(!this.spawnNormalMenu)
		{
			this.spawnNormalMenu = new SCMSpawnMenu2 in this;
			this.spawnNormalMenu.COMPANION_TYPE = ST_Normal;
		}
		this.window.OpenMenu(this.spawnNormalMenu);
	}

	var listSpecialMenu : SCMMenuListCompanions;
	private function OpenCompanionListSpecialMenu()
	{
		if(!this.listSpecialMenu)
		{
			this.listSpecialMenu = new SCMMenuListCompanions in this;
			this.listSpecialMenu.COMPANION_TYPE = ST_Special;
		}
		this.window.OpenMenu(this.listSpecialMenu);
	}

	var listNormalMenu : SCMMenuListCompanions;
	private function OpenCompanionListNormalMenu()
	{
		if(!this.listNormalMenu)
		{
			this.listNormalMenu = new SCMMenuListCompanions in this;
			this.listNormalMenu.COMPANION_TYPE = ST_Normal;
		}
		this.window.OpenMenu(this.listNormalMenu);
	}
}

//==================================================================================
//
//					LIST CURRENT COMPANIONS
//
//==================================================================================

class SCMMenuListCompanions extends SCMMenuBase
{
	//theCamera.WorldVectorToViewRatio( targetPos, targetCoord.X, targetCoord.Y );
	public editable var COMPANION_TYPE : ESCMSelectionType; default COMPANION_TYPE = ST_Both;
	
	private var companions : array<CNewNPC>;
	private var fxName_long : name; default fxName_long = 'axii_confusion';
	private var fxName_short : name; default fxName_short = 'hit_electric';
	public function ItemCount() : int
	{
		return companions.Size();
	}
	
	public function GetItem(index : int) : String
	{
		return companions[index].scmcc.data.niceName + "(" + VecDistance(thePlayer.GetWorldPosition(), companions[index].GetWorldPosition()) + "m)";
	}

	protected function OnMenuCreated()
	{
		companions.Clear(); 
		mod_scm_GetNPCs(companions, 'GeraltsBFF', COMPANION_TYPE, true);
		if(companions.Size() > 0)
		{
			companions[selectedIndex].PlayEffect(fxName_long);
			companions[selectedIndex].PlayEffect(fxName_short);
		}
	}

	public function onSelectionChanged(from, to : int)
	{
		companions[from].StopEffect(fxName_long);
		companions[to].PlayEffect(fxName_long);
		companions[to].PlayEffect(fxName_short);
	}
	
	public function OnMenuOpened()
	{
		OnMenuCreated();
		if(selectedIndex < 0) selectedIndex = 0;

		if(selectedIndex >= companions.Size())
		{
			selectedIndex = companions.Size() - 1;
		}
	}

	public function OnMenuClosed()
	{
		if(companions[selectedIndex])
		{
			companions[selectedIndex].StopEffect(fxName_long);
		}
	}
	
	public function GetName() : String
	{
		if(COMPANION_TYPE == ST_Special)
		{
			return "List Special Companions";
		}
		else if(COMPANION_TYPE == ST_Normal)
		{
			return "List Normal Companions";
		}

		return "List All Companions";
	}

	public function selectEnter(optional rapid : bool)
	{
		var npc : CNewNPC;
		var newMenu : SCMMenuEditCompanion2;
		npc = companions[this.selectedIndex];
		if(npc)
		{
			newMenu = new SCMMenuEditCompanion2 in this;
			newMenu.COMPANION = npc;
			window.OpenMenu(newMenu);
		}
		else
		{
			window.PlayDeniedSound();
			OnMenuOpened();
		}
	}
}

class SCMMenuEditCompanion extends SCMMenuBase
{
	public editable var COMPANION : CNewNPC;
	var currentScale : float; default currentScale = 1.0;
	var currentScaleEntry : mod_scm_ScaleEntry;
	private var fxName_long : name; default fxName_long = 'axii_confusion';
	
	//Name (Uneditable)
	//Level (Editable)
	public function ItemCount() : int
	{
		return 4;
	}

	function incrementScale(amt : float)
	{
		if(!currentScaleEntry || currentScaleEntry.Destroyed)
		{
			currentScaleEntry = MCM_GetMCM().ScaleManager.SetScale(COMPANION, amt);
			currentScale = amt;
		}
		else
		{
			currentScaleEntry.scaleToReach *= amt;
			currentScale = currentScaleEntry.scaleToReach;
		}
	}
	
	public function GetItem(index : int) : String
	{
		switch(index)
		{
			case 0: return "REMOVE COMPANION";
			case 1: return "Level: " + colr(""+COMPANION.scmcc.data.level, "2299EE");
			case 2: return "Appearance";
			case 3: return "Scale: " + colr("" + currentScale, "2299EE");
		}
		return "Unknown";
	}

	protected function OnMenuCreated()
	{
		var scaleEntry : mod_scm_ScaleEntry;
		scaleEntry = MCM_GetMCM().ScaleManager.GetScaleEntry(COMPANION);
		if(scaleEntry)
		{
			currentScaleEntry = scaleEntry;
			currentScale = scaleEntry.scaleToReach;
		}
	}

	public function GetColour(index : int) : String
	{
		switch(index)
		{
		case 0: return "FF0000";
		case 2: return COLOUR_SUB_MENU;
		}
		return "";
	}
	
	public function GetName() : String
	{
		return "Editing " + COMPANION.scmcc.data.niceName;
	}
	
	private function showAppearanceMenu()
	{
		var newMenu : SCMAppearanceChangeMenu;
		newMenu = new SCMAppearanceChangeMenu in this;
		newMenu.COMPANION = COMPANION;
		window.OpenMenu(newMenu);
	}

	public function selectEnter(optional rapid : bool)
	{
		switch(this.selectedIndex)
		{
		case 0: mod_scm_RemoveNPC(COMPANION); window.CloseMenu(); break;
		case 2: showAppearanceMenu(); break;
		}
	}
	
	public function selectLeft(optional rapid : bool)
	{
		switch(this.selectedIndex)
		{
		case 1: if(COMPANION.scmcc.data.level>1) {COMPANION.scmcc.data.level-=1; window.PlayTickSound();}  break;
		case 3: incrementScale(1.0/1.1); window.PlayTickSound(); break;
		default: selectExit(rapid);
		}
		window.UpdateAndRefresh();
	}

	public function selectRight(optional rapid : bool)
	{
		switch(this.selectedIndex)
		{
		case 1: if(COMPANION.scmcc.data.level< 200) {COMPANION.scmcc.data.level+=1; window.PlayTickSound();}  break;
		case 2: showAppearanceMenu(); break;
		case 3: incrementScale(1.1); window.PlayTickSound(); break;
		}
		window.UpdateAndRefresh();
	}

	public function OnMenuOpened()
	{
		COMPANION.PlayEffect(fxName_long);
	}

	public function OnMenuClosed()
	{
		COMPANION.StopEffect(fxName_long);
	}
}

class SCMSpawnOtherMenu extends SCMMenu_Elements
{
	public var spawnName : String; default spawnName = "Select Entity";
	public var spawnFolder : MCM_FileContainer;
	var spawnCount : int; default spawnCount = 1;
	var spawnLevel : int; default spawnLevel = 10;
	var type : String; default type = "Auto";
	var tmpMessage : String;

	public function GetName() : String
	{
		return "Spawn Other";
	}

	protected function OnMenuCreated()
	{
		AddText('spawnname', true, spawnName, COLOUR_SUB_MENU_SPECIAL);
		AddText('spawn', true, "Spawn", COLOUR_ACTIVATE);
		AddText('spacer1', false, "------------", COLOUR_DISABLED);
		AddCounter('count', "Count: ", 1, 1, 100);
		AddCounter('level', "Level: ", spawnLevel, 1, 1000);
		AddEnum('type', "Type: ", "Auto,Friendly,Hostile,Follower", ",");
		AddText('spacer2', false, "------------", COLOUR_DISABLED);
		AddDoubleButton('remove', "Remove All", "a43535", "ffafaf");
	}

	public function OnMenuOpened()
	{
		var textElement : SCMMenu_TextElement;
		textElement = (SCMMenu_TextElement) this.elements[0];
		textElement.textValue = this.spawnName;
	}

	public function OnChange(element : SCMMenu_BaseElement)
	{
		switch(element.ID)
		{
			case 'spawnname': 	OpenSpawnNameMenu(); return;
			case 'count': 		UpdateCount((SCMMenu_Counter)element); return;
			case 'level': 		UpdateLevel((SCMMenu_Counter)element); return;
			case 'spawn': 		DoSpawn(); break;
			case 'remove':		RemoveAll(); break;
			case 'type':		UpdateType((SCMMenu_Enum)element); break;
		}
		window.UpdateAndRefresh();
	}

	public function UpdateType(enumElement : SCMMenu_Enum)
	{
		this.type = enumElement.GetSelectedEnum();
	}

	private function RemoveAll()
	{
		var npcs : array<CNewNPC>;
		var i : int;
		theGame.GetNPCsByTag('mcm_menuspawn', npcs);

		for(i = npcs.Size()-1; i >= 0; i-=1)
		{
			npcs[i].Destroy();
		}
	}

	var entMenu : SCMEntityNameMenu;
	private function OpenSpawnNameMenu()
	{
		var tmp : SCMEntityNameMenu;
		if(!entMenu) entMenu = new SCMEntityNameMenu in this;
		entMenu.spawnMenu = this;
		tmp = entMenu;
		while(true)
		{
			if(tmp.subMenu)
			{
				window.openMenus.PushBack(tmp);
				tmp = tmp.subMenu;
				tmp.spawnMenu = this;
			}
			else
			{
				break;
			}
		}
		window.OpenMenu(tmp);
	}

	private function UpdateCount(counter : SCMMenu_Counter)
	{
		this.spawnCount = counter.GetCounterValue();
	}

	private function UpdateLevel(counter : SCMMenu_Counter)
	{
		this.spawnLevel = counter.GetCounterValue();
	}

	private function DoSpawn()
	{
		var res : String;
		if(spawnFolder)
		{
			res = spawnFolder.getPathPrepend() + "/" + spawnName;
			LogSCM("Spawning with res " + res);
			doSpawn(res, spawnCount, spawnLevel);
			window.FlashGoodBad(true, 2);
		}
		else
		{
			window.FlashGoodBad(false, 1);
			window.PlayDeniedSound();
		}
		LogSCM("Spawn " + spawnCount + " " + spawnName + " at level " + spawnLevel);
	}

	private function doSpawn(res : String, count : int, level : int, optional appearance : name)
	{
		var npc : CNewNPC;
		var pos : Vector;
		var template : CEntityTemplate;
		var i, j : int;

		var minHealth : float;
		var myHealth : float;
		
		template = (CEntityTemplate)LoadResource(res, true);
		
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
				pos = thePlayer.GetWorldPosition() + VecRingRand(2.f,4.f);
				npc = (CNewNPC)theGame.CreateEntity(template, pos);
				npc.SetLevel(level);
				npc.AddTag('mcm_menuspawn');
				
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

				switch(this.type)
				{
					case "Friendly": {
						npc.SetTemporaryAttitudeGroup( 'friendly_to_player', AGP_Default );
						npc.SetAttitude( thePlayer, AIA_Friendly );
					} break;
					case "Hostile": {
						npc.SetTemporaryAttitudeGroup( 'hostile_to_player', AGP_Default );
						npc.SetAttitude( thePlayer, AIA_Hostile );
					} break;
					case "Follower": {
						npc.SetTemporaryAttitudeGroup( 'player', AGP_Default );
						npc.SetAttitude( thePlayer, AIA_Friendly );
					} break;
				}

				npc.SetImmortalityMode(AIM_None, AIC_Default, true);
				npc.SetImmortalityMode(AIM_None, AIC_Combat, true);
				npc.SetImmortalityMode(AIM_None, AIC_Fistfight, true);
				npc.SetImmortalityMode(AIM_None, AIC_IsAttackableByPlayer, true);
			}
		}
		else
		{
			tmpMessage = colr("Failed to load template", COLOUR_CAREFUL);
			window.PlayDeniedSound();
		}
	}

	public function GetMetaInfo() : String
	{
		var ret : String;
		if(tmpMessage != "")
		{
			ret = tmpMessage;
			tmpMessage = "";
		}
		else
		{
			if(spawnFolder)
			{
				ret = "<font size=\"16\">" + spawnFolder.getPathPrepend() + "</font>";
			}
			else
			{
				ret = "First Select an Entity";
			}
		}
		return ret;
	}
}

class SCMEntityNameMenu extends SCMMenuBase
{
	public var folder : MCM_FileContainer;
	public var spawnMenu : SCMSpawnOtherMenu;
	public var levelDeep : int; default levelDeep = 1;

	protected function OnMenuCreated()
	{
		if(!folder)
		{
			folder = MCM_GetMCM().EntityList.dataB;
		}
	}

	public function OnMenuOpened()
	{

	}

	public function ItemCount() : int
	{
		return folder.children.Size() + folder.files.Size();
	}

	public function GetItem(index : int) : String
	{
		if(index < folder.children.Size())
		{
			return folder.children[index].folderName;
		}
		return folder.files[index-folder.children.Size()];
	}

	public function GetColour(index : int) : String
	{
		if(index < folder.children.Size())
		{
			return COLOUR_SUB_MENU;
		}
		return "";
	}

	public function GetName() : String
	{
		return "Spawn Other";
	}

	public function GetMetaInfo() : String
	{
		return "<FONT size=\"16\">" + folder.getPathPrepend() + "</FONT>";
	}

	private function onFileSelected(fileName : String)
	{
		spawnMenu.spawnName = fileName;
		spawnMenu.spawnFolder = folder;
		window.CloseMenu(levelDeep);
	}

	public var subMenu : SCMEntityNameMenu;
	private function openSubMenu(folder : MCM_FileContainer)
	{
		if(!subMenu) 
		{
			subMenu = new SCMEntityNameMenu in this;
			subMenu.levelDeep = this.levelDeep + 1;
			subMenu.spawnMenu = this.spawnMenu;
		}

		if(subMenu.folder == folder)
		{
			window.OpenMenu(subMenu);
		}
		else
		{
			subMenu.clearSubMenus();
			subMenu.folder = folder;
			subMenu.selectedIndex = 0;
			window.OpenMenu(subMenu);
		}
	}

	private function clearSubMenus()
	{
		if(this.subMenu)
		{
			this.subMenu.clearSubMenus();
		}
		this.subMenu = NULL;
	}

	public function selectEnter(optional rapid : bool)
	{
		if(selectedIndex < folder.children.Size())
		{
			openSubMenu(folder.children[selectedIndex]);
		}
		else
		{
			onFileSelected(folder.files[selectedIndex-folder.children.Size()]);
		}
	}
}

class SCMSpawnMenu2 extends SCMMenuBase
{
	public var title : String; default title = "All";
	public var node : MCM_EntityListNode;
	
	public var COMPANION_TYPE : ESCMSelectionType;

	//public var children : array<MCM_EntityListNode>;
    	//public var values : array<MCM_EntityEntry>;
    	//public var nodeName : String;

	public function ItemCount() : int
	{
		return node.children.Size() + node.values.Size();
	}
	
	public function GetItem(index : int) : String
	{
		if(index < node.children.Size())
		{
			return node.children[index].nodeName;
		}
		return node.values[index-node.children.Size()].displayName;
	}

	public function GetColour(index : int) : String
	{
		if(index < node.children.Size())
		{
			return COLOUR_SUB_MENU;
		}
		return "";
	}

	public function GetMetaInfo() : String
	{
		return colr(this.title, COLOUR_DISABLED);
	}
	
	public function GetName() : String
	{
		if(COMPANION_TYPE == ST_Special)
		{
			return "Spawn Special Companion";
		}
		return "Spawn Normal Companion";
	}

	protected function OnMenuCreated()
	{
		if(!node)
		{
			node = MCM_GetMCM().EntityList.dataA;
		}
	}

	private function openSubMenu(newNode : MCM_EntityListNode)
	{
		var newMenu : SCMSpawnMenu2 = new SCMSpawnMenu2 in this;
		newMenu.node = newNode;
		newMenu.COMPANION_TYPE = this.COMPANION_TYPE;
		newMenu.title = this.title + "/" + newNode.nodeName;

		window.OpenMenu(newMenu);
	}

	private function spawnCompanion(entEntry : MCM_EntityEntry, optional justEditIfPossible : bool)
	{
		var npc : CNewNPC;
		var newMenu : SCMMenuEditCompanion2;

		npc = MCM_SpawnNPCParams(entEntry.nam, entEntry.displayName, entEntry.defaultAppearance, , COMPANION_TYPE==ST_Special, , true);
		if(npc)
		{
			if(npc.scmcc)
			{
				npc.scmcc.PlayTPAnimation();
			}

			newMenu = new SCMMenuEditCompanion2 in this;
			newMenu.COMPANION = npc;
			window.OpenMenu(newMenu);
			
			window.PlaySound("gui_character_buy_skill");
		}
	}

	private function editCompanion(entEntry : MCM_EntityEntry) : bool
	{
		var npc : CNewNPC;
		var newMenu : SCMMenuEditCompanion2;

		npc = mod_scm_GetNPC(entEntry.nam, COMPANION_TYPE, true);
		if(npc)
		{
			if(VecDistanceSquared(npc.GetWorldPosition(), thePlayer.GetWorldPosition()) > 9)
			{
				npc.scmcc.tpToPlayer();
			}

			newMenu = new SCMMenuEditCompanion2 in this;
			newMenu.COMPANION = npc;
			window.OpenMenu(newMenu);
			return true;
		}
		return false;
	}

	public function selectRight(optional rapid : bool)
	{
		if(selectedIndex < node.children.Size())
		{
			openSubMenu(node.children[selectedIndex]);
		}
		else
		{
			if(!editCompanion(node.values[selectedIndex-node.children.Size()]))
			{
				window.PlayDeniedSound();
			}
		}
	}

	public function selectEnter(optional rapid : bool)
	{
		if(selectedIndex < node.children.Size())
		{
			openSubMenu(node.children[selectedIndex]);
		}
		else
		{
			spawnCompanion(node.values[selectedIndex-node.children.Size()]);
		}
	}
}

//==================================================================================
//
//					Spawn Normal Companion Menu
//
//==================================================================================

class SCMSpawnMenu extends SCMMenu_NameList
{
	public var COMPANION_TYPE : ESCMSelectionType;

	protected function OnMenuCreated()
	{
		nl('Ciri');
		nl('Yennefer');
		nl('Triss');
		nl('Keira');
		nl('Philippa');
		nl('Avallach');
		nl('Baron');
		nl('Cerys');
		nl('Crach');
		nl('Dandelion');
		nl('Emhyr');
		nl('Hjalmar');
		nl('Radovid');
		nl('Roche');
		nl('Vesemir');
		nl('Eskel');
		nl('Lambert');
		nl('Corina');
		nl('Fringilla');
		nl('Letho');
		nl('Zoltan');
		nl('Shani');
		nl('Iris');
		nl('Olgierd');
		nl('mirror');
		nl('Anna');
		nl('Regis');
		nl('Syanna');
		nl('Dettlaff');
		nl('Guillaume');
		nl('Palmerin');
		nl('Vivienne');
		nl('ladyofthelake');
		nl('Gaetan');
		nl('LynxWitch');
		nl('Salma');
	}
	
	public function GetName() : String
	{
		if(COMPANION_TYPE == ST_Special)
		{
			return "Spawn Special Companion";
		}
		return "Spawn Normal Companion";
	}

	public function selectRight(optional rapid : bool)
	{
		
	}
	
	public function selectEnter(optional rapid : bool)
	{
		var nam : name;
		var npc : CNewNPC;
		var newMenu : SCMMenuEditCompanion2;
		nam = lines[selectedIndex];
		npc = MCM_SpawnNPCParams(nam, , , , COMPANION_TYPE==ST_Special, , true);
		if(npc)
		{
			if(npc.scmcc)
			{
				npc.scmcc.PlayTPAnimation();
			}
			if(nam == 'Ciri')
			{
				MCM_GetMCM().AsyncActionManager.AddDelayedDialogue(thePlayer, 1075163, 0.1);//Ciri...
				MCM_GetMCM().AsyncActionManager.AddDelayedTpToPlayer(npc, 1);
				MCM_GetMCM().AsyncActionManager.AddDelayedDialogue(npc, 480615, 1.5);//Ready?...
				npc.Teleport(Vector(0, 1000, 0));
			}
			if(nam == 'Yennefer')
			{
				MCM_GetMCM().AsyncActionManager.AddDelayedDialogue(thePlayer, 544117, 0.1);//Yen!
				MCM_GetMCM().AsyncActionManager.AddDelayedTpToPlayer(npc, 0.8);
				MCM_GetMCM().AsyncActionManager.AddDelayedDialogue(npc, 420362, 1.3);//Come Geralt..
				npc.Teleport(Vector(0, 1000, 0));
			}
			if(nam == 'Triss')
			{
				MCM_GetMCM().AsyncActionManager.AddDelayedTpToPlayer(npc, 0.1);
				MCM_GetMCM().AsyncActionManager.AddDelayedDialogue(npc, 1000783, 0.5);//Mmhhh, Geralt..
				MCM_GetMCM().AsyncActionManager.AddDelayedDialogue(thePlayer, 487414, 1.9);//Hey Triss
				npc.Teleport(Vector(0, 1000, 0));
			}

			newMenu = new SCMMenuEditCompanion2 in this;
			newMenu.COMPANION = npc;
			window.OpenMenu(newMenu);
			
			window.PlaySound("gui_character_buy_skill");
		}
	}
}*/
