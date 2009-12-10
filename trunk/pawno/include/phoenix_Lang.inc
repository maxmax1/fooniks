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
*    This File: phoenix_Lang.inc
*    Purpose: Add Multilanguage support into Phoenix.
*/

/*
*    DEFINES
*/

#define Lang_STR(%0,%1) %1_%0

/*
*    GLOBALS
*/

/*
*    FORWARDS
*/

/*
*    PUBLICS
*/

stock GetLangSTR(langstr[])
{	
	new string[128];
	format(string, 128, "%s", langstr);
	return string;
}

/*
*    DEFINES
*/

#define LANG_WELCOME_TO				"Tere Tulemast %s-%sr%s-%s, Palun oota..."
#define LANG_FAILED_TO_CONNECT			"\t\t* %s - Failed to connect to mysql DB."
#define LANG_CONNECTED				"\t\t* %s - Connected to mysql DB."
#define LANG_LOADED				"\t\t* %s-%sr%s-%s Loaded."
#define LANG_UNLOADED				"\t\t* %s-%sr%s-%s UnLoaded."
#define LANG_NOCHARACTER			"Sellise nimega karakterit ei ole!"
#define LANG_NOUSER				"Sellise nimega kasutajat ei ole!"

#define LANG_DIALOG_LOGIN_CAPTION		"Palun logige sisse!"
#define LANG_DIALOG_LOGIN_INFO			"Tere, %s.\n Sisesta parool:"
#define LANG_DIALOG_LOGIN_LOGINBUTTON		"Logi Sisse!"
#define LANG_DIALOG_EXITBUTTON		"Välju"
#define LANG_DIALOG_OK		    "Ok"
#define LANG_DIALOG_SEND		    "Saada"
#define LANG_DIALOG_END		    "Lõpeta"
#define LANG_DIALOG_REASON		    "Sisesta põhjus:"
#define LANG_DIALOG_BAN		    "Banni"
#define LANG_DIALOG_BAN_S		    "Banni %s"
#define LANG_DIALOG_KICK		    "Kicki"
#define LANG_DIALOG_KICK_S		    "Kicki %s"
#define LANG_DIALOG_ADMINCPHEAD "Administratsioon"
#define LANG_DIALOG_POCKETSHEAD "Taskud"
#define LANG_DIALOG_TELEHEAD "Telepordid"
#define LANG_DIALOG_ADMINCP "Avalik Sõnum\nMäära Kellaaeg\nMäära Ilm\nTelepordid"

#define LANG_BAD_INPUT "Vigane sisestus."

#define LANG_LOGGED_IN                "Edukalt sisse logitud."
#define LANG_WRONG_PASSWORD               "Vale parool!"
#define LANG_MUST_LOGIN               "Mängimiseks pead sisse logima!"
#define LANG_BB               "Nägemist!"
#define LANG_EMPTY_ES         "Tühja erasõnumit ei saa saata!"
#define LANG_NOT_ONLINE         "Mängijat ei ole (enam) online!"
#define LANG_SEND_ES_TO        "Saada erasõnum mängijale: %s"
#define LANG_ES               "Erasõnum"
#define LANG_VEH_NOKEYS               "Sul pole selle auto võtmeid."
#define LANG_VEH_CRASH               "lendab masinast välja"
#define LANG_CRASH_SEATBELT            "lendab peaga pehmesse turvapatja"
#define LANG_GLOBAL_BANMSG               "Administraator %s bannis kasutaja %s. Põhjus: %s"
#define LANG_GLOBAL_KICKMSG               "Administraator %s kickis kasutaja %s. Põhjus: %s"
#define LANG_NOT_ADMIN               "Sa pole admin!"
#define LANG_ACTION_SHOUT               "karjub"
#define LANG_STATSERROR "Statistika Laadimisel oli Viga."
#define LANG_LEVELUP "Sinu %s oskus on nüüd %d. Oled kogunud %d kogemuspunkti."
#define LANG_ADMINMSG "Administraator %s: %s"
#define LANG_REPORT "(%i)%s teatab: %s"
#define LANG_TELEPORTED_TO "Teleported to %s."

#define LANG_WAIT "Palun oota..."

#define LANG_SOME_ERROR "Ups, see on nüüd küll piinlik. Juhtus mingi viga."
#define LANG_WARNING_TURNCATE "Hoiatus: Teie sisestatud teksti lõigati lühemaks."

/*
*    NewsPaper
*/
#define LANG_WRITE_HEADLINE "Kirjuta lehe pealkiri."
#define LANG_WRITE_ARTICLE "Kirjuta lehe lõik %d."
#define LANG_SHOW_HEADLINE "*** Pealkiri:"
#define LANG_SHOW_ARTICLE "*** Lõik:"
#define LANG_SKIP_ARTICLE "Jätsid selle lõigu vahele."
#define LANG_MUST_WRITE_HEADLINE "Pealkirja kirjutamine on kohustuslik."

/*
*    AFK
*/
#define LANG_AFK "Sa %s AFK."

/*
*    JOBS
*/
#define LANG_GOT_JOB_EX "Õnnitleme, Sind võeti tööle. Töökoht: %s, Töölepingu kehtivus: %d"
#define LANG_JOB_CONTRACT_TIME "Su tööleping kestab veel %d tundi, ära unusta seda uuendada oma tööandja juures..."
#define LANG_JOB_CONTRACT_END "Su tööleping on läbi, kui soovid töölepingut pikendada pead rääkima oma ülemusega enne järgmist \"palgapäeva\"."
#define LANG_JOBHELP "Vaata ka /tööabi."
#define LANG_X_JOB "Sul on juba töö."
#define LANG_REFUSE_JOB "Sa otsustasid tööd mitte võtta."

// EOF