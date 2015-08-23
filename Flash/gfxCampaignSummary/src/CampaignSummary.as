class CampaignSummary extends MovieClip
{
	var sitHud;
	var sitRoom;
	var scrollOrigY;
	var scrollOrigHeight;
	var summaryLines:String;
	var transport:MovieClip;
	var playIcon:MovieClip;
	var pauseIcon:MovieClip;
	var slider:MovieClip;
	var head:MovieClip;
	var draggingHead;
	
	function CampaignSummary()
	{
		super();
		this.sitHud = _level0.theInterfaceMgr.gfxSituationRoomHUD.theScreen;
		this.sitHud.countryInfo.bg.gotoAndStop(1);
		this.scrollOrigY = this.sitHud.descFieldScrolling._y;
		this.sitHud.descFieldScrolling._y -= 40;
		this.scrollOrigHeight = this.sitHud.descFieldScrolling.height;
		this.sitHud.descFieldScrolling.height += 50;
		this.transport = this["transport"];
		this.pauseIcon = this.transport.pauseIcon;
		this.playIcon = this.transport.playIcon;
		this.slider = this["theSlider"];
		this.head = this["theHead"];
		this.pauseIcon._visible = false;
		this.head.onPress = function() { 
			this.draggingHead = true;
			//this.head.startDrag(true);
		};
		this.head.onMouseUp = function() {
			this.draggingHead = false;
		}
		this.head.onMouseMove = function() {
			if (this.draggingHead) 
			{
				if (_level0._xmouse < (_parent.slider._x - (this._width/2)))
				{
					this.head._x = _parent.slider._x - (this._width/2);
				}
				else if (_level0._xmouse > (_parent.slider._x + _parent.slider._width - (this._width/2)))
				{
					this._x = _parent.slider._x + _parent.slider._width - (this._width/2);
				}
				else
				{
					this._x = _level0._xmouse;
				}
				var pct:Number = (this._x - _parent.slider._x + (this._width/2)) / _parent.slider._width;
				flash.external.ExternalInterface.call("FlashRaiseMouseEvent", string(this._parent), 394, pct.toString() + ".head" );
			}
		}
		UpdateSlider(0);
	}
	
	function onLoad()
	{
	}
	
	function Hide()
	{
		this._visible = false;
		this.sitHud.descFieldScrolling._y = scrollOrigY;
		this.sitHud.descFieldScrolling.height = scrollOrigHeight;
	}
	
	function ClearSummary()
	{
		this.summaryLines = "";
	}
	
	function AddSummaryLine(s:String)
	{
		if (s.charAt(s.length - 1) != '\n')
		{
			s += '\n';
		}
		s = "<textformat indent=\"-20\" leftMargin=\"20\">" + s + "</textformat>";
		this.summaryLines += s;
	}
	
	function DisplaySummary()
	{
		this.sitHud.descFieldScrolling.setHTML(this.summaryLines);
		this.sitHud.descFieldScrolling.setMaskHeight(132);
	}
	
	function SetCountryState(c, panic)
	{
		this.sitRoom.countries[c].panicLevels.gotoAndStop(panic);
	}
	
	function UpdateSlider(pct)
	{
		var ratio = this.slider._width * pct;
		this.head._x = (this.slider._x + ratio - (this.head._width/2));
	}
	
	function SetPlaying(p)
	{
		if (p)
		{
			this.playIcon._visible = false;
			this.pauseIcon._visible = true;
		}
		else
		{
			this.playIcon._visible = true;
			this.pauseIcon._visible = false;
		}
	}
}