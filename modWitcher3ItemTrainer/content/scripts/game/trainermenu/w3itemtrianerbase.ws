

class UITrainerBase
{



	public const var COLOUR_SUB_MENU : String;         default COLOUR_SUB_MENU = "3399ff";  
public const var COLOUR_SUB_MENU_SPECIAL : String; default COLOUR_SUB_MENU_SPECIAL = "3366cc"; 
public const var COLOUR_DISABLED : String;         default COLOUR_DISABLED = "444444";  
public const var COLOUR_ITEM : String;             default COLOUR_ITEM = "e0e0e0";      
public const var COLOUR_CAREFUL : String;          default COLOUR_CAREFUL = "ff9933";   
public const var COLOUR_ACTIVATE : String;         default COLOUR_ACTIVATE = "66ffcc";  
public const var COLOUR_RED : String;              default COLOUR_RED = "ff3333";       
public const var COLOUR_GREEN : String;            default COLOUR_GREEN = "33ff66";     
	public var window : UIForTrainer_MenuManager;
	
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



class UIForTrainerMenu_Text extends UITrainerBase
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


class UIForTrainerMenu_Elements extends UITrainerBase
{
	var elements : array<UIForTrainerMenu_BaseElement>;

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

	protected function AddChild(element : UIForTrainerMenu_BaseElement)
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

	public function GetElementAt(index : int) : UIForTrainerMenu_BaseElement
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

	public function OnChange(element : UIForTrainerMenu_BaseElement)
	{
		
	}

	public function GetName() : String
	{
		return "Element List";
	}

	public function AddText(id : name, clickable : bool, text : String, optional colour : String) : UIForTrainerMenu_TextElement
	{
		var element : UIForTrainerMenu_TextElement;
		element = new UIForTrainerMenu_TextElement in this;
		element.ID = id;
		element.clickable = clickable;
		element.textValue = text;
		element.colourValue = colour;

		this.AddChild(element);
		return element;
	}

	public function AddCounter(id : name, text : String, start, min, max : int) : UIForTrainerMenu_Counter
	{
		var element : UIForTrainerMenu_Counter;
		element = new UIForTrainerMenu_Counter in this;
		element.ID = id;
		element.prefix = text;
		element.Setup(start, min, max);

		this.AddChild(element);
		return element;
	}

	public function AddDoubleButton(id : name, text : String, optional normalColour, selectedColour : String) : UIForTrainerMenu_DoubleClickButton
	{
		var element : UIForTrainerMenu_DoubleClickButton;
		element = new UIForTrainerMenu_DoubleClickButton in this;
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

	public function AddEnum(id : name, prepend : String, values : String, optional delemiter : String) : UIForTrainerMenu_Enum
	{
		var element : UIForTrainerMenu_Enum;
		element = new UIForTrainerMenu_Enum in this;
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

	public function AddInputText(id : name, value : String, defaultValue : String) : UIForTrainerMenu_InputElement
	{
		var element : UIForTrainerMenu_InputElement;
		element = new UIForTrainerMenu_InputElement in this;
		element.ID = id;
		element.value = value;
		element.defaultValue = defaultValue;

		this.AddChild(element);
		return element;
	}
}

class UIForTrainerMenu_BaseElement
{
	public var root : UIForTrainerMenu_Elements;
	public var ID : name;

	public var flashGreen : bool;
	public var flashRed : bool;
	public var Disabled : bool; default Disabled = false;

	function OnKey(action : SInputAction, letter : name)
    	{
		
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

class UIForTrainerMenu_InputElement extends UIForTrainerMenu_BaseElement
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
class UIForTrainerMenu_TextElement extends UIForTrainerMenu_BaseElement
{
	public var textValue : String; default textValue = "Change This Text";
	public var colourValue : String; default colourValue = "";
	public var clickable : bool; default clickable = true;
	public var textItemName : name;
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
class UIForTrainerMenu_DoubleClickButton extends UIForTrainerMenu_BaseElement
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
class UIForTrainerMenu_FocusableElement extends UIForTrainerMenu_BaseElement
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
class UIForTrainerMenu_Counter extends UIForTrainerMenu_FocusableElement
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
class UIForTrainerMenu_Enum extends UIForTrainerMenu_FocusableElement
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
}