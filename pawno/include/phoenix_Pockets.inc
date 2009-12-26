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

#define MAX_ITEMS 15
#define MAX_POCKETS 16
#define POCKETS_NUM_WEAPONS 12

#define DIALOG_POCKETS 2017
#define DIALOG_POCKETSA 2018

enum itemInf
{
	itemName[18],
	itemMin,
	itemMax,
	itemCallBack[16],
	itemOtherId,
	itemParent
};
new Items[MAX_ITEMS][itemInf] = 
{
	{"tühjus", 0, 0, "UseEmpty",  0, -1},	
	{"Püstol", 0, 500, "setWep", 22, -1},
	{"Summutatud Püstol", 0, 500, "setWep", 23, 1},
	{"Deagle", 0, 500, "setWep", 24, 1},
	{"Pump", 0, 500, "setWep", 25, -1},
	{"Kaheraudne", 0, 500, "setWep", 26, 4},
	{"M3", 0, 500, "setWep", 27, 4},
	{"UZI", 0, 500, "setWep", 28, -1},
	{"MP5", 0, 500, "setWep", 29, 8},
	{"AK47", 0, 500, "setWep", 30, -1},
	{"M4", 0, 500, "setWep", 31, 10},	
	{"Vintpüss", 0, 500, "setWep", 33, -1},	
	{"Snaiper", 0, 500, "setWep", 34, 11},
	{"SIM-Kaart", 0, 0, "ActivateSimCard", 0, -1},
	{"Telefon", 0, 0, "forward_Phone", 0, -1}
};

enum pockInf
{
	pType,
	pAmount
};
new Pockets[MAX_PLAYERS][MAX_POCKETS][pockInf];

new gActivePocket[MAX_PLAYERS];

new gTradeOffer[MAX_PLAYERS];
new gTradePrice[MAX_PLAYERS];

/*
*    STOCKS
*/

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

stock clearPockets(playerid)
{
	for(new i; i < MAX_POCKETS; i++)
	{
		Pockets[playerid][i][pType] = 0;
		Pockets[playerid][i][pAmount] = 0;
	}
	gActivePocket[playerid] = -1;
	gTradeOffer[playerid] = -1;
	gTradePrice[playerid] = 0;
	return 0;
}

stock getItemByWeapon(weaponid)
{
	for(new i; i < MAX_ITEMS; i++)
	{
		if(Items[i][itemOtherId] == weaponid) return i;
	}
	return -1;
}

stock ShowActionMenu(playerid, pocketid)
{
	new string[32];

	new Type = Pockets[playerid][pocketid][pType];
	if(Type < 1 || Type > MAX_ITEMS)
	{
		SendClientMessage(playerid, COLOR_RED, "Tühjust ei saa uurida.");
		showPockets(playerid);
	}
	else	
	{
		format(string, 32, LANG_DIALOG_POCKETSHEADA, Items[Type][itemName]);
		ShowPlayerDialog(playerid, DIALOG_POCKETSA, DIALOG_STYLE_LIST, string, "Kasuta\nAnna\nMüü\nViska Maha\nHävita", LANG_DIALOG_OK, LANG_DIALOG_EXITBUTTON);
		gActivePocket[playerid] = pocketid;
	}
}

// Forwards

forward BuildPockets(playerid, string[], len);
forward UseItem(playerid, pocketid);
forward giveItem(playerid, itemId, amount);
forward RemAmount(playerid, itemId, amount);
forward giveItemOtherStuff(playerid, itemid, amount);
forward ClearPocket(playerid, slotId);
forward LoadPockets(playerid);
forward SavePockets(playerid);
forward SavePocket(playerid, pocketId);

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
	new ret = CallLocalFunction(Items[Type][itemCallBack], "iii", playerid, Amount, Items[Type][itemOtherId]);
	
	if(ret > 0) // Remove item after usage.
	{
		ClearPocket(playerid, pocketid);
	}
	
	return 0;
}

// returns amount not given.
public giveItem(playerid, itemId, amount)
{
	if(itemId < 0 || itemId > MAX_ITEMS) return 0;		

	new type = (Items[itemId][itemMax] > 1)?itemId:0; // If itemMax is bigger than 1 find a slot that has free space.	
	new maks = (Items[itemId][itemMax] > 1)?Items[itemId][itemMax]:0; // If itemMax is bigger than 1 find a slot that has free space.	
	new par = (Items[itemId][itemParent] != -1)?Items[itemId][itemParent]:-1; // If itemMax is bigger than 1 find a slot that has free space.	
	new freeSlot = findFreeSlot(playerid, type, maks, par);
	
	if(freeSlot == -1)
	{
		return amount;
	}
	if(maks == 0)
	{
		Pockets[playerid][freeSlot][pType] = itemId;
		Pockets[playerid][freeSlot][pAmount] = amount;
		giveItemOtherStuff(playerid, itemId, amount);	
		return 0;
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
		return amount;
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
		ClearPocket(playerid, foundSlot);
	}
	return 1;
}

public ClearPocket(playerid, slotId)
{
	if(slotId < 0 || slotId > MAX_POCKETS) return 0;	
	
	new otype = Pockets[playerid][slotId][pType];
	Pockets[playerid][slotId][pType] = 0;
	Pockets[playerid][slotId][pAmount] = 0;
	
	if(otype < POCKETS_NUM_WEAPONS)
	{
		ResetPlayerWeapons(playerid);
		for(new i; i < MAX_POCKETS; i++)
		{
			if(Pockets[playerid][i][pType] > 0 && Pockets[playerid][i][pType] < POCKETS_NUM_WEAPONS)
			{
				giveItemOtherStuff(playerid, Pockets[playerid][i][pType], Pockets[playerid][i][pAmount]);
			}
		}
	}	
	
	return 1;
}

public LoadPockets(playerid)
{
	if(pInfo[playerid][pSqlId] == 0) return 0;
	clearPockets(playerid);
	
	new query[128];
	format(query, 128, "SELECT * FROM %sPockets WHERE cid = '%d'", MYSQL_PREFIX, pInfo[playerid][pSqlId]);
	mysql_query(query);
	
	if(mysql_store_result() == 1)
	{
		if(mysql_num_rows() > 0)
		{
			new Field[64], str[12];
			mysql_fetch_row(Field);	
			
			for(new i = 0; i < MAX_POCKETS; i++)
			{
				format(str, 12, "pType_%d", i);
				mysql_fetch_field_row(Field, str);				
				new itemId = strval(Field);
				
				format(str, 12, "pData_%d", i);
				mysql_fetch_field_row(Field, str);
				new amount = strval(Field);				
				SetTimerEx("giveItem", 5000, 0, "iii", playerid, itemId, amount);
			}			
			mysql_free_result();
			OnPlayerLogin(playerid);
			return 1;			
		}
		else
		{
			mysql_free_result();
			format(query, 128, "INSERT INTO %sPockets(id, cid) VALUES(NULL, '%d');", MYSQL_PREFIX, pInfo[playerid][pSqlId]);
			mysql_query(query);
			SetTimerEx("LoadPockets", 500, 0, "i", playerid);
			return 1;
		}
	}
	
	SendClientMessage(playerid, COLOR_RED, LANG_POCKETSERROR);
	Kick(playerid);
	return 1;
}

public SavePockets(playerid)
{
	for(new i = 0; i < MAX_POCKETS; i++)
	{
		SavePocket(playerid, i);
	}
}

public SavePocket(playerid, pocketId)
{	
	if(!pInfo[playerid][pLoggedIn]) return 0;
	if(pInfo[playerid][pSqlId] == 0) return 0;
	if(pocketId < 0 || pocketId >= MAX_POCKETS) return 0;

	new sqlid = pInfo[playerid][pSqlId];
	new query[MAX_QUERY], table[32], str[12];
	format(table, 32, "%sPockets", MYSQL_PREFIX);
	
	MysqlUpdateBuild(query, table);
	
	format(str, 12, "pType_%d", pocketId);
	MysqlUpdateInt(query, str, Pockets[playerid][pocketId][pType]);
	format(str, 12, "pData_%d", pocketId);
	MysqlUpdateInt(query, str, Pockets[playerid][pocketId][pAmount]);
	
	MysqlUpdateFinish(query, "cid", sqlid);	
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
	else if(itemid < POCKETS_NUM_WEAPONS)
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
	return 0;
}

public setWep(playerid, amount, weP)
{
	SetPlayerArmedWeapon(playerid, weP);
	SendEmote(playerid, "võtab kätte relva.");
	return 0;
}