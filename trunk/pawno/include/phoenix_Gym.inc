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
*    This File: phoenix_Gym.inc
*    Purpose: Add benchpressing and boxingbags for ATHLETE skill training.
*/

/*
*    DEFINES
*/

#define MAX_BENCES	6

#define WEIGHT_OBJ	2913

#define BENCH_IDLE		0
#define BENCH_PLYON		1
#define BENCH_WDWN		2
#define BENCH_WDWN_E	3
#define BENCH_WDWN_G	4
#define BENCH_WUP		5
#define BENCH_WUP_G		6

#define W_OFFSET_X	1.45
#define W_OFFSET_Y	0.5
#define W_OFFSET_Z	-0.05

#define P_OFFSET_X	-0.1
#define P_OFFSET_Y	0.025
#define P_OFFSET_Z	0.0
#define P_OFFSET_A	0.0

/*
*    GLOBALS
*/

enum benchInf
{
	Float: benchX,
	Float: benchY,
	Float: benchZ,
	Float: benchRot,
	bool: bInUse,
	benchStatus,
	weightObject,
	objTick,
	bPlayer
};

new Benches[MAX_BENCES][benchInf];
Itter_Create(Bench, MAX_BENCES);

new gMyBench[MAX_PLAYERS];
new bool: gInBench[MAX_PLAYERS];

/*
*    FORWARDS
*/

forward AddBench(Float: x, Float: y, Float: z, Float: ang);
forward StartBenchPress(playerid, benchId);
forward LiftWeights(playerid);
forward EndBenchPress(playerid);
forward TimedWeightMove(benchId, Float: x, Float: y, Float: z, Float: speed);

forward OnWeightLifted(playerid);

forward Gym_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);

/*
*    STOCKS
*/

stock getClosestBench(playerid)
{
	new Float: x, Float: y, Float: z, Float: dist = 15.0, foundId = -1;
	GetPlayerPos(playerid, x, y, z);
	
	foreach(Bench, i)
	{
		new Float: tDist = DistanceCheck(x, y, z, Benches[i][benchX], Benches[i][benchY], Benches[i][benchZ]);
		if(tDist < dist)
		{
			foundId = i;
			dist = tDist;
		}
	}
	return foundId;
}

/*
*    PUBLICS
*/

public AddBench(Float: x, Float: y, Float: z, Float: ang)
{
	new freeId = Itter_Free(Bench);
	
	if(freeId != -1)
	{
		Benches[freeId][benchX] = x;
		Benches[freeId][benchY] = y;
		Benches[freeId][benchZ] = z;
		Benches[freeId][benchRot] = ang;
		
		Benches[freeId][bInUse] = false;
		Benches[freeId][benchStatus] = BENCH_IDLE;
		
		Benches[freeId][weightObject] = CreateDynamicObject(WEIGHT_OBJ, x+W_OFFSET_X, y+W_OFFSET_Y, z+W_OFFSET_Z, 0, 90, ang);
		Itter_Add(Bench, freeId);
	}
	
	return freeId;
}

public StartBenchPress(playerid, benchId)
{
	Benches[benchId][bInUse] = true;
	Benches[benchId][benchStatus] = BENCH_PLYON;
	Benches[benchId][bPlayer] = playerid;
	
	gInBench[playerid] = true;
	gMyBench[playerid] = benchId;
	
	SetPlayerPos(playerid, Benches[benchId][benchX]+P_OFFSET_X, Benches[benchId][benchY]+P_OFFSET_Y, Benches[benchId][benchZ]+P_OFFSET_Z);
	SetPlayerFacingAngle(playerid, Benches[benchId][benchRot]+P_OFFSET_A);
	
	ApplyAnimation(playerid, "benchpress", "gym_bp_geton", 1.0, 0, 0, 0, 1, 0); 
	
	Benches[benchId][objTick] = 0;
	
	SetTimerEx("TimedWeightMove", 4650, 0, "iffff", benchId, W_OFFSET_X-0.05, W_OFFSET_Y, W_OFFSET_Z+0.05, 0.5);
	SetTimerEx("TimedWeightMove", 4750, 0, "iffff", benchId, W_OFFSET_X-0.08, W_OFFSET_Y, W_OFFSET_Z-0.05, 0.5);
	SetTimerEx("TimedWeightMove", 4850, 0, "iffff", benchId, W_OFFSET_X-0.1,  W_OFFSET_Y,  W_OFFSET_Z-0.1, 0.5);
	SetTimerEx("TimedWeightMove", 4950, 0, "iffff", benchId, W_OFFSET_X-0.2,  W_OFFSET_Y, W_OFFSET_Z-0.25, 0.5);
	
	return 1;
}

public TimedWeightMove(benchId, Float: x, Float: y, Float: z, Float: speed)
{
	MoveDynamicObject(Benches[benchId][weightObject], Benches[benchId][benchX]+x, Benches[benchId][benchY]+y, Benches[benchId][benchZ]+z, speed);
	
	if(Benches[benchId][benchStatus] == BENCH_PLYON)
	{	
		if(Benches[benchId][objTick] < 3)
		{
			Benches[benchId][objTick]++;
		}
		else
		{
			Benches[benchId][benchStatus] = BENCH_WDWN;
			Benches[benchId][objTick] = 0;
		}
	}
	else if(Benches[benchId][benchStatus] == BENCH_WDWN_E)
	{
		if(Benches[benchId][objTick] < 3)
		{
			Benches[benchId][objTick]++;
		}
		else
		{
			Benches[benchId][benchStatus] = BENCH_IDLE;
			Benches[benchId][objTick] = 0;
			
			gInBench[Benches[benchId][bPlayer]] = false;
			gMyBench[Benches[benchId][bPlayer]] = -1;
			
			Benches[benchId][bPlayer] = -1;
			Benches[benchId][bInUse] = false;
		}
	}
	else if(Benches[benchId][benchStatus] == BENCH_WUP_G)
	{
		if(Benches[benchId][objTick] < 0)
		{
			Benches[benchId][objTick]++;
		}
		else
		{
			Benches[benchId][benchStatus] = BENCH_WUP;
			Benches[benchId][objTick] = 0;
			OnWeightLifted(Benches[benchId][bPlayer]);
		}
	}
	else if(Benches[benchId][benchStatus] == BENCH_WDWN_G)
	{
		if(Benches[benchId][objTick] < 1)
		{
			Benches[benchId][objTick]++;
		}
		else
		{
			Benches[benchId][benchStatus] = BENCH_WDWN;
			Benches[benchId][objTick] = 0;
		}
	}
}

public LiftWeights(playerid)
{
	if(gMyBench[playerid] < 0 || gMyBench[playerid] >= MAX_BENCES) return 0;
	
	if(pRest[playerid] < 11.0)
	{
		SendClientMessage(playerid, COLOR_YELLOW, "Sa ei jõua enam kangi tõsta. Puhka vahepeal.");
		return EndBenchPress(playerid);
	}

	if(Benches[gMyBench[playerid]][benchStatus] == BENCH_WDWN)
	{
		Benches[gMyBench[playerid]][benchStatus] = BENCH_WUP_G;
		Benches[gMyBench[playerid]][objTick] = 0;
		
		ApplyAnimation(playerid, "benchpress", "gym_bp_up_A", 1.0, 0, 0, 0, 1, 0);

		SetTimerEx("TimedWeightMove", 600, 0, "iffff", gMyBench[playerid], W_OFFSET_X-0.19,  W_OFFSET_Y, W_OFFSET_Z+0.1, 0.19);
	}
	else if(Benches[gMyBench[playerid]][benchStatus] == BENCH_WUP)
	{
		Benches[gMyBench[playerid]][benchStatus] = BENCH_WDWN_G;
		Benches[gMyBench[playerid]][objTick] = 0;
		
		ApplyAnimation(playerid, "benchpress", "gym_bp_down", 1.0, 0, 0, 0, 1, 0);

		SetTimerEx("TimedWeightMove", 200, 0, "iffff", gMyBench[playerid], W_OFFSET_X-0.19,  W_OFFSET_Y, W_OFFSET_Z-0.20, 0.25);
		SetTimerEx("TimedWeightMove", 300, 0, "iffff", gMyBench[playerid], W_OFFSET_X-0.19,  W_OFFSET_Y, W_OFFSET_Z-0.24, 0.5);
	}
	return 1;
}

public EndBenchPress(playerid)
{
	if(gMyBench[playerid] < 0 || gMyBench[playerid] >= MAX_BENCES) return 0;
	
	Benches[gMyBench[playerid]][objTick] = 0;
	Benches[gMyBench[playerid]][benchStatus] = BENCH_WDWN_E;
		
	ApplyAnimation(playerid, "benchpress", "gym_bp_getoff", 1.0, 0, 0, 0, 0, 0);	
	
	SetTimerEx("TimedWeightMove", 600, 0, "iffff", gMyBench[playerid], W_OFFSET_X-0.1,  W_OFFSET_Y, W_OFFSET_Z-0.1, 0.25);	
	SetTimerEx("TimedWeightMove", 700, 0, "iffff", gMyBench[playerid], W_OFFSET_X-0.09,  W_OFFSET_Y,  W_OFFSET_Z-0.05, 0.25);
	SetTimerEx("TimedWeightMove", 800, 0, "iffff", gMyBench[playerid], W_OFFSET_X-0.08, W_OFFSET_Y, W_OFFSET_Z+0.05, 0.25);
	SetTimerEx("TimedWeightMove", 900, 0, "iffff", gMyBench[playerid], W_OFFSET_X, W_OFFSET_Y, W_OFFSET_Z, 0.25);
	
	return 1;
}

/*
*    ALS
*/

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(PRESSED(KEY_SECONDARY_ATTACK)) 
	{
		if(gInBench[playerid])
		{
			if(Benches[gMyBench[playerid]][benchStatus] == BENCH_WDWN) return EndBenchPress(playerid);
			else return 0;
		}
	
		new spot = getClosestBench(playerid);
		if(spot != -1)
		{
			if(Benches[spot][bInUse])
			{
				SendClientMessage(playerid, COLOR_RED, "See pink on juba kasutuses.");
			}
			else
			{
				StartBenchPress(playerid, spot);
			}
			
			return 0;
		}
	}
	else if(PRESSED(KEY_SPRINT)) 
	{	
		if(gInBench[playerid])
		{
			if(Benches[gMyBench[playerid]][benchStatus] == BENCH_WDWN || Benches[gMyBench[playerid]][benchStatus] == BENCH_WUP) return LiftWeights(playerid);
			else return 0;
		}
	}

	if (funcidx("Gym_OnPlayerKeyStateChange") != -1)
    {
        return CallLocalFunction("Gym_OnPlayerKeyStateChange", "iii", playerid, newkeys, oldkeys);
    }
    return 1;
}

#if defined _ALS_OnPlayerKeyStateChange
    #undef OnPlayerKeyStateChange
#else
    #define _ALS_OnPlayerKeyStateChange
#endif
#define OnPlayerKeyStateChange Gym_OnPlayerKeyStateChange