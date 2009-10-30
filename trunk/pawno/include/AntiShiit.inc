/*  
*        
*        The contents of this file are subject to the eRP Private Licence
*        Version 1.0 (the "License"); you may not use this file except in
*        compliance with the License. 
*        
*        Software distributed under the License is distributed on an "AS IS"
*        basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*        License for the specific language governing rights and limitations
*        under the License.
*        
*        The Project Name is AntiShiit.
*        The Developer of the Project is Jyrno42.
*        The Owner of the Project is eRP Gaming.
*        
*/
// Launcher.inc

#define DistanceCheck(%0,%1,%2,%3,%4,%5) \
((((%0) - (%3)) * ((%0) - (%3))) + (((%1) - (%4)) * ((%1) - (%4))) + (((%2) - (%5)) * ((%2) - (%5)))) // Y_Less's macro.

#define COLOR_KICK 0xAA3333AA

#if !defined ANTISHIIT_PORT
	#define ANTISHIIT_PORT 7777
#endif

/*************************************************/
/*************************************************/
/********************NATIVES*******************/
/*************************************************/
/*************************************************/

native StartAntiShiitServer(port);
native StopAntiShiitServer();
native aToggleKick(toggle);

native AntiShiitPlayerConnect(playerid, ip[]);
native AntiShiitPlayerDisconnect(playerid);

native RegisterStream(url[], Float: defaultVolume);
native PlayStream(playerid, streamid);
native StreamSetVolume(playerid, streamid, Float: volume);

forward TimerFor3DSound();
forward Add3DStream(url[], Float: x, Float: y, Float: z, Float: radius);

enum streaminf
{
	Float: stream3X,
	Float: stream3Y,
	Float: stream3Z,
	Float: stream3r
};
new threeDeeStreams[10][streaminf];
new reg3D = 0;
new threeDeeTimer = -1;
new BeenInRange[MAX_PLAYERS][10];

/*************************************************/
/*************************************************/
/******************IMPLEMENT*****************/
/*************************************************/
/*************************************************/

public OnGameModeInit()
{
	StartAntiShiitServer(ANTISHIIT_PORT);
	threeDeeTimer = SetTimer("TimerFor3DSound", 1000, 1);
	
	#if defined ANTISHIIT_KICK
		aToggleKick(1);
	#else 
		aToggleKick(0);
	#endif	
	
    if (funcidx("Launcher_OnGameModeInit") != -1)
    {
        return CallLocalFunction("Launcher_OnGameModeInit", "");
    }
    return 1;
}

public OnGameModeExit()
{
	StopAntiShiitServer();
	KillTimer(threeDeeTimer);
	
    if (funcidx("Launcher_OnGameModeExit") != -1)
    {
        return CallLocalFunction("Launcher_OnGameModeExit", "");
    }
    return 1;
}

public OnPlayerConnect(playerid)
{
	LOnPlayerConnect(playerid);
	
    if (funcidx("Launcher_OnPlayerConnect") != -1)
    {
        return CallLocalFunction("Launcher_OnPlayerConnect", "i", playerid);
    }	
    return 1;	
}

public OnPlayerDisconnect(playerid)
{
	LOnPlayerDisconnect(playerid);
	
    if (funcidx("Launcher_OnPlayerDisconnect") != -1)
    {
        return CallLocalFunction("Launcher_OnPlayerDisconnect", "i", playerid);
    }	
    return 1;	
}

#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit Launcher_OnGameModeInit


#if defined _ALS_OnGameModeExit
    #undef OnGameModeExit
#else
    #define _ALS_OnGameModeExit
#endif
#define OnGameModeExit Launcher_OnGameModeExit

#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect Launcher_OnPlayerConnect

#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect Launcher_OnPlayerDisconnect

forward Launcher_OnGameModeInit();
forward Launcher_OnGameModeExit();
forward Launcher_OnPlayerConnect(playerid);
forward Launcher_OnPlayerDisconnect(playerid);

public TimerFor3DSound()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i)) continue;
		new Float: dX, Float: dY, Float: dZ, Float: playerDistance;
		GetPlayerPos(i, dX, dY, dZ);
		
		for(new s; s < reg3D; s++)
		{
			playerDistance = floatsqroot(DistanceCheck(dX, dY, dZ, threeDeeStreams[s][stream3X], threeDeeStreams[s][stream3Y], threeDeeStreams[s][stream3Z]));
			if(playerDistance < threeDeeStreams[s][stream3r])
			{
				if(BeenInRange[i][s] == 0)
				{
					PlayStream(i, s);
				}
				StreamSetVolume(i, s, (threeDeeStreams[s][stream3r]-playerDistance)/threeDeeStreams[s][stream3r]);
				BeenInRange[i][s] = 1;
			}
			else if(BeenInRange[i][s] == 1)
			{
				StreamSetVolume(i, s, 0.0);
				BeenInRange[i][s] = 0;
			}
		}
	}
}

public Add3DStream(url[], Float: x, Float: y, Float: z, Float: radius)
{
	if(reg3D == 10) reg3D = 0;
	
	new myStream = RegisterStream(url, 0.0);
	threeDeeStreams[myStream][stream3X] = x;
	threeDeeStreams[myStream][stream3Y] = y;
	threeDeeStreams[myStream][stream3Z] = z;
	threeDeeStreams[myStream][stream3r] = radius;
	
	reg3D++;
	return myStream;
}

/*************************************************/
/*************************************************/
/********************STOCKS*******************/
/*************************************************/
/*************************************************/
stock LOnPlayerConnect(playerid)
{
	new ip[16];
	GetPlayerIp(playerid, ip, sizeof(ip));
	AntiShiitPlayerConnect(playerid, ip);	
	return 1;
}

stock LOnPlayerDisconnect(playerid)
{
	AntiShiitPlayerDisconnect(playerid);
	return 1;	
}

/*************************************************/
/*************************************************/
/***************PAWNHANDLERS**************/
/*************************************************/
/*************************************************/

/*************************************************/
/******************FORWARDS*****************/
/*************************************************/

/************HELPER FUNCTIONS*************/
forward KickPlayer(playerid);

/**************SAMP FUNCTIONS**************/
forward sampKickPlayer(playerid, reason[]);
forward sampSendClientMessage(playerid, color, msg[]);


/*************************************************/
/************HELPER FUNCTIONS*************/
/*************************************************/
public KickPlayer(playerid) Kick(playerid);

/*************************************************/
/**************SAMP FUNCTIONS**************/
/*************************************************/

public sampKickPlayer(playerid, reason[])
{
	SendClientMessage(playerid, COLOR_KICK, reason);
	SetTimerEx("KickPlayer", 3000, 0, "i", playerid);	
}

public sampSendClientMessage(playerid, color, msg[])
{
	SendClientMessage(playerid, color, msg);
}