
statemachine abstract class ScmCombatRoot
{
	public var npc : CNewNPC;
		
	public function SetNPC(theNPC : CNewNPC)
	{
		npc = theNPC;
	}
	
	public function GetSpecialCombatCount() : int;
	public function PerformAttack(attackID : int);
}

state SCMCiriBlink in CNewNPC
{
	event OnEnterState(prevStateName : name)
	{
		//super.OnEnterState(prevStateName);	
		//theInput.SetContext(parent.GetCombatInputContext());
		//parent.OnEquipMeleeWeapon(PW_Steel, true);
		//theGame.GetBehTreeReactionManager().CreateReactionEvent(thePlayer, 'DrawWeapon', 0.0f, 10.0f, 2.0f, -1);
		
		if (!ciriGhostFxTemplate)
			ciriGhostFxTemplate = (CEntityTemplate)LoadResource('ciri_ghost');
		if (!ciriPhantomTemplate)
			ciriPhantomTemplate = (CEntityTemplate)LoadResource("dlc/mod_spawn_companions/hack/npc/ciri_phantom_fx.w2ent", true); //'ciri_phantom');

		isCompletingSpecialAttack = false;
		animComp = (CMovingPhysicalAgentComponent)parent.GetComponentByClassName('CMovingPhysicalAgentComponent');
		//parent.AddTimer('CheckNPCActionState', 0.1, true);
	}
	
	private var animComp : CMovingPhysicalAgentComponent; //CAnimatedComponent
	
	private latent function PlayAnim(nam : name)
	{
		if(animComp) animComp.PlaySlotAnimationAsync(nam, 'NPC_ANIM_SLOT');
	}
	
	/*timer function CheckNPCActionState(dt : float , id : int)
	{
		if(parent.scmcc.PeformSpecialAttackAction())
		{
			if(!isCompletingSpecialAttack)
			{
				parent.RemoveTag('mod_scm_specialCiriDone');
				parent.PlayVoiceset(150, 'battlecry_geralt');
				PerformBlinkAttack();
			}
		}
	}*/
	
	event OnModSCMDoSpecialAttack(nam : name)
	{
		if(nam == 'Blink')
		{
			if(!isCompletingSpecialAttack)
			{
				parent.RemoveTag('mod_scm_specialCiriDone');
				parent.PlayVoiceset(150, 'battlecry_geralt');
				PerformBlinkAttack();
			}
		}
	}
	
	event OnLeaveState(nextStateName : name)
	{
		Interrupt();
		
		DestroyPhantoms();
		
		parent.RemoveTag('mod_scm_specialCiriDone');
		parent.StopAllEffectsAfter(2.0);
		//parent.RemoveTimer('CheckNPCActionState');
	}
	
	private var ciriPhantoms : array<W3CiriPhantomSCM>;

	public function AddPhantom(phantom : W3CiriPhantomSCM)
	{
		ciriPhantoms.PushBack(phantom);
	}
	
	public function DestroyPhantoms()
	{
		var i : int;
		
		for (i=0 ; i < ciriPhantoms.Size() ; i+=1)
		{
			ciriPhantoms[i].DestroyAfter(0.8);
		}
		
		ciriPhantoms.Clear();
	}
	
	private function PhantomsCleanup()
	{
		this.DestroyPhantoms();
	}

	private var specialAttackHeading : float;
	private var completeSpecialAttackDist : float;
	private var specialAttackStartTimeStamp : float;
	private var isCompletingSpecialAttack : bool;
				
	private var specialAttackSphere : CMeshComponent;
	private var specialAttackSphereEnt : CEntity;
	
	private saved var specialAttackEffectTemplate : CEntityTemplate;
	private saved var ciriPhantomTemplate : CEntityTemplate;
	private saved var ciriGhostFxTemplate : CEntityTemplate;
	
	private var buttonWasHeld : bool; default buttonWasHeld = false;
	private var specialAttackRadius : float; default specialAttackRadius = 0.f;
	private var specialAttackInterrupted : bool; default specialAttackInterrupted = false;
	
	private const var HOLD_SPECIAL_ATTACK_BUTTON_TIME : float; default HOLD_SPECIAL_ATTACK_BUTTON_TIME = 0.2f;
	private const var ATTACK_RADIUS_INITIAL_VAL : float; default ATTACK_RADIUS_INITIAL_VAL = 1.5f;
	private const var ATTACK_RADIUS_MAXIMUM_VAL : float; default ATTACK_RADIUS_MAXIMUM_VAL = 12.0f;
	private const var ATTACK_RADIUS_INCREASE_SPEED : float;	default ATTACK_RADIUS_INCREASE_SPEED = 8.0f;
	private const var SPECIAL_ATTACK_MAX_TARGETS : int; default SPECIAL_ATTACK_MAX_TARGETS = 10.0f;
	private const var DODGE_DISTANCE : float; default DODGE_DISTANCE = 2.5f;
	private const var DASH_DISTANCE : float; default DASH_DISTANCE = 7.0f;
	
	private const var SPECIAL_ATTACK_HEAVY_MAX_DIST : float; default SPECIAL_ATTACK_HEAVY_MAX_DIST = 15.0f;
	
	public function log(val : string)
	{
		//LogChannel('SCM Ciri', "======================" + val + "======================");
	}

	entry function PerformBlinkAttack()
	{
		isCompletingSpecialAttack = true;
		PerformBlinkAttack_DO();
	}
	
	entry function Interrupt()
	{
		parent.GetMovingAgentComponent().GetMovementAdjustor().CancelAll();
		
		if (!isCompletingSpecialAttack)
		{
			isCompletingSpecialAttack = true;
			SpecialAttackCleanup();
			//parent.RemoveCustomOrientationTarget('CiriSpecialAttack');
		}
		else if(specialAttackInterrupted)
		{	
			specialAttackInterrupted = false;
			SpecialAttackCleanup();
			//parent.RemoveCustomOrientationTarget('CiriSpecialAttack');
			parent.RemoveBuffImmunity_AllNegative('CiriSpecial');
			parent.StopEffect('disappear');
		}
		else if (parent.IsCurrentlyDodging())
		{
			//parent.SetBehaviorVariable('isPerformingSpecialAttack', 0.f);
		}
		//parent.StopEffect('fury');
		Appear();
		
		parent.StopEffect('fury');
		parent.StopEffect('disappear');
		parent.StopEffect('appear');
		parent.StopEffect('appear_cutscene');
		parent.StopEffect('disappear_cutscene');
	}
	
	private const var teleportToLastPos : bool;
	private var lastTarget : CActor;
	
	default teleportToLastPos = false;
	
	private latent function PerformBlinkAttack_DO()
	{
		var cachedPos : Vector;
		var cachedRot : EulerAngles;
		var cachedHeadingVec : Vector;
		var targets : array<CActor>;
		var phantom : W3CiriPhantomSCM;
		var newHeadingVec : Vector;
		var newPosition : Vector;
		var targetPos : Vector;
		var distance : float;
		var correctedZ : float;
		
		cachedPos = parent.GetWorldPosition();
		cachedRot = parent.GetWorldRotation();
		cachedHeadingVec = parent.GetHeadingVector();
		
		parent.AddBuffImmunity_AllNegative('CiriSpecial', true);
		parent.StopEffect('critical_poison');
		
		buttonWasHeld = true;
		specialAttackRadius = 12;
		
		PlayAnim('woman_ciri_sword_special_blink_attack_start_lp');
		Sleep(0.5);
		Disappear();
		Sleep(0.5);
		
		FindSpecialAttackTargets(targets, SPECIAL_ATTACK_MAX_TARGETS);
		
		LogChannel('ModSpawnCompanions', "Found " + targets.Size());

		specialAttackInterrupted = true;
		ExecuteSpecialAttack(targets);
		specialAttackInterrupted = false;
		
		PhantomsCleanup();
		
		if (lastTarget)
		{
			targetPos = lastTarget.GetWorldPosition();
			newHeadingVec = VecNormalize(cachedPos - targetPos);
			
			lastTarget.IsAttacked(true);
			
			distance = lastTarget.GetRadius() + parent.GetRadius() + 1.8f;
			
			if (distance < 1.5) distance = 1.5;
				
			newPosition = targetPos - newHeadingVec*distance;
			
			if (!theGame.GetWorld().NavigationComputeZ(newPosition,newPosition.Z - 1, newPosition.Z + 1, correctedZ))
			{
				SlideToNewPosition(GetSlideDuration(cachedPos), cachedPos, cachedHeadingVec, true);
			}
			else
			{
				SlideToNewPosition(GetSlideDuration(newPosition), newPosition, newHeadingVec);
			}
			
			lastTarget = NULL;
		}
		else
		{
			//parent.SetBehaviorVariable('specialAttackInPlace', 1.f);
			
			if(targets.Size() > 0)
			{
				SlideToNewPosition(GetSlideDuration(cachedPos), cachedPos, cachedHeadingVec, true);
			}
			else
			{
				SlideToNewPosition(0.4, cachedPos, cachedHeadingVec, true);
			}
		}
		
		Appear();
		parent.RemoveBuffImmunity_AllNegative('CiriSpecial');
		SpecialAttackSphereCleanup();
		parent.AddTag('mod_scm_specialCiriDone');
		isCompletingSpecialAttack = false;
	}
	
	private function FindSpecialAttackTargets(out targets : array<CActor>, maxEnemiesNo : int)
	{
		var i : int;
		
		targets = parent.GetNPCsAndPlayersInRange(specialAttackRadius, maxEnemiesNo, '', FLAG_Attitude_Hostile + FLAG_OnlyAliveActors + FLAG_ExcludeTarget);
		
		for (i=targets.Size()-1 ; i >= 0 ; i-=1)
		{
			if (!targets[i].GetGameplayVisibility())
			{
				targets.Erase(i);
			}
		}
	}
	
	private latent function ExecuteSpecialAttack(targets : array<CActor>)
	{
		var i,j : int;
		var targetPos, playerPos, spawnPos : Vector;
		var spawnHeading : Vector;
		var spawnRot : EulerAngles;
		var dist : float;
		var slideDuration : float;
		var oneTarget : bool;
		
		playerPos = parent.GetWorldPosition();
		//parent.PlayEffect('fury');
		
		LogChannel('ModSpawnCompanions', "Executing Special Attack");
		
		for (i=0 ; i < targets.Size() ; i+= 1)
		{
			if (i == targets.Size() - 1 && teleportToLastPos)
			{
				lastTarget = targets[i];
				break;
			}
			
			if(targets[i].IsAlive())
			{
				PhantomsCleanup();
			
				if (targets.Size() == 1)
				{
					oneTarget = true;
					for(j=0 ; j < 2 ; j+=1)
					{
						dist = targets[i].GetRadius() + parent.GetRadius() + 0.5f;
						if (j == 1)
							GetSpawnPosAndRot(targets[i],-95,dist,spawnPos,spawnRot);
						else if (j == 0)
							GetSpawnPosAndRot(targets[i],95,dist,spawnPos,spawnRot);
							
						SpawnPhantomWithAnim(spawnPos, spawnRot, targets[i]);
						parent.SetHideInGame(true);
						Sleep(0.05f*10);
					}
					lastTarget = targets[i];
				}
				else
				{
					dist = targets[i].GetRadius() + parent.GetRadius() + 0.5f; //1.8
					GetSpawnPosAndRot(targets[i],0,dist,spawnPos,spawnRot);
					SpawnPhantomWithAnim(spawnPos, spawnRot, targets[i]);
					parent.SetHideInGame(true);
					Sleep(0.05f*10);
					lastTarget = targets[i];
				}
				
				targets[i].IsAttacked(true);
				
				targetPos = targets[i].GetWorldPosition();
				slideDuration = GetSlideDuration(targetPos);
				
				//this.OnSlideToNewPositionStart(slideDuration,targetPos); //,GetProperHeadingForCamera(targets[i].GetHeadingVector(),oneTarget));
				
				SlideToNewNode(slideDuration,targets[i]);
			}
		}
	}
	
	private var currentCombatAction : EBufferActionType;
	
	function SetCombatAction(action : EBufferActionType)
	{
		currentCombatAction = action;
	}
	
	function GetCombatAction() : EBufferActionType
	{
		return currentCombatAction;
	}	
	
	protected var bIsInCombatAction : bool;
	
	function IsInCombatAction() : bool
	{
		return bIsInCombatAction;
	}
	
	public function IsInCombatAction_SpecialAttack() : bool
	{
		return IsInCombatAction() && (GetCombatAction() == EBAT_Ciri_SpecialAttack || GetCombatAction() == EBAT_Ciri_SpecialAttack_Heavy);
	}
	
	private saved var attackAnimsListLP : array<name>;
	private saved var attackAnimsListRP : array<name>;
	
	private function SelectRandomAnim(out animName : name)
	{
		var anim : name;
		var index : int;
		if (attackAnimsListLP.Size() == 0 && attackAnimsListRP.Size() == 0)
		{
			attackAnimsListLP.PushBack('woman_ciri_sword_attack_fast_1_lp_40ms');
			attackAnimsListLP.PushBack('woman_ciri_sword_attack_fast_2_lp_40ms');
			attackAnimsListLP.PushBack('woman_ciri_sword_attack_fast_3_lp_40ms');
			attackAnimsListLP.PushBack('woman_ciri_sword_attack_fast_4_lp_40ms');
			
			attackAnimsListRP.PushBack('woman_ciri_sword_attack_fast_1_rp_40ms');
			attackAnimsListRP.PushBack('woman_ciri_sword_attack_fast_2_rp_40ms');
			attackAnimsListRP.PushBack('woman_ciri_sword_attack_fast_3_rp_40ms');
			attackAnimsListRP.PushBack('woman_ciri_sword_attack_fast_4_rp_40ms');
			attackAnimsListRP.PushBack('woman_ciri_sword_attack_fast_5_rp_40ms');
		}
		
		if (RandRange(100,0) > 50)
		{
			index = RandRange(attackAnimsListLP.Size());
			anim = attackAnimsListLP[index];
		}
		else
		{
			index = RandRange(attackAnimsListRP.Size());
			anim = attackAnimsListRP[index];
		}
		animName = anim;
	}
	
	private function GetSlideDuration(destinationPos : Vector) : float
	{
		var slideDistance, slideDuration : float;
		
		slideDistance = VecDistance(parent.GetWorldPosition(), destinationPos);
		slideDuration = slideDistance / 10; 
		slideDuration = ClampF(slideDuration,0.1,0.4);
		
		return slideDuration;
	}
	
	private function GetSpawnPosAndRot(target : CNode, angleDiff : float, distOffset : float, out spawnPos : Vector, out spawnRot : EulerAngles)
	{
		var headingVec : Vector;
		
		headingVec = VecFromHeading(AngleNormalize180(target.GetHeading() + angleDiff));
		spawnRot = VecToRotation(headingVec);
		spawnPos = GetSpawnOffsetPosition(target.GetWorldPosition(), headingVec, distOffset);
	}
	
	private function GetSpawnOffsetPosition(targetPos : Vector, out headingVec : Vector, offset : float) : Vector
	{
		var pos, newPos, normal : Vector;
		
		pos = targetPos - headingVec*offset;
		
		if (theGame.GetWorld().NavigationFindSafeSpot(pos, parent.GetRadius(), 2.f, newPos))
		{
			if (theGame.GetWorld().StaticTrace(newPos + Vector(0,0,3), newPos - Vector(0,0,3), newPos, normal))
			{
				headingVec = targetPos - newPos;
				return newPos;
			}
		}
		
		return pos;
	}
	
	private latent function SpawnPhantomWithAnim(position : Vector, rotation : EulerAngles, optional target : CActor, optional animationName : name)
	{
		var phantom : W3CiriPhantomSCM;
		var animComp : CAnimatedComponent;
		var res : bool;
		
		phantom = (W3CiriPhantomSCM)theGame.CreateEntity(ciriPhantomTemplate, position, rotation);
		
		if (phantom)
		{
			if (!IsNameValid(animationName))
				 SelectRandomAnim(animationName);
			
			phantom.Init(parent,target);

			AddPhantom(phantom);
			animComp = (CAnimatedComponent)phantom.GetComponentByClassName('CAnimatedComponent');
			
			if (animComp)
			{
				res = animComp.PlaySlotAnimationAsync(animationName,'GAMEPLAY_SLOT');
			}
		}
		res = false;
	}
	
	private function SpecialAttackCleanup()
	{
		SpecialAttackSphereCleanup();
		PhantomsCleanup();
		
		isCompletingSpecialAttack = false;
		
		Appear();
	}
	
	private function SpecialAttackSphereCleanup()
	{		
		if (specialAttackSphereEnt)
		{
			specialAttackSphereEnt.PlayEffect('fade');
			specialAttackSphereEnt.DestroyAfter(0.6);
		}

		specialAttackSphereEnt = NULL;
		specialAttackSphere = NULL;
	}
	
	private function SpawnSpecialAttackSphere()
	{
		specialAttackSphereEnt = theGame.CreateEntity(specialAttackEffectTemplate, parent.GetWorldPosition(), parent.GetWorldRotation());
	}
	
	private function sphereScaleFunction(time : float) : float
	{
		var scale : float;
		scale = ATTACK_RADIUS_MAXIMUM_VAL*(1-(((time*1.5)-1)*((time*1.5)-1)));
		if(scale < 0) scale = 0;
		if(scale > ATTACK_RADIUS_MAXIMUM_VAL) scale = ATTACK_RADIUS_MAXIMUM_VAL;
		
		return scale;
	}
	
	private function Appear()
	{
		parent.SetHideInGame(false);
		parent.PlayEffect('appear_cutscene');
		parent.PlayEffect('appear');
	}
	
	private latent function Disappear()
	{
		parent.PlayEffect('disappear_cutscene');
		parent.PlayEffect('disappear');
		parent.SetHideInGame(true); 
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

		if (newHeading != Vector(0,0,0))
			movementAdjustor.RotateTo(ticket,VecHeading(newHeading));
			
		if (duration > 0)
			Sleep(duration);
		
		if (alsoTeleport && VecDistanceSquared(newPos,parent.GetWorldPosition()) > 0.25f) 
			parent.Teleport(newPos);
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
	
	private latent function SlideToNewNode (duration : float, node : CNode)
	{
		var movementAdjustor : CMovementAdjustor;
		var ticket : SMovementAdjustmentRequestTicket;

		movementAdjustor = parent.GetMovingAgentComponent().GetMovementAdjustor();
		movementAdjustor.CancelAll();

		ticket = movementAdjustor.CreateNewRequest('CiriSpecialAttackSlide');
		movementAdjustor.MaxRotationAdjustmentSpeed(ticket, 1000000.f);

		movementAdjustor.AdjustmentDuration(ticket, duration);
		movementAdjustor.SlideTowards(ticket,node);
			
		Sleep(duration);
	}
}
