
enum SCMHorseMountSide
{
	SCMHMS_Back,
	SCMHMS_Left,
	SCMHMS_LeftFront,
	SCMHMS_Right,
	SCMHMS_RightFront,
}

statemachine class SCMSyncAnimationManager
{
	default autoState = 'Idle';
	
	protected var syncInstances : array< CAnimationManualSlotSyncInstance >;
	public var npc : CNewNPC;
	public var syncActionName : name;
	protected var animSpeed : float; default animSpeed = 1.0;
	
	public function setAnimSpeed(speed : float)
	{
		animSpeed = speed;
	}
	
	public function setNPC(npc : CNewNPC)
	{
		this.npc = npc;
	}
	
	public function CreateNewSyncInstance(out index : int) : CAnimationManualSlotSyncInstance
	{
		var newSyncInstance : CAnimationManualSlotSyncInstance;
		
		newSyncInstance = new CAnimationManualSlotSyncInstance in this;
		syncInstances.PushBack(newSyncInstance);
		
		index = syncInstances.Size() - 1;
		
		GotoState('Active', true);
		
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
	
	private function CreatePart(animName : name, index : int, optional finalPos : Vector) : SAnimationSequencePartDefinition
	{
		var masterSequencePart : SAnimationSequencePartDefinition;
		masterSequencePart.animation = animName;
		masterSequencePart.syncType = AMST_SyncBeginning;
		masterSequencePart.syncEventName = 'SyncEvent';
		masterSequencePart.shouldSlide = false;
		masterSequencePart.shouldRotate = false;
		masterSequencePart.blendInTime = 0;
		masterSequencePart.blendOutTime = 0;
		masterSequencePart.sequenceIndex = index;
		if(finalPos.X != 0 || finalPos.Y != 0 || finalPos.Z != 0)
		{
			masterSequencePart.finalPosition = finalPos;
			masterSequencePart.shouldSlide = true;
		}
		
		return masterSequencePart;
	}
	
	public function PlayAnims(anims : array<name>, master : CEntity, optional freezeAtEnd : bool, optional finalPos : Vector, optional startFrom : float) : bool
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
				masterDef.parts.PushBack(CreatePart(anims[i], i, finalPos));		
			}
		
			masterDef.entity = master;
			masterDef.manualSlotName = 'GAMEPLAY_SLOT';
			masterDef.freezeAtEnd = freezeAtEnd;
		}
		
		//thePlayer.BlockAction(EIAB_Interactions, 'SyncManager');
		//thePlayer.BlockAction(EIAB_FastTravel, 'SyncManager');
		
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
		if(startFrom > 0)
		{
			syncInstance.Update(startFrom);
		}
		return true;
	}
	
	public function PlayAnim(animName : name, master : CEntity, optional freezeAtEnd : bool, optional finalPos : Vector, optional startFrom : float) : bool
	{
		var anims : array<name>;
		anims.PushBack(animName);
		
		return PlayAnims(anims, master, freezeAtEnd, finalPos, startFrom);
		
		/*var masterDef : SAnimationSequenceDefinition;
		var masterSequencePart : SAnimationSequencePartDefinition;
		var syncInstance : CAnimationManualSlotSyncInstance;
		var instanceIndex, sequenceIndex : int;
		var finisherAnim : bool;
		var actorMaster : CActor;
		
		syncInstance = CreateNewSyncInstance(instanceIndex);
		
		{
			masterSequencePart = CreatePart(animName, 0);
			
			masterDef.parts.PushBack(masterSequencePart);			
			masterDef.entity = master;
			masterDef.manualSlotName = 'GAMEPLAY_SLOT';
			masterDef.freezeAtEnd = false;
		}
		
		//thePlayer.BlockAction(EIAB_Interactions, 'SyncManager');
		//thePlayer.BlockAction(EIAB_FastTravel, 'SyncManager');
		
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
		
		return true;*/
	}
	
	function stopAllAnims()
	{
		var size : int = syncInstances.Size();
		var i : int;
		
		for(i = size - 1; i >= 0; i -= 1)
		{
			syncInstances[i].StopSequence(0);
		}
		
		syncInstances.Clear();
	}
}

state Idle in SCMSyncAnimationManager
{

}

state Active in SCMSyncAnimationManager
{
	event OnEnterState(prevStateName : name)
	{
		super.OnEnterState(prevStateName);
		Run();
	}
	
	event OnLeaveState(prevStateName : name)
	{
		super.OnLeaveState(prevStateName);
		
		//parent.masterEntity.OnSyncAnimEnd();
		//parent.slaveEntity.OnSyncAnimEnd();
		
		//thePlayer.UnblockAction(EIAB_Interactions, 'SyncManager');
		//thePlayer.UnblockAction(EIAB_FastTravel, 'SyncManager');
		thePlayer.BlockAllActions('BTTaskPlaySyncAnim', false);
		thePlayer.SetImmortalityMode(AIM_None, AIC_SyncedAnim);
	}
	
	entry function Run()
	{
		var size : int = parent.syncInstances.Size();
		var i : int;

		while(size > 0)
		{
			for(i = size - 1; i >= 0; i -= 1)
			{
				parent.syncInstances[i].Update(theTimer.timeDelta*parent.animSpeed);
				
				if(parent.syncInstances[i].HasEnded())
				{
					parent.syncInstances.Erase(i);
					if(parent.syncInstances.Size() == 0 && parent.npc && parent.npc.scmcc)
					{
						parent.npc.scmcc.animsFinished();
					}
				}
			}
			
			SleepOneFrame();
			size = parent.syncInstances.Size();
		}
		
		parent.PopState(true);
	}
}

/*class CModSCMAnimSequence {
    var sequenceId: String;
    var slotSyncInstance: CAnimationManualSlotSyncInstance;
    // ------------------------------------------------------------------------
    public function stop() {

        slotSyncInstance.StopSequence(0);
    }
    // ------------------------------------------------------------------------
    public function update(delta: float) { slotSyncInstance.Update(delta); }
    public function hasEnded() : bool { return slotSyncInstance.HasEnded(); }
    // ------------------------------------------------------------------------
}

statemachine class CModSCMAnimationSequencer {
    // ------------------------------------------------------------------------
    default autoState = 'SbUi_Idle';
    // ------------------------------------------------------------------------
    protected var seqInstances: array<CModSCMAnimSequence>;
    protected var masterEntity: CGameplayEntity;

    // ------------------------------------------------------------------------
    public function init(animDirector: CModStoryBoardAnimationDirector) {
		
    }
	public function PlayAnim(animName : name, npc : CNewNPC)
	{
		var anims : array<CName>;
		var result : bool;
		LogChannel('ModSpawnCompanions', "Play Anim1?");
		anims.PushBack(animName);
		LogChannel('ModSpawnCompanions', "Play Anim2?");
		result = setupAnimSequence("testscm", anims, npc);
	
		if(result) LogChannel('ModSpawnCompanions', "Success");
		if(!result) LogChannel('ModSpawnCompanions', "Failure :(");
	
		LogChannel('ModSpawnCompanions', "Play Anim3?");
	}
	
    // ------------------------------------------------------------------------
    private function createNewAnimSequence(sequenceId: String, out index: int) : CModSCMAnimSequence
    {
        var newAnimSequence: CModSCMAnimSequence;

        newAnimSequence = new CModSCMAnimSequence in this;

        newAnimSequence.sequenceId = sequenceId;
        newAnimSequence.slotSyncInstance = new CAnimationManualSlotSyncInstance in newAnimSequence;

        seqInstances.PushBack(newAnimSequence);

        index = seqInstances.Size() - 1;

        return newAnimSequence;
    }
    // ------------------------------------------------------------------------
    private function setupSequencePart(idx: int, animName: CName) : SAnimationSequencePartDefinition
    {
        var sequencePart: SAnimationSequencePartDefinition;

        sequencePart.animation = animName;
        sequencePart.syncType = AMST_SyncBeginning;
        sequencePart.syncEventName = 'SyncEvent';
        sequencePart.shouldSlide = false;
        sequencePart.shouldRotate = false;
        sequencePart.blendInTime = 0;
        sequencePart.blendOutTime = 0;
        sequencePart.sequenceIndex = idx;

        return sequencePart;
    }
    // ------------------------------------------------------------------------
    public function setupAnimSequence(sequenceId: String, animNames: array<CName>, entity: CEntity) : bool
    {
        var animSequence: CModSCMAnimSequence;
        var masterDef: SAnimationSequenceDefinition;
        var instanceIndex: int;
        var sequenceIndex: int;
        var i: int;

        var actor: CActor;

        var rot : EulerAngles = entity.GetWorldRotation();
        var pos : Vector = entity.GetWorldPosition();

        animSequence = createNewAnimSequence(sequenceId, instanceIndex);

        for (i = 0; i < animNames.Size(); i += 1)
		{
            masterDef.parts.PushBack(setupSequencePart(i, animNames[i]));
        }
        masterDef.entity = entity;
        masterDef.manualSlotName = 'GAMEPLAY_SLOT';
        masterDef.freezeAtEnd = true;

        sequenceIndex = animSequence.slotSyncInstance.RegisterMaster(masterDef);
        if (sequenceIndex == -1)
		{
            seqInstances.Remove(animSequence);
            return false;
        }

        actor = (CActor)entity;
        if (actor) {
            actor.SignalGameplayEventParamInt('SetupSyncInstance', instanceIndex);
            actor.SignalGameplayEventParamInt('SetupSequenceIndex', sequenceIndex);
            actor.SignalGameplayEvent('PlaySyncedAnim');
        }

        return true;
    }
    // ------------------------------------------------------------------------
    public function startAnimations() {
        if (GetCurrentStateName() != 'SbUi_Active' && seqInstances.Size() > 0) {
            GotoState('SbUi_Active', true);
        }
    }
    // ------------------------------------------------------------------------
    public function stopAnimations() {
        var i: int;

        for (i = seqInstances.Size() - 1; i >= 0; i -= 1) {
            seqInstances[i].stop();
        }
    }
    // ------------------------------------------------------------------------
    public function stopAnimationsFor(animSequenceId: String) {
        var i: int;

        for (i = seqInstances.Size() - 1; i >= 0; i -= 1) {
            if (seqInstances[i].sequenceId == animSequenceId) {
                seqInstances[i].stop();
            }
        }
    }
    // ------------------------------------------------------------------------
}

class ModSCMAnimManager
{
	var syncManager : W3SyncAnimationManager;
	
	private var init : bool; default init = false;
	public function init()
	{
		if(init) return;
		init = true;
		
		syncManager = theGame.GetSyncAnimManager();
	}
	
	function scm_CreateNewSyncInstance(out index : int) : CAnimationManualSlotSyncInstance
	{
		var newSyncInstance : CAnimationManualSlotSyncInstance;
		
		newSyncInstance = new CAnimationManualSlotSyncInstance in this;
		syncManager.syncInstances.PushBack(newSyncInstance);
		
		index = syncManager.syncInstances.Size() - 1;
		
		syncManager.GotoState('Active', true);
		
		return newSyncInstance;
	}
	
	public function PlayAnim(animName : CName, entity : CEntity)
	{
		
	}
}

function scm_DoAnim()
{

}*/
