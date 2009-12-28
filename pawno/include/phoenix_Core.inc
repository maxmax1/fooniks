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
*    Purpose: The core of Phoenix, Mysql Connection, ETC...
*/

#if defined _phoenix_included
  #endinput
#endif
#define _phoenix_included
#pragma library phoenix

/*
*    INCLUDE SOME MORE STUFF
*/
#include <../../../phoenix_Safe>
#include <phoenix_Lang>

/*
*    DEFINES
*/
#define MAX_QUERY 512
#define SQL_FINISH_TIME 1000

/*
*    COLORS
*/

#define COLOR_YELLOW		0xFFFF00AA
#define COLOR_RED 0xAA3333AA
#define COLOR_GREEN 0x33AA33AA
#define COLOR_LIGHTGREEN 0x9ACD32AA
#define COLOR_BLACK 0x000000FF
#define COLOR_WHITE 0xffffffff
#define COLOR_BLUE 0x0000FFAA

#define PLAYER_COLOR 0xFFFF0000
#define COLOR_AFK    0xFFFF3300

#define COLOR_CHAT_IC 0xf2ffacAA
#define COLOR_CHAT_OOC_GLOBAL 0x8cf8ffAA
#define COLOR_CHAT_OOC_LOCAL 0xf2ffacAA
#define COLOR_CHAT_ME 0xda92e5AA
#define COLOR_CHAT_SHOUT 0xd7ff00AA
#define COLOR_CHAT_ES 0xfffc00AA
#define COLOR_ADMINMSG 0xff3c00AA
#define COLOR_ADMINCHAT 0xffa800AA
#define COLOR_TEATA 0xff0000AA
#define COLOR_ADMIN_MESSAGE 0x0082fcAA


/*
*    GLOBALS
*/
new Connection;
Itter_Create(User, MAX_PLAYERS);

/*
*    FORWARDS
*/

forward MysqlConnect();
forward MysqlCheck();

forward MysqlUpdateBuild(query[], table[]);
forward MysqlUpdateInt(query[], field[], value);
forward MysqlUpdateFlo(query[], field[], Float: value);
forward MysqlUpdateStr(query[], field[], value[]);
forward MysqlUpdateFinish(query[], field[], value, threadid);

// Next ones for ALS
forward Phoenix_OnGameModeInit();

/*
*    PUBLICS
*/

public MysqlConnect()
{
	#if  defined PH_DEBUG
	
		mysql_debug(1);
		
	#endif
	
	Connection = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_DB, MYSQL_PASSWORD);
	if(!Connection)
	{
		printf(LANG_FAILED_TO_CONNECT, SCRIPT_NAME);
		SendRconCommand("exit");
		return 1;
	}
	printf(LANG_CONNECTED, SCRIPT_NAME);
	
	return 0;
}

public MysqlCheck()
{
	if(mysql_ping() == -1)
	{
		printf("MYSQL LOST, reconnecting.");
		MysqlConnect();
	}
}

public MysqlUpdateBuild(query[], table[])
{
	format(query, MAX_QUERY, "UPDATE %s SET ", table);
	return 1;
}

public MysqlUpdateInt(query[], field[], value)
{
	new qLen = strlen(query);
	if(qLen+50 < MAX_QUERY) // It 's safe to add.
	{
		format(query, MAX_QUERY, "%s %s = '%d', ", query, field, value);
	}
	return 1;
}

public MysqlUpdateFlo(query[], field[], Float: value)
{
	new qLen = strlen(query);
	if(qLen+50 < MAX_QUERY) // It 's safe to add.
	{
		format(query, MAX_QUERY, "%s %s = '%f', ", query, field, value);
	}
	return 1;
}

public MysqlUpdateStr(query[], field[], value[])
{
	new qLen = strlen(query);
	if(qLen+50 < MAX_QUERY) // It 's safe to add.
	{
		format(query, MAX_QUERY, "%s %s = '%s', ", query, field, value);
	}
	return 1;
}

public MysqlUpdateFinish(query[], field[], value, threadid)
{
	new qLen = strlen(query);
	strdel(query, qLen-2, qLen); // remove the extra comma 
	
	format(query, MAX_QUERY, "%s WHERE %s = '%d'", query, field, value);
	print(query);
	if(threadid == -1) mysql_query(query);
	else mysql_query(query, threadid);
}

/*
*    ALS Silent Include
*/
  
public OnGameModeInit()
{
	if(!Connection)
	{
		MysqlConnect();
		if(!Connection) return 1;
	}
	
    if (funcidx("Phoenix_OnGameModeInit") != -1)
    {
        return CallLocalFunction("Phoenix_OnGameModeInit", "");
    }
    return 1;
}  

#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit Phoenix_OnGameModeInit