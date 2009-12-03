
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
	
	foreach(Player, i)
	{
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
	if(mySelf == -1) return 0;
	if(strcmp(myName, MY_NAME)) return 0;
	
	new string[136];
	format(string, sizeof(string), "%d %s", playerid, text);
	
	#if defined GLOBALCHAT
	
	SendClientMessage(mySelf, SMART_COLOR, text);
	
	#else
	new Float: x, Float: y, Float: z;
	GetPlayerPos(mySelf, x, y, z);	

	if(IsPlayerInRangeOfPoint(playerid, 10.0, x, y, z))
	{
		SendClientMessage(mySelf, SMART_COLOR, text);
	}	
	#endif
	return 1;
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
		new tempStr[MAX_PLAYER_NAME];
		GetPlayerIp(playerid, tempStr, sizeof(tempStr));
		if(!strcmp(tempStr, "127.0.0.1"))
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

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(mySelf != -1 && playerid == mySelf)
	{
		if(!strcmp(cmdtext, "/smartAnwser", false, 12))
		{
			new str[128];
			if(sscanf(cmdtext[12], "s", str) == 0)
			{
				SendSmartMessage(str);
			}
		}
		if(!strcmp(cmdtext, "/smartlog", false, 9))
		{
			new str[128];
			if(sscanf(cmdtext[9], "s", str) == 0)
			{
				print(str);
			}
		}
	}
	
	if (funcidx("SmartNPC_OnPlayerCommandText") != -1)
    {
        return CallLocalFunction("SmartNPC_OnPlayerCommandText", "is", playerid, cmdtext);
    }	
    return 1;	
}

#if defined _ALS_OnPlayerCommandText
    #undef OnPlayerCommandText
#else
    #define _ALS_OnPlayerCommandText
#endif
#define OnPlayerCommandText SmartNPC_OnPlayerCommandText

forward SmartNPC_OnPlayerCommandText(playerid, cmdtext[]);

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