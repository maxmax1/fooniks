/*
*
*		SmartNPC
*		
*		Jyrno42 
*		eRP
*		
*		Licenced under the DoWhateverYaWantwithIt 1.0.
*
*/

#if !defined MAX_STRING

	#define MAX_STRING 128

#endif

#if !defined DEFAULT_MESSAGE

	#define DEFAULT_MESSAGE		"Speak slowly and precicely, I cannot understand what you're saying."
	
#endif

#if !defined DEFAULT_NOANWSER

	#define DEFAULT_NOANWSER	"I have nothing to say to you!"
	
#endif

#if !defined MYNAME

	#define MYNAME "Igor"
	
#endif

#include <YSI_XML>

#define MAX_MOODS 			5
#define MAX_AUTOMESSAGES 	5
#define MAX_TRIGGERGROUPS 	3
#define MAX_TRIGGERWORDS 	32

#define SMART_COLOR 0x00000005

new FALSE = false;

#define NPCLOG(%0,%1) do{new str[128]; format(str, 128, %0, %1); SmartLog(str);}while(FALSE)
#define CALLNATIVE(%0,%1) do{new str[128]; format(str, 128, %0, %1); SmartNative(str);}while(FALSE)

forward makeSmart();
forward onXmlResponse(handler[]);

/*
*    <npc>
*/

enum myInf
{
	mySkin,
	myName[MAX_PLAYER_NAME],
	myMood
};
new gMySelf[myInf];

/*
*    <moods>
*/

new gMoods[MAX_MOODS][16];

/*
*    <triggergroup> 's
*/

enum triggerInf
{
	name[16],
	moodModifier
};
new gTriggerGroups[MAX_TRIGGERGROUPS][triggerInf];
Itter_Create(TriggerGroup, MAX_TRIGGERGROUPS);

/*
*    <word> 's
*/

enum tWordInf
{
	tGroupId,
	word1[32],
	word2[32],
	bool: andSecond,
	bool: orSecond,
	bool: Synced
};
new gTriggerWords[MAX_TRIGGERWORDS][tWordInf];
Itter_Create(TriggerWord, MAX_TRIGGERWORDS);

/*
*    <sentence> 's
*/

enum sentenceInf
{
	mood,
	sTGroupId,
	sentence[128],
	sAnimLib[16],
	sAnimName[32],
	bool: sAnim
};
new gSentences[32][sentenceInf];
Itter_Create(Sentence, 32);
Itter_Create(tempAnwser, 10);

/*
*    <automessage> 's
*/
enum autMsgInf
{
	gAutoMessage[128],
	gAutoMood
};
new gAutoMessages[MAX_AUTOMESSAGES][autMsgInf];
Itter_Create(AutoMessage, MAX_AUTOMESSAGES);

/*
*    AnwserCheck
*/
stock AnwserCheck(fromPlayer, gotMessage[])
{
	new anwsGroup = scanForTriggerWords(gotMessage);
	if(anwsGroup > -1)
	{
		// if mood after mod is bigger than max or smaller than 0 fix the error, else set it to a new value.
		gMySelf[myMood] = gTriggerGroups[anwsGroup][moodModifier];
		
		if(gMySelf[myMood] >= MAX_MOODS) gMySelf[myMood] = MAX_MOODS-1;
		else if(gMySelf[myMood] < 0) gMySelf[myMood] = 0;
		
		// Send The Anwser..
		sendAnwser(fromPlayer, findMessage(anwsGroup));
		return 1;
	}
	sendAnwser(fromPlayer, DEFAULT_MESSAGE);
	return 1;
}

/*
*    scanForTriggerWords
*/
stock scanForTriggerWords(sentenceToScan[])
{
	foreach(TriggerWord, i)
	{
		if(gTriggerWords[i][andSecond])
		{
			if(strfind(sentenceToScan, gTriggerWords[i][word1], true) != -1 && strfind(sentenceToScan, gTriggerWords[i][word2], true) != -1)
			{
				return gTriggerWords[i][tGroupId];
			}
		}
		else if(gTriggerWords[i][orSecond])
		{
			if(strfind(sentenceToScan, gTriggerWords[i][word1], true) != -1 || strfind(sentenceToScan, gTriggerWords[i][word2], true) != -1)
			{
				return gTriggerWords[i][tGroupId];
			}
		}
		else
		{
			if(strfind(sentenceToScan, gTriggerWords[i][word1], true, 0) != -1) return gTriggerWords[i][tGroupId];
		}
	}
	return -1;
}

/*
*    SendAnwser
*/
stock sendAnwser(toPlayer, message[])
{
	#pragma unused toPlayer
	new string[128];
	format(string, 128, "/smartAnwser %s", message);
	SendCommand(string);
}

stock SmartLog(message[])
{
	new string[64];
	format(string, 64, "/smartlog %s", message);
	SendCommand(string);
}

stock SmartNative(message[])
{
	new string[64];
	format(string, 64, "/smartnative %s", message);
	SendCommand(string);
}

/*
*    FindMessage
*/
findMessage(anwserGroup)
{
	new string[128], hits;
	foreach(Sentence, i)
	{
		if(gSentences[i][sTGroupId] == anwserGroup)
		{
			if(gSentences[i][mood] == gMySelf[myMood])
			{
				hits++;
				Iter_Add(tempAnwser, i);
			}
		}
	}
	
	if(hits == 0) format(string, 128, "%s", DEFAULT_NOANWSER);
	else
	{
		new randMemb = Itter_Random(tempAnwser);
		format(string, 128, "%s", gSentences[randMemb][sentence]);
		
		if(gSentences[randMemb][sAnim])
		{
			CALLNATIVE("ApplyAnimation %s %s", gSentences[randMemb][sAnimLib], gSentences[randMemb][sAnimName]);
		}
		
		foreach(tempAnwser, e)
		{
			Iter_Remove(tempAnwser, e);
		}
	}
	
	return string;
}

/*
*    AutoMessage
*/
stock AutoMessage(toPlayer)
{
	#pragma unused toPlayer
	new hits;
	foreach(AutoMessage, i)
	{
		if(gAutoMessages[i][gAutoMood] == gMySelf[myMood])
		{
			Iter_Add(tempAnwser, i);
			hits++;
		}
	}
	if(hits > 0)
	{
		new randMemb = Itter_Random(tempAnwser);
		sendAnwser(0, gAutoMessages[randMemb][gAutoMessage]);
		
		foreach(tempAnwser, e)
		{
			Iter_Remove(tempAnwser, e);
		}	
	}
}

/*
*    Public 's
*/

public makeSmart()
{
	new botName[32];
	format(botName, 32, "%s.Brain.xml", MYNAME);
	if (fexist(botName))
	{
		new XML:xRules = XML_New();
		if (xRules != NO_XML_FILE)
		{
			XML_AddHandler(xRules, "npc", "npc");
			XML_AddHandler(xRules, "moods", "moods");
			XML_AddHandler(xRules, "triggergroup", "triggergroup");
			XML_AddHandler(xRules, "moodMod", "moodMod");
			XML_AddHandler(xRules, "sentence", "sentence");
			XML_Parse(xRules, botName);
			
			NPCLOG("%s loaded with skinid %d.", gMySelf[myName], gMySelf[mySkin]);
		}
	}
	else NPCLOG("BrainFile %s doesn't exist.", botName);
}

public onXmlResponse(handler[])
{
	static key[MAX_XML_ENTRY_NAME],
			val[MAX_XML_ENTRY_TEXT];
	if(!strcmp(handler, "npc"))
	{
		while (XML_GetKeyValue(key, val))
		{
			if(!strcmp(key, "name")) format(gMySelf[myName], MAX_PLAYER_NAME, "%s", val);
			else if(!strcmp(key, "skin")) gMySelf[mySkin] = strval(val);
		}
	}
	if(!strcmp(handler, "moods"))
	{
		new loop = true, tempStr[16], tempVal, got = 0;
		for(new i; loop; i++)
		{
			if(XML_GetKeyValue(key, val))
			{
				if(!strcmp(key, "mood"))
				{
					format(tempStr, 16, "%s", val);
					got++;
				}
				XML_GetKeyValue(key, val);
				if(!strcmp(key, "value"))
				{
					tempVal = strval(val);
					got++;
				}
				if(got > 1)
				{
					format(gMoods[tempVal], 16, "%s", tempStr);
					got = 0;
				}
			}
			else break;
		}
	}
	if(!strcmp(handler, "triggergroup"))
	{
		new got = 0, times = 0, loop = true;

		if(XML_GetKeyValue(key, val))
		{
			while(!strcmp(key, "word"))
			{
				new wordId = Itter_Free(TriggerWord);
				format(gTriggerWords[wordId][word1], 128, "%s", val);
				
				if(strfind(val, "(and)") != -1)
				{
					gTriggerWords[wordId][andSecond] = true;
				}
				else if(strfind(val, "(or)") != -1)
				{
					gTriggerWords[wordId][orSecond] = true;
				}
				
				gTriggerWords[wordId][Synced] = false;
				Itter_Add(TriggerWord, wordId);
				XML_GetKeyValue(key, val);
			}
			
			new freeId = Itter_Free(TriggerGroup);
			do
			{
				if(!strcmp(key, "name"))
				{
					format(gTriggerGroups[freeId][name], 16, "%s", val);
					got++;
				}	
				if(got > 0 || times > 3)
				{
					foreach(TriggerWord, i)
					{
						if(gTriggerWords[i][Synced] == false)
						{
							gTriggerWords[i][tGroupId] = freeId;
							gTriggerWords[i][Synced] = true;
						}
					}
					Itter_Add(TriggerGroup, freeId);
					break;
				}
				times++;
				XML_GetKeyValue(key, val);
			} while(loop)
		}
	}
	if(!strcmp(handler, "moodMod"))
	{
		new tempStr[32], tempVal;
		while (XML_GetKeyValue(key, val))
		{
			if(!strcmp(key, "group")) format(tempStr, 32, "%s", val);
			else if(!strcmp(key, "moodMod")) tempVal = strval(val);
		}
		
		foreach(TriggerGroup, i)
		{
			if(!strcmp(tempStr, gTriggerGroups[i][name]))
			{
				gTriggerGroups[i][moodModifier] = tempVal;
			}
		}
	}
	if(!strcmp(handler, "sentence"))
	{
		new freeId = Itter_Free(Sentence), tempStr[32];
		while (XML_GetKeyValue(key, val))
		{
			if(!strcmp(key, "text")) format(gSentences[freeId][sentence], 128, "%s", val);
			else if(!strcmp(key, "group")) format(tempStr, 16, "%s", val);
			else if(!strcmp(key, "mood")) gSentences[freeId][mood] = strval(val);
			else if(!strcmp(key, "lib"))
			{
				format(gSentences[freeId][sAnimLib], 16, "%s", val);
				gSentences[freeId][sAnim] = true;
			}
			else if(!strcmp(key, "animation")) format(gSentences[freeId][sAnimName], 32, "%s", val);
		}
		Itter_Add(Sentence, freeId);
		foreach(TriggerGroup, i)
		{
			if(!strcmp(tempStr, gTriggerGroups[i][name]))
			{
				gSentences[freeId][sTGroupId] = i;
			}
		}
	}
	if(!strcmp(handler, "automessages"))
	{
		new freeId = Itter_Free(AutoMessage);
		new got = 0, times = 0;
		while (XML_GetKeyValue(key, val) && times < 5)
		{
			if(!strcmp(key, "automessage"))
			{
				format(gAutoMessages[freeId][gAutoMessage], 128, "%s", val);
				got++;
			}
			else if(!strcmp(key, "mood"))
			{
				gAutoMessages[freeId][gAutoMood] = strval(val);
				got++;
			}
			
			if(got > 2)
			{
				Itter_Add(AutoMessage, freeId);
				break;
			}
			times++;
		}
	}
	return 1;
}