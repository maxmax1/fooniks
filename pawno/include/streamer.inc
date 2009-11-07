/*
    SA-MP Streamer Plugin v2.1
    Copyright © 2009 Incognito

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#if defined _streamer_included
	#endinput
#endif
#define _streamer_included
#pragma library streamer

// Natives (settings)

native Streamer_TickRate(rate);
native Streamer_MaxObjects(objects);
native Streamer_MaxPickups(pickups);
native Streamer_MaxCPs(checkpoints);
native Streamer_MaxRaceCPs(checkpoints);
native Streamer_MaxMapIcons(icons);
native Streamer_Max3DTextLabels(labels);
native Streamer_VisibleObjects(objects);
native Streamer_VisiblePickups(pickups);
native Streamer_VisibleMapIcons(icons);
native Streamer_Visible3DTextLabels(labels);

// Natives (updates)

native Streamer_UpdateObjects(playerid);
native Streamer_UpdatePickups();
native Streamer_UpdateCPs(playerid);
native Streamer_UpdateRaceCPs(playerid);
native Streamer_UpdateMapIcons(playerid);
native Streamer_Update3DTextLabels(playerid);

// Natives (objects)

native CreateDynamicObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, worldid = -1, interiorid = -1, playerid = -1, Float:distance = 200.0);
native DestroyDynamicObject(objectid);
native SetDynamicObjectPos(objectid, Float:x, Float:y, Float:z);
native GetDynamicObjectPos(objectid, &Float:x, &Float:y, &Float:z);
native SetDynamicObjectRot(objectid, Float:rx, Float:ry, Float:rz);
native GetDynamicObjectRot(objectid, &Float:rx, &Float:ry, &Float:rz);
native IsValidDynamicObject(objectid);
native MoveDynamicObject(objectid, Float:x, Float:y, Float:z, Float:speed);
native StopDynamicObject(objectid);
native DestroyAllDynamicObjects();
native CountDynamicObjects();

// Natives (pickups)

native CreateDynamicPickup(modelid, type, Float:x, Float:y, Float:z, worldid = -1, interiorid = -1, playerid = -1, Float:distance = 50.0);
native DestroyDynamicPickup(pickupid);
native DestroyAllDynamicPickups();
native CountDynamicPickups();

// Natives (checkpoints)

native CreateDynamicCP(Float:x, Float:y, Float:z, Float:size, worldid = -1, interiorid = -1, playerid = -1, Float:distance = 50.0);
native DestroyDynamicCP(checkpointid);
native TogglePlayerDynamicCP(playerid, checkpointid, toggle);
native IsPlayerInDynamicCP(playerid, checkpointid);
native DestroyAllDynamicCPs();
native CountDynamicCPs();

// Natives (race checkpoints)

native CreateDynamicRaceCP(type, Float:x, Float:y, Float:z, Float:nextx, Float:nexty, Float:nextz, Float:size, worldid = -1, interiorid = -1, playerid = -1, Float:distance = 50.0);
native DestroyDynamicRaceCP(checkpointid);
native TogglePlayerDynamicRaceCP(playerid, checkpointid, toggle);
native IsPlayerInDynamicRaceCP(playerid, checkpointid);
native DestroyAllDynamicRaceCPs();
native CountDynamicRaceCPs();

// Natives (map icons)

native CreateDynamicMapIcon(Float:x, Float:y, Float:z, markertype, color, worldid = -1, interiorid = -1, playerid = -1, Float:distance = 100.0);
native DestroyDynamicMapIcon(iconid);
native DestroyAllDynamicMapIcons();
native CountDynamicMapIcons();

// Natives (3D text labels)

native Text3D:CreateDynamic3DTextLabel(text[], color, Float:x, Float:y, Float:z, Float:drawdistance, attachedplayer = INVALID_PLAYER_ID, attachedvehicle = INVALID_VEHICLE_ID, testlos = 0, worldid = -1, interiorid = -1, playerid = -1, Float:distance = 100.0);
native DestroyDynamic3DTextLabel(Text3D:id);
native UpdateDynamic3DTextLabelText(Text3D:id, color, text[]);
native DestroyAllDynamic3DTextLabels();
native CountDynamic3DTextLabels();

// Natives (internals)

native Streamer_IndexPlayer(playerid);
native Streamer_DeindexPlayer(playerid);
native Streamer_CheckPickup(playerid, pickupid);
native Streamer_RegisterGameMode();

// Callbacks

forward OnDynamicObjectMoved(objectid);
forward OnPlayerPickUpDynamicPickup(playerid, pickupid);
forward OnPlayerEnterDynamicCP(playerid, checkpointid);
forward OnPlayerLeaveDynamicCP(playerid, checkpointid);
forward OnPlayerEnterDynamicRaceCP(playerid, checkpointid);
forward OnPlayerLeaveDynamicRaceCP(playerid, checkpointid);

// Automatic setup system
// Utilizes callback hooks

static
	bool:Streamer_g_OPC = false,
	bool:Streamer_g_OPDC = false,
	bool:Streamer_g_OPPP = false;

public OnGameModeInit()
{
	Streamer_g_OPC = funcidx("Streamer_OnPlayerConnect") != -1;
	Streamer_g_OPDC = funcidx("Streamer_OnPlayerDisconnect") != -1;
	Streamer_g_OPPP = funcidx("Streamer_OnPlayerPickUpPickup") != -1;
	Streamer_RegisterGameMode();
	if (funcidx("Streamer_OnGameModeInit") != -1)
	{
		return CallLocalFunction("Streamer_OnGameModeInit", "");
	}
	return 1;
}

#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif
#define OnGameModeInit Streamer_OnGameModeInit
forward Streamer_OnGameModeInit();

public OnPlayerConnect(playerid)
{
	Streamer_IndexPlayer(playerid);
	if (Streamer_g_OPC)
	{
		return CallLocalFunction("Streamer_OnPlayerConnect", "d", playerid);
	}
	return 1;
}

#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect Streamer_OnPlayerConnect
forward Streamer_OnPlayerConnect(playerid);

public OnPlayerDisconnect(playerid, reason)
{
	Streamer_DeindexPlayer(playerid);
	if (Streamer_g_OPDC)
	{
		return CallLocalFunction("Streamer_OnPlayerDisconnect", "dd", playerid, reason);
	}
	return 1;
}

#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect Streamer_OnPlayerDisconnect
forward Streamer_OnPlayerDisconnect(playerid, reason);

public OnPlayerPickUpPickup(playerid, pickupid)
{
	Streamer_CheckPickup(playerid, pickupid);
	if (Streamer_g_OPPP)
	{
		return CallLocalFunction("Streamer_OnPlayerPickUpPickup", "dd", playerid, pickupid);
	}
	return 1;
}

#if defined _ALS_OnPlayerPickUpPickup
	#undef OnPlayerPickUpPickup
#else
	#define _ALS_OnPlayerPickUpPickup
#endif
#define OnPlayerPickUpPickup Streamer_OnPlayerPickUpPickup
forward Streamer_OnPlayerPickUpPickup(playerid, pickupid);

// Function that contains natives used by the streamer
// Necessary in order to invoke PAWN in the plugin

forward InvokePAWNFunction();
public InvokePAWNFunction()
{
	new
		Float:value;
	GetPlayerPos(0, value, value, value);
	GetPlayerInterior(0);
	GetPlayerVirtualWorld(0);
	CreatePlayerObject(0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
	SetPlayerObjectPos(0, 0, 0.0, 0.0, 0.0);
	GetPlayerObjectPos(0, 0, value, value, value);
	SetPlayerObjectRot(0, 0, 0.0, 0.0, 0.0);
	GetPlayerObjectRot(0, 0, value, value, value);
	DestroyPlayerObject(0, 0);
	MovePlayerObject(0, 0, 0.0, 0.0, 0.0, 0.0);
	StopPlayerObject(0, 0);
	CreatePickup(0, 0, 0.0, 0.0, 0.0, 0);
	DestroyPickup(0);
	SetPlayerCheckpoint(0, 0.0, 0.0, 0.0, 0.0);
	DisablePlayerCheckpoint(0);
	SetPlayerRaceCheckpoint(0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
	DisablePlayerRaceCheckpoint(0);
	SetPlayerMapIcon(0, 0, 0.0, 0.0, 0.0, 0, 0);
	RemovePlayerMapIcon(0, 0);
	CreatePlayer3DTextLabel(0, "", 0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0);
	DeletePlayer3DTextLabel(0, PlayerText3D:0);
	UpdatePlayer3DTextLabelText(0, PlayerText3D:0, 0, "");
	return 1;
}

// Public functions that wrap a few natives with float parameters
// Required only for Linux (resolves an issue with invoking PAWN)

forward Streamer_CreateObject(playerid, modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz);
public Streamer_CreateObject(playerid, modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	return CreatePlayerObject(playerid, modelid, x, y, z, rx, ry, rz);
}

forward Streamer_SetObjectPos(playerid, objectid, Float:x, Float:y, Float:z);
public Streamer_SetObjectPos(playerid, objectid, Float:x, Float:y, Float:z)
{
	return SetPlayerObjectPos(playerid, objectid, x, y, z);
}

forward Streamer_SetObjectRot(playerid, objectid, Float:rx, Float:ry, Float:rz);
public Streamer_SetObjectRot(playerid, objectid, Float:rx, Float:ry, Float:rz)
{
	return SetPlayerObjectRot(playerid, objectid, rx, ry, rz);	
}

forward Streamer_MoveObject(playerid, objectid, Float:x, Float:y, Float:z, Float:speed);
public Streamer_MoveObject(playerid, objectid, Float:x, Float:y, Float:z, Float:speed)
{
	return MovePlayerObject(playerid, objectid, x, y, z, speed);
}

forward Streamer_CreatePickup(model, type, Float:x, Float:y, Float:z, worldid);
public Streamer_CreatePickup(model, type, Float:x, Float:y, Float:z, worldid)
{
	return CreatePickup(model, type, x, y, z, worldid);
}

forward Streamer_CreateCP(playerid, Float:x, Float:y, Float:z, Float:size);
public Streamer_CreateCP(playerid, Float:x, Float:y, Float:z, Float:size)
{
	return SetPlayerCheckpoint(playerid, x, y, z, size);
}

forward Streamer_CreateRaceCP(playerid, type, Float:x, Float:y, Float:z, Float:nextx, Float:nexty, Float:nextz, Float:size);
public Streamer_CreateRaceCP(playerid, type, Float:x, Float:y, Float:z, Float:nextx, Float:nexty, Float:nextz, Float:size)
{
	return SetPlayerRaceCheckpoint(playerid, type, x, y, z, nextx, nexty, nextz, size);
}

forward Streamer_CreateMapIcon(playerid, iconid, Float:x, Float:y, Float:z, markertype, color);
public Streamer_CreateMapIcon(playerid, iconid, Float:x, Float:y, Float:z, markertype, color)
{
	return SetPlayerMapIcon(playerid, iconid, x, y, z, markertype, color);
}

forward PlayerText3D:Streamer_Create3DTextLabel(playerid, text[], color, Float:x, Float:y, Float:z, Float:drawdistance, attachedplayer, attachedvehicle, testlos);
public PlayerText3D:Streamer_Create3DTextLabel(playerid, text[], color, Float:x, Float:y, Float:z, Float:drawdistance, attachedplayer, attachedvehicle, testlos)
{
	return CreatePlayer3DTextLabel(playerid, text, color, x, y, z, drawdistance, attachedplayer, attachedvehicle, testlos);
}
