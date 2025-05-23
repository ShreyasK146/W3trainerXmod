/*
Copyright © CD Projekt RED & Jamezo97 2017
*/

enum MCM_TpPosition
{
	MCM_TPP_Anywhere,
	MCM_TPP_Behind,
	MCM_TPP_Front,
}

//==================================================================================================================================================================================================================
//====
//====							SCM NPC Companion Controls
//====
//==================================================================================================================================================================================================================

class SCMCompanionControls
{
	var npc : CNewNPC;
	public saved var data : MCMSpawnData;
	var info : mod_scm_SpecialNPC;

	public var specialData : MCM_NPCEntry;
	public var justSpawned : bool;

	public saved var isCombatFriendlyWithPlayer : bool;
	default isCombatFriendlyWithPlayer = false;
	
	public editable var scale : float;

	var followOnFootAI : CAIFollowSideBySideAction;

	public function setNPC(npc : CNewNPC)
	{
		this.npc = npc;
	}
	
	//===============================================================================================================
	//        Horse Mounting
	//===============================================================================================================

	public editable saved var IsOnHorse : bool; default IsOnHorse = false;
	public editable var MountedHorse : CNewNPC;
	
	public var CanUseHorse : bool;
	var followOnHorseDoNothingAI : CAIHorseDoNothingAction;
	var followOnHorseAI : CAIRiderFollowSideBySideAction;
	
	public function CanUseHorse() : bool
	{
		switch(data.nam)
		{
			case 'cirilla':
			case 'yennefer':
			//case 'triss':
                        //case 'shani':
                        //case 'anna_henrietta':
			//case 'avallach':
                        //case 'baron':
			case 'becca':
                        //case 'crach_an_craite':
			//case 'cyprian_willey':
			//case 'damien':
			//case 'dandelion':
			//case 'dettlaff_van_eretein_vampire':
                        //case 'dijkstra':
			//case 'dreamer_corine_tilly':
                        //case 'emhyr':
			//case 'eskel':
			//case 'ewald':
                        //case 'fringilla_vigo':
			//case 'graden':
			//case 'guillaume':
                        //case 'hattori':
                        //case 'hjalmar':
			case 'keira_metz': return true;
			//case 'king_beggar':
			//case 'lambert':
			//case 'letho':
                        //case 'margarita':
			//case 'milton_de_peyrac':
                        //case 'mousesack':
			//case 'mq1058_lynx_witcher':
                        //case 'olgierd':
			//case 'palmerin': 
                        //case 'philippa_eilhart':
                        //case 'pryscilla':
			//case 'q603_circus_artist_companion':
			//case 'q002_huntsman':
			//case 'q603_safecracker_companion':
			//case 'radovid':
			//case 'regis_terzieff_vampire':
                        //case 'rosa_var_attre':
			//case 'sq306_sacha':
			//case 'sq106_tauler':
			//case 'sq701_vivienne':
                        //case 'syanna':
                        //case 'talar':
                        //case 'tamara':
			//case 'udalryk':
                        //case 'vampire_diva':
			//case 'vernon_roche':
                        //case 'ves':
			//case 'vesemir':
			//case 'von_gratz':
			//case 'voorhis':
		}
		return false;
	}
	
	public function GetHorseTag() : name
	{
		if(CanUseHorse)
		{
			switch(data.nam)
			{
			case 'cirilla': return 'ciri_horse';
			case 'yennefer': return 'yennefer_horse';
			//case 'triss': return 'triss_horse';
                        case 'shani': return 'shani_horse';
                        case 'anna_henrietta': return 'anna_henrietta_horse';
			case 'avallach': return 'avallach_horse';
                        case 'baron': return 'baron_horse';
			case 'becca': return 'becca_horse';
			case 'crach_an_craite': return 'crach_an_craite_horse';
			case 'cyprian_willey': return 'cyprian_willey_horse';
                        case 'damien': return 'damien_horse';
			case 'dandelion': return 'dandelion_horse';
			case 'dettlaff_van_eretein_vampire': return 'dettlaff_horse';
                        case 'dijkstra': return 'dijkstra_horse';
			case 'dreamer_corine_tilly': return 'corine_horse';
                        case 'emhyr': return 'emhyr_horse';
			case 'eskel': return 'eskel_horse';
			case 'ewald': return 'ewald_horse';
                        case 'fringilla_vigo': return 'fringilla_horse';
                        case 'graden': return 'graden_horse';
			case 'guillaume': return 'guillaume_horse';
                        case 'hattori': return 'hattori_horse';
                        case 'hjalmar': return 'hjalmar_horse';
                        case 'keira_metz': return 'keira_horse';
			case 'king_beggar': return 'king_beggar_horse';
			case 'lambert': return 'lambert_horse';
			case 'letho': return 'letho_horse';
                        case 'margarita': return 'margarita_horse';
			case 'milton_de_peyrac': return 'milton_de_peyrac_horse';
                        case 'mousesack': return 'mousesack_horse';
			case 'mq1058_lynx_witcher': return 'mq1058_lynx_witcher_horse';
                        case 'olgierd': return 'olgierd_horse';
			case 'palmerin': return 'palmerin_horse';
                        case 'philippa_eilhart': return 'philippa_horse';
                        case 'pryscilla': return 'pryscilla_horse';
			case 'q603_circus_artist_companion': return 'q603_circus_artist_companion_horse';
                        case 'q002_huntsman': return 'q002_huntsman_horse';
			case 'q603_safecracker_companion': return 'q603_safecracker_companion_horse';
			case 'radovid': return 'radovid_horse';
			case 'regis_terzieff_vampire': return 'regis_horse';
                        case 'rosa_var_attre': return 'rosa_var_attre_horse';
			case 'sq306_sacha': return 'sq306_sacha_horse';
			case 'sq106_tauler': return 'sq106_tauler_horse';
			case 'sq701_vivienne': return 'sq701_vivienne_horse';
                        case 'syanna': return 'syanna_horse';
                        case 'talar': return 'talar_horse';
                        case 'tamara': return 'tamara_horse';
			case 'udalryk': return 'udalryk_horse';
                        case 'vampire_diva': return 'vampire_diva_horse';
			case 'vernon_roche': return 'vernon_roche_horse';
			case 'ves': return 'ves_horse';
			case 'vesemir': return 'vesemir_horse';
			case 'von_gratz': return 'von_gratz_horse';
			case 'voorhis': return 'voorhis_horse';
			
			default: return 'generic_horse';
			}
		}
		return '';
	}

	public function MountHorse(mount : bool, optional now : bool)
	{
		if(mount && !IsOnHorse)
		{
			if(npc.GetCurrentStateName() != 'SCMMountHorse')
			{
				npc.GotoState('SCMMountHorse');
			}
		}
		else if(!mount && IsOnHorse)
		{
			if(npc.GetCurrentStateName() == 'SCMMountHorse')
			{
				npc.OnModSCMMountInfo('DismountHorse', 0);
			}
		}
	}
	
	//===============================================================================================================
	//        Boat Mounting
	//===============================================================================================================
	
	public editable saved var IsOnBoat : bool; default IsOnBoat = false;
	public var autoTpToPlayer : bool; default autoTpToPlayer = true;
	var wasOnBoat : bool; default wasOnBoat = false;
	
	public function MountBoat(mount : bool)
	{
		if(mount && !IsOnBoat)
		{
			if(npc.GetCurrentStateName() != 'SCMMountBoat')
			{
				npc.GotoState('SCMMountBoat');
			}
			wasOnBoat = true;
		}
		else if(!mount && IsOnBoat)
		{
			if(npc.GetCurrentStateName() == 'SCMMountBoat')
			{
				npc.OnModSCMMountInfo('DismountBoat', 0);
			}
		}
	}
		
	//===============================================================================================================
	//        ANIMATION & POSING
	//===============================================================================================================
	
	private var Anim : SCMSyncAnimationManager;
	
	public function PlayAnimSimple(animName : name, optional blendIn, blendOut : float, optional animSpeed : float, optional useAnimSpeed : bool)
	{
		var animComp : CMovingPhysicalAgentComponent;
		var settings : SAnimatedComponentSlotAnimationSettings;
		animComp = (CMovingPhysicalAgentComponent)npc.GetComponentByClassName('CMovingPhysicalAgentComponent');
			
		if (animComp)
		{
			if(!useAnimSpeed) animSpeed = 1;
			
			settings.blendIn = blendIn;
			settings.blendOut = blendOut;
			
			animComp.SetAnimationSpeedMultiplier(animSpeed);
			
			animComp.PlaySlotAnimationAsync(animName, 'NPC_ANIM_SLOT', settings);
			animComp.PlaySlotAnimationAsync(animName, 'GAMEPLAY_SLOT', settings);
		}
	}
	
	public function PlayAnim(animName : name, optional repeat : bool, optional startFrom : float)
	{
		if(Anim)
		{
			Anim.PlayAnim(animName, this.npc, , , startFrom);
		
			if(repeat)
			{
				Anim.setAnimSpeed(1);
			}
			else
			{
				Anim.setAnimSpeed(0);
			}
		}
	}
	
	public function PlayAnims2(optional a1 : name, optional a2 : name, optional a3 : name, optional a4 : name, optional a5 : name, optional a6 : name, optional a7 : name, optional a8 : name, optional a9 : name, optional a10 : name)
	{
		var anims : array<name>;
		if(a1) anims.PushBack(a1);
		if(a2) anims.PushBack(a2);
		if(a3) anims.PushBack(a3);
		if(a4) anims.PushBack(a4);
		if(a5) anims.PushBack(a5);
		if(a6) anims.PushBack(a6);
		if(a7) anims.PushBack(a7);
		if(a8) anims.PushBack(a8);
		if(a9) anims.PushBack(a9);
		if(a10) anims.PushBack(a10);
		Anim.setAnimSpeed(1);
		Anim.PlayAnims(anims, this.npc);
	}
	
	public function PlayMimic(mimicName : name)
	{
		this.npc.PlayMimicAnimationAsync(mimicName);
	}
		
	public function animsFinished()
	{
		if(!IsFollowing() && info && info.HasIdleAnimation)
		{
			PlayAnim(info.IdleAnimation, info.IdleAnimationSpeed>0);
		}
	}
	
	private function activateMimics()
	{
		var scene: CStoryScene;
		
		if (npc.IsHuman() && !npc.isDead)
		{
			npc.AddTag('MimicEnable');
			scene = (CStoryScene)LoadResource("dlc/mod_spawn_companions/enablenpcmimics.w2scene", true);
			theGame.GetStorySceneSystem().PlayScene(scene, "enable");
			npc.RemoveTag('MimicEnable');
			//npc.useHiResShadows = true;
		}
	}
	
	//===============================================================================================================
	//        MOVEMENT
	//===============================================================================================================
	
	var currentMoveSpeed : float; default currentMoveSpeed = 0;
	var lastMoveSpeed : float; default lastMoveSpeed = 0;
	
	public function setMoveSpeed(speed : float)
	{
		currentMoveSpeed = speed;
		npc.GetMovingAgentComponent().SetGameplayRelativeMoveSpeed(speed);
		
		if(IsOnHorse && MountedHorse)
		{
			MountedHorse.GetMovingAgentComponent().SetGameplayRelativeMoveSpeed(speed);
		}
	}
	
	public function update4Second()
	{
		var tpMax : int;
		var playerBoat : W3Boat;
	
		//npc.EnableCharacterCollisions(false);
		if(this.IsFollowing())
		{
			if(this.CanUseHorse && this.data.isSpecial)
			{
				if(thePlayer.IsUsingHorse() && !this.IsOnHorse)
				{
					this.MountHorse(true);
				}
				else if(!thePlayer.IsUsingHorse() && this.IsOnHorse)
				{
					this.MountHorse(false);
				}
			}
			
			playerBoat = ((W3Boat)thePlayer.GetUsedVehicle());
			
			if(playerBoat && !this.IsOnBoat)
			{
				this.MountBoat(true);
			}
			else if(!playerBoat && this.IsOnBoat)
			{
				this.MountBoat(false);
			}
			
			if(this.IsOnHorse)
			{
				tpMax = 3600;
			}
			else
			{
				tpMax = 1225;
			}
			
			if (this.autoTpToPlayer && npc.HasTag('mod_scm_IsFollowing') && (VecDistanceSquared(thePlayer.GetWorldPosition(), npc.GetWorldPosition()) >= tpMax || (wasOnBoat && !IsOnBoat))) //45^2
			{
				if(!thePlayer.IsSwimming() && !thePlayer.IsDiving() && !thePlayer.IsSailing() && !thePlayer.IsOnBoat())
				{
					if (thePlayer.IsOnGround() && !((CActor)npc).IsInCombat())
					{
						wasOnBoat = false;
						this.tpToPlayer(MCM_TPP_Behind);
						
						//RemoveFollowingAI(npcname);
						//AddFollowingAI(npcname);
					}
				}
			}
		}
		
		/*if(npc.IsImmortal() == data.mortal)
		{
			LogSCM("Forcing Mortality/Immortality " + data.mortal);
			setMortality(data.mortal);
		}*/
		
		if(npc.GetCurrentStateName() == 'NewIdle')
		{
			npc.EnableCharacterCollisions(false);
		}
	}
	
	public function Say(text : int, time : float)
	{
		var chatElement : mod_scm_NPCChatElement;
		
		chatElement = new mod_scm_NPCChatElement in npc;
		chatElement.entSpecialID = this.data.nam;
		chatElement.talkingID = text;
		chatElement.talkingString = GetLocStringById(text);
		chatElement.time = time;

		MCM_GetMCM().DialogueManager.AddChat(chatElement);
	}
	
	public function UpdateQuick()
	{
		if(this.IsFollowing()) updateSpeed();
		if(isCombatFriendlyWithPlayer) updateFriendlyCombat();
		//if(isMountedOnBoat) DismountBoatIfStoppedUsing();
	}
	
	editable var PlayerDisablesSpeed : bool; default PlayerDisablesSpeed = false;
	
	public function updateSpeed()
	{
		var distance, movespeed : float;
		var deltaPos : Vector;
		var playerVelocityVector : Vector;
		var distanceInfront : float;
		var playerSpeed : float;		
		var tmp : float;
		
		playerSpeed = thePlayer.GetMovingAgentComponent().GetSpeed();

		if(wasOnBoat || npc.IsInCombat() || !npc.HasTag('mod_scm_IsFollowing') || PlayerDisablesSpeed || npc.IsInInterior())
		{
			movespeed = 0.0;
		}
		else
		{
			deltaPos = npc.GetWorldPosition() - thePlayer.GetWorldPosition();

			playerVelocityVector = thePlayer.GetMovingAgentComponent().GetVelocity();
			
			distanceInfront = VecDot2D(deltaPos, VecNormalize(playerVelocityVector)) + 2.4;
			
			distance = VecLengthSquared(deltaPos);
			
			npc.SetOriginalInteractionPriority(IP_Prio_12);
			npc.RestoreOriginalInteractionPriority();
			
			movespeed = playerSpeed/2.0;
		
			if(movespeed > 0.5)
			{
				tmp = ExpF(-distanceInfront)-1;
				
				if(tmp > 10) tmp = 10;
				if(tmp < -10) tmp = -10;
				
				movespeed += tmp;
			}
			else
			{
				if(IsOnHorse)
				{
					if(distance < 81)
					{
						movespeed = 0;
					}
					else
					{
						movespeed += MinF((distance-81) / 225, 1.0) * 8.0;
					}
				}
				else
				{
					if(distance < 25)
					{
						movespeed = 0;
					}
					else
					{
						movespeed += MinF((distance-25) / 81, 1.0) * 8.0;
					}
				}
			}
			
			if(movespeed < 0) movespeed = 0;
		}
		
		lastMoveSpeed = movespeed;
		setMoveSpeed(((lastMoveSpeed + movespeed)/2.0) / this.data.scale);
	}
	
	//===============================================================================================================
	//      INITIALIZATION
	//===============================================================================================================

	private function setCombatActive(active : bool)
	{
		if(active)
		{
			npc.SetTemporaryAttitudeGroup('player', AGP_Default);
		}
		else
		{
			npc.SetTemporaryAttitudeGroup('neutral_to_player', AGP_Default);
		}
	}

	private function initCommon()
	{
		if(data.isSpecial)
		{
			//info = MCM_GetMCM().specialNPCInfos.getNPCInfo(data.nam);
			specialData = MCM_GetMCM().NPCManager.GetNpcEntry(data.nam);
		}
	
		npc.ApplyAppearance(data.appearance);
		
		npc.SetLevel(data.level);
		
		if(!npc.HasAbility('Ciri_CombatRegen')) npc.AddAbility('Ciri_CombatRegen', true);
		if(!npc.HasAbility('_canBeFollower')) npc.AddAbility('_canBeFollower', true); 
		
		npc.SetNPCType(ENGT_Quest);
		
		if(this.data.scale < 0.0001)
		{
			this.data.scale = 1;
		}
		if(this.data.scale != 1)
		{
			MCM_GetMCM().ScaleManager.SetScale(this.npc, this.data.scale);
		}
		
		npc.SetAttitude(thePlayer, AIA_Friendly);
		setCombatActive(false);

		((CActor)npc).GetComponent('talk').SetEnabled(true);
		
		npc.RemoveTag('no_talk');
		npc.DisableTalking(false, false);
		npc.DisableTalking(false, true);
		
		npc.EnableCharacterCollisions(false);
		
		npc.SetOriginalInteractionPriority(IP_Prio_1);
		npc.RestoreOriginalInteractionPriority();
		
		setMortality(data.mortal);

		LogChannel('ModSpawnCompanions', "Setting up NPC");
		
		initSpecialDialogue();
		
		if(npc.HasTag('mod_scm_IsFollowing'))
		{
			StartFollowing();
		}

		if(specialData)
		{
			activateMimics();
		}

		InitAbilities();
		InitAI();
		SetupBaseAI();
		
		npc.GotoState('NewIdle', false);
		IsOnBoat = false; IsOnHorse = false;
		MountedHorse = NULL; wasOnBoat = false;
		
		update4Second();
	}

	//CAINpcOneHandedCombat
	//CAINpcDefaults
	private function InitAI()
	{
		var followerMovingagent : CMovingAgentComponent;
		
		followerMovingagent = npc.GetMovingAgentComponent();
		followerMovingagent.SetGameplayRelativeMoveSpeed(0.0f);
		followerMovingagent.SetDirectionChangeRate(0.16);
		followerMovingagent.SetMaxMoveRotationPerSec(60);
		
		followOnFootAI = new CAIFollowSideBySideAction in npc;
		followOnFootAI.OnCreated();
	
		followOnFootAI.params.targetTag = 'PLAYER';
		followOnFootAI.params.moveSpeed = 6;
		followOnFootAI.params.teleportToCatchup = true;
		
		CanUseHorse = CanUseHorse();
		if(CanUseHorse)
		{
			followOnHorseAI = new CAIRiderFollowSideBySideAction in npc;
			followOnHorseAI.OnCreated();
			
			followOnHorseAI.params.followDistance = 6.0;
			followOnHorseAI.params.matchRiderMountStatus = false;
			
			followOnHorseAI.params.targetTag = 'PLAYER';
			followOnHorseAI.params.moveSpeed = 6;
			
			followOnHorseDoNothingAI = new CAIHorseDoNothingAction in npc;
			followOnHorseDoNothingAI.OnCreated();
		}
	}

	private function CanRemoveAbility(nam : name) : bool
	{
		switch(nam)
		{
			//[All Must Have]
			case '_canBeFollower':
			case 'Ciri_CombatRegen':
			case 'all_NPC_ability':
			case 'difficulty_CommonHard':
			case 'ConDefault':
			case 'ablParryHeavyAttacks':
			case 'ablComboAttacks':
			case 'IsNotScaredOfMonsters': 

			//[NPC Specific]
			case 'SkillCiri': 
			case 'SkillSorceress': 
			case 'ablTeleport': 
			case 'SkillWitcher': 
			case 'ablSignAttacks': return false;
		}
		return true;
	}

	private function addAbility(nam : name)
	{
		if(!npc.HasAbility(nam)) npc.AddAbility(nam, true); 
	}

	private function InitAbilities()
	{
		var abls : array<name>;
		var i : int;

		addAbility('_canBeFollower');
		addAbility('Ciri_CombatRegen');
		addAbility('all_NPC_ability');
		addAbility('difficulty_CommonHard');
		addAbility('ConDefault');
		addAbility('ablParryHeavyAttacks');
		addAbility('ablComboAttacks');
		addAbility('IsNotScaredOfMonsters'); 

		//TODO, use npc.GetCharacterStats.GetAbilities()
		//if(!npc.HasAbility('SkillBoss') && !npc.HasAbility('SkillWitcher') && !npc.HasAbility('SkillCiri') && !npc.HasAbility('SkillSorceress')) npc.AddAbility('SkillBoss', true); 
		//if(!npc.HasAbility('ablComboAttacks')) npc.AddAbility('ablComboAttacks', true); 
		//if(!npc.HasAbility('ablPrioritizeAvoidingHeavyAttacks')) npc.AddAbility('ablPrioritizeAvoidingHeavyAttacks', true); 
		//if(!npc.HasAbility('ablCounterHeavyAttacks')) npc.AddAbility('ablCounterHeavyAttacks', true); 
		//if(!npc.HasAbility('BurnIgnore')) npc.AddAbility('BurnIgnore', true); 
		//if(!npc.HasAbility('ablParryHeavyAttacks')) npc.AddAbility('ablParryHeavyAttacks', true); 
		//if(!npc.HasAbility('IsNotScaredOfMonsters')) npc.AddAbility('IsNotScaredOfMonsters', true); 
		
		//if(!npc.HasAbility('ablTeleport')) npc.AddAbility('ablTeleport', true); 
		//if(!npc.HasAbility('DisableFinishers')) npc.AddAbility('DisableFinishers', true); 

		//npc.RemoveAbilityAll('NPCDoNotGainBoost');
		
		//npc.RemoveAbilityAll('SkillElite');
		//npc.RemoveAbilityAll('SkillOfficer');
		//npc.RemoveAbilityAll('SkillMercenary');
		//npc.RemoveAbilityAll('SkillGuard');
		//npc.RemoveAbilityAll('SkillSoldier');
		//npc.RemoveAbilityAll('SkillBrigand');
		//npc.RemoveAbilityAll('SkillThug');
		//npc.RemoveAbilityAll('SkillPeasant');
		//npc.RemoveAbilityAll('Commoner');
		//npc.RemoveAbilityAll('BurnIgnore');
		//npc.RemoveAbilityAll('ConDefault');
		//npc.RemoveAbilityAll('DisableFinishers');
		
		//npc.RemoveAbilityAll('NPCLevelBonusDeadly');
		//npc.RemoveAbilityAll('VesemirDamage');
		//npc.RemoveAbilityAll('_q403Follower');

		//abls.Clear();
		//npc.GetCharacterStats().GetAbilities(abls);
		//LogSCM(this.data.niceName + " post abilities start");
		//for(i = 0; i < abls.Size(); i+=1)
		//{
		// 	LogSCM(abls[i]);
		//}
		//LogSCM(this.data.niceName + " post abilities end");
	}
	
	public function setMortality(mortal : bool)
	{
		this.data.mortal = mortal;

		if(mortal)
		{	
			npc.immortalityFlags = 50331648; //(AIC_Combat * 16777216) | (AIC_Default * 16777216);
			//npc.SetImmortalityMode(AIM_None, AIC_Default, true);
			//npc.SetImmortalityMode(AIM_None, AIC_Combat, true);
			//npc.SetImmortalityMode(AIM_None, AIC_Fistfight, true);
			//npc.SetImmortalityMode(AIM_None, AIC_IsAttackableByPlayer, true);
			npc.RemoveTag('vip');
		}
		else
		{
			npc.immortalityFlags = 50331904; //256 | (AIC_Combat * 16777216) | (AIC_Default * 16777216);
			if(!npc.HasAbility('ConImmortal')) npc.AddAbility('ConImmortal', true);
			//npc.SetImmortalityMode(AIM_Immortal, AIC_Default, true);
			//LogSCM("FlagsB: " + npc.immortalityFlags);
			//npc.SetImmortalityMode(AIM_Immortal, AIC_Combat, true);
			//LogSCM("FlagsC: " + npc.immortalityFlags);
			//npc.SetImmortalityMode(AIM_Immortal, AIC_Fistfight, true);
			//LogSCM("FlagsD: " + npc.immortalityFlags);
			//npc.SetImmortalityMode(AIM_Immortal, AIC_IsAttackableByPlayer, true);
			//LogSCM("FlagsE: " + npc.immortalityFlags);
			//LogSCM("PureFlags: " + npc.GetPureImmortalityFlags());
			//LogSCM("Flags: " + npc.immortalityFlags);
			npc.AddTag('vip');
		}
	}

	public function initFirstSpawned(nam : name, optional niceName : name, optional appearance : name, optional level : int, optional mortal : bool, optional isSpecial : bool)
	{
		this.data = new MCMSpawnData in this;

		this.data.nam = nam;
		this.data.niceName = niceName;
		this.data.appearance = appearance;
		this.data.level = level;
		this.data.mortal = mortal;
		this.data.isSpecial = isSpecial;
		
		npc.ForceSetStat(BCS_Vitality, thePlayer.GetStatMax(BCS_Vitality));
		npc.SetHealthPerc(100);
		
		initCommon();
	}
	
	public function onFirstSpawned(spawnData : MCMSpawnData)
	{
		this.data = new MCMSpawnData in this;
		this.data.copyFrom(spawnData);
		this.onSpawned();
	}

	public function onSpawned()
	{
		initCommon();
	}
	
	public function PostSpawnedInit()
	{
		update4Second();
	}

	//===============================================================================================================
	//        COMBAT
	//===============================================================================================================
	
	public function getAdditionalDamagePoints(vitalityDamage : float, essenceDamange : float) : float
	{
		var shouldBeAtLeast, addVit, addEss, add : float;
		shouldBeAtLeast = data.level * 16;
		
		addVit = shouldBeAtLeast - vitalityDamage;
		addEss = shouldBeAtLeast - essenceDamange;
		
		add = data.level * 5;
		
		if(addVit > add) add = addVit;
		if(addEss > add) add = addEss;
		
		return add;
	}
	
	public function onKilledEntity(entity : CNewNPC, exp : int)
	{
		mod_scm_GetSCM().addKilledEXP(exp);
	}
	
	public function CountNearbyHostiles(radius : float, maxEnemiesNo : int) : int
	{
		var lst : array<CActor>;

		lst = npc.GetNPCsAndPlayersInRange(radius, maxEnemiesNo, '', FLAG_Attitude_Hostile + FLAG_OnlyAliveActors + FLAG_ExcludeTarget);
		
		return lst.Size();
	}
	
	//===============================================================================================================
	//        Friendly Combat
	//===============================================================================================================
	
	var geraltCommentDelay : int;
	default geraltCommentDelay = 30;
	
	private function updateFriendlyCombat()
	{
		if(FriendlyCombatSwordDrawDelay > 0)
		{
			FriendlyCombatSwordDrawDelay-=1;
		}
		else
		{
			if(thePlayer.GetCurrentMeleeWeaponType() != PW_Steel && thePlayer.GetCurrentMeleeWeaponType() != PW_Silver)
			{
				LogSCM("EXITING FRIENDLY COMBAT");
			
				EnterFriendlyCombat(false);
			}
			else
			{
				LogSCM("CommentDelay " + geraltCommentDelay);
				if(geraltCommentDelay > 0)
				{
					geraltCommentDelay-=1;
				}
				else if(RandRange(15, 0) == 5)
				{
					switch(RandRange(12, 0))
					{
					case 0: mod_scm_PlayerSay(546852, 0.0); break; //Wrong.
					case 1: mod_scm_PlayerSay(546856, 0.0); break; //Wrong. Footwork!
					case 2: mod_scm_PlayerSay(577749, 0.0); break; //Position, Ciri! Footwork! Remember!
					case 3: mod_scm_PlayerSay(425145, 0.0); break; //Careful…!
					case 4: mod_scm_PlayerSay(580943, 1.7); this.Say(1063571, 0.0); break; //Ciri, stop fooling around. //Hahaha, come and get me!
					case 5: mod_scm_PlayerSay(577548, 0.0); break; //Careful now.
					case 6: mod_scm_PlayerSay(1128842, 0.0); break; //Whoooaaaa! Slow down!
					case 7: this.Say(548151, 0.0); break; //Oh, you're in for it now!
					case 8: this.Say(484134, 0.0); break; //Hey!
					case 9: this.Say(548150, 0.0); break; //Hey, that's cheating!
					case 10: this.Say(584098, 0.0); break; //Heeey!
					case 11: this.Say(584101, 0.0); break; //You'll regret that!
					}
				
					geraltCommentDelay = 40;
				}
			}
		}
	}
	
	//===============================================================================================================
	//        Specialized Combat Functions
	//===============================================================================================================
	
	private function goToIdleState() : bool
	{
		if(npc.IsInState('NewIdle')) return true;
	
		if(!npc.IsInState('NewIdle') && npc.HasTag('mod_scm_specialCiriDone'))
		{
			npc.GotoState('NewIdle', false);
			return true;
		}
		return false;
	}
	
	private var queueAttack : bool;
	default queueAttack = false;
	
	public function PeformSpecialAttackAction() : bool
	{
		if(queueAttack)
		{
			queueAttack = false;
			return true;
		}
		return false;
	}
	
	private function EnterStateIfCan(stateName : name) : bool
	{
		((CR4Hud)theGame.GetHud()).HideOneliner(this.npc);
	
		if(npc.IsInState(stateName))
		{
			return true;
		}
		else if(npc.IsInState('NewIdle') || npc.HasTag('mod_scm_specialCiriDone'))
		{
			LogChannel('ModSpawnCompanions', "Entering " + NameToString(stateName) + " from " + npc.GetCurrentStateName());
			npc.GotoState(stateName);
			return true;
		}
		return false;
	}
	
	public editable var specialCountdown : int;
	
	public function doSpecialCombat() : int
	{
		if(npc.GetTarget() == thePlayer)
		{
			return 0;
		}
	
		LogChannel('ModSpawnCompanions', "Special Combat: " + NameToString(this.data.nam) + "???");
	
		if(this.data.nam == 'cirilla')
		{
			if(RandRange(100, 0) < 40)
			{
				doCiriBlink();
				return 5;
			}
			else
			{
				doCiriDash();
				return 3;
			}
		}
		else if(this.data.nam == 'triss')
		{
			if(doMeteor('ciri_meteor'))
			{
				return 10;
			}
			return 0;
		}
		return 0;
	}
	
	public function doCiriBlink()
	{
		if(EnterStateIfCan('SCMCiriBlink'))
		{
			npc.RemoveTag('mod_scm_specialCiriDone');
			
			npc.OnModSCMDoSpecialAttack('Blink');
		}
	}
		
	public function doCiriDash()
	{
		if(EnterStateIfCan('SCMCiriDash'))
		{
			npc.RemoveTag('mod_scm_specialCiriDone');
			
			npc.OnModSCMDoSpecialAttack('Dash');
		}
	}
	
	private function getMeteorTarget() : CActor
	{
		var targets : array<CActor>;
		var target : CActor;
		var i, sz : int;
		var avgPosition : Vector;
		var deltaDist, closestDeltaDist : float;
		
		targets = npc.GetNPCsAndPlayersInRange(30, 40, '', FLAG_Attitude_Hostile + FLAG_OnlyAliveActors);
		
		for (i = targets.Size()-1 ; i >= 0 ; i-=1)
		{
			if (!targets[i].GetGameplayVisibility())
			{
				targets.Erase(i);
			}
		}
		
		if(targets.Size() > 0)
		{
			sz = targets.Size();
			
			for (i = sz-1 ; i >= 0 ; i-=1)
			{
				avgPosition += targets[i].GetWorldPosition();
			}
			avgPosition /= Vector(sz, sz, sz);
			
			
			closestDeltaDist = 1600; //40*40, max distance
			
			for (i = sz-1 ; i >= 0 ; i-=1)
			{
				deltaDist = VecLengthSquared(targets[i].GetWorldPosition() - avgPosition);
				if(deltaDist < closestDeltaDist)
				{
					target = targets[i];
					closestDeltaDist = deltaDist;
				}
			}
			return target;
		}
		return NULL;
	}
	
	private function createMeteor(meteorEntityTemplate : CEntityTemplate, optional target : CActor) : W3MeteorProjectile
	{
		var userPosition : Vector;
		var meteorPosition : Vector;
		var userRotation : EulerAngles;
		var meteorEntity : W3MeteorProjectile;
	
		userPosition = npc.GetWorldPosition();
		userRotation = npc.GetWorldRotation();
		
		meteorPosition = userPosition;
		meteorPosition.X += RandRange(5, -5);
		meteorPosition.Y += RandRange(5, -5);
		meteorPosition.Z += RandRange(70, 40);
		
		meteorEntity = (W3MeteorProjectile)theGame.CreateEntity(meteorEntityTemplate, meteorPosition, userRotation);
		
		meteorEntity.Init(NULL);
		meteorEntity.decreasePlayerDmgBy = 1; //0.9999;
		meteorEntity.explosionRadius = 6;
		
		meteorEntity.projDMG = Clamp(data.level*40, 100, 4000);
		
		LogChannel('ModSpawnCompanions', "Projectile Damage: " + meteorEntity.projDMG);
		
		return meteorEntity;
	}
	
	public function doMeteor(entName : name, optional targetMeInstead : bool) : bool
	{		
		var collisionGroups : array<name>;
		var companions : array<CNewNPC>;
		var meteorEntityTemplate : CEntityTemplate;
		var combatTarget : CActor;
		var meteorEntity :  W3MeteorProjectile;
		var i, j : int;
		var success : bool;
		
		if(thePlayer.IsInInterior() || npc.IsInInterior())
		{
			return false;
		}
				
		if(!targetMeInstead) combatTarget = getMeteorTarget();
		
		if(combatTarget || targetMeInstead)
		{
			meteorEntityTemplate = (CEntityTemplate)LoadResource(entName); //'meteor_strong'); //'ciri_meteor');
			collisionGroups.PushBack('Terrain');
			collisionGroups.PushBack('Static');
			
			theGame.GetNPCsByTag('GeraltsBFF', companions);
			
			for(i = RandRange(4, 1); i >= 0; i-=1)
			{
				if(combatTarget || targetMeInstead)
				{
					meteorEntity = createMeteor(meteorEntityTemplate, combatTarget);
					
					if(meteorEntity)
					{
						if(targetMeInstead)
						{
							meteorEntity.ShootProjectileAtPosition(meteorEntity.projAngle, meteorEntity.projSpeed, npc.GetWorldPosition() + Vector(RandRange(-10, 10)/40.0, RandRange(-10, 10)/40.0, 0), 500, collisionGroups);	
							success = true;
						}
						else
						{	
							meteorEntity.ShootProjectileAtPosition(meteorEntity.projAngle, meteorEntity.projSpeed, combatTarget.GetWorldPosition() + Vector(RandRange(-100, 100)/40.0, RandRange(-100, 100)/40.0, 0), 500, collisionGroups);	
							success = true;
						}
						
							//meteorEntity.AddColidedEntity(npc);

						for(j = companions.Size()-1; j>=0; j-=1)
						{
							//LogChannel('ModSpawnCompanions', "ADDING COMPANION " + companions[j]);
							meteorEntity.AddColidedEntity(companions[j]);
						}
						
						meteorEntity.AddColidedEntity(thePlayer);
					}
				}
				else
				{
					break;
				}
				
				if(i > 0 && !targetMeInstead) combatTarget = getMeteorTarget();
			}
		}
		return success;
	}

	//===============================================================================================================
	//        FOLLOWING
	//===============================================================================================================

	private saved var followingAICode : int; default followingAICode = 0;
	private saved var followingAICodeHorse : int; default followingAICodeHorse = 0;
	
	private saved var isFollowing : bool; default isFollowing = false;
	
	private function VecRingRandBehindCam(min : float, max : float) : Vector
	{
		var pos, delta, camDir : Vector;
		var dot : float;
		pos = VecRingRand(min, max);
		camDir = theCamera.GetCameraDirection();
		dot = VecDot2D(pos, camDir);
		
		if(dot > -0.2)
		{
			if(dot > 0)
			{
				pos.X *= -camDir.X;
				pos.Y *= -camDir.Y;
				pos.Z *= -camDir.Z;
			}
			pos -= theCamera.GetCameraDirection();
		}
		
		return pos;
	}

	private function VecRingRandFrontCam(min : float, max : float) : Vector
	{
		var heading, radius : float;
		heading = VecHeading(theCamera.GetCameraDirection());
		heading += RandRangeF(70, -70);
		radius = RandRangeF(max, min);

		return VecFromHeading(heading) * radius;
	}
		
	public function PlayTPAnimation(optional dontPlayAnim : bool)
	{
		if(!dontPlayAnim)
		{
			if(npc.scmcc.data.nam == 'cirilla')
			{
				npc.PlayEffect('appear_cutscene');
				PlayAnimSimple('woman_ciri_teleport_to_idle');
			}
 			else if(npc.scmcc.data.nam == 'baron')
			{
				npc.PlayEffect('blood_spill');
				PlayAnim('dialogue_jump_idle', true, 1.0);
			} 
			else
			{
				npc.PlayEffect('teleport_in');
				PlayAnimSimple('dialogue_ex_jump_land_damage_stop');
			}
		}
	}
		
	public function tpToPlayer(optional behind : MCM_TpPosition)
	{
		var pos : Vector;
		var min : float = 1;
		var max : float = 3;

		if(IsOnHorse) {min = 3; max = 5;}
		
		if(behind == MCM_TPP_Front)
		{
			pos = thePlayer.GetWorldPosition() + VecRingRandFrontCam(min, max);
		} 
		else if(behind == MCM_TPP_Behind)
		{
			pos = thePlayer.GetWorldPosition() + VecRingRandBehindCam(min, max);
		}
		else
		{
			pos = thePlayer.GetWorldPosition() + VecRingRand(min, max);
		}
		
		if(!IsOnHorse && thePlayer.GetMovingAgentComponent().GetSpeed() < 0.75) PlayTPAnimation();
		this.npc.Teleport(pos);
	}
	
	public function StopFollowing(optional dontModifyPlayersList : bool)
	{
		if(followingAICode != 0)
		{
			LogSCM("Cancelling " + followingAICode);
			npc.CancelAIBehavior(followingAICode);
			followingAICode = 0;
			
			npc.RemoveTag('mod_scm_IsFollowing');
			if(!dontModifyPlayersList)
			{
				thePlayer.MODSCM_COMPANIONS.RemoveCompanion(this.data);
			}
		}
		
		if(followingAICodeHorse != 0)
		{
			if(MountedHorse) MountedHorse.CancelAIBehavior(followingAICodeHorse);
			followingAICodeHorse = 0;
		}
		
		isFollowing = false;
		setCombatActive(false);
	}

	public function snowball()
	{
		var l_aiTree : CAICiriSnowballFightActionTree;
		
		l_aiTree = new CAICiriSnowballFightActionTree in this.npc;
		l_aiTree.OnCreated();
		
		this.npc.ForceAIBehavior(l_aiTree, BTAP_AboveCombat);
	}

	public function StartFollowing(optional dontModifyPlayersList : bool)
	{
		if(npc.GetCurrentStateName() == 'SCMPlayIdleAnim')
		{
			npc.PopState(true);
		}
	
		if(followingAICode != 0 || followingAICodeHorse != 0)
		{
			StopFollowing(dontModifyPlayersList);
		}
	
		if(followingAICode == 0)
		{
			if(IsOnHorse)
			{
				//followingAICode = npc.ForceAIBehavior(followOnHorseDoNothingAI, BTAP_Emergency, 'AI_Rider_Load_Forced');
				followingAICodeHorse = MountedHorse.ForceAIBehavior(followOnHorseAI, BTAP_Emergency); //, 'AI_Rider_Load_Forced');
			}
			else
			{
				followingAICode = npc.ForceAIBehavior(followOnFootAI, BTAP_Emergency);
			}
				
			if (followingAICode) updateSpeed();
			if(!npc.HasTag('mod_scm_IsFollowing')) npc.AddTag('mod_scm_IsFollowing');
			if(!dontModifyPlayersList) thePlayer.MODSCM_COMPANIONS.AddCompanion(this.data);
			LogSCM("Started following and made code " + followingAICode);
			isFollowing = true;
		}
		setCombatActive(true);
	}
	
	public function IsFollowing() : bool
	{
		return this.isFollowing;
	}
	
	//===============================================================================================================
	//        TALKING
	//===============================================================================================================
	
	saved var hasCustomDialog : bool;
	saved var customDialog : string;
	saved var customDialogInput : string;
	
	private function initSpecialDialogue()
	{
		if(data.isSpecial)
		{
			if(specialData && StrLen(specialData.customDialogue) > 0)
			{
				hasCustomDialog = true;
				customDialog = specialData.customDialogue;
				customDialogInput = "Input";
			}
			else
			{
				hasCustomDialog = true;
				customDialogInput = "mod_scm_TOGGLE_FOLLOWING";
			}
		}
	}
	
	public function CanStartTalk() : bool
	{
		return true;
	}
	
	private function sayHiToGeralt()
	{
		npc.PlayVoiceset(100, "greeting_geralt");
		npc.EnableDynamicLookAt(thePlayer, 5);
		npc.wasInTalkInteraction = true;
		npc.AddTimer('ResetTalkInteractionFlag', 1.0, true, , , true);
	}

	public function ToggleFollowing()
	{
		var startFollowing : bool;
		
		if(!data.isSpecial) return;
		
		startFollowing = !(IsFollowing());
	
		LogChannel('ModSpawnCompanions', "Toggling " + NameToString(data.nam) + " " + startFollowing);
		
		if(startFollowing)
		{
			npc.AddTag('mod_scm_IsFollowing');
			this.StartFollowing();
			thePlayer.DisplayHudMessage(data.niceName + " is following you");
		}
		else
		{
			npc.RemoveTag('mod_scm_IsFollowing');
			this.StopFollowing();
			thePlayer.DisplayHudMessage(data.niceName + " is no longer following you");
		}
	}
	
	var doNoInteraction : bool; default doNoInteraction = false;
	var myInteractionFlag : bool; default myInteractionFlag = false;
	var wasInDialogue : bool;
	
	private function disableInteractionFor(time : float)
	{
		myInteractionFlag = true;
		npc.AddTimer('mod_scm_reset_interaction', time, false);
	}
	
	public function RefreshMimics()
	{
		if(wasInDialogue)
		{
			activateMimics();
			npc.EnableCharacterCollisions(false);
		}
	}
	
	private function prepareMimicsForReinit()
	{
		wasInDialogue = true;
		mod_scm_GetSCM().RefreshMimicsNextStateChange();
	}
	
	public function resetInteractionFlag()
	{
		myInteractionFlag = false;
	}

	function checkAndRespondIfSleeping(worker : MCM_Worker) : bool
	{
		if(worker)
		{
			if(worker.IsInState('Working') && worker.currentAction)
			{
				if(worker.currentAction.action.actionCategory == 'sleep')
				{
					switch(this.data.nam)
					{
						case 'cirilla': this.npc.PlayLine(581716, false); break; //Geralt, please. Not now.
						case 'yennefer': this.npc.PlayLine(373572, false); break; //Geralt?
						case 'triss': this.npc.PlayLine(456753, false); break; //No.
						default: thePlayer.DisplayHudMessage(this.data.niceName + " is sleeping"); break;
					}
					return true;
				}
			}
		}

		return false;
	}
	
	public function OnPlayerInteract() : bool
	{
		var scene : CStoryScene;
		var sensesEnabled : bool;
		var customScene : bool;
		var worker : MCM_Worker;
		
		LogSCM("NPC State " + this.npc.GetCurrentStateName());

		if(myInteractionFlag) return true;

		worker = MCM_GetMCM().JobManager.getWorker(this.npc);

		//if(checkAndRespondIfSleeping(worker)) return true;
		
		if(Anim) Anim.stopAllAnims();
		if(npc.GetCurrentStateName() == 'SCMPlayIdleAnim')
		{
			npc.PopState(true);
		}
		
		sensesEnabled = theGame.IsFocusModeActive();
		customScene = customDialogInput != "greeting_geralt" && customDialogInput != "mod_scm_TOGGLE_FOLLOWING";
		npc.EnableCharacterCollisions(false);
		
		if(hasCustomDialog && (!sensesEnabled || customScene))
		{
			LogChannel('ModSpawnCompanions', "Overriding Interaction, starting dialog: " + customDialog + ", " +  customDialogInput);
			
			if(customDialogInput == "greeting_geralt")
			{
				sayHiToGeralt();
			}
			else if(customDialogInput == "mod_scm_TOGGLE_FOLLOWING")
			{
				this.sayHiToGeralt();
				this.ToggleFollowing();
				if(worker)
				{
					worker.softStop();
				}
			}
			else
			{
				scene = (CStoryScene)LoadResource(customDialog, true);
				
				if(scene)
				{
					if(this.IsFollowing())
					{
						FactsSet('mod_scm_fact_following', 1, -1);
					}
					else
					{
						FactsSet('mod_scm_fact_following', 0, -1);
					}
					
					if(worker)
					{
						worker.forceStop();
					}
					
					prepareMimicsForReinit();
					mod_scm_GetSCM().NaughtyManager.PreDialogue(npc);
					theGame.GetStorySceneSystem().PlayScene(scene, customDialogInput);
				}
				else
				{
					sayHiToGeralt();
					if(data.isSpecial)
					{
						this.ToggleFollowing();
					}
				}
			}
			disableInteractionFor(0.5);
			return true;
		}
		else if(doNoInteraction)
		{
			//disableInteractionFor(0.5);
			return false;
		}
		return false;
	}
	
	private var FriendlyCombatSwordDrawDelay : int;
	
	public function EnterFriendlyCombat(doEnter : bool)
	{
		isCombatFriendlyWithPlayer = doEnter;
		setHostile(doEnter);
		FriendlyCombatSwordDrawDelay = 8;
		geraltCommentDelay = 10;
		
		if(doEnter)
		{
			if(!npc.HasAbility('SkillWitcher') && !npc.HasAbility('SkillCiri'))
			{
				thePlayer.BlockAction(EIAB_Signs, 'friendly_combat');
				thePlayer.BlockAction(EIAB_RadialMenu, 'friendly_combat');
			}
		
			thePlayer.BlockAction(EIAB_ThrowBomb, 'friendly_combat');
			thePlayer.BlockAction(EIAB_Crossbow, 'friendly_combat');
			thePlayer.BlockAction(EIAB_QuickSlots, 'friendly_combat');
			
			npc.ForceSetStat(BCS_Vitality, thePlayer.GetStatMax(BCS_Vitality));
			npc.ForceSetStat(BCS_Stamina, thePlayer.GetStatMax(BCS_Stamina));
			
			npc.SetParryEnabled(true);
			npc.EnableCounterParryFor(60);
			npc.SetGuarded(true);
			
			npc.EnableCharacterCollisions(true);
		}
		else
		{
			thePlayer.UnblockAction(EIAB_Signs, 'friendly_combat');
			thePlayer.UnblockAction(EIAB_ThrowBomb, 'friendly_combat');
			thePlayer.UnblockAction(EIAB_Crossbow, 'friendly_combat');
			thePlayer.UnblockAction(EIAB_QuickSlots, 'friendly_combat');
			thePlayer.UnblockAction(EIAB_RadialMenu, 'friendly_combat');
		
			npc.EnableCharacterCollisions(false);
		}
	}
	
	public function endFriendlyCombat(wonBattle : bool)
	{
		if(wonBattle)
		{
			if(data.nam == 'cirilla')
			{
				GetWitcherPlayer().DisplayHudMessage("Ciri Won");
				
				Say(548186, 5.8); //Ha-ha! Geralt of Rivia, defeated! Need to work on those dodges.
				mod_scm_PlayerSay(549111, 0.0); //Sure I didn't let you win?
			}
			
			mod_scm_PlayPlayerAnim('man_ger_sword_heavyhit_front_rp');
			EnterFriendlyCombat(false);
		}
		else
		{
			GetWitcherPlayer().DisplayHudMessage("Geralt Won");
			if(data.nam == 'cirilla')
			{
				mod_scm_PlayerSay(558797, 1.4); //Can still beat you.
				Say(558799, 0.0); //I let you win.
			}
			
			npc.RemoveAllBuffsOfType(EET_Poison);
			npc.RemoveAllBuffsOfType(EET_Burning);
			npc.RemoveAllBuffsOfType(EET_Frozen);
			npc.RemoveAllBuffsOfType(EET_Bleeding);
			
			npc.AddTimer('EnterFriendlyCombatFalse2', 0.1);
			npc.AddTimer('EnterFriendlyCombatFalse', 0.5);
		}
	}
		
	function setHostile(hostile : bool)
	{
		if(hostile)
		{
			npc.SetAttitude(thePlayer, AIA_Hostile);
			//npc.SetTemporaryAttitudeGroup('sq107_nekkers', AGP_Default);
		}
		else
		{
			npc.SetAttitude(thePlayer, AIA_Friendly);
			npc.SetTemporaryAttitudeGroup('player', AGP_Default);
		}
	}

	public function applyNakedAppearance()
	{
		if(this.specialData) this.npc.ApplyAppearance(this.specialData.nakedAppearance);
	}

	public function applyUnderwearAppearance()
	{
		if(this.specialData) this.npc.ApplyAppearance(this.specialData.underwearAppearance);
	}

	public function applyNormalAppearance()
	{
		if(this.specialData) this.npc.ApplyAppearance(this.specialData.defaultAppearance);
	}

	private function SetupBaseAI()
	{
		var aiTree : IAITree;
		var resID : int;

		if(false && StrContains(this.data.depotPathPrefix, "novigrad"))
		{
			aiTree = CreateAITree();

			LogSCM("Created tree: " + aiTree);

			resID = this.npc.ForceAIBehavior(aiTree, BTAP_AboveCombat2);

			LogSCM("Forcing Tree... " + resID);
		}

		//BTAP_BelowIdle 16
		//BTAP_Idle 20
		//BTAP_AboveIdle 26
		//BTAP_AboveIdle2 31
		//BTAP_Emergency 50
		//BTAP_AboveEmergency 61
		//BTAP_AboveEmergency2 66
		//BTAP_Combat 75
		//BTAP_AboveCombat 86
		//BTAP_AboveCombat2 91
		//BTAP_FullCutscene 95
	}

	private function CreateAITree() : IAITree
	{
		/*var tree : MCM_CAINpcCombat;
		tree = new MCM_CAINpcCombat in this.npc;
		tree.OnCreated();
		return tree;*/

		var npcBase : CAINpcBase;

		npcBase = new CAINpcBase in npc;
		npcBase.OnCreated();
		
		npcBase.params.combatTree = new CAINpcOneHandedCombat in npcBase.params;
		npcBase.params.combatTree.OnCreated();

		npcBase.params.reactionTree = new CAICombatNPCReactionsTree in npcBase.params;
		npcBase.params.reactionTree.OnCreated();

		npcBase.params.softReactionTree = new CAICombatSoftReactionsTree in npcBase.params; //CAIQuestSoftReactionsTree
		npcBase.params.softReactionTree.OnCreated();

		//npcBase.params.npcGroupType = new CAINPCGroupTypeRedefinition in npcBase.params;
		//npcBase.params.npcGroupType.npcGroupType = ENGT_Quest; //ENPCGroupType

		//npcBase.params.npcGroupType = NULL;
		//npcBase.params.combatTree = NULL;
		//npcBase.params.idleTree = NULL;
		//npcBase.params.deathTree = NULL;
		//npcBase.params.reactionTree = NULL;
		//npcBase.params.softReactionTree = NULL;

		return npcBase;
	}
}

	//editable inlined var npcGroupType : CAINPCGroupTypeRedefinition;
	//editable inlined var combatTree : CAINpcCombat;
	//editable inlined var idleTree : CAIIdleTree;
	//editable inlined var deathTree : CAIDeathTree;
	//editable inlined var reactionTree : CAINpcReactionsTree;
	//editable inlined var softReactionTree : CAISoftReactionTree;

/*
class MCM_CAINpcCombat extends CAICombatTree
{
	default aiTreeName = "resdef:ai\npc_basecombat";

	editable inlined var params : CAINpcOneHandedCombatParams;
	
	function Init()
	{
		params = new CAINpcOneHandedCombatParams in this;
		params.OnCreated();
	}
}

class MCM_CAINpcBase extends CAIBaseTree
{
	default aiTreeName = "resdef:ai\npc_base";

	editable inlined var params : CAINpcDefaults;
	
	function Init()
	{
		params = new CAINpcDefaults in this;
		params.OnCreated();
	}
};

class MCM_CAINpcDefaults extends CAIDefaults
{	
	editable inlined var npcGroupType : CAINPCGroupTypeRedefinition;
	editable inlined var combatTree : CAINpcCombat;
	editable inlined var idleTree : CAIIdleTree;
	editable inlined var deathTree : CAIDeathTree;
	editable inlined var reactionTree : CAINpcReactionsTree;
	editable inlined var softReactionTree : CAISoftReactionTree;
	
	editable var hasDrinkingMinigame : bool;
	editable var morphInCombat : bool;
	default hasDrinkingMinigame = false;
	var tempNpcGroupType : ENPCGroupType;
	
	function Init()
	{
		combatTree = new CAINpcCombat in this;
		combatTree.OnCreated();
		idleTree = new CAIIdleTree in this;
		idleTree.OnCreated();
		deathTree = new CAINpcDeath in this;
		deathTree.OnCreated();
	}
};*/

//CAIFollowPartyMemberSideBySideTree

/*
class CAINpcBase extends CAIBaseTree
{
	default aiTreeName = "resdef:ai\npc_base";

	editable inlined var params : CAINpcDefaults;
	
	function Init()
	{
		params = new CAINpcDefaults in this;
		params.OnCreated();
	}
};

class CAINpcDefaults extends CAIDefaults
{	
	editable inlined var npcGroupType : CAINPCGroupTypeRedefinition;
	editable inlined var combatTree : CAINpcCombat;
	editable inlined var idleTree : CAIIdleTree;
	editable inlined var deathTree : CAIDeathTree;
	editable inlined var reactionTree : CAINpcReactionsTree;
	editable inlined var softReactionTree : CAISoftReactionTree;
	
	editable var hasDrinkingMinigame : bool;
	editable var morphInCombat : bool;
	default hasDrinkingMinigame = false;
	var tempNpcGroupType : ENPCGroupType;
	
	function Init()
	{
		combatTree = new CAINpcCombat in this;
		combatTree.OnCreated();
		idleTree = new CAIIdleTree in this;
		idleTree.OnCreated();
		deathTree = new CAINpcDeath in this;
		deathTree.OnCreated();
	}
};*/
