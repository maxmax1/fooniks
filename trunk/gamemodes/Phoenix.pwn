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
*    The Initial Developers of the Original Code are 13th and Jyrno42.
*/

/*
*    EXTERNAL CREDITS
*
*        External Credit #1 - Simon, IsValidSkin
*        External Credit #2 - Alex "Y_Less" Cole, MD5 Core
*        External Credit #3 - Alex "Y_Less" Cole, Y_SERVER
*        External Credit #4 - Alex "Y_Less" Cole, sscanf
*        External Credit #5 - DCMD
*        External Credit #6 - Alex "Y_Less" Cole, SendFormattedText/SendFormattedTextToAll
*
*/

/*
*    INCLUDES
*/

 // author: -, External Credit #4
#define dcmd(%1,%2,%3) if (!strcmp((%3)[1], #%1, true, (%2)) && ((((%3)[(%2) + 1] == '\0') && (dcmd_%1(playerid, ""))) || (((%3)[(%2) + 1] == ' ') && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1

#include <a_samp>
#include <a_mysql>
#include <md5_core>  // author: Alex "Y_Less" Cole, External Credit #2
#include <Y_server>  // author: Alex "Y_Less" Cole, External Credit #3
#include <phoenix_Core>
#include <phoenix_Lang>
#include <phoenix_RealCarnames>

// author: Alex "Y_Less" Cole, External Credit #6
#define SendFormattedText(%1,%2,%3,%4) do{new sendfstring[128];format(sendfstring,128,(%3),%4);SendClientMessage((%1), (%2) ,sendfstring);}while(FALSE)
#define SendFormattedTextToAll(%1,%2,%3) do{new sendfstring[128];format(sendfstring,128,(%2),%3);SendClientMessageToAll((%1),sendfstring);}while(FALSE)

/*
*    DEFINES
*/

#define SCRIPT_NAME			"Phoenix"
#define SCRIPT_VERSION  	"0.1"
#define SCRIPT_REVISION 	"92"

#define MYSQL_HOST			"localhost"
#define MYSQL_USER			"estrpco_portal"
#define MYSQL_DB			"estrpco_portal"
#define MYSQL_PREFIX		"ph_"

    /*
         *  THREADS IDs
         */
	#define VEHICLE_LOAD_THREAD     1
	#define VEHICLE_SAVE_THREAD     2
	#define FETCH_UINFO_THREAD      3

#define VEHICLE_DELAY 60000
#define SQL_FINISH_TIME 1000
#define CHAT_RADIUS 25
#define CHAT_RADIUS_SHOUT 40

#define STRING_LENGHT 256
#define MAX_QUERY 255

#define VEHICLE_GROUP			0	// Gängid, Grupeeringud
#define VEHICLE_JOB				1	// Tööd
#define VEHICLE_BUYABLE			2	// Ostetav masin
#define VEHICLE_SPECIAL			3	// Rongid, transpordivahendid jms. PS: Neid ei saa mängijad kasutada. Botid juhivad!
#define VEHICLE_ADMIN			4	// Administraatorite masinad

#define COLOR_YELLOW		0xFFFF00AA
#define COLOR_RED 0xAA3333AA
#define COLOR_GREEN 0x33AA33AA

#define PLAYER_COLOR 0xFFFF0000

#define COLOR_CHAT_IC 0xf2ffacAA
#define COLOR_CHAT_OOC_GLOBAL 0x8cf8ffAA
#define COLOR_CHAT_OOC_LOCAL 0xf2ffacAA
#define COLOR_CHAT_ME 0xda92e5AA
#define COLOR_CHAT_SHOUT 0xd7ff00AA
#define COLOR_CHAT_ES 0xfffc00AA
#define COLOR_ADMINMSG 0xff3c00AA
#define COLOR_ADMINCHAT 0xffa800AA

/* DialogIDs */
#define DIALOG_LOGIN 2009
#define DIALOG_PLAYER 2010
#define DIALOG_SENDES 2011
#define DIALOG_BANPLAYER 2012
#define DIALOG_KICKPLAYER 2013

#define NPC_IGOR 1

/*
*    SKILL DEFINES
*/
#define MAX_SKILLS		1
#define SKILL_PISTOL	0

/*
*    GLOBAL VARIABLES
*/

new WelcomeStr[64];

    /*
         *  THREADS Vars
         */
	new Fetch_UInfo_Thread = -1;

new EaglePickup, SawnoffPickup, MP5Pickup, AKPickup;

enum pInf
{
	uSqlId,
	uUserName[20],	
	uPassWordHash[64],
	uSalt[10],
	pLoggedIn,
	pCharName[30],
	pSqlId,
	pAdmin,
	pJob,
	pMember,
	pLeader,
	pModel,
	pAdminLevel,
	
	Float:pPosX,
	Float:pPosY,
	Float:pPosZ,
	Float:pAngle,
	Float:pHealth,
	pVW,
	pInterior,
	
	SelectedPlayer,
	npcId,
	pSkill[MAX_SKILLS+1],
};
new pInfo[MAX_PLAYERS][pInf];

new Text:  InfoBar[MAX_PLAYERS];
new 	   InfoBarTimer[MAX_PLAYERS];

new VEHICLE_SAVE_NEXT = 0;
new LOADED_VEHICLES = 0;
enum vInf
{
	vSqlID,
	vSampId,
	
	vModel,
	vType,
	
	Float: vPosXd,
	Float: vPosYd,
	Float: vPosZd,
	Float: vAngZd,
	Float: vPosX,
	Float: vPosY,
	Float: vPosZ,
	vSpeed,
	Float: vSpeedX,
	Float: vSpeedY,
	Float: vSpeedZ,
	Float: vAngZ,
	
	vColor1,
	vColor2,
	
	vOwner,
	vValue,
	
	vDeaths,
	Float: vHealth,
};
new Vehicles[700][vInf];

enum sInf
{
	sName[32],
	sLevel,
	Float: sRatio
};
new Skills[MAX_SKILLS][sInf] = 
{
	{"PISTOL", 1000, 1.5}
};

new SkillDelay[MAX_PLAYERS][MAX_SKILLS];

/*
*    FORWARDS
*/
forward AddCarToSQL(model, Float:posX, Float:posY, Float:posZ, Float:angle);
forward SendAdminChat(playerid, text[]);
forward ShowBanDialog(playerid);
forward ShowKickDialog(playerid);
forward WarpPlayerToPlayer(WarpWho, WarpTo);
forward BanPlayer(playerid, banner, reason[]);
forward KickPlayer(playerid, kicker, reason[]);
forward SendEs(playerid);
forward ForwardEs(playerid, message[]);
forward SendEmote(playerid, emote[]);
forward SCMTAInPlayerRadius(playerid, radius, color, message[]);
forward LoadAllVehiclesStart();
forward LoadAllVehiclesFinish();
forward SaveAllVehicles(closingdown);
forward SaveVehicle(vId, saveall);
forward SetVehicleSpawn(vId);
forward OnDriverEnterVehicle(playerid);
forward OnDriverExitVehicle(playerid);
forward ShowSpeedo(playerid);
forward OnSpeedoUpdate(playerid);
forward CheckCharacter(playerid);
forward CheckCharacterFinish(playerid);
forward GetUserInfo(playerid);
forward GetUserInfoFinish(playerid);
forward AuthenticateUser(playerid, givenPassword[]);
forward FetchCharacterInformation(playerid);
forward FetchCharacterInformationFinish(playerid);
forward UpdatePlayer(playerid);
forward UpdateAllPlayers();

forward MysqlUpdateBuild(query[], table[]);
forward MysqlUpdateInt(query[], field[], value);
forward MysqlUpdateFlo(query[], field[], Float: value);
forward MysqlUpdateStr(query[], field[], value[]);
forward MysqlUpdateFinish(query[], field[], value);
forward Velocity(playerid, Float: X, Float: Y, Float: Z);
forward NPCHandle(playerid);
forward LoadSkills(playerid);
forward SaveSkills(playerid);
forward XpAdd(playerid, skillId, amount);
forward SetSkills(playerid);
forward OnLevelUp(playerid, skillId, newLevel, showMsg);
forward GetLevel(skillId, xP, &xpNeeded);
forward ClearDelay(playerid, skillId)

/*
*    MAIN()
*/

main()
{
	print("FIREBIRDIE HAS MAIN()");
}

/*
*    STOCKS
*/

stock GetVehicleSqlId(vehicleid)
{
	for(new i; i < LOADED_VEHICLES; i++)
	{
		if(Vehicles[i][vSampId] == vehicleid) return i;
	}
	return -1;
}

stock findBotAVehicle(botType)
{
	for(new i; i < LOADED_VEHICLES; i++)
	{
		if(Vehicles[i][vType] == VEHICLE_SPECIAL && Vehicles[i][vOwner] == botType) return i;
	}
	return -1;
}

stock VehPos(vId)
{
	GetVehiclePos(Vehicles[vId][vSampId], Vehicles[vId][vPosX], Vehicles[vId][vPosY], Vehicles[vId][vPosZ]);
	GetVehicleZAngle(Vehicles[vId][vSampId], Vehicles[vId][vAngZ]);
}

stock VehPosd(vId)
{
	Vehicles[vId][vPosX] = Vehicles[vId][vPosXd];
	Vehicles[vId][vPosY] = Vehicles[vId][vPosZd];
	Vehicles[vId][vPosZ] = Vehicles[vId][vPosYd];
	Vehicles[vId][vAngZ] = Vehicles[vId][vAngZd];
}

stock IsValidSkin(skinid) // author: Simon, External Credit #1
{
    #define	MAX_BAD_SKINS 22
    new badSkins[MAX_BAD_SKINS] =
    { 3, 4, 5, 6, 8, 42, 65, 74, 86, 119, 149, 208, 268, 273, 289 };
    if (skinid < 0 || skinid > 299) return false;
    for (new i = 0; i < MAX_BAD_SKINS; i++) { if (skinid == badSkins[i]) return false; }
    #undef MAX_BAD_SKINS
    return 1;
}

stock IsGroupMember(playerid)
{
	new ret = pInfo[playerid][pMember];
	if(pInfo[playerid][pLeader] > 0) ret = pInfo[playerid][pLeader];
	return ret;
}

stock showLogin(playerid)
{
	new string[64];
	format(string, 64, LANG_DIALOG_LOGIN_INFO, pInfo[playerid][uUserName]);
	ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, LANG_DIALOG_LOGIN_CAPTION, string, LANG_DIALOG_LOGIN_LOGINBUTTON, LANG_DIALOG_EXITBUTTON);
}

PasswordHash(password[], salt[])
{
	new string[STRING_LENGHT];
	format(string, STRING_LENGHT, "%s%s", strtolower(MD5_Hash(password)), salt);
	format(string, STRING_LENGHT, "%s", strtolower(MD5_Hash(string)));
	return string;
}

public GetLevel(skillId, xP, &xpNeeded)
{
	if(xP < Skills[skillId][sLevel])
	{
		xpNeeded = Skills[skillId][sLevel];
		return 1;
	}
	for(new i = 0; i < 99; i++)
	{
		xpNeeded = (floatround(Skills[skillId][sLevel] * Skills[skillId][sRatio]) * i);
		if(xP < xpNeeded) return i;
	}	
	xpNeeded = 999;
	return 99;
}

/*
*    NATIVES
*/


public OnGameModeInit()
{
	// First things first, lets attempt to connect to database.
	new Connection = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_DB, MYSQL_PASSWORD);
	if(!Connection)
	{
		printf(LANG_FAILED_TO_CONNECT, SCRIPT_NAME);
		SendRconCommand("exit");
		return 1;
	}
	printf(LANG_CONNECTED, SCRIPT_NAME);
	mysql_debug(1);

	new string[24]; // 24 should be enough.
	format(string, 24, "%s %s r%s", SCRIPT_NAME, SCRIPT_VERSION, SCRIPT_REVISION);
	SetGameModeText(string);
	
	printf(LANG_LOADED, SCRIPT_NAME, SCRIPT_VERSION, SCRIPT_REVISION, SCRIPTER_NAME);
	format(WelcomeStr, 64, LANG_WELCOME_TO, SCRIPT_NAME, SCRIPT_VERSION, SCRIPT_REVISION, SCRIPTER_NAME);
	
	AddPlayerClass(0, 1492.5065, 1007.7800, 10.8203, 90, 0, 0, 0, 0, 0, 0);
	
	LoadAllVehiclesStart();
	
	for(new td; td < MAX_PLAYERS; td++)
	{
		InfoBar[td] = TextDrawCreate(200.0,418.0,":)"); //minX = 120 // 330
		TextDrawAlignment(InfoBar[td],1);
		TextDrawUseBox(InfoBar[td],1);
		TextDrawBoxColor(InfoBar[td],0x00000050);
		TextDrawTextSize(InfoBar[td],640.0,480.0);
		TextDrawFont(InfoBar[td],1);
		TextDrawSetOutline(InfoBar[td],0);
	}
	
	ShowNameTags( 1 );
	SetNameTagDrawDistance(7.5);
	LimitGlobalChatRadius(CHAT_RADIUS);
	
	SetTimer("UpdateAllPlayers", 1000*60*15, true);
	
	EaglePickup = CreatePickup(348 , 2, 2394.2112,-1206.5466,27.8595, 0); // eagle
	SawnoffPickup = CreatePickup(350 , 2, 2505.4795,-1117.3652,56.2031, 0); // sawnoff
	MP5Pickup = CreatePickup(353 , 2, 2526.4465,-1237.0942,43.6563, 0); // mp5
	AKPickup = CreatePickup(355 , 2, 2345.6289,-1364.8751,28.0859, 0); // AK
	
	ConnectNPC("Igor", "Igor_Takso");
	
	return 1;
}

public OnGameModeExit()
{
	SaveAllVehicles(true);
	UpdateAllPlayers();

	printf(LANG_UNLOADED, SCRIPT_NAME, SCRIPT_VERSION, SCRIPT_REVISION, SCRIPTER_NAME);
	return 1;
}

public OnPlayerConnect(playerid)
{
	if(IsPlayerNPC(playerid)) return NPCHandle(playerid);
	
    GetPlayerName(playerid, pInfo[playerid][pCharName], 30);
	SendClientMessage(playerid, COLOR_YELLOW, WelcomeStr);
	InfoBarTimer[playerid] = -1;
	CheckCharacter(playerid);

	pInfo[playerid][pLoggedIn] = 0;
	return 1;
}

public OnPlayerDisconnect(playerid)
{
	UpdatePlayer(playerid);
	SaveSkills(playerid);
}

public OnPlayerRequestClass(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
	SetPlayerVirtualWorld(playerid, playerid);
	SetPlayerPos(playerid, 1763.4633,-1110.3879,74.4867);
	SetPlayerFacingAngle(playerid, 90);
	
	SetPlayerCameraPos(playerid, 	2028.6260,-856.2253,157.4038);
	SetPlayerCameraLookAt(playerid, 1813.7842,-1015.3187,188.0742);
	if( !pInfo[playerid][pLoggedIn] )	showLogin(playerid);
	
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid))
	{
		if(pInfo[playerid][npcId] == NPC_IGOR)
		{
			new npcVeh = findBotAVehicle(NPC_IGOR);
			if(npcVeh != -1)
			{
				SetPlayerSkin(playerid, 255);
				PutPlayerInVehicle(playerid, Vehicles[npcVeh][vSampId], 0);
				return 1;
			}
			Kick(playerid);
		}
	}

    SetPlayerPos(playerid, pInfo[playerid][pPosX],pInfo[playerid][pPosY],pInfo[playerid][pPosZ]+1);
	SetPlayerVirtualWorld(playerid, pInfo[playerid][pVW]);
	SetPlayerInterior(playerid,pInfo[playerid][pInterior]);
	SetPlayerFacingAngle(playerid, pInfo[playerid][pAngle]);
	SetPlayerSkin(playerid, pInfo[playerid][pModel]);
	SetPlayerHealth(playerid, pInfo[playerid][pHealth]);
	SetPlayerColor(playerid, PLAYER_COLOR);
	
	SetCameraBehindPlayer(playerid);
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER) 										OnDriverEnterVehicle(playerid);
	else if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT) OnDriverExitVehicle(playerid);
}

public OnVehicleDeath(vehicleid)
{
	SetVehicleToRespawn(vehicleid);
	
	new vSqlId = GetVehicleSqlId(vehicleid);
	if(vSqlId != -1)
	{
		Vehicles[vSqlId][vDeaths]++;
		VehPosd(vSqlId);
		SetTimerEx("SetVehicleSpawn", 500, 0, "d", vSqlId);
	}
	return 1;
}

public OnRconCommand(cmd[])
{
	if( strcmp(cmd, "gmx", true) == 0 ) OnGameModeExit();
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_LOGIN)
	{
		if(response == 0)
		{
			SendClientMessage(playerid, COLOR_RED, LANG_MUST_LOGIN);
			
			SendClientMessage(playerid, COLOR_GREEN, LANG_BB);
			Kick(playerid);
			return 1;
		}
		else
		{
			AuthenticateUser(playerid, inputtext);
			return 1;
		}
	}
	else if( dialogid == DIALOG_PLAYER )
	{
	    if( response == 0 )
	    {
	        return 1;
	    }
	    else if( listitem == 0 ) // Erasõnum
	    {
			SendEs(playerid);
	    }
	    else if( listitem == 1 ) // Tele Siia
	    {
	        WarpPlayerToPlayer(pInfo[playerid][SelectedPlayer], playerid);
	    }
	    else if( listitem == 2 ) // Tele Sinna
	    {
            WarpPlayerToPlayer(playerid, pInfo[playerid][SelectedPlayer]);
	    }
	    else if( listitem == 3 ) // Kick
	    {
	        ShowKickDialog(playerid);
	    }
	    else if( listitem == 4 ) // Ban
	    {
	        ShowBanDialog(playerid);
	    }
	}
	else if( dialogid == DIALOG_SENDES )
	{
	    if( strlen(inputtext) == 0 )
		{
		    SendClientMessage(playerid, COLOR_RED, LANG_EMPTY_ES);
		    SendEs(playerid);
		}
		else
		{
		    if( IsPlayerConnected(pInfo[playerid][SelectedPlayer]) && pInfo[pInfo[playerid][SelectedPlayer]][pLoggedIn] )
		    {
				ForwardEs(playerid, inputtext);
		    }
			else
			SendClientMessage(playerid, COLOR_RED, LANG_NOT_ONLINE);
		}
	}
	else if( dialogid == DIALOG_KICKPLAYER )
	{
	    if( response == 0 )
	    {
	        return 1;
	    }
	    else
	    {
	        KickPlayer(pInfo[playerid][SelectedPlayer], playerid, inputtext);
	    }
	}
	else if( dialogid == DIALOG_BANPLAYER )
	{
	    if( response == 0 )
	    {
	        return 1;
	    }
	    else
	    {
	        BanPlayer(pInfo[playerid][SelectedPlayer], playerid, inputtext);
	    }
	}
	return 1;
}
public OnPlayerRequestSpawn(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
    if( !pInfo[playerid][pLoggedIn] )
    {
        SendClientMessage(playerid, COLOR_RED, LANG_MUST_LOGIN);
		
		showLogin(playerid);
		return 0;    
    }
    return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	if( pickupid == EaglePickup )
		GivePlayerWeapon(playerid, 22, 100);
	if( pickupid == SawnoffPickup )
		GivePlayerWeapon(playerid, 26, 100);
	if( pickupid == MP5Pickup )
		GivePlayerWeapon(playerid, 29, 100);
	if( pickupid == AKPickup )
		GivePlayerWeapon(playerid, 30, 100);

	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	pInfo[playerid][pPosX] = 2420.3459;
	pInfo[playerid][pPosY] = -1229.8799;
	pInfo[playerid][pPosZ] = 24.7299;
	pInfo[playerid][pAngle] = 180;
	pInfo[playerid][pHealth] = 100;
	pInfo[playerid][pVW] = 0;
	pInfo[playerid][pInterior] = 0;
	
	return 1;
}

public OnPlayerText(playerid, text[])
{
	new delay = ( strlen(text) * 150 ) + 2000;
	new str[STRING_LENGHT];
	format(str, sizeof(str),"%s:  %s", pInfo[playerid][pCharName], text);	
	if(IsPlayerNPC(playerid))
	{
		format(str, sizeof(str),"Igor_Yakov:  %s", text);
	}

	SetPlayerChatBubble(playerid, str, COLOR_CHAT_IC, CHAT_RADIUS, delay);
	SCMTAInPlayerRadius(playerid, CHAT_RADIUS, COLOR_CHAT_IC, str);
	return 0;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
    pInfo[playerid][SelectedPlayer] = clickedplayerid;
    new str[STRING_LENGHT];
    str = "Erasõnum";

	if( pInfo[playerid][pAdminLevel] > 0 )
        format( str, sizeof(str), "%s\nTele Siia\nTele Sinna\nKicki\nBanni", str);

	ShowPlayerDialog( playerid, DIALOG_PLAYER, DIALOG_STYLE_LIST, "Mängija Valikud", str, "Ok", LANG_DIALOG_EXITBUTTON);
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	SendFormattedText(playerid, COLOR_GREEN, "NEW: %d, OLD, %d" , newkeys, oldkeys);
	if(SkillDelay[playerid][SKILL_PISTOL] == 0 && newkeys == KEY_FIRE && !IsPlayerInAnyVehicle(playerid) && GetPlayerWeapon(playerid) == 22)
	{
		XpAdd(playerid, SKILL_PISTOL, 25);
		SkillDelay[playerid][SKILL_PISTOL] = 1;
		SetTimerEx("ClearDelay", 300, 0, "ii", playerid, SKILL_PISTOL);
	}
}
/*
*    COMMANDS
*/
public OnPlayerCommandText(playerid, cmdtext[])
{
	dcmd(o, 1, cmdtext);
	dcmd(b, 1, cmdtext);
	dcmd(me, 2, cmdtext);
	dcmd(s, 1, cmdtext);
	dcmd(es, 2, cmdtext);
	dcmd(mjuurde, 7, cmdtext);
	dcmd(msiia, 5, cmdtext);
	dcmd(kick, 4, cmdtext);
	dcmd(ban, 3, cmdtext);
	dcmd(a, 1, cmdtext);
	dcmd(oskus, 5, cmdtext);
	
	// ajutine
	dcmd(kaklus, 6, cmdtext);
	dcmd(mj, 2, cmdtext);
	dcmd(addveh, 6, cmdtext);

	return 1;
}

dcmd_o(playerid, params[])
{
	new text[STRING_LENGHT], str[STRING_LENGHT];
	sscanf(params, "s", text);
	
	if(strlen(text) == 0) return SendClientMessage(playerid, COLOR_RED, "KASUTUS: /o tekst");
	format(str, sizeof(str), "(( %s: %s ))", pInfo[playerid][pCharName], text);
	
	for( new i = 0; i <= MAX_PLAYERS; i++ )
	{
	    if( IsPlayerConnected(i) && pInfo[i][pLoggedIn] && !IsPlayerNPC(i) )
	    {
				SendClientMessage(i, COLOR_CHAT_OOC_GLOBAL, str);
	    }
	}
	
	return 1;
}
dcmd_b(playerid, params[])
{
	new text[STRING_LENGHT], str[STRING_LENGHT];
	sscanf(params, "s", text);

	if(strlen(text) == 0) return SendClientMessage(playerid, COLOR_RED, "KASUTUS: /b tekst");

	format(str, sizeof(str), "%s OOC:(( %s ))", pInfo[playerid][pCharName], text);
	SCMTAInPlayerRadius(playerid, CHAT_RADIUS, COLOR_CHAT_OOC_LOCAL, str);
	return 1;
}
dcmd_me(playerid, params[])
{
	new text[STRING_LENGHT];
	sscanf(params, "s", text);

	if(strlen(text) == 0) return SendClientMessage(playerid, COLOR_RED, "KASUTUS: /me tekst");

	SendEmote(playerid, text);
	return 1;
}
dcmd_s(playerid, params[])
{
	new text[STRING_LENGHT], str[STRING_LENGHT];
	sscanf(params, "s", text);

	if(strlen(text) == 0) return SendClientMessage(playerid, COLOR_RED, "KASUTUS: /s tekst");

	new delay = ( strlen(text) * 150 ) + 2000;
	format(str, sizeof(str), "%s %s: %s", pInfo[playerid][pCharName], LANG_ACTION_SHOUT, text);
	SetPlayerChatBubble(playerid, str, COLOR_CHAT_SHOUT, CHAT_RADIUS_SHOUT, delay);
	SCMTAInPlayerRadius(playerid, CHAT_RADIUS_SHOUT, COLOR_CHAT_SHOUT, str);
	return 1;
}
dcmd_es(playerid, params[])
{
	new selplayer, text[STRING_LENGHT];
	sscanf(params, "us", selplayer, text);
	pInfo[playerid][SelectedPlayer] = selplayer;
	if( strlen(text) > 0 ) ForwardEs(playerid, text);
	else SendEs(playerid);
}

dcmd_mjuurde(playerid, params[])
{
	if( pInfo[playerid][pAdminLevel] == 0 ) return SendClientMessage(playerid,COLOR_YELLOW, LANG_NOT_ADMIN);
	new selectedplayer;
	if ( sscanf(params, "u", selectedplayer) ) return SendClientMessage(playerid, COLOR_YELLOW, "KASUTUS: /mjuurde [ID/NIMI]");
    WarpPlayerToPlayer(playerid, selectedplayer);
    return 1;
}
dcmd_msiia(playerid, params[])
{
    if( pInfo[playerid][pAdminLevel] == 0 ) return SendClientMessage(playerid,COLOR_YELLOW, LANG_NOT_ADMIN);
    new selectedplayer;
    if ( sscanf(params, "u", selectedplayer) ) return SendClientMessage(playerid, COLOR_YELLOW, "KASUTUS: /msiia [ID/NIMI]");
    WarpPlayerToPlayer(selectedplayer, playerid);
    return 1;
}
dcmd_kick(playerid, params[])
{
    if( pInfo[playerid][pAdminLevel] == 0 ) return SendClientMessage(playerid,COLOR_YELLOW, LANG_NOT_ADMIN);
	new selectedplayer, reason[STRING_LENGHT];
    sscanf(params, "us", selectedplayer, reason);
    if( strlen(reason) == 0 ){ pInfo[playerid][SelectedPlayer] = selectedplayer; ShowKickDialog(playerid); return 1;}
    else KickPlayer(selectedplayer, playerid, reason);
    return 1;
}
dcmd_ban(playerid, params[])
{
    if( pInfo[playerid][pAdminLevel] == 0 ) return SendClientMessage(playerid,COLOR_YELLOW, LANG_NOT_ADMIN);
    new selectedplayer, reason[STRING_LENGHT];
    sscanf(params, "us", selectedplayer, reason);
	if( strlen(reason) == 0 ){ pInfo[playerid][SelectedPlayer] = selectedplayer; ShowBanDialog(playerid); return 1;}
    else BanPlayer(selectedplayer, playerid, reason);
    return 1;
}
dcmd_a(playerid, params[])
{
	if( pInfo[playerid][pAdminLevel] == 0 ) return SendClientMessage(playerid,COLOR_YELLOW, LANG_NOT_ADMIN);
	new str[STRING_LENGHT];
	if( sscanf(params,"s",str) ) return SendClientMessage(playerid, COLOR_YELLOW, "KASUTUS: /a [SÕNUM]");
	SendAdminChat(playerid, str);
	return 1;
}

dcmd_oskus(playerid, params[])
{
	#pragma unused params
	
	SendClientMessage(playerid, COLOR_YELLOW, "Sinu oskused:");
	new string[128];
	
	for(new i = 0; i < MAX_SKILLS; i++)
	{
		new xpNeeded;
		new level = GetLevel(i, pInfo[playerid][pSkill][i], xpNeeded);
		format(string, 128, "Oskus: %s, Level: %d, XP: %d / %d", Skills[i][sName], level, pInfo[playerid][pSkill][i], xpNeeded);
		SendClientMessage(playerid, COLOR_YELLOW, string);
	}
	return 1;
}

// AJUTISED
dcmd_kaklus(playerid, params[])
{
	new style;
	if(sscanf(params, "i", style))
	{
		SendClientMessage(playerid, COLOR_YELLOW, "KASUTUS: /kaklus [stiiliNR]");
		SendClientMessage(playerid, COLOR_YELLOW, "stiiliNR: 0(tava), 1(poks), 2(kungfu), 3(põlv, pea), 4(haare, löök), 5(küünarnukid)");
		return 1;
	}
	if(style < 0 || style > 5) return SendClientMessage(playerid, COLOR_RED, "Vale stiiliNR.");
	
	new sampStyleID = 4;
	if(style == 1) 		sampStyleID = 5;
	else if(style == 2) sampStyleID = 6;
	else if(style == 3) sampStyleID = 7;
	else if(style == 4) sampStyleID = 15;
	else if(style == 5) sampStyleID = 26;
	
	SendClientMessage(playerid, COLOR_RED, "Muutsid oma kaklusstiili.");
	SetPlayerFightingStyle(playerid, sampStyleID);
	return 1;	
}

dcmd_mj(playerid, params[])
{
	#pragma unused params
	new Float: vx, Float: vy, Float: vz;
	GetPlayerVelocity(playerid, vx, vy, vz);
	vz += 10.0;
	SetPlayerVelocity(playerid, vx, vy, vz);
	SendEmote(playerid, "hüppab jube kõrgele.");
	return 1;
}
dcmd_addveh(playerid, params[])
{
    #pragma unused params
	if( pInfo[playerid][pAdminLevel] > 1 )
	{
	    if( IsPlayerInAnyVehicle(playerid) )
	    {
	        new vid = GetPlayerVehicleID(playerid);
	        new model = GetVehicleModel(vid);
	        new Float:posX, Float:posY, Float:posZ, Float:angle;
	        GetVehicleZAngle(vid, angle);
	        GetVehiclePos(vid, posX, posY, posZ);
	        AddCarToSQL(model, posX, posY, posZ, angle);

			SendClientMessage(playerid, COLOR_YELLOW, "LISATUD!");
	    }
	    else return 1;
	}
	return 1;
}

/*
*    PUBLICS
*/

public SendEs(playerid)
{
	new str[STRING_LENGHT];
	format(str, sizeof(str), LANG_SEND_ES_TO, pInfo[pInfo[playerid][SelectedPlayer]][pCharName]);
	ShowPlayerDialog(playerid, DIALOG_SENDES, DIALOG_STYLE_INPUT, LANG_ES, str, LANG_DIALOG_SEND, LANG_DIALOG_EXITBUTTON);
}
public ForwardEs(playerid, message[])
{
	new str[STRING_LENGHT];
	
	format(str, sizeof(str),"-> %s: %s", pInfo[pInfo[playerid][SelectedPlayer]][pCharName], message);
	SendClientMessage(playerid, COLOR_CHAT_ES, str);
	format(str, sizeof(str),"<- %s: %s", pInfo[playerid][pCharName], message);
	SendClientMessage(pInfo[playerid][SelectedPlayer], COLOR_CHAT_ES, str);
}

public SendEmote(playerid, emote[])
{
	new Float:PlayerLocX, Float:PlayerLocY, Float:PlayerLocZ, str[STRING_LENGHT];
	GetPlayerPos(playerid, PlayerLocX, PlayerLocY, PlayerLocZ);
	format(str, sizeof(str),"*%s %s*", pInfo[playerid][pCharName], emote);
	for( new i = 0; i <= MAX_PLAYERS; i++ )
	{
	    if( IsPlayerConnected(i) && pInfo[i][pLoggedIn] )
	    {
	        if( IsPlayerInRangeOfPoint(i, CHAT_RADIUS, PlayerLocX, PlayerLocY, PlayerLocZ) )
	        {
				SendClientMessage(i, COLOR_CHAT_ME, str);
	        }
	    }
	}
}
public SCMTAInPlayerRadius(playerid, radius, color, message[])
{
	new Float:PlayerLocX, Float:PlayerLocY, Float:PlayerLocZ;
	GetPlayerPos(playerid, PlayerLocX, PlayerLocY, PlayerLocZ);
	for( new i = 0; i <= MAX_PLAYERS; i++ )
	{
	    if( IsPlayerConnected(i) && pInfo[i][pLoggedIn] )
	    {
	        if( IsPlayerInRangeOfPoint(i, radius, PlayerLocX, PlayerLocY, PlayerLocZ) )
	        {
				SendClientMessage(i, color, message);
	        }
	    }
		else if(IsPlayerNPC(i) && i != playerid)
		{
			if(pInfo[i][npcId] == NPC_IGOR)
			{
				if(color == COLOR_CHAT_IC)
				{
					if(IsPlayerInVehicle(playerid, GetPlayerVehicleID(i)))
					{
						SendClientMessage(i, color, message);
					}
				}
			}
		}
	}
}

public OnQueryFinish(query[], resultid)
{
	if( resultid == VEHICLE_LOAD_THREAD )
	{
		LoadAllVehiclesFinish();
	}
	else if( resultid == VEHICLE_SAVE_THREAD )
	{
		if(VEHICLE_SAVE_NEXT < LOADED_VEHICLES)
		{
			SaveVehicle(VEHICLE_SAVE_NEXT, true);
			VEHICLE_SAVE_NEXT++;
		}
		else VEHICLE_SAVE_NEXT = 0;
	}
	else if( resultid == FETCH_UINFO_THREAD )
	{
		FetchCharacterInformationFinish(Fetch_UInfo_Thread);
	}
}

public LoadAllVehiclesStart()
{
	print("\t\t Started Loading Vehicles.");
	new query[32];
	format(query, 32, "SELECT * FROM %svehicles", MYSQL_PREFIX);
	mysql_query(query, VEHICLE_LOAD_THREAD);
}

public LoadAllVehiclesFinish()
{
	mysql_store_result();
	
	new Field[64], Data[128], vId;
	for(vId = 0; vId < mysql_num_rows(); vId++)
	{
		mysql_fetch_row(Data);
		
		mysql_fetch_field_row(Field, "vehicleId");
		Vehicles[vId][vSqlID] = strval(Field);
		
		mysql_fetch_field_row(Field, "vModel");
		Vehicles[vId][vModel] = strval(Field);
		
		mysql_fetch_field_row(Field, "vType");
		Vehicles[vId][vType] = strval(Field);
		
		mysql_fetch_field_row(Field, "vPosXd");
		Vehicles[vId][vPosXd] = floatstr(Field);
		
		mysql_fetch_field_row(Field, "vPosYd");
		Vehicles[vId][vPosYd] = floatstr(Field);
		
		mysql_fetch_field_row(Field, "vPosZd");
		Vehicles[vId][vPosZd] = floatstr(Field);
		
		mysql_fetch_field_row(Field, "vAngZd");
		Vehicles[vId][vAngZd] = floatstr(Field);
		
		mysql_fetch_field_row(Field, "vPosX");
		Vehicles[vId][vPosX] = floatstr(Field);
		
		mysql_fetch_field_row(Field, "vPosY");
		Vehicles[vId][vPosY] = floatstr(Field);
		
		mysql_fetch_field_row(Field, "vPosZ");
		Vehicles[vId][vPosZ] = floatstr(Field);
		
		mysql_fetch_field_row(Field, "vAngZ");
		Vehicles[vId][vAngZ] = floatstr(Field);
		
		mysql_fetch_field_row(Field, "vColor1");
		Vehicles[vId][vColor1] = strval(Field);
		
		mysql_fetch_field_row(Field, "vColor2");
		Vehicles[vId][vColor2] = strval(Field);
		
		mysql_fetch_field_row(Field, "vOwner");
		Vehicles[vId][vOwner] = strval(Field);
		
		mysql_fetch_field_row(Field, "vValue");
		Vehicles[vId][vValue] = strval(Field);
		
		mysql_fetch_field_row(Field, "vDeaths");
		Vehicles[vId][vDeaths] = strval(Field);
		
		mysql_fetch_field_row(Field, "vHealth");
		Vehicles[vId][vHealth] = floatstr(Field);
		if(Vehicles[vId][vHealth] < 400.0) Vehicles[vId][vHealth] = 450.0;
		
		Vehicles[vId][vSampId] = AddStaticVehicleEx(Vehicles[vId][vModel], 
													Vehicles[vId][vPosXd],
													Vehicles[vId][vPosYd],
													Vehicles[vId][vPosZd],
													Vehicles[vId][vAngZd],
													Vehicles[vId][vColor1],
													Vehicles[vId][vColor2],
													VEHICLE_DELAY);
		SetTimerEx("SetVehicleSpawn", 500, 0, "d", vId);
	}
	LOADED_VEHICLES = vId+1;
	printf("\t\t %d Vehicles Loaded.", LOADED_VEHICLES);
	mysql_free_result();
}

public SaveAllVehicles(closingdown)
{
	print("Started Saving all vehicles.");
	if(closingdown)
	{
		print("Saving all before server shutdown.");
		for(new i; i < LOADED_VEHICLES; i++)
		{
			SaveVehicle(i, false); // Kui server on kinni minemas peame kindlad olema, et ennem asjad salvestatud on.
		}
		print("All vehicles saved.");
	}
	else
	{
		SaveVehicle(VEHICLE_SAVE_NEXT, true);
		VEHICLE_SAVE_NEXT++;
	}
}

public SaveVehicle(vId, saveall)
{
	VehPos(vId);
	new query[512];
	
	format(query, 512, "UPDATE %svehicles SET vPosX = '%.5f', vPosY = '%.5f', vPosZ = '%.5f', vAngZ = '%.5f', vColor1 = '%d', vColor2 = '%d', vOwner = '%d', vValue = '%d', vDeaths = '%d', vHealth = '%f' WHERE vehicleId = '%d'",
		MYSQL_PREFIX,
		Vehicles[vId][vPosX],
		Vehicles[vId][vPosY],
		Vehicles[vId][vPosZ],
		Vehicles[vId][vAngZ],
		Vehicles[vId][vColor1],
		Vehicles[vId][vColor2],
		Vehicles[vId][vOwner],
		Vehicles[vId][vValue],
		Vehicles[vId][vDeaths],
		Vehicles[vId][vHealth],
		Vehicles[vId][vSqlID]);
	if(!saveall) mysql_query(query);
	else mysql_query(query, VEHICLE_SAVE_THREAD);
}

public SetVehicleSpawn(vId)
{
	SetVehicleHealth(Vehicles[vId][vSampId], Vehicles[vId][vHealth]);
	SetVehiclePos(Vehicles[vId][vSampId], Vehicles[vId][vPosX], Vehicles[vId][vPosY], Vehicles[vId][vPosZ]);
	SetVehicleZAngle(Vehicles[vId][vSampId], Vehicles[vId][vAngZ]);
}

public OnDriverEnterVehicle(playerid)
{
	new vId = GetVehicleSqlId(GetPlayerVehicleID(playerid));
	new Remove = false, Freeze = false;
	new string[128];
	
	if(vId == -1) Remove = false;
	else
	{
		if		(Vehicles[vId][vType] == VEHICLE_GROUP)
		{
			if(Vehicles[vId][vOwner] == 0) Remove = false;
			else if(IsGroupMember(playerid) != Vehicles[vId][vOwner]) Remove = true;
		}
		else if	(Vehicles[vId][vType] == VEHICLE_JOB)
		{
			if(Vehicles[vId][vOwner] == 0) Remove = false;
			else if(pInfo[playerid][pJob] != Vehicles[vId][vOwner]) Remove = true;
		}
		else if	(Vehicles[vId][vType] == VEHICLE_BUYABLE)
		{
			if(Vehicles[vId][vOwner] > 0) Remove = true;
			else
			{	
				format(string, 128, "~y~ %s ~n~~g~ Hind: %d SAK", CarNames[Vehicles[vId][vModel] - 400], Vehicles[vId][vValue]);
				GameTextForPlayer(playerid, string, 3000, 4);
				
				format(string, 128, "Kirjuta: /omasin, et seda masinat osta.");
				SendClientMessage(playerid, COLOR_GREEN, string);	
				Freeze = false;
			}
		}
		else if	(Vehicles[vId][vType] == VEHICLE_SPECIAL)
		{
			if(!IsPlayerNPC(playerid)) Remove = true;
		}
		else
		{
			if(pInfo[playerid][pAdmin] < 1) Remove = true;
			else if(pInfo[playerid][pAdmin] < Vehicles[vId][vOwner]) Remove = true;
		}
	}
	
	if(Remove)
	{
		RemovePlayerFromVehicle(playerid);
		SendClientMessage(playerid, COLOR_RED, LANG_VEH_NOKEYS);
	}
	else
	{
		if(Freeze) TogglePlayerControllable(playerid, 0);
	
		ShowSpeedo(playerid);
		format(string, 128, "%s", CarNames[Vehicles[vId][vModel] - 400]);
		GameTextForPlayer(playerid, string, 6000, 1);
	}
	return 1;
}

public OnDriverExitVehicle(playerid)
{
	OnSpeedoUpdate(playerid);
	new vId = GetVehicleSqlId(GetPlayerVehicleID(playerid));
	if(vId == -1) vId = 200+playerid;
	Vehicles[vId][vSpeed] = 0;
	InfoBarTimer[playerid] = -1;
}

public ShowSpeedo(playerid)
{
	if(InfoBarTimer[playerid] != -1) return 0;
	
	InfoBarTimer[playerid] = SetTimerEx("OnSpeedoUpdate", 200, 1, "i", playerid);
	TextDrawShowForPlayer(playerid, InfoBar[playerid]);	
	return 1;
}

public OnSpeedoUpdate(playerid)
{
	if(IsPlayerConnected(playerid) && IsPlayerInAnyVehicle(playerid))
	{
		new vId = GetVehicleSqlId(GetPlayerVehicleID(playerid));
		if(vId == -1)
		{
			vId = 200+playerid;
			Vehicles[vId][vSampId] = GetPlayerVehicleID(playerid);
			VehPos(vId);
		}

		new oSpeed = Vehicles[vId][vSpeed], Float: oHealth = Vehicles[vId][vHealth];
		new Float: oX = Vehicles[vId][vSpeedX], Float: oY = Vehicles[vId][vSpeedY], Float: oZ = Vehicles[vId][vSpeedZ];
	
		GetVehicleHealth(Vehicles[vId][vSampId], Vehicles[vId][vHealth]);
		new hProtsenti = floatround((Vehicles[vId][vHealth] - 300) / 10);
		new string[128], fuel[3] = "-";
		
		GetVehicleVelocity(Vehicles[vId][vSampId], Vehicles[vId][vSpeedX], Vehicles[vId][vSpeedY], Vehicles[vId][vSpeedZ]);
		new Float: distance = floatabs(Vehicles[vId][vSpeedX]) + floatabs(Vehicles[vId][vSpeedY]) + floatabs(Vehicles[vId][vSpeedZ]);
		Vehicles[vId][vSpeed] = floatround(distance * 175);
		format(string,sizeof(string),"~y~~h~Bensiin: %s  ~y~~h~Kiirus: ~w~%i km/h  ~y~~h~Korras: ~w~%d", fuel, Vehicles[vId][vSpeed], hProtsenti);
		TextDrawSetString(InfoBar[playerid], string);
		
		if((oSpeed - Vehicles[vId][vSpeed]) > 50 && (oHealth - Vehicles[vId][vHealth]) > 50)
		{
			SendEmote(playerid, LANG_VEH_CRASH);
			SetPlayerPos(playerid, Vehicles[vId][vPosX], Vehicles[vId][vPosY], Vehicles[vId][vPosZ]+2);
			SetTimerEx("Velocity", 75, 0, "ifff", playerid, oX, oY, oZ);
			ApplyAnimation(playerid, "CRACK", "crckdeth2", 4.0, 1, 1, 1, 1, 1);
			Vehicles[vId][vSpeed] = 0;
		}
	}
	else
	{
		TextDrawHideForPlayer(playerid, InfoBar[playerid]);
		KillTimer(InfoBarTimer[playerid]);
	}
}

public CheckCharacter(playerid)
{
	new eName[32], query[86];
	mysql_real_escape_string(pInfo[playerid][pCharName], eName);
	format(query, 86, "SELECT id, userid FROM %scharacters WHERE name = '%s' LIMIT 0, 1", MYSQL_PREFIX, eName);	
	mysql_query(query);
		
	if(mysql_store_result())
	{
		if(mysql_num_rows() > 0)
		{
			new Field[64], Data[128];
			mysql_fetch_row(Data);
			
			mysql_fetch_field_row(Field, "id");
			pInfo[playerid][pSqlId] = strval(Field);
			
			mysql_fetch_field_row(Field, "userid");
			pInfo[playerid][uSqlId] = strval(Field);
			mysql_free_result();
			
			GetUserInfo(playerid);
			return 1;
		}	
	}
	
	SendClientMessage(playerid, COLOR_RED, LANG_NOCHARACTER);
	Kick(playerid);
	return 1;
}

public GetUserInfo(playerid)
{
	new query[86];
	format(query, 86, "SELECT username, password, salt FROM user WHERE userid = '%d' LIMIT 1", pInfo[playerid][uSqlId]);
	mysql_query(query);

	if(mysql_store_result() == 1)
	{		
		if(mysql_num_rows() > 0)
		{
			new Field[64], Data[128];
			mysql_fetch_row(Data);
			
			mysql_fetch_field_row(Field, "username");
			strmid(pInfo[playerid][uUserName], Field, 0, strlen(Field), STRING_LENGHT);
			
			mysql_fetch_field_row(Field, "password");
			strmid(pInfo[playerid][uPassWordHash], Field, 0, strlen(Field), STRING_LENGHT);
			
			mysql_fetch_field_row(Field, "salt");
			strmid(pInfo[playerid][uSalt], Field, 0, strlen(Field), STRING_LENGHT);
			mysql_free_result();
		}	
		return 1;
	}
	SendClientMessage(playerid, COLOR_RED, LANG_NOUSER);
	Kick(playerid);
	return 1;
}

public AuthenticateUser(playerid, givenPassword[])
{
	new string[STRING_LENGHT];
	format(string, STRING_LENGHT, "%s", PasswordHash(givenPassword, pInfo[playerid][uSalt]));
	new strC = strcmp(pInfo[playerid][uPassWordHash], string, true);
	

	if(strC != 0) // wrong Password
	{
		SendClientMessage(playerid, COLOR_RED, LANG_WRONG_PASSWORD);
		showLogin(playerid);
	}
	else
	{
	    FetchCharacterInformation(playerid);
	}
	return 1;
}

public FetchCharacterInformation(playerid)
{
	if(Fetch_UInfo_Thread != -1) // thread is busy, lets attemp again in 1 second.
	{
		SetTimerEx("FetchCharacterInformation", 1000, 0, "i", playerid);
		return 1;
	}
	Fetch_UInfo_Thread = playerid;

	new query[86];
	format(query, 86, "SELECT * FROM %scharacters WHERE id = '%d' LIMIT 0, 1", MYSQL_PREFIX, pInfo[playerid][pSqlId]);
	mysql_query(query, FETCH_UINFO_THREAD);
	SetTimerEx("FetchCharacterInformationFinish", SQL_FINISH_TIME, 0, "i", playerid);
	return 1;

}

public FetchCharacterInformationFinish(playerid)
{
	if(Fetch_UInfo_Thread != playerid) return 1;
	
	if(mysql_store_result() == 1)
	{
		if(mysql_num_rows() < 1)
		{
			SendClientMessage(playerid, COLOR_RED, LANG_NOCHARACTER);
			Kick(playerid);
		}
		else
		{
			new Field[64], Data[1024];
			mysql_fetch_row(Data);
			
			mysql_fetch_field_row(Field, "model");
			pInfo[playerid][pModel] = strval(Field);
			mysql_fetch_field_row(Field, "money");
			GivePlayerMoney(playerid, strval(Field));
			mysql_fetch_field_row(Field, "posX");
			pInfo[playerid][pPosX] = floatstr(Field);
			mysql_fetch_field_row(Field, "posY");
			pInfo[playerid][pPosY] = floatstr(Field);
			mysql_fetch_field_row(Field, "posZ");
			pInfo[playerid][pPosZ] = floatstr(Field);
			mysql_fetch_field_row(Field, "angle");
			pInfo[playerid][pAngle] = floatstr(Field);
			mysql_fetch_field_row(Field, "VirtualWorld");
			pInfo[playerid][pVW] = strval(Field);
			mysql_fetch_field_row(Field, "interior");
			pInfo[playerid][pInterior] = strval(Field);
			mysql_fetch_field_row(Field, "health");
			pInfo[playerid][pHealth] = floatstr(Field);
			mysql_fetch_field_row(Field, "adminLevel");
			pInfo[playerid][pAdminLevel] = strval(Field);
			
			mysql_free_result();
			LoadSkills(playerid);
		}
	}
	Fetch_UInfo_Thread = -1;
	return 1;
}

public UpdatePlayer(playerid)
{
	if(!pInfo[playerid][pLoggedIn]) return 1;
	
	GetPlayerPos(playerid, pInfo[playerid][pPosX], pInfo[playerid][pPosY], pInfo[playerid][pPosZ]);
	GetPlayerFacingAngle(playerid, pInfo[playerid][pAngle]);
	GetPlayerHealth(playerid, pInfo[playerid][pHealth]);
	
	new sqlid = pInfo[playerid][pSqlId];
	
	new query[MAX_QUERY], table[32];
	format(table, 32, "%scharacters", MYSQL_PREFIX);
	
	MysqlUpdateBuild(query, table);
	
	MysqlUpdateInt(query, "money", GetPlayerMoney(playerid));
	MysqlUpdateInt(query, "model", pInfo[playerid][pModel]);
	MysqlUpdateFlo(query, "posX", pInfo[playerid][pPosX]);
	MysqlUpdateFlo(query, "posY", pInfo[playerid][pPosY]);
	MysqlUpdateFlo(query, "posZ", pInfo[playerid][pPosZ]);
	MysqlUpdateFlo(query, "angle", pInfo[playerid][pAngle]);

	MysqlUpdateInt(query, "VirtualWorld", pInfo[playerid][pVW]);
	MysqlUpdateInt(query, "interior", pInfo[playerid][pInterior]);
	MysqlUpdateFlo(query, "health", pInfo[playerid][pHealth]);
	MysqlUpdateInt(query, "adminLevel", pInfo[playerid][pAdminLevel]);
	
	MysqlUpdateFinish(query, "id", sqlid);

	return 1;
}

public UpdateAllPlayers()
{
	for( new i = 0; i <= MAX_PLAYERS; i++ )
	{
	    if( IsPlayerConnected(i) && pInfo[i][pLoggedIn] )
	    UpdatePlayer(i);
		SaveSkills(i);
	}
}

public MysqlUpdateBuild(query[], table[])
{
	format(query, MAX_QUERY, "UPDATE %s SET ", table);
	return 1;
}

public MysqlUpdateInt(query[], field[], value)
{
	new qLen = strlen(query);
	if(qLen+50 < MAX_QUERY) // It 's safe to add.
	{
		format(query, MAX_QUERY, "%s %s = '%d', ", query, field, value);
	}
	return 1;
}

public MysqlUpdateFlo(query[], field[], Float: value)
{
	new qLen = strlen(query);
	if(qLen+50 < MAX_QUERY) // It 's safe to add.
	{
		format(query, MAX_QUERY, "%s %s = '%f', ", query, field, value);
	}
	return 1;
}

public MysqlUpdateStr(query[], field[], value[])
{
	new qLen = strlen(query);
	if(qLen+50 < MAX_QUERY) // It 's safe to add.
	{
		format(query, MAX_QUERY, "%s %s = '%s', ", query, field, value);
	}
	return 1;
}

public MysqlUpdateFinish(query[], field[], value)
{
	new qLen = strlen(query);
	strdel(query, qLen-2, qLen); // remove the extra comma 
	
	format(query, MAX_QUERY, "%s WHERE %s = '%d'", query, field, value);
	print(query);
	mysql_query(query);
}

public WarpPlayerToPlayer(WarpWho, WarpTo)
{
	new Float:WarpToX, Float:WarpToY, Float:WarpToZ;
	GetPlayerPos(WarpTo, WarpToX, WarpToY, WarpToZ);
	SetPlayerPos(WarpWho, WarpToX, WarpToY, WarpToZ);
}

public BanPlayer(playerid, banner, reason[])
{
	new str[STRING_LENGHT];
	format(str, sizeof(str), LANG_GLOBAL_BANMSG, pInfo[banner][pCharName], pInfo[playerid][pCharName], reason);
    SendClientMessageToAll(COLOR_ADMINMSG, str);
	// Siia võiks mingi hea ban süsteemi teha :D
}

public KickPlayer(playerid, kicker, reason[])
{
	new str[STRING_LENGHT];
	format(str, sizeof(str), LANG_GLOBAL_KICKMSG, pInfo[kicker][pCharName], pInfo[playerid][pCharName], reason);
	SendClientMessageToAll(COLOR_ADMINMSG, str);
	Kick(playerid);
}

public ShowBanDialog(playerid)
{
	new str[STRING_LENGHT];
	format( str, sizeof(str), "Banni %s", pInfo[pInfo[playerid][SelectedPlayer]][pCharName]);
	ShowPlayerDialog(playerid, DIALOG_BANPLAYER, DIALOG_STYLE_INPUT, str, LANG_DIALOG_REASON, LANG_DIALOG_BAN, LANG_DIALOG_END);
}

public ShowKickDialog(playerid)
{
	new str[STRING_LENGHT];
	format( str, sizeof(str), "Kicki %s", pInfo[pInfo[playerid][SelectedPlayer]][pCharName]);
	ShowPlayerDialog(playerid, DIALOG_KICKPLAYER, DIALOG_STYLE_INPUT, str, LANG_DIALOG_REASON, LANG_DIALOG_KICK, LANG_DIALOG_END);
}

public SendAdminChat(playerid, text[])
{
	new str[STRING_LENGHT];
	format( str, sizeof(str), "(%i)%s: %s", pInfo[playerid][pAdminLevel], pInfo[playerid][pCharName], text);
	for( new i = 0; i <= MAX_PLAYERS; i++ )
	{
	    if( IsPlayerConnected(i) && pInfo[i][pLoggedIn] && pInfo[i][pAdminLevel] > 0 )
	    	SendClientMessage(i, COLOR_ADMINCHAT, str);
	}
}

public Velocity(playerid, Float: X, Float: Y, Float: Z)
{
	SetPlayerVelocity(playerid, X, Y, Z);
	ApplyAnimation(playerid, "CRACK", "crckdeth2", 4.0, 1, 1, 1, 1, 1);
}

public NPCHandle(playerid)
{
	new pName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, pName, MAX_PLAYER_NAME);
	if(!strcmp(pName, "Igor", true))
	{
		pInfo[playerid][npcId] = NPC_IGOR;
		strmid(pInfo[playerid][pCharName], "Igor_Yakov", 0, 30);
		return 1;
	}
	//Kick(playerid);
	return 0;
}

public AddCarToSQL(model, Float:posX, Float:posY, Float:posZ, Float:angle)
{
	new query[1028];
	format(query, sizeof(query), "INSERT INTO `estrpco_portal`.`ph_vehicles` (`vehicleId` ,`vModel` ,`vType` ,`vPosXd` ,`vPosYd` ,`vPosZd` ,`vAngZd` ,`vPosX` ,`vPosY` ,`vPosZ` ,`vAngZ` ,`vColor1` ,`vColor2` ,`vOwner` ,`vValue` ,`vDeaths` ,`vHealth`)VALUES (NULL , '%i', '0', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '-1', '-1', '0', '0', '0', '1000');", model, posX, posY, posZ, angle, posX, posY, posZ, angle);
	mysql_query(query, FETCH_UINFO_THREAD);
}

public LoadSkills(playerid)
{	
	new query[128];
	format(query, 128, "SELECT * FROM %sskills WHERE cid = '%d'", MYSQL_PREFIX, pInfo[playerid][pSqlId]);
	mysql_query(query);
	
	if(mysql_store_result() == 1)
	{
		if(mysql_num_rows() > 0)
		{
			new Field[64], str[12];			
			for(new i = 0; i < MAX_SKILLS; i++)
			{
				format(str, 12, "skill_%d", i);
				mysql_fetch_field_row(Field, str);
				pInfo[playerid][pSkill][i]	= strval(Field);
			}			
			mysql_free_result();	

			SetSkills(playerid);
		
			SendClientMessage(playerid, COLOR_GREEN, LANG_LOGGED_IN);
			pInfo[playerid][pLoggedIn] = 1;
			SpawnPlayer(playerid);		
			return 1;			
		}
		else
		{
			mysql_free_result();
			format(query, 128, "INSERT INTO %sskills(id, cid) VALUES(NULL, '%d');", MYSQL_PREFIX, pInfo[playerid][pSqlId]);
			mysql_query(query);
			SetTimerEx("LoadSkills", 500, 0, "i", playerid);
			return 1;
		}
	}
	
	SendClientMessage(playerid, COLOR_RED, LANG_STATSERROR);
	Kick(playerid);
	return 1;
}

public SaveSkills(playerid)
{	
	new sqlid = pInfo[playerid][pSqlId];
	new query[MAX_QUERY], table[32];
	format(table, 32, "%sskills", MYSQL_PREFIX);
	
	MysqlUpdateBuild(query, table);
	
	new str[12];			
	for(new i = 0; i < MAX_SKILLS; i++)
	{
		format(str, 12, "skill_%d", i);
		MysqlUpdateInt(query, str, pInfo[playerid][pSkill][i]);
	}
	
	MysqlUpdateFinish(query, "cid", sqlid);	
	return 1;
}

public XpAdd(playerid, skillId, amount)
{
	new xpNeeded;
	new oldLevel = GetLevel(skillId, pInfo[playerid][pSkill][skillId], xpNeeded);
	pInfo[playerid][pSkill][skillId] += amount;
	
	if(pInfo[playerid][pSkill][skillId] >= xpNeeded)
	{	
		OnLevelUp(playerid, skillId, (oldLevel+1), 1);
	}
	
	//UpdateSkillDraw(playerid, skillId, amount);
	return 1;
}

public SetSkills(playerid)
{
	for(new i = 0; i < MAX_SKILLS; i++)
	{
		new xpNeeded;
		new level = GetLevel(i, pInfo[playerid][pSkill][i], xpNeeded);
		OnLevelUp(playerid, i, level, 0);
	}
}

public OnLevelUp(playerid, skillId, newLevel, showMsg)
{
	if(showMsg == 1)
	{
		//	LevelAP
		new string[128];
		format(string, 128, "Sinu %s oskus on nüüd %d. Oled kogunud %d kogemuspunkti.", Skills[skillId][sName], newLevel, pInfo[playerid][pSkill][skillId]);
		SendClientMessage(playerid, COLOR_GREEN, string);
	}
	
	if(skillId == SKILL_PISTOL) SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, floatround(newLevel*10));
	return 1;
}

public ClearDelay(playerid, skillId)
{
	SkillDelay[playerid][skillId] = 0;
	return 1;
}

/*
*    EOF
*/
