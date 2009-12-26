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
#define MAX_JOBCOMMANDS 10

/*
*    Global Variables
*/
new gMyJob[MAX_PLAYERS];
new gMyContract[MAX_PLAYERS];

new pJobRequest[MAX_PLAYERS];
new pJobRequestT[MAX_PLAYERS];

new bool: gJobsRegistred[MAX_JOBS];

new gJobsPay[MAX_JOBS];
new gJobsTime[MAX_JOBS];
new bool: gJobsPayH[MAX_JOBS];

new gJobsNames[MAX_JOBS][32];
new gJobsArray[MAX_JOBS][32];

Itter_Create(Jobs, MAX_JOBS);

enum jobCMD
{
	jCmd[32],
	jobID	
};	
new JobCommands[MAX_JOBCOMMANDS][jobCMD];
Itter_Create(JobCommand, MAX_JOBCOMMANDS);

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

forward JOBS_RegisterJob(id, string[], safeString[], bool: payPerHour, payAmount, cTime);
forward SetPlayerJob(playerid, jobId, cTime);

/*
*    Custom Callbacks
*/

forward AddAllJobs();
forward OnPlayerRequestJob(playerid, jobId);
forward OnPlayerJobChange(playerid, bool: success);
forward AddJobCommand(jobId, myCommand[]);
	
/*
*    ALS NEXT ONES
*/

forward JobSystem_OnGameModeInit();
forward JobSystem_OnPlayerConnect(playerid);
forward JobSystem_OnPlayerDisconnect(playerid);

/*
*    Public
*/
public JOBS_RegisterJob(id, string[], safeString[], bool: payPerHour, payAmount, cTime)
{
	format(gJobsArray[id], 32, "%s", string);
	format(gJobsNames[id], 32, "%s", safeString);
	gJobsRegistred[id] = true;
	gJobsPayH[id] = payPerHour;
	gJobsPay[id] = payAmount;
	gJobsTime[id] = cTime;	
	Itter_Add(Jobs, id);
}

public SetPlayerJob(playerid, jobId, cTime)
{
	if(!gJobsRegistred[jobId]) return 0;
	
	if(gMyJob[playerid] == 0)
	{
		gMyJob[playerid] = jobId;
		gMyContract[playerid] = (cTime > 0)?cTime:5;
		OnPlayerJobChange(playerid, true);
	}
	else OnPlayerJobChange(playerid, false);

	return 1;
}

public AddJobCommand(jobId, myCommand[])
{
	new freeId = Itter_Free(JobCommand);
	if(freeId == -1) return -1;
	
	JobCommands[freeId][jobID] = jobId;
	format(JobCommands[freeId][jCmd], 32, "/%s", myCommand);
	
	Itter_Add(JobCommand, freeId);
	return freeId;
}

COMMAND:t88abi(playerid, params[])
{
	#pragma unused params
	if(gMyJob[playerid] < 1 || gMyJob[playerid] > MAX_JOBS || !gJobsRegistred[gMyJob[playerid]])
	{
		return SendClientMessage(playerid, COLOR_RED, "Sul pole töökohta.");
	}
	
	SendClientMessage(playerid, COLOR_GREEN, "*** Tööabi ***");
	foreach(JobCommand, i)
	{
		if(JobCommands[i][jobID] == gMyJob[playerid])
		{
			SendClientMessage(playerid, COLOR_GREEN, JobCommands[i][jCmd]);
		}
	}	
	SendClientMessage(playerid, COLOR_GREEN, "**************");
	return 1;
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