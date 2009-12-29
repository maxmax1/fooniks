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
*    The Initial Developers of the Original Code are 13th and Jyrno42.
*/

/*
*    This File: phoenix_Skills.inc
*    Purpose: Add Skills system into Phoenix.
*/

/*
*    DEFINES
*/

#define SKILL_PISTOL				0
#define SKILL_PISTOLS				1
#define SKILL_DEAGLE				2
#define SKILL_SHOTGUN				3
#define SKILL_SAWNOFF_SHOTGUN		4
#define SKILL_SPAS12_SHOTGUN		5
#define SKILL_MICRO_UZI				6
#define SKILL_MP5					7
#define SKILL_AK47					8
#define SKILL_M4					9
#define SKILL_SNIPERRIFLE			10
#define SKILL_ATHLETE				11

#define SkillWeapon(%0) \
		((%0 == 0)?22:(%0 == 1)?23:(%0 == 2)?24:(%0 == 3)?25:(%0 == 4)?26:(%0 == 5)?27:(%0 == 6)?28:(%0 == 7)?29:(%0 == 8)?30:(%0 == 9)?31:(%0 == 10)?34:999)

/*
*    GLOBALS
*/

enum sInf
{
	sName[32],
	sLevel,
	Float: sRatio
};
new Skills[MAX_SKILLS][sInf] = 
{
	{"PISTOL", 1000, 1.5},
	{"PISTOL_VAIKNE", 1250, 2.0},
	{"DEAGLE", 1500, 4.0},
	{"SHOTGUN", 2000, 2.8},
	{"SAWNOFF_SHOTGUN", 2100, 3.5},
	{"SPAS12_SHOTGUN", 1800, 3.5},
	{"MICRO_UZI", 3000, 6.0},
	{"MP5", 1800, 2.5},
	{"AK47", 3500, 3.0},
	{"M4", 2000, 3.0},
	{"SNIPERRIFLE", 5000, 5.0},
	{"ATHLETE", 7500, 1.8}
};
new SkillDelay[MAX_PLAYERS][MAX_SKILLS];

new pSkill[MAX_PLAYERS][MAX_SKILLS];
new pSkillLevel[MAX_PLAYERS][MAX_SKILLS];
new pSkillXPNeeded[MAX_PLAYERS][MAX_SKILLS];

/*
*    FORWARDS
*/

forward LoadSkills(playerid);
forward SaveSkills(playerid, threadid);
forward XpAdd(playerid, skillId, amount);
forward SetSkills(playerid);
forward OnLevelUp(playerid, skillId, newLevel, showMsg);
forward GetLevel(skillId, xP, &xpNeeded);
forward ClearDelay(playerid, skillId);

/*
*    PUBLICS
*/

public LoadSkills(playerid)
{	
	if(pInfo[playerid][pSqlId] == 0) return 0;
	
	new query[128];
	format(query, 128, "SELECT * FROM %sskills WHERE cid = '%d'", MYSQL_PREFIX, pInfo[playerid][pSqlId]);
	mysql_query(query);
	
	if(mysql_store_result() == 1)
	{
		if(mysql_num_rows() > 0)
		{
			new Field[64], str[12];
			mysql_fetch_row(Field);	
			
			for(new i = 0; i < MAX_SKILLS; i++)
			{
				format(str, 12, "skill_%d", i);
				mysql_fetch_field_row(Field, str);
				pSkill[playerid][i]	= strval(Field);
			}			
			mysql_free_result();	

			SetSkills(playerid);
			LoadPockets(playerid);
			return 1;			
		}
		else
		{
			mysql_free_result();
			format(query, 128, "INSERT INTO %sskills(id, cid) VALUES(NULL, '%d');", MYSQL_PREFIX, pInfo[playerid][pSqlId]);
			mysql_query(query);
			SetTimerEx("LoadSkills", 500, 0, "i", playerid);
			return 1;
		}
	}
	
	SendClientMessage(playerid, COLOR_RED, LANG_STATSERROR);
	Kick(playerid);
	return 1;
}

public SaveSkills(playerid, threadid)
{	
	if(!pInfo[playerid][pLoggedIn]) return 0;
	if(pInfo[playerid][pSqlId] == 0) return 0;

	new sqlid = pInfo[playerid][pSqlId];
	new query[MAX_QUERY], table[32];
	format(table, 32, "%sskills", MYSQL_PREFIX);
	
	MysqlUpdateBuild(query, table);
	
	new str[12];			
	for(new i = 0; i < MAX_SKILLS; i++)
	{
		format(str, 12, "skill_%d", i);
		MysqlUpdateInt(query, str, pSkill[playerid][i]);
	}
	
	MysqlUpdateFinish(query, "cid", sqlid, threadid);	
	return 1;
}

public XpAdd(playerid, skillId, amount)
{
	pSkillLevel[playerid][skillId] = GetLevel(skillId, pSkill[playerid][skillId], pSkillXPNeeded[playerid][skillId]);
	pSkill[playerid][skillId] += amount;
	
	if( skillId <= 10 )
	{
	    if ( IsPlayerInAnyVehicle(playerid) || GetPlayerWeapon(playerid) != SkillWeapon(skillId) )
		{
		    if( pInfo[playerid][pSkillTimer] != 0 )
		    {
				KillTimer(pInfo[playerid][pSkillTimer]);
				pInfo[playerid][pSkillTimer] = 0;
			}
			return 1;
		}
		SkillDelay[playerid][skillId] = 1;
		SetTimerEx("ClearDelay", 285, 0, "ii", playerid, skillId);
		if(skillId <= 10)
		{
			new wepId = skillId+1;
			RemAmount(playerid, wepId, 1);
		}
	}	
	
	if(pSkill[playerid][skillId] >= pSkillXPNeeded[playerid][skillId])
	{	
		OnLevelUp(playerid, skillId, (pSkillLevel[playerid][skillId]+1), 1);
		pSkillLevel[playerid][skillId]++;
	}
	
	//UpdateSkillDraw(playerid, skillId, amount);
	return 1;
}

public SetSkills(playerid)
{
	for(new i = 0; i < MAX_SKILLS; i++)
	{
		pSkillLevel[playerid][i] = GetLevel(i, pSkill[playerid][i], pSkillXPNeeded[playerid][i]);
		OnLevelUp(playerid, i, pSkillLevel[playerid][i], 0);
	}
}

public OnLevelUp(playerid, skillId, newLevel, showMsg)
{
	if(showMsg == 1)
	{
		//	LevelAP
		new string[128];
		format(string, 128, "Sinu %s oskus on nüüd %d. Oled kogunud %d kogemuspunkti.", Skills[skillId][sName], newLevel, pSkill[playerid][skillId]);
		SendClientMessage(playerid, COLOR_GREEN, string);
	}
	
	if(skillId < 11) SetPlayerSkillLevel(playerid, skillId, floatround(newLevel*10));
	return 1;
}

public GetLevel(skillId, xP, &xpNeeded)
{
	if(xP < Skills[skillId][sLevel])
	{
		xpNeeded = Skills[skillId][sLevel];
		return 1;
	}
	new temp = Skills[skillId][sLevel];
	
	xpNeeded = floatround(temp);
	for(new i = 2; i < 99; i++)
	{
		temp = floatround(temp*Skills[skillId][sRatio]);		
		if(xP < floatround(temp * i) && xP > xpNeeded)
		{
			xpNeeded = floatround(temp * i);
			return i;
		}
	}	
	xpNeeded = 999;
	return 99;
}

public ClearDelay(playerid, skillId)
{
	SkillDelay[playerid][skillId] = 0;
	return 1;
}