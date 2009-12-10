#include <a_npc>
#include <foreach>
#include <sscanf_NPC>

#define MY_NAME "Jann"

#define DEFAULT_NOANWSER	"ok siis"

#include <smart_npc>

public OnNPCModeInit()
{
	StartRecordingPlayback(PLAYER_RECORDING_TYPE_ONFOOT, "Recycle");
	SetTimer("SmartInit", 3000, 0);
}	

public SmartInit()
{
	MakeSmart(MY_NAME, 242, 2441.3633, -1422.0017, 24.0, 270.0);
	SetMaxMood(3);	
	
	AddDefaultMessage(0, "Räägi ARUSAADAVALT!");
	AddDefaultMessage(0, "MIDA!??");
	AddDefaultMessage(1, "Oota, Misasja?");
	AddDefaultMessage(1, "Ma ei mõista su keelt?");
	AddDefaultMessage(2, "Ma ei saa sust aru.");
	AddDefaultMessage(2, "Räägi arusaadavalt.");
	AddDefaultMessage(3, "Palun räägi selgemalt.");
	AddDefaultMessage(3, "Palun räägi arusaadavalt.");
	
	new tGroup1 = AddTriggerGroup(1);
	AddTriggerWord(tGroup1, "tere");
	AddTriggerWord(tGroup1, "jõu");
	AddTriggerWord(tGroup1, "jou");
	AddTriggerWord(tGroup1, "jann");
	AddTriggerWord(tGroup1, "hey");
	AddTriggerWord(tGroup1, "hei");
	new tempSentenceId;
	
	AddSentence(tGroup1, 0, "Kasi minema!");
	AddSentence(tGroup1, 0, "Kao ära!");
	AddSentence(tGroup1, 0, "Ma lõpetan oma suitsu ära ja tulen õpetan sind väheke!");
	
	AddSentence(tGroup1, 1, "Ole vait!");
	AddSentence(tGroup1, 1, "Jäta mind rahule, niigi raske päev olnud.");
	
	AddSentence(tGroup1, 2, "Tere tere.");
	AddSentence(tGroup1, 2, "Tervist noorhärra!");
	AddSentence(tGroup1, 2, "Tere. Ilus päev täna, või mis?");
	
	AddSentence(tGroup1, 3, "Tere, tööd tahad?");
	AddSentence(tGroup1, 3, "Tere jah, ma olen Jann.");	
	
	new tGroup2 = AddTriggerGroup(-1);
	AddTriggerWord(tGroup2, "munn");
	AddTriggerWord(tGroup2, "pede");
	AddTriggerWord(tGroup2, "homo");
	AddTriggerWord(tGroup2, "gey");
	AddTriggerWord(tGroup2, "lits");
	AddTriggerWord(tGroup2, "hoor");
	AddTriggerWord(tGroup2, "munn");
	AddTriggerWord(tGroup2, "hoor");
	
	AddSentence(tGroup2, 0, "Ma tapan su ära!");
	AddSentence(tGroup2, 0, "Kui ma su kätte saan, raisk!");
	AddSentence(tGroup2, 0, "KÄI PERSE RAISK, NOLK SELLINE, KAO MINEMA!");
	
	AddSentence(tGroup2, 1, "Ole parem vait.");
	AddSentence(tGroup2, 1, "Käi õige kuradile!");
	AddSentence(tGroup2, 1, "Samad sõnad.");	
	
	AddSentence(tGroup2, 2, "Sama sullegi.");
	AddSentence(tGroup2, 2, "Edu.");
	AddSentence(tGroup2, 2, "Kuradi lohh, ole vait parem.");
	
	AddSentence(tGroup2, 3, "Lohh");
	
	new tGroup3 = AddTriggerGroup(0);
	AddTriggerWord(tGroup3, "tööd");
	AddTriggerWord(tGroup3, "tahan");
	AddTriggerWord(tGroup3, "teha");	
	AddTriggerWord(tGroup3, "küll");	
	AddTriggerWord(tGroup3, "ikka");	
	
	AddSentence(tGroup3, 0, "Ei saa sa mingit tööd...");
	AddSentence(tGroup3, 0, "Sina ja tööd, Ahh käi parem perse.");
	AddSentence(tGroup3, 1, "Kui sa vähe korralikumalt käituda mõistaksid siis ehk saaksid tööle.");
	AddSentence(tGroup3, 1, "Mul ei ole sulle küll tööd anda.");
	
	tempSentenceId = AddSentence(tGroup3, 0, "Ei annaks ka sulle.");
	SetNegative(tempSentenceId);
	tempSentenceId = AddSentence(tGroup3, 0, "Sulle ma ei annaks ka.");
	SetNegative(tempSentenceId);
	tempSentenceId = AddSentence(tGroup3, 1, "Mul ei oleks sulle anda ikka...");
	SetNegative(tempSentenceId);
	
	tempSentenceId = AddSentence(tGroup3, 2, "säh, uuri lepingut.");
	AddSentenceJobFunction(tempSentenceId, 1);
	tempSentenceId = AddSentence(tGroup3, 2, "näe uuri lepingut.");
	AddSentenceJobFunction(tempSentenceId, 1);
	tempSentenceId = AddSentence(tGroup3, 3, "Palun, uuri lepingut.");
	AddSentenceJobFunction(tempSentenceId, 1);	

	tempSentenceId = AddSentence(tGroup3, 2, "Kui ei taha, siis ei saa ka.");
	SetNegative(tempSentenceId);
	tempSentenceId = AddSentence(tGroup3, 3, "Kui ei taha, siis ei taha.");
	SetNegative(tempSentenceId);

	AddAutoMessage(0, "Mis sa siit otsid?");
	AddAutoMessage(1, "Mis vahid siin, kao minema!");
	AddAutoMessage(2, "Aega on? Mul oleks tööd pakkuda... Tahad?");
	AddAutoMessage(2, "Tööd tahad?");
	AddAutoMessage(3, "Hei sina, tööd tahad?");
	AddAutoMessage(3, "Hei, tööd soovid?");
}

public OnRecordingPlaybackEnd()
{
    StartRecordingPlayback(PLAYER_RECORDING_TYPE_ONFOOT, "Recycle");
}

public OnClientMessage(color, text[])
{
	if(color == SMART_COLOR)
	{
		if(!strcmp(text, "myPOS"))
		{
			SMARTSPAWN("%d %f %f %f %f", gMySelf[mySkin], gMySelf[myPosX], gMySelf[myPosY], gMySelf[myPosZ], gMySelf[myPosAng]);
			return 1;
		}
		
		new fromPlayer, text2[128];
		if(sscanf(text, "ds", fromPlayer, text2) == 0)
		{
			if(!strcmp(text2, "autoMessage"))
			{
				AutoMessage(fromPlayer);
				return 1;
			}
			else
			{			
				AnwserCheck(fromPlayer, text2);
				return 1;
			}
		}
	}
	return 0;
}