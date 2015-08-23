class CampaignSummaryMutator extends XComMutator;

var JournalProcessor m_kJournalProcessor;
var UICampaignSummary m_kUI;
var UICampaignSummaryMap m_kUIMap;

simulated function XComHQPresentationLayer PRES()
{
	return XComHQPresentationLayer(
                XComHeadQuartersController(     
                        XComHeadquartersGame(class'Engine'.static.GetCurrentWorldInfo().Game).PlayerController).m_Pres);
}

simulated function UIDisplayMovie Get3DMovie()
{
	return XComHQPresentationLayer(XComHeadquartersController(XComHeadquartersGame(class'Engine'.static.GetCurrentWorldInfo().Game).PlayerController).m_Pres).Get3DMovie();
}

function JournalProcessor GetJournalProcessor()
{
    return m_kJournalProcessor;
}

function Mutate(String MutateString, PlayerController Sender)
{
    if (MutateString == "CampaignSummary.Show")
    {
        ShowUI();
    }
    else if (MutateString == "XGStrategy.PostLoadSaveGame")
    {
        CreateActor(Sender);
    }
 
    super.Mutate(MutateString, Sender);
}

function CreateActor(PlayerController Sender)
{
    local bool foundActor;
    local JournalProcessor jp;

    foundActor = false;

    foreach AllActors(class'JournalProcessor', jp)
    {
        foundActor = true;
        m_kJournalProcessor = jp;
        break;
    }

    if (!foundActor)
    {
        m_kJournalProcessor = Spawn(class'JournalProcessor', Sender);
    }

    m_kJournalProcessor.ProcessEntries();
}

function HeadQuartersInitNewGame(PlayerController Sender)
{
    CreateActor(Sender);
}

function AddSummaryLine(string Line)
{
    m_kUI.AS_AddSummaryLine(Line);
}

function AddMissionIcon(Vector2D vect)
{
    m_kUIMap.AS_AddMissionIcon(vect.X, vect.Y);
}

function HideUI()
{
    PRES().GetStrategyHUD().m_kMenu.Show();
    PRES().GetStrategyHUD().m_kMenu.m_kSubMenu.Show();
    PRES().m_kSituationRoom.ShowObjectives();
    PRES().GetStrategyHUD().AS_ShowResourcesPanel();
    PlaySound(soundcue'SoundUI.MenuCancelCue', true);
    m_kUI.AS_Hide();
    m_kUI.SetInputState(0);
    m_kUI.Remove();
    m_kUI = none;
    m_kUIMap.Remove();
    m_kUIMap = none;
    PRES().m_kSituationRoom.GoToView(0);
    PRES().m_kSituationRoom.Hide();
    PRES().m_kSituationRoom.Show();
    PRES().m_kSituationRoom.UpdateData();
    PRES().m_kSituationRoom.RealizeMap();
    PRES().m_kSituationRoom.AS_ShowTicker();
    PRES().m_kSituationRoom.m_kSitRoomHUD.SetContinentInfo("", "", 0);
    PRES().m_kSituationRoom.m_kSitRoomHUD.SetCountryInfo("", "", 0);
}

function ShowUI()
{
    PRES().GetStrategyHUD().m_kMenu.Hide();
    PRES().GetStrategyHUD().m_kMenu.m_kSubMenu.Hide();
    PRES().GetStrategyHUD().AS_HideResourcesPanel();
    PRES().m_kSituationRoom.HideObjectives();
    PRES().m_kSituationRoom.AS_HideTicker();
    PRES().m_kStrategyHUD.ShowBackButton(HideUI);
    PRES().m_kSituationRoom.m_kSitRoomHUD.AS_SetDisplayMode(DISPLAY_MODE_SATELLITE);
    PRES().m_kSituationRoom.m_kSitRoomHUD.SetCountryInfo("15 December 2015", "", 0);
    PRES().m_kSituationRoom.m_kSitRoomHUD.SetContinentInfo("<br/>", "<br/>", 0);
    m_kUIMap = Spawn(class'UICampaignSummaryMap', self);
    m_kUIMap.SetMgr(self);
    m_kUIMap.Init(XComPlayerController(Owner), Get3DMovie());
    Get3DMovie().ShowDisplay(class'UICampaignSummaryMap'.default.DisplayTag);

    m_kUI = Spawn(class'UICampaignSummary',self);
    m_kUI.SetMgr(self);
    m_kUI.Init(XComPlayerController(Owner), PRES().GetHUD());

}

function String GetMissionTypeString(XGGameData.EMissionType eType)
{
    switch(eType)
    {
        case eMission_Abduction: return "Abduction";
        case eMission_Crash: return "UFO Crash";
        case eMission_LandedUFO: return "UFO Landing";
        case eMission_CovertOpsExtraction: return "Covert Extraction";
        case eMission_CaptureAndHold: return "Covert Data Recovery";
        case eMission_HQAssault: return "Base Defense";
        case eMission_AlienBase: return "Alien Base Assault";
        case eMission_TerrorSite: return "Terror Attack";
        case eMission_Final: return "Temple Ship Assault";
        case eMission_Special: return "Council Mission";
        case eMission_DLC: return "Council Mission";
    }

    return "Unknown";
}

defaultproperties
{
    m_kJournalProcessor=none
    m_kUI=none
    m_kUIMap=none
}
