class CSEvent_ExpiredMission extends CSEvent;

struct CheckpointRecord
{
    var XGGameData.EMissionType m_eType;
    var string m_strLoc;
};

var XGGameData.EMissionType m_eType;
var string m_strLoc;

function SetType(XGGameData.EMissionType e)
{
    m_eType = e;
}

function SetLoc(String loc)
{
    m_strLoc = loc;
}

function Realize(CampaignSummaryMutator cs)
{
    local string str;
    str = cs.GetMissionTypeString(m_eType) $ " mission expired";
    if (m_strLoc != "")
    {
        str = str $ " in " $ m_strLoc;
    }

    cs.AddSummaryLine(str);

    /*if (m_vCoords.X != 0 && m_vCoords.Y != 0)
    {
        cs.AddMissionIcon(m_vCoords);
    }*/
}
