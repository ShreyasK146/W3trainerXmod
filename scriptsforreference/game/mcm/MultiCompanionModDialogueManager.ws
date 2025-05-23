
statemachine class MCM_DialogueManager extends CObject
{
	protected var chatQueue : array<mod_scm_NPCChatElement>;
	protected var lastActor : CActor;
	
	public function clearHUD()
	{
		var hud : CR4ScriptedHud;
		if(lastActor)
		{
			hud = (CR4ScriptedHud)theGame.GetHud();
			
			hud.HideOneliner(lastActor);
		}
	}
	
	private var isInit : bool; default isInit = false;
	public function init()
	{
		if(isInit) return;
		isInit = true;
	}
	
	public function AddChat(chatElement : mod_scm_NPCChatElement)
	{
		chatQueue.PushBack(chatElement);
			
		if(!IsInState('MCM_DM_Talking'))
		{
			GotoState('MCM_DM_Talking');
		}
	}
}

state MCM_DM_Idle in MCM_DialogueManager
{
}

state MCM_DM_Talking in MCM_DialogueManager
{
	event OnEnterState( prevStateName : name )
	{
		Run();
	}
	
	event OnLeaveState( nextStateName : name)
	{
		parent.clearHUD();
	}
	
	var delayTime : float;
	
	entry function Run()
	{
		while(parent.chatQueue.Size() > 0)
		{
			playNextDialogue();
			if(delayTime > 0)
			{
				Sleep(delayTime);
			}
		}
		parent.GotoState('MCM_DM_Idle');
	}
	
	function playNextDialogue()
	{
		var chatElement : mod_scm_NPCChatElement;
		var actor : CActor;
		
		var hud : CR4ScriptedHud;
		
		parent.clearHUD();
		
		if(parent.chatQueue.Size() > 0)
		{
			chatElement = parent.chatQueue[0];
			
			if(chatElement.entSpecialID == 'PLAYER')
			{
				actor = thePlayer;
			}
			else
			{
				actor = mod_scm_GetNPC(chatElement.entSpecialID, ST_Special);
			}
			
			if(actor)
			{
				actor.PlayLine(chatElement.talkingID, true);
				
				if(!chatElement.playedOnce)
				{
					chatElement.playedOnce = true;
					delayTime = 0.1;
				}
				else
				{
					parent.chatQueue.Erase(0);
					delayTime = chatElement.time;
					
					{
						hud = (CR4ScriptedHud)theGame.GetHud();
						hud.ShowOneliner(chatElement.talkingString, actor);
					}
				}
			}
			else
			{
				delayTime = chatElement.time;
			}
			
			parent.lastActor = actor;
		}
	}
}
