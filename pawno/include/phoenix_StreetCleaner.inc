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
*    This File: phoenix_CleaningJob.inc
*    Purpose:  A streetcleaner job for phoenix.
*/

// This will add a streetcleaner job to gamemode.

// Job System functions. - Public


#if !defined _phoenix_included
	#error "Phoenix ERROR #1, You need phoenix base for this gamemode to run!"
	#endinput
#endif

#if !defined _phoenix_JobSystem_included
	#error "StreetCleaner Job needs phoenix_JobSystem!"
	#endinput
#endif

/*
*    Defines
*/
#define MAX_CLEAN_POINTS 64
#define CLEANING_MONEY 50
#define CLEAN_JOB_ID 1

// Private functions
forward AddCleaningPoint(Float: x, Float: y, Float: z);
forward StartPath(playerid, PathId);
forward CleanPath(playerid);
forward PathEnd(playerid);

// Syncing forwards.
forward CJob_OnPlayerEnterCheckpoint(playerid);

Itter_Create(CleanPoints, MAX_CLEAN_POINTS);

enum cleanPointsInf
{
	Float: cleanX,
	Float: cleanY,
	Float: cleanZ
}
new CleanCheckPoints[MAX_CLEAN_POINTS][cleanPointsInf];
new cleanPointsUsed = 0;

enum cleanPlayersInf
{
	bool: isCleaning,
	numCleanpoints,
	cpId
};
new CleanPlayer[MAX_PLAYERS][cleanPlayersInf];

JOBS_OnJobInit(SCleaner)
{
	printf("ICANHASHAPPY");
	AddCleaningPoint(2497.7292, -1681.5367, 13.1551);
	AddCleaningPoint(2403.9653, -1654.0575, 13.2224);	
	AddCleaningPoint(2272.0327, -1653.7729, 15.0048);
	AddCleaningPoint(2005.541, -1609.274, 13.2192);
	AddCleaningPoint(1997.23, -1655.2301, 13.2625);
	AddCleaningPoint(2076.1912, -1705.0613, 13.2646);
	AddCleaningPoint(2257.8291, -1898.5248, 13.2665);
	AddCleaningPoint(2349.7646, -1998.0045, 13.172);
	AddCleaningPoint(2439.6208, -2014.6731, 13.2475);
	AddCleaningPoint(2718.9502, -2028.2637, 13.2166);
	AddCleaningPoint(2773.9883, -2000.5878, 13.3552);
	AddCleaningPoint(2597.2097, -1249.4607, 47.1614);
	AddCleaningPoint(2563.2588, -1280.4109, 45.9333);
	AddCleaningPoint(2564.4216, -1452.6285, 23.7809);
	AddCleaningPoint(2494.9558, -1498.3657, 23.7829);
	AddCleaningPoint(2426.2095, -1463.1338, 23.7101);
	AddCleaningPoint(2367.3408, -1333.467, 23.6878);
	AddCleaningPoint(2425.5952, -1261.6375, 23.7137);
	AddCleaningPoint(2695.3682, -1251.5393, 57.1408);
	AddCleaningPoint(2745.644, -1278.9292, 57.6268);
	AddCleaningPoint(2744.3728, -1426.5873, 30.9157);
	AddCleaningPoint(2850.5132, -1555.161, 10.8503);
	AddCleaningPoint(2802.3152, -1336.1127, 30.7603);
	AddCleaningPoint(2793.0432, -1251.4083, 46.7573);
	AddCleaningPoint(2637.1135, -1068.8735, 69.3275);
	AddCleaningPoint(2579.1077, -1040.5352, 69.3766);
	AddCleaningPoint(2545.1021, -1040.5966, 69.3767);
	AddCleaningPoint(2451.1851, -1026.4686, 58.4054);
	AddCleaningPoint(2378.9658, -1035.7756, 53.6834);
	AddCleaningPoint(2271.571, -1048.6743, 49.416);
	AddCleaningPoint(2197.7463, -1007.2318, 62.0155);
	AddCleaningPoint(2029.8365, -962.8117, 40.5086);
	AddCleaningPoint(1905.5948, -1088.3898, 24.0654);
	AddCleaningPoint(2012.5916, -1099.9464, 24.6819);
	AddCleaningPoint(2110.4189, -1065.1085, 25.523);
	AddCleaningPoint(1279.1864, -613.0311, 102.4644);
	AddCleaningPoint(1241.5123, -738.4109, 95.4786);
	AddCleaningPoint(1071.1918, -777.2178, 107.2469);
	AddCleaningPoint(1019.7954, -793.1988, 102.0088);
	AddCleaningPoint(966.9901, -816.9537, 97.0199);
	AddCleaningPoint(913.4783, -836.74, 92.5763);
	AddCleaningPoint(870.5432, -982.2148, 35.3499);
	AddCleaningPoint(733.6482, -1135.7968, 18.2001);
	AddCleaningPoint(733.6482, -1135.7968, 18.2001);
	foreach(Player, i)
	{
		CleanPlayer[i][cpId] = -1;
		CleanPlayer[i][isCleaning] = false;
		CleanPlayer[i][numCleanpoints] = 0;
	}
}

JOBS_OnPlayerConnect(SCleaner)
{
	CleanPlayer[playerid][cpId] = -1;
	CleanPlayer[playerid][isCleaning] = false;
	CleanPlayer[playerid][numCleanpoints] = 0;
}

JOBS_OnPlayerDisconnect(SCleaner)
{
	CleanPlayer[playerid][cpId] = -1;
	CleanPlayer[playerid][isCleaning] = false;
	CleanPlayer[playerid][numCleanpoints] = 0;
}

public AddCleaningPoint(Float: x, Float: y, Float: z)
{
	if(cleanPointsUsed >= MAX_CLEAN_POINTS) return -1;
	CleanCheckPoints[cleanPointsUsed][cleanX] = x;
	CleanCheckPoints[cleanPointsUsed][cleanY] = y;
	CleanCheckPoints[cleanPointsUsed][cleanZ] = z;
	
	Itter_Add(CleanPoints, cleanPointsUsed);
	cleanPointsUsed++;
	return cleanPointsUsed-1;
}

public StartPath(playerid, PathId)
{
	if(PathId == -1) return 0;
	CleanPlayer[playerid][cpId] = SetPlayerCheckpoint(playerid, CleanCheckPoints[PathId][cleanX], CleanCheckPoints[PathId][cleanY], CleanCheckPoints[PathId][cleanZ], 3.0);
	return 1;
}

public CleanPath(playerid)
{
	CleanPlayer[playerid][numCleanpoints]++;
	
	if(CleanPlayer[playerid][numCleanpoints] > 16)
	{
		PathEnd(playerid);
	}
	else
	{
		new PathId = Itter_Random(CleanPoints);
		StartPath(playerid, PathId);
	}
}

public PathEnd(playerid)
{
	CleanPlayer[playerid][isCleaning] = false;
	CleanPlayer[playerid][numCleanpoints] = 0;
	
    #if defined _phoenix_Money_included
		GivePlayerMoneyNew(playerid, CLEANING_MONEY);
	#else
		GivePlayerMoney(playerid, CLEANING_MONEY);
	#endif
	
	SendClientMessage(playerid, COLOR_GREEN, "Lõpetasid prügiringi, teenisid 50 ühikut.");
	DisablePlayerCheckpoint(playerid);
	return 1;
}

/*
*    Commands for the job!
*/
COMMAND:puhasta(playerid, params[])
{
	if(gMyJob[playerid] != CLEAN_JOB_ID) 	return SendClientMessage(playerid, COLOR_RED, "Sa ei ole tänavapuhastaja!");
	if(CleanPlayer[playerid][isCleaning])  	return SendClientMessage(playerid, COLOR_RED, "Sa oled juba prügiringil!");
	
	CleanPath(playerid);
	CleanPlayer[playerid][isCleaning] = true;
	SendClientMessage(playerid, COLOR_GREEN, "Alustasid prügiringi, sõida punaste markerite järgi.");
	return 1;
}

// SILENT INCLUDE

public OnPlayerEnterCheckpoint(playerid)
{
	if(CleanPlayer[playerid][isCleaning])
	{
		CleanPath(playerid);
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