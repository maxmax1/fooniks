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

#if !defined _phoenix_included
	#error "Phoenix ERROR #1, You need phoenix base for this gamemode to run!"
	#endinput
#endif

#define MAX_INTERIORS 54

#define INT_NATIVE 		0
#define INT_CUSTOM 		1
#define INT_PENTHOUSE 	2

enum intInf
{
	intName[16],
	intSampInt,
	Float: intX,
	Float: intY,
	Float: intZ,
	IntType
};

/*
*    !!! NOTE !!!
*    ADD TO END!!!
*/

new Interiors[MAX_INTERIORS][intInf] = 
{
	{"24/7 1", 17, -25.884499, -185.868988, 1003.549988, INT_NATIVE}, // 0
	{"24/7 2", 10, 6.091180, -29.271898, 1003.549988, INT_NATIVE}, // 1
	{"24/7 3", 18, -30.946699, -89.609596, 1003.549988, INT_NATIVE}, // 2
	{"24/7 4", 16, -25.132599, -139.066986, 1003.549988, INT_NATIVE}, // 3
	{"24/7 5", 4, -27.312300, -29.277599, 1003.549988, INT_NATIVE}, // 4
	{"24/7 6", 6, -26.691599, -55.714897, 1003.549988, INT_NATIVE}, // 5
	{"Shamal cabin", 1, 2.384830, 33.103397, 1199.849976, INT_NATIVE}, // 6
	{"Andromada cargo", 9, 315.856170, 1024.496459, 1949.797363, INT_NATIVE}, // 7
	{"Ammunation 1", 1, 286.148987, -40.644398, 1001.569946, INT_NATIVE}, // 8 
	{"Ammunation 2", 4, 286.800995, -82.547600, 1001.539978, INT_NATIVE}, // 9
	{"Ammunation 3", 6, 296.919983, -108.071999, 1001.569946, INT_NATIVE}, // 10
	{"Ammunation 4", 7, 314.820984, -141.431992, 999.661987, INT_NATIVE}, // 11 
	{"Ammunation 5", 6, 316.524994, -167.706985, 999.661987, INT_NATIVE}, // 12
	{"Booth", 7, 302.292877, -143.139099, 1004.062500, INT_NATIVE}, // 13
	{"Range", 7, 280.795104, -135.203353, 1004.062500, INT_NATIVE}, // 14
	{"House 1", 3, 235.508994, 1189.169897, 1080.339966, INT_NATIVE}, // 15
	{"House 2", 2, 225.756989, 1240.000000, 1082.149902, INT_NATIVE}, // 16
	{"House 3", 1, 223.043991, 1289.259888, 1082.199951, INT_NATIVE}, // 17
	{"House 4", 7, 225.630997, 1022.479980, 1084.069946, INT_NATIVE}, // 18
	{"House 5", 15, 295.138977, 1474.469971, 1080.519897, INT_NATIVE}, // 19
	{"House 6", 15, 328.493988, 1480.589966, 1084.449951, INT_NATIVE}, // 20
	{"House 7", 15, 385.803986, 1471.769897, 1080.209961, INT_NATIVE}, // 21
	{"Atrium", 18, 1726.18, -1641.00, 20.23, INT_NATIVE}, // 22
	{"Crack Palace", 2, 2567.52, -1294.59, 1063.25, INT_NATIVE}, // 23
	{"Bloodbowl", 15, -1394.20, 987.62, 1023.96, INT_NATIVE}, // 24
	{"Furhbergers", 8, 2807.63, -1170.15, 1025.57, INT_NATIVE}, // 25
	{"Jefferson Motel", 15, 2220.26, -1148.01, 1025.80, INT_NATIVE}, // 26
	{"Kickstart", 14, -1410.72, 1591.16, 1052.53, INT_NATIVE}, // 27
	{"Pleasures Dome", 3, -2637.69, 1404.24, 906.46, INT_NATIVE}, // 28
	{"RC Battlefield", 10, -1079.99, 1061.58, 1343.04, INT_NATIVE}, // 29
	{"Ryders House", 2, 2451.77, -1699.80, 1013.51, INT_NATIVE}, // 30
	{"Woozies", 1, -2158.72, 641.29, 1052.38, INT_NATIVE}, // 31
	{"8-Track", 7, -1395.958, -208.197, 1051.170, INT_NATIVE}, // 32
	{"Dirt Track", 4, -1424.9319, -664.5869, 1059.8585, INT_NATIVE}, // 33
	{"Crack Den", 5, 318.565, 1115.210, 1082.98, INT_NATIVE},  // 34
	{"Hashbury House", 10, 2260.76, -1210.45, 1049.02, INT_NATIVE}, // 35
	{"Johnsons House", 3, 2496.65, -1696.55, 1014.74, INT_NATIVE}, // 36
	{"Madd Dogg", 5, 1299.14, -794.77, 1084.00, INT_NATIVE}, // 37
	{"Motel Room", 10, 2262.83, -1137.71, 1050.63, INT_NATIVE}, // 38
	{"Zeros RC Shop", 6, -2240.00, 131.00, 1035.40, INT_NATIVE}, // 39
	{"SF Police", 10, 246.40, 110.84, 1003.22, INT_NATIVE}, // 40
	{"Unused Safe", 12, 2324.33, -1144.79, 1050.71, INT_NATIVE}, // 41
	{"Tattoos", 16, -203.0764, -24.1658, 1002.2734, INT_NATIVE}, // 42
	{"Burger Shot", 10, 363.4129, -74.5786, 1001.5078, INT_NATIVE}, // 43
	{"Pizza", 5, 372.3520, -131.6510, 1001.4922, INT_NATIVE}, // 44
	{"Cluckin Bell", 9, 365.7158, -9.8873, 1001.8516, INT_NATIVE}, // 45
	{"Caligulas", 1, 2233.8032, 1712.2303, 1011.7632, INT_NATIVE}, // 46
	{"4 Dragons", 10, 2016.2699, 1017.7790, 996.8750, INT_NATIVE}, // 47
	{"RB Donuts", 17, 378.026, -190.5155, 1000.6328, INT_NATIVE}, // 48
	{"Pig Pen", 2, 1204.8101, -12.5868, 1000.9219, INT_NATIVE}, // 49
	{"PentHouseTop", 0, 1824.7119140625, -1300.3558349609, 119.89214324951, INT_PENTHOUSE}, // 50
	{"Grove Gym", 5, 771.9399, -2.2574, 1000.7292, INT_NATIVE}, // 51
	{"CityHall", 3, 385.1285, 173.6007, 1008.3828, INT_NATIVE}, // 52
	{"Bank", 0, 2305.4048, -16.0771, 26.7496, INT_NATIVE} // 53
};

new 
	Float: gMyPentHouseCameraZ[MAX_PLAYERS], 
	gMyPentHouseCameraT[MAX_PLAYERS];

forward ResetPlayerCamera(playerid);
forward PenthouseCamera(playerid, interiorid);

stock setToInt(playerid, intId)
{
	if(intId < 0 || intId > MAX_INTERIORS) return 1;
	
	SetPlayerInterior(playerid, Interiors[intId][intSampInt]);
	SetPlayerPos(playerid, Interiors[intId][intX], Interiors[intId][intY], Interiors[intId][intZ]);		
	
	if(Interiors[intId][IntType] == INT_CUSTOM)
	{
		TogglePlayerControllableEx(playerid, 0, -1);
		SetTimerEx("ResetPlayerCamera", 5000, 0, "i", playerid);
		SetPlayerCameraLookAt(playerid, Interiors[intId][intX], Interiors[intId][intY], Interiors[intId][intZ]);
		
		new Float: x, Float: y;
		GetXYInFrontOfPlayer(playerid, x, y, 1.0);		
		SetPlayerCameraPos(playerid, x, y, Interiors[intId][intZ]+1.0);		
	}
	else if(Interiors[intId][IntType] == INT_PENTHOUSE)
	{
		TogglePlayerControllableEx(playerid, 0, -1);
		gMyPentHouseCameraZ[playerid] = 10.0;
		
		SetPlayerCameraLookAt(playerid, Interiors[intId][intX], Interiors[intId][intY], gMyPentHouseCameraZ[playerid]);
		SetPlayerCameraPos(playerid, Interiors[intId][intX]+20.0, Interiors[intId][intY], gMyPentHouseCameraZ[playerid]+5.0);
		
		gMyPentHouseCameraT[playerid] = SetTimerEx("PenthouseCamera", 100, 1, "ii", playerid, intId);
	}
		
	return 1;
}

public PenthouseCamera(playerid, interiorid)
{
	gMyPentHouseCameraZ[playerid]++;
	SetPlayerCameraLookAt(playerid, Interiors[interiorid][intX], Interiors[interiorid][intY], gMyPentHouseCameraZ[playerid]);
	SetPlayerCameraPos(playerid, Interiors[interiorid][intX]+20.0, Interiors[interiorid][intY], gMyPentHouseCameraZ[playerid]+5.0);
	
	if(gMyPentHouseCameraZ[playerid] > Interiors[interiorid][intZ])
	{
		KillTimer(gMyPentHouseCameraT[playerid]);
		ResetPlayerCamera(playerid);
	}
}

public ResetPlayerCamera(playerid)
{
	TogglePlayerControllableEx(playerid, 1, -1);
	SetCameraBehindPlayer(playerid);
}