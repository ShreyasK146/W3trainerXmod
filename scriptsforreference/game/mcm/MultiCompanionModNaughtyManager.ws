
class MCM_NaughtyManager
{
	private var isInit : bool; default isInit = false;
	
	public var naughtyPoints : mod_scm_NaughtyPoints;
	
	public function init()
	{
		if(isInit) return;
		isInit = true;
		
		naughtyPoints = new mod_scm_NaughtyPoints in this;
		naughtyPoints.init();
		
		UnequipSlots.PushBack(EES_SilverSword);
		UnequipSlots.PushBack(EES_SteelSword);
		UnequipSlots.PushBack(EES_Armor);
		UnequipSlots.PushBack(EES_Boots);
		UnequipSlots.PushBack(EES_Pants);
		UnequipSlots.PushBack(EES_Gloves);
		UnequipSlots.PushBack(EES_RangedWeapon);
		UnequipSlots.PushBack(EES_Mask);
	}
	
	private var UnequipSlots : array<EEquipmentSlots>;
	private var UnequipedItems : array<SItemUniqueId>;
	private var CurrentNaughtyNPC : CNewNPC;
	
	public function PreNaughtyWith(npcName : name)
	{
		var point : mod_scm_NaughtyPoint;
		CurrentNaughtyNPC = mod_scm_GetNPC(npcName, ST_Special, false);
		
		if(CurrentNaughtyNPC && StrLen(CurrentNaughtyNPC.scmcc.specialData.naughtyScene) > 0)
		{
			point = naughtyPoints.GetClosestPoint(20.0);
			
			if(point)
			{
				point.AddActionPoint();
				mod_scm_GetSCMEntity().mod_scm_delayedDialogue(CurrentNaughtyNPC.scmcc.specialData.naughtyScene, 0.01);
				HideAllExcept(CurrentNaughtyNPC);
			}
		}
	}
	
	public function HideAllExcept(npc : CNewNPC)
	{
		var npcs : array<CNewNPC>;
		var i : int;
		
		theGame.GetNPCsByTag('GeraltsBFF', npcs);
		
		for(i = npcs.Size()-1; i >= 0; i-=1)
		{
			if(npcs[i] != npc)
			{
				npcs[i].SetHideInGame(true); 
			}
		}
	}
	
	public function ShowAllExcept(npc : CNewNPC)
	{
		var npcs : array<CNewNPC>;
		var i : int;
		
		theGame.GetNPCsByTag('GeraltsBFF', npcs);
		
		for(i = npcs.Size()-1; i >= 0; i-=1)
		{
			if(npcs[i] != npc)
			{
				npcs[i].SetHideInGame(false); 
			}
		}
	}
	
	public function PostNaughty()
	{
		var i : int;
		for(i = UnequipedItems.Size()-1; i >= 0; i-=1)
		{
			thePlayer.EquipItem(UnequipedItems[i]);
		}
		UnequipedItems.Clear();
		
		//Reset the NPC's appearance
		if(CurrentNaughtyNPC && CurrentNaughtyNPC.scmcc) CurrentNaughtyNPC.ApplyAppearance(CurrentNaughtyNPC.scmcc.data.appearance);
		
		ShowAllExcept(CurrentNaughtyNPC);
		
		CurrentNaughtyNPC = NULL;
	}
	
	public function PreNaughty()
	{
		var i : int;
		var item : SItemUniqueId;
		UnequipedItems.Clear();
		
		for(i = UnequipSlots.Size()-1; i >= 0; i-=1)
		{
			GetWitcherPlayer().GetItemEquippedOnSlot(UnequipSlots[i], item);
			UnequipedItems.PushBack(item);
		}
	}
	
	//About to enter dialogue scene with this NPC
	public function PreDialogue(npc : CNewNPC)
	{
		if(npc.scmcc.specialData && StrLen(npc.scmcc.specialData.naughtyScene) > 0)
		{
			if(naughtyPoints.GetClosestPoint(16.0) && (FactsQuerySum('mod_scm_AllowAllNaughty') > 0 || npc.scmcc.specialData.satisfiesNaughtyRequirements()))
			{
				FactsSet('mod_scm_allownaughty', 1);
			}
			else
			{
				FactsSet('mod_scm_allownaughty', 0);
			}
		}
	}
}
