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

#if !defined MY_NAME

	#error "MY_NAME must be set!"
	
#endif

#include <YSI_XML>

#define MAX_MOODS 			6
#define MAX_AUTOMESSAGES 	6
#define MAX_TRIGGERGROUPS 	5
#define MAX_SENTENCES 		32
#define MAX_TRIGGERWORDS 	64

#define SMART_COLOR 0x00000005

new FALSE = false;

#define NPCLOG(%0,%1) do{new str[128]; format(str, 128, %0, %1); SmartCmd("smartlog", str);}while(FALSE)
#define SMARTSPAWN(%0,%1) do{new str[128]; format(str, 128, %0, %1); SmartCmd("smartspawn", str);}while(FALSE)
#define SMARTANIM(%0,%1) do{new str[128]; format(str, 128, %0, %1); SmartCmd("smartanim", str);}while(FALSE)
#define SMARTPFUNC(%0,%1) do{new str[128]; format(str, 128, %0, %1); SmartCmd("callpfunction", str);}while(FALSE)

forward SmartInit();
forward MakeSmart(SmartName[], skin, Float: posX, Float: posY, Float: posZ, Float: posAng);
forward SetMaxMood(max);

forward AddTriggerGroup(moodMod);
forward AddTriggerWord(tGroup, word[]);
forward AddSentence(tGroup, moodLevel, sent[]);
forward AddSentencePFunction(sentenceId, pFunc[]);
forward AddAutoMessage(moodLevel, msg[]);

/*
*
*/
new gMaxMood;

/*
*    <npc>
*/

enum myInf
{
	mySkin,
	myName[MAX_PLAYER_NAME],
	myMood,
	Float: myPosX,
	Float: myPosY,
	Float: myPosZ,
	Float: myPosAng,
};
new gMySelf[myInf];

/*
*    <triggergroup> 's
*/

new gTriggerGroups[MAX_TRIGGERGROUPS];
Itter_Create(TriggerGroup, MAX_TRIGGERGROUPS);

/*
*    <word> 's
*/

enum tWordInf
{
	tGroupId,
	word1[32]
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
	cFunction[32],
	bool: pFunction,
	bool: sAnim
};
new gSentences[MAX_SENTENCES][sentenceInf];
Itter_Create(Sentence, MAX_SENTENCES);
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
		gMySelf[myMood] += gTriggerGroups[anwsGroup];
		
		if(gMySelf[myMood] >= gMaxMood) gMySelf[myMood] = gMaxMood;
		else if(gMySelf[myMood] < 0) gMySelf[myMood] = 0;
		
		// Send The Anwser..
		sendAnwser(findMessage(fromPlayer, anwsGroup));
		return 1;
	}
	sendAnwser(DEFAULT_MESSAGE);
	return 1;
}

/*
*    scanForTriggerWords
*/
stock scanForTriggerWords(sentenceToScan[])
{
	foreach(TriggerWord, i)
	{
		if(strfind(sentenceToScan, gTriggerWords[i][word1], true, 0) != -1) return gTriggerWords[i][tGroupId];
	}
	return -1;
}

/*
*    SendAnwser
*/
stock sendAnwser(message[])
{
	SendChat(message);
}

stock SmartCmd(command[], message[])
{
	new string[128];
	format(string, 128, "/%s %s", command, message);
	SendCommand(string);
}

/*
*    FindMessage
*/
findMessage(fromPlayer, anwserGroup)
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
			SMARTANIM("%s %s", gSentences[randMemb][sAnimLib], gSentences[randMemb][sAnimName]);
		}
		
		if(gSentences[randMemb][pFunction])
		{
			SMARTPFUNC("%s %d", gSentences[randMemb][cFunction], fromPlayer);
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
		sendAnwser(gAutoMessages[randMemb][gAutoMessage]);
		
		foreach(tempAnwser, e)
		{
			Iter_Remove(tempAnwser, e);
		}	
	}
}

/*
*    Public 's
*/

public MakeSmart(SmartName[], skin, Float: posX, Float: posY, Float: posZ, Float: posAng)
{
	format(gMySelf[myName], 32, "%s", SmartName);
	gMySelf[mySkin] = skin;
	gMySelf[myPosX] = posX;
	gMySelf[myPosY] = posY;
	gMySelf[myPosZ] = posZ;
	gMySelf[myPosAng] = posAng;
	
	NPCLOG("%s loaded with skinid %d.", gMySelf[myName], gMySelf[mySkin]);
	SMARTSPAWN("%d %f %f %f %f", gMySelf[mySkin], gMySelf[myPosX], gMySelf[myPosY], gMySelf[myPosZ], gMySelf[myPosAng]);
}

public SetMaxMood(max)
{
	if(max > MAX_MOODS) max = MAX_MOODS-1;
	gMaxMood = max;
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

public AddSentencePFunction(sentenceId, pFunc[])
{
	if(sentenceId < 0 || sentenceId >= MAX_SENTENCES) return 0;
	
	format(gSentences[sentenceId][cFunction], 32, "%s", pFunc);	
	gSentences[sentenceId][pFunction] = true;
	return 1;
}

public AddAutoMessage(moodLevel, msg[])
{
	new freeId = Itter_Free(AutoMessage);
	if(freeId == -1) return -1;
	
	gAutoMessages[freeId][gAutoMood] = moodLevel;
	format(gAutoMessages[freeId][gAutoMessage], 32, "%s", msg);
	
	Itter_Add(AutoMessage, freeId);
	return freeId;	
}