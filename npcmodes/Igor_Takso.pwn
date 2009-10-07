#include <a_npc>

#define IDLE_FORMAT 	"%s_IDLE"
#define TRAVEL_FORMAT 	"%s_TO_%s"

#define WAYPOINTS		3

#define ACTION_IDLE		0
#define ACTION_DRIVING	1

new cWaypoint = 0;
new cTravelTo = 0;
new cAction = ACTION_IDLE;
new gStoppedForTraffic;

new waypoints[WAYPOINTS][32] =
{
	"LSPD",
	"UNITY",
	"PIGPEN"
};

stock getRecFile(str[], point, nextPoint, action)
{
	if(action == ACTION_IDLE) format(str, 32, IDLE_FORMAT, waypoints[point]);
	else format(str, 32, TRAVEL_FORMAT, waypoints[point], waypoints[nextPoint]);
}

main(){}

public OnRecordingPlaybackEnd()
{
	if(cAction == ACTION_IDLE) // We are Idle.
	{
		new str[32];
		getRecFile(str, cWaypoint, cTravelTo, cAction);
		StartRecordingPlayback(1, str);
	}
	else // we Were driving.
	{
		cWaypoint = cTravelTo;
		cAction = ACTION_IDLE;
		
		new str[32];
		getRecFile(str, cWaypoint, cTravelTo, cAction);
		StartRecordingPlayback(1, str);
		SendChat("jõudsime sihtkohta!");
	}
}

public OnNPCEnterVehicle(vehicleid, seatid)
{
	cWaypoint = 0;
	cTravelTo = 0;
	cAction = ACTION_IDLE;
	new str[32];
	getRecFile(str, cWaypoint, cTravelTo, cAction);
	StartRecordingPlayback(1, str);
}



public OnNPCSpawn()
{
	
}

public OnClientMessage(color, text[])
{
	new str[128];
	if(strfind(text, "tere", true) != -1 || strfind(text, "igor", true) != -1)
	{
		SendChat("Tere jah.");
		
		new string[96];
		for(new i = 0; i < WAYPOINTS; i++)
		{
			if(strlen(string) > 90) continue;
			format(string, 128, "%s %s", string, waypoints[i]);
		}
		
		format(str, 128, "Kuhu sõidame? ((%s ))", string);
		SendChat(str);
	}
	
	new cmd = -1;
	for(new i = 0; i < WAYPOINTS; i++)
	{
		if(strfind(text, waypoints[i], true) != -1) cmd = i;
	}
	if(cmd != -1)
	{
		if(cAction == ACTION_IDLE)
		{
			cTravelTo = cmd;
			cAction = ACTION_DRIVING;
			
			getRecFile(str, cWaypoint, cTravelTo, cAction);
			StartRecordingPlayback(1, str);
			SendChat("sõidame...");
		}
		else SendChat("Ma ole hetkel hõivatud!");
	}
}

stock GetXYInfrontOfMe(Float:distance, &Float:x, &Float:y)
{
    new Float:z, Float:angle;
    GetMyPos(x,y,z);
    GetMyFacingAngle(angle);
    x += (distance * floatsin(-angle, degrees));
    y += (distance * floatcos(-angle, degrees));
}

LookForAReasonToPause()
{
  	new Float:X,Float:Y,Float:Z;
	new x=0;

	GetMyPos(X,Y,Z);
	GetXYInfrontOfMe(11.0, X, Y);

	while(x!=MAX_PLAYERS)
	{
	    if(IsPlayerConnected(x) && IsPlayerStreamedIn(x))
		{
			if( GetPlayerState(x) == PLAYER_STATE_DRIVER || GetPlayerState(x) == PLAYER_STATE_ONFOOT )
			{
				if(IsPlayerInRangeOfPoint(x,11.0,X,Y,Z))
				{
					return 1;
				}
			}
		}
		x++;
	}
	return 0;
}

public OnNPCModeInit()
{
	SetTimer("ScanTimer",200,1);
}

forward ScanTimer();
public ScanTimer()
{
    new ReasonToPause = LookForAReasonToPause();

	if(ReasonToPause && !gStoppedForTraffic)
	{
		PauseRecordingPlayback();
		gStoppedForTraffic = 1;
	}
	else if(!ReasonToPause && gStoppedForTraffic)
	{
	    ResumeRecordingPlayback();
	    gStoppedForTraffic = 0;
	}
}

