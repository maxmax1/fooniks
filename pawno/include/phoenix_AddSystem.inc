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
*    This File: phoenix_AddSystem.inc
*    Purpose: Create a add system.
*/

/*
*    DEFINES
*/

#define MAX_ADDBOARDS 31

#define ADD_COLOR1 0x33AA33FF
#define ADD_COLOR2 0xFFFF00FF
#define ADD_COLOR3 0xAA3333FF
#define ADD_COLOR4 0x0000FFFF

/*
*    GLOBALS
*/

new Text3D: gAddBoards[MAX_ADDBOARDS] = {Text3D: -1, ...};
new bool: gAddBoardText[MAX_ADDBOARDS];
new gAddBoardTexts[MAX_ADDBOARDS][128];
new Float: gAddBoardPos[MAX_ADDBOARDS][3];

new gAddBoardNR[MAX_ADDBOARDS];
new gAddBoardTime[MAX_ADDBOARDS];
new gAddBoardTimeS[MAX_ADDBOARDS];
new gAddBoardCol[MAX_ADDBOARDS];

Itter_Create(AddBoards, MAX_ADDBOARDS);

/*
*    FORWARDS
*/

forward CreateAddboard(Float: x, Float: y, Float: z);
forward NewBoardAdd(freeId, col, number, text[], time);
forward ClearAddBoard(addBoardId);

forward LoadAddBoards();
forward SaveAddBoards();
forward SaveAddBoard(boardId, boardUsed, boardTime);

forward Add_OnGameModeInit();
forward Add_OnGameModeExit();

/*
*    PUBLICS
*/

public CreateAddboard(Float: x, Float: y, Float: z)
{
	new freeId = Itter_Free(AddBoards);
	if(freeId == -1) return 0;	
	
	gAddBoards[freeId] = CreateDynamic3DTextLabel("Sinu Reklaam siia!\n(( /reklaam ))", ADD_COLOR1, x, y, z+1.0, 30.0);
	Itter_Add(AddBoards, freeId);
	
	gAddBoardPos[freeId][0] = x;
	gAddBoardPos[freeId][1] = y;
	gAddBoardPos[freeId][2] = z;
	return 1;
}

stock CloseToAddBoard(playerid)
{
	new freeId = -1;	
	foreach(AddBoards, i)
	{
		if(IsPlayerInRangeOfPoint(playerid, 10.0, gAddBoardPos[i][0], gAddBoardPos[i][1], gAddBoardPos[i][2]))
		{
			freeId = i;
			break;
		}
	}
	return freeId;
}

public NewBoardAdd(freeId, col, number, text[], time)
{
	if(freeId == -1 || gAddBoards[freeId] == Text3D: -1) return 1;
	if(gAddBoardText[freeId]) return 2;
	
	gAddBoardText[freeId] = true;
	gAddBoardNR[freeId] = number;
	format(gAddBoardTexts[freeId], 128, "%s", text);
	format(text, 128, "%s\n\n%d", gAddBoardTexts[freeId], number);
	
	new color = ADD_COLOR1;
	if(col == 1) color = ADD_COLOR2;
	else if(col == 2) color = ADD_COLOR3;
	else if(col == 3) color = ADD_COLOR4;	
	
	UpdateDynamic3DTextLabelText(gAddBoards[freeId], color, text);
	
	gAddBoardTime[freeId] = ((time > 0)?time:15*60*1000);
	gAddBoardTimeS[freeId] = GetTickCount();	
	gAddBoardCol[freeId] = col;
	
	SetTimerEx("ClearAddBoard", ((time > 0)?time:15*60*1000), 0, "i", freeId);
	
	return 0;
}

public ClearAddBoard(addBoardId)
{
	if(addBoardId < 0 || addBoardId >= MAX_ADDBOARDS) return 0;
	if(gAddBoards[addBoardId] == Text3D: -1) return 0;
	
	UpdateDynamic3DTextLabelText(gAddBoards[addBoardId], ADD_COLOR1, "Sinu Reklaam siia!\n(( /reklaam ))");
	gAddBoardText[addBoardId] = false;
	gAddBoardCol[addBoardId] = 0;
	gAddBoardNR[addBoardId] = 0;
	format(gAddBoardTexts[addBoardId], 128, "Sinu Reklaam siia!\n(( /reklaam ))");
	
	SaveAddBoard(addBoardId, 0, 90000);
	return 1;
}

public LoadAddBoards()
{
	new Field[128];
	format(Field, 64, "SELECT * FROM %sAddBoards ORDER BY boardId ASC LIMIT %d", MYSQL_PREFIX, MAX_ADDBOARDS-1);
	
	mysql_query(Field);
	mysql_store_result();
	
	new Data[512], numRows = mysql_num_rows();
	for(new nId = 0; nId < numRows; nId++)
	{
		if(!mysql_fetch_row_format(Data, " ")) continue;
		
		mysql_fetch_field_row(Field, "boardUsed");
		if(strval(Field) == 0) continue;
		
		mysql_fetch_field_row(Field, "boardId");
		new id = strval(Field);
		
		mysql_fetch_field_row(Field, "boardColor");
		new col = strval(Field);
		
		mysql_fetch_field_row(Field, "boardTime");
		new time = strval(Field);
		
		mysql_fetch_field_row(Field, "boardNr");
		new nr = strval(Field);
		
		mysql_fetch_field_row(Field, "boardText");		
		NewBoardAdd(id-1, col, nr, Field, time);
	}
}

public SaveAddBoards()
{
	foreach(AddBoards, i)
	{
		if(gAddBoardText[i])
		{
			new tLeft = gAddBoardTime[i] - (GetTickCount() - gAddBoardTimeS[i]);
			if(tLeft < 1000) continue;
			SaveAddBoard(i, 1, tLeft);
		}
	}
}

public SaveAddBoard(boardId, boardUsed, boardTime)
{
	new query[MAX_QUERY], table[32];
	format(table, 32, "%sAddBoards", MYSQL_PREFIX);

	MysqlUpdateBuild(query, table);
	MysqlUpdateInt(query, "boardColor", gAddBoardCol[boardId]);
	MysqlUpdateInt(query, "boardTime", boardTime);
	MysqlUpdateStr(query, "boardText", gAddBoardTexts[boardId]);
	MysqlUpdateInt(query, "boardUsed", boardUsed);
	MysqlUpdateInt(query, "boardNr", gAddBoardNR[boardId]);

	MysqlUpdateFinish(query, "boardId", boardId+1);
}

/*
*    COMMANDS
*/

COMMAND:reklaam(playerid, params[])
{
	new l, col, str[90];
	if(sscanf(params, "iis", l, col, str))
	{
		SendClientMessage(playerid, COLOR_YELLOW, "KASUTUS: /reklaam telefoniNR värviKood tekst");
		return SendClientMessage(playerid, COLOR_YELLOW, "VärviKoodid: 0 - Roheline, 1 - Kollane, 2 - Punane, 3 - Sinine");
	}
		
	new freeId = CloseToAddBoard(playerid);	
	new ret = NewBoardAdd(freeId, col, l, str, -1);
	
	if(ret == 0) SendClientMessage(playerid, COLOR_GREEN, "Reklaam üles seatud!");
	else if(ret == 2) SendClientMessage(playerid, COLOR_YELLOW, "See reklaam on hetkel kinni!");
	else SendClientMessage(playerid, COLOR_RED, "Sa pole ühegi reklaamtahvli läheduses.");
	
	return 1;
}

/*
*    ALS
*/

public OnGameModeInit()
{
	CreateAddboard(2405.0647, -1229.3162, 23.4084); 
	CreateAddboard(2361.9260, -1337.7264, 23.5846); 
	CreateAddboard(2408.2507, -1454.4087, 23.5806); 
	CreateAddboard(2438.8340, -1484.0712, 23.5741); 
	CreateAddboard(2481.9121, -1539.6898, 23.6897); 
	CreateAddboard(2568.2651, -1457.6340, 23.5967); 
	CreateAddboard(2634.0801, -1381.3911, 30.0032); 
	CreateAddboard(2690.9580, -1489.5188, 30.1684); 
	CreateAddboard(2714.1350, -1456.9910, 30.0792); 
	CreateAddboard(2699.9019, -1139.5435, 71.3599);
	CreateAddboard(2084.0554, -972.1322, 50.3594); 
	CreateAddboard(1419.0139, -966.5059, 37.0510); 
	CreateAddboard(1310.9161, -898.4438, 39.1549); 
	CreateAddboard(1203.5463, -920.1927, 42.6648); 
	CreateAddboard(1106.1940, -923.8296, 42.9598); 
	CreateAddboard(1000.8124, -926.4086, 41.8756); 
	CreateAddboard(363.1519, -1355.9850, 14.1006); 
	CreateAddboard(148.5969, -1950.8474, 3.3537); 
	CreateAddboard(379.0499, -2060.8857, 7.4150); 
	CreateAddboard(482.7443, -1733.3594, 10.5959); 
	CreateAddboard(1070.5614, -1880.9642, 13.1227); 
	CreateAddboard(1236.8879, -1859.8301, 13.1151); 
	CreateAddboard(1348.6663, -1757.8407, 13.0883); 
	CreateAddboard(1737.2230, -1862.9480, 13.1351); 
	CreateAddboard(1832.3739, -1848.0690, 13.1568); 
	CreateAddboard(2072.1853, -1789.8707, 13.1048); 
	CreateAddboard(2149.6982, -1743.0437, 13.1285); 
	CreateAddboard(2428.1572, -1741.7167, 13.1752); 
	CreateAddboard(2467.6936, -1922.8610, 13.1299); 
	CreateAddboard(2394.8052, -1899.1581, 13.1215); 
	
	LoadAddBoards();
	
    if (funcidx("Add_OnGameModeInit") != -1)
    {
        return CallLocalFunction("Add_OnGameModeInit", "");
    }
    return 1;
}


#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit Add_OnGameModeInit

public OnGameModeExit()
{
	SaveAddBoards();
	
    if (funcidx("Add_OnGameModeExit") != -1)
    {
        return CallLocalFunction("Add_OnGameModeExit", "");
    }
    return 1;
}


#if defined _ALS_OnGameModeExit
    #undef OnGameModeExit
#else
    #define _ALS_OnGameModeExit
#endif
#define OnGameModeExit Add_OnGameModeExit

// EOF