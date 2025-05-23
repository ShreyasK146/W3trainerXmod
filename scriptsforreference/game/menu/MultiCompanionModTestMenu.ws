
exec function MCMAnim(animName : name, optional time : float)
{
    var testMenu : MCMTestMenu;

    testMenu = (MCMTestMenu)MCM_GetMCM().MenuManager.currentMenu;

    if(testMenu)
    {
        if(time <= 0.001)
        {
            time = 1;
        }
        testMenu.SetAnim(animName, time);
    }
}

class MCMTestMenu extends SCMMenu_Elements
{
    public var animName : name;
    public var animTime : float;

    public function SetAnim(nam : name, time : float)
    {
        this.animName = nam;
        this.animTime = time;
        animWaitTimeRemaining = 0;
    }

    var animWaitTimeRemaining : float;

    function playAnim()
    {
        var animComp : CMovingPhysicalAgentComponent;
        animComp =  (CMovingPhysicalAgentComponent)entity.GetComponentByClassName('CMovingPhysicalAgentComponent');
        animComp.PlaySlotAnimationAsync(this.animName, 'NPC_ANIM_SLOT');
        animWaitTimeRemaining = this.animTime;
    }

    function updateAnim(dt : float)
    {
        if(animWaitTimeRemaining > 0)
        {
            animWaitTimeRemaining -= dt;
        }
        if(entity && animWaitTimeRemaining <= 0 && IsNameValid(animName))
        {
            playAnim();
        }
    }

    public function GetName() : String
	{
		return "Test Menu";
	}

    var movElement : SCMMenu_MoveElement;
    var rotElement : SCMMenu_RotElement;
    var spawnElement : SCMMenu_TextElement;


    public function AddMoveElement(id : name) : SCMMenu_MoveElement
	{
		var element : SCMMenu_MoveElement;
		element = new SCMMenu_MoveElement in this;
		element.ID = id;

		this.AddChild(element);
		return element;
	}

    public function AddRotElement(id : name) : SCMMenu_RotElement
	{
		var element : SCMMenu_RotElement;
		element = new SCMMenu_RotElement in this;
		element.ID = id;

		this.AddChild(element);
		return element;
	}

	protected function OnMenuCreated()
	{
	spawnElement = AddText('choose', true, "Choose Entity", COLOUR_SUB_MENU);
        movElement = AddMoveElement('mov');
        rotElement = AddRotElement('rot');
        AddText('test', false, "MCMAnim(anim, time)", COLOUR_DISABLED);
        AddText('print', true, "Print");
        AddText('reset', true, "Reset");

        startPos = thePlayer.GetWorldPosition();
        startRot = thePlayer.GetWorldRotation();
	}

    public function OnMenuClosed()
    {
        destroyEntity();
    }

    var chooseMenu : MCMChooseEntityMenu;
    private function OpenChooseMenu()
    {
        if(!chooseMenu) chooseMenu = new MCMChooseEntityMenu in this;
        window.OpenMenu(chooseMenu);
    }

    public var quickUpdateSlowDown : int;

    public function updateQuickSlowly()
    {
        quickUpdateSlowDown+=1;
        if(quickUpdateSlowDown > 20)
        {
            quickUpdateSlowDown = 0;
            window.UpdateAndRefresh();
        }
    }

    public function printPosRot()
    {
        LogSCM("Vector(" + MCM_VecToStringPrec(movElement.position, 3) + "), EulerAngles(" + MCM_EulerToStringPrec(rotElement.rotation, 1) + ")");
    }

	public function OnChange(element : SCMMenu_BaseElement)
	{
		switch(element.ID)
		{
		case 'choose': OpenChooseMenu(); break;
            	case 'mov': updateQuickSlowly(); break;
            	case 'rot': updateQuickSlowly(); break;
            	case 'print': printPosRot(); break;
            	case 'reset': respawnEntity(true); break;
		}
	}

    var startPos : Vector;
    var startRot : EulerAngles;

    var entityName : name; default entityName = 'triss';
    var depotPath : String;
    var entity : CNewNPC;

    public function destroyEntity(optional resetPos : bool)
    {
        if(entity)
        {
            if(resetPos)
            {
                startPos = thePlayer.GetWorldPosition();
                startRot = thePlayer.GetWorldRotation();
            }
            else
            {
                startPos = entity.GetWorldPosition();
                startRot = entity.GetWorldRotation();
            }
            entity.Destroy();
            entity = NULL;
        }
    }

    public function respawnEntity(optional resetPos : bool)
    {
        var template : CEntityTemplate;
        destroyEntity(resetPos);
        LogSCM("Spawning New Entity " + entityName + ":" + depotPath);
        template = MCM_GetEntityTemplate(entityName, depotPath);
        if(template)
        {
            entity = (CNewNPC)theGame.CreateEntity(template, startPos, startRot);
            if(entity)
            {
                entity.EnableCharacterCollisions(false);
                entity.SetImmortalityMode(AIM_Immortal, AIC_Default, true);
                entity.SetImmortalityMode(AIM_Immortal, AIC_Combat, true);
                entity.SetImmortalityMode(AIM_Immortal, AIC_Fistfight, true);
                entity.SetImmortalityMode(AIM_Immortal, AIC_IsAttackableByPlayer, true);
                entity.SetTemporaryAttitudeGroup( 'friendly_to_player', AGP_Default );
                entity.SetAttitude( thePlayer, AIA_Friendly );
                thePlayer.SetAttitude( entity, AIA_Friendly );
            }
        }

        movElement.position = startPos;
        rotElement.rotation = startRot;
    }

    public function OnMenuOpened()
    {
        if(chooseMenu)
        {
            if(chooseMenu.nam != entityName || chooseMenu.dep != depotPath)
            {
                entityName = chooseMenu.nam;
                depotPath = chooseMenu.dep;
            }
        }
        animWaitTimeRemaining = 0;
        respawnEntity();
        spawnElement.textValue = NameToString(entityName);
    }

	public function onTick(dt : float)
	{
        super.onTick(dt);
        updateAnim(dt);
        movElement.tickFast();
        rotElement.tickFast();

        if(entity)
        {
            entity.TeleportWithRotation(movElement.position, rotElement.rotation);
        }
	}
}

class SCMMenu_MoveElement extends SCMMenu_MoveRotElementBase
{
    public var position : Vector;

	public function GetValue() : String
	{
        return VecToString(position);
	}

    public function tickFast()
    {
        var forwardVec : Vector;
        var rightVec : Vector;
        var upVec : Vector;

        var moveVec : Vector;
        
        upVec = Vector(0, 0, 1);
        forwardVec = theCamera.GetCameraDirection(); forwardVec.Z = 0; forwardVec = VecNormalize(forwardVec);
        rightVec = VecCross(forwardVec, Vector(0, 0, 1));
        
        if(isFocused)
        {
            if(lShiftDown||rShiftDown) moveVec -= upVec;
            if(spaceDown) moveVec += upVec;
            if(wDown) moveVec += forwardVec;
            if(aDown) moveVec -= rightVec;
            if(sDown) moveVec -= forwardVec;
            if(dDown) moveVec += rightVec;
            if(VecLengthSquared(moveVec) > 0)
            {
                position += moveVec * 0.02;
                root.OnChange(this);
            }
        }
    }
}

class SCMMenu_RotElement extends SCMMenu_MoveRotElementBase
{
    public var rotation : EulerAngles;

	public function GetValue() : String
	{
        return "P "+ rotation.Pitch +"Y "+ rotation.Yaw +"R" + rotation.Roll;
	}

    public function tickFast()
    {
        var changed : bool;

        if(isFocused)
        {
            if(aDown) {rotation.Yaw += 0.5; changed = true;}
            if(dDown) {rotation.Yaw -= 0.5; changed = true;}
            if(wDown) {rotation.Pitch -= 0.5; changed = true;}
            if(sDown) {rotation.Pitch += 0.5; changed = true;}
            if(changed)
            {
                root.OnChange(this);
            }
        }

        //root.onChange(this);
    }
}

class SCMMenu_MoveRotElementBase extends SCMMenu_BaseElement
{
	public var lShiftDown : bool;
	public var rShiftDown : bool;
	public var ctrlDown : bool;
    	public var spaceDown : bool;
    	public var wDown : bool;
    	public var aDown : bool;
    	public var sDown : bool;
    	public var dDown : bool;
	private var backspaceDown : bool;
	protected var isFocused : bool;

	public function selectEnter(optional rapid : bool) : bool
	{
		this.flashGreen = true;
		this.isFocused = true;
		root.window.StartCapture();
		root.window.UpdateAndRefresh();
		root.window.PlayTickSound();
		return true;
	}

	public function GetValue() : String
	{
		return "[BaseElement]";
	}

    public function tickFast()
    {

    }

	private function ExitCapture()
	{
		this.flashGreen = false;
		this.isFocused = false;

		root.window.EndCapture();
		root.window.PlayWhooshSound();
		root.window.UpdateAndRefresh();

        	lShiftDown = false;
        	rShiftDown = false;
        	spaceDown = false;
        	wDown = false;
        	aDown = false;
        	sDown = false;
        	dDown = false;
	}

	function OnKey(action : SInputAction, letter : name)
    {
		switch(letter)
		{
			case 'LShift': lShiftDown = IsPressed(action); return;
			case 'RShift': rShiftDown = IsPressed(action); return;
			case ' ': spaceDown = IsPressed(action); return;
			case 'W': wDown = IsPressed(action); return;
			case 'A': aDown = IsPressed(action); return;
			case 'S': sDown = IsPressed(action); return;
			case 'D': dDown = IsPressed(action); return;
			case 'T': wDown = IsPressed(action); return;
			case 'F': aDown = IsPressed(action); return;
			case 'G': sDown = IsPressed(action); return;
			case 'H': dDown = IsPressed(action); return;
		}

        if(IsPressed(action))
        {
            switch(letter)
            {
                case 'Escape': ExitCapture(); return;
                case 'E': ExitCapture(); return;
            }
        }
    }
}
