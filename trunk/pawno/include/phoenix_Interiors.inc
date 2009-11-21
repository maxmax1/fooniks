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

#define MAX_INTERIORS 49

enum intInf
{
	intName[16],
	intSampInt,
	Float: intX,
	Float: intY,
	Float: intZ
};

new Interiors[MAX_INTERIORS][intInf] = 
{
	{"24/7 1", 17, -25.884499, -185.868988, 1003.549988},
	{"24/7 2", 10, 6.091180, -29.271898, 1003.549988},
	{"24/7 3", 18, -30.946699, -89.609596, 1003.549988},
	{"24/7 4", 16, -25.132599, -139.066986, 1003.549988},
	{"24/7 5", 4, -27.312300, -29.277599, 1003.549988},
	{"24/7 6", 6, -26.691599, -55.714897, 1003.549988},
	{"Shamal cabin", 1, 2.384830, 33.103397, 1199.849976}, // Lennuki sisemus
	{"Andromada cargo", 9, 315.856170, 1024.496459, 1949.797363 },
	{"Ammunation 1", 1, 286.148987, -40.644398, 1001.569946},
	{"Ammunation 2", 4, 286.800995, -82.547600, 1001.539978},
	{"Ammunation 3", 6, 296.919983, -108.071999, 1001.569946},
	{"Ammunation 4", 7, 314.820984, -141.431992, 999.661987},
	{"Ammunation 5", 6, 316.524994, -167.706985, 999.661987},
	{"Booth", 7, 302.292877, -143.139099, 1004.062500},
	{"Range", 7, 280.795104, -135.203353, 1004.062500},
	{"House 1", 3, 235.508994, 1189.169897, 1080.339966},
	{"House 2", 2, 225.756989, 1240.000000, 1082.149902},
	{"House 3", 1, 223.043991, 1289.259888, 1082.199951},
	{"House 4", 7, 225.630997, 1022.479980, 1084.069946},
	{"House 5", 15, 295.138977, 1474.469971, 1080.519897},
	{"House 6", 15, 328.493988, 1480.589966, 1084.449951},
	{"House 7", 15, 385.803986, 1471.769897, 1080.209961},
	{"Atrium", 18, 1726.18, -1641.00, 20.23},
	{"Crack Palace", 2, 2567.52, -1294.59, 1063.25},
	{"Bloodbowl", 15, -1394.20, 987.62, 1023.96},
	{"Furhbergers", 8, 2807.63, -1170.15, 1025.57},
	{"Jefferson Motel", 15, 2220.26, -1148.01, 1025.80},
	{"Kickstart", 14, -1410.72, 1591.16, 1052.53},
	{"Pleasures Dome", 3, -2637.69, 1404.24, 906.46},
	{"RC Battlefield", 10, -1079.99, 1061.58, 1343.04},
	{"Ryders House", 2, 2451.77, -1699.80, 1013.51},
	{"Woozies", 1, -2158.72, 641.29, 1052.38},
	{"8-Track", 7, -1395.958, -208.197, 1051.170},
	{"Dirt Track", 4, -1424.9319, -664.5869, 1059.8585},
	{"Crack Den", 5, 318.565, 1115.210, 1082.98}, 
	{"Hashbury House", 10, 2260.76, -1210.45, 1049.02},
	{"Johnsons House", 3, 2496.65, -1696.55, 1014.74},
	{"Madd Dogg", 5, 1299.14, -794.77, 1084.00},
	{"Motel Room", 10, 2262.83, -1137.71, 1050.63},
	{"Zeros RC Shop", 6, -2240.00, 131.00, 1035.40},
	{"SF Police", 10, 246.40, 110.84, 1003.22},
	{"Unused Safe", 12, 2324.33, -1144.79, 1050.71},
	{"Tattoos", 16, -203.0764, -24.1658, 1002.2734},
	{"Burger Shot", 10, 363.4129, -74.5786, 1001.5078},
	{"Pizza", 5, 372.3520, -131.6510, 1001.4922},
	{"Cluckin Bell", 9, 365.7158, -9.8873, 1001.8516},
	{"Caligulas", 1, 2233.8032, 1712.2303, 1011.7632},
	{"4 Dragons", 10, 2016.2699, 1017.7790, 996.8750},
	{"RB Donuts", 17, 378.026, -190.5155, 1000.6328}
};

stock setToInt(playerid, intId)
{
	if(intId < 0 || intId > MAX_INTERIORS) return 1;
	
	SetPlayerInterior(playerid, Interiors[intId][intSampInt]);
	SetPlayerPos(playerid, Interiors[intId][intX], Interiors[intId][intY], Interiors[intId][intZ]);
	return 1;
}