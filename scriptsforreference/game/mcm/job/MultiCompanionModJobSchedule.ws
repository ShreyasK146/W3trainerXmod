
class MCM_JobEntry
{
    public var job : MCM_Job;
    public var startTime : int;
    public var endTime : int;

    public function IsActiveAtTime(time : int) : bool
    {
        if(startTime > endTime)
        {
            return time >= startTime || time < endTime;
        }
        return time >= startTime && time < endTime;
    }

    public function Print()
    {
        var sz, i : int;
        LogMCM_Job("        JobEntry " + job + " " + startTime + ":" + endTime);
    }

    /*public function getEndTime() : int
    {
        var localEndTime : int;
        if(this.maxRunTime <= 0)
        {
            return this.endTime;
        }
        
        localEndTime = MCM_GameTimeSeconds() + this.maxRunTime;
        if(localEndTime >= 24*3600) localEndTime -= 24*3600;
        LogMCM_Job("Local End Time " + localEndTime);
        if(startTime < endTime)
        {
            if(localEndTime > endTime) localEndTime = endTime;
        }
        else
        {
            if(localEndTime > endTime && localEndTime < startTime) localEndTime = endTime;
        }
        
        LogMCM_Job("Got Local End Time " + localEndTime + " from time " + MCM_GameTimeSeconds());
        return localEndTime;
    }

    public function checkIsEndTime(localEndTime : int) : bool
    {
        var time : int = MCM_GameTimeSeconds();
        if(localEndTime == -1) return !IsActive();
        LogMCM_Job("Check end (time, localend, start, end) " + time + "," + localEndTime + "," + startTime + "," + endTime);
        if(startTime < endTime)
        {
            return time >= localEndTime;
        }
        else
        {
            return time >= localEndTime && time < startTime;
        }
    }*/

    public function IsActive() : bool
    {
        return IsActiveAtTime(MCM_GameTimeSeconds());
    }
}

class MCM_WorkSchedule
{
    //AN_NMLandNovigrad
    //AN_Skellige_ArdSkellig
    //AN_Kaer_Morhen
    //AN_Prologue_Village
    //AN_Velen?
    //AN_Bob = 11
    public var scheduleName : name;
    public var land : EAreaName; default land = AN_Undefined;
    public var jobs : array<MCM_JobEntry>;
    public var manager : MCM_JobManager;

    public function Print()
    {
        var sz, i : int;
        LogMCM_Job("    Schedule " + scheduleName);
        sz = jobs.Size();
        for(i = 0; i < sz; i+=1)
        {
            jobs[i].Print();
        }
    }

    public function addJob(job : MCM_Job, startTime : int, endTime : int) : MCM_WorkSchedule
    {
        var jobEntry : MCM_JobEntry;
        jobEntry = new MCM_JobEntry in this;

        //Offset everything by about 3 minutes.
        startTime -= 180;
        endTime -= 180;
        if(startTime < 0) startTime += 86400;
        if(endTime < 0) endTime += 86400;
        
        jobEntry.job = job;
        jobEntry.startTime = startTime;
        jobEntry.endTime = endTime;

        jobs.PushBack(jobEntry);

        return this;
    }

    public function land(land : EAreaName) : MCM_WorkSchedule
    {
        this.land = land;
        return this;
    }

    public function getJobForTime(time : int) : MCM_JobEntry
    {
        var i : int;
        // LogMCM_Job(time + ", " + jobs.Size());
        for(i = jobs.Size()-1; i >= 0; i-=1)
        {
            if(jobs[i].IsActiveAtTime(time) && jobs[i].job.canPerformJob())
            {
                return jobs[i];
            }
        }
        return NULL;
    }
}
