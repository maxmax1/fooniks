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
*    This File: phoenix_Whore.inc
*    Purpose:  A whore job for phoenix.
*/

#if !defined _phoenix_included
	#error "Phoenix ERROR #1, You need phoenix base for this gamemode to run!"
	#endinput
#endif

#if !defined _phoenix_JobSystem_included
	#error "Whore Job needs phoenix_JobSystem!"
	#endinput
#endif


/*
*    Defines
*/

#define WHORE_JOB_ID 2

#define NO_BJ 0
#define GETTING_BJ 1
#define GIVING_BJ  2

/*
*    GLOBALS
*/

new 
	gMyBjPrice[MAX_PLAYERS],
	gBjOffer[MAX_PLAYERS],
	gOnBj[MAX_PLAYERS];

/*
*    FORWARDS
*/

forward HaveBJ(meesId, eitId);
forward SemiEndBJ(meesId, eitId);
forward EndBJ(meesId, eitId);
forward RealStopBJ(meesId, eitId);

/*
*    PUBLICS
*/

JOBS_OnJobInit(Whore)
{
	AddJobCommand(WHORE_JOB_ID, "vıtasuhu");
	for(new i; i < MAX_PLAYERS; i++) gBjOffer[i] = -1;
}

public HaveBJ(meesId, eitId)
{
	GivePlayerMoneyNew(eitId, gMyBjPrice[eitId]);
	GivePlayerMoneyNew(meesId, -(gMyBjPrice[eitId]));

	gMyBjPrice[eitId] = 0;
	
	gOnBj[meesId] = GETTING_BJ;
	gOnBj[eitId] = GIVING_BJ;

	new Float: eitX, Float: eitY, Float: eitZ;

	GetPlayerPos(eitId, eitX, eitY, eitZ);
	
	SetPlayerFacingAngle(meesId, 180);
	SetPlayerFacingAngle(eitId, 0);	

	SetPlayerPos(meesId, eitX, eitY+1, eitZ); // mees
	
	ApplyAnimation(meesId, "BLOWJOBZ","BJ_STAND_START_P",4.1,0,1,1,1,1);//mees
	ApplyAnimation(eitId, "BLOWJOBZ","BJ_STAND_START_W",4.1,0,1,1,1,1);//lits

	new time = 1005;
	SetTimerEx("SemiEndBJ", time, 0, "ii", meesId, eitId);
	SetTimerEx("SemiEndBJ", 2*time, 0, "ii", meesId, eitId);
	SetTimerEx("SemiEndBJ", 3*time, 0, "ii", meesId, eitId);
	SetTimerEx("SemiEndBJ", 4*time, 0, "ii", meesId, eitId);
	SetTimerEx("SemiEndBJ", 5*time, 0, "ii", meesId, eitId);
	SetTimerEx("SemiEndBJ", 6*time, 0, "ii", meesId, eitId);
	SetTimerEx("SemiEndBJ", 7*time, 0, "ii", meesId, eitId);	
	SetTimerEx("EndBJ", 8*time, 0, "ii", meesId, eitId);
	SetPlayerHealth(meesId, 100);
	return 1;
}

public SemiEndBJ(meesId, eitId)
{
	ApplyAnimation(meesId,"BLOWJOBZ","BJ_STAND_LOOP_P",4.1,0,1,1,1,1);
	ApplyAnimation(eitId,"BLOWJOBZ","BJ_STAND_LOOP_W",4.1,0,1,1,1,1);
	return 1;
}

public EndBJ(meesId, eitId)
{	
	ApplyAnimation(meesId,"BLOWJOBZ","BJ_STAND_END_P",4.1,0,0,0,1,1);//mees
	ApplyAnimation(eitId,"BLOWJOBZ","BJ_STAND_END_W",4.1,0,0,0,1,1);//lits	
	
	ApplyAnimation(meesId,"BLOWJOBZ","BJ_STAND_END_P",4.1,0,0,0,1,1);//mees
	ApplyAnimation(eitId,"BLOWJOBZ","BJ_STAND_END_W",4.1,0,0,0,1,1);//lits	
	
	gOnBj[meesId] = NO_BJ;
	gOnBj[eitId] = NO_BJ;	
	
	gBjOffer[meesId] = -1;	
	gBjOffer[eitId] = -1;	
	
	SetTimerEx("RealStopBJ", 1000, 0, "ii", meesId, eitId);
	
	return 1;
}

public RealStopBJ(meesId, eitId)
{
	stopAnims(meesId);
	stopAnims(eitId);
}

/*
*    COMMANDS
*/

COMMAND:v6tasuhu(playerid, params[])
{
	if(gMyJob[playerid] != WHORE_JOB_ID) return SendClientMessage(playerid, COLOR_RED, "Sa pole hoor.");
	if(gBjOffer[playerid] != -1 || gOnBj[playerid] != NO_BJ) return SendClientMessage(playerid, COLOR_RED, "Sa tegutsed juba.");
	
	new hind;
	if(sscanf(params, "i", hind)) return SendClientMessage(playerid, COLOR_YELLOW, "KASUTUS: /vıtasuhu Hind");
	if(hind < 1 || hind > 99999)  return SendClientMessage(playerid, COLOR_RED, "Hind peab j‰‰ma vahemikku 1 - 99999.");
	
	gMyBjPrice[playerid] = hind;	
	ShowPlayerList(playerid, PLIST_BLOWJOB, 10.0, false);	
	return 1;
}

/*
*    ALS
*/