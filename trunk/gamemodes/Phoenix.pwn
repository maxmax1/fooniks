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
*    INCLUDES
*/

#include <a_samp>
#include <a_mysql>
#include <phoenix_Core>
#include <phoenix_Lang>
#include <phoenix_RealCarnames>

/*
*    DEFINES
*/

#define SCRIPT_NAME			"Phoenix"
#define SCRIPT_VERSION  	"0.1"
#define SCRIPT_REVISION 	"26"

#define MYSQL_HOST			"80.79.119.221"//"localhost"
#define MYSQL_USER			"estrpco_portal"
#define MYSQL_DB			"estrpco_portal"
#define MYSQL_PREFIX		"ph_"

#define VEHICLE_DELAY 60000
#define VEHICLE_LOAD_THREAD 1
#define VEHICLE_SAVE_THREAD 2
#define VEHICLE_GROUP			0	// Gängid, Grupeeringud
#define VEHICLE_JOB				1	// Tööd
#define VEHICLE_BUYABLE			2	// Ostetav masin
#define VEHICLE_SPECIAL			3	// Rongid, transpordivahendid jms. PS: Neid ei saa mängijad kasutada. Botid juhivad!
#define VEHICLE_ADMIN			4	// Administraatorite masinad

#define COLOR_YELLOW		0xFFFF00AA
#define COLOR_RED 0xAA3333AA
#define COLOR_GREEN 0x33AA33AA

/*
*    GLOBAL VARIABLES
*/

new WelcomeStr[32];

enum pInf
{
	pAdmin,
	pJob,
	pMember,
	pLeader
};
new PlayerInfo[MAX_PLAYERS][pInf];

IsGroupMember(playerid)
{
	new ret = PlayerInfo[playerid][pMember];
	if(PlayerInfo[playerid][pLeader] > 0) ret = PlayerInfo[playerid][pLeader];
	return ret;
}

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
	Float: vAngZ,
	
	vColor1,
	vColor2,
	
	vOwner,
	vValue,
	
	vDeaths,
	Float: vHealth,
};
new Vehicles[700][vInf];

/*
*    FORWARDS
*/
forward LoadAllVehiclesStart();
forward LoadAllVehiclesFinish();
forward SaveAllVehicles(closingdown);
forward SaveVehicle(vId, saveall);
forward SetVehicleSpawn(vId);
forward OnDriverEnterVehicle(playerid);
forward OnDriverExitVehicle(playerid);
forward ShowSpeedo(playerid);
forward OnSpeedoUpdate(playerid);

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

stock VehPos(vId)
{
	GetVehiclePos(Vehicles[vId][vSampId], Vehicles[vId][vPosX], Vehicles[vId][vPosY], Vehicles[vId][vPosZ]);
	GetVehicleZAngle(Vehicles[vId][vSampId], Vehicles[vId][vAngZ]);
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

	new string[24]; // 24 should be enough.
	format(string, 24, "%s %s r%d", SCRIPT_NAME, SCRIPT_VERSION, SCRIPT_REVISION);
	SetGameModeText(string);
	
	printf(LANG_LOADED, SCRIPT_NAME, SCRIPT_VERSION, SCRIPT_REVISION, SCRIPTER_NAME);
	format(WelcomeStr, 32, LANG_WELCOME_TO, SCRIPT_NAME, SCRIPT_VERSION, SCRIPT_REVISION, SCRIPTER_NAME);
	
	AddPlayerClass(0, 0, 0, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
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
	
	return 1;
}

public OnGameModeExit()
{
	SaveAllVehicles(true);

	printf(LANG_UNLOADED, SCRIPT_NAME, SCRIPT_VERSION, SCRIPT_REVISION, SCRIPTER_NAME);
	return 1;
}

public OnPlayerConnect(playerid)
{
	SendClientMessage(playerid, COLOR_YELLOW, WelcomeStr);
	InfoBarTimer[playerid] = -1;
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER) 			OnDriverEnterVehicle(playerid);
	else if(newstate == PLAYER_STATE_ONFOOT) 		OnDriverExitVehicle(playerid);
}

public OnVehicleDeath(vehicleid)
{
	SetVehicleToRespawn(vehicleid);
	SetTimerEx("SetVehicleSpawn", 500, 0, "d", GetVehicleSqlId(vehicleid));
}

/*
*    PUBLICS
*/


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
		
		mysql_fetch_field_row(Field, "vOwner");
		Vehicles[vId][vOwner] = strval(Field);
		
		mysql_fetch_field_row(Field, "vValue");
		Vehicles[vId][vValue] = strval(Field);
		
		mysql_fetch_field_row(Field, "vDeaths");
		Vehicles[vId][vDeaths] = strval(Field);
		
		mysql_fetch_field_row(Field, "vHealth");
		Vehicles[vId][vHealth] = floatstr(Field);
		
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
	
	if(vId == -1) Remove = true;
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
			else if(PlayerInfo[playerid][pJob] != Vehicles[vId][vOwner]) Remove = true;
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
			if(PlayerInfo[playerid][pAdmin] < 1) Remove = true;
			else if(PlayerInfo[playerid][pAdmin] < Vehicles[vId][vOwner]) Remove = true;
		}
	}
	
	if(Remove)
	{
		RemovePlayerFromVehicle(playerid);
		SendClientMessage(playerid, COLOR_RED, "Sul pole selle auto võtmeid.");
	}
	else
	{
		if(Freeze) TogglePlayerControllable(playerid, 0);
	
		ShowSpeedo(playerid);
		format(string, 128, "%s", CarNames[Vehicles[vId][vModel] - 400]);
		GameTextForPlayer(playerid, string, 6000, 1);
	}
}

public OnDriverExitVehicle(playerid)
{
	InfoBarTimer[playerid] = -1;
}

public ShowSpeedo(playerid)
{
	if(InfoBarTimer[playerid] != -1) return 0;
	
	InfoBarTimer[playerid] = SetTimerEx("OnSpeedoUpdate", 500, 1, "i", playerid);
	TextDrawShowForPlayer(playerid, InfoBar[playerid]);	
	return 1;
}

public OnSpeedoUpdate(playerid)
{
	if(IsPlayerConnected(playerid) && IsPlayerInAnyVehicle(playerid))
	{
		new vId = GetVehicleSqlId(GetPlayerVehicleID(playerid));
		GetVehicleHealth(Vehicles[vId][vSampId], Vehicles[vId][vHealth]);
		new hProtsenti = floatround((Vehicles[vId][vHealth] - 300) / 10);
		new string[128], fuel[3] = "-";
		
		GetVehicleVelocity(Vehicles[vId][vSampId], Vehicles[vId][vPosX], Vehicles[vId][vPosY], Vehicles[vId][vPosZ]);
		new Float: distance = floatabs(Vehicles[vId][vPosX]) + floatabs(Vehicles[vId][vPosY]) + floatabs(Vehicles[vId][vPosZ]);
		new speed = floatround(distance * 175);
		format(string,sizeof(string),"~y~~h~Bensiin: %s  ~y~~h~Kiirus: ~w~%i km/h  ~y~~h~Korras: ~w~%d", fuel, speed, hProtsenti);
		TextDrawSetString(InfoBar[playerid], string);
	}
	else
	{
		TextDrawHideForPlayer(playerid, InfoBar[playerid]);
		KillTimer(InfoBarTimer[playerid]);
	}
}

/*
*    EOF
*/