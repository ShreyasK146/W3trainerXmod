
class UIForTrainerSpawnMenu extends UIForTrainerMenu_Elements
{
    public var type : name; default type = 'OtheR';
    public var itemTextName : name;
    public var spawnCount : int; default spawnCount = 1;
   


    public function GetName() : String
	{
		return "Choose Your Gift";
	}

    var chosenTextElement : UIForTrainerMenu_TextElement;

    var spawnTextElement : UIForTrainerMenu_TextElement;


	protected function OnMenuCreated()
	{

       

	chosenTextElement = AddText('choose', true, "[Select]", COLOUR_SUB_MENU_SPECIAL);
    AddText('spacer1', false, "------------", COLOUR_DISABLED);
	spawnTextElement = AddText('spawn', true, "Gift Me", COLOUR_RED);
	AddText('spacer1', false, "------------", COLOUR_DISABLED);

        if(type != 'Special') AddCounter('count', "Count: ", this.spawnCount,1,100);
       

	}

	public function OnChange(element : UIForTrainerMenu_BaseElement)
	{
		switch(element.ID)
		{
        case 'spawn': DoSpawn(); DoSpawn2(); break;
	    case 'choose': OpenChooseMenu(); break;
	    case 'count': setCount((UIForTrainerMenu_Counter)element); break;

		}
        window.UpdateAndRefresh();
	}

    var newID : array<SItemUniqueId>;
    var lm : W3PlayerWitcher;
	var exp, prevLvl, currLvl,i,times : int;
	var acs : array< CComponent >;
    var ent : CEntity;
	var pos : Vector;
	var template : CEntityTemplate;
    var manager : CWitcherJournalManager;
    private function DoSpawn2()
    {
        switch(chosenTextElement.textItemName)
        {
            case 'EET_AbilityOnLowHealth':
            case 'EET_AdrenalineDrain':
            case 'EET_AirBoost':
            case 'EET_AirDrain':
            case 'EET_AirDrainDive':
            case 'EET_AutoAirRegen':
            case 'EET_AutoEssenceRegen':
            case 'EET_AutoMoraleRegen':
            case 'EET_AutoPanicRegen':
            case 'EET_AutoStaminaRegen':
            case 'EET_AutoSwimmingStaminaRegen':
            case 'EET_AutoVitalityRegen':
            case 'EET_AxiiGuardMe':
            case 'EET_BattleTrance':
            case 'EET_BlackBlood':
            case 'EET_Bleeding':
            case 'EET_BleedingTracking':
            case 'EET_Blindness':
            case 'EET_Blizzard':
            case 'EET_BoostedEssenceRegen':
            case 'EET_BoostedStaminaRegen':
            case 'EET_Burning':
            case 'EET_Cat':
            case 'EET_Choking':
            case 'EET_Confusion':
            case 'EET_CounterStrikeHit':
            case 'EET_DoTHPRegenReduce':
            case 'EET_DoppelgangerEssenceRegen':
            case 'EET_Drowning':
            case 'EET_Drunkenness':
            case 'EET_Edible':
            case 'EET_EnhancedArmor':
            case 'EET_EnhancedWeapon':
            case 'EET_Fact':
            case 'EET_FireAura':
            case 'EET_Frozen':
            case 'EET_FullMoon':
            case 'EET_GoldenOriole':
            case 'EET_HeavyKnockdown':
            case 'EET_Hypnotized':
            case 'EET_IgnorePain':
            case 'EET_Immobilized':
            case 'EET_KillerWhale':
            case 'EET_Knockdown':
            case 'EET_KnockdownTypeApplicator':
            case 'EET_LongStagger':
            case 'EET_LowHealth':
            case 'EET_MariborForest':
            case 'EET_Mutagen01':
            case 'EET_Mutagen02':
            case 'EET_Mutagen03':
            case 'EET_Mutagen04':
            case 'EET_Mutagen05':
            case 'EET_Mutagen06':
            case 'EET_Mutagen07':
            case 'EET_Mutagen08':
            case 'EET_Mutagen09':
            case 'EET_Mutagen10':
            case 'EET_Mutagen11':
            case 'EET_Mutagen12':
            case 'EET_Mutagen13':
            case 'EET_Mutagen14':
            case 'EET_Mutagen15':
            case 'EET_Mutagen16':
            case 'EET_Mutagen17':
            case 'EET_Mutagen18':
            case 'EET_Mutagen19':
            case 'EET_Mutagen20':
            case 'EET_Mutagen21':
            case 'EET_Mutagen22':
            case 'EET_Mutagen23':
            case 'EET_Mutagen24':
            case 'EET_Mutagen25':
            case 'EET_Mutagen26':
            case 'EET_Mutagen27':
            case 'EET_Mutagen28':
            case 'EET_OverEncumbered':
            case 'EET_Paralyzed':
            case 'EET_PetriPhiltre':
            case 'EET_PheromoneBear':
            case 'EET_PheromoneDrowner':
            case 'EET_PheromoneNekker':
            case 'EET_Poison':
            case 'EET_PoisonCritical':
            case 'EET_Pull':
            case 'EET_Ragdoll':
            case 'EET_ShrineAard':
            case 'EET_ShrineAxii':
            case 'EET_ShrineIgni':
            case 'EET_ShrineQuen':
            case 'EET_ShrineYrden':
            case 'EET_SilverDust':
            case 'EET_Slowdown':
            case 'EET_SlowdownAxii':
            case 'EET_SlowdownFrost':
            case 'EET_Snowstorm':
            case 'EET_SnowstormQ403':
            case 'EET_Stagger':
            case 'EET_StaggerAura':
            case 'EET_StaminaDrain':
            case 'EET_StaminaDrainSwimming':
            case 'EET_Swallow':
            case 'EET_Swarm':
            case 'EET_TawnyOwl':
            case 'EET_Thunderbolt':
            case 'EET_Toxicity':
            case 'EET_Undefined':
            case 'EET_Unused1':
            case 'EET_VitalityDrain':
            case 'EET_WeatherBonus':
            case 'EET_WellFed':
            case 'EET_WellHydrated':
            case 'EET_WhiteHoney':
            case 'EET_WhiteRaffardDecoction':
            case 'EET_WitchHypnotized':
            case 'EET_WraithBlindness':
            case 'EET_YrdenHealthDrain':
            GiveBuffForW3Player(GetEffectTypeByName(chosenTextElement.textItemName), spawnCount * 10);break;
            case 'head_0':
            case 'head_0_tattoo':
            case 'head_1':
            case 'head_1_tattoo':
            case 'head_2':
            case 'head_2_tattoo':
            case 'head_3':
            case 'head_3_tattoo':
            case 'head_4':
            case 'head_4_tattoo':
            case 'head_shaving1':
            case 'head_shaving2':
            case 'head_shaving3':
            case 'head_robbery':
            case 'head_robbery_tattoo':
            case 'head_5':
            case 'head_5_tattoo':
            case 'head_6':
            case 'head_6_tattoo':
            case 'head_7':
            case 'head_7_tattoo':
            acs = thePlayer.GetComponentsByClassName( 'CHeadManagerComponent' );
	        ( ( CHeadManagerComponent ) acs[0] ).SetCustomHead(chosenTextElement.textItemName); break;
             case 'WT_Clear':
            case 'WT_Light_Clouds':
            case 'WT_Mid_Clouds':
            case 'WT_Heavy_Clouds':
            case 'WT_Light_Rain':
            case 'WT_Light_Snow':
            case 'WT_Blizzard':
            case 'WT_Rain_Storm':
            case 'WT_Vesemir_burial_hour_3_30':
            case 'WT_Heavy_Clouds_Dark':
            case 'WT_Battle':
            case 'WT_Battle_Forest':
            case 'WT_Mid_Clouds_Dark':
            case 'WT_Snow':
            case 'WT_Mid_Clouds_Fog':
            case 'WT_Wild_Hunt':
            case 'WT_q501_Blizzard':
            case 'WT_q501_Storm':
            case 'WT_q501_Blizzard2':
            case 'WT_lessun_forest':
            case 'WT_q501_fight_ship_18_00':
            case 'WT_q501_storm_arena':
            case 'Spiral_Eternal_Cold':
            case 'Spiral_Aen_Elle':
            case 'Spiral_Desert':
            case 'Spiral_Dark_Valley':
            case 'Clear':
            case 'Winter Epilog':
            RequestWeatherChangeTo(chosenTextElement.textItemName ,spawnCount, false ); break;
            case 'sword_2':
            case 'sword_5':
            case 'sword_s1':
            case 'sword_s2':
            case 'sword_s3':
            case 'sword_s4':
            case 'sword_s5':
            case 'sword_s6':
            case 'sword_s7':
            case 'sword_s8':
            case 'sword_s9':
            case 'sword_s10':
            case 'sword_s11':
            case 'sword_s12':
            case 'sword_s13':
            case 'sword_s15':
            case 'sword_s16':
            case 'sword_s17':
            case 'sword_s18':
            case 'sword_s19':
            case 'sword_s20':
            case 'sword_s21':
            case 'magic_1':
            case 'magic_2':
            case 'magic_3':
            case 'magic_4':
            case 'magic_5':
            case 'magic_s1':
            case 'magic_s2':
            case 'magic_s3':
            case 'magic_s4':
            case 'magic_s5':
            case 'magic_s6':
            case 'magic_s7':
            case 'magic_s8':
            case 'magic_s9':
            case 'magic_s10':
            case 'magic_s11':
            case 'magic_s12':
            case 'magic_s13':
            case 'magic_s14':
            case 'magic_s15':
            case 'magic_s16':
            case 'magic_s17':
            case 'magic_s18':
            case 'magic_s19':
            case 'magic_s20':
            case 'alchemy_s1':
            case 'alchemy_s2':
            case 'alchemy_s3':
            case 'alchemy_s4':
            case 'alchemy_s5':
            case 'alchemy_s6':
            case 'alchemy_s7':
            case 'alchemy_s8':
            case 'alchemy_s9':
            case 'alchemy_s10':
            case 'alchemy_s11':
            case 'alchemy_s12':
            case 'alchemy_s13':
            case 'alchemy_s14':
            case 'alchemy_s15':
            case 'alchemy_s16':
            case 'alchemy_s17':
            case 'alchemy_s18':
            case 'alchemy_s19':
            case 'perk_1':
            case 'perk_1_day_ability':
            case 'perk_1_night_ability':
            case 'perk_2':
            case 'perk_3':
            case 'perk_4':
            case 'perk_5':
            case 'perk_6':
            case 'perk_7':
            case 'perk_10':
            case 'perk_11':
            case 'perk_12':
            LearnSkillForW3Player(chosenTextElement.textItemName); break;
            default : thePlayer.inv.AddAnItem(chosenTextElement.textItemName,spawnCount);
            }
    }
    private function DoSpawn()
    {

        switch(chosenTextElement.textItemName)
        {
              
            case 'skillpoints': GetWitcherPlayer().AddPoints(ESkillPoint, spawnCount, true); break;
            case 'moneyx100': thePlayer.AddMoney(spawnCount*100); break;
            case 'removeMoneyx100': thePlayer.RemoveMoney(spawnCount*100); break;
            case 'Half With Tail Hairstyle': 	        
            newID = thePlayer.inv.AddAnItem('Half With Tail Hairstyle',spawnCount);
            thePlayer.EquipItem(newID[0]);break;
            case 'Shaved With Tail Hairstyle':
            newID = thePlayer.inv.AddAnItem('Shaved With Tail Hairstyle',spawnCount);
            thePlayer.EquipItem(newID[0]);break;
            case 'Long Loose Hairstyle':
            newID = thePlayer.inv.AddAnItem('Long Loose Hairstyle',spawnCount);
            thePlayer.EquipItem(newID[0]);break;
            case 'Short Loose Hairstyle':
            newID = thePlayer.inv.AddAnItem('Short Loose Hairstyle',spawnCount);
            thePlayer.EquipItem(newID[0]);break;
            case 'Mohawk With Ponytail Hairstyle':
            newID = thePlayer.inv.AddAnItem('Mohawk With Ponytail Hairstyle',spawnCount);
            thePlayer.EquipItem(newID[0]);break;
            case 'Nilfgaardian Hairstyle':
            newID = thePlayer.inv.AddAnItem('Nilfgaardian Hairstyle',spawnCount);
            thePlayer.EquipItem(newID[0]);break;
            case 'setlevel': SetLevelForW3Player();break;
            case 'levelup': LevelUpForW3Player();break;
            case 'addExpx100': GetWitcherPlayer().AddPoints(EExperiencePoint, spawnCount * 100, false );break;
            case 'spawnbarrel': SpawnBarrelsForW3Player();break;
            case 'spawnbees': SpawnBeesForW3Player();break;
            case 'addkeys': SpawnKeysForW3Player();break;
            case 'activateAllGlossary':ActivateAllGloassaryForW3Player();break;
            case 'addallrepairkits': GiveAllRepairKitsForW3Player();break;
            case 'addFTmaps': GiveFTMapsForW3Player();break;
            case 'mutagenitems': GiveMutagensForW3Player();break;
            case 'addbombs': GiveBombsForW3Player(true);break;
            case 'addbolts': GiveBoltsForW3Player();break;
            case 'addcraft': GiveCraftingItemsForW3Player();break;
            case 'addsteelswords': GiveSteelSwordsForW3Player();break;
            case 'addwolfdlc': AddWolfDlcForW3Player();break;
            case 'addsilverswords': AddSilverSwordsForW3Player();break;
            case 'addcrossbows': AddCrossBowsForW3Player();break;
            case 'addarmors': AddArmorForW3Player();break;
            case 'addpants': AddPantsForW3Player();break;
            case 'addhorseitems': AddHorseItemsForW3Player();break;
            case 'addmiscs': AddMiscForW3Player();break;
            case 'addbooks': AddBooksForW3Player();break;
            case 'addboots': AddBootsForW3Player();break;
            case 'addgloves': AddGlovesForW3Player();break;
            case 'addsets': AddSetsForW3Player();break;
            case 'addloreitems': AddLoreForW3Player();break;
            case 'addloreitems2': AddLore2ForW3Player();break;
            case 'addfoods': AddFoodForW3Player();break;
            case 'adddrinks': AddDrinksForW3Player();break;
            case 'addupgrades': AddUpgradesForW3Player();break;
            case 'learnallschematics': AddCraftingSchematicForW3Player();break;
            case 'addsecondary': AddSecondaryRangedThrowable();break;
            case 'adddyes': AddDyeForW3Player();break;
            case 'mutagenthings': AddMutagenThingsForW3Player();break;
            case 'adddyes': AddRecipesForW3Player();break;
            case 'adquestitems': AddQuestItemsForW3Player();break;
            case 'adquestitems2': AddQuestItems2ForW3Player();break;
            case 'adddyes': AddDyeForW3Player();break;
            case 'addallgwintcards': AddAllGwentCardsForW3Player(); break;
            case 'resetall': GetWitcherPlayer().Debug_ClearCharacterDevelopment(); break;
            case 'killme': thePlayer.Kill( 'Debug', true ); break;
            case 'removeall': 	GetWitcherPlayer().GetInventory().RemoveAllItems(); break;
            case 'witchcraft': theGame.GetDefinitionsManager().TestWitchcraft(); break;
            case 'toxicity0' : MakeToxicityZeroForW3Player();break;
            case 'DamageBuff':
            case 'ForceCriticalHits':
            case 'ForceFinisher':
            case 'ForceDismemberment':
            case 'ConAthletic':
            case 'ConImmortal':
            case 'StatsRangedSuperLame':
            case 'Rune veles lesser _Stats':
            case 'Rune veles _Stats':
            case 'Rune veles greater _Stats':
            case 'HorseBag1':
            case 'HorseBag2':
            case 'HorseBag3':  
            case 'MistCharge':
            case 'attack_explosion':
            case 'AardShrineBuff':
            // case 'CiriBlink': 
            // case 'CiriCharge': 
            // case 'Ciri_Rage': 
            // case 'Ciri_Q205': 
            // case 'Ciri_Q305': 
            // case 'Ciri_Q403': 
            // case 'Ciri_Q111': 
            // case 'Ciri_Q501': 
            thePlayer.AddAbility(chosenTextElement.textItemName); break;
            case 'rmvDamageBuff':thePlayer.RemoveAbility('DamageBuff'); break;
            case 'rmvForceCriticalHits':thePlayer.RemoveAbility('ForceCriticalHits'); break;
            case 'rmvForceFinisher':thePlayer.RemoveAbility('ForceFinisher'); break;
            case 'rmvForceDismemberment':thePlayer.RemoveAbility('ForceDismemberment'); break;
            case 'rmvConAthletic':thePlayer.RemoveAbility('ConAthletic'); break;
            case 'rmvConImmortal':thePlayer.RemoveAbility('ConImmortal'); break;
            case 'rmvStatsRangedSuperLame':thePlayer.RemoveAbility('StatsRangedSuperLame'); break;
            case 'rmvRune veles lesser _Stats':thePlayer.RemoveAbility('Rune veles lesser _Stats'); break;
            case 'rmvRune veles _Stats':thePlayer.RemoveAbility('Rune veles _Stats'); break;
            case 'rmvRune veles greater _Stats':thePlayer.RemoveAbility('Rune veles greater _Stats'); break;
            case 'rmvHorseBag1':thePlayer.RemoveAbility('HorseBag1'); break;
            case 'rmvHorseBag2':thePlayer.RemoveAbility('HorseBag2'); break;
            case 'rmvHorseBag3':thePlayer.RemoveAbility('HorseBag3'); break;
            case 'rmvMistCharge':thePlayer.RemoveAbility('MistCharge'); break;
            case 'rmvattack_explosion':thePlayer.RemoveAbility('attack_explosion'); break;
            case 'rmvAardShrineBuff':thePlayer.RemoveAbility('AardShrineBuff'); break;
            case 'horse': InstantMountForW3Player(chosenTextElement.textItemName);break;
            case 'gotoWyzima':
            theGame.ScheduleWorldChangeToMapPin( "levels\wyzima_castle\wyzima_castle.w2w", '' );
			theGame.RequestAutoSave( "fast travel", true );break;
            case 'gotoNovigrad':
			theGame.ScheduleWorldChangeToMapPin( "levels\novigrad\novigrad.w2w", '' );
			theGame.RequestAutoSave( "fast travel", true );break;
            case 'gotoSkellige': 
            theGame.ScheduleWorldChangeToMapPin( "levels\skellige\skellige.w2w", '' );
			theGame.RequestAutoSave( "fast travel", true );break;
            case 'gotoKaerMohren':
            theGame.ScheduleWorldChangeToMapPin( "levels\kaer_morhen\kaer_morhen.w2w", '' );
			theGame.RequestAutoSave( "fast travel", true );break;
            case 'gotoProlog':
            theGame.ScheduleWorldChangeToMapPin( "levels\prolog_village\prolog_village.w2w", '' );
			theGame.RequestAutoSave( "fast travel", true );break;
            case 'gotoPrologWinter':
            theGame.ScheduleWorldChangeToMapPin( "levels\prolog_village_winter\prolog_village.w2w", '' );
			theGame.RequestAutoSave( "fast travel", true );break;
            case 'x0.0625': theGame.SetHoursPerMinute(0.0625);break;
            case 'x0.125': theGame.SetHoursPerMinute(0.125);break;
            case 'x0.25': theGame.SetHoursPerMinute( 0.25);break;
            case 'x0.5': theGame.SetHoursPerMinute( 0.5);break;
            case 'x1': theGame.SetHoursPerMinute( 1);break;
            case 'x2': theGame.SetHoursPerMinute( 2);break;
            case 'x4': theGame.SetHoursPerMinute( 4);break;
            case 'x8': theGame.SetHoursPerMinute( 8);break;
            case 'x16': theGame.SetHoursPerMinute( 16);break;
            case 'x0.0625T': theGame.SetTimeScale(0.0625, theGame.GetTimescaleSource(ETS_CFM_On), theGame.GetTimescalePriority(ETS_CFM_On), true );break;
            case 'x0.125T': theGame.SetTimeScale(0.125, theGame.GetTimescaleSource(ETS_CFM_On), theGame.GetTimescalePriority(ETS_CFM_On), true );break;
            case 'x0.25T': theGame.SetTimeScale(0.25, theGame.GetTimescaleSource(ETS_CFM_On), theGame.GetTimescalePriority(ETS_CFM_On), true );break;
            case 'x0.5T': theGame.SetTimeScale(0.5, theGame.GetTimescaleSource(ETS_CFM_On), theGame.GetTimescalePriority(ETS_CFM_On), true );break;
            case 'x1T': theGame.SetTimeScale(1, theGame.GetTimescaleSource(ETS_CFM_On), theGame.GetTimescalePriority(ETS_CFM_On), true );break;
            case 'x2T': theGame.SetTimeScale(2, theGame.GetTimescaleSource(ETS_CFM_On), theGame.GetTimescalePriority(ETS_CFM_On), true );break;
            case 'x4T': theGame.SetTimeScale(4, theGame.GetTimescaleSource(ETS_CFM_On), theGame.GetTimescalePriority(ETS_CFM_On), true );break;
            case 'x8T': theGame.SetTimeScale(8, theGame.GetTimescaleSource(ETS_CFM_On), theGame.GetTimescalePriority(ETS_CFM_On), true );break;
            case 'x16T':theGame.SetTimeScale(16, theGame.GetTimescaleSource(ETS_CFM_On), theGame.GetTimescalePriority(ETS_CFM_On), true );break;
            case 'mutall': mutall_internal(); break;
            case 'SecretGwent': StartGwentForW3Player(1); break;
            case 'StaminaPony': StaminaPonyInternal(!FactsDoesExist("debug_fact_stamina_pony")); break;
            case 'LikeABoss': LikeABossForW3Player();break;
            case 'DLikeABoss': DisableLikeABossForW3Player();break;
            case 'EDM_Easy':temp_difflevel(EDM_Easy);break;
            case 'EDM_Medium':temp_difflevel(EDM_Medium);break;
            case 'EDM_Hard':temp_difflevel(EDM_Hard);break;
            case 'EDM_Hardcore':temp_difflevel(EDM_Hardcore);break;
            case 'god_mod_enabled': EnableGodModeForW3Player();break;
            case 'god_mod_disabled': DisableGodModeForW3Player();break;
            case 'unlimited_stamina': EnableUnlimitedStaminaForW3Player();break;
            case 'disable_unlimited_stamina': DisableUnlimitedStaminaForW3Player();break;
            case 'healme': HealForW3Player();break;
            case 'AllowFT': AllowFastTravelForW3Player();break;
            case 'ShowAllFT': ShowAllFastTravelPointsForW3Player();break;
            case 'ShowKnownPins': ShowKnownPinsForW3Player();break;
            case 'ShowPins': ShowPinsForW3Player();break;
            case 'DisableAllowFT': AllowFastTravelForW3Player();break;
            case 'DisableShowAllFT': ShowAllFastTravelPointsForW3Player();break;
            case 'DisableShowKnownPins': ShowKnownPinsForW3Player();break;
            case 'DisableShowPins': ShowPinsForW3Player();break;
            case 'Cat': NightVisionForW3Player();break;
            case 'disableCat': DisableNightVisionForW3Player();break;
            case 'Drunk': DrunkModeForW3Player();break;
            case 'disableDrunk': DisableDrunkModeForW3Player();break;
            case 'Shave': ShaveForW3Player();break;
            case 'killall': KillAllForW3Player();break;
            case 'pause':theGame.Pause( "testpause" );break;
            case 'unpause':theGame.Unpause( "testpause" );break;
            case 'potions':AddPotionsForW3Player();break;
            case 'oils': AddOilsForW3Player();break;
            case 'carrycapacity': IncreaseCarryCapacityForW3Player(); break;
            // case 'playciri': SwitchCharacterToCiri();break;
            // case 'playgeralt': SwitchCharacterToGeralt();break;
            //default : thePlayer.inv.AddAnItem(chosenTextElement.textItemName,spawnCount);
            
        }
    
    }
    function AddOilsForW3Player()
    {
        var inv : CInventoryComponent;
	var arr : array<SItemUniqueId>;
	
	inv = thePlayer.inv;
	
	arr = inv.AddAnItem('Beast Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Beast Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Beast Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Cursed Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Cursed Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Cursed Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Hanged Man Venom 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Hanged Man Venom 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Hanged Man Venom 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Hybrid Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Hybrid Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Hybrid Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Insectoid Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Insectoid Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Insectoid Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Magicals Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Magicals Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Magicals Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Necrophage Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Necrophage Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Necrophage Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Specter Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Specter Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Specter Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Vampire Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Vampire Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Vampire Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Draconide Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Draconide Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Draconide Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Ogre Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Ogre Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Ogre Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Relic Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Relic Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Relic Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
    }
    function IncreaseCarryCapacityForW3Player()
    {
        //var effectManager				: W3EffectManager;
        //if( effectManager && effectManager.IsReady() )
			//effectManager.RemoveAllEffectsOfType(EET_OverEncumbered);
        //RemoveAllBuffsOfType(EET_OverEncumbered);
        	/*public function GetMaxRunEncumbrance(out usesHorseBonus : bool) : float
	{
		var value : float;

		return 999999;
		
		value = CalculateAttributeValue(GetHorseManager().GetHorseAttributeValue('encumbrance', false));
		usesHorseBonus = (value > 0);
		value += CalculateAttributeValue( GetAttributeValue('encumbrance') );
		
		return value;
	}*/
    }
    function MakeToxicityZeroForW3Player()
    {
        thePlayer.ForceSetStat(BCS_Toxicity, 0);
    }
    function DisableAllowFastTravelForW3Player()
    {
        theGame.GetCommonMapManager().DBG_AllowFT(false);
    }
    function DisableShowAllFastTravelPointsForW3Player()
    {
        theGame.GetCommonMapManager().DBG_ShowAllFT(false);
    }
    function DisableShowKnownPinsForW3Player()
    {
        theGame.GetCommonMapManager().DBG_ShowKnownPins(false);
    }
    function DisableShowPinsForW3Player()
    {
        theGame.GetCommonMapManager().DBG_ShowPins(false);
    }
    function DisableUnlimitedStaminaForW3Player()
    {
        if ( thePlayer.IsImmortal() )
            thePlayer.CheatGod2( false );
    }
    function EnableUnlimitedStaminaForW3Player()
    {
        if ( !thePlayer.IsImmortal() )
            thePlayer.CheatGod2( true );
    }
    function HealForW3Player()
    {
        var max, current : float;
        max = thePlayer.GetStatMax(BCS_Vitality);
        current = thePlayer.GetStat(BCS_Vitality);
        thePlayer.ForceSetStat(BCS_Vitality, MinF(max, current + max * 100 / 100));
    }
    function AllowFastTravelForW3Player()
    {
        theGame.GetCommonMapManager().DBG_AllowFT(true);
    }
    function ShowAllFastTravelPointsForW3Player()
    {
        theGame.GetCommonMapManager().DBG_ShowAllFT(true);
    }
    function ShowKnownPinsForW3Player()
    {
        theGame.GetCommonMapManager().DBG_ShowKnownPins(true);
    }
    function ShowPinsForW3Player()
    {
        theGame.GetCommonMapManager().DBG_ShowPins(true);
    }
    function NightVisionForW3Player()
    {
        EnableCatViewFx( 1.0f );	
        SetPositionCatViewFx( Vector(0,0,0,0) , true );	
    }
    function DisableNightVisionForW3Player()
    {
        DisableCatViewFx( 1.0f );	
    }
    function DrunkModeForW3Player()
    {
        EnableDrunkFx( 1.0f );
    }
    function DisableDrunkModeForW3Player()
    {
        DisableDrunkFx( 1.0f );	
    }
    function ShaveForW3Player()
    {
        acs = thePlayer.GetComponentsByClassName( 'CHeadManagerComponent' );
        ( ( CHeadManagerComponent ) acs[0] ).Shave();
    }
    function KillAllForW3Player()
    {
        var enemies: array<CActor>;
		var i, enemiesSize : int;
		var npc : CNewNPC;

        enemies = GetActorsInRange(thePlayer, 20);
        
        enemiesSize = enemies.Size();
        
        for( i = 0; i < enemiesSize; i += 1 )
        {
            npc = (CNewNPC)enemies[i];
            
            if( npc )
            {
                if( npc.GetAttitude( thePlayer ) == AIA_Hostile )
                {
                    npc.Kill( 'Debug' );
                }
            }
        }
		
    }
    function EnableGodModeForW3Player()
    {
        if( !thePlayer.IsInvulnerable() )
        {
            GetWitcherPlayer().DisplayHudMessage("enabled i thunk");
            thePlayer.SetImmortalityMode(AIM_Invulnerable, AIC_Default, true);
            thePlayer.SetCanPlayHitAnim(false);
            thePlayer.AddBuffImmunity_AllNegative('god', true);
            StaminaBoyInternal(true);
            LogCheats("God is now ON");
        }
    }
    function DisableGodModeForW3Player()
    {
        if(thePlayer.IsInvulnerable() )
        {		
            GetWitcherPlayer().DisplayHudMessage("disabled i thunk");
            thePlayer.SetImmortalityMode(AIM_None, AIC_Default, true);
            thePlayer.SetCanPlayHitAnim(true);
            thePlayer.RemoveBuffImmunity_AllNegative('god');
            StaminaBoyInternal(false);
            LogCheats("God is now OFF");
        }
    }
    function InstantMountForW3Player(vehicleTag : name)
    {

        var entities : array<CGameplayEntity>;
        var entity : CGameplayEntity;
        var vehicle : CVehicleComponent;
        
        FindGameplayEntitiesInRange(entities,thePlayer,1000,1,vehicleTag);
        entity = entities[0];
        
        if ( entity )
        {
            vehicle = (CVehicleComponent)(entity.GetComponentByClassName('CVehicleComponent'));
            if ( vehicle )
            {
                vehicle.Mount( thePlayer, VMT_ImmediateUse, EVS_driver_slot );
            }
        }

    }
    function LearnSkillForW3Player(skillName : name)
    {
        var i : int;
	    var skills : array<SSkill>;

        if(skillName == 'all')
        {
            skills = thePlayer.GetPlayerSkills();
            for(i=0; i<skills.Size(); i+=1)
            {
                thePlayer.AddSkill(skills[i].skillType);
            }
        }
        else
        {
            thePlayer.AddSkill(SkillNameToEnum(skillName));
        }
    }
   
    function GetEffectTypeByName(effectName: CName) : EEffectType
    {
        switch (effectName)
        {
            case 'EET_AbilityOnLowHealth': return EET_AbilityOnLowHealth;
            case 'EET_AdrenalineDrain': return EET_AdrenalineDrain;
            case 'EET_AirBoost': return EET_AirBoost;
            case 'EET_AirDrain': return EET_AirDrain;
            case 'EET_AirDrainDive': return EET_AirDrainDive;
            case 'EET_AutoAirRegen': return EET_AutoAirRegen;
            case 'EET_AutoEssenceRegen': return EET_AutoEssenceRegen;
            case 'EET_AutoMoraleRegen': return EET_AutoMoraleRegen;
            case 'EET_AutoPanicRegen': return EET_AutoPanicRegen;
            case 'EET_AutoStaminaRegen': return EET_AutoStaminaRegen;
            case 'EET_AutoSwimmingStaminaRegen': return EET_AutoSwimmingStaminaRegen;
            case 'EET_AutoVitalityRegen': return EET_AutoVitalityRegen;
            case 'EET_AxiiGuardMe': return EET_AxiiGuardMe;
            case 'EET_BattleTrance': return EET_BattleTrance;
            case 'EET_BlackBlood': return EET_BlackBlood;
            case 'EET_Bleeding': return EET_Bleeding;
            case 'EET_BleedingTracking': return EET_BleedingTracking;
            case 'EET_Blindness': return EET_Blindness;
            case 'EET_Blizzard': return EET_Blizzard;
            case 'EET_BoostedEssenceRegen': return EET_BoostedEssenceRegen;
            case 'EET_BoostedStaminaRegen': return EET_BoostedStaminaRegen;
            case 'EET_Burning': return EET_Burning;
            case 'EET_Cat': return EET_Cat;
            case 'EET_Choking': return EET_Choking;
            case 'EET_Confusion': return EET_Confusion;
            case 'EET_CounterStrikeHit': return EET_CounterStrikeHit;
            case 'EET_DoTHPRegenReduce': return EET_DoTHPRegenReduce;
            case 'EET_DoppelgangerEssenceRegen': return EET_DoppelgangerEssenceRegen;
            case 'EET_Drowning': return EET_Drowning;
            case 'EET_Drunkenness': return EET_Drunkenness;
            case 'EET_Edible': return EET_Edible;
            case 'EET_EnhancedArmor': return EET_EnhancedArmor;
            case 'EET_EnhancedWeapon': return EET_EnhancedWeapon;
            case 'EET_Fact': return EET_Fact;
            case 'EET_FireAura': return EET_FireAura;
            case 'EET_Frozen': return EET_Frozen;
            case 'EET_FullMoon': return EET_FullMoon;
            case 'EET_GoldenOriole': return EET_GoldenOriole;
            case 'EET_HeavyKnockdown': return EET_HeavyKnockdown;
            case 'EET_Hypnotized': return EET_Hypnotized;
            case 'EET_IgnorePain': return EET_IgnorePain;
            case 'EET_Immobilized': return EET_Immobilized;
            case 'EET_KillerWhale': return EET_KillerWhale;
            case 'EET_Knockdown': return EET_Knockdown;
            case 'EET_KnockdownTypeApplicator': return EET_KnockdownTypeApplicator;
            case 'EET_LongStagger': return EET_LongStagger;
            case 'EET_LowHealth': return EET_LowHealth;
            case 'EET_MariborForest': return EET_MariborForest;
            case 'EET_Mutagen01': return EET_Mutagen01;
            case 'EET_Mutagen02': return EET_Mutagen02;
            case 'EET_Mutagen03': return EET_Mutagen03;
            case 'EET_Mutagen04': return EET_Mutagen04;
            case 'EET_Mutagen05': return EET_Mutagen05;
            case 'EET_Mutagen06': return EET_Mutagen06;
            case 'EET_Mutagen07': return EET_Mutagen07;
            case 'EET_Mutagen08': return EET_Mutagen08;
            case 'EET_Mutagen09': return EET_Mutagen09;
            case 'EET_Mutagen10': return EET_Mutagen10;
            case 'EET_Mutagen11': return EET_Mutagen11;
            case 'EET_Mutagen12': return EET_Mutagen12;
            case 'EET_Mutagen13': return EET_Mutagen13;
            case 'EET_Mutagen14': return EET_Mutagen14;
            case 'EET_Mutagen15': return EET_Mutagen15;
            case 'EET_Mutagen16': return EET_Mutagen16;
            case 'EET_Mutagen17': return EET_Mutagen17;
            case 'EET_Mutagen18': return EET_Mutagen18;

            case 'EET_Mutagen19': return EET_Mutagen19;
            case 'EET_Mutagen20': return EET_Mutagen20;
            case 'EET_Mutagen21': return EET_Mutagen21;
            case 'EET_Mutagen22': return EET_Mutagen22;
            case 'EET_Mutagen23': return EET_Mutagen23;
            case 'EET_Mutagen24': return EET_Mutagen24;
            case 'EET_Mutagen25': return EET_Mutagen25;
            case 'EET_Mutagen26': return EET_Mutagen26;
            case 'EET_Mutagen27': return EET_Mutagen27;
            case 'EET_Mutagen28': return EET_Mutagen28;
            case 'EET_OverEncumbered': return EET_OverEncumbered;
            case 'EET_Paralyzed': return EET_Paralyzed;
            case 'EET_PetriPhiltre': return EET_PetriPhiltre;
            case 'EET_PheromoneBear': return EET_PheromoneBear;
            case 'EET_PheromoneDrowner': return EET_PheromoneDrowner;
            case 'EET_PheromoneNekker': return EET_PheromoneNekker;
            case 'EET_Poison': return EET_Poison;
            case 'EET_PoisonCritical': return EET_PoisonCritical;
            case 'EET_Pull': return EET_Pull;
            case 'EET_Ragdoll': return EET_Ragdoll;
            case 'EET_ShrineAard': return EET_ShrineAard;
            case 'EET_ShrineAxii': return EET_ShrineAxii;
            case 'EET_ShrineIgni': return EET_ShrineIgni;
            case 'EET_ShrineQuen': return EET_ShrineQuen;
            case 'EET_ShrineYrden': return EET_ShrineYrden;
            case 'EET_SilverDust': return EET_SilverDust;
            case 'EET_Slowdown': return EET_Slowdown;
            case 'EET_SlowdownAxii': return EET_SlowdownAxii;
            case 'EET_SlowdownFrost': return EET_SlowdownFrost;
            case 'EET_Snowstorm': return EET_Snowstorm;
            case 'EET_SnowstormQ403': return EET_SnowstormQ403;
            case 'EET_Stagger': return EET_Stagger;
            case 'EET_StaggerAura': return EET_StaggerAura;
            case 'EET_StaminaDrain': return EET_StaminaDrain;
            case 'EET_StaminaDrainSwimming': return EET_StaminaDrainSwimming;
            case 'EET_Swallow': return EET_Swallow;
            case 'EET_Swarm': return EET_Swarm;
            case 'EET_TawnyOwl': return EET_TawnyOwl;
            case 'EET_Thunderbolt': return EET_Thunderbolt;
            case 'EET_Toxicity': return EET_Toxicity;
            case 'EET_Undefined': return EET_Undefined;
            case 'EET_Unused1': return EET_Unused1;
            case 'EET_VitalityDrain': return EET_VitalityDrain;
            case 'EET_WeatherBonus': return EET_WeatherBonus;
            case 'EET_WellFed': return EET_WellFed;
            case 'EET_WellHydrated': return EET_WellHydrated;
            case 'EET_WhiteHoney': return EET_WhiteHoney;
            case 'EET_WhiteRaffardDecoction': return EET_WhiteRaffardDecoction;
            case 'EET_WitchHypnotized': return EET_WitchHypnotized;
            case 'EET_WraithBlindness': return EET_WraithBlindness;
            case 'EET_YrdenHealthDrain': return EET_YrdenHealthDrain;

        }
    }
    /*
    
    */
    function GiveBuffForW3Player(type : EEffectType, optional duration : float)
    {
        var params : SCustomEffectParams;

        if(duration > 0)
        {
            params.effectType = type;
            //params.sourceName = src;
            params.duration = duration;
            thePlayer.AddEffectCustom(params);
        }

    }
    function AddAllGwentCardsForW3Player()
    {
        AddDeckNeutral();
        AddDeckNK();
        AddDeckNilf();
        AddDeckScoia();
        AddDeckMonst();
        AddDeckSke();
        thePlayer.inv.AddAnItem( 'gwint_card_impera_brigade',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_cynthia',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_letho',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_archer_support',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_siege_engineer',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_assire',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_fringilla',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_nauzicaa',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_black_archer',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_siege_support',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_menno',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_imlerith',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_katakan',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_bruxa',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_garkain',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_fleder',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_ghoul',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_nekker',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_grave_hag',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_fire_elemental',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_fogling',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_wyvern',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_leshan',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_witch_velen',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_arachas',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_saskia',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_havekar_support',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_mahakam',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_isengrim',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_havekar_nurse',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_barclay',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_dennis',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_elf_skirmisher',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_dol_infantry',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_vrihedd_brigade',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_thaler',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_blue_stripes',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_poor_infantry',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_trebuchet',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_natalis',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_esterad',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_siege_tower',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_crinfrid',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_kaedwen',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_witch_hunters',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_ballista_officer',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_ballista',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_stennis',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_siegfried',spawnCount);
        thePlayer.inv.AddAnItem( 'gwint_card_king_bran_bronze',spawnCount );
        thePlayer.inv.AddAnItem( 'gwint_card_hemdal',spawnCount );
        thePlayer.inv.AddAnItem( 'gwint_card_hjalmar',spawnCount );
        thePlayer.inv.AddAnItem( 'gwint_card_cerys',spawnCount );
        thePlayer.inv.AddAnItem( 'gwint_card_ermion',spawnCount );
        thePlayer.inv.AddAnItem( 'gwint_card_draig',spawnCount );
        thePlayer.inv.AddAnItem( 'gwint_card_holger_blackhand',spawnCount );
        thePlayer.inv.AddAnItem( 'gwint_card_madman_lugos',spawnCount );
        thePlayer.inv.AddAnItem( 'gwint_card_donar_an_hindar',spawnCount );
        thePlayer.inv.AddAnItem( 'gwint_card_udalryk',spawnCount );
        thePlayer.inv.AddAnItem( 'gwint_card_birna_bran',spawnCount );
        thePlayer.inv.AddAnItem( 'gwint_card_blueboy_lugos',spawnCount );
        thePlayer.inv.AddAnItem( 'gwint_card_svanrige',spawnCount );
        thePlayer.inv.AddAnItem( 'gwint_card_olaf',spawnCount );
        thePlayer.inv.AddAnItem( 'gwint_card_berserker',spawnCount );
        thePlayer.inv.AddAnItem( 'gwint_card_young_berserker',spawnCount );
        thePlayer.inv.AddAnItem( 'gwint_card_clan_an_craite_warrior',spawnCount );
        thePlayer.inv.AddAnItem( 'gwint_card_clan_tordarroch_armorsmith',spawnCount );
        thePlayer.inv.AddAnItem( 'gwint_card_clan_heymaey_skald',spawnCount );
        thePlayer.inv.AddAnItem( 'gwint_card_light_drakkar',spawnCount );
        thePlayer.inv.AddAnItem( 'gwint_card_war_drakkar',spawnCount );
        thePlayer.inv.AddAnItem( 'gwint_card_clan_brokvar_archer',spawnCount );
        thePlayer.inv.AddAnItem( 'gwint_card_clan_drummond_shieldmaiden',spawnCount );
        thePlayer.inv.AddAnItem( 'gwint_card_clan_dimun_pirate',spawnCount );
        thePlayer.inv.AddAnItem( 'gwint_card_cock',spawnCount );
        thePlayer.inv.AddAnItem( 'gwint_card_mushroom',spawnCount );
    }
    function AddLore2ForW3Player()
    {

		thePlayer.inv.AddAnItem('Laundry stick',spawnCount);
		thePlayer.inv.AddAnItem('Laundry pole',spawnCount);
        thePlayer.inv.AddAnItem('q701_duchess_summons',spawnCount);
		thePlayer.inv.AddAnItem('q701_beast_picture_01',spawnCount);
		thePlayer.inv.AddAnItem('q701_beast_picture_02',spawnCount);
		thePlayer.inv.AddAnItem('q701_beast_picture_03',spawnCount);
		thePlayer.inv.AddAnItem('q701_corvo_bianco_deed',spawnCount);
		thePlayer.inv.AddAnItem('q701_victim_handkarchief',spawnCount);
		thePlayer.inv.AddAnItem('q701_coin_pouch',spawnCount);
		thePlayer.inv.AddAnItem('q701_swan_item',spawnCount);
		thePlayer.inv.AddAnItem('q701_unicorn_item',spawnCount);
		thePlayer.inv.AddAnItem('q701_cookie_lure',spawnCount);
		thePlayer.inv.AddAnItem('q701_apple_lure',spawnCount);
		thePlayer.inv.AddAnItem('q701_carrot_basket',spawnCount);
		thePlayer.inv.AddAnItem('q701_grain_cup',spawnCount);
		thePlayer.inv.AddAnItem('q701_gardens_lost_ring',spawnCount);
		thePlayer.inv.AddAnItem('q701_crayfish_soup',spawnCount);
		thePlayer.inv.AddAnItem('q701_pate',spawnCount);
        thePlayer.inv.AddAnItem('q702_wight_gland',spawnCount);
		thePlayer.inv.AddAnItem('q702_wight_brew',spawnCount);
		thePlayer.inv.AddAnItem('q702_wicht_key',spawnCount);
		thePlayer.inv.AddAnItem('q702_wicht_fork',spawnCount);
		thePlayer.inv.AddAnItem('q702_fly',spawnCount);
		thePlayer.inv.AddAnItem('q702_leaflet',spawnCount);
		thePlayer.inv.AddAnItem('q702_graveir_lure',spawnCount);
		thePlayer.inv.AddAnItem('q702_victims_names',spawnCount);
		thePlayer.inv.AddAnItem('q702_blackmail_letter',spawnCount);
		thePlayer.inv.AddAnItem('q702_bootblack_prices',spawnCount);
		thePlayer.inv.AddAnItem('q702_knight_oath',spawnCount);
		thePlayer.inv.AddAnItem('q702_love_letter',spawnCount);
		thePlayer.inv.AddAnItem('q702_marlena_father_letter',spawnCount);
		thePlayer.inv.AddAnItem('q702_marlena_letter',spawnCount);
		thePlayer.inv.AddAnItem('q702_mill_order',spawnCount);
		thePlayer.inv.AddAnItem('q702_tesham_mutna_cell_letter',spawnCount);
		thePlayer.inv.AddAnItem('q702_toy_store_closing_order',spawnCount);
		thePlayer.inv.AddAnItem('q702_toy_store_letter',spawnCount);
		thePlayer.inv.AddAnItem('q702_regeneration_elixir',spawnCount);
		thePlayer.inv.AddAnItem('q702_spoon_key_message',spawnCount);
		thePlayer.inv.AddAnItem('q702_wight_diary',spawnCount);
		thePlayer.inv.AddAnItem('q702_comissariat',spawnCount);
		thePlayer.inv.AddAnItem('q702_regis_biography',spawnCount);
		thePlayer.inv.AddAnItem('q702_regis_sentences',spawnCount);
		thePlayer.inv.AddAnItem('q702_cage_breeding_humans',spawnCount);
		thePlayer.inv.AddAnItem('q702_monster_curses',spawnCount);
		thePlayer.inv.AddAnItem('q702_vampire_transcript',spawnCount);
		thePlayer.inv.AddAnItem('q702_spoon_key',spawnCount);
		thePlayer.inv.AddAnItem('q702_secret_urn',spawnCount);
		thePlayer.inv.AddAnItem('q702_marlena_dowry',spawnCount);
		thePlayer.inv.AddAnItem('q702_breeding_humans',spawnCount);
		thePlayer.inv.AddAnItem('Vampire Vision Potion',spawnCount);
        thePlayer.inv.AddAnItem('q703_bung',spawnCount);
		thePlayer.inv.AddAnItem('q703_geralt_wanted_note',spawnCount);
		thePlayer.inv.AddAnItem('q703_heart_of_toussaint',spawnCount);
		thePlayer.inv.AddAnItem('q703_mandragora_mask_male',spawnCount);
		thePlayer.inv.AddAnItem('q703_mandragora_mask_female',spawnCount);
		thePlayer.inv.AddAnItem('q703_paint_bomb_red',spawnCount);
		thePlayer.inv.AddAnItem('q703_unique_hunting_knife',spawnCount);
		thePlayer.inv.AddAnItem('q703_wooden_hammer',spawnCount);
		thePlayer.inv.AddAnItem('Geralt mandragora mask',spawnCount);
        thePlayer.inv.AddAnItem('th701_wg_initial_note',spawnCount);
		thePlayer.inv.AddAnItem('th701_wg_swords_note',spawnCount);
		thePlayer.inv.AddAnItem('th701_wg_pants_note',spawnCount);
		thePlayer.inv.AddAnItem('th701_bear_contract',spawnCount);
		thePlayer.inv.AddAnItem('th701_bear_journal',spawnCount);
		thePlayer.inv.AddAnItem('th701_bear_notes',spawnCount);
		thePlayer.inv.AddAnItem('th701_cat_journal',spawnCount);
		thePlayer.inv.AddAnItem('th701_cat_notes',spawnCount);
		thePlayer.inv.AddAnItem('th701_cat_witcher_notes',spawnCount);
		thePlayer.inv.AddAnItem('th701_gryphon_moreau_letter',spawnCount);
		thePlayer.inv.AddAnItem('th701_gryphon_moreau_journal',spawnCount);
		thePlayer.inv.AddAnItem('th701_gryphon_jerome_letter',spawnCount);
		thePlayer.inv.AddAnItem('th701_power_core',spawnCount);
		thePlayer.inv.AddAnItem('th701_wolf_journal',spawnCount);
		thePlayer.inv.AddAnItem('th701_wolf_witcher_note',spawnCount);
		thePlayer.inv.AddAnItem('th701_elven_journal',spawnCount);
		thePlayer.inv.AddAnItem('th701_portal_crystal',spawnCount);
		thePlayer.inv.AddAnItem('th701_coward_journal',spawnCount);
		thePlayer.inv.AddAnItem('th700_crypt_journal',spawnCount);
		thePlayer.inv.AddAnItem('th700_vault_journal',spawnCount);
		thePlayer.inv.AddAnItem('th700_lake_journal',spawnCount);
		thePlayer.inv.AddAnItem('th700_chapel_journal',spawnCount);
		thePlayer.inv.AddAnItem('th700_lake_fluff_note1',spawnCount);
		thePlayer.inv.AddAnItem('th700_lake_fluff_note2',spawnCount);
		thePlayer.inv.AddAnItem('th700_lake_fluff_note3',spawnCount);
		thePlayer.inv.AddAnItem('th700_preacher_bones',spawnCount);
        thePlayer.inv.AddAnItem('ff701_fist_fight_trophy',spawnCount);
        		thePlayer.inv.AddAnItem('cg700_base_deck',spawnCount);
		thePlayer.inv.AddAnItem('cg700_gwent_statue',spawnCount);
		thePlayer.inv.AddAnItem('cg700_letter_monniers_brother',spawnCount);
		thePlayer.inv.AddAnItem('cg700_letter_merchants',spawnCount);
		thePlayer.inv.AddAnItem('cg700_letter_purist',spawnCount);
        thePlayer.inv.AddAnItem('mq7024_alchemy_lab_note',spawnCount);
        		thePlayer.inv.AddAnItem('mq7023_letter_yen',spawnCount);
		thePlayer.inv.AddAnItem('mq7023_letter_triss',spawnCount);
		thePlayer.inv.AddAnItem('mq7023_letter_neutral',spawnCount);
		thePlayer.inv.AddAnItem('mq7023_map',spawnCount);
		thePlayer.inv.AddAnItem('mq7023_journal_laura',spawnCount);
		thePlayer.inv.AddAnItem('mq7023_gargoyle_hand',spawnCount);
		thePlayer.inv.AddAnItem('mq7023_portal_key',spawnCount);
		thePlayer.inv.AddAnItem('mq7023_megascope_crystal_2',spawnCount);
		thePlayer.inv.AddAnItem('mq7023_megascope_crystal',spawnCount);
		thePlayer.inv.AddAnItem('mq7023_megascope_crystal_4',spawnCount);
		thePlayer.inv.AddAnItem('mq7023_centipede_albumen_mutated',spawnCount); 
		thePlayer.inv.AddAnItem('mq7023_fluff_book_mutations',spawnCount);
		thePlayer.inv.AddAnItem('mq7023_fluff_book_scolopendromorphs',spawnCount);
        thePlayer.inv.AddAnItem('mq7021_treasure_map',spawnCount);
		thePlayer.inv.AddAnItem('mq7021_filter',spawnCount);
        thePlayer.inv.AddAnItem('mq7018_guild_contract_letter',spawnCount);
		thePlayer.inv.AddAnItem('mq7018_workers_letter_basilisk_alive',spawnCount);
		thePlayer.inv.AddAnItem('mq7018_workers_letter_basilisk_dead',spawnCount);
        thePlayer.inv.AddAnItem('mq7017_mushroom_potion',spawnCount);
		thePlayer.inv.AddAnItem('mq7017_pinastri_note',spawnCount);
        thePlayer.inv.AddAnItem('mq7015_reginalds_balls',spawnCount);
		thePlayer.inv.AddAnItem('mq7015_reginalds_figurine',spawnCount);
        thePlayer.inv.AddAnItem('mq7011_document',spawnCount);
        thePlayer.inv.AddAnItem('mq7010_still_note',spawnCount);
        		thePlayer.inv.AddAnItem('mq7009_painter_accessories',spawnCount);
		thePlayer.inv.AddAnItem('mq7009_painting_pose1',spawnCount);
		thePlayer.inv.AddAnItem('mq7009_painting_pose1_grif',spawnCount);
		thePlayer.inv.AddAnItem('mq7009_painting_pose2',spawnCount);
		thePlayer.inv.AddAnItem('mq7009_painting_pose2_grif',spawnCount);
		thePlayer.inv.AddAnItem('mq7009_painting_pose3',spawnCount);
		thePlayer.inv.AddAnItem('mq7009_painting_pose3_grif',spawnCount);
        		thePlayer.inv.AddAnItem('mq7007_tribute_food',spawnCount);
		thePlayer.inv.AddAnItem('mq7007_tribute_wine',spawnCount);
		thePlayer.inv.AddAnItem('mq7007_elven_shield',spawnCount);
		thePlayer.inv.AddAnItem('mq7007 Elven Sword',spawnCount);
		thePlayer.inv.AddAnItem('mq7007_elven_mask',spawnCount);
        thePlayer.inv.AddAnItem('mq7006_egg',spawnCount);
        		thePlayer.inv.AddAnItem('mq7004_knight_item',spawnCount);
		thePlayer.inv.AddAnItem('mq7004_scarf',spawnCount);
		thePlayer.inv.AddAnItem('mq7004_storybook',spawnCount);
		thePlayer.inv.AddAnItem('mq7004_note_01',spawnCount);
		thePlayer.inv.AddAnItem('mq7004_note_02',spawnCount);
		thePlayer.inv.AddAnItem('mq7004_note_03',spawnCount);
        		thePlayer.inv.AddAnItem('mq7002_love_letter_01',spawnCount);
		thePlayer.inv.AddAnItem('mq7002_love_letter_02',spawnCount);
        		thePlayer.inv.AddAnItem('mq7001_louis_urn',spawnCount);
		thePlayer.inv.AddAnItem('mq7001_margot_urn',spawnCount);
		thePlayer.inv.AddAnItem('mq7001_gwent_poems',spawnCount);
        		thePlayer.inv.AddAnItem('mh701_lost_locket',spawnCount);
		thePlayer.inv.AddAnItem('mh701_fresh_blood',spawnCount);
		thePlayer.inv.AddAnItem('mh701_usable_lur',spawnCount);
		thePlayer.inv.AddAnItem('mh701_work_schedule',spawnCount);
		thePlayer.inv.AddAnItem('mh701_wine_list',spawnCount);
        		thePlayer.inv.AddAnItem('sq703_peacock_feather',spawnCount);
		thePlayer.inv.AddAnItem('sq703_map',spawnCount);
		thePlayer.inv.AddAnItem('sq703_map_alternative',spawnCount);
		thePlayer.inv.AddAnItem('sq703_safari_picture',spawnCount);
		thePlayer.inv.AddAnItem('sq703_hunter_letter',spawnCount);
		thePlayer.inv.AddAnItem('sq703_wife_letter',spawnCount);
		thePlayer.inv.AddAnItem('sq703_accountance_book',spawnCount);
        		thePlayer.inv.AddAnItem('sq701_nest',spawnCount);
		thePlayer.inv.AddAnItem('sq701_geralt_shield',spawnCount);
		thePlayer.inv.AddAnItem('sq701_ravix_shield',spawnCount);
		thePlayer.inv.AddAnItem('sq701_tutorial_shield',spawnCount);
		thePlayer.inv.AddAnItem('sq701 Geralt of Rivia sword',spawnCount);
		thePlayer.inv.AddAnItem('sq701 Ravix of Fourhorn sword',spawnCount);
		thePlayer.inv.AddAnItem('sq701_geralt_armor',spawnCount);
		thePlayer.inv.AddAnItem('sq701_ravix_armor',spawnCount);
        thePlayer.inv.AddAnItem('Guard Lvl1 Armor 1',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl1 Armor 2',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Armor 1',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Armor 2',spawnCount);
		
		thePlayer.inv.AddAnItem('Guard Lvl2 Armor 1',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl2 Armor 2',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Armor 1',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Armor 2',spawnCount);
		
		thePlayer.inv.AddAnItem('Knight Geralt Armor 1',spawnCount);
		thePlayer.inv.AddAnItem('Knight Geralt Armor 2',spawnCount);
		thePlayer.inv.AddAnItem('Knight Geralt A Armor 1',spawnCount);
		thePlayer.inv.AddAnItem('Knight Geralt A Armor 2',spawnCount);
		thePlayer.inv.AddAnItem('Toussaint Armor 2',spawnCount);
		thePlayer.inv.AddAnItem('sq701_victory_laurels',spawnCount);
        		thePlayer.inv.AddAnItem('q705_ah_letter',spawnCount);
		thePlayer.inv.AddAnItem('q705_dirty_clothes',spawnCount);
		thePlayer.inv.AddAnItem('q705_soap',spawnCount);
		thePlayer.inv.AddAnItem('q705_medal',spawnCount);
		thePlayer.inv.AddAnItem('q705_white_roses',spawnCount);
		thePlayer.inv.AddAnItem('q705_mandragora',spawnCount);
		thePlayer.inv.AddAnItem('q705_prison_stash_note',spawnCount);
		thePlayer.inv.AddAnItem('q705_hammer_chisel',spawnCount);
		thePlayer.inv.AddAnItem('q705_pinup_poster',spawnCount);
		thePlayer.inv.AddAnItem('q705_geralt_mask',spawnCount);
        		thePlayer.inv.AddAnItem('q704_ft_bean_01',spawnCount);
		thePlayer.inv.AddAnItem('q704_ft_bean_02',spawnCount);
		thePlayer.inv.AddAnItem('q704_ft_bean_03',spawnCount);
		thePlayer.inv.AddAnItem('q704_ft_riding_hoods_hood',spawnCount);
		thePlayer.inv.AddAnItem('q704_ft_pipe',spawnCount);
		thePlayer.inv.AddAnItem('q704_ft_golden_egg',spawnCount);
		thePlayer.inv.AddAnItem('q704_ft_bottle_caps',spawnCount);
		thePlayer.inv.AddAnItem('q704_ft_corkscrew',spawnCount);
		thePlayer.inv.AddAnItem('q704_ft_fake_teeth',spawnCount);
		thePlayer.inv.AddAnItem('q704_ft_syanna_journal',spawnCount);
        		thePlayer.inv.AddAnItem('q704_orianas_vampire_key',spawnCount);
		thePlayer.inv.AddAnItem('q704_caretakers_letter',spawnCount);
		thePlayer.inv.AddAnItem('q704_mages_notebook',spawnCount);
		thePlayer.inv.AddAnItem('q704_mages_notes_01',spawnCount);
		thePlayer.inv.AddAnItem('q704_mages_notes_02',spawnCount);
		thePlayer.inv.AddAnItem('q704_vampire_offering',spawnCount);
		thePlayer.inv.AddAnItem('q704_vampire_lure_bolt',spawnCount);
    }
    function AddQuestItems2ForW3Player()
    {
        	thePlayer.inv.AddAnItem('mq2049_book_1',spawnCount);
	thePlayer.inv.AddAnItem('mq2049_book_2',spawnCount);
	thePlayer.inv.AddAnItem('mq2049_book_3',spawnCount);
	thePlayer.inv.AddAnItem('mq2049_book_4',spawnCount);
	thePlayer.inv.AddAnItem('mq2049_book_5',spawnCount);
	thePlayer.inv.AddAnItem('mq3002_hidden_messages_note_01',spawnCount);
	thePlayer.inv.AddAnItem('mq3002_hidden_messages_note_02',spawnCount);
	thePlayer.inv.AddAnItem('mq3002_hidden_messages_note_03',spawnCount);
	thePlayer.inv.AddAnItem('mq3017_reds_diary',spawnCount);
	thePlayer.inv.AddAnItem('mq3026_varese_invitation',spawnCount);
	thePlayer.inv.AddAnItem('mq3026_horse_racing_leaflet',spawnCount);
	thePlayer.inv.AddAnItem('mq3027_my_manifest',spawnCount);
	thePlayer.inv.AddAnItem('mq3027_fluff_book_1',spawnCount);
	thePlayer.inv.AddAnItem('mq3027_fluff_book_2',spawnCount);
	thePlayer.inv.AddAnItem('mq3027_fluff_book_3',spawnCount);
	thePlayer.inv.AddAnItem('mq3027_fluff_book_4',spawnCount);
	thePlayer.inv.AddAnItem('mq3027_letter',spawnCount);
	thePlayer.inv.AddAnItem('mq3030_trader_documents',spawnCount);
	thePlayer.inv.AddAnItem('mq3035_talar_notes',spawnCount);
	thePlayer.inv.AddAnItem('mq3036_rosas_letter',spawnCount);
	thePlayer.inv.AddAnItem('mq3036_rosas_second_letter',spawnCount);
	thePlayer.inv.AddAnItem('mq4001_book',spawnCount);
	thePlayer.inv.AddAnItem('mq4002_note',spawnCount);
	thePlayer.inv.AddAnItem('mq4003_letter',spawnCount);
	thePlayer.inv.AddAnItem('mq4005_note_1',spawnCount);
	thePlayer.inv.AddAnItem('mq4006_book',spawnCount);
	thePlayer.inv.AddAnItem('mh103_girls_journal',spawnCount);
	thePlayer.inv.AddAnItem('mh207_lighthouse_keeper_letter',spawnCount);
	thePlayer.inv.AddAnItem('mh301_merc_contract',spawnCount);
	thePlayer.inv.AddAnItem('mh305_doppler_letter',spawnCount);
	thePlayer.inv.AddAnItem('mh306_mages_journal',spawnCount);
	thePlayer.inv.AddAnItem('mh306_tenant_journal',spawnCount);
	thePlayer.inv.AddAnItem('lw_temerian_soldiers_journal',spawnCount);
	thePlayer.inv.AddAnItem('lw_sb13_note',spawnCount);
    }
    function AddQuestItemsForW3Player()
    {
        thePlayer.inv.AddAnItem('q001_crystal_skull',spawnCount);
	thePlayer.inv.AddAnItem('q101_hendrik_trapdoor_key',spawnCount);
	thePlayer.inv.AddAnItem('q202_navigator_horn',spawnCount);
	thePlayer.inv.AddAnItem('q103_medallion',spawnCount);
	thePlayer.inv.AddAnItem('q103_botch_blood',spawnCount);
	thePlayer.inv.AddAnItem('q103_wooden_doll',spawnCount);
	thePlayer.inv.AddAnItem('q103_talisman',spawnCount);
	thePlayer.inv.AddAnItem('q103_spinning_topc',spawnCount);
	thePlayer.inv.AddAnItem('q103_incense',spawnCount);
	thePlayer.inv.AddAnItem('q104_oillamp',spawnCount);
	thePlayer.inv.AddAnItem('q105_johnnys_dollc',spawnCount);
	thePlayer.inv.AddAnItem('q105_ravens_feather',spawnCount);
	thePlayer.inv.AddAnItem('q105_ritual_dagger',spawnCount);
	thePlayer.inv.AddAnItem('q105_soltis_ear',spawnCount);
	thePlayer.inv.AddAnItem('q105_witch_bones',spawnCount);
	thePlayer.inv.AddAnItem('q106_magic_communicator',spawnCount);
	thePlayer.inv.AddAnItem('q106_anabelle_remains',spawnCount);
	thePlayer.inv.AddAnItem('q106_anabelle_vial',spawnCount);	
	thePlayer.inv.AddAnItem('q107_doll1',spawnCount);
	thePlayer.inv.AddAnItem('q107_doll2',spawnCount);
	thePlayer.inv.AddAnItem('q107_doll3',spawnCount);
	thePlayer.inv.AddAnItem('q107_doll_anna',spawnCount);
	thePlayer.inv.AddAnItem('q107_doll5',spawnCount);
	thePlayer.inv.AddAnItem('q107_doll6',spawnCount);
	thePlayer.inv.AddAnItem('q108_necklet',spawnCount);
	thePlayer.inv.AddAnItem('q111_ergot_beer',spawnCount);
	thePlayer.inv.AddAnItem('q111_fugas_top_key',spawnCount);
	thePlayer.inv.AddAnItem('q111_falkas_coin',spawnCount);
	thePlayer.inv.AddAnItem('q111_imlerith_acorn',spawnCount);
	thePlayer.inv.AddAnItem('q201_mead',spawnCount);
	thePlayer.inv.AddAnItem('q201_pine_cone',spawnCount);
	thePlayer.inv.AddAnItem('q201_skull',spawnCount);
	thePlayer.inv.AddAnItem('q202_shackles',spawnCount);
	thePlayer.inv.AddAnItem('q202_sail',spawnCount);
	thePlayer.inv.AddAnItem('q202_nails',spawnCount);
	thePlayer.inv.AddAnItem('q203_broken_eyeofloki',spawnCount);
	thePlayer.inv.AddAnItem('q203_chest_key',spawnCount);
	thePlayer.inv.AddAnItem('q203_broksvard',spawnCount);
	thePlayer.inv.AddAnItem('q205_mirt_green',spawnCount);
	thePlayer.inv.AddAnItem('q205_mirt_yellow',spawnCount);
	thePlayer.inv.AddAnItem('q205_hvitr_universal_key',spawnCount);
	thePlayer.inv.AddAnItem('q205_gaelnos_rootc',spawnCount);
	thePlayer.inv.AddAnItem('q205_swallow_green',spawnCount);
	thePlayer.inv.AddAnItem('q205_swallow_yellow',spawnCount);
	thePlayer.inv.AddAnItem('q206_wine_sample',spawnCount);
	thePlayer.inv.AddAnItem('q206_herb_mixture',spawnCount);
	thePlayer.inv.AddAnItem('q208_heroesmead',spawnCount);
	thePlayer.inv.AddAnItem('q210_avallach_notes_01',spawnCount);
	thePlayer.inv.AddAnItem('q210_avallach_notes_02',spawnCount);
	thePlayer.inv.AddAnItem('q210_avallach_lover_notes',spawnCount);
	thePlayer.inv.AddAnItem('q210_solarstein',spawnCount);
	thePlayer.inv.AddAnItem('q301_rose_remembrance',spawnCount);
	thePlayer.inv.AddAnItem('q301_triss_parcel',spawnCount);
	thePlayer.inv.AddAnItem('q301_magic_rat_incense',spawnCount);
	thePlayer.inv.AddAnItem('q301_haunted_doll',spawnCount);
	thePlayer.inv.AddAnItem('q301_burdock',spawnCount);
	thePlayer.inv.AddAnItem('q302_estate_key',spawnCount);
	thePlayer.inv.AddAnItem('q302_ring_door_key',spawnCount);
	thePlayer.inv.AddAnItem('q303_bomb_fragment',spawnCount);
	thePlayer.inv.AddAnItem('q303_bomb_cap',spawnCount);
	thePlayer.inv.AddAnItem('q303_wine_bottle',spawnCount);
	thePlayer.inv.AddAnItem('q305_dandelion_signet',spawnCount);
	thePlayer.inv.AddAnItem('q309_key_piece1',spawnCount);
	thePlayer.inv.AddAnItem('q309_key_piece2',spawnCount);
	thePlayer.inv.AddAnItem('q309_key_piece3',spawnCount);
	thePlayer.inv.AddAnItem('q309_three_keys_combined r',spawnCount);
	thePlayer.inv.AddAnItem('q310_wine',spawnCount);
	thePlayer.inv.AddAnItem('q310_lever',spawnCount);
	thePlayer.inv.AddAnItem('q310_sewer_door_key',spawnCount);
	thePlayer.inv.AddAnItem('q310_cell_key',spawnCount);
	thePlayer.inv.AddAnItem('q310_backdoor_keyc',spawnCount);
	thePlayer.inv.AddAnItem('q401_forktail_brain',spawnCount);
	thePlayer.inv.AddAnItem('q401_triss_earring',spawnCount);
	thePlayer.inv.AddAnItem('q401_sausages',spawnCount);
	thePlayer.inv.AddAnItem('q401_trial_key_ingredient_a',spawnCount);
	thePlayer.inv.AddAnItem('q401_trial_key_ingredient_b',spawnCount);
	thePlayer.inv.AddAnItem('q401_trial_key_ingredient_c',spawnCount);
	thePlayer.inv.AddAnItem('q401_bucket_and_rag',spawnCount);
	thePlayer.inv.AddAnItem('yennefers_omelette',spawnCount);
	thePlayer.inv.AddAnItem('yennefers_omelette_fantasie',spawnCount);
	thePlayer.inv.AddAnItem('scrambled_eggs',spawnCount);
	thePlayer.inv.AddAnItem('q401_disgusting_meal',spawnCount);
	thePlayer.inv.AddAnItem('q504_fish',spawnCount);
	thePlayer.inv.AddAnItem('q505_gems',spawnCount);
	thePlayer.inv.AddAnItem('sq101_safe_goods',spawnCount);
	thePlayer.inv.AddAnItem('sq104_key',spawnCount);
	thePlayer.inv.AddAnItem('sq107_vault_key',spawnCount);
	thePlayer.inv.AddAnItem('sq108_smith_toolsc',spawnCount);
	thePlayer.inv.AddAnItem('sq108_acid_gland',spawnCount);
	thePlayer.inv.AddAnItem('sq201_werewolf_meat',spawnCount);
	thePlayer.inv.AddAnItem('sq201_rotten_meatc',spawnCount);
	thePlayer.inv.AddAnItem('sq201_cursed_jewel',spawnCount);
	thePlayer.inv.AddAnItem('sq201_padlock_keyc',spawnCount);
	thePlayer.inv.AddAnItem('sq201_chamber_keyc',spawnCount);
	thePlayer.inv.AddAnItem('sq202_half_seal',spawnCount);
	thePlayer.inv.AddAnItem('sq204_wolf_heart',spawnCount);
	thePlayer.inv.AddAnItem('sq204_leshy_talisman',spawnCount);
	thePlayer.inv.AddAnItem('sq205_fernflower_petal',spawnCount);
	thePlayer.inv.AddAnItem('sq205_preserved_mash',spawnCount);
	thePlayer.inv.AddAnItem('sq205_moonshine_spirit',spawnCount);
	thePlayer.inv.AddAnItem('sq206_sleipnir_formula',spawnCount);
	thePlayer.inv.AddAnItem('sq206_sleipnir_ingredient',spawnCount);
	thePlayer.inv.AddAnItem('sq206_sleipnir_potion',spawnCount);
	thePlayer.inv.AddAnItem('sq207_portal_stone_red',spawnCount);
	thePlayer.inv.AddAnItem('sq207_portal_stone_green',spawnCount);
	thePlayer.inv.AddAnItem('sq207_portal_stone_blue',spawnCount);
	thePlayer.inv.AddAnItem('sq208_portait_otkell',spawnCount);
	thePlayer.inv.AddAnItem('sq208_portait_tyrc',spawnCount);
	thePlayer.inv.AddAnItem('sq208_portait_brodrr',spawnCount);
	thePlayer.inv.AddAnItem('sq208_portait_saemingr',spawnCount);
	thePlayer.inv.AddAnItem('sq208_herbs',spawnCount);
	thePlayer.inv.AddAnItem('sq208_raghnaroog',spawnCount);
	thePlayer.inv.AddAnItem('sq210_conch',spawnCount);
	thePlayer.inv.AddAnItem('sq210_golems_heart',spawnCount);
	thePlayer.inv.AddAnItem('sq210_golems_charged_heartg',spawnCount);
	thePlayer.inv.AddAnItem('sq210_burnt_heartc',spawnCount);
	thePlayer.inv.AddAnItem('sq210_gold_token',spawnCount);
	thePlayer.inv.AddAnItem('sq301_triss_mask_for_shop',spawnCount);
	thePlayer.inv.AddAnItem('sq302_crystal',spawnCount);
	thePlayer.inv.AddAnItem('sq302_generator_2',spawnCount);
	thePlayer.inv.AddAnItem('sq302_generator_3',spawnCount);
	thePlayer.inv.AddAnItem('sq303_lesser_white_honey',spawnCount);
	thePlayer.inv.AddAnItem('sq304_smithing_mtrls',spawnCount);
	thePlayer.inv.AddAnItem('sq304_chemicals',spawnCount);
	thePlayer.inv.AddAnItem('sq304_monster_trophy',spawnCount);
	thePlayer.inv.AddAnItem('sq304_aluminium',spawnCount);
	thePlayer.inv.AddAnItem('sq304_ferrum_cadmiae',spawnCount);
	thePlayer.inv.AddAnItem('sq304_thermite',spawnCount);
	thePlayer.inv.AddAnItem('sq402_ingredient',spawnCount);
	thePlayer.inv.AddAnItem('sq402_florence_flask_with_water',spawnCount);
	thePlayer.inv.AddAnItem('sq402_florence_flask',spawnCount);
	thePlayer.inv.AddAnItem('sq302_eyes',spawnCount);
	thePlayer.inv.AddAnItem('sq302_agates',spawnCount);
	thePlayer.inv.AddAnItem('sq303_blunt_sword',spawnCount);
	thePlayer.inv.AddAnItem('sq305_conduct',spawnCount);
	thePlayer.inv.AddAnItem('sq307_cattrap',spawnCount);
	thePlayer.inv.AddAnItem('sq307_cat_accessories',spawnCount);
	thePlayer.inv.AddAnItem('sq307_flower',spawnCount);
	thePlayer.inv.AddAnItem('sq401_old_sword',spawnCount);
	thePlayer.inv.AddAnItem('sq308_martin_maskask',spawnCount);
	thePlayer.inv.AddAnItem('sq310_card_1',spawnCount);
	thePlayer.inv.AddAnItem('sq310_card_2',spawnCount);
	thePlayer.inv.AddAnItem('sq310_card_3',spawnCount);
	thePlayer.inv.AddAnItem('sq309_iorweth_arrow',spawnCount);
	thePlayer.inv.AddAnItem('sq314_cure',spawnCount);
	thePlayer.inv.AddAnItem('sq314_cure_recipe',spawnCount);
	thePlayer.inv.AddAnItem('sq314_var_rechte_journal',spawnCount);
	thePlayer.inv.AddAnItem('mq0002_box',spawnCount);
	thePlayer.inv.AddAnItem('mq0003_ornate_bracelet',spawnCount);
	thePlayer.inv.AddAnItem('mq0004_thalers_monocle',spawnCount);
	thePlayer.inv.AddAnItem('mq0004_frying_pan',spawnCount);
	thePlayer.inv.AddAnItem('mq1001_dog_collar',spawnCount);
	thePlayer.inv.AddAnItem('mq1001_locker_key',spawnCount);
	thePlayer.inv.AddAnItem('mq1002_artifact_1',spawnCount);
	thePlayer.inv.AddAnItem('mq1002_artifact_2',spawnCount);
	thePlayer.inv.AddAnItem('mq1002_artifact_3',spawnCount);
	thePlayer.inv.AddAnItem('mq1006_elf_head',spawnCount);
	thePlayer.inv.AddAnItem('mq1022_paint',spawnCount);
	thePlayer.inv.AddAnItem('mq1010_ring',spawnCount);
	thePlayer.inv.AddAnItem('mq1028_muggs_papers',spawnCount);
	thePlayer.inv.AddAnItem('mq1050_dragon_root',spawnCount);
	thePlayer.inv.AddAnItem('mq1053_skull',spawnCount);
	thePlayer.inv.AddAnItem('mq1056_chain_cutter',spawnCount);
	thePlayer.inv.AddAnItem('mq2001_kuilu',spawnCount);
	thePlayer.inv.AddAnItem('mq2001_horn',spawnCount);
	thePlayer.inv.AddAnItem('mq2002_sword',spawnCount);
	thePlayer.inv.AddAnItem('mq2006_key_1',spawnCount);
	thePlayer.inv.AddAnItem('mq2006_key_2',spawnCount);
	thePlayer.inv.AddAnItem('mq2030_shawl',spawnCount);
	thePlayer.inv.AddAnItem('mq2033_tp_stone',spawnCount);
    thePlayer.inv.AddAnItem('mq2037_drakkar_chest_key',spawnCount);
	thePlayer.inv.AddAnItem('mq2038_headsman_sword',spawnCount);
	thePlayer.inv.AddAnItem('mq2048_stone_medalion',spawnCount);
	thePlayer.inv.AddAnItem('mq2048_ships_logbook',spawnCount);
	thePlayer.inv.AddAnItem('mq1019_oil',spawnCount);
	thePlayer.inv.AddAnItem('mq3012_noble_statuette',spawnCount);
	thePlayer.inv.AddAnItem('mq3012_soldier_statuette',spawnCount);
	thePlayer.inv.AddAnItem('mq3031_mother_of_pearl',spawnCount);
	thePlayer.inv.AddAnItem('mq3032_basilisk_leather',spawnCount);
	thePlayer.inv.AddAnItem('mq3035_philppa_ring',spawnCount);
	thePlayer.inv.AddAnItem('mq3039_loot_chest_key',spawnCount);
	thePlayer.inv.AddAnItem('mq1051_spyglass',spawnCount);
	thePlayer.inv.AddAnItem('mq1052_monster_trophy',spawnCount);
	thePlayer.inv.AddAnItem('mq3032_leather_boots',spawnCount);
	thePlayer.inv.AddAnItem('mq1052_bandit_key',spawnCount);
	thePlayer.inv.AddAnItem('sq312_medicine',spawnCount);
	thePlayer.inv.AddAnItem('mq2041_dexterity_token',spawnCount);
	thePlayer.inv.AddAnItem('mq2043_conviction_token',spawnCount);
	thePlayer.inv.AddAnItem('mq4003_siren_ring',spawnCount);
	thePlayer.inv.AddAnItem('mq4003_husband_ring',spawnCount);
	thePlayer.inv.AddAnItem('mq4004_boy_remains',spawnCount);
	thePlayer.inv.AddAnItem('mh103_killers_knife',spawnCount);
	thePlayer.inv.AddAnItem('mh106_hags_skulls',spawnCount);
	thePlayer.inv.AddAnItem('mh107_fiend_dung',spawnCount);
	thePlayer.inv.AddAnItem('mh203_water_hag_trophy',spawnCount);
	thePlayer.inv.AddAnItem('mh307_minion_trophy',spawnCount);
	thePlayer.inv.AddAnItem('mh307_minion_lair_key',spawnCount);
	thePlayer.inv.AddAnItem('mh308_dagger',spawnCount);
	thePlayer.inv.AddAnItem('troll_bane_gloves',spawnCount);
	thePlayer.inv.AddAnItem('q001_letter_from_yenn',spawnCount);
	thePlayer.inv.AddAnItem('q001_academic_book',spawnCount);
	thePlayer.inv.AddAnItem('q002_yenn_notes_about_ciri',spawnCount);
	thePlayer.inv.AddAnItem('q101_hendrik_notes',spawnCount);
	thePlayer.inv.AddAnItem('q101_candle_instruction',spawnCount);
	thePlayer.inv.AddAnItem('q103_tamara_prayer',spawnCount);
	thePlayer.inv.AddAnItem('q103_letter_from_graden_1',spawnCount);
	thePlayer.inv.AddAnItem('q103_letter_from_graden_2',spawnCount);
	thePlayer.inv.AddAnItem('q103_nilfgaardian_demand',spawnCount);
	thePlayer.inv.AddAnItem('q103_about_eve',spawnCount);
	thePlayer.inv.AddAnItem('q103_love_letter',spawnCount);
	thePlayer.inv.AddAnItem('q103_curse_book',spawnCount);
	thePlayer.inv.AddAnItem('q103_safe_conduct',spawnCount);
	thePlayer.inv.AddAnItem('q103_baron_dagger',spawnCount);
	thePlayer.inv.AddAnItem('q104_cure_recipe',spawnCount);
	thePlayer.inv.AddAnItem('q104_eye_ink_recipe',spawnCount);
	thePlayer.inv.AddAnItem('q104_aleksander_letter',spawnCount);
	thePlayer.inv.AddAnItem('q104_avallach_notes',spawnCount);
	thePlayer.inv.AddAnItem('q104_avallach_poetry',spawnCount);
	thePlayer.inv.AddAnItem('q105_book_about_witches',spawnCount);
	thePlayer.inv.AddAnItem('q106_note_from_keira',spawnCount);
	thePlayer.inv.AddAnItem('q106_alexander_notes_01',spawnCount);
	thePlayer.inv.AddAnItem('q106_alexander_notes_02',spawnCount);
	thePlayer.inv.AddAnItem('q201_yen_journal_1',spawnCount);
	thePlayer.inv.AddAnItem('q201_poisoned_source',spawnCount);
	thePlayer.inv.AddAnItem('q201_wild_hunt_book',spawnCount);
	thePlayer.inv.AddAnItem('q201_mousesack_letter',spawnCount);
	thePlayer.inv.AddAnItem('q201_criminal',spawnCount);
	thePlayer.inv.AddAnItem('q205_avallach_book',spawnCount);
	thePlayer.inv.AddAnItem('q206_arits_letterble',spawnCount);
	thePlayer.inv.AddAnItem('q206_arnvalds_letter',spawnCount);
	thePlayer.inv.AddAnItem('q210_letter_for_emhyr',spawnCount);
	thePlayer.inv.AddAnItem('q301_drawing_crib',spawnCount);
	thePlayer.inv.AddAnItem('q302_zdenek_contractble',spawnCount);
	thePlayer.inv.AddAnItem('q302_igor_note',spawnCount);
	thePlayer.inv.AddAnItem('q302_roche_letterble',spawnCount);
	thePlayer.inv.AddAnItem('q302_dijkstras_notes',spawnCount);
	thePlayer.inv.AddAnItem('q302_rico_thugs_notes',spawnCount);
	thePlayer.inv.AddAnItem('q302_casino_registerble',spawnCount);
	thePlayer.inv.AddAnItem('q302_roche_report',spawnCount);
	thePlayer.inv.AddAnItem('q302_crafter_notes',spawnCount);
	thePlayer.inv.AddAnItem('q302_whoreson_letter_to_radowid',spawnCount);
	thePlayer.inv.AddAnItem('q303_note_for_ciri',spawnCount);
	thePlayer.inv.AddAnItem('q303_dudus_briefing',spawnCount);
	thePlayer.inv.AddAnItem('q303_contact_note',spawnCount);
	thePlayer.inv.AddAnItem('q303_marked_bible',spawnCount);
	thePlayer.inv.AddAnItem('q304_dandelion_diary',spawnCount);
	thePlayer.inv.AddAnItem('q304_letter_1',spawnCount);
	thePlayer.inv.AddAnItem('q304_letter_2',spawnCount);
	thePlayer.inv.AddAnItem('q304_letter_3',spawnCount);
	thePlayer.inv.AddAnItem('q304_dandelion_ballad',spawnCount);
	thePlayer.inv.AddAnItem('q304_priscilla_letter',spawnCount);
	thePlayer.inv.AddAnItem('q304_ambasador_letter',spawnCount);
	thePlayer.inv.AddAnItem('q304_rosa_lover_letter',spawnCount);
	thePlayer.inv.AddAnItem('q305_script_drama_title1',spawnCount);
	thePlayer.inv.AddAnItem('q305_script_drama_title2',spawnCount);
	thePlayer.inv.AddAnItem('q305_script_comedy_title1',spawnCount);
	thePlayer.inv.AddAnItem('q305_script_comedy_title2',spawnCount);
	thePlayer.inv.AddAnItem('q305_script_for_irina',spawnCount);
	thePlayer.inv.AddAnItem('q308_coroner_msg',spawnCount);
	thePlayer.inv.AddAnItem('q308_sermon_1',spawnCount);
	thePlayer.inv.AddAnItem('q308_sermon_2',spawnCount);
	thePlayer.inv.AddAnItem('q308_sermon_3',spawnCount);
	thePlayer.inv.AddAnItem('q308_sermon_4',spawnCount);
	thePlayer.inv.AddAnItem('q308_sermon_5',spawnCount);
	thePlayer.inv.AddAnItem('q308_psycho_farewell',spawnCount);
	thePlayer.inv.AddAnItem('q308_vegelbud_invite',spawnCount);
	thePlayer.inv.AddAnItem('q308_priscilla_invite',spawnCount);
	thePlayer.inv.AddAnItem('q308_anneke_invite',spawnCount);
	thePlayer.inv.AddAnItem('q308_last_invite',spawnCount);
	thePlayer.inv.AddAnItem('q308_nathanel_sermon_1',spawnCount);
	thePlayer.inv.AddAnItem('q308_vg_ethanol',spawnCount);
	thePlayer.inv.AddAnItem('q308_vg_paraffin',spawnCount);
	thePlayer.inv.AddAnItem('q308_vg_guillotine',spawnCount);
	thePlayer.inv.AddAnItem('q309_note_from_varese',spawnCount);
	thePlayer.inv.AddAnItem('q309_witch_hunters_orders',spawnCount);
	thePlayer.inv.AddAnItem('q309_glejt_from_dijkstra',spawnCount);
	thePlayer.inv.AddAnItem('q309_mssg_from_triss',spawnCount);
	thePlayer.inv.AddAnItem('q309_key_letters',spawnCount);
	thePlayer.inv.AddAnItem('q309_key_orders',spawnCount);
	thePlayer.inv.AddAnItem('q310_journal_notes_1',spawnCount);
	thePlayer.inv.AddAnItem('q310_journal_notes_2',spawnCount);
	thePlayer.inv.AddAnItem('q311_lost_diary1',spawnCount);
	thePlayer.inv.AddAnItem('q311_lost_diary2',spawnCount);
	thePlayer.inv.AddAnItem('q311_lost_diary3',spawnCount);
	thePlayer.inv.AddAnItem('q311_lost_diary4',spawnCount);
	thePlayer.inv.AddAnItem('q311_aen_elle_notesble',spawnCount);
	thePlayer.inv.AddAnItem('q401_yen_journal_2',spawnCount);
	thePlayer.inv.AddAnItem('q403_treaty hold',spawnCount);
	thePlayer.inv.AddAnItem('q310_yen_trinket',spawnCount);
	thePlayer.inv.AddAnItem('q310_explorer_note',spawnCount);
	thePlayer.inv.AddAnItem('q505_nilf_diary_lost1',spawnCount);
	thePlayer.inv.AddAnItem('q505_nilf_diary_lost2',spawnCount);
	thePlayer.inv.AddAnItem('q505_nilf_diary_won1',spawnCount);
	thePlayer.inv.AddAnItem('sq101_shipment_list',spawnCount);
	thePlayer.inv.AddAnItem('sq101_letter_from_keiray',spawnCount);
	thePlayer.inv.AddAnItem('sq102_dolores_diary',spawnCount);
	thePlayer.inv.AddAnItem('sq102_huberts_diary',spawnCount);
	thePlayer.inv.AddAnItem('sq102_loose_papers',spawnCount);
	thePlayer.inv.AddAnItem('sq104_notes',spawnCount);
	thePlayer.inv.AddAnItem('sq106_manuscript',spawnCount);
	thePlayer.inv.AddAnItem('sq201_ship_manifesto',spawnCount);
	thePlayer.inv.AddAnItem('sq202_book_1',spawnCount);
	thePlayer.inv.AddAnItem('sq202_book_2',spawnCount);
	thePlayer.inv.AddAnItem('sq205_brewing_instructions',spawnCount);
	thePlayer.inv.AddAnItem('sq205_brewmasters_log',spawnCount);
	thePlayer.inv.AddAnItem('sq208_letter',spawnCount);
	thePlayer.inv.AddAnItem('sq208_otkell_journal',spawnCount);
	thePlayer.inv.AddAnItem('sq208_ashes',spawnCount);
	thePlayer.inv.AddAnItem('sq210_gog_book',spawnCount);
	thePlayer.inv.AddAnItem('sq210_gog_brain',spawnCount);
	thePlayer.inv.AddAnItem('sq210_blank_brain',spawnCount);
	thePlayer.inv.AddAnItem('sq210_drm_brain',spawnCount);
	thePlayer.inv.AddAnItem('sq210_gog_recipe',spawnCount);
	thePlayer.inv.AddAnItem('sq304_ledger_bookble',spawnCount);
	thePlayer.inv.AddAnItem('sq302_philippa_letter',spawnCount);
	thePlayer.inv.AddAnItem('sq303_robbery_speechble',spawnCount);
	thePlayer.inv.AddAnItem('sq309_girl_notebookble',spawnCount);
	thePlayer.inv.AddAnItem('sq311_spy_papers',spawnCount);
	thePlayer.inv.AddAnItem('sq309_mage_letter',spawnCount);
	thePlayer.inv.AddAnItem('sq310_ledger_book',spawnCount);
	thePlayer.inv.AddAnItem('sq310_package',spawnCount);
	thePlayer.inv.AddAnItem('sq313_iorveth_letters',spawnCount);
	thePlayer.inv.AddAnItem('sq401_orders',spawnCount);
	thePlayer.inv.AddAnItem('cg100_barons_notes',spawnCount);
	thePlayer.inv.AddAnItem('cg300_roches_list',spawnCount);
	thePlayer.inv.AddAnItem('mq0003_girls_diary',spawnCount);
	thePlayer.inv.AddAnItem('mq0004_burnt_papers',spawnCount);
	thePlayer.inv.AddAnItem('mq1001_locker_diary',spawnCount);
	thePlayer.inv.AddAnItem('mq1002_aeramas_journal',spawnCount);
	thePlayer.inv.AddAnItem('mq1002_aeramas_journal_2',spawnCount);
	thePlayer.inv.AddAnItem('mq1015_hang_man_note',spawnCount);
	thePlayer.inv.AddAnItem('mq1014_old_mine_journal',spawnCount);
	thePlayer.inv.AddAnItem('mq1017_nilfgaardian_letter',spawnCount);
	thePlayer.inv.AddAnItem('mq1023_fake_papers',spawnCount);
	thePlayer.inv.AddAnItem('mq1036_refugee_letter',spawnCount);
	thePlayer.inv.AddAnItem('mq1033_fight_diary',spawnCount);
	thePlayer.inv.AddAnItem('mq1053_letter_to_emhyr',spawnCount);
	thePlayer.inv.AddAnItem('mq1053_report',spawnCount);
	thePlayer.inv.AddAnItem('mq1053_martins_notes',spawnCount);
	thePlayer.inv.AddAnItem('mq1055_letters',spawnCount);
	thePlayer.inv.AddAnItem('mq2001_journal_1a',spawnCount);
	thePlayer.inv.AddAnItem('mq2001_journal_1b',spawnCount);
	thePlayer.inv.AddAnItem('mq2001_journal_1c',spawnCount);
	thePlayer.inv.AddAnItem('mq2001_journal_2a',spawnCount);
	thePlayer.inv.AddAnItem('mq2001_journal_2b',spawnCount);
	thePlayer.inv.AddAnItem('mq2003_bandit_journal',spawnCount);
	thePlayer.inv.AddAnItem('mq2006_map_1',spawnCount);
	thePlayer.inv.AddAnItem('mq2006_map_2',spawnCount);
	thePlayer.inv.AddAnItem('mq2008_journal',spawnCount);
	thePlayer.inv.AddAnItem('mq2010_lumbermill_journal_1',spawnCount);
	thePlayer.inv.AddAnItem('mq2010_lumbermill_journal_2',spawnCount);
	thePlayer.inv.AddAnItem('mq2010_lumbermill_journal_3',spawnCount);
	thePlayer.inv.AddAnItem('mq2012_letter',spawnCount);
	thePlayer.inv.AddAnItem('mq2015_kurisus_note',spawnCount);
	thePlayer.inv.AddAnItem('mq2033_captain_note',spawnCount);
	thePlayer.inv.AddAnItem('mq2033_captain_journal',spawnCount);
	thePlayer.inv.AddAnItem('mq2037_dimun_directions',spawnCount);
	thePlayer.inv.AddAnItem('mq2039_Honeycomb',spawnCount);
	thePlayer.inv.AddAnItem('mq2048_guide_notes',spawnCount);
	thePlayer.inv.AddAnItem('mq2048_waxed_letters',spawnCount);
    

    

    }
    function AddPotionsForW3Player()
    {
        	var inv : CInventoryComponent;
	var arr : array<SItemUniqueId>;
	
	inv = thePlayer.inv;
	arr = inv.AddAnItem('Black Blood 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Black Blood 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Black Blood 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Blizzard 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Blizzard 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Blizzard 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Cat 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Cat 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Cat 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Full Moon 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Full Moon 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Full Moon 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Golden Oriole 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Golden Oriole 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Golden Oriole 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Killer Whale 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Maribor Forest 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Maribor Forest 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Maribor Forest 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Petri Philtre 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Petri Philtre 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Petri Philtre 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Swallow 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Swallow 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Swallow 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Tawny Owl 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Tawny Owl 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Tawny Owl 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Thunderbolt 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Thunderbolt 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Thunderbolt 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('White Honey 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('White Honey 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('White Honey 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('White Raffards Decoction 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('White Raffards Decoction 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('White Raffards Decoction 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
    //     thePlayer.inv.AddAnItem('Mutagen Sword',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen Magic',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen Alchemy',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen Ulti',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 1',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 2',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 3',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 4',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 5',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 6',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 7',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 8',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 9',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 10',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 11',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 12',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 13',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 14',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 15',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 16',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 17',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 18',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 19',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 20',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 21',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 22',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 23',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 24',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 25',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 26',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 27',spawnCount);
	// thePlayer.inv.AddAnItem('Mutagen 28',spawnCount);
    arr = inv.AddAnItem('Mutagen Sword');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen Magic');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen Alchemy');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen Ulti');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 1');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 2');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 3');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 4');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 5');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 6');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 7');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 8');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 9');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 10');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 11');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 12');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 13');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 14');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 15');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 16');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 17');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 18');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 19');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 20');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 21');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 22');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 23');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 24');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 25');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 26');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 27');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

arr = inv.AddAnItem('Mutagen 28');
thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

    
        
    }
    function AddMutagenThingsForW3Player()
    {
thePlayer.inv.AddAnItem('Mutagen Sword',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen Magic',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen Alchemy',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen Ulti',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 1',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 2',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 3',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 4',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 5',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 6',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 7',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 8',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 9',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 10',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 11',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 12',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 13',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 14',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 15',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 16',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 17',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 18',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 19',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 20',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 21',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 22',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 23',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 24',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 25',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 26',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 27',spawnCount);
	thePlayer.inv.AddAnItem('Mutagen 28',spawnCount);
    thePlayer.inv.AddAnItem('Lesser mutagen red',spawnCount);
	thePlayer.inv.AddAnItem('Lesser mutagen green',spawnCount);
	thePlayer.inv.AddAnItem('Lesser mutagen blue',spawnCount);
	thePlayer.inv.AddAnItem('Katakan mutagen',spawnCount);
	thePlayer.inv.AddAnItem('Arachas mutagen',spawnCount);
	thePlayer.inv.AddAnItem('Cockatrice mutagen',spawnCount);
	thePlayer.inv.AddAnItem('Volcanic Gryphon mutagen',spawnCount);
	thePlayer.inv.AddAnItem('Gryphon mutagen',spawnCount);
	thePlayer.inv.AddAnItem('Water Hag mutagen',spawnCount);
	thePlayer.inv.AddAnItem('Nightwraith mutagen',spawnCount);
	thePlayer.inv.AddAnItem('Ekimma mutagen',spawnCount);
	thePlayer.inv.AddAnItem('Czart mutagen',spawnCount);
	thePlayer.inv.AddAnItem('Fogling 1 mutagen',spawnCount);
	thePlayer.inv.AddAnItem('Wyvern mutagen',spawnCount);
	thePlayer.inv.AddAnItem('Doppler mutagen',spawnCount);
	thePlayer.inv.AddAnItem('Troll mutagen',spawnCount);
	thePlayer.inv.AddAnItem('Noonwraith mutagen',spawnCount);
	thePlayer.inv.AddAnItem('Succubus mutagen',spawnCount);
	thePlayer.inv.AddAnItem('Fogling 2 mutagen',spawnCount);
	thePlayer.inv.AddAnItem('Fiend mutagen',spawnCount);
	thePlayer.inv.AddAnItem('Forktail mutagen',spawnCount);
	thePlayer.inv.AddAnItem('Grave Hag mutagen',spawnCount);
	thePlayer.inv.AddAnItem('Wraith mutagen',spawnCount);
	thePlayer.inv.AddAnItem('Dao mutagen',spawnCount);
	thePlayer.inv.AddAnItem('Lamia mutagen',spawnCount);
	thePlayer.inv.AddAnItem('Ancient Leshy mutagen',spawnCount);
	thePlayer.inv.AddAnItem('Basilisk mutagen',spawnCount);
	thePlayer.inv.AddAnItem('Werewolf mutagen',spawnCount);
	thePlayer.inv.AddAnItem('Nekker Warrior mutagen',spawnCount);
	thePlayer.inv.AddAnItem('Leshy mutagen',spawnCount);
    GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 2');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 4');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 5');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 6');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 7');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 8');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 9');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 10');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 11');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 12');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 13');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 14');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 15');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 16');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 17');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 18');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 19');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 20');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 21');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 22');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 23');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 24');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 25');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 26');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 27');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 28');
	
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Lesser Mutagen Red to Blue');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Lesser Mutagen Red to Green');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Lesser Mutagen Blue to Red');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Lesser Mutagen Blue to Green');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Lesser Mutagen Green to Red');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Lesser Mutagen Green to Blue');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Mutagen Red to Blue');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Mutagen Red to Green');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Mutagen Blue to Red');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Mutagen Blue to Green');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Mutagen Green to Red');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Mutagen Green to Blue');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Greater Mutagen Red to Blue');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Greater Mutagen Red to Green');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Greater Mutagen Blue to Red');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Greater Mutagen Blue to Green');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Greater Mutagen Green to Red');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Greater Mutagen Green to Blue');
    }
    function AddRecipesForW3Player()
    {
        	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Anthropomorph Oil 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Cursed Oil 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Hanged Man Venom 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Hybrid Oil 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Insectoid Oil 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Magicals Oil 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Necrophage Oil 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Specter Oil 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Vampire Oil 3');
	
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Dancing Star 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Devils Puffball 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Dwimeritum Bomb 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Dragons Dream 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Grapeshot 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Samum 3');
        thePlayer.inv.AddAnItem('Recipe for Beast Oil 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Beast Oil 2',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Beast Oil 3',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Cursed Oil 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Cursed Oil 2',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Cursed Oil 3',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Hanged Man Venom 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Hanged Man Venom 2',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Hanged Man Venom 3',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Hybrid Oil 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Hybrid Oil 2',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Hybrid Oil 3',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Insectoid Oil 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Insectoid Oil 2',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Insectoid Oil 3',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Magicals Oil 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Magicals Oil 2',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Magicals Oil 3',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Necrophage Oil 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Necrophage Oil 2',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Necrophage Oil 3',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Specter Oil 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Specter Oil 2',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Specter Oil 3',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Vampire Oil 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Vampire Oil 2',spawnCount);

	thePlayer.inv.AddAnItem('Recipe for Ogre Oil 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Ogre Oil 2',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Ogre Oil 3',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Relic Oil 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Relic Oil 2',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Relic Oil 3',spawnCount);
    thePlayer.inv.AddAnItem('Recipe for Dancing Star 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Dancing Star 2',spawnCount);

	thePlayer.inv.AddAnItem('Recipe for Devils Puffball 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Devils Puffball 2',spawnCount);

	thePlayer.inv.AddAnItem('Recipe for Dimeritum Bomb 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Dimeritum Bomb 2',spawnCount);

	thePlayer.inv.AddAnItem('Recipe for Dragons Dream 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Dragons Dream 2',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Grapeshot 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Grapeshot 2',spawnCount);

	thePlayer.inv.AddAnItem('Recipe for Samum 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Samum 2',spawnCount);

	thePlayer.inv.AddAnItem('Recipe for Silver Dust Bomb 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Silver Dust Bomb 2',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Silver Dust Bomb 3',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for White Frost 1',spawnCount);
    thePlayer.inv.AddAnItem('Recipe for Black Blood 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Black Blood 2',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Black Blood 3',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Blizzard 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Blizzard 2',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Blizzard 3',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Cat 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Cat 2',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Cat 3',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Czart Lure',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Bear Pheromone Potion 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Drowner Pheromone Potion 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Nekker Pheromone Potion 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Full Moon 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Full Moon 2',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Full Moon 3',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Golden Oriole 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Golden Oriole 2',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Golden Oriole 3',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Killer Whale 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Maribor Forest 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Maribor Forest 2',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Maribor Forest 3',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Petris Philtre 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Petris Philtre 2',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Petris Philtre 3',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Pops Antidote',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Swallow 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Swallow 2',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Swallow 3',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Tawny Owl 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Tawny Owl 2',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Tawny Owl 3',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Thunderbolt 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Thunderbolt 2',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Thunderbolt 3',spawnCount);
    	thePlayer.inv.AddAnItem('Recipe for Trial Potion 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Trial Potion 2',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Trial Potion 3',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for White Gull 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for White Honey 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for White Honey 2',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for White Honey 3',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for White Raffard Decoction 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for White Raffard Decoction 2',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for White Raffard Decoction 3',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Dwarven spirit 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Alcohest 1',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for White gull 1',spawnCount);
    thePlayer.inv.AddAnItem('Draconide infused leather schematic',spawnCount);
	thePlayer.inv.AddAnItem('Nickel ore schematic',spawnCount);
	thePlayer.inv.AddAnItem('Cupronickel ore schematic',spawnCount);
	thePlayer.inv.AddAnItem('Copper ore schematic',spawnCount);
	thePlayer.inv.AddAnItem('Copper ingot schematic',spawnCount);
	thePlayer.inv.AddAnItem('Copper plate schematic',spawnCount);
	thePlayer.inv.AddAnItem('Green gold ore schematic',spawnCount);
	thePlayer.inv.AddAnItem('Green gold ore schematic1 ',spawnCount);
	thePlayer.inv.AddAnItem('Green gold ingot schematic',spawnCount);
	thePlayer.inv.AddAnItem('Green gold plate schematic',spawnCount);
	thePlayer.inv.AddAnItem('Orichalcum ore schematic',spawnCount);
	thePlayer.inv.AddAnItem('Orichalcum ore schematic 1',spawnCount);
	thePlayer.inv.AddAnItem('Orichalcum ingot schematic',spawnCount);
	thePlayer.inv.AddAnItem('Orichalcum plate schematic',spawnCount);
	thePlayer.inv.AddAnItem('Dwimeryte enriched ore schematic',spawnCount);
	thePlayer.inv.AddAnItem('Dwimeryte enriched ingot schematic',spawnCount);
	thePlayer.inv.AddAnItem('Dwimeryte enriched plate schematic',spawnCount);
    	thePlayer.inv.AddAnItem('Recipe for Sharley Lure',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Mutation Serum',spawnCount);
	thePlayer.inv.AddAnItem('q704_antidote_recipe',spawnCount);
	thePlayer.inv.AddAnItem('q704_vampire_lure_bolt_recipe',spawnCount);
    }
    function AddSecondaryRangedThrowable()
    {
        thePlayer.inv.AddAnItem('W_Axe01',spawnCount);
	thePlayer.inv.AddAnItem('W_Axe02',spawnCount);
	thePlayer.inv.AddAnItem('W_Axe03',spawnCount);
	thePlayer.inv.AddAnItem('W_Axe04',spawnCount);
	thePlayer.inv.AddAnItem('W_Axe05',spawnCount);
	thePlayer.inv.AddAnItem('W_Axe06',spawnCount);
	thePlayer.inv.AddAnItem('W_Club',spawnCount);
	thePlayer.inv.AddAnItem('W_Mace01',spawnCount);
	thePlayer.inv.AddAnItem('W_Mace02',spawnCount);
	thePlayer.inv.AddAnItem('W_Pickaxe',spawnCount);
	thePlayer.inv.AddAnItem('W_Poker',spawnCount);

    }
    function AddUpgradesForW3Player(optional count : int, optional dontOpenUI : bool)
    {
        if(count == 0)
            count = 1;
            
        thePlayer.inv.AddAnItem('Rune stribog lesser', count);
        thePlayer.inv.AddAnItem('Rune stribog', count);
        thePlayer.inv.AddAnItem('Rune stribog greater', count);
        thePlayer.inv.AddAnItem('Rune dazhbog lesser', count);
        thePlayer.inv.AddAnItem('Rune dazhbog', count);
        thePlayer.inv.AddAnItem('Rune dazhbog greater', count);
        thePlayer.inv.AddAnItem('Rune devana lesser', count);
        thePlayer.inv.AddAnItem('Rune devana', count);
        thePlayer.inv.AddAnItem('Rune devana greater', count);
        thePlayer.inv.AddAnItem('Rune zoria lesser', count);
        thePlayer.inv.AddAnItem('Rune zoria', count);
        thePlayer.inv.AddAnItem('Rune zoria greater', count);
        thePlayer.inv.AddAnItem('Rune morana lesser', count);
        thePlayer.inv.AddAnItem('Rune morana', count);
        thePlayer.inv.AddAnItem('Rune morana greater', count);
        thePlayer.inv.AddAnItem('Rune triglav lesser', count);
        thePlayer.inv.AddAnItem('Rune triglav', count);
        thePlayer.inv.AddAnItem('Rune triglav greater', count);
        thePlayer.inv.AddAnItem('Rune svarog lesser', count);
        thePlayer.inv.AddAnItem('Rune svarog', count);
        thePlayer.inv.AddAnItem('Rune svarog greater', count);
        thePlayer.inv.AddAnItem('Rune veles lesser', count);
        thePlayer.inv.AddAnItem('Rune veles', count);
        thePlayer.inv.AddAnItem('Rune veles greater', count);
        thePlayer.inv.AddAnItem('Rune perun lesser', count);
        thePlayer.inv.AddAnItem('Rune perun', count);
        thePlayer.inv.AddAnItem('Rune perun greater', count);
        thePlayer.inv.AddAnItem('Rune elemental lesser', count);
        thePlayer.inv.AddAnItem('Rune elemental', count);
        thePlayer.inv.AddAnItem('Rune elemental greater', count);
        thePlayer.inv.AddAnItem('Rune tvarog', count);
        thePlayer.inv.AddAnItem('Rune pierog', count);
        
        thePlayer.inv.AddAnItem('Glyph aard lesser', count);
        thePlayer.inv.AddAnItem('Glyph aard', count);
        thePlayer.inv.AddAnItem('Glyph aard greater', count);
        thePlayer.inv.AddAnItem('Glyph axii lesser', count);
        thePlayer.inv.AddAnItem('Glyph axii', count);
        thePlayer.inv.AddAnItem('Glyph axii greater', count);
        thePlayer.inv.AddAnItem('Glyph igni lesser', count);
        thePlayer.inv.AddAnItem('Glyph igni', count);
        thePlayer.inv.AddAnItem('Glyph igni greater', count);
        thePlayer.inv.AddAnItem('Glyph quen lesser', count);
        thePlayer.inv.AddAnItem('Glyph quen', count);
        thePlayer.inv.AddAnItem('Glyph quen greater', count);
        thePlayer.inv.AddAnItem('Glyph yrden lesser', count);
        thePlayer.inv.AddAnItem('Glyph yrden', count);
        thePlayer.inv.AddAnItem('Glyph yrden greater', count);
        thePlayer.inv.AddAnItem('Glyph warding lesser', count);
        thePlayer.inv.AddAnItem('Glyph warding', count);
        thePlayer.inv.AddAnItem('Glyph warding greater', count);
        thePlayer.inv.AddAnItem('Glyph binding lesser', count);
        thePlayer.inv.AddAnItem('Glyph binding', count);
        thePlayer.inv.AddAnItem('Glyph binding greater', count);
        thePlayer.inv.AddAnItem('Glyph mending lesser', count);
        thePlayer.inv.AddAnItem('Glyph mending', count);
        thePlayer.inv.AddAnItem('Glyph mending greater', count);
        thePlayer.inv.AddAnItem('Glyph binding lesser', count);
        thePlayer.inv.AddAnItem('Glyph binding', count);
        thePlayer.inv.AddAnItem('Glyph binding greater', count);
        thePlayer.inv.AddAnItem('Glyph reinforcement lesser', count);
        thePlayer.inv.AddAnItem('Glyph reinforcement', count);
        thePlayer.inv.AddAnItem('Glyph reinforcement greater', count);
    }
    function AddBootsForW3Player()
    {
        thePlayer.inv.AddAnItem('Lynx Boots 5',spawnCount);
		thePlayer.inv.AddAnItem('Gryphon Boots 5',spawnCount);
		thePlayer.inv.AddAnItem('Bear Boots 5',spawnCount);
		thePlayer.inv.AddAnItem('Wolf Boots 5',spawnCount);
		thePlayer.inv.AddAnItem('Red Wolf Boots 1',spawnCount);
		thePlayer.inv.AddAnItem('Red Wolf Boots 2',spawnCount);
        		thePlayer.inv.AddAnItem('Guard Lvl1 Boots 3',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Boots 3',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl2 Boots 3',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Boots 3',spawnCount);
		thePlayer.inv.AddAnItem('Knight Geralt Boots 3',spawnCount);
		thePlayer.inv.AddAnItem('Knight Geralt A Boots 3',spawnCount);
		thePlayer.inv.AddAnItem('Toussaint Boots 3',spawnCount);
        		thePlayer.inv.AddAnItem('Guard Lvl1 Boots 1',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl1 Boots 2',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Boots 1',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Boots 2',spawnCount);
		
		thePlayer.inv.AddAnItem('Guard Lvl2 Boots 1',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl2 Boots 2',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Boots 1',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Boots 2',spawnCount);
		
		thePlayer.inv.AddAnItem('Knight Geralt Boots 1',spawnCount);
		thePlayer.inv.AddAnItem('Knight Geralt Boots 2',spawnCount);
		thePlayer.inv.AddAnItem('Knight Geralt A Boots 1',spawnCount);
		thePlayer.inv.AddAnItem('Knight Geralt A Boots 2',spawnCount);
		thePlayer.inv.AddAnItem('Toussaint Boots 2',spawnCount);
        thePlayer.inv.AddAnItem('Starting Boots',spawnCount);
        thePlayer.inv.AddAnItem('Wolf Boots 1',spawnCount);
        thePlayer.inv.AddAnItem('Wolf Boots 2',spawnCount);
        thePlayer.inv.AddAnItem('Lynx Boots 1',spawnCount);
        thePlayer.inv.AddAnItem('Lynx Boots 2',spawnCount);
        thePlayer.inv.AddAnItem('Gryphon Boots 1',spawnCount);
        thePlayer.inv.AddAnItem('Gryphon Boots 2',spawnCount);
        thePlayer.inv.AddAnItem('Bear Boots 1',spawnCount);
        thePlayer.inv.AddAnItem('Bear Boots 2',spawnCount);
        thePlayer.inv.AddAnItem('Boots 01',spawnCount);
        thePlayer.inv.AddAnItem('Boots 01 q2',spawnCount);
        thePlayer.inv.AddAnItem('Boots 02',spawnCount);
        thePlayer.inv.AddAnItem('Boots 03',spawnCount);
        thePlayer.inv.AddAnItem('Boots 04',spawnCount);
        thePlayer.inv.AddAnItem('Boots 01',spawnCount);
        thePlayer.inv.AddAnItem('Heavy boots 01',spawnCount);
        thePlayer.inv.AddAnItem('Heavy boots 02',spawnCount);
        thePlayer.inv.AddAnItem('Heavy boots 03',spawnCount);
        thePlayer.inv.AddAnItem('Heavy boots 04',spawnCount);
        thePlayer.inv.AddAnItem('Nilfgaardian casual shoes',spawnCount);
        thePlayer.inv.AddAnItem('Skellige casual shoes',spawnCount);
        thePlayer.inv.AddAnItem('Radovid boots 01',spawnCount);
        
 
    }


    function AddGlovesForW3Player()
    {
        		thePlayer.inv.AddAnItem('Guard Lvl1 Gloves 1',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl1 Gloves 2',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Gloves 1',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Gloves 2',spawnCount);
		
		thePlayer.inv.AddAnItem('Guard Lvl2 Gloves 1',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl2 Gloves 2',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Gloves 1',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Gloves 2',spawnCount);
		
		thePlayer.inv.AddAnItem('Knight Geralt Gloves 1',spawnCount);
		thePlayer.inv.AddAnItem('Knight Geralt Gloves 2',spawnCount);
		thePlayer.inv.AddAnItem('Knight Geralt A Gloves 1',spawnCount);
		thePlayer.inv.AddAnItem('Knight Geralt A Gloves 2',spawnCount);
		thePlayer.inv.AddAnItem('Toussaint Gloves 2',spawnCount);
        thePlayer.inv.AddAnItem('Starting Gloves',spawnCount);
        thePlayer.inv.AddAnItem('Wolf Gloves 1',spawnCount);
        thePlayer.inv.AddAnItem('Wolf Gloves 2',spawnCount);
        thePlayer.inv.AddAnItem('Lynx Gloves 1',spawnCount);
        thePlayer.inv.AddAnItem('Lynx Gloves 2',spawnCount);
        thePlayer.inv.AddAnItem('Gryphon Gloves 1',spawnCount);
        thePlayer.inv.AddAnItem('Gryphon Gloves 2',spawnCount);
        thePlayer.inv.AddAnItem('Bear Gloves 1',spawnCount);
        thePlayer.inv.AddAnItem('Bear Gloves 2',spawnCount);
        thePlayer.inv.AddAnItem('Gloves 01',spawnCount);
        thePlayer.inv.AddAnItem('Gloves 01 q2',spawnCount);
        thePlayer.inv.AddAnItem('Gloves 02',spawnCount);
        thePlayer.inv.AddAnItem('Gloves 03',spawnCount);
        thePlayer.inv.AddAnItem('Gloves 04',spawnCount);
        thePlayer.inv.AddAnItem('Gloves 05',spawnCount);
        thePlayer.inv.AddAnItem('Heavy gloves 01',spawnCount);
        thePlayer.inv.AddAnItem('Heavy gloves 02',spawnCount);
        thePlayer.inv.AddAnItem('Heavy gloves 03',spawnCount);
        thePlayer.inv.AddAnItem('Heavy gloves 04',spawnCount);
        thePlayer.inv.AddAnItem('Wild Hunt gloves 01',spawnCount);
        
        
    }


    function AddSetsForW3Player()
    {


        		thePlayer.inv.AddAnItem('Bear Armor 4',spawnCount);
		thePlayer.inv.AddAnItem('Bear Boots 5',spawnCount);
		thePlayer.inv.AddAnItem('Bear Pants 5',spawnCount);
		thePlayer.inv.AddAnItem('Bear Gloves 5',spawnCount);
		thePlayer.inv.AddAnItem('Bear School steel sword 4',spawnCount);
		thePlayer.inv.AddAnItem('Bear School silver sword 4',spawnCount);
        		thePlayer.inv.AddAnItem('Lynx Armor 4',spawnCount);
		thePlayer.inv.AddAnItem('Lynx Boots 5',spawnCount);
		thePlayer.inv.AddAnItem('Lynx Pants 5',spawnCount);
		thePlayer.inv.AddAnItem('Lynx Gloves 5',spawnCount);
		thePlayer.inv.AddAnItem('Lynx School steel sword 4',spawnCount);
		thePlayer.inv.AddAnItem('Lynx School silver sword 4',spawnCount);
        		thePlayer.inv.AddAnItem('Gryphon Armor 4',spawnCount);
		thePlayer.inv.AddAnItem('Gryphon Boots 5',spawnCount);
		thePlayer.inv.AddAnItem('Gryphon Pants 5',spawnCount);
		thePlayer.inv.AddAnItem('Gryphon Gloves 5',spawnCount);
		thePlayer.inv.AddAnItem('Gryphon School steel sword 4',spawnCount);
		thePlayer.inv.AddAnItem('Gryphon School silver sword 4',spawnCount);
        		thePlayer.inv.AddAnItem('Wolf Armor 4',spawnCount);
		thePlayer.inv.AddAnItem('Wolf Boots 5',spawnCount);
		thePlayer.inv.AddAnItem('Wolf Pants 5',spawnCount);
		thePlayer.inv.AddAnItem('Wolf Gloves 5',spawnCount);
		thePlayer.inv.AddAnItem('Wolf School steel sword 4',spawnCount);
		thePlayer.inv.AddAnItem('Wolf School silver sword 4',spawnCount);
        		thePlayer.inv.AddAnItem('Red Wolf Armor 1',spawnCount);
		thePlayer.inv.AddAnItem('Red Wolf Boots 1',spawnCount);
		thePlayer.inv.AddAnItem('Red Wolf Pants 1',spawnCount);
		thePlayer.inv.AddAnItem('Red Wolf Gloves 1',spawnCount);
		thePlayer.inv.AddAnItem('Red Wolf School steel sword 1',spawnCount);
		thePlayer.inv.AddAnItem('Red Wolf School silver sword 1',spawnCount);
     		thePlayer.inv.AddAnItem('Red Wolf Armor 2',spawnCount);
		thePlayer.inv.AddAnItem('Red Wolf Boots 2',spawnCount);
		thePlayer.inv.AddAnItem('Red Wolf Pants 2',spawnCount);
		thePlayer.inv.AddAnItem('Red Wolf Gloves 2',spawnCount);
		thePlayer.inv.AddAnItem('Red Wolf School steel sword 2',spawnCount);
		thePlayer.inv.AddAnItem('Red Wolf School silver sword 2',spawnCount);   
        thePlayer.inv.AddAnItem('Wolf Boots 1',spawnCount);
        thePlayer.inv.AddAnItem('Lynx Boots 1',spawnCount);
        thePlayer.inv.AddAnItem('Gryphon Boots 1',spawnCount);
        thePlayer.inv.AddAnItem('Bear Boots 1',spawnCount);
        thePlayer.inv.AddAnItem('Wolf Pants 1',spawnCount);
        thePlayer.inv.AddAnItem('Lynx Pants 1',spawnCount);
        thePlayer.inv.AddAnItem('Gryphon Pants 1',spawnCount);
        thePlayer.inv.AddAnItem('Bear Pants 1',spawnCount);
        thePlayer.inv.AddAnItem('Bear Armor',spawnCount);
        thePlayer.inv.AddAnItem('Gryphon Armor',spawnCount);
        thePlayer.inv.AddAnItem('Lynx Armor',spawnCount);
        thePlayer.inv.AddAnItem('Wolf Armor',spawnCount);
        thePlayer.inv.AddAnItem('Wolf Gloves 1',spawnCount);
        thePlayer.inv.AddAnItem('Lynx Gloves 1',spawnCount);
        thePlayer.inv.AddAnItem('Gryphon Gloves 1',spawnCount);
        thePlayer.inv.AddAnItem('Bear Gloves 1',spawnCount);
        thePlayer.inv.AddAnItem('Bear School steel sword',spawnCount);
        thePlayer.inv.AddAnItem('Gryphon School steel sword',spawnCount);
        thePlayer.inv.AddAnItem('Lynx School steel sword',spawnCount);
        thePlayer.inv.AddAnItem('Wolf School steel sword',spawnCount);
        thePlayer.inv.AddAnItem('Bear School silver sword',spawnCount);
        thePlayer.inv.AddAnItem('Gryphon School silver sword',spawnCount);
        thePlayer.inv.AddAnItem('Lynx School silver sword',spawnCount);
        thePlayer.inv.AddAnItem('Wolf School silver sword',spawnCount);
        	thePlayer.inv.AddAnItem('FeromoneBomb',spawnCount);
	thePlayer.inv.AddAnItem('q205_gland_formula',spawnCount);
	thePlayer.inv.AddAnItem('q205_mushroom_formula',spawnCount);
	thePlayer.inv.AddAnItem('Recipe for Lesser White Honey',spawnCount);
	thePlayer.inv.AddAnItem('sq402_vitriol',spawnCount);
	thePlayer.inv.AddAnItem('sq402_rebis',spawnCount);
	thePlayer.inv.AddAnItem('sq402_hydragenum',spawnCount);
	thePlayer.inv.AddAnItem('sq402_aether',spawnCount);
	thePlayer.inv.AddAnItem('sq402_quebrith',spawnCount);
    thePlayer.inv.AddAnItem('Crafted Ofir Boots');
	thePlayer.inv.AddAnItem('Crafted Ofir Gloves');
	thePlayer.inv.AddAnItem('Crafted Ofir Pants');
	thePlayer.inv.AddAnItem('Crafted Ofir Steel Sword');
	thePlayer.inv.AddAnItem('Ofir Sabre 1');
	thePlayer.inv.AddAnItem('Ofir Sabre 2');
	thePlayer.inv.AddAnItem('Horse Saddle 6');
	thePlayer.inv.AddAnItem('Ofir Horse Bag');
	thePlayer.inv.AddAnItem('Ofir Horse Blinders');

	thePlayer.inv.AddAnItem('Ofir Armor');
	thePlayer.inv.AddAnItem('Crafted Ofir Armor');
	thePlayer.inv.AddAnItem('Olgierd Sabre');
	thePlayer.inv.AddAnItem('Soltis Vodka');
	thePlayer.inv.AddAnItem('Cornucopia');
	thePlayer.inv.AddAnItem('Flaming Rose Armor');
	thePlayer.inv.AddAnItem('Burning Rose Sword');
	thePlayer.inv.AddAnItem('Geralt Kontusz');
	thePlayer.inv.AddAnItem('Geralt Kontusz Boots');
	thePlayer.inv.AddAnItem('EP1 Witcher Silver Sword');
	thePlayer.inv.AddAnItem('EP1 Viper School steel sword');
	thePlayer.inv.AddAnItem('EP1 Viper School silver sword');
    }
    function AddBooksForW3Player()
    {
        var manager : CWitcherJournalManager;
	
	manager = theGame.GetJournalManager();
	
	activateJournalBestiaryEntryWithAlias("BestiaryPanther", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCBeastOfBeauclaire", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCPigs", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCBigBadWolf", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCEP2Boar", manager);
	
	
	activateJournalBestiaryEntryWithAlias("BestiaryDracolizard", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCDracolizardMatriarch", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCSilverBasilisk", manager);
	
	
	activateJournalBestiaryEntryWithAlias("BestiarySharley", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCSharleyMatriarch", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCSpriggan", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCSharleyCaptive", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCFTWitch", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCMQ7002Borowy", manager);
	
	
	activateJournalBestiaryEntryWithAlias("BestiaryBarghest", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCNightmare", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCDaphne", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCRapunzel", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCBeanshee", manager);
	
	
	activateJournalBestiaryEntryWithAlias("BestiaryGarkain", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryBruxa", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryFleder", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryAlp", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCBruxaCB", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCAlphaGarkain", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCDettlaff", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCProtofleder", manager);
	
	
	activateJournalBestiaryEntryWithAlias("BestiaryDagonet", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryCloudGiant"	, manager);
	
	
	activateJournalBestiaryEntryWithAlias("BestiaryGraveir", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryWicht", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCWightCollector", manager);
	
	
	activateJournalBestiaryEntryWithAlias("BestiaryScolopendromorph", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryPaleWidow", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryKikimoraWarrior", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryKikimoraWorker"	, manager);
	
	
	activateJournalBestiaryEntryWithAlias("BestiaryArchespore", manager);
	
	
	activateJournalBestiaryEntryWithAlias("BestiaryDarkPixie", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCMoreauGolem", manager);
        thePlayer.inv.AddAnItem('Beasts vol 1',spawnCount);
        thePlayer.inv.AddAnItem('Beasts vol 2',spawnCount);
        thePlayer.inv.AddAnItem('Cursed Monsters vol 1',spawnCount);
        thePlayer.inv.AddAnItem('Cursed Monsters vol 2',spawnCount);
        thePlayer.inv.AddAnItem('Draconides vol 1',spawnCount);
        thePlayer.inv.AddAnItem('Draconides vol 2',spawnCount);
        thePlayer.inv.AddAnItem('Hybrid Monsters vol 1',spawnCount);
        thePlayer.inv.AddAnItem('Hybrid Monsters vol 2',spawnCount);
        thePlayer.inv.AddAnItem('Insectoids vol 1',spawnCount);
        thePlayer.inv.AddAnItem('Insectoids vol 2',spawnCount);
        thePlayer.inv.AddAnItem('Magical Monsters vol 1',spawnCount);
        thePlayer.inv.AddAnItem('Magical Monsters vol 2',spawnCount);
        thePlayer.inv.AddAnItem('Necrophage vol 1',spawnCount);
        thePlayer.inv.AddAnItem('Necrophage vol 2',spawnCount);
        thePlayer.inv.AddAnItem('Relict Monsters vol 1',spawnCount);
        thePlayer.inv.AddAnItem('Relict Monsters vol 2',spawnCount);
        thePlayer.inv.AddAnItem('Specters vol 1',spawnCount);
        thePlayer.inv.AddAnItem('Specters vol 2',spawnCount);
        thePlayer.inv.AddAnItem('Ogres vol 1',spawnCount);
        thePlayer.inv.AddAnItem('Ogres vol 2',spawnCount);
        thePlayer.inv.AddAnItem('Vampires vol 1',spawnCount);
        thePlayer.inv.AddAnItem('Vampires vol 2',spawnCount);
        thePlayer.inv.AddAnItem('Wild Hunt',spawnCount);
        thePlayer.inv.AddAnItem('Horse vol 1',spawnCount);
        thePlayer.inv.AddAnItem('Horse vol 2',spawnCount);
        thePlayer.inv.AddAnItem('Boat vol 1',spawnCount);
        thePlayer.inv.AddAnItem('Boat vol 2',spawnCount);
        thePlayer.inv.AddAnItem('q701_crayfish_soup_recipe',spawnCount);
	thePlayer.inv.AddAnItem('q701_pate_recipe',spawnCount);
	thePlayer.inv.AddAnItem('q701_godfryd_book',spawnCount);
	thePlayer.inv.AddAnItem('q701_rydygier_book',spawnCount);
	thePlayer.inv.AddAnItem('q701_1st_victim_files',spawnCount);
	thePlayer.inv.AddAnItem('q701_2nd_victim_files',spawnCount);
	thePlayer.inv.AddAnItem('q701_3rd_victim_files',spawnCount);
	thePlayer.inv.AddAnItem('q701_goliath_book',spawnCount);
	thePlayer.inv.AddAnItem('q701_gardens_invitation',spawnCount);
	thePlayer.inv.AddAnItem('q701_wine_flier_01',spawnCount);
	thePlayer.inv.AddAnItem('q701_wine_flier_02',spawnCount);
	thePlayer.inv.AddAnItem('q701_wine_flier_03',spawnCount);
	thePlayer.inv.AddAnItem('q701_corvo_bianco_book',spawnCount);
	thePlayer.inv.AddAnItem('q701_fisherman_poetry',spawnCount);
	thePlayer.inv.AddAnItem('q703_killing_vampires',spawnCount);
	thePlayer.inv.AddAnItem('q703_history_of_est_est',spawnCount);
	thePlayer.inv.AddAnItem('q703_history_of_pomino',spawnCount);
	thePlayer.inv.AddAnItem('q703_one_handed_adalard',spawnCount);
	thePlayer.inv.AddAnItem('q703_napkin_love_letter',spawnCount);
	thePlayer.inv.AddAnItem('q703_letter_of_refusal',spawnCount);
	thePlayer.inv.AddAnItem('q703_piece_of_scenario',spawnCount);
	thePlayer.inv.AddAnItem('q704_ft_little_mermaid',spawnCount);
	thePlayer.inv.AddAnItem('q704_ft_letter_from_dandelion',spawnCount);
	thePlayer.inv.AddAnItem('sq701_registration_note',spawnCount);
	thePlayer.inv.AddAnItem('sq701_vivienne_note',spawnCount);
	thePlayer.inv.AddAnItem('sq701_rainfarn_note',spawnCount);
	thePlayer.inv.AddAnItem('sq701_guillaume_note',spawnCount);
	thePlayer.inv.AddAnItem('sq701_palmerin_note',spawnCount);
	thePlayer.inv.AddAnItem('sq701_tailles_note',spawnCount);
	thePlayer.inv.AddAnItem('sq701_anseis_note',spawnCount);
	thePlayer.inv.AddAnItem('sq701_donimir_note',spawnCount);
	thePlayer.inv.AddAnItem('sq701_horm_note',spawnCount);
	thePlayer.inv.AddAnItem('sq701_horm_emhyr_dead_note',spawnCount);
	thePlayer.inv.AddAnItem('sq701_horm_emhyr_victory_note',spawnCount);
	thePlayer.inv.AddAnItem('sq701_fan_01_note',spawnCount);
	thePlayer.inv.AddAnItem('sq701_fan_02_note',spawnCount);
	thePlayer.inv.AddAnItem('sq701_fan_03_note',spawnCount);
	thePlayer.inv.AddAnItem('lore_biography_beledals_grandfather',spawnCount);
	thePlayer.inv.AddAnItem('mq7011_procedures_book',spawnCount);
	thePlayer.inv.AddAnItem('mq7011_bank_book_filler_01',spawnCount);
	thePlayer.inv.AddAnItem('mq7011_bank_flier_01',spawnCount);
	thePlayer.inv.AddAnItem('mq7011_bank_flier_02',spawnCount);
	thePlayer.inv.AddAnItem('mq7020_hairdresser_recipe',spawnCount);
	thePlayer.inv.AddAnItem('mq7020_hairdresser_leaflet',spawnCount);
	thePlayer.inv.AddAnItem('mq7020_duvall_poem',spawnCount);
	thePlayer.inv.AddAnItem('mq7020_map',spawnCount);
	thePlayer.inv.AddAnItem('lore_basilisk_hunts',spawnCount);
	thePlayer.inv.AddAnItem('lore_toussaint_civil_war',spawnCount);
	thePlayer.inv.AddAnItem('lore_toussaint_nobles',spawnCount);
	thePlayer.inv.AddAnItem('lore_toussaint_ecology',spawnCount);
	thePlayer.inv.AddAnItem('lore_gwent_history',spawnCount);
        thePlayer.inv.AddAnItem('Gear improvement',spawnCount);
        thePlayer.inv.AddAnItem('Weapon maintenance',spawnCount);
        thePlayer.inv.AddAnItem('Armor maintenancet',spawnCount);
        thePlayer.inv.AddAnItem('Nilfgard arms and tactics',spawnCount);
        thePlayer.inv.AddAnItem('Norther Kingdoms arms and tactics',spawnCount);
        thePlayer.inv.AddAnItem('Skelige arms and tactics',spawnCount);
        thePlayer.inv.AddAnItem('Theatre Glossary vol 1',spawnCount);
        thePlayer.inv.AddAnItem('Theatre Glossary vol 2',spawnCount);
        thePlayer.inv.AddAnItem('Jacob of Varazze Chronicles',spawnCount);
        thePlayer.inv.AddAnItem('Poems of Gonzal de Verceo',spawnCount);
        thePlayer.inv.AddAnItem('Book of Arachases',spawnCount);
        thePlayer.inv.AddAnItem('Glossary Temerian Dynasty',spawnCount);
        thePlayer.inv.AddAnItem('Orders from Shilard',spawnCount);
        thePlayer.inv.AddAnItem('Journey into the mind',spawnCount);
        thePlayer.inv.AddAnItem('Necronomicon',spawnCount);
        thePlayer.inv.AddAnItem('Lead ore',spawnCount);

}

    


    function AddLoreForW3Player()
    {
        thePlayer.inv.AddAnItem('lore_imperial_edict_i',spawnCount);
        thePlayer.inv.AddAnItem('lore_imperial_edict_ii',spawnCount);
        thePlayer.inv.AddAnItem('lore_nilfgaardian_royal_dynasty',spawnCount);
        thePlayer.inv.AddAnItem('lore_nilfgaardian_history_book',spawnCount);
        thePlayer.inv.AddAnItem('lore_nilfgaardian_empire',spawnCount);
        thePlayer.inv.AddAnItem('lore_lodge_of_sorceresses',spawnCount);
        thePlayer.inv.AddAnItem('lore_third_war_with_nilfgaard',spawnCount);
        thePlayer.inv.AddAnItem('lore_wars_with_nilfgaard',spawnCount);
        thePlayer.inv.AddAnItem('lore_novigrad',spawnCount);
        thePlayer.inv.AddAnItem('lore_skellige_island',spawnCount);
        thePlayer.inv.AddAnItem('lore_skellige_heroes_sove',spawnCount);
        thePlayer.inv.AddAnItem('lore_skellige_heroes_tyr',spawnCount);
        thePlayer.inv.AddAnItem('lore_skellige_heroes_otkell',spawnCount);
        thePlayer.inv.AddAnItem('lore_skellige_heroes_modolf',spawnCount);
        thePlayer.inv.AddAnItem('lore_skellige_heroes_broddr',spawnCount);
        thePlayer.inv.AddAnItem('lore_skellige_heroes_grymmdjarr',spawnCount);
        thePlayer.inv.AddAnItem('lore_oxenfurt',spawnCount);
        thePlayer.inv.AddAnItem('lore_velen',spawnCount);
        thePlayer.inv.AddAnItem('lore_fate_of_temeria',spawnCount);
        thePlayer.inv.AddAnItem('lore_fall_of_wyzima',spawnCount);
        thePlayer.inv.AddAnItem('lore_summit_of_loc_muinne',spawnCount);
        thePlayer.inv.AddAnItem('lore_redania',spawnCount);
        thePlayer.inv.AddAnItem('lore_radovids_rise_to_power',spawnCount);
        thePlayer.inv.AddAnItem('lore_redanian_secret_service',spawnCount);
        thePlayer.inv.AddAnItem('lore_kovir',spawnCount);
        thePlayer.inv.AddAnItem('lore_kovir',spawnCount);
        thePlayer.inv.AddAnItem('lore_basics_of_magic',spawnCount);
        thePlayer.inv.AddAnItem('lore_principles_of_eternal_fire',spawnCount);
        thePlayer.inv.AddAnItem('lore_cult_of_freyia',spawnCount);
        thePlayer.inv.AddAnItem('lore_cult_of_hemdall',spawnCount);
        thePlayer.inv.AddAnItem('lore_druids',spawnCount);
        thePlayer.inv.AddAnItem('lore_witchers',spawnCount);
        thePlayer.inv.AddAnItem('lore_monstrum',spawnCount);
        thePlayer.inv.AddAnItem('lore_radovid_propaganda_pamphlet',spawnCount);
        thePlayer.inv.AddAnItem('lore_the_great_four',spawnCount);
        thePlayer.inv.AddAnItem('lore_wild_hunt',spawnCount);
        thePlayer.inv.AddAnItem('lore_non_humans',spawnCount);
        thePlayer.inv.AddAnItem('lore_prophecy_of_ithlinne',spawnCount);
        thePlayer.inv.AddAnItem('lore_conjunction_of_spheres',spawnCount);
        thePlayer.inv.AddAnItem('lore_theory_of_spheres',spawnCount);
        thePlayer.inv.AddAnItem('lore_elder_blood',spawnCount);
        thePlayer.inv.AddAnItem('lore_an_seidhe_and_aen_elle',spawnCount);
        thePlayer.inv.AddAnItem('lore_cirilla_of_cintra',spawnCount);
        thePlayer.inv.AddAnItem('lore_elven_sages',spawnCount);
        thePlayer.inv.AddAnItem('lore_elven_ruins',spawnCount);
        thePlayer.inv.AddAnItem('lore_elven_legends',spawnCount);
        thePlayer.inv.AddAnItem('lore_witch_hunters',spawnCount);
        thePlayer.inv.AddAnItem('lore_goetia',spawnCount);
        thePlayer.inv.AddAnItem('lore_oneiromancy',spawnCount);
        thePlayer.inv.AddAnItem('lore_hydromancy',spawnCount);
        thePlayer.inv.AddAnItem('lore_necromancy',spawnCount);
        thePlayer.inv.AddAnItem('lore_tyromancy',spawnCount);
        thePlayer.inv.AddAnItem('lore_polymorphism',spawnCount);
        thePlayer.inv.AddAnItem('lore_war_between_astrals',spawnCount);
        thePlayer.inv.AddAnItem('lore_witcher_signs',spawnCount);
        thePlayer.inv.AddAnItem('lore_last_wish',spawnCount);
        thePlayer.inv.AddAnItem('lore_bells_of_beauclair',spawnCount);
        thePlayer.inv.AddAnItem('lore_sands_of_zerrikania',spawnCount);
        thePlayer.inv.AddAnItem('lore_naglfar_demonic_drakkar',spawnCount);
        thePlayer.inv.AddAnItem('lore_ragnarok',spawnCount);
        thePlayer.inv.AddAnItem('lore_study_on_white_cold',spawnCount);
        thePlayer.inv.AddAnItem('lore_journals_from_urskar_1',spawnCount);
        thePlayer.inv.AddAnItem('lore_journals_from_urskar_2',spawnCount);
        thePlayer.inv.AddAnItem('lore_journals_from_urskar_3',spawnCount);
        thePlayer.inv.AddAnItem('lore_journals_from_urskar_4',spawnCount);
        thePlayer.inv.AddAnItem('lore_journals_from_urskar_5',spawnCount);
        thePlayer.inv.AddAnItem('lore_journals_from_urskar_6',spawnCount);
        thePlayer.inv.AddAnItem('lore_journals_from_urskar_7',spawnCount);
        thePlayer.inv.AddAnItem('lore_nilfgaardian_transport_orders',spawnCount);
        thePlayer.inv.AddAnItem('lore_yennefer_journals',spawnCount);
        thePlayer.inv.AddAnItem('lore_inteligence_report_about_ciri',spawnCount);
        thePlayer.inv.AddAnItem('lore_unfinished_war_annals',spawnCount);
        thePlayer.inv.AddAnItem('lore_aleksanders_notes',spawnCount);
        thePlayer.inv.AddAnItem('lore_popiels_journal',spawnCount);
        thePlayer.inv.AddAnItem('lore_about_the_fourth_witch',spawnCount);
        thePlayer.inv.AddAnItem('lore_brother_adalbert_bestiary',spawnCount);

    }

    function AddFoodForW3Player()
    {
        thePlayer.inv.AddAnItem( 'Beauclair White',spawnCount );
        thePlayer.inv.AddAnItem( 'Cherry Cordial',spawnCount );
        thePlayer.inv.AddAnItem( 'Dijkstra Dry',spawnCount );
        thePlayer.inv.AddAnItem( 'Erveluce',spawnCount );
        thePlayer.inv.AddAnItem( 'Est Est',spawnCount );
        thePlayer.inv.AddAnItem( 'Kaedwenian Stout',spawnCount );
        thePlayer.inv.AddAnItem( 'Mahakam Spirit',spawnCount );
        thePlayer.inv.AddAnItem( 'Mandrake cordial',spawnCount );
        thePlayer.inv.AddAnItem( 'Mettina Rose',spawnCount );
        thePlayer.inv.AddAnItem( 'Nilfgaardian Lemon',spawnCount );
        thePlayer.inv.AddAnItem( 'Local pepper vodka',spawnCount );
        thePlayer.inv.AddAnItem( 'Redanian Herbal',spawnCount );
        thePlayer.inv.AddAnItem( 'Redanian Lager',spawnCount );
        thePlayer.inv.AddAnItem( 'Rivian Kriek',spawnCount );
        thePlayer.inv.AddAnItem( 'Temerian Rye',spawnCount );
        thePlayer.inv.AddAnItem( 'Viziman Champion',spawnCount );
        thePlayer.inv.AddAnItem( 'Apple',spawnCount );
        thePlayer.inv.AddAnItem( 'Baked apple',spawnCount );
        thePlayer.inv.AddAnItem( 'Banana',spawnCount );
        thePlayer.inv.AddAnItem( 'Bell pepper',spawnCount );
        thePlayer.inv.AddAnItem( 'Blueberries',spawnCount );
        thePlayer.inv.AddAnItem( 'Bread',spawnCount );
        thePlayer.inv.AddAnItem( 'Burned bread',spawnCount );
        thePlayer.inv.AddAnItem( 'Bun',spawnCount );
        thePlayer.inv.AddAnItem( 'Burned bun',spawnCount );
        thePlayer.inv.AddAnItem( 'Candy',spawnCount );
        thePlayer.inv.AddAnItem( 'Cheese',spawnCount );
        thePlayer.inv.AddAnItem( 'Chicken',spawnCount );
        thePlayer.inv.AddAnItem( 'Chicken leg',spawnCount );
        thePlayer.inv.AddAnItem( 'Roasted chicken leg',spawnCount );
        thePlayer.inv.AddAnItem( 'Roasted chicken',spawnCount );
        thePlayer.inv.AddAnItem( 'Chicken sandwich',spawnCount );
        thePlayer.inv.AddAnItem( 'Grilled chicken sandwich',spawnCount );
        thePlayer.inv.AddAnItem( 'Cucumber',spawnCount );
        thePlayer.inv.AddAnItem( 'Dried fruit',spawnCount );
        thePlayer.inv.AddAnItem( 'Dried fruit and nuts',spawnCount );
        thePlayer.inv.AddAnItem( 'Egg',spawnCount );
        thePlayer.inv.AddAnItem( 'Fish',spawnCount );
        thePlayer.inv.AddAnItem( 'Fried fish',spawnCount );
        thePlayer.inv.AddAnItem( 'Gutted fish',spawnCount );
        thePlayer.inv.AddAnItem( 'Fondue',spawnCount );
        thePlayer.inv.AddAnItem( 'Grapes',spawnCount );
        thePlayer.inv.AddAnItem( 'Ham sandwich',spawnCount );
        thePlayer.inv.AddAnItem( 'Very good honey',spawnCount );
        thePlayer.inv.AddAnItem( 'Honeycomb',spawnCount );
        thePlayer.inv.AddAnItem( 'Fried meat',spawnCount );
        thePlayer.inv.AddAnItem( 'Raw meat',spawnCount );
        thePlayer.inv.AddAnItem( 'Cows milk',spawnCount );
        thePlayer.inv.AddAnItem( 'Goats milk',spawnCount );
        thePlayer.inv.AddAnItem( 'Mushroom',spawnCount );
        thePlayer.inv.AddAnItem( 'Mutton curry',spawnCount );
        thePlayer.inv.AddAnItem( 'Mutton leg',spawnCount );
        thePlayer.inv.AddAnItem( 'Olive',spawnCount );
        thePlayer.inv.AddAnItem( 'Onion',spawnCount );
        thePlayer.inv.AddAnItem( 'Pear',spawnCount );
        thePlayer.inv.AddAnItem( 'Pepper',spawnCount );
        thePlayer.inv.AddAnItem( 'Plum',spawnCount );
        thePlayer.inv.AddAnItem( 'Pork',spawnCount );
        thePlayer.inv.AddAnItem( 'Grilled pork',spawnCount );
        thePlayer.inv.AddAnItem( 'Potatoes',spawnCount );
        thePlayer.inv.AddAnItem( 'Baked potato',spawnCount );
        thePlayer.inv.AddAnItem( 'Chips',spawnCount );
        thePlayer.inv.AddAnItem( 'Raspberries',spawnCount );
        thePlayer.inv.AddAnItem( 'Raspberry juice',spawnCount );
        thePlayer.inv.AddAnItem( 'Strawberries',spawnCount );
        thePlayer.inv.AddAnItem( 'Toffee',spawnCount );
        thePlayer.inv.AddAnItem( 'Vinegar',spawnCount );
        thePlayer.inv.AddAnItem( 'Butter Bandalura',spawnCount );
        thePlayer.inv.AddAnItem( 'Apple juice',spawnCount );
        thePlayer.inv.AddAnItem( 'Bottled water',spawnCount );
thePlayer.inv.AddAnItem('Bourgogne chardonnay',spawnCount);
	thePlayer.inv.AddAnItem('Chateau mont valjean',spawnCount);
	thePlayer.inv.AddAnItem('Bourgogne pinot noir',spawnCount);
	thePlayer.inv.AddAnItem('Saint mathieu rouge',spawnCount);
	thePlayer.inv.AddAnItem('Duke nicolas chardonnay',spawnCount);
	thePlayer.inv.AddAnItem('Uncle toms exquisite blanc',spawnCount);
	thePlayer.inv.AddAnItem('Chevalier adam pinot blanc reserve',spawnCount);
	thePlayer.inv.AddAnItem('Prince john merlot',spawnCount);
	thePlayer.inv.AddAnItem('Count var ochmann shiraz',spawnCount);
	thePlayer.inv.AddAnItem('Chateau de konrad cabernet',spawnCount);
	thePlayer.inv.AddAnItem('Geralt de rivia',spawnCount);
	thePlayer.inv.AddAnItem('White Wolf',spawnCount);
	thePlayer.inv.AddAnItem('Butcher of Blaviken',spawnCount);
	thePlayer.inv.AddAnItem('Pheasant gutted',spawnCount);
	thePlayer.inv.AddAnItem('Tarte tatin',spawnCount);
	thePlayer.inv.AddAnItem('Ratatouille',spawnCount);
	thePlayer.inv.AddAnItem('Baguette camembert',spawnCount);
	thePlayer.inv.AddAnItem('Crossaint honey',spawnCount);
	thePlayer.inv.AddAnItem('Herb toasts',spawnCount);
	thePlayer.inv.AddAnItem('Brioche',spawnCount);
	thePlayer.inv.AddAnItem('Flamiche',spawnCount);
	thePlayer.inv.AddAnItem('Camembert',spawnCount);
	thePlayer.inv.AddAnItem('Chocolate souffle',spawnCount);
	thePlayer.inv.AddAnItem('Pate chicken livers',spawnCount);
	thePlayer.inv.AddAnItem('Confit de canard',spawnCount);
	thePlayer.inv.AddAnItem('Baguette fish paste',spawnCount);
	thePlayer.inv.AddAnItem('Fish tarte',spawnCount);
	thePlayer.inv.AddAnItem('Boeuf bourguignon',spawnCount);
	thePlayer.inv.AddAnItem('Rillettes porc',spawnCount);
	thePlayer.inv.AddAnItem('Onion soup',spawnCount);
	thePlayer.inv.AddAnItem('Ham roasted',spawnCount);
	thePlayer.inv.AddAnItem('Tomato',spawnCount);
	thePlayer.inv.AddAnItem('Cookies',spawnCount);
	thePlayer.inv.AddAnItem('Ginger Bread',spawnCount);
	thePlayer.inv.AddAnItem('Magic Mushrooms',spawnCount);
	thePlayer.inv.AddAnItem('Poison Apple',spawnCount);
    }


    function AddDrinksForW3Player()
    {
            
        thePlayer.inv.AddAnItem('Apple juice',spawnCount);
        thePlayer.inv.AddAnItem('Bottled water',spawnCount);
        thePlayer.inv.AddAnItem('Cows milk',spawnCount);
        thePlayer.inv.AddAnItem('Goats milk',spawnCount);
        thePlayer.inv.AddAnItem('Raspberry juice',spawnCount);
        thePlayer.inv.AddAnItem('Mandrake cordial',spawnCount);
        thePlayer.inv.AddAnItem('Cherry Cordial',spawnCount);
        thePlayer.inv.AddAnItem('Mahakam Spirit',spawnCount);
        thePlayer.inv.AddAnItem('Local pepper vodka',spawnCount);
        thePlayer.inv.AddAnItem('Nilfgaardian Lemon',spawnCount);
        thePlayer.inv.AddAnItem('Redanian Herbal',spawnCount);
        thePlayer.inv.AddAnItem('Temerian Rye',spawnCount);
        thePlayer.inv.AddAnItem('Beauclair White',spawnCount);
        thePlayer.inv.AddAnItem('Mettina Rose',spawnCount);
        thePlayer.inv.AddAnItem('Est Est',spawnCount);
        thePlayer.inv.AddAnItem('Erveluce',spawnCount);
        thePlayer.inv.AddAnItem('Dijkstra Dry',spawnCount);
        thePlayer.inv.AddAnItem('Viziman Champion',spawnCount);
        thePlayer.inv.AddAnItem('Redanian Lager',spawnCount);
        thePlayer.inv.AddAnItem('Rivian Kriek',spawnCount);
        thePlayer.inv.AddAnItem('Kaedwenian Stout',spawnCount);
        thePlayer.inv.AddAnItem('Dwarven spirit',spawnCount);
        
    }


    function AddTrophiesForW3Player()
    {
        thePlayer.inv.AddAnItem('Nekkers Trophy',spawnCount);
        thePlayer.inv.AddAnItem('Werewolf Trophy',spawnCount);
        thePlayer.inv.AddAnItem('q002_griffin_trophy',spawnCount);
        thePlayer.inv.AddAnItem('Drowned Dead Trophy',spawnCount);
        thePlayer.inv.AddAnItem('mh101_cockatrice_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mh102_arachas_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mh103_nightwraith_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mh104_ekimma_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mh105_wyvern_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mh106_gravehag_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mh107_czart_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mh108_fogling_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mh201_cave_troll_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mh202_nekker_warrior_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mh203_drowned_dead_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mh204_leshy_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mh205_leshy_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mh206_fiend_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mh207_wraith_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mh208_forktail_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mh209_fogling_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mh210_lamia_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mh211_bies_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mh212_erynie_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mq1024_water_hag_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mq1051_wyvern_trophy',spawnCount);
        thePlayer.inv.AddAnItem('q202_ice_giant_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mh301_gryphon_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mh302_leshy_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mh303_succubus_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mh304_katakan_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mh305_doppler_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mh306_dao_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mh308_noonwraith_trophy',spawnCount);
        thePlayer.inv.AddAnItem('sq108_griffin_trophy',spawnCount);
        thePlayer.inv.AddAnItem('mq0003_noonwraith_trophy',spawnCount);

    }


    function AddDyeForW3Player()
    {
        thePlayer.inv.AddAnItem('Dye Default',spawnCount);
        thePlayer.inv.AddAnItem('Dye Black',spawnCount);
        thePlayer.inv.AddAnItem('Dye Blue',spawnCount);
        thePlayer.inv.AddAnItem('Dye Brown',spawnCount);
        thePlayer.inv.AddAnItem('Dye Gray',spawnCount);
        thePlayer.inv.AddAnItem('Dye Green',spawnCount);
        thePlayer.inv.AddAnItem('Dye Orange',spawnCount);
        thePlayer.inv.AddAnItem('Dye Pink',spawnCount);
        thePlayer.inv.AddAnItem('Dye Purple',spawnCount);
        thePlayer.inv.AddAnItem('Dye Red',spawnCount);
        thePlayer.inv.AddAnItem('Dye Turquoise',spawnCount);
        thePlayer.inv.AddAnItem('Dye White',spawnCount);
        thePlayer.inv.AddAnItem('Dye Yellow',spawnCount);
        	thePlayer.inv.AddAnItem('Recipe Dye Gray',spawnCount);
	thePlayer.inv.AddAnItem('Recipe Dye Turquoise',spawnCount);
	thePlayer.inv.AddAnItem('Recipe Dye Brown',spawnCount);
	thePlayer.inv.AddAnItem('Recipe Dye Green',spawnCount);
	thePlayer.inv.AddAnItem('Recipe Dye Blue',spawnCount);
	thePlayer.inv.AddAnItem('Recipe Dye Orange',spawnCount);
	thePlayer.inv.AddAnItem('Recipe Dye Pink',spawnCount);
	thePlayer.inv.AddAnItem('Recipe Dye Yellow',spawnCount);
	thePlayer.inv.AddAnItem('Recipe Dye Black',spawnCount);
	thePlayer.inv.AddAnItem('Recipe Dye White',spawnCount);
	thePlayer.inv.AddAnItem('Recipe Dye Red',spawnCount);
	thePlayer.inv.AddAnItem('Recipe Dye Purple',spawnCount);
    }


    function AddMiscForW3Player()
    {
        thePlayer.inv.AddAnItem('Horn_of_Hornwales',spawnCount);
        thePlayer.inv.AddAnItem('Painting_of_hemmelfart',spawnCount);
        thePlayer.inv.AddAnItem('Weapon repair kit 1',spawnCount);
        thePlayer.inv.AddAnItem('Weapon repair kit 2',spawnCount);
        thePlayer.inv.AddAnItem('Weapon repair kit 3',spawnCount);
        thePlayer.inv.AddAnItem('Armor repair kit 1',spawnCount);
        thePlayer.inv.AddAnItem('Armor repair kit 2',spawnCount);
        thePlayer.inv.AddAnItem('Armor repair kit 3',spawnCount);
        thePlayer.inv.AddAnItem('Dismantle Kit',spawnCount);
        thePlayer.inv.AddAnItem('Torch',spawnCount);
        thePlayer.inv.AddAnItem('q106_magic_oillamp',spawnCount);
        thePlayer.inv.AddAnItem('Oil Lamp',spawnCount);
        thePlayer.inv.AddAnItem('Illusion Medallion',spawnCount);
        thePlayer.inv.AddAnItem('q103_bell',spawnCount);
        thePlayer.inv.AddAnItem('202_hornval_horn',spawnCount);
        thePlayer.inv.AddAnItem('q203_eyeofloki',spawnCount);
        thePlayer.inv.AddAnItem('ciris_phylactery',spawnCount);
        thePlayer.inv.AddAnItem('q403_ciri_meteor',spawnCount);
        thePlayer.inv.AddAnItem('mh107_czart_lure',spawnCount);
         thePlayer.inv.AddAnItem('Short Steel Sword',spawnCount);
        thePlayer.inv.AddAnItem('Spear 2',spawnCount);
        thePlayer.inv.AddAnItem('Science',spawnCount);
        thePlayer.inv.AddAnItem('Apple',spawnCount);
        thePlayer.inv.AddAnItem('Kaedwenian Stout',spawnCount);
        thePlayer.inv.AddAnItem('Raspberries',spawnCount);
        thePlayer.inv.AddAnItem('mh301_gryphon_trophy',spawnCount);
        thePlayer.inv.AddAnItem('q103_tamara_shrine_key',spawnCount);
        thePlayer.inv.AddAnItem('Emerald',spawnCount);
        thePlayer.inv.AddAnItem('Perfume',spawnCount);
        thePlayer.inv.AddAnItem('Wraith essence',spawnCount);
        thePlayer.inv.AddAnItem('Balisse fruit',spawnCount);
        thePlayer.inv.AddAnItem('Recipe for Nigredo',spawnCount);
        thePlayer.inv.AddAnItem('Recipe for Maribor Forest 3',spawnCount);
        thePlayer.inv.AddAnItem('Hanged Man Venom 3',spawnCount);
        thePlayer.inv.AddAnItem('White Honey 1',spawnCount);
        thePlayer.inv.AddAnItem('White Gull 1',spawnCount);
        thePlayer.inv.AddAnItem('Hjalmar_Short_Steel_Sword',spawnCount);
        thePlayer.inv.AddAnItem('Rusty No Mans Land sword',spawnCount);
        thePlayer.inv.AddAnItem('Lynx School steel sword',spawnCount);
        thePlayer.inv.AddAnItem('Inquisitor sword 2',spawnCount);
        thePlayer.inv.AddAnItem('Gnomish sword 2',spawnCount);
        thePlayer.inv.AddAnItem('Draconide infused leather',spawnCount);
	thePlayer.inv.AddAnItem('Nickel mineral',spawnCount);
	thePlayer.inv.AddAnItem('Nickel ore',spawnCount);
	thePlayer.inv.AddAnItem('Copper mineral',spawnCount);
	
	thePlayer.inv.AddAnItem('Malachite mineral',spawnCount);
	thePlayer.inv.AddAnItem('Copper ore',spawnCount);
	thePlayer.inv.AddAnItem('Cupronickel ore',spawnCount);
	thePlayer.inv.AddAnItem('Copper ingot',spawnCount);
	thePlayer.inv.AddAnItem('Copper plate',spawnCount);
	thePlayer.inv.AddAnItem('Green gold mineral',spawnCount);
	thePlayer.inv.AddAnItem('Green gold ore',spawnCount);
	thePlayer.inv.AddAnItem('Green gold ingot',spawnCount);
	thePlayer.inv.AddAnItem('Green gold plate',spawnCount);
	thePlayer.inv.AddAnItem('Orichalcum mineral',spawnCount);
	thePlayer.inv.AddAnItem('Orichalcum ore',spawnCount);
	thePlayer.inv.AddAnItem('Orichalcum ingot',spawnCount);
	thePlayer.inv.AddAnItem('Orichalcum plate',spawnCount);
	thePlayer.inv.AddAnItem('Dwimeryte enriched ore',spawnCount);
	thePlayer.inv.AddAnItem('Dwimeryte enriched ingot',spawnCount);
	thePlayer.inv.AddAnItem('Dwimeryte enriched plate',spawnCount);
	thePlayer.inv.AddAnItem('Acid extract',spawnCount);
	thePlayer.inv.AddAnItem('Centipede discharge',spawnCount);
	thePlayer.inv.AddAnItem('Archespore juice',spawnCount);
	thePlayer.inv.AddAnItem('Kikimore discharge',spawnCount);
	thePlayer.inv.AddAnItem('Vampire blood',spawnCount);
	thePlayer.inv.AddAnItem('Monstrous carapace',spawnCount);
	thePlayer.inv.AddAnItem('Sharley dust',spawnCount);
	thePlayer.inv.AddAnItem('Wight ear',spawnCount);
	thePlayer.inv.AddAnItem('Barhest essence',spawnCount);
	thePlayer.inv.AddAnItem('Wight hair',spawnCount);
	thePlayer.inv.AddAnItem('Sharley heart',spawnCount);
	thePlayer.inv.AddAnItem('Monstrous pincer',spawnCount);
	thePlayer.inv.AddAnItem('Centipede mandible',spawnCount);
	thePlayer.inv.AddAnItem('Dracolizard plate',spawnCount);
	thePlayer.inv.AddAnItem('Monstrous spore',spawnCount);
	thePlayer.inv.AddAnItem('Wight stomach',spawnCount);
	thePlayer.inv.AddAnItem('Monstrous vine',spawnCount);
	thePlayer.inv.AddAnItem('Archespore tendril',spawnCount);
	thePlayer.inv.AddAnItem('Monstrous wing',spawnCount);
		thePlayer.inv.AddAnItem('Peacock feather',spawnCount);
		thePlayer.inv.AddAnItem('Dull meteorite axe',spawnCount);
		thePlayer.inv.AddAnItem('Broken meteorite pickaxe',spawnCount);
		thePlayer.inv.AddAnItem('Hotel silver breadknife',spawnCount);
		thePlayer.inv.AddAnItem('Hotel silver goblet',spawnCount);
		thePlayer.inv.AddAnItem('Hotel silver teapot',spawnCount);
		thePlayer.inv.AddAnItem('Hotel silver fruitbowl',spawnCount);
		thePlayer.inv.AddAnItem('Hotel silver serving tray',spawnCount);
		thePlayer.inv.AddAnItem('Hotel silver wine bottle',spawnCount);
		thePlayer.inv.AddAnItem('Hotel silver cup',spawnCount);
		thePlayer.inv.AddAnItem('Copper salt pepper shaker',spawnCount);
		thePlayer.inv.AddAnItem('Copper mug',spawnCount);
		thePlayer.inv.AddAnItem('Copper platter',spawnCount);
		thePlayer.inv.AddAnItem('Copper casket',spawnCount);
		thePlayer.inv.AddAnItem('Copper candelabra',spawnCount);
		thePlayer.inv.AddAnItem('Cupronickel axe head',spawnCount);
		thePlayer.inv.AddAnItem('Cupronickel pickaxe head',spawnCount);
		thePlayer.inv.AddAnItem('Copper chain',spawnCount);
		thePlayer.inv.AddAnItem('Green gold ruby ring',spawnCount);
		thePlayer.inv.AddAnItem('Green gold sapphire ring',spawnCount);
		thePlayer.inv.AddAnItem('Green gold emerald ring',spawnCount);
		thePlayer.inv.AddAnItem('Green gold diamond ring',spawnCount);
		thePlayer.inv.AddAnItem('Green gold amber necklace',spawnCount);
		thePlayer.inv.AddAnItem('Green gold ruby necklace',spawnCount);
		thePlayer.inv.AddAnItem('Green gold sapphire necklace',spawnCount);
		thePlayer.inv.AddAnItem('Green gold emerald necklace',spawnCount);
		thePlayer.inv.AddAnItem('Green gold diamond necklace',spawnCount);
		thePlayer.inv.AddAnItem('Touissant knife',spawnCount);
		thePlayer.inv.AddAnItem('Bottle caps',spawnCount);
		thePlayer.inv.AddAnItem('Fake teeth',spawnCount);
		thePlayer.inv.AddAnItem('Corkscrew',spawnCount);
		thePlayer.inv.AddAnItem('Gingerbread man',spawnCount);
		thePlayer.inv.AddAnItem('Toys rich',spawnCount);
		thePlayer.inv.AddAnItem('Teapot teacups',spawnCount);
		thePlayer.inv.AddAnItem('Skeletal ashes',spawnCount);
		thePlayer.inv.AddAnItem('Magic mirror shard',spawnCount);
		thePlayer.inv.AddAnItem('Magic dust',spawnCount);
		thePlayer.inv.AddAnItem('Fourleaf clover',spawnCount);
		thePlayer.inv.AddAnItem('Magic gold',spawnCount);

    }


    function AddHorseItemsForW3Player()
    {
        thePlayer.inv.AddAnItem('i_01_hd__bags_lvl2',spawnCount);
thePlayer.inv.AddAnItem('i_01_hd__bags_lvl3',spawnCount);
thePlayer.inv.AddAnItem('c_01_hd__champron_lvl3',spawnCount);
thePlayer.inv.AddAnItem('c_01_hd__champron_lvl2',spawnCount);
thePlayer.inv.AddAnItem('s_01_hd__saddle_lvl1',spawnCount);
thePlayer.inv.AddAnItem('s_01_hd__saddle_lvl2',spawnCount);
thePlayer.inv.AddAnItem('s_01_hd__saddle_lvl3',spawnCount);
thePlayer.inv.AddAnItem('s_01_hd__saddle_lvl4',spawnCount);
        thePlayer.inv.AddAnItem('Horse Bag 1',spawnCount);
        thePlayer.inv.AddAnItem('Horse Bag 2',spawnCount);
        thePlayer.inv.AddAnItem('Horse Bag 3',spawnCount);
        thePlayer.inv.AddAnItem('Horse Blinder 1',spawnCount);
        thePlayer.inv.AddAnItem('Horse Blinder 2',spawnCount);
        thePlayer.inv.AddAnItem('Horse Blinder 3',spawnCount);
        thePlayer.inv.AddAnItem('Horse Saddle 1',spawnCount);
        thePlayer.inv.AddAnItem('Horse Saddle 1v2',spawnCount);
        thePlayer.inv.AddAnItem('Horse Saddle 1v3',spawnCount);
        thePlayer.inv.AddAnItem('Horse Saddle 1v4',spawnCount);
        thePlayer.inv.AddAnItem('Horse Saddle 2',spawnCount);
        thePlayer.inv.AddAnItem('Horse Saddle 2v2',spawnCount);
        thePlayer.inv.AddAnItem('Horse Saddle 2v3',spawnCount);
        thePlayer.inv.AddAnItem('Horse Saddle 2v4',spawnCount);
        thePlayer.inv.AddAnItem('Horse Saddle 3',spawnCount);
        thePlayer.inv.AddAnItem('Horse Saddle 3v2',spawnCount);
        thePlayer.inv.AddAnItem('Horse Saddle 3v3',spawnCount);
        thePlayer.inv.AddAnItem('Horse Saddle 3v4',spawnCount);
        thePlayer.inv.AddAnItem('Horse Saddle 4',spawnCount);
        thePlayer.inv.AddAnItem('Toussaint saddle');
	thePlayer.inv.AddAnItem('Toussaint saddle 2');
	thePlayer.inv.AddAnItem('Toussaint saddle 3');
	thePlayer.inv.AddAnItem('Toussaint saddle 4');
	thePlayer.inv.AddAnItem('Toussaint saddle 5');
	thePlayer.inv.AddAnItem('Toussaint saddle 6');
	
	thePlayer.inv.AddAnItem('Tourney Geralt Saddle');
	thePlayer.inv.AddAnItem('Tourney Ravix Saddle');
	
	thePlayer.inv.AddAnItem('Toussaint horsebag');
	
	thePlayer.inv.AddAnItem('Toussaint horse blinders');
	thePlayer.inv.AddAnItem('Toussaint horse blinders 2');
	thePlayer.inv.AddAnItem('Toussaint horse blinders 3');
	thePlayer.inv.AddAnItem('Toussaint horse blinders 4');
	thePlayer.inv.AddAnItem('Toussaint horse blinders 5');
	thePlayer.inv.AddAnItem('Toussaint horse blinders 6');
	
	thePlayer.inv.AddAnItem('Monniers horse blinders');
	
	thePlayer.inv.AddAnItem('q701_cyclops_trophy');
	thePlayer.inv.AddAnItem('q702_wicht_trophy');
	thePlayer.inv.AddAnItem('q704_garkain_trophy');
	thePlayer.inv.AddAnItem('mq7002_spriggan_trophy');
	thePlayer.inv.AddAnItem('mq7009_griffin_trophy');
	thePlayer.inv.AddAnItem('mq7017_zmora_trophy');
	thePlayer.inv.AddAnItem('mq7010_dracolizard_trophy');
	thePlayer.inv.AddAnItem('mq7018_basilisk_trophy');
	thePlayer.inv.AddAnItem('mh701_sharley_matriarch_trophy');
        
    }
    function AddPantsForW3Player()
    {
        thePlayer.inv.AddAnItem('Guard Lvl1 Pants 3',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Pants 3',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl2 Pants 3',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Pants 3',spawnCount);
		thePlayer.inv.AddAnItem('Knight Geralt Pants 3',spawnCount);
		thePlayer.inv.AddAnItem('Knight Geralt A Pants 3',spawnCount);
		thePlayer.inv.AddAnItem('Toussaint Pants 3',spawnCount);
        	thePlayer.inv.AddAnItem('Guard Lvl1 Pants 1',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl1 Pants 2',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Pants 1',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Pants 2',spawnCount);
		
		thePlayer.inv.AddAnItem('Guard Lvl2 Pants 1',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl2 Pants 2',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Pants 1',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Pants 2',spawnCount);
		
		thePlayer.inv.AddAnItem('Knight Geralt Pants 1',spawnCount);
		thePlayer.inv.AddAnItem('Knight Geralt Pants 2',spawnCount);
		thePlayer.inv.AddAnItem('Knight Geralt A Pants 1',spawnCount);
		thePlayer.inv.AddAnItem('Knight Geralt A Pants 2',spawnCount);
		thePlayer.inv.AddAnItem('Toussaint Pants 2',spawnCount);
        thePlayer.inv.AddAnItem('Starting Pants',spawnCount);
        thePlayer.inv.AddAnItem('Wolf Pants 1',spawnCount);
        thePlayer.inv.AddAnItem('Wolf Pants 2',spawnCount);
        thePlayer.inv.AddAnItem('Lynx Pants 1',spawnCount);
        thePlayer.inv.AddAnItem('Lynx Pants 2',spawnCount);
        thePlayer.inv.AddAnItem('Gryphon Pants 1',spawnCount);
        thePlayer.inv.AddAnItem('Gryphon Pants 2',spawnCount);
        thePlayer.inv.AddAnItem('Bear Pants 1',spawnCount);
        thePlayer.inv.AddAnItem('Bear Pants 2',spawnCount);
        thePlayer.inv.AddAnItem('Pants 01',spawnCount);
        thePlayer.inv.AddAnItem('Pants 01 q2',spawnCount);
        thePlayer.inv.AddAnItem('Pants 02',spawnCount);
        thePlayer.inv.AddAnItem('Pants 03',spawnCount);
        thePlayer.inv.AddAnItem('Pants 04',spawnCount);
        thePlayer.inv.AddAnItem('Heavy pants 01',spawnCount);
        thePlayer.inv.AddAnItem('Heavy pants 02',spawnCount);
        thePlayer.inv.AddAnItem('Heavy pants 03',spawnCount);
        thePlayer.inv.AddAnItem('Heavy pants 04',spawnCount);
        thePlayer.inv.AddAnItem('Nilfgaardian Casual Pants',spawnCount);
        thePlayer.inv.AddAnItem('Skellige Casual Pants 01',spawnCount);
        thePlayer.inv.AddAnItem('Skellige Casual Pants 02',spawnCount);
        thePlayer.inv.AddAnItem('Bath Towel Pants 01',spawnCount);
        thePlayer.inv.AddAnItem('Ciri pants 01',spawnCount);
        thePlayer.inv.AddAnItem('Wild Hunt pants 01',spawnCount);
    }
    function AddArmorForW3Player()
    {
        thePlayer.inv.AddAnItem('Shiadhal armor',spawnCount);
thePlayer.inv.AddAnItem('Thyssen armor',spawnCount);
thePlayer.inv.AddAnItem('Oathbreaker armor',spawnCount);
thePlayer.inv.AddAnItem('Zireael armor',spawnCount);
thePlayer.inv.AddAnItem('Shadaal armor',spawnCount);
thePlayer.inv.AddAnItem('Relic Heavy 3 armor',spawnCount);
        	thePlayer.inv.AddAnItem('Guard Lvl2 Armor 3',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Armor 3',spawnCount);
		thePlayer.inv.AddAnItem('Knight Geralt Armor 3',spawnCount);
		thePlayer.inv.AddAnItem('Knight Geralt A Armor 3',spawnCount);
		thePlayer.inv.AddAnItem('Toussaint Armor 3',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl1 Armor 3',spawnCount);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Armor 3',spawnCount);
        thePlayer.inv.AddAnItem('Heavy armor 01',spawnCount);
        thePlayer.inv.AddAnItem('Heavy armor 02',spawnCount);
        thePlayer.inv.AddAnItem('Heavy armor 03',spawnCount);
        thePlayer.inv.AddAnItem('Heavy armor 04',spawnCount);
        thePlayer.inv.AddAnItem('Heavy armor 05',spawnCount);
        thePlayer.inv.AddAnItem('Light armor 01',spawnCount);
        thePlayer.inv.AddAnItem('Light armor 02',spawnCount);
        thePlayer.inv.AddAnItem('Light armor 03',spawnCount);
        thePlayer.inv.AddAnItem('Light armor 04',spawnCount);

        thePlayer.inv.AddAnItem('Light armor 06',spawnCount);
        thePlayer.inv.AddAnItem('Light armor 07',spawnCount);
        thePlayer.inv.AddAnItem('Light armor 08',spawnCount);
        thePlayer.inv.AddAnItem('Light armor 09',spawnCount);
        thePlayer.inv.AddAnItem('Medium armor 01',spawnCount);
        thePlayer.inv.AddAnItem('Medium armor 02',spawnCount);
        thePlayer.inv.AddAnItem('Medium armor 03',spawnCount);
        thePlayer.inv.AddAnItem('Medium armor 04',spawnCount);
        thePlayer.inv.AddAnItem('Medium armor 05',spawnCount);

        thePlayer.inv.AddAnItem('Medium armor 07',spawnCount);


        thePlayer.inv.AddAnItem('Medium armor 10',spawnCount);
        thePlayer.inv.AddAnItem('Medium armor 11',spawnCount);

        thePlayer.inv.AddAnItem('Nilfgaardian Casual Suit 01',spawnCount);
        thePlayer.inv.AddAnItem('Nilfgaardian Casual Suit 02',spawnCount);
        thePlayer.inv.AddAnItem('Nilfgaardian Casual Suit 03',spawnCount);
        thePlayer.inv.AddAnItem('Skellige Casual Suit 01',spawnCount);
        thePlayer.inv.AddAnItem('Skellige Casual Suit 02',spawnCount);
        thePlayer.inv.AddAnItem('Starting Armor',spawnCount);
        thePlayer.inv.AddAnItem('Bear Armor',spawnCount);
        thePlayer.inv.AddAnItem('Bear Armor 1',spawnCount);
        thePlayer.inv.AddAnItem('Bear Armor 2',spawnCount);
        thePlayer.inv.AddAnItem('Bear Armor 3',spawnCount);
        thePlayer.inv.AddAnItem('Gryphon Armor',spawnCount);
        thePlayer.inv.AddAnItem('Gryphon Armor 1',spawnCount);
        thePlayer.inv.AddAnItem('Gryphon Armor 2',spawnCount);
        thePlayer.inv.AddAnItem('Gryphon Armor 3',spawnCount);
        thePlayer.inv.AddAnItem('Lynx Armor',spawnCount);
        thePlayer.inv.AddAnItem('Lynx Armor 1',spawnCount);
        thePlayer.inv.AddAnItem('Lynx Armor 2',spawnCount);
        thePlayer.inv.AddAnItem('Lynx Armor 3',spawnCount);
        thePlayer.inv.AddAnItem('Wolf Armor',spawnCount);
        thePlayer.inv.AddAnItem('Wolf Armor 1',spawnCount);
        thePlayer.inv.AddAnItem('Wolf Armor 2',spawnCount);
        thePlayer.inv.AddAnItem('Wolf Armor 3',spawnCount);
        thePlayer.inv.AddAnItem('Geralt Shirt',spawnCount);
        thePlayer.inv.AddAnItem('Geralt Shirt No Knife',spawnCount);
        thePlayer.inv.AddAnItem('Nilfgaardian Casual Suit 01',spawnCount);
        thePlayer.inv.AddAnItem('Nilfgaardian Casual Suit 02',spawnCount);
        thePlayer.inv.AddAnItem('Nilfgaardian Casual Suit 03',spawnCount);
        thePlayer.inv.AddAnItem('Skellige Casual Suit 01',spawnCount);
        thePlayer.inv.AddAnItem('Skellige Casual Suit 02',spawnCount);
        thePlayer.inv.AddAnItem('sq108_heavy_armor',spawnCount);
        thePlayer.inv.AddAnItem('Witcher Lynx Jacket Upgrade schematic 4',spawnCount);
	thePlayer.inv.AddAnItem('Witcher Lynx Gloves Upgrade schematic 5',spawnCount);
	thePlayer.inv.AddAnItem('Witcher Lynx Boots Upgrade schematic 5',spawnCount);
	thePlayer.inv.AddAnItem('Witcher Lynx Pants Upgrade schematic 5',spawnCount);
	thePlayer.inv.AddAnItem('Witcher Gryphon Jacket Upgrade schematic 4',spawnCount);
	thePlayer.inv.AddAnItem('Witcher Gryphon Gloves Upgrade schematic 5',spawnCount);
	thePlayer.inv.AddAnItem('Witcher Gryphon Boots Upgrade schematic 5',spawnCount);
	thePlayer.inv.AddAnItem('Witcher Gryphon Pants Upgrade schematic 5',spawnCount);
	thePlayer.inv.AddAnItem('Witcher Bear Jacket Upgrade schematic 4',spawnCount);
	thePlayer.inv.AddAnItem('Witcher Bear Gloves Upgrade schematic 5',spawnCount);
	thePlayer.inv.AddAnItem('Witcher Bear Boots Upgrade schematic 5',spawnCount);
	thePlayer.inv.AddAnItem('Witcher Bear Pants Upgrade schematic 5',spawnCount);
	thePlayer.inv.AddAnItem('Witcher Wolf Jacket Upgrade schematic 4',spawnCount);
	thePlayer.inv.AddAnItem('Witcher Wolf Gloves Upgrade schematic 5',spawnCount);
	thePlayer.inv.AddAnItem('Witcher Wolf Boots Upgrade schematic 5',spawnCount);
	thePlayer.inv.AddAnItem('Witcher Wolf Pants Upgrade schematic 5',spawnCount);
	thePlayer.inv.AddAnItem('Witcher Red Wolf Jacket schematic 1',spawnCount);
	thePlayer.inv.AddAnItem('Witcher Red Wolf Jacket Upgrade schematic 2',spawnCount);
	thePlayer.inv.AddAnItem('Witcher Red Wolf Gloves schematic 1',spawnCount);
	thePlayer.inv.AddAnItem('Witcher Red Wolf Gloves Upgrade schematic 2',spawnCount);
	thePlayer.inv.AddAnItem('Witcher Red Wolf Boots schematic 1',spawnCount);
	thePlayer.inv.AddAnItem('Witcher Red Wolf Boots Upgrade schematic 2',spawnCount);
	thePlayer.inv.AddAnItem('Witcher Red Wolf Pants schematic 1',spawnCount);
	thePlayer.inv.AddAnItem('Witcher Red Wolf Pants Upgrade schematic 2',spawnCount);
	thePlayer.inv.AddAnItem('Guard Lvl1 Armor 3 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Guard Lvl1 Gloves 3 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Guard Lvl1 Boots 3 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Guard Lvl1 Pants 3 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Guard Lvl1 A Armor 3 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Guard Lvl1 A Gloves 3 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Guard Lvl1 A Boots 3 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Guard Lvl1 A Pants 3 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Guard Lvl2 Armor 3 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Guard Lvl2 Gloves 3 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Guard Lvl2 Boots 3 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Guard Lvl2 Pants 3 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Guard Lvl2 A Armor 3 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Guard Lvl2 A Gloves 3 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Guard Lvl2 A Boots 3 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Guard Lvl2 A Pants 3 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Knight Geralt Armor 3 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Knight Geralt Gloves 3 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Knight Geralt Boots 3 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Knight Geralt Pants 3 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Knight Geralt A Armor 3 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Knight Geralt A Gloves 3 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Knight Geralt A Boots 3 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Knight Geralt A Pants 3 schematic',spawnCount);
    }
    function AddCrossBowsForW3Player()
    {
        thePlayer.inv.AddAnItem('Crossbow 1',spawnCount);
        thePlayer.inv.AddAnItem('Crossbow q206',spawnCount);
        thePlayer.inv.AddAnItem('Crossbow 2',spawnCount);
        thePlayer.inv.AddAnItem('Crossbow 3',spawnCount);
        thePlayer.inv.AddAnItem('Crossbow 4',spawnCount);
        thePlayer.inv.AddAnItem('Crossbow 5',spawnCount);
        thePlayer.inv.AddAnItem('Crossbow 6',spawnCount);
        thePlayer.inv.AddAnItem('Crossbow 7',spawnCount);
        thePlayer.inv.AddAnItem('Lynx School Crossbow',spawnCount);
        thePlayer.inv.AddAnItem('Bear School Crossbow',spawnCount);
        thePlayer.inv.AddAnItem('Nilfgaardian crossbow',spawnCount);
    }
    function AddSilverSwordsForW3Player()
    {
        			thePlayer.inv.AddAnItem('Lynx School silver sword 4',spawnCount);
			thePlayer.inv.AddAnItem('Gryphon School silver sword 4',spawnCount);
			thePlayer.inv.AddAnItem('Bear School silver sword 4',spawnCount);
			thePlayer.inv.AddAnItem('Wolf School silver sword 4',spawnCount);
			thePlayer.inv.AddAnItem('Red Wolf School silver sword 1',spawnCount);
			thePlayer.inv.AddAnItem('Red Wolf School silver sword 2',spawnCount);
			thePlayer.inv.AddAnItem('Serpent Silver Sword 1',spawnCount);
			thePlayer.inv.AddAnItem('Serpent Silver Sword 2',spawnCount);
			thePlayer.inv.AddAnItem('Serpent Silver Sword 3',spawnCount);
			
        thePlayer.inv.AddAnItem('Witcher Silver Sword',spawnCount);
        thePlayer.inv.AddAnItem('Silver sword 1',spawnCount);
        thePlayer.inv.AddAnItem('Silver sword 2',spawnCount);
        thePlayer.inv.AddAnItem('Silver sword 3',spawnCount);
        thePlayer.inv.AddAnItem('Silver sword 4',spawnCount);
        thePlayer.inv.AddAnItem('Silver sword 5',spawnCount);
        thePlayer.inv.AddAnItem('Silver sword 6',spawnCount);
        thePlayer.inv.AddAnItem('Silver sword 7',spawnCount);
        thePlayer.inv.AddAnItem('Silver sword 8',spawnCount);
        thePlayer.inv.AddAnItem('Dwarven silver sword 1',spawnCount);
        thePlayer.inv.AddAnItem('Dwarven silver sword 2',spawnCount);
        thePlayer.inv.AddAnItem('Elven silver sword 1',spawnCount);
        thePlayer.inv.AddAnItem('Elven silver sword 2',spawnCount);
        thePlayer.inv.AddAnItem('Gnomish silver sword 1',spawnCount);
        thePlayer.inv.AddAnItem('Gnomish silver sword 2',spawnCount);
        thePlayer.inv.AddAnItem('Bear School silver sword',spawnCount);
        thePlayer.inv.AddAnItem('Bear School silver sword 1',spawnCount);
        thePlayer.inv.AddAnItem('Bear School silver sword 2',spawnCount);
        thePlayer.inv.AddAnItem('Bear School silver sword 3',spawnCount);
        thePlayer.inv.AddAnItem('Lynx School silver sword',spawnCount);
        thePlayer.inv.AddAnItem('Lynx School silver sword 1',spawnCount);
        thePlayer.inv.AddAnItem('Lynx School silver sword 2',spawnCount);
        thePlayer.inv.AddAnItem('Lynx School silver sword 3',spawnCount);
        thePlayer.inv.AddAnItem('Gryphon School silver sword',spawnCount);
        thePlayer.inv.AddAnItem('Gryphon School silver sword 1',spawnCount);
        thePlayer.inv.AddAnItem('Gryphon School silver sword 2',spawnCount);
        thePlayer.inv.AddAnItem('Gryphon School silver sword 3',spawnCount);
        thePlayer.inv.AddAnItem('Viper School silver sword',spawnCount);
        thePlayer.inv.AddAnItem('Wolf School silver sword',spawnCount);
        thePlayer.inv.AddAnItem('Wolf School silver sword 1',spawnCount);
        thePlayer.inv.AddAnItem('Wolf School silver sword 2',spawnCount);
        thePlayer.inv.AddAnItem('Wolf School silver sword 3',spawnCount);
        	thePlayer.inv.AddAnItem('Harpy_crafted',spawnCount);
	thePlayer.inv.AddAnItem('Negotiator_crafted',spawnCount);
	thePlayer.inv.AddAnItem('Weeper_crafted',spawnCount);
    	
	thePlayer.inv.AddAnItem('Lynx School silver sword Upgrade schematic 4',spawnCount);
	thePlayer.inv.AddAnItem('Gryphon School silver sword Upgrade schematic 4',spawnCount);
	thePlayer.inv.AddAnItem('Bear School silver sword Upgrade schematic 4',spawnCount);
	thePlayer.inv.AddAnItem('Wolf School silver sword Upgrade schematic 4',spawnCount);
	thePlayer.inv.AddAnItem('Red Wolf School silver sword schematic 1',spawnCount);
	thePlayer.inv.AddAnItem('Red Wolf School silver sword Upgrade schematic 2',spawnCount);
	thePlayer.inv.AddAnItem('Serpent Silver Sword schematic 1',spawnCount);
	thePlayer.inv.AddAnItem('Serpent Silver Sword schematic 2',spawnCount);
	thePlayer.inv.AddAnItem('Serpent Silver Sword schematic 3',spawnCount);

    }
    function AddWolfDlcForW3Player()
    {
        thePlayer.inv.AddAnItem('Wolf Armor',spawnCount);
        thePlayer.inv.AddAnItem('Wolf Armor 1',spawnCount);
        thePlayer.inv.AddAnItem('Wolf Armor 2',spawnCount);
        thePlayer.inv.AddAnItem('Wolf Armor 3',spawnCount);

        thePlayer.inv.AddAnItem('Wolf Gloves 1',spawnCount);
        thePlayer.inv.AddAnItem('Wolf Gloves 2',spawnCount);

        thePlayer.inv.AddAnItem('Wolf Pants 1',spawnCount);
        thePlayer.inv.AddAnItem('Wolf Pants 2',spawnCount);

        thePlayer.inv.AddAnItem('Wolf Boots 1',spawnCount);
        thePlayer.inv.AddAnItem('Wolf Boots 2',spawnCount);

        thePlayer.inv.AddAnItem('Wolf School steel sword',spawnCount);
        thePlayer.inv.AddAnItem('Wolf School steel sword 1',spawnCount);
        thePlayer.inv.AddAnItem('Wolf School steel sword 2',spawnCount);
        thePlayer.inv.AddAnItem('Wolf School steel sword 3',spawnCount);

        thePlayer.inv.AddAnItem('Wolf School silver sword',spawnCount);
        thePlayer.inv.AddAnItem('Wolf School silver sword 1',spawnCount);
        thePlayer.inv.AddAnItem('Wolf School silver sword 2',spawnCount);
        thePlayer.inv.AddAnItem('Wolf School silver sword 3',spawnCount);
        	thePlayer.inv.AddAnItem('Bear School steel sword 2',spawnCount);
            thePlayer.inv.AddAnItem('Arbitrator_crafted',spawnCount);
	thePlayer.inv.AddAnItem('Beannshie_crafted',spawnCount);
	thePlayer.inv.AddAnItem('Blackunicorn_crafted',spawnCount);
	thePlayer.inv.AddAnItem('Longclaw_crafted',spawnCount);

    }
    function GiveSteelSwordsForW3Player()
    {
                thePlayer.inv.AddAnItem('Lynx School steel sword Upgrade schematic 4',spawnCount);
            thePlayer.inv.AddAnItem('Gryphon School steel sword Upgrade schematic 4',spawnCount);
            thePlayer.inv.AddAnItem('Bear School steel sword Upgrade schematic 4',spawnCount);
            thePlayer.inv.AddAnItem('Wolf School steel sword Upgrade schematic 4',spawnCount);
            thePlayer.inv.AddAnItem('Red Wolf School steel sword schematic 1',spawnCount);
            thePlayer.inv.AddAnItem('Red Wolf School steel sword Upgrade schematic 2',spawnCount);
            thePlayer.inv.AddAnItem('Serpent Steel Sword schematic 1',spawnCount);
            thePlayer.inv.AddAnItem('Serpent Steel Sword schematic 2',spawnCount);
            thePlayer.inv.AddAnItem('Serpent Steel Sword schematic 3',spawnCount);
            thePlayer.inv.AddAnItem('Guard Lvl1 steel sword 3 schematic',spawnCount);
            thePlayer.inv.AddAnItem('Guard Lvl1 A steel sword 3 schematic',spawnCount);
            thePlayer.inv.AddAnItem('Guard Lvl2 steel sword 3 schematic',spawnCount);
            thePlayer.inv.AddAnItem('Guard Lvl2 A steel sword 3 schematic',spawnCount);
            thePlayer.inv.AddAnItem('Knights Geralt steel sword 3 schematic',spawnCount);
            thePlayer.inv.AddAnItem('Squire steel sword 3 schematic',spawnCount);
            thePlayer.inv.AddAnItem('Hanza steel sword 3 schematic',spawnCount);
            thePlayer.inv.AddAnItem('Toussaint steel sword 3 schematic',spawnCount);
                thePlayer.inv.AddAnItem('Lynx School steel sword 4',spawnCount);
			thePlayer.inv.AddAnItem('Gryphon School steel sword 4',spawnCount);
			thePlayer.inv.AddAnItem('Bear School steel sword 4',spawnCount);
			thePlayer.inv.AddAnItem('Wolf School steel sword 4',spawnCount);
			thePlayer.inv.AddAnItem('Red Wolf School steel sword 1',spawnCount);
			thePlayer.inv.AddAnItem('Red Wolf School steel sword 2',spawnCount);
			thePlayer.inv.AddAnItem('Serpent Steel Sword 1',spawnCount);
			thePlayer.inv.AddAnItem('Serpent Steel Sword 2',spawnCount);
			thePlayer.inv.AddAnItem('Serpent Steel Sword 3',spawnCount);
			thePlayer.inv.AddAnItem('Guard lvl1 steel sword 3',spawnCount);
			thePlayer.inv.AddAnItem('Guard lvl2 steel sword 3',spawnCount);
			thePlayer.inv.AddAnItem('Knights steel sword 3',spawnCount);
			thePlayer.inv.AddAnItem('Hanza steel sword 3',spawnCount);
			thePlayer.inv.AddAnItem('Toussaint steel sword 3',spawnCount);
			thePlayer.inv.AddAnItem('Guard Lvl1 steel sword 1',spawnCount);
			thePlayer.inv.AddAnItem('Guard Lvl1 steel sword 2',spawnCount);
			thePlayer.inv.AddAnItem('Guard Lvl2 steel sword 1',spawnCount);
			thePlayer.inv.AddAnItem('Guard Lvl2 steel sword 2',spawnCount);
			thePlayer.inv.AddAnItem('Knights steel sword 1',spawnCount);
			thePlayer.inv.AddAnItem('Knights steel sword 2',spawnCount);
			thePlayer.inv.AddAnItem('Squire steel sword 1',spawnCount);
			thePlayer.inv.AddAnItem('Squire steel sword 2',spawnCount);
			thePlayer.inv.AddAnItem('Unique steel sword',spawnCount);
			thePlayer.inv.AddAnItem('Unique silver sword',spawnCount);
			thePlayer.inv.AddAnItem('Gwent steel sword 1',spawnCount);
			thePlayer.inv.AddAnItem('sq701 Geralt of Rivia sword',spawnCount);
			thePlayer.inv.AddAnItem('sq701 Ravix of Fourhorn sword',spawnCount);
			thePlayer.inv.AddAnItem('mq7001 Toussaint steel sword',spawnCount);
			thePlayer.inv.AddAnItem('mq7007 Elven Sword',spawnCount);
			thePlayer.inv.AddAnItem('mq7011 Cianfanelli steel sword',spawnCount);
        thePlayer.inv.AddAnItem('Long Steel Sword',spawnCount);
        thePlayer.inv.AddAnItem('Viper School steel sword',spawnCount);
        thePlayer.inv.AddAnItem('Short Steel Sword',spawnCount);
        thePlayer.inv.AddAnItem('Hjalmar_Short_Steel_Sword',spawnCount);
        thePlayer.inv.AddAnItem('Short sword 1',spawnCount);
        thePlayer.inv.AddAnItem('Short sword 2',spawnCount);
        thePlayer.inv.AddAnItem('Dwarven sword 1',spawnCount);
        thePlayer.inv.AddAnItem('Dwarven sword 2',spawnCount);
        thePlayer.inv.AddAnItem('Gnomish sword 1',spawnCount);
        thePlayer.inv.AddAnItem('Gnomish sword 2',spawnCount);
        thePlayer.inv.AddAnItem('Inquisitor sword 1',spawnCount);
        thePlayer.inv.AddAnItem('Inquisitor sword 2',spawnCount);
        thePlayer.inv.AddAnItem('No Mans Land sword 1',spawnCount);
        thePlayer.inv.AddAnItem('No Mans Land sword 1 q2',spawnCount);
        thePlayer.inv.AddAnItem('No Mans Land sword 2',spawnCount);
        thePlayer.inv.AddAnItem('No Mans Land sword 3',spawnCount);
        thePlayer.inv.AddAnItem('No Mans Land sword 4',spawnCount);
        thePlayer.inv.AddAnItem('Rusty Nilfgaardian sword',spawnCount);
        thePlayer.inv.AddAnItem('Nilfgaardian sword 1',spawnCount);
        thePlayer.inv.AddAnItem('Nilfgaardian sword 2',spawnCount);
        thePlayer.inv.AddAnItem('Nilfgaardian sword 3',spawnCount);
        thePlayer.inv.AddAnItem('Nilfgaardian sword 4',spawnCount);
        thePlayer.inv.AddAnItem('Rusty Novigraadan sword',spawnCount);
        thePlayer.inv.AddAnItem('Novigraadan sword 1',spawnCount);
        thePlayer.inv.AddAnItem('Novigraadan sword 2',spawnCount);
        thePlayer.inv.AddAnItem('Novigraadan sword 3',spawnCount);
        thePlayer.inv.AddAnItem('Novigraadan sword 4',spawnCount);
        thePlayer.inv.AddAnItem('Scoiatael sword 1',spawnCount);
        thePlayer.inv.AddAnItem('Scoiatael sword 2',spawnCount);
        thePlayer.inv.AddAnItem('Scoiatael sword 3',spawnCount);
        thePlayer.inv.AddAnItem('Rusty Skellige sword',spawnCount);
        thePlayer.inv.AddAnItem('Skellige sword 1',spawnCount);
        thePlayer.inv.AddAnItem('Skellige sword 2',spawnCount);
        thePlayer.inv.AddAnItem('Skellige sword 3',spawnCount);
        thePlayer.inv.AddAnItem('Skellige sword 4',spawnCount);
        thePlayer.inv.AddAnItem('Wild Hunt sword 1',spawnCount);
        thePlayer.inv.AddAnItem('Wild Hunt sword 2',spawnCount);
        thePlayer.inv.AddAnItem('Wild Hunt sword 3',spawnCount);
        thePlayer.inv.AddAnItem('Wild Hunt sword 4',spawnCount);
        thePlayer.inv.AddAnItem('Bear School steel sword',spawnCount);
        thePlayer.inv.AddAnItem('Bear School steel sword 1',spawnCount);
        thePlayer.inv.AddAnItem('Bear School steel sword 2',spawnCount);
        thePlayer.inv.AddAnItem('Bear School steel sword 3',spawnCount);
        thePlayer.inv.AddAnItem('Gryphon School steel sword',spawnCount);
        thePlayer.inv.AddAnItem('Gryphon School steel sword 1',spawnCount);
        thePlayer.inv.AddAnItem('Gryphon School steel sword 2',spawnCount);
        thePlayer.inv.AddAnItem('Gryphon School steel sword 3',spawnCount);
        thePlayer.inv.AddAnItem('Lynx School steel sword',spawnCount);
        thePlayer.inv.AddAnItem('Lynx School steel sword 1',spawnCount);
        thePlayer.inv.AddAnItem('Lynx School steel sword 2',spawnCount);
        thePlayer.inv.AddAnItem('Lynx School steel sword 3',spawnCount);
        thePlayer.inv.AddAnItem('Short sword 1_crafted',spawnCount);
        thePlayer.inv.AddAnItem('Short sword 2_crafted',spawnCount);
        thePlayer.inv.AddAnItem('No Mans Land sword 1_crafted',spawnCount);
        thePlayer.inv.AddAnItem('No Mans Land sword 2_crafted',spawnCount);
        thePlayer.inv.AddAnItem('Skellige sword 1_crafted',spawnCount);
        thePlayer.inv.AddAnItem('Lynx School steel sword',spawnCount);
        thePlayer.inv.AddAnItem('Nilfgaardian sword 1_crafted',spawnCount);
        thePlayer.inv.AddAnItem('Novigraadan sword 1_crafted',spawnCount);
        thePlayer.inv.AddAnItem('No Mans Land sword 3_crafted',spawnCount);
        thePlayer.inv.AddAnItem('Skellige sword 2_crafted',spawnCount);
        thePlayer.inv.AddAnItem('Gryphon School steel sword',spawnCount);
        thePlayer.inv.AddAnItem('Viper School steel sword',spawnCount);
        thePlayer.inv.AddAnItem('No Mans Land sword 4_crafted',spawnCount);
        thePlayer.inv.AddAnItem('Scoiatael sword 2_crafted',spawnCount);
        thePlayer.inv.AddAnItem('Novigraadan sword 4_crafted',spawnCount);
        thePlayer.inv.AddAnItem('Nilfgaardian sword 4_crafted',spawnCount);
        thePlayer.inv.AddAnItem('Scoiatael sword 3_crafted',spawnCount);
        thePlayer.inv.AddAnItem('Inquisitor sword 1_crafted',spawnCount);
        thePlayer.inv.AddAnItem('Bear School steel sword',spawnCount);
        thePlayer.inv.AddAnItem('Wolf School steel sword',spawnCount);
        thePlayer.inv.AddAnItem('Inquisitor sword 2_crafted',spawnCount);
        thePlayer.inv.AddAnItem('Dwarven sword 1_crafted',spawnCount);
        thePlayer.inv.AddAnItem('Dwarven sword 2_crafted',spawnCount);
        thePlayer.inv.AddAnItem('Gnomish sword 1_crafted',spawnCount);
        thePlayer.inv.AddAnItem('Gnomish sword 2_crafted',spawnCount);
    }
    function GiveCraftingItemsForW3Player()
    {
        thePlayer.inv.AddAnItem('Hardened leather', spawnCount);
        thePlayer.inv.AddAnItem('Linen', spawnCount);
        thePlayer.inv.AddAnItem('Thread', spawnCount);
        thePlayer.inv.AddAnItem('Twine', spawnCount);
        thePlayer.inv.AddAnItem('Steel plate', spawnCount);
        thePlayer.inv.AddAnItem('Cotton', spawnCount);
        thePlayer.inv.AddAnItem('Oil', spawnCount);
        thePlayer.inv.AddAnItem('Infused shard', spawnCount);
        thePlayer.inv.AddAnItem('Alghoul bone marrow',spawnCount);
	thePlayer.inv.AddAnItem('Amethyst dust',spawnCount);
	thePlayer.inv.AddAnItem('Arachas eyes',spawnCount);
	thePlayer.inv.AddAnItem('Arachas venom',spawnCount);
	thePlayer.inv.AddAnItem('Basilisk hide',spawnCount);
	thePlayer.inv.AddAnItem('Basilisk venom',spawnCount);
	thePlayer.inv.AddAnItem('Bear pelt',spawnCount);
	thePlayer.inv.AddAnItem('Berserker pelt',spawnCount);
	thePlayer.inv.AddAnItem('Coal',spawnCount);
	thePlayer.inv.AddAnItem('Cockatrice egg',spawnCount);
	thePlayer.inv.AddAnItem('Cotton',spawnCount);
	thePlayer.inv.AddAnItem('Crystalized essence',spawnCount);
	thePlayer.inv.AddAnItem('Cyclops eye',spawnCount);
	thePlayer.inv.AddAnItem('Czart hide',spawnCount);
	thePlayer.inv.AddAnItem('Dark iron ingot',spawnCount);
	thePlayer.inv.AddAnItem('Dark iron ore',spawnCount);
	thePlayer.inv.AddAnItem('Deer hide',spawnCount);
	thePlayer.inv.AddAnItem('Diamond dust',spawnCount);
	thePlayer.inv.AddAnItem('Draconide leather',spawnCount);
	thePlayer.inv.AddAnItem('Dragon scales',spawnCount);
	thePlayer.inv.AddAnItem('Drowned dead tongue',spawnCount);
	thePlayer.inv.AddAnItem('Drowner brain',spawnCount);
	thePlayer.inv.AddAnItem('Dwimeryte ingot',spawnCount);
	thePlayer.inv.AddAnItem('Dwimeryte ore',spawnCount);
	thePlayer.inv.AddAnItem('Elemental essence',spawnCount);
	thePlayer.inv.AddAnItem('Elemental rune',spawnCount);
	thePlayer.inv.AddAnItem('Emerald dust',spawnCount);
	thePlayer.inv.AddAnItem('Endriag chitin plates',spawnCount);
	thePlayer.inv.AddAnItem('Endriag embryo',spawnCount);
	thePlayer.inv.AddAnItem('Fiend eye',spawnCount);
	thePlayer.inv.AddAnItem('Forgotten soul',spawnCount);
	thePlayer.inv.AddAnItem('Forktail hide',spawnCount);
	thePlayer.inv.AddAnItem('Gargoyle Dust',spawnCount);
	thePlayer.inv.AddAnItem('Gargoyle Heart',spawnCount);
	thePlayer.inv.AddAnItem('Ghoul blood',spawnCount);
	thePlayer.inv.AddAnItem('Glowing ore',spawnCount);
	thePlayer.inv.AddAnItem('Goat hide',spawnCount);
	thePlayer.inv.AddAnItem('Golem heart',spawnCount);
	thePlayer.inv.AddAnItem('Gryphon egg',spawnCount);
	thePlayer.inv.AddAnItem('Gryphon feathers',spawnCount);
	thePlayer.inv.AddAnItem('Hag teeth',spawnCount);
	thePlayer.inv.AddAnItem('Hardened leather',spawnCount);
	thePlayer.inv.AddAnItem('Hardened timber',spawnCount);
	thePlayer.inv.AddAnItem('Harpy feathers',spawnCount);
	thePlayer.inv.AddAnItem('Horse hide',spawnCount);
	thePlayer.inv.AddAnItem('Iron ore',spawnCount);
	thePlayer.inv.AddAnItem('Lamia lock of hair',spawnCount);
	thePlayer.inv.AddAnItem('Leather straps',spawnCount);
	thePlayer.inv.AddAnItem('Leather',spawnCount);
	thePlayer.inv.AddAnItem('Leshy resin',spawnCount);
	thePlayer.inv.AddAnItem('Linen',spawnCount);
	thePlayer.inv.AddAnItem('Meteorite ingot',spawnCount);
	thePlayer.inv.AddAnItem('Meteorite ore',spawnCount);
	thePlayer.inv.AddAnItem('Necrophage skin',spawnCount);
	thePlayer.inv.AddAnItem('Nekker blood',spawnCount);
	thePlayer.inv.AddAnItem('Nekker heart',spawnCount);
	thePlayer.inv.AddAnItem('Nightwraith dark essence',spawnCount);
	thePlayer.inv.AddAnItem('Noonwraith light essence',spawnCount);
	thePlayer.inv.AddAnItem('Oil',spawnCount);
	thePlayer.inv.AddAnItem('Phosphorescent crystal',spawnCount);
	thePlayer.inv.AddAnItem('Pig hide',spawnCount);
	thePlayer.inv.AddAnItem('Pure silver',spawnCount);
	thePlayer.inv.AddAnItem('Rabbit pelt',spawnCount);
	thePlayer.inv.AddAnItem('Rotfiend blood',spawnCount);
	thePlayer.inv.AddAnItem('Sapphire dust',spawnCount);
	thePlayer.inv.AddAnItem('Shattered core',spawnCount);
	thePlayer.inv.AddAnItem('Silk',spawnCount);
	thePlayer.inv.AddAnItem('Silver ingot',spawnCount);
	thePlayer.inv.AddAnItem('Silver mineral',spawnCount);
	thePlayer.inv.AddAnItem('Silver ore',spawnCount);
	thePlayer.inv.AddAnItem('Siren vocal cords',spawnCount);
	thePlayer.inv.AddAnItem('Specter dust',spawnCount);
	thePlayer.inv.AddAnItem('Steel ingot',spawnCount);
	thePlayer.inv.AddAnItem('Steel plate',spawnCount);
	thePlayer.inv.AddAnItem('String',spawnCount);
	thePlayer.inv.AddAnItem('Thread',spawnCount);
	thePlayer.inv.AddAnItem('Timber',spawnCount);
	thePlayer.inv.AddAnItem('Troll skin',spawnCount);
	thePlayer.inv.AddAnItem('Twine',spawnCount);
	thePlayer.inv.AddAnItem('Vampire fang',spawnCount);
	thePlayer.inv.AddAnItem('Vampire saliva',spawnCount);
	thePlayer.inv.AddAnItem('Venom extract',spawnCount);
	thePlayer.inv.AddAnItem('Water essence',spawnCount);
	thePlayer.inv.AddAnItem('Werewolf pelt',spawnCount);
	thePlayer.inv.AddAnItem('Werewolf saliva',spawnCount);
	thePlayer.inv.AddAnItem('White bear pelt',spawnCount);
	thePlayer.inv.AddAnItem('White wolf pelt',spawnCount);
	thePlayer.inv.AddAnItem('Wolf liver',spawnCount);
	thePlayer.inv.AddAnItem('Wolf pelt',spawnCount);
	thePlayer.inv.AddAnItem('Wyvern egg',spawnCount);
	thePlayer.inv.AddAnItem('Wyvern plate',spawnCount);
        	thePlayer.inv.AddAnItem('Zoria rune',spawnCount);
            	thePlayer.inv.AddAnItem('Allspice root',spawnCount);
	thePlayer.inv.AddAnItem('Arenaria',spawnCount);
	thePlayer.inv.AddAnItem('Balisse fruit',spawnCount);
	thePlayer.inv.AddAnItem('Beggartick blossoms',spawnCount);
	thePlayer.inv.AddAnItem('Berbercane fruit',spawnCount);
	thePlayer.inv.AddAnItem('Bison Grass',spawnCount);
	thePlayer.inv.AddAnItem('Bloodmoss',spawnCount);
	thePlayer.inv.AddAnItem('Blowbill',spawnCount);
	thePlayer.inv.AddAnItem('Bryonia',spawnCount);
	thePlayer.inv.AddAnItem('Buckthorn',spawnCount);
	thePlayer.inv.AddAnItem('Celandine',spawnCount);
	thePlayer.inv.AddAnItem('Cortinarius',spawnCount);
	thePlayer.inv.AddAnItem('Crows eye',spawnCount);
	thePlayer.inv.AddAnItem('Ergot seeds',spawnCount);
	thePlayer.inv.AddAnItem('Fools parsley leaves',spawnCount);
	thePlayer.inv.AddAnItem('Ginatia petals',spawnCount);
	thePlayer.inv.AddAnItem('Green mold',spawnCount);
	thePlayer.inv.AddAnItem('Han',spawnCount);
	thePlayer.inv.AddAnItem('Hellebore petals',spawnCount);
	thePlayer.inv.AddAnItem('Honeysuckle',spawnCount);
	thePlayer.inv.AddAnItem('Hop umbels',spawnCount);
	thePlayer.inv.AddAnItem('Hornwort',spawnCount);
	thePlayer.inv.AddAnItem('Longrube',spawnCount);
	thePlayer.inv.AddAnItem('Mandrake root',spawnCount);
	thePlayer.inv.AddAnItem('Mistletoe',spawnCount);
	thePlayer.inv.AddAnItem('Moleyarrow',spawnCount);
	thePlayer.inv.AddAnItem('Nostrix',spawnCount);
	thePlayer.inv.AddAnItem('Pigskin puffball',spawnCount);
	thePlayer.inv.AddAnItem('Pringrape',spawnCount);
	thePlayer.inv.AddAnItem('Ranogrin',spawnCount);
	thePlayer.inv.AddAnItem('Ribleaf',spawnCount);
	thePlayer.inv.AddAnItem('Sewant mushrooms',spawnCount);
	thePlayer.inv.AddAnItem('Verbena',spawnCount);
	thePlayer.inv.AddAnItem('White myrtle',spawnCount);
	thePlayer.inv.AddAnItem('Wolfsbane',spawnCount);
    	thePlayer.inv.AddAnItem('Melitele figurine',spawnCount);
	thePlayer.inv.AddAnItem('Iron ore',spawnCount);
	thePlayer.inv.AddAnItem('Bandalur butter knife',spawnCount);
	thePlayer.inv.AddAnItem('Goblet',spawnCount);
	thePlayer.inv.AddAnItem('Nails',spawnCount);
	thePlayer.inv.AddAnItem('Old rusty breadknife',spawnCount);
	thePlayer.inv.AddAnItem('Salt pepper shaker',spawnCount);
	thePlayer.inv.AddAnItem('Razor',spawnCount);
	thePlayer.inv.AddAnItem('Wire',spawnCount);
	thePlayer.inv.AddAnItem('Wire rope',spawnCount);
	thePlayer.inv.AddAnItem('Iron ingot',spawnCount);
	thePlayer.inv.AddAnItem('Candelabra',spawnCount);
	thePlayer.inv.AddAnItem('Lute',spawnCount);
	thePlayer.inv.AddAnItem('Steel ingot',spawnCount);
	thePlayer.inv.AddAnItem('Axe head',spawnCount);
	thePlayer.inv.AddAnItem('Pickaxe head',spawnCount);
	thePlayer.inv.AddAnItem('Rusty hammer head',spawnCount);
	thePlayer.inv.AddAnItem('Blunt axe',spawnCount);
	thePlayer.inv.AddAnItem('Blunt pickaxe',spawnCount);
	thePlayer.inv.AddAnItem('Chain',spawnCount);
	thePlayer.inv.AddAnItem('Steel plate',spawnCount);
	thePlayer.inv.AddAnItem('Dark iron ore',spawnCount);
	thePlayer.inv.AddAnItem('Dark iron ingot',spawnCount);
	thePlayer.inv.AddAnItem('Dark steel ingot',spawnCount);
	thePlayer.inv.AddAnItem('Dark steel plate',spawnCount);
	thePlayer.inv.AddAnItem('Meteorite ore',spawnCount);
	thePlayer.inv.AddAnItem('Meteorite ingot',spawnCount);
	
	thePlayer.inv.AddAnItem('Meteorite silver ingot',spawnCount);
	thePlayer.inv.AddAnItem('Meteorite silver plate',spawnCount);
	thePlayer.inv.AddAnItem('Glowing ore',spawnCount);
	thePlayer.inv.AddAnItem('Dwimeritium shackles',spawnCount);
	thePlayer.inv.AddAnItem('Glowing ingot',spawnCount);
	thePlayer.inv.AddAnItem('Dwimeritium chains',spawnCount);
	thePlayer.inv.AddAnItem('Dwimeryte ore',spawnCount);
	thePlayer.inv.AddAnItem('Dwimeryte ingot',spawnCount);
	thePlayer.inv.AddAnItem('Dwimeryte plate',spawnCount);
        GetWitcherPlayer().AddCraftingSchematic('Heavy Boots 2 schematic');
        GetWitcherPlayer().AddCraftingSchematic('Heavy Boots 1 schematic');
        GetWitcherPlayer().AddCraftingSchematic('Pants 1 schematic');
        GetWitcherPlayer().AddCraftingSchematic('Heavy Pants 2 schematic');
        
        thePlayer.AddMoney(50000);
    }
    function GiveBoltsForW3Player()
    {
        
        thePlayer.inv.AddAnItem('Tracking Bolt',spawnCount);
        thePlayer.inv.AddAnItem('Bait Bolt',spawnCount);
        thePlayer.inv.AddAnItem('Blunt Bolt',spawnCount);
        thePlayer.inv.AddAnItem('Broadhead Bolt',spawnCount);
        thePlayer.inv.AddAnItem('Target Point Bolt',spawnCount);
        thePlayer.inv.AddAnItem('Split Bolt',spawnCount);
        thePlayer.inv.AddAnItem('Explosive Bolt',spawnCount);
        
        thePlayer.inv.AddAnItem('Blunt Bolt Legendary',spawnCount);
        thePlayer.inv.AddAnItem('Broadhead Bolt Legendary',spawnCount);
        thePlayer.inv.AddAnItem('Target Point Bolt Legendary',spawnCount);
        thePlayer.inv.AddAnItem('Split Bolt Legendary',spawnCount);
        thePlayer.inv.AddAnItem('Explosive Bolt Legendary',spawnCount);
    }
    function GiveBombsForW3Player(optional notInfinite : bool)
    {
        var arr : array<SItemUniqueId>;

        if(!notInfinite)
        {
            FactsAdd("debug_fact_inf_bombs");
        }
        
        arr = thePlayer.inv.AddAnItem('White Frost 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Silver Dust Bomb 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Devils Puffball 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Samum 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Dancing Star 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));

        arr = thePlayer.inv.AddAnItem('Samum 1');
        thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
        arr = thePlayer.inv.AddAnItem('Samum 2');
        thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
        arr = thePlayer.inv.AddAnItem('Samum 3');
        thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
        arr = thePlayer.inv.AddAnItem('Dwimeritium Bomb 1');
        thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
        arr = thePlayer.inv.AddAnItem('Dwimeritium Bomb 2');
        thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
        arr = thePlayer.inv.AddAnItem('Dwimeritium Bomb 3');
        thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
        arr = thePlayer.inv.AddAnItem('Dancing Star 1');
        thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
        arr = thePlayer.inv.AddAnItem('Dancing Star 2');
        thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
        arr = thePlayer.inv.AddAnItem('Dancing Star 3');
        thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
        arr = thePlayer.inv.AddAnItem('Devils Puffball 1');
        thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
        arr = thePlayer.inv.AddAnItem('Devils Puffball 2');
        thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
        arr = thePlayer.inv.AddAnItem('Devils Puffball 3');
        thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
        arr = thePlayer.inv.AddAnItem('Dragons Dream 1');
        thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
        arr = thePlayer.inv.AddAnItem('Dragons Dream 2');
        thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
        arr = thePlayer.inv.AddAnItem('Dragons Dream 3');
        thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
        arr = thePlayer.inv.AddAnItem('Silver Dust Bomb 1');
        thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
        arr = thePlayer.inv.AddAnItem('Silver Dust Bomb 2');
        thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
        arr = thePlayer.inv.AddAnItem('Silver Dust Bomb 3');
        thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
        arr = thePlayer.inv.AddAnItem('White Frost 1');
        thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
        arr = thePlayer.inv.AddAnItem('White Frost 2');
        thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
        arr = thePlayer.inv.AddAnItem('White Frost 3');
        thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
            
        arr = thePlayer.inv.AddAnItem('Grapeshot 2');
        thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
        arr = thePlayer.inv.AddAnItem('Grapeshot 3');
        thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
        arr = thePlayer.inv.AddAnItem('Grapeshot 1');
        thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
        
        thePlayer.EquipItem(arr[0], EES_Petard1);
        GetWitcherPlayer().SelectQuickslotItem( EES_Petard1 );
    }
    
    function GiveRandom2ForW3Player()
    {
           	var manager : CWitcherJournalManager;
        		thePlayer.inv.AddAnItem('Winter cherry',spawnCount);
		thePlayer.inv.AddAnItem('Holy basil',spawnCount);
		thePlayer.inv.AddAnItem('Blue lotus',spawnCount);
        
	thePlayer.inv.AddAnItem('Ashes',spawnCount);
	
	thePlayer.inv.AddAnItem('Axe head',spawnCount);
	thePlayer.inv.AddAnItem('Bag of grain',spawnCount);
	thePlayer.inv.AddAnItem('Bandalur butter knife',spawnCount);
	thePlayer.inv.AddAnItem('Blunt axe',spawnCount);
	thePlayer.inv.AddAnItem('Blunt pickaxe',spawnCount);
	thePlayer.inv.AddAnItem('Broken paddle',spawnCount);
	thePlayer.inv.AddAnItem('Broken rakes',spawnCount);
	thePlayer.inv.AddAnItem('Candle',spawnCount);
	thePlayer.inv.AddAnItem('Chain',spawnCount);
	thePlayer.inv.AddAnItem('Child doll',spawnCount);
	thePlayer.inv.AddAnItem('Drum',spawnCount);
	thePlayer.inv.AddAnItem('Empty bottle',spawnCount);
	thePlayer.inv.AddAnItem('Empty vial',spawnCount);
	thePlayer.inv.AddAnItem('Fishing net',spawnCount);
	thePlayer.inv.AddAnItem('Fishing rod',spawnCount);
	thePlayer.inv.AddAnItem('Fisstech',spawnCount);
	thePlayer.inv.AddAnItem('Flowers',spawnCount);
	thePlayer.inv.AddAnItem('Flute',spawnCount);
	thePlayer.inv.AddAnItem('Glamarye',spawnCount);
	thePlayer.inv.AddAnItem('Goblet',spawnCount);
	thePlayer.inv.AddAnItem('Golden mug',spawnCount);
	thePlayer.inv.AddAnItem('Golden platter',spawnCount);
	thePlayer.inv.AddAnItem('Inkwell',spawnCount);
	thePlayer.inv.AddAnItem('Jumping rope',spawnCount);
	thePlayer.inv.AddAnItem('Ladle',spawnCount);
	thePlayer.inv.AddAnItem('Lead',spawnCount);
	thePlayer.inv.AddAnItem('Lute',spawnCount);
	thePlayer.inv.AddAnItem('Melitele figurine',spawnCount);
	thePlayer.inv.AddAnItem('Mug',spawnCount);
	thePlayer.inv.AddAnItem('Nails',spawnCount);
	thePlayer.inv.AddAnItem('Nilfgaardian special forces insignia',spawnCount);
	thePlayer.inv.AddAnItem('Old bear skin',spawnCount);
	thePlayer.inv.AddAnItem('Old goat skin',spawnCount);
	thePlayer.inv.AddAnItem('Old rusty breadknife',spawnCount);
	thePlayer.inv.AddAnItem('Old sheep skin',spawnCount);
	thePlayer.inv.AddAnItem('Ornate silver shield replica',spawnCount);
	thePlayer.inv.AddAnItem('Ornate silver sword replica',spawnCount);
	thePlayer.inv.AddAnItem('Parchment',spawnCount);
    thePlayer.inv.AddAnItem('Patchwork vest',spawnCount);
	thePlayer.inv.AddAnItem('Perfume',spawnCount);
	thePlayer.inv.AddAnItem('Philosophers stone',spawnCount);
	thePlayer.inv.AddAnItem('Pickaxe head',spawnCount);
	thePlayer.inv.AddAnItem('Razor',spawnCount);
	thePlayer.inv.AddAnItem('Rope',spawnCount);
	thePlayer.inv.AddAnItem('Rusty hammer head',spawnCount);
	thePlayer.inv.AddAnItem('Seashell',spawnCount);
	thePlayer.inv.AddAnItem('Scoiatael trophies',spawnCount);
	thePlayer.inv.AddAnItem('Shell',spawnCount);
	thePlayer.inv.AddAnItem('Silver mug',spawnCount);
	thePlayer.inv.AddAnItem('Silver pantaloons',spawnCount);
	thePlayer.inv.AddAnItem('Silver plate',spawnCount);
	thePlayer.inv.AddAnItem('Silver teapot',spawnCount);
	thePlayer.inv.AddAnItem('Silverware',spawnCount);
	thePlayer.inv.AddAnItem('Skull',spawnCount);
	thePlayer.inv.AddAnItem('Smoking pipe',spawnCount);
	thePlayer.inv.AddAnItem('Temerian special forces insignia',spawnCount);
	thePlayer.inv.AddAnItem('Valuable fossil',spawnCount);
	
	thePlayer.inv.AddAnItem('Vial',spawnCount);
	thePlayer.inv.AddAnItem('Voodoo doll',spawnCount);
	thePlayer.inv.AddAnItem('Wire',spawnCount);
	thePlayer.inv.AddAnItem('Wire rope',spawnCount);
	thePlayer.inv.AddAnItem('Wooden rung rope ladder',spawnCount);
	thePlayer.inv.AddAnItem('Worn leather pelt',spawnCount);
	thePlayer.inv.AddAnItem('lw_001_monstrous_remains',spawnCount);
	thePlayer.inv.AddAnItem('q305_painting_of_hemmelfart',spawnCount);
	thePlayer.inv.AddAnItem('mq3016_bards_belongings',spawnCount);
	thePlayer.inv.AddAnItem('sq202_tableware',spawnCount);
   
	
      
        thePlayer.inv.AddAnItem('Torch',spawnCount);
        thePlayer.inv.AddAnItem('q103_bell',spawnCount);
        thePlayer.inv.AddAnItem('Peacock feather',spawnCount);
		thePlayer.inv.AddAnItem('Dull meteorite axe',spawnCount);
		thePlayer.inv.AddAnItem('Broken meteorite pickaxe',spawnCount);
		thePlayer.inv.AddAnItem('Hotel silver breadknife',spawnCount);
		thePlayer.inv.AddAnItem('Hotel silver goblet',spawnCount);
		thePlayer.inv.AddAnItem('Hotel silver teapot',spawnCount);
		thePlayer.inv.AddAnItem('Hotel silver fruitbowl',spawnCount);
		thePlayer.inv.AddAnItem('Hotel silver serving tray',spawnCount);
		thePlayer.inv.AddAnItem('Hotel silver wine bottle',spawnCount);
		thePlayer.inv.AddAnItem('Hotel silver cup',spawnCount);
		thePlayer.inv.AddAnItem('Copper salt pepper shaker',spawnCount);
		thePlayer.inv.AddAnItem('Copper mug',spawnCount);
		thePlayer.inv.AddAnItem('Copper platter',spawnCount);
		thePlayer.inv.AddAnItem('Copper casket',spawnCount);
		thePlayer.inv.AddAnItem('Copper candelabra',spawnCount);
		thePlayer.inv.AddAnItem('Cupronickel axe head',spawnCount);
		thePlayer.inv.AddAnItem('Cupronickel pickaxe head',spawnCount);
		thePlayer.inv.AddAnItem('Copper chain',spawnCount);
		thePlayer.inv.AddAnItem('Green gold ruby ring',spawnCount);
		thePlayer.inv.AddAnItem('Green gold sapphire ring',spawnCount);
		thePlayer.inv.AddAnItem('Green gold emerald ring',spawnCount);
		thePlayer.inv.AddAnItem('Green gold diamond ring',spawnCount);
		thePlayer.inv.AddAnItem('Green gold amber necklace',spawnCount);
		thePlayer.inv.AddAnItem('Green gold ruby necklace',spawnCount);
		thePlayer.inv.AddAnItem('Green gold sapphire necklace',spawnCount);
		thePlayer.inv.AddAnItem('Green gold emerald necklace',spawnCount);
		thePlayer.inv.AddAnItem('Green gold diamond necklace',spawnCount);
		thePlayer.inv.AddAnItem('Touissant knife',spawnCount);
		thePlayer.inv.AddAnItem('Bottle caps',spawnCount);
		thePlayer.inv.AddAnItem('Fake teeth',spawnCount);
		thePlayer.inv.AddAnItem('Corkscrew',spawnCount);
		thePlayer.inv.AddAnItem('Gingerbread man',spawnCount);
		thePlayer.inv.AddAnItem('Toys rich',spawnCount);
		thePlayer.inv.AddAnItem('Teapot teacups',spawnCount);
		thePlayer.inv.AddAnItem('Skeletal ashes',spawnCount);
		thePlayer.inv.AddAnItem('Magic mirror shard',spawnCount);
		thePlayer.inv.AddAnItem('Magic dust',spawnCount);
		thePlayer.inv.AddAnItem('Fourleaf clover',spawnCount);
		thePlayer.inv.AddAnItem('Magic gold',spawnCount);
     thePlayer.inv.AddAnItem('th1003_map_lynx_upgrade1a',spawnCount);
	thePlayer.inv.AddAnItem('th1003_map_lynx_upgrade1b',spawnCount);
	thePlayer.inv.AddAnItem('th1003_map_lynx_upgrade2',spawnCount);
	thePlayer.inv.AddAnItem('th1003_map_lynx_upgrade3',spawnCount);
	thePlayer.inv.AddAnItem('th1005_map_gryphon_upgrade1a',spawnCount);
	thePlayer.inv.AddAnItem('th1005_map_gryphon_upgrade1b',spawnCount);
	thePlayer.inv.AddAnItem('th1005_map_gryphon_upgrade2',spawnCount);
	thePlayer.inv.AddAnItem('th1005_map_gryphon_upgrade3',spawnCount);
	thePlayer.inv.AddAnItem('th1007_map_bear_upgrade1a',spawnCount);
	thePlayer.inv.AddAnItem('th1007_map_bear_upgrade1b',spawnCount);
	thePlayer.inv.AddAnItem('th1007_map_bear_upgrade2',spawnCount);
	thePlayer.inv.AddAnItem('th1007_map_bear_upgrade3',spawnCount);
	
	manager = theGame.GetJournalManager();
	
	activateJournalCharacterEntryWithAlias("CharactersAnnaHenrietta", manager);
	activateJournalCharacterEntryWithAlias("CharactersDamien", manager);
	activateJournalCharacterEntryWithAlias("CharactersDettlaff", manager);
	activateJournalCharacterEntryWithAlias("CharactersGuillaume", manager);
	activateJournalCharacterEntryWithAlias("CharactersMilton", manager);
	activateJournalCharacterEntryWithAlias("CharactersOriana", manager);
	activateJournalCharacterEntryWithAlias("CharactersRegis", manager);
	activateJournalCharacterEntryWithAlias("CharactersPalmerin", manager);
	activateJournalCharacterEntryWithAlias("CharactersSyanna", manager);
	activateJournalCharacterEntryWithAlias("CharactersUkryty", manager);
	activateJournalCharacterEntryWithAlias("CharactersVivienne", manager);
	activateJournalCharacterEntryWithAlias("CharactersHermit", manager);
	activateJournalCharacterEntryWithAlias("CharactersLadyOfTheLake", manager);
	activateJournalCharacterEntryWithAlias("CharactersBarnabe", manager);
	activateJournalCharacterEntryWithAlias("CharactersBootblack", manager);
	activateJournalCharacterEntryWithAlias("CharactersRoach", manager);
    }

    function GiveMutagensForW3Player()
    {
        thePlayer.inv.AddAnItem('Dwarven spirit',spawnCount);
        thePlayer.inv.AddAnItem('Katakan mutagen',spawnCount);
        thePlayer.inv.AddAnItem('Verbena',spawnCount);
        thePlayer.inv.AddAnItem('Arenaria',spawnCount);
        thePlayer.inv.AddAnItem('Balisse fruit',spawnCount);
        thePlayer.inv.AddAnItem('Longrube',spawnCount);
        thePlayer.inv.AddAnItem('Arachas mutagen',spawnCount);
        thePlayer.inv.AddAnItem('White myrtle',spawnCount);
        thePlayer.inv.AddAnItem('Han',spawnCount);
        thePlayer.inv.AddAnItem('Nostrix',spawnCount);
        thePlayer.inv.AddAnItem('Cockatrice mutagen',spawnCount);
        thePlayer.inv.AddAnItem('Crows eye',spawnCount);
        thePlayer.inv.AddAnItem('Pringrape',spawnCount);
        thePlayer.inv.AddAnItem('Cortinarius',spawnCount);
        thePlayer.inv.AddAnItem('Volcanic Gryphon mutagen',spawnCount);
        thePlayer.inv.AddAnItem('Ribleaf',spawnCount);
        thePlayer.inv.AddAnItem('Blowbill',spawnCount);
        thePlayer.inv.AddAnItem('Ergot seeds',spawnCount);
        thePlayer.inv.AddAnItem('Celandine',spawnCount);
        thePlayer.inv.AddAnItem('Water Hag mutagen',spawnCount);
        thePlayer.inv.AddAnItem('Berbercane fruit',spawnCount);
        thePlayer.inv.AddAnItem('Bloodmoss',spawnCount);
        thePlayer.inv.AddAnItem('Green mold',spawnCount);
        
        GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 1');
        GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 2');
        GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 3');
        GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 4');
        GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 5');
    }
    function AddCraftingSchematicForW3Player()
    {
        	GetWitcherPlayer().AddCraftingSchematic('Short sword 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Short sword 2 schematic');
            GetWitcherPlayer().AddCraftingSchematic('No Mans Land sword 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('No Mans Land sword 2 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Skellige sword 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Lynx School steel sword schematic');
            GetWitcherPlayer().AddCraftingSchematic('Bear School Crossbow schematic');
            GetWitcherPlayer().AddCraftingSchematic('Lynx School Crossbow schematicfting_');
            GetWitcherPlayer().AddCraftingSchematic('Nilfgaardian sword 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Novigraadan sword 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('No Mans Land sword 3 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Light Armor 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Skellige sword 2 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Gryphon School steel sword schematic');
            GetWitcherPlayer().AddCraftingSchematic('Viper Steel sword schematic');
            GetWitcherPlayer().AddCraftingSchematic('No Mans Land sword 4 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Scoiatael sword 2 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Novigraadan sword 4 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Nilfgaardian sword 4 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Scoiatael sword 3 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Inquisitor sword 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Bear School steel sword schematic');
            GetWitcherPlayer().AddCraftingSchematic('Wolf School steel sword schematic');
            GetWitcherPlayer().AddCraftingSchematic('Inquisitor sword 2 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Silver sword 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Silver sword 2 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Viper Silver sword schematic');
            GetWitcherPlayer().AddCraftingSchematic('Lynx School silver sword schematic');
            
            GetWitcherPlayer().AddCraftingSchematic('Boots 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Dwarven sword 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Boots 2 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Dwarven sword 2 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Boots 3 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Gnomish sword 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Boots 4 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Gnomish sword 2 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Heavy Boots 1 schematic');
            
            GetWitcherPlayer().AddCraftingSchematic('Pants 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Silver sword 3 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Pants 2 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Gryphon School silver sword schematic');
            GetWitcherPlayer().AddCraftingSchematic('Pants 3 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Silver sword 4 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Pants 4 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Silver sword 6 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Heavy Pants 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Silver sword 7 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Heavy Pants 2 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Elven silver sword 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Heavy Pants 3 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Bear School silver sword schematic');
            GetWitcherPlayer().AddCraftingSchematic('Heavy Pants 4 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Elven silver sword 2 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Wolf School silver sword schematic');
            
            GetWitcherPlayer().AddCraftingSchematic('Gloves 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Dwarven silver sword 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Gloves 2 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Dwarven silver sword 2 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Gloves 3 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Gnomish silver sword 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Gloves 4 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Gnomish silver sword 2 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Heavy Gloves 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Heavy Gloves 2 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Heavy Gloves 3 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Heavy Gloves 4 schematic');
            
            GetWitcherPlayer().AddCraftingSchematic('Lynx Armor schematic');
            GetWitcherPlayer().AddCraftingSchematic('Lynx Boots 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Lynx Gloves 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Lynx Pants 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Gryphon Armor schematic');
            GetWitcherPlayer().AddCraftingSchematic('Gryphon Boots 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Gryphon Gloves 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Gryphon Pants 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Bear Armor schematic');
            GetWitcherPlayer().AddCraftingSchematic('Bear Boots 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Bear Gloves 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Bear Pants 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Wolf Armor schematic');
            GetWitcherPlayer().AddCraftingSchematic('Wolf Boots 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Wolf Gloves 1 schematic');
            GetWitcherPlayer().AddCraftingSchematic('Wolf Pants 1 schematic');
            
            GetWitcherPlayer().AddCraftingSchematic('Witcher Bear Jacket Upgrade schematic 1');
            GetWitcherPlayer().AddCraftingSchematic('Witcher Bear Jacket Upgrade schematic 2');
            GetWitcherPlayer().AddCraftingSchematic('Witcher Bear Jacket Upgrade schematic 3');
            GetWitcherPlayer().AddCraftingSchematic('Witcher Bear Boots Upgrade schematic 1');
            GetWitcherPlayer().AddCraftingSchematic('Witcher Bear Pants Upgrade schematic 1');
            GetWitcherPlayer().AddCraftingSchematic('Witcher Bear Gloves Upgrade schematic 1');
            GetWitcherPlayer().AddCraftingSchematic('Bear School steel sword Upgrade schematic 1');
            GetWitcherPlayer().AddCraftingSchematic('Bear School steel sword Upgrade schematic 2');
            GetWitcherPlayer().AddCraftingSchematic('Bear School steel sword Upgrade schematic 3');
            GetWitcherPlayer().AddCraftingSchematic('Bear School silver sword Upgrade schematic 1');
            GetWitcherPlayer().AddCraftingSchematic('Bear School silver sword Upgrade schematic 2');
            GetWitcherPlayer().AddCraftingSchematic('Bear School silver sword Upgrade schematic 3');
            GetWitcherPlayer().AddCraftingSchematic('Witcher Gryphon Jacket Upgrade schematic 1');
            GetWitcherPlayer().AddCraftingSchematic('Witcher Gryphon Jacket Upgrade schematic 2');
            GetWitcherPlayer().AddCraftingSchematic('Witcher Gryphon Jacket Upgrade schematic 3');
            GetWitcherPlayer().AddCraftingSchematic('Witcher Gryphon Boots Upgrade schematic 1');
            GetWitcherPlayer().AddCraftingSchematic('Witcher Gryphon Pants Upgrade schematic 1');
            GetWitcherPlayer().AddCraftingSchematic('Witcher Gryphon Gloves Upgrade schematic 1');
            GetWitcherPlayer().AddCraftingSchematic('Gryphon School steel sword Upgrade schematic 1');
            GetWitcherPlayer().AddCraftingSchematic('Gryphon School steel sword Upgrade schematic 2');
            GetWitcherPlayer().AddCraftingSchematic('Gryphon School steel sword Upgrade schematic 3');
            GetWitcherPlayer().AddCraftingSchematic('Gryphon School silver sword Upgrade schematic 1');
            GetWitcherPlayer().AddCraftingSchematic('Gryphon School silver sword Upgrade schematic 2');
            GetWitcherPlayer().AddCraftingSchematic('Gryphon School silver sword Upgrade schematic 3');
            GetWitcherPlayer().AddCraftingSchematic('Witcher Wolf Jacket Upgrade schematic 1');
            GetWitcherPlayer().AddCraftingSchematic('Witcher Wolf Jacket Upgrade schematic 2');
            GetWitcherPlayer().AddCraftingSchematic('Witcher Wolf Jacket Upgrade schematic 3');
            GetWitcherPlayer().AddCraftingSchematic('Witcher Wolf Boots Upgrade schematic 1');
            GetWitcherPlayer().AddCraftingSchematic('Witcher Wolf Pants Upgrade schematic 1');
            GetWitcherPlayer().AddCraftingSchematic('Witcher Wolf Gloves Upgrade schematic 1');
            GetWitcherPlayer().AddCraftingSchematic('Wolf School steel sword Upgrade schematic 1');
            GetWitcherPlayer().AddCraftingSchematic('Wolf School steel sword Upgrade schematic 2');
            GetWitcherPlayer().AddCraftingSchematic('Wolf School steel sword Upgrade schematic 3');
            GetWitcherPlayer().AddCraftingSchematic('Wolf School silver sword Upgrade schematic 1');
            GetWitcherPlayer().AddCraftingSchematic('Wolf School silver sword Upgrade schematic 2');
            GetWitcherPlayer().AddCraftingSchematic('Wolf School silver sword Upgrade schematic 3');
            GetWitcherPlayer().AddCraftingSchematic('Witcher Lynx Jacket Upgrade schematic 1');
            GetWitcherPlayer().AddCraftingSchematic('Witcher Lynx Jacket Upgrade schematic 2');
            GetWitcherPlayer().AddCraftingSchematic('Witcher Lynx Jacket Upgrade schematic 3');
            GetWitcherPlayer().AddCraftingSchematic('Witcher Lynx Boots Upgrade schematic 1');
            GetWitcherPlayer().AddCraftingSchematic('Witcher Lynx Pants Upgrade schematic 1');
            GetWitcherPlayer().AddCraftingSchematic('Witcher Lynx Gloves Upgrade schematic 1');
            GetWitcherPlayer().AddCraftingSchematic('Lynx School steel sword Upgrade schematic 1');
            GetWitcherPlayer().AddCraftingSchematic('Lynx School steel sword Upgrade schematic 2');
            GetWitcherPlayer().AddCraftingSchematic('Lynx School steel sword Upgrade schematic 3');
            GetWitcherPlayer().AddCraftingSchematic('Lynx School silver sword Upgrade schematic ');
            GetWitcherPlayer().AddCraftingSchematic('Lynx School silver sword Upgrade schematic 2');
            GetWitcherPlayer().AddCraftingSchematic('Lynx School silver sword Upgrade schematic 3'); 
            
            GetWitcherPlayer().AddCraftingSchematic('Steel ingot schematic');
            GetWitcherPlayer().AddCraftingSchematic('Dark iron ingot schematic');
            GetWitcherPlayer().AddCraftingSchematic('Meteorite ingot schematic');
            GetWitcherPlayer().AddCraftingSchematic('Dwimeryte ingot schematic');
            GetWitcherPlayer().AddCraftingSchematic('Silver ingot schematic 1a');
            GetWitcherPlayer().AddCraftingSchematic('Silver ingot schematic 2a');
            GetWitcherPlayer().AddCraftingSchematic('Silver ingot schematic 3a');
            GetWitcherPlayer().AddCraftingSchematic('Hardened leather schematic 1');
            GetWitcherPlayer().AddCraftingSchematic('Hardened leather schematic 2');
            GetWitcherPlayer().AddCraftingSchematic('Hardened leather schematic 3');
            GetWitcherPlayer().AddCraftingSchematic('Hardened leather schematic 4');
            GetWitcherPlayer().AddCraftingSchematic('Hardened timber schematic 1h');
            GetWitcherPlayer().AddCraftingSchematic('Draconide leather schematic 1');
            GetWitcherPlayer().AddCraftingSchematic('Draconide leather schematic 2');
            GetWitcherPlayer().AddCraftingSchematic('Draconide leather schematic 3');
            GetWitcherPlayer().AddCraftingSchematic('Draconide leather schematic ');
            GetWitcherPlayer().AddCraftingSchematic('Leather schematic 1');
            GetWitcherPlayer().AddCraftingSchematic('Leather schematic 2');
            GetWitcherPlayer().AddCraftingSchematic('Leather schematic 3');
            GetWitcherPlayer().AddCraftingSchematic('Leather schematic 4');
            GetWitcherPlayer().AddCraftingSchematic('Leather schematic 5');
            GetWitcherPlayer().AddCraftingSchematic('Leather schematic 6');
            GetWitcherPlayer().AddCraftingSchematic('Leather schematic 7');
            GetWitcherPlayer().AddCraftingSchematic('Leather schematic 8');
            GetWitcherPlayer().AddCraftingSchematic('Leather straps schematic');
            GetWitcherPlayer().AddCraftingSchematic('Steel plate schematic');
            
            GetWitcherPlayer().AddCraftingSchematic('Rune stribog lesser schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune stribog schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune stribog greater schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune dazhbog lesser schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune dazhbog schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune dazhbog greater schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune devana lesser schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune devana schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune devana greater schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune zoria lesser schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune zoria schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune zoria greater schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune morana lesser schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune morana schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune morana greater schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune triglav lesser schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune triglav schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune triglav greater schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune svarog lesser schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune svarog schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune svarog greater schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune veles lesser schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune veles schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune veles greater schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune perun lesser schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune perun schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune perun greater schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune elemental lesser schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune elemental schematic');
            GetWitcherPlayer().AddCraftingSchematic('Rune elemental greater schematic');
                    thePlayer.inv.AddAnItem('Steel ingot schematic',spawnCount);
            thePlayer.inv.AddAnItem('Dark iron ingot schematic',spawnCount);
            thePlayer.inv.AddAnItem('Meteorite ingot schematic',spawnCount);
            thePlayer.inv.AddAnItem('Dwimeryte ingot schematic',spawnCount);
            thePlayer.inv.AddAnItem('Silver ingot schematic 1a',spawnCount);
            thePlayer.inv.AddAnItem('Silver ingot schematic 2a',spawnCount);
            thePlayer.inv.AddAnItem('Silver ingot schematic 3a',spawnCount);
            thePlayer.inv.AddAnItem('Hardened leather schematic 1',spawnCount);
            thePlayer.inv.AddAnItem('Hardened leather schematic 2',spawnCount);
            thePlayer.inv.AddAnItem('Hardened leather schematic 3',spawnCount);
            thePlayer.inv.AddAnItem('Hardened leather schematic 4',spawnCount);
            thePlayer.inv.AddAnItem('Hardened timber schematic 1h',spawnCount);
            thePlayer.inv.AddAnItem('Draconide leather schematic 1',spawnCount);
            thePlayer.inv.AddAnItem('Draconide leather schematic 2',spawnCount);
            thePlayer.inv.AddAnItem('Draconide leather schematic 3',spawnCount);
            thePlayer.inv.AddAnItem('Draconide leather schematic ',spawnCount);
            thePlayer.inv.AddAnItem('Leather schematic 1',spawnCount);
            thePlayer.inv.AddAnItem('Leather schematic 2',spawnCount);
            thePlayer.inv.AddAnItem('Leather schematic 3',spawnCount);
            thePlayer.inv.AddAnItem('Leather schematic 4',spawnCount);
            thePlayer.inv.AddAnItem('Leather schematic 5',spawnCount);
            thePlayer.inv.AddAnItem('Leather schematic 6',spawnCount);
            thePlayer.inv.AddAnItem('Leather schematic 7',spawnCount);
            thePlayer.inv.AddAnItem('Leather schematic 8',spawnCount);
            thePlayer.inv.AddAnItem('Leather straps schematic',spawnCount);
            thePlayer.inv.AddAnItem('Steel plate schematic',spawnCount);
            	thePlayer.inv.AddAnItem('Lynx Armor schematic',spawnCount);
	thePlayer.inv.AddAnItem('Lynx Boots schematic',spawnCount);
	thePlayer.inv.AddAnItem('Lynx Gloves schematic',spawnCount);
	thePlayer.inv.AddAnItem('Lynx Pants schematic',spawnCount);
	thePlayer.inv.AddAnItem('Gryphon Armor schematic',spawnCount);
	thePlayer.inv.AddAnItem('Gryphon Boots schematic',spawnCount);
	thePlayer.inv.AddAnItem('Gryphon Gloves schematic',spawnCount);
	thePlayer.inv.AddAnItem('Gryphon Pants schematic',spawnCount);
	thePlayer.inv.AddAnItem('Bear Armor schematic',spawnCount);
	thePlayer.inv.AddAnItem('Bear Boots schematic',spawnCount);
	thePlayer.inv.AddAnItem('Bear Gloves schematic',spawnCount);
	thePlayer.inv.AddAnItem('Bear Pants schematic',spawnCount);
	thePlayer.inv.AddAnItem('Wolf Armor schematic',spawnCount);
	thePlayer.inv.AddAnItem('Wolf Boots schematic',spawnCount);
	thePlayer.inv.AddAnItem('Wolf Gloves schematic',spawnCount);
	thePlayer.inv.AddAnItem('Wolf Pants schematic',spawnCount);
	thePlayer.inv.AddAnItem('Light Armor 1 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Light Armor 1 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Light Armor 2 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Light Armor 3 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Light Armor 4 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Light Armor 5 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Light Armor 6 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Light Armor 7 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Light Armor 8 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Medium Armor 1 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Medium Armor 2 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Medium Armor 3 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Medium Armor 4 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Medium Armor 5 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Medium Armor 6 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Medium Armor 7 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Medium Armor 8 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Medium Armor 9 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Medium Armor 10 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Heavy Armor 1 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Heavy Armor 2 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Heavy Armor 3 schematic',spawnCount);
	thePlayer.inv.AddAnItem('Heavy Armor 4 schematic',spawnCount);
    thePlayer.inv.AddAnItem('Bodkin Bolt schematic',spawnCount);
	thePlayer.inv.AddAnItem('Tracking Bolt schematic',spawnCount);
	thePlayer.inv.AddAnItem('Bait Bolt schematic',spawnCount);
	thePlayer.inv.AddAnItem('Blunt Bolt schematic',spawnCount);
	thePlayer.inv.AddAnItem('Broadhead Bolt schematic',spawnCount);
	thePlayer.inv.AddAnItem('Target Point Bolt schematic',spawnCount);
	thePlayer.inv.AddAnItem('Split Bolt schematic',spawnCount);
	thePlayer.inv.AddAnItem('Explosive Bolt schematic',spawnCount);
    }
    function GiveFTMapsForW3Player()
    {
        	thePlayer.inv.AddAnItem('an_skellige_map',spawnCount);
            thePlayer.inv.AddAnItem('ard_skellige_map',spawnCount);
            thePlayer.inv.AddAnItem('faroe_map',spawnCount);
            thePlayer.inv.AddAnItem('hindarsfjal_map',spawnCount);
            thePlayer.inv.AddAnItem('undvik_map',spawnCount);
            thePlayer.inv.AddAnItem('spikeroog_map',spawnCount);
    }
    function GiveAllRepairKitsForW3Player()
    {
        thePlayer.inv.AddAnItem('weapon_repair_kit_1',spawnCount);
        thePlayer.inv.AddAnItem('weapon_repair_kit_2',spawnCount);
        thePlayer.inv.AddAnItem('weapon_repair_kit_3',spawnCount);
        thePlayer.inv.AddAnItem('armor_repair_kit_1',spawnCount);
        thePlayer.inv.AddAnItem('armor_repair_kit_2',spawnCount);
        thePlayer.inv.AddAnItem('armor_repair_kit_3',spawnCount);
    }
    function SwitchCharacterToCiri()
    {
        theGame.ChangePlayer( "Ciri" );
	    thePlayer.Debug_ReleaseCriticalStateSaveLocks();
        
    }
    function SwitchCharacterToGeralt()
    {
        theGame.ChangePlayer( "Geralt" );
	    thePlayer.Debug_ReleaseCriticalStateSaveLocks();
    }
    function LikeABossForW3Player()
    {
        FactsAdd('player_is_the_boss');
        LogCheats( "Like a Boss is now ON" );
    }
    function DisableLikeABossForW3Player()
    {
        FactsRemove('player_is_the_boss');
        LogCheats( "Like a Boss is now OFF" );
    }
    function StartGwentForW3Player(deckIndex : int)
    {
        var gwintManager:CR4GwintManager;
        gwintManager = theGame.GetGwintManager();
        gwintManager.setDoubleAIEnabled(false);
        deckIndex = 1;
        if (deckIndex)
        {
            gwintManager.SetEnemyDeckIndex(deckIndex);
        }
        
        gwintManager.testMatch = true;
        
        gwintManager.SetForcedFaction(GwintFaction_Neutral);

        if (gwintManager.GetHasDoneTutorial())
        {
            gwintManager.gameRequested = true;
            theGame.RequestMenu( 'DeckBuilder' );
        }
        else
        {
            theGame.RequestMenu( 'GwintGame' );
        }
    }

    var params : SCustomEffectParams;
   

    function ActivateAllGloassaryForW3Player()
    {
        manager = theGame.GetJournalManager();
        
        activateJournalCharacterEntryWithAlias("CharactersAnabelle", manager);
        activateJournalCharacterEntryWithAlias("CharactersAnnaStenger", manager);
        activateJournalCharacterEntryWithAlias("CharactersArnvald", manager);
        activateJournalCharacterEntryWithAlias("CharactersAvallach", manager);
        activateJournalCharacterEntryWithAlias("CharactersBabcia", manager);
        activateJournalCharacterEntryWithAlias("CharactersBaron", manager);
        activateJournalCharacterEntryWithAlias("CharactersBirna", manager);
        activateJournalCharacterEntryWithAlias("CharactersBlueBoyLugos", manager);
        activateJournalCharacterEntryWithAlias("CharactersBrewess", manager);
        activateJournalCharacterEntryWithAlias("CharactersCaranthir", manager);
        activateJournalCharacterEntryWithAlias("CharactersCarduin", manager);
        activateJournalCharacterEntryWithAlias("CharactersCerys", manager);
        activateJournalCharacterEntryWithAlias("CharactersChapelle", manager);
        activateJournalCharacterEntryWithAlias("CharactersCirilla", manager);
        activateJournalCharacterEntryWithAlias("CharactersCorinetilly", manager);
        activateJournalCharacterEntryWithAlias("CharactersCrach", manager);
        activateJournalCharacterEntryWithAlias("CharactersDandelion", manager);
        activateJournalCharacterEntryWithAlias("CharactersDijkstra", manager);
        activateJournalCharacterEntryWithAlias("CharactersDonar", manager);
        activateJournalCharacterEntryWithAlias("CharactersDuchDrzewa", manager);
        activateJournalCharacterEntryWithAlias("CharactersDudu", manager);
        activateJournalCharacterEntryWithAlias("CharactersElihal", manager);
        activateJournalCharacterEntryWithAlias("CharactersEmhyrVarEmreis", manager);
        activateJournalCharacterEntryWithAlias("CharactersEredin", manager);
        activateJournalCharacterEntryWithAlias("CharactersEskel", manager);
        activateJournalCharacterEntryWithAlias("CharactersFeliciaCori", manager);
        activateJournalCharacterEntryWithAlias("CharactersFolan", manager);
        activateJournalCharacterEntryWithAlias("CharactersFringilla", manager);
        activateJournalCharacterEntryWithAlias("CharactersFugas", manager);
        activateJournalCharacterEntryWithAlias("CharactersGeels", manager);
        activateJournalCharacterEntryWithAlias("CharactersGeralt", manager);
        activateJournalCharacterEntryWithAlias("CharactersGraden", manager);
        activateJournalCharacterEntryWithAlias("CharactersGraham", manager);
        activateJournalCharacterEntryWithAlias("CharactersGuslarz", manager);
        activateJournalCharacterEntryWithAlias("CharactersHalbjorn", manager);
        activateJournalCharacterEntryWithAlias("CharactersHarald", manager);
        activateJournalCharacterEntryWithAlias("CharactersHendrik", manager);
        activateJournalCharacterEntryWithAlias("CharactersHjalmar", manager);
        activateJournalCharacterEntryWithAlias("CharactersHjort", manager);
        activateJournalCharacterEntryWithAlias("CharactersHolger", manager);
        activateJournalCharacterEntryWithAlias("CharactersHubert", manager);
        activateJournalCharacterEntryWithAlias("CharactersImlerith", manager);
        activateJournalCharacterEntryWithAlias("CharactersIrinaRenarde", manager);
        activateJournalCharacterEntryWithAlias("CharactersJanek", manager);
        activateJournalCharacterEntryWithAlias("CharactersJoachim", manager);
        activateJournalCharacterEntryWithAlias("CharactersKarlVarese", manager);
        activateJournalCharacterEntryWithAlias("CharactersKeira", manager);
        activateJournalCharacterEntryWithAlias("CharactersKrolZebrakow", manager);
        activateJournalCharacterEntryWithAlias("CharactersLambert", manager);
        activateJournalCharacterEntryWithAlias("CharactersLetho", manager);
        activateJournalCharacterEntryWithAlias("CharactersLugosMad", manager);
        activateJournalCharacterEntryWithAlias("CharactersLuizaLaValette", manager);
        activateJournalCharacterEntryWithAlias("CharactersMargarita", manager);
        activateJournalCharacterEntryWithAlias("CharactersMenge", manager);
        activateJournalCharacterEntryWithAlias("CharactersMousesack", manager);
        activateJournalCharacterEntryWithAlias("CharactersMysteriousElf", manager);
        activateJournalCharacterEntryWithAlias("CharactersNataniel", manager);
        activateJournalCharacterEntryWithAlias("CharactersOtrygg", manager);
        activateJournalCharacterEntryWithAlias("CharactersPhilippaEilhart", manager);
        activateJournalCharacterEntryWithAlias("CharactersPriscilla", manager);
        activateJournalCharacterEntryWithAlias("CharactersRadovid", manager);
        activateJournalCharacterEntryWithAlias("CharactersRoche", manager);
        activateJournalCharacterEntryWithAlias("CharactersSheala", manager);
        activateJournalCharacterEntryWithAlias("CharactersSvanrige", manager);
        activateJournalCharacterEntryWithAlias("CharactersTalar", manager);
        activateJournalCharacterEntryWithAlias("CharactersTamara", manager);
        activateJournalCharacterEntryWithAlias("CharactersTavar", manager);
        activateJournalCharacterEntryWithAlias("CharactersTriss", manager);
        activateJournalCharacterEntryWithAlias("CharactersTrollBart", manager);
        activateJournalCharacterEntryWithAlias("CharactersUdalryk", manager);
        activateJournalCharacterEntryWithAlias("CharactersUma", manager);
        activateJournalCharacterEntryWithAlias("CharactersVes", manager);
        activateJournalCharacterEntryWithAlias("CharactersVesemir", manager);
        activateJournalCharacterEntryWithAlias("CharactersVigi", manager);
        activateJournalCharacterEntryWithAlias("CharactersVimme", manager);
        activateJournalCharacterEntryWithAlias("CharactersVoorhis", manager);
        activateJournalCharacterEntryWithAlias("CharactersWeavess", manager);
        activateJournalCharacterEntryWithAlias("CharactersWhisperess", manager);
        activateJournalCharacterEntryWithAlias("CharactersWhoreson", manager);
        activateJournalCharacterEntryWithAlias("CharactersWszerad", manager);
        activateJournalCharacterEntryWithAlias("CharactersYennefer", manager);
        activateJournalCharacterEntryWithAlias("CharactersZoltan", manager);

        
        activateJournalGlossaryGroupWithAlias("GlossaryDebugGlossary", manager);
        activateJournalGlossaryGroupWithAlias("GlossaryWitchers", manager);

        
        
        activateJournalStoryBookPageEntryWithAlias("StoryBookPrologueEntry01", manager);
        activateJournalStoryBookPageEntryWithAlias("StoryBookPrologueEntry02", manager);
        
        
        activateJournalStoryBookPageEntryWithAlias("StoryBookChapter1Entry01", manager);
        activateJournalStoryBookPageEntryWithAlias("StoryBookChapter1Entry02", manager);
        activateJournalStoryBookPageEntryWithAlias("StoryBookChapter1Entry03", manager);
        activateJournalStoryBookPageEntryWithAlias("StoryBookChapter1Entry04", manager);
        activateJournalStoryBookPageEntryWithAlias("StoryBookChapter1Entry05", manager);
        activateJournalStoryBookPageEntryWithAlias("StoryBookChapter1Entry06", manager);
        activateJournalStoryBookPageEntryWithAlias("StoryBookChapter1Entry07", manager);
        activateJournalStoryBookPageEntryWithAlias("StoryBookChapter1Entry08", manager);
        activateJournalStoryBookPageEntryWithAlias("StoryBookChapter1Entry09", manager);
        activateJournalStoryBookPageEntryWithAlias("StoryBookChapter1Entry10", manager);

        
        activateJournalStoryBookPageEntryWithAlias("StoryBookChapter2Entry01", manager);
        activateJournalStoryBookPageEntryWithAlias("StoryBookChapter2Entry02", manager);
        activateJournalStoryBookPageEntryWithAlias("StoryBookChapter2Entry03", manager);

        
        activateJournalStoryBookPageEntryWithAlias("StoryBookChapter3Entry01", manager);
        activateJournalStoryBookPageEntryWithAlias("StoryBookChapter3Entry02", manager);
        activateJournalStoryBookPageEntryWithAlias("StoryBookChapter3Entry03", manager);
        activateJournalStoryBookPageEntryWithAlias("StoryBookChapter3Entry04", manager);

        
        activateJournalBestiaryEntryWithAlias("BestiaryElemental", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryGolem", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryIceGolem", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryFireElemental", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryWhMinion", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryDzinn", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryGargoyle", manager);

        activateJournalBestiaryEntryWithAlias("BestiaryWerebear", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryMiscreant", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryWerewolf", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryLycanthrope", manager);

        activateJournalBestiaryEntryWithAlias("BestiaryEndriaga", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryCrabSpider", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryArmoredArachas", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryPoisonousArachas", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryEndriagaTruten", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryEndriagaWorker", manager);

        activateJournalBestiaryEntryWithAlias("BestiaryAlghoul", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryGhoul", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryGreaterRotFiend", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryDrowner", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryFogling", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryGraveHag", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryWaterHag", manager);

        activateJournalBestiaryEntryWithAlias("BestiaryBasilisk", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryCockatrice", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryForktail", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryWyvern", manager);

        activateJournalBestiaryEntryWithAlias("BestiaryNoonwright", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryMoonwright", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryPesta", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryHim", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryWraith", manager);

        activateJournalBestiaryEntryWithAlias("BestiaryWolf", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryBear", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryDog", manager);

        activateJournalBestiaryEntryWithAlias("BestiaryKatakan", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryEkkima", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryHigherVampire", manager);

        activateJournalBestiaryEntryWithAlias("BestiaryCyclop", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryIceGiant", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryNekker", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryIceTroll", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryCaveTroll", manager);

        activateJournalBestiaryEntryWithAlias("BestiaryErynia", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryGriffin", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryHarpy", manager);
        activateJournalBestiaryEntryWithAlias("BestiarySiren", manager);
        activateJournalBestiaryEntryWithAlias("BestiarySuccubus", manager);

        activateJournalBestiaryEntryWithAlias("BestiaryLeshy", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryBies", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryCzart", manager);
        activateJournalBestiaryEntryWithAlias("BestiarySilvan", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryWitches", manager);
        activateJournalBestiaryEntryWithAlias("BestiaryGolding", manager);

        activateJournalBestiaryEntryWithAlias(      "BestiaryElemental",        theGame.GetJournalManager() );
        activateJournalStoryBookPageEntryWithAlias( "StoryBookPrologueEntry01", theGame.GetJournalManager() );
        activateJournalCharacterEntryWithAlias(     "CharactersEredin",         theGame.GetJournalManager() );
        activateJournalGlossaryGroupWithAlias(      "GlossaryDebugGlossary",    theGame.GetJournalManager() );
    }

    function SpawnKeysForW3Player()
    {
        thePlayer.inv.AddAnItem('q103_tamara_shrine_key',spawnCount);
        thePlayer.inv.AddAnItem('q104_keira_mine_key',spawnCount);
        thePlayer.inv.AddAnItem('q107_guslar_cell_key',spawnCount);
        thePlayer.inv.AddAnItem('q201_yen_chamber_key',spawnCount);
        thePlayer.inv.AddAnItem('q202_hjalmar_cell_key',spawnCount);
        thePlayer.inv.AddAnItem('q205_key_to_burrow',spawnCount);
        thePlayer.inv.AddAnItem('q206_arnvalds_key',spawnCount);
        thePlayer.inv.AddAnItem('q206_arnvalds_chest_key',spawnCount);
        thePlayer.inv.AddAnItem('q208_yen_room_key',spawnCount);
        thePlayer.inv.AddAnItem('q301_crematory_key',spawnCount);
        thePlayer.inv.AddAnItem('q303_menges_skeleton_key',spawnCount);
        thePlayer.inv.AddAnItem('q303_vault_key',spawnCount);
        thePlayer.inv.AddAnItem('q305_key_midgets_house',spawnCount);
        thePlayer.inv.AddAnItem('q401_trial_ingredients_key',spawnCount);
        thePlayer.inv.AddAnItem('q503_lockbox_key',spawnCount);
        thePlayer.inv.AddAnItem('sq102_barn_door_side_key',spawnCount);
        thePlayer.inv.AddAnItem('sq102_lockbox_key',spawnCount);
        thePlayer.inv.AddAnItem('sq210_underwater_chest_key',spawnCount);
        thePlayer.inv.AddAnItem('sq210_underwater_gate2_key',spawnCount);
        thePlayer.inv.AddAnItem('sq210_underwater_gate1_key',spawnCount);
        thePlayer.inv.AddAnItem('sq302_philippa_key',spawnCount);
        thePlayer.inv.AddAnItem('sq303_pollys_key',spawnCount);
        thePlayer.inv.AddAnItem('sq304_warehouse_key',spawnCount);
        thePlayer.inv.AddAnItem('sq304_wrhs_indoor_key',spawnCount);
        thePlayer.inv.AddAnItem('sq310_zed_door_key',spawnCount);
        thePlayer.inv.AddAnItem('sq310_attic_key',spawnCount);
        thePlayer.inv.AddAnItem('sq310_triangle_key',spawnCount);
        thePlayer.inv.AddAnItem('sq314_prison_key',spawnCount);
        thePlayer.inv.AddAnItem('sq314_sigil_key',spawnCount);
        thePlayer.inv.AddAnItem('mq2003_treasure_chamber_key',spawnCount);
        thePlayer.inv.AddAnItem('mq3002_chest_key',spawnCount);
        thePlayer.inv.AddAnItem('mq2020_slave_cells_key',spawnCount);
        thePlayer.inv.AddAnItem('mh207_lighthouse_door_key',spawnCount);
        thePlayer.inv.AddAnItem('mh104_ekimma_house_key',spawnCount);
        thePlayer.inv.AddAnItem('mq2020_pirate_lord_house_door',spawnCount);
        thePlayer.inv.AddAnItem('mh303_succubus_house_key',spawnCount);
        thePlayer.inv.AddAnItem('mh304_morge_door_key',spawnCount);
        thePlayer.inv.AddAnItem('mh304_katakan_hideout_door_key',spawnCount);
        thePlayer.inv.AddAnItem('mh306_dao_manor_door_key',spawnCount);
        thePlayer.inv.AddAnItem('gp_prologue_key01',spawnCount);
        thePlayer.inv.AddAnItem('lw_prologue_royal_key01',spawnCount);
        thePlayer.inv.AddAnItem('lw_cb17_key',spawnCount);
        thePlayer.inv.AddAnItem('lw_cp_glinsk_cage_key_1',spawnCount);
        thePlayer.inv.AddAnItem('lw_tm12_refugee_camp_key',spawnCount);
        thePlayer.inv.AddAnItem('lw_gr13_slavers_key',spawnCount);
        thePlayer.inv.AddAnItem('lw_de6_scavenger_key',spawnCount);
    }
    function SpawnBarrelsForW3Player()
    {
        pos = thePlayer.GetWorldPosition();
        pos.Z += 3;
        template = (CEntityTemplate)LoadResource( "barrel");
        
        pos.X += 4;
        pos.Y += 4;
        ent = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation() );
        
        pos.X -= 4;
        pos.Y += 4;
        ent = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation() );
        
        pos.X += 4;
        pos.Y -= 4;
        ent = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation() );
        
        pos.X -= 4;
        pos.Y -= 4;
        ent = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation() );
        
        pos.X += 6;
        pos.Y += 6;
        ent = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation() );
        
        pos.X -= 6;
        pos.Y += 6;
        ent = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation() );
        
        pos.X += 6;
        pos.Y -= 6;
        ent = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation() );
        
        pos.X -= 6;
        pos.Y -= 6;
        ent = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation() );
    }

    function SpawnBeesForW3Player()
    {
        pos = thePlayer.GetWorldPosition();
        pos.Z += 4;
        template = (CEntityTemplate)LoadResource( "beehive");
        
        ent = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation() );
        
        pos.X += 8;
        ent = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation() );
        
        pos.Y += 8;
        ent = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation() );
        
        pos.X -= 8;
        ent = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation() );
    }

    function SetLevelForW3Player()
    {
        GetWitcherPlayer().DisplayHudMessage("level set");
        lm = GetWitcherPlayer();
        prevLvl = lm.GetLevel();
        currLvl = lm.GetLevel();
        while(currLvl < spawnCount)
        {
            exp = lm.GetTotalExpForNextLevel() - lm.GetPointsTotal(EExperiencePoint);
            lm.AddPoints(EExperiencePoint, exp, false);
            currLvl = lm.GetLevel();
            
            if(prevLvl == currLvl)
                break;				
            
            prevLvl = currLvl;
        }	
    }
    function LevelUpForW3Player()
    {
        times = spawnCount;
        if(times < 1)
            times = 1;
            
        lm = GetWitcherPlayer();
        for(i=0; i<times; i+=1)
        {
            exp = lm.GetTotalExpForNextLevel() - lm.GetPointsTotal(EExperiencePoint);
            lm.AddPoints(EExperiencePoint, exp, false );
        }
    }   
            
        
       
        
            

        
            
    
  	var entityName : name;
    var entityAppearance : name;
    var displayName : name;
    var depotPath : String;
    var displayTextW3Player : name;

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
            chosenTextElement.textItemName = displayName;
            spawnTextElement.colourValue = COLOUR_GREEN;
            chosenTextElement.textItemName = entityName;
        }
        else
        {
            chosenTextElement.textValue = "[Select]";
            spawnTextElement.colourValue = COLOUR_RED;
        }
        if(IsNameValid(entityAppearance))
        {
            //chosenAppearanceElement.textValue = NameToString(entityAppearance);
        }
        else
        {
            //chosenAppearanceElement.textValue = "Default Appearance";
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

    }
	  var chooseMenu : UIForTrainerChooseEntityMenu;
    private function OpenChooseMenu()
    {
        if(!chooseMenu) chooseMenu = new UIForTrainerChooseEntityMenu in this;
        window.OpenMenu(chooseMenu);
    }

    private function setCount(counter : UIForTrainerMenu_Counter) { this.spawnCount = counter.GetCounterValue(); }

}




class 	UIForTrainerSpawnData
{
	public saved var nam : name;
	public saved var niceName : name;
	public saved var appearance : name;
	public saved var level : int;
	public saved var scale : float;
	//public saved var mortal : bool;
	public saved var isSpecial : bool;
	public saved var depotPathPrefix : String;
	
	public function equals(data : UIForTrainerSpawnData) : bool
	{
		return this.nam == 		data.nam && 
		this.niceName == 		data.niceName && 
		this.appearance == 		data.appearance && 
		this.level == 			data.level && 
		this.scale == 			data.scale && 
		//this.mortal == 			data.mortal && 
		this.isSpecial == 		data.isSpecial && 
		this.depotPathPrefix == 	data.depotPathPrefix;
	}
	
	public function copyFrom(data : UIForTrainerSpawnData)
	{
		this.nam = data.nam;
		this.niceName = data.niceName;
		this.appearance = data.appearance;
		this.level = data.level;
		this.scale = data.scale;
		//this.mortal = data.mortal;
		this.isSpecial = data.isSpecial;
		this.depotPathPrefix = data.depotPathPrefix;
	}
}
