

/*
*    DEFINES
*/

#define COLOR_CHAT 0xf2ffacAA
#define SMART_COLOR 0x00000005

#define MAX_SMART_NPC 10

#define MAX_MOODS 			6
#define MAX_AUTOMESSAGES 	6
#define MAX_TRIGGERGROUPS 	6
#define MAX_SENTENCES 		64
#define MAX_TRIGGERWORDS 	64
#define MAX_TEMPA			10

#define MAX_MOOD 3.0

#define DEFAULT_NOANWSER	"ok siis"

#define DEFAULT_NORENEW		"Ma küll su ülemus pole!"
#define DEFAULT_NORENEW2	"Oota kuni leping läbi saab."
#define DEFAULT_NOJOB		"Ma ei saa sind tööle võtta kui sul juba töö on."

/*
*    GLOBALS
*/

enum smartInf
{
	mySelf,
	myName[16],
	myScript[16],
	myTimer,
	Float: myMood,
	bool: myConnected,
	bool: mySpawned,
	
	Float: myX,
	Float: myY,
	Float: myZ,
	Float: myAng,
	mySkin,
	myJobId
};
new SmartNpc[MAX_SMART_NPC][smartInf];

new bool: inMyArea[MAX_SMART_NPC][MAX_PLAYERS]; // AutoMSG stuff
Itter_Create(SmartNPC, MAX_SMART_NPC);

Itter_Create2(sNpcTGroup, MAX_SMART_NPC, MAX_TRIGGERGROUPS);

/*
*    CHAT
*/

new gTriggerGroups[MAX_TRIGGERGROUPS];
Itter_Create(TriggerGroup, MAX_TRIGGERGROUPS);

enum tWordInf
{
	tGroupId,
	word1[32]
};
new gTriggerWords[MAX_TRIGGERWORDS][tWordInf];
Itter_Create(TriggerWord, MAX_TRIGGERWORDS);

enum sentenceInf
{
	mood,
	sTGroupId,
	sentence[128],
	sAnimLib[16],
	sAnimName[32],
	Function[32],
	bool: pFunction,
	bool: plyFunction,
	bool: sAnim,
	bool: sTNegative
};
new gSentences[MAX_SENTENCES][sentenceInf];
Itter_Create(Sentence, MAX_SENTENCES);

enum autMsgInf
{
	gAutoMessage[128],
	gAutoMood,
	gAutoNPC
};
new gAutoMessages[MAX_AUTOMESSAGES][autMsgInf];
Itter_Create(AutoMessage, MAX_AUTOMESSAGES);


/*
*    FORWARDS
*/

forward RegisterAllSmartNPC();
forward ConnectAllSmartNPC();
forward RegisterSmartNpc(name[], script[], skin, Float: posX, Float: posY, Float: posZ, Float: posAng);
forward SmartChatWithMe(playerid, text[]);
forward AutoMessageTimer(smartId);
forward sendAuto(smartid, text);
forward sendAnwser(smartid, text);

forward AddTriggerGroup(moodMod);
forward AddTriggerWord(tGroup, word[]);
forward AddSentence(tGroup, moodLevel, sent[]);
forward AddDefaultMessage(moodLevel, sent[]);
forward AddSentenceContractFunction(sentenceId, pFunc);
forward AddSentencePlayerFunction(sentenceId, pFunc[]);
forward AddAutoMessage(NPCid, moodLevel, msg[]);
forward SetNegative(sentenceId);

/*
*    STOCK
*/

stock getSmartId(playerid)
{
	foreach(SmartNPC, i)
	{
		if(SmartNpc[i][mySelf] == playerid)
		{
			return i;
		}
	}
	return -1;
}

stock getSmartIdFromName(smartName[])
{
	foreach(SmartNPC, i)
	{
		if(!strcmp(SmartNpc[i][myName], smartName))
		{
			return i;
		}
	}
	return -1;
}

stock RegisterTriggerGroup(tgroup, smartid)
{
	if(smartid < 0 || smartid >= MAX_SMART_NPC) return 0;
	
	Itter_Add2(sNpcTGroup, smartid, tgroup);	
	return 1;
}

stock AnwserCheck(smartid, fromPlayer, gotMessage[])
{
	new anwsGroup = -1, bool: negative;
	if(strfind(gotMessage, "ei", true) != -1) negative = true;
	else negative = false;
	
	foreach2(sNpcTGroup, smartid, grupp)
	{
		foreach(TriggerWord, i)
		{
			if(gTriggerWords[i][tGroupId] != grupp)
			{
				continue;
			}
			
			if(strfind(gotMessage, gTriggerWords[i][word1], true, 0) != -1)
			{			
				anwsGroup = gTriggerWords[i][tGroupId];
				break;
			}
		}
	}
	
	if(anwsGroup > -1)
	{
		// if mood after mod is bigger than max or smaller than 0 fix the error, else set it to a new value.
		SmartNpc[smartid][myMood] += gTriggerGroups[anwsGroup];
		
		if(SmartNpc[smartid][myMood] >= MAX_MOOD) SmartNpc[smartid][myMood] = MAX_MOOD;
		else if(SmartNpc[smartid][myMood] < 0) SmartNpc[smartid][myMood] = 0;
	}
	
	new hits = 0, temp[MAX_TEMPA];
	
	foreach(Sentence, i)
	{
		if(hits >= MAX_TEMPA) break;
		
		if(gSentences[i][sTGroupId] == anwsGroup)
		{
			if(gSentences[i][mood] == SmartNpc[smartid][myMood] && (anwsGroup < 2 || negative == gSentences[i][sTNegative]))
			{
				temp[hits] = i;
				hits++;
			}
		}
	}
	new randMemb = (hits>0)?random(hits):-1;
	if(randMemb != -1)
	{	
		new send = temp[randMemb];
				
		if(gSentences[send][sAnim])
		{
			ApplyAnimation(SmartNpc[smartid][mySelf], gSentences[send][sAnimLib], gSentences[send][sAnimName],1.0,1,1,1,1,0);
		}
		
		if(gSentences[send][plyFunction])
		{
			new ret = CallLocalFunction(gSentences[send][Function], "ii", fromPlayer, SmartNpc[smartid][myJobId]);
			
			if(ret == 1)
			{
				SetTimerEx("sendAnwser", 150, 0, "ii", smartid, -2);
				return 1;
			}
			else if(ret == 2)
			{
				SetTimerEx("sendAnwser", 150, 0, "ii", smartid, -3);
				return 1;
			}
			else if(ret == 3)
			{
				SetTimerEx("sendAnwser", 150, 0, "ii", smartid, -4);
				return 1;
			}
		}
			
		SetTimerEx("sendAnwser", 150, 0, "ii", smartid, send);
		
		return 1;
	}
	SetTimerEx("sendAnwser", 150, 0, "ii", smartid, -1);
	return 1;
}

stock AutoMessage(smartid)
{
	new hits, temp[MAX_TEMPA];
	
	foreach(AutoMessage, i)
	{
		if(gAutoMessages[i][gAutoNPC] != smartid) continue;
		
		if(hits >= MAX_TEMPA) break;
		if(gAutoMessages[i][gAutoMood] == SmartNpc[smartid][myMood])
		{
			temp[hits] = i;
			hits++;
		}
	}

	new randMemb = (hits>0)?random(hits):-1;
	if(randMemb != -1)
	{
		new send = temp[randMemb];
		SetTimerEx("sendAuto", 150, 0, "ii", smartid, send);
	}
}

public sendAuto(smartid, text)
{
	if(text != -1) 	OnPlayerText(SmartNpc[smartid][mySelf], gAutoMessages[text][gAutoMessage]);
}

public sendAnwser(smartid, text)
{
	if(text == -1) 			OnPlayerText(SmartNpc[smartid][mySelf], DEFAULT_NOANWSER);
	else if(text == -2) 	OnPlayerText(SmartNpc[smartid][mySelf], DEFAULT_NORENEW);
	else if(text == -3) 	OnPlayerText(SmartNpc[smartid][mySelf], DEFAULT_NORENEW2);
	else if(text == -4) 	OnPlayerText(SmartNpc[smartid][mySelf], DEFAULT_NOJOB);
	else 					OnPlayerText(SmartNpc[smartid][mySelf], gSentences[text][sentence]);
}

/*
*    PUBLICS
*/

public ConnectAllSmartNPC()
{
	foreach(SmartNPC, i)
	{
		printf("%d, ConnectNPC(%s, %s);", i, SmartNpc[i][myName], SmartNpc[i][myScript]);
		ConnectNPC(SmartNpc[i][myName], SmartNpc[i][myScript]);
	}	
}

public RegisterSmartNpc(name[], script[], skin, Float: posX, Float: posY, Float: posZ, Float: posAng)
{
	new freeId = Itter_Free(SmartNPC);
	if(freeId == -1) return -1;
	
	format(SmartNpc[freeId][myName], 32, "%s", name);
	format(SmartNpc[freeId][myScript], 32, "%s", script);
	
	SmartNpc[freeId][myX] = posX;
	SmartNpc[freeId][myY] = posY;
	SmartNpc[freeId][myZ] = posZ;
	SmartNpc[freeId][myAng] = posAng;
	SmartNpc[freeId][mySkin] = skin;
	
	Itter_Add(SmartNPC, freeId);
	return freeId;
}

public SmartChatWithMe(playerid, text[])
{
	new Float: x, Float: y, Float: z;
	GetPlayerPos(playerid, x, y, z);	

	foreach(SmartNPC, i)
	{		
		if(playerid != SmartNpc[i][mySelf] && IsPlayerInRangeOfPoint(SmartNpc[i][mySelf], 10.0, x, y, z))
		{
			AnwserCheck(i, playerid, text);
			return 1;
		}	
	}
	return 0;
}

public AutoMessageTimer(smartId)
{
	if(!SmartNpc[smartId][mySpawned])
	{
		SmartNpc[smartId][mySpawned] = true;
		SetPlayerPos(SmartNpc[smartId][mySelf], SmartNpc[smartId][myX], SmartNpc[smartId][myY], SmartNpc[smartId][myZ]);
		SetPlayerFacingAngle(SmartNpc[smartId][mySelf], SmartNpc[smartId][myAng]);
		SetPlayerSkin(SmartNpc[smartId][mySelf], SmartNpc[smartId][mySkin]);
	}

	new Float: x, Float: y, Float: z;
	GetPlayerPos(SmartNpc[smartId][mySelf], x, y, z);	

	foreach(Player, i)
	{
		if(i != SmartNpc[smartId][mySelf] && IsPlayerInRangeOfPoint(i, 10.0, x, y, z))
		{
			if(!inMyArea[smartId][i])
			{
				inMyArea[smartId][i] = true;
				AutoMessage(smartId);
			}
		}
		else if(inMyArea[smartId][i])
		{
			inMyArea[smartId][i] = false;
		}
	}
	return 1;
}

public AddTriggerGroup(moodMod)
{
	new freeId = Itter_Free(TriggerGroup);
	if(freeId == -1) return -1;
	
	gTriggerGroups[freeId] = moodMod;
	Itter_Add(TriggerGroup, freeId);
	return freeId;
}

public AddTriggerWord(tGroup, word[])
{
	new freeId = Itter_Free(TriggerWord);
	if(freeId == -1) return -1;
	
	gTriggerWords[freeId][tGroupId] = tGroup;
	format(gTriggerWords[freeId][word1], 32, "%s", word);
	
	Itter_Add(TriggerWord, freeId);
	return freeId;	
}

public AddSentence(tGroup, moodLevel, sent[])
{
	new freeId = Itter_Free(Sentence);
	if(freeId == -1) return -1;
	
	gSentences[freeId][sTGroupId] = tGroup;
	gSentences[freeId][mood] = moodLevel;
	format(gSentences[freeId][sentence], 32, "%s", sent);
	
	Itter_Add(Sentence, freeId);
	return freeId;
}

public AddDefaultMessage(moodLevel, sent[])
{
	new freeId = Itter_Free(Sentence);
	if(freeId == -1) return -1;
	
	gSentences[freeId][sTGroupId] = -1;
	gSentences[freeId][mood] = moodLevel;
	format(gSentences[freeId][sentence], 32, "%s", sent);
	
	Itter_Add(Sentence, freeId);
	return freeId;
}

public AddSentencePlayerFunction(sentenceId, pFunc[])
{
	if(sentenceId < 0 || sentenceId >= MAX_SENTENCES) return 0;
	
	format(gSentences[sentenceId][Function], 32, "%s", pFunc);
	gSentences[sentenceId][plyFunction] = true;
	return 1;
}

public AddAutoMessage(NPCid, moodLevel, msg[])
{
	new freeId = Itter_Free(AutoMessage);
	if(freeId == -1) return -1;
	
	gAutoMessages[freeId][gAutoMood] = moodLevel;
	gAutoMessages[freeId][gAutoNPC] = NPCid;
	format(gAutoMessages[freeId][gAutoMessage], 32, "%s", msg);
	
	Itter_Add(AutoMessage, freeId);
	return freeId;	
}

public SetNegative(sentenceId)
{
	if(sentenceId < 0 || sentenceId >= MAX_SENTENCES) return 0;
	gSentences[sentenceId][sTNegative] = true;
	return 1;
}

/*
*    ALS Silent
*/

#if !defined FILTERSCRIPT

public OnGameModeInit()
{
	Itter_Init2(sNpcTGroup);

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
				if(!SmartNpc[smID][myConnected]) // Not Connected Yet
				{
					printf("Me: %d", playerid);
					
					SmartNpc[smID][myTimer] = SetTimerEx("AutoMessageTimer", 3000, 1, "i", smID);
					SmartNpc[smID][mySelf] = playerid;
					SmartNpc[smID][myConnected] = true;
					SmartNpc[smID][myMood] = MAX_MOOD;
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
		SmartNpc[smID][mySelf] = -1;
		KillTimer(SmartNpc[smID][myTimer]);
		SmartNpc[smID][myConnected] = false;
		ConnectNPC(SmartNpc[smID][myName], SmartNpc[smID][myScript]);
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