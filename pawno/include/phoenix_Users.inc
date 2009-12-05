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
*    This File: phoenix_Core.inc
*    Purpose: The user & character system for phoenix.
*/

/*
*    DEFINES
*/

/*
*    GLOBALS
*/

new Fetch_UInfo_Thread = -1;

enum pInf
{
	bool: u1Fetched,
	bool: u2Fetched,
	bool: cFetched,
	uSqlId,
	uUserName[20],	
	uPassWordHash[64],
	uSalt[10],
	bool: pLoggedIn,
	pCharName[30],
	pSqlId,
	pAdmin,
	pJob,
	pMember,
	pLeader,
	pModel,
	pAdminLevel,
	aAction,
	
	Float:pPosX,
	Float:pPosY,
	Float:pPosZ,
	Float:pAngle,
	Float:pHealth,
	pVW,
	pInterior,
	
	SelectedPlayer,
	npcId,
	pSkill[MAX_SKILLS+1],
	pSkillTimer,
	pSeatbelt,
	
	Float: pRest,
	bool: pResting,
	pRestingAt,
	
	pControllable
};
new pInfo[MAX_PLAYERS][pInf];

/*
*    FORWARDS
*/

forward CheckCharacter(playerid);
forward CheckCharacterFinish(playerid);
forward GetUserInfo(playerid);
forward GetUserInfoFinish(playerid);
forward AuthenticateUser(playerid, givenPassword[]);
forward FetchCharacterInformation(playerid);
forward FetchCharacterInformationFinish(playerid);
forward UpdatePlayer(playerid);
forward UpdateAllPlayers();
forward ClearPlayerData(playerid);

/*
*    PUBLICS
*/


public CheckCharacter(playerid)
{
	new eName[32], query[86];
	mysql_real_escape_string(pInfo[playerid][pCharName], eName);
	format(query, 86, "SELECT id, userid FROM %scharacters WHERE name = '%s' LIMIT 0, 1", MYSQL_PREFIX, eName);	
	mysql_query(query);
		
	if(mysql_store_result())
	{
		if(mysql_num_rows() > 0)
		{
			new Field[64], Data[128];
			mysql_fetch_row(Data);
			
			mysql_fetch_field_row(Field, "id");
			pInfo[playerid][pSqlId] = strval(Field);
			
			mysql_fetch_field_row(Field, "userid");
			pInfo[playerid][uSqlId] = strval(Field);
			mysql_free_result();
			
			pInfo[playerid][u1Fetched] = true;
			GetUserInfo(playerid);
			return 1;
		}
		else
		{
	 		SendClientMessage(playerid, COLOR_RED, LANG_NOCHARACTER);
			Kick(playerid);
		}
	}
	return 1;
}

public GetUserInfo(playerid)
{
	if(!pInfo[playerid][u1Fetched])
	{
		CheckCharacter(playerid);
		return 1;
	}

	new query[86];
	format(query, 86, "SELECT username, password, salt FROM user WHERE userid = '%d' LIMIT 1", pInfo[playerid][uSqlId]);
	mysql_query(query);

	if(mysql_store_result() == 1)
	{		
		if(mysql_num_rows() > 0)
		{
			new Field[64], Data[128];
			mysql_fetch_row(Data);
			
			mysql_fetch_field_row(Field, "username");
			strmid(pInfo[playerid][uUserName], Field, 0, strlen(Field), MAX_STRING);
			
			mysql_fetch_field_row(Field, "password");
			strmid(pInfo[playerid][uPassWordHash], Field, 0, strlen(Field), MAX_STRING);
			
			mysql_fetch_field_row(Field, "salt");
			strmid(pInfo[playerid][uSalt], Field, 0, strlen(Field), MAX_STRING);
			mysql_free_result();
			pInfo[playerid][u2Fetched] = true;
		}	
		return 1;
	}
	SendClientMessage(playerid, COLOR_RED, LANG_NOUSER);
	Kick(playerid);
	return 1;
}

public AuthenticateUser(playerid, givenPassword[])
{
	if(!pInfo[playerid][u2Fetched])
	{
		GetUserInfo(playerid);
		SendClientMessage(playerid, COLOR_RED, LANG_WAIT);
		return 1;
	}

	new string[MAX_STRING];
	format(string, MAX_STRING, "%s", PasswordHash(givenPassword, pInfo[playerid][uSalt]));
	new strC = strcmp(pInfo[playerid][uPassWordHash], string, true);
	if(strC != 0) // wrong Password
	{
		SendClientMessage(playerid, COLOR_RED, LANG_WRONG_PASSWORD);
		showLogin(playerid);
	}
	else
	{
	    FetchCharacterInformation(playerid);
	}
	return 1;
}

public FetchCharacterInformation(playerid)
{
	if(!pInfo[playerid][u2Fetched])
	{
		GetUserInfo(playerid);
		SendClientMessage(playerid, COLOR_RED, LANG_WAIT);
		return 1;
	}

	if(Fetch_UInfo_Thread != -1) // thread is busy, lets attemp again in 1 second.
	{
		SetTimerEx("FetchCharacterInformation", 1000, 0, "i", playerid);
		return 1;
	}
	Fetch_UInfo_Thread = playerid;

	new query[86];
	format(query, 86, "SELECT * FROM %scharacters WHERE id = '%d' LIMIT 0, 1", MYSQL_PREFIX, pInfo[playerid][pSqlId]);
	mysql_query(query, FETCH_UINFO_THREAD);
	SetTimerEx("FetchCharacterInformationFinish", SQL_FINISH_TIME, 0, "i", playerid);
	return 1;

}

public FetchCharacterInformationFinish(playerid)
{
	if(Fetch_UInfo_Thread != playerid) return 1;
	
	if(mysql_store_result() == 1)
	{
		if(mysql_num_rows() < 1)
		{
			SendClientMessage(playerid, COLOR_RED, LANG_NOCHARACTER);
			Kick(playerid);
		}
		else
		{
			new Field[64], Data[1024];
			mysql_fetch_row(Data);
			
			mysql_fetch_field_row(Field, "model");
			pInfo[playerid][pModel] = strval(Field);
			mysql_fetch_field_row(Field, "money");
			GivePlayerMoneyNew(playerid, strval(Field));
			mysql_fetch_field_row(Field, "posX");
			pInfo[playerid][pPosX] = floatstr(Field);
			mysql_fetch_field_row(Field, "posY");
			pInfo[playerid][pPosY] = floatstr(Field);
			mysql_fetch_field_row(Field, "posZ");
			pInfo[playerid][pPosZ] = floatstr(Field);
			mysql_fetch_field_row(Field, "angle");
			pInfo[playerid][pAngle] = floatstr(Field);
			mysql_fetch_field_row(Field, "VirtualWorld");
			pInfo[playerid][pVW] = strval(Field);
			mysql_fetch_field_row(Field, "interior");
			pInfo[playerid][pInterior] = strval(Field);
			mysql_fetch_field_row(Field, "health");
			pInfo[playerid][pHealth] = floatstr(Field);
			mysql_fetch_field_row(Field, "adminLevel");
			pInfo[playerid][pAdminLevel] = strval(Field);
			mysql_fetch_field_row(Field, "playerJob");
			gMyJob[playerid] = strval(Field);
			
			mysql_free_result();
			LoadSkills(playerid);
		}
	}
	Fetch_UInfo_Thread = -1;
	pInfo[playerid][cFetched] = true;
	return 1;
}

public UpdatePlayer(playerid)
{
	if(!pInfo[playerid][pLoggedIn]) return 1;
	
	GetPlayerPos(playerid, pInfo[playerid][pPosX], pInfo[playerid][pPosY], pInfo[playerid][pPosZ]);
	GetPlayerFacingAngle(playerid, pInfo[playerid][pAngle]);
	GetPlayerHealth(playerid, pInfo[playerid][pHealth]);
	
	new sqlid = pInfo[playerid][pSqlId];
	
	new query[MAX_QUERY], table[32];
	format(table, 32, "%scharacters", MYSQL_PREFIX);
	
	MysqlUpdateBuild(query, table);
	
	MysqlUpdateInt(query, "money", PlayerMoney[playerid]);
	MysqlUpdateInt(query, "model", pInfo[playerid][pModel]);
	MysqlUpdateFlo(query, "posX", pInfo[playerid][pPosX]);
	MysqlUpdateFlo(query, "posY", pInfo[playerid][pPosY]);
	MysqlUpdateFlo(query, "posZ", pInfo[playerid][pPosZ]);
	MysqlUpdateFlo(query, "angle", pInfo[playerid][pAngle]);

	MysqlUpdateInt(query, "VirtualWorld", pInfo[playerid][pVW]);
	MysqlUpdateInt(query, "interior", pInfo[playerid][pInterior]);
	MysqlUpdateFlo(query, "health", pInfo[playerid][pHealth]);
	MysqlUpdateInt(query, "adminLevel", pInfo[playerid][pAdminLevel]);
	
	MysqlUpdateFinish(query, "id", sqlid);

	print("Player Updated!");
	return 1;
}
public UpdateAllPlayerPos()
{
	foreach(Player, playerid)
	{
		if(pInfo[playerid][pLoggedIn])
		{
			GetPlayerPos(playerid, pInfo[playerid][pPosX], pInfo[playerid][pPosY], pInfo[playerid][pPosZ]);

			new sqlid = pInfo[playerid][pSqlId];
			new query[MAX_QUERY], table[32];
			format(table, 32, "%scharacters", MYSQL_PREFIX);
			MysqlUpdateBuild(query, table);
			MysqlUpdateFlo(query, "posX", pInfo[playerid][pPosX]);
			MysqlUpdateFlo(query, "posY", pInfo[playerid][pPosY]);
			MysqlUpdateFlo(query, "posZ", pInfo[playerid][pPosZ]);
			MysqlUpdateFinish(query, "id", sqlid);
		}
	}
	print("All Player Positsions Saved!");
	return 1;
}

public UpdateAllPlayers()
{
	foreach(Player, i)
	{
	    if( pInfo[i][pLoggedIn] )
	    {
	    	UpdatePlayer(i);
			SaveSkills(i);
		}
	}
}

public ClearPlayerData(playerid)
{
	pInfo[playerid][u1Fetched] = false;
	pInfo[playerid][u2Fetched] = false;
	pInfo[playerid][cFetched] = false;
	pInfo[playerid][uSqlId] = 0;
	strmid(pInfo[playerid][uUserName], "", 0, 2);
	strmid(pInfo[playerid][uPassWordHash], "", 0, 2);
	strmid(pInfo[playerid][uSalt], "", 0, 2);
	
	strmid(pInfo[playerid][pCharName], "", 0, 2);
	
	pInfo[playerid][pLoggedIn] = false;
	pInfo[playerid][pSqlId] = 0;
	pInfo[playerid][pAdmin] = 0;
	pInfo[playerid][pJob] = 0;
	pInfo[playerid][pMember] = 0;
	pInfo[playerid][pLeader] = 0;
	pInfo[playerid][pModel] = 0;
	pInfo[playerid][pAdminLevel] = 0;
	pInfo[playerid][aAction] = 0;
	
	pInfo[playerid][pPosX] = 0.0;
	pInfo[playerid][pPosY] = 0.0;
	pInfo[playerid][pPosZ] = 0.0;
	pInfo[playerid][pAngle] = 0.0;
	pInfo[playerid][pHealth] = 0.0;
	
	pInfo[playerid][pVW] = 0;
	pInfo[playerid][pInterior] = 0;
	
	pInfo[playerid][SelectedPlayer] = 0;
	pInfo[playerid][npcId] = 0;
	pInfo[playerid][pSeatbelt] = 0;
	pInfo[playerid][pRest] = 0.0;
	pInfo[playerid][pResting] = false;
	pInfo[playerid][pRestingAt] = -1;
	
	pInfo[playerid][pControllable] = 1;
	
	#if defined _phoenix_Money_included
	ResetPlayerMoneyNew(playerid);
	#endif	
	
}

// EOF