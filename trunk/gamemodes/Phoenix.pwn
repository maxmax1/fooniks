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
#define SCRIPT_REVISION 	1

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
		printf("\t\t* %s - %s", SCRIPT_NAME, LANG_FAILED_TO_CONNECT);
		SendRconCommand("exit");
		return 1;
	}
	printf("\t\t* %s - %s", SCRIPT_NAME, LANG_CONNECTED);

	new string[24]; // 24 should be enough.
	format(string, 24, "%s %s r%d", SCRIPT_NAME, SCRIPT_VERSION, SCRIPT_REVISION);
	SetGameModeText(string);
	printf("\t\t* %s-%sr%s-%s %s.", SCRIPT_NAME, SCRIPT_VERSION, SCRIPT_REVISION, SCRIPTER_NAME, LANG_LOADED);
	format(WelcomeStr, 32, "%s %s-%sr%s-%s", LANG_WELCOME_TO, SCRIPT_NAME, SCRIPT_VERSION, SCRIPT_REVISION, SCRIPTER_NAME);
	
	return 1;
}

public OnGameModeExit()
{
	printf("\t\t* %s-%sr%s-%s %s.", SCRIPT_NAME, SCRIPT_VERSION, SCRIPT_REVISION, SCRIPTER_NAME, LANG_UNLOADED);
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