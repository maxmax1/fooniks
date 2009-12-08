
#define COLOR_CHAT 0xf2ffacAA
#define SMART_COLOR 0x00000005

#if !defined MY_NAME

	#define MY_NAME "Smart_NPC"

#endif

#if !defined NPC_SCRIPT

	#define NPC_SCRIPT "Smart_NPC"

#endif

new mySelf = -1;
new bool: inMyArea[MAX_PLAYERS];

forward SendSmartMessage(string[]);
forward SmartChatWithMe(myName[], playerid, text[]);
forward AutoMessageTimer();

public SendSmartMessage(string[])
{
	if(mySelf == -1) return 0;

	#if defined GLOBALCHAT
	
	SendClientMessageToAll(COLOR_CHAT, string);
	
	#else
	
	new Float: x, Float: y, Float: z;
	GetPlayerPos(mySelf, x, y, z);
	
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(i == mySelf) continue;
		if(!IsPlayerConnected(i)) continue;
		
		if(IsPlayerInRangeOfPoint(i, 10.0, x, y, z))
		{
			SendClientMessage(i, COLOR_CHAT, string);
		}
	}
	
	#endif
	return 1;
}

public SmartChatWithMe(myName[], playerid, text[])
{
	if(mySelf == -1) return 2;
	if(strcmp(myName, MY_NAME)) return 3;
	
	new string[136];
	format(string, sizeof(string), "%d %s", playerid, text);
	
	#if defined GLOBALCHAT
	
	SendClientMessage(mySelf, SMART_COLOR, string);
	return 0;
	
	#else
	new Float: x, Float: y, Float: z;
	GetPlayerPos(mySelf, x, y, z);	

	if(IsPlayerInRangeOfPoint(playerid, 10.0, x, y, z))
	{
		SendClientMessage(mySelf, SMART_COLOR, string);
		return 1;
	}	
	return 0;
	#endif
}

public AutoMessageTimer()
{
	if(mySelf == -1) return 0;
	new Float: x, Float: y, Float: z;
	GetPlayerPos(mySelf, x, y, z);	

	foreach(Player, i)
	{
		if(IsPlayerInRangeOfPoint(i, 10.0, x, y, z))
		{
			if(!inMyArea[i])
			{
				inMyArea[i] = true;
				new string[128];
				format(string, 128, "%d autoMessage", i);
				SendClientMessage(mySelf, SMART_COLOR, string);
			}
		}
		else if(inMyArea[i])
		{
			inMyArea[i] = false;
		}
	}
	SetTimer("AutoMessageTimer", 3000, 0);
	return 1;
}

/*
*    IMPLEMENTATION
*/
#if !defined FILTERSCRIPT

public OnGameModeInit()
{
	ConnectNPC(MY_NAME, NPC_SCRIPT);
	
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

public OnFilterScriptInit()
{
	ConnectNPC(MY_NAME, NPC_SCRIPT);
	
	if (funcidx("SmartNPC_OnFilterScriptInit") != -1)
    {
        return CallLocalFunction("SmartNPC_OnFilterScriptInit", "");
    }	
    return 1;	
}

#if defined _ALS_OnFilterScriptInit
    #undef OnFilterScriptInit
#else
    #define _ALS_OnFilterScriptInit
#endif
#define OnFilterScriptInit SmartNPC_OnFilterScriptInit

forward SmartNPC_OnFilterScriptInit();

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
			if(!strcmp(tempStr, MY_NAME))
			{
				mySelf = playerid;
				printf("Me: %d", mySelf);
				SetTimer("AutoMessageTimer", 3000, 0);
			}
		}
		else
		{
			print("NPC Flood Attempt!");
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
	if(mySelf != -1 && playerid == mySelf)
	{
		ConnectNPC(MY_NAME, NPC_SCRIPT);
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
	if(mySelf == -1 || playerid != mySelf) return 0;

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
	if(mySelf == -1 || playerid != mySelf) return 0;
	new str[128];
	if(sscanf(params, "s", str) == 0)
	{
		SendSmartMessage(str);
	}
	return 1;
}

COMMAND:smartlog(playerid, params[])
{
	if(mySelf == -1 || playerid != mySelf) return 0;
	new str[128];
	if(sscanf(params, "s", str) == 0)
	{
		print(str);
	}
	return 1;
}

COMMAND:smartanim(playerid, params[])
{
	if(mySelf == -1 || playerid != mySelf) return 0;
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
	if(mySelf == -1 || playerid != mySelf) return 0;
	new str1[32], val;
	if(sscanf(params, "sd", str1, val) == 0)
	{
		CallRemoteFunction(str1, "d", val);
	}
	return 1;
}

#if !defined SMART_NO_ONTEXT

public OnPlayerText(playerid, text[])
{
	if(mySelf != playerid && mySelf != -1)
	{
		SmartChatWithMe(MY_NAME, playerid, text);
	}
	
	if (funcidx("SmartNPC_OnPlayerText") != -1)
    {
        return CallLocalFunction("SmartNPC_OnPlayerText", "is", playerid, text);
    }	
    return 1;	
}

#if defined _ALS_OnPlayerText
    #undef OnPlayerText
#else
    #define _ALS_OnPlayerText
#endif
#define OnPlayerText SmartNPC_OnPlayerText

#endif