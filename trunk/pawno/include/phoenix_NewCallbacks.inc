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
*    The Initial Developers of the Original Code are 13th and Jyrno42.
*/

/*
*    This File: phoenix_Callbacks.inc
*    Purpose: Add some new callbacks to phoenix.
*/

/*
*    GLOBALS
*/

new bool: gBackTimer[MAX_PLAYERS];

new PlayerKey[MAX_PLAYERS][4];

new 
	gCBHas_OPU = -1,
	gCBHas_OPKSC = -1;

/*
*    STOCKS
*/


stock IsPlayerAiming(playerid, aimid, weaponType)
{
	if(weaponType < 1 || weaponType > 2) return false;

	new Float:X1, Float:Y1, Float:Z1, Float:X2, Float:Y2, Float:Z2;
	GetPlayerPos(playerid, X1, Y1, Z1);
	GetPlayerPos(aimid, X2, Y2, Z2);
	new Float:Distance = floatsqroot(floatpower(floatabs(X1-X2), 2) + floatpower(floatabs(Y1-Y2), 2));
	
	if(Distance < 100 && Distance > 1.0 && weaponType == 2 || Distance < 1.0 && weaponType == 1)
	{
		new Float:A;
		GetPlayerFacingAngle(playerid, A);
		X1 += (Distance * floatsin(-A, degrees));
		Y1 += (Distance * floatcos(-A, degrees));
		Distance = floatsqroot(floatpower(floatabs(X1-X2), 2) + floatpower(floatabs(Y1-Y2), 2));
		if(Distance < 0.5)
		{
			return true;
		}
	}
	return false;
}

/*
*    FORWARDS
*/

forward OnPlayerKeys(playerid, pressedkey);
forward CB_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
forward OnPlayerUpdate(playerid);
forward UnsetGBackTimer(playerid, target);

// NEW CALLBACKS
forward OnPlayerShootPlayer(playerid, weaponid, targetid);
forward OnPlayerHitPlayer(playerid, weaponid, targetid);
forward OnPlayerHitNPC(playerid, weaponid, npcid);

public OnPlayerKeys(playerid, pressedkey)
{
	if(paperActive[playerid] && currentPage[playerid] == 2)
	{
		if(pressedkey == 16)
		{
			addSel[playerid]--;
			addSel[playerid] = (addSel[playerid]<0)?0:addSel[playerid];
			RedrawJobAds(playerid, paperDrawActive[playerid]);
		}
		else if(pressedkey == 32)
		{
			addSel[playerid]++;
			addSel[playerid] = (addSel[playerid]>=ADDED_JADS)?ADDED_JADS-1:addSel[playerid];
			RedrawJobAds(playerid, paperDrawActive[playerid]);
		}		
	}	
}

public UnsetGBackTimer(playerid, target)
{
	gBackTimer[playerid] = false;
	if(target != -1) ApplyAnimation(target, "CRACK", "crckdeth2", 1.0, 0, 0, 0, 0, 3000);
}

/*
*    ALS
*/
	
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if( PRESSED(KEY_FIRE) || PRESSED(KEY_FIRE | KEY_HANDBRAKE) || PRESSED(KEY_SECONDARY_ATTACK | KEY_HANDBRAKE))
	{
		if(gBackTimer[playerid] != true)
		{
			foreach(Character, i)
			{
				if(playerid != i)
				{
					new weaponid = GetPlayerWeapon(playerid);
					new weaponType = ((weaponid < 9 || weaponid > 9 && weaponid < 16)?1:(weaponid > 21 && weaponid < 35 || weaponid == 38)?(2):(0));
					
					if(IsPlayerAiming(playerid, i, weaponType) && GetPlayerState(i) == PLAYER_STATE_ONFOOT)
					{
						if(weaponType == 1 && IsPlayerNPC(i))
						{
							gBackTimer[playerid] = true;
							OnPlayerHitNPC(playerid, weaponid, i);
							SetTimerEx("UnsetGBackTimer", 1000, 0, "ii", playerid, -1);
						}
						else if(weaponType == 1)
						{
							gBackTimer[playerid] = true;
							OnPlayerHitPlayer(playerid, weaponid, i);
							SetTimerEx("UnsetGBackTimer", 1000, 0, "ii", playerid, -1);
						}
						else if(weaponType == 2)
						{
							gBackTimer[playerid] = true;
							new ret = OnPlayerShootPlayer(playerid, weaponid, i);
							SetTimerEx("UnsetGBackTimer", 1000, 0, "ii", playerid, (ret == 1)?i:-1);
						}
					}
				}
			}
		}
	}
	if(gCBHas_OPKSC == -1) gCBHas_OPKSC = funcidx("CB_OnPlayerKeyStateChange");
    if (gCBHas_OPKSC != -1)
    {
        return CallLocalFunction("CB_OnPlayerKeyStateChange", "iii", playerid,  newkeys, oldkeys);
    }	
	return 1;
}	

public OnPlayerUpdate(playerid)
{
	new keys, updown, leftright;
	GetPlayerKeys(playerid, keys, updown, leftright);
	
	if(updown == KEY_UP && PlayerKey[playerid][0] == 0)
	{
		OnPlayerKeys(playerid, 16); // KEY_UP
		PlayerKey[playerid][0] = true;
	}
	else if(updown == KEY_DOWN && PlayerKey[playerid][1] == 0)
	{
		OnPlayerKeys(playerid, 32); // KEY_DOWN
    	PlayerKey[playerid][1] = true;
	}
	else if(leftright == KEY_LEFT && PlayerKey[playerid][2] == 0)
	{
		OnPlayerKeys(playerid, 64); // KEY_LEFT
    	PlayerKey[playerid][2] = true;
	}
	else if(leftright == KEY_RIGHT && PlayerKey[playerid][3] == 0)
	{
		OnPlayerKeys(playerid, 128); // KEY_RIGHT
    	PlayerKey[playerid][3] = true;
	}
	
	if(updown != KEY_UP) PlayerKey[playerid][0] = false;
	if(updown != KEY_DOWN) PlayerKey[playerid][1] = false;
	if(leftright != KEY_LEFT) PlayerKey[playerid][2] = false;
	if(leftright != KEY_RIGHT) PlayerKey[playerid][3] = false;
	
	if(gCBHas_OPU == -1) gCBHas_OPU = funcidx("CB_OnPlayerUpdate");
    if (gCBHas_OPU != -1)
    {
        return CallLocalFunction("CB_OnPlayerUpdate", "i", playerid);
    }	
	return 1;
}

#if defined _ALS_OnPlayerKeyStateChange
    #undef OnPlayerKeyStateChange
#else
    #define _ALS_OnPlayerKeyStateChange
#endif
#define OnPlayerKeyStateChange CB_OnPlayerKeyStateChange

#if defined _ALS_OnPlayerUpdate
    #undef OnPlayerUpdate
#else
    #define _ALS_OnPlayerUpdate
#endif
#define OnPlayerUpdate CB_OnPlayerUpdate