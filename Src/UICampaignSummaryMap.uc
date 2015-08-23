class UICampaignSummaryMap extends UI_FxsScreen
    hidecategories(Navigation)
    implements(IScreenMgrInterface);

var CampaignSummaryMutator m_kMgr;
var Name DisplayTag;

function SetMgr(CampaignSummaryMutator mgr)
{
    m_kMgr = mgr;
}

function Init(XComPlayerController _controllerRef, UIFxsMovie _manager)
{
    BaseInit(_controllerRef, _manager);
    _manager.LoadScreen(self);
    Show();
}

simulated function OnInit()
{
    super.OnInit();
}

simulated function Remove()
{
    super.Remove();
}

function AS_AddMissionIcon(float x, float y)
{
    manager.ActionScriptVoid(string(GetMCPath()) $ ".AddMissionIcon");
}

defaultproperties
{
    s_package="/ package/gfxCampaignSummary/CampaignSummaryMap"
    s_screenId="gfxCampaignSummaryMap"
    s_name="theScreen"
    DisplayTag="UIDisplay_CountryPanels"
}
