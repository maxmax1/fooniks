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

#if !defined DEFAULT_NOANWSER

	#define DEFAULT_NOANWSER	"I have nothing to say to you!"
	
#endif

#if !defined NO

	#define NO "no"
	
#endif

#if !defined MY_NAME

	#error "MY_NAME must be set!"
	
#endif

#define MAX_MOODS 			6
#define MAX_AUTOMESSAGES 	6
#define MAX_TRIGGERGROUPS 	5
#define MAX_SENTENCES 		40
#define MAX_TRIGGERWORDS 	64
#define MAX_TEMPA			10

#define SMART_COLOR 0x00000005

new FALSE = false;

#define NPCLOG(%0,%1) do{new str[128]; format(str, 128, %0, %1); SmartCmd("smartlog", str);}while(FALSE)
#define SMARTSPAWN(%0,%1) do{new str[128]; format(str, 128, %0, %1); SmartCmd("smartspawn", str);}while(FALSE)
#define SMARTANIM(%0,%1) do{new str[128]; format(str, 128, %0, %1); SmartCmd("smartanim", str);}while(FALSE)

forward SmartInit();
forward MakeSmart(SmartName[], skin, Float: posX, Float: posY, Float: posZ, Float: posAng);
forward SetMaxMood(max);

forward AddTriggerGroup(moodMod);
forward AddTriggerWord(tGroup, word[]);
forward AddSentence(tGroup, moodLevel, sent[]);
forward AddDefaultMessage(moodLevel, sent[]);
forward AddSentenceJobFunction(sentenceId, pFunc);
forward AddAutoMessage(moodLevel, msg[]);
forward SetNegative(sentenceId);

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
	cFunction,
	bool: pFunction,
	bool: sAnim,
	bool: sTNegative
};
new gSentences[MAX_SENTENCES][sentenceInf];
Itter_Create(Sentence, MAX_SENTENCES);

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
	new anwsGroup = -1, bool: neg;
	if(strfind(gotMessage, "ei", true) != -1) neg = true;
	else neg = false;
	
	foreach(TriggerWord, i)
	{
		if(strfind(gotMessage, gTriggerWords[i][word1], true, 0) != -1)
		{			
			anwsGroup = gTriggerWords[i][tGroupId];
			break;
		}
	}
	
	if(anwsGroup > -1)
	{
		// if mood after mod is bigger than max or smaller than 0 fix the error, else set it to a new value.
		gMySelf[myMood] += gTriggerGroups[anwsGroup];
		
		if(gMySelf[myMood] >= gMaxMood) gMySelf[myMood] = gMaxMood;
		else if(gMySelf[myMood] < 0) gMySelf[myMood] = 0;
	}
	sendAnwser(findMessage(fromPlayer, anwsGroup, neg));
	return 1;
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
	new string[256];
	format(string, 256, "/%s %s", command, message);
	SendCommand(string);
}

/*
*    FindMessage
*/
findMessage(fromPlayer, anwserGroup, bool: negative)
{
	new string[128], hits = 0, temp[MAX_TEMPA];
	foreach(Sentence, i)
	{
		if(hits >= MAX_TEMPA) break;
		
		if(gSentences[i][sTGroupId] == anwserGroup)
		{
			if(gSentences[i][mood] == gMySelf[myMood] && (anwserGroup < 2 || negative == gSentences[i][sTNegative]))
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
		format(string, 128, "%s", gSentences[send][sentence]);
		
		if(gSentences[send][sAnim])
		{
			SMARTANIM("%s %s", gSentences[send][sAnimLib], gSentences[send][sAnimName]);
		}
		
		if(gSentences[send][pFunction])
		{
			new str[128];
			format(str, 128, "OnPlayerRequestJob %d %d", gSentences[send][cFunction], fromPlayer);
			SmartCmd("callpfunction", str);
		}
		return string;
	}
	format(string, 128, "%s", DEFAULT_NOANWSER);
	return string;
}

/*
*    AutoMessage
*/
stock AutoMessage(toPlayer)
{
	#pragma unused toPlayer
	new hits, temp[MAX_TEMPA];
	foreach(AutoMessage, i)
	{
		if(hits >= MAX_TEMPA) break;
		if(gAutoMessages[i][gAutoMood] == gMySelf[myMood])
		{
			temp[hits] = i;
			hits++;
		}
	}

	new randMemb = (hits>0)?random(hits):-1;
	if(randMemb != -1)
	{
		new send = temp[randMemb];
		sendAnwser(gAutoMessages[send][gAutoMessage]);
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

public AddSentenceJobFunction(sentenceId, pFunc)
{
	if(sentenceId < 0 || sentenceId >= MAX_SENTENCES) return 0;
	
	gSentences[sentenceId][cFunction] = pFunc;	
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

public SetNegative(sentenceId)
{
	if(sentenceId < 0 || sentenceId >= MAX_SENTENCES) return 0;
	gSentences[sentenceId][sTNegative] = true;
	return 1;
}