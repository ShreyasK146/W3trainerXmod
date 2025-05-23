
function LogMCM_Job(str : String)
{
    LogChannel('ModSpawnCompanions', str);
}

state Idle in MCM_JobManager
{
    event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
	}

    event OnLeaveState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
	}
}

state LogPlayerWalking in MCM_JobManager
{
    event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
        StartLogging();
	}

    entry function StartLogging()
    {
        while(true)
        {
            Sleep(0.25);
            LogChannel('MCMJM', VecToString(thePlayer.GetWorldPosition()));
        }
    }
}

statemachine class MCM_JobManager extends CObject
{
	default autoState = 'Idle';

    public function togglePlayerLogging()
    {
        if(this.IsInState('LogPlayerWalking'))
        {
            this.GotoState('Idle');
        }
        else
        {
	        LogChannel('MCMJM CLEAR', "Do Clear");
            this.GotoState('LogPlayerWalking');
        }
    }

	private var isInit : bool; default isInit = false;
	public function init()
	{
		if(isInit) return;
		isInit = true;

        InitActions();

        this.GotoState('Idle');
	}

    private var isPostInit : bool; default isPostInit = false;
    private function CheckPostInit() {
        if(!this.isPostInit) {
            this.isPostInit = true;
            this.InitPost();
        }
    }

    private function InitPost()
    {
        var level : EAreaName = MCM_GetAreaName();

        LogSCM("Initialzing In Post" + level);

        switch(level) {
            case AN_Kaer_Morhen: {
                LogSCM("Initializing job manager for KAER MORHEN");
                InitActionPoints_KAERMORHEN();
                InitJobs_KAERMORHEN();
                InitSchedules_KAERMORHEN();
            } break;
            case AN_Prologue_Village: {
                LogSCM("Initializing job manager for WHITE ORCHARD");
                InitActionPoints_WHITEORCHARD();
                InitJobs_WHITEORCHARD();
                InitSchedules_WHITEORCHARD();
            } break;
            case AN_Wyzima: {
                LogSCM("Initializing job manager for VIZIMA");
                InitActionPoints_VIZIMA();
                InitJobs_VIZIMA();
                InitSchedules_VIZIMA();
            } break;
            case AN_NMLandNovigrad: {
                LogSCM("Initializing job manager for NOVIGRAD");
                InitActionPoints_NOVIGRAD();
                InitJobs_NOVIGRAD();
                InitSchedules_NOVIGRAD();
            } break;
            case AN_Skellige_ArdSkellig: {
                LogSCM("Initializing job manager for SKELLIGE");
                InitActionPoints_SKELLIGE();
                InitJobs_SKELLIGE();
                InitSchedules_SKELLIGE();
            } break;
            case 11: {
                LogSCM("Initializing job manager for TOUSSAINT");
                InitActionPoints_TOUSSAINT();
                InitJobs_TOUSSAINT();
                InitSchedules_TOUSSAINT();
            } break;
        }
    }

    var worldPaths : array<MCM_WorldPath>;

    public function getWorldPath() : MCM_WorldPath
    {
        var level : int = theGame.GetCommonMapManager().GetCurrentArea();
        var i : int;
        for(i = 0; i < worldPaths.Size(); i+=1)
        {
            if(worldPaths[i].level == level)
            {
                return worldPaths[i];
            }
        }
        return CreateWorldPath(level);
    }

    private function newWorldPath(worldName : name, worldTag : EAreaName, csvFile : String) : MCM_WorldPath
    {
        var worldPath : MCM_WorldPath;
        var currentLevel : int;
        currentLevel = theGame.GetCommonMapManager().GetCurrentArea();
        LogMCM_Job(currentLevel);
        if(worldTag == currentLevel)
        {
            worldPath = new MCM_WorldPath in this;

            worldPath.worldName = worldName;
            worldPath.level = worldTag;
            worldPath.Load(csvFile);

            this.worldPaths.PushBack(worldPath);

            return worldPath;
        }
        else
        {
            LogMCM_Job("Skipping world " + worldName + " as it's not currently loaded");
        }
        return NULL;
    }

        	// AN_NMLandNovigrad 1
		// AN_Skellige_ArdSkellig 2
		// AN_Kaer_Morhen 3
		// AN_Prologue_Village 4
		// AN_Wyzima 5
		// AN_Island_of_Myst 6
		// AN_Spiral 7
		// AN_Prologue_Village_Winter 8
		// AN_Velen 9
		// AN_CombatTestLevel 10

    private function CreateWorldPath(level : int) : MCM_WorldPath
    {
        switch(level)
        {
            case AN_Kaer_Morhen:    		return newWorldPath('kaermorhen', AN_Kaer_Morhen, "dlc\mod_spawn_companions\data\paths\KaerMorhen.csv");
            case AN_Prologue_Village:    	return newWorldPath('whiteorchard', AN_Prologue_Village, "dlc\mod_spawn_companions\data\paths\WhiteOrchard.csv");
            case AN_Wyzima:         		return newWorldPath('vizima', AN_Wyzima, "dlc\mod_spawn_companions\data\paths\Vizima.csv");
            case AN_NMLandNovigrad:		return newWorldPath('novigrad', AN_NMLandNovigrad, "dlc\mod_spawn_companions\data\paths\Velen.csv");
            case AN_Skellige_ArdSkellig:	return newWorldPath('skellige', AN_Skellige_ArdSkellig, "dlc\mod_spawn_companions\data\paths\Skellige.csv");
            case 11: 				return newWorldPath('toussaint', (EAreaName)11, "dlc\mod_spawn_companions\data\paths\Toussaint.csv");
        }
        return NULL;
    }

    var activeWorkers : array<MCM_Worker>;

    public function removeWorker(worker : MCM_Worker)
    {
        worker.forceStop();
        activeWorkers.Remove(worker);
    }

    public function cancelWorkerByActor(actor : CNewNPC)
    {
        var worker : MCM_Worker;
        worker = getWorker(actor);
        if(worker)
        {
            worker.forceStop();
            activeWorkers.Remove(worker);
        }
    }

    public function cleanWorkers()
    {
        var i : int;
        for(i = 0; i < activeWorkers.Size(); i+=1)
        {
            if(!activeWorkers[i] || !activeWorkers[i].actor)
            {
                activeWorkers.Erase(i);
                i-=1; continue;
            }
        }
    }

    public function onTimeJump()
    {
        var i : int;
        var newWorkers : array<MCM_Worker>;
        
        //Copy all the workers
        //Force stop all the old ones
        //This just solves the problem of latent functions needing to be stopped and instantly resumed without delay.
        //Could make it happen over 1-2 frames, but not instantly.
        for(i = 0; i < activeWorkers.Size(); i+=1)
        {
            if(activeWorkers[i].hasValidJob() && activeWorkers[i].IsInState('Working'))
            {
                newWorkers.PushBack(activeWorkers[i]);
            }
            else
            {
                newWorkers.PushBack(activeWorkers[i].createCopy());
                activeWorkers[i].forceStop();
            }
        }

        this.activeWorkers = newWorkers;

        for(i = 0; i < activeWorkers.Size(); i+=1)
        {
            if(activeWorkers[i].GetCurrentStateName() == 'None')
            {
                activeWorkers[i].onTimeJumpResume();
            }
        }
    }

    public function assignWorker(actor : CNewNPC, workerName : name, scheduleName : name)
    {
        var worker : MCM_Worker;
        var schedule : MCM_WorkSchedule;

        if(!actor)
        {
            LogMCM_Job("Can't assign worker to NULL actor");
        }

        CheckPostInit();

        cleanWorkers();
        schedule = getSchedule(scheduleName);
        if(schedule)
        {
            worker = getWorker(actor);

            if(worker)
            {
                if(worker.schedule != schedule)
                {
                    worker.changeSchedule(schedule);
                }
            }
            else
            {
                worker = new MCM_Worker in actor;
                worker.manager = this;
                worker.workerName = workerName;
                this.activeWorkers.PushBack(worker);
                
                worker.Begin(actor, schedule);
            }
        }
        else
        {
            LogMCM_Job("No schedule exists by name '" + scheduleName + "'");
        }
    }

    public function cancelWorker(actor : CNewNPC)
    {
        var i : int;
        for(i = activeWorkers.Size()-1; i>=0; i-=1)
        {
            if(activeWorkers[i] && activeWorkers[i].actor)
            {
                if(activeWorkers[i].actor == actor)
                {
                    activeWorkers[i].forceStop();
                    activeWorkers.Erase(i);
                    return;
                }
            }
        }
    }

    public function getWorker(actor : CNewNPC) : MCM_Worker
    {
        var i : int;
        for(i = activeWorkers.Size()-1; i>=0; i-=1)
        {
            if(activeWorkers[i] && activeWorkers[i].actor)
            {
                if(activeWorkers[i].actor == actor)
                {
                    return activeWorkers[i];
                }
            }
            else
            {
                activeWorkers.Erase(i);
                continue;
            }
        }
        return NULL;
    }

    public function Print()
    {
        var sz, i : int;

        cleanWorkers();

        sz = actions.Size();
        LogMCM_Job("There are " + sz + " actions:");
        for(i = 0; i < sz; i+=1) actions[i].Print();
        
        sz = jobs.Size();
        LogMCM_Job("There are " + sz + " jobs:");
        for(i = 0; i < sz; i+=1) jobs[i].Print();
        
        sz = schedules.Size();
        LogMCM_Job("There are " + sz + " schedules:");
        for(i = 0; i < sz; i+=1) schedules[i].Print();
        
        sz = activeWorkers.Size();
        LogMCM_Job("There are " + sz + " workers:");
        for(i = 0; i < sz; i+=1) activeWorkers[i].Print();
    }

    var actions : array<MCM_JobAction>;
    var actionPoints : array<MCM_JobActionPoint>;
    var jobs : array<MCM_Job>;
    var schedules : array<MCM_WorkSchedule>;

    private function getAction(actionName : name) : MCM_JobAction
    {
        var i : int;
        for(i = actions.Size()-1; i >= 0; i-=1)
        {
            if(actions[i].actionName == actionName)
            {
                return actions[i];
            }
        }
        LogMCM_Job("ACTION DOES NOT EXIST " + actionName);
        return NULL;
    }

    private function getActionPoint(actionPointName : name) : MCM_JobActionPoint
    {
        var i : int;
        for(i = actionPoints.Size()-1; i >= 0; i-=1)
        {
            if(actionPoints[i].actionPointName == actionPointName)
            {
                return actionPoints[i];
            }
        }
        LogMCM_Job("ACTION POINT DOES NOT EXIST " + actionPointName);
        return NULL;
    }

    private function getJob(jobName : name) : MCM_Job
    {
        var i : int;
        for(i = jobs.Size()-1; i >= 0; i-=1)
        {
            if(jobs[i].jobName == jobName)
            {
                return jobs[i];
            }
        }
        LogMCM_Job("JOB DOES NOT EXIST " + jobName);
        return NULL;
    }

    private function getSchedule(scheduleName : name) : MCM_WorkSchedule
    {
        var i : int;
        for(i = schedules.Size()-1; i >= 0; i-=1)
        {
            if(schedules[i].scheduleName == scheduleName)
            {
                return schedules[i];
            }
        }
        LogMCM_Job("SCHEDULE DOES NOT EXIST " + scheduleName);
        return NULL;
    }

    //Simple action, just play animations
    private function newAction_anim(actionName : name, optional actionCategory : name) : MCM_JobActionAnimated
    {
        var action : MCM_JobActionAnimated;
        action = new MCM_JobActionAnimated in this;
        action.actionName = actionName;
        action.actionCategory = actionCategory;
        actions.PushBack(action);

        return action;
    }

    private function newAction_special(actionName : name) : MCM_JobActionSpecial
    {
        var action : MCM_JobActionSpecial;
        action = new MCM_JobActionSpecial in this;
        action.actionName = actionName;
        actions.PushBack(action);

        return action;
    }

    //Simple action, just play animations
    private function newAction_joinMaleFemale(actionName : name, optional actionCategory : name) : MCM_JobActionMaleFemale
    {
        var action : MCM_JobActionMaleFemale;
        action = new MCM_JobActionMaleFemale in this;
        action.actionName = actionName;
        action.actionCategory = actionCategory;
        actions.PushBack(action);

        return action;
    }

    private function newActionPoint(actionPointName : name, position : Vector, rotation : EulerAngles, optional activationRadius : float, optional isOutside : bool) : MCM_JobActionPoint
    {
        var actionPoint : MCM_JobActionPoint;
        actionPoint = new MCM_JobActionPoint in this;
        actionPoint.actionPointName = actionPointName;
        actionPoint.position = position;
        actionPoint.rotation = rotation;
        actionPoint.isOutside = isOutside;
        if(activationRadius < 0.01) activationRadius = 1;
        actionPoint.activationRadius = activationRadius;
        actionPoints.PushBack(actionPoint);

        return actionPoint;
    }

    private function newJob(jobName : name) : MCM_Job
    {
        var job : MCM_Job;
        job = new MCM_Job in this;
        job.jobName = jobName;
        jobs.PushBack(job);

        return job;
    }

    private function newSchedule(scheduleName : name) : MCM_WorkSchedule
    {
        var schedule : MCM_WorkSchedule;
        schedule = new MCM_WorkSchedule in this;
        schedule.scheduleName = scheduleName;
        schedule.manager = this;
        schedules.PushBack(schedule);

        return schedule;
    }

    private function copyJob(copyFrom : MCM_Job, newName : name) : MCM_Job
    {
        var job : MCM_Job;
        var i : int;
        var tmp : MCM_ActionEntry;
        job = new MCM_Job in this;
        job.jobName = newName;
        jobs.PushBack(job);

        for(i = 0; i < copyFrom.actions.Size(); i+=1) {
            tmp = copyFrom.actions[i];
            job.addAction(tmp.action, tmp.actionPoint, tmp.maxTimePerform, tmp.isInteractingWithObject);
        }

        return job;
    }

    //Actions are a thing an NPC can do.
    //However an action doesn't specify where or when to do the action.
    //Thats specified in a job
    private function InitActions()
    {
	newAction_anim('anarietta_standing_relaxed')
		.addStart('high_standing_determined_to_ep2_anarietta_standing_relaxed')
		.addStartT(0)
		.addEnd('ep2_anarietta_standing_relaxed_to_high_standing_determined')
		.addEndT(0)
		.addAnim('ep2_anarietta_standing_relaxed_weight_shift_01', 'ep2_anarietta_standing_relaxed_weight_shift_02')
		.addAnimT(0);

	newAction_anim('blacksmith_work_sword_sharpening')
		.addAnim('man_work_sword_sharpening_01')
		.addAnimT(0);

	newAction_anim('ciri_lying_relaxed')
		.addStart('woman_noble_lying_relaxed_on_grass_start')
		.addStartT(0)
		.addEnd('woman_noble_lying_relaxed_on_grass_stop')
		.addEndT(0)
		.addAnim('woman_noble_lying_relaxed_on_grass_loop_02', 'woman_noble_lying_relaxed_on_grass_loop_03', 'woman_noble_lying_relaxed_on_grass_loop_04')
		.addAnimT(0);

	newAction_anim('ciri_sitting_under_the_tree')
		.addStart('q705_high_standing_neutral_turn_180_to_ciri_sitting_under_the_tree')
		.addStartT(0)
		.addEnd('q705_ciri_sitting_under_the_tree_to_high_standing_neutral')
		.addEndT(0)
		.addAnim('gp_q705_ciri_sitting_under_the_tree_loop_01', 'gp_q705_ciri_sitting_under_the_tree_loop_02', 'gp_q705_ciri_sitting_under_the_tree_loop_03')
		.addAnimT(0);

	newAction_anim('dandelion_sitting_on_a_fence')
		.addStart('man_playing_lute_start')
		.addStartT(0)
		.addEnd('man_playing_lute_stop')
		.addEndT(0)
		.addAnim('man_playing_lute_loop_02')
		.addAnimT(0);

	newAction_anim('dettlaff_high_sitting_determined')
		.addAnim('high_sitting_determined_idle')
		.addAnimT(0);

	newAction_anim('dwarf_work_standing_hands_crossed')
		.addStart('dwarf_work_standing_hands_crossed_start')
		.addStartT(0)
		.addEnd('dwarf_work_standing_hands_crossed_stop')
		.addEndT(0)
		.addAnim('dwarf_work_standing_hands_crossed_loop_01', 'dwarf_work_standing_hands_crossed_loop_02')
		.addAnimT(0);

	newAction_anim('hattori_work_writing_stand')
		.addStart('man_work_writing_stand_start')
		.addStartT(0)
		.addEnd('man_work_writing_stand_stop')
		.addEndT(0)
		.addAnim('man_work_writing_stand_01', 'man_work_writing_stand_02', 'man_work_writing_stand_04')
		.addAnimT(0);

	newAction_anim('high_sitting_determined')
		.addStart('high_standing_determined_to_high_sitting_determined')
		.addStartT(0)
		.addEnd('high_sitting_determined_to_high_standing_determined')
		.addEndT(0)
		.addAnim('high_sitting_determined_idle')
		.addAnimT(0);

	newAction_anim('high_sitting_determined_bath', 'naked')
		.addStart('high_standing_determined_to_high_sitting_determined')
		.addStartT(0)
		.addEnd('high_sitting_determined_to_high_standing_determined')
		.addEndT(0)
		.addAnim('high_sitting_determined_idle')
		.addAnimT(0);

	newAction_anim('high_sitting_ground_determined')
		.addEnd('high_sitting_ground_determined_to_high_standing_determined')
		.addEndT(0)
		.addAnim('high_sitting_ground_determined_idle')
		.addAnimT(0);

	newAction_anim('high_sitting_leaning_determined')
		.addStart('high_standing_determined_to_high_sitting_leaning_determined')
		.addStartT(0)
		.addEnd('high_sitting_leaning_determined_to_high_standing_determined')
		.addEndT(0)
		.addAnim('high_sitting_leaning_determined_idle')
		.addAnimT(0);

        newAction_anim('high_standing_bored')
            	.addStart('high_standing_determined_to_high_standing_bored')
            	.addStartT(0)
            	.addEnd('high_standing_bored_to_high_standing_determined')
            	.addEndT(0)
            	.addAnim('high_standing_bored_idle')
            	.addAnimT(0);

	newAction_anim('high_standing_determined2')
		.addStart('high_standing_determined_to_high_standing_determined2')
		.addStartT(0)
		.addEnd('high_standing_determined2_to_high_standing_determined')
		.addEndT(0)
		.addAnim('high_standing_determined2_idle')
		.addAnimT(0);

	newAction_anim('high_standing_determined_gesture_autopsy')
		.addAnim('high_standing_determined_gesture_autopsy_pick_up_inspect')
		.addAnimT(0);

	newAction_anim('high_standing_happy')
		.addStart('high_standing_determined_to_high_standing_happy')
		.addStartT(0)
		.addEnd('high_standing_happy_to_high_standing_determined')
		.addEndT(0)
		.addAnim('high_standing_happy_idle')
		.addAnimT(0);

	newAction_anim('high_standing_leaning_back_determined')
		.addStart('high_standing_determined_to_high_standing_leaning_back_determined')
		.addStartT(0)
		.addEnd('high_standing_leaning_back_determined_to_high_standing_determined')
		.addEndT(0)
		.addAnim('high_standing_leaning_back_determined_idle')
		.addAnimT(0);

	newAction_anim('high_standing_leaning_back2_determined')
		.addEnd('high_standing_leaning_back2_determined_to_high_standing_determined')
		.addEndT(0)
		.addAnim('high_standing_leaning_back2_determined_idle')
		.addAnimT(0);

        newAction_anim('lean_mw_fence_on_arms_jt')
            	.addStart('lean_mw_fence_on_arms_jt_start')
            	.addStartT(0)
            	.addEnd('lean_mw_fence_on_arms_jt_start_stop')
            	.addEndT(0)
            	.addAnim('lean_mw_fence_on_arms_jt_start_loop_01', 'lean_mw_fence_on_arms_jt_start_loop_02', 'lean_mw_fence_on_arms_jt_start_loop_03', 'lean_mw_fence_on_arms_jt_start_loop_04')
            	.addAnimT(0);

	newAction_anim('low_sitting_ground_happy')
		.addAnim('low_sitting_ground_happy_idle')
		.addAnimT(0);

	newAction_anim('low_sitting_happy')
		.addStart('high_standing_determined_to_low_sitting_happy')
		.addStartT(0)
		.addEnd('low_sitting_happy_to_high_standing_determined')
		.addEndT(0)
		.addAnim('low_sitting_happy_idle')
		.addAnimT(0);

	newAction_anim('man_leaning_on_fence')
		.addStart('man_leaning_on_fence_on_hands_start')
		.addStartT(0)
		.addEnd('man_leaning_on_fence_on_hands_end')
		.addEndT(0)
		.addAnim('man_leaning_on_fence_on_hands_loop')
		.addAnimT(0);

	newAction_anim('man_sharpening_sword')
		.addStart('man_sharpening_sword_start')
		.addStartT(0)
		.addEnd('man_sharpening_sword_stop')
		.addEndT(0)
		.addAnim('man_sharpening_sword_loop_1', 'man_sharpening_sword_loop_2', 'man_sharpening_sword_loop_3')
		.addAnimT(0);

	newAction_anim('man_sit_eating_fish')
		.addStart('man_work_sit_table_start')
		.addStartT(0)
		.addEnd('man_work_sit_table_stop')
		.addEndT(0)
		.addAnim('man_sit_eating_fish_01', 'man_sit_eating_fish_02', 'man_sit_eating_fish_03', 'man_sit_eating_fish_04', 'man_sit_eating_fish_05')
		.addAnimT(0);

	newAction_anim('man_sitting_ground_leaning_back_bored')
		.addAnim('low_sitting_ground_leaning_back_bored_idle')
		.addAnimT(0);

	newAction_anim('man_stand_tasting_wine')
		.addStart('man_noble_stand_tasting_wine_start')
		.addStartT(0)
		.addEnd('man_noble_stand_tasting_wine_stop')
		.addEndT(0)
		.addAnim('man_noble_stand_tasting_wine_1', 'man_noble_stand_tasting_wine_2', 'man_noble_stand_tasting_wine_4')
		.addAnimT(0);

	newAction_anim('man_work_drinking')
		.addStart('man_work_drinking_start')
		.addStartT(0)
		.addEnd('man_work_drinking_stop')
		.addEndT(0)
		.addAnim('man_work_drinking_loop_01', 'man_work_drinking_loop_02', 'man_work_drinking_loop_03', 'man_work_drinking_loop_04')
		.addAnimT(0);

	newAction_anim('man_work_loot_ground')
		.addStart('man_work_loot_ground_start')
		.addStartT(0)
		.addEnd('man_work_loot_ground_stop')
		.addEndT(0)
		.addAnim('man_work_loot_ground_01')
		.addAnimT(0);

	newAction_anim('man_work_meditation')
		.addStart('man_work_meditation_start_long')
		.addStartT(0)
		.addEnd('man_work_meditation_stop_long')
		.addEndT(0)
		.addAnim('man_work_meditation_idle_01', 'man_work_meditation_idle_02')
		.addAnimT(0);

	newAction_anim('man_work_picking_up_herbs')
		.addStart('man_work_picking_up_herbs_start')
		.addStartT(0)
		.addEnd('man_work_picking_up_herbs_stop')
		.addEndT(0)
		.addAnim('man_work_picking_up_herbs_loop_01', 'man_work_picking_up_herbs_loop_03', 'man_work_picking_up_herbs_loop_06')
		.addAnimT(0);

	newAction_anim('man_work_playing_lute')
		.addStart('man_work_playing_lute_start')
		.addStartT(0)
		.addEnd('man_work_playing_lute_stop')
		.addEndT(0)
		.addAnim('man_work_playing_lute_01', 'man_work_playing_lute_02')
		.addAnimT(0);

	newAction_anim('man_work_playing_with_axe')
		.addStart('man_work_playing_with_axe_start')
		.addStartT(0)
		.addEnd('man_work_playing_with_axe_end')
		.addEndT(0)
		.addAnim('man_work_playing_with_axe_1', 'man_work_playing_with_axe_2', 'man_work_playing_with_axe_3', 'man_work_playing_with_axe_4')
		.addAnimT(0);

	newAction_anim('man_work_relaxed_sitting_and_resting')
		.addStart('man_work_relaxed_sitting_and_resting_start')
		.addStartT(0)
		.addEnd('man_work_relaxed_sitting_and_resting_stop')
		.addEndT(0)
		.addAnim('man_work_relaxed_sitting_and_resting_1', 'man_work_relaxed_sitting_and_resting_2', 'man_work_relaxed_sitting_and_resting_3')
		.addAnimT(0);

        newAction_anim('man_work_sit_chair_crosshands')
            	.addStart('man_work_sit_chair_start', 'man_work_sit_chair_crosshands_start')
            	.addStartT(0)
            	.addEnd('man_work_sit_chair_crosshands_stop', 'man_work_sit_chair_stop')
            	.addEndT(0)
            	.addAnim('man_work_sit_chair_crosshands_01', 'man_work_sit_chair_crosshands_02', 'man_work_sit_chair_crosshands_04', 'man_work_sit_chair_crosshands_05')
            	.addAnimT(0);

	newAction_anim('man_work_sit_chair_pipe')
		.addStart('man_work_sit_chair_start', 'man_work_sit_chair_pipe_start')
		.addStartT(0)
		.addEnd('man_work_sit_chair_pipe_stop', 'man_work_sit_chair_stop')
		.addEndT(0)
		.addAnim('man_work_sit_chair_pipe_01', 'man_work_sit_chair_pipe_02', 'man_work_sit_chair_pipe_03', 'man_work_sit_chair_pipe_06')
		.addAnimT(0);

        newAction_anim('man_work_sit_chair_sleep')
            	.addStart('man_work_sit_chair_start', 'man_work_sit_chair_sleep_start')
            	.addStartT(0)
            	.addEnd('man_work_sit_chair_sleep_stop', 'man_work_sit_chair_stop')
            	.addEndT(0)
            	.addAnim('man_work_sit_chair_sleep_01', 'man_work_sit_chair_sleep_02')
            	.addAnimT(0);

	newAction_anim('man_work_sitting_chair_reading_book')
		.addStart('man_work_sitting_chair_reading_book_start')
		.addStartT(0)
		.addEnd('man_work_sitting_chair_reading_book_stop')
		.addEndT(0)
		.addAnim('man_work_sitting_chair_reading_book_loop_01', 'man_work_sitting_chair_reading_book_loop_02', 'man_work_sitting_chair_reading_book_loop_03')
		.addAnimT(0);

	newAction_anim('man_work_sitting_pier_legs_hanging')
		.addStart('man_work_sitting_pier_legs_hanging_start')
		.addStartT(0)
		.addEnd('man_work_sitting_pier_legs_hanging_stop')
		.addEndT(0)
		.addAnim('man_work_sitting_pier_legs_hanging_loop_01', 'man_work_sitting_pier_legs_hanging_loop_02', 'man_work_sitting_pier_legs_hanging_loop_03', 'man_work_sitting_pier_legs_hanging_loop_04', 'man_work_sitting_pier_legs_hanging_loop_05')
		.addAnimT(0);

	newAction_anim('man_work_sit_squat')
		.addStart('man_work_sit_squat_start')
		.addStartT(0)
		.addEnd('man_work_sit_squat_stop')
		.addEndT(0)
		.addAnim('man_work_sit_squat_01')
		.addAnimT(0);

	newAction_anim('man_work_sleep_bed_right')
		.addStart('man_work_sleep_bed_right_start')
		.addStartT(0)
		.addEnd('man_work_sleep_bed_right_stop')
		.addEndT(0)
		.addAnim('man_work_sleep_bed_right_loop_2')
		.addAnimT(0);

        newAction_anim('man_work_sleep_ground')
            	.addStart('man_work_sleep_ground_start')
            	.addStartT(0)
            	.addEnd('man_work_sleep_ground_stop')
            	.addEndT(0)
            	.addAnim('man_work_sleep_ground_loop_1', 'man_work_sleep_ground_loop_2')
            	.addAnimT(0);

	newAction_anim('man_work_sleep_ground_leaning_wall')
		.addStart('man_work_sleep_ground_leaning_wall_start')
		.addStartT(0)
		.addEnd('man_work_sleep_ground_leaning_wall_stop')
		.addEndT(0)
		.addAnim('man_work_sleep_ground_leaning_wall_loop_1')
		.addAnimT(0);

	newAction_anim('man_work_standing_brewing_elixirs')
		.addStart('man_work_standing_brewing_elixirs_start')
		.addStartT(0)
		.addEnd('man_work_standing_brewing_elixirs_stop')
		.addEndT(0)
		.addAnim('man_work_standing_brewing_elixirs_loop_01', 'man_work_standing_brewing_elixirs_loop_02', 'man_work_standing_brewing_elixirs_loop_03', 'man_work_standing_brewing_elixirs_loop_04', 'man_work_standing_brewing_elixirs_loop_05')
		.addAnimT(0);

	newAction_anim('man_work_standing_reading_noticeboard')
		.addStart('man_work_standing_reading_noticeboard_start')
		.addStartT(0)
		.addEnd('man_work_standing_reading_noticeboard_stop')
		.addEndT(0)
		.addAnim('man_work_standing_reading_noticeboard_loop_01')
		.addAnimT(0);

	newAction_anim('man_work_stand_wall')
		.addStart('man_work_stand_wall_start')
		.addStartT(0)
		.addEnd('man_work_stand_wall_stop')
		.addEndT(0)
		.addAnim('man_work_stand_wall_loop')
		.addAnimT(0);

	newAction_anim('man_work_sword_sharpening')
		.addAnim('man_work_sword_sharpening_01', 'man_work_sword_sharpening_02', 'man_work_sword_sharpening_03')
		.addAnimT(0);

	newAction_anim('man_work_writing_stand')
		.addStart('man_work_writing_stand_start')
		.addStartT(0)
		.addEnd('man_work_writing_stand_stop')
		.addEndT(0)
		.addAnim('man_work_writing_stand_01', 'man_work_writing_stand_02', 'man_work_writing_stand_03', 'man_work_writing_stand_04')
		.addAnimT(0);

	newAction_anim('oriana_custom_pose')
		.addEnd('q703_oriana_custom_pose_to_high_standing_determined')
		.addEndT(0)
		.addAnim('q703_oriana_custom_pose_idle')
		.addAnimT(0);

	newAction_anim('playing_cards')
		.addStart('man_work_sit_table_start')
		.addStartT(0)
		.addEnd('man_work_sit_table_stop')
		.addEndT(0)
		.addAnim('playing_cards_01_loop_01', 'playing_cards_01_loop_02', 'playing_cards_01_loop_03', 'playing_cards_01_loop_04', 'playing_cards_01_loop_05')
		.addAnimT(0);

	newAction_anim('regis_standing_hand_straight_gesture_think')
		.addAnim('regis_standing_hand_straight_gesture_think')
		.addAnimT(0);

        newAction_anim('stand_mw_training_sword_jt', 'work')
            	.addStart('stand_mw_training_sword_jt_start')
            	.addStartT(0)
            	.addEnd('stand_mw_training_sword_jt_stop')
            	.addEndT(0)
            	.addAnim('stand_mw_training_sword_jt_loop_01', 'stand_mw_training_sword_jt_loop_02')
            	.addAnimT(0);

	newAction_anim('syanna_sitting_on_windowsill')
		.addEnd('q705_syanna_sitting_on_windowsill_to_high_standing_neutral')
		.addEndT(0)
		.addAnim('q705_syanna_sitting_on_windowsill_idle')
		.addAnimT(0);

        newAction_anim('woman_cheering_arena')
            	.addAnim('woman_cheering_arena_loop_1', 'woman_cheering_arena_loop_2', 'woman_cheering_arena_loop_3', 'woman_cheering_arena_loop_4')
            	.addAnimT(0);

        newAction_anim('woman_looking_around')
            	.addAnim('woman_looking_around_loop_1', 'woman_looking_around_loop_2', 'woman_looking_around_loop_3')
            	.addAnimT(0);

        newAction_anim('woman_looking_down')
            	.addAnim('woman_looking_down_loop_1', 'woman_looking_down_loop_2', 'woman_looking_down_loop_3')
            	.addAnimT(0);

	newAction_anim('woman_lying_on_a_deckchair')
		.addStart('q705_high_standing_neutral_to_triss_lying_on_a_deckchair')
		.addStartT(0)
		.addEnd('q705_triss_lying_on_a_deckchair_to_high_standing_neutral_gameplay')
		.addEndT(0)
		.addAnim('q705_yenn_lying_on_a_deckchair_with_a_book_loop_02', 'q705_yenn_lying_on_a_deckchair_with_a_book_loop_03')
		.addAnimT(0);

	newAction_anim('woman_lying_relaxed_on_grass')
		.addStart('woman_noble_lying_relaxed_on_grass_start')
		.addStartT(0)
		.addEnd('woman_noble_lying_relaxed_on_grass_stop')
		.addEndT(0)
		.addAnim('woman_noble_lying_relaxed_on_grass_loop_01', 'woman_noble_lying_relaxed_on_grass_loop_02', 'woman_noble_lying_relaxed_on_grass_loop_03', 'woman_noble_lying_relaxed_on_grass_loop_04')
		.addAnimT(0);

        newAction_anim('woman_sleep_on_bed_lf', 'sleep')
            	.addStart('woman_sleep_on_bed_lf_start')
            	.addStartT(0)
            	.addEnd('woman_sleep_on_bed_lf_end')
            	.addEndT(0)
            	.addAnim('woman_sleep_on_bed_lf_loop')
            	.addAnimT(0);

        newAction_anim('woman_sleep_on_bed_rf', 'sleep')
            	.addStart('woman_sleep_on_bed_rf_strat')
            	.addStartT(0)
            	.addEnd('woman_sleep_on_bed_rf_end')
            	.addEndT(0)
            	.addAnim('woman_sleep_on_bed_rf_loop')
            	.addAnimT(0);

	newAction_anim('woman_wine_tasting')
		.addStart('woman_noble_wine_tasting_start')
		.addStartT(0)
		.addEnd('woman_noble_wine_tasting_stop')
		.addEndT(0)
		.addAnim('woman_noble_wine_tasting_loop_01', 'woman_noble_wine_tasting_loop_03', 'woman_noble_wine_tasting_loop_04')
		.addAnimT(0);

        newAction_anim('woman_work_picking_up_goods')
            	.addStart('woman_work_picking_up_goods_start')
            	.addStartT(0)
            	.addEnd('woman_work_picking_up_goods_stop')
            	.addEndT(0)
            	.addAnim('woman_work_picking_up_goods_loop_01', 'woman_work_picking_up_goods_loop_02', 'woman_work_picking_up_goods_loop_03')
            	.addAnimT(0);

        newAction_anim('woman_work_sitting_bath', 'naked')
            	.addStart('woman_work_sitting_bath_start')
            	.addStartT(0)
            	.addEnd('woman_work_sitting_bath_stop')
            	.addEndT(0)
            	.addAnim('woman_work_sitting_bath_loop_01', 'woman_work_sitting_bath_loop_02', 'woman_work_sitting_bath_loop_03')
            	.addAnimT(0);

        newAction_anim('woman_work_sit_brushing_hair')
            	.addStart('woman_work_sit_brushing_hair_start')
            	.addStartT(0)
            	.addEnd('woman_work_sit_brushing_hair_stop')
            	.addEndT(0)
            	.addAnim('woman_work_sit_brushing_hair_loop')
            	.addAnimT(0);

        newAction_anim('woman_work_stand_looking_at_goods_1')
            	.addStart('woman_work_stand_looking_at_goods_start')
            	.addStartT(0)
            	.addEnd('woman_work_stand_looking_at_goods_stop')
            	.addEndT(0)
            	.addAnim('woman_work_stand_looking_at_goods_loop_01', 'woman_work_stand_looking_at_goods_loop_02', 'woman_work_stand_looking_at_goods_loop_03')
            	.addAnimT(0);

	newAction_anim('woman_work_stand_looking_at_goods_2')
		.addStart('woman_work_stand_looking_at_goods_start')
		.addStartT(0)
		.addEnd('woman_work_stand_looking_at_goods_stop')
		.addEndT(0)
		.addAnim('woman_work_stand_looking_at_goods_loop_02', 'woman_work_stand_looking_at_goods_loop_03')
		.addAnimT(0);

	newAction_anim('woman_work_stand_looking_at_goods_3')
		.addStart('woman_work_stand_looking_at_goods_start')
		.addStartT(0)
		.addEnd('woman_work_stand_looking_at_goods_stop')
		.addEndT(0)
		.addAnim('woman_work_stand_looking_at_goods_loop_03')
		.addAnimT(0);

        newAction_anim('woman_work_stand_looking_in_the_mirror')
            	.addStart('woman_work_stand_looking_in_the_mirror_start')
            	.addStartT(0)
            	.addEnd('woman_work_stand_looking_in_the_mirror_stop')
            	.addEndT(0)
            	.addAnim('woman_work_stand_looking_in_the_mirror_loop')
            	.addAnimT(0);

        newAction_anim('woman_work_sit_chair_crosshands')
            	.addStart('woman_work_sit_chair_start', 'woman_work_sit_chair_crosshands_start')
            	.addStartT(0)
            	.addEnd('woman_work_sit_chair_crosshands_stop', 'woman_work_sit_chair_stop')
            	.addEndT(0)
            	.addAnim('woman_work_sit_chair_crosshands_01', 'woman_work_sit_chair_crosshands_02', 'woman_work_sit_chair_crosshands_03')
            	.addAnim('woman_work_sit_chair_crosshands_04', 'woman_work_sit_chair_crosshands_05', 'woman_work_sit_chair_crosshands_06')
            	.addAnimT(0)
            	.addAnimT(0);

        newAction_anim('woman_work_sit_chair_sleep', 'sleep')
            	.addStart('woman_work_sit_chair_start')
           	.addStartT(0)
            	.addEnd('woman_work_sit_chair_stop')
            	.addEndT(0)
            	.addAnim('woman_sit_sleeping_loop_01', 'woman_sit_sleeping_loop_02', 'woman_sit_sleeping_loop_03')
            	.addAnimT(0);

        newAction_anim('woman_work_sitting_reading_book')
            	.addStart('woman_work_sitting_reading_book_start')
            	.addStartT(0)
            	.addEnd('woman_work_sitting_reading_book_stop')
            	.addEndT(0)
            	.addAnim('woman_work_sitting_reading_book_loop_02', 'woman_work_sitting_reading_book_loop_03', 'woman_work_sitting_reading_book_loop_04')
            	.addAnimT(0);

        newAction_anim('woman_work_sit_table_eat')
            	.addStart('woman_work_sit_chair_start', 'woman_work_sit_table_eat_start')
            	.addStartT(0)
            	.addEnd('woman_work_sit_table_eat_stop', 'woman_work_sit_chair_stop')
            	.addEndT(0)
            	.addAnim('woman_work_sit_eating_chicken_loop_01', 'woman_work_sit_eating_cheese_loop_02')
            	.addAnimT(0);

	newAction_anim('work_kneeling')
		.addStart('work_kneeling_start')    
		.addStartT(0)
		.addEnd('work_kneeling_end')
		.addEndT(0)
		.addAnim('work_kneeling_loop')
		.addAnimT(0);

	newAction_anim('work_training_sword')
		.addStart('work_training_sword_start')
		.addStartT(0)
		.addEnd('work_training_sword_stop')
		.addEndT(0)
		.addAnim('work_training_sword_01', 'work_training_sword_02', 'work_training_sword_03', 'work_training_sword_04', 'work_training_sword_05')
		.addAnimT(0);

        newAction_joinMaleFemale('sit_chair_crosshands')
            	.setMaleAction(getAction('man_work_sit_chair_crosshands'))
            	.setFemaleAction(getAction('woman_work_sit_chair_crosshands'));
    }

    //=============================================
    //
    //              KAER MORHEN
    //
    //=============================================

    private function InitActionPoints_KAERMORHEN()
    {
        newActionPoint('km_chair_down_1', Vector(78.982, 15.089, 170.754), EulerAngles(0, 80.0, 0));
        newActionPoint('km_chair_down_2', Vector(86.508, 0.174, 170.674), EulerAngles(0, -178.0, 0));
        newActionPoint('km_chair_down_3', Vector(87.382, 0.184, 170.674), EulerAngles(0, -178.0, 0));
        newActionPoint('km_chair_down_4', Vector(88.222, 0.194, 170.674), EulerAngles(0, -178.0, 0));
        newActionPoint('km_chair_down_5', Vector(88.198, -2.306, 170.674), EulerAngles(0, -3.0, 0));
        newActionPoint('km_chair_down_6', Vector(87.339, -2.316, 170.674), EulerAngles(0, -3.0, 0));
        newActionPoint('km_chair_down_7', Vector(86.496, -2.326, 170.674), EulerAngles(0, -3.0, 0));

	newActionPoint('km_ciri_training_sword', Vector(67.887916, -0.498757, 170.729849), EulerAngles(0, 94.0, 0));

        newActionPoint('km_fire_down_1', Vector(97.349, 2.948, 170.764), EulerAngles(0, -118.0, 0));
	newActionPoint('km_fire_down_2', Vector(96.959, 0.368, 170.738), EulerAngles(0, -60.0, 0));

	newActionPoint('km_gwent_1', Vector(89.989427, 0.008729, 170.625963), EulerAngles(0, -178.0, 0));
	newActionPoint('km_gwent_2', Vector(89.962586, -2.149269, 170.625963), EulerAngles(0, -3.0, 0));

	newActionPoint('km_man_eat', Vector(113.960948, 5.409627, 170.678594), EulerAngles(0, -86.0, 0));

	newActionPoint('km_man_looking_at_books', Vector(85.136871, 20.801283, 170.753799), EulerAngles(0, 0.0, 0));

	newActionPoint('km_man_sitting_sharpening_sword', Vector(70.660235, -2.046914, 170.609914), EulerAngles(0, -20.0, 0));

	newActionPoint('km_man_training_sword', Vector(68.865036, 7.941954, 170.753784), EulerAngles(0, 0.0, 0));

	newActionPoint('km_man_work_kneeling', Vector(112.527698, 7.904829, 170.752984), EulerAngles(0, 8.0, 0));

        newActionPoint('km_sleep_down_1', Vector(80.860, -2.205, 171.132), EulerAngles(0, -54.0, 0));
        newActionPoint('km_sleep_down_2', Vector(78.050, -2.300, 171.132), EulerAngles(0, -45.0, 0));
        newActionPoint('km_sleep_down_3', Vector(75.354, -2.476, 171.112), EulerAngles(0, -52.0, 0));
        newActionPoint('km_sleep_down_4', Vector(72.953, -2.268, 171.132), EulerAngles(0, -64.0, 0));
	newActionPoint('km_sleep_down_5', Vector(96.907, 0.836, 170.728), EulerAngles(0, -55.0, 0));

        newActionPoint('km_sleep_up_1', Vector(120.728, 35.274, 192.996), EulerAngles(0, 189.0, 0));
        newActionPoint('km_sleep_up_2', Vector(120.748, 35.789, 192.982), EulerAngles(0, 6.0, 0));
        newActionPoint('km_sleep_up_3', Vector(129.998, 8.746, 192.708), EulerAngles(0, 194.0, 0));

	newActionPoint('km_woman_eat_1', Vector(106.728936, 6.738469, 170.678594), EulerAngles(0, -178.0, 0));
	newActionPoint('km_woman_eat_2', Vector(105.985827, 5.174926, 170.678594), EulerAngles(0, 0.0, 0));

	newActionPoint('km_woman_looking_at_herbs', Vector(103.925842, 8.362949, 170.752984), EulerAngles(0, 0.0, 0));
    }

    private function InitJobs_KAERMORHEN()
    {
        newJob('km_ciri_misc')
		.addAction(getAction('sit_chair_crosshands'), getActionPoint('km_chair_down_1'),600,true)
		.addAction(getAction('sit_chair_crosshands'), getActionPoint('km_chair_down_2'),600,true)
		.addAction(getAction('sit_chair_crosshands'), getActionPoint('km_chair_down_3'),600,true)
		.addAction(getAction('sit_chair_crosshands'), getActionPoint('km_chair_down_4'),600,true)
		.addAction(getAction('sit_chair_crosshands'), getActionPoint('km_chair_down_5'),600,true)
		.addAction(getAction('sit_chair_crosshands'), getActionPoint('km_chair_down_6'),600,true)
		.addAction(getAction('sit_chair_crosshands'), getActionPoint('km_chair_down_7'),600,true)
		.addAction(getAction('stand_mw_training_sword_jt'), getActionPoint('km_ciri_training_sword'),1200,true)
		.addAction(getAction('high_sitting_ground_determined'), getActionPoint('km_fire_down_2'),1200,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_2'), getActionPoint('km_woman_looking_at_herbs'),600,true);

        newJob('km_sleep_down')
		.addAction(getAction('man_work_sleep_ground'), getActionPoint('km_sleep_down_1'),,true)
		.addAction(getAction('man_work_sleep_ground'), getActionPoint('km_sleep_down_2'),,true)
		.addAction(getAction('man_work_sleep_ground'), getActionPoint('km_sleep_down_3'),,true)
		.addAction(getAction('man_work_sleep_ground'), getActionPoint('km_sleep_down_4'),,true)
		.addAction(getAction('man_work_sleep_ground'), getActionPoint('km_sleep_down_5'),,true);

        newJob('km_sleep_up')
		.addAction(getAction('woman_sleep_on_bed_rf'), getActionPoint('km_sleep_up_1'),,true)
		.addAction(getAction('woman_sleep_on_bed_lf'), getActionPoint('km_sleep_up_2'),,true)
		.addAction(getAction('woman_sleep_on_bed_rf'), getActionPoint('km_sleep_up_3'),,true);

        newJob('km_sorceresses_misc')
		.addAction(getAction('sit_chair_crosshands'), getActionPoint('km_chair_down_1'),600,true)
		.addAction(getAction('sit_chair_crosshands'), getActionPoint('km_chair_down_2'),600,true)
		.addAction(getAction('sit_chair_crosshands'), getActionPoint('km_chair_down_3'),600,true)
		.addAction(getAction('sit_chair_crosshands'), getActionPoint('km_chair_down_4'),600,true)
		.addAction(getAction('sit_chair_crosshands'), getActionPoint('km_chair_down_5'),600,true)
		.addAction(getAction('sit_chair_crosshands'), getActionPoint('km_chair_down_6'),600,true)
		.addAction(getAction('sit_chair_crosshands'), getActionPoint('km_chair_down_7'),600,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_2'), getActionPoint('km_woman_looking_at_herbs'),600,true);

        newJob('km_triss_looking_at_herbs')
		.addAction(getAction('woman_work_stand_looking_at_goods_2'), getActionPoint('km_woman_looking_at_herbs'),,true);

        newJob('km_witchers_misc_1')
		.addAction(getAction('sit_chair_crosshands'), getActionPoint('km_chair_down_1'),600,true)
		.addAction(getAction('sit_chair_crosshands'), getActionPoint('km_chair_down_2'),600,true)
		.addAction(getAction('sit_chair_crosshands'), getActionPoint('km_chair_down_3'),600,true)
		.addAction(getAction('sit_chair_crosshands'), getActionPoint('km_chair_down_4'),600,true)
		.addAction(getAction('sit_chair_crosshands'), getActionPoint('km_chair_down_5'),600,true)
		.addAction(getAction('sit_chair_crosshands'), getActionPoint('km_chair_down_6'),600,true)
		.addAction(getAction('sit_chair_crosshands'), getActionPoint('km_chair_down_7'),600,true)
		.addAction(getAction('high_sitting_determined'), getActionPoint('km_fire_down_1'),1200,true)
		.addAction(getAction('man_sit_eating_fish'), getActionPoint('km_man_eat'),1800,true)
		.addAction(getAction('man_work_standing_reading_noticeboard'), getActionPoint('km_man_looking_at_books'),600,true)
		.addAction(getAction('man_sharpening_sword'), getActionPoint('km_man_sitting_sharpening_sword'),1200,true)
		.addAction(getAction('work_training_sword'), getActionPoint('km_man_training_sword'),1200,true)
		.addAction(getAction('work_kneeling'), getActionPoint('km_man_work_kneeling'),600,true);

        newJob('km_witchers_misc_2')
		.addAction(getAction('playing_cards'), getActionPoint('km_gwent_1'),,true)
		.addAction(getAction('playing_cards'), getActionPoint('km_gwent_2'),,true)
		.addAction(getAction('high_sitting_determined'), getActionPoint('km_fire_down_1'),,true)
		.addAction(getAction('man_sharpening_sword'), getActionPoint('km_man_sitting_sharpening_sword'),,true);

        newJob('km_women_eat')
		.addAction(getAction('woman_work_sit_table_eat'), getActionPoint('km_woman_eat_1'),,true)
		.addAction(getAction('woman_work_sit_table_eat'), getActionPoint('km_woman_eat_2'),,true);

        newJob('km_yennefer_sleep')
		.addAction(getAction('woman_sleep_on_bed_rf'), getActionPoint('km_sleep_up_1'),,true)
		.addAction(getAction('woman_sleep_on_bed_lf'), getActionPoint('km_sleep_up_2'),,true);
    }

    private function InitSchedules_KAERMORHEN()
    {
        newSchedule('ciri')
		.addJob(getJob('km_sleep_up'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('km_women_eat'), 3600*8, 3600*9) //8AM to 9AM
		.addJob(getJob('km_ciri_misc'), 3600*9, 3600*15) //9AM to 3PM
		.addJob(getJob('km_women_eat'), 3600*15, 3600*16) //3PM to 4PM
		.addJob(getJob('km_ciri_misc'), 3600*16, 3600*22) //4PM to 10PM
		.land(AN_Kaer_Morhen);

        newSchedule('triss')
		.addJob(getJob('km_sleep_up'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('km_triss_looking_at_herbs'), 3600*8, 3600*9) //8AM to 9AM
		.addJob(getJob('km_sorceresses_misc'), 3600*9, 3600*15) //9AM to 3PM
		.addJob(getJob('km_triss_looking_at_herbs'), 3600*15, 3600*16) //3PM to 4PM
		.addJob(getJob('km_sorceresses_misc'), 3600*16, 3600*22) //4PM to 10PM
		.land(AN_Kaer_Morhen);

        newSchedule('vesemir')
		.addJob(getJob('km_sleep_down'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('km_witchers_misc_1'), 3600*8, 3600*22) //8AM to 10PM
		.land(AN_Kaer_Morhen);

        newSchedule('witchers')
		.addJob(getJob('km_sleep_down'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('km_witchers_misc_1'), 3600*8, 3600*10) //8AM to 10AM
		.addJob(getJob('km_witchers_misc_2'), 3600*10, 3600*11) //10AM to 11AM
		.addJob(getJob('km_witchers_misc_1'), 3600*11, 3600*13) //11AM to 1PM
		.addJob(getJob('km_witchers_misc_2'), 3600*13, 3600*14) //1PM to 2PM
		.addJob(getJob('km_witchers_misc_1'), 3600*14, 3600*16) //2PM to 4PM
		.addJob(getJob('km_witchers_misc_2'), 3600*16, 3600*17) //4PM to 5PM
		.addJob(getJob('km_witchers_misc_1'), 3600*17, 3600*19) //5PM to 7PM
		.addJob(getJob('km_witchers_misc_2'), 3600*19, 3600*20) //7PM to 8PM
		.addJob(getJob('km_witchers_misc_1'), 3600*20, 3600*22) //8PM to 10PM
		.land(AN_Kaer_Morhen);

        newSchedule('yennefer')
		.addJob(getJob('km_yennefer_sleep'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('km_women_eat'), 3600*8, 3600*9) //8AM to 9AM
		.addJob(getJob('km_sorceresses_misc'), 3600*9, 3600*15) //9AM to 3PM
		.addJob(getJob('km_women_eat'), 3600*15, 3600*16) //3PM to 4PM
		.addJob(getJob('km_sorceresses_misc'), 3600*16, 3600*22) //4PM to 10PM
		.land(AN_Kaer_Morhen);
    }

    //=============================================
    //
    //              WHITE ORCHARD
    //
    //=============================================

    private function InitActionPoints_WHITEORCHARD()
    {
        newActionPoint('wo_mislav_sitting_outside', Vector(-40.590532, -105.069745, 7.608024), EulerAngles(0, -62.0, 0));
        newActionPoint('wo_mislav_sleep', Vector(-46.265736, -104.064919, 7.877649), EulerAngles(0, 58.0, 0));
    }

    private function InitJobs_WHITEORCHARD()
    {
	newJob('wo_mislav_sitting_outside')
		.addAction(getAction('high_sitting_determined'), getActionPoint('wo_mislav_sitting_outside'),,true);
	newJob('wo_mislav_sleep')
		.addAction(getAction('man_work_sleep_ground'), getActionPoint('wo_mislav_sleep'),,true);
    }

    private function InitSchedules_WHITEORCHARD()
    {
	newSchedule('mislav')
		.addJob(getJob('wo_mislav_sleep'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('wo_mislav_sitting_outside'), 3600*8, 3600*22) //8AM to 10PM
		.land(AN_Prologue_Village);
    }

    //=============================================
    //
    //              VIZIMA
    //
    //=============================================

    private function InitActionPoints_VIZIMA()
    {
        //Chamber
        newActionPoint('viz_chamber_bath', Vector(-9.495, 51.679, 10.284), EulerAngles(0, 220.0, 0));

        newActionPoint('viz_chamber_chair_1', Vector(-4.241, 51.850, 10.110), EulerAngles(0, 162.0, 0));
        newActionPoint('viz_chamber_chair_2', Vector(-8.512, 40.584, 10.129), EulerAngles(0, 118.0, 0)); 
        newActionPoint('viz_chamber_chair_3', Vector(-9.962, 39.229, 10.129), EulerAngles(0, -20.0, 0));
        newActionPoint('viz_chamber_chair_4', Vector(1.508, 32.214, 10.109), EulerAngles(0, 60.0, 0));

        newActionPoint('viz_chamber_sleep_1', Vector(0.974, 51.444, 10.203), EulerAngles(0, 136.0, 0));
        newActionPoint('viz_chamber_sleep_2', Vector(0.169, 51.356, 10.203), EulerAngles(0, 136.0, 0));
        newActionPoint('viz_chamber_sleep_3', Vector(-0.554, 50.939, 10.203), EulerAngles(0, 136.0, 0));
        newActionPoint('viz_chamber_sleep_4', Vector(1.256, 49.518, 10.203), EulerAngles(0, 136.0, 0));
        newActionPoint('viz_chamber_sleep_5', Vector(0.533, 49.183, 10.203), EulerAngles(0, 136.0, 0));

        //Outside courtyard
        newActionPoint('viz_outside_chair_1', Vector(-13.432, 7.844, 9.169), EulerAngles(0, 180.0, 0));
        newActionPoint('viz_outside_chair_2', Vector(-14.362, 7.844, 9.169), EulerAngles(0, 180.0, 0));

        //Throne
        newActionPoint('viz_throne_chair', Vector(11.605, 17.029, 11.679), EulerAngles(0, 180.0, 0));

        //Work room
        newActionPoint('viz_work_chair_1', Vector(38.889, 49.962, 11.909), EulerAngles(0, 116.0, 0));
        newActionPoint('viz_work_chair_2', Vector(36.940, 49.926, 11.909), EulerAngles(0, -105.0, 0));
        newActionPoint('viz_work_chair_3', Vector(42.690, 42.054, 11.940), EulerAngles(0, 90.0, 0));
    }

    private function InitJobs_VIZIMA() {

        newJob('viz_misc')
		.addAction(getAction('woman_work_sitting_bath'), getActionPoint('viz_chamber_bath'),2400,true)
		.addAction(getAction('woman_work_sit_chair_crosshands'), getActionPoint('viz_chamber_chair_1'),600,true)
		.addAction(getAction('woman_work_sit_chair_crosshands'), getActionPoint('viz_chamber_chair_2'),600,true)
		.addAction(getAction('woman_work_sit_chair_crosshands'), getActionPoint('viz_chamber_chair_3'),600,true)
		.addAction(getAction('woman_work_sit_chair_crosshands'), getActionPoint('viz_chamber_chair_4'),600,true)
		.addAction(getAction('woman_work_sit_chair_crosshands'), getActionPoint('viz_outside_chair_1'),600,true)
		.addAction(getAction('woman_work_sit_chair_crosshands'), getActionPoint('viz_outside_chair_2'),600,true)
		.addAction(getAction('woman_work_sit_chair_crosshands'), getActionPoint('viz_throne_chair'),2400,true)
		.addAction(getAction('woman_work_sit_chair_crosshands'), getActionPoint('viz_work_chair_1'),600,true)
		.addAction(getAction('woman_work_sit_chair_crosshands'), getActionPoint('viz_work_chair_2'),600,true)
		.addAction(getAction('woman_work_sit_chair_crosshands'), getActionPoint('viz_work_chair_3'),600,true);

        newJob('viz_sleep')
		.addAction(getAction('man_work_sleep_ground'), getActionPoint('viz_chamber_sleep_1'),,true)
		.addAction(getAction('man_work_sleep_ground'), getActionPoint('viz_chamber_sleep_2'),,true)
		.addAction(getAction('man_work_sleep_ground'), getActionPoint('viz_chamber_sleep_3'),,true)
		.addAction(getAction('man_work_sleep_ground'), getActionPoint('viz_chamber_sleep_4'),,true)
		.addAction(getAction('man_work_sleep_ground'), getActionPoint('viz_chamber_sleep_5'),,true);
    }

    private function InitSchedules_VIZIMA() {
		newSchedule('viz_main')
		.addJob(getJob('viz_sleep'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('viz_misc'), 3600*8, 3600*22) //8AM to 10PM
		.land(AN_Wyzima);
    }

    //=============================================
    //
    //              NOVIGRAD
    //
    //=============================================

    private function InitActionPoints_NOVIGRAD()
    {
        //Velen
	newActionPoint('nml_baron', Vector(155.089819, 180.723523, 36.968210), EulerAngles(0, -32.0, 0));

	newActionPoint('nml_johnny', Vector(1374.879150, -591.690132, 1.753458), EulerAngles(0, -96.0, 0));

	//Novigrad
        newActionPoint('nov_attre_chair', Vector(714.085, 2065.529, 36.369), EulerAngles(0, -146.0, 0));

        newActionPoint('nov_attre_dummy', Vector(716.140, 2069.682, 31.116), EulerAngles(0, -90.0, 0));

	newActionPoint('nov_attre_sleep', Vector(712.586, 2077.695, 40.758), EulerAngles(0, -86.0, 0));

        newActionPoint('nov_bath_1', Vector(694.819, 1993.418, 11.920), EulerAngles(0, -168.0, 0));
        newActionPoint('nov_bath_2', Vector(695.546, 1991.712, 11.920), EulerAngles(0, 67.0, 0));
        newActionPoint('nov_bath_3', Vector(692.154, 1990.253, 11.920), EulerAngles(0, 16.0, 0));
        newActionPoint('nov_bath_4', Vector(691.510, 1992.083, 11.920), EulerAngles(0, 218.0, 0));
        newActionPoint('nov_bath_5', Vector(690.128, 1991.335, 11.920), EulerAngles(0, -158.0, 0));
        newActionPoint('nov_bath_6', Vector(688.913, 1991.222, 11.920), EulerAngles(0, -158.0, 0));
        newActionPoint('nov_bath_7', Vector(687.916, 1990.789, 11.920), EulerAngles(0, -145.0, 0));
        newActionPoint('nov_bath_8', Vector(688.615, 1989.005, 11.920), EulerAngles(0, 18.0, 0));
        newActionPoint('nov_bath_9', Vector(689.849, 1989.148, 11.920), EulerAngles(0, 18.0, 0));
        newActionPoint('nov_bath_10', Vector(691.142, 1989.784, 11.920), EulerAngles(0, 18.0, 0));

	newActionPoint('nov_bathhouse_dijkstra', Vector(662.832764, 1999.390416, 13.160227), EulerAngles(0, -67.0, 0));
	newActionPoint('nov_bathhouse_dijkstra_bath', Vector(695.845897, 1992.836274, 12.173479), EulerAngles(0, 115.0, 0));

	newActionPoint('nov_chameleon_avallach', Vector(734.089611, 1735.483765, 9.774629), EulerAngles(0, 57.0, 0));

	newActionPoint('nov_chameleon_balcony_1', Vector(714.505676, 1728.788696, 14.366973), EulerAngles(0, 100.0, 0));
	newActionPoint('nov_chameleon_balcony_2', Vector(714.815857, 1727.207446, 14.366029), EulerAngles(0, 12.0, 0));

	newActionPoint('nov_chameleon_bed_mid_1', Vector(725.782419, 1724.329160, 9.750986), EulerAngles(0, 62.0, 0));
	newActionPoint('nov_chameleon_bed_mid_2', Vector(735.044287, 1735.062703, 9.750986), EulerAngles(0, -116.0, 0));
	newActionPoint('nov_chameleon_bed_mid_3', Vector(736.180603, 1734.217690, 9.750986), EulerAngles(0, 62.0, 0));
	newActionPoint('nov_chameleon_bed_mid_4', Vector(725.409846, 1739.501583, 9.547086), EulerAngles(0, -28.0, 0));
	newActionPoint('nov_chameleon_bed_mid_5', Vector(727.248047, 1742.038574, 9.547086), EulerAngles(0, 150.0, 0));

        newActionPoint('nov_chameleon_bed_up_1', Vector(723.072974, 1733.890636, 14.265249), EulerAngles(6, 150.0, 0));
        newActionPoint('nov_chameleon_bed_up_2', Vector(724.068524, 1735.234086, 14.265249), EulerAngles(6, -26.0, 0));

        newActionPoint('nov_chameleon_bench_up_boudoir_1', Vector(726.680, 1740.209, 14.280), EulerAngles(0, 214.0, 0));
        newActionPoint('nov_chameleon_bench_up_boudoir_2', Vector(726.142, 1739.433, 14.280), EulerAngles(0, -105.0, 0));
        newActionPoint('nov_chameleon_bench_up_boudoir_3', Vector(728.490, 1741.169, 14.280), EulerAngles(0, -200.0, 0));
        newActionPoint('nov_chameleon_bench_up_boudoir_4', Vector(729.184, 1740.549, 14.280), EulerAngles(0, 112.0, 0));

        newActionPoint('nov_chameleon_bench_up_theatrical_1', Vector(726.680, 1740.209, 14.280), EulerAngles(0, 214.0, 0));
        newActionPoint('nov_chameleon_bench_up_theatrical_2', Vector(726.142, 1739.433, 14.280), EulerAngles(0, -105.0, 0));
        newActionPoint('nov_chameleon_bench_up_theatrical_3', Vector(728.960, 1740.878, 14.280), EulerAngles(0, -200.0, 0));
        newActionPoint('nov_chameleon_bench_up_theatrical_4', Vector(729.684, 1740.357, 14.280), EulerAngles(0, 112.0, 0));

        newActionPoint('nov_chameleon_cheer_1', Vector(716.989, 1739.844, 4.540), EulerAngles(0, -144.0, 0));
        newActionPoint('nov_chameleon_cheer_2', Vector(715.284, 1736.793, 4.540), EulerAngles(0, -118.0, 0));
	newActionPoint('nov_chameleon_cheer_3', Vector(721.893, 1732.159, 4.636), EulerAngles(0, 140.0, 0));

        newActionPoint('nov_chameleon_dandelion', Vector(720.989632, 1732.589249, 4.635289), EulerAngles(0, -90.0, 0));

        newActionPoint('nov_chameleon_desk_boudoir_1', Vector(727.234215, 1726.099764, 14.329840), EulerAngles(0, 23.0, 0));
        newActionPoint('nov_chameleon_desk_boudoir_2', Vector(726.982753, 1728.126377, 14.219689), EulerAngles(0, 80.0, 0));

        newActionPoint('nov_chameleon_desk_theatrical_1', Vector(727.234215, 1726.099764, 14.329840), EulerAngles(0, 23.0, 0));
        newActionPoint('nov_chameleon_desk_theatrical_2', Vector(726.982753, 1728.126377, 14.356086), EulerAngles(0, 80.0, 0));

        newActionPoint('nov_chameleon_eat_up_boudoir_1', Vector(731.218, 1734.726, 14.326), EulerAngles(0, -36.0, 0));
        newActionPoint('nov_chameleon_eat_up_boudoir_2', Vector(732.092, 1734.106, 14.326), EulerAngles(0, -29.0, 0));
        newActionPoint('nov_chameleon_eat_up_boudoir_3', Vector(733.358, 1734.364, 14.326), EulerAngles(0, 58.0, 0));
        newActionPoint('nov_chameleon_eat_up_boudoir_4', Vector(733.099, 1735.579, 14.326), EulerAngles(0, 140.0, 0));
        newActionPoint('nov_chameleon_eat_up_boudoir_5', Vector(732.198, 1736.254, 14.326), EulerAngles(0, 154.0, 0));
        newActionPoint('nov_chameleon_eat_up_boudoir_6', Vector(730.902, 1735.999, 14.326), EulerAngles(0, -116.0, 0));

        newActionPoint('nov_chameleon_eat_up_theatrical_1', Vector(731.148, 1734.616, 14.326), EulerAngles(0, -36.0, 0));
        newActionPoint('nov_chameleon_eat_up_theatrical_2', Vector(731.997, 1733.917, 14.326), EulerAngles(0, -29.0, 0));
        newActionPoint('nov_chameleon_eat_up_theatrical_3', Vector(733.528, 1734.234, 14.326), EulerAngles(0, 58.0, 0));
        newActionPoint('nov_chameleon_eat_up_theatrical_4', Vector(733.169, 1735.642, 14.326), EulerAngles(0, 140.0, 0));
        newActionPoint('nov_chameleon_eat_up_theatrical_5', Vector(732.238, 1736.294, 14.326), EulerAngles(0, 154.0, 0));
        newActionPoint('nov_chameleon_eat_up_theatrical_6', Vector(730.799, 1736.147, 14.326), EulerAngles(0, -116.0, 0));

        newActionPoint('nov_chameleon_fence_up_1', Vector(716.217, 1732.222, 14.478), EulerAngles(0, 57.0, 0));
        newActionPoint('nov_chameleon_fence_up_2', Vector(718.611, 1735.629, 14.557), EulerAngles(0, 57.0, 0));
        newActionPoint('nov_chameleon_fence_up_3', Vector(720.996, 1738.958, 14.617), EulerAngles(0, 57.0, 0));

        newActionPoint('nov_chameleon_gwent_boudoir_1', Vector(725.724896, 1739.412947, 4.586897), EulerAngles(0, -122.0, 0));
        newActionPoint('nov_chameleon_gwent_boudoir_2', Vector(726.992384, 1738.458695, 4.586960), EulerAngles(0, 56.0, 0));

        newActionPoint('nov_chameleon_gwent_theatrical_1', Vector(723.309417, 1732.276980, 4.670897), EulerAngles(0, -122.0, 0));
        newActionPoint('nov_chameleon_gwent_theatrical_2', Vector(724.658136, 1731.358619, 4.648960), EulerAngles(0, 56.0, 0));

        newActionPoint('nov_chameleon_leaning_back', Vector(721.129802, 1732.536548, 14.281639), EulerAngles(0, -127.0, 0));

	newActionPoint('nov_chameleon_olgierd', Vector(727.736365, 1726.319854, 9.718056), EulerAngles(0, -35.0, 0));

	newActionPoint('nov_chameleon_woman_brushing_hair', Vector(729.179486, 1740.529648, 9.660985), EulerAngles(0, 150.0, 0));

        newActionPoint('nov_chameleon_zoltan', Vector(721.251946, 1737.046149, 4.570462), EulerAngles(0, 56.0, 0));
	newActionPoint('nov_chameleon_zoltan_gwent_boudoir', Vector(726.942384, 1738.508695, 4.586960), EulerAngles(0, 56.0, 0));
        newActionPoint('nov_chameleon_zoltan_gwent_theatrical', Vector(724.608136, 1731.408619, 4.685960), EulerAngles(0, 56.0, 0));

        newActionPoint('nov_grove_bedlam', Vector(683.120694, 1726.260825, 6.540629), EulerAngles(0, -156.0, 0));

	newActionPoint('nov_hideout_cyprian', Vector(524.761714, 2163.231266, 41.201343), EulerAngles(0, 110.0, 0));

        newActionPoint('nov_house_jad', Vector(728.280926, 1972.604296, 27.142836), EulerAngles(0, 14.0, 0));

	newActionPoint('nov_house_salma', Vector(559.164780, 1700.368129, 6.401854), EulerAngles(0, -62.0, 0));

	newActionPoint('nov_kingfisher_up_1', Vector(685.685073, 1916.633057, 25.508723), EulerAngles(0, 96.0, 0));
	newActionPoint('nov_kingfisher_up_2', Vector(682.698410, 1916.316104, 25.509819), EulerAngles(0, -83.0, 0));

	newActionPoint('nov_kingfisher_up_sleep_1', Vector(692.614072, 1918.837646, 25.769431), EulerAngles(0, -78.0, 0));
	newActionPoint('nov_kingfisher_up_sleep_2', Vector(694.150618, 1918.928213, 25.769431), EulerAngles(0, 102.0, 0));

	newActionPoint('nov_morgue_joachim', Vector(713.986331, 1997.127231, 22.728092), EulerAngles(0, 164.0, 0));

        newActionPoint('nov_shop_A_1', Vector(670.209, 1883.157, 10.246), EulerAngles(0, -78.0, 0));
        newActionPoint('nov_shop_A_2', Vector(666.190, 1878.129, 9.960), EulerAngles(0, 108.0, 0));
        newActionPoint('nov_shop_A_3', Vector(664.218, 1896.328, 10.019), EulerAngles(0, 106.0, 0));
        newActionPoint('nov_shop_A_4', Vector(663.655, 1870.331, 9.836), EulerAngles(0, 39.0, 0));
        newActionPoint('nov_shop_A_5', Vector(660.416, 1902.664, 10.015), EulerAngles(0, -1.0, 0));
	newActionPoint('nov_shop_A_6', Vector(649.167, 1895.725, 9.356), EulerAngles(0, -18.0, 0));
        newActionPoint('nov_shop_A_7', Vector(646.164, 1896.701, 9.210), EulerAngles(0, -16.0, 0));
        newActionPoint('nov_shop_A_8', Vector(645.082, 1880.206, 9.049), EulerAngles(0, -126.0, 0));
        newActionPoint('nov_shop_A_9', Vector(642.855, 1899.064, 9.127), EulerAngles(0, -10.0, 0));
	newActionPoint('nov_shop_A_10', Vector(636.159, 1899.850, 8.902), EulerAngles(0, -10.0, 0));

        newActionPoint('nov_shop_B_1', Vector(728.934, 2018.892, 32.900), EulerAngles(0, -152.0, 0));
        newActionPoint('nov_shop_B_2', Vector(727.855, 2027.602, 32.900), EulerAngles(0, -60.0, 0));
        newActionPoint('nov_shop_B_3', Vector(715.992, 2015.529, 32.890), EulerAngles(0, -136.0, 0));
        newActionPoint('nov_shop_B_4', Vector(706.885, 2015.573, 32.900), EulerAngles(0, -188.0, 0));
        newActionPoint('nov_shop_B_5', Vector(704.695, 2036.742, 32.900), EulerAngles(0, 41.0, 0));
        newActionPoint('nov_shop_B_6', Vector(701.505, 2033.607, 32.890), EulerAngles(0, 41.0, 0));
        newActionPoint('nov_shop_B_7', Vector(695.222, 2045.940, 35.628), EulerAngles(0, 48.0, 0));
        newActionPoint('nov_shop_B_8', Vector(694.570, 2057.142, 35.568), EulerAngles(0, 132.0, 0));
	newActionPoint('nov_shop_B_9', Vector(687.339, 2037.385, 35.546), EulerAngles(0, 178.0, 0));
        newActionPoint('nov_shop_B_10', Vector(681.843, 2037.544, 35.546), EulerAngles(0, 174.0, 0));

        newActionPoint('nov_shop_C_1', Vector(668.696, 1902.729, 10.332), EulerAngles(0, -80.0, 0));
        newActionPoint('nov_shop_C_2', Vector(665.084, 1881.689, 10.019), EulerAngles(0, 96.0, 0));
	newActionPoint('nov_shop_C_3', Vector(664.718, 1887.714, 10.019), EulerAngles(0, 96.0, 0));
	newActionPoint('nov_shop_C_4', Vector(664.403, 1895.152, 10.019), EulerAngles(0, 90.0, 0));
	newActionPoint('nov_shop_C_5', Vector(656.248, 1868.327, 9.650), EulerAngles(0, 0.0, 0));
        newActionPoint('nov_shop_C_6', Vector(653.287, 1894.523, 9.436), EulerAngles(0, -40.0, 0));
	newActionPoint('nov_shop_C_7', Vector(644.462, 1884.283, 9.010), EulerAngles(0, 60.0, 0));
	newActionPoint('nov_shop_C_8', Vector(643.486, 1876.944, 8.960), EulerAngles(0, -138.0, 0));
	newActionPoint('nov_shop_C_9', Vector(637.640, 1907.135, 10.149), EulerAngles(0, 186.0, 0));
        newActionPoint('nov_shop_C_10', Vector(617.560, 1893.050, 8.912), EulerAngles(0, 129.0, 0));

	newActionPoint('nov_vault_bart', Vector(669.914734, 1988.639526, 6.727913), EulerAngles(0, -12.0, 0));

        //Oxenfurt
        newActionPoint('oxen_casimir', Vector(1712.627056, 977.449208, 6.614209), EulerAngles(0, -126.0, 0));

        newActionPoint('oxen_eveline', Vector(1713.110649, 975.835840, 6.509486), EulerAngles(0, -55.0, 0));

        newActionPoint('oxen_ewald', Vector(1714.547349, 975.954407, 6.591446), EulerAngles(0, 54.0, 0));

        newActionPoint('oxen_graden', Vector(1689.164527, 1079.435801, 3.386596), EulerAngles(0, 33.0, 0));

        newActionPoint('oxen_quinto', Vector(1716.070313, 979.185682, 6.586032), EulerAngles(0, 145.0, 0));

	newActionPoint('oxen_shani_chair', Vector(1672.885, 965.901, 8.190), EulerAngles(0, -44.0, 0));

	newActionPoint('oxen_shani_looking_1', Vector(1668.986, 964.139, 8.186), EulerAngles(0, -128.0, 0));
	newActionPoint('oxen_shani_looking_2', Vector(1677.621, 966.783, 8.186), EulerAngles(0, -128.0, 0));
	newActionPoint('oxen_shani_looking_3', Vector(1667.464, 964.854, 3.578), EulerAngles(0, 50.0, 0));
	newActionPoint('oxen_shani_looking_4', Vector(1675.728, 969.744, 3.578), EulerAngles(0, -36.0, 0));
	newActionPoint('oxen_shani_looking_5', Vector(1676.878, 965.974, 3.578), EulerAngles(0, -128.0, 0));

        newActionPoint('oxen_shani_sleep', Vector(1671.609834, 960.490723, 8.024169), EulerAngles(0, 55.0, 0));

	newActionPoint('oxen_shop_1', Vector(1690.116, 1033.308, 4.580), EulerAngles(0, 9.0, 0));
	newActionPoint('oxen_shop_2', Vector(1694.825, 1033.867, 4.543), EulerAngles(0, 21.0, 0));
	newActionPoint('oxen_shop_3', Vector(1697.710, 1071.450, 4.200), EulerAngles(0, 46.0, 0));
	newActionPoint('oxen_shop_4', Vector(1701.698, 1049.875, 3.547), EulerAngles(0, 74.0, 0));
	newActionPoint('oxen_shop_5', Vector(1720.358, 1060.092, 3.578), EulerAngles(0, -14.0, 0));
	newActionPoint('oxen_shop_6', Vector(1706.713, 1052.808, 3.516), EulerAngles(0, -129.0, 0));
	newActionPoint('oxen_shop_7', Vector(1695.980, 1059.107, 4.202), EulerAngles(0, 78.0, 0));

        newActionPoint('oxen_tamara', Vector(1683.608521, 1081.809204, 8.504318), EulerAngles(0, 90.0, 0));

	newActionPoint('oxen_tamara_sleep', Vector(1685.078760, 1081.042969, 8.502639), EulerAngles(0, 70.0, 0));
    }

    private function InitJobs_NOVIGRAD()
    {
	newJob('nml_baron')
		.addAction(getAction('man_work_sit_chair_pipe'), getActionPoint('nml_baron'),,true);

	newJob('nml_johnny')
		.addAction(getAction('high_standing_bored'), getActionPoint('nml_johnny'),,true);

        newJob('nov_attre_chair')
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('nov_attre_chair'),,true);

        newJob('nov_attre_practice')
		.addAction(getAction('stand_mw_training_sword_jt'), getActionPoint('nov_attre_dummy'),,true);

        newJob('nov_attre_sleep')
		.addAction(getAction('woman_sleep_on_bed_lf'), getActionPoint('nov_attre_sleep'),,true);

        newJob('nov_bath')
		.addAction(getAction('woman_work_sitting_bath'), getActionPoint('nov_bath_1'),,true)
		.addAction(getAction('woman_work_sitting_bath'), getActionPoint('nov_bath_2'),,true)
		.addAction(getAction('woman_work_sitting_bath'), getActionPoint('nov_bath_3'),,true)
		.addAction(getAction('woman_work_sitting_bath'), getActionPoint('nov_bath_4'),,true)
		.addAction(getAction('woman_work_sitting_bath'), getActionPoint('nov_bath_5'),,true)
		.addAction(getAction('woman_work_sitting_bath'), getActionPoint('nov_bath_6'),,true)
		.addAction(getAction('woman_work_sitting_bath'), getActionPoint('nov_bath_7'),,true)
		.addAction(getAction('woman_work_sitting_bath'), getActionPoint('nov_bath_8'),,true)
		.addAction(getAction('woman_work_sitting_bath'), getActionPoint('nov_bath_9'),,true)
		.addAction(getAction('woman_work_sitting_bath'), getActionPoint('nov_bath_10'),,true);

	newJob('nov_bathhouse_dijkstra')
		.addAction(getAction('man_work_writing_stand'), getActionPoint('nov_bathhouse_dijkstra'),,true);
	newJob('nov_bathhouse_dijkstra_bath')
		.addAction(getAction('high_sitting_determined_bath'), getActionPoint('nov_bathhouse_dijkstra_bath'),,true);

	newJob('nov_chameleon_avallach')
		.addAction(getAction('high_sitting_determined'), getActionPoint('nov_chameleon_avallach'),,true);

	newJob('nov_chameleon_dandelion')
		.addAction(getAction('high_standing_happy'), getActionPoint('nov_chameleon_dandelion'),,true);

        newJob('nov_chameleon_eat_upstairs_boudoir')
		.setFact(MCM_SFactCheck('sq303_boudoir', EO_GreaterEqual, 1))
		.addAction(getAction('woman_work_sit_table_eat'), getActionPoint('nov_chameleon_eat_up_boudoir_1'),,true)
		.addAction(getAction('woman_work_sit_table_eat'), getActionPoint('nov_chameleon_eat_up_boudoir_2'),,true)
		.addAction(getAction('woman_work_sit_table_eat'), getActionPoint('nov_chameleon_eat_up_boudoir_3'),,true)
		.addAction(getAction('woman_work_sit_table_eat'), getActionPoint('nov_chameleon_eat_up_boudoir_4'),,true)
		.addAction(getAction('woman_work_sit_table_eat'), getActionPoint('nov_chameleon_eat_up_boudoir_5'),,true)
		.addAction(getAction('woman_work_sit_table_eat'), getActionPoint('nov_chameleon_eat_up_boudoir_6'),,true);

        newJob('nov_chameleon_eat_upstairs_theatrical')
		.setFact(MCM_SFactCheck('sq303_theatrical', EO_GreaterEqual, 1))
		.addAction(getAction('woman_work_sit_table_eat'), getActionPoint('nov_chameleon_eat_up_theatrical_1'),,true)
		.addAction(getAction('woman_work_sit_table_eat'), getActionPoint('nov_chameleon_eat_up_theatrical_2'),,true)
		.addAction(getAction('woman_work_sit_table_eat'), getActionPoint('nov_chameleon_eat_up_theatrical_3'),,true)
		.addAction(getAction('woman_work_sit_table_eat'), getActionPoint('nov_chameleon_eat_up_theatrical_4'),,true)
		.addAction(getAction('woman_work_sit_table_eat'), getActionPoint('nov_chameleon_eat_up_theatrical_5'),,true)
		.addAction(getAction('woman_work_sit_table_eat'), getActionPoint('nov_chameleon_eat_up_theatrical_6'),,true);

	newJob('nov_chameleon_gwent_boudoir_1')
		.setFact(MCM_SFactCheck('sq303_boudoir', EO_GreaterEqual, 1))
		.addAction(getAction('playing_cards'), getActionPoint('nov_chameleon_gwent_boudoir_1'),,true);
	newJob('nov_chameleon_gwent_boudoir_2')
		.setFact(MCM_SFactCheck('sq303_boudoir', EO_GreaterEqual, 1))
		.addAction(getAction('playing_cards'), getActionPoint('nov_chameleon_gwent_boudoir_2'),,true);

	newJob('nov_chameleon_gwent_theatrical_1')
		.setFact(MCM_SFactCheck('sq303_theatrical', EO_GreaterEqual, 1))
		.addAction(getAction('playing_cards'), getActionPoint('nov_chameleon_gwent_theatrical_1'),,true);
	newJob('nov_chameleon_gwent_theatrical_2')
		.setFact(MCM_SFactCheck('sq303_theatrical', EO_GreaterEqual, 1))
		.addAction(getAction('playing_cards'), getActionPoint('nov_chameleon_gwent_theatrical_2'),,true);

        newJob('nov_chameleon_lean_railing')
		.addAction(getAction('lean_mw_fence_on_arms_jt'), getActionPoint('nov_chameleon_fence_up_1'),,true)
		.addAction(getAction('lean_mw_fence_on_arms_jt'), getActionPoint('nov_chameleon_fence_up_2'),,true)
		.addAction(getAction('lean_mw_fence_on_arms_jt'), getActionPoint('nov_chameleon_fence_up_3'),,true);

        newJob('nov_chameleon_men_boudoir_misc')
		.setFact(MCM_SFactCheck('sq303_boudoir', EO_GreaterEqual, 1))
		.addAction(getAction('high_standing_happy'), getActionPoint('nov_chameleon_balcony_1'),,true)
		.addAction(getAction('playing_cards'), getActionPoint('nov_chameleon_gwent_boudoir_1'),,true)
		.addAction(getAction('playing_cards'), getActionPoint('nov_chameleon_gwent_boudoir_2'),,true)
		.addAction(getAction('high_standing_leaning_back2_determined'), getActionPoint('nov_chameleon_balcony_2'),,true);

        newJob('nov_chameleon_men_theatrical_misc')
		.setFact(MCM_SFactCheck('sq303_theatrical', EO_GreaterEqual, 1))
		.addAction(getAction('high_standing_happy'), getActionPoint('nov_chameleon_balcony_1'),,true)
		.addAction(getAction('playing_cards'), getActionPoint('nov_chameleon_gwent_theatrical_1'),,true)
		.addAction(getAction('playing_cards'), getActionPoint('nov_chameleon_gwent_theatrical_2'),,true)
		.addAction(getAction('high_standing_leaning_back2_determined'), getActionPoint('nov_chameleon_balcony_2'),,true);

	newJob('nov_chameleon_olgierd')
		.addAction(getAction('high_standing_leaning_back_determined'), getActionPoint('nov_chameleon_olgierd'),,true);

        newJob('nov_chameleon_sleep')
		.addAction(getAction('woman_sleep_on_bed_lf'), getActionPoint('nov_chameleon_bed_mid_1'),,true)
		.addAction(getAction('woman_sleep_on_bed_lf'), getActionPoint('nov_chameleon_bed_mid_2'),,true)
		.addAction(getAction('woman_sleep_on_bed_rf'), getActionPoint('nov_chameleon_bed_mid_3'),,true)
		.addAction(getAction('woman_sleep_on_bed_lf'), getActionPoint('nov_chameleon_bed_mid_4'),,true)
		.addAction(getAction('woman_sleep_on_bed_rf'), getActionPoint('nov_chameleon_bed_mid_5'),,true);

        newJob('nov_chameleon_sleep_up')
		.addAction(getAction('woman_sleep_on_bed_rf'), getActionPoint('nov_chameleon_bed_up_1'),,true)
		.addAction(getAction('woman_sleep_on_bed_lf'), getActionPoint('nov_chameleon_bed_up_2'),,true);

        newJob('nov_chameleon_women_misc_boudoir_1')
		.setFact(MCM_SFactCheck('sq303_boudoir', EO_GreaterEqual, 1))
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('nov_chameleon_bench_up_boudoir_1'),40*60,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('nov_chameleon_bench_up_boudoir_2'),40*60,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('nov_chameleon_bench_up_boudoir_3'),40*60,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('nov_chameleon_bench_up_boudoir_4'),40*60,true)

		.addAction(getAction('woman_cheering_arena'), getActionPoint('nov_chameleon_cheer_1'),20*60,true)
		.addAction(getAction('woman_cheering_arena'), getActionPoint('nov_chameleon_cheer_2'),20*60,true)
		.addAction(getAction('woman_cheering_arena'), getActionPoint('nov_chameleon_cheer_3'),20*60,true)

		.addAction(getAction('woman_work_sit_chair_crosshands'), getActionPoint('nov_chameleon_desk_boudoir_1'),40*60,true)
		.addAction(getAction('high_sitting_determined'), getActionPoint('nov_chameleon_desk_boudoir_2'),40*60,true)

		.addAction(getAction('lean_mw_fence_on_arms_jt'), getActionPoint('nov_chameleon_fence_up_1'),20*60,true)
		.addAction(getAction('lean_mw_fence_on_arms_jt'), getActionPoint('nov_chameleon_fence_up_2'),20*60,true)
		.addAction(getAction('lean_mw_fence_on_arms_jt'), getActionPoint('nov_chameleon_fence_up_3'),20*60,true)

		.addAction(getAction('high_standing_leaning_back_determined'), getActionPoint('nov_chameleon_leaning_back'),20*60,true)

		.addAction(getAction('woman_work_sit_brushing_hair'), getActionPoint('nov_chameleon_woman_brushing_hair'),40*60,true);

        newJob('nov_chameleon_women_misc_theatrical_1')
		.setFact(MCM_SFactCheck('sq303_theatrical', EO_GreaterEqual, 1))
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('nov_chameleon_bench_up_theatrical_1'),40*60,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('nov_chameleon_bench_up_theatrical_2'),40*60,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('nov_chameleon_bench_up_theatrical_3'),40*60,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('nov_chameleon_bench_up_theatrical_4'),40*60,true)

		.addAction(getAction('woman_cheering_arena'), getActionPoint('nov_chameleon_cheer_1'),20*60,true)
		.addAction(getAction('woman_cheering_arena'), getActionPoint('nov_chameleon_cheer_2'),20*60,true)
		.addAction(getAction('woman_cheering_arena'), getActionPoint('nov_chameleon_cheer_3'),20*60,true)

		.addAction(getAction('woman_work_sit_chair_crosshands'), getActionPoint('nov_chameleon_desk_theatrical_1'),40*60,true)
		.addAction(getAction('high_sitting_determined'), getActionPoint('nov_chameleon_desk_theatrical_2'),40*60,true)

		.addAction(getAction('lean_mw_fence_on_arms_jt'), getActionPoint('nov_chameleon_fence_up_1'),20*60,true)
		.addAction(getAction('lean_mw_fence_on_arms_jt'), getActionPoint('nov_chameleon_fence_up_2'),20*60,true)
		.addAction(getAction('lean_mw_fence_on_arms_jt'), getActionPoint('nov_chameleon_fence_up_3'),20*60,true)

		.addAction(getAction('high_standing_leaning_back_determined'), getActionPoint('nov_chameleon_leaning_back'),20*60,true)

		.addAction(getAction('woman_work_sit_brushing_hair'), getActionPoint('nov_chameleon_woman_brushing_hair'),40*60,true);

        newJob('nov_chameleon_women_misc_boudoir_2')
		.setFact(MCM_SFactCheck('sq303_boudoir', EO_GreaterEqual, 1))
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('nov_chameleon_bench_up_boudoir_1'),40*60,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('nov_chameleon_bench_up_boudoir_2'),40*60,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('nov_chameleon_bench_up_boudoir_3'),40*60,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('nov_chameleon_bench_up_boudoir_4'),40*60,true)

		.addAction(getAction('woman_cheering_arena'), getActionPoint('nov_chameleon_cheer_1'),20*60,true)
		.addAction(getAction('woman_cheering_arena'), getActionPoint('nov_chameleon_cheer_2'),20*60,true)
		.addAction(getAction('woman_cheering_arena'), getActionPoint('nov_chameleon_cheer_3'),20*60,true)

		.addAction(getAction('woman_work_sit_chair_crosshands'), getActionPoint('nov_chameleon_desk_boudoir_1'),40*60,true)
		.addAction(getAction('high_sitting_determined'), getActionPoint('nov_chameleon_desk_boudoir_2'),40*60,true)

		.addAction(getAction('high_standing_leaning_back_determined'), getActionPoint('nov_chameleon_leaning_back'),20*60,true)

		.addAction(getAction('woman_work_sit_brushing_hair'), getActionPoint('nov_chameleon_woman_brushing_hair'),40*60,true);

        newJob('nov_chameleon_women_misc_theatrical_2')
		.setFact(MCM_SFactCheck('sq303_theatrical', EO_GreaterEqual, 1))
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('nov_chameleon_bench_up_theatrical_1'),40*60,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('nov_chameleon_bench_up_theatrical_2'),40*60,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('nov_chameleon_bench_up_theatrical_3'),40*60,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('nov_chameleon_bench_up_theatrical_4'),40*60,true)

		.addAction(getAction('woman_cheering_arena'), getActionPoint('nov_chameleon_cheer_1'),20*60,true)
		.addAction(getAction('woman_cheering_arena'), getActionPoint('nov_chameleon_cheer_2'),20*60,true)
		.addAction(getAction('woman_cheering_arena'), getActionPoint('nov_chameleon_cheer_3'),20*60,true)

		.addAction(getAction('woman_work_sit_chair_crosshands'), getActionPoint('nov_chameleon_desk_theatrical_1'),40*60,true)
		.addAction(getAction('high_sitting_determined'), getActionPoint('nov_chameleon_desk_theatrical_2'),40*60,true)

		.addAction(getAction('high_standing_leaning_back_determined'), getActionPoint('nov_chameleon_leaning_back'),20*60,true)

		.addAction(getAction('woman_work_sit_brushing_hair'), getActionPoint('nov_chameleon_woman_brushing_hair'),40*60,true);

	newJob('nov_chameleon_zoltan')
		.addAction(getAction('dwarf_work_standing_hands_crossed'), getActionPoint('nov_chameleon_zoltan'),,true);
	newJob('nov_chameleon_zoltan_gwent_boudoir')
		.setFact(MCM_SFactCheck('sq303_boudoir', EO_GreaterEqual, 1))
		.addAction(getAction('playing_cards'), getActionPoint('nov_chameleon_zoltan_gwent_boudoir'),,true);
	newJob('nov_chameleon_zoltan_gwent_theatrical')
		.setFact(MCM_SFactCheck('sq303_theatrical', EO_GreaterEqual, 1))
		.addAction(getAction('playing_cards'), getActionPoint('nov_chameleon_zoltan_gwent_theatrical'),,true);

	newJob('nov_grove_bedlam')
		.addAction(getAction('high_sitting_determined'), getActionPoint('nov_grove_bedlam'),,true);

	newJob('nov_hideout_cyprian')
		.addAction(getAction('high_sitting_determined'), getActionPoint('nov_hideout_cyprian'),,true);

	newJob('nov_house_jad')
		.addAction(getAction('high_sitting_determined'), getActionPoint('nov_house_jad'),,true);

	newJob('nov_house_salma')
		.addAction(getAction('woman_work_sit_brushing_hair'), getActionPoint('nov_house_salma'),,true);

	newJob('nov_kingfisher_misc')
		.addAction(getAction('woman_work_sit_brushing_hair'), getActionPoint('nov_kingfisher_up_1'),,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('nov_kingfisher_up_2'),,true);

	newJob('nov_kingfisher_sleep')
		.addAction(getAction('woman_sleep_on_bed_lf'), getActionPoint('nov_kingfisher_up_sleep_1'),,true)
		.addAction(getAction('woman_sleep_on_bed_rf'), getActionPoint('nov_kingfisher_up_sleep_2'),,true);

	newJob('nov_morgue_joachim')
		.addAction(getAction('high_standing_determined_gesture_autopsy'), getActionPoint('nov_morgue_joachim'),,true);

        newJob('nov_shop_1')
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('nov_shop_A_1'),600,true) //No more than 10 minutes per stall
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('nov_shop_A_2'),600,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('nov_shop_A_3'),600,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('nov_shop_A_4'),600,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('nov_shop_A_5'),600,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('nov_shop_A_6'),600,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('nov_shop_A_7'),600,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('nov_shop_A_8'),600,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('nov_shop_A_9'),600,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('nov_shop_A_10'),600,true);

        newJob('nov_shop_2')
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('nov_shop_B_1'),600,true) //No more than 10 minutes per stall
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('nov_shop_B_2'),600,true) 
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('nov_shop_B_3'),600,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('nov_shop_B_4'),600,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('nov_shop_B_5'),600,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('nov_shop_B_6'),600,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('nov_shop_B_7'),600,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('nov_shop_B_8'),600,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('nov_shop_B_9'),600,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('nov_shop_B_10'),600,true);

        newJob('nov_shop_3')
		.addAction(getAction('man_work_standing_reading_noticeboard'), getActionPoint('nov_shop_C_1'),600,true) //No more than 10 minutes per stall
		.addAction(getAction('man_work_standing_reading_noticeboard'), getActionPoint('nov_shop_C_2'),600,true) 
		.addAction(getAction('man_work_standing_reading_noticeboard'), getActionPoint('nov_shop_C_3'),600,true)
		.addAction(getAction('man_work_standing_reading_noticeboard'), getActionPoint('nov_shop_C_4'),600,true)
		.addAction(getAction('man_work_standing_reading_noticeboard'), getActionPoint('nov_shop_C_5'),600,true)
		.addAction(getAction('man_work_standing_reading_noticeboard'), getActionPoint('nov_shop_C_6'),600,true)
		.addAction(getAction('high_standing_determined2'), getActionPoint('nov_shop_C_7'),600,true)
		.addAction(getAction('man_work_standing_reading_noticeboard'), getActionPoint('nov_shop_C_8'),600,true)
		.addAction(getAction('man_work_standing_reading_noticeboard'), getActionPoint('nov_shop_C_9'),600,true)
		.addAction(getAction('man_work_standing_reading_noticeboard'), getActionPoint('nov_shop_C_10'),600,true);

	newJob('nov_vault_bart')
		.addAction(getAction('high_standing_bored'), getActionPoint('nov_vault_bart'),,true);

        newJob('oxen_casimir')
		.addAction(getAction('dwarf_work_standing_hands_crossed'), getActionPoint('oxen_casimir'),,true);

        newJob('oxen_eveline')
		.addAction(getAction('high_sitting_determined'), getActionPoint('oxen_eveline'),,true);

        newJob('oxen_ewald')
		.addAction(getAction('high_sitting_determined'), getActionPoint('oxen_ewald'),,true);

        newJob('oxen_graden')
		.addAction(getAction('high_sitting_determined'), getActionPoint('oxen_graden'),,true);

        newJob('oxen_quinto')
		.addAction(getAction('high_standing_leaning_back2_determined'), getActionPoint('oxen_quinto'),,true);

        newJob('oxen_shani_misc')
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('oxen_shani_chair'),1200,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('oxen_shani_looking_1'),600,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('oxen_shani_looking_2'),600,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('oxen_shani_looking_3'),600,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('oxen_shani_looking_4'),600,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('oxen_shani_looking_5'),600,true);

        newJob('oxen_shani_sleep')
		.addAction(getAction('woman_sleep_on_bed_lf'), getActionPoint('oxen_shani_sleep'),,true);

        newJob('oxen_shop')
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('oxen_shop_1'),600,true) //No more than 10 minutes per stall
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('oxen_shop_2'),600,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('oxen_shop_3'),600,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('oxen_shop_4'),600,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('oxen_shop_5'),600,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('oxen_shop_6'),600,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_1'), getActionPoint('oxen_shop_7'),600,true);

        newJob('oxen_tamara')
		.addAction(getAction('high_standing_bored'), getActionPoint('oxen_tamara'),,true);

        newJob('oxen_tamara_sleep')
		.addAction(getAction('woman_sleep_on_bed_lf'), getActionPoint('oxen_tamara_sleep'),,true);
    }

    private function InitSchedules_NOVIGRAD()
    {
        newSchedule('novigrad_1')
            	.addJob(getJob('nov_chameleon_sleep_up'), 3600*22, 3600*8) //10PM to 8AM
            	.addJob(getJob('nov_chameleon_lean_railing'), 3600*8, 1800*17) //8AM to 8:30AM
            	.addJob(getJob('nov_chameleon_eat_upstairs_boudoir'), 1800*17, 1800*19) //8:30AM to 9:30AM
            	.addJob(getJob('nov_chameleon_eat_upstairs_theatrical'), 1800*17, 1800*19) //8:30AM to 9:30AM
            	.addJob(getJob('nov_bath'), 1800*19, 1800*23) //9:30AM to 11:30AM
            	.addJob(getJob('nov_shop_2'), 1800*23, 1800*27) //11:30AM to 1:30PM
            	.addJob(getJob('nov_shop_1'), 1800*27, 1800*31) //1:30PM to 3:30PM
		.addJob(getJob('nov_chameleon_eat_upstairs_boudoir'), 1800*31, 3600*17) //3:30PM to 5PM
		.addJob(getJob('nov_chameleon_eat_upstairs_theatrical'), 1800*31, 3600*17) //3:30PM to 5PM
		.addJob(getJob('nov_chameleon_women_misc_boudoir_1'), 3600*17, 3600*22) //5PM to 10PM
		.addJob(getJob('nov_chameleon_women_misc_theatrical_1'), 3600*17, 3600*22) //5PM to 10PM
            	.land(AN_NMLandNovigrad);

        newSchedule('novigrad_2')
            	.addJob(getJob('nov_chameleon_sleep'), 3600*22, 3600*8) //10PM to 8AM
            	.addJob(getJob('nov_chameleon_lean_railing'), 3600*8, 1800*17) //8AM to 8:30AM
            	.addJob(getJob('nov_chameleon_eat_upstairs_boudoir'), 1800*17, 1800*19) //8:30AM to 9:30AM
            	.addJob(getJob('nov_chameleon_eat_upstairs_theatrical'), 1800*17, 1800*19) //8:30AM to 9:30AM
            	.addJob(getJob('nov_bath'), 1800*19, 1800*23) //9:30AM to 11:30AM
            	.addJob(getJob('nov_shop_2'), 1800*23, 1800*27) //11:30AM to 1:30PM
            	.addJob(getJob('nov_shop_1'), 1800*27, 1800*31) //1:30PM to 3:30PM
		.addJob(getJob('nov_chameleon_eat_upstairs_boudoir'), 1800*31, 3600*17) //3:30PM to 5PM
		.addJob(getJob('nov_chameleon_eat_upstairs_theatrical'), 1800*31, 3600*17) //3:30PM to 5PM
		.addJob(getJob('nov_chameleon_women_misc_boudoir_1'), 3600*17, 3600*22) //5PM to 10PM
		.addJob(getJob('nov_chameleon_women_misc_theatrical_1'), 3600*17, 3600*22) //5PM to 10PM
            	.land(AN_NMLandNovigrad);

        newSchedule('novigrad_3')
            	.addJob(getJob('nov_chameleon_sleep'), 3600*22, 3600*8) //10PM to 8AM
            	.addJob(getJob('nov_chameleon_women_misc_theatrical_2'), 3600*8, 1800*17) //8AM to 8:30AM
            	.addJob(getJob('nov_chameleon_eat_upstairs_boudoir'), 1800*17, 1800*19) //8:30AM to 9:30AM
            	.addJob(getJob('nov_chameleon_eat_upstairs_theatrical'), 1800*17, 1800*19) //8:30AM to 9:30AM
            	.addJob(getJob('nov_bath'), 1800*19, 1800*23) //9:30AM to 11:30AM
            	.addJob(getJob('nov_shop_2'), 1800*23, 1800*27) //11:30AM to 1:30PM
            	.addJob(getJob('nov_shop_1'), 1800*27, 1800*31) //1:30PM to 3:30PM
		.addJob(getJob('nov_chameleon_eat_upstairs_boudoir'), 1800*31, 3600*17) //3:30PM to 5PM
		.addJob(getJob('nov_chameleon_eat_upstairs_theatrical'), 1800*31, 3600*17) //3:30PM to 5PM
		.addJob(getJob('nov_chameleon_women_misc_boudoir_1'), 3600*17, 3600*22) //5PM to 10PM
		.addJob(getJob('nov_chameleon_women_misc_theatrical_1'), 3600*17, 3600*22) //5PM to 10PM
            	.land(AN_NMLandNovigrad);

	newSchedule('avallach')
		.addJob(getJob('nov_chameleon_men_boudoir_misc'), 3600*21, 3600*9) //9PM to 9AM
		.addJob(getJob('nov_chameleon_men_theatrical_misc'), 3600*21, 3600*9) //9PM to 9AM
		.addJob(getJob('nov_shop_3'), 3600*9, 3600*16) //9AM to 4PM
		.addJob(getJob('nov_chameleon_avallach'), 3600*16, 3600*21) //4PM to 9PM
		.land(AN_NMLandNovigrad);

	newSchedule('baron')
		.addJob(getJob('nml_baron'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('nml_baron'), 3600*8, 3600*22) //8AM to 10PM
		.land(AN_NMLandNovigrad);

	newSchedule('bart')
		.addJob(getJob('nov_vault_bart'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('nov_vault_bart'), 3600*8, 1800*22) //8AM to 10PM
		.land(AN_NMLandNovigrad);

	newSchedule('bedlam')
		.addJob(getJob('nov_grove_bedlam'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('nov_grove_bedlam'), 3600*8, 3600*22) //8AM to 10PM
		.land(AN_NMLandNovigrad);

        newSchedule('casimir')
            	.addJob(getJob('oxen_casimir'), 3600*22, 3600*8) //10PM to 8AM
            	.addJob(getJob('oxen_casimir'), 3600*8, 3600*22) //8AM to 10PM
            	.land(AN_NMLandNovigrad);

	newSchedule('cyprian')
		.addJob(getJob('nov_hideout_cyprian'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('nov_hideout_cyprian'), 3600*8, 1800*22) //8AM to 10PM
		.land(AN_NMLandNovigrad);

	newSchedule('dandelion')
		.addJob(getJob('nov_chameleon_dandelion'), 3600*22, 3600*9) //10PM to 9AM
		.addJob(getJob('nov_chameleon_gwent_boudoir_1'), 3600*9, 3600*16) //9AM to 4PM
		.addJob(getJob('nov_chameleon_gwent_theatrical_1'), 3600*9, 3600*16) //9AM to 4PM
		.addJob(getJob('nov_chameleon_dandelion'), 3600*16, 3600*22) //4PM to 10PM
		.land(AN_NMLandNovigrad);

	newSchedule('dijkstra')
		.addJob(getJob('nov_bathhouse_dijkstra'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('nov_bathhouse_dijkstra_bath'), 3600*8, 1800*19) //8AM to 9:30AM
		.addJob(getJob('nov_shop_3'), 1800*19, 3600*16) //9:30AM to 4PM
		.addJob(getJob('nov_bathhouse_dijkstra'), 3600*16, 3600*22) //4PM to 10PM
		.land(AN_NMLandNovigrad);

        newSchedule('eveline')
            	.addJob(getJob('oxen_eveline'), 3600*22, 3600*8) //10PM to 8AM
            	.addJob(getJob('oxen_eveline'), 3600*8, 3600*22) //8AM to 10PM
            	.land(AN_NMLandNovigrad);

        newSchedule('ewald')
            	.addJob(getJob('oxen_ewald'), 3600*22, 3600*8) //10PM to 8AM
            	.addJob(getJob('oxen_ewald'), 3600*8, 3600*22) //8AM to 10PM
            	.land(AN_NMLandNovigrad);

	newSchedule('fringilla')
		.addJob(getJob('nov_kingfisher_sleep'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('nov_kingfisher_misc'), 3600*8, 1800*19) //8AM to 9:30AM
		.addJob(getJob('nov_shop_2'), 1800*19, 1800*25) //9:30AM to 12:30PM
            	.addJob(getJob('nov_shop_1'), 1800*25, 1800*31) //12:30PM to 3:30PM
		.addJob(getJob('nov_kingfisher_misc'), 1800*31, 3600*22) //3:30PM to 10PM
		.land(AN_NMLandNovigrad);

        newSchedule('graden')
            	.addJob(getJob('oxen_graden'), 3600*22, 3600*8) //10PM to 8AM
            	.addJob(getJob('oxen_graden'), 3600*8, 3600*22) //8AM to 10PM
            	.land(AN_NMLandNovigrad);

	newSchedule('jad')
		.addJob(getJob('nov_house_jad'), 3600*22, 1800*19) //10PM to 9:30AM
		.addJob(getJob('nov_shop_3'), 1800*19, 3600*16) //9:30AM to 4PM
		.addJob(getJob('nov_house_jad'), 3600*16, 3600*22) //4PM to 10PM
		.land(AN_NMLandNovigrad);

	newSchedule('joachim')
		.addJob(getJob('nov_morgue_joachim'), 3600*22, 1800*19) //10PM to 9:30AM
		.addJob(getJob('nov_shop_3'), 1800*19, 3600*16) //9:30AM to 4PM
		.addJob(getJob('nov_morgue_joachim'), 3600*16, 3600*22) //4PM to 10PM
		.land(AN_NMLandNovigrad);

	newSchedule('johnny')
		.addJob(getJob('nml_johnny'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('nml_johnny'), 3600*8, 3600*22) //8AM to 10PM
		.land(AN_NMLandNovigrad);

	newSchedule('margarita')
		.addJob(getJob('nov_kingfisher_sleep'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('nov_kingfisher_misc'), 3600*8, 1800*19) //8AM to 9:30AM
		.addJob(getJob('nov_shop_2'), 1800*19, 1800*25) //9:30AM to 12:30PM
            	.addJob(getJob('nov_shop_1'), 1800*25, 1800*31) //12:30PM to 3:30PM
		.addJob(getJob('nov_kingfisher_misc'), 1800*31, 3600*22) //3:30PM to 10PM
		.land(AN_NMLandNovigrad);

	newSchedule('olgierd')
		.addJob(getJob('nov_chameleon_men_boudoir_misc'), 3600*21, 3600*9) //9PM to 9AM
		.addJob(getJob('nov_chameleon_men_theatrical_misc'), 3600*21, 3600*9) //9PM to 9AM
		.addJob(getJob('nov_shop_3'), 3600*9, 3600*16) //9AM to 4PM
		.addJob(getJob('nov_chameleon_olgierd'), 3600*16, 3600*21) //4PM to 9PM
		.land(AN_NMLandNovigrad);

	newSchedule('philippa')
		.addJob(getJob('nov_chameleon_sleep'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('nov_chameleon_women_misc_boudoir_2'), 3600*8, 1800*17) //8AM to 8:30AM
		.addJob(getJob('nov_chameleon_women_misc_theatrical_2'), 3600*8, 1800*17) //8AM to 8:30AM
		.addJob(getJob('nov_chameleon_eat_upstairs_boudoir'), 1800*17, 1800*19) //8:30AM to 9:30AM
		.addJob(getJob('nov_chameleon_eat_upstairs_theatrical'), 1800*17, 1800*19) //8:30AM to 9:30AM
		.addJob(getJob('nov_shop_2'), 1800*19, 1800*25) //9:30AM to 12:30PM
            	.addJob(getJob('nov_shop_1'), 1800*25, 1800*31) //12:30PM to 3:30PM
		.addJob(getJob('nov_chameleon_eat_upstairs_boudoir'), 1800*31, 3600*17) //3:30PM to 5PM
		.addJob(getJob('nov_chameleon_eat_upstairs_theatrical'), 1800*31, 3600*17) //3:30PM to 5PM
		.addJob(getJob('nov_chameleon_women_misc_boudoir_1'), 3600*17, 3600*22) //5PM to 10PM
		.addJob(getJob('nov_chameleon_women_misc_theatrical_1'), 3600*17, 3600*22) //5PM to 10PM
		.land(AN_NMLandNovigrad);

	newSchedule('priscilla')
		.addJob(getJob('nov_chameleon_sleep'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('nov_chameleon_women_misc_boudoir_2'), 3600*8, 1800*17) //8AM to 8:30AM
		.addJob(getJob('nov_chameleon_women_misc_theatrical_2'), 3600*8, 1800*17) //8AM to 8:30AM
		.addJob(getJob('nov_chameleon_eat_upstairs_boudoir'), 1800*17, 1800*19) //8:30AM to 9:30AM
		.addJob(getJob('nov_chameleon_eat_upstairs_theatrical'), 1800*17, 1800*19) //8:30AM to 9:30AM
		.addJob(getJob('nov_shop_1'), 1800*19, 3600*13) //9:30AM to 1PM
            	.addJob(getJob('nov_shop_2'), 3600*13, 1800*31) //1PM to 3:30PM
		.addJob(getJob('nov_chameleon_eat_upstairs_boudoir'), 1800*31, 3600*17) //3:30PM to 5PM
		.addJob(getJob('nov_chameleon_eat_upstairs_theatrical'), 1800*31, 3600*17) //3:30PM to 5PM
		.addJob(getJob('nov_chameleon_women_misc_boudoir_1'), 3600*17, 3600*22) //5PM to 10PM
		.addJob(getJob('nov_chameleon_women_misc_theatrical_1'), 3600*17, 3600*22) //5PM to 10PM
		.land(AN_NMLandNovigrad);

        newSchedule('quinto')
            	.addJob(getJob('oxen_quinto'), 3600*22, 3600*8) //10PM to 8AM
            	.addJob(getJob('oxen_quinto'), 3600*8, 3600*22) //8AM to 10PM
            	.land(AN_NMLandNovigrad);

	newSchedule('salma')
		.addJob(getJob('nov_house_salma'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('nov_house_salma'), 3600*8, 3600*22) //8AM to 10PM
		.land(AN_NMLandNovigrad);

        newSchedule('shani')
            	.addJob(getJob('oxen_shani_sleep'), 3600*22, 3600*8) //10PM to 8AM
            	.addJob(getJob('oxen_shani_misc'), 3600*8, 3600*10) //8AM to 10AM
            	.addJob(getJob('oxen_shop'), 3600*10, 3600*16) //10AM to 4PM
            	.addJob(getJob('oxen_shani_misc'), 3600*16, 3600*22) //4PM to 10PM
            	.land(AN_NMLandNovigrad);

	newSchedule('tamara')
		.addJob(getJob('oxen_tamara_sleep'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('oxen_tamara'), 3600*8, 3600*22) //8AM to 10PM
		.land(AN_NMLandNovigrad);

	newSchedule('thaler')
		.addJob(getJob('nov_chameleon_men_boudoir_misc'), 3600*21, 3600*9) //9PM to 9AM
		.addJob(getJob('nov_chameleon_men_theatrical_misc'), 3600*21, 3600*9) //9PM to 9AM
		.addJob(getJob('nov_shop_3'), 3600*9, 3600*16) //9AM to 4PM
		.addJob(getJob('nov_chameleon_gwent_boudoir_2'), 3600*16, 3600*21) //4PM to 9PM
		.addJob(getJob('nov_chameleon_gwent_theatrical_2'), 3600*16, 3600*21) //4PM to 9PM
		.land(AN_NMLandNovigrad);

        newSchedule('rosa_var_attre')
            	.addJob(getJob('nov_attre_sleep'), 3600*22, 3600*8) //10PM to 8AM
            	.addJob(getJob('nov_attre_chair'), 3600*8, 1800*19) //8AM to 9:30AM
		.addJob(getJob('nov_shop_1'), 1800*19, 3600*13) //9:30AM to 1PM
            	.addJob(getJob('nov_shop_2'), 3600*13, 1800*31) //1PM to 3:30PM
            	.addJob(getJob('nov_attre_practice'), 1800*31, 1800*37) //3:30PM to 6:30PM
            	.addJob(getJob('nov_attre_chair'), 1800*37, 3600*22) //6:30PM to 10PM
            	.land(AN_NMLandNovigrad);

	newSchedule('vernon')
		.addJob(getJob('nov_chameleon_men_boudoir_misc'), 3600*21, 3600*9) //9PM to 9AM
		.addJob(getJob('nov_chameleon_men_theatrical_misc'), 3600*21, 3600*9) //9PM to 9AM
		.addJob(getJob('nov_shop_3'), 3600*9, 3600*16) //9AM to 4PM
		.addJob(getJob('nov_chameleon_gwent_boudoir_1'), 3600*16, 3600*21) //4PM to 9PM
		.addJob(getJob('nov_chameleon_gwent_theatrical_1'), 3600*16, 3600*21) //4PM to 9PM
		.land(AN_NMLandNovigrad);

	newSchedule('ves')
		.addJob(getJob('nov_chameleon_sleep'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('nov_chameleon_women_misc_boudoir_2'), 3600*8, 1800*17) //8AM to 8:30AM
		.addJob(getJob('nov_chameleon_women_misc_theatrical_2'), 3600*8, 1800*17) //8AM to 8:30AM
		.addJob(getJob('nov_chameleon_lean_railing'), 1800*17, 1800*19) //8:30AM to 9:30AM
		.addJob(getJob('nov_shop_1'), 1800*19, 3600*13) //9:30AM to 1PM
            	.addJob(getJob('nov_shop_2'), 3600*13, 1800*31) //1PM to 3:30PM
		.addJob(getJob('nov_chameleon_women_misc_boudoir_1'), 1800*31, 3600*22) //3:30PM to 10PM
		.addJob(getJob('nov_chameleon_women_misc_theatrical_1'), 1800*31, 3600*22) //3:30PM to 10PM
		.land(AN_NMLandNovigrad);

	newSchedule('zoltan')
		.addJob(getJob('nov_chameleon_zoltan'), 3600*22, 3600*9) //10PM to 9AM
		.addJob(getJob('nov_chameleon_zoltan_gwent_boudoir'), 3600*9, 3600*16) //9AM to 4PM
		.addJob(getJob('nov_chameleon_zoltan_gwent_theatrical'), 3600*9, 3600*16) //9AM to 4PM
		.addJob(getJob('nov_chameleon_zoltan'), 3600*16, 3600*22) //4PM to 10PM
		.land(AN_NMLandNovigrad);
    }

    //=============================================
    //
    //              SKELLIGE
    //
    //=============================================

    private function InitActionPoints_SKELLIGE()
    {
	newActionPoint('skellige_cerys_sitting', Vector(-164.109285, 677.925869, 94.324092), EulerAngles(0, -144.0, 0));
	newActionPoint('skellige_cerys_sleep', Vector(-158.024606, 676.120479, 94.199086), EulerAngles(0, 0.0, 0));

	newActionPoint('skellige_ermion', Vector(1005.938171, -41.338650, 54.152948), EulerAngles(0, 182.0, 0));

	newActionPoint('skellige_hjalmar_sleep', Vector(-175.074362, 743.937408, 108.604958), EulerAngles(0, -132.0, 0));
	newActionPoint('skellige_hjalmar_squatting', Vector(-161.406245, 669.348095, 94.389481), EulerAngles(0, -142.0, 0));

	newActionPoint('skellige_udalryk_sitting', Vector(-1649.368584, 1317.526504, 19.745729), EulerAngles(0, -31.0, 0));
	newActionPoint('skellige_udalryk_sleep', Vector(-1635.466920, 1308.543946, 19.984235), EulerAngles(0, -16.0, 0));
    }

    private function InitJobs_SKELLIGE()
    {
	newJob('skellige_cerys_sitting')
		.addAction(getAction('woman_work_sit_chair_crosshands'), getActionPoint('skellige_cerys_sitting'),,true);
	newJob('skellige_cerys_sleep')
		.addAction(getAction('woman_sleep_on_bed_rf'), getActionPoint('skellige_cerys_sleep'),,true);

	newJob('skellige_ermion')
		.addAction(getAction('high_standing_happy'), getActionPoint('skellige_ermion'),,true);

	newJob('skellige_hjalmar_sleep')
		.addAction(getAction('man_work_sleep_ground'), getActionPoint('skellige_hjalmar_sleep'),,true);
	newJob('skellige_hjalmar_squatting')
		.addAction(getAction('man_work_sit_squat'), getActionPoint('skellige_hjalmar_squatting'),,true);

	newJob('skellige_udalryk_sitting')
		.addAction(getAction('high_sitting_determined'), getActionPoint('skellige_udalryk_sitting'),,true);
	newJob('skellige_udalryk_sleep')
		.addAction(getAction('man_work_sleep_ground'), getActionPoint('skellige_udalryk_sleep'),,true);
    }

    private function InitSchedules_SKELLIGE()
    {
	newSchedule('cerys')
		.addJob(getJob('skellige_cerys_sleep'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('skellige_cerys_sitting'), 3600*8, 3600*22) //8AM to 10PM
		.land(AN_Skellige_ArdSkellig);

	newSchedule('ermion')
		.addJob(getJob('skellige_ermion'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('skellige_ermion'), 3600*8, 3600*22) //8AM to 10PM
		.land(AN_Skellige_ArdSkellig);

	newSchedule('hjalmar')
		.addJob(getJob('skellige_hjalmar_sleep'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('skellige_hjalmar_squatting'), 3600*8, 3600*22) //8AM to 10PM
		.land(AN_Skellige_ArdSkellig);

	newSchedule('udalryk')
		.addJob(getJob('skellige_udalryk_sleep'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('skellige_udalryk_sitting'), 3600*8, 3600*22) //8AM to 10PM
		.land(AN_Skellige_ArdSkellig);
    }

    //=============================================
    //
    //              TOUSSAINT
    //
    //=============================================

    private function InitActionPoints_TOUSSAINT()
    {
	newActionPoint('bob_beauclair_anarietta', Vector(-718.389694, -1197.496192, 164.264910), EulerAngles(0, 212.0, 0));
	newActionPoint('bob_beauclair_anarietta_gardens', Vector(-817.380657, -1386.362871, 104.926890), EulerAngles(0, -68.0, 0));

	newActionPoint('bob_beauclair_damien', Vector(-718.216083, -1201.029946, 164.240529), EulerAngles(0, -29.0, 0));
	newActionPoint('bob_beauclair_damien_gardens', Vector(-816.286011, -1387.687744, 104.840862), EulerAngles(0, -20.0, 0));

	newActionPoint('bob_beauclair_dettlaff', Vector(-234.097968, -1288.986295, 7.449527), EulerAngles(0, -27.0, 0));

	newActionPoint('bob_beauclair_gregoire', Vector(-700.072144, -1181.914917, 163.049946), EulerAngles(0, 36.0, 0));

	newActionPoint('bob_beauclair_guillaume', Vector(-694.862979, -1171.204565, 163.109524), EulerAngles(0, 100.0, 0));

	newActionPoint('bob_beauclair_orianna', Vector(-352.340146, -1443.926734, 87.978065), EulerAngles(0, -128.0, 0));

	newActionPoint('bob_beauclair_palmerin', Vector(-700.742488, -1194.261719, 163.838029), EulerAngles(0, 78.0, 0));

	newActionPoint('bob_beauclair_syanna', Vector(-673.604205, -1188.309555, 164.334944), EulerAngles(0, 40.0, 0));

	newActionPoint('bob_beauclair_vivienne', Vector(-694.996790, -1170.478049, 163.906921), EulerAngles(0, 118.0, 0));

	newActionPoint('bob_belgaard_blacksmith', Vector(-232.194892, -1595.014625, 50.186572), EulerAngles(0, 107.0, 0));

	newActionPoint('bob_corvo_bath_1', Vector(-393.629819, -775.746512, 34.318205), EulerAngles(0, -64.0, 0));
	newActionPoint('bob_corvo_bath_2', Vector(-394.501857, -774.452926, 34.191264), EulerAngles(0, -120.0, 0));
	newActionPoint('bob_corvo_bath_3', Vector(-395.923145, -775.291057, 34.181562), EulerAngles(0, -90.0, 0));

	newActionPoint('bob_corvo_ciri_lying_relaxed', Vector(-399.287394, -804.328936, 39.940728), EulerAngles(0, 0.0, 0));
	newActionPoint('bob_corvo_ciri_sitting_under_the_tree', Vector(-407.946118, -827.728631, 45.428947), EulerAngles(0, 10.0, 0));
	newActionPoint('bob_corvo_ciri_training_sword', Vector(-359.049746, -803.090842, 30.360897), EulerAngles(0, -10.0, 0));

	newActionPoint('bob_corvo_creek', Vector(-397.189760, -777.497068, 34.509264), EulerAngles(0, 14.0, 0));

	newActionPoint('bob_corvo_creek_bridge', Vector(-365.026418, -786.549166, 31.836527), EulerAngles(0, -80.0, 0));

	newActionPoint('bob_corvo_dandelion_playing_lute', Vector(-385.214294, -787.794861, 35.340285), EulerAngles(0, -124.0, 0));
	newActionPoint('bob_corvo_dandelion_sitting_legs_hanging', Vector(-403.584606, -826.354194, 44.876902), EulerAngles(0, -48.0, 0));
	newActionPoint('bob_corvo_dandelion_sitting_on_a_fence', Vector(-382.612756, -789.839546, 35.328136), EulerAngles(0, 46.0, 0));
	newActionPoint('bob_corvo_dandelion_sitting_relaxed', Vector(-401.728925, -799.905244, 39.253898), EulerAngles(0, -100.0, 0));
	newActionPoint('bob_corvo_dandelion_sleep_1', Vector(-401.875215, -799.674861, 39.734186), EulerAngles(0, -42.0, 0));
	newActionPoint('bob_corvo_dandelion_sleep_2', Vector(-400.979628, -799.869734, 39.221659), EulerAngles(0, -124.0, 0));

	newActionPoint('bob_corvo_dettlaff_leaning_on_fence', Vector(-398.980265, -838.548036, 43.905862), EulerAngles(0, -84.0, 0));
	newActionPoint('bob_corvo_dettlaff_sitting_legs_hanging', Vector(-393.476980, -805.718492, 38.489659), EulerAngles(0, -124.0, 0));

	newActionPoint('bob_corvo_dining_chair_1', Vector(-395.614089, -792.158965, 35.355182), EulerAngles(0, -9.0, 0));
	newActionPoint('bob_corvo_dining_chair_2', Vector(-397.674932, -790.360424, 35.339865), EulerAngles(0, -100.0, 0));
	newActionPoint('bob_corvo_dining_deckchair', Vector(-393.507426, -790.560181, 35.352479), EulerAngles(0, 85.0, 0));

        newActionPoint('bob_corvo_down_sleep_1_rf', Vector(-399.806, -800.192, 35.235), EulerAngles(0, 66.0, 0));
        newActionPoint('bob_corvo_down_sleep_1_lf', Vector(-400.561, -799.693, 35.235), EulerAngles(0, -114.0, 0));

	newActionPoint('bob_corvo_eskel_sleep', Vector(-393.567322, -790.492589, 35.981422), EulerAngles(0, 158.0, 0));

	newActionPoint('bob_corvo_greenhouse_1', Vector(-359.740763, -754.586532, 27.825209), EulerAngles(0, 94.0, 0));
	newActionPoint('bob_corvo_greenhouse_2', Vector(-357.380354, -753.149341, 27.853480), EulerAngles(0, -98.0, 0));
	newActionPoint('bob_corvo_greenhouse_3', Vector(-358.989645, -750.572847, 27.718590), EulerAngles(0, 62.0, 0));

	newActionPoint('bob_corvo_greenhouse_picking_up_herbs_1', Vector(-360.769846, -753.302694, 27.850269), EulerAngles(0, 100.0, 0));
	newActionPoint('bob_corvo_greenhouse_picking_up_herbs_2', Vector(-357.783162, -754.826350, 27.829769), EulerAngles(0, -98.0, 0));
	newActionPoint('bob_corvo_greenhouse_picking_up_herbs_3', Vector(-360.392496, -750.709628, 27.850269), EulerAngles(0, 74.0, 0));

	newActionPoint('bob_corvo_guesthouse_sleep_1', Vector(-359.168513, -832.326025, 29.521749), EulerAngles(0, 25.0, 0));
	newActionPoint('bob_corvo_guesthouse_sleep_2', Vector(-359.316268, -832.979042, 28.904751), EulerAngles(0, 0.0, 0));

	newActionPoint('bob_corvo_guestroom_chair', Vector(-397.071398, -802.047073, 39.305214), EulerAngles(0, 165.0, 0));
	newActionPoint('bob_corvo_guestroom_deckchair', Vector(-399.729581, -798.643567, 39.240748), EulerAngles(0, 155.0, 0));
	newActionPoint('bob_corvo_guestroom_woman_brushing_hair', Vector(-397.167398, -802.247073, 39.305214), EulerAngles(0, 165.0, 0));

	newActionPoint('bob_corvo_gwent_1', Vector(-357.145246, -825.940467, 29.376289), EulerAngles(0, -124.0, 0));
	newActionPoint('bob_corvo_gwent_2', Vector(-356.384562, -827.374326, 29.318689), EulerAngles(0, 0.0, 0));

	newActionPoint('bob_corvo_hattori_in_the_workshop', Vector(-366.812596, -810.484193, 31.219760), EulerAngles(0, 91.0, 0));
	newActionPoint('bob_corvo_hattori_sleep', Vector(-364.203962, -812.698502, 31.148567), EulerAngles(0, 14.0, 0));

	newActionPoint('bob_corvo_inside_bench', Vector(-392.021757, -792.309226, 35.334658), EulerAngles(0, -124.0, 0));

	newActionPoint('bob_corvo_kitchen', Vector(-388.724906, -786.908264, 35.334518), EulerAngles(0, 110.0, 0));

	newActionPoint('bob_corvo_lab_1', Vector(-405.146151, -801.612620, 25.502795), EulerAngles(0, -121.0, 0));
	newActionPoint('bob_corvo_lab_2', Vector(-406.499638, -801.538204, 25.505896), EulerAngles(0, 91.0, 0));

	newActionPoint('bob_corvo_majordomo_garden', Vector(-359.706268, -771.699284, 29.141269), EulerAngles(0, -112.0, 0));
	newActionPoint('bob_corvo_majordomo_porch', Vector(-382.329086, -788.498740, 35.342968), EulerAngles(0, -124.0, 0));
	newActionPoint('bob_corvo_majordomo_sleep', Vector(-395.624089, -792.398465, 35.355182), EulerAngles(0, 0.0, 0));
	newActionPoint('bob_corvo_majordomo_wine_cellar', Vector(-397.109849, -817.326858, 25.578295), EulerAngles(0, 186.0, 0));

	newActionPoint('bob_corvo_male_guest_sleep', Vector(-383.128544, -775.360718, 35.635206), EulerAngles(0, -10.0, 0));

	newActionPoint('bob_corvo_man_meditation', Vector(-382.426205, -772.542048, 35.056946), EulerAngles(0, -49.0, 0));

	newActionPoint('bob_corvo_man_sitting_sharpening_sword', Vector(-386.094897, -789.246995, 35.287450), EulerAngles(0, -122.0, 0));

	newActionPoint('bob_corvo_man_sitting_under_the_tree', Vector(-407.946118, -827.469631, 45.413947), EulerAngles(0, 10.0, 0));

	newActionPoint('bob_corvo_man_standing_sharpening_sword', Vector(-363.846569, -812.598629, 31.127604), EulerAngles(0, 32.0, 0));

	newActionPoint('bob_corvo_man_stand_tasting_wine_1', Vector(-385.214294, -787.794861, 35.252794), EulerAngles(0, -124.0, 0));
	newActionPoint('bob_corvo_man_stand_tasting_wine_2', Vector(-394.967492, -789.049258, 35.336892), EulerAngles(0, 146.0, 0));

	newActionPoint('bob_corvo_man_training_sword', Vector(-351.389580, -804.431635, 30.095409), EulerAngles(0, -10.0, 0));

	newActionPoint('bob_corvo_man_work_drinking', Vector(-382.592849, -787.092358, 35.340285), EulerAngles(0, 145.0, 0));

	newActionPoint('bob_corvo_man_work_stand_wall', Vector(-383.584972, -790.596218, 35.342136), EulerAngles(0, 0.0, 0));

	newActionPoint('bob_corvo_master_bedroom_chair', Vector(-397.519841, -803.298621, 35.295247), EulerAngles(0, -24.0, 0));

	newActionPoint('bob_corvo_outside_bench_1', Vector(-386.520697, -789.582936, 35.267450), EulerAngles(0, -124.0, 0));
	newActionPoint('bob_corvo_outside_bench_2', Vector(-385.984697, -789.602936, 35.257450), EulerAngles(0, -124.0, 0));

	newActionPoint('bob_corvo_outside_deckchair_1', Vector(-382.834792, -775.725794, 35.196026), EulerAngles(0, -40.0, 0));
	newActionPoint('bob_corvo_outside_deckchair_2', Vector(-382.819952, -774.406797, 35.240479), EulerAngles(0, -49.0, 0));

	newActionPoint('bob_corvo_priscilla_sleep', Vector(-401.720469, -799.189526, 39.079426), EulerAngles(0, -114.0, 0));

	newActionPoint('bob_corvo_stable', Vector(-353.704041, -808.596130, 30.300295), EulerAngles(0, 0.0, 0));

        newActionPoint('bob_corvo_up_sleep_1_rf', Vector(-399.463, -804.643, 39.372), EulerAngles(0, -24.0, 0));
        newActionPoint('bob_corvo_up_sleep_1_lf', Vector(-398.906, -803.835, 39.372), EulerAngles(0, 156.0, 0));

	newActionPoint('bob_corvo_wine_barrels_1', Vector(-393.109528, -804.458209, 35.289749), EulerAngles(0, -116.0, 0));
	newActionPoint('bob_corvo_wine_barrels_2', Vector(-395.039264, -808.632968, 35.219274), EulerAngles(0, -72.0, 0));

	newActionPoint('bob_corvo_wine_cellar_1', Vector(-397.109849, -817.396858, 25.578295), EulerAngles(0, 186.0, 0));
	newActionPoint('bob_corvo_wine_cellar_2', Vector(-397.109849, -817.396858, 25.578295), EulerAngles(0, 186.0, 0));

	newActionPoint('bob_corvo_woman_looking_around', Vector(-403.026029, -828.384695, 44.948340), EulerAngles(0, -38.0, 0));

	newActionPoint('bob_corvo_woman_looking_at_weapon_rack', Vector(-390.198294, -793.798726, 35.342965), EulerAngles(0, -124.0, 0));

	newActionPoint('bob_corvo_woman_looking_in_the_mirror', Vector(-397.869724, -801.782945, 39.230894), EulerAngles(0, -100.0, 0));

	newActionPoint('bob_corvo_woman_lying_relaxed_on_grass', Vector(-391.603583, -773.429698, 35.860926), EulerAngles(0, 196.0, 0));

	newActionPoint('bob_corvo_woman_wine_tasting_1', Vector(-386.394076, -790.740692, 35.342708), EulerAngles(0, -124.0, 0));
	newActionPoint('bob_corvo_woman_wine_tasting_2', Vector(-395.989275, -788.572964, 35.338296), EulerAngles(0, -186.0, 0));

	newActionPoint('bob_corvo_zoltan_in_the_workshop', Vector(-363.153442, -811.250427, 31.123859), EulerAngles(0, 78.0, 0));
	newActionPoint('bob_corvo_zoltan_sitting_outside_on_bench', Vector(-385.704897, -789.082936, 35.282450), EulerAngles(0, -127.0, 0));
	newActionPoint('bob_corvo_zoltan_sleep', Vector(-399.546835, -798.863982, 39.184986), EulerAngles(0, 154.0, 0));
	newActionPoint('bob_corvo_zoltan_standing_by_the_tree', Vector(-405.239288, -825.980530, 45.269837), EulerAngles(0, -48.0, 0));
	newActionPoint('bob_corvo_zoltan_standing_inside', Vector(-395.606873, -788.703735, 35.336892), EulerAngles(0, 149.0, 0));
	newActionPoint('bob_corvo_zoltan_standing_outside', Vector(-394.308198, -806.097266, 35.214523), EulerAngles(0, -119.0, 0));

	newActionPoint('bob_lady_of_the_lake', Vector(-958.040649, -774.796138, 62.529628), EulerAngles(0, -68.0, 0));

	newActionPoint('bob_sorceress_1', Vector(-1041.916283, -239.274063, 12.189036), EulerAngles(0, 18.0, 0));
	newActionPoint('bob_sorceress_2', Vector(-1040.782974, -239.285249, 12.403858), EulerAngles(0, 18.0, 0));
	newActionPoint('bob_sorceress_3', Vector(-1039.780285, -238.716295, 12.296074), EulerAngles(0, 18.0, 0));
    }

    private function InitJobs_TOUSSAINT()
    {
        newJob('bob_beauclair_anarietta')
		.addAction(getAction('anarietta_standing_relaxed'), getActionPoint('bob_beauclair_anarietta'),,true);

        newJob('bob_beauclair_anarietta_gardens')
		.addAction(getAction('high_sitting_determined'), getActionPoint('bob_beauclair_anarietta_gardens'),,true);

        newJob('bob_beauclair_damien')
		.addAction(getAction('high_standing_determined2'), getActionPoint('bob_beauclair_damien'),,true);

        newJob('bob_beauclair_damien_gardens')
		.addAction(getAction('high_standing_determined2'), getActionPoint('bob_beauclair_damien_gardens'),,true);

        newJob('bob_beauclair_dettlaff')
		.addAction(getAction('high_sitting_determined'), getActionPoint('bob_beauclair_dettlaff'),,true);

        newJob('bob_beauclair_gregoire')
		.addAction(getAction('high_standing_determined2'), getActionPoint('bob_beauclair_gregoire'),,true);

        newJob('bob_beauclair_guillaume')
		.addAction(getAction('high_standing_happy'), getActionPoint('bob_beauclair_guillaume'),,true);

        newJob('bob_beauclair_orianna')
		.addAction(getAction('oriana_custom_pose'), getActionPoint('bob_beauclair_orianna'),,true);

        newJob('bob_beauclair_palmerin')
		.addAction(getAction('high_sitting_determined'), getActionPoint('bob_beauclair_palmerin'),,true);

        newJob('bob_beauclair_syanna')
		.addAction(getAction('syanna_sitting_on_windowsill'), getActionPoint('bob_beauclair_syanna'),,true);

        newJob('bob_beauclair_vivienne')
		.addAction(getAction('high_sitting_determined'), getActionPoint('bob_beauclair_vivienne'),,true);

	newJob('bob_belgaard_blacksmith')
		.addAction(getAction('blacksmith_work_sword_sharpening'), getActionPoint('bob_belgaard_blacksmith'),,true);

        newJob('bob_corvo_anarietta_misc_1')
		.addAction(getAction('high_sitting_determined'), getActionPoint('bob_corvo_dining_chair_1'),,true)
		.addAction(getAction('woman_work_sit_chair_crosshands'), getActionPoint('bob_corvo_dining_chair_2'),,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('bob_corvo_guestroom_chair'),,true)
		.addAction(getAction('high_standing_bored'), getActionPoint('bob_corvo_kitchen'),,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('bob_corvo_outside_bench_1'),,true)
		.addAction(getAction('woman_looking_around'), getActionPoint('bob_corvo_woman_looking_around'),,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_3'), getActionPoint('bob_corvo_woman_looking_at_weapon_rack'),200,true)
		.addAction(getAction('woman_lying_relaxed_on_grass'), getActionPoint('bob_corvo_woman_lying_relaxed_on_grass'),,true)
		.addAction(getAction('woman_wine_tasting'), getActionPoint('bob_corvo_woman_wine_tasting_1'),,true)
		.addAction(getAction('woman_wine_tasting'), getActionPoint('bob_corvo_woman_wine_tasting_2'),,true);

        newJob('bob_corvo_anarietta_misc_2')
		.addAction(getAction('high_sitting_determined'), getActionPoint('bob_corvo_dining_chair_1'),,true)
		.addAction(getAction('woman_work_sit_chair_crosshands'), getActionPoint('bob_corvo_dining_chair_2'),,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('bob_corvo_guestroom_chair'),,true)
		.addAction(getAction('high_standing_bored'), getActionPoint('bob_corvo_kitchen'),,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_2'), getActionPoint('bob_corvo_wine_cellar_1'),,true)
		.addAction(getAction('woman_looking_around'), getActionPoint('bob_corvo_woman_looking_around'),,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_3'), getActionPoint('bob_corvo_woman_looking_at_weapon_rack'),200,true)
		.addAction(getAction('woman_lying_relaxed_on_grass'), getActionPoint('bob_corvo_woman_lying_relaxed_on_grass'),,true)
		.addAction(getAction('woman_wine_tasting'), getActionPoint('bob_corvo_woman_wine_tasting_1'),,true)
		.addAction(getAction('woman_wine_tasting'), getActionPoint('bob_corvo_woman_wine_tasting_2'),,true);

	newJob('bob_corvo_bathing_1')
		.addAction(getAction('woman_work_sitting_bath'), getActionPoint('bob_corvo_bath_1'),,true)
		.addAction(getAction('woman_work_sitting_bath'), getActionPoint('bob_corvo_bath_2'),,true)
		.addAction(getAction('woman_work_sitting_bath'), getActionPoint('bob_corvo_bath_3'),,true);

	newJob('bob_corvo_bathing_2')
		.addAction(getAction('woman_work_sitting_bath'), getActionPoint('bob_corvo_bath_1'),,true)
		.addAction(getAction('woman_work_sitting_bath'), getActionPoint('bob_corvo_bath_2'),,true);

	newJob('bob_corvo_ciri_lying_relaxed')
		.addAction(getAction('ciri_lying_relaxed'), getActionPoint('bob_corvo_ciri_lying_relaxed'),,true);
	newJob('bob_corvo_ciri_sitting_under_the_tree')
		.addAction(getAction('ciri_sitting_under_the_tree'), getActionPoint('bob_corvo_ciri_sitting_under_the_tree'),,true);

        newJob('bob_corvo_ciri_misc_1')
		.addAction(getAction('stand_mw_training_sword_jt'), getActionPoint('bob_corvo_ciri_training_sword'),,true)
		.addAction(getAction('high_standing_leaning_back_determined'), getActionPoint('bob_corvo_creek'),,true)
		.addAction(getAction('high_sitting_determined'), getActionPoint('bob_corvo_dining_chair_1'),,true)
		.addAction(getAction('woman_work_sit_chair_crosshands'), getActionPoint('bob_corvo_dining_chair_2'),,true)
		.addAction(getAction('woman_lying_on_a_deckchair'), getActionPoint('bob_corvo_dining_deckchair'),,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('bob_corvo_guestroom_chair'),,true)
		.addAction(getAction('woman_lying_on_a_deckchair'), getActionPoint('bob_corvo_guestroom_deckchair'),,true)
		.addAction(getAction('high_standing_bored'), getActionPoint('bob_corvo_kitchen'),,true)
		.addAction(getAction('woman_work_sit_brushing_hair'), getActionPoint('bob_corvo_master_bedroom_chair'),,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('bob_corvo_outside_bench_1'),,true)
		.addAction(getAction('woman_lying_on_a_deckchair'), getActionPoint('bob_corvo_outside_deckchair_1'),,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_2'), getActionPoint('bob_corvo_wine_cellar_1'),,true)
		.addAction(getAction('woman_looking_around'), getActionPoint('bob_corvo_woman_looking_around'),,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_3'), getActionPoint('bob_corvo_woman_looking_at_weapon_rack'),200,true)
		.addAction(getAction('woman_work_stand_looking_in_the_mirror'), getActionPoint('bob_corvo_woman_looking_in_the_mirror'),,true)
		.addAction(getAction('woman_lying_relaxed_on_grass'), getActionPoint('bob_corvo_woman_lying_relaxed_on_grass'),,true)
		.addAction(getAction('woman_wine_tasting'), getActionPoint('bob_corvo_woman_wine_tasting_1'),,true)
		.addAction(getAction('woman_wine_tasting'), getActionPoint('bob_corvo_woman_wine_tasting_2'),,true);

        newJob('bob_corvo_ciri_misc_2')
		.addAction(getAction('stand_mw_training_sword_jt'), getActionPoint('bob_corvo_ciri_training_sword'),,true)
		.addAction(getAction('high_standing_leaning_back_determined'), getActionPoint('bob_corvo_creek'),,true)
		.addAction(getAction('high_sitting_determined'), getActionPoint('bob_corvo_dining_chair_1'),,true)
		.addAction(getAction('woman_work_sit_chair_crosshands'), getActionPoint('bob_corvo_dining_chair_2'),,true)
		.addAction(getAction('woman_lying_on_a_deckchair'), getActionPoint('bob_corvo_dining_deckchair'),,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('bob_corvo_guestroom_chair'),,true)
		.addAction(getAction('woman_lying_on_a_deckchair'), getActionPoint('bob_corvo_guestroom_deckchair'),,true)
		.addAction(getAction('high_standing_bored'), getActionPoint('bob_corvo_kitchen'),,true)
		.addAction(getAction('woman_work_sit_brushing_hair'), getActionPoint('bob_corvo_master_bedroom_chair'),,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('bob_corvo_outside_bench_1'),,true)
		.addAction(getAction('woman_lying_on_a_deckchair'), getActionPoint('bob_corvo_outside_deckchair_1'),,true)
		.addAction(getAction('woman_looking_around'), getActionPoint('bob_corvo_woman_looking_around'),,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_3'), getActionPoint('bob_corvo_woman_looking_at_weapon_rack'),200,true)
		.addAction(getAction('woman_work_stand_looking_in_the_mirror'), getActionPoint('bob_corvo_woman_looking_in_the_mirror'),,true)
		.addAction(getAction('woman_lying_relaxed_on_grass'), getActionPoint('bob_corvo_woman_lying_relaxed_on_grass'),,true)
		.addAction(getAction('woman_wine_tasting'), getActionPoint('bob_corvo_woman_wine_tasting_1'),,true)
		.addAction(getAction('woman_wine_tasting'), getActionPoint('bob_corvo_woman_wine_tasting_2'),,true);

	newJob('bob_corvo_dandelion_playing_lute')
		.addAction(getAction('man_work_playing_lute'), getActionPoint('bob_corvo_dandelion_playing_lute'),,true);
	newJob('bob_corvo_dandelion_sitting_legs_hanging')
		.addAction(getAction('man_work_sitting_pier_legs_hanging'), getActionPoint('bob_corvo_dandelion_sitting_legs_hanging'),,true);
	newJob('bob_corvo_dandelion_sitting_relaxed')
		.addAction(getAction('man_work_relaxed_sitting_and_resting'), getActionPoint('bob_corvo_dandelion_sitting_relaxed'),,true);
	newJob('bob_corvo_dandelion_sleep_1')
		.addAction(getAction('man_work_sleep_ground_leaning_wall'), getActionPoint('bob_corvo_dandelion_sleep_1'),,true);
	newJob('bob_corvo_dandelion_sleep_2')
		.addAction(getAction('man_work_sleep_ground_leaning_wall'), getActionPoint('bob_corvo_dandelion_sleep_2'),,true);

	newJob('bob_corvo_dandelion_misc_1')
		.addAction(getAction('man_leaning_on_fence'), getActionPoint('bob_corvo_creek_bridge'),,true)
		.addAction(getAction('man_work_sitting_pier_legs_hanging'), getActionPoint('bob_corvo_dandelion_sitting_legs_hanging'),,true)
		.addAction(getAction('dandelion_sitting_on_a_fence'), getActionPoint('bob_corvo_dandelion_sitting_on_a_fence'),,true)
		.addAction(getAction('man_work_relaxed_sitting_and_resting'), getActionPoint('bob_corvo_dandelion_sitting_relaxed'),,true)
		.addAction(getAction('man_stand_tasting_wine'), getActionPoint('bob_corvo_man_stand_tasting_wine_1'),,true)
		.addAction(getAction('man_stand_tasting_wine'), getActionPoint('bob_corvo_man_stand_tasting_wine_2'),,true)
		.addAction(getAction('man_work_stand_wall'), getActionPoint('bob_corvo_man_work_stand_wall'),,true)
		.addAction(getAction('low_sitting_happy'), getActionPoint('bob_corvo_outside_deckchair_2'),,true)
		.addAction(getAction('man_work_standing_reading_noticeboard'), getActionPoint('bob_corvo_wine_cellar_2'),,true);

	newJob('bob_corvo_dandelion_misc_2')
		.addAction(getAction('man_leaning_on_fence'), getActionPoint('bob_corvo_creek_bridge'),,true)
		.addAction(getAction('man_work_sitting_pier_legs_hanging'), getActionPoint('bob_corvo_dandelion_sitting_legs_hanging'),,true)
		.addAction(getAction('dandelion_sitting_on_a_fence'), getActionPoint('bob_corvo_dandelion_sitting_on_a_fence'),,true)
		.addAction(getAction('man_stand_tasting_wine'), getActionPoint('bob_corvo_man_stand_tasting_wine_1'),,true)
		.addAction(getAction('man_stand_tasting_wine'), getActionPoint('bob_corvo_man_stand_tasting_wine_2'),,true)
		.addAction(getAction('man_work_stand_wall'), getActionPoint('bob_corvo_man_work_stand_wall'),,true)
		.addAction(getAction('low_sitting_happy'), getActionPoint('bob_corvo_outside_deckchair_2'),,true);

        newJob('bob_corvo_dettlaff_leaning_on_fence')
		.addAction(getAction('man_leaning_on_fence'), getActionPoint('bob_corvo_dettlaff_leaning_on_fence'),,true);
        newJob('bob_corvo_dettlaff_sitting_legs_hanging')
		.addAction(getAction('dettlaff_high_sitting_determined'), getActionPoint('bob_corvo_dettlaff_sitting_legs_hanging'),,true);

        newJob('bob_corvo_dettlaff_misc_1')
		.addAction(getAction('man_leaning_on_fence'), getActionPoint('bob_corvo_creek_bridge'),,true)
		.addAction(getAction('man_leaning_on_fence'), getActionPoint('bob_corvo_dettlaff_leaning_on_fence'),,true)
		.addAction(getAction('high_sitting_determined'), getActionPoint('bob_corvo_inside_bench'),,true)
		.addAction(getAction('man_sitting_ground_leaning_back_bored'), getActionPoint('bob_corvo_man_sitting_under_the_tree'),,true)
		.addAction(getAction('man_work_stand_wall'), getActionPoint('bob_corvo_man_work_stand_wall'),,true)
		.addAction(getAction('low_sitting_happy'), getActionPoint('bob_corvo_outside_deckchair_2'),,true)
		.addAction(getAction('high_standing_leaning_back2_determined'), getActionPoint('bob_corvo_wine_barrels_1'),,true)
		.addAction(getAction('high_standing_leaning_back2_determined'), getActionPoint('bob_corvo_wine_barrels_2'),,true)
		.addAction(getAction('man_work_standing_reading_noticeboard'), getActionPoint('bob_corvo_wine_cellar_2'),,true);

        newJob('bob_corvo_dettlaff_misc_2')
		.addAction(getAction('man_leaning_on_fence'), getActionPoint('bob_corvo_creek_bridge'),,true)
		.addAction(getAction('man_leaning_on_fence'), getActionPoint('bob_corvo_dettlaff_leaning_on_fence'),,true)
		.addAction(getAction('high_sitting_determined'), getActionPoint('bob_corvo_inside_bench'),,true)
		.addAction(getAction('man_sitting_ground_leaning_back_bored'), getActionPoint('bob_corvo_man_sitting_under_the_tree'),,true)
		.addAction(getAction('man_work_stand_wall'), getActionPoint('bob_corvo_man_work_stand_wall'),,true)
		.addAction(getAction('low_sitting_happy'), getActionPoint('bob_corvo_outside_deckchair_2'),,true)
		.addAction(getAction('high_standing_leaning_back2_determined'), getActionPoint('bob_corvo_wine_barrels_1'),,true)
		.addAction(getAction('high_standing_leaning_back2_determined'), getActionPoint('bob_corvo_wine_barrels_2'),,true);

        newJob('bob_corvo_dettlaff_misc_3')
		.addAction(getAction('man_leaning_on_fence'), getActionPoint('bob_corvo_creek_bridge'),,true)
		.addAction(getAction('man_leaning_on_fence'), getActionPoint('bob_corvo_dettlaff_leaning_on_fence'),,true)
		.addAction(getAction('high_sitting_determined'), getActionPoint('bob_corvo_inside_bench'),,true)
		.addAction(getAction('man_work_stand_wall'), getActionPoint('bob_corvo_man_work_stand_wall'),,true)
		.addAction(getAction('high_standing_leaning_back2_determined'), getActionPoint('bob_corvo_wine_barrels_1'),,true)
		.addAction(getAction('high_standing_leaning_back2_determined'), getActionPoint('bob_corvo_wine_barrels_2'),,true);

        newJob('bob_corvo_dettlaff_misc_4')
		.addAction(getAction('man_leaning_on_fence'), getActionPoint('bob_corvo_dettlaff_leaning_on_fence'),,true)
		.addAction(getAction('high_sitting_determined'), getActionPoint('bob_corvo_inside_bench'),,true)
		.addAction(getAction('man_sitting_ground_leaning_back_bored'), getActionPoint('bob_corvo_man_sitting_under_the_tree'),,true)
		.addAction(getAction('high_standing_leaning_back2_determined'), getActionPoint('bob_corvo_wine_barrels_2'),,true);

	newJob('bob_corvo_eskel_sleep')
		.addAction(getAction('man_work_sleep_ground_leaning_wall'), getActionPoint('bob_corvo_eskel_sleep'),,true);

        newJob('bob_corvo_greenhouse')
		.addAction(getAction('woman_work_stand_looking_at_goods_3'), getActionPoint('bob_corvo_greenhouse_1'),600,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_3'), getActionPoint('bob_corvo_greenhouse_2'),600,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_3'), getActionPoint('bob_corvo_greenhouse_3'),600,true);

        newJob('bob_corvo_greenhouse_picking_up_herbs')
		.addAction(getAction('man_work_picking_up_herbs'), getActionPoint('bob_corvo_greenhouse_picking_up_herbs_1'),600,true)
		.addAction(getAction('man_work_picking_up_herbs'), getActionPoint('bob_corvo_greenhouse_picking_up_herbs_2'),600,true)
		.addAction(getAction('man_work_loot_ground'), getActionPoint('bob_corvo_greenhouse_picking_up_herbs_3'),600,true);

        newJob('bob_corvo_guest_bedroom_sleep')
		.addAction(getAction('woman_sleep_on_bed_lf'), getActionPoint('bob_corvo_up_sleep_1_lf'),,true);

        newJob('bob_corvo_guesthouse_sleep_1')
		.addAction(getAction('man_work_sleep_ground'), getActionPoint('bob_corvo_guesthouse_sleep_1'),,true);
        newJob('bob_corvo_guesthouse_sleep_2')
		.addAction(getAction('woman_sleep_on_bed_rf'), getActionPoint('bob_corvo_guesthouse_sleep_2'),,true);

	newJob('bob_corvo_hattori_in_the_workshop')
		.addAction(getAction('hattori_work_writing_stand'), getActionPoint('bob_corvo_hattori_in_the_workshop'),,true);
	newJob('bob_corvo_hattori_sleep')
		.addAction(getAction('man_work_sleep_ground_leaning_wall'), getActionPoint('bob_corvo_hattori_sleep'),,true);

        newJob('bob_corvo_lab')
		.addAction(getAction('regis_standing_hand_straight_gesture_think'), getActionPoint('bob_corvo_lab_1'),600,true)
		.addAction(getAction('man_work_standing_reading_noticeboard'), getActionPoint('bob_corvo_lab_2'),600,true);

        newJob('bob_corvo_majordomo_sleep')
		.addAction(getAction('man_work_sit_chair_sleep'), getActionPoint('bob_corvo_majordomo_sleep'),,true);
        newJob('bob_corvo_majordomo_wine_cellar')
		.addAction(getAction('man_work_writing_stand'), getActionPoint('bob_corvo_majordomo_wine_cellar'),,true);

        newJob('bob_corvo_majordomo_misc_1')
		.addAction(getAction('high_standing_happy'), getActionPoint('bob_corvo_majordomo_garden'),,true)
		.addAction(getAction('high_standing_happy'), getActionPoint('bob_corvo_majordomo_porch'),,true)
		.addAction(getAction('man_stand_tasting_wine'), getActionPoint('bob_corvo_man_stand_tasting_wine_1'),,true)
		.addAction(getAction('man_stand_tasting_wine'), getActionPoint('bob_corvo_man_stand_tasting_wine_2'),,true)
		.addAction(getAction('man_work_stand_wall'), getActionPoint('bob_corvo_man_work_stand_wall'),,true);

        newJob('bob_corvo_majordomo_misc_2')
		.addAction(getAction('high_standing_happy'), getActionPoint('bob_corvo_majordomo_garden'),1200,true)
		.addAction(getAction('high_standing_happy'), getActionPoint('bob_corvo_majordomo_porch'),1200,true)
		.addAction(getAction('man_stand_tasting_wine'), getActionPoint('bob_corvo_man_stand_tasting_wine_1'),1200,true)
		.addAction(getAction('man_stand_tasting_wine'), getActionPoint('bob_corvo_man_stand_tasting_wine_2'),1200,true)
		.addAction(getAction('man_work_stand_wall'), getActionPoint('bob_corvo_man_work_stand_wall'),1200,true);

        newJob('bob_corvo_male_guest_misc_1')
		.addAction(getAction('man_leaning_on_fence'), getActionPoint('bob_corvo_creek_bridge'),,true)
		.addAction(getAction('high_sitting_determined'), getActionPoint('bob_corvo_inside_bench'),,true)
		.addAction(getAction('man_sharpening_sword'), getActionPoint('bob_corvo_man_sitting_sharpening_sword'),,true)
		.addAction(getAction('man_sitting_ground_leaning_back_bored'), getActionPoint('bob_corvo_man_sitting_under_the_tree'),,true)
		.addAction(getAction('man_work_sword_sharpening'), getActionPoint('bob_corvo_man_standing_sharpening_sword'),,true)
		.addAction(getAction('work_training_sword'), getActionPoint('bob_corvo_man_training_sword'),,true)
		.addAction(getAction('man_work_drinking'), getActionPoint('bob_corvo_man_work_drinking'),,true)
		.addAction(getAction('man_work_stand_wall'), getActionPoint('bob_corvo_man_work_stand_wall'),,true)
		.addAction(getAction('low_sitting_happy'), getActionPoint('bob_corvo_outside_deckchair_2'),,true)
		.addAction(getAction('high_standing_leaning_back2_determined'), getActionPoint('bob_corvo_wine_barrels_1'),,true)
		.addAction(getAction('high_standing_leaning_back2_determined'), getActionPoint('bob_corvo_wine_barrels_2'),,true);

        newJob('bob_corvo_male_guest_misc_2')
		.addAction(getAction('man_leaning_on_fence'), getActionPoint('bob_corvo_creek_bridge'),,true)
		.addAction(getAction('high_sitting_determined'), getActionPoint('bob_corvo_inside_bench'),,true)
		.addAction(getAction('man_sitting_ground_leaning_back_bored'), getActionPoint('bob_corvo_man_sitting_under_the_tree'),,true)
		.addAction(getAction('man_work_sword_sharpening'), getActionPoint('bob_corvo_man_standing_sharpening_sword'),,true)
		.addAction(getAction('work_training_sword'), getActionPoint('bob_corvo_man_training_sword'),,true)
		.addAction(getAction('man_work_drinking'), getActionPoint('bob_corvo_man_work_drinking'),,true)
		.addAction(getAction('man_work_stand_wall'), getActionPoint('bob_corvo_man_work_stand_wall'),,true)
		.addAction(getAction('low_sitting_happy'), getActionPoint('bob_corvo_outside_deckchair_2'),,true)
		.addAction(getAction('high_standing_leaning_back2_determined'), getActionPoint('bob_corvo_wine_barrels_1'),,true)
		.addAction(getAction('high_standing_leaning_back2_determined'), getActionPoint('bob_corvo_wine_barrels_2'),,true)
		.addAction(getAction('man_work_standing_reading_noticeboard'), getActionPoint('bob_corvo_wine_cellar_2'),,true);

        newJob('bob_corvo_male_guest_misc_3')
		.addAction(getAction('man_leaning_on_fence'), getActionPoint('bob_corvo_creek_bridge'),,true)
		.addAction(getAction('man_sitting_ground_leaning_back_bored'), getActionPoint('bob_corvo_man_sitting_under_the_tree'),,true)
		.addAction(getAction('man_work_sword_sharpening'), getActionPoint('bob_corvo_man_standing_sharpening_sword'),,true)
		.addAction(getAction('work_training_sword'), getActionPoint('bob_corvo_man_training_sword'),,true)
		.addAction(getAction('man_work_drinking'), getActionPoint('bob_corvo_man_work_drinking'),,true)
		.addAction(getAction('man_work_stand_wall'), getActionPoint('bob_corvo_man_work_stand_wall'),,true)
		.addAction(getAction('low_sitting_happy'), getActionPoint('bob_corvo_outside_deckchair_2'),,true)
		.addAction(getAction('high_standing_leaning_back2_determined'), getActionPoint('bob_corvo_wine_barrels_1'),,true)
		.addAction(getAction('high_standing_leaning_back2_determined'), getActionPoint('bob_corvo_wine_barrels_2'),,true);

        newJob('bob_corvo_male_guest_misc_4')
		.addAction(getAction('high_sitting_determined'), getActionPoint('bob_corvo_inside_bench'),,true)
		.addAction(getAction('man_sitting_ground_leaning_back_bored'), getActionPoint('bob_corvo_man_sitting_under_the_tree'),,true)
		.addAction(getAction('man_work_sword_sharpening'), getActionPoint('bob_corvo_man_standing_sharpening_sword'),,true)
		.addAction(getAction('man_stand_tasting_wine'), getActionPoint('bob_corvo_man_stand_tasting_wine_2'),,true)
		.addAction(getAction('work_training_sword'), getActionPoint('bob_corvo_man_training_sword'),,true)
		.addAction(getAction('high_standing_leaning_back2_determined'), getActionPoint('bob_corvo_wine_barrels_2'),,true);

        newJob('bob_corvo_male_guest_misc_5')
		.addAction(getAction('man_leaning_on_fence'), getActionPoint('bob_corvo_creek_bridge'),,true)
		.addAction(getAction('man_work_stand_wall'), getActionPoint('bob_corvo_man_work_stand_wall'),,true)
		.addAction(getAction('high_standing_leaning_back2_determined'), getActionPoint('bob_corvo_wine_barrels_1'),,true);

	newJob('bob_corvo_male_guest_sleep')
		.addAction(getAction('man_work_sleep_ground'), getActionPoint('bob_corvo_male_guest_sleep'),,true);

        newJob('bob_corvo_master_bedroom_sleep')
		.addAction(getAction('woman_sleep_on_bed_rf'), getActionPoint('bob_corvo_down_sleep_1_rf'),,true);

        newJob('bob_corvo_men_misc_1')
		.addAction(getAction('man_leaning_on_fence'), getActionPoint('bob_corvo_creek_bridge'),,true)
		.addAction(getAction('high_sitting_determined'), getActionPoint('bob_corvo_inside_bench'),,true)
		.addAction(getAction('man_work_meditation'), getActionPoint('bob_corvo_man_meditation'),,true)
		.addAction(getAction('man_sharpening_sword'), getActionPoint('bob_corvo_man_sitting_sharpening_sword'),,true)
		.addAction(getAction('man_sitting_ground_leaning_back_bored'), getActionPoint('bob_corvo_man_sitting_under_the_tree'),,true)
		.addAction(getAction('man_work_sword_sharpening'), getActionPoint('bob_corvo_man_standing_sharpening_sword'),,true)
		.addAction(getAction('work_training_sword'), getActionPoint('bob_corvo_man_training_sword'),,true)
		.addAction(getAction('man_work_drinking'), getActionPoint('bob_corvo_man_work_drinking'),,true)
		.addAction(getAction('man_work_stand_wall'), getActionPoint('bob_corvo_man_work_stand_wall'),,true)
		.addAction(getAction('low_sitting_happy'), getActionPoint('bob_corvo_outside_deckchair_2'),,true)
		.addAction(getAction('high_standing_leaning_back2_determined'), getActionPoint('bob_corvo_wine_barrels_1'),,true)
		.addAction(getAction('high_standing_leaning_back2_determined'), getActionPoint('bob_corvo_wine_barrels_2'),,true);

        newJob('bob_corvo_men_misc_2')
		.addAction(getAction('man_leaning_on_fence'), getActionPoint('bob_corvo_creek_bridge'),,true)
		.addAction(getAction('high_sitting_determined'), getActionPoint('bob_corvo_inside_bench'),,true)
		.addAction(getAction('man_work_meditation'), getActionPoint('bob_corvo_man_meditation'),,true)
		.addAction(getAction('man_sitting_ground_leaning_back_bored'), getActionPoint('bob_corvo_man_sitting_under_the_tree'),,true)
		.addAction(getAction('man_work_sword_sharpening'), getActionPoint('bob_corvo_man_standing_sharpening_sword'),,true)
		.addAction(getAction('work_training_sword'), getActionPoint('bob_corvo_man_training_sword'),,true)
		.addAction(getAction('man_work_drinking'), getActionPoint('bob_corvo_man_work_drinking'),,true)
		.addAction(getAction('man_work_stand_wall'), getActionPoint('bob_corvo_man_work_stand_wall'),,true)
		.addAction(getAction('low_sitting_happy'), getActionPoint('bob_corvo_outside_deckchair_2'),,true)
		.addAction(getAction('high_standing_leaning_back2_determined'), getActionPoint('bob_corvo_wine_barrels_1'),,true)
		.addAction(getAction('high_standing_leaning_back2_determined'), getActionPoint('bob_corvo_wine_barrels_2'),,true)
		.addAction(getAction('man_work_standing_reading_noticeboard'), getActionPoint('bob_corvo_wine_cellar_2'),,true);

        newJob('bob_corvo_men_misc_3')
		.addAction(getAction('man_leaning_on_fence'), getActionPoint('bob_corvo_creek_bridge'),,true)
		.addAction(getAction('man_work_meditation'), getActionPoint('bob_corvo_man_meditation'),,true)
		.addAction(getAction('man_sitting_ground_leaning_back_bored'), getActionPoint('bob_corvo_man_sitting_under_the_tree'),,true)
		.addAction(getAction('man_work_sword_sharpening'), getActionPoint('bob_corvo_man_standing_sharpening_sword'),,true)
		.addAction(getAction('work_training_sword'), getActionPoint('bob_corvo_man_training_sword'),,true)
		.addAction(getAction('man_work_drinking'), getActionPoint('bob_corvo_man_work_drinking'),,true)
		.addAction(getAction('man_work_stand_wall'), getActionPoint('bob_corvo_man_work_stand_wall'),,true)
		.addAction(getAction('low_sitting_happy'), getActionPoint('bob_corvo_outside_deckchair_2'),,true)
		.addAction(getAction('high_standing_leaning_back2_determined'), getActionPoint('bob_corvo_wine_barrels_1'),,true)
		.addAction(getAction('high_standing_leaning_back2_determined'), getActionPoint('bob_corvo_wine_barrels_2'),,true);

        newJob('bob_corvo_men_misc_4')
		.addAction(getAction('man_leaning_on_fence'), getActionPoint('bob_corvo_creek_bridge'),,true)
		.addAction(getAction('playing_cards'), getActionPoint('bob_corvo_gwent_2'),,true)
		.addAction(getAction('man_work_stand_wall'), getActionPoint('bob_corvo_man_work_stand_wall'),,true)
		.addAction(getAction('man_work_sitting_chair_reading_book'), getActionPoint('bob_corvo_outside_bench_2'),,true)
		.addAction(getAction('low_sitting_happy'), getActionPoint('bob_corvo_outside_deckchair_2'),,true)
		.addAction(getAction('high_standing_leaning_back2_determined'), getActionPoint('bob_corvo_wine_barrels_1'),,true);

        newJob('bob_corvo_men_misc_5')
		.addAction(getAction('man_leaning_on_fence'), getActionPoint('bob_corvo_creek_bridge'),,true)
		.addAction(getAction('high_sitting_determined'), getActionPoint('bob_corvo_inside_bench'),,true)
		.addAction(getAction('man_work_stand_wall'), getActionPoint('bob_corvo_man_work_stand_wall'),,true)
		.addAction(getAction('low_sitting_happy'), getActionPoint('bob_corvo_outside_deckchair_2'),,true)
		.addAction(getAction('high_standing_leaning_back2_determined'), getActionPoint('bob_corvo_wine_barrels_1'),,true);

        newJob('bob_corvo_men_misc_6')
		.addAction(getAction('man_leaning_on_fence'), getActionPoint('bob_corvo_creek_bridge'),,true)
		.addAction(getAction('man_work_meditation'), getActionPoint('bob_corvo_man_meditation'),,true)
		.addAction(getAction('man_work_stand_wall'), getActionPoint('bob_corvo_man_work_stand_wall'),,true);

	newJob('bob_corvo_outside_bench_2')
		.addAction(getAction('man_work_sitting_chair_reading_book'), getActionPoint('bob_corvo_outside_bench_2'),,true);

	newJob('bob_corvo_outside_deckchair_2')
		.addAction(getAction('low_sitting_happy'), getActionPoint('bob_corvo_outside_deckchair_2'),,true);

	newJob('bob_corvo_priscilla_sleep')
		.addAction(getAction('woman_sleep_on_bed_rf'), getActionPoint('bob_corvo_priscilla_sleep'),,true);

        newJob('bob_corvo_stable')
		.addAction(getAction('high_standing_bored'), getActionPoint('bob_corvo_stable'),,true);

        newJob('bob_corvo_women_misc_1')
		.addAction(getAction('high_standing_leaning_back_determined'), getActionPoint('bob_corvo_creek'),,true)
		.addAction(getAction('high_sitting_determined'), getActionPoint('bob_corvo_dining_chair_1'),,true)
		.addAction(getAction('woman_work_sit_chair_crosshands'), getActionPoint('bob_corvo_dining_chair_2'),,true)
		.addAction(getAction('woman_lying_on_a_deckchair'), getActionPoint('bob_corvo_dining_deckchair'),,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('bob_corvo_guestroom_chair'),,true)
		.addAction(getAction('woman_lying_on_a_deckchair'), getActionPoint('bob_corvo_guestroom_deckchair'),,true)
		.addAction(getAction('high_standing_bored'), getActionPoint('bob_corvo_kitchen'),,true)
		.addAction(getAction('woman_work_sit_brushing_hair'), getActionPoint('bob_corvo_master_bedroom_chair'),,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('bob_corvo_outside_bench_1'),,true)
		.addAction(getAction('woman_lying_on_a_deckchair'), getActionPoint('bob_corvo_outside_deckchair_1'),,true)
		.addAction(getAction('woman_looking_around'), getActionPoint('bob_corvo_woman_looking_around'),,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_3'), getActionPoint('bob_corvo_woman_looking_at_weapon_rack'),200,true)
		.addAction(getAction('woman_work_stand_looking_in_the_mirror'), getActionPoint('bob_corvo_woman_looking_in_the_mirror'),,true)
		.addAction(getAction('woman_lying_relaxed_on_grass'), getActionPoint('bob_corvo_woman_lying_relaxed_on_grass'),,true)
		.addAction(getAction('woman_wine_tasting'), getActionPoint('bob_corvo_woman_wine_tasting_1'),,true)
		.addAction(getAction('woman_wine_tasting'), getActionPoint('bob_corvo_woman_wine_tasting_2'),,true);

        newJob('bob_corvo_women_misc_2')
		.addAction(getAction('high_standing_leaning_back_determined'), getActionPoint('bob_corvo_creek'),,true)
		.addAction(getAction('high_sitting_determined'), getActionPoint('bob_corvo_dining_chair_1'),,true)
		.addAction(getAction('woman_work_sit_chair_crosshands'), getActionPoint('bob_corvo_dining_chair_2'),,true)
		.addAction(getAction('woman_lying_on_a_deckchair'), getActionPoint('bob_corvo_dining_deckchair'),,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('bob_corvo_guestroom_chair'),,true)
		.addAction(getAction('woman_lying_on_a_deckchair'), getActionPoint('bob_corvo_guestroom_deckchair'),,true)
		.addAction(getAction('high_standing_bored'), getActionPoint('bob_corvo_kitchen'),,true)
		.addAction(getAction('woman_work_sit_brushing_hair'), getActionPoint('bob_corvo_master_bedroom_chair'),,true)
		.addAction(getAction('woman_lying_on_a_deckchair'), getActionPoint('bob_corvo_outside_deckchair_1'),,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_2'), getActionPoint('bob_corvo_wine_cellar_1'),,true)
		.addAction(getAction('woman_looking_around'), getActionPoint('bob_corvo_woman_looking_around'),,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_3'), getActionPoint('bob_corvo_woman_looking_at_weapon_rack'),200,true)
		.addAction(getAction('woman_work_stand_looking_in_the_mirror'), getActionPoint('bob_corvo_woman_looking_in_the_mirror'),,true)
		.addAction(getAction('woman_lying_relaxed_on_grass'), getActionPoint('bob_corvo_woman_lying_relaxed_on_grass'),,true)
		.addAction(getAction('woman_wine_tasting'), getActionPoint('bob_corvo_woman_wine_tasting_1'),,true)
		.addAction(getAction('woman_wine_tasting'), getActionPoint('bob_corvo_woman_wine_tasting_2'),,true);

        newJob('bob_corvo_women_misc_3')
		.addAction(getAction('high_standing_leaning_back_determined'), getActionPoint('bob_corvo_creek'),,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('bob_corvo_guestroom_chair'),,true)
		.addAction(getAction('high_standing_bored'), getActionPoint('bob_corvo_kitchen'),,true)
		.addAction(getAction('woman_work_sit_brushing_hair'), getActionPoint('bob_corvo_master_bedroom_chair'),,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('bob_corvo_outside_bench_1'),,true)
		.addAction(getAction('woman_lying_on_a_deckchair'), getActionPoint('bob_corvo_outside_deckchair_1'),,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_2'), getActionPoint('bob_corvo_wine_cellar_1'),,true)
		.addAction(getAction('woman_looking_around'), getActionPoint('bob_corvo_woman_looking_around'),,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_3'), getActionPoint('bob_corvo_woman_looking_at_weapon_rack'),200,true)
		.addAction(getAction('woman_work_stand_looking_in_the_mirror'), getActionPoint('bob_corvo_woman_looking_in_the_mirror'),,true)
		.addAction(getAction('woman_lying_relaxed_on_grass'), getActionPoint('bob_corvo_woman_lying_relaxed_on_grass'),,true)
		.addAction(getAction('woman_wine_tasting'), getActionPoint('bob_corvo_woman_wine_tasting_1'),,true)
		.addAction(getAction('woman_wine_tasting'), getActionPoint('bob_corvo_woman_wine_tasting_2'),,true);

        newJob('bob_corvo_women_misc_4')
		.addAction(getAction('high_sitting_determined'), getActionPoint('bob_corvo_dining_chair_1'),,true)
		.addAction(getAction('woman_work_sit_chair_crosshands'), getActionPoint('bob_corvo_dining_chair_2'),,true)
		.addAction(getAction('woman_lying_on_a_deckchair'), getActionPoint('bob_corvo_dining_deckchair'),,true)
		.addAction(getAction('woman_lying_on_a_deckchair'), getActionPoint('bob_corvo_guestroom_deckchair'),,true)
		.addAction(getAction('woman_work_sit_brushing_hair'), getActionPoint('bob_corvo_guestroom_woman_brushing_hair'),,true);

        newJob('bob_corvo_women_misc_5')
		.addAction(getAction('woman_lying_on_a_deckchair'), getActionPoint('bob_corvo_outside_deckchair_1'),,true)
		.addAction(getAction('woman_lying_relaxed_on_grass'), getActionPoint('bob_corvo_woman_lying_relaxed_on_grass'),,true);

        newJob('bob_corvo_women_other_misc_1')
		.addAction(getAction('high_sitting_determined'), getActionPoint('bob_corvo_dining_chair_1'),,true)
		.addAction(getAction('woman_lying_on_a_deckchair'), getActionPoint('bob_corvo_dining_deckchair'),,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('bob_corvo_guestroom_chair'),,true)
		.addAction(getAction('woman_lying_on_a_deckchair'), getActionPoint('bob_corvo_guestroom_deckchair'),,true)
		.addAction(getAction('high_standing_bored'), getActionPoint('bob_corvo_kitchen'),,true)
		.addAction(getAction('woman_work_sit_brushing_hair'), getActionPoint('bob_corvo_master_bedroom_chair'),,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('bob_corvo_outside_bench_1'),,true)
		.addAction(getAction('woman_lying_on_a_deckchair'), getActionPoint('bob_corvo_outside_deckchair_1'),,true)
		.addAction(getAction('woman_looking_around'), getActionPoint('bob_corvo_woman_looking_around'),,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_3'), getActionPoint('bob_corvo_woman_looking_at_weapon_rack'),200,true)
		.addAction(getAction('woman_work_stand_looking_in_the_mirror'), getActionPoint('bob_corvo_woman_looking_in_the_mirror'),,true)
		.addAction(getAction('woman_lying_relaxed_on_grass'), getActionPoint('bob_corvo_woman_lying_relaxed_on_grass'),,true)
		.addAction(getAction('woman_wine_tasting'), getActionPoint('bob_corvo_woman_wine_tasting_1'),,true)
		.addAction(getAction('woman_wine_tasting'), getActionPoint('bob_corvo_woman_wine_tasting_2'),,true);

        newJob('bob_corvo_women_other_misc_2')
		.addAction(getAction('high_sitting_determined'), getActionPoint('bob_corvo_dining_chair_1'),,true)
		.addAction(getAction('woman_lying_on_a_deckchair'), getActionPoint('bob_corvo_dining_deckchair'),,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('bob_corvo_guestroom_chair'),,true)
		.addAction(getAction('woman_lying_on_a_deckchair'), getActionPoint('bob_corvo_guestroom_deckchair'),,true)
		.addAction(getAction('high_standing_bored'), getActionPoint('bob_corvo_kitchen'),,true)
		.addAction(getAction('woman_work_sit_brushing_hair'), getActionPoint('bob_corvo_master_bedroom_chair'),,true)
		.addAction(getAction('woman_lying_on_a_deckchair'), getActionPoint('bob_corvo_outside_deckchair_1'),,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_2'), getActionPoint('bob_corvo_wine_cellar_1'),,true)
		.addAction(getAction('woman_looking_around'), getActionPoint('bob_corvo_woman_looking_around'),,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_3'), getActionPoint('bob_corvo_woman_looking_at_weapon_rack'),200,true)
		.addAction(getAction('woman_work_stand_looking_in_the_mirror'), getActionPoint('bob_corvo_woman_looking_in_the_mirror'),,true)
		.addAction(getAction('woman_lying_relaxed_on_grass'), getActionPoint('bob_corvo_woman_lying_relaxed_on_grass'),,true)
		.addAction(getAction('woman_wine_tasting'), getActionPoint('bob_corvo_woman_wine_tasting_1'),,true)
		.addAction(getAction('woman_wine_tasting'), getActionPoint('bob_corvo_woman_wine_tasting_2'),,true);

        newJob('bob_corvo_women_other_misc_3')
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('bob_corvo_guestroom_chair'),,true)
		.addAction(getAction('high_standing_bored'), getActionPoint('bob_corvo_kitchen'),,true)
		.addAction(getAction('woman_work_sit_brushing_hair'), getActionPoint('bob_corvo_master_bedroom_chair'),,true)
		.addAction(getAction('woman_work_sitting_reading_book'), getActionPoint('bob_corvo_outside_bench_1'),,true)
		.addAction(getAction('woman_lying_on_a_deckchair'), getActionPoint('bob_corvo_outside_deckchair_1'),,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_2'), getActionPoint('bob_corvo_wine_cellar_1'),,true)
		.addAction(getAction('woman_looking_around'), getActionPoint('bob_corvo_woman_looking_around'),,true)
		.addAction(getAction('woman_work_stand_looking_at_goods_3'), getActionPoint('bob_corvo_woman_looking_at_weapon_rack'),200,true)
		.addAction(getAction('woman_work_stand_looking_in_the_mirror'), getActionPoint('bob_corvo_woman_looking_in_the_mirror'),,true)
		.addAction(getAction('woman_lying_relaxed_on_grass'), getActionPoint('bob_corvo_woman_lying_relaxed_on_grass'),,true)
		.addAction(getAction('woman_wine_tasting'), getActionPoint('bob_corvo_woman_wine_tasting_1'),,true)
		.addAction(getAction('woman_wine_tasting'), getActionPoint('bob_corvo_woman_wine_tasting_2'),,true);

        newJob('bob_corvo_women_other_misc_4')
		.addAction(getAction('high_sitting_determined'), getActionPoint('bob_corvo_dining_chair_1'),,true)
		.addAction(getAction('woman_lying_on_a_deckchair'), getActionPoint('bob_corvo_dining_deckchair'),,true)
		.addAction(getAction('woman_lying_on_a_deckchair'), getActionPoint('bob_corvo_guestroom_deckchair'),,true)
		.addAction(getAction('woman_work_sit_brushing_hair'), getActionPoint('bob_corvo_guestroom_woman_brushing_hair'),,true);

        newJob('bob_corvo_women_sleep_1')
		.addAction(getAction('woman_sleep_on_bed_rf'), getActionPoint('bob_corvo_down_sleep_1_rf'),,true)
		.addAction(getAction('woman_sleep_on_bed_lf'), getActionPoint('bob_corvo_down_sleep_1_lf'),,true)
		.addAction(getAction('woman_sleep_on_bed_rf'), getActionPoint('bob_corvo_up_sleep_1_rf'),,true)
		.addAction(getAction('woman_sleep_on_bed_lf'), getActionPoint('bob_corvo_up_sleep_1_lf'),,true);

        newJob('bob_corvo_women_sleep_2')
		.addAction(getAction('woman_sleep_on_bed_lf'), getActionPoint('bob_corvo_down_sleep_1_lf'),,true)
		.addAction(getAction('woman_sleep_on_bed_rf'), getActionPoint('bob_corvo_up_sleep_1_rf'),,true)
		.addAction(getAction('woman_sleep_on_bed_lf'), getActionPoint('bob_corvo_up_sleep_1_lf'),,true);

        newJob('bob_corvo_women_sleep_3')
		.addAction(getAction('woman_sleep_on_bed_rf'), getActionPoint('bob_corvo_down_sleep_1_rf'),,true)
		.addAction(getAction('woman_sleep_on_bed_lf'), getActionPoint('bob_corvo_down_sleep_1_lf'),,true)
		.addAction(getAction('woman_sleep_on_bed_rf'), getActionPoint('bob_corvo_up_sleep_1_rf'),,true);

        newJob('bob_corvo_women_sleep_4')
		.addAction(getAction('woman_sleep_on_bed_lf'), getActionPoint('bob_corvo_down_sleep_1_lf'),,true)
		.addAction(getAction('woman_sleep_on_bed_rf'), getActionPoint('bob_corvo_up_sleep_1_rf'),,true);

	newJob('bob_corvo_zoltan_gwent')
		.addAction(getAction('playing_cards'), getActionPoint('bob_corvo_gwent_1'),,true);
	newJob('bob_corvo_zoltan_sitting_outside_on_bench')
		.addAction(getAction('high_sitting_determined'), getActionPoint('bob_corvo_zoltan_sitting_outside_on_bench'),,true);
	newJob('bob_corvo_zoltan_sleep')
		.addAction(getAction('man_work_sleep_bed_right'), getActionPoint('bob_corvo_zoltan_sleep'),,true);
	newJob('bob_corvo_zoltan_standing_inside')
		.addAction(getAction('dwarf_work_standing_hands_crossed'), getActionPoint('bob_corvo_zoltan_standing_inside'),,true);

	newJob('bob_corvo_zoltan_misc_1')
		.addAction(getAction('man_work_playing_with_axe'), getActionPoint('bob_corvo_zoltan_in_the_workshop'),,true)
		.addAction(getAction('high_sitting_determined'), getActionPoint('bob_corvo_zoltan_sitting_outside_on_bench'),,true)
		.addAction(getAction('dwarf_work_standing_hands_crossed'), getActionPoint('bob_corvo_zoltan_standing_by_the_tree'),,true)
		.addAction(getAction('dwarf_work_standing_hands_crossed'), getActionPoint('bob_corvo_zoltan_standing_outside'),,true);

	newJob('bob_corvo_zoltan_misc_2')
		.addAction(getAction('man_work_playing_with_axe'), getActionPoint('bob_corvo_zoltan_in_the_workshop'),,true)
		.addAction(getAction('dwarf_work_standing_hands_crossed'), getActionPoint('bob_corvo_zoltan_standing_by_the_tree'),,true)
		.addAction(getAction('dwarf_work_standing_hands_crossed'), getActionPoint('bob_corvo_zoltan_standing_outside'),,true);

        newJob('bob_lady_of_the_lake')
		.addAction(getAction('low_sitting_ground_happy'), getActionPoint('bob_lady_of_the_lake'),,true);

        newJob('bob_sorceress')
		.addAction(getAction('high_standing_bored'), getActionPoint('bob_sorceress_1'),,true)
		.addAction(getAction('high_standing_bored'), getActionPoint('bob_sorceress_2'),,true)
		.addAction(getAction('high_standing_bored'), getActionPoint('bob_sorceress_3'),,true);
    }

    private function InitSchedules_TOUSSAINT()
    {
	newSchedule('anarietta_1')
		.addJob(getJob('bob_beauclair_anarietta'), 3600*22, 3600*12) //10PM to 12PM
		.addJob(getJob('bob_beauclair_anarietta_gardens'), 3600*12, 3600*17) //12PM to 5PM
		.addJob(getJob('bob_beauclair_anarietta'), 3600*17, 3600*22) //5PM to 10PM
		.land(11);

	newSchedule('anarietta_2')
		.addJob(getJob('bob_beauclair_anarietta'), 3600*22, 3600*11) //10PM to 11AM
		.addJob(getJob('bob_corvo_anarietta_misc_2'), 3600*11, 3600*13) //11AM to 1PM
		.addJob(getJob('bob_corvo_anarietta_misc_2'), 3600*13, 3600*15) //1PM to 3PM
		.addJob(getJob('bob_corvo_anarietta_misc_1'), 3600*15, 3600*17) //3PM to 5PM
		.addJob(getJob('bob_beauclair_anarietta'), 3600*17, 3600*22) //5PM to 10PM
		.land(11);

	newSchedule('blacksmith')
		.addJob(getJob('bob_belgaard_blacksmith'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_belgaard_blacksmith'), 3600*8, 3600*22) //8AM to 10PM
		.land(11);

	newSchedule('ciri')
		.addJob(getJob('bob_corvo_women_sleep_1'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_corvo_ciri_sitting_under_the_tree'), 3600*8, 3600*11) //8AM to 11AM
		.addJob(getJob('bob_corvo_bathing_2'), 3600*11, 3600*13) //11AM to 1PM
		.addJob(getJob('bob_corvo_greenhouse'), 3600*13, 3600*15) //1PM to 3PM
		.addJob(getJob('bob_corvo_ciri_misc_2'), 3600*15, 3600*17) //3PM to 5PM
		.addJob(getJob('bob_corvo_ciri_misc_1'), 3600*17, 3600*19) //5PM to 7PM
		.addJob(getJob('bob_corvo_ciri_lying_relaxed'), 3600*19, 3600*22) //7PM to 10PM
		.land(11);

	newSchedule('damien_1')
		.addJob(getJob('bob_beauclair_damien'), 3600*22, 3600*12) //10PM to 12PM
		.addJob(getJob('bob_beauclair_damien_gardens'), 3600*12, 3600*17) //12PM to 5PM
		.addJob(getJob('bob_beauclair_damien'), 3600*17, 3600*22) //5PM to 10PM
		.land(11);

	newSchedule('damien_2')
		.addJob(getJob('bob_beauclair_damien'), 3600*22, 3600*11) //10PM to 11AM
		.addJob(getJob('bob_corvo_male_guest_misc_1'), 3600*11, 3600*13) //11AM to 1PM
		.addJob(getJob('bob_corvo_male_guest_misc_4'), 3600*13, 3600*15) //1PM to 3PM
		.addJob(getJob('bob_corvo_male_guest_misc_2'), 3600*15, 3600*17) //3PM to 5PM
		.addJob(getJob('bob_beauclair_damien'), 3600*17, 3600*22) //5PM to 10PM
		.land(11);

	newSchedule('dandelion_1')
		.addJob(getJob('bob_corvo_dandelion_sleep_1'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_corvo_dandelion_playing_lute'), 3600*8, 3600*11) //8AM to 11AM
		.addJob(getJob('bob_corvo_dandelion_sitting_legs_hanging'), 3600*11, 3600*13) //11AM to 1PM
		.addJob(getJob('bob_corvo_men_misc_4'), 3600*13, 3600*15) //1PM to 3PM
		.addJob(getJob('bob_corvo_dandelion_misc_1'), 3600*15, 3600*17) //3PM to 5PM
		.addJob(getJob('bob_corvo_dandelion_misc_2'), 3600*17, 3600*19) //5PM to 7PM
		.addJob(getJob('bob_corvo_dandelion_sitting_relaxed'), 3600*19, 3600*22) //7PM to 10PM
		.land(11);

	newSchedule('dandelion_2')
		.addJob(getJob('bob_corvo_dandelion_sleep_2'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_corvo_dandelion_playing_lute'), 3600*8, 3600*11) //8AM to 11AM
		.addJob(getJob('bob_corvo_dandelion_sitting_legs_hanging'), 3600*11, 3600*13) //11AM to 1PM
		.addJob(getJob('bob_corvo_men_misc_4'), 3600*13, 3600*15) //1PM to 3PM
		.addJob(getJob('bob_corvo_dandelion_misc_1'), 3600*15, 3600*17) //3PM to 5PM
		.addJob(getJob('bob_corvo_dandelion_misc_2'), 3600*17, 3600*19) //5PM to 7PM
		.addJob(getJob('bob_corvo_dandelion_sitting_relaxed'), 3600*19, 3600*22) //7PM to 10PM
		.land(11);

	newSchedule('dettlaff_1')
		.addJob(getJob('bob_beauclair_dettlaff'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_beauclair_dettlaff'), 3600*8, 3600*22) //8AM to 10PM
		.land(11);

	newSchedule('dettlaff_2')
		.addJob(getJob('bob_corvo_dettlaff_sitting_legs_hanging'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_corvo_outside_deckchair_2'), 3600*8, 3600*11) //8AM to 11AM
		.addJob(getJob('bob_corvo_dettlaff_misc_3'), 3600*11, 3600*13) //11AM to 1PM
		.addJob(getJob('bob_corvo_dettlaff_misc_4'), 3600*13, 3600*15) //1PM to 3PM
		.addJob(getJob('bob_corvo_dettlaff_misc_1'), 3600*15, 3600*17) //3PM to 5PM
		.addJob(getJob('bob_corvo_dettlaff_misc_2'), 3600*17, 3600*19) //5PM to 7PM
		.addJob(getJob('bob_corvo_outside_bench_2'), 3600*19, 3600*22) //7PM to 10PM
		.land(11);

	newSchedule('eskel')
		.addJob(getJob('bob_corvo_eskel_sleep'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_corvo_men_misc_6'), 3600*8, 3600*11) //8AM to 11AM
		.addJob(getJob('bob_corvo_men_misc_1'), 3600*11, 3600*13) //11AM to 1PM
		.addJob(getJob('bob_corvo_men_misc_4'), 3600*13, 3600*15) //1PM to 3PM
		.addJob(getJob('bob_corvo_men_misc_2'), 3600*15, 3600*17) //3PM to 5PM
		.addJob(getJob('bob_corvo_men_misc_3'), 3600*17, 3600*19) //5PM to 7PM
		.addJob(getJob('bob_corvo_men_misc_5'), 3600*19, 3600*22) //7PM to 10PM
		.land(11);

	newSchedule('gregoire')
		.addJob(getJob('bob_beauclair_gregoire'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_beauclair_gregoire'), 3600*8, 3600*22) //8AM to 10PM
		.land(11);

	newSchedule('guillaume')
		.addJob(getJob('bob_beauclair_guillaume'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_beauclair_guillaume'), 3600*8, 3600*22) //8AM to 10PM
		.land(11);

	newSchedule('hattori')
		.addJob(getJob('bob_corvo_hattori_sleep'), 3600*22, 3600*5) //10PM to 5AM
		.addJob(getJob('bob_corvo_hattori_in_the_workshop'), 3600*5, 3600*22) //5AM to 10PM
		.land(11);

	newSchedule('keira')
		.addJob(getJob('bob_corvo_guesthouse_sleep_2'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_corvo_bathing_1'), 3600*8, 1800*21) //8AM to 10:30AM
		.addJob(getJob('bob_corvo_women_misc_2'), 1800*21, 3600*13) //10:30AM to 1PM
		.addJob(getJob('bob_corvo_greenhouse'), 3600*13, 3600*15) //1PM to 3PM
		.addJob(getJob('bob_corvo_women_misc_1'), 3600*15, 3600*17) //3PM to 5PM
		.addJob(getJob('bob_corvo_women_misc_3'), 3600*17, 3600*19) //5PM to 7PM
		.addJob(getJob('bob_corvo_women_misc_4'), 3600*19, 3600*22) //7PM to 10PM
		.land(11);

	newSchedule('lambert')
		.addJob(getJob('bob_corvo_guesthouse_sleep_1'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_corvo_men_misc_6'), 3600*8, 3600*11) //8AM to 11AM
		.addJob(getJob('bob_corvo_men_misc_1'), 3600*11, 3600*13) //11AM to 1PM
		.addJob(getJob('bob_corvo_men_misc_4'), 3600*13, 3600*15) //1PM to 3PM
		.addJob(getJob('bob_corvo_men_misc_2'), 3600*15, 3600*17) //3PM to 5PM
		.addJob(getJob('bob_corvo_men_misc_3'), 3600*17, 3600*19) //5PM to 7PM
		.addJob(getJob('bob_corvo_men_misc_5'), 3600*19, 3600*22) //7PM to 10PM
		.land(11);

	newSchedule('letho')
		.addJob(getJob('bob_corvo_male_guest_sleep'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_corvo_men_misc_6'), 3600*8, 3600*11) //8AM to 11AM
		.addJob(getJob('bob_corvo_men_misc_1'), 3600*11, 3600*13) //11AM to 1PM
		.addJob(getJob('bob_corvo_men_misc_4'), 3600*13, 3600*15) //1PM to 3PM
		.addJob(getJob('bob_corvo_men_misc_2'), 3600*15, 3600*17) //3PM to 5PM
		.addJob(getJob('bob_corvo_men_misc_3'), 3600*17, 3600*19) //5PM to 7PM
		.addJob(getJob('bob_corvo_men_misc_5'), 3600*19, 3600*22) //7PM to 10PM
		.land(11);

	newSchedule('majordomo')
		.addJob(getJob('bob_corvo_majordomo_sleep'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_corvo_majordomo_wine_cellar'), 3600*8, 3600*11) //8AM to 11AM
		.addJob(getJob('bob_corvo_majordomo_misc_1'), 3600*11, 3600*13) //11AM to 1PM
		.addJob(getJob('bob_corvo_men_misc_4'), 3600*13, 3600*15) //1PM to 3PM
		.addJob(getJob('bob_corvo_majordomo_misc_2'), 3600*15, 3600*17) //3PM to 5PM
		.addJob(getJob('bob_corvo_majordomo_misc_1'), 3600*17, 3600*19) //5PM to 7PM
		.addJob(getJob('bob_corvo_men_misc_5'), 3600*19, 3600*22) //7PM to 10PM
		.land(11);

	newSchedule('male_guest')
		.addJob(getJob('bob_corvo_male_guest_sleep'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_corvo_male_guest_misc_5'), 3600*8, 3600*11) //8AM to 11AM
		.addJob(getJob('bob_corvo_male_guest_misc_1'), 3600*11, 3600*13) //11AM to 1PM
		.addJob(getJob('bob_corvo_men_misc_4'), 3600*13, 3600*15) //1PM to 3PM
		.addJob(getJob('bob_corvo_male_guest_misc_2'), 3600*15, 3600*17) //3PM to 5PM
		.addJob(getJob('bob_corvo_male_guest_misc_3'), 3600*17, 3600*19) //5PM to 7PM
		.addJob(getJob('bob_corvo_men_misc_5'), 3600*19, 3600*22) //7PM to 10PM
		.land(11);

	newSchedule('nymph')
		.addJob(getJob('bob_lady_of_the_lake'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_lady_of_the_lake'), 3600*8, 3600*22) //8AM to 10PM
		.land(11);

	newSchedule('orianna')
		.addJob(getJob('bob_beauclair_orianna'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_beauclair_orianna'), 3600*8, 3600*22) //8AM to 10PM
		.land(11);

	newSchedule('palmerin')
		.addJob(getJob('bob_beauclair_palmerin'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_beauclair_palmerin'), 3600*8, 3600*22) //8AM to 10PM
		.land(11);

	newSchedule('priscilla')
		.addJob(getJob('bob_corvo_priscilla_sleep'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_corvo_women_misc_5'), 3600*8, 3600*11) //8AM to 11AM
		.addJob(getJob('bob_corvo_women_other_misc_2'), 3600*11, 3600*13) //11AM to 1PM
		.addJob(getJob('bob_corvo_women_other_misc_2'), 3600*13, 3600*15) //1PM to 3PM
		.addJob(getJob('bob_corvo_greenhouse'), 3600*15, 3600*17) //3PM to 5PM
		.addJob(getJob('bob_corvo_women_other_misc_3'), 3600*17, 3600*19) //5PM to 7PM
		.addJob(getJob('bob_corvo_women_other_misc_4'), 3600*19, 3600*22) //7PM to 10PM
		.land(11);

	newSchedule('regis')
		.addJob(getJob('bob_corvo_outside_bench_2'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_corvo_lab'), 3600*8, 1800*19) //8AM to 9:30AM
		.addJob(getJob('bob_corvo_greenhouse_picking_up_herbs'), 1800*19, 3600*11) //9:30AM to 11AM
		.addJob(getJob('bob_corvo_lab'), 3600*11, 3600*13) //11AM to 1PM
		.addJob(getJob('bob_corvo_men_misc_4'), 3600*13, 3600*15) //1PM to 3PM
		.addJob(getJob('bob_corvo_lab'), 3600*15, 3600*19) //3PM to 7PM
		.addJob(getJob('bob_corvo_men_misc_5'), 3600*19, 3600*22) //7PM to 10PM
		.land(11);

	newSchedule('shani')
		.addJob(getJob('bob_corvo_women_sleep_1'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_corvo_women_misc_5'), 3600*8, 3600*11) //8AM to 11AM
		.addJob(getJob('bob_corvo_bathing_2'), 3600*11, 3600*13) //11AM to 1PM
		.addJob(getJob('bob_corvo_women_other_misc_2'), 3600*13, 3600*15) //1PM to 3PM
		.addJob(getJob('bob_corvo_greenhouse'), 3600*15, 3600*17) //3PM to 5PM
		.addJob(getJob('bob_corvo_women_other_misc_3'), 3600*17, 3600*19) //5PM to 7PM
		.addJob(getJob('bob_corvo_women_other_misc_4'), 3600*19, 3600*22) //7PM to 10PM
		.land(11);

	newSchedule('sorceress')
		.addJob(getJob('bob_sorceress'), 3600*22, 3600*11) //10PM to 11AM
		.addJob(getJob('bob_corvo_women_other_misc_2'), 3600*11, 3600*13) //11AM to 1PM
		.addJob(getJob('bob_corvo_women_other_misc_2'), 3600*13, 3600*15) //1PM to 3PM
		.addJob(getJob('bob_corvo_women_other_misc_1'), 3600*15, 3600*17) //3PM to 5PM
		.addJob(getJob('bob_corvo_women_other_misc_3'), 3600*17, 3600*19) //5PM to 7PM
		.addJob(getJob('bob_sorceress'), 3600*19, 3600*22) //7PM to 10PM
		.land(11);

	newSchedule('syanna_1')
		.addJob(getJob('bob_beauclair_syanna'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_beauclair_syanna'), 3600*8, 3600*22) //8AM to 10PM
		.land(11);

	newSchedule('syanna_2')
		.addJob(getJob('bob_corvo_women_sleep_1'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_corvo_women_misc_5'), 3600*8, 3600*11) //8AM to 11AM
		.addJob(getJob('bob_corvo_bathing_2'), 3600*11, 3600*13) //11AM to 1PM
		.addJob(getJob('bob_corvo_women_misc_2'), 3600*13, 3600*15) //1PM to 3PM
		.addJob(getJob('bob_corvo_greenhouse'), 3600*15, 3600*17) //3PM to 5PM
		.addJob(getJob('bob_corvo_women_misc_3'), 3600*17, 3600*19) //5PM to 7PM
		.addJob(getJob('bob_corvo_women_misc_4'), 3600*19, 3600*22) //7PM to 10PM
		.land(11);

	newSchedule('syanna_3')
		.addJob(getJob('bob_corvo_women_sleep_1'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_corvo_bathing_1'), 3600*8, 1800*21) //8AM to 10:30AM
		.addJob(getJob('bob_corvo_greenhouse'), 1800*21, 3600*13) //10:30AM to 1PM
		.addJob(getJob('bob_corvo_women_misc_2'), 3600*13, 3600*15) //1PM to 3PM
		.addJob(getJob('bob_corvo_women_misc_1'), 3600*15, 3600*17) //3PM to 5PM
		.addJob(getJob('bob_corvo_women_misc_3'), 3600*17, 3600*19) //5PM to 7PM
		.addJob(getJob('bob_corvo_women_misc_4'), 3600*19, 3600*22) //7PM to 10PM
		.land(11);

	newSchedule('triss')
		.addJob(getJob('bob_corvo_women_sleep_1'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_corvo_bathing_1'), 3600*8, 1800*21) //8AM to 10:30AM
		.addJob(getJob('bob_corvo_greenhouse'), 1800*21, 3600*13) //10:30AM to 1PM
		.addJob(getJob('bob_corvo_women_other_misc_2'), 3600*13, 3600*15) //1PM to 3PM
		.addJob(getJob('bob_corvo_women_other_misc_1'), 3600*15, 3600*17) //3PM to 5PM
		.addJob(getJob('bob_corvo_women_other_misc_3'), 3600*17, 3600*19) //5PM to 7PM
		.addJob(getJob('bob_corvo_women_other_misc_4'), 3600*19, 3600*22) //7PM to 10PM
		.land(11);

	newSchedule('vivienne')
		.addJob(getJob('bob_beauclair_vivienne'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_beauclair_vivienne'), 3600*8, 3600*22) //8AM to 10PM
		.land(11);

	newSchedule('yennefer')
		.addJob(getJob('bob_corvo_women_sleep_1'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_corvo_bathing_1'), 3600*8, 1800*21) //8AM to 10:30AM
		.addJob(getJob('bob_corvo_greenhouse'), 1800*21, 3600*13) //10:30AM to 1PM
		.addJob(getJob('bob_corvo_women_misc_2'), 3600*13, 3600*15) //1PM to 3PM
		.addJob(getJob('bob_corvo_women_misc_1'), 3600*15, 3600*17) //3PM to 5PM
		.addJob(getJob('bob_corvo_women_misc_3'), 3600*17, 3600*19) //5PM to 7PM
		.addJob(getJob('bob_corvo_women_misc_4'), 3600*19, 3600*22) //7PM to 10PM
		.land(11);

	newSchedule('wolf')
		.addJob(getJob('bob_corvo_stable'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_corvo_stable'), 3600*8, 3600*22) //8AM to 10PM
		.land(11);

	newSchedule('zoltan')
		.addJob(getJob('bob_corvo_zoltan_sleep'), 3600*22, 3600*8) //10PM to 8AM
		.addJob(getJob('bob_corvo_zoltan_sitting_outside_on_bench'), 3600*8, 1800*21) //8AM to 10:30AM
		.addJob(getJob('bob_corvo_zoltan_misc_2'), 1800*21, 3600*13) //10:30AM to 1PM
		.addJob(getJob('bob_corvo_zoltan_gwent'), 3600*13, 3600*15) //1PM to 3PM
		.addJob(getJob('bob_corvo_zoltan_misc_1'), 3600*15, 3600*17) //3PM to 5PM
		.addJob(getJob('bob_corvo_zoltan_misc_1'), 3600*17, 3600*19) //5PM to 7PM
		.addJob(getJob('bob_corvo_zoltan_standing_inside'), 3600*19, 3600*22) //7PM to 10PM
		.land(11);
    }
}
