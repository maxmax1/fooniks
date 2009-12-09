/*
*    The contents of this file are subject to the Mozilla Public License
*    Version 1.1 (the "License"); you may not use this file except in
*    compliance with the License. You may obtain a copy of the License at
*    http://www.mozilla.org/MPL/
*    
*    Software distributed under the License is distributed on an "AS IS"
*    basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*    License for the specific language governing rights and limitations
*    under the License.
*    
*    The Original Code is Phoenix.
*    The Initial Developers of the Original Code are Jyrno42 and 13th.
*/

/*
*    This File: phoenix_StreetCleaner.inc
*    Purpose:  A garbage collecting job for phoenix.
*/

#if !defined _phoenix_included
	#error "Phoenix ERROR #1, You need phoenix base for this gamemode to run!"
	#endinput
#endif

#if !defined _phoenix_JobSystem_included
	#error "GarbageCollector Job needs phoenix_JobSystem!"
	#endinput
#endif

/*
*    Defines
*/
#define MAX_GARBAGE_POINTS 64
#define GARBAGE_MONEY 50
#define GARBAGE_JOB_ID 1
#define GARBAGE_TRUCK 408

// Private functions
forward AddGarbagePoint(Float: x, Float: y, Float: z);
forward StartPath(playerid, PathId);
forward GarbagePath(playerid);
forward PathEnd(playerid);

// Syncing forwards.
forward CJob_OnPlayerEnterCheckpoint(playerid);

Itter_Create(GarbagePoints, MAX_GARBAGE_POINTS);

enum garbPointsInf
{
	Float: garbX,
	Float: garbY,
	Float: garbZ
}
new GarbageCheckPoints[MAX_GARBAGE_POINTS][garbPointsInf];
new garbPointsUsed = 0;

enum garbagePlayersInf
{
	bool: onGRound,
	numGPoints,
	cpId
};
new GarbagePlayer[MAX_PLAYERS][garbagePlayersInf];

JOBS_OnJobInit(GCollector)
{
	AddGarbagePoint(2497.7292, -1681.5367, 13.1551);
	AddGarbagePoint(2403.9653, -1654.0575, 13.2224);	
	AddGarbagePoint(2272.0327, -1653.7729, 15.0048);
	AddGarbagePoint(2005.541, -1609.274, 13.2192);
	AddGarbagePoint(1997.23, -1655.2301, 13.2625);
	AddGarbagePoint(2076.1912, -1705.0613, 13.2646);
	AddGarbagePoint(2257.8291, -1898.5248, 13.2665);
	AddGarbagePoint(2349.7646, -1998.0045, 13.172);
	AddGarbagePoint(2439.6208, -2014.6731, 13.2475);
	AddGarbagePoint(2718.9502, -2028.2637, 13.2166);
	AddGarbagePoint(2773.9883, -2000.5878, 13.3552);
	AddGarbagePoint(2597.2097, -1249.4607, 47.1614);
	AddGarbagePoint(2563.2588, -1280.4109, 45.9333);
	AddGarbagePoint(2564.4216, -1452.6285, 23.7809);
	AddGarbagePoint(2494.9558, -1498.3657, 23.7829);
	AddGarbagePoint(2426.2095, -1463.1338, 23.7101);
	AddGarbagePoint(2367.3408, -1333.467, 23.6878);
	AddGarbagePoint(2425.5952, -1261.6375, 23.7137);
	AddGarbagePoint(2695.3682, -1251.5393, 57.1408);
	AddGarbagePoint(2745.644, -1278.9292, 57.6268);
	AddGarbagePoint(2744.3728, -1426.5873, 30.9157);
	AddGarbagePoint(2850.5132, -1555.161, 10.8503);
	AddGarbagePoint(2802.3152, -1336.1127, 30.7603);
	AddGarbagePoint(2793.0432, -1251.4083, 46.7573);
	AddGarbagePoint(2637.1135, -1068.8735, 69.3275);
	AddGarbagePoint(2579.1077, -1040.5352, 69.3766);
	AddGarbagePoint(2545.1021, -1040.5966, 69.3767);
	AddGarbagePoint(2451.1851, -1026.4686, 58.4054);
	AddGarbagePoint(2378.9658, -1035.7756, 53.6834);
	AddGarbagePoint(2271.571, -1048.6743, 49.416);
	AddGarbagePoint(2197.7463, -1007.2318, 62.0155);
	AddGarbagePoint(2029.8365, -962.8117, 40.5086);
	AddGarbagePoint(1905.5948, -1088.3898, 24.0654);
	AddGarbagePoint(2012.5916, -1099.9464, 24.6819);
	AddGarbagePoint(2110.4189, -1065.1085, 25.523);
	AddGarbagePoint(1279.1864, -613.0311, 102.4644);
	AddGarbagePoint(1241.5123, -738.4109, 95.4786);
	AddGarbagePoint(1071.1918, -777.2178, 107.2469);
	AddGarbagePoint(1019.7954, -793.1988, 102.0088);
	AddGarbagePoint(966.9901, -816.9537, 97.0199);
	AddGarbagePoint(913.4783, -836.74, 92.5763);
	AddGarbagePoint(870.5432, -982.2148, 35.3499);
	AddGarbagePoint(733.6482, -1135.7968, 18.2001);
	AddGarbagePoint(733.6482, -1135.7968, 18.2001);
	foreach(Player, i)
	{
		GarbagePlayer[i][cpId] = -1;
		GarbagePlayer[i][onGRound] = false;
		GarbagePlayer[i][numGPoints] = 0;
	}
	AddJobCommand(GARBAGE_JOB_ID, "prügiring");
}

JOBS_OnPlayerConnect(GCollector)
{
	GarbagePlayer[playerid][cpId] = -1;
	GarbagePlayer[playerid][onGRound] = false;
	GarbagePlayer[playerid][numGPoints] = 0;
}

JOBS_OnPlayerDisconnect(GCollector)
{
	GarbagePlayer[playerid][cpId] = -1;
	GarbagePlayer[playerid][onGRound] = false;
	GarbagePlayer[playerid][numGPoints] = 0;
}

public AddGarbagePoint(Float: x, Float: y, Float: z)
{
	if(garbPointsUsed >= MAX_GARBAGE_POINTS) return -1;
	GarbageCheckPoints[garbPointsUsed][garbX] = x;
	GarbageCheckPoints[garbPointsUsed][garbY] = y;
	GarbageCheckPoints[garbPointsUsed][garbZ] = z;
	
	Itter_Add(GarbagePoints, garbPointsUsed);
	garbPointsUsed++;
	return garbPointsUsed-1;
}

public StartPath(playerid, PathId)
{
	if(PathId == -1) return 0;
	GarbagePlayer[playerid][cpId] = SetPlayerCheckpoint(playerid, GarbageCheckPoints[PathId][garbX], GarbageCheckPoints[PathId][garbY], GarbageCheckPoints[PathId][garbZ], 3.0);
	return 1;
}

public GarbagePath(playerid)
{
	GarbagePlayer[playerid][numGPoints]++;
	
	if(GarbagePlayer[playerid][numGPoints] == 16)
	{
		GarbagePlayer[playerid][cpId] = SetPlayerCheckpoint(playerid, 2413.7822, -1425.1913, 23.9835, 3.0);
		SmallHelpDrawShow(playerid, "Masin on täis, tühjenda see Taaskasutuskeskuses.", 5);
	}
	else if(GarbagePlayer[playerid][numGPoints] > 16)
	{
		PathEnd(playerid);
	}
	else
	{
		new PathId = Itter_Random(GarbagePoints);
		StartPath(playerid, PathId);
		
		new string[128];
		format(string, 128, "~b~Masin: ~n~~n~~w~%d/16", GarbagePlayer[playerid][numGPoints]-1);
		SmallHelpDrawShow(playerid, string, 5);
	}
}

public PathEnd(playerid)
{
	GarbagePlayer[playerid][onGRound] = false;
	GarbagePlayer[playerid][numGPoints] = 0;
	
    #if defined _phoenix_Money_included
		GivePlayerMoneyNew(playerid, GARBAGE_MONEY);
	#else
		GivePlayerMoney(playerid, GARBAGE_MONEY);
	#endif
	
	SmallHelpDrawShow(playerid, "Lõpetasid prügiringi, teenisid 50 ühikut.", 5);
	DisablePlayerCheckpoint(playerid);
	return 1;
}

/*
*    Commands for the job!
*/

COMMAND:prygiring(playerid, params[])
{
	if(gMyJob[playerid] != GARBAGE_JOB_ID) 	return SendClientMessage(playerid, COLOR_RED, "Sa ei ole tänavapuhastaja!");
	if(GarbagePlayer[playerid][onGRound])  	return SendClientMessage(playerid, COLOR_RED, "Sa oled juba prügiringil!");
	new VehicleId = GetPlayerVehicleID(playerid);
	if(VehicleId == 0 || GetVehicleModel(VehicleId) != GARBAGE_TRUCK)
	{
		return SendClientMessage(playerid, COLOR_RED, "Sa pole prügiautos!");
	}
	
	GarbagePath(playerid);
	GarbagePlayer[playerid][onGRound] = true;
	SendClientMessage(playerid, COLOR_GREEN, "Alustasid prügiringi, sõida punaste markerite järgi.");
	return 1;
}

// SILENT INCLUDE

public OnPlayerEnterCheckpoint(playerid)
{
	if(GarbagePlayer[playerid][onGRound])
	{
		GarbagePath(playerid);
	}
	
    if (funcidx("CJob_OnPlayerEnterCheckpoint") != -1)
    {
        return CallLocalFunction("CJob_OnPlayerEnterCheckpoint", "i", playerid);
    }
    return 1;
}

#if defined _ALS_OnPlayerEnterCheckpoint
    #undef OnPlayerEnterCheckpoint
#else
    #define _ALS_OnPlayerEnterCheckpoint
#endif
#define OnPlayerEnterCheckpoint CJob_OnPlayerEnterCheckpoint