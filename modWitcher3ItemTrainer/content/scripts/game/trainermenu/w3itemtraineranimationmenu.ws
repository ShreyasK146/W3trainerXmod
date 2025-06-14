
exec function UIForTrainerAnim(animName : name, optional time : float)
{
    var testMenu : UIForTrainerTestMenu;

    testMenu = (UIForTrainerTestMenu)UIForTrainer__GetUIForTrainer().MenuManager.currentMenu;

    if(testMenu)
    {
        if(time <= 0.001)
        {
            time = 1;
        }
        testMenu.SetAnim(animName, time);
    }
}

class UIForTrainerTestMenu extends UIForTrainerMenu_Elements
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

    var movElement : UIForTrainer_MoveElement;
    var rotElement : UIForTrainer_RotElement;
    var spawnElement : UIForTrainerMenu_TextElement;


    public function AddMoveElement(id : name) : UIForTrainer_MoveElement
	{
		var element : UIForTrainer_MoveElement;
		element = new UIForTrainer_MoveElement in this;
		element.ID = id;

		this.AddChild(element);
		return element;
	}

    public function AddRotElement(id : name) : UIForTrainer_RotElement
	{
		var element : UIForTrainer_RotElement;
		element = new UIForTrainer_RotElement in this;
		element.ID = id;

		this.AddChild(element);
		return element;
	}

	protected function OnMenuCreated()
	{
	spawnElement = AddText('choose', true, "Choose Your Gift", COLOUR_SUB_MENU);
        movElement = AddMoveElement('mov');
        rotElement = AddRotElement('rot');
        AddText('test', false, "UIForTrainerAnim(anim, time)", COLOUR_DISABLED);
        AddText('print', true, "Print");
        AddText('reset', true, "Reset");

        startPos = thePlayer.GetWorldPosition();
        startRot = thePlayer.GetWorldRotation();
	}

    public function OnMenuClosed()
    {
        destroyEntity();
    }

    var chooseMenu : UIForTrainerChooseEntityMenu;
    private function OpenChooseMenu()
    {
        if(!chooseMenu) chooseMenu = new UIForTrainerChooseEntityMenu in this;
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

    }

	public function OnChange(element : UIForTrainerMenu_BaseElement)
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

class UIForTrainer_MoveElement extends UIForTrainer_MoveRotElementBase
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

class UIForTrainer_RotElement extends UIForTrainer_MoveRotElementBase
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

      
    }
}

class UIForTrainer_MoveRotElementBase extends UIForTrainerMenu_BaseElement
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
class UIForTrainerChooseEntityMenu extends UITrainerBase
{
     var currentNode : UIForTrainerMenu_EntityListBase;
    public var nam : name;
    public var app : name;
    public var dis : name;
    public var dep : String;
    
    public function ItemCount() : int
	{
		return currentNode.GetChildCount() + currentNode.GetValueCount();
	}
	
	public function GetItem(index : int) : String
	{
        if(index < currentNode.GetChildCount())
        {
            return currentNode.GetChildAt(index).GetName();
        }
		return NameToString(currentNode.GetDisplayNameAt(index - currentNode.GetChildCount()));
	}

    public function GetColour(index : int) : String
    {
        if(index < currentNode.GetChildCount())
        {
            return COLOUR_SUB_MENU;
        }
        return "";
    }

	protected function OnMenuCreated()
	{
        currentNode = UIForTrainer__GetUIForTrainer().EntityList.dataALL;
	}

    public function GetMetaInfo() : String
	{
		return "<font size=\"16\">" + currentNode.GetMetaInfo(this.selectedIndex) + "</font>";
	}

	public function OnMenuOpened()
	{
        this.selectedIndex = currentNode.RetrieveSelectedIndex();
	}

	public function OnMenuClosed()
	{
        currentNode.StoreSelectedIndex(this.selectedIndex);
	}
	
	public function GetName() : String
	{
		return "Choose Your Gift";
	}

    public function selectLeft(optional rapid : bool)
	{
        if(currentNode.GetParentListWithOverride())
        {
            currentNode.StoreSelectedIndex(this.selectedIndex);
            currentNode = currentNode.GetParentListWithOverride();
            this.selectedIndex = currentNode.RetrieveSelectedIndex();
            window.UpdateAndRefresh();
            window.PlayCloseSound();
        }
        else
        {
            window.CloseMenu();
        }
    }

    public function selectRight(optional rapid : bool)
	{
        selectEnter(rapid);
    }

	public function selectEnter(optional rapid : bool)
	{
		if(this.selectedIndex < currentNode.GetChildCount())
        {
            currentNode.StoreSelectedIndex(this.selectedIndex);
            currentNode = currentNode.GetChildAt(this.selectedIndex);
            this.selectedIndex = currentNode.RetrieveSelectedIndex();
            window.UpdateAndRefresh();
            window.PlayOpenSound();
        }
        else
        {
            this.nam = currentNode.GetValueAt(this.selectedIndex - currentNode.GetChildCount());
            this.app = currentNode.GetAppearanceAt(this.selectedIndex - currentNode.GetChildCount());
            this.dis = currentNode.GetDisplayNameAt(this.selectedIndex - currentNode.GetChildCount());
            this.dep = currentNode.GetDepotPath();
            window.CloseMenu();
        }
	}
}

function UIForTrainer__GetUIForTrainer() : mod_UIForTrainer
{
	return mod_UIForTrainer_GetUIForTrainer();
}

function mod_UIForTrainer_GetUIForTrainer() : mod_UIForTrainer
{
	var NPC : UIForTrainerEntity;
	
	if(thePlayer.MODUIFORTRAINER)
	{

		return thePlayer.MODUIFORTRAINER;
	}
	else
	{
		NPC = mod_UIForTrainer_GetUIForTrainerEntity();
		if(NPC)
		{

			if(!NPC.MODUIFORTRAINER)
			{
				NPC.MODUIFORTRAINER = new mod_UIForTrainer in theGame;
          
				NPC.MODUIFORTRAINER.init();
			}
			thePlayer.mod_UIForTrainer_SET_UIForTrainer(NPC.MODUIFORTRAINER);
			return NPC.MODUIFORTRAINER;
		}
		else
		{
       
			return thePlayer.mod_UIForTrainer_CreateUIForTrainer();
		}
	}
    
}
function mod_UIForTrainer_GetUIForTrainerEntity(optional dontspawn : bool) : UIForTrainerEntity
{
	var NPC : UIForTrainerEntity;
    return NPC;
}


statemachine class UIForTrainerEntity extends CEntity
{
	public editable var MODUIFORTRAINER : mod_UIForTrainer;
	public editable var FOLLOWERDATA2 : mod_UIForTrainer_saved_data;
	public editable var HAS_DATA2 : bool;

	timer function UpdateTick(dt : float, id : int)
	{
	}

	public function SetFollowerDataForUITrainer(data : mod_UIForTrainer_saved_data)
	{
	
	}
	
	public function mod_uifortrainer_delayedDialogue(dialogRes : string, delay : float)
	{
	
	}
}
