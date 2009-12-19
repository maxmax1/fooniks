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
*    This File: phoenix_Vehicles.inc
*    Purpose: Vehicle System for phoenix.
*/

/*
*    DEFINES
*/

#define VEHICLE_DELAY 1000*60*5

#define VEHICLE_GROUP			0	// Gängid, Grupeeringud
#define VEHICLE_JOB				1	// Tööd
#define VEHICLE_BUYABLE			2	// Ostetav masin
#define VEHICLE_SPECIAL			3	// Rongid, transpordivahendid jms. PS: Neid ei saa mängijad kasutada. Botid juhivad!
#define VEHICLE_ADMIN			4	// Administraatorite masinad

/*
*    GLOBALS
*/

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
	SpeedLimit = 300,
	Float:Turbo
};
new Vehicles[700][vInf];

new Text:  InfoBar[MAX_PLAYERS];
new 	   InfoBarTimer[MAX_PLAYERS];

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

stock VehPosd(vId)
{
	Vehicles[vId][vPosX] = Vehicles[vId][vPosXd];
	Vehicles[vId][vPosY] = Vehicles[vId][vPosZd];
	Vehicles[vId][vPosZ] = Vehicles[vId][vPosYd];
	Vehicles[vId][vAngZ] = Vehicles[vId][vAngZd];
}

/*
*    FORWARDS
*/

forward LoadAllVehiclesStart();
forward LoadAllVehiclesFinish();
forward SaveAllVehicles(closingdown);
forward SaveVehicle(vId);
forward SetVehicleSpawn(vId);
forward OnDriverEnterVehicle(playerid);
forward OnDriverExitVehicle(playerid);
forward ShowSpeedo(playerid);
forward OnSpeedoUpdate(playerid);
forward AddCarToSQL(model, Float:posX, Float:posY, Float:posZ, Float:angle);
forward CrashCar(SQLVid, vehicleid, Float:damage, Float:oX, Float:oY, Float:oZ);

/*
*    ALS Next Ones
*/
forward phV_OnGameModeExit();

/*
*    PUBLICS
*/


public LoadAllVehiclesStart()
{
	print("\t\t Started Loading Vehicles.");
	new query[32];
	format(query, 32, "SELECT * FROM %svehicles", MYSQL_PREFIX);
	mysql_query(query, VEHICLE_LOAD_THREAD);
}

public LoadAllVehiclesFinish()
{
	if(!mysql_store_result()) return 0;
	
	new Field[64], Data[512], vId, numRows = mysql_num_rows();
	while(vId < numRows)
	{
		if(!mysql_fetch_row_format(Data, " ")) continue;
		
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
			
		#if defined PH_DEBUG
		printf("Loaded Veh: %d.\n", Vehicles[vId][vSqlID]);
		#endif
			
		if(Vehicles[vId][vHealth] < 400.0) Vehicles[vId][vHealth] = 450.0;
		
		Vehicles[vId][vSampId] = AddStaticVehicleEx(Vehicles[vId][vModel], 
													Vehicles[vId][vPosXd],
													Vehicles[vId][vPosYd],
													Vehicles[vId][vPosZd],
													Vehicles[vId][vAngZd],
													/*Vehicles[vId][vColor1]*/-1,
													/*Vehicles[vId][vColor2]*/-1,
													VEHICLE_DELAY);
		//SetTimerEx("SetVehicleSpawn", 500, 0, "d", vId);
		vId++;
	}
	LOADED_VEHICLES = vId+1;
	printf("\t\t %d Vehicles Loaded.", LOADED_VEHICLES);
	mysql_free_result();
	return 1;
}

public SaveAllVehicles(closingdown)
{
	for(new i; i < LOADED_VEHICLES; i++)
	{
		SaveVehicle(i);
	}
}

public SaveVehicle(vId)
{
	if(vId < 0 || vId > LOADED_VEHICLES) return 0;
	if(Vehicles[vId][vSqlID] < 1) return 0;

	VehPos(vId);
	
	new query[MAX_QUERY], table[32];
	format(table, 32, "%svehicles", MYSQL_PREFIX);
	
	MysqlUpdateBuild(query, table);
	MysqlUpdateInt(query, "vColor1", Vehicles[vId][vColor1]);
	MysqlUpdateInt(query, "vColor2", Vehicles[vId][vColor2]);
	MysqlUpdateInt(query, "vOwner", Vehicles[vId][vOwner]);
	MysqlUpdateInt(query, "vValue", Vehicles[vId][vValue]);
	MysqlUpdateInt(query, "vDeaths", Vehicles[vId][vDeaths]);
	MysqlUpdateFlo(query, "vHealth", Vehicles[vId][vHealth]);
	
	MysqlUpdateFlo(query, "vPosX", Vehicles[vId][vPosX]);
	MysqlUpdateFlo(query, "vPosY", Vehicles[vId][vPosY]);
	MysqlUpdateFlo(query, "vPosZ", Vehicles[vId][vPosZ]);
	MysqlUpdateFlo(query, "vAngZ", Vehicles[vId][vAngZ]);
	
	MysqlUpdateFinish(query, "vehicleId", Vehicles[vId][vSqlID]);
	return 1;
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
			else if(gMyJob[playerid] != Vehicles[vId][vOwner]) Remove = true;
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
	if(vId == -1) return 0;
	
	Vehicles[vId][vSpeed] = 0;
	InfoBarTimer[playerid] = -1;
	
	if(pInfo[playerid][pSeatbelt] > 0)
	{
		SendEmote(playerid, "võtab turvavöö ära ning tuleb masinast välja.");
		pInfo[playerid][pSeatbelt] = 0;
	}	
	return 1;
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
		if(vId == -1) return 0;

		new oSpeed = Vehicles[vId][vSpeed], Float: oHealth = Vehicles[vId][vHealth];
		new Float: oX = Vehicles[vId][vSpeedX], Float: oY = Vehicles[vId][vSpeedY], Float: oZ = Vehicles[vId][vSpeedZ];

		GetVehicleHealth(Vehicles[vId][vSampId], Vehicles[vId][vHealth]);		
		new hProtsenti = floatround(((Vehicles[vId][vHealth] - 295) / 705) * 100);
		if(hProtsenti < 0) hProtsenti = 0;
		new string[128], fuel[3] = "-";

		GetVehicleVelocity(Vehicles[vId][vSampId], Vehicles[vId][vSpeedX], Vehicles[vId][vSpeedY], Vehicles[vId][vSpeedZ]);
		new Float: distance = floatabs(Vehicles[vId][vSpeedX]) + floatabs(Vehicles[vId][vSpeedY]) + floatabs(Vehicles[vId][vSpeedZ]);
		Vehicles[vId][vSpeed] = floatround(distance * 175);
		new showspeed = Vehicles[vId][vSpeed];
		if( showspeed > Vehicles[vId][SpeedLimit] && Vehicles[vId][SpeedLimit] != 0 ) showspeed = Vehicles[vId][SpeedLimit];
		format(string,sizeof(string),"~y~~h~Bensiin: %s  ~y~~h~Kiirus: ~w~%i km/h  ~y~~h~Korras: ~w~%d %%", fuel, showspeed, hProtsenti);
		TextDrawSetString(InfoBar[playerid], string);
		
		if((oSpeed - Vehicles[vId][vSpeed]) > 70 && (oHealth - Vehicles[vId][vHealth]) > 100)
		{
         	new Float:damage = oHealth - Vehicles[vId][vHealth];
			CrashCar(vId, Vehicles[vId][vSampId], damage, oX, oY, oZ);
			Vehicles[vId][vSpeed] = 0;
		}
		if( Vehicles[vId][Turbo] != 0 )
		{
		    new keys, updown, leftright;
		    GetPlayerKeys(playerid, keys, updown, leftright);
		    if( keys == 8 && leftright == 0 && showspeed > 10)
		    {
		        new Float:SpeedX, Float:SpeedY, Float:PercentX, Float:PercentY, Float:newX, Float: newY, NegativeX, NegativeY;
				SpeedX = Vehicles[vId][vSpeedX];
				SpeedY = Vehicles[vId][vSpeedY];

				if(SpeedX < 0) NegativeX = 1;
				if(SpeedY < 0) NegativeY = 1;
				if(NegativeX) SpeedX = SpeedX*-1;
				if(NegativeY) SpeedY = SpeedY*-1;
				PercentX = SpeedX/100;
				PercentY = SpeedY/100;
				
				new Float:turbo = Vehicles[vId][Turbo];
				
				if ( showspeed > 200 ) turbo = turbo / 4;
				else if ( showspeed > 100 ) turbo = turbo / 2;

				newX = SpeedX + PercentX*turbo;
				newY = SpeedY + PercentY*turbo;
				if(NegativeX) newX = newX*-1;
				if(NegativeY) newY = newY*-1;

				SetVehicleVelocity(Vehicles[vId][vSampId], newX, newY, Vehicles[vId][vSpeedZ]);
			}
		}
		if( Vehicles[vId][vSpeed] > Vehicles[vId][SpeedLimit] && Vehicles[vId][SpeedLimit] != 0 )
		{
			new Float:SpeedX, Float:SpeedY, Float:RatioX, Float:RatioY, Float:newX, Float: newY, NegativeX, NegativeY;
			new Limit = Vehicles[vId][SpeedLimit];
			
			SpeedX = Vehicles[vId][vSpeedX];
			SpeedY = Vehicles[vId][vSpeedY];

			if(SpeedX < 0) NegativeX = 1;
			if(SpeedY < 0) NegativeY = 1;
			if(NegativeX) SpeedX = SpeedX*-1;
			if(NegativeY) SpeedY = SpeedY*-1;
			RatioX = SpeedX/( SpeedX + SpeedY );
			RatioY = SpeedY/( SpeedX + SpeedY );
			new Float:SU_Limit = floatdiv(Limit, 175);
			newX = floatmul(SU_Limit ,RatioX);
			newY = floatmul(SU_Limit ,RatioY);
			if(NegativeX) newX = newX*-1;
			if(NegativeY) newY = newY*-1;

			SetVehicleVelocity(Vehicles[vId][vSampId], newX, newY, Vehicles[vId][vSpeedZ]);

		}
		
	}
	else
	{
		TextDrawHideForPlayer(playerid, InfoBar[playerid]);
		KillTimer(InfoBarTimer[playerid]);
	}
	return 1;
}

public AddCarToSQL(model, Float:posX, Float:posY, Float:posZ, Float:angle)
{
	new query[1028];
	format(query, sizeof(query), "INSERT INTO `estrpco_portal`.`ph_vehicles` (`vehicleId` ,`vModel` ,`vType` ,`vPosXd` ,`vPosYd` ,`vPosZd` ,`vAngZd` ,`vPosX` ,`vPosY` ,`vPosZ` ,`vAngZ` ,`vColor1` ,`vColor2` ,`vOwner` ,`vValue` ,`vDeaths` ,`vHealth`)VALUES (NULL , '%i', '0', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '-1', '-1', '0', '0', '0', '1000');", model, posX, posY, posZ, angle, posX, posY, posZ, angle);
	mysql_query(query, FETCH_UINFO_THREAD);
}

public CrashCar(SQLVid, vehicleid, Float:damage, Float:oX, Float:oY, Float:oZ)
{
	new pVeh;
	foreach (Player, playerid)
	{
	    if( pInfo[playerid][pLoggedIn] && IsPlayerInAnyVehicle(playerid) )
	    {
			pVeh = GetPlayerVehicleID(playerid);
			if( pVeh == vehicleid )
			{
				if(pInfo[playerid][pSeatbelt] == 0)
				{
					VehPos(SQLVid);
					SendEmote(playerid, LANG_VEH_CRASH);
					SetPlayerPos(playerid, Vehicles[SQLVid][vPosX], Vehicles[SQLVid][vPosY], Vehicles[SQLVid][vPosZ]+2);
					SetTimerEx("Velocity", 75, 0, "ifff", playerid, oX, oY, oZ);
					ApplyAnimation(playerid, "CRACK", "crckdeth2", 4.0, 1, 1, 1, 1, 1);
					new Float:health;
					GetPlayerHealth(playerid, health);
					health = health - damage/10;
					SetPlayerHealth(playerid, health);
				}
				else
				{
					SendEmote(playerid, LANG_CRASH_SEATBELT);
					new Float:health;
					GetPlayerHealth(playerid, health);
					health = health - damage/25;
					SetPlayerHealth(playerid, health);
					TogglePlayerControllableEx(playerid, 0, 5000);
				}
			}
		}
	}
}

/*
*    ALS Silent Include
*/

public OnGameModeExit()
{
	SaveAllVehicles(true);
	
    if (funcidx("phV_OnGameModeExit") != -1)
    {
        return CallLocalFunction("phV_OnGameModeExit", "");
    }
    return 1;
}

#if defined _ALS_OnGameModeExit
    #undef OnGameModeExit
#else
    #define _ALS_OnGameModeExit
#endif
#define OnGameModeExit phV_OnGameModeExit

// EOF
