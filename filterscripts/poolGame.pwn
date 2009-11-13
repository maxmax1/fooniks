#include <a_samp>
#include <playerList>

#define MAX_GAMES 3
#define MAX_BALLS 16
#define MAX_PATHS 128

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

#define PATH_STEP 0.02

#define DistanceCheck2D(%0,%1,%2,%3) \
((((%0) - (%2)) * ((%0) - (%2))) + (((%1) - (%3)) * ((%1) - (%3)))) // Y_Less's macro.

new FALSE = false;
// author: Alex "Y_Less" Cole, External Credit #6
#define SendFormattedText(%1,%2,%3,%4) do{new sendfstring[128];format(sendfstring,128,(%3),%4);SendClientMessage((%1), (%2) ,sendfstring);}while(FALSE)
#define SendFormattedTextToAll(%1,%2,%3) do{new sendfstring[128];format(sendfstring,128,(%2),%3);SendClientMessageToAll((%1),sendfstring);}while(FALSE)

#define COLOR_YELLOW		0xFFFF33AA
#define COLOR_RED			0xFF3333AA
#define COLOR_GREEN			0x33FF33AA

enum bPathInf
{
	ballParentTick,
	ballParent,
	
	ballPUsed,
	ballToHole,
	Float: ballPX,
	Float: ballPY,
	Float: ballPZ,
	Float: ballSpeed,
}
new BallPaths[MAX_GAMES*MAX_BALLS][MAX_PATHS][bPathInf];

enum bgInf
{
	Float: tablePos[3],
	timer,
	gameOn,
	tempUsed,
	ballsMoving,
	
	poolPlayer1,
	poolPlayer2,
	poolScore1,
	poolScore2,
	poolCurrentPlayer,
	
	pathPos[MAX_BALLS],
	playPath[MAX_BALLS],
	
	balls[MAX_BALLS],
	ballGone[MAX_BALLS],
	Float: ballX[MAX_BALLS],
	Float: ballY[MAX_BALLS],
	Float: ballZ[MAX_BALLS],
	
	Text: shotDraw
};
new Games[MAX_GAMES][bgInf];
new freeId = 0;

new onShot[MAX_PLAYERS];
new myGame[MAX_PLAYERS];
new speed[MAX_PLAYERS];
new cam[MAX_PLAYERS];
new confirmBox[MAX_PLAYERS];

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
forward GameCam(playerid, game);
forward ResetCam(playerid);
forward ResetBalls(game);
forward endGame(game);
forward GameCheck(game);
forward IsInHole(game, Float: x, Float: y);
forward BuildPath(game, ball, Float: angle, Float: spd, parent, parentTick);
forward StartPath(game, ball);
forward PlayPath(game, ball, playId);
forward ClearPath(game, ball);

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
	cam[pl1] = 0;
	cam[pl2] = 0;
	
	Games[game][poolCurrentPlayer] = 1;	
	
	SetTimerEx("GameCheck", 30000, 0, "i", game);
	Games[game][gameOn] = true;
}
/*
public GameTimer(game)
{
	for(new i = 0; i < MAX_BALLS; i++)
	{
		if(Games[game][ballGone][i] != 0) continue;
		
		if(Games[game][ballMoving][i])
		{
			GetObjectPos(Games[game][balls][i], Games[game][ballX][i], Games[game][ballY][i], Games[game][ballZ][i]);
			
			// Ball Bounce
			for(new ball; ball < MAX_BALLS; ball++)
			{
				if(ball == i) continue;
				if((DistanceCheck2D(Games[game][ballX][ball], Games[game][ballY][ball], Games[game][ballX][i], Games[game][ballY][i])) > BALL_DIAMETER) continue;
				
				if(!Games[game][ballMoving][ball])
				{
					new Float: vecNW2x = Games[game][ballX][ball] - Games[game][ballX][i];
					new Float: vecNW2y = Games[game][ballY][ball] - Games[game][ballY][i];
					new Float: vecNW2Len = floatsqroot(floatpower(vecNW2x, 2) + floatpower(vecNW2y, 2));
					
					new Float: vecWx = Games[game][ballEndX][i] - Games[game][ballX][i];
					new Float: vecWy = Games[game][ballEndY][i] - Games[game][ballY][i];
					new Float: vecWLen = floatsqroot(floatpower(vecWx, 2) + floatpower(vecWy, 2));
					
					new Float: vecWang;
					
					if(Games[game][ballY][i] == Games[game][ballEndY][i] && Games[game][ballX][i] < Games[game][ballEndX][i])
					{
						vecWang = 0.0;
					}
					else if(Games[game][ballY][i] == Games[game][ballEndY][i] && Games[game][ballX][i] > Games[game][ballEndX][i])
					{
						vecWang = 180.0;
					}
					else if(Games[game][ballX][i] == Games[game][ballEndX][i] && Games[game][ballY][i] < Games[game][ballEndY][i])
					{
						vecWang = 90.0;
					}
					else if(Games[game][ballX][i] == Games[game][ballEndX][i] && Games[game][ballY][i] > Games[game][ballEndY][i])
					{
						vecWang = 270.0;
					}
					else
					{
						vecWang = atan((Games[game][ballEndX][i] - Games[game][ballX][i]) / (Games[game][ballEndY][i] - Games[game][ballY][i]));
					}
					
					
					new Float: gamma = acos((vecWx * vecNW2x) + (vecWy * vecNW2y) / (vecWLen * vecNW2Len));
					new Float: alpha = vecWang + (gamma - 90);
					new Float: beta = vecWang - (gamma - 90);
					
					new Float: vecNWx2 = Games[game][ballX][i] - (vecWLen * floatsin(-(alpha), degrees));
					new Float: vecNWy2 = Games[game][ballY][i] - (vecWLen * floatcos(-(alpha), degrees));
					
					MoveObject(Games[game][balls][i],  vecNWx2, vecNWy2, Games[game][ballZ][i], (Games[game][ballSpeed][i]*WALL_MODIFIER));
					
					Games[game][ballSpeed][i] = (Games[game][ballSpeed][i]*WALL_MODIFIER);
					Games[game][ballMoving][i] = 1;
					Games[game][ballStartX][i] = Games[game][ballX][i];
					Games[game][ballStartY][i] = Games[game][ballY][i];
					Games[game][ballEndX][i] = vecNWx2;
					Games[game][ballEndY][i] = vecNWy2;	
					
					new Float: vecNW2x2 = Games[game][ballX][i] - (vecWLen * floatsin(-(beta), degrees));
					new Float: vecNW2y2 = Games[game][ballY][i] - (vecWLen * floatcos(-(beta), degrees));					
					
					MoveObject(Games[game][balls][ball],  vecNW2x2, vecNW2y2, Games[game][ballZ][ball], (Games[game][ballSpeed][i]*WALL_MODIFIER));
					
					Games[game][ballSpeed][ball] = (Games[game][ballSpeed][i]*WALL_MODIFIER);
					Games[game][ballMoving][ball] = 1;
					Games[game][ballStartX][ball] = Games[game][ballX][ball];
					Games[game][ballStartY][ball] = Games[game][ballY][ball];
					Games[game][ballEndX][ball] = vecNW2x2;
					Games[game][ballEndY][ball] = vecNW2y2;						
				}
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
				
				new Float: k = floattan(180.0 - (gamma-90.0), degrees);
				
				new Float: hX = Games[game][ballX][i] - (sX - Games[game][ballX][i]);
				new Float: hY = k * (hX - (backToCord)) + (Games[game][ballY][i]);
					
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
				
				new Float: k = floattan(180.0 - (gamma-90.0), degrees);
				
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
*/

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
		cam[i] = 0;
	}
}

public OnObjectMoved(objectid)
{
	for(new game = 0; game < freeId; game++)
	{
		for(new i = 0; i < MAX_BALLS; i++)
		{	
			if(objectid == Games[game][balls][i])
			{
				GetObjectPos(Games[game][balls][i], Games[game][ballX][i], Games[game][ballY][i], Games[game][ballZ][i]);
				if(Games[game][playPath][i])
				{
					if(BallPaths[(game*MAX_BALLS)+i][Games[game][pathPos][i]][ballToHole] > 0)
					{
						if(i == BALL_CUE)
						{
							SendClientMessage(Games[game][poolPlayer1], COLOR_RED, "Lõid valge palli auku.");
							
							DestroyObject(Games[game][balls][BALL_CUE]);
							Games[game][ballX][BALL_CUE] = Games[game][tablePos][0];
							Games[game][ballY][BALL_CUE] = (Games[game][tablePos][1]+0.47);
							Games[game][ballZ][BALL_CUE] = Games[game][tablePos][2];							
							Games[game][balls][BALL_CUE] = CreateObject(OB_WHITE, Games[game][ballX][i], Games[game][ballY][i], Games[game][ballZ][i], 0.0, 0.0, 0.0);
							Games[game][poolCurrentPlayer] = (Games[game][poolCurrentPlayer] < 2)?2:1;
							Games[game][ballsMoving] = false;
						}
					}
					
					Games[game][pathPos][i]++;
					if(!PlayPath(game, i, Games[game][pathPos][i]))
					{
						Games[game][playPath][i] = false;
						ClearPath(game, i);
						Games[game][ballsMoving] = false;
					}
				}
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
		TextDrawHideForAll(Games[i1][shotDraw]);
	}
}

public OnPlayerConnect(playerid)
{
	onShot[playerid] = 0;
	myGame[playerid] = -1;
	speed[playerid] = 2;
	cam[playerid] = 0;
	confirmBox[playerid] = false;
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
	cam[playerid] = 0;
	confirmBox[playerid] = false;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys == KEY_SECONDARY_ATTACK)
	{
		new i = nearPoolTable(playerid);
		if(i != -1)
		{
			if(Games[i][gameOn] || Games[i][tempUsed])
			{
				SendClientMessage(playerid, COLOR_YELLOW, "Mäng juba käib selles lauas.");
			}
			else
			{
				myGame[playerid] = i;
				SendClientMessage(playerid, COLOR_YELLOW, "Vali omale vastane...");	
				ShowPlayerList(playerid, 15.0, true);
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
					if(Games[i][poolCurrentPlayer] == 1 && Games[i][poolPlayer1] != playerid || Games[i][poolCurrentPlayer] == 2 && Games[i][poolPlayer2] != playerid)
					{
						SendClientMessage(playerid, COLOR_YELLOW, "Hetkel pole sinu kord lüüa..");
					}
					else if(Games[i][ballsMoving])
					{
						SendClientMessage(playerid, COLOR_YELLOW, "Oota kuni pallid seisma jäävad.");
					}
					else
					{					
						onShot[playerid] = 1;
						poolPostition(playerid, 3, 3);
						TextDrawShowForPlayer(playerid, Games[i][shotDraw]);
						
						SetSpeed(playerid, 2, i);
						GameCam(playerid, myGame[playerid]);
					}
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
	else if(newkeys == KEY_LOOK_BEHIND)
	{
		if(onShot[playerid] == 1)
		{
			cam[playerid]++;
			if(cam[playerid] > 1) cam[playerid] = 0;
			GameCam(playerid, myGame[playerid]);
		}
	}
}

public CueBall(game, playerid)
{
	new Float: a;
	GetPlayerFacingAngle(playerid, a);	
	BuildPath(game, BALL_CUE,  a+2.8, speed[playerid], -1, 0);
	StartPath(game, BALL_CUE);
	
	Games[game][poolCurrentPlayer] = (Games[game][poolCurrentPlayer] < 2)?2:1;
	Games[game][ballsMoving] = true;
}

public SetSpeed(playerid, spd, game)
{
	if(spd > MAX_SPEED) spd = MAX_SPEED;
	else if(spd < 1) spd = 1;
	
	speed[playerid] = spd;
	new str[10+(MAX_SPEED*4)] = "Kiirus: ";
	
	for(new i = 1; i <= MAX_SPEED; i++)
	{
		if(spd >= float(i))
		{
			format(str, sizeof(str), "%s%s", str, "~g~|");
		}
		else
		{
			format(str, sizeof(str), "%s%s", str, "~r~|");
		}
	}
	
	TextDrawSetString(Games[game][shotDraw], str);
}

public GameCam(playerid, game)
{
	if(cam[playerid] == 0)
	{
		new Float: tx, Float: ty, Float: sz;
		new Float:a;				
		GetPlayerPos(playerid, tx, ty, sz);
		GetPlayerFacingAngle(playerid, a);
		a += 2.8;
		SetPlayerCameraPos(playerid, tx+(0.5 * floatsin(-a, degrees)), ty+(0.5 * floatcos(-a, degrees)), sz+0.5);
		SetPlayerCameraLookAt(playerid, tx+(1.0 * floatsin(-a, degrees)), ty+(1.0 * floatcos(-a, degrees)), sz);
	}
	else
	{
		SetPlayerCameraPos(playerid, Games[game][tablePos][0], Games[game][tablePos][1], Games[game][tablePos][2]+3.0);
		SetPlayerCameraLookAt(playerid, Games[game][tablePos][0], Games[game][tablePos][1], Games[game][tablePos][2]);
	}
}

public ResetCam(playerid) 
{
	SetCameraBehindPlayer(playerid);
	onShot[playerid] = 0;
}

public ResetBalls(game)
{
	new Float: posX = Games[game][tablePos][0];
	new Float: posY = Games[game][tablePos][1];
	new Float: posZ = Games[game][tablePos][2];

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
	SendClientMessage(Games[game][poolPlayer1], COLOR_GREEN, "* Piljardimäng lõppes.");
	onShot[Games[game][poolPlayer1]] = 0;
	myGame[Games[game][poolPlayer1]] = -1;
	speed[Games[game][poolPlayer1]] = 2;
	cam[Games[game][poolPlayer1]] = 0;	
	
	if(Games[game][poolPlayer1] != Games[game][poolPlayer2])
	{
		SendClientMessage(Games[game][poolPlayer2], COLOR_GREEN, "* Piljardimäng lõppes.");
		onShot[Games[game][poolPlayer2]] = 0;
		myGame[Games[game][poolPlayer2]] = -1;
		speed[Games[game][poolPlayer2]] = 2;
		cam[Games[game][poolPlayer2]] = 0;	
	}
	
	TextDrawHideForAll(Games[game][shotDraw]);

	for(new i; i < MAX_BALLS; i++)
	{
		if(Games[game][balls][i] == 0) continue;
		DestroyObject(Games[game][balls][i]);
	}

	ResetBalls(game);
	Games[game][gameOn] = false;	
}

public GameCheck(game)
{
	if(!IsPlayerConnected(Games[game][poolPlayer1]))
	{
		endGame(game);
		return 0;
	}
	if(!IsPlayerConnected(Games[game][poolPlayer2]))
	{
		endGame(game);
		return 0;
	}
	if(!IsPlayerInRangeOfPoint(Games[game][poolPlayer1], 50.0, Games[game][tablePos][0], Games[game][tablePos][1], Games[game][tablePos][2]))
	{
		endGame(game);
		return 0;
	}
	if(!IsPlayerInRangeOfPoint(Games[game][poolPlayer2], 50.0, Games[game][tablePos][0], Games[game][tablePos][1], Games[game][tablePos][2]))
	{
		endGame(game);
		return 0;
	}
	
	SetTimerEx("GameCheck", 30000, 0, "i", game);
	return 1;
}

public IsInHole(game, Float: x, Float: y)
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
	if(DistanceCheck2D(x, y, Games[game][tablePos][0]-0.51, Games[game][tablePos][1]+0.96) < 0.0025)
	{
		return 1;
	}
	else if(DistanceCheck2D(x, y, Games[game][tablePos][0]+0.51, Games[game][tablePos][1]+0.96) < 0.0025)
	{
		return 2;
	}
	else if(DistanceCheck2D(x, y, Games[game][tablePos][0]-0.53, Games[game][tablePos][1]) < 0.0025)
	{
		return 3;
	}
	else if(DistanceCheck2D(x, y, Games[game][tablePos][0]+0.53, Games[game][tablePos][1]) < 0.0025)
	{
		return 4;
	}
	else if(DistanceCheck2D(x, y, Games[game][tablePos][0]-0.51, Games[game][tablePos][1]-0.96) < 0.0025)
	{
		return 5;
	}
	else if(DistanceCheck2D(x, y, Games[game][tablePos][0]+0.51, Games[game][tablePos][1]-0.96) < 0.0025)
	{
		return 6;
	}
	return 0;
}

public BuildPath(game, ball,  Float: angle, Float: spd, parent, parentTick)
{
	ClearPath(game, ball);
	new Float: newX = Games[game][ballX][ball];
	new Float: newY = Games[game][ballY][ball];
	
	BallPaths[(game*MAX_BALLS)+ball][0][ballParent] = parent;
	BallPaths[(game*MAX_BALLS)+ball][0][ballParentTick] = parentTick;

	new i = 0;
	while(spd > 0.002 && i < MAX_PATHS)
	{
		// Seintega põrkumise kontroll ning uue nurga määramine.
		
		angle += ((newX+((spd*0.1) * floatsin(-angle, degrees))) > (Games[game][tablePos][0]+0.49))?((angle >= 90)?(90-angle):((2*90)-angle)):(0.0);
		angle += ((newX+((spd*0.1) * floatsin(-angle, degrees))) < (Games[game][tablePos][0]-0.49))?-((angle >= 90)?(angle+90):((2*90)-angle)):(0.0);
		
		angle += ((newY+((spd*0.1) * floatcos(-angle, degrees))) > (Games[game][tablePos][1]+0.96))?((angle >= 180)?(180-angle):((2*180)-angle)):(0.0);
		angle += ((newY+((spd*0.1) * floatcos(-angle, degrees))) < (Games[game][tablePos][1]-0.96))?-((angle >= 180)?(angle+180):((2*180)-angle)):(0.0);
			
		// Pallidevahelised põrked. ballParentTick.
		
		for(new bl; bl < MAX_BALLS; bl++)
		{
			if(bl == ball) continue;
			if((DistanceCheck2D(newX, newY, Games[game][ballX][bl], Games[game][ballY][bl])) > 0.025) continue;
			
			new Float: ballsAngle;
			
			if(newY == Games[game][ballY][bl] && newX < Games[game][ballX][bl])
			{
				ballsAngle = 0.0;
			}
			else if(newY == Games[game][ballY][bl] && newX > Games[game][ballX][bl])
			{
				ballsAngle = 180.0;
			}
			else if(newX == Games[game][ballX][bl] && newY < Games[game][ballY][bl])
			{
				ballsAngle = 90.0;
			}
			else if(newX == Games[game][ballX][bl] && newY > Games[game][ballY][bl])
			{
				ballsAngle = 270.0;
			}
			else
			{
				ballsAngle = atan((Games[game][ballX][bl] - newX) / (Games[game][ballY][bl] - newY));
			}			
			BuildPath(game, bl,  ballsAngle, spd, ball, i);
			angle += (ballsAngle > angle)?(ballsAngle - angle):(angle+ballsAngle);
		}
			
		// Järgmine liikumiskoht
		newX += ((spd*0.1) * floatsin(-angle, degrees));
		newY += ((spd*0.1) * floatcos(-angle, degrees));
		
		BallPaths[(game*MAX_BALLS)+ball][i][ballPX] = newX;
		BallPaths[(game*MAX_BALLS)+ball][i][ballPY] = newY;
		BallPaths[(game*MAX_BALLS)+ball][i][ballSpeed] = spd;
		BallPaths[(game*MAX_BALLS)+ball][i][ballPUsed] = 1;	

		new hole = IsInHole(game, newX, newY);
		if(hole > 0)
		{
			BallPaths[(game*MAX_BALLS)+ball][i][ballToHole] = hole;
			break;
		}
				
		spd -= (spd*0.1);
		i++;
	}
}

public StartPath(game, ball)
{
	if(!BallPaths[(game*MAX_BALLS)+ball][0][ballPUsed]) return false;
	Games[game][pathPos][ball] = 0;
	Games[game][playPath][ball] = true;
	PlayPath(game, ball, 0);
	return true;
}

public PlayPath(game, ball, playId)
{
	if(!BallPaths[(game*MAX_BALLS)+ball][playId][ballPUsed]) return false;
	MoveObject(Games[game][balls][ball], BallPaths[(game*MAX_BALLS)+ball][playId][ballPX], 
										 BallPaths[(game*MAX_BALLS)+ball][playId][ballPY],
										 Games[game][tablePos][2],
										 BallPaths[(game*MAX_BALLS)+ball][playId][ballSpeed]);
	if(playId != 0)
	{
		for(new ball2; ball2 < MAX_BALLS; ball2++)
		{
			if(ball == ball2) continue;
			
			if(BallPaths[(game*MAX_BALLS)+ball2][0][ballParentTick] == playId && BallPaths[(game*MAX_BALLS)+ball2][0][ballParent] == ball)
			{
				PlayPath(game, ball2, 0);
			}	
		}
	}
	return true;
}

public ClearPath(game, ball)
{
	for(new i = 0; i < MAX_PATHS; i++)
	{
		if(!BallPaths[(game*MAX_BALLS)+ball][i][ballPUsed]) break;
		
		BallPaths[(game*MAX_BALLS)+ball][i][ballPUsed] = 0;
		BallPaths[(game*MAX_BALLS)+ball][i][ballPX] = 0;
		BallPaths[(game*MAX_BALLS)+ball][i][ballPY] = 0;
		BallPaths[(game*MAX_BALLS)+ball][i][ballSpeed] = 0;		
		BallPaths[(game*MAX_BALLS)+ball][i][ballParentTick] = 0;		
	}
}

public OnPlayerSelectPlayer(playerid, otherId, btn)
{
	if(btn == 0)
	{
		myGame[playerid] = 0;
	}
	else if(playerid == otherId)
	{
		StartGame(myGame[playerid], playerid, otherId);
	}
	else
	{
		if(myGame[otherId] != 0)
		{
			SendClientMessage(playerid, COLOR_RED, "Vastane juba mängib...");
		}
		else
		{
			// Siia asja kontroll...
			Games[myGame[playerid]][poolPlayer1] = playerid;
			Games[myGame[playerid]][poolPlayer2] = otherId;
			Games[myGame[playerid]][tempUsed] = 1;
			
			new str[64];
			GetPlayerName(playerid, str, MAX_PLAYER_NAME);
			format(str, 64, "%s soovib sinuga piljardit mängida.\n Nõustud?", str);
			
			ShowPlayerConfirmbox(playerid, str);			
			confirmBox[otherId] = true;
			myGame[otherId] = myGame[playerid];
		}
	}
}

public OnPlayerConfirm(playerid, accepted)
{
	if(confirmBox[playerid])
	{
		confirmBox[playerid] = false;
		if(accepted == 0)
		{
			// No
			if(Games[myGame[playerid]][poolPlayer1] != playerid)
			{
				myGame[Games[myGame[playerid]][poolPlayer1]] = 0;
			}
			else
			{
				myGame[Games[myGame[playerid]][poolPlayer2]] = 0;
			}		
			Games[myGame[playerid]][poolPlayer1] = -1;
			Games[myGame[playerid]][poolPlayer2] = -1;
			Games[myGame[playerid]][tempUsed] = 0;
		}
		else
		{
			StartGame(myGame[playerid], Games[myGame[playerid]][poolPlayer1], Games[myGame[playerid]][poolPlayer2]);
		}
	}
}