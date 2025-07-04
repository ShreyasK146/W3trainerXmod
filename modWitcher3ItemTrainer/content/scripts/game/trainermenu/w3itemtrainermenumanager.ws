state WindowClosed in UIForTrainer_MenuManager
{
    event OnEnterState(prevStateName : name)
    {
        //HACK_CheckKeyPress();
	}

	event OnLeaveState(nextStateName : name)
	{

	}

    entry function HACK_CheckKeyPress()
    {
        while(true)
        {
            if(theInput.GetActionValue('CameraLock') != 0)
            {
                parent.ToggleWindow();
            }
            SleepOneFrame();
            SleepOneFrame();
        }
    }
}

state WindowOpen in UIForTrainer_MenuManager
{
    
    //Prepares the input system and registers key listeners when the menu is opened.
    event OnEnterState(prevStateName : name)
    {
        keydowns.Clear();
        keydowns.Grow(6);

        theInput.SetContext('UIForTrainerMenuBase');
        RegisterKeyListeners();
        //GetWitcherPlayer().DisplayHudMessage("trying to register listeners");
        UpdateTick();
	}
    //Restores the input context back to normal gameplay and closes the menu window if still open.
	event OnLeaveState(nextStateName : name)
	{
        //GetWitcherPlayer().DisplayHudMessage("trying to unregister listeners");
       
		
		
		//GetWitcherPlayer().DisplayHudMessage("context set to exploration");
        theInput.SetContext('Exploration'); 
		if(theInput.GetContext() == 'EMPTY_CONTEXT')
        {
			theInput.StoreContext('EMPTY_CONTEXT');
		}
		
        /*if(theInput.GetContext() == 'UIForTrainerMenuBase')
        {
			GetWitcherPlayer().DisplayHudMessage("context set to exploration");
            theInput.SetContext('Exploration');
            theInput.SetContext('Combat');
        }
        else if (theInput.GetContext() == 'EMPTY_CONTEXT')
        {
			GetWitcherPlayer().DisplayHudMessage("context set to exploration2");
            theInput.SetContext('Exploration');
            theInput.SetContext('Combat');
            theInput.StoreContext('EMPTY_CONTEXT');
        }*/
        
        if(parent.IsWindowOpen())
        {
            parent.CloseWindow();
        }

        UnregisterKeyListeners();
	}

    entry function UpdateTick()
    {
        OnFirstOpened();
        WaitForClose();
    }
    //Waits for the UI window to open, then triggers refresh logic once it's open. Acts like a setup delay handler.
    latent function OnFirstOpened()
    {
        var maxTry : int = 120;
        while(maxTry > 0)
        {
            maxTry -= 1;
            if(parent.IsWindowOpen())
            {
                parent.OnWindowOpened();

                SleepOneFrame();
                parent.Refresh();
                
                break;
            }
            SleepOneFrame();
        }
    }
    //Keeps looping while the menu is open. Updates key input timing and calls onTick() on the current menu. Ends by switching to the WindowClosed state once the menu is closed.
    latent function WaitForClose()
    {
        var dtAdd : float = 0;
        var dt : float;
        while(parent.IsWindowOpen() && (theInput.GetContext() == 'UIForTrainerMenuBase' || theInput.GetContext() == 'Combat'))
        {
            SleepOneFrame();
            if(parent.pauseOn)
            {
                dt = 1.0/60.0;
            }
            else
            {
                dt = theTimer.timeDelta;
            }
            dtAdd += dt;
            if(dtAdd >= 0.05)
            {
                dtAdd = 0;
                UpdateKeypressTiming();
            }
            if(parent.currentMenu)
            {
                parent.currentMenu.onTick(dt);
            }
        }

        parent.OnWindowClosed();

        parent.GotoState('WindowClosed');
        virtual_parent.GotoState('WindowClosed');
        this.GotoState('WindowClosed');
    }

    private var keydowns : array<int>;
    private var letterdowns : array<int>;
    //Manages repeated input behavior for held-down keys. If a key is held beyond a threshold (5 frames), it triggers the related menu navigation.
	function UpdateKeypressTiming()
	{
		var i : int;
		for(i = 0; i < keydowns.Size(); i+=1)
		{
            if(parent.InputCaptured)
            {
                keydowns[i] = 0;
            }
            else if(keydowns[i] > 0)
			{
				keydowns[i] += 1;
				if(keydowns[i] > 5)
				{
					switch(i)
					{
					case 0: parent.currentMenu.selectUp(true); break;
					case 1: parent.currentMenu.selectDown(true); break;
					case 2: parent.currentMenu.selectLeft(true); break;
					case 3: parent.currentMenu.selectRight(true); break;
					case 4: parent.currentMenu.selectEnter(true); break;
					case 5: parent.currentMenu.selectExit(true); break;
					}
				}				
			}
		}
	}
    //Tracks key press/release events by updating the keydowns array.
	private function keypressChanged(id : int, ac : SInputAction)
	{
		if(IsPressed(ac))
		{
			this.keydowns[id] = 1;
		}
		else
		{
			this.keydowns[id] = -10;
		}
	}

    function RegisterKeyListeners()
    {
        theInput.RegisterListener(parent, 'OnKey_A', 'UIForTrainer_K_A');
        theInput.RegisterListener(parent, 'OnKey_B', 'UIForTrainer_K_B');
        theInput.RegisterListener(parent, 'OnKey_C', 'UIForTrainer_K_C');
        theInput.RegisterListener(parent, 'OnKey_D', 'UIForTrainer_K_D');
        theInput.RegisterListener(parent, 'OnKey_E', 'UIForTrainer_K_E');
        theInput.RegisterListener(parent, 'OnKey_F', 'UIForTrainer_K_F');
        theInput.RegisterListener(parent, 'OnKey_G', 'UIForTrainer_K_G');
        theInput.RegisterListener(parent, 'OnKey_H', 'UIForTrainer_K_H');
        theInput.RegisterListener(parent, 'OnKey_I', 'UIForTrainer_K_I');
        theInput.RegisterListener(parent, 'OnKey_J', 'UIForTrainer_K_J');
        theInput.RegisterListener(parent, 'OnKey_K', 'UIForTrainer_K_K');
        theInput.RegisterListener(parent, 'OnKey_L', 'UIForTrainer_K_L');
        theInput.RegisterListener(parent, 'OnKey_M', 'UIForTrainer_K_M');
        theInput.RegisterListener(parent, 'OnKey_N', 'UIForTrainer_K_N');
        theInput.RegisterListener(parent, 'OnKey_O', 'UIForTrainer_K_O');
        theInput.RegisterListener(parent, 'OnKey_P', 'UIForTrainer_K_P');
        theInput.RegisterListener(parent, 'OnKey_Q', 'UIForTrainer_K_Q');
        theInput.RegisterListener(parent, 'OnKey_R', 'UIForTrainer_K_R');
        theInput.RegisterListener(parent, 'OnKey_S', 'UIForTrainer_K_S');
        theInput.RegisterListener(parent, 'OnKey_T', 'UIForTrainer_K_T');
        theInput.RegisterListener(parent, 'OnKey_U', 'UIForTrainer_K_U');
        theInput.RegisterListener(parent, 'OnKey_V', 'UIForTrainer_K_V');
        theInput.RegisterListener(parent, 'OnKey_W', 'UIForTrainer_K_W');
        theInput.RegisterListener(parent, 'OnKey_X', 'UIForTrainer_K_X');
        theInput.RegisterListener(parent, 'OnKey_Y', 'UIForTrainer_K_Y');
        theInput.RegisterListener(parent, 'OnKey_Z', 'UIForTrainer_K_Z');
        theInput.RegisterListener(parent, 'OnKey_0', 'UIForTrainer_K_0');
        theInput.RegisterListener(parent, 'OnKey_1', 'UIForTrainer_K_1');
        theInput.RegisterListener(parent, 'OnKey_2', 'UIForTrainer_K_2');
        theInput.RegisterListener(parent, 'OnKey_3', 'UIForTrainer_K_3');
        theInput.RegisterListener(parent, 'OnKey_4', 'UIForTrainer_K_4');
        theInput.RegisterListener(parent, 'OnKey_5', 'UIForTrainer_K_5');
        theInput.RegisterListener(parent, 'OnKey_6', 'UIForTrainer_K_6');
        theInput.RegisterListener(parent, 'OnKey_7', 'UIForTrainer_K_7');
        theInput.RegisterListener(parent, 'OnKey_8', 'UIForTrainer_K_8');
        theInput.RegisterListener(parent, 'OnKey_9', 'UIForTrainer_K_9');
        theInput.RegisterListener(parent, 'OnKey_Enter', 'UIForTrainer_K_Enter');
        theInput.RegisterListener(parent, 'OnKey_US', 'UIForTrainer_K_US');
        theInput.RegisterListener(parent, 'OnKey_Space', 'UIForTrainer_K_Space');
        theInput.RegisterListener(parent, 'OnKey_LShift', 'UIForTrainer_K_LShift');
        theInput.RegisterListener(parent, 'OnKey_RShift', 'UIForTrainer_K_RShift');
        theInput.RegisterListener(parent, 'OnKey_Backspace', 'UIForTrainer_K_Backspace');

	theInput.RegisterListener(parent, 'OnUITrainerMenuUp', 'UIForTrainerModUp');
	theInput.RegisterListener(parent, 'OnUITrainerMenuDown', 'UIForTrainerModDown');
	theInput.RegisterListener(parent, 'OnUITrainerMenuLeft', 'UIForTrainerModLeft');
	theInput.RegisterListener(parent, 'OnUITrainerMenuRight', 'UIForTrainerModRight');
	theInput.RegisterListener(parent, 'OnUITrainerMenuSelect', 'UIForTrainerModE');
	theInput.RegisterListener(parent, 'OnUITrainerMenuBack', 'UIForTrainerModBack');
	theInput.RegisterListener(parent, 'OnUITrainerMenuEscape', 'UIForTrainerModEscape');
    }

    function UnregisterKeyListeners()
    {
        theInput.UnregisterListener(parent, 'UIForTrainer_K_A');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_B');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_C');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_D');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_E');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_F');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_G');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_H');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_I');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_J');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_K');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_L');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_M');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_N');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_O');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_P');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_Q');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_R');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_S');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_T');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_U');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_V');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_W');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_X');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_Y');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_Z');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_0');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_1');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_2');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_3');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_4');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_5');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_6');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_7');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_8');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_9');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_Enter');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_US');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_Space');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_LShift');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_RShift');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_Backspace');

    	theInput.UnregisterListener(parent, 'UIForTrainerModUp');
	theInput.UnregisterListener(parent, 'UIForTrainerModDown');
	theInput.UnregisterListener(parent, 'UIForTrainerModLeft');
	theInput.UnregisterListener(parent, 'UIForTrainerModRight');
	theInput.UnregisterListener(parent, 'UIForTrainerModE'); 
	theInput.UnregisterListener(parent, 'UIForTrainerModBack'); 
	theInput.UnregisterListener(parent, 'UIForTrainerModEscape');
        theInput.UnregisterListener(parent, 'UIForTrainer_K_A');
    }

    function kp(action : SInputAction, letter : name)
    {
        if(parent.HACK_IgnoreFirstInput)
        {
            parent.HACK_IgnoreFirstInput = false;
        }
        else if(parent.InputCaptured)
        {
            parent.currentMenu.OnKey(action, letter);
        }
    }

    event OnKey_A(a:SInputAction){kp(a,'A');}
    event OnKey_B(a:SInputAction){kp(a,'B');}
    event OnKey_C(a:SInputAction){kp(a,'C');}
    event OnKey_D(a:SInputAction){kp(a,'D');}
    event OnKey_E(a:SInputAction){kp(a,'E');}
    event OnKey_F(a:SInputAction){kp(a,'F');}
    event OnKey_G(a:SInputAction){kp(a,'G');}
    event OnKey_H(a:SInputAction){kp(a,'H');}
    event OnKey_I(a:SInputAction){kp(a,'I');}
    event OnKey_J(a:SInputAction){kp(a,'J');}
    event OnKey_K(a:SInputAction){kp(a,'K');}
    event OnKey_L(a:SInputAction){kp(a,'L');}
    event OnKey_M(a:SInputAction){kp(a,'M');}
    event OnKey_N(a:SInputAction){kp(a,'N');}
    event OnKey_O(a:SInputAction){kp(a,'O');}
    event OnKey_P(a:SInputAction){kp(a,'P');}
    event OnKey_Q(a:SInputAction){kp(a,'Q');}
    event OnKey_R(a:SInputAction){kp(a,'R');}
    event OnKey_S(a:SInputAction){kp(a,'S');}
    event OnKey_T(a:SInputAction){kp(a,'T');}
    event OnKey_U(a:SInputAction){kp(a,'U');}
    event OnKey_V(a:SInputAction){kp(a,'V');}
    event OnKey_W(a:SInputAction){kp(a,'W');}
    event OnKey_X(a:SInputAction){kp(a,'X');}
    event OnKey_Y(a:SInputAction){kp(a,'Y');}
    event OnKey_Z(a:SInputAction){kp(a,'Z');}
    event OnKey_0(a:SInputAction){kp(a,'0');}
    event OnKey_1(a:SInputAction){kp(a,'1');}
    event OnKey_2(a:SInputAction){kp(a,'2');}
    event OnKey_3(a:SInputAction){kp(a,'3');}
    event OnKey_4(a:SInputAction){kp(a,'4');}
    event OnKey_5(a:SInputAction){kp(a,'5');}
    event OnKey_6(a:SInputAction){kp(a,'6');}
    event OnKey_7(a:SInputAction){kp(a,'7');}
    event OnKey_8(a:SInputAction){kp(a,'8');}
    event OnKey_9(a:SInputAction){kp(a,'9');}
    event OnKey_US(a:SInputAction){kp(a,'_');}//Underscore
    event OnKey_Space(a:SInputAction){kp(a,' ');}
    event OnKey_Enter(a:SInputAction){kp(a,'Enter');}
    event OnKey_LShift(a:SInputAction){kp(a,'LShift');}
    event OnKey_RShift(a:SInputAction){kp(a,'RShift');}
    event OnKey_Backspace(a:SInputAction){kp(a,'Backspace');}

    event OnUITrainerMenuEscape(action : SInputAction)
	{
        
        if(parent.InputCaptured)
        {
            kp(action, 'Escape');
            parent.InputCaptured = false;
        }
        else if(IsPressed(action))
		{
			parent.CloseWindow();
		}
	}
	
	event OnUITrainerMenuUp(action : SInputAction)
	{
        if(!parent.InputCaptured)
        {
            this.keypressChanged(0, action);
            if(IsPressed(action))
            {
                parent.currentMenu.selectUp();
            }
        }
	}
	event OnUITrainerMenuDown(action : SInputAction)
	{
        if(!parent.InputCaptured)
        {
            this.keypressChanged(1, action);
            if(IsPressed(action))
            {
                parent.currentMenu.selectDown();
            }
        }
	}
	event OnUITrainerMenuLeft(action : SInputAction)
	{
        if(!parent.InputCaptured)
        {
            this.keypressChanged(2, action);
            if(IsPressed(action))
            {
                parent.currentMenu.selectLeft();
            }
        }
	}
	event OnUITrainerMenuRight(action : SInputAction)
	{
        if(!parent.InputCaptured)
        {
            this.keypressChanged(3, action);
            if(IsPressed(action))
            {
                parent.currentMenu.selectRight();
            }
        }
	}
	event OnUITrainerMenuSelect(action : SInputAction)
	{
        if(!parent.InputCaptured)
        {
            this.keypressChanged(4, action);
            if(IsPressed(action))
            {
                parent.currentMenu.selectEnter();
            }
        }
	}
	event OnUITrainerMenuBack(action : SInputAction)
	{
        if(!parent.InputCaptured)
        {
            if(IsPressed(action))
            {
                parent.CloseWindow();
            }
        }
    }
}

statemachine class UIForTrainer_MenuManager extends CObject
{
    public var openMenus : array<UITrainerBase>;
    public var currentMenu : UITrainerBase;

    public var pauseOn : bool; default pauseOn = false;

    public var InputCaptured : bool; default InputCaptured = false;
    protected var HACK_IgnoreFirstInput : bool;

    public function StartCapture()
    {
        if(IsWindowOpen())
        {
            InputCaptured = true;
            HACK_IgnoreFirstInput = true;
        }
    }

    public function EndCapture()
    {
        InputCaptured = false;
        HACK_IgnoreFirstInput = false;
    }

    public function SetPause(pauseOn : bool)
    {
        this.pauseOn = pauseOn;
        GetWitcherPlayer().DisplayHudMessage("paused ?");
        if(this.pauseOn)
        {
            if(!theGame.IsPausedForReason("UIForTrainer_MenuManager"))
            {
                theGame.Pause("UIForTrainer_MenuManager");
                GetWitcherPlayer().DisplayHudMessage("paused!");
            } 
        }
        else
        {
            theGame.Unpause("UIForTrainer_MenuManager");
        }
    }

    public function OpenMenu(menu : UITrainerBase)
    {
        if(menu)
        {
            if(currentMenu)
            {
                currentMenu.OnMenuClosed();
            }
            menu.window = this;
            openMenus.PushBack(menu);
            currentMenu = menu;
            
            menu._OnMenuCreated();
            menu.OnMenuOpened();
            if(menu == this.currentMenu)
            {
                this.UpdateAndRefresh();
                PlayOpenSound();
            }
        }
    }

    public function CloseMenu(optional count : int)
    {
        //currentMenu.OnMenuDestroyed();
        if(count <= 0) count = 1;

        while(count > 0)
        {
            currentMenu.OnMenuClosed();

            if(openMenus.Size() > 1)
            {
                openMenus.PopBack();
                currentMenu = openMenus[openMenus.Size()-1];
                if(count == 1)
                {
                    currentMenu.OnMenuOpened();
                    this.UpdateAndRefresh();
                    PlayCloseSound();
                }
            }
            else
            {
                this.openMenus.Clear();
                this.currentMenu = NULL;
                this.CloseWindow();
                break;
            }

            count -= 1;
        }
    }

	event OnUITrainerMenuUp(action : SInputAction){}
	event OnUITrainerMenuDown(action : SInputAction){}
	event OnUITrainerMenuLeft(action : SInputAction){}
	event OnUITrainerMenuRight(action : SInputAction){}
	event OnUITrainerMenuSelect(action : SInputAction){}
	event OnUITrainerMenuBack(action : SInputAction){}
	event OnUITrainerMenuEscape(action : SInputAction){}

    	event OnKey_A(a:SInputAction){}
    	event OnKey_B(a:SInputAction){}
    	event OnKey_C(a:SInputAction){}
    	event OnKey_D(a:SInputAction){}
    	event OnKey_E(a:SInputAction){}
    	event OnKey_F(a:SInputAction){}
    	event OnKey_G(a:SInputAction){}
    	event OnKey_H(a:SInputAction){}
    	event OnKey_I(a:SInputAction){}
    	event OnKey_J(a:SInputAction){}
    	event OnKey_K(a:SInputAction){}
    	event OnKey_L(a:SInputAction){}
    	event OnKey_M(a:SInputAction){}
    	event OnKey_N(a:SInputAction){}
    	event OnKey_O(a:SInputAction){}
    	event OnKey_P(a:SInputAction){}
    	event OnKey_Q(a:SInputAction){}
    	event OnKey_R(a:SInputAction){}
    	event OnKey_S(a:SInputAction){}
    	event OnKey_T(a:SInputAction){}
    	event OnKey_U(a:SInputAction){}
    	event OnKey_V(a:SInputAction){}
    	event OnKey_W(a:SInputAction){}
    	event OnKey_X(a:SInputAction){}
    	event OnKey_Y(a:SInputAction){}
    	event OnKey_Z(a:SInputAction){}
    	event OnKey_0(a:SInputAction){}
    	event OnKey_1(a:SInputAction){}
    	event OnKey_2(a:SInputAction){}
    	event OnKey_3(a:SInputAction){}
    	event OnKey_4(a:SInputAction){}
    	event OnKey_5(a:SInputAction){}
    	event OnKey_6(a:SInputAction){}
    	event OnKey_7(a:SInputAction){}
    	event OnKey_8(a:SInputAction){}
    	event OnKey_9(a:SInputAction){}
    	event OnKey_US(a:SInputAction){}
    	event OnKey_Enter(a:SInputAction){}
    	event OnKey_Space(a:SInputAction){}
    	event OnKey_LShift(a:SInputAction){}
    	event OnKey_RShift(a:SInputAction){}
    	event OnKey_Backspace(a:SInputAction){}

	private var isInit : bool; default isInit = false;
	public function init()
	{
		if(isInit) return;
		isInit = true;
        this.GotoState('WindowClosed');
    }

    protected var IsWindowOpen : bool; default IsWindowOpen = false;
    protected var OpenWindow : CR4TutorialPopup;
    protected var OpenWindowFlash : CScriptedFlashSprite;

    public function IsWindowOpen() : bool
    {
        if(!this.IsWindowOpen)
        {
            this.OpenWindow = (CR4TutorialPopup)theGame.GetGuiManager().GetPopup('TutorialPopup');
            if(this.OpenWindow)
            {
                this.OpenWindowFlash = this.OpenWindow.GetPopupFlash();
                if(this.OpenWindowFlash)
                {
                    return this.IsWindowOpen = true;
                }
                this.OpenWindowFlash = NULL;
            }
            this.OpenWindow = NULL;
            return false;
        }
        else
        {
            if(this.OpenWindow && this.OpenWindowFlash)
            {
                return true;
            }
            this.OpenWindow = NULL;
            this.OpenWindowFlash = NULL;
            this.IsWindowOpen = false;
            return false;
        }
    }

    protected function OnWindowOpened()
    {
        
        if(this.pauseOn)
        {
            if(!theGame.IsPausedForReason("UIForTrainer_MenuManager")) theGame.Pause("UIForTrainer_MenuManager");
        }
        else
        {
            theGame.Unpause("UIForTrainer_MenuManager");
        }
    }

    protected function OnWindowClosed()
    {
        
        if(this.currentMenu)
        {
            this.currentMenu.OnMenuClosed();
        }
        
        theGame.Unpause("UIForTrainer_MenuManager");
    }

    public function ToggleWindow()
    {
        if(IsWindowOpen())
        {
            CloseWindow();
        }
        else
        {
            OpenWindow();
        }
    }

    public function CloseWindow()
    {
        if(IsWindowOpen())
        {
            this.OpenWindow.ClosePopup();
            this.IsWindowOpen = false;
            this.OpenWindow = NULL;
            this.OpenWindowFlash = NULL;
            PlayCloseSound();
        }
        else
        {
            
        }
    }

    public function OpenWindow()
    {
        var rootMenu : UITrainerBase;
        if(!IsWindowOpen())
        {
            if(theInput.GetContext() == 'Exploration' || theInput.GetContext() == 'Combat')
            {
                if(!this.currentMenu)
                {
                    rootMenu = new UIForTrainerSpawnMenu in this;
                    OpenMenu(rootMenu);
                }
                else
                {
                    this.currentMenu.OnMenuOpened();
                    PlayOpenSound();
                }
                UpdateCurrentText();
                ShowSideWindow(this.currentTitle, this.currentText);
                //GetWitcherPlayer().DisplayHudMessage("trying to go to windowopen state");
                this.GotoState('WindowOpen');
            }
        }
        else
        {
            
        }
    }

    public function Refresh()
    {
        if(IsWindowOpen())
        {
            ShowSideWindow(this.currentTitle, this.currentText);
        }
    }

    public function UpdateAndRefresh()
    {
        if(IsWindowOpen())
        {
            UpdateCurrentText();
            ShowSideWindow(this.currentTitle, this.currentText);
        }
    }

    protected var currentTitle, currentText : String;
    private function calculateStartEndIndex(index, itemCount : int, out startIndex, endIndex : int)
    {
        var MAX_SHOW : int = 16;

		startIndex = index - 7;
		if(startIndex < 0) startIndex = 0;
		endIndex = startIndex + MAX_SHOW;
		if(endIndex > itemCount)
		{
			endIndex = itemCount;
			if(startIndex > 0)
			{
				startIndex = endIndex - MAX_SHOW;
				if(startIndex < 0) startIndex = 0;
			}
		}
	}
//Calculates the Y position of a menu item based on the scroll window. Helpful for aligning UI elements in a list (e.g., highlighting selection).
    private function getYIndexOfItem(itemIndex : int) : int
    {
        var startIndex, endIndex : int;

		calculateStartEndIndex(currentMenu.selectedIndex, currentMenu.ItemCount(), startIndex, endIndex);
        	return itemIndex - startIndex;
    }
//Builds the HTML content for the right-side info window.
    public function UpdateCurrentText()
    {
        var html, htmlTitle, metaLine, colour : String;
		var i : int;
		var itemCount : int;
		
		var startIndex : int;
		var endIndex : int;
		var innerTxt : String;
		
		itemCount = currentMenu.ItemCount();
		calculateStartEndIndex(currentMenu.selectedIndex, itemCount, startIndex, endIndex);

		//currentMenu.selectedIndex
		html = "";
		htmlTitle = "<FONT color=\"#00CC00\">" + currentMenu.GetName() + "</FONT><FONT color=\"#2299FF\">&nbsp;&nbsp;" + (currentMenu.selectedIndex+1) + "/" + itemCount + "</FONT>";
		htmlTitle = currentMenu.GetName();

		for(i = startIndex; i < endIndex; i+=1)
		{
			innerTxt = currentMenu.GetItem(i);
			colour = currentMenu.GetColour(i);
			if(i == currentMenu.selectedIndex)
			{
				//colour = "cc0000";
				if(currentMenu.showItemIndicator)
				{
					innerTxt = "==&gt; " + innerTxt + " &lt;==";
				}
			}
			
			if(StrLen(colour) > 1)
			{
				html += "<p align=\"center\"><FONT color=\"#" + colour + "\">" + innerTxt + "</FONT></p>";
			}
			else
			{
				html += "<p align=\"center\">" + innerTxt + "</p>";
			}
		}
		if(itemCount == 0)
		{
			html += "<p align=\"right\"><font color='#555555'>No Items</font></p>";
		}
		else
		{
			html += "<p align=\"right\"><font color='#555555'>" + (currentMenu.selectedIndex+1) + "/" + itemCount + "</font></p>";
		}

        metaLine = currentMenu.GetMetaInfo();
        if(metaLine != "")
        {
            html += "<p align=\"left\">" + metaLine + "</p>";
        }

        this.currentTitle = htmlTitle;
        this.currentText = html;

    }

    	public function PlaySound(soundName : String){theSound.SoundEvent(soundName);}
    	public function PlaySelectSound(){theSound.SoundEvent("gui_global_highlight");}
	public function PlayOpenSound(){theSound.SoundEvent("gui_global_panel_open");}
	public function PlayCloseSound(){theSound.SoundEvent("gui_global_panel_close");}
	public function PlayDeniedSound(){theSound.SoundEvent("gui_global_denied");}
	public function PlayWhooshSound(){theSound.SoundEvent("gui_no_stamina");}//gui_global_submenu_woosh
	public function PlayTickSound(){theSound.SoundEvent("gui_ingame_wheel_highlight");}
    
 

    function UITrainerlaySoundPopup(soundName : String)
    {
        theSound.SoundEvent( soundName );
    }

    function GUI_IsWindowOpen() : bool
    {
        var messagePopupRef : CR4TutorialPopup;	
        messagePopupRef = (CR4TutorialPopup)theGame.GetGuiManager().GetPopup('TutorialPopup');

        return !(!messagePopupRef);
    }
    //This creates a new tutorial window, setting properties like title, text, and whether the game should be paused or input should be blocked. It uses a W3TutorialPopupData object to set up the popup details.
    function CreateSideWindow(title : String, text : String, pauseGame : bool, blockInput : bool)
    {
        var popupData : W3TutorialPopupData;

        popupData = new W3TutorialPopupData in theGame;

        popupData.messageTitle = title;
        popupData.messageText = text;
        popupData.pauseGame = pauseGame;
        popupData.blockInput = blockInput;
        popupData.fullscreen = false;
        popupData.duration = -1;

        theGame.RequestPopup('TutorialPopup', popupData);
    }

  
    function alignContent(txtDescription, txtTitle, background, contentMask, topDelemiter, borderLineTop, borderLineBottom, mcCorrectFeedback, mcErrorFeedback : CScriptedFlashObject)
    {
        var MIN_WIDTH : float = 480;
        var MAX_WIDTH : float = 600;
        var EDGE_PADDING : float = 5;
        var UI_EDGE_PADDING : float = 40;
        var GRADIENT_PADDING : float = 115+30;
        var TOP_BORDER_POS : float = -7;
        var BUTTONS_PADDING : float = 15;
        var BUTTONS_OFFSET : float = 10;
        var TOP_OFFSET_FOR_TITLE : float = 90;
        var SAFE_TEXTFIELD_OFFSET : float = 5;
        var BLOCK_PADDING : float = 2;
        var GLOSSARY_RIGHT_PADDING : float = 60;
        var GLOSSARY_PADDING : float = 10;
        var GLOSSARY_HEIGHT : float = 70;
        var BOTTOM_PADDING : float = 10;
        var SAFE_TEXT_PADDING : float = 7;

        var accumHeight : float = 0;
        var innerWidth : float = 0;
        var screenWidthF : float = 1920; //Screen width = CommonUtils.getScreenRect();
        var additionalWidth : float;
        var centerX : float;
        var centerY : float;
        var txtDescWidth : float;

        var screenWidth, screenHeight : int;

        theGame.GetCurrentViewportResolution( screenWidth, screenHeight );

        screenWidthF = screenWidth;

        if(true)//this.topDelemiter.visible
        {
            accumHeight = accumHeight + (TOP_OFFSET_FOR_TITLE + BLOCK_PADDING);
        }
        else
        {
            accumHeight = accumHeight + BLOCK_PADDING * 4;
        }
        if(true)//this.txtDescription.visible
        {
            txtDescription.SetMemberFlashNumber("y", accumHeight);
            txtDescWidth = MinF(MAX_WIDTH, 500 + SAFE_TEXT_PADDING); //500!=txtDescription.GetMemberFlashNumber("textWidth")
            txtDescription.SetMemberFlashNumber("width", txtDescWidth);
            txtDescription.SetMemberFlashNumber("height", txtDescription.GetMemberFlashNumber("textHeight") + SAFE_TEXTFIELD_OFFSET);
            accumHeight = accumHeight + (txtDescription.GetMemberFlashNumber("height") + BLOCK_PADDING);
            innerWidth = txtDescription.GetMemberFlashNumber("width");
        }

        accumHeight = accumHeight + BOTTOM_PADDING;
        background.SetMemberFlashNumber("height", accumHeight + BLOCK_PADDING);

        if(false)//this._data.isUiTutorial
        {
            additionalWidth = 0;
            innerWidth = MaxF(MIN_WIDTH,innerWidth) + UI_EDGE_PADDING;
            background.SetMemberFlashNumber("width", innerWidth);
        }
        else
        {
            additionalWidth = screenWidthF * (0.05-0.03) + BLOCK_PADDING;
            innerWidth = MaxF(MIN_WIDTH,innerWidth) + EDGE_PADDING;
            background.SetMemberFlashNumber("width", innerWidth + GRADIENT_PADDING + additionalWidth);
        }

        
        centerX = RoundF(innerWidth / 2) + additionalWidth;
        centerY = RoundF(accumHeight / 2);

        txtDescription.SetMemberFlashNumber("x", centerX - txtDescription.GetMemberFlashNumber("width") / 2);
        topDelemiter.SetMemberFlashNumber("x", centerX);
        topDelemiter.SetMemberFlashNumber("y", txtTitle.GetMemberFlashNumber("y") + txtTitle.GetMemberFlashNumber("height") + BOTTOM_PADDING);
        txtTitle.SetMemberFlashNumber("x", centerX - txtTitle.GetMemberFlashNumber("width")/2);
        
        contentMask.SetMemberFlashNumber("y", centerY);
        contentMask.SetMemberFlashNumber("width", background.GetMemberFlashNumber("width"));
        //if(true)
        {
            contentMask.SetMemberFlashNumber("height", background.GetMemberFlashNumber("height") + 200);
            borderLineTop.SetMemberFlashNumber("y", 0);
            borderLineBottom.SetMemberFlashNumber("y", background.GetMemberFlashNumber("height") - 1);
        }
    }
    //This function modifies the title and text inside the popup and then calls alignContent to adjust the layout of the window based on the new data.
    function UpdateSideWindow(popupObj : CR4TutorialPopup, title : String, text : String, pauseGame : bool, blockInput : bool)
    {
        var flashBase : CScriptedFlashSprite;
        var popupInstance, tutorialOverlay, data : CScriptedFlashObject;

        var txtDescription, txtTitle, background, contentMask, topDelemiter, borderLineTop, borderLineBottom, mcCorrectFeedback, mcErrorFeedback : CScriptedFlashObject;

        var _loc1_ : float = 0;
        var _loc2_ : float = 0;


        flashBase = popupObj.GetPopupFlash(); //TutorialPopupWindow

        popupInstance = flashBase.GetMemberFlashObject("popupInstance"); //TutorialPopup
        //tutorialOverlay = flashBase.GetMemberFlashObject("tutorialOverlay"); //TutorialOverlay

        //Get all the objects
        txtDescription = popupInstance.GetMemberFlashObject("txtDescription");
        txtTitle = popupInstance.GetMemberFlashObject("txtTitle");
        background = popupInstance.GetMemberFlashObject("background");
        contentMask = popupInstance.GetMemberFlashObject("contentMask");
        topDelemiter = popupInstance.GetMemberFlashObject("topDelemiter");
        borderLineTop = popupInstance.GetMemberFlashObject("borderLineTop");
        mcErrorFeedback = popupInstance.GetMemberFlashObject("mcErrorFeedback");
        borderLineBottom = popupInstance.GetMemberFlashObject("borderLineBottom");
        mcCorrectFeedback = popupInstance.GetMemberFlashObject("mcCorrectFeedback");

        //Set the new data
        txtTitle.SetMemberFlashString("htmlText", title);
        txtDescription.SetMemberFlashString("htmlText", text);

        //Update the UI positions
        alignContent(txtDescription, txtTitle, background, contentMask, topDelemiter, borderLineTop, borderLineBottom, mcCorrectFeedback, mcErrorFeedback);
    }

   
    function ShowSideWindow(title : String, text : String, optional pauseGame : bool, optional blockInput : bool)
    {
        var popup : CR4TutorialPopup;

        popup = (CR4TutorialPopup)theGame.GetGuiManager().GetPopup('TutorialPopup');

        if(!popup)
        {
            CreateSideWindow(title, text, pauseGame, blockInput);
        }
        else
        {
            UpdateSideWindow(popup, title, text, pauseGame, blockInput);
        }
    }
    //Highlights a specific area on the screen, presumably for tutorial or feedback purposes.
    function HighlightArea(x, y, width, height : float)
    {
        var popupInstance, mcCorrectFeedback : CScriptedFlashObject;
        var playFeedbackAnimation_f : CScriptedFlashFunction;
        var screenWidthInt, screenHeightInt : int;
        var screenWidth, screenHeight : float;
        if(this.IsWindowOpen())
        {
            theGame.GetCurrentViewportResolution( screenWidthInt, screenHeightInt );

            screenWidth = screenWidthInt;
            screenHeight = screenHeightInt;

            popupInstance = this.OpenWindowFlash.GetMemberFlashObject("popupInstance"); //TutorialPopup
            mcCorrectFeedback = popupInstance.GetMemberFlashObject("mcCorrectFeedback");
            playFeedbackAnimation_f = popupInstance.GetMemberFlashFunction("playFeedbackAnimation");

            x *= screenWidth;
            y *= screenHeight;
            width *= screenWidth;
            height *= screenHeight;

            mcCorrectFeedback.SetMemberFlashNumber("x", x);
            mcCorrectFeedback.SetMemberFlashNumber("y", y);
            mcCorrectFeedback.SetMemberFlashNumber("width", width);
            mcCorrectFeedback.SetMemberFlashNumber("height", height);

            playFeedbackAnimation_f.InvokeSelfOneArg(FlashArgBool(true));
        }
    }
    //Plays a feedback animation indicating whether something was successful (good) or unsuccessful (bad).
    function FlashGoodBad(goodbad : bool, optional overIndex : int)
    {
        var popupInstance, mcFeedback, background : CScriptedFlashObject;
        var playFeedbackAnimation_f : CScriptedFlashFunction;
        var count : int;
        if(this.IsWindowOpen())
        {
            popupInstance = this.OpenWindowFlash.GetMemberFlashObject("popupInstance"); //TutorialPopup
            
            if (goodbad) {
                mcFeedback = popupInstance.GetMemberFlashObject("mcCorrectFeedback");
            } else {
                mcFeedback = popupInstance.GetMemberFlashObject("mcErrorFeedback");
            }

            background = popupInstance.GetMemberFlashObject("background");

            if(overIndex <= 0)
            {
                mcFeedback.SetMemberFlashNumber("x", background.GetMemberFlashNumber("x"));
                mcFeedback.SetMemberFlashNumber("y", background.GetMemberFlashNumber("y"));
                mcFeedback.SetMemberFlashNumber("width", background.GetMemberFlashNumber("width"));
                mcFeedback.SetMemberFlashNumber("height", background.GetMemberFlashNumber("height"));
            }
            else
            {
                overIndex = getYIndexOfItem(overIndex-1);

                mcFeedback.SetMemberFlashNumber("x", background.GetMemberFlashNumber("x"));
                mcFeedback.SetMemberFlashNumber("width", background.GetMemberFlashNumber("width"));

                mcFeedback.SetMemberFlashNumber("y", background.GetMemberFlashNumber("y") + 90 + ((float)overIndex) * 29.6);
                mcFeedback.SetMemberFlashNumber("height", 30);
            }

            playFeedbackAnimation_f = popupInstance.GetMemberFlashFunction("playFeedbackAnimation");

            playFeedbackAnimation_f.InvokeSelfOneArg(FlashArgBool(goodbad));
        }
    }
}
