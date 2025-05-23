
	class MCMMenuMain extends SCMMenu_Elements
	{
		public function GetName() : String
		{
			return "Multi Companion Menu";
		}
	//high_standing_determined_exit_rightside
		protected function OnMenuCreated()
		{
			AddText('spawn', true, "Spawn", COLOUR_SUB_MENU);
			AddText('list', true, "List", COLOUR_SUB_MENU);
			AddText('spacer1', false, "------------", COLOUR_DISABLED);
			AddText('commands', true, "Commands", COLOUR_SUB_MENU);
			AddText('settings', true, "Settings", COLOUR_SUB_MENU);
			AddText('spacer3', false, "------------", COLOUR_DISABLED);
			AddEnum('pause', "Pause: ", "Off,On", ",");
			if(FactsQuerySum('MCMTestMenu') > 0) AddText('test', true, "Test Menu", COLOUR_DISABLED);
			AddText('close', true, "Close Menu", COLOUR_SUB_MENU_SPECIAL);
		}

		public function OnChange(element : SCMMenu_BaseElement)
		{
			switch(element.ID)
			{
				case 'spawn': OpenSpawnSubMenu(); break;
				case 'list': OpenListSubMenu(); break;
				case 'commands': OpenCommandsMenu(); break;
				case 'settings': OpenOptionsMenu(); break;
				case 'pause': UpdatePauseSetting((SCMMenu_Enum)element); break;
				case 'test': OpenTestMenu(); break;
				case 'close': window.CloseMenu(); break;
			}
		}

		var testMenu : MCMTestMenu;
		public function OpenTestMenu()
		{
			if(!testMenu) testMenu = new MCMTestMenu in this;
			window.OpenMenu(testMenu);
		}

		public function UpdatePauseSetting(num : SCMMenu_Enum)
		{
			if(num.GetSelectedEnum() == "On")
			{
				
				window.SetPause(true);
			}
			else
			{
				window.SetPause(false);
			}
			window.UpdateAndRefresh();
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
		
		var spawnMainMenu : MCMSpawnMainMenu;
		private function OpenSpawnSubMenu()
		{
			if(!this.spawnMainMenu) this.spawnMainMenu = new MCMSpawnMainMenu in this;
			this.window.OpenMenu(this.spawnMainMenu);
		}

		var listMainMenu : MCMListMainMenu;
		private function OpenListSubMenu()
		{
			if(!this.listMainMenu) this.listMainMenu = new MCMListMainMenu in this;
			this.window.OpenMenu(this.listMainMenu);
		}
	}

	class MCMSpawnMainMenu extends SCMMenu_Elements
	{
		public function GetName() : String
		{
			return "Spawn NPC";
		}

		protected function OnMenuCreated()
		{
			AddText('Special', true, "Special Companion", COLOUR_SUB_MENU);
			AddText('Normal', true, "Normal Companion", COLOUR_SUB_MENU);
			AddText('Other', true, "Other", COLOUR_SUB_MENU);
			//AddInputText('Text', "", colr("Type Something", COLOUR_DISABLED));
		}

		public function OnChange(element : SCMMenu_BaseElement)
		{
			switch(element.ID)
			{
				case 'Special': OpenSpawnSpecialMenu(); break;
				case 'Normal': OpenSpawnNormalMenu(); break;
				case 'Other': OpenSpawnOtherMenu(); break;
			}
		}

		var spawnSpecial, spawnNormal, spawnOther : MCMSpawnMenu;

		private function OpenSpawnSpecialMenu()
		{
			if(!spawnSpecial) spawnSpecial = new MCMSpawnMenu in this;
			spawnSpecial.type = 'Special';
			window.OpenMenu(spawnSpecial);
		}

		private function OpenSpawnNormalMenu()
		{
			if(!spawnNormal) spawnNormal = new MCMSpawnMenu in this;
			spawnNormal.type = 'Normal';
			window.OpenMenu(spawnNormal);
		}

		private function OpenSpawnOtherMenu()
		{
			if(!spawnOther) spawnOther = new MCMSpawnMenu in this;
			spawnOther.type = 'Other';
			window.OpenMenu(spawnOther);
		}
	}

class MCMListMainMenu extends SCMMenu_Elements
{
    public function GetName() : String
	{
		return "List NPC";
	}

	protected function OnMenuCreated()
	{
		AddText('Special', true, "Special Companion", COLOUR_SUB_MENU);
		AddText('Normal', true, "Normal Companion", COLOUR_SUB_MENU);
		AddText('Other', true, "Other", COLOUR_SUB_MENU);
	}

	public function OnChange(element : SCMMenu_BaseElement)
	{
		switch(element.ID)
		{
			case 'Special': OpenListSpecialMenu(); break;
			case 'Normal': OpenListNormalMenu(); break;
			case 'Other': OpenListOtherMenu(); break;
		}
	}

    var listSpecial, listNormal, listOther : MCMListNPCMenu;

    private function OpenListSpecialMenu()
    {
        if(!listSpecial) listSpecial = new MCMListNPCMenu in this;
        listSpecial.type = 'Special';
        window.OpenMenu(listSpecial);
    }

    private function OpenListNormalMenu()
    {
        if(!listNormal) listNormal = new MCMListNPCMenu in this;
        listNormal.type = 'Normal';
        window.OpenMenu(listNormal);
    }

    private function OpenListOtherMenu()
    {
        if(!listOther) listOther = new MCMListNPCMenu in this;
        listOther.type = 'Other';
        window.OpenMenu(listOther);
    }
}

class SCMOptionsMenu extends SCMMenu_Elements
{
    public function GetName() : String
	{
		return "Options Root Menu";
	}

	protected function OnMenuCreated()
	{
		AddText('Global', true, "Global Options", COLOUR_SUB_MENU);
		AddText('Spawn', true, "Spawning Options", COLOUR_SUB_MENU);
	}

	public function OnChange(element : SCMMenu_BaseElement)
	{
		switch(element.ID)
		{
			case 'Global': OpenGlobalMenu(); break;
			case 'Spawn': OpenSpawnMenu(); break;
		}
	}

	var globalMenu : SCMGlobalOptionsMenu;
    private function OpenGlobalMenu()
    {
        if(!globalMenu) globalMenu = new SCMGlobalOptionsMenu in this;
        window.OpenMenu(globalMenu);
    }
	var spawnMenu : SCMSpawnFactOptionsRootMenu;
    private function OpenSpawnMenu()
    {
        if(!spawnMenu) spawnMenu = new SCMSpawnFactOptionsRootMenu in this;
        window.OpenMenu(spawnMenu);
    }
}

class SCMSpawnFactOptionsRootMenu extends SCMMenuBase
{
	var regs : array<MCM_NPCSpawnFactRegistry>;

	protected function OnMenuCreated()
	{
		regs = MCM_GetMCM().NPCManager.spawnFactRegistries;
	}

	public function ItemCount() : int
	{
		return regs.Size();
	}

    public function GetName() : String
	{
		return "Disable Spawning";
	}

	public function GetColour(index : int) : String
	{
		return COLOUR_SUB_MENU;
	}
	
	public function GetItem(index : int) : String
	{
		return regs[index].levelName;
	}
	
	public function selectEnter(optional rapid : bool)
	{
		var menu : SCMSpawnFactOptionsMenu;
		menu = new SCMSpawnFactOptionsMenu in this;
		menu.spawnFactReg = this.regs[this.selectedIndex];
		window.OpenMenu(menu);
	}
}

class SCMSpawnFactOptionsMenu extends SCMFactMenu
{
	public var spawnFactReg : MCM_NPCSpawnFactRegistry;

	protected function OnMenuCreated()
	{
		var i, sz : int;
		var spawnEntry : MCM_NPCSpawnEntry;
		var niceName : name;

		sz = spawnFactReg.entries.Size();

		for(i = 0; i < sz; i+=1)
		{
			spawnEntry = spawnFactReg.entries[i];
			niceName = MCM_NicifyName(spawnEntry.npcEntry.npcName);

			addOption(spawnEntry.spawnFact, 
				"Disable " + niceName, 
				"When ON, stops " + niceName + " from spawning in " + spawnFactReg.levelName);
		}
	}

	public function GetName() : String
	{
		return "Disable Spawning";
	}

	public function GetMetaInfo() : String
	{
		return spawnFactReg.levelName;
	}
}

class SCMGlobalOptionsMenu extends SCMFactMenu
{
	protected function OnMenuCreated()
	{
		addOption('mod_scm_talking_disabled', "Disable Talking", "When ON, stops special companions from saying random lines.");
		addOption('mod_scm_enabled', "Force Spawning", "When ON, forces companions to spawn throughout the world even if you haven't finished the game yet.");
		addOption('mod_scm_disabled', "Force No Spawning", "When ON, forces no companions to spawn in the world, even if you have finished the game.");
		addOption('mod_scm_AllowAllNaughty', "Allow Special Scenes", "Allows you to engage in deviant activities with as many characters as programmed.");
		addOption('MCM_DisableAppearanceChanging', "Disable Appearance Changes", "Stops companions from changing appearances as they go about their daily business.");
		addOption('mod_scm_SpecialCombatOff', "Disable Special Combat", "Disables special combat moves. i.e. Blink for Ciri, meteors for Yen and Triss.");
		addOption('MCMTestMenu', "Enable Debugging", "Enable a bit of debugging stuff.");
	}

	public function GetName() : String
	{
		return "Global Options";
	}
}

struct SCMOptionsMenuEntry
{
	var fact : name;
	var text : String;
	var desc : String;
}

class SCMFactMenu extends SCMMenuBase
{
	var options : array<SCMOptionsMenuEntry>;
	
	public function addOption(fact : name, text : String, desc : String)
	{
		options.PushBack(SCMOptionsMenuEntry(fact, text, desc));
	}
	
	public function ItemCount() : int
	{
		return options.Size();
	}
	
	public function IsOn(index : int) : bool
	{
		return FactsQuerySum(options[index].fact) > 0;
	}
	
	public function GetColour(index : int) : String
	{
		if(IsOn(index))
		{
			return "22DD22";
		}
		return "FF8888";
	}
	
	public function GetItem(index : int) : String
	{
		if(IsOn(index))
		{
			return options[index].text + ": ON";
		}
		
		return options[index].text + ": OFF";
	}
	
	public function selectEnter(optional rapid : bool)
	{
		if(IsOn(selectedIndex))
		{
			FactsSet(options[selectedIndex].fact, 0);
		}
		else
		{
			FactsSet(options[selectedIndex].fact, 1);
		}
		
		window.UpdateAndRefresh();
		window.PlaySelectSound();
	}
	
	public function selectRight(optional rapid : bool)
	{
		var helpMenu : SCMMenu_Text;
		
		helpMenu = new SCMMenu_Text in this;
		
		helpMenu.text = options[selectedIndex].desc;
		helpMenu.title = options[selectedIndex].text + " Help";
		
		window.OpenMenu(helpMenu);
	}
}

class SCMCommandMenu extends SCMMenu_NameList
{
	protected function OnMenuCreated()
	{
		nl('Remove All Normal Companions');
		nl('Remove All Special Companions');
		nl('Call All Companions');
	}
	
	public function GetName() : String
	{
		return "SCM Command Menu";
	}
	
	public function selectEnter(optional rapid : bool)
	{
		switch(selectedIndex)
		{
		case 0: _RemoveAllCompanions(); break;
		case 1: _RemoveSpecialCompanions(); break;
		case 2: _CallAllCompanions(); break;
		}
		window.PlaySound("gui_character_place_mutagen");
	}
}
