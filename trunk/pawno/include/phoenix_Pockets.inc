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

#define MAX_ITEMS 2
#define MAX_POCKETS 10
#define DIALOG_POCKETS 2017

enum itemInf
{
	itemName[16],
	itemMin,
	itemMax,
	itemCallBack[16],
	
};
new Items[MAX_ITEMS][itemInf] = 
{
	{"tühjus", 0, 0, "UseEmpty"},
	{"püstol", 0, 1, "setAPistol"}
};

enum pockInf
{
	pType,
	pAmount
};
new Pockets[MAX_PLAYERS][MAX_POCKETS][pockInf];

stock showPockets(playerid)
{
	new string[128];
	BuildPockets(playerid, string, 128);
	
	ShowPlayerDialog(playerid, DIALOG_POCKETS, DIALOG_STYLE_LIST, LANG_DIALOG_POCKETSHEAD, string, LANG_DIALOG_OK, LANG_DIALOG_EXITBUTTON);
}

// Forwards

forward BuildPockets(playerid, string[], len);
forward UseItem(playerid, pocketid);

// Publics

public BuildPockets(playerid, string[], len)
{
	#define strSafe (len-10)
	for(new i; i < MAX_POCKETS; i++)
	{
		if(strlen(string) > strSafe) break;
		
		new Type = Pockets[playerid][i][pType];
		if(Type < 0 || Type > MAX_ITEMS) continue;		
		
		format(string, len, "%s%s\n", string, Items[Type][itemName]);
	}
	#undef strSafe
}

public UseItem(playerid, pocketid)
{
	if(pocketid < 0 || pocketid > MAX_POCKETS) return 1;
	if(!IsPlayerConnected(playerid)) return 2;
	
	new Type = Pockets[playerid][pocketid][pType];
	if(Type < 0 || Type > MAX_ITEMS) return 3;
	
	new Amount = Pockets[playerid][pocketid][pAmount];
	CallLocalFunction(Items[Type][itemCallBack], "ii", playerid, Amount);
	
	return 0;
}

// HANDLERS

// forwards
forward UseEmpty(playerid, amount);
forward setAPistol(playerid, amount);

// publics
public UseEmpty(playerid, amount)
{
	SendEmote(playerid, "katsub oma tühja taskut.");
	return 1;
}
public setAPistol(playerid, amount)
{
	SetPlayerArmedWeapon(playerid, 22);
	return 1;
}