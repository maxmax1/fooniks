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
*    This File: phoenix_JobSystem.inc
*    Purpose: This is for easy job adding.
*/

#if defined _phoenix_JobSystem_included
  #endinput
#endif
#define _phoenix_JobSystem_included
#pragma library phoenix_JobSystem

/*
*    Defines 
*/
#define MAX_JOBS 5

/*
*    Global Variables
*/
new gMyJob[MAX_PLAYERS];
new gJobsArray[MAX_JOBS][32];

Itter_Create(Jobs, MAX_JOBS);

/*
*    Macro Defines
*/

#define JOBS_OnJobInit(%0) \
				forward JobModeInit_%0(); \
				public JobModeInit_%0()

#define JOBS_OnPlayerConnect(%0) \
				forward JobPConnect_%0(playerid); \
				public JobPConnect_%0(playerid)

#define JOBS_OnPlayerDisconnect(%0) \
				forward JobPDisConnect_%0(playerid); \
				public JobPDisConnect_%0(playerid)

/*
*    Forwards
*/
forward JobSystem_OnGameModeInit();
forward JobSystem_OnPlayerConnect(playerid);
forward JobSystem_OnPlayerDisconnect(playerid);

forward JOBS_RegisterJob(id, string[]);
forward AddAllJobs();

/*
*    Public
*/
public JOBS_RegisterJob(id, string[])
{
	format(gJobsArray[id], 32, "%s", string);
	Itter_Add(Jobs, id);
}

/*
*    Silent Implentation
*/

public OnGameModeInit()
{
	AddAllJobs();

	foreach(Jobs, i)
	{	
		new str[45];			
		// Call Init functions
		format(str, 45, "JobModeInit_%s", gJobsArray[i]);
		if (funcidx(str) != -1)
		{
			CallLocalFunction(str, "");
		}
	}
	
    if (funcidx("JobSystem_OnGameModeInit") != -1)
    {
        return CallLocalFunction("JobSystem_OnGameModeInit", "");
    }
    return 1;
}

#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit JobSystem_OnGameModeInit

public OnPlayerConnect(playerid)
{
	foreach(Jobs, i)
	{	
		if(strcmp(gJobsArray[i], ""))
		{
			new str[45];			
			// Call Init functions
			format(str, 45, "JobPConnect_%s", gJobsArray[i]);
			if (funcidx(str) != -1)
			{
				CallLocalFunction(str, "i", playerid);
			}
		}
	}
	
    if (funcidx("JobSystem_OnPlayerConnect") != -1)
    {
        return CallLocalFunction("JobSystem_OnPlayerConnect", "i", playerid);
    }
    return 1;
}

#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect JobSystem_OnPlayerConnect

public OnPlayerDisconnect(playerid)
{
	foreach(Jobs, i)
	{	
		if(strcmp(gJobsArray[i], ""))
		{
			new str[45];			
			// Call Init functions
			format(str, 45, "JobPDisConnect_%s", gJobsArray[i]);
			if (funcidx(str) != -1)
			{
				CallLocalFunction(str, "i", playerid);
			}
		}
	}
	
    if (funcidx("JobSystem_OnPlayerDisconnect") != -1)
    {
        return CallLocalFunction("JobSystem_OnPlayerDisconnect", "i", playerid);
    }
    return 1;
}

#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect JobSystem_OnPlayerDisconnect