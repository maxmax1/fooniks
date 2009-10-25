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
	itemOtherId
};
new Items[MAX_ITEMS][itemInf] = 
{
	{"tühjus", 0, 0, "UseEmpty",  0},
	{"püstol", 0, 1, "setAPistol", 21}
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

stock FindFreeSlot(playerid, type, max)
{
	for(new i; i < MAX_POCKETS; i++)
	{
		if(type != 0 && Pockets[playerid][i][pAmount] > max) continue;
		if(Pockets[playerid][i][pType] == type) return i;
	}
	return -1;
}

// Forwards

forward BuildPockets(playerid, string[], len);
forward UseItem(playerid, pocketid);
forward public giveItem(playerid, itemId, amount);

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

// returns given amount.
public giveItem(playerid, itemId, amount)
{
	if(itemId < 0 || itemId > MAX_ITEMS) return 0;		

	new type = (Items[itemId][itemMax] > 1)?itemId:0; // If itemMax is bigger than 1 find a slot that has free space.	
	new maks = (Items[itemId][itemMax] > 1)?Items[itemId][itemMax]:0; // If itemMax is bigger than 1 find a slot that has free space.	
	new freeSlot = FindFreeSlot(playerid, type, maks);
	if(freeSlot == -1) return 0;
	
	if(maks == 0)
	{
		Pockets[playerid][freeSlot][pType] = itemId;
		Pockets[playerid][freeSlot][pAmount] = amount;
		return amount;
	}
	else
	{
		new canGive = maks - Pockets[playerid][freeSlot][pAmount];
		new realGive = (amount > canGive)?canGive:amount;
		
		if(canGive > 0)
		{
			Pockets[playerid][freeSlot][pAmount] += realGive;
			return (amount-realGive);
		}
		return 0;
	}
}


// HANDLERS

// forwards

forward giveItemOtherStuff(playerid, itemid, amount);

forward UseEmpty(playerid, amount);
forward setAPistol(playerid, amount);

// publics
public UseEmpty(playerid, amount)
{
	SendEmote(playerid, "katsub oma tühja taskut.");
	return 1;
}

public giveItemOtherStuff(playerid, itemid, amount)
{
	if(itemid == 0)
	{
		return 1;
	}
	else if(itemid < 10)
	{
		GivePlayerWeapon(playerid, Items[itemid][itemOtherId], amount);
	}
	return 0;
}

public setAPistol(playerid, amount)
{
	SetPlayerArmedWeapon(playerid, 22);
	return 1;
}