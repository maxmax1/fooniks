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
*    This File: phoenix_NewsPaper.inc
*    Purpose: Create a good-looking newspaper.
*/

#if !defined _phoenix_included
	#error "Phoenix ERROR #1, You need phoenix base for this gamemode to run!"
	#endinput
#endif

/*
	STAT Calculating querys: 
		stat1 = 
			SELECT SUM( money )  FROM `ph_characters`
		stat2 = 
			SELECT COUNT( * )  FROM `ph_characters`  WHERE UNIX_TIMESTAMP( ) - UNIX_TIMESTAMP( `regDate` ) < 86400
		stat3 = 
			SELECT id FROM `ph_characters`  ORDER BY UNIX_TIMESTAMP( regDate ) ASC LIMIT 1
		stat4 = 
		
*/

#define NEWSPAPERBACK 0x000000AA

#define FRONT_PAGE 0

#define MAX_NEWSPAPERS 3

new paperActive[MAX_PLAYERS];
new paperDrawActive[MAX_PLAYERS];
new currentPage[MAX_PLAYERS];

enum newsDrawInf
{
	Text: Text0,
	Text: Text1,
	Text: Text2,
	Text: Text3,
	Text: Text4,
	Text: Text5,
	Text: Text6,
	bool: used,
	textId
};
new NewsDraw[50][newsDrawInf];

enum newsInf
{
	headLine[32],
	article1[256],
	article2[256],
	article3[256],
	article4[256],
	stat1,
	stat2,
	stat3,
	stat4,
	add1[256],
	add2[256],
	add3[256],
	add4[256],
	bool: paperUsed,
	sqlId
};
new NewsPapers[MAX_NEWSPAPERS][newsInf];

forward ShowNewsPaper(playerid, paperid);
forward HideNewsPaper(playerid, page);
forward CreatePaperDraw(paperid);
forward LoadNewsPapers();

forward NewsPaper_OnGameModeInit();
forward NP_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
forward NP_OnPlayerConnect(playerid);
forward NP_OnPlayerDisconnect(playerid);
 
public ShowNewsPaper(playerid, paperid)
{
	if(paperid < 0 || paperid > MAX_NEWSPAPERS) return 1;
	if(!NewsPapers[paperid][paperUsed]) return 2;
	
	if(paperDrawActive[playerid] > -1)
	{
		HideNewsPaper(playerid, false);
	}
	else
	{
		// Just opened!
		SmallHelpDrawShow(playerid, "~b~Ajaleht.~n~~g~Liikumiseks kasuta: ~n~~<~ ~w~~k~~VEHICLE_TURRETLEFT~~n~~>~ ~w~~k~~VEHICLE_TURRETRIGHT~~n~~r~Sulgemiseks: ~n~~w~~k~~VEHICLE_ENTER_EXIT~", 10000);
	}
	
	new i = findFreePaperDraw();
	if(i != -1)
	{
		if(currentPage[playerid] < 0) currentPage[playerid] = 0;
		if(currentPage[playerid] > 3) currentPage[playerid] = 3;
		
		if(currentPage[playerid] == 0)
		{
			TextDrawSetString(NewsDraw[i][Text1], NewsPapers[paperid][headLine]);
			TextDrawSetString(NewsDraw[i][Text2], "1 / 4");
			
			TextDrawSetString(NewsDraw[i][Text3], NewsPapers[paperid][article1]);
			TextDrawSetString(NewsDraw[i][Text4], NewsPapers[paperid][article2]);
			TextDrawSetString(NewsDraw[i][Text5], NewsPapers[paperid][article3]);
			TextDrawSetString(NewsDraw[i][Text6], NewsPapers[paperid][article4]);
		}
		else if(currentPage[playerid] == 1)
		{
			TextDrawSetString(NewsDraw[i][Text1], "F88niks Numbrites");
			TextDrawSetString(NewsDraw[i][Text2], "2 / 4");
			
			new string[150];
			format(string, 150, "~b~Majandus~n~~n~~g~Sularaha: ~w~%d~n~~g~Pangas: ~w~x~n~~g~Kinnisvaraturul: ~w~x~n~~g~Autoturul: ~w~x~n~~g~Arimaailmas: ~w~x", NewsPapers[i][stat1]);
			TextDrawSetString(NewsDraw[i][Text3], string);

			format(string, 128, "~b~Sotsiaalelu~n~~n~~g~Syndide Arv: ~w~%d~n~~g~Vanim isik: ~w~%s", NewsPapers[i][stat2], GetCharacterName(NewsPapers[i][stat3]));
			TextDrawSetString(NewsDraw[i][Text4], string);

			format(string, 128, "~b~Kuritegevus~n~~n~M6rvu: x~n~Varguseid: x~n~2Randamisi: x~n~Trahvide arv: x");
			TextDrawSetString(NewsDraw[i][Text5], string);
			
			format(string, 100, "Infot vahendab Riigi Statistikaamet.~n~Kontaktisik: Martin_Mets~n~53934751~n~Linnavalitsus: ~n~113");
			TextDrawSetString(NewsDraw[i][Text6], string);
		}
		else if(currentPage[playerid] == 2)
		{
			TextDrawSetString(NewsDraw[i][Text1], "T88kuulutused");
			TextDrawSetString(NewsDraw[i][Text2], "3 / 4");
			
			TextDrawSetString(NewsDraw[i][Text3], " ");
			TextDrawSetString(NewsDraw[i][Text4], " ");
			TextDrawSetString(NewsDraw[i][Text5], " ");
			TextDrawSetString(NewsDraw[i][Text6], " ");
		}
		else if(currentPage[playerid] == 3)
		{
			TextDrawSetString(NewsDraw[i][Text1], "Kuulutused");
			TextDrawSetString(NewsDraw[i][Text2], "4 / 4");
			
			TextDrawSetString(NewsDraw[i][Text3], NewsPapers[paperid][add1]);
			TextDrawSetString(NewsDraw[i][Text4], NewsPapers[paperid][add2]);
			TextDrawSetString(NewsDraw[i][Text5], NewsPapers[paperid][add3]);
			TextDrawSetString(NewsDraw[i][Text6], NewsPapers[paperid][add4]);
		}
		
		TextDrawShowForPlayer(playerid, NewsDraw[i][Text0]); // Taust
		TextDrawShowForPlayer(playerid, NewsDraw[i][Text1]); // Pealkiri
		TextDrawShowForPlayer(playerid, NewsDraw[i][Text2]); // Lehenumber
		TextDrawShowForPlayer(playerid, NewsDraw[i][Text3]); // Block 1
		TextDrawShowForPlayer(playerid, NewsDraw[i][Text4]); // Block 2
		TextDrawShowForPlayer(playerid, NewsDraw[i][Text5]); // Block 3
		TextDrawShowForPlayer(playerid, NewsDraw[i][Text6]); // Block 4
		NewsDraw[i][used] = true;
		paperActive[playerid] = paperid;
		paperDrawActive[playerid] = i;
		TogglePlayerControllableEx(playerid, 0, -1);
		return 0;
	}
	return 4;
}

public HideNewsPaper(playerid, page)
{
	new i = paperDrawActive[playerid];
	if(i == -1) return 1;	
	TextDrawHideForPlayer(playerid, NewsDraw[i][Text0]); // Taust
	TextDrawHideForPlayer(playerid, NewsDraw[i][Text1]); // Pealkiri
	TextDrawHideForPlayer(playerid, NewsDraw[i][Text2]); // Lehenumber
	TextDrawHideForPlayer(playerid, NewsDraw[i][Text3]); // Block 1
	TextDrawHideForPlayer(playerid, NewsDraw[i][Text4]); // Block 2
	TextDrawHideForPlayer(playerid, NewsDraw[i][Text5]); // Block 3
	TextDrawHideForPlayer(playerid, NewsDraw[i][Text6]); // Block 4
	NewsDraw[i][used] = false;
	paperDrawActive[playerid] = -1;
	if(page) currentPage[playerid] = 0;
	TogglePlayerControllableEx(playerid, 1, -1);
	return 0;	
}

public CreatePaperDraw(paperid)
{
	NewsDraw[paperid][Text0] = TextDrawCreate(44, 86, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~");
	TextDrawUseBox(NewsDraw[paperid][Text0], 1);
	TextDrawBoxColor(NewsDraw[paperid][Text0], NEWSPAPERBACK);
	TextDrawFont(NewsDraw[paperid][Text0], 2);
	TextDrawTextSize(NewsDraw[paperid][Text0], 492, 308.0);
	
	NewsDraw[paperid][Text1] = TextDrawCreate(52, 90, " ");
	TextDrawFont(NewsDraw[paperid][Text1], 2);
	TextDrawLetterSize(NewsDraw[paperid][Text1], 0.499999, 1.300000);
	TextDrawSetProportional(NewsDraw[paperid][Text1], true);
	
	NewsDraw[paperid][Text2] = TextDrawCreate(452, 290.0, "1 / 4");
	TextDrawFont(NewsDraw[paperid][Text2], 2);
	TextDrawLetterSize(NewsDraw[paperid][Text2], 0.299999, 1.100000);
	TextDrawSetProportional(NewsDraw[paperid][Text2], true);	
	
	NewsDraw[paperid][Text3] = TextDrawCreate(72, 128, "~b~Lorem ipsum~n~~n~~w~Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt.");
	TextDrawTextSize(NewsDraw[paperid][Text3], 260, 300);
	TextDrawUseBox(NewsDraw[paperid][Text3], 1);
	TextDrawBoxColor(NewsDraw[paperid][Text3], NEWSPAPERBACK);	
	TextDrawFont(NewsDraw[paperid][Text3], 2);
	TextDrawLetterSize(NewsDraw[paperid][Text3], 0.199999, 0.900000);
	TextDrawSetProportional(NewsDraw[paperid][Text3], true);	
	
	NewsDraw[paperid][Text4] = TextDrawCreate(72, 210, "~b~Lorem ipsum~n~~n~~w~Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt.");
	TextDrawTextSize(NewsDraw[paperid][Text4], 260, 300);
	TextDrawUseBox(NewsDraw[paperid][Text4], 1);
	TextDrawBoxColor(NewsDraw[paperid][Text4], NEWSPAPERBACK);	
	TextDrawFont(NewsDraw[paperid][Text4], 2);
	TextDrawLetterSize(NewsDraw[paperid][Text4], 0.199999, 0.900000);
	TextDrawSetProportional(NewsDraw[paperid][Text4], true);	
	
	NewsDraw[paperid][Text5] = TextDrawCreate(270, 128, "~b~Lorem ipsum~n~~n~~w~Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt.");
	TextDrawTextSize(NewsDraw[paperid][Text5], 458, 300);
	TextDrawUseBox(NewsDraw[paperid][Text5], 1);
	TextDrawBoxColor(NewsDraw[paperid][Text5], NEWSPAPERBACK);	
	TextDrawFont(NewsDraw[paperid][Text5], 2);
	TextDrawLetterSize(NewsDraw[paperid][Text5], 0.199999, 0.900000);
	TextDrawSetProportional(NewsDraw[paperid][Text5], true);	
	
	NewsDraw[paperid][Text6] = TextDrawCreate(270, 210, "~b~Lorem ipsum~n~~n~~w~Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt.");
	TextDrawTextSize(NewsDraw[paperid][Text6], 458, 300);
	TextDrawUseBox(NewsDraw[paperid][Text6], 1);
	TextDrawBoxColor(NewsDraw[paperid][Text6], NEWSPAPERBACK);	
	TextDrawFont(NewsDraw[paperid][Text6], 2);
	TextDrawLetterSize(NewsDraw[paperid][Text6], 0.199999, 0.900000);
	TextDrawSetProportional(NewsDraw[paperid][Text6], true);
}

stock findFreePaperDraw()
{
	for(new i = 0; i < 50; i++)
	{
		if(!NewsDraw[i][used])
		{
			return i;
		}
	}
	return -1;
}

public LoadNewsPapers()
{
	new string[64];
	format(string, 64, "SELECT * FROM %sNewsPaper ORDER BY date DESC LIMIT %d", MYSQL_PREFIX, MAX_NEWSPAPERS-1);
	
	mysql_query(string);
	mysql_store_result();
	
	new Field[260], Data[1024], numRows = mysql_num_rows();
	for(new nId = 0; nId < numRows; nId++)
	{
		if(!mysql_fetch_row_format(Data, " ")) continue;
		
		mysql_fetch_field_row(Field, "id");
		NewsPapers[nId][sqlId] = strval(Field);
		
		mysql_fetch_field_row(Field, "headLine");
		format(NewsPapers[nId][headLine], 32, "%s", Field);
		
		mysql_fetch_field_row(Field, "Block1");
		format(NewsPapers[nId][article1], 256, "%s", Field);
		
		mysql_fetch_field_row(Field, "Block2");
		format(NewsPapers[nId][article2], 256, "%s", Field);
		
		mysql_fetch_field_row(Field, "Block3");
		format(NewsPapers[nId][article3], 256, "%s", Field);
		
		mysql_fetch_field_row(Field, "Block4");
		format(NewsPapers[nId][article4], 256, "%s", Field);
		
		mysql_fetch_field_row(Field, "Add1");
		format(NewsPapers[nId][add1], 256, "%s", Field);
		
		mysql_fetch_field_row(Field, "Add2");
		format(NewsPapers[nId][add2], 256, "%s", Field);
		
		mysql_fetch_field_row(Field, "Add3");
		format(NewsPapers[nId][add3], 256, "%s", Field);
		
		mysql_fetch_field_row(Field, "Add4");
		format(NewsPapers[nId][add4], 256, "%s", Field);
		
		mysql_fetch_field_row(Field, "stat1");
		NewsPapers[nId][stat1] = strval(Field);
		
		mysql_fetch_field_row(Field, "stat2");
		NewsPapers[nId][stat2] = strval(Field);
		
		mysql_fetch_field_row(Field, "stat3");
		NewsPapers[nId][stat3] = strval(Field);
		
		mysql_fetch_field_row(Field, "stat4");
		NewsPapers[nId][stat4] = strval(Field);
		
		#if defined PH_DEBUG
		printf("\n NewsStats: %d, %d, %d, %d, \n", NewsPapers[nId][stat1], NewsPapers[nId][stat2], NewsPapers[nId][stat3], NewsPapers[nId][stat4]);
		#endif
		
		NewsPapers[nId][paperUsed] = true;
	}
	mysql_free_result();
}

/*
*    Silent Implentation
*/

public OnGameModeInit()
{
	for(new i = 0; i < 50; i++)
	{
		CreatePaperDraw(i);
	}
	
	foreach(Player, i)
	{
		paperDrawActive[i] = -1;
	}
	
	LoadNewsPapers();
	
    if (funcidx("NewsPaper_OnGameModeInit") != -1)
    {
        return CallLocalFunction("NewsPaper_OnGameModeInit", "");
    }
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(paperActive[playerid] > -1)
	{
		if(PRESSED(KEY_ANALOG_LEFT)) currentPage[playerid]--;
		else if(PRESSED(KEY_ANALOG_RIGHT)) currentPage[playerid]++;
		else if(PRESSED(KEY_SECONDARY_ATTACK))
		{
			HideNewsPaper(playerid, true);
			goto wrong_key;
		}
		else
		{
			goto wrong_key;
		}
		currentPage[playerid] = (currentPage[playerid] > 3)?0:currentPage[playerid];
		currentPage[playerid] = (currentPage[playerid] < 0)?3:currentPage[playerid];
		ShowNewsPaper(playerid, paperActive[playerid]);
	}
	wrong_key:
    if (funcidx("NP_OnPlayerKeyStateChange") != -1)
    {
        return CallLocalFunction("NP_OnPlayerKeyStateChange", "iii", playerid, newkeys, oldkeys);
    }
    return 1;
}


public OnPlayerConnect(playerid)
{
	HideNewsPaper(playerid, true);
	paperActive[playerid] = -1;
	
    if (funcidx("NP_OnPlayerConnect") != -1)
    {
        return CallLocalFunction("NP_OnPlayerConnect", "i", playerid);
    }
    return 1;
}

public OnPlayerDisconnect(playerid)
{
	HideNewsPaper(playerid, true);
	paperActive[playerid] = -1;
	
    if (funcidx("NP_OnPlayerDisconnect") != -1)
    {
        return CallLocalFunction("NP_OnPlayerDisconnect", "i", playerid);
    }
    return 1;
}

#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit NewsPaper_OnGameModeInit

#if defined _ALS_OnPlayerKeyStateChange
    #undef OnPlayerKeyStateChange
#else
    #define _ALS_OnPlayerKeyStateChange
#endif
#define OnPlayerKeyStateChange NP_OnPlayerKeyStateChange

#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect NP_OnPlayerConnect

#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect NP_OnPlayerDisconnect