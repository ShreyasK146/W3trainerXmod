
state WindowClosed in MCM_MenuManager
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

state WindowOpen in MCM_MenuManager
{
    //Prepares the input system and registers key listeners when the menu is opened.
    event OnEnterState(prevStateName : name)
    {
        keydowns.Clear();
        keydowns.Grow(6);

        theInput.SetContext('SCMMenuBase');
        RegisterKeyListeners();
        UpdateTick();
	}
    //Restores the input context back to normal gameplay and closes the menu window if still open.
	event OnLeaveState(nextStateName : name)
	{
        LogSCM("CONTEXT: " + theInput.GetContext());
        if(theInput.GetContext() == 'SCMMenuBase')
        {
            theInput.SetContext('Exploration');
        }
        else if (theInput.GetContext() == 'EMPTY_CONTEXT')
        {
            theInput.SetContext('Exploration');
            theInput.StoreContext('EMPTY_CONTEXT');
        }
        
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
        while(parent.IsWindowOpen() && (theInput.GetContext() == 'SCMMenuBase'))
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
        theInput.RegisterListener(parent, 'OnKey_A', 'MCM_K_A');
        theInput.RegisterListener(parent, 'OnKey_B', 'MCM_K_B');
        theInput.RegisterListener(parent, 'OnKey_C', 'MCM_K_C');
        theInput.RegisterListener(parent, 'OnKey_D', 'MCM_K_D');
        theInput.RegisterListener(parent, 'OnKey_E', 'MCM_K_E');
        theInput.RegisterListener(parent, 'OnKey_F', 'MCM_K_F');
        theInput.RegisterListener(parent, 'OnKey_G', 'MCM_K_G');
        theInput.RegisterListener(parent, 'OnKey_H', 'MCM_K_H');
        theInput.RegisterListener(parent, 'OnKey_I', 'MCM_K_I');
        theInput.RegisterListener(parent, 'OnKey_J', 'MCM_K_J');
        theInput.RegisterListener(parent, 'OnKey_K', 'MCM_K_K');
        theInput.RegisterListener(parent, 'OnKey_L', 'MCM_K_L');
        theInput.RegisterListener(parent, 'OnKey_M', 'MCM_K_M');
        theInput.RegisterListener(parent, 'OnKey_N', 'MCM_K_N');
        theInput.RegisterListener(parent, 'OnKey_O', 'MCM_K_O');
        theInput.RegisterListener(parent, 'OnKey_P', 'MCM_K_P');
        theInput.RegisterListener(parent, 'OnKey_Q', 'MCM_K_Q');
        theInput.RegisterListener(parent, 'OnKey_R', 'MCM_K_R');
        theInput.RegisterListener(parent, 'OnKey_S', 'MCM_K_S');
        theInput.RegisterListener(parent, 'OnKey_T', 'MCM_K_T');
        theInput.RegisterListener(parent, 'OnKey_U', 'MCM_K_U');
        theInput.RegisterListener(parent, 'OnKey_V', 'MCM_K_V');
        theInput.RegisterListener(parent, 'OnKey_W', 'MCM_K_W');
        theInput.RegisterListener(parent, 'OnKey_X', 'MCM_K_X');
        theInput.RegisterListener(parent, 'OnKey_Y', 'MCM_K_Y');
        theInput.RegisterListener(parent, 'OnKey_Z', 'MCM_K_Z');
        theInput.RegisterListener(parent, 'OnKey_0', 'MCM_K_0');
        theInput.RegisterListener(parent, 'OnKey_1', 'MCM_K_1');
        theInput.RegisterListener(parent, 'OnKey_2', 'MCM_K_2');
        theInput.RegisterListener(parent, 'OnKey_3', 'MCM_K_3');
        theInput.RegisterListener(parent, 'OnKey_4', 'MCM_K_4');
        theInput.RegisterListener(parent, 'OnKey_5', 'MCM_K_5');
        theInput.RegisterListener(parent, 'OnKey_6', 'MCM_K_6');
        theInput.RegisterListener(parent, 'OnKey_7', 'MCM_K_7');
        theInput.RegisterListener(parent, 'OnKey_8', 'MCM_K_8');
        theInput.RegisterListener(parent, 'OnKey_9', 'MCM_K_9');
        theInput.RegisterListener(parent, 'OnKey_Enter', 'MCM_K_Enter');
        theInput.RegisterListener(parent, 'OnKey_US', 'MCM_K_US');
        theInput.RegisterListener(parent, 'OnKey_Space', 'MCM_K_Space');
        theInput.RegisterListener(parent, 'OnKey_LShift', 'MCM_K_LShift');
        theInput.RegisterListener(parent, 'OnKey_RShift', 'MCM_K_RShift');
        theInput.RegisterListener(parent, 'OnKey_Backspace', 'MCM_K_Backspace');

	theInput.RegisterListener(parent, 'OnSCMUp', 'SCMUp');
	theInput.RegisterListener(parent, 'OnSCMDown', 'SCMDown');
	theInput.RegisterListener(parent, 'OnSCMLeft', 'SCMLeft');
	theInput.RegisterListener(parent, 'OnSCMRight', 'SCMRight');
	theInput.RegisterListener(parent, 'OnSCMSelect', 'SCME');
	theInput.RegisterListener(parent, 'OnSCMBack', 'SCMBack');
	theInput.RegisterListener(parent, 'OnSCMEscape', 'SCMEscape');
    }

    function UnregisterKeyListeners()
    {
        theInput.UnregisterListener(parent, 'MCM_K_A');
        theInput.UnregisterListener(parent, 'MCM_K_B');
        theInput.UnregisterListener(parent, 'MCM_K_C');
        theInput.UnregisterListener(parent, 'MCM_K_D');
        theInput.UnregisterListener(parent, 'MCM_K_E');
        theInput.UnregisterListener(parent, 'MCM_K_F');
        theInput.UnregisterListener(parent, 'MCM_K_G');
        theInput.UnregisterListener(parent, 'MCM_K_H');
        theInput.UnregisterListener(parent, 'MCM_K_I');
        theInput.UnregisterListener(parent, 'MCM_K_J');
        theInput.UnregisterListener(parent, 'MCM_K_K');
        theInput.UnregisterListener(parent, 'MCM_K_L');
        theInput.UnregisterListener(parent, 'MCM_K_M');
        theInput.UnregisterListener(parent, 'MCM_K_N');
        theInput.UnregisterListener(parent, 'MCM_K_O');
        theInput.UnregisterListener(parent, 'MCM_K_P');
        theInput.UnregisterListener(parent, 'MCM_K_Q');
        theInput.UnregisterListener(parent, 'MCM_K_R');
        theInput.UnregisterListener(parent, 'MCM_K_S');
        theInput.UnregisterListener(parent, 'MCM_K_T');
        theInput.UnregisterListener(parent, 'MCM_K_U');
        theInput.UnregisterListener(parent, 'MCM_K_V');
        theInput.UnregisterListener(parent, 'MCM_K_W');
        theInput.UnregisterListener(parent, 'MCM_K_X');
        theInput.UnregisterListener(parent, 'MCM_K_Y');
        theInput.UnregisterListener(parent, 'MCM_K_Z');
        theInput.UnregisterListener(parent, 'MCM_K_0');
        theInput.UnregisterListener(parent, 'MCM_K_1');
        theInput.UnregisterListener(parent, 'MCM_K_2');
        theInput.UnregisterListener(parent, 'MCM_K_3');
        theInput.UnregisterListener(parent, 'MCM_K_4');
        theInput.UnregisterListener(parent, 'MCM_K_5');
        theInput.UnregisterListener(parent, 'MCM_K_6');
        theInput.UnregisterListener(parent, 'MCM_K_7');
        theInput.UnregisterListener(parent, 'MCM_K_8');
        theInput.UnregisterListener(parent, 'MCM_K_9');
        theInput.UnregisterListener(parent, 'MCM_K_Enter');
        theInput.UnregisterListener(parent, 'MCM_K_US');
        theInput.UnregisterListener(parent, 'MCM_K_Space');
        theInput.UnregisterListener(parent, 'MCM_K_LShift');
        theInput.UnregisterListener(parent, 'MCM_K_RShift');
        theInput.UnregisterListener(parent, 'MCM_K_Backspace');

    	theInput.UnregisterListener(parent, 'SCMUp');
	theInput.UnregisterListener(parent, 'SCMDown');
	theInput.UnregisterListener(parent, 'SCMLeft');
	theInput.UnregisterListener(parent, 'SCMRight');
	theInput.UnregisterListener(parent, 'SCME'); 
	theInput.UnregisterListener(parent, 'SCMBack'); 
	theInput.UnregisterListener(parent, 'SCMEscape');
        theInput.UnregisterListener(parent, 'MCM_K_A');
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

    event OnSCMEscape(action : SInputAction)
	{
        LogSCM("On Escape");
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
	
	event OnSCMUp(action : SInputAction)
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
	event OnSCMDown(action : SInputAction)
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
	event OnSCMLeft(action : SInputAction)
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
	event OnSCMRight(action : SInputAction)
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
	event OnSCMSelect(action : SInputAction)
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
	event OnSCMBack(action : SInputAction)
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

statemachine class MCM_MenuManager extends CObject
{
    public var openMenus : array<SCMMenuBase>;
    public var currentMenu : SCMMenuBase;

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
            if(!theGame.IsPausedForReason("MCM_MenuManager"))
            {
                theGame.Pause("MCM_MenuManager");
                GetWitcherPlayer().DisplayHudMessage("paused!");
            } 
        }
        else
        {
            theGame.Unpause("MCM_MenuManager");
        }
    }

    public function OpenMenu(menu : SCMMenuBase)
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

	event OnSCMUp(action : SInputAction){}
	event OnSCMDown(action : SInputAction){}
	event OnSCMLeft(action : SInputAction){}
	event OnSCMRight(action : SInputAction){}
	event OnSCMSelect(action : SInputAction){}
	event OnSCMBack(action : SInputAction){}
	event OnSCMEscape(action : SInputAction){}

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
        LogSCM("Window Opened Event");
        if(this.pauseOn)
        {
            if(!theGame.IsPausedForReason("MCM_MenuManager")) theGame.Pause("MCM_MenuManager");
        }
        else
        {
            theGame.Unpause("MCM_MenuManager");
        }
    }

    protected function OnWindowClosed()
    {
        LogSCM("Window Closed Event");
        if(this.currentMenu)
        {
            this.currentMenu.OnMenuClosed();
        }
        
        theGame.Unpause("MCM_MenuManager");
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
            LogSCM("Requested Window Close when it's already closed");
        }
    }

    public function OpenWindow()
    {
        var rootMenu : SCMMenuBase;
        if(!IsWindowOpen())
        {
            if(theInput.GetContext() == 'Exploration')
            {
                if(!this.currentMenu)
                {
                    rootMenu = new MCMMenuMain in this;
                    OpenMenu(rootMenu);
                }
                else
                {
                    this.currentMenu.OnMenuOpened();
                    PlayOpenSound();
                }
                UpdateCurrentText();
                ShowSideWindow(this.currentTitle, this.currentText);
                this.GotoState('WindowOpen');
            }
        }
        else
        {
            LogSCM("Requested Window open when it's already open");
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
//Figures out which slice of the menu items to display (like pagination). Shows a max of 16 items centered around the selected index.
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
		//img://textures/journal/characters/journal_damien.png
		//Mouse_LeftBtn.png
		//html += "<img src=\"img://icons/monsters/ICO_MonsterDefault.png\" vspace=\"-10\" />";

        this.currentTitle = htmlTitle;
        this.currentText = html;

		//SetString(html, htmlTitle);

        //this.currentTitle = "This Is Title " + RandRange(0, 1000);
        //this.currentText = "<p>This is text</p><p>So is this</p>";
    }

    	public function PlaySound(soundName : String){theSound.SoundEvent(soundName);}
    	public function PlaySelectSound(){theSound.SoundEvent("gui_global_highlight");}
	public function PlayOpenSound(){theSound.SoundEvent("gui_global_panel_open");}
	public function PlayCloseSound(){theSound.SoundEvent("gui_global_panel_close");}
	public function PlayDeniedSound(){theSound.SoundEvent("gui_global_denied");}
	public function PlayWhooshSound(){theSound.SoundEvent("gui_no_stamina");}//gui_global_submenu_woosh
	public function PlayTickSound(){theSound.SoundEvent("gui_ingame_wheel_highlight");}
    
    //=============================================================
    //===                                                       ===
    //===                   Static Functions                    ===
    //===                                                       ===
    //=============================================================

    function SCMPlaySoundPopup(soundName : String)
    {
        theSound.SoundEvent( soundName );
        /*var guiManager: CR4GuiManager;
        var messagePopupRef : CR4PopupBase;
        
        guiManager = theGame.GetGuiManager();
        
        messagePopupRef = (CR4PopupBase)guiManager.GetPopup('TutorialPopup');
        if (messagePopupRef)
        {
            messagePopupRef.OnPlaySoundEvent(soundName);
        }*/
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

    /*
        Translated from ActionScript in popup_tutorial.redswf #TutorialPopup.alignContent
        For some reason calling the data setter function causes the menu to flicker
        So instead I've just updated the data manually, and aligned everything here.
        This also alows for greater control over the positions of things. 
    */
    //This function is focused on positioning and aligning the tutorial popup's content. It handles things like:
    //The comment about "translated from ActionScript" suggests that this code was adapted from an earlier Flash/ActionScript-based implementation, which was used in a previous UI system (likely in the SWF files). The developer is indicating that the original layout logic was translated from Flash to the current game scripting language.
    //This could mean that earlier the UI system might have used Flash (SWF) files for dynamic UI elements, and now it's being handled directly within the game's scripting system (likely using REDkit and their custom game scripts).
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

        /*mcCorrectFeedback.SetMemberFlashNumber("x", background.GetMemberFlashNumber("x"));
        mcCorrectFeedback.SetMemberFlashNumber("y", background.GetMemberFlashNumber("y"));
        mcCorrectFeedback.SetMemberFlashNumber("width", background.GetMemberFlashNumber("width"));
        mcCorrectFeedback.SetMemberFlashNumber("height", background.GetMemberFlashNumber("height"));
        
        mcErrorFeedback.SetMemberFlashNumber("x", background.GetMemberFlashNumber("x"));
        mcErrorFeedback.SetMemberFlashNumber("y", background.GetMemberFlashNumber("y"));
        mcErrorFeedback.SetMemberFlashNumber("width", background.GetMemberFlashNumber("width"));
        mcErrorFeedback.SetMemberFlashNumber("height", background.GetMemberFlashNumber("height")); */
        
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

        // LogSCM("flashBase " + flashBase.GetX() + ", " + flashBase.GetY());
        // LogSCM("flashBase2 " + flashBase.GetMemberFlashNumber("x") + ", " + flashBase.GetMemberFlashNumber("y"));
        // LogSCM("popupInstance " + popupInstance.GetMemberFlashNumber("x") + ", " + popupInstance.GetMemberFlashNumber("y"));

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

    /*
        Either creates a side menu with the required data, or updates an existing, open, side menu.
    */
    //If the side window (popup) is already open, it updates it with the new title and text. If it's not open, it creates a new side window using CreateSideWindow.
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

/*

[SCMMenuBase]
IK_W=(Action=SCMUp)
IK_A=(Action=SCMLeft)
IK_S=(Action=SCMDown)
IK_D=(Action=SCMRight)
IK_Up=(Action=SCMUp)
IK_Down=(Action=SCMDown)
IK_Left=(Action=SCMLeft)
IK_Right=(Action=SCMRight)
IK_E=(Action=SCME)
IK_Escape=(Action=SCMEscape)
IK_Z=(Action=SCMEscape)
IK_A=(Action=MCM_K_A)
IK_B=(Action=MCM_K_B)
IK_C=(Action=MCM_K_C)
IK_D=(Action=MCM_K_D)
IK_E=(Action=MCM_K_E)
IK_F=(Action=MCM_K_F)
IK_G=(Action=MCM_K_G)
IK_H=(Action=MCM_K_H)
IK_I=(Action=MCM_K_I)
IK_J=(Action=MCM_K_J)
IK_K=(Action=MCM_K_K)
IK_L=(Action=MCM_K_L)
IK_M=(Action=MCM_K_M)
IK_N=(Action=MCM_K_N)
IK_O=(Action=MCM_K_O)
IK_P=(Action=MCM_K_P)
IK_Q=(Action=MCM_K_Q)
IK_R=(Action=MCM_K_R)
IK_S=(Action=MCM_K_S)
IK_T=(Action=MCM_K_T)
IK_U=(Action=MCM_K_U)
IK_V=(Action=MCM_K_V)
IK_W=(Action=MCM_K_W)
IK_X=(Action=MCM_K_X)
IK_Y=(Action=MCM_K_Y)
IK_Z=(Action=MCM_K_Z)

[Exploration]
IK_Z=(Action=OpenMCMMenu)

[RadialMenu]
IK_Z=(Action=OpenMCMMenu)

*/
