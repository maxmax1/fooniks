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
*        External Credit #5 - Zeex, zcmd
*        External Credit #6 - Alex "Y_Less" Cole, SendFormattedText/SendFormattedTextToAll
*        External Credit #7 - UnKnown - GetXYInFrontOfPlayer
*        External Credit #8 - Westie, strlib
*        External Credit #9 - Alex "Y_Less" Cole, foreach
*/

/*
*    DEFINES 1
*/

#define SCRIPT_NAME			"Phoenix"
#define SCRIPT_VERSION  		"0.1.2"
#define SCRIPT_REVISION 		"174"

#define MYSQL_HOST			"localhost"
#define MYSQL_USER			"estrpco_portal"
#define MYSQL_DB				"estrpco_portal"
#define MYSQL_PREFIX			"ph_"

#define MAX_SKILLS		12

#define PH_DEBUG // Turn debug on!

/*
*    THREADS IDs
*/
#define VEHICLE_LOAD_THREAD     1
#define FETCH_UINFO_THREAD      2

/*
*    INCLUDES
*/
#include <a_samp>
#include <a_mysql>
#include <md5_core> 		 // author: Alex "Y_Less" Cole, External Credit #2
#include <Y_server> 		 // author: Alex "Y_Less" Cole, External Credit #3
#include <strlib>  			 // author: Westie, External Credit #8
#include <foreach>   		 // author: Alex "Y_Less" Cole, External Credit #9
#include <zcmd> 			 // author: Zeex, External Credit #5
#include <stuff> 	 		 // some Stuff Needed EveryWhere
#include <playerlist> 		 // colse Players List
#include <smart_npc_samp> 	 // SmartNPC
#include <streamer> 	 // SmartNPC

#include <phoenix_Core>
#include <phoenix_RealCarnames>
#include <phoenix_Money>
#include <phoenix_Status>

#include <phoenix_JobSystem>
#include <phoenix_StreetCleaner>

#include <phoenix_Users>
#include <phoenix_Skills>
#include <phoenix_Vehicles>

#include <phoenix_Anims>
#include <phoenix_ProgressBar>
#include <phoenix_Interiors>
#include <phoenix_Pockets>
#include <phoenix_HelpDraw>
#include <phoenix_NewsPaper>
#include <phoenix_AddSystem>
#include <phoenix_Resting>
//#include <AntiShiit>

public AddAllJobs()
{
	JOBS_RegisterJob(GARBAGE_JOB_ID, "GCollector", "Prügivedaja", false, 50, 5);
}

public RegisterAllSmartNPC()
{
	RegisterSmartNpc("Jann", "Jann");
}

/*
*    DEFINES 2
*/

#define TIME_OFFSET 0
#define CHAT_RADIUS 25
#define CHAT_RADIUS_SHOUT 40

#define STRING_LENGHT 256
#define MAX_TELEPORTS 10

/* DialogIDs */
#define DIALOG_LOGIN 2009
#define DIALOG_PLAYER 2010
#define DIALOG_SENDES 2011
#define DIALOG_BANPLAYER 2012
#define DIALOG_KICKPLAYER 2013
#define DIALOG_ADMINCP 2014
#define DIALOG_AACTION 2015
#define DIALOG_TELEPORTS 2016
//#define DIALOG_POCKETS 2017 // Reserved

#define NPC_IGOR 1

/*
*    GLOBAL VARIABLES
*/
new gHour, gMinute, gSecond, bool: gHourChange;

new foodBar;

new WelcomeStr[64];

new PistolPickup, SawnoffPickup, MP5Pickup, AKPickup;

enum posInfo
{
	tName[32],
	Float: tX,
	Float: tY,
	Float: tZ,
	Float: tvX,
	Float: tvY,
	Float: tvZ
};	
new telePositions[MAX_TELEPORTS][posInfo] = 
{
	{"LSPD", 1552.2706, -1675.6493, 16.1953, 1524.2191, -1632.0856, 13.1682},
	{"Kardirada", 1645.6719, -1149.8458, 24.0712, 1660.2335, -1155.1641, 23.4643},
	{"Linnavalitsus", 1481.6273, -1748.2708, 15.4453, 1484.5649, -1737.8258, 13.1684},
	{"Unity", 1756.1044, -1862.4084, 13.5763, 1765.5027, -1859.9630, 13.1998},
	{"Lennukas", 2010.0344, -2201.4253, 13.5469, 2008.3926, -2202.1609, 13.2537},
	{"Sadam", 2753.3142, -2452.6616, 13.6432, 2755.5708, -2452.7727, 13.2536},
	{"Staadion", 2680.4749, -1672.8507, 9.4194, 2682.1299, -1672.1379, 9.1324},
	{"PigPen", 2427.9739, -1242.3777, 24.2333, 2426.4302, -1243.2527, 23.8387},
	{"pay'N'spray", 2074.6631, -1825.7513, 13.5469, 2076.2275, -1824.9553, 13.1682},
	{"TenGreen", 2351.5228, -1673.0512, 13.5469, 2351.5228, -1673.0512, 13.1682}
};

/*
*    FORWARDS
*/

forward SyncPlayerTime(playerid);
forward SyncAllPlayerTime();
forward UpdateAllPlayerPos();
forward SendTeata(playerid, text[]);
forward SendAdminMessage(playerid, text[]);
forward CheckFalseDeadPlayers(playerid);
forward SendAdminChat(playerid, text[]);
forward ShowBanDialog(playerid);
forward ShowKickDialog(playerid);
forward WarpPlayerToPlayer(WarpWho, WarpTo);
forward BanPlayer(playerid, banner, reason[]);
forward KickPlayerP(playerid, kicker, reason[]);
forward SendEs(playerid);
forward ForwardEs(playerid, message[]);
forward SendEmote(playerid, emote[]);
forward SCMTAInPlayerRadius(playerid, radius, color, message[]);

forward Velocity(playerid, Float: X, Float: Y, Float: Z);
forward NPCHandle(playerid);
forward TogglePlayerControllableEx(playerid, toggle, timer);
forward OnNewHour();

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

stock findBotAVehicle(botType)
{
	for(new i; i < LOADED_VEHICLES; i++)
	{
		if(Vehicles[i][vType] == VEHICLE_SPECIAL && Vehicles[i][vOwner] == botType) return i;
	}
	return -1;
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

GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance) // author: UnKnown, External Credit #7
{
	new Float:a;
	GetPlayerPos(playerid, x, y, a);
	GetPlayerFacingAngle(playerid, a);
	if (GetPlayerVehicleID(playerid))
	{
	    GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	}
	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
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

stock showAdminDialog(playerid)
{
	if(pInfo[playerid][pAdminLevel] < 1) return 1;
	ShowPlayerDialog(playerid, DIALOG_ADMINCP, DIALOG_STYLE_LIST, LANG_DIALOG_ADMINCPHEAD, LANG_DIALOG_ADMINCP, LANG_DIALOG_OK, LANG_DIALOG_EXITBUTTON);	
	return 1;
}

stock showAdminActionDialog(playerid, action)
{
	if(pInfo[playerid][pAdminLevel] < 1) return 1;
	pInfo[playerid][aAction] = action+1;
	
	new string[32];
	if(action == 1) format(string, 32, "Määra Kellaaeg");
	else if(action == 2) format(string, 32, "Määra Ilm");
	else format(string, 32, "Avalik Sõnum:");
	
	ShowPlayerDialog(playerid, DIALOG_AACTION, DIALOG_STYLE_INPUT, LANG_DIALOG_ADMINCPHEAD, string, LANG_DIALOG_OK, LANG_DIALOG_EXITBUTTON);
	return 1;
}

stock showTeleDialog(playerid)
{
	if(pInfo[playerid][pAdminLevel] < 1) return 1;
	
	new string[128];	
	for(new i; i < MAX_TELEPORTS; i++)
	{
		format(string, 128, "%s\n%s", string, telePositions[i][tName]);
	}
	ShowPlayerDialog(playerid, DIALOG_TELEPORTS, DIALOG_STYLE_LIST, LANG_DIALOG_TELEHEAD, string, LANG_DIALOG_OK, LANG_DIALOG_EXITBUTTON);	
	return 1;
}

MegaJump(playerid)
{
	new Float: rad = 0.0125;
	new Float: higher = 0.125;
	new Float: JumpEnergy = 15.0;
	
	if(pRest[playerid] > 50.0 && pRest[playerid] < 75.0)
	{
		rad = 0.00625;
		higher = 0.0625;
	}
	else if(pRest[playerid] > 25.0 && pRest[playerid] < 50.0)
	{
		rad = 0.003125;
		higher = 0.03125;
	}
	else if(pRest[playerid] < 25.0)
	{
		return 1;
	}

	if(SkillDelay[playerid][SKILL_ATHLETE] == 0 && pInfo[playerid][pControllable] == 1)
	{
		new Float: px, Float: py, Float: pz, Float: nx, Float: ny, Float: mx, Float: my;
		GetPlayerPos(playerid, px, py, pz);
		GetXYInFrontOfPlayer(playerid, nx, ny, rad);
		
		mx = nx - px;
		my = ny - py;
			
		new Float: vx, Float: vy, Float: vz;
		GetPlayerVelocity(playerid, vx, vy, vz);
		SetPlayerVelocity(playerid, vx+mx, vy+my, vz+higher);	
		
		SkillDelay[playerid][SKILL_ATHLETE] = 1;
		SetTimerEx("ClearDelay", 10000, 0, "ii", playerid, SKILL_ATHLETE);
		XpAdd(playerid, SKILL_ATHLETE, 25);
		
		pRest[playerid] -= JumpEnergy;
		setProgressBar(restBar, playerid, pRest[playerid]);
	}
	return 1;
}

stock GetCharacterName(charSqlId)
{
	new query[128], retStr[32];
	format(query, 128, "SELECT name FROM %scharacters WHERE id = '%d' LIMIT 0, 1", MYSQL_PREFIX, charSqlId);
	mysql_query(query);
	if(mysql_store_result())
	{
		if(mysql_fetch_row_format(query, " ")) 
		{
			format(retStr, 32, "%s", query);
			return retStr;
		}
	}
	format(retStr, 32, "Pole");
	return retStr;
}

/*
*    NATIVES
*/


public OnGameModeInit()
{
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
	
	PistolPickup = CreatePickup(346 , 2, 2394.2112,-1206.5466,27.8595, 0); // Pistol
	SawnoffPickup = CreatePickup(350 , 2, 2505.4795,-1117.3652,56.2031, 0); // sawnoff
	MP5Pickup = CreatePickup(353 , 2, 2526.4465,-1237.0942,43.6563, 0); // mp5
	AKPickup = CreatePickup(355 , 2, 2345.6289,-1364.8751,28.0859, 0); // AK
	
	//ConnectNPC("Igor", "Igor_Takso");
	
	//// KARDIRAJA OBJEKTID
	CreateDynamicObject(978, 1801.377563, -1040.903320, 23.426163, 0.0000, 0.0000, 154.6978);
	CreateDynamicObject(978, 1781.199097, -1042.265991, 23.383846, 0.0000, 0.0000, 200.2479);
	CreateDynamicObject(978, 1792.510254, -1039.356445, 23.426163, 0.0000, 0.0000, 186.3938);
	CreateDynamicObject(978, 1769.416504, -1043.925049, 23.414612, 0.0000, 0.0000, 159.7513);
	CreateDynamicObject(978, 1783.479004, -1041.437866, 23.401163, 0.0000, 0.0000, 200.2479);
	CreateDynamicObject(978, 1737.989136, -1039.293091, 23.426163, 0.0000, 0.0000, 146.0003);
	CreateDynamicObject(978, 1741.407593, -1058.687622, 23.451162, 0.0000, 0.0000, 329.0603);
	CreateDynamicObject(978, 1749.786133, -1062.751587, 23.428240, 0.0000, 0.0000, 339.3735);
	CreateDynamicObject(978, 1733.522095, -1053.656616, 23.435760, 0.0000, 0.0000, 325.6225);
	CreateDynamicObject(978, 1725.913574, -1048.359009, 23.379263, 0.0000, 359.1406, 324.7631);
	CreateDynamicObject(978, 1718.344360, -1042.902344, 23.329264, 0.0000, 0.0000, 323.9037);
	CreateDynamicObject(978, 1696.818115, -1039.661865, 23.346476, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(978, 1753.548096, -1042.090332, 23.346476, 0.0000, 0.0000, 180.3777);
	CreateDynamicObject(978, 1754.148804, -1064.387573, 23.421474, 0.0000, 0.0000, 339.3735);
	CreateDynamicObject(978, 1679.393433, -1039.629150, 23.371454, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(978, 1667.020996, -1039.424561, 23.388662, 0.0000, 0.0000, 18.0473);
	CreateDynamicObject(978, 1663.532104, -1040.595337, 23.388662, 0.0000, 0.0000, 17.1879);
	CreateDynamicObject(978, 1643.608154, -1041.927490, 23.363663, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(978, 1623.853638, -1038.247925, 23.363663, 0.0000, 0.0000, 304.1366);
	CreateDynamicObject(978, 1619.487183, -1031.782471, 23.368946, 0.0000, 0.0000, 304.1366);
	CreateDynamicObject(978, 1611.642090, -1033.153198, 23.388662, 0.0000, 0.0000, 64.4569);
	CreateDynamicObject(978, 1607.655518, -1041.492188, 23.371454, 0.0000, 0.0000, 64.4569);
	CreateDynamicObject(978, 1603.672974, -1049.829590, 23.371475, 0.0000, 0.0000, 64.4569);
	CreateDynamicObject(978, 1601.389648, -1054.602783, 23.371475, 0.0000, 0.0000, 64.4569);
	CreateDynamicObject(978, 1604.144653, -1065.579956, 23.346476, 0.0000, 0.0000, 142.6656);
	CreateDynamicObject(978, 1611.590332, -1071.177368, 23.363663, 0.0000, 0.0000, 143.4220);
	CreateDynamicObject(978, 1618.918579, -1076.868896, 23.363663, 0.0000, 0.0000, 140.8436);
	CreateDynamicObject(978, 1625.153076, -1108.348511, 23.371475, 0.0000, 0.0000, 90.1369);
	CreateDynamicObject(978, 1625.136230, -1098.987793, 23.371475, 0.0000, 0.0000, 90.1369);
	CreateDynamicObject(978, 1625.091553, -1089.621948, 23.379259, 0.0000, 0.0000, 90.2400);
	CreateDynamicObject(978, 1621.439453, -1078.901611, 23.363663, 0.0000, 0.0000, 140.8436);
	CreateDynamicObject(978, 1625.069092, -1086.744873, 23.346476, 0.0000, 0.0000, 90.2400);
	CreateDynamicObject(978, 1653.917969, -1111.886841, 23.416231, 0.0000, 0.0000, 270.6186);
	CreateDynamicObject(978, 1653.878174, -1102.550293, 23.421474, 0.0000, 0.0000, 269.7591);
	CreateDynamicObject(978, 1653.863525, -1093.183228, 23.346476, 0.0000, 359.1406, 269.8394);
	CreateDynamicObject(978, 1653.894775, -1083.826050, 23.271477, 0.0000, 0.0000, 269.8623);
	CreateDynamicObject(978, 1649.192383, -1082.291992, 23.346476, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(978, 1639.923584, -1082.277222, 23.346476, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(978, 1630.578369, -1082.136719, 23.346476, 0.0000, 0.0000, 358.2811);
	CreateDynamicObject(978, 1648.632568, -1118.609863, 23.371475, 0.0000, 0.0000, 171.7834);
	CreateDynamicObject(978, 1639.362915, -1117.193726, 23.371475, 0.0000, 0.0000, 170.9239);
	CreateDynamicObject(978, 1630.443481, -1115.775513, 23.371475, 0.0000, 0.0000, 170.9239);
	CreateDynamicObject(978, 1777.193359, -1065.995605, 23.401163, 0.0000, 0.0000, 180.3777);
	CreateDynamicObject(978, 1755.306274, -1065.880981, 23.426163, 0.0000, 0.0000, 179.6214);
	CreateDynamicObject(978, 1749.381226, -1065.848022, 23.421963, 0.0000, 0.0000, 181.3403);
	CreateDynamicObject(978, 1740.191772, -1065.795166, 23.426163, 0.0000, 0.0000, 177.9026);
	CreateDynamicObject(978, 1735.519775, -1065.763062, 23.413609, 0.0000, 0.0000, 179.6214);
	CreateDynamicObject(978, 1722.148438, -1065.414307, 23.435490, 0.0000, 0.8586, 179.6214);
	CreateDynamicObject(978, 1712.811401, -1065.429810, 23.371475, 0.0000, 0.0000, 180.4809);
	CreateDynamicObject(978, 1703.469238, -1065.536743, 23.396475, 0.0000, 0.0000, 180.4809);
	CreateDynamicObject(978, 1694.112305, -1065.627197, 23.371475, 0.0000, 0.0000, 180.4809);
	CreateDynamicObject(978, 1685.592529, -1068.395996, 23.379633, 0.0000, 0.0000, 214.7552);
	CreateDynamicObject(978, 1678.181152, -1065.294922, 23.413662, 0.0000, 0.0000, 104.7473);
	CreateDynamicObject(978, 1675.270630, -1056.572021, 23.363663, 0.0000, 0.0000, 112.4822);
	CreateDynamicObject(978, 1670.394043, -1048.710815, 23.363663, 0.0000, 0.0000, 131.3898);
	CreateDynamicObject(978, 1662.842041, -1043.802612, 23.338663, 0.0000, 0.0000, 162.3296);
	CreateDynamicObject(978, 1682.891235, -1092.518066, 23.346476, 0.0000, 0.0000, 48.9870);
	CreateDynamicObject(978, 1639.453491, -1059.855713, 23.388662, 0.0000, 0.0000, 2.5775);
	CreateDynamicObject(978, 1648.526978, -1060.493286, 23.388662, 0.0000, 0.0000, 349.6868);
	CreateDynamicObject(978, 1657.196533, -1062.843750, 23.363663, 0.0000, 0.0000, 340.2330);
	CreateDynamicObject(978, 1638.258667, -1059.910034, 23.396454, 0.0000, 0.0000, 2.5775);
	CreateDynamicObject(978, 1678.198975, -1091.790527, 23.338663, 0.0000, 0.0000, 113.3417);
	CreateDynamicObject(978, 1674.315674, -1084.005005, 23.354258, 0.0000, 0.0000, 120.2172);
	CreateDynamicObject(978, 1669.595459, -1076.687500, 23.363663, 0.0000, 0.0000, 125.3738);
	CreateDynamicObject(978, 1663.745361, -1069.897827, 23.340876, 0.0000, 0.0000, 135.6870);
	CreateDynamicObject(978, 1669.632080, -1072.209839, 23.388662, 0.0000, 0.0000, 312.7310);
	CreateDynamicObject(978, 1676.031372, -1079.042603, 23.388662, 0.0000, 0.0000, 313.5904);
	CreateDynamicObject(978, 1682.526489, -1085.765991, 23.371475, 0.0000, 0.0000, 314.4499);
	CreateDynamicObject(978, 1666.294434, -1068.684937, 23.388662, 0.0000, 0.0000, 313.5904);
	CreateDynamicObject(978, 1679.968872, -1100.670288, 23.371475, 0.0000, 0.0000, 90.2400);
	CreateDynamicObject(978, 1690.430786, -1089.196899, 23.371475, 0.0000, 0.0000, 359.1406);
	CreateDynamicObject(978, 1699.810425, -1089.252319, 23.371475, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(978, 1709.176880, -1089.256836, 23.371475, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(978, 1718.554810, -1089.262695, 23.371475, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(978, 1727.893555, -1089.248657, 23.372623, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(978, 1737.260376, -1089.237427, 23.401163, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(978, 1746.577393, -1089.245483, 23.401163, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(978, 1755.939331, -1089.243164, 23.401163, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(978, 1765.303345, -1089.223022, 23.401163, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(978, 1774.683350, -1089.222778, 23.401163, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(978, 1783.985962, -1089.232178, 23.408846, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(978, 1793.349243, -1089.238159, 23.408846, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(978, 1802.711670, -1089.251465, 23.401163, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(978, 1804.842285, -1089.252319, 23.421032, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(978, 1809.599121, -1084.548950, 23.426163, 0.0000, 0.0000, 90.2400);
	CreateDynamicObject(978, 1809.569580, -1075.185669, 23.426064, 0.0000, 0.0000, 90.2400);
	CreateDynamicObject(978, 1809.381714, -1065.835205, 23.433846, 0.0000, 0.0000, 91.8558);
	CreateDynamicObject(978, 1808.500000, -1056.665894, 23.426163, 0.0000, 0.0000, 98.8344);
	CreateDynamicObject(978, 1806.708862, -1047.473999, 23.426163, 0.0000, 0.0000, 103.1316);
	CreateDynamicObject(978, 1736.442261, -1038.244141, 23.401163, 0.0000, 0.0000, 146.1034);
	CreateDynamicObject(978, 1768.317871, -1043.504150, 23.426163, 0.0000, 0.0000, 159.9575);
	CreateDynamicObject(978, 1656.177856, -1065.088257, 23.363663, 0.0000, 0.0000, 160.6107);
	CreateDynamicObject(978, 1647.186401, -1062.592529, 23.363663, 0.0000, 0.0000, 168.4487);
	CreateDynamicObject(978, 1637.956909, -1062.415405, 23.388662, 0.0000, 0.0000, 189.0752);
	CreateDynamicObject(978, 1643.492554, -1042.448730, 23.363663, 0.0000, 0.0000, 179.6214);
	CreateDynamicObject(978, 1718.383545, -1027.036255, 23.391417, 0.0000, 0.0000, 149.4380);
	CreateDynamicObject(978, 1710.284058, -1022.347412, 23.404263, 0.0000, 0.0000, 150.2974);
	CreateDynamicObject(978, 1702.177002, -1017.736206, 23.401142, 0.0000, 0.0000, 150.4006);
	CreateDynamicObject(978, 1694.047363, -1013.114258, 23.404263, 0.0000, 0.0000, 150.2974);
	CreateDynamicObject(978, 1685.954102, -1008.431519, 23.393353, 0.0000, 0.0000, 149.5411);
	CreateDynamicObject(978, 1726.390259, -1031.831055, 23.396475, 0.0000, 0.0000, 148.6817);
	CreateDynamicObject(978, 1731.380005, -1034.931030, 23.396475, 0.0000, 0.0000, 147.8223);
	CreateDynamicObject(978, 1677.507324, -1007.514709, 23.388662, 0.0000, 0.0000, 198.5290);
	CreateDynamicObject(978, 1668.522461, -1010.000122, 23.388662, 0.0000, 0.0000, 192.4098);
	CreateDynamicObject(978, 1659.392578, -1011.875977, 23.388662, 0.0000, 0.0000, 190.7941);
	CreateDynamicObject(978, 1653.169678, -1013.034363, 23.363663, 0.0000, 0.0000, 190.6910);
	CreateDynamicObject(978, 1644.196899, -1012.499756, 23.363663, 0.0000, 0.0000, 162.4327);
	CreateDynamicObject(978, 1635.260620, -1009.669922, 23.363663, 0.0000, 0.0000, 162.4327);
	CreateDynamicObject(978, 1626.309204, -1006.901794, 23.363663, 0.0000, 0.0000, 163.1890);
	CreateDynamicObject(978, 1615.491699, -1005.033691, 23.404272, 0.0000, 0.0000, 178.7620);
	CreateDynamicObject(978, 1624.593384, -1006.445740, 23.396475, 0.0000, 0.0000, 163.1890);
	CreateDynamicObject(978, 1606.153198, -1004.827209, 23.404272, 0.0000, 0.0000, 178.7620);
	CreateDynamicObject(978, 1599.043457, -1008.736267, 23.396475, 0.0000, 0.0000, 238.9226);
	CreateDynamicObject(978, 1594.336304, -1016.821838, 23.396475, 0.0000, 0.0000, 240.6414);
	CreateDynamicObject(978, 1590.245239, -1025.165161, 23.371475, 0.0000, 0.0000, 247.5169);
	CreateDynamicObject(978, 1586.940186, -1033.865112, 23.371475, 0.0000, 0.0000, 250.8515);
	CreateDynamicObject(978, 1584.280396, -1042.805542, 23.371475, 0.0000, 0.0000, 256.0082);
	CreateDynamicObject(978, 1582.944946, -1048.092163, 23.371475, 0.0000, 0.0000, 256.0082);
	CreateDynamicObject(978, 1584.633667, -1056.001343, 23.371475, 0.0000, 0.0000, 308.4338);
	CreateDynamicObject(978, 1588.060425, -1060.317017, 23.371475, 0.0000, 0.0000, 308.4338);
	CreateDynamicObject(978, 1593.107056, -1068.131348, 23.368353, 0.0000, 0.0000, 297.2611);
	CreateDynamicObject(978, 1597.374878, -1076.409546, 23.371475, 0.0000, 0.0000, 297.2611);
	CreateDynamicObject(978, 1601.017212, -1084.832886, 23.379261, 0.0000, 0.0000, 289.5262);
	CreateDynamicObject(978, 1603.046509, -1090.315186, 23.371840, 0.0000, 0.0000, 290.3856);
	CreateDynamicObject(978, 1605.617920, -1099.268066, 23.371475, 0.0000, 0.0000, 281.7913);
	CreateDynamicObject(978, 1606.587402, -1103.918701, 23.371475, 0.0000, 0.0000, 281.7913);
	CreateDynamicObject(978, 1608.215210, -1113.122925, 23.371475, 0.0000, 0.0000, 278.3535);
	CreateDynamicObject(978, 1680.047119, -1119.331177, 23.346476, 0.0000, 0.0000, 90.1369);
	CreateDynamicObject(978, 1659.577515, -1140.142212, 23.371475, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(978, 1679.993530, -1110.032959, 23.371475, 0.0000, 0.0000, 90.1369);
	CreateDynamicObject(978, 1680.047852, -1122.335449, 23.360540, 0.0000, 0.0000, 89.3806);
	CreateDynamicObject(978, 1676.616943, -1130.265259, 23.371475, 0.0000, 0.0000, 43.8304);
	CreateDynamicObject(978, 1669.964111, -1135.937012, 23.396475, 0.0000, 0.0000, 36.9549);
	CreateDynamicObject(978, 1668.030029, -1137.347900, 23.371475, 0.0000, 0.0000, 36.9549);
	CreateDynamicObject(978, 1650.791748, -1140.133911, 23.371475, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(978, 1609.497925, -1122.360229, 23.371475, 0.0000, 0.0000, 277.5972);
	CreateDynamicObject(978, 1610.474243, -1131.389282, 23.371475, 0.0000, 0.0000, 274.9158);
	CreateDynamicObject(978, 1615.869507, -1139.548828, 23.346476, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(978, 1610.767456, -1134.859497, 23.371475, 0.0000, 0.0000, 274.9158);
	CreateDynamicObject(978, 1620.257202, -1139.549683, 23.329807, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(978, 1645.980469, -1140.102051, 23.371475, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(978, 1629.151611, -1140.030396, 23.396475, 0.0000, 0.8586, 0.0000);
	CreateDynamicObject(966, 1634.226196, -1140.067627, 22.906250, 0.0000, 0.0000, 180.4809);
	CreateDynamicObject(968, 1634.109741, -1140.096680, 23.661848, 0.0000, 0.0000, 0.8586);
	//////////KARDIRADA LÕPP
	
	foodBar = CreateProgressbar(548.2, 54.5, 53.8, 0.1, 2.0, COLOR_BLACK, COLOR_GREEN, COLOR_WHITE);
	
	for( new i = 0; i <= 699; i++ )
	{
	    Vehicles[i][SpeedLimit] = 300;
	}
	
	SetTimer("MysqlCheck", 1000*60*5, true);
	SetTimer("UpdateAllPlayers", 1000*60*15, true);
	SetTimer("CheckFalseDeadPlayers", 3000, true);
	SetTimer("SyncAllPlayerTime", 950, true);
	SetTimer("UpdateAllPlayerPos", 1000*15, true);
	
	//Add3DStream("http://streamer.sotovik.ee:8500/skyplus_hi.ogg", 1742.8539,-1861.9402, 14.0, 25.0);	
	
	AddHelpDraw(510.12, -84.84, 998.867, "PILJARD", "Siin saad mängida piljardit, vajuta ENTER, et mängu alustada.");
	AddHelpDraw(494.1889, -75.4208, 998.7578, "BAAR", "Jookide ostmiseks vajuta ENTER.");
	AddHelpDraw(1939.5618, -1773.0765, 12.9710, "TANKLA", "Kütuse ostmiseks vajuta ENTER.");
	AddHelpDraw(1840.4050, -1857.0118, 12.9691, "AUTOTÖÖKODA", "Sisenemiseks vajuta ENTER.");
	AddHelpDraw(1025.4198, -1881.5576, 12.3513, "TURG", "Leia omale vaba putka ning kasuta /turg käsku, et kaupu müüa.");
	AddHelpDraw(654.1728, -1863.9569, 5.4609, "KANG", "Trenni tegemiseks vajuta ENTER.");
	AddHelpDraw(774.0507, 1.5343, 1001.1402, "KANG", "Trenni tegemiseks vajuta ENTER.");
	AddHelpDraw(770.0912, 13.4033, 1000.6996, "POKSIKOTID", "Trenni tegemiseks vajuta ENTER.");
	AddHelpDraw(396.9932,-2087.8381,7.8359, "KALAPÜÜK", "Püügi alustamiseks vajuta ENTER.");
	AddHelpDraw(387.3677,-2087.9058,7.8359, "KALAPÜÜK", "Püügi alustamiseks vajuta ENTER.");
	AddHelpDraw(367.4025,-2087.6528,7.8359, "KALAPÜÜK", "Püügi alustamiseks vajuta ENTER.");
	AddHelpDraw(358.8732,-2087.8032,7.8359, "KALAPÜÜK", "Püügi alustamiseks vajuta ENTER.");
	
	return 1;
}

public OnGameModeExit()
{
	UpdateAllPlayers();

	printf(LANG_UNLOADED, SCRIPT_NAME, SCRIPT_VERSION, SCRIPT_REVISION, SCRIPTER_NAME);
	return 1;
}

public OnPlayerConnect(playerid)
{
	MysqlCheck();

	ClearPlayerData(playerid);
    GetPlayerName(playerid, pInfo[playerid][pCharName], 30);
	
	if(IsPlayerNPC(playerid)) return NPCHandle(playerid);
	SendClientMessage(playerid, COLOR_YELLOW, WelcomeStr);
	InfoBarTimer[playerid] = -1;
	CheckCharacter(playerid);

	pInfo[playerid][pLoggedIn] = false;
	
	SyncPlayerTime(playerid);
	return 1;
}

public OnPlayerDisconnect(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
	if(pInfo[playerid][pLoggedIn])
	{
		UpdatePlayer(playerid);
		SaveSkills(playerid);
	}
	ClearPlayerData(playerid);	
	return 1;
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
		else return 1;
	}
	
	// Make Spawning safe.
	if(pInfo[playerid][pHealth] < 1.0) pInfo[playerid][pHealth] = 50.0;
	if(pInfo[playerid][pPosX] == 0 && pInfo[playerid][pPosY] == 0 && pInfo[playerid][pPosZ] == 0)
	{
		pInfo[playerid][pPosX] = 2420.3459;
		pInfo[playerid][pPosY] = -1229.8799;
		pInfo[playerid][pPosZ] = 24.7299;
		pInfo[playerid][pAngle] = 180;
	}


    SetPlayerPos(playerid, pInfo[playerid][pPosX],pInfo[playerid][pPosY],pInfo[playerid][pPosZ]+1);
	SetPlayerVirtualWorld(playerid, pInfo[playerid][pVW]);
	SetPlayerInterior(playerid,pInfo[playerid][pInterior]);
	SetPlayerFacingAngle(playerid, pInfo[playerid][pAngle]);
	SetPlayerSkin(playerid, pInfo[playerid][pModel]);
	SetPlayerHealth(playerid, pInfo[playerid][pHealth]);
	SetPlayerColor(playerid, PLAYER_COLOR);
	
	SetCameraBehindPlayer(playerid);
	
	ProccesBarShowForPlayer(foodBar, playerid);
	TogglePlayerClock(playerid, 1);
	
	pInfo[playerid][pControllable] = 1;
	
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER) 										OnDriverEnterVehicle(playerid);
	else if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT) OnDriverExitVehicle(playerid);
	
	if(oldstate == PLAYER_STATE_PASSENGER && newstate == PLAYER_STATE_ONFOOT && pInfo[playerid][pSeatbelt] > 0)
	{
		SendEmote(playerid, "võtab turvavöö ära ning tuleb masinast välja.");
		pInfo[playerid][pSeatbelt] = 0;
	}
}

public OnVehicleDeath(vehicleid)
{
	/*
	new vSqlId = GetVehicleSqlId(vehicleid);
	if(vSqlId != -1)
	{
		Vehicles[vSqlId][vDeaths]++;
		VehPosd(vSqlId);
		SetTimerEx("SetVehicleSpawn", 500, 0, "d", vSqlId);
	}
	*/
	return 1;
}

public OnRconCommand(cmd[])
{
	if( strcmp(cmd, "gmx", true) == 0 ){ SendClientMessageToAll(COLOR_GREEN, "GMX"); OnGameModeExit(); }
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
		if( response == 0 ) return 1;
		
	    if( strlen(inputtext) == 0 )
		{
		    SendClientMessage(playerid, COLOR_RED, LANG_EMPTY_ES);
		    SendEs(playerid);
		}
		else
		{
			new str[_strlib_med_string];
			str = str_replace("%s", "s", inputtext);
		    if( IsPlayerConnected(pInfo[playerid][SelectedPlayer]) && pInfo[pInfo[playerid][SelectedPlayer]][pLoggedIn] )
		    {
				ForwardEs(playerid, str);
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
	        KickPlayerP(pInfo[playerid][SelectedPlayer], playerid, inputtext);
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
	else if( dialogid == DIALOG_ADMINCP )
	{
		if( response == 0 ) return 1;
		
		if(listitem < 3) // 
		{
			showAdminActionDialog(playerid, listitem);
			return 1;
		}
		else showTeleDialog(playerid);
	}
	else if( dialogid == DIALOG_AACTION )
	{
		if( response != 0 )
		{
			if(pInfo[playerid][aAction] == 2)
			{
				new hour = strval(inputtext);
				if(hour > 0 && hour < 24) SetWorldTime(hour);
				else SendClientMessage(playerid, COLOR_RED, LANG_BAD_INPUT);
			}
			else if(pInfo[playerid][aAction] == 3)
			{
				new weather = strval(inputtext);
				if(weather > 0 && weather < 50) SetWeather(weather);
				else SendClientMessage(playerid, COLOR_RED, LANG_BAD_INPUT);
			}
			else
			{
				new str[_strlib_med_string];
				str = str_replace("%s", "s", inputtext);
				cmd_am(playerid, str);
			}
		}
		pInfo[playerid][aAction] = 0;
	}
	else if( dialogid == DIALOG_TELEPORTS )
	{
		if( response == 0 ) return 1;
		
		new vehId = GetPlayerVehicleID(playerid);
		
		if(vehId == 0)
		{
			SetPlayerPos(playerid, telePositions[listitem][tX], telePositions[listitem][tY], telePositions[listitem][tZ]);
		}
		else
		{
			SetVehiclePos(vehId, telePositions[listitem][tvX], telePositions[listitem][tvY], telePositions[listitem][tvZ]);
		}
		
		SendFormattedText(playerid, COLOR_GREEN, LANG_TELEPORTED_TO, telePositions[listitem][tName]);
	}
	else if( dialogid == DIALOG_POCKETS )
	{
		if( response == 0 ) return 1;
		UseItem(playerid, listitem);
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
	if( pickupid == PistolPickup )
		giveItem(playerid, 2, 100);
	if( pickupid == SawnoffPickup )
		giveItem(playerid, 5, 100);
	if( pickupid == MP5Pickup )		
		giveItem(playerid, 8, 100);
	if( pickupid == AKPickup )		
		giveItem(playerid, 9, 100);

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

	if(IsPlayerInAnyVehicle(playerid))
	{
		ApplyAnimation(playerid,"CAR_CHAT","car_talkm_loop",4.1,0,1,1,1,1);
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
    if( PRESSED(KEY_FIRE) || PRESSED(KEY_FIRE | KEY_HANDBRAKE) )
    {
		if(!IsPlayerInAnyVehicle(playerid))
		{
			if(SkillDelay[playerid][SKILL_PISTOL] == 0 && GetPlayerWeapon(playerid) == 22)
			{
				XpAdd(playerid, SKILL_PISTOL, 25);
				if( pInfo[playerid][pSkillTimer] == 0 ) pInfo[playerid][pSkillTimer] = SetTimerEx("XpAdd", 300, true, "iii", playerid, SKILL_PISTOL, 25);
			}
			if(SkillDelay[playerid][SKILL_PISTOLS] == 0 && GetPlayerWeapon(playerid) == 23)
			{
				XpAdd(playerid, SKILL_PISTOLS, 25);
				if( pInfo[playerid][pSkillTimer] == 0 ) pInfo[playerid][pSkillTimer] = SetTimerEx("XpAdd", 300, true, "iii", playerid, SKILL_PISTOLS, 25);
			}
			if(SkillDelay[playerid][SKILL_DEAGLE] == 0 && GetPlayerWeapon(playerid) == 24)
			{
				XpAdd(playerid, SKILL_DEAGLE, 25);
				if( pInfo[playerid][pSkillTimer] == 0 ) pInfo[playerid][pSkillTimer] = SetTimerEx("XpAdd", 300, true, "iii", playerid, SKILL_DEAGLE, 25);
			}
			if(SkillDelay[playerid][SKILL_SHOTGUN] == 0 && GetPlayerWeapon(playerid) == 25)
			{
				XpAdd(playerid, SKILL_SHOTGUN, 25);
				if( pInfo[playerid][pSkillTimer] == 0 ) pInfo[playerid][pSkillTimer] = SetTimerEx("XpAdd", 300, true, "iii", playerid, SKILL_SHOTGUN, 25);
			}
			if(SkillDelay[playerid][SKILL_SAWNOFF_SHOTGUN] == 0 && GetPlayerWeapon(playerid) == 26)
			{
				XpAdd(playerid, SKILL_SAWNOFF_SHOTGUN, 25);
				if( pInfo[playerid][pSkillTimer] == 0 ) pInfo[playerid][pSkillTimer] = SetTimerEx("XpAdd", 300, true, "iii", playerid, SKILL_SAWNOFF_SHOTGUN, 25);
			}
			if(SkillDelay[playerid][SKILL_SPAS12_SHOTGUN] == 0 && GetPlayerWeapon(playerid) == 27)
			{
				XpAdd(playerid, SKILL_SPAS12_SHOTGUN, 25);
				if( pInfo[playerid][pSkillTimer] == 0 ) pInfo[playerid][pSkillTimer] = SetTimerEx("XpAdd", 300, true, "iii", playerid, SKILL_SPAS12_SHOTGUN, 25);
			}
			if(SkillDelay[playerid][SKILL_MICRO_UZI] == 0 && GetPlayerWeapon(playerid) == 28)
			{
				XpAdd(playerid, SKILL_MICRO_UZI, 25);
				if( pInfo[playerid][pSkillTimer] == 0 ) pInfo[playerid][pSkillTimer] = SetTimerEx("XpAdd", 300, true, "iii", playerid, SKILL_MICRO_UZI, 25);
			}
			if(SkillDelay[playerid][SKILL_MP5] == 0 && GetPlayerWeapon(playerid) == 29)
			{
				XpAdd(playerid, SKILL_MP5, 25);
				if( pInfo[playerid][pSkillTimer] == 0 ) pInfo[playerid][pSkillTimer] = SetTimerEx("XpAdd", 300, true, "iii", playerid, SKILL_MP5, 25);
			}
			if(SkillDelay[playerid][SKILL_AK47] == 0 && GetPlayerWeapon(playerid) == 30)
			{
				XpAdd(playerid, SKILL_AK47, 25);
				if( pInfo[playerid][pSkillTimer] == 0 ) pInfo[playerid][pSkillTimer] = SetTimerEx("XpAdd", 300, true, "iii", playerid, SKILL_AK47, 25);
			}
			if(SkillDelay[playerid][SKILL_M4] == 0 && GetPlayerWeapon(playerid) == 31)
			{
				XpAdd(playerid, SKILL_M4, 25);
				if( pInfo[playerid][pSkillTimer] == 0 ) pInfo[playerid][pSkillTimer] = SetTimerEx("XpAdd", 300, true, "iii", playerid, SKILL_M4, 25);
			}
			if(SkillDelay[playerid][SKILL_SNIPERRIFLE] == 0 && GetPlayerWeapon(playerid) == 34)
			{
				XpAdd(playerid, SKILL_SNIPERRIFLE, 25);
				if( pInfo[playerid][pSkillTimer] == 0 ) pInfo[playerid][pSkillTimer] = SetTimerEx("XpAdd", 300, true, "iii", playerid, SKILL_SNIPERRIFLE, 25);
			}			
		}
	}
	if( RELEASED(KEY_FIRE) || RELEASED(KEY_FIRE | KEY_HANDBRAKE) )
	{
	    if( pInfo[playerid][pSkillTimer] != 0 )
	    {
	    	KillTimer(pInfo[playerid][pSkillTimer]);
			pInfo[playerid][pSkillTimer] = 0;
		}
	}
	if(PRESSED(KEY_JUMP) && !IsPlayerInAnyVehicle(playerid)) MegaJump(playerid);
}

public OnEnterExitModShop(playerid, enterexit, interiorid)
{
	if(enterexit == 0) serverMoneyFix(playerid);
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	serverMoneyFix(playerid);
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	serverMoneyFix(playerid);
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	serverMoneyFix(playerid);
}

public OnPlayerCommandText(playerid, cmdtext[])
{

}

public OnQueryFinish(query[], resultid)
{
	if( resultid == VEHICLE_LOAD_THREAD )
	{
		LoadAllVehiclesFinish();
	}
	else if( resultid == FETCH_UINFO_THREAD )
	{
		FetchCharacterInformationFinish(Fetch_UInfo_Thread);
	}
}

/*
*    COMMANDS
*/

COMMAND:o(playerid, params[])
{
	new text[STRING_LENGHT], str[STRING_LENGHT];
	sscanf(params, "s", text);
	
	if(strlen(text) == 0) return SendClientMessage(playerid, COLOR_RED, "KASUTUS: /o tekst");
	format(str, sizeof(str), "(( %s: %s ))", pInfo[playerid][pCharName], text);
	
	foreach(Player, i)
	{
	    if( pInfo[i][pLoggedIn] )
	    {
			SendClientMessage(i, COLOR_CHAT_OOC_GLOBAL, str);
	    }
	}
	
	return 1;
}

COMMAND:b(playerid, params[])
{
	new text[STRING_LENGHT], str[STRING_LENGHT];
	sscanf(params, "s", text);

	if(strlen(text) == 0) return SendClientMessage(playerid, COLOR_RED, "KASUTUS: /b tekst");

	format(str, sizeof(str), "%s OOC:(( %s ))", pInfo[playerid][pCharName], text);
	SCMTAInPlayerRadius(playerid, CHAT_RADIUS, COLOR_CHAT_OOC_LOCAL, str);
	return 1;
}

COMMAND:c(playerid, params[])
{
	new text[STRING_LENGHT], str[STRING_LENGHT];
	sscanf(params, "s", text);

	if(strlen(text) == 0) return SendClientMessage(playerid, COLOR_RED, "KASUTUS: /c tekst");

	new delay = ( strlen(text) * 150 ) + 2000;
	format(str, sizeof(str),"%s:  %s", pInfo[playerid][pCharName], text);	
	SetPlayerChatBubble(playerid, str, COLOR_CHAT_IC, CHAT_RADIUS, delay);
	SCMTAInPlayerRadius(playerid, CHAT_RADIUS, COLOR_CHAT_IC, str);
	return 1;
}

COMMAND:me(playerid, params[])
{
	new text[STRING_LENGHT];
	sscanf(params, "s", text);

	if(strlen(text) == 0) return SendClientMessage(playerid, COLOR_RED, "KASUTUS: /me tekst");

	SendEmote(playerid, text);
	return 1;
}
COMMAND:s(playerid, params[])
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
COMMAND:es(playerid, params[])
{
	new selplayer, text[STRING_LENGHT];
	sscanf(params, "us", selplayer, text);
	pInfo[playerid][SelectedPlayer] = selplayer;
	if( strlen(text) > 0 ) ForwardEs(playerid, text);
	else SendEs(playerid);
	return 1;
}

COMMAND:mjuurde(playerid, params[])
{
	if( pInfo[playerid][pAdminLevel] == 0 ) return SendClientMessage(playerid,COLOR_YELLOW, LANG_NOT_ADMIN);
	new selectedplayer;
	if ( sscanf(params, "u", selectedplayer) ) return SendClientMessage(playerid, COLOR_YELLOW, "KASUTUS: /mjuurde [ID/NIMI]");
    WarpPlayerToPlayer(playerid, selectedplayer);
    return 1;
}

COMMAND:m2m(playerid, params[])
{
	if( pInfo[playerid][pAdminLevel] == 0 ) return SendClientMessage(playerid,COLOR_YELLOW, LANG_NOT_ADMIN);
	new selectedplayer, selectedplayer2;
	if ( sscanf(params, "uu", selectedplayer, selectedplayer2) ) return SendClientMessage(playerid, COLOR_YELLOW, "KASUTUS: /m2m [ID/NIMI] [ID/NIMI]");
    WarpPlayerToPlayer(selectedplayer, selectedplayer2);
    return 1;
}

COMMAND:msiia(playerid, params[])
{
    if( pInfo[playerid][pAdminLevel] == 0 ) return SendClientMessage(playerid,COLOR_YELLOW, LANG_NOT_ADMIN);
    new selectedplayer;
    if ( sscanf(params, "u", selectedplayer) ) return SendClientMessage(playerid, COLOR_YELLOW, "KASUTUS: /msiia [ID/NIMI]");
    WarpPlayerToPlayer(selectedplayer, playerid);
    return 1;
}

COMMAND:kick(playerid, params[])
{
    if( pInfo[playerid][pAdminLevel] == 0 ) return SendClientMessage(playerid,COLOR_YELLOW, LANG_NOT_ADMIN);
	new selectedplayer, reason[STRING_LENGHT];
    sscanf(params, "us", selectedplayer, reason);
    if( strlen(reason) == 0 ){ pInfo[playerid][SelectedPlayer] = selectedplayer; ShowKickDialog(playerid); return 1;}
    else KickPlayerP(selectedplayer, playerid, reason);
    return 1;
}

COMMAND:ban(playerid, params[])
{
    if( pInfo[playerid][pAdminLevel] == 0 ) return SendClientMessage(playerid,COLOR_YELLOW, LANG_NOT_ADMIN);
    new selectedplayer, reason[STRING_LENGHT];
    sscanf(params, "us", selectedplayer, reason);
	if( strlen(reason) == 0 ){ pInfo[playerid][SelectedPlayer] = selectedplayer; ShowBanDialog(playerid); return 1;}
    else BanPlayer(selectedplayer, playerid, reason);
    return 1;
}

COMMAND:a(playerid, params[])
{
	if( pInfo[playerid][pAdminLevel] == 0 ) return SendClientMessage(playerid,COLOR_YELLOW, LANG_NOT_ADMIN);
	new str[STRING_LENGHT];
	if( sscanf(params,"s",str) ) return SendClientMessage(playerid, COLOR_YELLOW, "KASUTUS: /a [SÕNUM]");
	SendAdminChat(playerid, str);
	return 1;
}

COMMAND:oskus(playerid, params[])
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

COMMAND:teata(playerid, params[])
{
	new str[STRING_LENGHT];
	if( sscanf(params,"s",str) ) return SendClientMessage(playerid, COLOR_YELLOW, "KASUTUS: /teata [SÕNUM]");
	SendTeata(playerid, str);
	return 1;
}

COMMAND:am(playerid, params[])
{
	if( pInfo[playerid][pAdminLevel] == 0 ) return SendClientMessage(playerid,COLOR_YELLOW, LANG_NOT_ADMIN);
	new str[STRING_LENGHT];
	if( sscanf(params,"s",str) ) return SendClientMessage(playerid, COLOR_YELLOW, "KASUTUS: /am [SÕNUM]");
	SendAdminMessage(playerid, str);
	return 1;
}

COMMAND:admin(playerid, params[])
{
	#pragma unused params
	if( pInfo[playerid][pAdminLevel] == 0 ) return SendClientMessage(playerid,COLOR_YELLOW, LANG_NOT_ADMIN);
	
	showAdminDialog(playerid);
	return 1;
}

COMMAND:kiirusepiirang(playerid, params[])
{
	new piirang;
	if( sscanf(params, "i", piirang) ) return SendClientMessage(playerid, COLOR_YELLOW, "KASUTUS: /kiirusepiirang [Piirang KM/H]");
	if( piirang < 15 && piirang != 0 ) return SendClientMessage(playerid, COLOR_YELLOW, "Piirang ei saa olla väiksem kui 15km/h!, piiraja välja lülitamiseks sisesta 0");
	if( piirang > 300 ) piirang = 300;
	if( GetPlayerState(playerid) == PLAYER_STATE_DRIVER )
	{
	    new vehicleid = GetVehicleSqlId(GetPlayerVehicleID(playerid));

		Vehicles[vehicleid][SpeedLimit] = piirang;
		SendClientMessage(playerid, COLOR_YELLOW, "Piirang määratud!");

	}
	else return SendClientMessage(playerid, COLOR_YELLOW, "Sa ei juhi ühtegi autot!");
	return 1;
}

COMMAND:turbo(playerid, params[])
{
	new Float:turbo;
	if( sscanf(params, "f", turbo) ) return SendClientMessage(playerid, COLOR_YELLOW, "KASUTUS: /turbo [turbo suurus]");
	if( turbo > 10 || turbo < 0 ) return SendClientMessage(playerid, COLOR_YELLOW, "Turbo suurus võib olla 0-10");
	if( GetPlayerState(playerid) == PLAYER_STATE_DRIVER )
	{
	    new vehicleid = GetVehicleSqlId(GetPlayerVehicleID(playerid));

		Vehicles[vehicleid][Turbo] = turbo;
		SendClientMessage(playerid, COLOR_YELLOW, "turbo määratud!");

	}
	else return SendClientMessage(playerid, COLOR_YELLOW, "Sa ei juhi ühtegi autot!");
	return 1;
}

COMMAND:turvav88(playerid, params[])
{
	#pragma unused params
	if(IsPlayerInAnyVehicle(playerid))
	{
	    if(pInfo[playerid][pSeatbelt] == 1)
		{
			SendEmote(playerid, "eemaldab turvavöö.");
			pInfo[playerid][pSeatbelt] = 0;
		}
		else
		{
			SendEmote(playerid, "paneb turvavöö peale.");
			pInfo[playerid][pSeatbelt] = 1;
		}
	}
	else return SendClientMessage(playerid, COLOR_YELLOW, "Sa ei ole üheski autos!");
	return 1;
}

COMMAND:tapa(playerid, params[])
{
	#pragma unused params
	SetPlayerHealth(playerid, 0.0);
	return 1;
}

COMMAND:taskud(playerid, params[])
{
	#pragma unused params
	showPockets(playerid);
	return 1;
}
COMMAND:td(playerid, params[])
{
	#pragma unused params
	giveItem(playerid, 1, 100);
	return 1;
}

COMMAND:afk(playerid, params[])
{
	if(pInfo[playerid][AFK])
	{
		pInfo[playerid][AFK] = false;
		SetPlayerColor(playerid, PLAYER_COLOR);
		gAnimsDisabled[playerid] = false;
	}
	else
	{
		pInfo[playerid][AFK] = true;
		SetPlayerColor(playerid, COLOR_AFK);
		gAnimsDisabled[playerid] = true;
	}
	PlayerStatusChange(playerid, ((pInfo[playerid][AFK])?STATUS_AFK:STATUS_NONE));	
	TogglePlayerControllableEx(playerid, ((pInfo[playerid][AFK])?0:1), -1);
	SendFormattedText(playerid, COLOR_GREEN, LANG_AFK, ((pInfo[playerid][AFK])?("oled nüüd"):("ei ole enam")));
	return 1;
}

COMMAND:abi(playerid, params[])
{
	#pragma unused params
	SendClientMessage(playerid, COLOR_YELLOW, "*** ABI");
	SendClientMessage(playerid, COLOR_YELLOW, " ");
	
	SendClientMessage(playerid, COLOR_YELLOW, "/ic - Saad teada mis on ic.");	
	SendClientMessage(playerid, COLOR_YELLOW, "/ooc - Saad teada mis on ooc.");	

	SendClientMessage(playerid, COLOR_YELLOW, "/rääkimisabi - Erinevate suhtluskanalite abi.");	
	SendClientMessage(playerid, COLOR_YELLOW, "/animatsioonid - Animatsioonide käsud.");	
	
	SendClientMessage(playerid, COLOR_YELLOW, "MUUD ASJAD:");	
	
	SendClientMessage(playerid, COLOR_YELLOW, "/oskus /teata /kiirusepiirang /turvavöö /taskud /tapa /afk");	
	
	SendClientMessage(playerid, COLOR_YELLOW, " ");
	SendClientMessage(playerid, COLOR_YELLOW, "*** ABI");
	return 1;
}

COMMAND:r22kimisabi(playerid, params[])
{
	#pragma unused params
	SendClientMessage(playerid, COLOR_YELLOW, "*** RÄÄKIMISABI");
	SendClientMessage(playerid, COLOR_YELLOW, " ");
	
	SendClientMessage(playerid, COLOR_YELLOW, "/o - Globaalne OOC(vaata /ooc) suhtluskanal..");	
	SendClientMessage(playerid, COLOR_YELLOW, "/b - Lokaalne OOC(vaata /ooc) suhtluskanal..");	
	SendClientMessage(playerid, COLOR_YELLOW, "/es - Teise mängijaga privaatne OOC(vaata /ooc) suhtluskanal..");
	
	SendClientMessage(playerid, COLOR_YELLOW, "/c - IC(vaata /ic) sosistamine.");
	SendClientMessage(playerid, COLOR_YELLOW, "/s - IC(vaata /ic) karjumine.");
	SendClientMessage(playerid, COLOR_YELLOW, "/me - Saad väljendada oma IC(vaata /ic) tegevust, tundeid.");
	
	SendClientMessage(playerid, COLOR_YELLOW, " ");
	SendClientMessage(playerid, COLOR_YELLOW, "*** RÄÄKIMISABI");	
	return 1;
}

COMMAND:ic(playerid, params[])
{
	#pragma unused params
	SendClientMessage(playerid, COLOR_YELLOW, "*** IC");
	SendClientMessage(playerid, COLOR_YELLOW, " ");	
	
	SendClientMessage(playerid, COLOR_YELLOW, "In Character ehk tegelasesisene on kõik mida ütleb/mõtleb/teeb sinu karakter mitte isik kes karakterit kontrollib.");		
	
	SendClientMessage(playerid, COLOR_YELLOW, " ");
	SendClientMessage(playerid, COLOR_YELLOW, "*** IC");	
	return 1;
}

COMMAND:ooc(playerid, params[])
{
	#pragma unused params
	SendClientMessage(playerid, COLOR_YELLOW, "*** OOC");
	SendClientMessage(playerid, COLOR_YELLOW, " ");	
	
	SendClientMessage(playerid, COLOR_YELLOW, "Out of Character ehk tegelaseväline on kõik mida ütled/mõtled/teed sina mitte isik kes mängus rooliratast keerab.");
	
	SendClientMessage(playerid, COLOR_YELLOW, " ");
	SendClientMessage(playerid, COLOR_YELLOW, "*** OOC");	
	return 1;
}
	

// AJUTISED
COMMAND:kaklus(playerid, params[])
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

COMMAND:addveh(playerid, params[])
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

// AJUTISED
COMMAND:int(playerid, params[])
{
	new id;
	if(sscanf(params, "i", id))
	{
		SendClientMessage(playerid, COLOR_YELLOW, "KASUTUS: /int [id]");
		return 1;
	}
	
	setToInt(playerid, id);
	return 1;
}

COMMAND:pasad(playerid, params[])
{
	new id, id2;
	if(sscanf(params, "ii", id, id2))
	{
		SendClientMessage(playerid, COLOR_YELLOW, "KASUTUS: /pasad [id] [id2]");
		return 1;
	}
	
	CallRemoteFunction("poolPostition", "iii", playerid, id, id2);
	return 1;
}

COMMAND:ajaleht(playerid, params[])
{
	new id = 0;
	if(sscanf(params, "i", id)) id = 0;
	
	new ret = ShowNewsPaper(playerid, id);
	SendFormattedText(playerid, COLOR_ADMINCHAT, "ID: %d Ret %d", id, ret);
	return 1;
}

COMMAND:epicownage(playerid, params[])
{
	if(WritePaper(playerid))
	{
		SendClientMessage(playerid, COLOR_GREEN, LANG_WRITE_HEADLINE);
	}
	else
	{
		SendClientMessage(playerid, COLOR_GREEN, LANG_SOME_ERROR);
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
	
	format(str, sizeof(str),"-> %s(%d): %s", pInfo[pInfo[playerid][SelectedPlayer]][pCharName], pInfo[playerid][SelectedPlayer], message);
	SendClientMessage(playerid, COLOR_CHAT_ES, str);
	format(str, sizeof(str),"<- %s(%d): %s", pInfo[playerid][pCharName], playerid, message);
	SendClientMessage(pInfo[playerid][SelectedPlayer], COLOR_CHAT_ES, str);
}

public SendEmote(playerid, emote[])
{
	new Float:PlayerLocX, Float:PlayerLocY, Float:PlayerLocZ, str[STRING_LENGHT];
	GetPlayerPos(playerid, PlayerLocX, PlayerLocY, PlayerLocZ);
	format(str, sizeof(str),"*%s %s*", pInfo[playerid][pCharName], emote);
	
	foreach(Player, i)
	{
	    if( pInfo[i][pLoggedIn] )
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
	
	foreach(Character, i)
	{
	    if( pInfo[i][pLoggedIn] )
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

public KickPlayerP(playerid, kicker, reason[])
{
	new str[STRING_LENGHT];
	format(str, sizeof(str), LANG_GLOBAL_KICKMSG, pInfo[kicker][pCharName], pInfo[playerid][pCharName], reason);
	SendClientMessageToAll(COLOR_ADMINMSG, str);
	Kick(playerid);
}

public ShowBanDialog(playerid)
{
	new str[STRING_LENGHT];
	format( str, sizeof(str), LANG_DIALOG_BAN_S, pInfo[pInfo[playerid][SelectedPlayer]][pCharName]);
	ShowPlayerDialog(playerid, DIALOG_BANPLAYER, DIALOG_STYLE_INPUT, str, LANG_DIALOG_REASON, LANG_DIALOG_BAN, LANG_DIALOG_END);
}

public ShowKickDialog(playerid)
{
	new str[STRING_LENGHT];
	format( str, sizeof(str), LANG_DIALOG_KICK_S, pInfo[pInfo[playerid][SelectedPlayer]][pCharName]);
	ShowPlayerDialog(playerid, DIALOG_KICKPLAYER, DIALOG_STYLE_INPUT, str, LANG_DIALOG_REASON, LANG_DIALOG_KICK, LANG_DIALOG_END);
}

public SendAdminChat(playerid, text[])
{
	new str[STRING_LENGHT];
	format( str, sizeof(str), "(%i)%s: %s", pInfo[playerid][pAdminLevel], pInfo[playerid][pCharName], text);
	foreach(Player, i)
	{
	    if( pInfo[i][pLoggedIn] && pInfo[i][pAdminLevel] > 0 )
	    	SendClientMessage(i, COLOR_ADMINCHAT, str);
	}
}
public SendTeata(playerid, text[])
{
	new str[STRING_LENGHT];
	format( str, sizeof(str), LANG_REPORT, playerid, pInfo[playerid][pCharName], text);
	foreach (Player, i)
	{
	    if( pInfo[i][pLoggedIn] && pInfo[i][pAdminLevel] > 0 )
	    	SendClientMessage(i, COLOR_TEATA, str);
	}
}
public SendAdminMessage(playerid, text[])
{
    new str[STRING_LENGHT];
	format( str, sizeof(str), LANG_ADMINMSG, pInfo[playerid][pCharName], text);
	SendClientMessageToAll(COLOR_ADMIN_MESSAGE, str);
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
	else pInfo[playerid][npcId] = 99;
	//Kick(playerid);
	return 0;
}

public CheckFalseDeadPlayers(playerid)
{
	new Float:health;
	foreach (Player, i)
	{
	    if( pInfo[i][pLoggedIn] )
	    {
	    	health = GetPlayerHealth(i, health);
	    	if( health < 1 )
	   		{
				SpawnPlayer(i);
	    	}
	    }
	}
}

public SyncPlayerTime(playerid)
{
	SetPlayerTime(playerid, gHour, gMinute);
}

public SyncAllPlayerTime()
{
	new old = gHour;
	gettime(gHour, gMinute, gSecond);
	gHour = gHour + TIME_OFFSET;
	if(old != gHour) SetWorldTime(gHour);
	if(gMinute == 0 && !gHourChange) 
	{
		gHourChange = true;
		OnNewHour();
	}
	else if(gMinute != 0 && gHourChange) gHourChange = false;
	
	foreach(Player, playerid)
	{
		SyncPlayerTime(playerid);
	}
}

public TogglePlayerControllableEx(playerid, toggle, timer)
{
	pInfo[playerid][pControllable] = toggle;
	TogglePlayerControllable(playerid, toggle);
	
	if(timer != -1)
	{
		new newval = 0;
		if(toggle == 0) newval = 1;
		SetTimerEx("TogglePlayerControllableEx", timer, 0, "iii", playerid, newval, -1);
	}
}

public OnNewHour()
{
	SendFormattedTextToAll(COLOR_GREEN, "Kell on nüüd %d:0%d.", gHour, gMinute);
	
	foreach(Player, playerid)
	{
		if(gMyJob[playerid] > 0)
		{
			gMyContract[playerid]--;
			if(gMyContract[playerid] > 0)
			{
				SendFormattedText(playerid, COLOR_GREEN, LANG_JOB_CONTRACT_TIME, gMyContract[playerid]);
			}
			else
			{
				SendClientMessage(playerid, COLOR_GREEN, LANG_JOB_CONTRACT_END);
			}			
		}
	}
}

public OnPlayerJobChange(playerid, bool: success)
{
	if(success)
	{
		SendFormattedText(playerid, COLOR_GREEN, LANG_GOT_JOB_EX, gJobsNames[gMyJob[playerid]], gMyContract[playerid]);
		SendClientMessage(playerid, COLOR_GREEN, LANG_JOBHELP);
	}
	else
	{
		SendClientMessage(playerid, COLOR_GREEN, LANG_X_JOB);
	}
}

public OnPlayerRequestJob(playerid, jobId)
{
	new string[64];
	format(string, 64, "Kas nõustud töölepinguga?\n\tAmet: %s\n\tPalk: %d %s\n\tTööaeg: %d", gJobsNames[jobId], gJobsPay[jobId], (gJobsPayH[jobId]?(" tunnis"):("(tükitöö)")), gJobsTime[jobId]);
	ShowPlayerConfirmbox(playerid, JOB_CONFIRM_BOX, string);
	
	pJobRequest[playerid] = jobId;
	pJobRequestT[playerid] = gJobsTime[jobId];
}

public OnPlayerConfirm(playerid, response, boxId)
{
	if(boxId == JOB_CONFIRM_BOX)
	{
		if(response != 0) SetPlayerJob(playerid, pJobRequest[playerid], pJobRequestT[playerid]);
		else SendClientMessage(playerid, COLOR_YELLOW, LANG_REFUSE_JOB);
	}
	else SendClientMessage(playerid, COLOR_YELLOW, "VALE KAST!");
}

/*
*    EOF
*/
