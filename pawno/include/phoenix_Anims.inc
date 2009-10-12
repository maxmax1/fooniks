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
#define animStop(%0,%1) if(!strcmp(DcmdFix( (%1)[1], strlen((%1)[1]) ),#%0,true)) return stopAnims(playerid)
#define animHelper(%0,%1,%2) if(!strcmp(DcmdFix( (%2)[1], strlen((%2)[1]) ),#%0,true)) return SendClientMessage(playerid, COLOR_ANIMS, %1)

stock animCmdHandler(playerid, cmdtext[])
{
	animHelper("animatsioonid", "/istu /püsti /aken /lehvita /lama /suitseta /suudle /pese /paanika /jõuka /animpomm /atulista /kanna /lõpeta", cmdtext);	

	animCmd("pysti", "Attractors", "Stepsit_out", 0, 0, 0, cmdtext);
	animCmd("aken", "AIRPORT", "thrw_barl_thrw", 1, 0, 2000, cmdtext);
	animCmd("lehvita", "BD_FIRE", "BD_GF_Wave", 1, 0, 0, cmdtext);
	animCmd("suitseta", "BD_FIRE", "M_smklean_loop", 1, 0, 0, cmdtext);
	animCmd("suudle", "BD_FIRE", "Playa_Kiss_03", 1, 0, 0, cmdtext);
	animCmd("pese", "BD_FIRE", "wash_up", 1, 0, 0, cmdtext);
	animStop("l6peta", cmdtext);

	animHelper("istu", "ISTU: /istu [1-2]", cmdtext);		
	animCmd("istu 1", "Attractors", "Stepsit_loop", 1, 0, 0, cmdtext);
	animCmd("istu 2", "BEACH", "bather", 1, 0, 0, cmdtext);	
	
	animHelper("lama", "LAMA: /lama [1-3]", cmdtext);		
	animCmd("lama 1", "BEACH", "Lay_Bac_Loop", 1, 0, 0, cmdtext);
	animCmd("lama 2", "BEACH", "ParkSit_W_loop", 1, 0, 0, cmdtext);
	animCmd("lama 3", "BEACH", "SitnWait_loop_W", 1, 0, 0, cmdtext);	
	
	animHelper("baar", "BAAR: /baar [1-12]", cmdtext);		
	animCmd("baar 1", "BAR", "Barcustom_get", 1, 0, 2000, cmdtext);
	animCmd("baar 2", "BAR", "Barcustom_loop", 1, 0, 0, cmdtext);
	animCmd("baar 3", "BAR", "Barcustom_order", 1, 0, 2000, cmdtext);
	animCmd("baar 4", "BAR", "Barserve_bottle", 1, 0, 2000, cmdtext);
	animCmd("baar 5", "BAR", "Barserve_give", 1, 0, 2000, cmdtext);
	animCmd("baar 6", "BAR", "Barserve_glass", 1, 0, 2000, cmdtext);
	animCmd("baar 7", "BAR", "Barserve_in", 1, 0, 2000, cmdtext);
	animCmd("baar 8", "BAR", "Barserve_loop", 1, 0, 0, cmdtext);
	animCmd("baar 9", "BAR", "Barserve_order", 1, 0, 2000, cmdtext);
	animCmd("baar 10", "BAR", "dnk_stndF_loop", 1, 0, 0, cmdtext);
	animCmd("baar 11", "BAR", "dnk_stndM_loop", 1, 0, 0, cmdtext);
	animCmd("baar 12", "BAR", "BARman_idle", 1, 0, 0, cmdtext);	
	
	animHelper("paanika", "PAANIKA: /paanika [1-5]", cmdtext);	
	animCmd("paanika 1", "BD_FIRE", "BD_Panic_01", 1, 0, 2000, cmdtext);
	animCmd("paanika 2", "BD_FIRE", "BD_Panic_02", 1, 0, 2000, cmdtext);
	animCmd("paanika 3", "BD_FIRE", "BD_Panic_03", 1, 0, 2000, cmdtext);
	animCmd("paanika 4", "BD_FIRE", "BD_Panic_04", 1, 0, 2000, cmdtext);
	animCmd("paanika 5", "BD_FIRE", "BD_Panic_Loop", 1, 0, 0, cmdtext);

	animHelper("j6uka", "JÕUKA: /jõuka [1-7]", cmdtext);	
	animCmd("j6uka 1", "benchpress", "gym_bp_celebrate", 1, 0, 0, cmdtext);
	animCmd("j6uka 2", "benchpress", "gym_bp_down", 1, 0, 0, cmdtext);
	animCmd("j6uka 3", "benchpress", "gym_bp_getoff", 1, 0, 0, cmdtext);
	animCmd("j6uka 4", "benchpress", "gym_bp_geton", 1, 0, 0, cmdtext);
	animCmd("j6uka 5", "benchpress", "gym_bp_up_A", 1, 0, 0, cmdtext);
	animCmd("j6uka 6", "benchpress", "gym_bp_up_B", 1, 0, 0, cmdtext);
	animCmd("j6uka 7", "benchpress", "gym_bp_up_smooth", 1, 0, 0, cmdtext);

	animHelper("animpomm", "ANIMPOMM: /animpomm [1-6]", cmdtext);	
	animCmd("animpomm 1", "BOMBER", "BOM_Plant", 1, 0, 2000, cmdtext);
	animCmd("animpomm 2", "BOMBER", "BOM_Plant_2Idle", 1, 0, 2000, cmdtext);
	animCmd("animpomm 3", "BOMBER", "BOM_Plant_Crouch_In", 1, 0, 2000, cmdtext);
	animCmd("animpomm 4", "BOMBER", "BOM_Plant_Crouch_Out", 1, 0, 2000, cmdtext);
	animCmd("animpomm 5", "BOMBER", "BOM_Plant_In", 1, 0, 2000, cmdtext);
	animCmd("animpomm 6", "BOMBER", "BOM_Plant_Loop", 1, 0, 0, cmdtext);
	
	animHelper("atulista", "ATULISTA: /atulista [1-5]", cmdtext);		
	animCmd("atulista 1", "BUDDY","buddy_crouchfire", 1, 0, 2000, cmdtext);
	animCmd("atulista 2", "BUDDY","buddy_crouchreload", 1, 0, 2000, cmdtext);
	animCmd("atulista 3", "BUDDY","buddy_fire", 1, 0, 2000, cmdtext);
	animCmd("atulista 4", "BUDDY","buddy_fire_poor", 1, 0, 2000, cmdtext);
	animCmd("atulista 5", "BUDDY","buddy_reload", 1, 0, 2000, cmdtext);

	animHelper("kanna", "KANNA: /kanna [1-7]", cmdtext);		
	animCmd("kanna 1", "CARRY","crry_prtial", 1, 0, 2000, cmdtext);
	animCmd("kanna 2", "CARRY","liftup", 1, 0, 2000, cmdtext);
	animCmd("kanna 3", "CARRY","liftup05", 1, 0, 2000, cmdtext);
	animCmd("kanna 4", "CARRY","liftup105", 1, 0, 2000, cmdtext);
	animCmd("kanna 5", "CARRY","putdwn", 1, 0, 2000, cmdtext);
	animCmd("kanna 6", "CARRY","putdwn05", 1, 0, 2000, cmdtext);
	animCmd("kanna 7", "CARRY","putdwn105", 1, 0, 2000, cmdtext);	
	
	return -1;
}

stock stopAnims(playerid)
{
	ClearAnimations(playerid);
	TogglePlayerControllable(playerid, 0);
	TogglePlayerControllable(playerid, 1);
	return 1;
}