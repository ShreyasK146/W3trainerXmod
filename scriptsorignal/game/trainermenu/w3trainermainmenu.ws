

	class UIForTrainerMenuMain extends UIForTrainerMenu_Elements
	{
		public function GetName() : String
		{
			return "Witcher 3 - UI for Trainer";
		}
	//high_standing_determined_exit_rightside
		protected function OnMenuCreated()
		{
			AddText('spawn', true, "Gift Me", COLOUR_SUB_MENU);
	
			AddText('spacer1', false, "------------", COLOUR_DISABLED);
	
			AddText('settings', true, "Cheats", COLOUR_SUB_MENU);
			AddText('spacer3', false, "------------", COLOUR_DISABLED);
			AddEnum('pause', "Pause Game: ", "Off,On", ",");
			if(FactsQuerySum('UIForTrainerTestMenu') > 0) AddText('test', true, "Test Menu", COLOUR_DISABLED);
			AddText('close', true, "Close Menu", COLOUR_SUB_MENU_SPECIAL);
		}

		public function OnChange(element : UIForTrainerMenu_BaseElement)
		{
			switch(element.ID)																																																																																																																																																																																																																																												
			{
				case 'spawn': OpenSpawnSubMenu(); break;
	
				case 'settings': OpenOptionsMenu(); break;
				case 'pause': UpdatePauseSetting((UIForTrainerMenu_Enum)element); break;
				case 'test': OpenTestMenu(); break;
				case 'close': window.CloseMenu(); break;
			}
		}

		var testMenu : UIForTrainerTestMenu;
		public function OpenTestMenu()
		{
			if(!testMenu) testMenu = new UIForTrainerTestMenu in this;
			window.OpenMenu(testMenu);
		}

		public function UpdatePauseSetting(num : UIForTrainerMenu_Enum)
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


		var optionsMenu : UIForTrainerOptionsMenu;
		private function OpenOptionsMenu()
		{
			if(!this.optionsMenu) this.optionsMenu = new UIForTrainerOptionsMenu in this;
			this.window.OpenMenu(this.optionsMenu);
		}
		
		var spawnMainMenu : UIForTrainerMainMenu;
		private function OpenSpawnSubMenu()
		{
			if(!this.spawnMainMenu) this.spawnMainMenu = new UIForTrainerMainMenu in this;
			this.window.OpenMenu(this.spawnMainMenu);
		}


	}

	class UIForTrainerMainMenu extends UIForTrainerMenu_Elements
	{
		public function GetName() : String
		{
			return "Choose Your Gift1";
		}

		protected function OnMenuCreated()
		{
	
			AddText('Normal', true, "Add Items", COLOUR_SUB_MENU);
			//AddText('Other', true, "Add Cheats", COLOUR_SUB_MENU);

		}

		public function OnChange(element : UIForTrainerMenu_BaseElement)
		{
			switch(element.ID)
			{
				
				case 'Normal': OpenSpawnNormalMenu(); break;
				//case 'Other': OpenSpawnOtherMenu(); break;
				
			}
		}

		var spawnSpecial, spawnNormal, spawnOther : UIForTrainerSpawnMenu;



		private function OpenSpawnNormalMenu()
		{
			if(!spawnNormal) spawnNormal = new UIForTrainerSpawnMenu in this;
			spawnNormal.type = 'Normal';
			window.OpenMenu(spawnNormal);
		}
		// private function OpenSpawnOtherMenu()
		// {
		// 	if(!spawnOther) spawnOther = new UIForTrainerSpawnMenu in this;
		// 	spawnOther.type = 'Other';
		// 	window.OpenMenu(spawnOther);
		// }

	}



class UIForTrainerOptionsMenu extends UIForTrainerMenu_Elements
{
    public function GetName() : String
	{
		return "Cheats Menu";
	}

	protected function OnMenuCreated()
	{
		AddText('Global', true, "Cheating is OK in SP Game", COLOUR_SUB_MENU);
		//AddText('Spawn', true, "Spawning Options", COLOUR_SUB_MENU);
	}

	public function OnChange(element : UIForTrainerMenu_BaseElement)
	{
		switch(element.ID)
		{
			case 'Global': OpenGlobalMenu(); break;
			//case 'Spawn': OpenSpawnMenu(); break;
		}
	}

	var globalMenu : UIForTrainerGlobalOptionsMenu;
    private function OpenGlobalMenu()
    {
        if(!globalMenu) globalMenu = new UIForTrainerGlobalOptionsMenu in this;
        window.OpenMenu(globalMenu);
    }
	var spawnMenu : UIForTrainerSpawnFactOptionsRootMenu;

}

class UIForTrainerSpawnFactOptionsRootMenu extends UITrainerBase
{
	
}

class UIForTrainerSpawnFactOptionsMenu extends UIForTrainerFactMenu
{

}
class UIForTrainer_NPCSpawnEntry
{

}

class UIForTrainerGlobalOptionsMenu extends UIForTrainerFactMenu
{
	protected function OnMenuCreated()
	{
	
		addOption('god_mode_enabled', "Unlimited Health", "When turned on, Geralt is GOD.");
		addOption('unlimited_stamina', "Unlimited Stamina", "When turned on, Stamina never drains.");
		addOption('healme', "Heal Me", "When turned on, it keeps healing Geralt to full health.");
		addOption('AllowFT', "FT from Any", "This command can be used to enable or disable the ability to Fast Travel from any location.");
		addOption('ShowAllFT', "Show All FT", " This command will show all Fast Travel pins on the map. It is recommended that you save your game before running this command, as some players have been unable to undo the effects of this command.");
		addOption('ShowKnownPins', "Show Known Pins", "This console command will reveal 1 or hide 0 all locations on the map currently that should display as a question mark ?.");
		addOption('ShowPins', "Show Pins", "This command will show all pins on the map. It is recommended that you save your game before running this command, as some players have been unable to undo the effects of this command.");
		addOption('Cat', "NightVision", "When turned on, Geralt has nightvision");
		addOption('Drunk', "Drunk Geralt", "When turned on, Geralt is in drunk state ");
		addOption('Shave', "Shave Beard", "When turned on, it keeps Geralt's beard shaved");
		//addOption('StaminaPony', "Stamina Pony", "Carry unlimited inventory weight.");
		// addOption('InstantMount', "Instant Mount", "Carry unlimited inventory weight.");
		addOption('killall', "Kill All", "When turned on, Kills all enemies when they come in radius of 20");
		addOption('removeall', "Remove All Items", "BE CAREFUL!!! This command will reset Geralt completely, clearing your inventory and resetting your level to 1. You will also be given starter gear.");

	}
	//IK_P=(Action=DebugInput)
	public function GetName() : String
	{
		return "Cheats Menu";
	}
}

struct UIForTrainerOptionsMenuEntry
{
	var fact : name;
	var text : String;
	var desc : String;
}

class UIForTrainerFactMenu extends UITrainerBase
{
	var options : array<UIForTrainerOptionsMenuEntry>;
	
	public function addOption(fact : name, text : String, desc : String)
	{
		options.PushBack(UIForTrainerOptionsMenuEntry(fact, text, desc));
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
		var helpMenu : UIForTrainerMenu_Text;
		
		helpMenu = new UIForTrainerMenu_Text in this;
		
		helpMenu.text = options[selectedIndex].desc;
		helpMenu.title = options[selectedIndex].text + " Help";
		
		window.OpenMenu(helpMenu);
	}
}

