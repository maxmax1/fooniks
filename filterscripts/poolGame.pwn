#include <a_samp>

#define MAX_GAMES 3
#define MAX_BALLS 16

#define BALL_CUE	0
#define BALL_8		1

#define BALL_1		2
#define BALL_2		3
#define BALL_3		4
#define BALL_4		5
#define BALL_5		6
#define BALL_6		7
#define BALL_7		8

#define BALL_1_S	9
#define BALL_2_S	10
#define BALL_3_S	11
#define BALL_4_S	12
#define BALL_5_S	13
#define BALL_6_S	14
#define BALL_7_S	15

#define OB_WHITE	3003
#define OB_1		3002
#define OB_2		3100
#define OB_3		3101
#define OB_4		3102
#define OB_5		3103
#define OB_6		3104
#define OB_7		3105
#define OB_1_S		2995
#define OB_2_S		2996
#define OB_3_S		2997
#define OB_4_S		2998
#define OB_5_S		2999
#define OB_6_S		3000
#define OB_7_S		3001
#define OB_8		3106

#define DistanceCheck2D(%0,%1,%2,%3) \
((((%0) - (%2)) * ((%0) - (%2))) + (((%1) - (%3)) * ((%1) - (%3)))) // Y_Less's macro.
#define COLOR_YELLOW		0xFFFF00AA

//		FÜÜSIKA
#define CUE_CONST 10	// kg·m/s2
#define BALL_WEIGHT 0.156 // kg
#define TIP_t_CONST 0.01 //
#define BALL_DIAMETER 0.05

enum bgInf
{
	Float: tablePos[3],
	timer,
	
	balls[MAX_BALLS],
	Float: ballX[MAX_BALLS],
	Float: ballY[MAX_BALLS],
	Float: ballZ[MAX_BALLS],
	
	Float: ballStartX[MAX_BALLS],
	Float: ballStartY[MAX_BALLS],
	
	Float: ballSpeed[MAX_BALLS],
	ballMoving[MAX_BALLS]
};
new Games[MAX_GAMES][bgInf];
new freeId = 0;

new onShot[MAX_PLAYERS];
new myGame[MAX_PLAYERS];

stock nearPoolTable(playerid)
{
	for(new i; i < MAX_GAMES; i++)
	{
		if(IsPlayerInRangeOfPoint(playerid, 2.5, Games[i][tablePos][0], Games[i][tablePos][1], Games[i][tablePos][2]))
		{
			return i;
		}
	}
	return -1;
}

stock GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance) // author: UnKnown, External Credit #7
{
	new Float:a;
	GetPlayerPos(playerid, x, y, a);
	GetPlayerFacingAngle(playerid, a);
	if (GetPlayerVehicleID(playerid))
	{
	    GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	}
	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
}

PreloadAnimLib(playerid, animlib[])
{
	ApplyAnimation(playerid,animlib,"null",0.0,0,0,0,0,0);
}

Anim(playerid,animlib[],animname[], Float:Speed, looping, lockx, locky, lockz, lp)
{
    ApplyAnimation(playerid, animlib, animname, Speed, looping, lockx, locky, lockz, lp);
}

/*
*    FORWARDS
*/

forward endShot(playerid, set);
forward poolPostition(playerid, type, offset);
forward AddGame(Float: posX, Float: posY, Float: posZ);
forward GameTimer(game);

/*
*    PUBLICS
*/

public endShot(playerid, set)
{
	if(set == 1)
	{
		Anim(playerid, "POOL", "POOL_Med_Shot_O", 1.0, 0, 1, 1, 1, 0);
		SetTimerEx("endShot", 250, 0, "ii", playerid, 0);
		return 1;
	}

	TogglePlayerControllable(playerid, 1);
	PreloadAnimLib(playerid, "POOL");
	ClearAnimations(playerid);
	onShot[playerid] = false;
	SetCameraBehindPlayer(playerid);
	myGame[playerid] = -1;
	return 0;
}

public poolPostition(playerid, type, offset)
{
	GivePlayerWeapon(playerid, 7, 1);
	PreloadAnimLib(playerid, "POOL");

	if(type == 1)
	{
		if(offset == 1) 		Anim(playerid, "POOL", "POOL_Short_Shot", 1.0, 0, 1, 1, 1, 0);
		else if(offset == 2) 	Anim(playerid, "POOL", "POOL_Short_Shot_O", 1.0, 1, 1, 1, 1, 0);
		else if(offset == 3) 	Anim(playerid, "POOL", "POOL_Short_Start", 1.0, 0, 1, 1, 1, 0);
		else if(offset == 4) 	Anim(playerid, "POOL", "POOL_Short_Start_O", 1.0, 0, 1, 1, 1, 0);
	}
	else if(type == 2)
	{
		if(offset == 1) 		Anim(playerid, "POOL", "POOL_Med_Shot", 1.0, 0, 1, 1, 1, 0);
		else if(offset == 2) 	Anim(playerid, "POOL", "POOL_Med_Shot_O", 1.0, 1, 1, 1, 1, 0);
		else if(offset == 3) 	Anim(playerid, "POOL", "POOL_Med_Start", 1.0, 0, 1, 1, 1, 0);
		else if(offset == 4) 	Anim(playerid, "POOL", "POOL_Med_Start_O", 1.0, 0, 1, 1, 1, 0);
	}
	else if(type == 3)
	{
		if(offset == 1) 		Anim(playerid, "POOL", "POOL_Long_Shot", 1.0, 0, 1, 1, 1, 0);
		else if(offset == 2) 	Anim(playerid, "POOL", "POOL_Long_Shot_O", 1.0, 1, 1, 1, 1, 0);
		else if(offset == 3) 	Anim(playerid, "POOL", "POOL_Long_Start", 1.0, 0, 1, 1, 1, 0);
		else if(offset == 4) 	Anim(playerid, "POOL", "POOL_Long_Start_O", 1.0, 0, 1, 1, 1, 0);
	}
}

public AddGame(Float: posX, Float: posY, Float: posZ)
{
	Games[freeId][tablePos][0] = posX;
	Games[freeId][tablePos][1] = posY;
	Games[freeId][tablePos][2] = posZ;
	
	Games[freeId][balls][BALL_CUE] = CreateObject(OB_WHITE, posX, (posY+0.47), posZ, 0, 0, 0);
	Games[freeId][ballX][BALL_CUE] = posX;
	Games[freeId][ballY][BALL_CUE] = (posY+0.47);
	Games[freeId][ballZ][BALL_CUE] = posZ;
	
	// rida 1
	Games[freeId][balls][BALL_1] = CreateObject(OB_1, posX, (posY-0.47), posZ, 0, 0, 0);
	Games[freeId][ballX][BALL_1] = posX;
	Games[freeId][ballY][BALL_1] = (posY-0.47);
	Games[freeId][ballZ][BALL_1] = posZ;
	
	// rida 2
	Games[freeId][balls][BALL_2] = CreateObject(OB_2, posX+BALL_DIAMETER, posY-(0.47+BALL_DIAMETER), posZ, 0, 0, 0);
	Games[freeId][ballX][BALL_2] = posX+BALL_DIAMETER;
	Games[freeId][ballY][BALL_2] = posY-(0.47+BALL_DIAMETER);
	Games[freeId][ballZ][BALL_2] = posZ;
	
	Games[freeId][balls][BALL_1_S] = CreateObject(OB_1_S, posX-BALL_DIAMETER, posY-(0.47+BALL_DIAMETER), posZ, 0, 0, 0);
	Games[freeId][ballX][BALL_1_S] = posX-BALL_DIAMETER;
	Games[freeId][ballY][BALL_1_S] = posY-(0.47+BALL_DIAMETER);
	Games[freeId][ballZ][BALL_1_S] = posZ;
	
	// rida 3
	Games[freeId][balls][BALL_2_S] = CreateObject(OB_2_S, posX, posY-(0.47+(BALL_DIAMETER*2)), posZ, 0, 0, 0);
	Games[freeId][ballX][BALL_2_S] = posX;
	Games[freeId][ballY][BALL_2_S] = posY-(0.47+(BALL_DIAMETER*2));
	Games[freeId][ballZ][BALL_2_S] = posZ;
	
	Games[freeId][balls][BALL_3_S] = CreateObject(OB_3_S, posX-(BALL_DIAMETER*2), posY-(0.47+(BALL_DIAMETER*2)), posZ, 0, 0, 0);
	Games[freeId][ballX][BALL_3_S] = posX-(BALL_DIAMETER*2);
	Games[freeId][ballY][BALL_3_S] = posY-(0.47+(BALL_DIAMETER*2));
	Games[freeId][ballZ][BALL_3_S] = posZ;
	
	Games[freeId][balls][BALL_3] = CreateObject(OB_3, posX+(BALL_DIAMETER*2), posY-(0.47+(BALL_DIAMETER*2)), posZ, 0, 0, 0);
	Games[freeId][ballX][BALL_3] = posX+(BALL_DIAMETER*2);
	Games[freeId][ballY][BALL_3] = posY-(0.47+(BALL_DIAMETER*2));
	Games[freeId][ballZ][BALL_3] = posZ;
	
	// rida 4
	Games[freeId][balls][BALL_5_S] = CreateObject(OB_5_S, posX+BALL_DIAMETER, posY-(0.47+(BALL_DIAMETER*3)), posZ, 0, 0, 0);
	Games[freeId][ballX][BALL_5_S] = posX+BALL_DIAMETER;
	Games[freeId][ballY][BALL_5_S] = posY-(0.47+(BALL_DIAMETER*3));
	Games[freeId][ballZ][BALL_5_S] = posZ;
	
	Games[freeId][balls][BALL_5] = CreateObject(OB_5, posX-BALL_DIAMETER, posY-(0.47+(BALL_DIAMETER*3)), posZ, 0, 0, 0);
	Games[freeId][ballX][BALL_5] = posX-BALL_DIAMETER;
	Games[freeId][ballY][BALL_5] = posY-(0.47+(BALL_DIAMETER*3));
	Games[freeId][ballZ][BALL_5] = posZ;	
	
	Games[freeId][balls][BALL_4] = CreateObject(OB_4, posX+(BALL_DIAMETER*3), posY-(0.47+(BALL_DIAMETER*3)), posZ, 0, 0, 0);
	Games[freeId][ballX][BALL_4] = posX+(BALL_DIAMETER*3);
	Games[freeId][ballY][BALL_4] = posY-(0.47+(BALL_DIAMETER*3));
	Games[freeId][ballZ][BALL_4] = posZ;
	
	Games[freeId][balls][BALL_4_S] = CreateObject(OB_4_S, posX-(BALL_DIAMETER*3), posY-(0.47+(BALL_DIAMETER*3)), posZ, 0, 0, 0);
	Games[freeId][ballX][BALL_4_S] = posX-(BALL_DIAMETER*3);
	Games[freeId][ballY][BALL_4_S] = posY-(0.47+(BALL_DIAMETER*3));
	Games[freeId][ballZ][BALL_4_S] = posZ;	
	
	// rida 4
	Games[freeId][balls][BALL_8] = CreateObject(OB_8, posX, posY-(0.47+(BALL_DIAMETER*4)), posZ, 0, 0, 0);
	Games[freeId][ballX][BALL_8] = posX;
	Games[freeId][ballY][BALL_8] = posY-(0.47+(BALL_DIAMETER*4));
	Games[freeId][ballZ][BALL_8] = posZ;
	
	Games[freeId][balls][BALL_6] = CreateObject(OB_6, posX-(BALL_DIAMETER*2), posY-(0.47+(BALL_DIAMETER*4)), posZ, 0, 0, 0);
	Games[freeId][ballX][BALL_6] = posX-(BALL_DIAMETER*2);
	Games[freeId][ballY][BALL_6] = posY-(0.47+(BALL_DIAMETER*4));
	Games[freeId][ballZ][BALL_6] = posZ;
	
	Games[freeId][balls][BALL_6_S] = CreateObject(OB_6_S, posX+(BALL_DIAMETER*2), posY-(0.47+(BALL_DIAMETER*4)), posZ, 0, 0, 0);
	Games[freeId][ballX][BALL_6_S] = posX+(BALL_DIAMETER*2);
	Games[freeId][ballY][BALL_6_S] = posY-(0.47+(BALL_DIAMETER*4));
	Games[freeId][ballZ][BALL_6_S] = posZ;
	
	Games[freeId][balls][BALL_7_S] = CreateObject(OB_7_S, posX-(BALL_DIAMETER*4), posY-(0.47+(BALL_DIAMETER*4)), posZ, 0, 0, 0);
	Games[freeId][ballX][BALL_7_S] = posX-(BALL_DIAMETER*4);
	Games[freeId][ballY][BALL_7_S] = posY-(0.47+(BALL_DIAMETER*4));
	Games[freeId][ballZ][BALL_7_S] = posZ;
	
	Games[freeId][balls][BALL_7] = CreateObject(OB_7, posX+(BALL_DIAMETER*4), posY-(0.47+(BALL_DIAMETER*4)), posZ, 0, 0, 0);
	Games[freeId][ballX][BALL_7] = posX+(BALL_DIAMETER*4);
	Games[freeId][ballY][BALL_7] = posY-(0.47+(BALL_DIAMETER*4));
	Games[freeId][ballZ][BALL_7] = posZ;
	
	Games[freeId][timer] = SetTimerEx("GameTimer", 50, 1, "i", freeId);
	freeId++;
}

public GameTimer(game)
{
	for(new i = 0; i < MAX_BALLS; i++)
	{
		if(Games[game][ballMoving][i])
		{
			GetObjectPos(Games[game][balls][i], Games[game][ballX][i], Games[game][ballY][i], Games[game][ballZ][i]);
			if(Games[game][ballX][i] > (Games[game][tablePos][0]+0.47))
			{
				StopObject(Games[game][balls][i]);
				SendClientMessage(0, COLOR_YELLOW, "Stop.1");
				
				new Float: vecBX = Games[game][ballX][i] - Games[game][ballStartX][i];
				new Float: vecBY = Games[game][ballY][i] - Games[game][ballStartY][i];
				new Float: vecBL = floatsqroot(floatpower(vecBX, 2) + floatpower(vecBY, 2));
				
				new Float: vecWX = (Games[game][tablePos][0]+0.47)-(Games[game][tablePos][0]+0.47);
				new Float: vecWY = (Games[game][tablePos][1]+0.94)-(Games[game][tablePos][1]-0.94);
				new Float: vecWL = floatsqroot(floatpower(vecWX, 2) + floatpower(vecWY, 2));
				
				new Float: beta = 90 - ((vecBX * vecWX) + (vecBY * vecWY) / vecBL * vecWL);
				
				// VAATA SIIA
				// uue vektori arvutamisel nurga järgi tekib probleem...:(				
				
				new Float: newX2 = Games[game][ballX][i]+0.04;
				new Float: newY2 = beta*(newX2 - Games[game][ballX][i]) + (Games[game][ballY][i]);
				
				MoveObject(Games[game][balls][i], newX2, newY2, Games[game][ballZ][i], (Games[game][ballSpeed][BALL_CUE]*0.5));
				Games[game][ballSpeed][BALL_CUE] = 1.0;
				Games[game][ballMoving][BALL_CUE] = 0;
				
				new str[128];
				format(str, 128, "(%f %f %f)", newX2, newY2, Games[game][ballY][i]);
				SendClientMessage(0, COLOR_YELLOW, str);
			}
			if(Games[game][ballX][i] < (Games[game][tablePos][0]-0.47))
			{
				StopObject(Games[game][balls][i]);
				Games[game][ballMoving][i] = 0;
				SendClientMessage(0, COLOR_YELLOW, "Stop.2");
			}
			if(Games[game][ballY][i] > (Games[game][tablePos][1]+0.94))
			{
				StopObject(Games[game][balls][i]);
				Games[game][ballMoving][i] = 0;
				SendClientMessage(0, COLOR_YELLOW, "Stop.3");
			}
			if(Games[game][ballY][i] < (Games[game][tablePos][1]-0.94))
			{
				StopObject(Games[game][balls][i]);
				Games[game][ballMoving][i] = 0;
				SendClientMessage(0, COLOR_YELLOW, "Stop.4");
			}
		}
	}
}

/*
*    SA-MP Natives
*/

public OnFilterScriptInit()
{
	AddGame(510.12, -84.84, 998.867);
}

public OnObjectMoved(objectid)
{
	for(new i1 = 0; i1 < freeId; i1++)
	{
		for(new i = 0; i < MAX_BALLS; i++)
		{	
			if(objectid == Games[i1][balls][i])
			{
				Games[i1][ballMoving][i] = 0;
				GetObjectPos(Games[i1][balls][i], Games[i1][ballX][i], Games[i1][ballY][i], Games[i1][ballZ][i]);
				SendClientMessage(0, COLOR_YELLOW, "oStop.");
			}
		}
	}
}

public OnFilterScriptExit()
{
	for(new i; i < MAX_BALLS; i++)
	{
		if(Games[0][balls][i] == 0) continue;
		DestroyObject(Games[0][balls][i]);
	}
	KillTimer(Games[0][timer]);
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys == KEY_WALK)
	{
		if(onShot[playerid])
		{
			endShot(playerid, 1);
		}
		else
		{
			new i = nearPoolTable(playerid);
			if(i != -1)
			{
				onShot[playerid] = true;
				myGame[playerid] = i;
				poolPostition(playerid, 3, 3);
				
				new Float: tx, Float: ty, Float: sz;
				new Float:a;				
				GetPlayerPos(playerid, tx, ty, sz);
				GetPlayerFacingAngle(playerid, a);				
				
				SetPlayerCameraPos(playerid, tx, ty, sz+1.0);
				SetPlayerCameraLookAt(playerid, tx+(1.0 * floatsin(-a, degrees)), ty+(1.0 * floatcos(-a, degrees)), sz);			
			}
		}
	}
	else if(newkeys == KEY_FIRE)
	{
		if(onShot[playerid])
		{
			// kii ots, 1 unit playeri ees.
			new Float: x, Float: y, game = myGame[playerid];
			GetXYInFrontOfPlayer(playerid, x, y, 1.0);
			
			if(DistanceCheck2D(x, y, Games[game][ballX][BALL_CUE], Games[game][ballY][BALL_CUE]) > 0.1)
			{
				SendClientMessage(playerid, COLOR_YELLOW, "Sa pead lööma valget palli.");
			}
			else
			{			
				GetXYInFrontOfPlayer(playerid, x, y, 2.0);
				GetObjectPos(Games[game][balls][BALL_CUE], Games[game][ballStartX][BALL_CUE], Games[game][ballStartY][BALL_CUE], Games[game][ballZ][BALL_CUE]);
				MoveObject(Games[game][balls][BALL_CUE], x, y, Games[game][ballZ][BALL_CUE], 2.0);
				Games[game][ballSpeed][BALL_CUE] = 2.0;
				Games[game][ballMoving][BALL_CUE] = 1;
				poolPostition(playerid, 3, 1);
				SetTimerEx("endShot", 1000, 0, "ii", playerid, 1);	
			}
		}
	}
}