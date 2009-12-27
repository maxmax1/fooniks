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
*    This File: phoenix_Resting.inc
*    Purpose: This is for resting system.
*/

/*
*    DEFINES
*/

#define MAX_REST_POSITIONS 14
#define REST_SIT 0
#define REST_LAY 1

/*
*    GLOBALS
*/

new restBar;

enum restInf
{
	restType,
	Float: restX,
	Float: restY,
	Float: restZ,
	Float: restAng,
	bool: Taken
};

new RestPositions[MAX_REST_POSITIONS][restInf] = 
{
	{REST_SIT, 0.0, 0.0, 0.0, 0.0, false},
	{REST_LAY, 2.0, 2.0, 2.0, 2.0, false},
	{REST_SIT,1202.5208,2.6604,1001.5255,194.8951, false},
	{REST_SIT,1201.4686,1.3668,1001.5255,271.1574, false},
	{REST_SIT,1201.4637,0.6496,1001.5255,266.7708, false},
	{REST_SIT,1201.5294,-0.6220,1001.5255,265.5174, false},
	{REST_SIT,1201.5164,-2.1263,1001.5255,257.9973, false},
	{REST_SIT,1201.4718,-3.4100,1001.5255,266.1441, false},
	{REST_SIT,1201.5441,-4.1636,1001.5255,270.8441, false},
	{REST_SIT,1201.5792,-5.1626,1001.5255,265.8307, false},
	{REST_SIT,1201.7568,-6.0220,1001.5255,286.7518, false},
	{REST_SIT,1202.1875,-7.2701,1001.5255,344.3098, false},
	{REST_LAY,1201.3108,-7.2603,1001.5255,320.8096, false},
	{REST_LAY,1201.6097,2.2717,1001.5255,222.9037, false}
	
};

new Float: pRest[MAX_PLAYERS];
new bool: pResting[MAX_PLAYERS];
new pRestingAt[MAX_PLAYERS];

/*
*    FORWARDS
*/

forward ClearResting(playerid);
forward Rest(playerid);
forward IsPlayerNearRestingPlace(playerid);
forward RestingEnd(playerid);
forward RestChange();
forward GivePlayerRestprecent(playerid, Float: amount);
forward RestUpdateForPlayer(playerid);

forward Rest_OnGameModeInit();
forward Rest_OnPlayerDisconnect(playerid);
forward Rest_OnPlayerSpawn(playerid);
forward Rest_OnPlayerDeath(playerid, killerid, reason);

/*
*    PUBLICS
*/


public Rest(playerid)
{
	
	if( pResting[playerid] )
	{
		RestingEnd(playerid);
		return 1;
	}
	new RestPlace = IsPlayerNearRestingPlace(playerid);
	if(RestPlace != -1)
	{
		SetPlayerPos(playerid, RestPositions[RestPlace][restX], RestPositions[RestPlace][restY],  RestPositions[RestPlace][restZ]);
		SetPlayerFacingAngle(playerid, RestPositions[RestPlace][restAng]);

		pResting[playerid] = true;
		RestPositions[RestPlace][Taken] = true;
		pRestingAt[playerid] = RestPlace;

		if(RestPositions[RestPlace][restType] == REST_LAY)
		{
			ApplyAnimation(playerid, "BEACH", "null", 4.0, 1, 0, 0, 0, 0);	/// preload
			ApplyAnimation(playerid, "BEACH", "bather", 4.0, 1, 0, 0, 0, 0);
			SendEmote(playerid, "läheb pikali");
		}
		else
		{
			ApplyAnimation(playerid, "BEACH", "null", 4.0, 1, 0, 0, 0, 0);	/// preload
			ApplyAnimation(playerid,"BEACH", "ParkSit_M_loop", 4.0, 1, 0, 0, 0, 0);
			SendEmote(playerid, "istub");
		}

		SendClientMessage(playerid, COLOR_YELLOW, "Kirjuta /puhka, et püsti tõusta.");
	}
	else
	{
		ApplyAnimation(playerid, "BEACH", "null", 4.0, 1, 0, 0, 0, 0);	/// preload
		ApplyAnimation(playerid,"BEACH", "ParkSit_M_loop", 4.0, 1, 0, 0, 5000, 0);
		SendEmote(playerid, "istub maha");		
		pResting[playerid] = true;
		pRestingAt[playerid] = -1;
	}
	return 1;	
}

public IsPlayerNearRestingPlace(playerid)
{
	new Float: pX, Float: pY, Float: pZ;	
	GetPlayerPos(playerid, pX, pY, pZ);
	
	new Float: kaugus = 5.0;
	new Float: kaugus2;
	
	new ret = -1;
	
	for(new i; i < MAX_REST_POSITIONS; i++)
	{
		if( !RestPositions[i][Taken] )
		{
			kaugus2 = DistanceCheck(pX, pY, pZ, RestPositions[i][restX], RestPositions[i][restY],  RestPositions[i][restZ]);

			if(kaugus2 < kaugus)
			{
				kaugus = kaugus2;
				ret = i;
			}
		}
	}	
	
	return ret;
}

public RestingEnd(playerid)
{
	ClearResting(playerid);
	SendEmote(playerid, "tõuseb püsti");
	ClearAnimations(playerid);
}

public ClearResting(playerid)
{
    new RestPlace = pRestingAt[playerid];
	if(RestPlace != -1 && RestPlace < MAX_REST_POSITIONS) RestPositions[RestPlace][Taken] = false;
    pResting[playerid] = false;
    pRestingAt[playerid] = -1;
}


public RestChange()
{
	foreach (User, playerid)
	{
		if( pResting[playerid] )
		{
			new Float: Rem = 1.0;
			
			if(pRestingAt[playerid] != -1)
			{
				Rem = 2.5;
				if(RestPositions[pRestingAt[playerid]][restType] == REST_LAY) Rem = 5.0;
			}
			
			if(pSkillLevel[playerid][SKILL_ATHLETE] > 10) Rem = 1.0 + (pSkillLevel[playerid][SKILL_ATHLETE] / 25);
			
			GivePlayerRestprecent(playerid, Rem);
			XpAdd(playerid, SKILL_ATHLETE, 25);
		}
		else
		{
			if(IsPlayerInAnyVehicle(playerid)) GivePlayerRestprecent(playerid, 1.0);
		}
		RestUpdateForPlayer(playerid);
	}
}

public GivePlayerRestprecent(playerid, Float: amount)
{
	pRest[playerid] += amount;
	if(pRest[playerid] < 0.0) pRest[playerid] = 0.0;
	if(pRest[playerid] > 100.0) pRest[playerid] = 100.0;
	RestUpdateForPlayer(playerid);
}

public RestUpdateForPlayer(playerid)
{
	if(progressInf[restBar][innerPrecent][playerid] != pRest[playerid]) setProgressBar(restBar, playerid, pRest[playerid]);
}

COMMAND:puhka(playerid, params[])
{
	#pragma unused params
	if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_YELLOW, "Sa istud juba!");
	Rest(playerid);
	return 1;
}

COMMAND:puhkakiirelt(playerid, params[])
{
	pRest[playerid] = 100.0;
	return 1;
}

/*
*    ALS Silent
*/

public OnGameModeInit()
{
	restBar = CreateProgressbar(548.2, 61.5, 53.8, 0.1, 2.0, COLOR_BLACK, COLOR_YELLOW, COLOR_WHITE);
	SetTimer("RestChange", 10000, true);
	
	if (funcidx("Rest_OnGameModeInit") != -1)
    {
        return CallLocalFunction("Rest_OnGameModeInit", "");
    }
	return 1;
}

public OnPlayerDisconnect(playerid)
{
	if( pResting[playerid] ) ClearResting(playerid);
	pRest[playerid] = 100.0;
	
    if (funcidx("Rest_OnPlayerDisconnect") != -1)
    {
        return CallLocalFunction("Rest_OnPlayerDisconnect", "i", playerid);
    }
    return 1;
}

public OnPlayerSpawn(playerid)
{
	if(!IsPlayerNPC(playerid))
	{
		ProccesBarShowForPlayer(restBar, playerid);
	}
	
    if (funcidx("Rest_OnPlayerSpawn") != -1)
    {
        return CallLocalFunction("Rest_OnPlayerSpawn", "i", playerid);
    }
    return 1;	
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if ( pResting[playerid] ) ClearResting(playerid);
	pRest[playerid] = 100.0;
	
    if (funcidx("Rest_OnPlayerDeath") != -1)
    {
        return CallLocalFunction("Rest_OnPlayerDeath", "iii", playerid, killerid, reason);
    }
    return 1;
}
	

#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit Rest_OnGameModeInit

#if defined _ALS_OnPlayerSpawn
    #undef OnPlayerSpawn
#else
    #define _ALS_OnPlayerSpawn
#endif
#define OnPlayerSpawn Rest_OnPlayerSpawn

#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect Rest_OnPlayerDisconnect

#if defined _ALS_OnPlayerDeath
    #undef OnPlayerDeath
#else
    #define _ALS_OnPlayerDeath
#endif
#define OnPlayerDeath Rest_OnPlayerDeath

// EOF