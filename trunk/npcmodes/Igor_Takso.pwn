#include <a_npc>

#define IDLE_FORMAT 	"%s_IDLE"
#define TRAVEL_FORMAT 	"%s_TO_%s"

#define WAYPOINTS		3

#define ACTION_IDLE		0
#define ACTION_DRIVING	1

new cWaypoint = 0;
new cTravelTo = 0;
new cAction = ACTION_IDLE;

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
			
			new str[32];
			getRecFile(str, cWaypoint, cTravelTo, cAction);
			StartRecordingPlayback(1, str);
		}
		else SendChat("Igor: Ma ole hetkel hõivatud!");
	}
}