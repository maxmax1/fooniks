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

#define COLOR_ANIMS 0x33AA33AA
#define animCmd(%0,%1,%2,%3,%4,%5,%6) if(!strcmp(DcmdFix( (%6)[1], strlen((%6)[1]) ),#%0,true)) return  ApplyAnimation(playerid,%1,%2,1.0,%3,%4,%4,0,%5)
#define animHelper(%0,%1,%2) if(!strcmp(DcmdFix( (%2)[1], strlen((%2)[1]) ),#%0,true)) return SendClientMessage(playerid, COLOR_ANIMS, %1);

stock animCmdHandler(playerid, cmdtext[])
{
	animHelper("animatsioonid", "/istu /püsti /aken /lehvita /lama /suitseta /suudle /pese /bather /pesapall", cmdtext);	

	animCmd("pysti", "Attractors", "Stepsit_out", 0, 0, 0, cmdtext);
	animCmd("aken", "AIRPORT", "thrw_barl_thrw", 1, 0, 2000, cmdtext);
	animCmd("lehvita", "BD_FIRE", "BD_GF_Wave", 1, 0, 0, cmdtext);
	animCmd("lama", "BEACH", "Lay_Bac_Loop", 1, 0, 0, cmdtext);
	animCmd("suitseta", "BD_FIRE", "M_smklean_loop", 1, 0, 0, cmdtext);
	animCmd("suudle", "BD_FIRE", "Playa_Kiss_03", 1, 0, 0, cmdtext);
	animCmd("pese", "BD_FIRE", "wash_up", 1, 0, 0, cmdtext);
	animCmd("bather", "BEACH", "bather", 1, 0, 0, cmdtext);	
	
	animHelper("istu", "ISTU: /istu [1-3]", cmdtext);	
	animCmd("istu 1", "Attractors", "Stepsit_loop", 1, 0, 0, cmdtext);
	animCmd("istu 2", "BEACH", "ParkSit_W_loop", 1, 0, 0, cmdtext);
	animCmd("istu 3", "BEACH", "SitnWait_loop_W", 1, 0, 0, cmdtext);	
	
	animHelper("pesapall", "PESAPALL: /pesapall [1-10]", cmdtext);	
	animCmd("pesapall 1", "BASEBALL", "Bat_1", 0,1,1, 2000, cmdtext);
	animCmd("pesapall 2", "BASEBALL", "Bat_2", 0,1,1, 2000, cmdtext);
	animCmd("pesapall 3", "BASEBALL", "Bat_2", 0,1,1, 2000, cmdtext);
	animCmd("pesapall 4", "BASEBALL", "Bat_4", 0,1,1, 2000, cmdtext);
	animCmd("pesapall 5", "BASEBALL", "Bat_block", 0,1,1, 2000, cmdtext);
	animCmd("pesapall 5", "BASEBALL", "Bat_Hit_1", 0,1,1, 2000, cmdtext);
	animCmd("pesapall 6", "BASEBALL", "Bat_Hit_2", 0,1,1, 2000, cmdtext);
	animCmd("pesapall 7", "BASEBALL", "Bat_Hit_3", 0,1,1, 2000, cmdtext);
	animCmd("pesapall 8", "BASEBALL", "Bat_IDLE", 0,1,1, 2000, cmdtext);
	animCmd("pesapall 9", "BASEBALL", "Bat_M", 0,1,1, 2000, cmdtext);
	animCmd("pesapall 10", "BASEBALL", "BAT_PART", 0,1,1, 2000, cmdtext);
	
	animHelper("baar", "BAAR: /baar [1-12]", cmdtext);		
	animCmd("baar 1", "BAR", "Barcustom_get", 1, 0, 0, cmdtext);
	animCmd("baar 2", "BAR", "Barcustom_loop", 1, 0, 0, cmdtext);
	animCmd("baar 3", "BAR", "Barcustom_order", 1, 0, 0, cmdtext);
	animCmd("baar 4", "BAR", "Barserve_bottle", 1, 0, 0, cmdtext);
	animCmd("baar 5", "BAR", "Barserve_give", 1, 0, 0, cmdtext);
	animCmd("baar 6", "BAR", "Barserve_glass", 1, 0, 0, cmdtext);
	animCmd("baar 7", "BAR", "Barserve_in", 1, 0, 0, cmdtext);
	animCmd("baar 8", "BAR", "Barserve_loop", 1, 0, 0, cmdtext);
	animCmd("baar 9", "BAR", "Barserve_order", 1, 0, 0, cmdtext);
	animCmd("baar 10", "BAR", "dnk_stndF_loop", 1, 0, 0, cmdtext);
	animCmd("baar 11", "BAR", "dnk_stndM_loop", 1, 0, 0, cmdtext);
	animCmd("baar 12", "BAR", "BARman_idle", 1, 0, 0, cmdtext);	
	
	animHelper("tuli", "TULI: /tuli [1-5]", cmdtext);		
	animCmd("tuli 1", "BD_FIRE", "BD_Fire1", 1, 0, 0, cmdtext);
	animCmd("tuli 2", "BD_FIRE", "BD_Fire2", 1, 0, 0, cmdtext);
	animCmd("tuli 3", "BD_FIRE", "BD_Fire3", 1, 0, 0, cmdtext);
	animCmd("tuli 4", "BEACH", "BD_Fire3", 1, 0, 0, cmdtext);

	animHelper("paanika", "PAANIKA: /paanika [1-5]", cmdtext);	
	animCmd("paanika 1", "BD_FIRE", "BD_Panic_01", 1, 0, 0, cmdtext);
	animCmd("paanika 2", "BD_FIRE", "BD_Panic_02", 1, 0, 0, cmdtext);
	animCmd("paanika 3", "BD_FIRE", "BD_Panic_03", 1, 0, 0, cmdtext);
	animCmd("paanika 4", "BD_FIRE", "BD_Panic_04", 1, 0, 0, cmdtext);
	animCmd("paanika 5", "BD_FIRE", "BD_Panic_Loop", 1, 0, 0, cmdtext);

	animHelper("jõuka", "JÕUKA: /jõuka [1-7]", cmdtext);	
	animCmd("jõuka 1", "benchpress", "gym_bp_celebrate", 1, 0, 0, cmdtext);
	animCmd("jõuka 2", "benchpress", "gym_bp_down", 1, 0, 0, cmdtext);
	animCmd("jõuka 3", "benchpress", "gym_bp_getoff", 1, 0, 0, cmdtext);
	animCmd("jõuka 4", "benchpress", "gym_bp_geton", 1, 0, 0, cmdtext);
	animCmd("jõuka 5", "benchpress", "gym_bp_up_A", 1, 0, 0, cmdtext);
	animCmd("jõuka 6", "benchpress", "gym_bp_up_B", 1, 0, 0, cmdtext);
	animCmd("jõuka 7", "benchpress", "gym_bp_up_smooth", 1, 0, 0, cmdtext);

	
	
	return -1;
}