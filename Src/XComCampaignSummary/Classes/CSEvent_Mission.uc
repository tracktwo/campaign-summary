class CSEvent_Mission extends CSEvent;

struct CheckpointRecord
{
    var string m_strName;
    var XGGameData.EMissionType m_eType;
    var string m_strLoc;
    var Vector2D m_vCoords;
    var XGBattle.EBattleResult m_eResult;
};

var string m_strName;
var XGGameData.EMissionType m_eType;
var string m_strLoc;
var Vector2D m_vCoords;
var XGBattle.EBattleResult m_eResult;

function SetName(String s)
{
    m_strName = s;
}

function SetType(XGGameData.EMissionType e)
{
    m_eType = e;
}

function SetLoc(String loc)
{
    m_strLoc = loc;
}

function SetCoords(Vector2D coords)
{
    m_vCoords = coords;
}

function SetResult(XGBattle.EBattleResult e)
{
    m_eResult = e;
}

function String GetResultString()
{
    switch(m_eResult)
    {
        case eResult_Victory: return "Victory";
        case eResult_Defeat: return "Defeat";
        case eResult_Abandon: return "Aborted";
        case eResult_TimeOut: return "Failed";
    }

    return "Unknown result";
}

function Realize(CampaignSummaryMutator cs)
{
    local string str;
    str = "Completed " $ m_strName $ ": " $ cs.GetMissionTypeString(m_eType);
    if (m_strLoc != "")
    {
        str = str $ " in " $ m_strLoc;
    }

    if (m_eResult != eResult_Victory)
    {
        str = str $ " - " $ GetResultString();
    }

    cs.AddSummaryLine(str);

    if (m_vCoords.X != 0 && m_vCoords.Y != 0)
    {
        cs.AddMissionIcon(m_vCoords);
    }
}
