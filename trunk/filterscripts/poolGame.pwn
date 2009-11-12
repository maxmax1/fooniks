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

#define BALL_DIAMETER 0.05

#define WALL_MODIFIER 0.7
#define MAX_SPEED 5

#define DistanceCheck2D(%0,%1,%2,%3) \
((((%0) - (%2)) * ((%0) - (%2))) + (((%1) - (%3)) * ((%1) - (%3)))) // Y_Less's macro.

new FALSE = false;
// author: Alex "Y_Less" Cole, External Credit #6
#define SendFormattedText(%1,%2,%3,%4) do{new sendfstring[128];format(sendfstring,128,(%3),%4);SendClientMessage((%1), (%2) ,sendfstring);}while(FALSE)
#define SendFormattedTextToAll(%1,%2,%3) do{new sendfstring[128];format(sendfstring,128,(%2),%3);SendClientMessageToAll((%1),sendfstring);}while(FALSE)

#define COLOR_YELLOW		0xFFFF33AA
#define COLOR_RED			0xFF3333AA
#define COLOR_GREEN			0x33FF33AA

enum bgInf
{
	Float: tablePos[3],
	timer,
	poolPlayer1,
	poolPlayer2,
	gameOn,
	
	balls[MAX_BALLS],
	ballGone[MAX_BALLS],
	Float: ballX[MAX_BALLS],
	Float: ballY[MAX_BALLS],
	Float: ballZ[MAX_BALLS],
	
	Float: ballStartX[MAX_BALLS],
	Float: ballStartY[MAX_BALLS],
	Float: ballStartSpeed[MAX_BALLS],
	
	Float: ballEndX[MAX_BALLS],
	Float: ballEndY[MAX_BALLS],
	
	Float: ballSpeed[MAX_BALLS],
	ballMoving[MAX_BALLS],
	
	Text: shotDraw
};
new Games[MAX_GAMES][bgInf];
new freeId = 0;

new onShot[MAX_PLAYERS];
new myGame[MAX_PLAYERS];
new speed[MAX_PLAYERS];

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
forward StartGame(game, pl1, pl2);
forward GameTimer(game);
forward CueBall(game, playerid);
forward SetSpeed(playerid, spd, game);
forward OverHeadCam(playerid, game);
forward ResetCam(playerid);
forward ResetBalls(game);
forward endGame(game);
forward IsInHole(game, ball);

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
	if(onShot[playerid] == 1) onShot[playerid] = 0;
	TextDrawHideForPlayer(playerid, Games[myGame[playerid]][shotDraw]);	
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
	
	Games[freeId][shotDraw] = TextDrawCreate(320, 400, "2");
	
	ResetBalls(freeId);
	
	freeId++;
}

public StartGame(game, pl1, pl2)
{
	if(pl1 == pl2)
	{
		SendClientMessage(pl1, COLOR_GREEN, "* Alustasid iseenda vastu piljardi mängimist");
	}
	else
	{
		new str[128], pName[MAX_PLAYER_NAME];

		GetPlayerName(pl1, pName, MAX_PLAYER_NAME);
		format(str, 128, "* Alustasid %s vastu piljardi mängimist.");
		SendClientMessage(pl2, COLOR_GREEN, str);

		GetPlayerName(pl2, pName, MAX_PLAYER_NAME);
		format(str, 128, "* Alustasid %s vastu piljardi mängimist.");
		SendClientMessage(pl1, COLOR_GREEN, str);
	}
	Games[game][poolPlayer1] = pl1;
	Games[game][poolPlayer2] = pl2;
	
	Games[game][timer] = SetTimerEx("GameTimer", 20, 1, "i", game);
	Games[game][gameOn] = true;
}

public GameTimer(game)
{
	for(new i = 0; i < MAX_BALLS; i++)
	{
		if(Games[game][ballGone][i] != 0) continue;
		
		if(Games[game][ballMoving][i])
		{
			GetObjectPos(Games[game][balls][i], Games[game][ballX][i], Games[game][ballY][i], Games[game][ballZ][i]);
			
			new hole = IsInHole(game, i);
			if(hole > 0)
			{
				DestroyObject(Games[game][balls][i]);
				Games[game][ballMoving][i] = 0;
				Games[game][ballGone][i] = 1;
				
				if(i == BALL_CUE)
				{
					SendClientMessage(Games[game][poolPlayer1], COLOR_RED, "* Lõid valge palli auku. Vastase kord");
					Games[game][ballGone][BALL_CUE] = 0;
					
					Games[game][ballX][BALL_CUE] = Games[game][tablePos][0];
					Games[game][ballY][BALL_CUE] = (Games[game][tablePos][1]+0.47);
					Games[game][ballZ][BALL_CUE] = Games[game][tablePos][2];
					Games[game][ballSpeed][BALL_CUE] = 0;
					Games[game][ballEndX][BALL_CUE] = 0;
					Games[game][ballEndY][BALL_CUE] = 0;				
					Games[game][ballStartX][BALL_CUE] = 0;
					Games[game][ballStartY][BALL_CUE] = 0;
					
					Games[game][balls][BALL_CUE] = CreateObject(OB_WHITE, Games[game][ballX][BALL_CUE], Games[game][ballY][BALL_CUE], Games[game][ballZ][BALL_CUE], 0, 0, 0);
				}
				else
				{
					SendClientMessage(Games[game][poolPlayer1], COLOR_RED, "* Lõid palli auku. ++");
				}
				continue;
			}
			
			// Wall Bounce
			if(Games[game][ballX][i] > (Games[game][tablePos][0]+0.47) || Games[game][ballX][i] < (Games[game][tablePos][0]-0.47))
			{
				new Float: backToCord = (Games[game][ballX][i] > (Games[game][tablePos][0]+0.47))?(Games[game][tablePos][0]+0.47):(Games[game][tablePos][0]-0.47);
				SetObjectPos(Games[game][balls][i], backToCord, Games[game][ballY][i], Games[game][ballZ][i]);
				StopObject(Games[game][balls][i]);
				
				new Float: sX = Games[game][ballEndX][i];
				
				new Float: vecTx = Games[game][ballEndX][i] - Games[game][ballStartX][i];
				new Float: vecTy = Games[game][ballEndY][i] - Games[game][ballStartY][i];
				new Float: vecTLen = floatsqroot(floatpower(vecTx, 2) + floatpower(vecTy, 2));
				
				new Float: vecUx = 0;
				new Float: vecUy = (Games[game][tablePos][0]-0.94) - (Games[game][tablePos][0]+0.94);				
				new Float: vecULen = floatsqroot(floatpower(vecUx, 2) + floatpower(vecUy, 2));
					
				new Float: gamma = acos((vecTx * vecUx) + (vecTy * vecUy) / (vecTLen * vecULen));
				
				new Float: k = floattan(180.0 - (gamma-90.0));
				
				new Float: hX = Games[game][ballX][i] - (sX - Games[game][ballX][i]);
				new Float: hY = k * (hX - (backToCord)) + (Games[game][ballY][i]);
				
				SendFormattedText(0, COLOR_GREEN, "%f", gamma);
				
				MoveObject(Games[game][balls][i],  hX, hY, Games[game][ballZ][i], (Games[game][ballSpeed][i]*WALL_MODIFIER));
				
				Games[game][ballSpeed][i] = (Games[game][ballSpeed][i]*WALL_MODIFIER);
				Games[game][ballMoving][i] = 1;
				
				Games[game][ballStartX][i] = Games[game][ballX][i];
				Games[game][ballStartY][i] = Games[game][ballY][i];
				Games[game][ballEndX][i] = hX;
				Games[game][ballEndY][i] = hY;		
			}
			if(Games[game][ballY][i] > (Games[game][tablePos][1]+0.94) || Games[game][ballY][i] < (Games[game][tablePos][1]-0.94))
			{
				new Float: backToCord = (Games[game][ballY][i] > (Games[game][tablePos][1]+0.94))?(Games[game][tablePos][1]+0.94):(Games[game][tablePos][1]-0.94);
				SetObjectPos(Games[game][balls][i], Games[game][ballX][i], backToCord, Games[game][ballZ][i]);
				StopObject(Games[game][balls][i]);
				
				new Float: sY = Games[game][ballEndY][i];
				
				new Float: vecTx = Games[game][ballEndX][i] - Games[game][ballStartX][i];
				new Float: vecTy = Games[game][ballEndY][i] - Games[game][ballStartY][i];
				new Float: vecTLen = floatsqroot(floatpower(vecTx, 2) + floatpower(vecTy, 2));
				
				new Float: vecUx = (Games[game][tablePos][1]-0.47) - (Games[game][tablePos][1]+0.47);	
				new Float: vecUy = 0;			
				new Float: vecULen = floatsqroot(floatpower(vecUx, 2) + floatpower(vecUy, 2));
					
				new Float: gamma = acos((vecTx * vecUx) + (vecTy * vecUy) / (vecTLen * vecULen));
				
				new Float: k = floattan(180.0 - (gamma-90.0));
				
				new Float: hY = Games[game][ballY][i] - (sY - Games[game][ballY][i]);
				new Float: hX = k * (hY - (backToCord)) + (Games[game][ballX][i]);
				
				MoveObject(Games[game][balls][i],  hX, hY, Games[game][ballZ][i], (Games[game][ballSpeed][i]*WALL_MODIFIER));
				
				Games[game][ballSpeed][i] = (Games[game][ballSpeed][i]*WALL_MODIFIER);
				Games[game][ballMoving][i] = 1;
				
				Games[game][ballStartX][i] = Games[game][ballX][i];
				Games[game][ballStartY][i] = Games[game][ballY][i];
				Games[game][ballEndX][i] = hX;
				Games[game][ballEndY][i] = hY;		
			}
			
			// Palli kiiruse vähendamine...
			if(Games[game][ballSpeed][i] > 0)
			{
			
				StopObject(Games[game][balls][i]);
				Games[game][ballSpeed][i] -= 0.025;
				if(Games[game][ballSpeed][i] > 0)
				{
					MoveObject(Games[game][balls][i],  Games[game][ballEndX][i], Games[game][ballEndY][i], Games[game][ballZ][i], Games[game][ballSpeed][i]);
				}
			}
			else
			{
				StopObject(Games[game][balls][i]);
				GetObjectPos(Games[game][balls][i], Games[game][ballX][i], Games[game][ballY][i], Games[game][ballZ][i]);
				Games[game][ballMoving][i] = 0;
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
	AddGame(506.52, -84.84, 998.867);
	for(new i; i < MAX_PLAYERS; i++)
	{
		myGame[i] = -1;
		onShot[i] = 0;
		speed[i] = 2;
	}
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
			}
		}
	}
}

public OnFilterScriptExit()
{	
	for(new i1 = 0; i1 < freeId; i1++)
	{
		for(new i; i < MAX_BALLS; i++)
		{
			if(Games[i1][balls][i] == 0) continue;
			DestroyObject(Games[i1][balls][i]);
		}
		KillTimer(Games[i1][timer]);
		TextDrawHideForAll(Games[freeId][shotDraw]);
	}
}

public OnPlayerConnect(playerid)
{
	onShot[playerid] = 0;
	myGame[playerid] = -1;
	speed[playerid] = 2;
}

public OnPlayerDisconnect(playerid)
{
	if(onShot[playerid] > 0)
	{
		onShot[playerid] = 0;
	}
	if(myGame[playerid] != -1)
	{
		endGame(myGame[playerid]);
	}
	myGame[playerid] = -1;
	speed[playerid] = 2;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys == KEY_SECONDARY_ATTACK)
	{
		new i = nearPoolTable(playerid);
		if(i != -1)
		{
			if(Games[i][gameOn])
			{
				SendClientMessage(playerid, COLOR_YELLOW, "Mäng juba käib selles lauas.");
			}
			else
			{
				myGame[playerid] = i;
				SendClientMessage(playerid, COLOR_YELLOW, "Vali omale vastane...");	
				StartGame(i, playerid, playerid);
			}
		}
	}
	else if(newkeys == KEY_WALK)
	{
		if(onShot[playerid] == 1)
		{
			endShot(playerid, 1);			
			SetTimerEx("ResetCam", 250, 0, "i", playerid);	
		}
		else if(onShot[playerid] == 0)
		{
			new i = nearPoolTable(playerid);
			if(i != -1)
			{
				if(myGame[playerid] == i)
				{
					onShot[playerid] = 1;
					poolPostition(playerid, 3, 3);
					TextDrawShowForPlayer(playerid, Games[i][shotDraw]);
					
					SetSpeed(playerid, 2, i);
					
					new Float: tx, Float: ty, Float: sz;
					new Float:a;				
					GetPlayerPos(playerid, tx, ty, sz);
					GetPlayerFacingAngle(playerid, a);				
					
					SetPlayerCameraPos(playerid, tx, ty, sz+1.0);
					SetPlayerCameraLookAt(playerid, tx+(1.0 * floatsin(-a, degrees)), ty+(1.0 * floatcos(-a, degrees)), sz);
				}
				else if(Games[i][gameOn])
				{
					SendClientMessage(playerid, COLOR_YELLOW, "Mäng juba käib selles lauas.");
				}
				else
				{
					SendClientMessage(playerid, COLOR_YELLOW, "Mäng ei käi, et mängida vajuta F/ENTER.");				
				}
			}
		}
	}
	else if(newkeys == KEY_FIRE)
	{
		if(onShot[playerid] == 1)
		{
			// kii ots, 1 unit playeri ees.
			new Float: x, Float: y, game = myGame[playerid];
			
			new Float:a;
			GetPlayerPos(playerid, x, y, a);
			GetPlayerFacingAngle(playerid, a);
			if (GetPlayerVehicleID(playerid))
			{
				GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
			}
			x += (1.17 * floatsin(-a+2.8, degrees));
			y += (1.17 * floatcos(-a+2.8, degrees));						
			new Float: dist = DistanceCheck2D(x, y, Games[game][ballX][BALL_CUE], Games[game][ballY][BALL_CUE]);
			if(dist > 0.025)
			{
				SendClientMessage(playerid, COLOR_RED, "Sa pead lööma valget palli.");
			}
			else
			{	
				poolPostition(playerid, 3, 1);
				SetTimerEx("CueBall", 490, 0, "ii", game, playerid);	
				SetTimerEx("endShot", 1000, 0, "ii", playerid, 1);	
				SetTimerEx("ResetCam", 2500, 0, "i", playerid);	
				onShot[playerid] = 2;
			}
		}
	}
	else if(newkeys == KEY_SPRINT)
	{
		if(onShot[playerid] == 1)
		{
			SetSpeed(playerid, (speed[playerid]+1), myGame[playerid]);
		}
	}
	else if(newkeys == KEY_JUMP)
	{
		if(onShot[playerid] == 1)
		{
			SetSpeed(playerid, (speed[playerid]-1), myGame[playerid]);
		}
	}
}

public CueBall(game, playerid)
{
	new Float: x, Float: y;
	GetXYInFrontOfPlayer(playerid, x, y, float(speed[playerid]));
	GetObjectPos(Games[game][balls][BALL_CUE], Games[game][ballStartX][BALL_CUE], Games[game][ballStartY][BALL_CUE], Games[game][ballZ][BALL_CUE]);
	MoveObject(Games[game][balls][BALL_CUE], x, y, Games[game][ballZ][BALL_CUE], float(speed[playerid]));
	
	Games[game][ballEndX][BALL_CUE] = x;
	Games[game][ballEndY][BALL_CUE] = y;
	
	Games[game][ballSpeed][BALL_CUE] = speed[playerid];
	Games[game][ballStartSpeed][BALL_CUE] = speed[playerid];
	Games[game][ballMoving][BALL_CUE] = 1;
	OverHeadCam(playerid, game);
}

public SetSpeed(playerid, spd, game)
{
	if(spd > MAX_SPEED) spd = MAX_SPEED;
	else if(spd < 1) spd = 1;
	
	speed[playerid] = spd;
	new str[8];
	format(str, 8, "%d", spd);
	TextDrawSetString(Games[game][shotDraw], str);
}

public OverHeadCam(playerid, game)
{
	SetPlayerCameraPos(playerid, Games[game][tablePos][0], Games[game][tablePos][1], Games[game][tablePos][2]+3.0);
	SetPlayerCameraLookAt(playerid, Games[game][tablePos][0], Games[game][tablePos][1], Games[game][tablePos][2]);
}

public ResetCam(playerid) 
{
	SetCameraBehindPlayer(playerid);
	onShot[playerid] = 0;
}

public ResetBalls(game)
{
	new Float: posX = Games[freeId][tablePos][0];
	new Float: posY = Games[freeId][tablePos][1];
	new Float: posZ = Games[freeId][tablePos][2];

	Games[game][balls][BALL_CUE] = CreateObject(OB_WHITE, posX, (posY+0.47), posZ, 0, 0, 0);
	Games[game][ballX][BALL_CUE] = posX;
	Games[game][ballY][BALL_CUE] = (posY+0.47);
	Games[game][ballZ][BALL_CUE] = posZ;
	
	// rida 1
	Games[game][balls][BALL_1] = CreateObject(OB_1, posX, (posY-0.47), posZ, 0, 0, 0);
	Games[game][ballX][BALL_1] = posX;
	Games[game][ballY][BALL_1] = (posY-0.47);
	Games[game][ballZ][BALL_1] = posZ;
	
	// rida 2
	Games[game][balls][BALL_2] = CreateObject(OB_2, posX+BALL_DIAMETER, posY-(0.47+BALL_DIAMETER), posZ, 0, 0, 0);
	Games[game][ballX][BALL_2] = posX+BALL_DIAMETER;
	Games[game][ballY][BALL_2] = posY-(0.47+BALL_DIAMETER);
	Games[game][ballZ][BALL_2] = posZ;
	
	Games[game][balls][BALL_1_S] = CreateObject(OB_1_S, posX-BALL_DIAMETER, posY-(0.47+BALL_DIAMETER), posZ, 0, 0, 0);
	Games[game][ballX][BALL_1_S] = posX-BALL_DIAMETER;
	Games[game][ballY][BALL_1_S] = posY-(0.47+BALL_DIAMETER);
	Games[game][ballZ][BALL_1_S] = posZ;
	
	// rida 3
	Games[game][balls][BALL_2_S] = CreateObject(OB_2_S, posX, posY-(0.47+(BALL_DIAMETER*2)), posZ, 0, 0, 0);
	Games[game][ballX][BALL_2_S] = posX;
	Games[game][ballY][BALL_2_S] = posY-(0.47+(BALL_DIAMETER*2));
	Games[game][ballZ][BALL_2_S] = posZ;
	
	Games[game][balls][BALL_3_S] = CreateObject(OB_3_S, posX-(BALL_DIAMETER*2), posY-(0.47+(BALL_DIAMETER*2)), posZ, 0, 0, 0);
	Games[game][ballX][BALL_3_S] = posX-(BALL_DIAMETER*2);
	Games[game][ballY][BALL_3_S] = posY-(0.47+(BALL_DIAMETER*2));
	Games[game][ballZ][BALL_3_S] = posZ;
	
	Games[game][balls][BALL_3] = CreateObject(OB_3, posX+(BALL_DIAMETER*2), posY-(0.47+(BALL_DIAMETER*2)), posZ, 0, 0, 0);
	Games[game][ballX][BALL_3] = posX+(BALL_DIAMETER*2);
	Games[game][ballY][BALL_3] = posY-(0.47+(BALL_DIAMETER*2));
	Games[game][ballZ][BALL_3] = posZ;
	
	// rida 4
	Games[game][balls][BALL_5_S] = CreateObject(OB_5_S, posX+BALL_DIAMETER, posY-(0.47+(BALL_DIAMETER*3)), posZ, 0, 0, 0);
	Games[game][ballX][BALL_5_S] = posX+BALL_DIAMETER;
	Games[game][ballY][BALL_5_S] = posY-(0.47+(BALL_DIAMETER*3));
	Games[game][ballZ][BALL_5_S] = posZ;
	
	Games[game][balls][BALL_5] = CreateObject(OB_5, posX-BALL_DIAMETER, posY-(0.47+(BALL_DIAMETER*3)), posZ, 0, 0, 0);
	Games[game][ballX][BALL_5] = posX-BALL_DIAMETER;
	Games[game][ballY][BALL_5] = posY-(0.47+(BALL_DIAMETER*3));
	Games[game][ballZ][BALL_5] = posZ;	
	
	Games[game][balls][BALL_4] = CreateObject(OB_4, posX+(BALL_DIAMETER*3), posY-(0.47+(BALL_DIAMETER*3)), posZ, 0, 0, 0);
	Games[game][ballX][BALL_4] = posX+(BALL_DIAMETER*3);
	Games[game][ballY][BALL_4] = posY-(0.47+(BALL_DIAMETER*3));
	Games[game][ballZ][BALL_4] = posZ;
	
	Games[game][balls][BALL_4_S] = CreateObject(OB_4_S, posX-(BALL_DIAMETER*3), posY-(0.47+(BALL_DIAMETER*3)), posZ, 0, 0, 0);
	Games[game][ballX][BALL_4_S] = posX-(BALL_DIAMETER*3);
	Games[game][ballY][BALL_4_S] = posY-(0.47+(BALL_DIAMETER*3));
	Games[game][ballZ][BALL_4_S] = posZ;	
	
	// rida 4
	Games[game][balls][BALL_8] = CreateObject(OB_8, posX, posY-(0.47+(BALL_DIAMETER*4)), posZ, 0, 0, 0);
	Games[game][ballX][BALL_8] = posX;
	Games[game][ballY][BALL_8] = posY-(0.47+(BALL_DIAMETER*4));
	Games[game][ballZ][BALL_8] = posZ;
	
	Games[game][balls][BALL_6] = CreateObject(OB_6, posX-(BALL_DIAMETER*2), posY-(0.47+(BALL_DIAMETER*4)), posZ, 0, 0, 0);
	Games[game][ballX][BALL_6] = posX-(BALL_DIAMETER*2);
	Games[game][ballY][BALL_6] = posY-(0.47+(BALL_DIAMETER*4));
	Games[game][ballZ][BALL_6] = posZ;
	
	Games[game][balls][BALL_6_S] = CreateObject(OB_6_S, posX+(BALL_DIAMETER*2), posY-(0.47+(BALL_DIAMETER*4)), posZ, 0, 0, 0);
	Games[game][ballX][BALL_6_S] = posX+(BALL_DIAMETER*2);
	Games[game][ballY][BALL_6_S] = posY-(0.47+(BALL_DIAMETER*4));
	Games[game][ballZ][BALL_6_S] = posZ;
	
	Games[game][balls][BALL_7_S] = CreateObject(OB_7_S, posX-(BALL_DIAMETER*4), posY-(0.47+(BALL_DIAMETER*4)), posZ, 0, 0, 0);
	Games[game][ballX][BALL_7_S] = posX-(BALL_DIAMETER*4);
	Games[game][ballY][BALL_7_S] = posY-(0.47+(BALL_DIAMETER*4));
	Games[game][ballZ][BALL_7_S] = posZ;
	
	Games[game][balls][BALL_7] = CreateObject(OB_7, posX+(BALL_DIAMETER*4), posY-(0.47+(BALL_DIAMETER*4)), posZ, 0, 0, 0);
	Games[game][ballX][BALL_7] = posX+(BALL_DIAMETER*4);
	Games[game][ballY][BALL_7] = posY-(0.47+(BALL_DIAMETER*4));
	Games[game][ballZ][BALL_7] = posZ;
}

public endGame(game)
{
	KillTimer(Games[game][timer]);
	Games[game][timer] = -1;
	TextDrawHideForAll(Games[game][shotDraw]);	
	ResetBalls(freeId);
	Games[game][gameOn] = false;	
}

public IsInHole(game, ball)
{
/*
1***********2
*                   *
*                   *
*                   *
3                  4
*                   *
*                   *
*                   *
5***********6	
*/
	if(DistanceCheck2D(Games[game][ballX][ball], Games[game][ballY][ball], Games[game][tablePos][0]-0.49, Games[game][tablePos][1]+0.96) < 0.0025)
	{
		return 1;
	}
	else if(DistanceCheck2D(Games[game][ballX][ball], Games[game][ballY][ball], Games[game][tablePos][0]+0.49, Games[game][tablePos][1]+0.96) < 0.0025)
	{
		return 2;
	}
	else if(DistanceCheck2D(Games[game][ballX][ball], Games[game][ballY][ball], Games[game][tablePos][0]-0.49, Games[game][tablePos][1]) < 0.0025)
	{
		return 3;
	}
	else if(DistanceCheck2D(Games[game][ballX][ball], Games[game][ballY][ball], Games[game][tablePos][0]+0.49, Games[game][tablePos][1]) < 0.0025)
	{
		return 4;
	}
	else if(DistanceCheck2D(Games[game][ballX][ball], Games[game][ballY][ball], Games[game][tablePos][0]-0.49, Games[game][tablePos][1]-0.96) < 0.0025)
	{
		return 5;
	}
	else if(DistanceCheck2D(Games[game][ballX][ball], Games[game][ballY][ball], Games[game][tablePos][0]+0.49, Games[game][tablePos][1]-0.96) < 0.0025)
	{
		return 6;
	}
	return 0;
}