
//The class which links an NPC and their schedule.

statemachine class MCM_Worker extends CObject
{
    default autoState = 'Waiting';
    public var actor : CNewNPC;
    public var workerName : name;
    public var schedule : MCM_WorkSchedule;
    public var animComp : CMovingPhysicalAgentComponent;

    public var currentJob : MCM_JobEntry;
    public var currentAction : MCM_ActionEntry;

    public var manager : MCM_JobManager;

    public var justSpawned : bool;

    public function Print()
    {
        LogSCM("    Worker: " + actor + " " + schedule + " " + currentJob + " " + currentAction);
    }

    public function Log(str : String)
    {
        //LogSCM("{" + actor.scmcc.data.niceName + "}" + str);
    }

    public function createCopy() : MCM_Worker
    {
        var worker : MCM_Worker;
        this.Log("Creating Copy!");
        worker = new MCM_Worker in actor;

        worker.manager = manager;
        worker.actor = actor;
        worker.workerName = workerName;
        worker.schedule = schedule;
        worker.animComp = animComp;
        worker.justSpawned = true;

        return worker;
    }

    public function onTimeJumpResume()
    {
        this.Log("Time Jump Resume GO!");
        GotoStateAuto();
    }

    public function resetRotation() {
        var rot : EulerAngles;
        rot = this.actor.GetWorldRotation();
        rot.Pitch = 0;  rot.Roll = 0;
        this.actor.TeleportWithRotation(this.actor.GetWorldPosition(), rot);
    }

    private var currentSyncInstance : CAnimationManualSlotSyncInstance;
    private var currentSequenceIndex : int;

    private latent function PlayAnimGood(animName : name, time : float, fixInPlace : bool) : bool
    {
        var startPos : Vector;
        var startAngles : EulerAngles;
	var syncInstance : CAnimationManualSlotSyncInstance;
	var masterSequencePart : SAnimationSequencePartDefinition;
	var masterDef : SAnimationSequenceDefinition;

        this.Log("Playing " + animName);
		
        startPos = currentAction.actionPoint.position;
        startAngles = currentAction.actionPoint.rotation;

        this.actor.TeleportWithRotation(startPos, startAngles);
        
        //Create the sync instance
		currentSyncInstance = new CAnimationManualSlotSyncInstance in this.actor;

        //Create the animation entry
		masterSequencePart.animation = animName;
		masterSequencePart.syncType = AMST_SyncBeginning;
		masterSequencePart.syncEventName = 'SyncEvent';
		masterSequencePart.shouldSlide = false;
		masterSequencePart.shouldRotate = false;
		masterSequencePart.blendInTime = 0;
		masterSequencePart.blendOutTime = 0;
		masterSequencePart.sequenceIndex = 0;

        //Add it to the master definition
        	masterDef.parts.PushBack(masterSequencePart);
        	masterDef.entity = this.actor;
        	masterDef.manualSlotName = 'GAMEPLAY_SLOT';
        	masterDef.freezeAtEnd = false;

        //Register the master definition with the syncInstance
        	currentSequenceIndex = currentSyncInstance.RegisterMaster( masterDef );
		if( currentSequenceIndex == -1 )
		{
            	this.Log("Failed to register sync instance");
			return false;
		}
        
        //Play the animation
        currentSyncInstance.Update(0);

        while(!currentSyncInstance.HasEnded() && !this.forceStopped && this.actor)
        {
	    SleepOneFrame();
            currentSyncInstance.Update( theTimer.timeDelta);
            if(fixInPlace)
            {
                this.actor.TeleportWithRotation(startPos, startAngles);
            }
        }

        if(!currentSyncInstance.HasEnded())
        {
            currentSyncInstance.StopSequence(currentSequenceIndex);
        }

        currentSyncInstance = NULL;

        return true;
    }

    public function cancelCurrentAnimation() {
        if(this.currentSyncInstance)
        {
            if(!this.currentSyncInstance.HasEnded())
            {
                this.currentSyncInstance.StopSequence(this.currentSequenceIndex);
            }
        }
    }

    latent function PlayAnim(animName : name, time : float, isInteractingWithObject : bool) : bool
    {
        var res : bool;
        this.Log("Trying to play '" + animName + "'  :  " + time + "  :  " + isInteractingWithObject);

        if(!actor)
        {
            this.Log("Actor No Exist");
            SleepOneFrame();
            return false;
        }
        if(this.forceStopped)
        {
            this.Log("Forcibly Stopped!");
            SleepOneFrame();
            return false;
        }

        animComp.SetEnabledFeetIK(false);
        if(isInteractingWithObject)
        {
            res = PlayAnimGood(animName, time, true);
        }
        else
        {
            res = PlayAnimGood(animName, time, false);
        }

        animComp.SetEnabledFeetIK(true);

        // if(this.isCancelled)
        // {
        //     animComp.PlaySlotAnimationAsync('plzstop', 'NPC_ANIM_SLOT');
        // }

        if(res == false)
        {
            this.Log("Anim Failed to play");
            Sleep(4);
        }

        if(this.forceStopped)
        {
            //LogSCM("I'm done. Lets update states");
            this.updateStates();
        }
        
        return res;
    }

    public function Begin(actor : CNewNPC, schedule : MCM_WorkSchedule)
    {
        this.actor = actor;
        this.schedule = schedule;
        this.animComp = (CMovingPhysicalAgentComponent)actor.GetComponentByClassName('CMovingPhysicalAgentComponent');

        if(this.actor && this.schedule && this.animComp)
        {
            this.Log("All Good Let's Begin");
            this.justSpawned = this.actor.scmcc.justSpawned;
            GotoStateAuto();
        }
        else
        {
            this.Log("Something Failed:");
            this.Log("Actor " + this.actor);
            this.Log("Schedule " + this.schedule);
            this.Log("Anim Comp " + this.animComp);
        }
    }

    public function canActorDoWork() : bool
    {
        return actor && actor.IsAlive() && !actor.GetTarget();
    }

    public function changeSchedule(newSchedule : MCM_WorkSchedule)
    {
        LogSCM("Not Implemented [MCM_Worker#changeSchedule]");
    }

    public function distanceToJobAction() : float
    {
        return VecDistance(this.actor.GetWorldPosition(), currentAction.actionPoint.position);
    }

    public function isInActivationRadius() : bool
    {
        return currentAction && (VecDistance(this.actor.GetWorldPosition(), currentAction.actionPoint.position) < this.currentAction.actionPoint.activationRadius);
    }
    
    public function getEndTime() : int
    {
        var localEndTime : int;
        if(currentAction.maxTimePerform <= 0)
        {
            return currentJob.endTime;
        }
        
        localEndTime = MCM_GameTimeSeconds();
        if(currentAction.maxTimePerform > 0)
        {
            localEndTime += currentAction.maxTimePerform + RandRange(5*60);
        }

        if(localEndTime >= 24*3600) localEndTime -= 24*3600;
        //LogSCM("Local End Time " + localEndTime);
        if(currentJob.startTime < currentJob.endTime)
        {
            if(localEndTime > currentJob.endTime) localEndTime = currentJob.endTime;
        }
        else
        {
            if(localEndTime > currentJob.endTime && localEndTime < currentJob.startTime) localEndTime = currentJob.endTime;
        }
        
        //LogSCM("Got Local End Time " + localEndTime + " from time " + MCM_GameTimeSeconds());
        return localEndTime;
    }

    public function checkIsEndTime(localEndTime : int) : bool
    {
        var time : int = MCM_GameTimeSeconds();
        if(localEndTime == -1) return !currentJob.IsActive();
        //LogSCM("Check end (time, localend, start, end) " + time + "," + localEndTime + "," + currentJob.startTime + "," + currentJob.endTime);
        if(currentJob.startTime < currentJob.endTime)
        {
            return time >= localEndTime;
        }
        else
        {
            return time >= localEndTime && time < currentJob.startTime;
        }
    }

    public function hasValidJobAndAction() : bool
    {
        return this.currentJob && this.currentAction && this.currentJob.IsActive();
    }

    public function hasValidJob() : bool
    {
        return this.currentJob && this.currentJob.IsActive();
    }

    public function cancelAction()
    {
        if(this.currentAction)
        {
            this.currentAction.actionPoint.workerUsing = NULL;
            this.currentAction = NULL;
        }
    }

    public function cancelJob()
    {
        this.currentJob = NULL;
    }

    public function continueInPauseMode() : bool
    {
        return theInput.GetContext() != 'Exploration' || shouldPause();
    }

    public function shouldHideWorker() : bool
    {
        var actorToPlayer : float;
        //var actionToPlayer : float;

        actorToPlayer = VecDistanceSquared(thePlayer.GetWorldPosition(), actor.GetWorldPosition());
        //actionToPlayer = VecDistanceSquared(thePlayer.GetWorldPosition(), this.currentAction.actionPoint.position);
        //actionToPlayer > (75*75) && 
        return actorToPlayer > (75*75);
    }
    
    //If the player is too far away from our current position, or action point, then go to pause state
    public function shouldPause() : bool
    {
        var playerPos, myPos, actionPos : Vector;
        var distToMyPos, distToActionPos : float;

        playerPos = thePlayer.GetWorldPosition();
        myPos = actor.GetWorldPosition();

        distToMyPos = VecDistance(playerPos, myPos);
        distToActionPos = VecDistance(playerPos, actionPos);

        return false;
        //150m
    }

    public function shouldBeWorking() : bool
    {
        return !this.forceStopped && !this.softStopped && this.actor && this.actor.IsAlive();
    }

    public function isActive() : bool
    {
        return !isCancelled();
    }

    public var forceStopped : bool;
    public var softStopped : bool;

    public function isCancelled() : bool
    {
        return !actor || forceStopped;
    }

    public function isStopped() : bool
    {
        return this.softStopped;
    }

    public function softStop()
    {
        this.softStopped = true;
    }

    public function forceStop()
    {
        this.forceStopped = true;
        cancelAction();
        cancelJob();
        cancelCurrentAnimation();
        updateStates();
    }

    public function updateStates()
    {
        if(this.shouldBeWorking())
        {
            if(this.shouldHideWorker())
            {
                if(!this.IsInState('Hidden')) this.GotoState('Hidden');
            }
            else if(!this.hasValidJobAndAction() && (this.IsInState('Working') || this.IsInState('Walking')))
            {
                if(!this.IsInState('Waiting')) this.GotoState('Waiting');
            }
        }
        else
        {
            if(this.forceStopped) {
                if(!this.IsInState('Stop')) this.GotoState('Stop');
            } else if(this.softStopped) {
                if(!this.IsInState('SoftStop')) this.GotoState('SoftStop');
            }
        }
    }

    public function dropItemsInHand()
    {
        actor.DropItemFromSlot( 'r_weapon' );
        actor.DropItemFromSlot( 'l_weapon' );
    }
}

state Stop in MCM_Worker
{
    event OnEnterState( prevStateName : name )
    {
        //LogSCM("In stop state");
        parent.Log("!!!ENTERED STOP STATE!!! from " + prevStateName);
        parent.actor.GetMovingAgentComponent().SetGameplayRelativeMoveSpeed(0);
        parent.cancelAction();
        parent.cancelJob();

        parent.manager.removeWorker(parent);
    }
}

//Basically pretends like the NPC is working by selecting action points
state Hidden in MCM_Worker
{
    private var path : MCM_Path;

    event OnEnterState( prevStateName : name )
	{
        parent.Log("[Hidden] Entering Hidden State");
        MCM_HideNPC(parent.actor);

        parent.actor.GetMovingAgentComponent().SetGameplayRelativeMoveSpeed(0);
        this.currentPos = parent.actor.GetWorldPosition();

        waitForUnhide();
	}

    event OnLeaveState( prevStateName : name )
    {
        parent.Log("[Hidden] Leaving Hidden State");
        MCM_ShowNPC(parent.actor);

        delete this.path; this.path = NULL;
    }

    function teleportToCurrentAction()
    {
        parent.actor.Teleport(currentPos);
      /*var closestNode : MCM_PathNode;

        closestNode = parent.manager.getWorldPath().getClosestNodeTo(currentPos);
        if(closestNode)
        {
            parent.actor.Teleport(closestNode.pos);
            LogSCM("[Hidden Exit] Teleporting Midway through actor walking");
        }
        else
        {
            parent.actor.Teleport(currentPos);
            LogSCM("[Hidden Exit] Couldn't teleport midway through walk. Going straight to new position");
        }*/
    }

    var currentPos : Vector;

    function interpolate(start, end : Vector, amount : float) : Vector
    {
        return (start * (1-amount)) + (end * amount);
    }

    latent function updatePathWalk()
    {
        var moveResult : bool;
        var nextPos : Vector;
        var dist : float;

        var toTravel : float = 20;

        if(!this.path)
        {
            dist = VecDistance(parent.currentAction.actionPoint.position, this.currentPos);
            if(dist > 5)
            {
                createPath_hidden();

                if(!this.path)
                {
                    this.currentPos = parent.currentAction.actionPoint.position;
                    //Couldn't find path. Just teleport if possible
                    
                }
            }
            else
            {
                parent.Log("Walk is done. Just standing around now");
            }
        }

        if(this.path)
        {
            for(; this.path.nodeWalkingTo < this.path.nodes.Size(); this.path.nodeWalkingTo += 1)
            {
                nextPos = this.path.nodes[this.path.nodeWalkingTo];
                dist = VecDistance(nextPos, this.currentPos);
                parent.Log("Fake walking. Up to node " + this.path.nodeWalkingTo + " / " + this.path.nodes.Size());// + ". " + dist + "/" + toTravel);
                //LogSCM("CurrentPos " + MCM_VecToStringPrec(this.currentPos, 2) + "; NextPos " + MCM_VecToStringPrec(nextPos, 2));
                if(dist < toTravel)
                {
                    toTravel -= dist;
                    this.currentPos = nextPos;
                    continue;
                } else {
                    //Convert dist to a percent, 0-1
                    dist = (toTravel / dist);
                    this.currentPos = interpolate(currentPos, nextPos, dist);
                    toTravel = 0;
                    break;
                }
            }
        }

        parent.actor.Teleport(currentPos);
    }

    latent function createPath_hidden()
    {
        var i : int;
        this.path = parent.manager.getWorldPath().createPathThreadSafe(this.currentPos, parent.currentAction.actionPoint.position);
        if(this.path) this.path.nodeWalkingTo = 0;
        //TODO Remove nodes that are in a straightish line, so we only have a few nodes to worry about
        //this.path.simplify();

        if(this.path && false) //Prints the path
        {
	        LogChannel('MCMJM CLEAR', "Do Clear");
            for(i = 0; i < this.path.nodes.Size(); i+=1)
            {
                LogChannel('MCMJM', VecToString(this.path.nodes[i]));
            }
        }
    }

    public function shouldContinueBeingPaused() : bool
    {
        var actorToPlayer : float;
        //var actionToPlayer : float;

        actorToPlayer = VecDistanceSquared(thePlayer.GetWorldPosition(), currentPos);
        //actionToPlayer = VecDistanceSquared(thePlayer.GetWorldPosition(), parent.currentAction.actionPoint.position);

        return actorToPlayer > (75*75);// && actionToPlayer > (75*75);
    }

    entry function waitForUnhide()
    {
        var time : int;

        while(parent.shouldBeWorking() && this.shouldContinueBeingPaused())
        {
            if(parent.hasValidJobAndAction())
            {
                updatePathWalk();
            }
            else
            {
                time = MCM_GameTimeSeconds();
                parent.currentJob = parent.schedule.getJobForTime(time);
                if(parent.currentJob)
                {
                    parent.Log("[Hidden] Found Job!");
                    parent.currentAction = parent.currentJob.job.getNewAction();
                    if(parent.currentAction)
                    {
                        parent.currentAction.actionPoint.workerUsing = parent;
                        //setupNewAction();
                        parent.Log("[Hidden] Found action!");
                    }
                    else
                    {
                        parent.currentJob = NULL;
                    }
                }
            }

            Sleep(5);
        }

        if(parent.hasValidJobAndAction())
        {
            parent.Log("[Hidden Finished] Going to walking state");
            teleportToCurrentAction();
            SleepOneFrame();
            parent.GotoState('Walking');
        }
        else
        {
            parent.Log("[Hidden Finished] Going to waiting state");
            parent.GotoState('Waiting');
        }
    }
}

state Hidden2 in MCM_Worker
{
    event OnEnterState( prevStateName : name )
	{
        parent.Log("[Hidden] Entering Hidden State");
        parent.actor.SetHideInGame(true);
        parent.actor.GetMovingAgentComponent().SetGameplayRelativeMoveSpeed(0);

        currentPos = parent.actor.GetWorldPosition();
        newPos = currentPos;

        waitForUnhide();
	}

    event OnLeaveState( prevStateName : name )
    {
        parent.Log("[Hidden] Leaving Hidden State");
        parent.actor.SetHideInGame(false);
    }

    function teleportToCurrentAction()
    {
        var midPos : Vector;
        var factor : float;
        var closestNode : MCM_PathNode;
        if(currentTime < timeTotal)
        {
            //If we're supposed to be walking to the new action point
            //then teleport midway between the old AP and the new AP.
            factor = currentTime / timeTotal;
            midPos = newPos*factor + currentPos*(1-factor);
            closestNode = parent.manager.getWorldPath().getClosestNodeTo(midPos);
            if(closestNode)
            {
                parent.actor.Teleport(closestNode.pos);
                parent.Log("[Hidden Exit] Teleporting Midway through actor walking");
            }
            else
            {
                parent.actor.Teleport(newPos);
                parent.Log("[Hidden Exit] Couldn't teleport midway through walk. Going straight to new position");
            }
        }
        else
        {
            parent.Log("[Hidden Exit] Teleporting straight to new AP");
            parent.actor.Teleport(newPos);
        }
    }

    var currentPos, newPos : Vector;
    var timeTotal, currentTime : float;

    function setupNewAction()
    {
        parent.Log("[Hidden] Setting up new action");
        newPos = parent.currentAction.actionPoint.position;
        timeTotal = VecDistance(currentPos, newPos) * 1.2;
        currentTime = 0;
    }

    public function updateWalk()
    {
        if(currentTime < timeTotal)
        {
            currentTime += 5;
            if(currentTime >= timeTotal)
            {
                currentPos = newPos;
                parent.actor.Teleport(currentPos);
                parent.Log("[Hidden] Walk done. Updating current pos");
            }
            else
            {
                parent.Log("[Hidden] Pretend new walk");
            }
        }
    }

    public function shouldContinueBeingPaused() : bool
    {
        var actorToPlayer : float;
        var actionToPlayer : float;

        actorToPlayer = VecDistanceSquared(thePlayer.GetWorldPosition(), currentPos);
        actionToPlayer = VecDistanceSquared(thePlayer.GetWorldPosition(), parent.currentAction.actionPoint.position);

        return actorToPlayer > (75*75) && actionToPlayer > (75*75);
    }

    entry function waitForUnhide()
    {
        var time : int;

        while(parent.shouldBeWorking() && this.shouldContinueBeingPaused())
        {
            if(parent.hasValidJobAndAction())
            {
                updateWalk();
            }
            else
            {
                time = MCM_GameTimeSeconds();
                parent.currentJob = parent.schedule.getJobForTime(time);
                if(parent.currentJob)
                {
                    parent.Log("[Hidden] Found Job!");
                    parent.currentAction = parent.currentJob.job.getNewAction();
                    if(parent.currentAction)
                    {
                        parent.currentAction.actionPoint.workerUsing = parent;
                        setupNewAction();
                        parent.Log("[Hidden] Found action!");
                    }
                    else
                    {
                        parent.currentJob = NULL;
                    }
                }
            }

            Sleep(5);
        }

        if(parent.hasValidJobAndAction())
        {
            parent.Log("[Hidden Finished] Going to walking state");
            teleportToCurrentAction();
            SleepOneFrame();
            parent.GotoState('Walking');
        }
        else
        {
            parent.Log("[Hidden Finished] Going to waiting state");
            parent.GotoState('Waiting');
        }
    }
}

state SoftStop in MCM_Worker
{
    event OnEnterState( prevStateName : name )
    {
        parent.manager.removeWorker(parent);
    }
}

state Paused in MCM_Worker
{
    event OnEnterState( prevStateName : name )
	{
	super.OnEnterState( prevStateName );
        parent.Log("Entering Paused State");
        parent.cancelAction();
        parent.cancelJob();
        parent.actor.GetMovingAgentComponent().SetGameplayRelativeMoveSpeed(0);
        parent.Log("Waiting For Unpause");
        waitForUnpause();
	}

    event OnLeaveState( prevStateName : name )
    {
        parent.actor.SetHideInGame(false);
    }

    entry function waitForUnpause()
    {
        Sleep(5);
        while(parent.continueInPauseMode() && parent.actor && parent.actor.IsAlive())
        {
            Sleep(5);
        }
        parent.Log("Unpaused");
        parent.GotoState('Waiting');
    }
}

//No job right now. Just waiting around
state Waiting in MCM_Worker
{
    event OnEnterState( prevStateName : name )
	{
	super.OnEnterState( prevStateName );
        
        parent.cancelAction();
        parent.cancelJob();

        if(parent.isCancelled())
        {
            parent.manager.removeWorker(parent);
        }
        else if (parent.isStopped())
        {
            parent.GotoState('SoftStop');
        }
        else
        {
            WaitForScheduledActivity();
        }
	}
    
    event OnLeaveState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
	}

    entry function WaitForScheduledActivity()
    {
        var time : int;
        parent.Log("Waiting for scheduled activity");

        while(!parent.hasValidJobAndAction())
        {
            if(parent.isCancelled())
            {
                parent.Log("Worker was cancelled.");
                parent.manager.removeWorker(parent);
                return;
            }
            /*if(parent.isPaused())
            {
                Sleep(5);
                continue;
            }*/
            
            time = MCM_GameTimeSeconds();
            parent.currentJob = parent.schedule.getJobForTime(time);
            if(parent.currentJob)
            {
                parent.Log("Found Job " + parent.currentJob.job.jobName);
                parent.currentAction = parent.currentJob.job.getNewAction();
                if(parent.currentAction)
                {
                    parent.Log("Found Action " + parent.currentAction.action.actionName);
                    parent.currentAction.actionPoint.workerUsing = parent;
                    parent.actor.ActivateAndSyncBehavior('Exploration');
                    break;
                }
                else
                {
                    parent.currentJob = NULL;
                    Sleep(5); //Wait a bit, no free actions right now
                }
            } else {
                parent.Log("No job available for the current time");
            }
            Sleep(5);
        }

        if(parent.hasValidJobAndAction())
        {
            if(parent.justSpawned)
            {
                parent.justSpawned = false;
                parent.actor.TeleportWithRotation(parent.currentAction.actionPoint.position, parent.currentAction.actionPoint.rotation);
                parent.Log("Going straight to working state");
                SleepOneFrame();
                parent.GotoState('Working');
            }
            else
            {
                parent.Log("Lets go for a walk");
                parent.GotoState('Walking');
            }
        }
    }
}

//Walking to a new job.
state Walking in MCM_Worker
{
    private var path : MCM_Path;

    event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );

        if(!parent.shouldBeWorking() || !parent.hasValidJobAndAction())
        {
            parent.Log("Entered walking state but parent shouldn't be working / doesn't have a valid job and action");
            SleepForFive();
        }
        else
        {
            if(parent.isInActivationRadius())
            {
                parent.GotoState('Working');
            }
            else
            {
                Run_Walk();
            }
        }
	}

    entry function SleepForFive()
    {
        Sleep(5);
        parent.GotoState('Waiting');
    }

    event OnLeaveState( prevStateName : name )
    {
        delete this.path; this.path = NULL;
        parent.actor.GetMovingAgentComponent().SetGameplayRelativeMoveSpeed(0);
    }

    latent function rotateToFirstHeading()
    {
	var movementAdjustor : CMovementAdjustor;
	var ticket : SMovementAdjustmentRequestTicket;
        var duration : float = 1;
        var point : Vector;

        point = this.path.nodes[0];
		
		movementAdjustor = parent.actor.GetMovingAgentComponent().GetMovementAdjustor();
		movementAdjustor.CancelAll();

		ticket = movementAdjustor.CreateNewRequest( 'MCM_JobWorkerRotate' );
		movementAdjustor.MaxRotationAdjustmentSpeed(ticket, 1000000.f);
		movementAdjustor.AdjustmentDuration(ticket, duration);
		movementAdjustor.RotateTo(ticket, VecHeading(point - parent.actor.GetWorldPosition()));

		Sleep(duration);

        movementAdjustor.Cancel(ticket);
    }

    entry function Run_Walk()
    {
        var dotProd : float;
        createPath_walk();
        if(this.path)
        {
            rotateToFirstHeading();
            followPath();
        }
        else
        {
            parent.Log("Couldn't find a path. Just teleporting once the player looks away");
            while(true)
            {
                Sleep(5);
                dotProd = VecDot( theCamera.GetCameraDirection(), parent.actor.GetWorldPosition() - thePlayer.GetWorldPosition());
                if(dotProd < -20)
                {
                    parent.Log("Teleporting to AP now");
                    parent.actor.Teleport(parent.currentAction.actionPoint.position);
                    break;
                }
                parent.Log("Look Dot prod " + dotProd);
            }
        }

        parent.updateStates();
        parent.GotoState('Working');
    }

    latent function createPath_walk()
    {
        var i : int;

        this.path = parent.manager.getWorldPath().createPathThreadSafe(parent.actor.GetWorldPosition(), parent.currentAction.actionPoint.position);
        if(this.path && false) //Prints the path
        {
	        LogChannel('MCMJM CLEAR', "Do Clear");
            for(i = 0; i < this.path.nodes.Size(); i+=1)
            {
                LogChannel('MCMJM', VecToString(this.path.nodes[i]));
            }
        }
    }

    private const var SECONDS_PER_METER : int; default SECONDS_PER_METER = 2.0f;

    latent function moveToPoint(point : Vector, speed : float) : bool
    {
        var heading : float;
        var dist : float = VecDistance(point, parent.actor.GetWorldPosition());
        var tries : int;
        var movingAgent : CMovingAgentComponent;
        var currentDist : float;
        
        movingAgent = parent.actor.GetMovingAgentComponent();
        
        tries = Max(RoundF(dist * (speed * 1.1) * 10), 10);
        
		movingAgent.SetGameplayRelativeMoveSpeed( speed );
        if(speed > 1)
        {
            movingAgent.SetMoveType(MT_Run);
        }
        else
        {
            movingAgent.SetMoveType(MT_Walk);
        }

        for(; tries >= 0; tries-=1)
        {
            heading = VecHeading(point - parent.actor.GetWorldPosition());
		    movingAgent.SetGameplayMoveDirection( heading );
            Sleep(0.1);
            if(VecDistance(parent.actor.GetWorldPosition(), point) < 0.6) //Can increase this distance for smoother walking, but might bump into things more
            {
                //LogSCM("Reached Point");
                break;
            }
            if(parent.isInActivationRadius()) 
            {
                //LogSCM("Reached JOB");
                break;
            }
            if(parent.forceStopped) break;
        }

	movingAgent.SetGameplayRelativeMoveSpeed( 0 );
        movingAgent.SetMoveType(MT_Walk);

        return tries > 0;
    }

    latent function followPath()
    {
        var tries : int;
        var moveResult : bool;
        var node, nextNode : MCM_PathNode;
        if(!this.path)
        {
            //TODO Wait for player to look away
            parent.actor.Teleport(parent.currentAction.actionPoint.position);
        }
        else
        {
            for(this.path.nodeWalkingTo = 0; this.path.nodeWalkingTo < this.path.nodes.Size(); this.path.nodeWalkingTo += 1)
            {
                parent.updateStates();
                moveResult = moveToPoint(this.path.nodes[this.path.nodeWalkingTo], RandRangeF(1, 0.8));
                
                if(!moveResult)
                {
                    parent.actor.Teleport(this.path.nodes[this.path.nodeWalkingTo]);
                }
            }
            delete this.path;
        }
    }
}

//Currently working at a job
state Working in MCM_Worker
{
    event OnEnterState( prevStateName : name )
	{
	super.OnEnterState( prevStateName );
        if(parent.shouldBeWorking())
        {
            if(parent.hasValidJobAndAction())
            {
                parent.Log("Working...");
                Run_Work();
            }
            else
            {
                parent.Log("Job/Action Expired");
                parent.GotoState('Waiting');
            }
        }
        else
        {
            parent.GotoState('Stop');
        }
	}

    private var appearanceIsModified : bool;

    event OnLeaveState( prevStateName : name )
    {
        parent.Log("Leaving Working state");
        if(parent.actor && parent.actor.scmcc && this.appearanceIsModified)
        {
            parent.Log("Applying normal appearance");
            parent.actor.scmcc.applyNormalAppearance();
        }
        parent.dropItemsInHand();

        //Is this actually needed?
        parent.cancelAction();
        parent.cancelJob();
        parent.resetRotation();
    }

    entry function Run_Work()
    {
        var lastAction : MCM_ActionEntry;

        parent.Log("Run Work");
        if(parent.currentAction) {
            this.appearanceIsModified = parent.currentAction.ApplyAppearanceForActionType(parent.actor);
            parent.Log("Has Parent Current Job. appearanceIsModified=" + appearanceIsModified);
        }

        SleepOneFrame();

        //this.npc.ActivateAndSyncBehavior('Exploration');
        while(parent.shouldBeWorking())
        {
            if(parent.shouldHideWorker())
            {
                parent.GotoState('Hidden');
                return;
            }
            else
            {
                if(parent.hasValidJob())
                {
                    if(!parent.currentAction)
                    {
                        parent.currentAction = parent.currentJob.job.getNewAction(lastAction);
                        if(parent.currentAction)
                        {
                            parent.currentAction.actionPoint.workerUsing = parent;
                            if(!parent.isInActivationRadius())
                            {
                                parent.Log("Distance too far to new job. Need to walk.");
                                parent.GotoState('Walking');
                                return;
                            }
                        }
                    }
                    if(parent.currentAction)
                    {
                        lastAction = parent.currentAction;
                        slideToAction();
                        parent.currentAction.performAction(parent);
                        parent.cancelAction();
                    }
                    else
                    {
                        Sleep(5);
                    }
                }
                else
                {
                    parent.cancelAction();
                    parent.cancelJob();
                    break;
                }
            }
        }

        //Cleanup
        parent.cancelAction();
        parent.cancelJob();

        parent.GotoState('Waiting');
    }

    latent function slideToAction()
    {
        var distance : float;
        var startPos : Vector = parent.actor.GetWorldPosition();
        var endPos : Vector = parent.currentAction.actionPoint.position;
        var startRot : EulerAngles = parent.actor.GetWorldRotation();
        var endRot : EulerAngles = parent.currentAction.actionPoint.rotation;
        var newPos : Vector;
        var newRot : EulerAngles;
        var percent : float;

        var totalTime : float;
        var time : float;
        
        distance = VecDistance(parent.actor.GetWorldPosition(), parent.currentAction.actionPoint.position);

        if(distance > 5 || distance <= 0.001)
        {
            parent.actor.TeleportWithRotation(parent.currentAction.actionPoint.position, parent.currentAction.actionPoint.rotation);
        }
        else if(distance > 0.001)
        {
            if(startRot.Yaw < endRot.Yaw)
            {
                if(endRot.Yaw - startRot.Yaw > 180) {
                    startRot.Yaw += 360;
                }
            }

            totalTime = distance;
            time = 0;
            while(time < totalTime)
            {
                percent = time / totalTime;
                
                newPos = startPos*(1-percent) + endPos*percent;

                newRot.Pitch = startRot.Pitch*(1-percent) + endRot.Pitch*percent;
                newRot.Yaw = startRot.Yaw*(1-percent) + endRot.Yaw*percent;
                newRot.Roll = startRot.Roll*(1-percent) + endRot.Roll*percent;

                parent.actor.TeleportWithRotation(newPos, newRot);

                SleepOneFrame();
                time += theTimer.timeDelta;
            }
        }
    }

    latent function slideToAP()
    {
        parent.actor.TeleportWithRotation(parent.currentAction.actionPoint.position, parent.currentAction.actionPoint.rotation);
    }
}

//latent function ActionMoveToWithHeading( target : Vector, heading : float, optional moveType : EMoveType, optional absSpeed : float, optional radius : float, optional failureAction : EMoveFailureAction ) : bool;	
//latent function ActionSlideTo( target : Vector, duration : float ) : bool;
//latent function ActionSlideToWithHeading( target : Vector, heading : float, duration : float, optional rotation : ESlideRotation  ) : bool;
//latent function ActionRotateTo( target : Vector ) : bool;	
//latent function ActionPlaySlotAnimation( slotName : name, animationName : name, optional blendIn : float, optional blendOut : float, optional continuePlaying : bool ) : bool;

  /*private latent function PlayAnimNoCollide(animName : name, path : MCM_AnimMovementPath) : bool
    {
        var syncInstance : CAnimationManualSlotSyncInstance;
        var masterDef : SAnimationSequenceDefinition;
        var part : SAnimationSequencePartDefinition;
        var sequenceIndex : int;

        var startPos : Vector;
        var newPos : Vector;
        var startAngles : EulerAngles;
        var newAngles : EulerAngles;

        var tmp : Vector;
        var topPos : Vector = Vector(0, 1000, 0);
        var i : int;

        startPos = actor.GetWorldPosition();
        startAngles = actor.GetWorldRotation();

        //startAngles.Yaw += 90;

        LogSCM("Playing with no collide");

        part.animation = animName;
	part.syncType = AMST_SyncBeginning;
	part.syncEventName = 'SyncEvent';
	part.shouldSlide = true;
	part.shouldRotate = false;
	part.blendInTime = 0;
	part.blendOutTime = 0;
	part.sequenceIndex = 0;
        part.finalPosition = startPos + VecRotByAngleXY(path.deltaPos[path.deltaPos.Size()-1], -startAngles.Yaw);// + Vector(1, 0, 0);
        part.disableProxyCollisions = true;

	masterDef.parts.PushBack(part);
        masterDef.entity = actor;
        masterDef.manualSlotName = 'GAMEPLAY_SLOT';
        masterDef.freezeAtEnd = false;

		syncInstance = new CAnimationManualSlotSyncInstance in this;
        sequenceIndex = syncInstance.RegisterMaster( masterDef );
		if( sequenceIndex == -1 )
		{
			return false;
		}
        LogSCM(VecToString(animComp.GetLocalPosition()));
        LogSCM(VecToString(animComp.GetWorldPosition()));

        i = 0;

        while(!syncInstance.HasEnded() && actor)
        {
            if(path && i < path.deltaTimes.Size())
            {
                newPos = startPos + VecRotByAngleXY(path.deltaPos[i], -startAngles.Yaw);
                newAngles.Pitch = startAngles.Pitch + path.deltaRot[i].Pitch;
                newAngles.Yaw = startAngles.Yaw + path.deltaRot[i].Yaw;
                newAngles.Roll = startAngles.Roll + path.deltaRot[i].Roll;

                actor.TeleportWithRotation(newPos, newAngles);
                SleepOneFrame();
                actor.TeleportWithRotation(newPos, newAngles);
            }
            else
            {
                SleepOneFrame();
            }
            syncInstance.Update(theTimer.timeDelta);
            i += 1;
        }

        return true;
    }*/
