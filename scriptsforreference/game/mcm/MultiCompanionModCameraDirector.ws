/*
statemachine class MCM_CameraDirector {

    private var isInit : bool; default isInit = false;
    public function init() 
    {
        if(this.isInit) return;
        this.isInit = true;
        //Do something 
    }

    function Start() 
    {
        if(!this.IsInState('Running'))
        {
            this.GotoState('Running');
            // MCM_HideNPC(thePlayer);
        }
    }

    function Stop()
    {
        if(!this.IsInState('Idle'))
        {
            this.GotoState('Idle');
            // MCM_ShowNPC(thePlayer);
        }
    }
}

exec function StartFPMode() {
    MCM_GetMCM().CameraDirector.Start();
}

exec function StopFPMode() {
    MCM_GetMCM().CameraDirector.Stop();
}

state Idle in MCM_CameraDirector {

}

state Running in MCM_CameraDirector {

    public var doRun : bool;

    event OnEnterState( prevStateName : name )
	{
        doRun = true;
        loopForever();
	}

    event OnLeaveState( prevStateName : name )
    {
        doRun = false;
    }

    entry function loopForever()
    {
        var camera : CCustomCamera;
        while(this.doRun)
        {
            camera = theGame.GetGameCamera();
            // theGame.GetGameCamera().TeleportWithRotation(thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation());
            //import class CCamera extends CEntity
            // theCamera
            LogSCM("PivotPos: " + camera.GetActivePivotPositionController());
            LogSCM("PivotRot: " + camera.GetActivePivotRotationController());
            LogSCM("PivotDst: " + camera.GetActivePivotDistanceController());
            // [10/02/2018 12:39:19 PM]: [ModSpawnCompanions] PivotPos: CCustomCameraRopePPC
            // [10/02/2018 12:39:20 PM]: [ModSpawnCompanions] PivotRot: CCustomCameraDefaultPRC
            // [10/02/2018 12:39:20 PM]: [ModSpawnCompanions] PivotDst: CCustomCameraDefaultPDC
            Sleep(1);
        }
        parent.GotoState('Idle');
    }
}
*/
