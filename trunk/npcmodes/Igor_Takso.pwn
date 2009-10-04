#include <a_npc>

new cAction = 0;

#define LSPD_IDLE 			0
#define LSPD_TO_UNITY 		1
#define UNITY_IDLE 			2
#define UNITY_TO_LSPD 		3

main(){}
public OnRecordingPlaybackEnd()
{
	if	 		(cAction == LSPD_IDLE) 		StartRecordingPlayback(1, "LSPD_IDLE");
	else if		(cAction == UNITY_IDLE) 	StartRecordingPlayback(1, "UNITY_IDLE");
	else if		(cAction == LSPD_TO_UNITY)
	{
		cAction = UNITY_IDLE;
		StartRecordingPlayback(1, "UNITY_IDLE");
	}
	else if		(cAction == UNITY_TO_LSPD)
	{
		cAction = LSPD_IDLE;
		StartRecordingPlayback(1, "LSPD_IDLE");
	}
}

public OnNPCEnterVehicle(vehicleid, seatid)
{
	cAction = LSPD_IDLE;
	StartRecordingPlayback(1, "LSPD_IDLE");
}


public OnNPCSpawn()
{
	
}

public OnClientMessage(color, text[])
{
	if(cAction == LSPD_IDLE && strfind(text,"Unity") != -1)
	{
		cAction = LSPD_TO_UNITY;
		StartRecordingPlayback(1, "LSPD_TO_UNITY");
	}
	else if(cAction == UNITY_IDLE && strfind(text,"LSPD") != -1)
	{
		cAction = UNITY_TO_LSPD;
		StartRecordingPlayback(1, "UNITY_TO_LSPD");
	}
}