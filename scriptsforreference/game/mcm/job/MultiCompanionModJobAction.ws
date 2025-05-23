
class MCM_JobAction
{
    public var actionName : name;
    public var actionCategory : name;
  /*public latent function performJob(worker : MCM_Worker)
    {
        var jobSimpleAnim : MCM_JobActionAnimated;

        jobSimpleAnim = (MCM_JobActionAnimated)this;
        if(jobSimpleAnim) jobSimpleAnim.JobSimpleAnim_performJob(worker);
    }*/

    public latent function performAction(worker : MCM_Worker, actionEntry : MCM_ActionEntry)
    {
        LogMCM_Job("PERFORM ACTION PARENT");
        Sleep(5);
    }
    
    public function Print()
    {
        LogMCM_Job("    Action: " + actionName);
    }
}

class MCM_JobActionMaleFemale extends MCM_JobAction
{
    public var maleAction : MCM_JobAction;
    public var femaleAction : MCM_JobAction;

    public function setMaleAction(maleAction : MCM_JobAction) : MCM_JobActionMaleFemale
    {
        this.maleAction = maleAction;
        return this;
    }

    public function setFemaleAction(femaleAction : MCM_JobAction) : MCM_JobActionMaleFemale
    {
        this.femaleAction = femaleAction;
        return this;
    }

    public latent function performAction(worker : MCM_Worker, actionEntry : MCM_ActionEntry)
    {
        if(worker.actor.IsMan())
        {
            this.maleAction.performAction(worker, actionEntry);
        }
        else if (worker.actor.IsWoman())
        {
            this.femaleAction.performAction(worker, actionEntry);
        }
        else
        {
            worker.Log("Actor is neither man nor woman. What do I do!? Argh");
            Sleep(5);
        }
    }
}

class MCM_JobActionAnimated extends MCM_JobAction
{
    public var startAnims : array<name>;
    public var endAnims : array<name>;
    public var anims : array<name>;

    public var startAnimsT : array<float>;
    public var endAnimsT : array<float>;
    public var animsT : array<float>;

    public latent function performAction(worker : MCM_Worker, actionEntry : MCM_ActionEntry)
    {
        var localEndTime : int = worker.getEndTime();

        worker.actor.TeleportWithRotation(actionEntry.actionPoint.position, actionEntry.actionPoint.rotation);

        OnPreAction(worker);

        worker.Log("Playing Entry Anims");
        playEntryAnims(worker, localEndTime);

        if(worker.checkIsEndTime(localEndTime) || worker.shouldHideWorker()) return;
        while(worker.shouldBeWorking())
        {
            worker.Log("New Idle Anim");
            playRandomAnim(worker, localEndTime);
            if(worker.checkIsEndTime(localEndTime) || worker.shouldHideWorker()) break;
        }

        worker.Log("Playing Exit Anims");
        playExitAnims(worker, localEndTime);
        
        OnPostAction(worker);
    }

    public function OnPreAction(worker : MCM_Worker)
    {
    }

    public function OnPostAction(worker : MCM_Worker)
    {
    }

    public var sequential : bool;

    public function addStart(optional a1, a2, a3, a4, a5 : name) : MCM_JobActionAnimated
    {
        if(IsNameValid(a1)) startAnims.PushBack(a1);
        if(IsNameValid(a2)) startAnims.PushBack(a2);
        if(IsNameValid(a3)) startAnims.PushBack(a3);
        if(IsNameValid(a4)) startAnims.PushBack(a4);
        if(IsNameValid(a5)) startAnims.PushBack(a5);
        return this;
    }

    public function addStartT(optional t1, t2, t3, t4, t5 : float) : MCM_JobActionAnimated
    {
        if(t1 > 0) startAnimsT.PushBack(t1);
        if(t2 > 0) startAnimsT.PushBack(t2);
        if(t3 > 0) startAnimsT.PushBack(t3);
        if(t4 > 0) startAnimsT.PushBack(t4);
        if(t5 > 0) startAnimsT.PushBack(t5);
        return this;
    }

    public function addEnd(optional a1, a2, a3, a4, a5 : name) : MCM_JobActionAnimated
    {
        if(IsNameValid(a1)) endAnims.PushBack(a1);
        if(IsNameValid(a2)) endAnims.PushBack(a2);
        if(IsNameValid(a3)) endAnims.PushBack(a3);
        if(IsNameValid(a4)) endAnims.PushBack(a4);
        if(IsNameValid(a5)) endAnims.PushBack(a5);
        return this;
    }

    public function addEndT(optional t1, t2, t3, t4, t5 : float) : MCM_JobActionAnimated
    {
        if(t1 > 0) endAnimsT.PushBack(t1);
        if(t2 > 0) endAnimsT.PushBack(t2);
        if(t3 > 0) endAnimsT.PushBack(t3);
        if(t4 > 0) endAnimsT.PushBack(t4);
        if(t5 > 0) endAnimsT.PushBack(t5);
        return this;
    }

    public function addAnim(optional a1, a2, a3, a4, a5 : name) : MCM_JobActionAnimated
    {
        if(IsNameValid(a1)) anims.PushBack(a1);
        if(IsNameValid(a2)) anims.PushBack(a2);
        if(IsNameValid(a3)) anims.PushBack(a3);
        if(IsNameValid(a4)) anims.PushBack(a4);
        if(IsNameValid(a5)) anims.PushBack(a5);
        return this;
    }

    public function addAnimT(optional t1, t2, t3, t4, t5 : float) : MCM_JobActionAnimated
    {
        if(t1 > 0) animsT.PushBack(t1);
        if(t2 > 0) animsT.PushBack(t2);
        if(t3 > 0) animsT.PushBack(t3);
        if(t4 > 0) animsT.PushBack(t4);
        if(t5 > 0) animsT.PushBack(t5);
        return this;
    }

    public function sequential(sequential : bool) : MCM_JobActionAnimated
    {
        this.sequential = sequential;
        return this;
    }
    
    latent function playEntryAnims(worker : MCM_Worker, localEndTime : int)
    {
        var i : int;
        for(i = 0; i < startAnims.Size(); i+=1)
        {
            worker.PlayAnim(startAnims[i], startAnimsT[i], worker.currentAction.isInteractingWithObject);
            // if(worker.checkIsEndTime(localEndTime)) return;
        }
    }

    latent function playExitAnims(worker : MCM_Worker, localEndTime : int)
    {
        var i : int;
        for(i = 0; i < endAnims.Size(); i+=1)
        {
            worker.PlayAnim(endAnims[i], endAnimsT[i], worker.currentAction.isInteractingWithObject);
            // if(worker.checkIsEndTime(localEndTime)) return;
        }
    }

    latent function playRandomAnim(worker : MCM_Worker, localEndTime : int)
    {
        var index : int;
        if(anims.Size() > 0)
        {
            index = RandRange(anims.Size(), 0);
            worker.PlayAnim(anims[index], animsT[index], worker.currentAction.isInteractingWithObject);
            // if(worker.checkIsEndTime(localEndTime)) return;
        }
        else
        {
            Sleep(2);
        }
    }
}

class MCM_JobActionSpecial extends MCM_JobAction
{
    public latent function performAction(worker : MCM_Worker, actionEntry : MCM_ActionEntry)
    {
        var actorName : name = worker.actor.scmcc.data.nam;
        var localEndTime : int = worker.getEndTime();

        if(IsNameValid(actorName))
        {
            worker.Log("Special Action for " + actorName);

            switch(actorName)
            {
                case 'cirilla': TASK_CIRI(localEndTime, worker, actionEntry); break;
                case 'triss': TASK_TRISS(localEndTime, worker, actionEntry); break;
                case 'yennefer': TASK_YEN(localEndTime, worker, actionEntry); break;
            }
        }
    }

    //TODO Add this one day.
    /*
        General idea is to have special tasks that each character can perform.
        i.e. Ciri can practice her teleporing
        Yen and Triss can practice using a megascope, or practice spells or something
        Dandelion can play the lute
        Zoltan can swing his axe
        etc
        Should be cool
        But nobody got time for dat right now.
    */
    latent function TASK_CIRI(endTime : int, worker : MCM_Worker, actionEntry : MCM_ActionEntry)
    {

    }
    
    latent function TASK_TRISS(endTime : int, worker : MCM_Worker, actionEntry : MCM_ActionEntry)
    {

    }
    
    latent function TASK_YEN(endTime : int, worker : MCM_Worker, actionEntry : MCM_ActionEntry)
    {

    }
}
