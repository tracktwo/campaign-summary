class JournalProcessor extends Actor;

struct TDayRecord
{
    var XGDateTime date;
    var int panic[16];
    var int satellite;
    var int withdrew;
    var array<CSEvent> events;
};

struct CheckpointRecord
{
    var int m_iLastProcessedIndex;
    var XGDateTime m_kLastProcessedDate;
    var array<TDayRecord> m_kRecords;
    var bool m_bSawSatelliteShotDown;
};

var int m_iLastProcessedIndex;
var XGDateTime m_kLastProcessedDate;
var array<TDayRecord> m_kRecords;
var bool m_bSawSatelliteShotDown;

function XGGeoscape GEOSCAPE()
{
    return XComHeadquartersGame(class'Engine'.static.GetCurrentWorldInfo().Game).GetGameCore().GetGeoscape();
}

function XGCountry Country(int iCountry)
{
    return XComHeadquartersGame(class'Engine'.static.GetCurrentWorldInfo().Game).GetGameCore().GetWorld().GetCountry(iCountry);
}

function XGTacticalGameCore TACTICAL()
{ 
    return XComGameReplicationInfo(class'Engine'.static.GetCurrentWorldInfo().GRI).m_kGameCore;
}

function XGFacility_Barracks BARRACKS()
{
    return XComHeadquartersGame(class'Engine'.static.GetCurrentWorldInfo().Game).GetGameCore().GetHQ().m_kBarracks;
}

function XGFacility_Engineering ENGINEERING()
{
    return XComHeadquartersGame(class'Engine'.static.GetCurrentWorldInfo().Game).GetGameCore().GetHQ().m_kEngineering;
}

function XGItemTree ITEMTREE()
{
    return ENGINEERING().m_kItems;
}

function int GetRecordCount()
{
    return m_kRecords.Length;
}

function array<CSEvent> GetEvents(int idx)
{
    return m_kRecords[idx].events;
}

function XGDateTime GetDate(int idx)
{
    return m_kRecords[idx].date;
}

function int GetPanicValue(int idx, int ctry)
{
    return m_kRecords[idx].panic[ctry];
}

function bool HasSatellite(int idx, int ctry)
{
    return (m_kRecords[idx].satellite & (1<<ctry)) != 0;
}

function bool HasWithdrawn(int idx, int ctry)
{
    return (m_kRecords[idx].withdrew & (1<<ctry)) != 0;
}

function int ParseInt(string str)
{   
    local int num;
    local int tmp;

    while (Len(str) > 0)
    {
        tmp = Asc(str);

        if ((tmp == 10 || tmp == 32) && Len(str) == 1)
        {
            // Last character is a space or a newline, ignore it.
            break;
        }

        num *= 10;

        if (tmp < 48 || tmp > 57)
        {
            `Log("JournalProcessor.ParseInt: Invalid character found: " $ str);
            return 0;
        }
        num += (tmp-48);
        str = Right(str, Len(str)-1);
    }

    return num;
}

function XGDateTime ParseDate(string entry)
{
    local XGDateTime origDate;
    local array<String> parts;

    // If we don't have a date yet, find the year and start at 1/1/year and walk forward
    // from there.
    if (m_kLastProcessedDate == none)
    {
        parts = SplitString(entry, " ", true);
        m_kLastProcessedDate = Spawn(class'XGDateTime');
        m_kLastProcessedDate.SetTime(0, 0, 0, 1, 1, ParseInt(parts[2]));
    }

    origDate = Spawn(class'XGDateTime');
    origDate.CopyDateTime(m_kLastProcessedDate);

    while (InStr(entry, m_kLastProcessedDate.GetDateString()) == -1)
    {
        m_kLastProcessedDate.AddDay();
        if (GEOSCAPE().m_kDateTime.LessThan(m_kLastProcessedDate))
        {
            `Log("JournalProcessor.ParseDate: Failed to parse date " $ entry);
            m_kLastProcessedDate.CopyDateTime(origDate);
            origDate.Destroy();
            return m_kLastProcessedDate;
        }
    }

    origDate.Destroy();
    return m_kLastProcessedDate;
}

function XGCountry GetCountry(string countryName)
{
    local XGCountry ctry;
    local int i;

    for (i = 0; i < 36; ++i)
    {
        ctry = Country(i);
        if (ctry.IsCouncilMember() && ctry.GetName() == countryName)
        {
            return ctry;
        }
    }

    `Log("JournalProcessor.GetCountry: Unknown country name " $ countryName);
    return Country(0);
}

function int GetCountryIndexByName(string countryName)
{
    local XGCountry ctry;
    ctry = GetCountry(countryName);
    return GetCountryIndex(ctry);
}

function int GetCountryIndex(XGCountry ctry)
{
    switch(ctry.GetID())
    {
        case ECountry_USA: return 0;
        case ECountry_Canada: return 1;
        case ECountry_Mexico: return 2;
        case ECountry_Argentina: return 3;
        case ECountry_Brazil: return 4;
        case ECountry_Egypt: return 5;
        case ECountry_SouthAfrica: return 6;
        case ECountry_Nigeria: return 7;
        case ECountry_UK: return 8;
        case ECountry_Russia: return 9;
        case ECountry_France: return 10;
        case ECountry_Germany: return 11;
        case ECountry_China: return 12;
        case ECountry_Japan: return 13;
        case ECountry_India: return 14;
        case ECountry_Australia: return 15;
        default:
            `Log("JournalProcessor.GetCountryIndex: Country is not a council member? " $ ctry.GetName());
            return 0;
    }
}

function EMissionType GetMissionTypeFromString(String missionType)
{
    local EMissionType eMissionType;

    switch(missionType)
    {
        case "eMission_Abduction": eMissionType = eMission_Abduction; break;
        case "eMission_Crash": eMissionType = eMission_Crash; break;
        case "eMission_LandedUFO": eMissionType = eMission_LandedUFO; break;
        case "eMission_CovertOpsExtraction": eMissionType = eMission_CovertOpsExtraction; break;
        case "eMission_CaptureAndHold": eMissionType = eMission_CaptureAndHold; break;
        case "eMission_HQAssault": eMissionType = eMission_HQAssault; break;
        case "eMission_AlienBase": eMissionType = eMission_AlienBase; break;
        case "eMission_TerrorSite": eMissionType = eMission_TerrorSite; break;
        case "eMission_Final": eMissionType = eMission_Final; break;
        case "eMission_Special": eMissionType = eMission_Special; break;
        case "eMission_DLC": eMissionType = eMission_DLC; break;
        case "eMission_ExaltRaid": eMissionType = eMission_ExaltRaid; break;
        default: 
            `Log("JournalProcessor.GetMissionTypeFromString: Unknown mission type " $ missionType);
            eMissionType = eMission_None;
    }
    return eMissionType;
}

function AddRecord(CSEvent e)
{
    m_kRecords[m_kRecords.Length-1].events.AddItem(e);
}

function RecordRawEvent(String entry)
{
    local CSEvent_Raw rawEvent;
    
    rawEvent = Spawn(class'CSEvent_Raw');
    rawEvent.AddString(entry);
    AddRecord(rawEvent);
}

function AddSatellite(XGDateTime date, String entry, int idx)
{
    local string countryName;

    // Country name is on the right after "Satellite launched over "
    countryName = Right(entry, Len(entry)-24);

    // Remove everything following " ... " from " ... New Panic Level: XX"
    idx = InStr(countryName, " ...");
    countryName = Left(countryName, idx);
    idx = GetCountryIndexByName(countryName);
    m_kRecords[m_kRecords.Length-1].satellite = m_kRecords[m_kRecords.Length-1].satellite | (1<<idx);
    RecordRawEvent("Satellite launched over " $ countryName);
}

function WithdrawCountry(XGDateTime date, String entry, int idx)
{
    local string countryName;

    // Country name is on the left before " has withdrawn from the XCom project"
    countryName = Left(entry, idx);
    idx = GetCountryIndexByName(countryName);
    m_kRecords[m_kRecords.Length-1].withdrew = m_kRecords[m_kRecords.Length-1].withdrew | (1<<idx);
    m_kRecords[m_kRecords.Length-1].satellite = m_kRecords[m_kRecords.Length-1].satellite & ~(1<<idx);
    RecordRawEvent(countryName $ " has withdrawn from the XCom project");
}

function StartedResearch(XGDateTime date, String entry, int idx)
{
    local string projectName;
    projectName = Right(entry, Len(entry) - 25);
    projectName = Left(projectName, InStr(projectName, " ETA"));
    RecordRawEvent("Started research project " $ projectName);
}

function FinishedResearch(XGDateTime date, String entry, int idx)
{
    local string projectName;
    projectName = Right(entry, Len(entry) - 22);
    projectName -= Chr(10);
    RecordRawEvent("Finished research project " $ projectName);
}

function StartedFacility(XGDateTime date, String entry, int idx)
{
    local string facilityName;
    facilityName = Right(entry, Len(entry) - 33);
    RecordRawEvent("Started construction of facility " $ facilityName);
}

function FinishedFacility(XGDateTime date, String entry, int idx)
{
    local string facilityName;
    facilityName = Right(entry, Len(entry) - 39);
    facilityName -= Chr(10);
    RecordRawEvent("Finished construction of facility " $ facilityName);
}

function CanceledFacility(XGDateTime date, String entry, int idx)
{
    local string facilityName;
    facilityName = Right(entry, Len(entry) - 34);
    facilityName -= Chr(10);
    RecordRawEvent("Canceled contruction of facility " $ facilityName);
}

function RemovedFacility(XGDateTime date, String entry, int idx)
{
    local string facilityName;
    facilityName = Right(entry, Len(entry) - 33);
    facilityName -= Chr(10);
    RecordRawEvent("Removed facility " $ facilityName);
}

function StartedItemConstruction(XGDateTime date, String entry, int idx)
{
    local string itemName;
    local int count;
    local array<string> parts;
    
    itemName = Right(entry, Len(entry) - 24);
    parts = SplitString(itemName, " ", true);

    // Parse the xN item count
    count = ParseInt(Right(parts[parts.Length-1], Len(parts[parts.Length-1]) - 1));

    parts.Length = parts.Length-1;
    JoinArray(parts, itemName, " ", true);
    RecordRawEvent("Started construction of " $ itemName $ " (x" $ count $ ")");
}

function FinishedItemConstruction(XGDateTime date, String entry, int idx)
{
    local array<string> parts;
    local int count;
    local string itemName;

    parts = SplitString(entry, " ", true);

    // Remove "Built"
    parts.Remove(0, 1);

    count = ParseInt(parts[0]);

    // Remove "n" "items" "of" "type"
    parts.Remove(0, 4);

    JoinArray(parts, itemName, " ", true);
    itemName -= Chr(10);
    RecordRawEvent("Finished construction of " $ itemName $ " (x" $ count $ ")");
}

function CanceledItemConstruction(XGDateTime date, String entry, int idx)
{
    local string itemName;
    local int count;
    local array<string> parts;
    
    itemName = Right(entry, Len(entry) - 25);
    parts = SplitString(itemName, " ", true);

    // Parse the xN item count
    count = ParseInt(Right(parts[parts.Length-1], Len(parts[parts.Length-1]) - 1));

    parts.Length = parts.Length-1;
    JoinArray(parts, itemName, " ", true);
    RecordRawEvent("Canceled construction of " $ itemName $ " (x" $ count $ ")");
}

function StartedFoundryProject(XGDateTime date, String entry, int idx)
{
    local string projectName; 
    local array<string> parts;
    parts = SplitString(entry, " ", true);
    parts.Remove(0, 3);
    JoinArray(parts, projectName, " ", true);
    projectName -= Chr(10);

    RecordRawEvent("Started foundry project " $ projectName);
}

function FinishedFoundryProject(XGDateTime date, String entry, int idx)
{
    local string projectName; 
    local array<string> parts;
    parts = SplitString(entry, " ", true);
    // Remove 'finished foundry project for'
    parts.Remove(0, 4);
    JoinArray(parts, projectName, " ", true);
    projectName -= Chr(10);

    RecordRawEvent("Finished foundry project " $ projectName);
}

function PurchasedOTSUpgrade(XGDateTime date, String entry, int idx)
{
    local array<string> parts;
    local string projectName;

    parts = SplitString(entry, " ", true);
    parts.Length = parts.Length - 2;
    parts.Remove(0, 2);
    JoinArray(parts, projectName, " ", true);
    RecordRawEvent("Purchased OTS upgrade " $ projectName);
}

function AwardedMedal(XGDateTime date, String entry, int idx)
{
    local string soldierName;
    local string rankName;
    local int i;

    // Format is: <Rnk> <Soldiername> has been awarded a medal: <MedalName>
    
    // Remove the initial rank from the string.
    for (i = 6; i < 11; ++i)
    {
        idx = InStr(entry, BARRACKS().m_arrMedalNames[i]);
        if (idx == 0)
        {
            // Found it...
            entry = Right(entry, Len(entry) - (Len(BARRACKS().m_arrMedalNames[i]) + 1));
            break;
        }
    }

    // Now locate the new rank (medal) name: may be multiple words
    idx = InStr(entry, " has been awarded a medal: ");

    // Soldier name is 
    soldierName = Left(entry, idx);
    rankName = Right(entry, Len(entry) - (idx + 27));
    rankName -= Chr(10);
    RecordRawEvent("Promoted " $ soldierName $ " to " $ rankName);
}

function ExaltOperation(XGDateTime date, String entry, int idx)
{
    local string operationKind;

    if (InStr(entry, "research hack") != -1)
    {
        operationKind = "research hack";
    }
    else if (InStr(entry, "sabotage") != -1)
    {
        operationKind = "sabotage";
    }
    else if (InStr(entry, "propaganda") != -1)
    {
        operationKind = "propaganda";
    }
    RecordRawEvent("Exalt performed a " $ operationKind $ " operation against X-Com");
}

function ExaltSweep(XGDateTime date, String entry, int idx)
{
    local array<string> parts;
    local int numCells;
    parts = SplitString(entry, " ", true);
    // Expected string to be "X-Com performed a sweep for Exalt, revealing N cells."
    if (parts.Length == 9)
    {
        numCells = ParseInt(parts[7]);
        RecordRawEvent("Intel sweep revealed " $ numCells $ " cell" $ (numCells > 1 ? "s." : "."));
    }
    else
    {
        `Log("Failed to parse exalt sweep string, can't find the number of cells: " $ entry);
        return;
    }
}

function GeneModifiedSoldier(XGDateTime date, String entry, int idx)
{
    local string nameString;
    local string modificationString;
    
    idx = InStr(entry, " has been entered into the gene labs");
    nameString = Left(entry, idx);
    // "So and so has been entered into the gene labs to receive modifications: some mods"
    // the mod names begin idx + 63 characters into the string
    modificationString = Right(entry, Len(entry) - (63 + idx));
    RecordRawEvent(nameString $ " has been entered into the gene labs for " $ modificationString);
}

function SatelliteShotDown(XGDateTime date, String entry, int idx)
{
    local int iCountry;
    local XGCountry ctry;
    local int countryIdx;

    // Remember that we saw this for future events.
    m_bSawSatelliteShotDown = true;
    
    // Satellite shot down over <country>
    entry = Right(entry, Len(entry) - 25);
    iCountry = ParseInt(entry);
    ctry = Country(iCountry);

    countryIdx = GetCountryIndex(ctry);
    m_kRecords[m_kRecords.Length-1].satellite = m_kRecords[m_kRecords.Length-1].satellite & ~(1<<countryIdx);
    RecordRawEvent("Satellite over " $ ctry.GetName() $ " was shot down by a UFO");
}

// <Interceptor> was shot down by a <ufo type> over <country>
function InterceptorShotDown(String entry)
{
    local string interceptorName;
    local string countryName;
    local string ufoName;
    local int idx;
    local int ufoIdx;

    idx = InStr(entry, " was shot down by a ");
    interceptorName = Left(entry, idx);
    entry = Right(entry, Len(entry) - (idx + 20));

    // Find the ufo type
    idx = InStr(entry,  " over ");
    ufoName = Left(entry, idx);
    ufoIdx = ParseInt(ufoName);
    if (ufoIdx > 0 && ufoIdx < 16)
    {
        ufoName = ITEMTREE().ShipTypeNames[ufoIdx];
    }
    else
    {
        ufoName = "[Unknown UFO]";
    }
    countryName = Right(entry, Len(entry) - (idx + 6));
    countryName -= Chr(10);
    RecordRawEvent(interceptorName $ " was shot down by a " $ ufoName $ " over " $ countryName);
}

// <Interceptor> shot down a <ufo> over <country>
function UFOShotDown(String entry)
{
    local string interceptorName;
    local string ufoName;
    local string countryName;
    local int idx;
    local int ufoIdx;

    idx = InStr(entry, " shot down a ");
    interceptorName = Left(entry, idx);
    entry = Right(entry, Len(entry) - (idx + 13));

    idx = InStr(entry, " over ");
    ufoName = Left(entry, idx);
    ufoIdx = ParseInt(ufoName);
    if (ufoIdx > 0 && ufoIdx < 16)
    {
        ufoName = ITEMTREE().ShipTypeNames[ufoIdx];
    }
    else
    {
        ufoName = "[Unknown UFO]";
    }
    countryName = Right(entry, Len(entry) - (idx + 6));
    countryName -= Chr(10);
    RecordRawEvent(interceptorName $ " shot down a " $ ufoName $ " over " $ countryName);
}

// <interceptor> destroyed a <ufo> over <country>
function UFODestroyed(String entry)
{
    local string interceptorName;
    local string ufoName;
    local string countryName;
    local int idx;
    local int ufoType;

    idx = InStr(entry, " destroyed a ");
    interceptorName = Left(entry, idx);
    entry = Right(entry, Len(entry) - (idx + 13));

    idx = InStr(entry, " over ");
    ufoName = Left(entry, idx);
    ufoType = ParseInt(ufoName);
    if (ufoType > 0 && ufoType < 16)
    {
        ufoName = ITEMTREE().ShipTypeNames[ufoType];
    }
    else
    {
        ufoName = "[unknown UFO]";
    }
    countryName = Right(entry, Len(entry) - (idx + 6));
    countryName -= Chr(10);
    RecordRawEvent(interceptorName $ " destroyed a " $ ufoName $ " over " $ countryName);
}

// Mission expired: <type> in <location>
function MissionExpired(String entry)
{
    local string missionTypeStr;
    local int missionType;
    local string locStr;
    local CSEvent_ExpiredMission kExpiredMission;
    local int idx;

    //Strip off the initial Mission expired: 
    entry = Right(entry, Len(entry)-17);
    
    idx = InStr(entry, " in ");
    missionTypeStr = Left(entry, idx);
    missionType = ParseInt(missionTypeStr);
    locStr = Right(entry, Len(entry) - (idx + 4));
    kExpiredMission = Spawn(class'CSEvent_ExpiredMission');
    kExpiredMission.SetType(EMissionType(missionType));
    kExpiredMission.SetLoc(locStr);
    AddRecord(kExpiredMission);
}

function AddPanicData(XGDateTime date, String entry, int idx)
{
    local string countryName;
    local int countryIdx;
    local int newPanic;
    local int oldPanic;
    local array<string> parts;

    countryName = Left(entry, idx-1);
    countryIdx = GetCountryIndexByName(countryName);

    // The final panic value should be in the last word.
    parts = SplitString(entry, " ", true);

    // Add one to panic values: they're recorded in the journal (and in XGCountry) as
    // values from 0-99 but displayed in the UI and on screen as values from 1-100
    newPanic = ParseInt(parts[parts.Length-1]) + 1;
    oldPanic = ParseInt(parts[parts.Length-3]) + 1;
    
    m_kRecords[m_kRecords.Length-1].panic[countryIdx] = newPanic;

    // Don't record the change in the log on the first day, as there are many repeated
    // small panic adjustments as initial panic gets distributed.
    if (!m_kRecords[m_kRecords.Length - 1].date.IsFirstDay())
    {
        // Note: New panic is recorded as 1 more than recorded in the journal: it's recorded
        // in XGCountry as a value from 0 to 99 but is shown in the UI as ranging from 1 to 100.
        if (newPanic > oldPanic)
        {
            RecordRawEvent("Panic has increased to " $ (newPanic) $ " in " $ countryName);
        }
        else
        {
            RecordRawEvent("Panic has decreased to " $ (newPanic) $ " in " $ countryName);
        }
    }

    // Is this panic increase by the SAT_DESTROYED amount?
    if (!m_bSawSatelliteShotDown && (newPanic-oldPanic == class'XGTacticalGameCore'.default.PANIC_SAT_DESTROYED_COUNTRY))
    {
        // Yep. Add a "satellite destroyed" event and remove the sat.
        SatelliteShotDown(date, "Satellite shot down over " $ GetCountry(countryName).GetID(), 0);
    }

}

function CompletedMission(XGDateTime date, String entry, int idx)
{
    local string missionType;
    local string missionResult;
    local array<string> parts;
    local array<string> subparts;
    local int i;
    local CSEvent_Mission kMission;
    local XGGameData.EMissionType eMissionType;
    local XGBattle.EBattleResult eMissionResult;
    local String coords;
    local Vector v;
    local Vector2D v2;

    kMission = Spawn(class'CSEvent_Mission');

    parts = SplitString(entry, Chr(10), true);

    // First line is blank
    // Second line is all #####s
    // Third line is Operation name

    if (InStr(parts[2], "Operation ") != 0)
    {
        `Log("JournalProcessor.CompletedMission: Expected operation name on 2nd line but found " $ parts[2]);
        kMission.SetName("unknown operation name");
    }
    else
    {
        kMission.SetName(parts[2]);
    }

    for (i = 3; i < parts.Length; ++i)
    {
        if (InStr(parts[i], "Mission Type") != -1)
        {
            subparts = SplitString(parts[i], " ", true);
            missionType = subparts[subparts.Length -1];
            eMissionType = GetMissionTypeFromString(missionType);
            kMission.SetType(eMissionType);
        }

        idx = InStr(parts[i], "Location: ");
        if (idx != -1)
        {
            kMission.SetLoc(Right(parts[i], Len(parts[i])-10));
        }

        idx = InStr(parts[i], "Coordinates: ");
        if (idx != -1)
        {
            coords = Right(parts[i], Len(parts[i]) - 13);
            v = Vector(coords);
            v2.X = v.X;
            v2.Y = v.Y;
            kMission.SetCoords(v2);
        }

        if (InStr(parts[i], "Result") == 0)
        {
            subparts = SplitString(parts[i], " ", true);
            missionResult = subparts[subparts.Length-1];
            switch(missionResult)
            {
                case "eResult_Victory": eMissionResult = eResult_Victory; break;
                case "eResult_Defeat": eMissionResult = eResult_Defeat; break;
                case "eResult_Abandon": eMissionResult = eResult_Abandon; break;
                case "eResult_TimeOut": eMissionResult = eResult_TimeOut; break;
                default:
                    `Log("JournalProcessor.CompletedMission: Unknown mission result: " $ missionResult);
                    eMissionResult = eResult_UNINITIALIZED;
                    break;
            }
            kMission.SetResult(eMissionResult);
        }
    }

    AddRecord(kMission);

    // If this mission was a successful base assault, return the country to X-Com
    if (eMissionType == eMission_AlienBase && eMissionResult == eResult_Victory && kMission.m_strLoc != "")
    {
        // The location should be just "Country"
        idx = GetCountryIndexByName(kMission.m_strLoc);
        m_kRecords[m_kRecords.Length-1].withdrew = m_kRecords[m_kRecords.Length-1].withdrew & ~(1<<idx);
    }
}

function AddEntry(XGDateTime date, String entry)
{
    local int idx;
    local TDayRecord record;

    // First, add the raw entry.
    if (m_kRecords.Length == 0 || !m_kRecords[m_kRecords.Length-1].date.DateEquals(date))
    {
        // No entry yet or the last entry is from a different date. Copy all info from previous
        // records.
       
        if (m_kRecords.Length > 0 && m_kRecords[m_kRecords.Length-1].events.Length == 0)
        {
            // Previous day had no unfiltered events. Re-use it.
            m_kRecords[m_kRecords.Length-1].date.CopyDateTime(date);
        }
        else
        {
            record = m_kRecords[m_kRecords.Length-1];
            record.date = Spawn(class'XGDateTime');
            record.date.CopyDateTime(date);
            record.events.Length = 0;
            m_kRecords.AddItem(record);
        }
    }

    // Figure out the entry kind.
    idx = InStr(entry, "has gone from panic level");
    if (idx != -1)
    {
        // It's a panic adjustment. Figure out the country
        AddPanicData(date, entry, idx);
        return;
    }

    idx = InStr(entry, "Satellite launched over");
    if (idx != -1)
    {
        AddSatellite(date, entry, idx);
        return;
    }

    idx = InStr(entry, " has withdrawn");
    if (idx != -1)
    {
        WithdrawCountry(date, entry, idx);
        return;
    }

    idx = InStr(entry, "Completed Mission");
    if (idx != -1)
    {
        CompletedMission(date, entry, idx);
        return;
    }

    idx = InStr(entry, "Sold alien techology");
    if (idx == 0)
    {
        //TODO Sold items
        return;
    }

    idx = InStr(entry, "XCom paid maintenance ");
    if (idx == 0)
    {
        // TODO maintenance
        return;
    }

    idx = InStr(entry, "X-Com gained");
    if (idx != 0)
    {
        idx = InStr(entry, "X-Com lost");
    }
    if (idx == 0)
    {
        // TODO Resources    
        return;
    }

    idx = InStr(entry, "Started research project");
    if (idx == 0)
    {
        StartedResearch(date, entry, idx);
        return;
    }

    idx = InStr(entry, "Finished research");
    if (idx == 0)
    {
        FinishedResearch(date, entry, idx);
        return;
    }

    idx = InStr(entry, "Started construction of facility");
    if (idx == 0)
    {
        StartedFacility(date, entry, idx);
        return;
    }

    idx = InStr(entry, "Finished construction of facility type");
    if (idx == 0)
    {
        FinishedFacility(date, entry, idx);
        return;
    }

    idx = InStr(entry, "Started construction project of type");
    if (idx == 0)
    {
        //TODO excavation
        return;
    }

    idx = InStr(entry, "Started construction of");
    if (idx == 0)
    {
        StartedItemConstruction(date, entry, idx);
        return;
    }

    idx = InStr(entry, "Built ");
    if (idx == 0)
    {
        FinishedItemConstruction(date, entry, idx);
        return;
    }

    idx = InStr(entry, "X-Com completed excavation");
    if (idx == 0)
    {
        //TODO completed excavation
        return;
    }

    idx = InStr(entry, "received a funding council reward");
    if (idx != -1)
    {
        // TODO funding council reward
        return;
    }

    idx = InStr(entry, "Purchased the ");
    if (idx == 0)
    {
        PurchasedOTSUpgrade(date, entry, idx);
        return;
    }

    idx = InStr(entry, "awarded a medal");
    if (idx != -1)
    {
        AwardedMedal(date, entry, idx);
        return;
    }

    idx = InStr(entry, "Started foundry project");
    if (idx != -1)
    {
        StartedFoundryProject(date, entry, idx);
        return;
    }

    idx = InStr(entry, "Finished foundry project");
    if (idx != -1)
    {
        FinishedFoundryProject(date, entry, idx);
        return;
    }

    idx = InStr(entry, "Exalt successfully placed");
    if (idx == 0)
    {
        // Exalt cell generated
        return;
    }

    idx = InStr(entry, "Exalt performed a");
    if (idx == 0)
    {
        ExaltOperation(date, entry, idx); 
        return;
    }

    idx = InStr(entry, "X-Com performed a sweep for Exalt");
    if (idx == 0)
    {
        ExaltSweep(date, entry, idx);
        return;
    }

    idx = InStr(entry, "XCom purchased ");
    if (idx == 0)
    {
        // TODO Handle interceptor purchase
        //PurchasedInterceptor(date, entry, idx);
        return;
    }

    idx = InStr(entry, "has been entered into the gene labs");
    if (idx != -1)
    {
        GeneModifiedSoldier(date, entry, idx);
        return;
    }

    idx = InStr(entry, "has successfully trained a new psionic ability");
    if (idx != -1)
    {
        //TODO Psi trained
        return;
    }

    idx = InStr(entry, "Upgraded or built MEC of type");
    if (idx != -1)
    {
        return;
    }
    
    idx = InStr(entry, "Canceled construction of facility");
    if (idx != -1)
    {
        CanceledFacility(date, entry, idx);
        return;
    }

    idx = InStr(entry, "Canceled construction of");
    if (idx != -1)
    {
        CanceledItemConstruction(date, entry, idx);
        return;
    }

    idx = InStr(entry, "X-Com removed a facility of type");
    if (idx == 0)
    {
        RemovedFacility(date, entry, idx);
        return;
    }

    idx = InStr(entry, "Satellite shot down over ");
    if (idx == 0)
    {
        SatelliteShotDown(date, entry, idx);
        return;
    }

    idx = InStr(entry, " was shot down by a ");
    if (idx != -1)
    {
        InterceptorShotDown(entry);
        return;
    }

    idx = InStr(entry, " destroyed a ");
    if (idx != -1)
    {
        UFODestroyed(entry);
        return;
    }

    idx = InStr(entry, " shot down a ");
    if (idx != -1)
    {
        UFOShotDown(entry);
        return;
    }

    idx = InStr(entry, "Mission expired: ");
    if (idx == 0)
    {
        MissionExpired(entry);
        return;
    }

    idx = InStr(entry, "XCom hired ");
    if (idx == 0)
    {
        // TODO hired soldiers
        return;
    }

    `Log("Unrecognized entry: " $ entry);
    RecordRawEvent(" * " $ entry);
}

function ProcessOneEntry(XGRecapSaveData recapData)
{
    local int firstColon;
    local int secondColon;
    local String entry;
    local String dateTimeStr;
    local XGDateTime date;
    
    entry = recapData.m_aJournalEvents[m_iLastProcessedIndex+1];
    

    // No matter what, we want to be done with this entry when we leave this
    // function, so increment it now.
    m_iLastProcessedIndex++;

    if (InStr(entry, "\n") == 0)
    {
        // Not an interesting entry.
        return;
    }

    // Check for bugged starting entries starting with "  :"
    if (InStr(entry, "  :") == 0)
    {
        date = Spawn(class'XGDateTime');
        date.SetTime(0, 0, 0, date.START_MONTH, date.START_DAY, date.START_YEAR);
        entry = Right(entry, Len(entry)-4);
    }
    else 
    {
        firstColon = InStr(entry, ":");
        if (firstColon == -1)
        {
            // Unknown entry format
            `Log("JournalProcessor: ERROR: Unknown entry format " $ entry);
            return;
        }

        secondColon = InStr(Right(entry,(Len(entry)-firstColon-1)), ":");
        if (secondColon == -1)
        {
            `Log("JournalProcessor: ERROR: Unknown entry format " $ entry);
            return;
        }

        dateTimeStr = Left(entry, firstColon+secondColon+1);
        date = ParseDate(dateTimeStr);
        entry = Right(entry, Len(entry)-firstColon-secondColon-3);
    }
    // Workaround a bug in the initial patch to add locations to mission entries
    entry = Repl(entry, "\\n", Chr(10), false);
    AddEntry(date, entry);
}

function ProcessEntries()
{
    local XGRecapSaveData recapData;

    recapData = XComHeadquartersGame(class'Engine'.static.GetCurrentWorldInfo().Game).GetGameCore().m_kRecapSaveData;

    if (recapData.m_aJournalEvents.Length > (m_iLastProcessedIndex+1) && GEOSCAPE().m_kDateTime != none)
    {
        ProcessOneEntry(recapData);
        SetTimer(0.1, false, 'ProcessEntries');
    }
    else
    {
        SetTimer(5, false, 'ProcessEntries');
    }
}

defaultproperties
{
    m_iLastProcessedIndex=-1
    m_kLastProcessedDate=none
    m_bSawSatelliteShotDown=false
}

