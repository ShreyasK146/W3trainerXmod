
struct UIForTrainerMenu_EntityEntry
{
    var nam : name;
    var defaultAppearance : name;
    var displayName : name;
}

abstract class UIForTrainerMenu_EntityListBase
{
    public function GetName() : String {return "[Name]";}
    public function GetDepotPath() : String {return "";}

    public function GetMetaInfo(index : int) : String {return "";}

    public function GetParentList() : UIForTrainerMenu_EntityListBase {return NULL;}

    public function GetChildCount() : int {return 0;}
    public function GetValueCount() : int {return 0;}
    public function GetChildAt(index : int) : UIForTrainerMenu_EntityListBase {return NULL;}
    public function GetValueAt(index : int) : name {return '';}

    public function GetAppearanceAt(index : int) : name {return GetValueAt(index);}
    public function GetDisplayNameAt(index : int) : name {return GetValueAt(index);}

    private var _selectedIndex : int; default _selectedIndex = 0;
    public final function StoreSelectedIndex(index : int) { this._selectedIndex = index; }
    public final function RetrieveSelectedIndex() : int { return this._selectedIndex; }

    public var parentOverride : UIForTrainerMenu_EntityListBase;
    public final function GetParentListWithOverride() : UIForTrainerMenu_EntityListBase
    {
        if(parentOverride) return parentOverride;
        return this.GetParentList();
    }
}

class UIForTrainerMenu_EntityListNode extends UIForTrainerMenu_EntityListBase
{
    public function GetName() : String
    {
        return nodeName;
    }
    
    public function GetParentList() : UIForTrainerMenu_EntityListBase
    {
        return parentNode;
    }

    public function GetChildCount() : int
    {
        return children.Size();
    }

    public function GetChildAt(index : int) : UIForTrainerMenu_EntityListBase
    {
        return children[index];
    }

    public function GetValueCount() : int 
    {
        return values.Size();
    }

    public function GetValueAt(index : int) : name
    {
        return values[index].nam;
    }

    public function GetAppearanceAt(index : int) : name
    {
        return values[index].defaultAppearance;
    }

    public function GetDisplayNameAt(index : int) : name 
    {
        return values[index].displayName;
    }

    public function GetMetaInfo(index : int) : String 
    {
        return this.getPath();
    }

    public function getPath() : String
    {
        if(parentNode)
        {
            return parentNode.getPath() + "." + nodeName;
        }
        return nodeName;
    }

    public var parentNode : UIForTrainerMenu_EntityListNode;
    public var children : array<UIForTrainerMenu_EntityListNode>;
    public var values : array<UIForTrainerMenu_EntityEntry>;
    public var nodeName : String;

    private function AddValue(entEntry : UIForTrainerMenu_EntityEntry)
    {
        values.PushBack(entEntry);
    }

    public function AddChild(path : String, entEntry : UIForTrainerMenu_EntityEntry)
    {
        var childNodeName : String;
        var remainingPath : String;

        if(path == "")
        {
            AddValue(entEntry);
        }
        else if(StrSplitFirst(path, ".", childNodeName, remainingPath))
        {
            GetOrCreateNode(childNodeName).AddChild(remainingPath, entEntry);
        }
        else
        {
            GetOrCreateNode(path).AddValue(entEntry);
        }
    }

    function GetOrCreateNode(nodeName : String) : UIForTrainerMenu_EntityListNode
    {
        var i : int;
        var newNode : UIForTrainerMenu_EntityListNode;
        for(i = children.Size()-1; i >= 0; i-=1)
        {
            if(children[i].nodeName == nodeName)
            {
                return children[i];
            }
        }
        newNode = new UIForTrainerMenu_EntityListNode in this;
        newNode.nodeName = nodeName;
        newNode.parentNode = this;
        children.PushBack(newNode);
        return newNode;
    }

    public function GetChildNode(nodeName : String) : UIForTrainerMenu_EntityListNode
    {
        var i : int;

        for(i = children.Size()-1; i >= 0; i-=1)
        {
            if(children[i].nodeName == nodeName)
            {
                return children[i];
            }
        }
        return NULL;
    }

    function SortChildNodes()
    {
        var i : int;
        for(i = this.children.Size(); i >= 0; i-=1)
        {
            this.children[i].SortAll();
        }
    }

    function SortAll()
    {
        this.SortValues();
        this.SortChildren();
        this.SortChildNodes();
    }

    function SortChildren()
    {
        var i, j, size : int;
        var result : array<UIForTrainerMenu_EntityListNode>;
        var found : bool;
        
        if(children.Size() <= 0)
            return;
            
        size = children.Size();	
        result.PushBack(children[0]);
        
        for(i=1; i<size; i+=1)
        {
            found = false;
            
            for(j=0; j<result.Size(); j+=1)
            {
                if( StrCmp( StrLower(children[i].nodeName), StrLower(result[j].nodeName)) < 0 )
                {
                    result.Insert(j, children[i]);
                    found = true;
                    break;
                }
            }
            
            if ( !found )
            {
                result.PushBack(children[i]);
            }
        }
        
        children.Clear();
        children = result;
    }

    function SortValues()
    {
        var i, j, size : int;
        var result : array<UIForTrainerMenu_EntityEntry>;
        var found : bool;
        
        if(values.Size() <= 0)
            return;
            
        size = values.Size();	
        result.PushBack(values[0]);
        
        for(i=1; i<size; i+=1)
        {
            found = false;
            
            for(j=0; j<result.Size(); j+=1)
            {
                if( StrCmp( StrLower(values[i].displayName), StrLower(result[j].displayName)) < 0 )
                {
                    result.Insert(j, values[i]);
                    found = true;
                    break;
                }
            }
            
            if ( !found )
            {
                result.PushBack(values[i]);
            }
        }
        
        values.Clear();
        values = result;
    }
}

class UIForTrainerMenu_EntityListHolder extends UIForTrainerMenu_EntityListBase
{
    public var children : array<UIForTrainerMenu_EntityListBase>;

    public function GetName() : String
    {
        return "Root";
    }

    public function GetChildCount() : int
    {
        return children.Size();
    }

    public function GetChildAt(index : int) : UIForTrainerMenu_EntityListBase
    {
        return children[index];
    }

    public function GetMetaInfo(index : int) : String 
    {
        if(index == 0)
        {
            return "List contains items that can be added to inventory and cheats that can be enabled. Didn't test all!!!";
        }
        return "";
    }
}

class UIForTrainerMenu_EntityList extends CObject
{
    public var dataA : UIForTrainerMenu_EntityListNode;

    public var dataALL : UIForTrainerMenu_EntityListHolder;

    public function GetNode(nodeName : String) : UIForTrainerMenu_EntityListNode
    {
        var splitA, splitB : String;
        var currentNode : UIForTrainerMenu_EntityListNode  = dataA;
        
        while(currentNode && StrSplitFirst(nodeName, ".", splitA, splitB))
        {
            currentNode = currentNode.GetChildNode(splitA);
            nodeName = splitB;
        }

        return currentNode;
    }

    private var isInit : bool; default isInit = false;
	public function init()
	{
	    if(isInit) return;
	    isInit = true;

        dataA = new UIForTrainerMenu_EntityListNode in this;
        dataA.nodeName = "Organised";
        
        LoadData();
  
        dataA.SortChildNodes();



        dataALL = new UIForTrainerMenu_EntityListHolder in this;
        dataA.parentOverride = dataALL;
     
        dataALL.children.PushBack(dataA);
   
    }

    public function a(path : String, nam : name, appearance : name, displayName : name)
    {
        var entEntry : UIForTrainerMenu_EntityEntry;
        var splitA, splitB : String;
        entEntry.nam = nam;
        entEntry.defaultAppearance = appearance;
        entEntry.displayName = displayName;

        while(StrSplitFirst(path, "|", splitA, splitB))
        {
            dataA.AddChild(splitA, entEntry);
            path = splitB;
        }

        dataA.AddChild(path, entEntry);
    }

  

    private function LoadData()
    {


        UIForTrainer_EL_AddVanillaConsumables(this);

        
        UIForTrainer_EL_AddVanillaFun(this);

        UIForTrainer_EL_AddVanillaGear(this);
        UIForTrainer_EL_AddVanillaGear2(this);
        UIForTrainer_EL_AddVanillaGear3(this);
        UIForTrainer_EL_AddVanillaGear4(this);
        UIForTrainer_EL_AddVanillaGear5(this);
        UIForTrainer_EL_AddVanillaGear6(this);
        UIForTrainer_EL_AddVanillaOthers(this);
        UIForTrainer_EL_AddVanillaOthers2(this);
        UIForTrainer_EL_AddVanillaOthers3(this);
        UIForTrainer_EL_AddVanillaOthers4(this);
        UIForTrainer_EL_AddVanillaCrafting(this);
        UIForTrainer_EL_AddVanillaCrafting2(this);
        UIForTrainer_EL_AddVanillaCrafting3(this);

        UIForTrainer_EL_AddVanillaQuest(this);

        UIForTrainer_EL_AddVanillaQuest2(this);

        UIForTrainer_EL_AddVanillaLore(this);
        UIForTrainer_EL_AddVanillaLore2(this);

        UIForTrainer_EL_AddVanillaRecipies(this);
        UIForTrainer_EL_AddVanillaRecipies2(this);
        UIForTrainer_EL_AddVanillaRecipies3(this);
        UIForTrainer_EL_AddVanillaRecipies4(this);
        UIForTrainer_EL_AddVanillaIngredients(this);
        
    }
}
