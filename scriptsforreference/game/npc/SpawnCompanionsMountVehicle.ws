
state SCMAnimBase in CNewNPC
{
	protected var LoopAnim : bool; default LoopAnim = false;
	protected var LoopCount : int; default LoopCount = -1;
	protected var syncInstances : array< CAnimationManualSlotSyncInstance >;
	
	protected var IsRunning : bool; default IsRunning = false;
	
	protected var AnimSpeed : float; default AnimSpeed = 1.0;
	
	event OnEnterState(prevStateName : name)
	{
		Run();
	}
	
	event OnLeaveState(nextStateName : name)
	{
		StopAllAnimations();
	}
	
	public function CreateNewSyncInstance(out index : int) : CAnimationManualSlotSyncInstance
	{
		var newSyncInstance : CAnimationManualSlotSyncInstance;
		
		newSyncInstance = new CAnimationManualSlotSyncInstance in this;
		syncInstances.PushBack(newSyncInstance);
		
		index = syncInstances.Size() - 1;
		
		return newSyncInstance;
	}
	
	public function GetSyncInstance(index : int) : CAnimationManualSlotSyncInstance
	{
		return syncInstances[index];
	}
	
	public function RemoveSyncInstance(instance : CAnimationManualSlotSyncInstance)
	{
		syncInstances.Remove(instance);
	}
	
	private function CreatePart(animName : name, index : int) : SAnimationSequencePartDefinition
	{
		var masterSequencePart : SAnimationSequencePartDefinition;
		masterSequencePart.animation = animName;
		masterSequencePart.syncType = AMST_SyncBeginning;
		masterSequencePart.syncEventName = 'SyncEvent';
		masterSequencePart.shouldSlide = true;
		masterSequencePart.shouldRotate = true;
		masterSequencePart.blendInTime = 0;
		masterSequencePart.blendOutTime = 0;
		masterSequencePart.sequenceIndex = index;
		masterSequencePart.finalPosition = Vector(0, 0, 0);
		
		return masterSequencePart;
	}
	
	public function PlayAnims4(master : CEntity, optional a1 : name, optional a2 : name, optional a3 : name, optional a4 : name)
	{
		var anims : array<name>;
		
		if(a1 != '') anims.PushBack(a1);
		if(a2 != '') anims.PushBack(a2);
		if(a3 != '') anims.PushBack(a3);
		if(a4 != '') anims.PushBack(a4);
		
		PlayAnims(anims, master);
	}
	
	public function PlayAnims(anims : array<name>, master : CEntity) : bool
	{
		var masterDef : SAnimationSequenceDefinition;
		var syncInstance : CAnimationManualSlotSyncInstance;
		var instanceIndex, sequenceIndex, sz, i : int;
		var finisherAnim : bool;
		var actorMaster : CActor;
		
		if(anims.Size() == 0) return false;
		
		syncInstance = CreateNewSyncInstance(instanceIndex);
		{
			sz = anims.Size();
			for(i = 0; i < sz; i+=1)
			{
				masterDef.parts.PushBack(CreatePart(anims[i], i));			
			}
		
			masterDef.entity = master;
			masterDef.manualSlotName = 'GAMEPLAY_SLOT';
			masterDef.freezeAtEnd = false;
		}

		sequenceIndex = syncInstance.RegisterMaster(masterDef);

		if(sequenceIndex == -1)
		{
			syncInstances.Remove(syncInstance);
			return false;
		}
		
		actorMaster = (CActor)master;
		
		if(actorMaster)
		{
			actorMaster.SignalGameplayEventParamInt('SetupSyncInstance', instanceIndex);
			actorMaster.SignalGameplayEventParamInt('SetupSequenceIndex', sequenceIndex);
			actorMaster.SignalGameplayEvent('PlaySyncedAnim');
		}
		
		parent.EnableCharacterCollisions(false);
		
		return true;
	}
	
	public function StopAllAnimations()
	{
		var i : int;
		for(i = syncInstances.Size() - 1; i >= 0; i -= 1)
		{
			syncInstances[i].StopSequence(0);
			syncInstances.Erase(i);
		}
		syncInstances.Clear();
	}
	
	protected function OnAnimsStarted()
	{
		
	}
	
	protected function OnAnimsFinished()
	{
		parent.PopState(true);
	}
	
	protected function SetupAnims() : bool
	{
		return false;
	}
	
	protected function OnAnimTick()
	{
		
	}
	
	entry function Run()
	{
		var size : int = syncInstances.Size();
		var i : int;
		
		IsRunning = true;
		OnAnimsStarted();
		
		while(size > 0)
		{
			OnAnimTick();
			size = syncInstances.Size();
			
			for(i = size - 1; i >= 0; i -= 1)
			{
				syncInstances[i].Update(theTimer.timeDelta * AnimSpeed);
				
				if(syncInstances[i].HasEnded())
				{
					syncInstances.Erase(i);
				}
			}
			
			size = syncInstances.Size();
			
			if(size == 0 && LoopAnim && LoopCount != 0)
			{
				while(SetupAnims())
				{
					SleepOneFrame();
					//Sleep(0.5);
				}
				size = syncInstances.Size();
				if(LoopCount > 0) LoopCount-=1;
			}
			else
			{
				SleepOneFrame();
			}
		}
		
		OnAnimsFinished();
		IsRunning = false;
	}
}

class MySharedParams
{
	
}

state SCMMountHorse2 in CNewNPC extends SCMAnimBase
{
	var horseEntity : CNewNPC;
	var horseComp : W3HorseComponent;
	var dismountHorse : bool;
	
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
	
	private function SetupHorse()
	{
		horseComp = (W3HorseComponent)horseEntity.GetComponentByClassName('W3HorseComponent');
		horseComp.SetCanTakeDamageFromFalling(false);	
		horseComp.Tame(parent, true);
		horseComp.SetMountableByPlayer(false);
		horseComp.CanBeUsedBy(parent);
	}
	
	private function GetUnmountedHorse() : CNewNPC
	{
		var npcs : array<CNewNPC>;
		var i : int;
		var horseComp : W3HorseComponent;
		
		theGame.GetNPCsByTag(parent.scmcc.GetHorseTag(), npcs);
		
		for(i = npcs.Size()-1; i >= 0; i-=1)
		{
			if(npcs[i].HasTag('scm_horse'))
			{
				horseComp = (W3HorseComponent)npcs[i].GetComponentByClassName('W3HorseComponent');
				if(horseComp && !(horseComp.GetCurrentUser()))
				{
					return npcs[i];
				}
			}
		}
		
		return NULL;
	}
	
	function GetHorseToMount()
	{
		horseEntity = GetUnmountedHorse();
		
		if(!horseEntity)
		{
			SpawnHorse();
		}
		
		SetupHorse();
	}

	event OnEnterState(prevStateName : name)
	{
		if(parent.scmcc.CanUseHorse)
		{
			GetHorseToMount();
			if(horseEntity)
			{
				vehicleSlot = EVS_driver_slot;
				ridingManagerInstantMount = false;
				ridingManagerMountError = false;
				parent.scmcc.MountedHorse = horseEntity;
				parent.scmcc.IsOnHorse = true;
				horseEntity.Teleport(parent.GetWorldPosition());
				Begin();
			}
		}
		else
		{
		LogSCM("D");
			PopState(true);
		}
	}
	
	event OnLeaveState(nextStateName : name)
	{
		if(horseEntity)
		{
			parent.scmcc.IsOnHorse = false;
			parent.scmcc.StartFollowing();
			parent.scmcc.MountedHorse = NULL;
			horseEntity.Destroy();
		}
	}

	entry function Begin()
	{
		Main();
	}
	
	protected var mountType : name;
	var riderData : CAIStorageRiderData;
	var attachSlot : name;
	var vehicleSlot : EVehicleSlot;
	var ridingManagerInstantMount : bool;
	var ridingManagerMountError : bool;
	var mountStatus : EVehicleMountStatus;
	//sharedParams
	
	latent function OnMountStarted(behGraphName: name, vehicleComponent : CVehicleComponent) 
	{
		var riderActor : CActor = GetActor();
		var vehicleActor : CActor;
		var behaviorsToActivate : array< name >;
		var preloadResult : bool = true;	

		vehicleComponent.OnMountStarted(riderActor, vehicleSlot);

		riderActor.SetUsedVehicle((CGameplayEntity)vehicleComponent.GetEntity());	
		behaviorsToActivate.PushBack(behGraphName);
		
		preloadResult = riderActor.PreloadBehaviorsToActivate(behaviorsToActivate);
		LogAssert(preloadResult, "CBTTaskRidingManagerVehicleMount::OnMountStarted - preloading behaviors failed");	
		
		mountStatus = VMS_mountInProgress;

		vehicleActor = (CActor)vehicleComponent.GetEntity();
		vehicleActor.SignalGameplayEvent('HorseMountStart');
		riderActor.SignalGameplayEvent('HorseMountStart');

		riderActor.EnableCharacterCollisions(false);
		riderActor.EnablePhysicalMovement(false);
		((CMovingPhysicalAgentComponent)riderActor.GetMovingAgentComponent()).SetAnimatedMovement(true);
	}	

	latent function OnMountFinishedSuccessfully(behGraphName: name, vehicleComponent : CVehicleComponent)
	{
		var riderActor : CActor = GetActor();
		var vehicleActor : CActor;
		var player : CR4Player;
		var behaviorsToActivate : array< name >;
		var graphResult : bool;
		var movementAdjustor : CMovementAdjustor;
		
	riderActor.GetRootAnimatedComponent().SetUseExtractedMotion(true);
        riderActor.EnableCollisions(false); 
		
	riderActor.GetMovingAgentComponent().ResetMoveRequests();
        riderActor.SetBehaviorVariable('direction', 0.0f);
        GetHorse().GetMovingAgentComponent().ResetMoveRequests();
        GetHorse().SetBehaviorVariable('direction', 0.0f);
        
        riderActor.SoundSwitch("vo_3d", 'vo_3d_long_on_horse', 'head');

		vehicleActor = (CActor)vehicleComponent.GetEntity();
		player = (CR4Player)riderActor;
		
		if (ridingManagerInstantMount == false)
		{
			riderActor.GetMovingAgentComponent().SetAdditionalOffsetWhenAttachingToEntity(vehicleActor, 1.0f);
		}

		if (player)
		{
			riderActor.EnableCollisions(false); 
		}

		riderActor.SetBehaviorVariable('rider', 1.0f);
		vehicleActor.SignalGameplayEvent('HorseMountEnd');
		riderActor.SignalGameplayEvent('HorseMountEnd');
		
		if (riderActor.CanStealOtherActor(vehicleActor))
		{
			theGame.ConvertToStrayActor(vehicleActor);
			if (player)
			{
				player.SaveLastMountedHorse(vehicleActor);
			}
		}
		
		mountStatus = VMS_mounted;
		
		riderActor.RemoveTimer('UpdateTraverser');

		behaviorsToActivate.PushBack(behGraphName);
		graphResult = riderActor.ActivateBehaviors(behaviorsToActivate);
		
		riderActor.SetBehaviorVariable('MountType',GetMountTypeVariable());
		
		if (ridingManagerInstantMount)
		{
			riderActor.RaiseForceEvent('InstantMount');
		}
		
		LogAssert(graphResult, "CBTTaskRidingManagerHorseMount::OnMountFinishedSuccessfully - behaviors activation failed");
		
		if (vehicleSlot == EVS_passenger_slot)
		{
			if (riderActor.SetBehaviorVariable('isPassenger', 1.0f) == false)
			{
				LogAssert(graphResult, "CBTTaskRidingManagerHorseMount::OnMountFinishedSuccessfully - behaviors variable init failed");
			}
		}
		else
		{
			if (riderActor.SetBehaviorVariable('isPassenger', 0.0f) == false)
			{
				LogAssert(graphResult, "CBTTaskRidingManagerHorseMount::OnMountFinishedSuccessfully - behaviors variable init failed");
			}
		}
		
		riderActor.EnableCollisions(false);
		
		riderActor.CreateAttachment(vehicleComponent.GetEntity(), attachSlot);		
		
		movementAdjustor = riderActor.GetMovingAgentComponent().GetMovementAdjustor();
		if (movementAdjustor)
		{
			movementAdjustor.CancelAll();
		}
		
		vehicleComponent.OnMountFinished(riderActor);
	}

	latent function OnMountFailed(vehicleComponent : CVehicleComponent)
	{
		var riderActor : CActor = GetActor();
		var vehicleEntity : CEntity = vehicleComponent.GetEntity();
		
		riderActor.EnableCharacterCollisions(true);
		((CMovingPhysicalAgentComponent)riderActor.GetMovingAgentComponent()).SetAnimatedMovement(false);

		ridingManagerMountError = true;
		vehicleComponent.OnDismountStarted(riderActor);
		vehicleComponent.OnDismountFinished(riderActor, vehicleSlot);
		
		mountStatus = VMS_dismounted;
		
		riderActor.SetUsedVehicle(NULL);
	}

    latent function Main()
    {
        var npc : CNewNPC = GetNPC();
        var stupidArray : array< name >;
        var vehicleEntity : CEntity;
	var vehicleComponent : CVehicleComponent;
		
        stupidArray.PushBack('Exploration');
	GetActor().ActivateBehaviors(stupidArray); 
		
	vehicleEntity = GetHorse();
        vehicleComponent = ((CNewNPC)vehicleEntity).GetHorseComponent();  

        MountActor('VehicleHorse', vehicleComponent);
    }
	
	private function GetActor() : CActor
	{
		return (CActor)parent;
	}
	
	private function GetNPC() : CNewNPC
	{
		return parent;
	}
	
	private function GetHorse() : CActor
	{
		return (CActor)horseEntity;
	}

	function GetVehicleComponent() : CVehicleComponent
	{
		return (CVehicleComponent) GetHorse().GetComponentByClassName('CVehicleComponent');
	}

	function OnActivate() : EBTNodeStatus
	{
        var vehicleComponent: CVehicleComponent;
	vehicleComponent = GetVehicleComponent();
		
		if (!vehicleComponent || vehicleComponent.IsMountingPossible() == false)
        {
		return BTNS_Failed;
        }
		
        return BTNS_Active;
	}
	
	latent function MountActor(behGraphName: name, vehicleComponent : CVehicleComponent)
	{
		var riderActor : CActor = GetActor();
		var exploration : SExplorationQueryToken;
		var vehicleEntity : CEntity = vehicleComponent.GetEntity();
		var queryContext : SExplorationQueryContext;
		var success : bool = true;		
		
		if (ridingManagerInstantMount == false)
		{
			queryContext.inputDirectionInWorldSpace = VecNormalize(vehicleEntity.GetWorldPosition() - riderActor.GetWorldPosition());
			
			exploration = theGame.QueryExplorationFromObjectSync(riderActor, vehicleEntity);
			success = exploration.valid;
				//import var valid : bool;
				//import var type : EExplorationType;
				//import var pointOnEdge : Vector;
				//import var normal : Vector;
				//import var usesHands : bool;
			LogSCM("Query: " + exploration.valid + ", " + exploration.type + ", " + exploration.usesHands);
		}
		
		if (success)
		{
			LogSCM("START");
			OnMountStarted(behGraphName, vehicleComponent);

			if (ridingManagerInstantMount == false)
			{
				riderActor.AddTimer('UpdateTraverser', 0.f, true, false, TICK_PrePhysics);
				success = riderActor.ActionExploration(exploration, NULL, GetHorse());
			}
		}
		
		if (success)
		{		
			LogSCM("SUCCESS");
			OnMountFinishedSuccessfully(behGraphName, vehicleComponent);
		}
		else
		{
			LogSCM("FAIL");
			OnMountFailed(vehicleComponent);
		}
	}
	
	function GetMountTypeVariable() : float
	{
		switch (mountType)
		{
			case 'horse_mount_B_01' 	: return 1.f;
			case 'horse_mount_L' 		: return 2.f;
			case 'horse_mount_LB' 		: return 3.f;
			case 'horse_mount_LF' 		: return 4.f;
			case 'horse_mount_R_01' 	: return 5.f;
			case 'horse_mount_RB_01' 	: return 6.f;
			case 'horse_mount_RF_01' 	: return 7.f;
			default				: return 0.f;
		}
		return 0.f;
	}
	
	function Initialize()
	{
		//riderData = (CAIStorageRiderData)RequestStorageItem('RiderData', 'CAIStorageRiderData');
	}
	
	function OnGameplayEvent(eventName : CName) : bool
	{
		var riderActor : CActor = GetActor();
		var riderData : CAIStorageRiderData;
		var vehicleEntity : CEntity;
		var vehicleComponent : W3HorseComponent;

		if(eventName == 'OnPoolRequest' || eventName == 'RequestInstantDismount')
		{
			//Complete(false);
		}

		return false;
	}  
}

state SCMMountHorse in CNewNPC extends SCMAnimBase
{
	var horseEntity : CNewNPC;
	var horseComp : W3HorseComponent;
	var dismountHorse : bool;
	
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
	
	private function SetupHorse()
	{
		var movingagent : CMovingAgentComponent;
		horseComp = (W3HorseComponent)horseEntity.GetComponentByClassName('W3HorseComponent');
		horseComp.SetCanTakeDamageFromFalling(false);	
		horseComp.Tame(parent, true);
		horseComp.SetMountableByPlayer(false);
		horseComp.CanBeUsedBy(parent);
		
		movingagent = horseEntity.GetMovingAgentComponent();
		movingagent.SetGameplayRelativeMoveSpeed(2.5);
		movingagent.SetDirectionChangeRate(0.16*3);
		movingagent.SetMaxMoveRotationPerSec(60*3);
	}
	
	private function GetUnmountedHorse() : CNewNPC
	{
		var npcs : array<CNewNPC>;
		var i : int;
		var horseComp : W3HorseComponent;
		
		theGame.GetNPCsByTag(parent.scmcc.GetHorseTag(), npcs);
		
		for(i = npcs.Size()-1; i >= 0; i-=1)
		{
			if(npcs[i].HasTag('scm_horse'))
			{
				horseComp = (W3HorseComponent)npcs[i].GetComponentByClassName('W3HorseComponent');
				if(horseComp && !(horseComp.GetCurrentUser()))
				{
					return npcs[i];
				}
			}
		}
		
		return NULL;
	}
	
	function GetHorseToMount()
	{
		horseEntity = GetUnmountedHorse();
		
		if(!horseEntity)
		{
			SpawnHorse();
		}
		
		SetupHorse();
	}

	event OnEnterState(prevStateName : name)
	{
		if(parent.scmcc.CanUseHorse)
		{
			GetHorseToMount();
			if(horseEntity)
			{
				LoopAnim = true;
				LoopCount = -1;
				parent.scmcc.MountedHorse = horseEntity;
				parent.scmcc.IsOnHorse = true;
				dismountHorse = false;
				
				//parent.EnableCollisions(false);
				//parent.EnableCharacterCollisions(false);
				//parent.EnablePhysicalMovement(false);
				//((CMovingPhysicalAgentComponent)parent.GetMovingAgentComponent()).SetAnimatedMovement(true);
				//horseEntity.EnableCollisions(false);
				AnimMountHorse(RandRange(4, 0));
				super.OnEnterState(prevStateName);
			}
		}
	}
	
	event OnLeaveState(nextStateName : name)
	{
		if(horseEntity)
		{
			parent.scmcc.IsOnHorse = false;
			parent.scmcc.StartFollowing();
			parent.scmcc.MountedHorse = NULL;
			horseEntity.Destroy();
		}
		//parent.EnableCollisions(true);
		//parent.EnableCharacterCollisions(false);
		//parent.EnablePhysicalMovement(true);
		super.OnLeaveState(nextStateName);
	}
	
	event OnModSCMMountInfo(tag : name, val : int)
	{
		if(tag == 'DismountHorse')
		{
			dismountHorse = true;
		}
	}
	
	function DoMount()
	{
		parent.SetUsedVehicle(horseEntity);
		parent.scmcc.StartFollowing();
		parent.SignalGameplayEventParamInt('RidingManagerMountHorse', MT_instant | MT_fromScript);
		parent.SignalGameplayEvent('MountHorse');
	}
	
	function DoDismount()
	{
		parent.SignalGameplayEvent('RequestInstantDismount');
		parent.SetUsedVehicle(NULL);
	}
	
	protected function SetupAnims() : bool
	{	
		if(dismountHorse)
		{
			LoopAnim = false;
			DoDismount();
			AnimDismountHorse(RandRange(4, 1));
			return false;
		}
		else
		{
			if(forceTeleport)
			{
				DoMount();
				horseEntity.EnableCollisions(true);
			}
			forceTeleport = false;
			return true;
		}
	}
	
	protected function OnAnimTick()
	{
		if(forceTeleport)
		{
			horseEntity.TeleportWithRotation(horsePos, horseRot);
		}
	}
	
	var forceTeleport : bool; default forceTeleport = false;
	var horsePos, npcPos : Vector;
	var horseRot, npcRot : EulerAngles;
	
	function SetupPos(delta : Vector, rot : float)
	{
		horsePos = parent.GetWorldPosition();
		npcPos = horsePos + delta;
		
		horseRot = EulerAngles(0, 0, 0);
		npcRot = EulerAngles(0, rot, 0);
		
		parent.TeleportWithRotation(npcPos, npcRot);
	}
	
	function AnimMountHorse(side : SCMHorseMountSide)
	{
		var anims : array<name>;
		var deltaVec : Vector;
		var deltaRot : float;
		anims.Grow(2);
		
		switch(side)
		{
			case SCMHMS_Back: {anims[0] = 'horse_mount_B_01'; anims[1] = 'horse_mount_b_stop'; deltaVec = Vector(0.000000,-3.142929,0.000000); deltaRot = 0; break;} //DELTA XYZ PYR: []  .  [0.000000]
			case SCMHMS_Left: {anims[0] = 'horse_mount_L'; anims[1] = 'horse_mount_l_stop'; deltaVec = Vector(-0.514160,0.057144,0.000000); deltaRot = -85; break;} //DELTA XYZ PYR: []  .  [-85.000000]
			case SCMHMS_LeftFront: {anims[0] = 'horse_mount_LF'; anims[1] = 'horse_mount_lf_stop'; deltaVec = Vector(-0.728394,1.185741,0.000000); deltaRot = -170; break;} //DELTA XYZ PYR: []  .  [-170.000000]
			case SCMHMS_Right: {anims[0] = 'horse_mount_R_01'; anims[1] = 'horse_mount_r_stop'; deltaVec = Vector(0.671265,0.285721,0.000000); deltaRot = -258; break;} //DELTA XYZ PYR: []  .  [-258.000000]
			case SCMHMS_RightFront: {anims[0] = 'horse_mount_RF_01'; anims[1] = 'horse_mount_rf_stop'; deltaVec = Vector(0.642700,1.514320,0.000000); deltaRot = -184; break;} //DELTA XYZ PYR: []  .  [-184.000000]
		}
		
		deltaVec.Z = 0.1;
		
		SetupPos(deltaVec, deltaRot);
		forceTeleport = true;
		
		PlayAnims(anims, parent);
	}
	
	function AnimDismountHorse(side : SCMHorseMountSide)
	{
		var anim : name;
		
		switch(side)
		{
			case SCMHMS_LeftFront: {anim = 'horse_dismount_lf_01'; break;}
			case SCMHMS_Right: {anim = 'horse_dismount_rb_01'; break;}
			case SCMHMS_RightFront: {anim = 'horse_dismount_rf_01'; break;}
			case SCMHMS_Left: {anim = 'horse_dismount_lb_01'; break;}
		}
		
		LogSCM("Dismount: " + anim);

		PlayAnims4(parent, anim);
		
		horsePos = horseEntity.GetWorldPosition();
		horseRot = horseEntity.GetWorldRotation();
		
		forceTeleport = true;
	}
}

state SCMMountBoat in CNewNPC extends SCMAnimBase
{
	protected var BoatToMount : W3Boat;
	protected var BoatComp : CBoatComponent;
	protected var NPCComp : CMovingPhysicalAgentComponent;
	
	protected var BoatEntry : MCM_BoatEntry;
	protected var BoatSittingPosition : MCM_BoatPos;
	
	private var FixedPos : Vector;
	private var FixedRot : EulerAngles;
	
	private var SitDownAnim : name;
	private var IdleAnim : name;
	private var StandUpAnim : name;
	
	private var CanSitFront : bool;
	
	private var DismountBoat : bool;
	private var StopCurrentAnim : bool;

	event OnEnterState(prevStateName : name)
	{
		BoatToMount = ((W3Boat)thePlayer.GetUsedVehicle());
		if(BoatToMount)
		{
			parent.scmcc.IsOnBoat = true;
			DismountBoat = false;
			StopCurrentAnim = false;
			
			NPCComp = (CMovingPhysicalAgentComponent)parent.GetComponentByClassName('CMovingPhysicalAgentComponent');
			BoatComp = (CBoatComponent)BoatToMount.GetComponentByClassName('CBoatComponent');
			
			LoopAnim = true;
			LoopCount = -1;
			
			FindCanSitFront();
			
			FindSittingPosition();
			
			if(BoatSittingPosition != MCMBP_Invalid)
			{
				AnimSitDown();
				
				parent.EnableCollisions(false);
				parent.scmcc.PlayTPAnimation(true);
				
				if(syncInstances.Size() == 0)
				{
					AnimLoop();
					if(syncInstances.Size() == 0)
					{
						SitDownAnim = '';
						IdleAnim = 'high_standing_determined_idle';
						StandUpAnim = '';
						
						AnimLoop();
						
						if(syncInstances.Size() == 0)
						{
							RunWithNoAnim();
						}
						else
						{
							super.OnEnterState(prevStateName);
						}
					}
					else
					{
						super.OnEnterState(prevStateName);
					}
				}
				else
				{
					super.OnEnterState(prevStateName);
				}
			}
			else
			{
				RunIdle();
			}
		}
		else
		{
			PopState(true);
		}
	}
		
	event OnLeaveState(nextStateName : name)
	{
		parent.EnableCollisions(true);
		parent.scmcc.IsOnBoat = false;
		
		if(BoatSittingPosition != MCMBP_Invalid)
		{
			BoatEntry.FreePosition(BoatSittingPosition);
		}
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnModSCMMountInfo(tag : name, val : int)
	{
		if(tag == 'DismountBoat')
		{
			if(!DismountBoat)
			{
				StopCurrentAnim = true;
			}
			DismountBoat = true;
		}
	}
	
	function FindCanSitFront()
	{
		var nam : name;
		nam = parent.scmcc.data.nam;
		
		CanSitFront = (nam == 'cirilla' || nam == 'yennefer' || nam == 'triss' || nam == 'shani' || nam == 'anna_henrietta' || nam == 'avallach' || nam == 'baron' || nam == 'becca' || nam == 'butler' || nam == 'crach_an_craite' || nam == 'cyprian_willey' || nam == 'damien' || nam == 'dandelion' || nam == 'dettlaff_van_eretein_vampire' || nam == 'dijkstra' || nam == 'dreamer_corine_tilly' || nam == 'emhyr' || nam == 'eskel' || nam == 'ewald' || nam == 'fringilla_vigo' || nam == 'graden' || nam == 'guillaume' || nam == 'hattori' || nam == 'hjalmar' || nam == 'keira_metz' || nam == 'king_beggar' || nam == 'lambert' || nam == 'letho' || nam == 'margarita' || nam == 'milton_de_peyrac' || nam == 'mh303_succbus_v2' || nam == 'mousesack' || nam == 'mq1058_lynx_witcher' || nam == 'mq1060_witcher' || nam == 'mq1060_witcher_ghost' || nam == 'olgierd' || nam == 'palmerin' || nam == 'philippa_eilhart' || nam == 'pryscilla' || nam == 'q603_circus_artist_companion' || nam == 'q002_huntsman' || nam == 'q603_safecracker_companion' || nam == 'radovid' || nam == 'regis_terzieff_vampire' || nam == 'rosa_var_attre' || nam == 'sq306_sacha' || nam == 'sq106_tauler' || nam == 'syanna' || nam == 'talar' || nam == 'tamara' || nam == 'udalryk' || nam == 'vampire_diva' || nam == 'vernon_roche' || nam == 'ves' || nam == 'vesemir' || nam == 'von_gratz' || nam == 'voorhis');
	}
	
	entry function RunIdle()
	{
		var i : int;
		
		while(true)
		{
			Sleep(0.5);
			
			if(DismountBoat)
			{
				break;
			}
		}
		
		PopState(true);
	}
	
	entry function RunWithNoAnim()
	{
		var i : int;
		
		while(true)
		{
			OnAnimTick();
			
			SleepOneFrame();
			
			if(DismountBoat)
			{
				break;
			}
		}
		
		PopState(true);
	}
	
	function FindSittingPosition()
	{
		BoatEntry = mod_scm_GetSCM().BoatManager.GetBoatEntry(BoatToMount);
		BoatSittingPosition = BoatEntry.GetFreePosition(true, !CanSitFront);
		
		if(BoatSittingPosition != MCMBP_Invalid)
		{
			BoatEntry.GetOffsetFor(BoatSittingPosition, FixedPos, FixedRot);
			BoatEntry.GetStartIdleStopAnimsFor(BoatSittingPosition, SitDownAnim, IdleAnim, StandUpAnim);
		}
	}

	protected function SetupAnims() : bool
	{
		if(DismountBoat)
		{
			syncInstances.Clear();
			LoopAnim = false;
			parent.EnableCollisions(false);
			AnimGetUp();
		}
		else
		{
			AnimLoop();
		}
		
		return false;
	}
	
	function AnimLoop()
	{
		PlayAnims4(parent, IdleAnim);
	}
	
	function AnimGetUp()
	{
		if(StandUpAnim != '') PlayAnims4(parent, StandUpAnim);
	}
	
	function AnimSitDown()
	{
		if(SitDownAnim != '') PlayAnims4(parent, SitDownAnim);
	}

	protected function OnAnimTick()
	{
		var BoatPos : Vector;
		var BoatRot : EulerAngles;
		var RotMatrix : Matrix;
		var TpPos : Vector;
		var TpRot : EulerAngles;
		
		if(StopCurrentAnim)
		{
			StopCurrentAnim = false;
			StopAllAnimations();
		}
		
		if(LoopAnim)
		{
			BoatPos = BoatToMount.GetWorldPosition();
			BoatRot = BoatToMount.GetWorldRotation();
			
			RotMatrix = RotToMatrix(BoatRot);
			
			TpPos = BoatPos + VecTransform(RotMatrix, FixedPos);
			
			TpRot.Pitch = BoatRot.Pitch + FixedRot.Pitch;
			TpRot.Yaw = BoatRot.Yaw + FixedRot.Yaw;
			TpRot.Roll = BoatRot.Roll + FixedRot.Roll;
			
			parent.TeleportWithRotation(TpPos, TpRot);
		}
	}
}

state SCMPlayIdleAnim in CNewNPC extends SCMAnimBase
{
	var AnimName : name;
	var FixedPos : Vector;
	var FixedRot : EulerAngles;
	var FixInPlace : bool;
	
	var DEBUG_MOVE : bool; default DEBUG_MOVE = false;

	event OnEnterState(prevStateName : name)
	{
		if(parent.scmcc.info.HasIdleAnimation)
		{
			parent.EnableCollisions(false);
			
			AnimName = parent.scmcc.info.IdleAnimation;
			AnimSpeed = parent.scmcc.info.IdleAnimationSpeed;

			FixInPlace = parent.scmcc.info.FixIdleAnimInPos;
			FixedPos = parent.scmcc.info.SpawnPos.Position;
			FixedRot = parent.scmcc.info.SpawnPos.Rotation;
			
			PlayAnims4(parent, AnimName);
			
			LoopAnim = true;
			LoopCount = -1;
			
			if(syncInstances.Size() == 0)
			{
				PopState(true);
			}
			else
			{
				super.OnEnterState(prevStateName);
			}
		}
		else
		{
			PopState(true);
		}
		
		if(DEBUG_MOVE)
		{
			theInput.RegisterListener(this, 'OnTransUp', 'SCMUp');
			theInput.RegisterListener(this, 'OnTransLeft', 'SCMLeft');
			theInput.RegisterListener(this, 'OnTransRight', 'SCMRight');
			theInput.RegisterListener(this, 'OnTransDown', 'SCMDown');
			theInput.RegisterListener(this, 'OnTransTop', 'Debug_TeleportToPin');
			theInput.RegisterListener(this, 'OnTransBottom', 'Debug_KillAllEnemies');
			theInput.RegisterListener(this, 'OnRot1', 'SCMRot1');
			theInput.RegisterListener(this, 'OnRot2', 'SCMRot2');
			theInput.RegisterListener(this, 'OnAmplify', 'WalkToggle');
			
			KeyStates.Grow(9);
		}
	}
	
	var KeyStates : array<bool>;
	
	event OnTransUp(action : SInputAction) { KeyStates[0] = IsPressed(action); }
	event OnTransLeft(action : SInputAction) { KeyStates[1] = IsPressed(action); }
	event OnTransRight(action : SInputAction) { KeyStates[2] = IsPressed(action); }
	event OnTransDown(action : SInputAction) { KeyStates[3] = IsPressed(action); }
	event OnTransTop(action : SInputAction) { KeyStates[4] = IsPressed(action); }
	event OnTransBottom(action : SInputAction) { KeyStates[5] = IsPressed(action); }
	event OnRot1(action : SInputAction) { KeyStates[6] = IsPressed(action); }
	event OnRot2(action : SInputAction) { KeyStates[7] = IsPressed(action); }
	event OnAmplify(action : SInputAction) { KeyStates[8] = IsPressed(action); }
	
	function UpdateFixedPos()
	{
		var trans : Vector;
		var rot : EulerAngles;
		var changed : bool = false;
		var cameraAngle : float;

		if(KeyStates[0]) {trans += Vector(0, 1, 0); changed = true;}
		if(KeyStates[1]) {trans += Vector(-1, 0, 0); changed = true;}
		if(KeyStates[2]) {trans += Vector(1, 0, 0); changed = true;}
		if(KeyStates[3]) {trans += Vector(0, -1, 0); changed = true;}
		if(KeyStates[4]) {trans += Vector(0, 0, 1); changed = true;}
		if(KeyStates[5]) {trans += Vector(0, 0, -1); changed = true;}
		if(KeyStates[6]) {rot.Yaw += 1; changed = true;}
		if(KeyStates[7]) {rot.Yaw -= 1; changed = true;}
		
		if(changed)
		{
			if(KeyStates[8])
			{
				trans /= 10;
				rot.Yaw /= 2;
			}
			else
			{
				trans /= 100;
				trans.Z /= 6;
				rot.Yaw /= 20;
			}
			
			cameraAngle = Deg2Rad(theCamera.GetCameraHeading());
			
			trans = VecRotateAxis(trans, Vector(0, 0, 1), cameraAngle);
		
			FixedPos += trans;
			FixedRot.Yaw += rot.Yaw;
			
			LogSCM("POSROT: " + VecToString(FixedPos) + "  " + FixedRot.Yaw + " Degrees");
		}
	}
		
	event OnLeaveState(nextStateName : name)
	{
		parent.EnableCollisions(true);
		if(DEBUG_MOVE)
		{
			theInput.UnregisterListener(this, 'SCMUp');
			theInput.UnregisterListener(this, 'SCMLeft');
			theInput.UnregisterListener(this, 'SCMRight');
			theInput.UnregisterListener(this, 'SCMDown');
			theInput.UnregisterListener(this, 'SCMRot1');
			theInput.UnregisterListener(this, 'SCMRot2');
		}
		
		super.OnLeaveState(nextStateName);
	}
	
	protected function SetupAnims() : bool
	{
		PlayAnims4(parent, AnimName);
		return false;
	}
	
	protected function OnAnimTick()
	{
		if(FixInPlace)
		{
			if(DEBUG_MOVE)UpdateFixedPos();
		
			parent.TeleportWithRotation(FixedPos, FixedRot);
		}
	}
}/*

state SCMMountADamnHorseBase in CNewNPC extends SCMAnimBase
{
	protected var myHorse : CNewNPC;
	protected var horsePos : Vector;
	protected var horseRot : EulerAngles;
	
	event OnEnterState(prevStateName : name)
	{
		super.OnEnterState(prevStateName);
	}

	protected function SetupAnims() : bool
	{
		SetupAnimsForSide(parent.scmcc.SIDE);
		return false;
	}
	
	protected function SetupAnimsForSide(side : SCMHorseMountSide)
	{

	}
	
	protected function OnAnimTick()
	{
		myHorse.TeleportWithRotation(horsePos, horseRot);
	}
}

state SCMMountADamnHorse in CNewNPC extends SCMMountADamnHorseBase
{
	event OnEnterState(prevStateName : name)
	{
		parent.scmcc.EnsureHorseExists();
		this.myHorse = parent.scmcc.myHorse;
		
		myHorse.Teleport(parent.GetWorldPosition());
		
		SetupAnimsForSide(RandRange(5, 0));
		
		LoopAnim = false;
		
		horsePos = parent.GetWorldPosition();
		horseRot = EulerAngles(0, 0, 0);
		
		super.OnEnterState(prevStateName);
	}
	
	event OnLeaveState(nextStateName : name)
	{ 
		parent.scmcc.MountHorseNOW();
	}
	
	public function SetupPos(deltaVec : Vector, deltaRot : float)
	{
		var actorPosition, horsePosition : Vector;
		var actorRotation, horseRotation : EulerAngles;
		
		actorPosition = parent.GetWorldPosition() + deltaVec; // + VecRotateAxis(deltaVec, Vector(0, 0, 1), horseHeading);
		actorRotation = EulerAngles(0, deltaRot, 0);
		
		horsePosition = parent.GetWorldPosition();
		horseRotation = EulerAngles(0, 0, 0);
		
		myHorse.TeleportWithRotation(horsePosition, horseRotation);
		parent.TeleportWithRotation(actorPosition, actorRotation);
	}
	
	protected function SetupAnimsForSide(side : SCMHorseMountSide)
	{
		var anims : array<name>;
		var deltaVec : Vector;
		var deltaRot : float;
		anims.Grow(2);
		
		switch(side)
		{
			case SCMHMS_Back: {anims[0] = 'horse_mount_B_01'; anims[1] = 'horse_mount_b_stop'; deltaVec = Vector(0.000000,-3.142929,0.000000); deltaRot = 0; break;} //DELTA XYZ PYR: []  .  [0.000000]
			case SCMHMS_Left: {anims[0] = 'horse_mount_L'; anims[1] = 'horse_mount_l_stop'; deltaVec = Vector(-0.514160,0.057144,0.000000); deltaRot = -85; break;} //DELTA XYZ PYR: []  .  [-85.000000]
			case SCMHMS_LeftFront: {anims[0] = 'horse_mount_LF'; anims[1] = 'horse_mount_lf_stop'; deltaVec = Vector(-0.728394,1.185741,0.000000); deltaRot = -170; break;} //DELTA XYZ PYR: []  .  [-170.000000]
			case SCMHMS_Right: {anims[0] = 'horse_mount_R_01'; anims[1] = 'horse_mount_r_stop'; deltaVec = Vector(0.671265,0.285721,0.000000); deltaRot = -258; break;} //DELTA XYZ PYR: []  .  [-258.000000]
			default: {anims[0] = 'horse_mount_RF_01'; anims[1] = 'horse_mount_rf_stop'; deltaVec = Vector(0.642700,1.514320,0.000000); deltaRot = -184; break;} //DELTA XYZ PYR: []  .  [-184.000000]
			//SCMHMS_RightFront
		}
		
		deltaVec.Z = 0.1;
		//parent.TeleportWithRotation(parent.scmcc.NPC_POS, parent.scmcc.NPC_ROT);
		//myHorse.TeleportWithRotation(parent.scmcc.HORSE_POS, parent.scmcc.HORSE_ROT);
		
		SetupPos(deltaVec, deltaRot);
		
		PlayAnims(anims, parent);
	}
}

state SCMDismountADamnHorse in CNewNPC extends SCMMountADamnHorseBase
{
	event OnEnterState(prevStateName : name)
	{
		this.myHorse = parent.scmcc.myHorse;
		
		if(myHorse)
		{
			SetupAnimsForSide(RandRange(4, 0));
			
			horsePos = myHorse.GetWorldPosition();
			horseRot = myHorse.GetWorldRotation();
			
			LoopAnim = false;
			super.OnEnterState(prevStateName);
		}
		else
		{
			PopState(true);
		}
	}
	
	event OnLeaveState(nextStateName : name)
	{ 
		parent.scmcc.DismountHorseNOW(true);
		parent.scmcc.RemoveHorseAI();
	}
	
	protected function SetupAnimsForSide(side : SCMHorseMountSide)
	{
		var anims : array<name>;
		var deltaVec : Vector;
		var deltaRot : float;
		anims.Grow(1);
		
		switch(side)
		{
			case SCMHMS_LeftFront: {anims[0] = 'horse_dismount_lf_01';}
			case SCMHMS_Right: {anims[0] = 'horse_dismount_rb_01';}
			case SCMHMS_RightFront: {anims[0] = 'horse_dismount_rf_01';}
			default: {anims[0] = 'horse_dismount_lb_01';}
		}

		PlayAnims(anims, parent);
	}
}*/
