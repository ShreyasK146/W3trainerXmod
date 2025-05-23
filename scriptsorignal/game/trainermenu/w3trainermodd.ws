class mod_UIForTrainer_saved_data_copy
{
	editable var followers : array<UIForTrainerSpawnData>;
}

class mod_UIForTrainer_saved_data
{
	editable saved var followers : array<UIForTrainerSpawnData>;
	editable var SCM_Copy : mod_UIForTrainer_saved_data_copy;
	
	public function copyFrom(data : mod_UIForTrainer_saved_data)
	{
		var i, sz : int;
		var tmp : UIForTrainerSpawnData;
		
		sz = data.followers.Size();
		this.followers.Clear();
		
		for(i = 0; i < sz; i+=1)
		{
			tmp = new UIForTrainerSpawnData in theGame;
			tmp.copyFrom(data.followers[i]);
			this.followers.PushBack(tmp);
		}
	}
	
	public function AddCompanion(data : UIForTrainerSpawnData)
	{
		followers.PushBack(data);
	}
	
	public function RemoveCompanion(data : UIForTrainerSpawnData) : bool
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
		var newArr : array<UIForTrainerSpawnData>;
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

function UIForTrainer_fact(nam : name) : bool
{
	return FactsQuerySum(nam) >= 1;
}
statemachine class mod_UIForTrainer extends CObject
{
	default autoState = 'Idle';


	public var MenuManager : UIForTrainer_MenuManager;
	public var EntityList : UIForTrainerMenu_EntityList;


	private var isInit : bool; default isInit = false;
	public function init()
	{
		
		if(isInit) return;
		isInit = true;
		this.GotoState('Idle');
	

		MenuManager = new UIForTrainer_MenuManager in this;
		MenuManager.init();

		EntityList = new UIForTrainerMenu_EntityList in this;
		EntityList.init();

	}

	public function ReloadData()
	{

	}


	
	event OnUIForTrainerMenu(action : SInputAction)
	{
		if(IsPressed(action))
		{
			
			this.MenuManager.ToggleWindow();
		}
	}

	
	
	public function timer1second2()
	{
		if(thePlayer.GetCurrentStateName() == 'Exploration')
		{
			EnableGodModeForGeralt();
			EnableUnlimitedStaminaForGeralt();
			HealGeraltForMe();
			ChangeWeatherSystem();
			RemoveAllItemsFromInventory();
			AddAbilityForGeralt();
			KillAllNearGeralt();
			KillGeralt();
			ActivateBossMode();
			MapManagerThings();
			WorldTeleportCommands();
			ScaryStuffCommands();
			SomeOtherThings();
		}
		
	}
	var hud : CR4ScriptedHud;
	var entities : array<CGameplayEntity>;
	var entity : CGameplayEntity;
	var vehicle : CVehicleComponent;
	var deckIndex : int;
	var options : array<UIForTrainerOptionsMenuEntry>;

	function SomeOtherThings()
	{
		var acs : array< CComponent >;
		var gwintManager:CR4GwintManager;
		gwintManager = theGame.GetGwintManager();
		gwintManager.setDoubleAIEnabled(false);

		if(UIForTrainer_fact('Cat'))
		{
			EnableCatViewFx( 1.0f );	
			SetPositionCatViewFx( Vector(0,0,0,0) , true );	
		}
		else
			DisableCatViewFx( 1.0f );	

		if(UIForTrainer_fact('Drunk'))
			EnableDrunkFx( 1.0f );
		else 
			DisableDrunkFx( 1.0f );	
			
		if(UIForTrainer_fact('Shave'))
		{
			acs = thePlayer.GetComponentsByClassName( 'CHeadManagerComponent' );
			( ( CHeadManagerComponent ) acs[0] ).Shave();
		}	
		if(UIForTrainer_fact('SetTattoo'))
		{
			// acs = thePlayer.GetComponentsByClassName( 'CHeadManagerComponent' );
			// ( ( CHeadManagerComponent ) acs[0] ).SetTattoo( true );
			// //GetWitcherPlayer().DisplayHudMessage('hello');
		}
		else
		{
			// acs = thePlayer.GetComponentsByClassName( 'CHeadManagerComponent' );
			// ( ( CHeadManagerComponent ) acs[0] ).SetTattoo( false );
			// //GetWitcherPlayer().DisplayHudMessage('hello2');
		}
		if(UIForTrainer_fact('SecretGwint'))
		{
			
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
			FactsSet(options[19].fact, 0);
		}
		if(UIForTrainer_fact('SetBeard'))
		{
			acs = thePlayer.GetComponentsByClassName( 'CHeadManagerComponent' );
			( ( CHeadManagerComponent ) acs[0] ).SetBeardStage( true, 1 );
		}
		if(UIForTrainer_fact('StaminaPony'))
		{
			//StaminaPonyInternal(!FactsDoesExist("debug_fact_stamina_pony"));
		}
		if(UIForTrainer_fact('InstantMount'))
		{
			// FindGameplayEntitiesInRange(entities,thePlayer,1000,1,vehicleTag);
			// entity = entities[0];
			
			// if ( entity )
			// {
			// 	vehicle = (CVehicleComponent)(entity.GetComponentByClassName('CVehicleComponent'));
			// 	if ( vehicle )
			// 	{
			// 		vehicle.Mount( thePlayer, VMT_ImmediateUse, EVS_driver_slot );
			// 	}
			// }
		}
		if(UIForTrainer_fact('HudHide'))
		{
			hud = (CR4ScriptedHud)theGame.GetHud();
			hud.OnDialogHudShow();
		}
		if(UIForTrainer_fact('HudShow'))
		{
			hud = (CR4ScriptedHud)theGame.GetHud();
			hud.OnDialogHudHide();
		}
	}
	
	function ScaryStuffCommands()
	{
		if (UIForTrainer_fact('witchcraft'))
		{
			theGame.GetDefinitionsManager().TestWitchcraft();
		}
		if (UIForTrainer_fact('cleardevelop'))
		{
			GetWitcherPlayer().Debug_ClearCharacterDevelopment();
		}
	}
	function WorldTeleportCommands()
	{
		
	}
	
	function EnableGodModeForGeralt()
	{
		if (UIForTrainer_fact('god_mode_enabled'))
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
		else
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

	}
	function EnableUnlimitedStaminaForGeralt()
	{
		var isImmortal : bool;
		if (UIForTrainer_fact('unlimited_stamina'))
		{
			if ( !thePlayer.IsImmortal() )
				thePlayer.CheatGod2( true );
		}
		else
		{
			if ( thePlayer.IsImmortal() )
				thePlayer.CheatGod2( false );
		}

	}

	function HealGeraltForMe()
	{
		var max, current : float;
		if (UIForTrainer_fact('healme'))
		{
			max = thePlayer.GetStatMax(BCS_Vitality);
			current = thePlayer.GetStat(BCS_Vitality);
			thePlayer.ForceSetStat(BCS_Vitality, MinF(max, current + max * 100 / 100));
		}

	}

	function ChangeWeatherSystem()
	{
		// if(UIForTrainer_fact('WT_Clear'))
		// 	RequestWeatherChangeTo( 'WT_Clear' , 1, false );
		// if(UIForTrainer_fact('WT_Light_Clouds'))
		// 	RequestWeatherChangeTo( 'WT_Light_Clouds' , 1, false );
		// if(UIForTrainer_fact('WT_Mid_Clouds'))
		// 	RequestWeatherChangeTo( 'WT_Mid_Clouds' , 1, false );
		// if(UIForTrainer_fact('WT_Heavy_Clouds'))
		// 	RequestWeatherChangeTo( 'WT_Heavy_Clouds' , 1, false );
		// if(UIForTrainer_fact('WT_Light_Rain'))
		// 	RequestWeatherChangeTo( 'WT_Light_Rain' , 1, false );
		// if(UIForTrainer_fact('WT_Light_Snow'))
		// 	RequestWeatherChangeTo( 'WT_Light_Snow' , 1, false );
		// if(UIForTrainer_fact('WT_Blizzard'))
		// 	RequestWeatherChangeTo( 'WT_Blizzard' , 1, false );
		// if(UIForTrainer_fact('WT_Rain_Storm'))
		// 	RequestWeatherChangeTo( 'WT_Rain_Storm' , 1, false );
			

	}

	function RemoveAllItemsFromInventory()
	{
		if (UIForTrainer_fact('removeall'))
		{
			GetWitcherPlayer().GetInventory().RemoveAllItems();
		}
	}

	function AddAbilityForGeralt()
	{
		// if(UIForTrainer_fact('Horse Bag 3'))
		// 	thePlayer.AddAbility('Horse Bag 3');
		// if(UIForTrainer_fact('MistCharge'))
		// 	thePlayer.AddAbility('MistCharge');
		// if(UIForTrainer_fact('attack_explosion'))
		// 	thePlayer.AddAbility('attack_explosion');
		// if(UIForTrainer_fact('AardShrineBuff'))
		// 	thePlayer.AddAbility('AardShrineBuff');
	}

	function ChangeDifficultyForGeralt()
	{
		if(UIForTrainer_fact('EDM_Easy'))
		{
			theGame.SetDifficultyLevel(EDM_Easy);
			theGame.OnDifficultyChanged(EDM_Easy);
		}

		else if(UIForTrainer_fact('EDM_Medium'))
		{
			theGame.SetDifficultyLevel(EDM_Medium);
			theGame.OnDifficultyChanged(EDM_Medium);
		}
	
		else if(UIForTrainer_fact('EDM_Hard'))
		{
			theGame.SetDifficultyLevel(EDM_Hard);
			theGame.OnDifficultyChanged(EDM_Hard);
		}
	
		else if(UIForTrainer_fact('EDM_Hardcore'))
		{
			theGame.SetDifficultyLevel(EDM_Hardcore);
			theGame.OnDifficultyChanged(EDM_Hardcore);
		}

	}

	function KillAllNearGeralt()
	{
		var enemies: array<CActor>;
		var i, enemiesSize : int;
		var npc : CNewNPC;
		if(UIForTrainer_fact('killall'))
		{
            
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
	}
	function KillGeralt()
	{
		if(UIForTrainer_fact('killme'))
			thePlayer.Kill( 'Debug', true );
	}
	function ActivateBossMode()
	{
		// if(FactsQuerySum('player_is_the_boss') > 0)
		// {
		// 	FactsRemove('player_is_the_boss');
		// 	LogCheats( "Like a Boss is now OFF" );
		// }
		// else
		// {
		// 	FactsAdd('player_is_the_boss');
		// 	LogCheats( "Like a Boss is now ON" );
		// }
	}

	function MapManagerThings()
	{
		if(FactsQuerySum('AllowFT') > 0)
			theGame.GetCommonMapManager().DBG_AllowFT(true);
		else
			theGame.GetCommonMapManager().DBG_AllowFT(false);

		if(FactsQuerySum('ShowAllFT') > 0)
			theGame.GetCommonMapManager().DBG_ShowAllFT(true);
		else
			theGame.GetCommonMapManager().DBG_ShowAllFT(false);

		if(FactsQuerySum('ShowKnownPins'))
			theGame.GetCommonMapManager().DBG_ShowKnownPins(true);
		else
			theGame.GetCommonMapManager().DBG_ShowKnownPins(false);

		if(FactsQuerySum('ShowPins') > 0)
			theGame.GetCommonMapManager().DBG_ShowPins(true);
		else
			theGame.GetCommonMapManager().DBG_ShowPins(false);
	}

	



//dismember
/*
	var actor 				: CActor;	
	var dismembermentComp 	: CDismembermentComponent;
	var wounds				: array< name >;
	var usedWound			: name;
	
	actor = thePlayer.GetTarget();
	if(!actor) return;
	dismembermentComp = (CDismembermentComponent)(actor.GetComponentByClassName( 'CDismembermentComponent' ));
	if(!dismembermentComp) return;
	
	dismembermentComp.GetWoundsNames( wounds, WTF_Explosion );
	
	if ( wounds.Size() > 0 )
					usedWound = wounds[ RandRange( wounds.Size() ) ];
					
	actor.SetDismembermentInfo( usedWound, actor.GetWorldPosition() - actor.GetWorldPosition(), true );
	actor.AddTimer( 'DelayedDismemberTimer', 0.05f );
*/
// appearence 
/*
exec function appearance( app : name )
{
	var npc : CActor;
	npc = thePlayer.GetTarget();
	
	if( npc )
	{
		npc.SetAppearance( app );
	}
}
*/
// fasttravel worlds


// hmmm spawnhorse
/*
	private function SpawnHorse()
	{
		var template : CEntityTemplate;
		var pos : Vector;
		var rot : EulerAngles;
		
		pos = parent.GetWorldPosition();
		rot = parent.GetWorldRotation();
		
		template = (CEntityTemplate)LoadResource("characters\npc_entities\animals\horse\horse_vehicle.w2ent", true); //'horse');
		
		horseEntity = (CNewNPC)theGame.CreateEntity(template, pos, rot, true, false, false, PM_DontPersist); //true, false, false, PM_DontPersist);
		horseEntity.AddTag(parent.scmcc.GetHorseTag());
		horseEntity.AddTag('scm_horse');
	}
*/
// spawnBoatAndMount
/*
var entities : array<CGameplayEntity>;
	var vehicle : CVehicleComponent;
	var i : int;
	var boat : W3Boat;
	var ent : CEntity;
	var player : Vector;
	var rot : EulerAngles;
	var template : CEntityTemplate;
	
	FindGameplayEntitiesInRange( entities, thePlayer, 10, 10, 'vehicle' );
	
	for( i = 0; i < entities.Size(); i = i + 1 )
	{
		boat = ( W3Boat )entities[ i ];
		if( boat )
		{
			vehicle = ( CVehicleComponent )( boat.GetComponentByClassName( 'CVehicleComponent' ) );
			if ( vehicle )
			{
				vehicle.Mount( thePlayer, VMT_ImmediateUse, EVS_driver_slot );
			}
			
			return;
		}
	}

	rot = thePlayer.GetWorldRotation();	
	player = thePlayer.GetWorldPosition();
	template = (CEntityTemplate)LoadResource( 'boat' );
	player.Z = 0.0f;

	ent = theGame.CreateEntity(template, player, rot, true, false, false, PM_Persist );
	
	if( ent )
	{
		vehicle = ( CVehicleComponent )( ent.GetComponentByClassName( 'CVehicleComponent' ) );
		if ( vehicle )
		{
			vehicle.Mount( thePlayer, VMT_ImmediateUse, EVS_driver_slot );
		}
	}
*/
// time set/TM
/*
exec function TM( hoursPerMinute : float )
{
	theGame.SetHoursPerMinute( hoursPerMinute );
	
	Log("Time : " + GameTimeToString( theGame.GetGameTime() ) );
}
*/

//addgwintcards 258
/*

			AddDeckNeutral();
			AddDeckNK();
			AddDeckNilf();
			AddDeckScoia();
			AddDeckMonst();
			AddDeckSke();
*/
//ToggleCameraAutoRotation
/*
// WitcherHairstyle
exec function WitcherHairstyle( number : int )
{
	var inv : CInventoryComponent;
	var witcher : W3PlayerWitcher;
	var ids : array<SItemUniqueId>;

	var size : int;
	var i : int;

	witcher = GetWitcherPlayer();
	inv = witcher.GetInventory();

	ids = inv.GetItemsByCategory( 'hair' );
	size = ids.Size();
	
	if( size > 0 )
	{
		
		for( i = 0; i < size; i+=1 )
		{
			inv.RemoveItem(ids[i], 1);	
		}
		
	}
	
	ids.Clear();
	
	if(number == 0)
	{
		ids = inv.AddAnItem('Half With Tail Hairstyle');
	}
	else if(number == 1)
	{
		ids = inv.AddAnItem('Shaved With Tail Hairstyle');
	}
	else if(number == 2)
	{
		ids = inv.AddAnItem('Long Loose Hairstyle');
	}
	else if( number == 3 )
	{
		ids = inv.AddAnItem('Preview Hair');
	}
	
	inv.MountItem(ids[0]);
}



/*
var camera : CCustomCamera;
		
	camera = (CCustomCamera)theCamera.GetTopmostCameraObject();
	if( camera )
	{
		camera.allowAutoRotation = !camera.allowAutoRotation;
	}
*/
	/*
	var max, current : float;

	if(perc <= 0)
		perc = 100;
		
	max = thePlayer.GetStatMax(BCS_Vitality);
	current = thePlayer.GetStat(BCS_Vitality);
	thePlayer.ForceSetStat(BCS_Vitality, MinF(max, current + max * perc / 100));*/

	public function timer250msecond2()
	{
		
	}
	
	var lastGameTime : int;

	var isMeditating : bool;

	var talkCoolDown : int; default talkCoolDown = 0;
	var specialCoolDown : int;
	
	public function timer4second2()
	{
		
	}
	
	
	
	public function onWorldLoaded2()
	{
		
	}



	function registerListeners()
	{
		theInput.RegisterListener(this, 'OnUIForTrainerMenu', 'OpenUIForTrainerMenu');	
		
	}

	function deregisterListeners()
	{
		theInput.UnregisterListener(this, 'OpenUIForTrainerMenu');

	}


}
state Idle in mod_UIForTrainer {
		
        event OnEnterState(prevStateName : name)
        {
            super.OnEnterState(prevStateName);
			//GetWitcherPlayer().DisplayHudMessage("inside  idle state");
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
