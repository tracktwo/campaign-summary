class CSEvent_Raw extends CSEvent;

struct CheckpointRecord
{
    var string m_kStr;
};

var string m_kStr;

function AddString(string s)
{
    m_kStr = s;
}

function Realize(CampaignSummaryMutator cs)
{
    cs.AddSummaryLine(m_kStr);
}

