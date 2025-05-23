
struct MCM_EntityEntry
{
    var nam : name;
    var defaultAppearance : name;
    var displayName : name;
}

abstract class MCM_EntityListBase
{
    public function GetName() : String {return "[Name]";}
    public function GetDepotPath() : String {return "";}

    public function GetMetaInfo(index : int) : String {return "";}

    public function GetParentList() : MCM_EntityListBase {return NULL;}

    public function GetChildCount() : int {return 0;}
    public function GetValueCount() : int {return 0;}
    public function GetChildAt(index : int) : MCM_EntityListBase {return NULL;}
    public function GetValueAt(index : int) : name {return '';}

    public function GetAppearanceAt(index : int) : name {return GetValueAt(index);}
    public function GetDisplayNameAt(index : int) : name {return GetValueAt(index);}

    private var _selectedIndex : int; default _selectedIndex = 0;
    public final function StoreSelectedIndex(index : int) { this._selectedIndex = index; }
    public final function RetrieveSelectedIndex() : int { return this._selectedIndex; }

    public var parentOverride : MCM_EntityListBase;
    public final function GetParentListWithOverride() : MCM_EntityListBase
    {
        if(parentOverride) return parentOverride;
        return this.GetParentList();
    }
}

class MCM_FileContainer extends MCM_EntityListBase
{
    public function GetName() : String
    {
        return folderName;
    }

    public function GetChildCount() : int
    {
        return children.Size();
    }

    public function GetChildAt(index : int) : MCM_EntityListBase
    {
        return children[index];
    }

    public function GetAppearanceAt(index : int) : name {return '';}

    public function GetDepotPath() : String
    {
        return this.getPathPrepend();
    }
    
    public function GetMetaInfo(index : int) : String 
    {
        return this.getPathPrepend();
    }

    public function GetValueCount() : int 
    {
        return files.Size();
    }

    public function GetValueAt(index : int) : name
    {
        return files[index];
    }

    public function GetParentList() : MCM_EntityListBase
    {
        return parentFolder;
    }

    public var parentFolder : MCM_FileContainer;
    public var children : array<MCM_FileContainer>;
    public var folderName : String; default folderName = "W2Ent Files";
    public var files : array<name>;
    public var isRootNode : bool; default isRootNode = true;

    public function Print(optional prepend : String)
    {
        var i : int;
        prepend += this.folderName + "/";
        for(i = 0; i < files.Size(); i+=1)
        {
            LogSCM(prepend + files[i]);
        }
        for(i = 0; i < children.Size(); i+=1)
        {
            children[i].Print(prepend);
        }
    }

    private function DLCStringToName(nam : String) : name
    {
        switch(nam)
        {
            case "HOS": return 'ep1';
            case "BAW": return 'abob_001_001';
            case "DLC1": return 'dlc_001_001';
            case "DLC2": return 'dlc_002_001';
            case "DLC3": return 'dlc_003_001';
            case "DLC4": return 'dlc_004_001';
            case "DLC5": return 'dlc_005_001';
            case "DLC6": return 'dlc_006_001';
            case "DLC7": return 'dlc_007_001';
            case "DLC8": return 'dlc_008_001';
            case "DLC9": return 'dlc_009_001';
            case "DLC10": return 'dlc_010_001';
            case "DLC11": return 'dlc_011_001';
            case "DLC12": return 'dlc_012_001';
            case "DLC13": return 'dlc_013_001';
            case "DLC14": return 'dlc_014_001';
            case "DLC15": return 'dlc_015_001';
            case "DLC16": return 'dlc_016_001';
        }
        return 'unknown';
    }

    private function IsDLCEnabled(nam : String) : bool
    {
        if(nam == "Vanilla") return true;
        return theGame.GetDLCManager().IsDLCEnabled(DLCStringToName(nam));
    }

    public function getPathPrepend() : String
    {
        if(parentFolder && !parentFolder.isRootNode)
        {
            return parentFolder.getPathPrepend() + "/" + folderName;
        }
        return folderName;
    }

    private function getOrCreateContainerFromPath(path : String) : MCM_FileContainer
    {
        var partA, partB : String;

        if(StrSplitFirst(path, "/", partA, partB))
        {
            return getOrCreateChildByName(partA).getOrCreateContainerFromPath(partB);
        }
        else
        {
            return getOrCreateChildByName(path);
        }
    }

    private function createChild(childName : String) : MCM_FileContainer
    {
        var child : MCM_FileContainer = new MCM_FileContainer in this;

        child.folderName = childName;
        child.isRootNode = false;
        child.parentFolder = this;
        this.children.PushBack(child);
        return child;
    }

    private function getOrCreateChildByName(childName : String) : MCM_FileContainer
    {
        var i : int;

        for(i = children.Size()-1; i >= 0; i-=1)
        {
            if(children[i].folderName == childName)
            {
                return children[i];
            }
        }
        return createChild(childName);
    }

    public function LoadSCMData()
    {
        var data: C2dArray;
        var i: int;
        var rowCount : int;

        var dlcName, entPath : String;
        var _dlcName, _entPath : String;
        var fileName, _fileName : name;
        var _container : MCM_FileContainer;

        if(this.children.Size() != 0 || this.files.Size() != 0)
        {
            LogSCM("Not loading SCM data on non-empty file container");
            return;
        }
        
        data = LoadCSV("dlc\mod_spawn_companions\mcm_entity_data.csv");
        if(data)
        {
            //Oh boy here we go!
            rowCount = data.GetNumRows();

            //Only load first 100 for now...
            //rowCount = Min(25, rowCount);
            LogSCM("Loading Data...");
            for (i = 0; i < rowCount; i += 1)
            {
                dlcName = data.GetValueAt(0, i);
                entPath = data.GetValueAt(1, i);
                fileName = data.GetValueAtAsName(2, i);
                
                if(StrLen(dlcName) > 0)
                {
                    //If the DLC isn't enabled
                    if(!IsDLCEnabled(dlcName))
                    {
                        //Skip through a whole bunch of entries
                        for(i = i; i < rowCount; i += 1)
                        {
                            //Until we find a dlc that is enabled
                            dlcName = data.GetValueAt(0, i);
                            if(StrLen(dlcName) > 0)
                            {
                                if(IsDLCEnabled(dlcName))
                                {
                                    //In which case, go back a step
                                    i -= 1;
                                    break;
                                }
                            }
                        }
                        //If we found a new DLC name, then it'll be loaded on the next iteration
                        //Otherwise the loop will exit as i >= rowCount
                        continue;
                    }
                    _dlcName = dlcName;
                }
                if(StrLen(entPath) > 0) 
                {
                    _entPath = entPath;
                    _container = getOrCreateContainerFromPath(entPath);
                }
                if(IsNameValid(fileName)) _fileName = fileName;

                _container.files.PushBack(_fileName);
            }
            LogSCM("Done Loading SCM Data");
        }
        else
        {
            LogSCM("Loading entity CSV list FAILED!");
        }
    }
}

class MCM_EntityListNode extends MCM_EntityListBase
{
    public function GetName() : String
    {
        return nodeName;
    }
    
    public function GetParentList() : MCM_EntityListBase
    {
        return parentNode;
    }

    public function GetChildCount() : int
    {
        return children.Size();
    }

    public function GetChildAt(index : int) : MCM_EntityListBase
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

    public var parentNode : MCM_EntityListNode;
    public var children : array<MCM_EntityListNode>;
    public var values : array<MCM_EntityEntry>;
    public var nodeName : String;

    private function AddValue(entEntry : MCM_EntityEntry)
    {
        values.PushBack(entEntry);
    }

    public function AddChild(path : String, entEntry : MCM_EntityEntry)
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

    function GetOrCreateNode(nodeName : String) : MCM_EntityListNode
    {
        var i : int;
        var newNode : MCM_EntityListNode;
        for(i = children.Size()-1; i >= 0; i-=1)
        {
            if(children[i].nodeName == nodeName)
            {
                return children[i];
            }
        }
        newNode = new MCM_EntityListNode in this;
        newNode.nodeName = nodeName;
        newNode.parentNode = this;
        children.PushBack(newNode);
        return newNode;
    }

    public function GetChildNode(nodeName : String) : MCM_EntityListNode
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
        var result : array<MCM_EntityListNode>;
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
        var result : array<MCM_EntityEntry>;
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

class MCM_EntityListHolder extends MCM_EntityListBase
{
    public var children : array<MCM_EntityListBase>;

    public function GetName() : String
    {
        return "Root";
    }

    public function GetChildCount() : int
    {
        return children.Size();
    }

    public function GetChildAt(index : int) : MCM_EntityListBase
    {
        return children[index];
    }

    public function GetMetaInfo(index : int) : String 
    {
        if(index == 0)
        {
            return "Tested NPCs. Small easy list.";
        }
        return "Basically all .w2ent files. May be broken!";
    }
}

class MCM_EntityList extends CObject
{
    public var dataA : MCM_EntityListNode;
    public var dataB : MCM_FileContainer;
    public var dataALL : MCM_EntityListHolder;

    public function GetNode(nodeName : String) : MCM_EntityListNode
    {
        var splitA, splitB : String;
        var currentNode : MCM_EntityListNode  = dataA;
        
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

        dataA = new MCM_EntityListNode in this;
        dataA.nodeName = "Organised";
        
        LoadData();
        //Don't sort the root node, just it's children
        dataA.SortChildNodes();

        LogSCM("Loading Data Big!");
        dataB = new MCM_FileContainer in this;
        dataB.LoadSCMData();

        dataALL = new MCM_EntityListHolder in this;
        dataA.parentOverride = dataALL;
        dataB.parentOverride = dataALL;
        dataALL.children.PushBack(dataA);
        dataALL.children.PushBack(dataB);
    }

    public function a(path : String, nam : name, appearance : name, displayName : name)
    {
        var entEntry : MCM_EntityEntry;
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

    public function b(path : String, nam : name)
    {
        var entEntry : MCM_EntityEntry;
        var splitA, splitB : String;
        entEntry.nam = nam;
        entEntry.defaultAppearance = nam;
        entEntry.displayName = nam;

        while(StrSplitFirst(path, "|", splitA, splitB))
        {
            dataA.AddChild(splitA, entEntry);
            path = splitB;
        }

        dataA.AddChild(path, entEntry);
    }

    private function LoadData()
    {
        //Pre make the common node, so it's first
        dataA.GetOrCreateNode("Common");

        MCM_EL_AddVanilla(this);
        MCM_EL_AddDLC(this);
        
        MCM_EL_AddVanillaMonster(this);
        MCM_EL_AddDLCMonster(this);
    }
}
