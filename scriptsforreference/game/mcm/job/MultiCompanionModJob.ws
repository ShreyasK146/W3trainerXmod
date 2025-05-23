
class MCM_JobActionPoint
{
    public var actionPointName : name;
    public var position : Vector;
    public var rotation : EulerAngles;
    public var workerUsing : MCM_Worker;
    public var activationRadius : float;
    public var isOutside : bool;

    public function ToString() : String
    {
        return actionPointName + ": Pos(" + MCM_VecToStringPrec(position, 1) + ") Rot(" + MCM_EulerToStringPrec(rotation, 1) + ") Being Used By " + workerUsing;
    }
    
    public var hasFact : bool;
    public var fact : MCM_SFactCheck;

    public function fact(fact : MCM_SFactCheck) : MCM_JobActionPoint 
    {
        this.hasFact = true;
        this.fact = fact;
        return this;
    }

    public function checkFact() : bool
    {
        return !this.hasFact || MCM_CheckFact(this.fact);
    }

    public function checkNotOccupied() : bool
    {
        var entities : array<CGameplayEntity>;
        var i : int;
        FindGameplayEntitiesInSphere(entities, position, 0.2, 10);
        for(i = 0; i < entities.Size(); i+= 1)
        {
            if(((CActor)entities[i])) {
                return false;
            }
        }
        return true;
    }
}

class MCM_ActionEntry
{
    public var index : int;
    public var action : MCM_JobAction;
    public var actionPoint : MCM_JobActionPoint;
    public var maxTimePerform : int;

    //If the action requires us to interact with an object in the world
    public var isInteractingWithObject : bool;

    public latent function performAction(worker : MCM_Worker)
    {
        LogMCM_Job("Performing Action!");
        action.performAction(worker, this);
    }  
    
    public function Print()
    {
        LogMCM_Job("        ActionEntry: " + index + " " + action + " " + actionPoint.ToString());
    }

    public function ApplyAppearanceForActionType(actor : CNewNPC) : bool
    {
        if(FactsQuerySum('MCM_DisableAppearanceChanging') == 0)
        {
            if(actor && actor.scmcc && IsNameValid(this.action.actionCategory))
            {
                switch(this.action.actionCategory)
                {
                    case 'sleep': actor.scmcc.applyUnderwearAppearance(); return true;
                    case 'naked': actor.scmcc.applyNakedAppearance(); return true;
                }
            }
        }
        
        return false;
    }
}

class MCM_Job 
{
    public var jobName : name;
    public var jobCategory : name;

    public var actions : array<MCM_ActionEntry>;

    public var hasFact : bool; default hasFact = false;
    public var fact : MCM_SFactCheck;

    public function Print()
    {
        var sz, i : int;
        LogMCM_Job("    Job " + jobName);
        sz = actions.Size();
        for(i = 0; i < sz; i+=1)
        {
            actions[i].Print();
        }
    }

    public function canPerformJob() : bool
    {
        return !hasFact || MCM_CheckFact(this.fact);
    }

    public function setFact(fact : MCM_SFactCheck) : MCM_Job
    {
        this.hasFact = true;
        this.fact = fact;
        return this;
    }

    public function addAction(action : MCM_JobAction, actionPoint : MCM_JobActionPoint, 
	optional maxTimePerform : int, optional isInteractingWithObject : bool) : MCM_Job
    {
        var actionEntry : MCM_ActionEntry;
        actionEntry = new MCM_ActionEntry in this;
        actionEntry.index = actions.Size();
        actionEntry.action = action;
        actionEntry.actionPoint = actionPoint;
        actionEntry.maxTimePerform = maxTimePerform;
        actionEntry.isInteractingWithObject = isInteractingWithObject;

        actions.PushBack(actionEntry);

        return this;
    }

    //Attempts to find a new and different action to perform.
    //If there are no new action to perform, then it just returns the same action.
    public function getNewAction(optional oldAction : MCM_ActionEntry) : MCM_ActionEntry
    {
        var newCandidates : array<MCM_ActionEntry>;
        var i : int;

        for(i = actions.Size()-1; i >= 0; i-=1)
        {
            if((!actions[i].actionPoint.workerUsing || !actions[i].actionPoint.workerUsing.actor) && actions[i].actionPoint.checkFact()) 
            {
                if(actions[i].actionPoint.checkNotOccupied())
                {
                    actions[i].actionPoint.workerUsing = NULL;
                    if(actions[i] != oldAction)
                    {
                        newCandidates.PushBack(actions[i]);
                    }
                } else {
                    // LogSCM("Job Position is occupied");
                }
            }
        }
        if(newCandidates.Size() > 0)
        {
            return newCandidates[RandRange(newCandidates.Size())];
        }
        else if(!oldAction.actionPoint.workerUsing)
        {
            return oldAction;
        }
        return NULL;
    }
}
