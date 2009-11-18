/*
*
*	Project:		poolGame for SA-MP
*	Author:		Jyrno42
*
*/

/*
*	This File:		poolGame.inc
*	Purpose:		Include file for SA-MP gamemodes / filterscripts.
*	Last Update:	21:58 14.11.2009
*/

/*
*	UPDATES
*
*	21:58 14.11.2009 - Created file.
*	19:00 15.11.2009 - Added everything needed for a fully plugin-side gameplay.
*	18:03 16.11.2009 - Added more natives, created everything needed to remove pawn overhead.
*/

#if defined _poolGame_included
	#endinput
#endif
#define _poolGame_included
#pragma library poolGame


native poolAmx();
native AddPoolGame(Float: x, Float: y, Float: z); // Note, poolTable should be at the same angle like the one's in ten green bottles are...
native RemovePoolGame(gameId);
native RemovePoolGames();

native poolTimerTimerEnd(timerid, param1, param2);

native StartGame(playerid);
//native IsPoolPlayer(playerid);
//native IsTempGameStarted(playerid);
//native SetTempPoolGame(playerid, otherId);
//native CancelTempGame(playerid);

native SetPoolControls(gamestart, aim, shoot, speedAdd, speedRem, viewchange); // -1 == leave old one
native SetSpeedRange(Float: min, Float: max);
native AddCameraAngle(Float: x, Float: y, Float: z, Float: lx, Float: ly, Float: lz); // These use an offset from tables center...

// Forwards for samp callbaks
native SafeSetPoolGames(); // 2 seconds after init
native ballsMoved(objectid); // OnObjectMoved
native poolKeyStateChange(playerid, newkeys); // OnPlayerKeyStateChange

#define MAX_GAMES 		5
#define MAX_POOLDRAWS 	2
new Text: poolTextDraws[MAX_GAMES][MAX_POOLDRAWS];

#if !defined FILTERSCRIPT

	public OnGameModeInit()
	{
		SetTimer("AddPoolGames", 2000, 0);
		
		if (funcidx("poolGame_OnGameModeInit") != -1)
		{
			return CallLocalFunction("poolGame_OnGameModeInit", "");
		}
		return 1;
	}
	
	public OnGameModeExit()
	{
		RemovePoolGames();		
		
		for(new i; i < MAX_GAMES; i++)
		{
			for(new i2; i2 < MAX_POOLDRAWS; i2++)
			{
				TextDrawHideForAll(poolTextDraws[i2][i]);
				TextDrawDestroy(poolTextDraws[i2][i]);
			}
		}	
		
		if (funcidx("poolGame_OnGameModeExit") != -1)
		{
			return CallLocalFunction("poolGame_OnGameModeExit", "");
		}
		return 1;
	}
	
	#if defined _ALS_OnGameModeInit
		#undef OnGameModeInit
	#else
		#define _ALS_OnGameModeInit
	#endif
	#define OnGameModeInit poolGame_OnGameModeInit

	#if defined _ALS_OnGameModeExit
		#undef OnGameModeExit
	#else
		#define _ALS_OnGameModeExit
	#endif
	#define OnGameModeExit poolGame_OnGameModeExit	
	
	forward poolGame_OnGameModeInit();
	forward poolGame_OnGameModeExit();	

#else

	public OnFilterScriptInit()
	{
		SetTimer("AddPoolGames", 2000, 0);
		
		if (funcidx("poolGame_OnFilterScriptInit") != -1)
		{
			return CallLocalFunction("poolGame_OnFilterScriptInit", "");
		}
		return 1;
	}
	
	public OnFilterScriptExit()
	{
		RemovePoolGames();
		
		for(new i; i < MAX_GAMES; i++)
		{
			TextDrawHideForAll(poolTextDraws[0][i]);
			TextDrawDestroy(poolTextDraws[0][i]);
		}		
		
		if (funcidx("poolGame_OnFilterScriptExit") != -1)
		{
			return CallLocalFunction("poolGame_OnFilterScriptExit", "");
		}
		return 1;
	}	
	
	#if defined _ALS_OnFilterScriptInit
		#undef OnFilterScriptInit
	#else
		#define _ALS_OnFilterScriptInit
	#endif
	#define OnFilterScriptInit poolGame_OnFilterScriptInit
	
	#if defined _ALS_OnFilterScriptExit
		#undef OnFilterScriptExit
	#else
		#define _ALS_OnFilterScriptExit
	#endif
	#define OnFilterScriptExit poolGame_OnFilterScriptExit
	
	forward poolGame_OnFilterScriptInit();
	forward poolGame_OnFilterScriptExit();	

#endif

public OnObjectMoved(objectid)
{
	ballsMoved(objectid);
	
	if (funcidx("poolGame_OnObjectMoved") != -1)
	{
		return CallLocalFunction("poolGame_OnObjectMoved", "i", objectid);
	}
	return 1;	
}

#if defined _ALS_OnObjectMoved
	#undef OnObjectMoved
#else
	#define _ALS_OnObjectMoved
#endif
#define OnObjectMoved poolGame_OnObjectMoved

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	poolKeyStateChange(playerid, newkeys);
	
	if (funcidx("poolGame_OnPlayerKeyStateChange") != -1)
	{
		return CallLocalFunction("poolGame_OnPlayerKeyStateChange", "iii", playerid, newkeys, oldkeys);
	}
	return 1;	
}

#if defined _ALS_OnPlayerKeyStateChange
	#undef OnPlayerKeyStateChange
#else
	#define _ALS_OnPlayerKeyStateChange
#endif
#define OnPlayerKeyStateChange poolGame_OnPlayerKeyStateChange

forward WeBetterNeverCallThisFunction();
forward AddPoolGames();
forward poolTextDraw(playerid, game, status, tdId);
forward poolTextDrawUpdate(game, text[], tdId);
forward onPoolRequestGame(playerid);

forward poolTimer(timerid, param1, param2, time);
public poolTimer(timerid, param1, param2, time)
{
	SetTimerEx("OnPoolTimerEnd", time, 0, "iii", timerid, param1, param2);
}

forward OnPoolTimerEnd(timerid, param1, param2);
public OnPoolTimerEnd(timerid, param1, param2)
{
	poolTimerTimerEnd(timerid, param1, param2);
}

public AddPoolGames()
{
	SafeSetPoolGames();
	for(new i; i < MAX_GAMES; i++)
	{
		poolTextDraws[i][0] = TextDrawCreate(320, 400, "~g~||");
		poolTextDraws[i][1] = TextDrawCreate(400, 400, "~b~Mangija1:\t~g~1\n~w~Mangija2:\t~r~0");
	}
}

public poolTextDraw(playerid, game, status, tdId)
{
	if(status == 0)
	{
		TextDrawShowForPlayer(playerid, poolTextDraws[game][tdId]);
	}
	else
	{
		TextDrawHideForPlayer(playerid, poolTextDraws[game][tdId]);
	}
}

public poolTextDrawUpdate(game, text[], tdId)
{
	TextDrawSetString(poolTextDraws[game][tdId], text);
}

public WeBetterNeverCallThisFunction()
{
	new Float: fl;
	
	// Those function work in my plugin:)
	
	CreateObject(0, 0, 0, 0, 0, 0, 0);
	MoveObject(0, 0.0, 0.0, 0.0, 0.0);
	DestroyObject(0);
	GetPlayerPos(0, fl, fl, fl);
	SetPlayerPos(0, 0, 0, 0);
	GetPlayerFacingAngle(0, fl);
	SetPlayerFacingAngle(0, 0);
	SetPlayerCameraPos(0, 0, 0, 0);
	SetPlayerCameraLookAt(0, 0, 0, 0);
	ApplyAnimation(0, "POOL", "null", 1.0, 0, 1, 1, 1, 0);	
	GivePlayerWeapon(0, 7, 1);
	ClearAnimations(0);
	SetCameraBehindPlayer(0);
	SetTimerEx("null", 500, 0, "i", 0);
	SendClientMessage(0, 0x00000000, "");
}