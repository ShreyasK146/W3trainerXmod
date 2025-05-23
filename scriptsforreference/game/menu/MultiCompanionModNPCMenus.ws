
class MCMSelectAppearanceMenu extends SCMMenu_NameList
{
    public var depot : String;
    public var nam : name;

    public var app : name;

    protected function OnMenuCreated()
	{
		var template : CEntityTemplate;
		var i : int;
        	var names : array<name>;
		template = MCM_GetEntityTemplate(nam, depot);
		
		if(template)
		{
		GetAppearanceNames(template, names);
			for(i = 0; i < names.Size(); i+=1)
			{
				nl(names[i]);
				if(names[i] == app)
				{
					this.selectedIndex = i;
				}
			}
		}
	}

	public function onSelectionChanged(from, to : int)
    {
        if(displayEntity)
        {
            displayEntity.ApplyAppearance(this.GetItemAsName(to));
        }
    }

    public function selectEnter(optional rapid : bool)
	{
        app = this.GetItemAsName(this.selectedIndex);
        window.CloseMenu();
    }

    private var displayEntity : CNewNPC;

    public function OnMenuOpened()
    {
        var template : CEntityTemplate;
	template = MCM_GetEntityTemplate(nam, depot);
        calcPosRot();
        displayEntity = (CNewNPC)theGame.CreateEntity(template, tmpPos, tmpRot);
        displayEntity.SetTemporaryAttitudeGroup( 'friendly_to_player', AGP_Default );
        displayEntity.SetAttitude( thePlayer, AIA_Friendly );
        displayEntity.EnableCharacterCollisions(false);
    }

    private var tmpPos : Vector;
    private var tmpRot : EulerAngles;

    private function calcPosRot()
    {
        var screenWidth, screenHeight : int;
        
        var startPos, vecDir : Vector;

        var pos : Vector;
        var rot : EulerAngles;

        theGame.GetCurrentViewportResolution( screenWidth, screenHeight );
        theCamera.ViewCoordsToWorldVector((screenWidth*2)/3, (screenHeight*5)/6, startPos, vecDir);
        startPos.W = 1;
        pos = startPos + vecDir * 2.4;

        rot = theCamera.GetCameraRotation();
        rot.Yaw += 180;
        rot.Pitch *= -1.0;
        this.tmpPos = pos;
        this.tmpRot = rot;
    }

    public function onTick(dt : float)
	{
        if(!window.pauseOn && displayEntity)
        {
            calcPosRot();
            displayEntity.TeleportWithRotation(tmpPos, tmpRot);
        }
	}

    private function TeleportWithRotation(pos : Vector, rot : EulerAngles)
    {
        var component : CComponent;
		var components : array< CComponent >;
		var i, sz : int;
		components = displayEntity.GetComponentsByClassName('CMovingPhysicalAgentComponent');
		sz = components.Size();
		
		for(i = 0; i < sz; i+=1)
		{
			component = components[i];
			
			if(component)
			{
				component.SetPosition(pos);
				component.SetRotation(rot);
				component.SetScale(Vector(1, 1, 2));
			}
		}        
    	}

    //import final function ViewCoordsToWorldVector( x, y : int, out rayStart : Vector, out rayDirection : Vector );

    public function OnMenuClosed()
    {
        displayEntity.Destroy();
    }
}

class MCMChooseEntityMenu extends SCMMenuBase
{
    var currentNode : MCM_EntityListBase;
    public var nam : name;
    public var app : name;
    public var dis : name;
    public var dep : String;
    
    public function ItemCount() : int
	{
		return currentNode.GetChildCount() + currentNode.GetValueCount();
	}
	
	public function GetItem(index : int) : String
	{
        if(index < currentNode.GetChildCount())
        {
            return currentNode.GetChildAt(index).GetName();
        }
		return NameToString(currentNode.GetDisplayNameAt(index - currentNode.GetChildCount()));
	}

    public function GetColour(index : int) : String
    {
        if(index < currentNode.GetChildCount())
        {
            return COLOUR_SUB_MENU;
        }
        return "";
    }

	protected function OnMenuCreated()
	{
        currentNode = MCM_GetMCM().EntityList.dataALL;
	}

    public function GetMetaInfo() : String
	{
		return "<font size=\"16\">" + currentNode.GetMetaInfo(this.selectedIndex) + "</font>";
	}

	public function OnMenuOpened()
	{
        this.selectedIndex = currentNode.RetrieveSelectedIndex();
	}

	public function OnMenuClosed()
	{
        currentNode.StoreSelectedIndex(this.selectedIndex);
	}
	
	public function GetName() : String
	{
		return "Choose Entity";
	}

    public function selectLeft(optional rapid : bool)
	{
        if(currentNode.GetParentListWithOverride())
        {
            currentNode.StoreSelectedIndex(this.selectedIndex);
            currentNode = currentNode.GetParentListWithOverride();
            this.selectedIndex = currentNode.RetrieveSelectedIndex();
            window.UpdateAndRefresh();
            window.PlayCloseSound();
        }
        else
        {
            window.CloseMenu();
        }
    }

    public function selectRight(optional rapid : bool)
	{
        selectEnter(rapid);
    }

	public function selectEnter(optional rapid : bool)
	{
		if(this.selectedIndex < currentNode.GetChildCount())
        {
            currentNode.StoreSelectedIndex(this.selectedIndex);
            currentNode = currentNode.GetChildAt(this.selectedIndex);
            this.selectedIndex = currentNode.RetrieveSelectedIndex();
            window.UpdateAndRefresh();
            window.PlayOpenSound();
        }
        else
        {
            this.nam = currentNode.GetValueAt(this.selectedIndex - currentNode.GetChildCount());
            this.app = currentNode.GetAppearanceAt(this.selectedIndex - currentNode.GetChildCount());
            this.dis = currentNode.GetDisplayNameAt(this.selectedIndex - currentNode.GetChildCount());
            this.dep = currentNode.GetDepotPath();
            window.CloseMenu();
        }
	}
}

class MCMSpawnMenu extends SCMMenu_Elements
{
    public var type : name; default type = 'Other';

    public var spawnCount : int; default spawnCount = 1;
    public var spawnLevel : int; default spawnLevel = 10;
    public var spawnScale : int; default spawnScale = 0;
    public var mortal : bool; default mortal = true;
    var aggressionType : String; default aggressionType = "Hostile";

    public function GetName() : String
	{
		return "Spawn " + NameToString(type);
	}

    var chosenTextElement : SCMMenu_TextElement;
    var chosenAppearanceElement : SCMMenu_TextElement;
    var spawnTextElement : SCMMenu_TextElement;
    var aggressionTypeElement : SCMMenu_Enum;
    var mortalityElement : SCMMenu_Enum;

	protected function OnMenuCreated()
	{
        switch(this.type)
        {
            case 'Special': mortal = false; break;
            case 'Normal': mortal = false; break;
            case 'Other': mortal = true; aggressionType = "Hostile"; break;
        }

        this.spawnLevel = GetWitcherPlayer().GetLevel();

	chosenTextElement = AddText('choose', true, "[Choose]", COLOUR_SUB_MENU_SPECIAL);
	spawnTextElement = AddText('spawn', true, "Spawn", COLOUR_RED);
	AddText('spacer1', false, "------------", COLOUR_DISABLED);
	chosenAppearanceElement = AddText('appearance', true, "Default Appearance", COLOUR_DISABLED);
        if(type != 'Special') AddCounter('count', "Count: ", this.spawnCount, 1, 100);
        if(type == 'Other') aggressionTypeElement = AddEnum('type', "Type: ", "Hostile,Friendly,Auto", ",");
        if(type == 'Other') mortal = true;
        if(mortal)
        {
		    mortalityElement = AddEnum('mortality', "Mortal: ", "Yes,No", ",");
        }
        else
        {
		    mortalityElement = AddEnum('mortality', "Mortal: ", "No,Yes", ",");
        }
        if(type == 'Other') mortalityElement.Disabled = true;
		AddCounter('level', "Level: ", this.spawnLevel, 1, 1000);
		AddCounter('scale', "Scale: ", this.spawnScale, -50, 50);
	}

	public function OnChange(element : SCMMenu_BaseElement)
	{
		switch(element.ID)
		{
            case 'spawn': DoSpawn(); break;
	    case 'choose': OpenChooseMenu(); break;
	    case 'count': setCount((SCMMenu_Counter)element); break;
	    case 'level': setLevel((SCMMenu_Counter)element); break;
	    case 'scale': setScale((SCMMenu_Counter)element); break;
            case 'mortality': setMortality((SCMMenu_Enum)element); break;
            case 'type': UpdateAggressionType((SCMMenu_Enum)element); break;
            case 'appearance': OpenAppearanceMenu(); break;
		}
        window.UpdateAndRefresh();
	}

    private var lastAppMenu : MCMSelectAppearanceMenu;

    private function OpenAppearanceMenu()
    {
        if(IsNameValid(entityName))
        {
            lastAppMenu = new MCMSelectAppearanceMenu in this;
            lastAppMenu.nam = this.entityName;
            lastAppMenu.depot = this.depotPath;
            lastAppMenu.app = this.entityAppearance;

            window.OpenMenu(lastAppMenu);
        }
        else
        {
            window.FlashGoodBad(false, 1);
            window.PlayDeniedSound();
        }
    }

	public function UpdateAggressionType(enumElement : SCMMenu_Enum)
	{
		this.aggressionType = enumElement.GetSelectedEnum();
        if(this.aggressionType == "Hostile")
        {
            LogSCM("DISABLED");
            mortalityElement.Disabled = true;
        }
        else
        {
            LogSCM("ENABLED");
            mortalityElement.Disabled = false;
        }
	}

    private function PlaySpecialAnims(entName : name, npc : CNewNPC)
    {
        if(entName == 'cirilla')
        {
            MCM_GetMCM().AsyncActionManager.AddDelayedDialogue(thePlayer, 1075163, 0.1); //Ciri?!
            MCM_GetMCM().AsyncActionManager.AddDelayedTpToPlayer(npc, 1);
            MCM_GetMCM().AsyncActionManager.AddDelayedDialogue(npc, 480615, 1.5); //Ready?
            npc.Teleport(Vector(0, 1000, 0));
        }
        if(entName == 'yennefer')
        {
            MCM_GetMCM().AsyncActionManager.AddDelayedDialogue(thePlayer, 544117, 0.1); //Yen…!
            MCM_GetMCM().AsyncActionManager.AddDelayedTpToPlayer(npc, 0.8);
            MCM_GetMCM().AsyncActionManager.AddDelayedDialogue(npc, 420362, 1.3); //Come, Geralt.
            npc.Teleport(Vector(0, 1000, 0));
        }
        if(entName == 'triss')
        {
            MCM_GetMCM().AsyncActionManager.AddDelayedDialogue(thePlayer, 496431, 0.1); //Triss…
            MCM_GetMCM().AsyncActionManager.AddDelayedTpToPlayer(npc, 0.8);
            MCM_GetMCM().AsyncActionManager.AddDelayedDialogue(npc, 1000783, 1.3); //Hmmmm… Geraaalt…
            npc.Teleport(Vector(0, 1000, 0));
        }
    }

    private function SpawnFollower(isSpecial : bool)
    {
        var spawnData : MCMSpawnData;
        var npc : CNewNPC;
        var i : int;
        var newMenu : SCMMenuEditCompanion2;
        spawnData = new MCMSpawnData in this;
        spawnData.nam = this.entityName;
        spawnData.niceName = this.displayName;
        spawnData.appearance = this.entityAppearance;
        spawnData.level = this.spawnLevel;
        spawnData.scale = PowF(1.05, this.spawnScale);
        spawnData.mortal = this.mortal;
        spawnData.isSpecial = isSpecial;
        spawnData.depotPathPrefix = this.depotPath;

        for(i = 0; i < spawnCount; i+=1)
        {
            npc = MCM_SpawnNPC(spawnData, true);
            if(!npc)
            {
                tmpMessage = colr("Failed to spawn npc " + i, COLOUR_CAREFUL);
            }
            else
            {
                PlaySpecialAnims(spawnData.nam, npc);
            }
        }

        if(spawnCount == 1)
        {
            if(npc.scmcc)
			{
				npc.scmcc.PlayTPAnimation();
			}

			newMenu = new SCMMenuEditCompanion2 in this;
			newMenu.COMPANION = npc;
			window.OpenMenu(newMenu);
        }
        window.PlaySound("gui_character_buy_skill");
    }

    private function SpawnEntity()
    {
        var npc : CNewNPC;
        var pos : Vector;
        var template : CEntityTemplate;
        var i, j : int;
        
        var stats : CCharacterStats;
        var abls : array<name>;
        var minHealth : float;
        var myHealth : float;
        
        template = MCM_GetEntityTemplate(this.entityName, this.depotPath);
        
        if(template)
        {
            minHealth = thePlayer.GetStatMax(BCS_Vitality);
            
            minHealth = minHealth * this.spawnLevel * 5 / (GetWitcherPlayer().GetLevel());
            
            if(minHealth < 1) minHealth = 1;
            
            for(i = 0; i < spawnCount; i+=1)
            {
                pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
                npc = (CNewNPC)theGame.CreateEntity(template, pos);
                npc.SetLevel(this.spawnLevel);
                npc.AddTag(this.entityName);
                npc.AddTag('MCM_Other');
                
                if(this.entityAppearance)
                {
                    npc.SetAppearance(this.entityAppearance);
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

				switch(this.aggressionType)
				{
					case "Friendly": {
						npc.SetTemporaryAttitudeGroup( 'friendly_to_player', AGP_Default );
						npc.SetAttitude( thePlayer, AIA_Friendly );
					} break;
					case "Hostile": {
						npc.SetTemporaryAttitudeGroup( 'hostile_to_player', AGP_Default );
						npc.SetAttitude( thePlayer, AIA_Hostile );
						thePlayer.SetAttitude( npc, AIA_Hostile );

                        npc.RemoveAbilityAll('NPCDoNotGainBoost');
                        
                        //npc.RemoveAbilityAll('SkillElite');
                        /*npc.RemoveAbilityAll('SkillOfficer');
                        npc.RemoveAbilityAll('SkillMercenary');
                        npc.RemoveAbilityAll('SkillGuard');
                        npc.RemoveAbilityAll('SkillSoldier');
                        npc.RemoveAbilityAll('SkillBrigand');
                        npc.RemoveAbilityAll('SkillThug');
                        npc.RemoveAbilityAll('SkillPeasant');
                        npc.RemoveAbilityAll('Commoner');*/
                        npc.RemoveAbilityAll('BurnIgnore');
                        npc.RemoveAbilityAll('DisableFinishers');
                        
                        npc.RemoveAbilityAll('NPCLevelBonusDeadly');
                        npc.RemoveAbilityAll('VesemirDamage');
                        npc.RemoveAbilityAll('_q403Follower');

			} break;
		}

                if(this.mortal && this.aggressionType == "Friendly")
                {
                    npc.SetImmortalityMode(AIM_None, AIC_Default, true);
                    npc.SetImmortalityMode(AIM_None, AIC_Combat, true);
                    npc.SetImmortalityMode(AIM_None, AIC_Fistfight, true);
                    npc.SetImmortalityMode(AIM_None, AIC_IsAttackableByPlayer, true);
                }
                else
                {
                    npc.SetImmortalityMode(AIM_Immortal, AIC_Default, true);
                    npc.SetImmortalityMode(AIM_Immortal, AIC_Combat, true);
                    npc.SetImmortalityMode(AIM_Immortal, AIC_Fistfight, true);
                    npc.SetImmortalityMode(AIM_Immortal, AIC_IsAttackableByPlayer, true);
                }
                if(this.spawnScale != 0)
                {
                    LogSCM("Scaling " + PowF(1.05, this.spawnScale));
                    MCM_GetMCM().ScaleManager.SetScale(npc, PowF(1.05, this.spawnScale));
                }
            }
        }
    }

    private function DoSpawn()
    {
        var template : CEntityTemplate;
        if(IsNameValid(entityName))
        {
            template = MCM_GetEntityTemplate(entityName, depotPath);
            if(!template)
            {
                window.FlashGoodBad(false, 2);
                tmpMessage = colr("Failed to load template", COLOUR_CAREFUL);
            }
            else
            {
                if(type == 'Special')
                {
                    SpawnFollower(true);
                }
                else if(type == 'Normal')
                {
                    SpawnFollower(false);
                }
                else
                {
                    SpawnEntity();
                }  
            }
        }
        else
        {
            window.FlashGoodBad(false, 1);
            window.PlayDeniedSound();
        }
    }

    var entityName : name;
    var entityAppearance : name;
    var displayName : name;
    var depotPath : String;

    var tmpMessage : String;
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
            ret = "";
		}
		return ret;
	}

    private function UpdateTextValues()
    {
        if(IsNameValid(displayName))
        {
            chosenTextElement.textValue = NameToString(displayName);
            spawnTextElement.colourValue = COLOUR_GREEN;
        }
        else
        {
            chosenTextElement.textValue = "[Choose]";
            spawnTextElement.colourValue = COLOUR_RED;
        }
        if(IsNameValid(entityAppearance))
        {
            chosenAppearanceElement.textValue = NameToString(entityAppearance);
        }
        else
        {
            chosenAppearanceElement.textValue = "Default Appearance";
        }
    }

    public function OnMenuOpened()
    {
        if(chooseMenu)
        {
            if(chooseMenu.nam != entityName || chooseMenu.dis != displayName || chooseMenu.dep != depotPath)
            {
                entityName = chooseMenu.nam;
                entityAppearance = chooseMenu.app;
                displayName = chooseMenu.dis;
                depotPath = chooseMenu.dep;
                UpdateTextValues();
            }
        }
        if(lastAppMenu)
        {
            if(this.entityAppearance != lastAppMenu.app)
            {
                this.entityAppearance = lastAppMenu.app;
                UpdateTextValues();
            }
            lastAppMenu = NULL;
        }
    }

    var chooseMenu : MCMChooseEntityMenu;
    private function OpenChooseMenu()
    {
        if(!chooseMenu) chooseMenu = new MCMChooseEntityMenu in this;
        window.OpenMenu(chooseMenu);
    }

    private function setCount(counter : SCMMenu_Counter) { this.spawnCount = counter.GetCounterValue(); }
    private function setLevel(counter : SCMMenu_Counter) { this.spawnLevel = counter.GetCounterValue(); }
    private function setScale(counter : SCMMenu_Counter) { this.spawnScale = counter.GetCounterValue(); }

    private function setMortality(enumer : SCMMenu_Enum) { this.mortal = enumer.GetSelectedEnum() == "Yes"; }
}

class MCMListNPCMenu extends SCMMenuBase
{
    public var type : name; default type = '';

    public var npcs : array<CNewNPC>;

	public function OnMenuOpened()
	{
        npcs.Clear();
        switch(type)
        {
            case 'Special': mod_scm_GetNPCs(npcs, 'GeraltsBFF', ST_Special, true); break;
            case 'Normal': mod_scm_GetNPCs(npcs, 'GeraltsBFF', ST_Normal, true); break;
            case 'Other': theGame.GetNPCsByTag('MCM_Other', npcs); break;
        }
        if(this.selectedIndex >= npcs.Size())
        {
            this.selectedIndex = npcs.Size()-1;
            if(this.selectedIndex < 0) this.selectedIndex = 0;
        }
	}

    public function ItemCount() : int
	{
		return npcs.Size();
	}
	
	public function GetItem(index : int) : String
	{
        if(npcs[index].scmcc)
        {
            return NameToString(npcs[index].scmcc.data.niceName);
        }
        return npcs[index].GetDisplayName();
	}

	public function OnMenuClosed()
	{
        npcs.Clear();
	}
	
	public function GetName() : String
	{
		return "List " + NameToString(this.type) + " NPCs";
	}

	public function selectEnter(optional rapid : bool)
	{
        switch(this.type)
        {
            case 'Other': npcs[selectedIndex].Destroy(); npcs.Erase(selectedIndex); window.PlayTickSound(); window.UpdateAndRefresh(); break;
            default: OpenEditMenu(); break;
        }
	}

    private function OpenEditMenu()
    {
        var newMenu : SCMMenuEditCompanion2;
        newMenu = new SCMMenuEditCompanion2 in this;
        newMenu.COMPANION = npcs[selectedIndex];
        window.OpenMenu(newMenu);
    }

    public function GetMetaInfo() : String
    {
        switch(this.type)
        {
            case 'Other': return "<font color='#775555'>You can only delete these</font>";
        }
        return "";
    }
}

class SCMAppearanceChangeMenu extends SCMMenu_NameList
{
	public var COMPANION : CNewNPC;
	private var fxName_long : name; default fxName_long = 'axii_confusion';

	protected function OnMenuCreated()
	{
		var template : CEntityTemplate;
		var i : int;
        	var names : array<name>;
		var currentApp : name;
		currentApp = COMPANION.GetAppearance();
		template = MCM_GetEntityTemplate(COMPANION.scmcc.data.nam, COMPANION.scmcc.data.depotPathPrefix);
		
		if(template)
		{
            	GetAppearanceNames(template, names);
			for(i = 0; i < names.Size(); i+=1)
			{
				nl(names[i]);
				if(names[i] == currentApp)
				{
					this.selectedIndex = i;
				}
			}
		}
	}

	var storedPos : Vector;
	var storedRot : EulerAngles;

	public function OnMenuOpened()
	{
		storedPos = COMPANION.GetWorldPosition();
		storedRot = COMPANION.GetWorldRotation();
		COMPANION.PlayEffect(fxName_long);
		COMPANION.scmcc.StopFollowing();
	}

	public function OnMenuClosed()
	{
		COMPANION.StopEffect(fxName_long);
		COMPANION.TeleportWithRotation(storedPos, storedRot);
		COMPANION.scmcc.StartFollowing();
	}

    private var tmpPos : Vector;
    private var tmpRot : EulerAngles;

    private function calcPosRot()
    {
        var screenWidth, screenHeight : int;
        
        var startPos, vecDir : Vector;

        var pos : Vector;
        var rot : EulerAngles;

        theGame.GetCurrentViewportResolution( screenWidth, screenHeight );
        theCamera.ViewCoordsToWorldVector((screenWidth*2)/3, (screenHeight*5)/6, startPos, vecDir);
        startPos.W = 1;
        pos = startPos + vecDir * 2.4;

        rot = theCamera.GetCameraRotation();
        rot.Yaw += 180;
        rot.Pitch *= -1.0;
        this.tmpPos = pos;
        this.tmpRot = rot;
    }

    public function onTick(dt : float)
	{
        if(COMPANION)
        {
            calcPosRot();
            COMPANION.TeleportWithRotation(tmpPos, tmpRot);
        }
	}
	
	public function selectEnter(optional rapid : bool)
	{
		if(COMPANION)
		{
			COMPANION.ApplyAppearance(GetItem(selectedIndex));
			if(COMPANION.scmcc)
			{
				COMPANION.scmcc.data.appearance = GetItemAsName(selectedIndex);
			}
			window.PlaySound("gui_no_stamina");
		}
		else
		{
			LogSCM("Entity Doesn't exist mate");
		}
	}
}

class SCMMenuEditCompanion2 extends SCMMenu_Elements
{
	public editable var COMPANION : CNewNPC;
	private var fxName_long : name; default fxName_long = 'axii_confusion';

	var currentScaleEntry : mod_scm_ScaleEntry;
	private const var ScaleBase : float; default ScaleBase = 1.05;

	private function setScale(val : int)
	{
		var scaleF : float = PowF(ScaleBase, val);
		if(!this.currentScaleEntry || this.currentScaleEntry.Destroyed)
		{
			this.currentScaleEntry = MCM_GetMCM().ScaleManager.SetScale(COMPANION, scaleF);
		}
		else
		{
			this.currentScaleEntry.scaleToReach = scaleF;
		}
		this.COMPANION.scmcc.data.scale = scaleF;
	}

	private function getScale() : int
	{
		var scaleentry : mod_scm_ScaleEntry = MCM_GetMCM().ScaleManager.GetScaleEntry(COMPANION);
		if(scaleentry)
		{
			return RoundF(LogF(scaleentry.scaleToReach) / LogF(ScaleBase));
		}
		return 0;
	}

	protected function OnMenuCreated()
	{
		AddText('changeapp', true, "Change Appearance", COLOUR_SUB_MENU);
		AddCounter('level', "Level: ", COMPANION.scmcc.data.level, 1, 200);
		AddCounter('scale', "Scale: ", getScale(), -50, 50);
		if(this.COMPANION.scmcc.data.mortal)
		{
			AddEnum('mortal', "Mortal: ", "Yes,No", ",");
		}
		else
		{
			AddEnum('mortal', "Mortal: ", "No,Yes", ",");
		}
		if(!COMPANION.scmcc.data.isSpecial) AddText('dupe', true, "Duplicate", COLOUR_DISABLED);
		AddText('call', true, "Call Companion", "");
		AddDoubleButton('remove', "Remove Companion", "a43535", "ffafaf");

		// AddText('remove', true, "Remove Companion", "ffafaf", "a43535");
	}

	public function OnChange(element : SCMMenu_BaseElement)
	{
		switch(element.ID)
		{
			case 'changeapp': 	OpenAppearanceMenu(); break;
			case 'level': 		UpdateLevel((SCMMenu_Counter)element); break;
			case 'scale': 		UpdateScale((SCMMenu_Counter)element); break;
			case 'mortal': 		UpdateMortality((SCMMenu_Enum)element); break;
			case 'dupe': 		DuplicateNPC(); break;
			case 'call': 		COMPANION.scmcc.tpToPlayer(MCM_TPP_Front); break;
			case 'remove': 		DeleteNPC(); break;
		}
		window.UpdateAndRefresh();
	}

    private function UpdateMortality(enumer : SCMMenu_Enum) { this.COMPANION.scmcc.setMortality(enumer.GetSelectedEnum() == "Yes"); }

	private function UpdateLevel(counter : SCMMenu_Counter)
	{
		COMPANION.scmcc.data.level = counter.GetCounterValue();
		COMPANION.SetLevel(counter.GetCounterValue());
	}

	private function UpdateScale(counter : SCMMenu_Counter)
	{
		setScale(counter.GetCounterValue());
	}

	private function DuplicateNPC()
	{
		var newNPC : CNewNPC;
		window.PlaySelectSound();
		newNPC = MCM_SpawnNPC(COMPANION.scmcc.data, true);
	}

	private function DeleteNPC()
	{
		window.PlaySelectSound();
		mod_scm_RemoveNPC(COMPANION);
		window.CloseMenu();
	}

	private function OpenAppearanceMenu()
	{
		var newMenu : SCMAppearanceChangeMenu;
		newMenu = new SCMAppearanceChangeMenu in this;
		newMenu.COMPANION = COMPANION;
		window.OpenMenu(newMenu);
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
