
state MCM_RidingHorse in CNewNPC
{
    var horse : CNewNPC;
    var horseComp : W3HorseComponent;

    var saddle : CMeshComponent;
    var reins : CMeshComponent;
    var mount : CComponent;
    
    function getOrCreateHorse() : CNewNPC
    {
        var horse : CNewNPC = theGame.GetNPCByTag('mcm_horse_unused');
        if(!horse)
        {
            //TODO Make this Async
            horse = (CNewNPC)(theGame.CreateEntity(MCM_GetEntityTemplate('horse'), parent.GetWorldPosition()));
        }
        return horse;
    }

    event OnEnterState( prevStateName : name )
	{
        horse = getOrCreateHorse();
        horseComp = (W3HorseComponent)horse.GetComponentByClassName('W3HorseComponent');

        saddle = (CMeshComponent)horse.GetComponent('saddle');
        reins = (CMeshComponent)horse.GetComponent('reins');
        mount = horse.GetComponent("horseMount");

        LogSCM("horse: " + horse);
        LogSCM("horseComp: " + horseComp);

        LogSCM("saddle: " + saddle);
        LogSCM("reins: " + reins);
        LogSCM("mount: " + mount);

        //W3HorseComponent# import final function GetSlotTransform( slotName : name, out translation : Vector, out rotQuat : Vector );

      /*import function GetComponent( compName : string ) : CComponent;
        import function GetComponentByClassName( className : name ) : CComponent;
        import function GetComponentsByClassName( className : name ) : array< CComponent >;
        import function GetComponentByUsedBoneName( boneIndex : int ) : array< CComponent >;	
        import function GetComponentsCountByClassName( className : name ) : int;*/
	}

    event OnLeaveState( prevStateName : name )
    {
        if(horse) {
            horse.Destroy();
            horse = NULL;
        }
    }
}

exec function MCMTestHorse()
{
	var triss, horse : CNewNPC;

	triss = (CNewNPC)(theGame.CreateEntity(MCM_GetEntityTemplate('triss'), thePlayer.GetWorldPosition()+Vector(2,0,0)));
	triss.AddTag('MCM_Other');
	triss.GotoState('MCM_RidingHorse');
}
