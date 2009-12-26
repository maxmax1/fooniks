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

#define Dialog_pList 	25252
#define Dialog_pConfirm	25253
#define PAGE_SIZE		32

new pList[MAX_PLAYERS][PAGE_SIZE];
new gMyPList[MAX_PLAYERS];
new gMyConfirmBox[MAX_PLAYERS];

forward OnPlayerSelectPlayer(playerid, otherId, listId, btn);
forward OnPlayerConfirm(playerid, response, boxId);
forward pList_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);

stock ShowPlayerList(playerid, listid, Float: dist, showMe)
{
	new str[MAX_PLAYER_NAME*PAGE_SIZE];
	
	new Float: pLx, Float: pLy, Float: pLz;
	
	if(dist != -1)
	{
		GetPlayerPos(playerid, pLx, pLy, pLz);
	}
	
	new i;
	for(new otherId = 0; otherId < MAX_PLAYERS; otherId++)
	{
		if(!showMe && otherId == playerid) continue;
		if(!IsPlayerConnected(otherId)) continue;
		
		if(dist == -1 || IsPlayerInRangeOfPoint(otherId, dist, pLx, pLy, pLz))
		{
			new otherName[MAX_PLAYER_NAME];
			GetPlayerName(otherId, otherName, MAX_PLAYER_NAME);
			pList[playerid][i] = otherId;
			format(str, sizeof(str), "%s %s\n", str, otherName);
			i++;
		}
	}
	
	if(i == 0)
	{
		format(str, sizeof(str), "Pole...\n");
		pList[playerid][0] = -1;
	}
	gMyPList[playerid] = listid;
	ShowPlayerDialog(playerid, Dialog_pList, DIALOG_STYLE_LIST, "Vali mängija", str, "OK", "Katkesta");		
}

stock ShowPlayerConfirmbox(playerid, boxId, mStr[])
{
	gMyConfirmBox[playerid] = boxId;
	ShowPlayerDialog(playerid, Dialog_pConfirm, DIALOG_STYLE_MSGBOX, "Kinnita", mStr, "Jah", "Ei");
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == Dialog_pList)
	{
		if (funcidx("OnPlayerSelectPlayer") != -1)
		{
			if(pList[playerid][listitem] == -1) response = 0;
			new oList = gMyPList[playerid];
			gMyPList[playerid] = -1;
			return CallRemoteFunction("OnPlayerSelectPlayer", "iiii", playerid, pList[playerid][listitem], oList, response);
		}
	}
	if(dialogid == Dialog_pConfirm)
	{
		if (funcidx("OnPlayerConfirm") != -1)
		{
			return CallRemoteFunction("OnPlayerConfirm", "iii", playerid, response, gMyConfirmBox[playerid]);
		}
	}

    if (funcidx("pList_OnDialogResponse") != -1)
    {
        return CallLocalFunction("pList_OnDialogResponse", "iiiis", playerid, dialogid, response, listitem, inputtext);
    }
    return 1;
}


#if defined _ALS_OnDialogResponse
    #undef OnDialogResponse
#else
    #define _ALS_OnDialogResponse
#endif
#define OnDialogResponse pList_OnDialogResponse