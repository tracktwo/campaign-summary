
class CampaignSummaryMap extends MovieClip 
{
	var sitRoom;
		
	public function CampaignSummaryMap() 
	{
		this.sitRoom = _level0.theInterfaceMgr.gfxSituationRoom.theScreen;
	}
	
	public function AddMissionIcon(x, y)
	{
		this.sitRoom.AddMapItem("_ufo", x, y);
		var newItem = this.sitRoom.mapArea["mapItem"+string(this.sitRoom.nextMapItem-1)];
		// Set the new UFO icon to half size
		newItem._xscale = 50;
		newItem._yscale = 60;
	}
}
