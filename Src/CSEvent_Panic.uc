class CSEvent_Panic extends CSEvent;

struct TPanicRecord
{
    var int origPanic;
    var int newPanic;

    structdefaultproperties
    {
        origPanic=-1
        newPanic=-1
    }
};

struct CheckpointRecord
{
    var TPanicRecord panic[16];
};

var TPanicRecord panic[16];

function RecordPanicChange(int countryIndex, int oldPanic, int newPanic)
{
    if (panic[countryIndex].origPanic == -1)
    {
        panic[countryIndex].origPanic = oldPanic;
    }

    panic[countryIndex].newPanic = newPanic;
}

function Realize(CampaignSummaryMutator cs)
{
}

