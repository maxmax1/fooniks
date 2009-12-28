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
*    This File: phoenix_InfoSpots.inc
*    Purpose: Add infoteleports into phoenix..
*/

/*
*    DEFINES
*/

#define MAX_INFOSPOTS 25

#define INFO_PICKUP 1239
#define INFO_COLOR 0x33AA33FF

/*
*    GLOBALS
*/

enum infoSpotInf
{
	Float: infoX,
	Float: infoY,
	Float: infoZ,
	infoInt,
	infoVW,
	infoPickup,
	Text3D: info3Dtext
};
new InfoSpots[MAX_INFOSPOTS][infoSpotInf];
Itter_Create(InfoSpot, MAX_INFOSPOTS);

new 
	bool: pInInfoInterior[MAX_PLAYERS],
	pInfoInterior[MAX_PLAYERS];

/*
*    STOCKS
*/

stock getClosestInfoSpot(playerid)
{
	new Float: x, Float: y, Float: z, Float: dist = 2.0, foundId = -1;
	GetPlayerPos(playerid, x, y, z);
	
	foreach(InfoSpot, i)
	{
		new Float: tDist = DistanceCheck(x, y, z, InfoSpots[i][infoX], InfoSpots[i][infoY], InfoSpots[i][infoZ]);
		if(tDist < dist)
		{
			foundId = i;
			dist = tDist;
		}
	}
	return foundId;
}

/*
*     FORWARDS
*/

forward AddInfoSpot(text[], Float: x, Float: y, Float: z, interiorId, intoVW);

/*
*    PUBLICS
*/

public AddInfoSpot(text[], Float: x, Float: y, Float: z, interiorId, intoVW)
{
	new freeId = Itter_Free(InfoSpot);
	if(freeId == -1) return -1;
	
	InfoSpots[freeId][infoX] = x;
	InfoSpots[freeId][infoY] = y;
	InfoSpots[freeId][infoZ] = z;
	InfoSpots[freeId][infoInt] = interiorId;
	InfoSpots[freeId][infoVW] = intoVW;
	
	InfoSpots[freeId][infoPickup] = CreateDynamicPickup(INFO_PICKUP, 1, x, y, z);
	InfoSpots[freeId][info3Dtext] = CreateDynamic3DTextLabel(text, INFO_COLOR, x, y, z+1.5, 30.0);

	Itter_Add(InfoSpot, freeId);
	return freeId;
}

/*
*    ALS
*/

forward Info_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(!IsPlayerInAnyVehicle(playerid) && PRESSED(KEY_SECONDARY_ATTACK))
	{
		if(!pInInfoInterior[playerid])
		{
			new spot = getClosestInfoSpot(playerid);
			if(spot != -1)
			{
				pInInfoInterior[playerid] = true;
				pInfoInterior[playerid] = spot;
				
				setToInt(playerid, InfoSpots[spot][infoInt]);
				SetPlayerVirtualWorld(playerid, InfoSpots[spot][infoVW]);
				return 1;
			}
		}
		else
		{
			new spot = InfoSpots[pInfoInterior[playerid]][infoInt];
			
			if(IsPlayerInRangeOfPoint(playerid, 2.0, Interiors[spot][intX], Interiors[spot][intY], Interiors[spot][intZ]))
			{
				SetPlayerVirtualWorld(playerid, 0);
				SetPlayerInterior(playerid, 0);
				SetPlayerPos(playerid, InfoSpots[pInfoInterior[playerid]][infoX], InfoSpots[pInfoInterior[playerid]][infoY], InfoSpots[pInfoInterior[playerid]][infoZ]);
				
				pInInfoInterior[playerid] = false;
				pInfoInterior[playerid] = -1;
				return 1;
			}
		}
	}
	
	if (funcidx("Info_OnPlayerKeyStateChange") != -1)
    {
        return CallLocalFunction("Info_OnPlayerKeyStateChange", "iii", playerid, newkeys, oldkeys);
    }
    return 1;
}

#if defined _ALS_OnPlayerKeyStateChange
    #undef OnPlayerKeyStateChange
#else
    #define _ALS_OnPlayerKeyStateChange
#endif
#define OnPlayerKeyStateChange Info_OnPlayerKeyStateChange

// EOF