
enum MCM_BoatPos
{
	MCMBP_Invalid,
	MCMBP_Front,
	MCMBP_Pos1,
	MCMBP_Pos2,
	MCMBP_Pos3,
	MCMBP_Pos4,
	MCMBP_Pos5,
	MCMBP_Pos6,
	MCMBP_Pos7,
	MCMBP_Pos8,
	MCMBP_Pos9,
	MCMBP_Pos10,
	MCMBP_Pos11,
	MCMBP_Pos12,
	MCMBP_Pos13,
	MCMBP_Pos14,
	MCMBP_Pos15,
	MCMBP_Pos16,
	MCMBP_Pos17,
	MCMBP_Pos18,
	MCMBP_Pos19,
	MCMBP_Pos20,
}

class MCM_BoatEntry
{
	private var boat : W3Boat;
	private var manager : MCM_BoatManager;
	
	private var taken : array<bool>;
	private var takenSize : int;
	
	public function GetBoat() : W3Boat
	{
		return boat;
	}

	public function Init(boat : W3Boat, manager : MCM_BoatManager)
	{
		var i : int;
		this.boat = boat;
		this.manager = manager;
		
		for(i = 21-1; i >= 0; i-=1)
		{
			taken.PushBack(false);
		}
		
		takenSize = taken.Size();
	}
	
	public function GetFreePosition(optional register : bool, optional ignorePassenger : bool) : MCM_BoatPos
	{
		var i : int;
		i = 0;
		
		if(ignorePassenger) i = 1;
		
		for(; i < takenSize; i+=1)
		{
			if(!taken[i])
			{
				if(register) taken[i] = true;
				return (MCM_BoatPos)(i+1);
			}
		}
		
		return MCMBP_Invalid;
	}
	
	public function TakePosition(pos : MCM_BoatPos)
	{
		if(pos > 0 && pos <= takenSize)
		{
			taken[pos-1] = true;
		}
	}
	
	public function FreePosition(pos : MCM_BoatPos)
	{
		if(pos > 0 && pos <= takenSize)
		{
			taken[pos-1] = false;
			DestroyIfFree();
		}
	}
	
	private function DestroyIfFree()
	{
		var i : int;
		
		for(i = 0; i < takenSize; i+=1)
		{
			if(taken[i])
			{
				return;
			}
		}
		
		manager.DestroyInstance(this);
	}
	
	public function GetOffsetFor(boatPos : MCM_BoatPos, out pos : Vector, out rot : EulerAngles)
	{
		var x,y,z : float;
		var dontRandomize : bool;
		x = 0.6;
		y = 0.5;
		z = 0.24;
		
		rot = EulerAngles(0, 0, 0);
		
		switch(boatPos)
		{
			case MCMBP_Front: pos = Vector(0.02, 2.7, 0.40); rot = EulerAngles(0, 183, 0); dontRandomize = true; break;
			case MCMBP_Pos1: pos = Vector(-x*0.6, 1.8, z); break;
			case MCMBP_Pos2: pos = Vector(x*0.6, 1.8, z); break;
			
			case MCMBP_Pos3: pos = Vector(-x,  y, z); break;
			case MCMBP_Pos4: pos = Vector(0,  y, z); break;
			case MCMBP_Pos5: pos = Vector(x,  y, z); break;
			
			case MCMBP_Pos6: pos = Vector(-x,  0, z); break;
			case MCMBP_Pos7: pos = Vector(0,  0, z); break;
			case MCMBP_Pos8: pos = Vector(x,  0, z); break;
			
			case MCMBP_Pos9: pos = Vector(-x, -y, z); break;
			case MCMBP_Pos10: pos = Vector(0, -y, z); break;
			case MCMBP_Pos11: pos = Vector(x, -y, z); break;
			
			case MCMBP_Pos12: pos = Vector(-x, -2*y, z); break;
			case MCMBP_Pos13: pos = Vector(0, -2*y, z); break;
			case MCMBP_Pos14: pos = Vector(x, -2*y, z); break;
			
			case MCMBP_Pos15: pos = Vector(-x, -3*y, z); break;
			case MCMBP_Pos16: pos = Vector(0, -3*y, z); break;
			case MCMBP_Pos17: pos = Vector(x, -3*y, z); break;
			
			case MCMBP_Pos18: pos = Vector(-x, -4*y, z); break;
			case MCMBP_Pos19: pos = Vector(0, -4*y, z); break;
			case MCMBP_Pos20: pos = Vector(x, -4*y, z); break;
			case MCMBP_Pos20: pos = Vector(x, -4*y, z); break;
		}
		if(!dontRandomize)
		{
			pos.X += RandRange(100, -100)/1000.0;
			pos.Y += RandRange(100, -100)/1000.0;
			rot.Yaw = RandRange(20, -20);
		}
	}
	
	public function GetStartIdleStopAnimsFor(boatPos : MCM_BoatPos, out start, idle, stop : name)
	{
		switch(boatPos)
		{
			case MCMBP_Front: start = 'boat_passenger_sit_start_back'; idle = 'boat_passenger_sit_idle'; stop = 'boat_passenger_sit_stop'; break;
			default: start = 'high_standing_determined_idle'; idle = 'high_standing_determined_idle'; stop = ''; break;
		}
	}
}

class MCM_BoatManager
{
	var instances : array<MCM_BoatEntry>;

	public function init()
	{

	}
	
	private function _CreateInstance(boat : W3Boat) : MCM_BoatEntry
	{
		//'asd' "asd"
		var instance : MCM_BoatEntry;
		instance = new MCM_BoatEntry in this;
		
		instance.Init(boat, this);
		
		instances.PushBack(instance);
		
		return instance;
	}
	
	public function DestroyInstance(boatEntry : MCM_BoatEntry)
	{
		instances.Remove(boatEntry);
		
		delete boatEntry;
	}
	
	public function GetBoatEntry(boat : W3Boat) : MCM_BoatEntry
	{
		var i : int;
		
		for(i = instances.Size()-1; i >= 0; i-=1)
		{
			if(instances[i].GetBoat() == boat)
			{
				return instances[i];
			}
		}
		
		return _CreateInstance(boat);
	}
}
