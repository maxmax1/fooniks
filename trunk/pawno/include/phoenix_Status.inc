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
*    This File: phoenix_Status.inc
*    Purpose: Add some player statuses to GM. (AFK, AOD, ETC)
*/

/*
*    DEFINES
*/

#define STATUS_NONE 0
#define STATUS_AFK  1

#define TAG_AFK "[AFK]"

/*
*    GLOBALS
*/

new gMyName[MAX_PLAYERS][32];

/*
*    FORWARDS
*/

forward PlayerStatusChange(playerid, newStatus);
forward STAT_OnPlayerConnect(playerid);

/*
*    PUBLICS
*/

public PlayerStatusChange(playerid, newStatus)
{
	new pName[48];
	if(newStatus == STATUS_NONE)
	{
		format(pName, 48, "%s", gMyName[playerid]);
	}
	else if(newStatus == STATUS_AFK)
	{
		format(pName, 48, "%s%s", TAG_AFK, gMyName[playerid]);
	}
	SetPlayerName(playerid, pName);
	return 1;
}

/*
*    ALS Silent Implement
*/

public OnPlayerConnect(playerid)
{
	GetPlayerName(playerid, gMyName[playerid], 32);
	
    if (funcidx("NP_OnPlayerConnect") != -1)
    {
        return CallLocalFunction("NP_OnPlayerConnect", "i", playerid);
    }
    return 1;
}

#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect STAT_OnPlayerConnect