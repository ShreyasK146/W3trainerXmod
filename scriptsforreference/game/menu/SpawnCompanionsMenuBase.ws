/*MenuBase Template

class SCM!Template! extends SCMMenuBase
{
	public function ItemCount() : int
	{
		return !dao!.Size();
	}
	
	public function GetItem(index : int) : String
	{
		return !dao![index].value";
	}

	protected function OnMenuCreated()
	{
		!dao!.setup();
	}

	public function onSelectionChanged(from, to : int)
	{

	}
	
	public function OnMenuOpened()
	{

	}

	public function OnMenuClosed()
	{

	}
	
	public function GetName() : String
	{
		return !MenuName!;
	}

	public function selectEnter(optional rapid : bool)
	{
		!dao!.doSomething();
	}
}*/

class SCMMenuBase
{
	public const var COLOUR_SUB_MENU : String; default COLOUR_SUB_MENU = "fcb103";
	public const var COLOUR_SUB_MENU_SPECIAL : String; default COLOUR_SUB_MENU_SPECIAL = "c16002";
	public const var COLOUR_DISABLED : String; default COLOUR_DISABLED = "555555";
	public const var COLOUR_ITEM : String; default COLOUR_ITEM = "ffffff";
	public const var COLOUR_CAREFUL : String; default COLOUR_CAREFUL = "ad1f03";
	public const var COLOUR_ACTIVATE : String; default COLOUR_ACTIVATE = "85ff85";
	public const var COLOUR_RED : String; default COLOUR_RED = "c10f0f";
	public const var COLOUR_GREEN : String; default COLOUR_GREEN = "18c10f";

	public var window : MCM_MenuManager;
	
	public editable var selectedIndex : int; default selectedIndex = 0;
	public editable var showItemIndicator : bool; default showItemIndicator = true;
	
	private var _hasBeenCreated : bool; default _hasBeenCreated = false;
	public function _OnMenuCreated()
	{
		if(_hasBeenCreated) return;
		_hasBeenCreated = true;
		this.SetCleanupFunction('OnMenuDestroyed');
		this.OnMenuCreated();
	}

	protected function colr(str : String, colour : String) : String
	{
		return "<FONT color=\"#" + colour + "\">" + str + "</FONT>";
	}

	public function GetMetaInfo() : String
	{
		return "";
	}
	
	public function ItemCount() : int
	{
		return 0;
	}
	
	public function GetItem(index : int) : String
	{
		return "NULL";
	}

	public function IsValidSelection(index : int) : bool
	{
		return true;
	}

	function OnKey(action : SInputAction, letter : name)
    	{
    		LogSCM("Why am I captured " + this);
	}

	public function onTick(dt : float){}

	protected function OnMenuCreated(){}
	public function OnMenuOpened(){}
	public function OnMenuClosed(){}
	public function OnMenuDestroyed(){}

	public function onSelectionChanged(from, to : int){}
	
	public function GetColour(index : int) : String
	{
		return "";
	}
	
	public function GetName() : String
	{
		return "BadMenu";
	}

	public function selectUp(optional rapid : bool)
	{
		var count, maxTry, from : int;
		count = ItemCount();
		maxTry = count;
		from = selectedIndex;

		if(count > 1)
		{
			do
			{
				selectedIndex -= 1;
				if(selectedIndex < 0)
				{
					selectedIndex = count-1;
				}
				if(this.IsValidSelection(selectedIndex))
				{
					window.UpdateAndRefresh();
					window.PlaySelectSound();
					this.onSelectionChanged(from, selectedIndex);
					break;
				}
				
				maxTry-=1;
			} while(maxTry > 0)

			if(maxTry == 0)
			{
				selectedIndex = from;
				window.PlayDeniedSound();
			}
		}
		else
		{
			window.PlayDeniedSound();
		}
	}
	//IsValidSelection
	public function selectDown(optional rapid : bool)
	{
		var count, maxTry, from : int;
		count = ItemCount();
		maxTry = count;
		from = selectedIndex;

		if(count > 1)
		{
			do
			{
				selectedIndex += 1;
				if(selectedIndex >= count)
				{
					selectedIndex = 0;
				}
				
				if(this.IsValidSelection(selectedIndex))
				{
					window.UpdateAndRefresh();
					window.PlaySelectSound();
					this.onSelectionChanged(from, selectedIndex);
					break;
				}
				
				maxTry-=1;
			} while(maxTry > 0)
			
			if(maxTry == 0)
			{
				selectedIndex = from;
				window.PlayDeniedSound();
			}
		}
		else
		{
			window.PlayDeniedSound();
		}
	}
	
	public function selectLeft(optional rapid : bool)
	{
		selectExit(rapid);
	}

	public function selectRight(optional rapid : bool)
	{
		selectEnter(rapid);
	}

	public function selectEnter(optional rapid : bool) {}
	
	public function selectExit(optional rapid : bool)
	{
		window.CloseMenu();
	}
}

class SCMMenu_StringList extends SCMMenuBase
{
	var lines : array<String>;
	protected function nl(str : String)
	{
		lines.PushBack(str);
	}
	
	public function ItemCount() : int
	{
		return lines.Size();
	}
	
	public function GetItem(index : int) : String
	{
		return lines[index];
	}
	
	public function GetName() : String
	{
		return "String List";
	}
}

class SCMMenu_Text extends SCMMenuBase
{
	public editable var text : String;
	public editable var title : String;
	
	public function ItemCount() : int
	{
		return 1;
	}
	
	public function GetItem(index : int) : String
	{
		return text;
	}
	
	protected function OnMenuCreated()
	{
		showItemIndicator = false;
	}
	
	public function GetName() : String
	{
		return title;
	}
}

class SCMMenu_NameList extends SCMMenuBase
{
	var lines : array<name>;
	protected function nl(str : name)
	{
		lines.PushBack(str);
	}
	
	public function ItemCount() : int
	{
		return lines.Size();
	}
	
	public function GetItem(index : int) : String
	{
		return NameToString(lines[index]);
	}

	public function GetItemAsName(index : int) : name
	{
		return lines[index];
	}

	public function GetName() : String
	{
		return "Name List";
	}
}

class SCMMenu_Elements extends SCMMenuBase
{
	var elements : array<SCMMenu_BaseElement>;

	function OnKey(action : SInputAction, letter : name)
    	{
		elements[this.selectedIndex].OnKey(action, letter);
	}

	public function GetIndexByID(ID : name) : int
	{
		var i : int;
		for(i = elements.Size()-1; i >= 0; i-=1)
		{
			if(elements[i].ID == ID)
			{
				return i;
			}
		}
		return -1;
	}

	protected function AddChild(element : SCMMenu_BaseElement)
	{
		element.root = this;
		elements.PushBack(element);
	}
	
	public function ItemCount() : int
	{
		return elements.Size();
	}

	public function GetItem(index : int) : String
	{
		return elements[index].GetValue();
	}

	public function GetColour(index : int) : String
	{
		if(elements[index].Disabled)
		{
			return COLOUR_DISABLED;
		}
		return elements[index].GetColour();
	}

	public function IsValidSelection(index : int) : bool
	{
		if(elements[index].Disabled)
		{
			return false;
		}
		return elements[index].IsValidSelection();
	}

	public function GetElementAt(index : int) : SCMMenu_BaseElement
	{
		return elements[index];
	}	

	private var dtAdd : float;
	private var dtAdd2 : float;
	public function onTick(dt : float)
	{
		dtAdd += dt;
		dtAdd2 += dt;
		if(dtAdd2 > 0.05)
		{
			dtAdd2 = 0;
			elements[this.selectedIndex].Tick100Ms();
		}
		if(dtAdd > 0.5)
		{
			dtAdd = 0;
			if(elements[this.selectedIndex].flashGreen)
			{
				window.FlashGoodBad(true, this.selectedIndex+1);
			}
			else if(elements[this.selectedIndex].flashRed)
			{
				window.FlashGoodBad(false, this.selectedIndex+1);
			}
		}
	}

	public function selectUp(optional rapid : bool)
	{
		if(!elements[selectedIndex].selectUp(rapid))
		{
			super.selectUp(rapid);
		}
	}

	public function selectDown(optional rapid : bool)
	{
		if(!elements[selectedIndex].selectDown(rapid))
		{
			super.selectDown(rapid);
		}
	}
	
	public function selectLeft(optional rapid : bool)
	{
		if(!elements[selectedIndex].selectLeft(rapid))
		{
			window.CloseMenu();
		}
	}

	public function selectRight(optional rapid : bool)
	{
		elements[selectedIndex].selectRight(rapid);
	}

	public function selectExit(optional rapid : bool)
	{
		if(!elements[selectedIndex].selectExit(rapid))
		{
			window.CloseMenu();
		}
	}
	
	public function selectEnter(optional rapid : bool)
	{
		elements[selectedIndex].selectEnter(rapid);
	}

	public function OnChange(element : SCMMenu_BaseElement)
	{
		LogSCM(element.ID + " changed. Deal with it. Plz");
	}

	public function GetName() : String
	{
		return "Element List";
	}

	public function AddText(id : name, clickable : bool, text : String, optional colour : String) : SCMMenu_TextElement
	{
		var element : SCMMenu_TextElement;
		element = new SCMMenu_TextElement in this;
		element.ID = id;
		element.clickable = clickable;
		element.textValue = text;
		element.colourValue = colour;

		this.AddChild(element);
		return element;
	}

	public function AddCounter(id : name, text : String, start, min, max : int) : SCMMenu_Counter
	{
		var element : SCMMenu_Counter;
		element = new SCMMenu_Counter in this;
		element.ID = id;
		element.prefix = text;
		element.Setup(start, min, max);

		this.AddChild(element);
		return element;
	}

	public function AddDoubleButton(id : name, text : String, optional normalColour, selectedColour : String) : SCMMenu_DoubleClickButton
	{
		var element : SCMMenu_DoubleClickButton;
		element = new SCMMenu_DoubleClickButton in this;
		element.ID = id;
		element.text = text;
		element.normalColour = normalColour;
		element.selectedColour = selectedColour;

		this.AddChild(element);
		return element;
	}

	private function SplitString(str : String, delemiter : String) : array<String>
	{
		var result : array<String>;
		var strLeft, strRight : String;
		while(StrSplitFirst(str, delemiter, strLeft, strRight))
		{
			result.PushBack(strLeft);
			str = strRight;
		}

		result.PushBack(str);

		return result;
	}

	public function AddEnum(id : name, prepend : String, values : String, optional delemiter : String) : SCMMenu_Enum
	{
		var element : SCMMenu_Enum;
		element = new SCMMenu_Enum in this;
		element.ID = id;
		element.prepend = prepend;

		if(delemiter == "")
		{
			delemiter = ",";
		}

		element.values = SplitString(values, delemiter);

		this.AddChild(element);
		return element;
	}

	public function AddInputText(id : name, value : String, defaultValue : String) : SCMMenu_InputElement
	{
		var element : SCMMenu_InputElement;
		element = new SCMMenu_InputElement in this;
		element.ID = id;
		element.value = value;
		element.defaultValue = defaultValue;

		this.AddChild(element);
		return element;
	}
}

class SCMMenu_BaseElement
{
	public var root : SCMMenu_Elements;
	public var ID : name;

	public var flashGreen : bool;
	public var flashRed : bool;
	public var Disabled : bool; default Disabled = false;

	function OnKey(action : SInputAction, letter : name)
    	{
		LogSCM("Why am I captured");
	}

	protected function colr(str : String, colour : String) : String
	{
		return "<FONT color=\"#" + colour + "\">" + str + "</FONT>";
	}
	
	public function GetColour() : String
	{
		return "";
	}
	
	public function GetValue() : String
	{
		return "[BaseElement]";
	}

	public function IsValidSelection() : bool
	{
		return true;
	}

	public function Tick100Ms()
	{

	}
	
	public function selectLeft(optional rapid : bool) : bool {return false;}
	public function selectRight(optional rapid : bool) : bool {return false;}
	public function selectUp(optional rapid : bool) : bool {return false;}
	public function selectDown(optional rapid : bool) : bool {return false;}
	public function selectEnter(optional rapid : bool) : bool {return false;}
	public function selectExit(optional rapid : bool) : bool {return false;}
}

class SCMMenu_InputElement extends SCMMenu_BaseElement
{
	public var value : String;
	public var defaultValue : String; default defaultValue = "Select to Edit";

	public var lShiftDown : bool;
	public var rShiftDown : bool;
	private var backspaceDown : bool;
	private var isFocused : bool;

	private var backspaceCountTick : int; default backspaceCountTick = 0;
	//Handles holding the backspace key and deleting the character repeatedly if it's held down.
	public function Tick100Ms()
	{
		if(backspaceDown)
		{
			backspaceCountTick += 1;
			if(backspaceCountTick > 3)
			{
				doBackspace();
			}
		}
		else
		{
			backspaceCountTick = 0;
		}
	}
	//Focuses on the input field, starts capturing input, and plays a sound to indicate focus.
	public function selectEnter(optional rapid : bool) : bool
	{
		this.flashGreen = true;
		this.isFocused = true;
		root.window.StartCapture();
		root.window.UpdateAndRefresh();
		root.window.PlayTickSound();
		return true;
	}
	//Returns the current value in the input field, or the default text if nothing is typed.
	public function GetValue() : String
	{
		if(value == "" && !this.isFocused)
		{
			return defaultValue;
		}
		return value;
	}
	//Deletes the last character from the value when backspace is pressed.
	private function doBackspace()
	{
		if(StrLen(value) > 0)
		{
			value = StrLeft(value, StrLen(value)-1);
			root.OnChange(this);
			root.window.PlayTickSound();
			root.window.UpdateAndRefresh();
		}
		else
		{
			root.window.PlayDeniedSound();
		}
	}
//Checks for backspace key presses and calls doBackspace() when necessary.
	private function CheckBackspace(action : SInputAction)
	{
		this.backspaceDown = IsPressed(action);
		if(this.backspaceDown)
		{
			doBackspace();
		}
		else
		{
			backspaceCountTick = 0;
		}
	}
	//Stops capturing input, and exits the focused state.
	private function ExitCapture()
	{
		this.flashGreen = false;
		this.isFocused = false;

		root.window.EndCapture();
		root.window.PlayWhooshSound();
		root.window.UpdateAndRefresh();
	}
//Handles the Enter key press to finalize input and exit capture mode.
	private function CheckEnter(action : SInputAction)
	{
		if(IsPressed(action))
		{
			this.isFocused = false;
			root.OnChange(this);
			ExitCapture();
		}
	}
	//This is the key input handler. It responds to the input actions (typing, shifts, backspace, enter, etc.) to modify the value.
	function OnKey(action : SInputAction, letter : name)
    	{
		switch(letter)
		{
			case 'LShift': lShiftDown = IsPressed(action); return;
			case 'RShift': rShiftDown = IsPressed(action); return;
			case 'Backspace': CheckBackspace(action); return;
			case 'Enter': CheckEnter(action); return;
			case 'Escape': ExitCapture(); return;
		}

		if(IsPressed(action))
		{
			if(lShiftDown || rShiftDown)
			{
				value = value + StrUpper(NameToString(letter));
			}
			else
			{
				value = value + StrLower(NameToString(letter));
			}
			root.OnChange(this);
			root.window.PlayTickSound();
			root.window.UpdateAndRefresh();
		}
	}
}
//Represents a text element that can be displayed in the menu. It can be clicked to trigger actions.
class SCMMenu_TextElement extends SCMMenu_BaseElement
{
	public var textValue : String; default textValue = "Change This Text";
	public var colourValue : String; default colourValue = "";
	public var clickable : bool; default clickable = true;

	public function GetValue() : String
	{
		return textValue;
	}

	public function GetColour() : String
	{
		return this.colourValue;
	}

	public function IsValidSelection() : bool
	{
		return clickable;
	}

	public function selectRight(optional rapid : bool) : bool
	{
		if(clickable)
		{
			root.OnChange(this);
			return true;
		}
		return false;
	}

	public function selectEnter(optional rapid : bool) : bool
	{
		if(clickable)
		{
			root.OnChange(this);
			return true;
		}
		return false;
	}
}
//Represents a button element in the menu that requires a double-click to be selected, and changes color when focused.
class SCMMenu_DoubleClickButton extends SCMMenu_BaseElement
{
	public var text : String; default text = "[Button]";
	public var normalColour : String; default normalColour = "";
	public var selectedColour : String; default selectedColour = "";

	private var isFocused : bool; default isFocused = false;

	public function GetValue() : String
	{
		return this.text;
	}

	public function GetColour() : String
	{
		if(this.isFocused)
		{
			return this.selectedColour;
		}
		return this.normalColour;
	}

	public function onMove() : bool
	{
		if(this.isFocused)
		{
			this.isFocused = false;
			this.flashRed = false;
			root.window.PlayDeniedSound();
			root.window.UpdateAndRefresh();
			return true;
		}
		return false;
	}

	public function selectUp(optional rapid : bool) : bool 		{return onMove();}
	public function selectDown(optional rapid : bool) : bool 	{return onMove();}
	public function selectLeft(optional rapid : bool) : bool 	{return onMove();}
	public function selectRight(optional rapid : bool) : bool 	{return onMove();}

	public function selectEnter(optional rapid : bool) : bool
	{
		if(!this.isFocused)
		{
			this.isFocused = true;
			this.flashRed = true;
			root.window.PlaySelectSound();
			root.window.UpdateAndRefresh();
			return true;
		}
		this.isFocused = false;
		this.flashRed = false;
		root.window.PlaySelectSound();
		root.OnChange(this);
		return true;
	}
}
//This class is a base class for elements that can be focused (like buttons or sliders). It handles focus and allows interaction when the element is focused.
class SCMMenu_FocusableElement extends SCMMenu_BaseElement
{
	private var isFocused : bool; default isFocused = false;

	public function selectUp(optional rapid : bool) : bool {return this.isFocused;}
	public function selectDown(optional rapid : bool) : bool {return this.isFocused;}

	public function selectLeft(optional rapid : bool) : bool
	{
		if(this.isFocused)
		{
			this.selectLeftF(rapid);
			return true;
		}
		return false;
	}

	public function selectRight(optional rapid : bool) : bool
	{
		if(this.isFocused)
		{
			this.selectRightF(rapid);
			return true;
		}
		return false;
	}

	public function selectEnter(optional rapid : bool) : bool
	{
		this.isFocused = !this.isFocused;
		this.flashGreen = this.isFocused;
		root.window.PlaySelectSound();
		return true;
	}

	public function selectLeftF(optional rapid : bool){}
	public function selectRightF(optional rapid : bool){}
}
//A counter element in the menu. It allows users to increase or decrease the value within a specified range.
class SCMMenu_Counter extends SCMMenu_FocusableElement
{
	private var value : int;
	private var minValue : int;
	private var maxValue : int;
	public var prefix : String;
	public var numberColour : String; default numberColour = "2299EE";

	public function Setup(startValue, minValue, maxValue : int)
	{
		this.minValue = minValue;
		this.maxValue = maxValue;
		this.SetValue(startValue);
	}

	public function GetCounterValue() : int
	{
		return this.value;
	}

	public function GetValue() : String
	{
		return prefix + colr(""+this.value, numberColour);
	}

	public function SetValue(value : int) : bool
	{
		if(value < minValue) value = minValue;
		if(value > maxValue) value = maxValue;
		if(value != this.value)
		{
			this.value = value;
			return true;
		}
		return false;
	}

	public function selectLeftF(optional rapid : bool) 
	{
		if(SetValue(value - 1))
		{
			root.OnChange(this);
			root.window.PlayTickSound();
		}
		else
		{
			root.window.PlayDeniedSound();
		}
	}

	public function selectRightF(optional rapid : bool)
	{
		if(SetValue(value + 1))
		{
			root.OnChange(this);
			root.window.PlayTickSound();
		}
		else
		{
			root.window.PlayDeniedSound();
		}
	}
}
//Allows the user to select from a list of predefined options (like a dropdown).
class SCMMenu_Enum extends SCMMenu_FocusableElement
{
	public var values : array<String>;
	public var selectedIndex : int; default selectedIndex = 0;
	public var prepend : String; default prepend = "";

	public var enumColour : String; default enumColour = "2299EE";

	public function GetSelectedEnum() : String
	{
		return values[selectedIndex];
	}

	public function GetValue() : String
	{
		return prepend + colr(""+this.values[selectedIndex], enumColour);
	}

	public function selectLeftF(optional rapid : bool) 
	{
		selectedIndex -= 1;
		if(selectedIndex < 0)
		{
			selectedIndex = values.Size()-1;
		}

		root.OnChange(this);
		root.window.PlayTickSound();
	}

	public function selectRightF(optional rapid : bool)
	{
		selectedIndex += 1;
		if(selectedIndex >= values.Size())
		{
			selectedIndex = 0;
		}

		root.OnChange(this);
		root.window.PlayTickSound();
	}
}/*

statemachine class SCMMenu
{
	var MAX_SHOW : int; default MAX_SHOW = 16;//15;
	var isFocused : bool; default isFocused = true;

	default autoState = 'Idle';
	
	var menus : array<SCMMenuBase>;
	var currentMenu : SCMMenuBase;
	
	public function OpenMenu(menu : SCMMenuBase)
	{
		if(menu)
		{
			menu.Init();
			menus.PushBack(menu);
			currentMenu = menus[menus.Size()-1];
			UpdateMenu();
			PlayOpenSound();
		}
	}
	
	public function CloseMenu()
	{
		if(menus.Size() > 1)
		{
			menus.PopBack();
			currentMenu = menus[menus.Size()-1];
			currentMenu.OnEnterFromExit();
			UpdateMenu();
			PlayCloseSound();
		}
		else if(menus.Size() == 1)
		{
			menus.PopBack();
			currentMenu = NULL;
			cleanupKeyDownStates();
			ClosePopup();
		}
	}

	public function ClosePopup()
	{
		PlayCloseSound();
		theGame.ClosePopup('TutorialPopup');
	}
	
	public function UpdateMenu()
	{
		var html, htmlTitle, colour : String;
		var i : int;
		var itemCount : int;
		
		var startIndex : int;
		var endIndex : int;
		var innerTxt : String;
		
		itemCount = currentMenu.ItemCount();
		
		startIndex = currentMenu.selectedIndex - 7;
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
		//img://textures/journal/characters/journal_damien.png
		//Mouse_LeftBtn.png
		//html += "<img src=\"img://icons/monsters/ICO_MonsterDefault.png\" vspace=\"-10\" />";
		SetString(html, htmlTitle);
	}
	
	public function PlaySound(soundName : String)
	{
		var messagePopupRef : CR4PopupBase;
		
		messagePopupRef = (CR4PopupBase)theGame.GetGuiManager().GetPopup('TutorialPopup');
		if (messagePopupRef)
		{
			messagePopupRef.OnPlaySoundEvent(soundName);
		}
	}
	
	public function PlaySelectSound(){PlaySound("gui_global_highlight");}
	public function PlayOpenSound(){PlaySound("gui_global_panel_open");}
	public function PlayCloseSound(){PlaySound("gui_global_panel_close");}
	
	event OnEnterState( prevStateName : name )
	{
	}
	
	event OnLeaveState( nextStateName : name )
	{
	}
	
	private var currentString: String;
	private var currentTitle: String;
	
	public function Open()
	{
		var rootMenu : SCMMenuMain;
		LogSCM("Current State " + this.GetCurrentStateName());
	
		if(!this.IsInState('Open'))
		{
			if(currentMenu)
			{
				cleanupKeyDownStates();
				Refresh();
			}
			else
			{
				rootMenu = new SCMMenuMain in this;
				OpenMenu(rootMenu);
			}
			this.GotoState('Open');
			this.isFocused = true;
		}
	}
	
	public function SetString(str : String, optional title : String)
	{
		currentString = str;
		currentTitle = title;
		MCM_ShowSideMenu(title, str, false, false);
	}
	
	public function Refresh()
	{
		LogSCM("Refreshing!!");
		MCM_ShowSideMenu(currentTitle, currentString, false, false);
	}

	public function ToggleFocus()
	{
		if(this.isFocused)
		{
			this.Unfocus();
		}
		else
		{
			this.Focus();
		}
	}

	public function Focus()
	{
		UnregisterKeys();
		RegisterKeys();
		this.isFocused = true;
		theInput.SetContext('SCMMenuBase');
	}

	public function Unfocus()
	{
		UnregisterKeys();
		this.isFocused = false;
		theInput.SetContext('Exploration');
	}
	
	var keydowns : array<int>;

	public function cleanupKeyDownStates()
	{
		var i : int;
		for(i = 0; i < keydowns.Size(); i+=1)
		{
			keydowns[i] = 0;
		}
	}

	/*
	//Add the following to input.settings!

	[SCMMenuBase]
	IK_Space=(Action=SCMSpace)
	IK_S=(Action=SCMDown)
	IK_Right=(Action=SCMRight)
	IK_Left=(Action=SCMLeft)
	IK_W=(Action=SCMUp)
	IK_Z=(Action=CameraLock)
	IK_A=(Action=SCMLeft)
	IK_Down=(Action=SCMDown)
	IK_Up=(Action=SCMUp)
	IK_Backspace=(Action=SCMBack)
	IK_D=(Action=SCMRight)
	IK_Escape=(Action=SCMEscape)
	*//*
	
	protected function RegisterKeys()
	{
		theInput.RegisterListener(this, 'OnSCMUp', 'SCMUp');
		theInput.RegisterListener(this, 'OnSCMDown', 'SCMDown');
		theInput.RegisterListener(this, 'OnSCMLeft', 'SCMLeft');
		theInput.RegisterListener(this, 'OnSCMRight', 'SCMRight');
		//theInput.RegisterListener(this, 'OnSCMSpace', 'SCMSpace');
		theInput.RegisterListener(this, 'OnSCMBack', 'SCMBack');
		theInput.RegisterListener(this, 'OnSCMEscape', 'SCMEscape');
		theInput.RegisterListener(this, 'OnSCMSpace', 'SCME');
		if(keydowns.Size() == 0)
		{
			keydowns.PushBack(0);
			keydowns.PushBack(0);
			keydowns.PushBack(0);
			keydowns.PushBack(0);
			keydowns.PushBack(0);
			keydowns.PushBack(0);
		}
	}
	
	protected function UnregisterKeys()
	{
		theInput.UnregisterListener(this, 'SCMUp');
		theInput.UnregisterListener(this, 'SCMDown');
		theInput.UnregisterListener(this, 'SCMLeft');
		theInput.UnregisterListener(this, 'SCMRight');
		//theInput.UnregisterListener(this, 'SCMSpace');
		theInput.UnregisterListener(this, 'SCMBack'); 
		theInput.UnregisterListener(this, 'SCMEscape'); 
		theInput.UnregisterListener(this, 'SCME'); 
	}

	private function kp(id : int, ac : SInputAction)
	{
		if(IsPressed(ac))
		{
			keydowns[id] = 1;
		}
		else
		{
			keydowns[id] = -10;
		}
	}
	event OnSCMEscape(action : SInputAction)
	{
		if(IsPressed(action))
		{
			ClosePopup();
		}
	}
	event OnSCMUp(action : SInputAction)
	{
		kp(0, action);
	
		if(IsPressed(action))
		{
			this.currentMenu.selectPrev(this);
		}
	}
	event OnSCMDown(action : SInputAction)
	{
		kp(1, action);
		if(IsPressed(action))
		{
			this.currentMenu.selectNext(this);
		}
	}
	event OnSCMLeft(action : SInputAction)
	{
		kp(2, action);
		if(IsPressed(action))
		{
			this.currentMenu.selectLeft(this);
		}
	}
	event OnSCMRight(action : SInputAction)
	{
		kp(3, action);
		if(IsPressed(action))
		{
			this.currentMenu.selectRight(this);
		}
	}
	event OnSCMSpace(action : SInputAction)
	{
		kp(4, action);
		if(IsPressed(action))
		{
			this.currentMenu.selectEnter(this);
		}
	}
	event OnSCMBack(action : SInputAction)
	{
		kp(5, action);
		if(IsPressed(action))
		{
			this.currentMenu.selectExit(this);
		}
	}
	
	function UpdateHalfSecond()
	{
		var i : int;
		if(!this.isFocused) return;
		for(i = 0; i < keydowns.Size(); i+=1)
		{
			if(keydowns[i] > 0)
			{
				keydowns[i] += 1;
				if(keydowns[i] > 5)
				{
					switch(i)
					{
					case 0: this.currentMenu.selectPrev(this, true); break;
					case 1: this.currentMenu.selectNext(this, true); break;
					case 2: this.currentMenu.selectLeft(this, true); break;
					case 3: this.currentMenu.selectRight(this, true); break;
					case 4: this.currentMenu.selectEnter(this, true); break;
					case 5: this.currentMenu.selectExit(this, true); break;
					}
				}				
			}
		}
	}
}

state Idle in SCMMenu
{
	
}

state Open in SCMMenu
{
	private var isCleaned : bool; default isCleaned = false;

	event OnEnterState( prevStateName : name )
	{
		LogSCM("XXXXXXXXXXXEntering State from " + prevStateName);
		isCleaned = false;
		this.SetCleanupFunction('MenuCleanup');
		parent.RegisterKeys();
		Run();
	}

	private function _doCleanup()
	{
		if(!isCleaned)
		{
			isCleaned = true;
			LogSCM("Cleaning....");
			parent.UnregisterKeys();
			theGame.ClosePopup('TutorialPopup');
			theInput.RestoreContext('SCMMenuBase', true);
			theInput.SetContext('Exploration');
		}
	}

	cleanup function MenuCleanup()
	{
		LogSCM("XXXXXXXXXXXCalled cleanup function wow");
		_doCleanup();
	}
	
	function FUCKYOUGAME()
	{
		LogSCM("XXXXXXXXXXXExiting State  Badly");
		_doCleanup();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		LogSCM("XXXXXXXXXXXExiting State nicely, going to " + nextStateName);
		_doCleanup();
	}
	
	entry function Run()
	{
		var popup : CR4TutorialPopup;
		var guiManager : CR4GuiManager;
		var max : int = 120;
		var toRefresh : int = 3;

		guiManager = theGame.GetGuiManager();

		while(max > 0)
		{
			max -= 1;
			popup = (CR4TutorialPopup)guiManager.GetPopup('TutorialPopup');
			if(popup)
			{
				if(toRefresh > 0)
				{
					toRefresh -= 1;
					parent.Refresh();
				}
				else
				{
					theInput.StoreContext('SCMMenuBase');
					break;
				}
			}
			SleepOneFrame();
		}
		LogSCM("RUn DUn");
		parent.PlayOpenSound();
		LogSCM("Open Sesame");
		CheckForMenuClose();
		LogSCM("Checking Sesame");
	}
	
	latent function CheckForMenuClose()
	{
		while(true)
		{
			if(!MCMIsMenuOpen() || theInput.GetContext()!='SCMMenuBase')
			{
				GotoState('Idle');
				parent.GotoState('Idle');
				virtual_parent.GotoState('Idle');
				FUCKYOUGAME();
				break;
			}
			else
			{
				parent.UpdateHalfSecond();
			}
			Sleep(0.075);
		}
	}
}

function SCMPlaySoundPopup(soundName : String)
{
	var guiManager: CR4GuiManager;
	var messagePopupRef : CR4PopupBase;
	
	guiManager = theGame.GetGuiManager();
	
	messagePopupRef = (CR4PopupBase)guiManager.GetPopup('TutorialPopup');
	if (messagePopupRef)
	{
		messagePopupRef.OnPlaySoundEvent(soundName);
	}
}

function SCMIsMenuOpen() : bool
{
	var guiManager: CR4GuiManager;
	var messagePopupRef : CR4PopupBase;
	
	guiManager = theGame.GetGuiManager();
	
	messagePopupRef = (CR4PopupBase)guiManager.GetPopup('TutorialPopup');
	if (!messagePopupRef)
	{
		return false;
	}
	return true;
}

function SCMUpdateMessage(popup : CR4MessagePopup, str : String)
{
	var mcMessageModule, mcInputFeedback : CScriptedFlashObject;
	var appendButton_function, setProgress_function, cleanupButtons_function, refreshButtonList_function, clearAllButtons_function : CScriptedFlashFunction;
	var data : CScriptedFlashObject;
	var m_flashModule : CScriptedFlashSprite;
	var width : float;

	m_flashModule = popup.GetPopupFlash(); //MessagePopupMenu extends CorePopup
	
	mcMessageModule = m_flashModule.GetMemberFlashObject("mcMessageModule");

	setProgress_function = mcMessageModule.GetMemberFlashFunction("setProgress");
	
	mcInputFeedback = mcMessageModule.GetMemberFlashObject("mcInputFeedback");
	appendButton_function = mcInputFeedback.GetMemberFlashFunction("appendButton");
	cleanupButtons_function = mcInputFeedback.GetMemberFlashFunction("cleanupButtons");
	refreshButtonList_function = mcInputFeedback.GetMemberFlashFunction("refreshButtonList");
	clearAllButtons_function = mcInputFeedback.GetMemberFlashFunction("clearAllButtons");

	data = mcMessageModule.GetMemberFlashObject("data");
	data.SetMemberFlashString("messageText", str);
	mcMessageModule.SetMemberFlashObject("data", data);
	
	width = mcMessageModule.GetMemberFlashNumber("width");
	
	mcMessageModule.SetMemberFlashNumber("y", 1.0);
	mcMessageModule.SetMemberFlashNumber("x", 1.0 + width/2.0);

//SFlashArgs
// import function FlashArgBool( value : bool ) : SFlashArg;
// import function FlashArgInt( value : int ) : SFlashArg;
// import function FlashArgUInt( value : int ) : SFlashArg;
// import function FlashArgNumber( value : float ) : SFlashArg;
// import function FlashArgString( value : string ) : SFlashArg;

	setProgress_function.InvokeSelfTwoArgs(
		FlashArgInt(40),
		FlashArgString("Some Text")
	);

	appendButton_function.InvokeSelfSixArgs(
		FlashArgInt(50),
		FlashArgString("escape-gamepad_B"),
		FlashArgInt(IK_Escape),
		FlashArgString("Test"),
		FlashArgBool(true),
		FlashArgInt(-1)
	);

	cleanupButtons_function.InvokeSelf();
	clearAllButtons_function.InvokeSelf();
	refreshButtonList_function.InvokeSelf();
}

function _SCMOpenNewPopup(str : String)
{
	var messageData : W3MessagePopupData;
	
	messageData = new W3MessagePopupData in theGame;
	messageData.titleText = "";
	messageData.messageText = str;
	messageData.autoLocalize = false;
	messageData.messageId = 0;
	messageData.progress = 0;
	messageData.progressType = UMPT_None;
	messageData.progressTag = '';
	messageData.setActionsByType(UDB_Ok);
	
	theGame.RequestPopup('MessagePopup',  messageData);
}

function SCMShowMessage(str : String)
{
	var guiManager: CR4GuiManager;
	var messagePopupRef : CR4MessagePopup;
	guiManager = theGame.GetGuiManager();
	messagePopupRef = (CR4MessagePopup)guiManager.GetPopup('MessagePopup');
	
	if(!messagePopupRef)
	{
		_SCMOpenNewPopup(str);
		messagePopupRef = (CR4MessagePopup)guiManager.GetPopup('MessagePopup');
	}
	
	if(messagePopupRef)
	{
		SCMUpdateMessage(messagePopupRef, str);
	}
}

function MCMIsMenuOpen() : bool
{
	var messagePopupRef : CR4TutorialPopup;	
	messagePopupRef = (CR4TutorialPopup)theGame.GetGuiManager().GetPopup('TutorialPopup');

	return !(!messagePopupRef);
}

function MCM_CreateSideMenu(title : String, text : String, pauseGame : bool, blockInput : bool)
{
	var popupData : W3TutorialPopupData;

	popupData = new W3TutorialPopupData in theGame;

	popupData.messageTitle = title;
	popupData.messageText = text;
	popupData.pauseGame = pauseGame;
	popupData.blockInput = blockInput;
	popupData.fullscreen = false;
	popupData.duration = -1;
	//popupData.imagePath = "img://textures/journal/characters/journal_ciri.png";

	theGame.RequestPopup('TutorialPopup', popupData);
}

function alignContent(txtDescription, txtTitle, background, contentMask, topDelemiter, borderLineTop, borderLineBottom : CScriptedFlashObject)
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
	var screenWidth : float = 1920; //Screen width = CommonUtils.getScreenRect();
	var additionalWidth : float;
	var centerX : float;
	var centerY : float;
	var txtDescWidth : float;

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
		additionalWidth = screenWidth * (0.05-0.03) + BLOCK_PADDING;
		innerWidth = MaxF(MIN_WIDTH,innerWidth) + EDGE_PADDING;
		background.SetMemberFlashNumber("width", innerWidth + GRADIENT_PADDING + additionalWidth);
	}

	//this.mcCorrectFeedback.x = this.mcErrorFeedback.x = this.background.x;
	//this.mcCorrectFeedback.y = this.mcErrorFeedback.y = this.background.y;
	//this.mcCorrectFeedback.width = this.mcErrorFeedback.width = this.background.width;
	//this.mcCorrectFeedback.height = this.mcErrorFeedback.height = this.background.height;
	
	centerX = RoundF(innerWidth / 2) + additionalWidth;
	centerY = RoundF(accumHeight / 2);

	txtDescription.SetMemberFlashNumber("x", centerX - txtDescription.GetMemberFlashNumber("width") / 2);
	topDelemiter.SetMemberFlashNumber("x", centerX);
	topDelemiter.SetMemberFlashNumber("y", txtTitle.GetMemberFlashNumber("y") + txtTitle.GetMemberFlashNumber("height") + BOTTOM_PADDING);
	txtTitle.SetMemberFlashNumber("x", centerX - txtTitle.GetMemberFlashNumber("width")/2);
	
	contentMask.SetMemberFlashNumber("y", centerY);
	contentMask.SetMemberFlashNumber("width", background.GetMemberFlashNumber("width"));
	contentMask.SetMemberFlashNumber("height", background.GetMemberFlashNumber("height") + 200);
	borderLineTop.SetMemberFlashNumber("y", 0);
	borderLineBottom.SetMemberFlashNumber("y", background.GetMemberFlashNumber("height") - 1);
}

function MCM_UpdateSideMenu(popupObj : CR4TutorialPopup, title : String, text : String, pauseGame : bool, blockInput : bool)
{
	var flashBase : CScriptedFlashSprite;
	var popupInstance, tutorialOverlay, data : CScriptedFlashObject;

	var txtDescription, txtTitle, background, contentMask, topDelemiter, borderLineTop, borderLineBottom : CScriptedFlashObject;

	var _loc1_ : float = 0;
	var _loc2_ : float = 0;
	flashBase = popupObj.GetPopupFlash(); //TutorialPopupMenu

	popupInstance = flashBase.GetMemberFlashObject("popupInstance"); //TutorialPopup
	tutorialOverlay = flashBase.GetMemberFlashObject("tutorialOverlay"); //TutorialOverlay

	if(true)
	{
		LogSCM("Updating............?");
		txtDescription = popupInstance.GetMemberFlashObject("txtDescription");
		txtTitle = popupInstance.GetMemberFlashObject("txtTitle");
		background = popupInstance.GetMemberFlashObject("background");
		contentMask = popupInstance.GetMemberFlashObject("contentMask");
		topDelemiter = popupInstance.GetMemberFlashObject("topDelemiter");
		borderLineTop = popupInstance.GetMemberFlashObject("borderLineTop");
		borderLineBottom = popupInstance.GetMemberFlashObject("borderLineBottom");
		LogSCM(txtTitle);

		txtTitle.SetMemberFlashString("htmlText", title);
		txtDescription.SetMemberFlashString("htmlText", text);

		alignContent(txtDescription, txtTitle, background, contentMask, topDelemiter, borderLineTop, borderLineBottom);

		//popupInstance.SetMemberFlashNumber("x", 0);
/* 		popupInstance.SetMemberFlashNumber("y", -10);

		txtDescription.SetMemberFlashNumber("x", 0);
		txtDescription.SetMemberFlashNumber("y", 92);
		txtDescription.SetMemberFlashNumber("width", 600);
		txtDescription.SetMemberFlashNumber("height", 600);

		background.SetMemberFlashNumber("x", 0);
		background.SetMemberFlashNumber("y", 0);
		background.SetMemberFlashNumber("width", 600);
		background.SetMemberFlashNumber("height", 600+92);*/

/* 		_loc1_ += (txtDescription.GetMemberFlashNumber("height") + 2);
		_loc2_ = txtDescription.GetMemberFlashNumber("width");

		background.SetMemberFlashNumber("height", _loc1_ + 2);

		_loc1_ += 10; //BOTTOM_PADDING
		_loc2_ = MaxF(480, _loc2_) + 5;

		background.SetMemberFlashNumber("width", _loc2_ + 115);*//*
	}
	else
	{
		data = popupInstance.GetMemberFlashObject("data");
		data.SetMemberFlashString("messageTitle", title);
		data.SetMemberFlashString("messageText", text);
		
		data.SetMemberFlashBool("showAnimation", false);
		data.SetMemberFlashBool("isUiTutorial", true);
		popupInstance.SetMemberFlashObject("data", data);
	}
}

function MCM_ShowSideMenu(title : String, text : String, pauseGame : bool, blockInput : bool)
{
	var popup : CR4TutorialPopup;

	popup = (CR4TutorialPopup)theGame.GetGuiManager().GetPopup('TutorialPopup');

	if(!popup)
	{
		LogSCM("Create!!");
		MCM_CreateSideMenu(title, text, pauseGame, blockInput);
	}
	else
	{
		LogSCM("Update!!");
		MCM_UpdateSideMenu(popup, title, text, pauseGame, blockInput);
	}
}

exec function ShowTute(optional pauseGame : bool, optional blockInput : bool)
{
	//CAN DO 26 LINES
	MCM_ShowSideMenu("Title: " + RandRange(0,99), "SomeText", pauseGame, blockInput);
}*/
