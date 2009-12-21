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
*    This File: phoenix_Phone.inc
*    Purpose: Create the phone system for Phoenix.
*/

/*
*    DEFINES
*/

#define COLOR_PHONE 0xF0DC82AA

#define MAX_CONTACTS 12

#define MAX_SIMCARDS 300

#define CALL_NONE 			0
#define CALL_PLAYER 		1
#define CALL_RECIVE			2
#define CALL_CONNECTED 		3

#define HANGUP_ME 			0
#define CALL_PLAYER 		1
#define CALL_RECIVE			2
#define CALL_CONNECTED 		3

#define CALL_END_UNKNOWN	0
#define CALL_END_WRONG_NR	1
#define CALL_NUMBER_INUSE	2
#define CALL_END_NO_ANWSER	3
#define CALL_END_DENIED		4
#define CALL_END_HANGUP		5
#define CALL_END_HANGUP_ME	6
#define CALL_END_HANGUP_OT	7

#define ITEM_SIMCARD 13

/*
*    GLOBALS
*/

enum phoneInf
{	
	// Other Inf
	bool: hasPhone,
	bool: simCardIn,
	simCard,	

	// Callin stuff.
	onCall,
	ringTime,
	callPlayer,
	bool: speakerOn
};
new gPlayerPhone[MAX_PLAYERS][phoneInf];

new ringDoneTime[MAX_PLAYERS];
new ringDoneTimer[MAX_PLAYERS];

new 
	gPlayerCMemoryAdding[MAX_PLAYERS],
	gPlayerCMemorySlot[MAX_PLAYERS];	

enum simInf
{
	sNumber,
	companyId
};
new gSimCards[MAX_SIMCARDS][simInf];
Itter_Create(SimCard, MAX_SIMCARDS);

new 
	gContactMemoryNR[MAX_SIMCARDS][MAX_CONTACTS],
	gContactMemoryName[MAX_SIMCARDS][MAX_CONTACTS][16], 
	bool: gContactMemoryUsed[MAX_SIMCARDS][MAX_CONTACTS];

new 
	g_Phone_Has_OPT = -1,
	g_Phone_Has_OPD = -1,
	g_Phone_Has_ODR = -1;

/*
*    FORWARDS
*/

forward GiveSimCard(playerid, company);
forward ActivateSimCard(playerid, selectedCard, other);
forward PlayerCallNumber(playerid, number);
forward EndCall(playerid, reason);
forward PhoneTimer();
forward PlayerPhoneRing(playerid, Float: x, Float: y, Float: z);

forward ph_Phone_OnGameModeInit();
forward Phone_OnPlayerDisconnect(playerid);
forward ph_Phone_OnPlayerText(playerid, text[]);
forward Phone_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);

/*
*    STOCKS
*/

stock GenerateRandomNumber(company)
{	
	return 50000000 + (company*1000000) + random(999999);
}

stock FindNumberFromContactname(simcard, namestr[])
{
	for(new i; i < MAX_CONTACTS; i++)
	{
		if(!gContactMemoryUsed[simcard][i]) continue;
		if(!strcmp(namestr, gContactMemoryName[simcard][i])) return gContactMemoryNR[simcard][i];
	}
	return -1;
}

stock findPlayerFromNumber(number)
{
	foreach(User, i)
	{
		if(!gPlayerPhone[i][hasPhone] || !gPlayerPhone[i][simCardIn] || gPlayerPhone[i][simCard] < 0 || gPlayerPhone[i][simCard] > MAX_SIMCARDS) continue;
		if(gSimCards[gPlayerPhone[i][simCard]][sNumber] == number) return i;
	}
	return -1;
}

/*
*    COMMANDS
*/

COMMAND:myphone(playerid, params[])
{
	gPlayerPhone[playerid][hasPhone] = true;
	GiveSimCard(playerid, 3);
	return 1;
}

COMMAND:telefon(playerid, params[])
{
	if(!gPlayerPhone[playerid][hasPhone]) return SendClientMessage(playerid, COLOR_RED, "Sul pole telefoni!");
	
	new nr, company;
	if(gPlayerPhone[playerid][simCardIn])
	{
		nr = gSimCards[gPlayerPhone[playerid][simCard]][sNumber];
		company = gSimCards[gPlayerPhone[playerid][simCard]][companyId];
	}
	new string[128];
	format(string, 128, "~b~Telefon~n~~g~Number: ~w~%d~n~~g~Firma: ~w~%d~n~/helista /vasta /katkesta /kontaktid /valjuh‰‰ldi", nr, company);	
	SmallHelpDrawShow(playerid, string, 10000);	
	return 1;
}

COMMAND:helista(playerid, params[])
{
	if(!gPlayerPhone[playerid][hasPhone]) return SendClientMessage(playerid, COLOR_RED, "Sul pole telefoni!");
	if(!gPlayerPhone[playerid][simCardIn]) return SendClientMessage(playerid, COLOR_RED, "Su telefonis pole SIM-kaarti!");
	if(gPlayerPhone[playerid][onCall] != CALL_NONE) return SendClientMessage(playerid, COLOR_RED, "Sul on juba kıne pooleli.");

	new nr = -1, name[16], found = true;
	if(sscanf(params, "d", nr)) found = false;
	else if(sscanf(params, "s", name)) found = false;
	
	if(!found) return SendClientMessage(playerid, COLOR_YELLOW, "KASUTUS: /helista number/nimi");
	
	if(nr != -1)
	{
		SendFormattedText(playerid, COLOR_PHONE, "helistan %d...", nr);
		PlayerCallNumber(playerid, nr);		
	}
	else
	{
		nr = FindNumberFromContactname(gPlayerPhone[playerid][simCard], name);
		if(nr != -1)
		{
			SendFormattedText(playerid, COLOR_PHONE, "helistan %s - %d...", name, nr);
			PlayerCallNumber(playerid, nr);
		}
		else SendClientMessage(playerid, COLOR_PHONE, "Sellist nime pole sinu kontaktide hulgas.");
	}	
	return 1;
}

COMMAND:kontaktid(playerid, params[])
{
	if(!gPlayerPhone[playerid][hasPhone]) return SendClientMessage(playerid, COLOR_RED, "Sul pole telefoni!");
	if(!gPlayerPhone[playerid][simCardIn]) return SendClientMessage(playerid, COLOR_RED, "Su telefonis pole SIM-kaarti!");
	
	new id, action[32], bool: found, simcard = gPlayerPhone[playerid][simCardIn];
	
	if(sscanf(params, "ds", id, action)) found = true;
	else if(sscanf(params, "d", id)) found = true;	
	
	if(!found || id < 0 || id > MAX_CONTACTS)
	{
		SendClientMessage(playerid, COLOR_PHONE, "*** Kontaktid");
		for(new i; i < MAX_CONTACTS; i++)
		{
			if(!gContactMemoryUsed[simcard][i]) continue;
			SendFormattedText(playerid, COLOR_PHONE, "%d) %s - %d.", i, gContactMemoryName[simcard][i], gContactMemoryNR[simcard][i]);
		}
		SendClientMessage(playerid, COLOR_PHONE, "*** Vaata ka: /kontaktid id tegevus");
		return 1;
	}
	else
	{
		SendClientMessage(playerid, COLOR_PHONE, "*** Kontakt");
	
		if(!strcmp(action, "salvesta"))
		{
			if(gContactMemoryUsed[simcard][id])
			{			
				SendClientMessage(playerid, COLOR_PHONE, "See kirje juba sisaldab kontakti. Pead selle ennem kustutama.");
			}
			else 
			{
				gPlayerCMemoryAdding[playerid] = 1;
				gPlayerCMemorySlot[playerid] = id;
				ShowPlayerDialog(playerid, DIALOG_PHONE_ADD, DIALOG_STYLE_INPUT, "Lisa Kontakt", "Nimi mida soovid salvestada:\n", "Edasi", "Katkesta");
			}
		}
		else if(!strcmp(action, "kustuta"))
		{
			if(!gContactMemoryUsed[simcard][id])
			{			
				SendClientMessage(playerid, COLOR_PHONE, "See kirje ei sisalda sisaldab kontakti.");
			}
			else 
			{
				SendFormattedText(playerid, COLOR_PHONE, "%d) %s - %d.", id, gContactMemoryName[simcard][id], gContactMemoryNR[simcard][id]);
				SendClientMessage(playerid, COLOR_PHONE, "Kustutatud...");
				
				format(gContactMemoryName[simcard][id], 2, "_");
				gContactMemoryNR[simcard][id] = 0;
				gContactMemoryUsed[simcard][id] = false;
			}
		}
		else
		{	
			if(!gContactMemoryUsed[simcard][id])
			{
				SendClientMessage(playerid, COLOR_PHONE, "See kirje ei sisalda kontakti. Saad siia nime salvestada kasutades /kontaktid id salvesta.");
			}
			else SendFormattedText(playerid, COLOR_PHONE, "%d) %s - %d.", id, gContactMemoryName[simcard][id], gContactMemoryNR[simcard][id]);
		}
		SendClientMessage(playerid, COLOR_PHONE, "*** Veel tegevusi: uuri salvesta kustuta");
	}
	return 1;
}

COMMAND:valjuh22ldi(playerid, params[])
{
	if(!gPlayerPhone[playerid][hasPhone]) return SendClientMessage(playerid, COLOR_RED, "Sul pole telefoni!");
	if(!gPlayerPhone[playerid][simCardIn]) return SendClientMessage(playerid, COLOR_RED, "Su telefonis pole SIM-kaarti!");
	if(gPlayerPhone[playerid][onCall] != CALL_CONNECTED) return SendClientMessage(playerid, COLOR_RED, "Sul pole kıne pooleli.");

	gPlayerPhone[playerid][onCall] = ((gPlayerPhone[playerid][onCall])?(false):(true));
	SendFormattedText(playerid, COLOR_PHONE, "Valjuh‰‰ldi %s.", ((gPlayerPhone[playerid][onCall])?("sees"):("v‰ljas")));
	return 1;
}

COMMAND:vasta(playerid, params[])
{
	if(!gPlayerPhone[playerid][hasPhone]) return SendClientMessage(playerid, COLOR_RED, "Sul pole telefoni!");
	if(!gPlayerPhone[playerid][simCardIn]) return SendClientMessage(playerid, COLOR_RED, "Su telefonis pole SIM-kaarti!");
	if(gPlayerPhone[playerid][onCall] != CALL_RECIVE) return SendClientMessage(playerid, COLOR_RED, "Keegi ei helista sulle!");
	
	new otherId = gPlayerPhone[playerid][callPlayer];
	gPlayerPhone[playerid][onCall] = CALL_CONNECTED;
	gPlayerPhone[otherId][onCall] = CALL_CONNECTED;
	
	SendClientMessage(playerid, COLOR_PHONE, "...¸hendatud... (( saad n¸¸d telefoni r‰‰kida ))");
	SendClientMessage(otherId, COLOR_PHONE, "...¸hendatud... (( saad n¸¸d telefoni r‰‰kida ))");
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
	return 1;
}

COMMAND:katkesta(playerid, params[])
{
	if(!gPlayerPhone[playerid][hasPhone]) return SendClientMessage(playerid, COLOR_RED, "Sul pole telefoni!");
	if(!gPlayerPhone[playerid][simCardIn]) return SendClientMessage(playerid, COLOR_RED, "Su telefonis pole SIM-kaarti!");
	
	if(gPlayerPhone[playerid][onCall] == CALL_RECIVE)
	{
		EndCall(playerid, HANGUP_ME);
		return 1;
	}
	else if(gPlayerPhone[playerid][onCall] == CALL_CONNECTED)
	{
		EndCall(playerid, HANGUP_ME);
		return 1;
	}	
	
	return SendClientMessage(playerid, COLOR_RED, "Keegi ei helista sulle/sa ei helista kellegile!");
}

/*
*    PUBLICS
*/

public GiveSimCard(playerid, company)
{
	new freeId = Itter_Free(SimCard);
	if(freeId == -1) return 1;
	
	new nr = GenerateRandomNumber(company);
	gSimCards[freeId][sNumber] = nr;
	
	gSimCards[freeId][companyId] = company;
	Itter_Add(SimCard, freeId);
	
	giveItem(playerid, ITEM_SIMCARD, freeId);
	return 0;
}

public ActivateSimCard(playerid, selectedCard, other)
{
	if(!gPlayerPhone[playerid][hasPhone])
	{
		SendClientMessage(playerid, COLOR_RED, "Sul pole telefoni kuhu seda simkaarti panna!");
		return 0;
	}
	if(gPlayerPhone[playerid][simCardIn] && gPlayerPhone[playerid][simCard] == selectedCard)
	{
		SendClientMessage(playerid, COLOR_YELLOW, "See simkaart on juba su telefonis.");
		return 0;
	}
	
	gPlayerPhone[playerid][simCard] = selectedCard;
	gPlayerPhone[playerid][simCardIn] = true;
	SendClientMessage(playerid, COLOR_YELLOW, "Paigaldasid oma telefoni edukalt SIM-Kaardi.");
	return 1;
}

public PlayerCallNumber(playerid, number)
{
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
	gPlayerPhone[playerid][callPlayer] = findPlayerFromNumber(number);
	gPlayerPhone[playerid][onCall] = CALL_PLAYER;
	gPlayerPhone[playerid][ringTime] = 20;
	
	if(gPlayerPhone[playerid][callPlayer] != -1)
	{
		new otherId = gPlayerPhone[playerid][callPlayer];
		
		if(gPlayerPhone[otherId][onCall] == CALL_NONE)
		{
			gPlayerPhone[otherId][callPlayer] = playerid;
			gPlayerPhone[otherId][onCall] = CALL_RECIVE;
			gPlayerPhone[otherId][ringTime] = 20;
		}
		else
		{
			EndCall(playerid, CALL_NUMBER_INUSE);
		}
	}
}

public EndCall(playerid, reason)
{	
	gPlayerPhone[playerid][callPlayer] = -1;
	gPlayerPhone[playerid][onCall] = CALL_NONE;
	gPlayerPhone[playerid][ringTime] = 0;
	
	if(reason == CALL_END_WRONG_NR)
	{
		SendClientMessage(playerid, COLOR_PHONE, "...telefon millele te helistate ei ole sisse l¸litatud vıi asub v‰ljaspool teeninduspiirkonda...");
	}
	else if(reason == CALL_NUMBER_INUSE)
	{
		SendClientMessage(playerid, COLOR_PHONE, "...kinnine toon...");
	}
	else if(reason == CALL_END_NO_ANWSER)
	{
		SendClientMessage(playerid, COLOR_PHONE, "...ei vasta...");
	}
	else if(reason == CALL_END_DENIED)
	{
		SendClientMessage(playerid, COLOR_PHONE, "...kınest keelduti...");
	}
	else if(reason == CALL_END_HANGUP || reason == CALL_END_UNKNOWN)
	{
		SendClientMessage(playerid, COLOR_PHONE, "...kıne lıppes...");
	}
	else if(reason == CALL_END_HANGUP_ME)
	{
		SendClientMessage(playerid, COLOR_PHONE, "panid toru ‰ra");
	}
	else if(reason == CALL_END_HANGUP_OT)
	{
		SendClientMessage(playerid, COLOR_PHONE, "teine m‰ngija pani toru ‰ra");
	}
	
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);
}

public PhoneTimer()
{
	foreach(User, playerid)
	{
		if(gPlayerPhone[playerid][onCall] == CALL_PLAYER)
		{
			if(gPlayerPhone[playerid][callPlayer] == -1)
			{
				EndCall(playerid, CALL_END_WRONG_NR);
				continue;
			}
			
			gPlayerPhone[playerid][ringTime]--;
			if(gPlayerPhone[playerid][ringTime] < 0)
			{
				EndCall(playerid, CALL_END_NO_ANWSER);
			}
			
			new otherId = gPlayerPhone[playerid][callPlayer];
			if(otherId < 0 || otherId > MAX_PLAYERS || !IsPlayerConnected(otherId) || gPlayerPhone[otherId][onCall] == CALL_NONE) EndCall(playerid, CALL_END_DENIED);
		}
		else if(gPlayerPhone[playerid][onCall] == CALL_CONNECTED)
		{
			new otherId = gPlayerPhone[playerid][callPlayer];			
			if(otherId < 0 || otherId > MAX_PLAYERS || !IsPlayerConnected(otherId) || gPlayerPhone[otherId][onCall] == CALL_NONE)
			{
				EndCall(playerid, CALL_END_HANGUP);
			}
		}
		else if(gPlayerPhone[playerid][onCall] == CALL_RECIVE)
		{
			new otherId = gPlayerPhone[playerid][callPlayer];
			if(otherId < 0 || otherId > MAX_PLAYERS || !IsPlayerConnected(otherId) || gPlayerPhone[otherId][onCall] == CALL_NONE) EndCall(playerid, CALL_END_HANGUP_OT);
			
			gPlayerPhone[playerid][ringTime]--;
			if(gPlayerPhone[playerid][ringTime] > 0)
			{
				// Play Music
				SendClientMessage(playerid, COLOR_PHONE, "Su telefon heliseb... Kasuta /vasta vıi /katkesta.");
				
				new Float: x, Float: y, Float: z;
				GetPlayerPos(playerid, x, y, z);
				
				if(ringDoneTime[playerid] == 0)
				{
					ringDoneTimer[playerid] = SetTimerEx("PlayerPhoneRing", 50, 1, "ifff", playerid, x, y, z);
				}
			}		
			else if(gPlayerPhone[playerid][ringTime] == -1) PlayerPlaySound(playerid, 1139, 0.0, 0.0, 0.0);
		}
	}
}

public PlayerPhoneRing(playerid, Float: x, Float: y, Float: z)
{
	ringDoneTime[playerid]++;
	if(ringDoneTime[playerid] > 5)
	{
		KillTimer(ringDoneTimer[playerid]);
		ringDoneTime[playerid] = 0;
	}
	
	foreach(User, i)
	{
		if(IsPlayerInRangeOfPoint(i, 5.0, x, y, z))
		{
			PlayerPlaySound(i, 1138, 0.0, 0.0, 0.0);
		}
	}
}

/*
*    ALS
*/

public OnGameModeInit()
{
	SetTimer("PhoneTimer", 1013, 1);
	
	g_Phone_Has_OPT = funcidx("ph_Phone_OnPlayerText");
	g_Phone_Has_OPD = funcidx("Phone_OnPlayerDisconnect");
	g_Phone_Has_ODR = funcidx("Phone_OnDialogResponse");
	
	if (funcidx("ph_Phone_OnGameModeInit") != -1)
    {
        return CallLocalFunction("ph_Phone_OnGameModeInit", "");
    }
    return 1;
}

public OnPlayerDisconnect(playerid)
{
	gPlayerPhone[playerid][hasPhone] = false;
	gPlayerPhone[playerid][simCardIn] = false;
	gPlayerPhone[playerid][speakerOn] = false;
	gPlayerPhone[playerid][simCard] = -1;
	gPlayerPhone[playerid][onCall] = CALL_NONE;
	gPlayerPhone[playerid][callPlayer] = -1;
	
    if (g_Phone_Has_OPD != -1)
    {
        return CallLocalFunction("Phone_OnPlayerDisconnect", "i", playerid);
    }
    return 1;
}


public OnPlayerText(playerid, text[])
{
	if(gPlayerPhone[playerid][onCall] == CALL_CONNECTED)
	{
		new otherId = gPlayerPhone[playerid][callPlayer];
		if(otherId < 0 || otherId > MAX_PLAYERS || !IsPlayerConnected(otherId) || gPlayerPhone[otherId][onCall] == CALL_NONE)
		{
			EndCall(playerid, CALL_END_HANGUP);
		}
		else
		{
			new string[128];
			new delay = ( strlen(text) * 150 ) + 2000;
			
			format(string, 128, "TELEFON %s:  %s", pInfo[playerid][pCharName], text);
			SetPlayerChatBubble(playerid, string, COLOR_PHONE, 10.0, delay);
			SCMTAInPlayerRadius(playerid, 10, COLOR_PHONE, string);
			
			if(gPlayerPhone[otherId][speakerOn])
			{
				SetPlayerChatBubble(playerid, string, COLOR_PHONE, 10.0, delay);
				SCMTAInPlayerRadius(playerid, 10, COLOR_PHONE, string);
			}
			else SendClientMessage(otherId, COLOR_PHONE, string);
		}		
		
		return 0;
	}
	
    if (g_Phone_Has_OPT != -1)
    {
        return CallLocalFunction("ph_Phone_OnPlayerText", "is", playerid, text);
    }
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_PHONE_ADD)
	{
		if(response == 0) return 1;
		else
		{
			if(gPlayerCMemoryAdding[playerid] == 1)
			{
				format(gContactMemoryName[gPlayerPhone[playerid][simCardIn]][gPlayerCMemorySlot[playerid]], 16, "%s", inputtext);
				gPlayerCMemoryAdding[playerid]++;				
				ShowPlayerDialog(playerid, DIALOG_PHONE_ADD, DIALOG_STYLE_INPUT, "Lisa Kontakt", "Number mida soovid salvestada:\n", "Salvesta", "Katkesta");
				return 1;
			}
			else if(gPlayerCMemoryAdding[playerid] == 2)
			{
				gContactMemoryNR[gPlayerPhone[playerid][simCardIn]][gPlayerCMemorySlot[playerid]] = strval(inputtext);
				gPlayerCMemoryAdding[playerid] = 0;
				gPlayerCMemorySlot[playerid] = 0;
				return 1;
			}
		}
	}

    if (g_Phone_Has_ODR != -1)
    {
        return CallLocalFunction("Phone_OnDialogResponse", "iiiis", playerid, dialogid, response, listitem, inputtext);
    }
    return 1;
}

#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit ph_Phone_OnGameModeInit

#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect Phone_OnPlayerDisconnect

#if defined _ALS_OnPlayerText
    #undef OnPlayerText
#else
    #define _ALS_OnPlayerText
#endif
#define OnPlayerText ph_Phone_OnPlayerText

#if defined _ALS_OnDialogResponse
    #undef OnDialogResponse
#else
    #define _ALS_OnDialogResponse
#endif
#define OnDialogResponse Phone_OnDialogResponse