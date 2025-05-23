
class MCM_ActionPoint
{
	public editable var tag : name;
	public editable var ent : CEntity;
}

class MCM_ActionPointManager
{
	private var isInit : bool; default isInit = false;
	public function init()
	{
		if(isInit) return;
		isInit = true;
	}

	var CreatedActionPoints : array<MCM_ActionPoint>;
	
	public function GetActionPoint(tag : name) : MCM_ActionPoint
	{
		var i : int;
		for(i = CreatedActionPoints.Size()-1; i >= 0; i-=1)
		{
			if(!CreatedActionPoints[i] || !CreatedActionPoints[i].ent)
			{
				CreatedActionPoints.Erase(i);
			}
			else if(CreatedActionPoints[i].tag == tag)
			{
				return CreatedActionPoints[i];
			}
		}
		
		return NULL;
	}
	
	public function CreateActionPoint(tag : name, x, y, z : float, optional pitch, yaw, roll : float) : MCM_ActionPoint
	{
		var template : CEntityTemplate;
		var pos : Vector;
		var rot : EulerAngles;
		var ent : CEntity;
		var AP : MCM_ActionPoint;
		
		AP = GetActionPoint(tag);
		
		if(AP)
		{
			pos = Vector(x, y, z);
			rot = EulerAngles(pitch, yaw, roll);
			AP.ent.TeleportWithRotation(pos, rot);
			return AP;
		}
		
		template = (CEntityTemplate)LoadResource("dlc/mod_spawn_companions/hack/npc/actionpoint.w2ent", true);
		
		if(template)
		{
			pos = Vector(x, y, z);
			rot = EulerAngles(pitch, yaw, roll);
			ent = theGame.CreateEntity(template, pos, rot);
			
			if(ent)
			{
				ent.AddTag(tag);
				
				AP = new MCM_ActionPoint in theGame;
				
				AP.tag = tag;
				AP.ent = ent;
				
				CreatedActionPoints.PushBack(AP);
				return AP;
			}
		}
		
		return NULL;
	}
}
