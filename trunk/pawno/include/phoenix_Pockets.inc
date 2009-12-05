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
*    This File: phoenix_Pockets.inc
*    Purpose: Add an inventory system...
*
*/

#if !defined _phoenix_included
	#error "Phoenix ERROR #1, You need phoenix base for this gamemode to run!"
	#endinput
#endif

#define MAX_ITEMS 13
#define MAX_POCKETS 10
#define DIALOG_POCKETS 2017

enum itemInf
{
	itemName[16],
	itemMin,
	itemMax,
	itemCallBack[16],
	itemOtherId,
	itemParent
};
new Items[MAX_ITEMS][itemInf] = 
{
	{"tühjus", 0, 0, "UseEmpty",  0, -1},	
	{"püstol", 0, 500, "setWep", 22, -1},
	{"püstolV", 0, 500, "setWep", 23, 1},
	{"DEAGLE", 0, 500, "setWep", 24, 1},
	{"Shotgun", 0, 500, "setWep", 25, -1},
	{"ShotgunS", 0, 500, "setWep", 26, 4},
	{"ShotgunSP", 0, 500, "setWep", 27, 4},
	{"MICROUZI", 0, 500, "setWep", 28, -1},
	{"MP5", 0, 500, "setWep", 29, 8},
	{"AK47", 0, 500, "setWep", 30, -1},
	{"M4", 0, 500, "setWep", 31, 10},	
	{"CRifle", 0, 500, "setWep", 33, -1},	
	{"SRifle", 0, 500, "setWep", 34, 11}
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

stock findFreeSlot(playerid, type, max, parent)
{
	for(new i; i < MAX_POCKETS; i++)
	{
		if(type != 0 && Pockets[playerid][i][pAmount] > max) continue;
		
		if(parent != -1 && Pockets[playerid][i][pType] == parent) return i;
		else if(parent == -1 && Items[Pockets[playerid][i][pType]][itemParent] == type) return i;
		else if(Pockets[playerid][i][pType] == 0) return i;
		else if(Pockets[playerid][i][pType] == type) return i;		
	}
	return -1;
}

stock getSlotByItem(playerid, item)
{
	for(new i; i < MAX_POCKETS; i++)
	{
		if(Pockets[playerid][i][pType] == item) return i;
	}
	return -1;
}

// Forwards

forward BuildPockets(playerid, string[], len);
forward UseItem(playerid, pocketid);
forward giveItem(playerid, itemId, amount);
forward RemAmount(playerid, itemId, amount);
forward giveItemOtherStuff(playerid, itemid, amount);

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
	CallLocalFunction(Items[Type][itemCallBack], "iii", playerid, Amount, Items[Type][itemOtherId]);
	
	return 0;
}

// returns given amount.
public giveItem(playerid, itemId, amount)
{
	if(itemId < 0 || itemId > MAX_ITEMS) return 0;		

	new type = (Items[itemId][itemMax] > 1)?itemId:0; // If itemMax is bigger than 1 find a slot that has free space.	
	new maks = (Items[itemId][itemMax] > 1)?Items[itemId][itemMax]:0; // If itemMax is bigger than 1 find a slot that has free space.	
	new par = (Items[itemId][itemParent] != -1)?Items[itemId][itemParent]:-1; // If itemMax is bigger than 1 find a slot that has free space.	
	new freeSlot = findFreeSlot(playerid, type, maks, par);
	
	if(freeSlot == -1) return 0;
	if(maks == 0)
	{
		Pockets[playerid][freeSlot][pType] = itemId;
		Pockets[playerid][freeSlot][pAmount] = amount;
		giveItemOtherStuff(playerid, itemId, amount);		
		return amount;
	}
	else
	{
		Pockets[playerid][freeSlot][pType] = itemId;
		
		new canGive = maks - Pockets[playerid][freeSlot][pAmount];
		new realGive = (amount > canGive)?canGive:amount;		
		if(canGive > 0)
		{
			Pockets[playerid][freeSlot][pAmount] += realGive;
			giveItemOtherStuff(playerid, itemId, realGive);
			return (amount-realGive);
		}
		return 0;
	}
}

public RemAmount(playerid, itemId, amount)
{
	if(itemId < 0 || itemId > MAX_ITEMS) return 0;	
	
	new foundSlot = getSlotByItem(playerid, itemId);
	if(foundSlot == -1) return 0;
	
	Pockets[playerid][foundSlot][pAmount] -= amount;
	if(Pockets[playerid][foundSlot][pAmount] < 1)
	{
		Pockets[playerid][foundSlot][pType] = 0;
	}
	return 1;
}

// HANDLERS

// forwards

public giveItemOtherStuff(playerid, itemid, amount)
{
	if(itemid == 0)
	{
		return 1;
	}
	else if(itemid < 12)
	{
		new oldWep = GetPlayerWeapon(playerid);
		GivePlayerWeapon(playerid, Items[itemid][itemOtherId], amount);
		SetPlayerArmedWeapon(playerid, oldWep);
	}
	return 0;
}


forward UseEmpty(playerid, amount, weP);
forward setWep(playerid, amount, weP);

// publics
public UseEmpty(playerid, amount, weP)
{
	SendEmote(playerid, "katsub oma tühja taskut.");
	return 1;
}

public setWep(playerid, amount, weP)
{
	SetPlayerArmedWeapon(playerid, weP);
	SendEmote(playerid, "võtab kätte relva.");
	return 1;
}