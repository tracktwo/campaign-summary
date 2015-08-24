============================================================
XCOM CAMPAIGN SUMMARY
By tracktwo
Version: 1.0b
============================================================

Table Of Contents

1. Introduction
2. Installation
3. Known Issues

============================================================
1. INTRODUCTION
============================================================

The Campaign Summary mod adds a new menu item "Campaign Summary" to the
Situation Room. This new UI displays a timeline of your campaign including
most major strategic layer events from the begining of the campaign through
to the current date.

IMPORTANT: This is a BETA release of the Campaign Summary and may contain
bugs. I don't think this will break your campaign but BACK UP YOUR SAVES!

============================================================
2. INSTALLATION
============================================================

Campaign Summary requires the following:

- Long War B15 or later (tested with B15f and B15f3)
- Long War Mod Manager

To install, copy the following files from the installation
ZIP to the indicated sub-folders of your XCOM EW folder:

XcomCampaignSummary.u -> CookedPCConsole
gfxCampaignSummary.upk -> CookedPCConsole
DefaultCheckpoint.ini -> Config

Then copy CampaignSummary.txt to your Mod Manager Mods folder
and select it in the Mod Manager to install.

============================================================
3. KNOWN ISSUES
============================================================

The Campaign Summary mod relies on the "journal" that tracks
important events in XCom to generate the display. Unfortunately,
this journal has several bugs in Vanilla XCom, as well as some
gaps in the entries it generates.

This mod works with existing campaigns that were started before
this mod was installed, but due to the bugs and missing entries 
some features may not be working entirely and some events may be 
missing or misinterpreted in these older campaigns, which may lead
to some weird effects in the Summary view. All events recorded
after the mod is installed will have all known bugfixes applied
and new events will begin being recorded.

Some of the known issues:

1. Processing the journal is SLOW. It may take several minutes
for the mod to "catch up" with processing the journal on campaigns
that are late in the game. The journal is processed continually
in the background when you're in the base, and the campaign
summary view can be used while the journal is still being processed
with new entries being added over time. During this catch up period
you will see events only up to the point the mod has processed so
far. The mod saves its current state in your save file so this backlog
only needs to be processed once.

2. Shot-down satellites are not recorded in Vanilla, so the mod
uses a basic heuristic to try to determine if a panic increase in
a country is due to a shot-down satellite. It often gets this wrong,
leading to satellites being listed as shot down when they were not.
The mod explicitly records shot-down satellites and avoids this issue.

3. Shot down UFOs and interceptors are not recorded in vanilla and won't
be shown in the summary for older saves. The mod explicitly records
shot down UFOs and interceptors.

4. Mission location information is not recorded in vanilla. The missions
will show up in the summary view but will not list where they occur nor
will they show an icon on the map. All missions after installation of
the mod will work correctly.



