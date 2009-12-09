

/*
*    DEFINES
*/

#define COLOR_CHAT 0xf2ffacAA
#define SMART_COLOR 0x00000005

#define MAX_SMART_NPC 10

/*
*    GLOBALS
*/

new mySelf[MAX_SMART_NPC] = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1}; // SampIds
new bool: mySelfR[MAX_SMART_NPC]; // SampIds
new mySelfN[MAX_SMART_NPC][32]; // Names
new mySelfS[MAX_SMART_NPC][32]; // Scripts

new bool: inMyArea[MAX_SMART_NPC][MAX_PLAYERS]; // AutoMSG stuff

/*
*    FORWARDS
*/

forward RegisterAllSmartNPC();
forward ConnectAllSmartNPC();
forward RegisterSmartNpc(name[], script[]);
forward SendSmartMessage(smartId, string[]);
forward SmartChatWithMe(playerid, text[]);
forward AutoMessageTimer(smartId);

/*
*    STOCK
*/

stock getSmartId(playerid)
{
	for(new i = 0; i < MAX_SMART_NPC; i++)
	{
		if(!mySelfR[i]) continue;
		if(mySelf[i] == playerid)
		{
			return i;
		}
	}
	return -1;
}

stock getSmartIdFromName(smartName[])
{
	for(new i = 0; i < MAX_SMART_NPC; i++)
	{
		if(!mySelfR[i]) continue;
		if(!strcmp(mySelfN[i], smartName))
		{
			return i;
		}
	}
	return -1;
}

/*
*    PUBLICS
*/

public ConnectAllSmartNPC()
{
	for(new i = 0; i < MAX_SMART_NPC; i++)
	{
		if(!mySelfR[i]) continue;
		printf("%d, ConnectNPC(%s, %s);", i, mySelfN[i], mySelfS[i]);
		ConnectNPC(mySelfN[i], mySelfS[i]);
	}	
}

public RegisterSmartNpc(name[], script[])
{
	new freeId = -1;
	for(new i = 0; i < MAX_SMART_NPC; i++)
	{
		if(!mySelfR[i]) freeId = i;
	}
	if(freeId == -1) return -1;
	
	format(mySelfN[freeId], 32, "%s", name);
	format(mySelfS[freeId], 32, "%s", script);
	mySelfR[freeId] = true;	
	printf("%d, RegisterSmartNpc(%s, %s);", freeId, mySelfN[freeId], mySelfS[freeId]);
	return freeId;
}

public SendSmartMessage(smartId, string[])
{
	if(mySelf[smartId] == -1) return 0;

	new Float: x, Float: y, Float: z;
	GetPlayerPos(mySelf[smartId], x, y, z);
	
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(i == mySelf[smartId]) continue;
		if(!IsPlayerConnected(i)) continue;
		
		if(IsPlayerInRangeOfPoint(i, 10.0, x, y, z))
		{
			SendClientMessage(i, COLOR_CHAT, string);
		}
	}
	return 1;
}

public SmartChatWithMe(playerid, text[])
{
	new string[136];
	format(string, sizeof(string), "%d %s", playerid, text);
	
	new Float: x, Float: y, Float: z;
	GetPlayerPos(playerid, x, y, z);	

	for(new i = 0; i < MAX_SMART_NPC; i++)
	{
		if(!mySelfR[i]) continue;
		if(playerid == mySelf[i]) continue;
		
		if(IsPlayerInRangeOfPoint(mySelf[i], 10.0, x, y, z))
		{
			SendClientMessage(mySelf[i], SMART_COLOR, string);
			return 1;
		}	
	}
	return 0;
}

public AutoMessageTimer(smartId)
{
	new Float: x, Float: y, Float: z;
	GetPlayerPos(mySelf[smartId], x, y, z);	

	foreach(Player, i)
	{
		if(IsPlayerInRangeOfPoint(i, 10.0, x, y, z))
		{
			if(!inMyArea[smartId][i])
			{
				inMyArea[smartId][i] = true;
				new string[128];
				format(string, 128, "%d autoMessage", i);
				SendClientMessage(smartId, SMART_COLOR, string);
			}
		}
		else if(inMyArea[smartId][i])
		{
			inMyArea[smartId][i] = false;
		}
	}
	SetTimerEx("AutoMessageTimer", 3000, 0, "i", smartId);
	return 1;
}

/*
*    ALS Silent
*/

#if !defined FILTERSCRIPT

public OnGameModeInit()
{
	RegisterAllSmartNPC();
	SetTimer("ConnectAllSmartNPC", 5000, 0);
	
	if (funcidx("SmartNPC_OnGameModeInit") != -1)
    {
        return CallLocalFunction("SmartNPC_OnGameModeInit", "");
    }	
    return 1;	
}

#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit SmartNPC_OnGameModeInit

forward SmartNPC_OnGameModeInit();

#else

#error "See ei tööta FSis!"

#endif

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
			
			new smID = getSmartIdFromName(tempStr);
			if(smID == -1)
			{
				Kick(playerid);
			}
			else
			{
				if(mySelf[smID] == -1) // Not Connected Yet
				{
					printf("Me: %d", playerid);
					SetTimerEx("AutoMessageTimer", 3000, 0, "i", smID);
					mySelf[smID] = playerid;
				}
				else Kick(playerid); // This SmartNPC is already Connected.
			}
		}
		else
		{
			print("NPC Flood Attempt!");
			Kick(playerid);
		}
	}
	
	if (funcidx("SmartNPC_OnPlayerConnect") != -1)
    {
        return CallLocalFunction("SmartNPC_OnPlayerConnect", "i", playerid);
    }	
    return 1;	
}

#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect SmartNPC_OnPlayerConnect

forward SmartNPC_OnPlayerConnect(playerid);

public OnPlayerDisconnect(playerid)
{
	new smID = getSmartId(playerid);
	if(smID != -1)
	{
		ConnectNPC(mySelfN[smID], mySelfS[smID]);
		mySelf[smID] = -1;
	}
	
	if (funcidx("SmartNPC_OnPlayerDisconnect") != -1)
    {
        return CallLocalFunction("SmartNPC_OnPlayerDisconnect", "i", playerid);
    }	
    return 1;	
}

#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect SmartNPC_OnPlayerDisconnect

forward SmartNPC_OnPlayerDisconnect(playerid);

COMMAND:smartspawn(playerid, params[])
{
	new smID = getSmartId(playerid);
	if(smID == -1) return 0;

	new skin, Float:x, Float:y, Float:z, Float:a;
	if(sscanf(params, "dffff", skin, x, y, z, a) == 0)
	{
		SetPlayerSkin(playerid, skin);
		SetPlayerPos(playerid, x, y, z);
		SetPlayerFacingAngle(playerid, a);
	}
	return 1;
}

COMMAND:smartAnwser(playerid, params[])
{
	new smID = getSmartId(playerid);
	if(smID == -1) return 0;
	
	new str[128];
	if(sscanf(params, "s", str) == 0)
	{
		SendSmartMessage(smID, str);
	}
	return 1;
}

COMMAND:smartlog(playerid, params[])
{
	new smID = getSmartId(playerid);
	if(smID == -1) return 0;
	
	new str[128];
	if(sscanf(params, "s", str) == 0)
	{
		printf("SMART(%s)", mySelfN[smID], str);
	}
	return 1;
}

COMMAND:smartanim(playerid, params[])
{
	new smID = getSmartId(playerid);
	if(smID == -1) return 0;
	
	new str1[32], str2[32];
	if(sscanf(params, "ss", str1, str2) == 0)
	{
		ApplyAnimation(playerid, str1, str2,1.0,1,1,1,1,0);
		ApplyAnimation(playerid, str1, str2,1.0,1,1,1,1,0);
	}
	return 1;
}

COMMAND:callpfunction(playerid, params[])
{
	new smID = getSmartId(playerid);
	if(smID == -1) return 0;
	
	new str1[32], val;
	if(sscanf(params, "sd", str1, val) == 0)
	{
		CallLocalFunction(str1, "dds", val, 1, 5);
	}
	return 1;
}

#if !defined SMART_NO_ONTEXT

public OnPlayerText(playerid, text[])
{
	SmartChatWithMe(playerid, text);
	
	if (funcidx("SmartNPC_OnPlayerText") != -1)
    {
        return CallLocalFunction("SmartNPC_OnPlayerText", "is", playerid, text);
    }	
    return 1;	
}

forward SmartNPC_OnPlayerText(playerid, text[]);

#if defined _ALS_OnPlayerText
    #undef OnPlayerText
#else
    #define _ALS_OnPlayerText
#endif
#define OnPlayerText SmartNPC_OnPlayerText

#endif