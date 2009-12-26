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
*    This File: phoenix_DropItems.inc
*    Purpose: Add item droping to inventory system.
*
*/

#if !defined _phoenix_included
	#error "Phoenix ERROR #1, You need phoenix base for this gamemode to run!"
	#endinput
#endif

#if !defined MAX_POCKETS
	#error "DropItems ERROR, You need inventory system!"
	#endinput
#endif

/*
*    DEFINES
*/

#define COLOR_DROP 0x33AA33FF
#define MAX_DROPITEMS 300

#define DROP_RANGE 25.0
#define DROP_PICKUP_RANGE 5.0
#define DROP_OBJECT 1210

/*
*    GLOBALS
*/

enum dropInf
{
	Float: dropPosX,
	Float: dropPosY,
	Float: dropPosZ,
	dItemType,
	dItemData,
	dropObj,
	dropInt,
	dropVW,
	Text3D: dropTxt,
	sqlId
}
new gDropItems[MAX_DROPITEMS][dropInf];
Itter_Create(DropItem, MAX_DROPITEMS);

new gDropHas_OPKSC;

/*
*    STOCKS
*/

stock getClosestDropItem(playerid)
{
	new Float: x, Float: y, Float: z, Float: dist = DROP_PICKUP_RANGE, foundId = -1;
	GetPlayerPos(playerid, x, y, z);
	
	foreach(DropItem, i)
	{
		new Float: tDist = DistanceCheck(x, y, z, gDropItems[i][dropPosX], gDropItems[i][dropPosY], gDropItems[i][dropPosZ]);
		if(tDist < dist)
		{
			foundId = i;
			dist = tDist;
		}
	}
	return foundId;
}

/*
*    FORWARDS
*/

forward AddDropItem(type, data, Float: posX, Float: posY, Float: posZ, interior, virworld, dropSqlId);
forward DestroyDropItem(itemid);
forward LoadDropItems();
forward SaveDropItems();
forward Drop(playerid, type, data);

forward DROP_OnGameModeInit();
forward DROP_OnGameModeExit();
forward DROP_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);

/*
*    PUBLICS
*/

public AddDropItem(type, data, Float: posX, Float: posY, Float: posZ, interior, virworld, dropSqlId)
{
	if(type < 1) return -1;
	
	new freeId = Itter_Free(DropItem);
	if(freeId == -1) return -1;
	
	gDropItems[freeId][dItemData] = data;
	gDropItems[freeId][dItemType] = type;
	
	gDropItems[freeId][dropPosX] = posX;
	gDropItems[freeId][dropPosY] = posY;
	gDropItems[freeId][dropPosZ] = posZ;
	gDropItems[freeId][dropInt] = interior;
	gDropItems[freeId][dropVW] = virworld;
	
	gDropItems[freeId][sqlId] = (dropSqlId > 0)?dropSqlId:gDropItems[freeId][sqlId];
	
	new string[128];
	format(string, 128, "Ese: %s\nData: %d\n(( Vajuta ligidal olles\n KEY_WALK+KEY_SPRINT,\n et üles korjata. ))",
		Items[type][itemName],
		data
	);
	
	gDropItems[freeId][dropObj] = CreateDynamicObject(DROP_OBJECT, posX, posY, posZ, 0.0, 0.0, 0.0, virworld, interior, -1, DROP_RANGE+10.0);
	gDropItems[freeId][dropTxt] = CreateDynamic3DTextLabel(string, COLOR_DROP, posX, posY, posZ, DROP_RANGE, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, virworld, interior, -1, DROP_RANGE+10.0);
	Itter_Add(DropItem, freeId);
	return freeId;
}

public DestroyDropItem(itemid)
{
	if(itemid < 0 || itemid >= MAX_DROPITEMS) return 1;
	
	DestroyDynamicObject(gDropItems[itemid][dropObj]);
	DestroyDynamic3DTextLabel(gDropItems[itemid][dropTxt]);
	
	Itter_Remove(DropItem, itemid);
	
	if(gDropItems[itemid][sqlId] > 0)
	{
		new query[MAX_QUERY];
		format(query, MAX_QUERY, "DELETE FROM `%sDropItems` WHERE `id` = '%d' LIMIT 1;", MYSQL_PREFIX, gDropItems[itemid][sqlId]);
		mysql_query(query);
	}	
	
	gDropItems[itemid][sqlId] = 0;
	return 0;
}

public LoadDropItems()
{
	new string[128];
	format(string, 128, "SELECT * FROM %sDropItems ORDER BY id ASC LIMIT %d", MYSQL_PREFIX, MAX_DROPITEMS-1);
	
	mysql_query(string);
	mysql_store_result();
	
	new Field[64], Data[256], numRows = mysql_num_rows();
	for(new nId = 0; nId < numRows; nId++)
	{
		if(!mysql_fetch_row_format(Data, " ")) continue;
		
		mysql_fetch_field_row(Field, "id");
		new id = strval(Field);
		
		mysql_fetch_field_row(Field, "dItemType");
		new type = strval(Field);
		
		mysql_fetch_field_row(Field, "dItemData");
		new data = strval(Field);
		
		mysql_fetch_field_row(Field, "dropPosX");
		new Float: x = floatstr(Field);
		mysql_fetch_field_row(Field, "dropPosY");
		new Float: y = floatstr(Field);
		mysql_fetch_field_row(Field, "dropPosZ");
		new Float: z = floatstr(Field);
		
		mysql_fetch_field_row(Field, "dropInterior");
		new int = strval(Field);
		
		mysql_fetch_field_row(Field, "dropVW");
		new vw = strval(Field);
		
		AddDropItem(type, data, x, y, z, int, vw, id);
	}
}

public SaveDropItems()
{
	foreach(DropItem, i)
	{
		if(gDropItems[i][sqlId] > 0)
		{
			new sqlid = gDropItems[i][sqlId];
			new query[MAX_QUERY], table[32];
			format(table, 32, "%sDropItems", MYSQL_PREFIX);
			
			MysqlUpdateBuild(query, table);
			
			MysqlUpdateInt(query, "dItemType", gDropItems[i][dItemType]);
			MysqlUpdateInt(query, "dItemData", gDropItems[i][dItemData]);
			MysqlUpdateFlo(query, "dropPosX", gDropItems[i][dropPosX]);
			MysqlUpdateFlo(query, "dropPosY", gDropItems[i][dropPosY]);
			MysqlUpdateFlo(query, "dropPosZ", gDropItems[i][dropPosZ]);
			MysqlUpdateInt(query, "dropInterior", gDropItems[i][dropInt]);
			MysqlUpdateInt(query, "dropVW", gDropItems[i][dropVW]);
			
			MysqlUpdateFinish(query, "id", sqlid);	
		}
		else
		{
			// Insert
			new string[MAX_QUERY];
			format(string, MAX_QUERY, "INSERT INTO %sDropItems(id, dItemType, dItemData, dropPosX, dropPosY, dropPosZ, dropInterior, dropVW) VALUES(NULL, '%d', '%d', '%f', '%f', '%f', '%d', '%d')",
				MYSQL_PREFIX,
				gDropItems[i][dItemType],
				gDropItems[i][dItemData],
				gDropItems[i][dropPosX],
				gDropItems[i][dropPosY],
				gDropItems[i][dropPosZ],
				gDropItems[i][dropInt],
				gDropItems[i][dropVW]);
			mysql_query(string);
			gDropItems[i][sqlId] = mysql_insert_id();
		}
	}
}

public Drop(playerid, type, data)
{
	if(type < 1 || type >= MAX_ITEMS) return false;
	
	new Float: x, Float: y, Float: z, vw, int;
	GetPlayerPos(playerid, x, y, z);
	
	int = GetPlayerInterior(playerid);
	vw = GetPlayerVirtualWorld(playerid);
	
	return (AddDropItem(type, data, x,y, z, int, vw, 0) != -1);
}

/*
*    ALS
*/

public OnGameModeInit()
{
	LoadDropItems();

	gDropHas_OPKSC = funcidx("DROP_OnPlayerKeyStateChange");
	
	if (funcidx("DROP_OnGameModeInit") != -1)
    {
        return CallLocalFunction("DROP_OnGameModeInit", "");
    }
    return 1;
}

public OnGameModeExit()
{
	SaveDropItems();

	if (funcidx("DROP_OnGameModeExit") != -1)
    {
        return CallLocalFunction("DROP_OnGameModeExit", "");
    }
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(PRESSED(KEY_WALK | KEY_SPRINT)) 
	{
		new spot = getClosestDropItem(playerid);
		if(spot != -1)
		{
			new given = giveItem(playerid, gDropItems[spot][dItemType], gDropItems[spot][dItemData]);
			if(given == 0)
			{
				SendEmote(playerid, "võtab mingi asja üles.");
				DestroyDropItem(spot);
			}
			else if(given != gDropItems[spot][dItemData])
			{
				gDropItems[spot][dItemData] -= given;
				SendEmote(playerid, "sorib kohvris ja võtab sealt midagi.");
				
				new string[128];
				format(string, 128, "Ese: %s\nData: %d\n(( Vajuta ligidal olles\n KEY_WALK+KEY_SPRINT,\n et üles korjata. ))",
					Items[gDropItems[spot][dItemType]][itemName],
					gDropItems[spot][dItemData]
				);
				UpdateDynamic3DTextLabelText(gDropItems[spot][dropTxt], COLOR_DROP, string);			
			}
			else
			{
				SendClientMessage(playerid, COLOR_RED, "Sa ei saa seda asja hetkel üles võtta.");
			}			
		}
	}

	if (gDropHas_OPKSC != -1)
    {
        return CallLocalFunction("DROP_OnPlayerKeyStateChange", "iii", playerid, newkeys, oldkeys);
    }
    return 1;
}

#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit DROP_OnGameModeInit

#if defined _ALS_OnGameModeExit
    #undef OnGameModeExit
#else
    #define _ALS_OnGameModeExit
#endif
#define OnGameModeExit DROP_OnGameModeExit

#if defined _ALS_OnPlayerKeyStateChange
    #undef OnPlayerKeyStateChange
#else
    #define _ALS_OnPlayerKeyStateChange
#endif
#define OnPlayerKeyStateChange DROP_OnPlayerKeyStateChange

// EOF