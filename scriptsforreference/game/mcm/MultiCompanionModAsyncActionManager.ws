/*
 * An Asynchronous action.
 * Calls 'Ready' and once that returns true, calls 'PerformAction'
 * If PerformAction returns true, then the action is deleted.
 */

abstract class MCM_AsyncAction
{
	//Check if action is ready. Passed 'DeltaTime' since last check
    public function Ready(DT : float) : bool;
	//Return true if action completed
    public function PerformAction() : bool;
}

/*
 * An delayed action. 'PerformAction' is called after 'delayTimeRemaining'
 */

abstract class MCM_DelayedAsyncAction extends MCM_AsyncAction
{
	public var delayTimeRemaining : float;

	public function Ready(DT : float) : bool
	{
		delayTimeRemaining -= DT;
		return delayTimeRemaining <= 0;
	}
}

/*
 * An delayed dialogue action.
 */

class MCM_DelayedDialogueAction extends MCM_DelayedAsyncAction
{
	private var doneOnce : bool; default doneOnce = false;

	public var actor : CActor;
	public var dialogueID : int;

	public function PerformAction() : bool
	{
		//If the actor has died or something, then do nothing and finish.
		if(!actor) return true;

		actor.PlayLine(dialogueID, true);
		if(doneOnce)
		{
			return true;
		}
		doneOnce = true;
		return false;
	}
}

class MCM_DelayedTpPlayerAction extends MCM_DelayedAsyncAction
{
	public var npc : CNewNPC;

	public function PerformAction() : bool
	{
		if(npc && npc.scmcc)
		{
			npc.scmcc.tpToPlayer(MCM_TPP_Front);
			npc.scmcc.autoTpToPlayer = true;
		}
		return true;
	}
}

statemachine class MCM_AsyncActionManager extends CObject
{
	protected var actions : array<MCM_AsyncAction>;

	private var isInit : bool; default isInit = false;
	public function init()
	{
		if(isInit) return;
		isInit = true;
		GotoState('Idle');
		//Do nothing...
	}

	public function AddAction(action : MCM_AsyncAction)
	{
		actions.PushBack(action);
		if(!IsInState('Running'))
		{
			GotoState('Running');
		}
	}

	public function AddDelayedAction(action : MCM_DelayedAsyncAction, time : float)
	{
		action.delayTimeRemaining = time;
		actions.PushBack(action);
		if(!IsInState('Running'))
		{
			GotoState('Running');
		}
	}

	public function AddDelayedDialogue(actor : CActor, dialogueID : int, delay : float)
	{
		var action : MCM_DelayedDialogueAction = new MCM_DelayedDialogueAction in this;

		action.actor = actor;
		action.dialogueID = dialogueID;

		AddDelayedAction(action, delay);
	}

	public function AddDelayedTpToPlayer(npc : CNewNPC, delay : float)
	{
		var action : MCM_DelayedTpPlayerAction = new MCM_DelayedTpPlayerAction in this;

		action.npc = npc;
		npc.scmcc.autoTpToPlayer = false;

		AddDelayedAction(action, delay);
	}
}

state Idle in MCM_AsyncActionManager
{

}

state Running in MCM_AsyncActionManager
{
    private const var DT : float; default DT = 0.05f;

	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		LogSCM("ENTERING ASYNCACTIONMANAGER STATE");
		Run();
	}
	
	event OnLeaveState( nextStateName : name)
	{
		super.OnLeaveState(nextStateName);
		LogSCM("LEAVING ASYNCACTIONMANAGER STATE");
	}

	entry function Run()
	{
		var i : int;

		while(parent.actions.Size() > 0)
		{
			Sleep(DT);
			for(i = 0; i < parent.actions.Size(); i+=1)
			{
				if(parent.actions[i].Ready(DT))
				{
			if(parent.actions[i].PerformAction())
                    	{
				parent.actions.Remove(parent.actions[i]);
				i-=1;
                    	}
				}
			}
		}
		LogSCM("Done!?");
		GotoState('Idle');
		parent.GotoState('Idle');
		virtual_parent.GotoState('Idle');
	}
}
