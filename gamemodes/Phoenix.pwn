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
*    INCLUDES
*/

#include <a_samp>
#include <a_mysql>
#include <phoenix_Core>
#include <phoenix_Lang>

/*
*    DEFINES
*/

#define SCRIPT_NAME			"Phoenix"
#define SCRIPT_VERSION  	"0.1"
#define SCRIPT_REVISION 	4

#define MYSQL_HOST			"localhost"
#define MYSQL_USER			"root"
#define MYSQL_DB			"phoenix"
#define MYSQL_PREFIX		"ph_"

#define COLOR_YELLOW		0xFFFF00AA

/*
*    GLOBAL VARIABLES
*/

new WelcomeStr[32];

/*
*    FORWARDS
*/

/*
*    MAIN()
*/

main()
{
	print("FIREBIRDIE HAS MAIN()");
}

/*
*    STOCKS
*/

/*
*    NATIVES
*/

public OnGameModeInit()
{
	// First things first, lets attempt to connect to database.
	new Connection = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_DB, MYSQL_PASSWORD);
	if(!Connection)
	{
		printf(LANG_FAILED_TO_CONNECT, SCRIPT_NAME);
		SendRconCommand("exit");
		return 1;
	}
	printf(LANG_CONNECTED, SCRIPT_NAME);

	new string[24]; // 24 should be enough.
	format(string, 24, "%s %s r%d", SCRIPT_NAME, SCRIPT_VERSION, SCRIPT_REVISION);
	SetGameModeText(string);
	
	printf(LANG_LOADED, SCRIPT_NAME, SCRIPT_VERSION, SCRIPT_REVISION, SCRIPTER_NAME);
	
	format(WelcomeStr, 32, LANG_WELCOME_TO, SCRIPT_NAME, SCRIPT_VERSION, SCRIPT_REVISION, SCRIPTER_NAME);
	
	return 1;
}

public OnGameModeExit()
{
	printf(LANG_UNLOADED, SCRIPT_NAME, SCRIPT_VERSION, SCRIPT_REVISION, SCRIPTER_NAME);
	return 1;
}

public OnPlayerConnect(playerid)
{
	SendClientMessage(playerid, COLOR_YELLOW, WelcomeStr);
	return 1;
}

/*
*    PUBLICS
*/

/*
*    EOF
*/