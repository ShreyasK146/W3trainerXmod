/*
Basically, I can add action points, but not new paths. I can't seem to get them to bloody walk between points.
So this is my HACKY script-based version.
*/

class MCM_PathNode
{
    public var tmpValue : float;

    public var pos : Vector;
    public var siblings : array<MCM_PathNode>;
    public var siblingCount : int;
    public var preComputeDist : array<float>;
    public var index : int;

    public var t_dist : float;
    public var t_isInWorkingSet : bool;

    public function computeDistances()
    {
        var i : int;
        this.siblingCount = siblings.Size();
        if(this.preComputeDist.Size() != siblings.Size())
        {
            this.preComputeDist.Clear();
            this.preComputeDist.Grow(this.siblings.Size());
        }

        for(i = siblings.Size()-1; i>=0; i-=1)
        {
            this.preComputeDist[i] = VecDistance(this.pos, siblings[i].pos);
        }
    }

    public function lowestSibling() : MCM_PathNode
    {
        var lowestNode : MCM_PathNode;
        var i : int;
        //Select the first node, assume it's the closest.
        lowestNode = siblings[0];

        //If there's a lower one, find it.
        for(i = siblingCount-1; i > 0; i-=1)
        {
            if(siblings[i].t_dist < lowestNode.t_dist)
            {
                lowestNode = siblings[i];
            }
        }
        return lowestNode;
    }
}

class MCM_Path
{
    public var nodes : array<Vector>;
    public var nodeWalkingTo : int;
}

class MCM_WorldPath
{
    var nodes : array<MCM_PathNode>;

    public var level : EAreaName;
    public var worldName : name;

    public function Load(fileName : String)
    {
        var data: C2dArray;
        var i: int;
        var rowCount : int;
        var nodeCount : int;
        var tmp : MCM_PathNode;
        var n1, n2 : int;

        data = LoadCSV(fileName);
        if(data)
        {
            rowCount = data.GetNumRows();
            nodeCount = StringToInt(data.GetValueAt(1, 0));

            nodes.Clear();
            nodes.Grow(nodeCount);

            LogSCM("Loading Nodes");
            for(i = 1; i <= nodeCount; i+=1)
            {
                tmp = new MCM_PathNode in this;
                tmp.pos = Vector(
                    StringToFloat(data.GetValueAt(1, i)),
                    StringToFloat(data.GetValueAt(2, i)),
                    StringToFloat(data.GetValueAt(3, i)));
                tmp.index = i-1;
                nodes[tmp.index] = tmp;
            }

            LogSCM("Creating Links");
            for(i = i; i < rowCount; i+=1)
            {
                n1 = StringToInt(data.GetValueAt(1, i));
                n2 = StringToInt(data.GetValueAt(2, i));
                nodes[n1].siblings.PushBack(nodes[n2]);
                nodes[n2].siblings.PushBack(nodes[n1]);
            }

            LogSCM("Precalculating Distances");

            for(i = 0; i < nodeCount; i+=1)
            {
                nodes[i].computeDistances();
            }

            LogSCM("Loaded " + nodes.Size() + " nodes for world " + this.worldName);

        }
        else
        {
            LogSCM("Failed to load level path data " + fileName);
        }
    }

    function resetNodes()
    {
        var i : int;
        for(i = nodes.Size()-1; i >= 0; i-=1)
        {
            nodes[i].t_dist = -1;
            nodes[i].t_isInWorkingSet = false;
        }
    }

    public function getClosestNodeTo(vec : Vector, optional maxDist : float) : MCM_PathNode
    {
        var i : int;
        var minNode : MCM_PathNode;
        var minDist, tmpDist : float;

        if(maxDist <= 0)
        {
            maxDist = 1000000;
        }

        minNode = this.nodes[0];
        minDist = VecDistanceSquared(vec, minNode.pos);

        for(i = this.nodes.Size()-1; i > 0; i-=1)
        {
            tmpDist = VecDistanceSquared(vec, this.nodes[i].pos);
            if(tmpDist < minDist)
            {
                minDist = tmpDist;
                minNode = this.nodes[i];
            }
        }
        if(minDist > maxDist)
        {
            return NULL;
        }
        return minNode;
    }

    private var semaphore : int;

    public latent function createPathThreadSafe(from, to : Vector) : MCM_Path
    {
        var path : MCM_Path;
        while(semaphore > 0)
	{
            SleepOneFrame();
        }
        semaphore += 1;
        path = createPath(from, to);
        semaphore -= 1;
        return path;
    }

    public function createPath(from, to : Vector) : MCM_Path
    {
        var path : MCM_Path;
        var rootNode, destNode, node : MCM_PathNode;
        var workingSet : array<MCM_PathNode>;
        var workingSetB : array<MCM_PathNode>;
        var newDist : float;
        var i, j, sz, FAILSAFE : int = 0;

        /**
        Start from the closest node to 'to', then jump to each sibling.
        If the sibling was reached before but we have a shorter distance, then add the node to the working set.
        If the sibling hasn't been reached before, add the node to the working set.
        If we've reached the node in a shorter time, then don't add it to the working set.
        */

        resetNodes();
        rootNode = getClosestNodeTo(from, 20);
        destNode = getClosestNodeTo(to, 20);
        if(destNode && rootNode)
        {
            //Work backwards from the destination
            path = new MCM_Path in this;
            destNode.t_dist = 0;
            workingSet.PushBack(destNode);

            sz = workingSet.Size();
            FAILSAFE = this.nodes.Size()+10;
            while(sz > 0 && FAILSAFE > 0)
            {
                FAILSAFE-=1;
                for(i = 0; i < sz; i+=1)
                {
                    //For each node in the working set
                    node = workingSet[i];
                    node.t_isInWorkingSet = false;

                    for(j = 0; j < node.siblingCount; j+=1)
                    {
                        //Calculate the new distance to it's sibling
                        newDist = node.t_dist + node.preComputeDist[j];
                        //If the sibling hasn't been reached yet, or we've found a new shorter path
                        if(node.siblings[j].t_dist == -1 || node.siblings[j].t_dist > newDist)
                        {
                            //Update the distance
                            node.siblings[j].t_dist = newDist;
                            //Add it to the working set, if it isn't already
                            if(!node.siblings[j].t_isInWorkingSet)
                            {
                                node.siblings[j].t_isInWorkingSet = true;
                                workingSet.PushBack(node.siblings[j]);
                            }
                        }
                    }
                }
                //Move the elements to the start of the array
                j = 0;
                for(i = sz; i < workingSet.Size(); i+=1)
                {
                    workingSet[j] = workingSet[i];
                    j+=1;
                }
                //Clear the back of the array
                j = workingSet.Size()-sz;
                for(i = workingSet.Size()-1; i >= j; i-=1)
                {
                    workingSet.Erase(i);
                }

                sz = workingSet.Size();
            }
            if(FAILSAFE == 0)
            {
                LogSCM("TRIGGERED FAILSAFE");
            }

            //Iterate backwards to find the best path
            node = rootNode;
            //path.nodes.PushBack(from);
            
            FAILSAFE = this.nodes.Size()+10;
            while(node.t_dist > 0 && FAILSAFE > 0)
            {
                FAILSAFE-=1;
                node = node.lowestSibling();
                if(node)
                {
                    path.nodes.PushBack(node.pos);
                }
            }

            path.nodes.PushBack(to);
            LogSCM("Found path with " + path.nodes.Size() + " nodes / " + this.nodes.Size());
        }
        else
        {
            LogSCM("Failed to find nodes to start/end path");
        }
        return path;
    }
}

exec function TestNodes()
{
    MCM_GetMCM().JobManager.getWorldPath().createPath(Vector(-387.84,-804.13,35.10), Vector(-360.5082,-797.2569,30.3678));
}
