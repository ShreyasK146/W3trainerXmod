
class mod_scm_ScaleEntry
{
	public editable var scaleToReach : float;
	public editable var currentScale : float;
	default currentScale = 1;
	default scaleToReach = 1;
	public editable var npc : CActor;
	public editable var scmcc : SCMCompanionControls;
	public var Destroyed : bool; default Destroyed = false;
	
	public function Update(dt : float)
	{
		var absDelta : float = AbsF(scaleToReach - currentScale);
        	var c1, c2, change : float;

        	if(absDelta != 0)
		{
			change = ClampF(PowF(absDelta, 0.8)*dt * 5, 0.001, 1);

			if(scaleToReach > currentScale)
			{
				currentScale += change;
				if(currentScale > scaleToReach) currentScale = scaleToReach;
			}
			else if(scaleToReach < currentScale)
			{
				currentScale -= change;
				if(currentScale < scaleToReach) currentScale = scaleToReach;
			}
			
			if(scmcc)
			{
				scmcc.scale = currentScale;
			}
			ScaleCMovingPhysicalAgentComponent();
		}
	}
	
	public function Cancel()
	{
		currentScale = 1;
		scaleToReach = 1;
		ScaleCMovingPhysicalAgentComponent();
	}

	private function ScaleCMovingPhysicalAgentComponent()
	{
		var mesh : CMovingPhysicalAgentComponent;
		var meshs : array< CComponent >;
		var i, sz : int;
		meshs = npc.GetComponentsByClassName('CMovingPhysicalAgentComponent');
		sz = meshs.Size();

		for(i = 0; i < sz; i+=1)
		{
			mesh = (CMovingPhysicalAgentComponent)meshs[i];
			
			if(mesh)
			{
				mesh.SetScale(Vector(currentScale, currentScale, currentScale));
			}
		}
	}
}

statemachine class MCM_ScaleManager extends CObject
{
	default	autoState = 'Idle';
	
	var scales : array<mod_scm_ScaleEntry>;

   	private var isInit : bool; default isInit = false;
	public function init()
	{
		if(isInit) return;
		isInit = true;
        //Do nothing...
	}
	
	public function ClearScales()
	{
		var i : int;
		
		for(i = scales.Size()-1; i >= 0; i-=1)
		{
			scales[i].Cancel();
			scales.Erase(i);
		}
	}
	
	public function SetScale(NPC : CActor, scale : float) : mod_scm_ScaleEntry
	{
		var scaleEntry : mod_scm_ScaleEntry;
		
		if(!NPC) return NULL;
		
		scaleEntry = GetScaleEntry(NPC);
		
		if(!scaleEntry)
		{
			scaleEntry = new mod_scm_ScaleEntry in NPC;
			scaleEntry.npc = NPC;
			scaleEntry.scmcc = ((CNewNPC)NPC).scmcc;
			scales.PushBack(scaleEntry);
		}
		
		scaleEntry.scaleToReach = scale;
		
        //If there's now a scale entry to be updated, go to the running state
        if(scales.Size() > 0)
        {
            if(!this.IsInState('Running'))
            {
                this.GotoState('Running');
            }
        }

		return scaleEntry;
	}
	
	public function GetScaleEntry(NPC : CActor) : mod_scm_ScaleEntry
	{
		var i : int;
		
		for(i = scales.Size()-1; i >= 0; i-=1)
		{
			if(scales[i].npc == NPC)
			{
				return scales[i];
			}
		}
		
		return NULL;
	}

    	protected function UpdateScales(dt : float)
    	{
        	var i : int;

		for(i = scales.Size()-1; i >= 0; i-=1)
		{
			if(scales[i] && scales[i].npc)// && scales[i].npc.IsAlive()
			{
				scales[i].Update(dt);
				if(scales[i].currentScale == 1 && scales[i].scaleToReach == 1)
				{
					scales[i].Destroyed = true;
					scales.Erase(i);
				}
			}
			else
			{
				scales.Erase(i);
			}
		}
	}
}

state Idle in MCM_ScaleManager
{
    
}

state Running in MCM_ScaleManager
{
    var running : bool;

    	event OnEnterState( prevStateName : name )
	{
        running = true;
		Run();
	}
	
	event OnLeaveState( nextStateName : name)
	{
        running = false;
	}
	
	var delayTime : float;
	
	entry function Run()
	{
		while(running)
		{
			parent.UpdateScales(theTimer.timeDelta);
            SleepOneFrame();
            
            if(parent.scales.Size() == 0)
            {
                running = false;
                break;
            }
		}
		parent.GotoState('Idle');
	}
}
