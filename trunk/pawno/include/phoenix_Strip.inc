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
*    This File: phoenix_Strip.inc
*    Purpose: Add strippers.
*/

/*
*    DEFINES
*/

#define STRIP_A 0
#define STRIP_B 1
#define STRIP_C 2

/*
*    GLOBALS
*/

new gMyStripState[MAX_PLAYERS];

new gStripStartAnims[3][16] = 
{
	{"strip_A"},
	{"strip_B"},
	{"strip_C"}
};

new gStripSecondAnims[4][16] = 
{
	{"strip_D"},
	{"strip_E"},
	{"strip_F"},
	{"strip_G"}
};

new Strippernames[5][16] = 
{
	"Destiny",
	"Candy",
	"Angel",
	"Cherry",
	"Raven"
};

new StripperSkins[14] = {152, 178, 237, 238, 243, 244, 207, 245, 246, 256, 257, 64, 63, 87};

enum stripPosInf
{
	Float: stripX,
	Float: stripY,
	Float: stripZ,
	Float: stripA,
	stripperId,
	bool: stripC
};
new StripperPositions[5][stripPosInf] = 
{
	{1208.2710, -6.6922, 1001.3281,  11.3035, -1, false},
	{1220.6715,  7.9612, 1001.3356, 133.0230, -1, false},
	{1223.1925, -11.990, 1001.3281,  37.0000, -1, false},
	{1223.4580, -3.2453, 1001.3281,   2.5067, -1, false},
	{1216.1250, -6.0529, 1001.3281, 245.4873, -1, false}
};
Itter_Create(StripperPosition, 5);

/*
*    STOCKS
*/

stock getStripperIdFromName(namestr[])
{
	foreach(StripperPosition, i)
	{
		if(!strcmp(Strippernames[i], namestr))
		{
			return i;
		}
	}
	return -1;
}

stock getClosestStripSpot(playerid)
{
	new Float: x, Float: y, Float: z, Float: dist = 10.0, foundId = -1;
	GetPlayerPos(playerid, x, y, z);
	
	foreach(StripperPosition, i)
	{
		new Float: tDist = DistanceCheck(x, y, z, StripperPositions[i][stripX], StripperPositions[i][stripY], StripperPositions[i][stripZ]);
		if(tDist < dist)
		{
			foundId = i;
			dist = tDist;
		}
	}
	return foundId;
}

/*
*    FORWARDS
*/

forward ConnectStripper();
forward StripShow(playerid);
forward OnStripStateChange(playerid);

forward Strip_OnPlayerConnect(playerid);
forward Strip_OnPlayerSpawn(playerid);

/*
*    PUBLICS
*/

public ConnectStripper()
{
	new freeId = Itter_Free(StripperPosition);
	if(freeId == -1) 
	{
		print("No free strippositions.");
		return -1;
	}
	
	ConnectNPC(Strippernames[freeId], "Jann");	
	Itter_Add(StripperPosition, freeId);
	return freeId;
}

public StripShow(playerid)
{
	gMyStripState[playerid] = 0;
	
	ApplyAnimation(playerid, "STRIP", gStripStartAnims[random(3)], 1.0, 0, 0, 0, 0, 0);
	
	TimedAnim(playerid, 300, "STRIP", gStripSecondAnims[random(4)], 1.0, 0, 0, 0, 0, 0);
	SetTimerEx("OnStripStateChange", 300, 0, "i", playerid);
	
	TimedAnim(playerid, 500, "STRIP", "STR_B2C", 1.0, 0, 0, 0, 0, 0);
	SetTimerEx("OnStripStateChange", 500, 0, "i", playerid);
	
	TimedAnim(playerid, 600, "STRIP", "STR_C1", 1.0, 0, 0, 0, 0, 0);
	SetTimerEx("OnStripStateChange", 600, 0, "i", playerid);
	
	TimedAnim(playerid, 700, "STRIP", "STR_Loop_C", 1.0, 0, 0, 0, 0, 0);
	SetTimerEx("OnStripStateChange", 700, 0, "i", playerid);
	
	TimedAnim(playerid, 800, "STRIP", "STR_C2", 1.0, 0, 0, 0, 0, 0);
	SetTimerEx("OnStripStateChange", 800, 0, "i", playerid);
	
	TimedAnim(playerid, 900, "STRIP", "STR_C2B", 1.0, 0, 0, 0, 0, 0);
	SetTimerEx("OnStripStateChange", 900, 0, "i", playerid);
	
	TimedAnim(playerid, 1000, "STRIP", "STR_Loop_B", 1.0, 1, 0, 0, 0, 0);
	SetTimerEx("OnStripStateChange", 1000, 0, "i", playerid);
	
	TimedAnim(playerid, 2000, "STRIP", "STR_Loop_A", 1.0, 1, 0, 0, 0, 0);
	SetTimerEx("OnStripStateChange", 2000, 0, "i", playerid);
}

public OnStripStateChange(playerid)
{
	gMyStripState[playerid]++;
	if(gMyStripState[playerid] > 7) StripShow(playerid);
}

public OnPlayerConnect(playerid)
{
	if(IsPlayerNPC(playerid))
	{
		new tempStr[MAX_PLAYER_NAME], tempStr2[64];
		GetPlayerIp(playerid, tempStr, sizeof(tempStr));
		GetServerVarAsString("bind", tempStr2, 64);
		
		if(!strcmp(tempStr, tempStr))
		{
			GetPlayerName(playerid, tempStr, sizeof(tempStr));
			
			new smID = getStripperIdFromName(tempStr);
			if(smID != -1)
			{
				if(!StripperPositions[smID][stripC]) // Not Connected Yet
				{
					printf("Stripper: %d", playerid);
					
					StripperPositions[smID][stripC] = true;
					StripperPositions[smID][stripperId] = playerid;
				}
				else Kick(playerid); //  Already Connected.
			}
		}
		else
		{
			print("NPC Flood Attempt!");
			Kick(playerid);
		}
	}
	
	if (funcidx("Strip_OnPlayerConnect") != -1)
    {
        return CallLocalFunction("Strip_OnPlayerConnect", "i", playerid);
    }	
    return 1;	
}

public OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid))
	{
		foreach(StripperPosition, i)
		{
			if(StripperPositions[i][stripC] && StripperPositions[i][stripperId] == playerid)
			{
				SetPlayerSkin(playerid, StripperSkins[random(14)]);				
				SetPlayerPos(playerid, StripperPositions[i][stripX], StripperPositions[i][stripY], StripperPositions[i][stripZ]);
				SetPlayerFacingAngle(playerid, StripperPositions[i][stripA]);
				StripShow(playerid);
				break;
			}
		}
	}
	
	if (funcidx("Strip_OnPlayerSpawn") != -1)
    {
        return CallLocalFunction("Strip_OnPlayerSpawn", "i", playerid);
    }	
    return 1;	
}

#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect Strip_OnPlayerConnect

#if defined _ALS_OnPlayerSpawn
    #undef OnPlayerSpawn
#else
    #define _ALS_OnPlayerSpawn
#endif
#define OnPlayerSpawn Strip_OnPlayerSpawn
