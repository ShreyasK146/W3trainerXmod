/*
Contains functions and code used when debugging the game
*/

/*
[ECompareFunc]
	CF_Equal = 0
	CF_NotEqual = 1
	CF_Less = 2
	CF_LessEqual = 3
	CF_Greater = 4
	CF_GreaterEqual = 5
	[EQueryFact]
	QF_Sum = 0
	QF_SumSince = 1
	QF_LatestValue = 2
	QF_DoesExist = 3

[ETopLevelAIPriorities]
	AIP_BelowIdle = 15
	AIP_AboveIdle = 25
	AIP_AboveIdle2 = 30
	AIP_AboveEmergency = 60
	AIP_AboveEmergency2 = 65
	AIP_AboveCombat = 85
	AIP_AboveCombat2 = 90

[EMountType]
	MT_normal 1
	MT_instant 2
	MT_fromScript 1024

[EDismountType]
	DT_normal 1
	DT_shakeOff 2
	DT_ragdoll 4
	DT_instant 8
	DT_fromScript 1024
*/

exec function MCM_PrintJobManager()
{
    MCM_GetMCM().JobManager.Print();
}

exec function MCM_ListTags(nam : name)
{
    var npc : CNewNPC;
    var tags : array<name>;
    var i : int;
		
    npc = theGame.GetNPCByTag(nam);
		
    if(npc)
    {
        tags = npc.GetTags();
        npc.LogAllAbilities();
        LogSCM("Begin Tags. Immortality Mode: " + npc.immortalityFlags);
        for ( i = 0; i < tags.Size(); i+=1 )
        {
            LogSCM(tags[i]);
        }
        LogSCM("End Tags");
    }
    else
    {
        LogSCM("NPC Doesn't exist => " + nam);
    }
}

/*exec function scmanim(ent : name, nam : name, optional type : int)
{
	var npc : CNewNPC;
	var animComp : CAnimatedComponent;
	var slotName : name;
	
	switch(type)
	{
		case 0: slotName = 'NPC_ANIM_SLOT'; break;
		case 1: slotName = 'GAMEPLAY_SLOT'; break;
		case 2: slotName = 'INJECT'; break;
		default: slotName = 'DIALOG_GEST_SLOT'; break;
	}
	
	npc = (CNewNPC)mod_scm_GetNPC(ent, ST_Both);
	
	if(npc)
	{
		npc.scmcc.PlayAnimSimple(nam);
	}
	else if(ent == 'player' || ent == 'PLAYER')
	{
		mod_scm_PlayPlayerAnim(nam);
	}
}*/

exec function PrintLevelInt()
{
	LogChannel('ModSpawnCompanions', "LEVEL INT: " + theGame.GetCommonMapManager().GetCurrentArea());
}

exec function OpenMenu(menu : name, optional close : bool)
{
	if(close)
	{
		theGame.CloseMenu(menu);
	}
	else
	{
		theGame.RequestMenu(menu);
	}
}

exec function OpenPopup(menu : name, optional close : bool)
{
	if(close)
	{
		theGame.ClosePopup(menu);
	}
	else
	{
		theGame.RequestPopup(menu);
	}
}

/*
Be careful with this one. The Witcher 3 engine has some memory management issues and it doesn't seem to like this haha
*/

exec function MCM_ResetMCM()
{
	MCM_GetMCM().ReloadData();
}

exec function MCMShowHidePlayer(show : bool) {
	if(show) {
		MCM_ShowNPC(thePlayer);
	} else {
		MCM_HideNPC(thePlayer);
	}
}

class CInventoryComponentJ extends CInventoryComponent
{

}

class JLoot extends W3Container
{
	public function AddItem(item : name)
	{
		if(this.inv)
		{
			LogSCM("Added");
			this.inv.AddAnItem( item, 1 );
		}
		else
		{
			LogSCM("No Inv");
		}
	}
}

exec function RagDoll(nam : name)
{
	var npc : CNewNPC = mod_scm_GetNPC(nam, ST_Both);
	
	if(npc)
	{
		npc.TurnOnRagdoll();
	}
}

exec function MCM_ChkFact(nam : name)
{
	var count : int;
	
	count = FactsQuerySum(nam);
	
	GetWitcherPlayer().DisplayHudMessage(nam + "=" + count);
}

exec function MCM_PrintPosRot()
{
	var areaInt : int;
	var playerPos : Vector;
	var playerRot : EulerAngles;
	
	playerPos = thePlayer.GetWorldPosition();
	playerRot = thePlayer.GetWorldRotation();
	
	LogChannel('SpawnCompanionMod', "Pos (XYZ): " + playerPos.X + ", " + playerPos.Y + ", " + playerPos.Z);
	LogChannel('SpawnCompanionMod', "Rot (PYR): " + playerRot.Pitch + ", " + playerRot.Yaw + ", " + playerRot.Roll);
}

exec function MCM_ListDLC()
{
	var dlcList : array<name>;
	var i : int;
	
	theGame.GetDLCManager().GetDLCs(dlcList);
	for(i = 0; i < dlcList.Size(); i+=1)
	{
		LogSCM("DLC AVAILABLE: " + dlcList[i]);
	}
}

exec function scmTestEnums()
{
	var i, j : int;

	if(true)
	{
		for(i = 0; i < 150; i+=1)
		{
			LogSCM(((ETopLevelAIPriorities)i) + " = " + i);
		}
		for(i = 0; i < 150; i+=1)
		{
			LogSCM(((EArbitratorPriorities)i) + " = " + i);
		}
	}
	else
	{
		j = 1;
		for(i = 0; i < 255; i+=1)
		{
			LogSCM(((EInputKey)j) + " " + j);
			j *= 2;
		}
	}
}

exec function StartLoggingPlayer()
{
	MCM_GetMCM().JobManager.togglePlayerLogging();
}

function MCM_GetTriss() : CNewNPC
{
	var triss : CNewNPC = theGame.GetNPCByTag('mcm_triss');
	if(!triss)
	{
		triss = (CNewNPC)(theGame.CreateEntity(MCM_GetEntityTemplate('triss'), thePlayer.GetWorldPosition()));
		triss.AddTag('MCM_Other');
		triss.AddTag('mcm_triss');
	}
	return triss;
}

function MCM_GetYen() : CNewNPC
{
	var yen : CNewNPC = theGame.GetNPCByTag('mcm_yen');
	if(!yen)
	{
		yen = (CNewNPC)(theGame.CreateEntity(MCM_GetEntityTemplate('yennefer'), thePlayer.GetWorldPosition()));
		yen.AddTag('MCM_Other');
		yen.AddTag('mcm_yen');
	}
	return yen;
}

exec function MCMListInRange(radius : float)
{
	var entities : array<CGameplayEntity>;
	var tags : array<name>;
	var i, j : int;
	FindGameplayEntitiesInSphere(entities, thePlayer.GetWorldPosition(), radius, 1000);
	LogSCM("Found " + entities.Size() + " in range");
	for(i = 0; i < entities.Size(); i+= 1)
	{
		tags = entities[i].GetTags();
		LogSCM(entities[i]);
		for(j = 0; j < tags.Size(); j+=1)
		{
			LogSCM("	" + tags[j]);
		}
	}
}

exec function TestHorseBone(optional bone : name, optional swap : bool)
{
	var triss, horse : CNewNPC;

	triss = (CNewNPC)(theGame.CreateEntity(MCM_GetEntityTemplate('triss'), thePlayer.GetWorldPosition()+Vector(1,0,0)));
	triss.AddTag('MCM_Other');

	horse = (CNewNPC)(theGame.CreateEntity(MCM_GetEntityTemplate('horse'), thePlayer.GetWorldPosition()+Vector(1,0,0)));
	horse.AddTag('MCM_Other');

	if(!IsNameValid(bone))
	{
		bone = 'pelvis';
	}
	if(swap)
	{
		if( !triss.CreateAttachmentAtBoneWS( horse , bone, Vector( 0, 0, 0 ), EulerAngles( 0, 0, 0 ) ) )
		{
			LogChannel( 'Miscreant',"Could not create attachment to bone " + bone );
		}
	}
	else
	{
		if( !horse.CreateAttachmentAtBoneWS( triss , bone, Vector( 0, 0, 0 ), EulerAngles( 0, 0, 0 ) ) )
		{
			LogChannel( 'Miscreant',"Could not create attachment to bone " + bone );
		}
	}
}

exec function YenHoldTriss() {
	var triss : CNewNPC = MCM_GetTriss();
	var yen : CNewNPC = MCM_GetYen();

	//Lol worth a shot.
	//Probably only works with simple entities

	//box = (CEntity)theGame.CreateEntity( entityTemplate, startPos );	
	triss.CreateAttachment( yen, 'r_weapon' );
	triss.Teleport(Vector(0, 0, 0));
}

exec function ILoveTriss() {
	FactsSet('q309_triss_lover', 1);
	FactsSet('sq202_yen_girlfriend', 0);
}

exec function ILoveYen() {
	FactsSet('q309_triss_lover', 0);
	FactsSet('sq202_yen_girlfriend', 1);
}

exec function ILoveTrissAndYen() {
	FactsSet('q309_triss_lover', 1);
	FactsSet('sq202_yen_girlfriend', 1);
}

exec function ILoveNobody() {
	FactsSet('q309_triss_lover', 0);
	FactsSet('sq202_yen_girlfriend', 0);
}
