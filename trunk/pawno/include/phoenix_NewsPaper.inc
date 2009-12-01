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

#define NEWSPAPERBACK 0x000000AA

#define FRONT_PAGE 0

enum newsInf
{
	Text: Text0,
	Text: Text1,
	Text: Text2,
	Text: Text3,
	Text: Text4,
	Text: Text5,
	Text: Text6,
	bool: used
};
new NewsDraw[50][newsInf];

forward ShowNewsPaper(playerid, page, heading[]);
forward CreatePaperDraw(paperid);
forward NewsPaper_OnGameModeInit();
 
public ShowNewsPaper(playerid, page, heading[])
{
	new i = findFreePaperDraw();
	if(i != -1)
	{
		if(page == 0)
		{
			TextDrawSetString(NewsDraw[i][Text1], heading);
			TextDrawSetString(NewsDraw[i][Text2], "1 / 4");
			
			TextDrawShowForPlayer(playerid, NewsDraw[i][Text0]);
			TextDrawShowForPlayer(playerid, NewsDraw[i][Text1]);
			TextDrawShowForPlayer(playerid, NewsDraw[i][Text2]);
			TextDrawShowForPlayer(playerid, NewsDraw[i][Text3]);
			TextDrawShowForPlayer(playerid, NewsDraw[i][Text4]);
			TextDrawShowForPlayer(playerid, NewsDraw[i][Text5]);
			TextDrawShowForPlayer(playerid, NewsDraw[i][Text6]);
			NewsDraw[i][used] = true;
		}
	}
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

/*
*    Silent Implentation
*/

public OnGameModeInit()
{
	for(new i = 0; i < 50; i++)
	{
		CreatePaperDraw(i);
	}
	
    if (funcidx("NewsPaper_OnGameModeInit") != -1)
    {
        return CallLocalFunction("NewsPaper_OnGameModeInit", "");
    }
    return 1;
}

#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit NewsPaper_OnGameModeInit