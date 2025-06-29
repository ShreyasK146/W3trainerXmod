class mod_UIForTrainer_saved_data_copy
{
	editable var followers : array<UIForTrainerSpawnData>;
}

class mod_UIForTrainer_saved_data
{
	editable saved var followers : array<UIForTrainerSpawnData>;
	
	public function copyFrom(data : mod_UIForTrainer_saved_data)
	{
		var i, sz : int;
		var tmp : UIForTrainerSpawnData;
		
		sz = data.followers.Size();
		this.followers.Clear();
		
		for(i = 0; i < sz; i+=1)
		{
			tmp = new UIForTrainerSpawnData in theGame;
			tmp.copyFrom(data.followers[i]);
			this.followers.PushBack(tmp);
		}
	}
	
	public function AddCompanion(data : UIForTrainerSpawnData)
	{
		followers.PushBack(data);
	}
	
	public function RemoveCompanion(data : UIForTrainerSpawnData) : bool
	{
		var i, sz : int;
		
		sz = followers.Size();
		
		for(i = 0; i < sz; i+=1)
		{
			if(data.equals(followers[i]))
			{
				followers.Remove(followers[i]);
				return true;
			}
		}
		return false;
	}
	
	public function CountCompanions() : int
	{
		return followers.Size();
	}

	public function ClearCompanions()
	{
		followers.Clear();
	}
	
	public function CleanArray()
	{
		var newArr : array<UIForTrainerSpawnData>;
		var i, sz : int;
		
		sz = followers.Size();
		
		for(i = 0; i < sz; i+=1)
		{
			if(followers[i])
			{
				newArr.PushBack(followers[i]);
			}
		}
		
		followers = newArr;
	}
}

function UIForTrainer_fact(nam : name) : bool
{
	return FactsQuerySum(nam) >= 1;
}
statemachine class mod_UIForTrainer extends CObject
{
	default autoState = 'Idle';


	public var MenuManager : UIForTrainer_MenuManager;
	public var EntityList : UIForTrainerMenu_EntityList;


	private var isInit : bool; default isInit = false;
	public function init()
	{
		
		if(isInit) return;
		isInit = true;
		this.GotoState('Idle');
	

		MenuManager = new UIForTrainer_MenuManager in this;
		MenuManager.init();

		EntityList = new UIForTrainerMenu_EntityList in this;
		EntityList.init();

	}

	public function ReloadData()
	{

	}


	
	event OnUIForTrainerMenu(action : SInputAction)
	{
		if(IsPressed(action))
		{
			//GetWitcherPlayer().DisplayHudMessage("hello iam executing");
			this.MenuManager.ToggleWindow();
		}
	}

	
	
	public function timer1second2()
	{

	}


	public function timer250msecond2()
	{
		
	}
	
	var lastGameTime : int;

	var isMeditating : bool;

	var talkCoolDown : int; default talkCoolDown = 0;
	var specialCoolDown : int;
	
	public function timer4second2()
	{
		
	}
	
	
	
	public function onWorldLoaded2()
	{
		
	}



	function registerListeners()
	{
		theInput.RegisterListener(this, 'OnUIForTrainerMenu', 'OpenUIForTrainerMenu');	
		
	}

	function deregisterListeners()
	{
		theInput.UnregisterListener(this, 'OpenUIForTrainerMenu');

	}


}
state Idle in mod_UIForTrainer {
		
        event OnEnterState(prevStateName : name)
        {
            super.OnEnterState(prevStateName);
			//GetWitcherPlayer().DisplayHudMessage("inside  idle state");
            doPostStuff();
        }

        entry function doPostStuff()
        {
            var i : int;
            for(i = 1; i > 0; i-=1)
            {
                parent.deregisterListeners();
                parent.registerListeners();
                Sleep(1);
            }
        }
    
        event OnLeaveState(prevStateName : name)
        {
            super.OnLeaveState(prevStateName);
            parent.deregisterListeners();
        }
    }
