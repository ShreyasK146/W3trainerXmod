
state SCMCiriDash in CNewNPC
{
	private var animComp : CMovingPhysicalAgentComponent; //CAnimatedComponent
	
	event OnEnterState(prevStateName : name)
	{
		if (!bloodExplode)
			bloodExplode = (CEntityTemplate)LoadResource('blood_explode');
		
		//parent.AddTimer('CheckNPCActionState', 0.1, true);
		
		//animComp = (CAnimatedComponent)parent.GetComponentByClassName('CAnimatedComponent');
		animComp = (CMovingPhysicalAgentComponent)parent.GetComponentByClassName('CMovingPhysicalAgentComponent');
	}
	
	private latent function PlayAnim(nam : name)
	{
		if(animComp) animComp.PlaySlotAnimationAsync(nam, 'NPC_ANIM_SLOT');
	}
	
	/*event OnAnimEvent_ActionBlend(animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo)
	{
		if (animEventType == AET_DurationStart)
		{	
			parent.SetCanPlayHitAnim(true);
			//if (this.BufferCombatAction != EBAT_EMPTY)
			{
			//	this.ProcessCombatActionBuffer();
			}
			//else
			{
			//	this.SetBIsCombatActionAllowed(true);
			}
		}
	}
	
	event OnAnimEvent_fx_trail(animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo)
	{
		if (parent.HasAbility('Ciri_Rage'))
		{
			this.PlayRageEffectOnWeapon('fury_trail');
		}
		else
		{
			this.PlayRageEffectOnWeapon('light_trail_fx');
		}
	}
	
	event OnAnimEvent_rage(animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo)
	{
		if (parent.HasAbility('Ciri_Rage'))
			parent.PlayEffect('rage');
	}
	
	event OnAnimEvent_SlideToTarget(animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo)
	{

	}*/
	
	/*timer function CheckNPCActionState(dt : float , id : int)
	{
		if(parent.scmcc.PeformSpecialAttackAction())
		{
			log("Lets Go RUMBLEE: " + isCompletingSpecialAttack);
			if(!isCompletingSpecialAttack)
			{
				parent.RemoveTag('mod_scm_specialCiriDone');
				parent.PlayVoiceset(150, 'battlecry_geralt');
				PerformDash();
			}
		}
	}*/
	
	event OnModSCMDoSpecialAttack(nam : name)
	{
		if(nam == 'Dash')
		{
			log("Lets Go RUMBLEE: " + isCompletingSpecialAttack);
			if(!isCompletingSpecialAttack)
			{
				parent.RemoveTag('mod_scm_specialCiriDone');
				parent.PlayVoiceset(150, 'battlecry_geralt');
				PerformDash();
			}
		}
	}
	
	/*event OnScriptReloaded()
	{
		log("Lets Go RUMBLEE: " + isCompletingSpecialAttack);
		if(!isCompletingSpecialAttack)
		{
			parent.RemoveTag('mod_scm_specialCiriDone');
			parent.PlayVoiceset(150, 'battlecry_geralt');
			PerformDash();
		}
	}*/
	
	event OnLeaveState(nextStateName : name)
	{
		PerformSpecialAttackHeavyCleanup();
		//parent.RemoveTimer('CheckNPCActionState');
		parent.RemoveTag('mod_scm_specialCiriDone');
		parent.RemoveTimer('SpecialAttackTimer');
	}
	
	entry function PerformDash()
	{	
		if(!isCompletingSpecialAttack)
		{
			CompleteSpecialAttackHeavy();
		}
	}

	private var bloodExplode : CEntityTemplate;

	private var specialAttackHeading : float;
	private var completeSpecialAttackDist : float;
	private var specialAttackStartTimeStamp : float;
	private var isCompletingSpecialAttack : bool;
				
	private var specialAttackSphere : CMeshComponent;
	private var specialAttackSphereEnt : CEntity;
	
	private saved  var specialAttackEffectTemplate : CEntityTemplate;
	private saved  var ciriPhantomTemplate : CEntityTemplate;
	private saved  var ciriGhostFxTemplate : CEntityTemplate;
	
	private var buttonWasHeld : bool; default buttonWasHeld = false;
	private var specialAttackRadius : float; default specialAttackRadius = 0.f;
	private var specialAttackInterrupted : bool; default specialAttackInterrupted = false;
	
	private const var HOLD_SPECIAL_ATTACK_BUTTON_TIME : float; default HOLD_SPECIAL_ATTACK_BUTTON_TIME = 0.2f;
	private const var ATTACK_RADIUS_INITIAL_VAL : float; default ATTACK_RADIUS_INITIAL_VAL = 1.5f;
	private const var ATTACK_RADIUS_MAXIMUM_VAL : float; default ATTACK_RADIUS_MAXIMUM_VAL = 12.0f;
	private const var ATTACK_RADIUS_INCREASE_SPEED : float; default ATTACK_RADIUS_INCREASE_SPEED = 8.0f;
	private const var SPECIAL_ATTACK_MAX_TARGETS : int; default SPECIAL_ATTACK_MAX_TARGETS = 10.0f;
	private const var DODGE_DISTANCE : float; default DODGE_DISTANCE = 2.5f;
	private const var DASH_DISTANCE : float; default DASH_DISTANCE = 7.0f;
	
	private const var SPECIAL_ATTACK_HEAVY_MAX_DIST : float; default SPECIAL_ATTACK_HEAVY_MAX_DIST = 15.0f;
	
	public function log(val : string)
	{
		//LogChannel('SCM CiriHV', "======================" + val + "======================");
	}
	
	private var targets : array<CActor>;
	
	private function GetFinalPositionActor() : CActor
	{
		var i : int;
		var dotProd : float;
		var bestDotProd : float;
		var bestActor : CActor;
		var bestHeading : Vector;
		var myPos : Vector;
		
		targets.Clear();
		targets = parent.GetNPCsAndPlayersInRange(12, 30, '', FLAG_Attitude_Hostile + FLAG_OnlyAliveActors);
		
		log("Found " + targets.Size() + " targets");
		
		if(targets.Size() == 0) return bestActor;
		
		myPos = parent.GetWorldPosition();
		
		for (i = targets.Size()-1 ; i >= 0 ; i-=1)
		{
			if (!targets[i].GetGameplayVisibility())
			{
				targets.Erase(i);
			}
			else
			{
				bestHeading += targets[i].GetWorldPosition(); //(targets[i].GetWorldPosition() - myPos);
			}
		}

		bestHeading = Vector(targets.Size(), targets.Size(), targets.Size());
		bestHeading = (bestHeading - myPos);
		bestHeading = VecNormalize(bestHeading);
		bestDotProd = 0;
		
		log("Best Heading: " + bestHeading.X + "," + bestHeading.Y + "," + bestHeading.Z);
		
		for (i = targets.Size()-1 ; i >= 0 ; i-=1)
		{
			dotProd = VecDot2D(VecNormalize((targets[i].GetWorldPosition() - myPos)), bestHeading);
			if(dotProd < 0) dotProd = -dotProd;
			
		log("Dotprod: " + dotProd);
			if(dotProd > bestDotProd)
			{
				bestActor = targets[i];
				bestDotProd = dotProd;
			}
		}
		
		return bestActor;
	}
	
	public function OnCombatActionStart()
	{
		/*if (virtual_parent.GetBehaviorVariable('combatActionType') != (int)CAT_Attack && virtual_parent.GetBehaviorVariable('combatActionType') != (int)CAT_PreAttack)
		{
			virtual_parent.RemoveTimer('ProcessAttackTimer');
			virtual_parent.RemoveTimer('AttackTimerEnd');
			//parent.UnblockAction(EIAB_DrawWeapon, 'OnCombatActionStart_Attack');
		}
		else
		{
			//parent.BlockAction(EIAB_DrawWeapon, 'OnCombatActionStart_Attack');
		}*/
	}
	
	public function SetCombatIdleStance(stance : float)
	{
		parent.SetBehaviorVariable('combatIdleStance', stance);
		parent.SetBehaviorVariable('CombatStanceForOverlay', stance);
	}
	
	private latent function RotateToNewHeading (duration : float, newHeading : Vector)
	{
		var movementAdjustor : CMovementAdjustor;
		var ticket : SMovementAdjustmentRequestTicket;
		
		movementAdjustor = parent.GetMovingAgentComponent().GetMovementAdjustor();
		movementAdjustor.CancelAll();
		ticket = movementAdjustor.CreateNewRequest('CiriDodgeRotation');
		movementAdjustor.MaxRotationAdjustmentSpeed(ticket, 1000000.f);
		movementAdjustor.AdjustmentDuration(ticket, duration);
		if (newHeading != Vector(0,0,0))
			movementAdjustor.RotateTo(ticket,VecHeading(newHeading));
		
		if (duration > 0)
			Sleep(duration);
	}
	
	private latent function CompleteSpecialAttackHeavy()
	{
		var buttonHeldTime : float;
		var newHeadingVec : Vector;
		var destinationPos : Vector;
		var distance : float;
		var angleToTarget : float;
		var vecDistance : float;
		var slideDuration : float;
		var npc : CNewNPC;
		var slideTarget : CActor;
		var i, dashCount : int;
		
		if(isCompletingSpecialAttack) return;
		
		isCompletingSpecialAttack = true;
		
		buttonHeldTime = 2.0; //theGame.GetEngineTimeAsSeconds() - specialAttackStartTimeStamp;
		
		log("Heavy Attack GOOOO");
		
		{
			SetCombatIdleStance(0.f);
		
			//parent.DrainResourceForSpecialAttack();
			
			//parent.SetBehaviorVariable('isCompletingSpecialAttack', 1.f);
			//parent.SetBehaviorVariable('isPerformingSpecialAttack', 1.f);
			//parent.SetBehaviorVariable('isCompletingSpecialAttack', 0.f);
			//parent.SetBehaviorVariable('playerAttackType', 3.f);
			//parent.SetBehaviorVariable('combatActionType', (int)CAT_SpecialAttack);
			//if (parent.RaiseForceEvent('CombatAction'))
			//OnCombatActionStart();
			
			//{
			//	SetCombatIdleStance(0.f);
				//parent.DrainResourceForSpecialAttack();	
			//	parent.SetBehaviorVariable('isCompletingSpecialAttack', 1.f);
			//}

			this.MakeInvulnerable(true);

			slideTarget = GetFinalPositionActor();

			if (slideTarget)
			{
				PlayAnim('woman_ciri_sword_special_heavy_attack_charge_start_lp');
				parent.PlayEffect('disappear');
				
				RotateToNewHeading(0.5, VecNormalize(slideTarget.GetWorldPosition() - parent.GetWorldPosition()));
				
				Sleep(0.3);
				//parent.PlayEffect('disappear_cutscene');
				
				dashCount = Clamp(RandRange(targets.Size()/3+2, 2) + targets.Size()/10, 2, 5);
				
				if(targets.Size() > 15)
				{
					parent.PlayEffect('fury');
				}
				
				for(i = 0; i < dashCount; i+=1)
				{
					if(i != 0)
					{
						slideTarget = GetFinalPositionActor();
					}
					if(!slideTarget) break;
					
					parent.PlayEffect('disappear_cutscene');
					Sleep(0.8);
					parent.PlayEffect('disappear');
					parent.PlayEffect('appear_cutscene');
					//PlayAnim('woman_ciri_sword_special_heavy_attack_charge_start_lp');
					
					angleToTarget = NodeToNodeAngleDistance(slideTarget, parent);
					
					newHeadingVec = VecFromHeading(AngleNormalize180(parent.GetHeading() - angleToTarget));
				
					vecDistance = VecDistance(parent.GetWorldPosition(), slideTarget.GetWorldPosition());
					distance = ClampF(buttonHeldTime,HOLD_SPECIAL_ATTACK_BUTTON_TIME,2.f);
					distance = SPECIAL_ATTACK_HEAVY_MAX_DIST * (distance*0.25);
					distance = ClampF(distance,vecDistance + distance,SPECIAL_ATTACK_HEAVY_MAX_DIST);

					destinationPos = parent.GetWorldPosition() + newHeadingVec*distance;
					
					slideDuration = distance/30; 
					slideDuration = ClampF(slideDuration,0.1,0.4);
					
					//this.EnableSpecialAttackHeavyCollsion(true);

					parent.AddTimer('SpecialAttackTimer', 0, true);
					SlideToNewPosition(slideDuration, destinationPos, newHeadingVec);
					parent.RemoveTimer('SpecialAttackTimer');
					
					Sleep(0.05f);
					//this.EnableSpecialAttackHeavyCollsion(false);
				}
				
				parent.StopEffect('fury');
				parent.PlayEffect('appear_cutscene');
				//PlayAnim('woman_ciri_sword_special_heavy_attack_long_end');
				Sleep(0.8);
			}
				log("Done1: ");
			
			this.MakeInvulnerable(false);
		}
		
		targets.Clear();
		log("Done2: ");
		
		parent.AddTag('mod_scm_specialCiriDone');
		parent.RemoveTimer('SpecialAttackTimer');
				
		parent.StopEffect('fury');
		parent.StopEffect('disappear');
		parent.StopEffect('appear');
		parent.StopEffect('appear_cutscene');
		parent.StopEffect('disappear_cutscene');
				
		//parent.SetBehaviorVariable('isPerformingSpecialAttack', 0.f);
		isCompletingSpecialAttack = false;
	}
	
	/*function PlayRageEffectOnWeapon(effectName : name, optional disable : bool) : bool
	{
		var itemId : SItemUniqueId;
		var inv : CInventoryComponent;
		
		inv = parent.GetInventory();		
		itemId = inv.GetItemFromSlot('r_weapon');
		
		if (!inv.IsIdValid(itemId))
		{
			itemId = inv.GetItemFromSlot('l_weapon');
			
			if (!inv.IsIdValid(itemId))
			{
				itemId = inv.GetItemFromSlot('steel_sword_back_slot');
				if (!inv.IsIdValid(itemId))
					return false;
			}
		}
		if (disable)
			inv.StopItemEffect(itemId,effectName);
		else
			inv.PlayItemEffect(itemId,effectName);
		
		return true;
	}*/
	
	private function hitall()
	{
		var i : int;
		for(i = targets.Size()-1; i >= 0; i-=1)
		{
			OnCollide(targets[i]);
		}
	}
	
	timer function SpecialAttackTimer(dt : float , id : int)
	{
		var pos : Vector;
		var npc : CActor;
		var i : int;
		var distance : float;
		pos = parent.GetWorldPosition();
		
		for(i = targets.Size()-1; i >= 0; i-=1)
		{
			npc = targets[i];
			if(npc && npc.IsAlive())
			{
				distance = VecDistanceSquared(npc.GetWorldPosition(), pos);
				if(distance < 1)
				{
					OnCollide(targets[i]);
					targets.Erase(i);
				}
			}
		}
		
		//PlayAnim('woman_ciri_sword_special_heavy_attack_charge_middle');
	}
	
	public function MakeInvulnerable(toggle : bool)
	{
		if(true) return;
		if (toggle)
		{
			parent.SetImmortalityMode(AIM_Invulnerable, AIC_Combat);
			parent.SetCanPlayHitAnim(false);
			parent.EnableCharacterCollisions(false);
			parent.AddBuffImmunity_AllNegative('CiriMakeInvulnerable', true);
		}
		else
		{
			parent.SetImmortalityMode(AIM_None, AIC_Combat);
			parent.SetCanPlayHitAnim(true);
			parent.EnableCharacterCollisions(true);
			parent.RemoveBuffImmunity_AllNegative('CiriMakeInvulnerable');
		}
	}
	
	private latent function SlideToNewPosition (duration : float, newPos : Vector, optional newHeading : Vector, optional alsoTeleport : bool)
	{
		var movementAdjustor : CMovementAdjustor;
		var ticket : SMovementAdjustmentRequestTicket;
		
		movementAdjustor = parent.GetMovingAgentComponent().GetMovementAdjustor();
		movementAdjustor.CancelAll();
		
		ticket = movementAdjustor.CreateNewRequest('CiriSpecialAttackSlide');
		movementAdjustor.MaxRotationAdjustmentSpeed(ticket, 1000000.f);
		movementAdjustor.AdjustmentDuration(ticket, duration);
		movementAdjustor.SlideTo(ticket, newPos);
		
		//log("Slide to go X:" + newHeading.X + ", Y:" + newHeading.Y + ", Z:" + newHeading.Z);
		
		if (newHeading != Vector(0,0,0))
			movementAdjustor.RotateTo(ticket,VecHeading(newHeading));
			
		if (duration > 0)
			Sleep(duration);
		
		if (alsoTeleport && VecDistanceSquared(newPos,parent.GetWorldPosition()) > 0.25f)
			parent.Teleport(newPos);
	}
	
	private function PerformSpecialAttackHeavyCleanup()
	{
		parent.SetBehaviorVariable('isCompletingSpecialAttack', 1.f);
		
		//this.EnableSpecialAttackHeavyCollsion(false);
		this.MakeInvulnerable(false);
		isCompletingSpecialAttack = false;
		
		parent.SetBehaviorVariable('isPerformingSpecialAttack', 0.f);
	}
	
	private function EnergyBurst(radius : float)
	{
		var entities : array<CGameplayEntity>;
		var i : int;
		
		FindGameplayEntitiesInSphere( entities,
			parent.GetWorldPosition(),
			radius,
			50,
			'',
			FLAG_ExcludeTarget + FLAG_OnlyAliveActors + FLAG_Attitude_Hostile + FLAG_TestLineOfSight,
			(CGameplayEntity)parent);
		
		for (i=0; i<entities.Size() ; i+=1)
		{
			((CActor)entities[i]).AddEffectDefault(EET_Knockdown,(CGameplayEntity)parent, 'CiriEnergyBurst');
		}
	}
	
	private var tempIsCollisionDisabled : bool; default tempIsCollisionDisabled = true;
	
	public function EnableSpecialAttackHeavyCollsion(enable : bool)
	{
		var collision : CComponent;
		collision = parent.GetComponent("SpecialAttackHeavyHitBox");
		
		if (collision)
			collision.SetEnabled(enable);
		
		tempIsCollisionDisabled = !enable;
		
		//if (!enable)
		//collidedEnemies.Clear();
	}

	function OnCollide(collidedActor : CActor)
	{
		var action : W3Action_Attack;
		var bloodEntity : CEntity;
		var position : Vector;
	
		if (collidedActor == parent || !collidedActor.IsAlive() || GetAttitudeBetween(parent, collidedActor) != AIA_Hostile)
			return ;
		
		if (collidedActor)
		{
			action = new W3Action_Attack in thePlayer;
			action.Init((CGameplayEntity)parent,collidedActor,NULL,parent.GetInventory().GetItemFromSlot('r_weapon'),'attack_heavy',parent.GetName(),EHRT_Heavy, false, false, 'attack_heavy', AST_Jab, ASD_NotSet, true, false, false, false);
			action.SetCriticalHit();
			//action.SetForceExplosionDismemberment();
			action.AddEffectInfo(EET_Knockdown);
			//action.SetProcessBuffsIfNoDamage(true);
			
			theGame.damageMgr.ProcessAction(action);
			
			delete action;	
			
			position = collidedActor.GetWorldPosition();
			position.Z += 0.7;
			bloodEntity = theGame.CreateEntity(bloodExplode,position);
			bloodEntity.PlayEffect('blood_explode');
			bloodEntity.DestroyAfter(5.0);
			//parent.AddTimer('SlowMoStart', 0.1f);
		}
	}
	
	/*private var collidedEnemies : array<CActor>;
	
	event OnSpecialAttackHeavyCollision(object : CObject, physicalActorindex : int, shapeIndex : int)
	{
		var collidedActor : CActor;
		var action : W3Action_Attack;
		var dismembermentComp : CDismembermentComponent;
		var wounds : array< name >;
		var usedWound : name;
		var component : CComponent;
		var bloodEntity : CEntity;
		var position : Vector;
		
		component = (CComponent) object;
		
		if(!component || tempIsCollisionDisabled)
		{
			return false;
		}
		
		collidedActor = (CActor)(component.GetEntity());
		
		if (collidedActor == parent || !collidedActor.IsAlive() || GetAttitudeBetween(parent, collidedActor) != AIA_Hostile)
			return true;
		
		if (collidedActor && !collidedEnemies.Contains(collidedActor))
		{
			action = new W3Action_Attack in parent;
			action.Init((CGameplayEntity)parent,collidedActor,NULL,parent.GetInventory().GetItemFromSlot('r_weapon'),'attack_heavy',parent.GetName(),EHRT_Heavy, false, false, 'attack_heavy', AST_Jab, ASD_NotSet, true, false, false, false);
			action.SetCriticalHit();
			action.SetForceExplosionDismemberment();
			action.AddEffectInfo(EET_Knockdown);
			action.SetProcessBuffsIfNoDamage(true);
			
			theGame.damageMgr.ProcessAction(action);
			
			delete action;	
			
			position = collidedActor.GetWorldPosition();
			position.Z += 0.7;
			bloodEntity = theGame.CreateEntity(bloodExplode,position);
			bloodEntity.PlayEffect('blood_explode');
			bloodEntity.DestroyAfter(5.0);
			collidedEnemies.PushBack(collidedActor);
			//parent.AddTimer('SlowMoStart', 0.1f);
		}
	}*/
}
