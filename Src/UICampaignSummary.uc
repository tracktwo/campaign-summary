class UICampaignSummary extends UI_FxsScreen
	hidecategories(Navigation)
	implements(IScreenMgrInterface);

var CampaignSummaryMutator m_kMgr;
var int m_iIndex;
var bool m_bPlaying;

function XGWorld World()
{
    return XComHeadquartersGame(class'Engine'.static.GetCurrentWorldInfo().Game).GetGameCore().GetWorld();
}

function XGHeadquarters HQ()
{
    return XComHeadquartersGame(class'Engine'.static.GetCurrentWorldInfo().Game).GetGameCore().GetHQ();
}

simulated function SetMgr(CampaignSummaryMutator mgr)
{
    m_kMgr = mgr;
}

simulated function Init(XComPlayerController _controllerRef, UIFxsMovie _manager)
{
	BaseInit(_controllerRef, _manager);
	_manager.LoadScreen(self);
	Show();
}

simulated function OnInit()
{
    super.OnInit();
    NextEvent(1);
}

simulated function Remove()
{
	super.Remove();
}

simulated function bool OnMouseEvent(int Cmd, array<string> args)
{
	local string Target;

	Target = args[args.Length-1];

    if (Target == "playButtonMC")
    {
        SetPlaying(!m_bPlaying);
    }
    if (Target == "rwSeekButtonMC")
    {
        OnRWSeek();
    }
    else if (Target == "fwSeekButtonMC")
    {
        OnFFSeek();
    }
    else if (Target == "head")
    {
        args.Length = args.Length - 1;
        JoinArray(args, Target, ".", true);
        OnSliderDrag(Target);
    }
	return true;
}

function OnSliderDrag(string pct)
{
    local float fPercent;

    fPercent = float(pct);
    m_iIndex = int(float(m_kMgr.GetJournalProcessor().GetRecordCount()) * fPercent);
    if (m_iIndex > 0)
    {
        m_iIndex--;
    }
    NextEvent(0);
}

simulated function AS_ClearSummary()
{
    manager.ActionScriptVoid(string(GetMCPath()) $ ".ClearSummary");
}

simulated function AS_AddSummaryLine(string e)
{
    manager.ActionScriptVoid(string(GetMCPath()) $ ".AddSummaryLine");
}

simulated function AS_DisplaySummary()
{
    manager.ActionScriptVoid(string(GetMCPath()) $ ".DisplaySummary");
}

simulated function AS_UpdateSlider(float pct)
{
    manager.ActionScriptVoid(string(GetMCPath()) $ ".UpdateSlider");
}

simulated function NextEvent(int dir)
{
    local int i;
    local XGSituationRoomUI.TSitCountry kCountry;
    local String money;
    local TSatNode kNode;
    local int numWithdrawn;
    local CSEvent csEvent;
    local array<CSEvent> events;
    local JournalProcessor jp;

    jp = m_kMgr.GetJournalProcessor();

    if (jp.GetRecordCount() == 0)
    {
        return;
    }

    m_iIndex += dir;
    if (m_iIndex < 0)
    {
        m_iIndex = 0;
    }
    if (m_iIndex >= jp.GetRecordCount())
    {
        m_iIndex = jp.GetRecordCount() - 1;
    }

    if (jp.GetRecordCount() < 2)
    {
        AS_UpdateSlider(0);
    }
    else
    {
        AS_UpdateSlider(float(m_iIndex) / (jp.GetRecordCount()-1));
    }
        

    m_kMgr.PRES().m_kSituationRoom.m_kSitRoomHUD.SetCountryInfo(jp.GetDate(m_iIndex).GetDateString(), "", 0); 
    AS_ClearSummary();
    m_kMgr.PRES().m_kSituationRoom.AS_ClearMap();
    m_kMgr.PRES().m_kSituationRoom.AS_AddMapItem("_hq", HQ().GetCoords().X, HQ().GetCoords().Y);

    for (i = 0; i < 16; ++i)
    {
        kCountry = m_kMgr.PRES().m_kSituationRoom.GetSitRoomMgr().m_arrCountriesUI[i];
        if (jp.HasSatellite(m_iIndex, i))
        {
            money = kCountry.txtFunding.StrValue;
        }
        else 
        {
            money = "";
        }
        m_kMgr.PRES().m_kSituationRoom.AS_SetCountryInfo(i, 
                class 'UIUtilities'.static.CapsCheckForGermanScharfesS(kCountry.txtName.StrValue),
                money, jp.GetPanicValue(m_iIndex, i), !jp.HasWithdrawn(m_iIndex, i));

        if (money != "")
        {
            kNode = World().GetSatelliteNode(kCountry.iEnum);
            m_kMgr.PRES().m_kSituationRoom.AS_AddMapItem("_satellite", kNode.v2Coords.X, kNode.v2Coords.Y);
        }

        if (jp.HasWithdrawn(m_iIndex, i))
        {
            ++numWithdrawn;
        }
    }

    events = jp.GetEvents(m_iIndex);
    foreach events(csEvent)
    {
        csEvent.Realize(m_kMgr);
    }

    AS_DisplaySummary();

    m_kMgr.PRES().m_kSituationRoom.AS_SetDoomLevel(numWithdrawn);
}

simulated function OnFFSeek()
{
    SetPlaying(false);
    NextEvent(1);
}

simulated function OnRWSeek()
{
    SetPlaying(false);
    NextEvent(-1);
}

function AS_SetPlaying(bool b)
{
    manager.ActionScriptVoid(string(GetMCPath()) $ ".SetPlaying");
}

simulated function PlayTimer()
{
    NextEvent(1);
}

simulated function SetPlaying(bool b)
{
    if (b)
    {
        m_bPlaying = true;
        AS_SetPlaying(true);
        NextEvent(1);
        SetTimer(1.0f, true, 'PlayTimer');
    }
    else
    {
        m_bPlaying = false;
        AS_SetPlaying(false);
        ClearTimer('PlayTimer');
    }

}

simulated function bool OnUnrealCommand(int Cmd, int Arg)
{
    local bool bHandled;
    bHandled = false;

    if (!CheckInputIsReleaseOrDirectionRepeat(Cmd, Arg))
    {
        return false;
    }

    if (!IsVisible())
    {
        return false;
    }

    switch (Cmd)
    {
        case 301:
        case 405:
        case 510:
                m_kMgr.HideUI();
                break;
        default:
                break;
    }
    return bHandled;
}

simulated function Hide()
{
	super.Hide();
}

public final simulated function AS_Hide()
{
	manager.ActionScriptVoid(string(GetMCPath()) $ ".Hide");
}

defaultproperties
{
	s_package="/ package/gfxCampaignSummary/CampaignSummary"
	s_screenId="gfxCampaignSummary"
	s_name="theScreen"
	e_InputState=eInputState_Consume
    m_iIndex=-1
}
