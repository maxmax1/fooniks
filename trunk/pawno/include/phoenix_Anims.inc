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
	
	animHelper("aplayidle", "APLAYIDLE: /aplayidle [1-5]", cmdtext);			
	animCmd("aplayidle 1", "PLAYIDLES","shift", 1, 0, 2000, cmdtext);
	animCmd("aplayidle 2", "PLAYIDLES","shldr", 1, 0, 2000, cmdtext);
	animCmd("aplayidle 3", "PLAYIDLES","stretch", 1, 0, 2000, cmdtext);
	animCmd("aplayidle 4", "PLAYIDLES","strleg", 1, 0, 2000, cmdtext);
	animCmd("aplayidle 5", "PLAYIDLES","time", 1, 0, 2000, cmdtext);
	
	animHelper("apiljard", "APILJARD: /apiljard [1-21]", cmdtext);			
	animCmd("apiljard 1", "POOL","POOL_ChalkCue", 1, 0, 2000, cmdtext);
	animCmd("apiljard 2", "POOL","POOL_Idle_Stance", 1, 0, 2000, cmdtext);
	animCmd("apiljard 3", "POOL","POOL_Long_Shot", 1, 0, 2000, cmdtext);
	animCmd("apiljard 4", "POOL","POOL_Long_Shot_O", 1, 0, 2000, cmdtext);
	animCmd("apiljard 5", "POOL","POOL_Long_Start", 1, 0, 2000, cmdtext);
	animCmd("apiljard 6", "POOL","POOL_Long_Start_O", 1, 0, 2000, cmdtext);
	animCmd("apiljard 7", "POOL","POOL_Med_Shot", 1, 0, 2000, cmdtext);
	animCmd("apiljard 8", "POOL","POOL_Med_Shot_O", 1, 0, 2000, cmdtext);
	animCmd("apiljard 9", "POOL","POOL_Med_Start", 1, 0, 2000, cmdtext);
	animCmd("apiljard 10", "POOL","POOL_Med_Start_O", 1, 0, 2000, cmdtext);
	animCmd("apiljard 11", "POOL","POOL_Place_White", 1, 0, 2000, cmdtext);
	animCmd("apiljard 12", "POOL","POOL_Short_Shot", 1, 0, 2000, cmdtext);
	animCmd("apiljard 13", "POOL","POOL_Short_Shot_O", 1, 0, 2000, cmdtext);
	animCmd("apiljard 14", "POOL","POOL_Short_Start", 1, 0, 2000, cmdtext);
	animCmd("apiljard 15", "POOL","POOL_Short_Start_O", 1, 0, 2000, cmdtext);
	animCmd("apiljard 16", "POOL","POOL_Walk", 1, 0, 2000, cmdtext);
	animCmd("apiljard 17", "POOL","POOL_Walk_Start", 1, 0, 2000, cmdtext);
	animCmd("apiljard 18", "POOL","POOL_XLong_Shot", 1, 0, 2000, cmdtext);
	animCmd("apiljard 19", "POOL","POOL_XLong_Shot_O", 1, 0, 2000, cmdtext);
	animCmd("apiljard 20", "POOL","POOL_XLong_Start", 1, 0, 2000, cmdtext);
	animCmd("apiljard 21", "POOL","POOL_XLong_Start_O", 1, 0, 2000, cmdtext);

	animCmd("avaene", "POOR","WINWASH_Wash2Beg", 1, 0, 2000, cmdtext);

	animHelper("apyyton", "APÜÜTON: /apüüton [1-5]", cmdtext);			
	animCmd("apyyton 1", "PYTHON","python_crouchfire", 1, 0, 2000, cmdtext);
	animCmd("apyyton 2", "PYTHON","python_crouchreload", 1, 0, 2000, cmdtext);
	animCmd("apyyton 3", "PYTHON","python_fire", 1, 0, 2000, cmdtext);
	animCmd("apyyton 4", "PYTHON","python_fire_poor", 1, 0, 2000, cmdtext);
	animCmd("apyyton 5", "PYTHON","python_reload", 1, 0, 2000, cmdtext);

	animHelper("arap", "ARAP: /arap [1-8]", cmdtext);			
	animCmd("arap 1", "RAPPING","Laugh_01", 1, 0, 2000, cmdtext);
	animCmd("arap 2", "RAPPING","RAP_A_IN", 1, 0, 2000, cmdtext);
	animCmd("arap 3", "RAPPING","RAP_A_Loop", 1, 0, 0, cmdtext);
	animCmd("arap 4", "RAPPING","RAP_A_OUT", 1, 0, 2000, cmdtext);
	animCmd("arap 5", "RAPPING","RAP_B_IN", 1, 0, 2000, cmdtext);
	animCmd("arap 6", "RAPPING","RAP_B_Loop", 1, 0, 0, cmdtext);
	animCmd("arap 7", "RAPPING","RAP_B_OUT", 1, 0, 2000, cmdtext);
	animCmd("arap 8", "RAPPING","RAP_C_Loop", 1, 0, 0, cmdtext);

	animHelper("ariot", "ARIOT: /ariot [1-7]", cmdtext);			
	animCmd("ariot 1", "RIOT","RIOT_ANGRY", 1, 0, 2000, cmdtext);
	animCmd("ariot 2", "RIOT","RIOT_ANGRY_B", 1, 0, 2000, cmdtext);
	animCmd("ariot 3", "RIOT","RIOT_challenge", 1, 0, 2000, cmdtext);
	animCmd("ariot 4", "RIOT","RIOT_CHANT", 1, 0, 2000, cmdtext);
	animCmd("ariot 5", "RIOT","RIOT_FUKU", 1, 0, 2000, cmdtext);
	animCmd("ariot 6", "RIOT","RIOT_PUNCHES", 1, 0, 2000, cmdtext);
	animCmd("ariot 7", "RIOT","RIOT_shout", 1, 0, 2000, cmdtext);

	animHelper("apank", "APANK: /apank [1-5]", cmdtext);			
	animCmd("apank 1", "ROB_BANK","CAT_Safe_End", 1, 0, 2000, cmdtext);
	animCmd("apank 2", "ROB_BANK","CAT_Safe_Open", 1, 0, 2000, cmdtext);
	animCmd("apank 3", "ROB_BANK","CAT_Safe_Open_O", 1, 0, 2000, cmdtext);
	animCmd("apank 4", "ROB_BANK","CAT_Safe_Rob", 1, 0, 2000, cmdtext);
	animCmd("apank 5", "ROB_BANK","SHP_HandsUp_Scr", 1, 0, 2000, cmdtext);

	animHelper("aryder", "ARYDER: /aryder [1-5]", cmdtext);			
	animCmd("aryder 1", "RYDER","RYD_Beckon_01", 1, 0, 2000, cmdtext);
	animCmd("aryder 2", "RYDER","RYD_Beckon_02", 1, 0, 2000, cmdtext);
	animCmd("aryder 3", "RYDER","RYD_Beckon_03", 1, 0, 2000, cmdtext);
	animCmd("aryder 4", "RYDER","RYD_Die_PT1", 1, 0, 2000, cmdtext);
	animCmd("aryder 5", "RYDER","RYD_Die_PT2", 1, 0, 2000, cmdtext);
	animCmd("aryder 6", "RYDER","Van_Crate_L", 1, 0, 2000, cmdtext);
	animCmd("aryder 7", "RYDER","Van_Crate_R", 1, 0, 2000, cmdtext);
	animCmd("aryder 8", "RYDER","Van_Fall_L", 1, 0, 2000, cmdtext);
	animCmd("aryder 9", "RYDER","Van_Fall_R", 1, 0, 2000, cmdtext);
	animCmd("aryder 10", "RYDER","Van_Lean_L", 1, 0, 2000, cmdtext);
	animCmd("aryder 11", "RYDER","Van_Lean_R", 1, 0, 2000, cmdtext);
	animCmd("aryder 12", "RYDER","VAN_PickUp_E", 1, 0, 2000, cmdtext);
	animCmd("aryder 13", "RYDER","VAN_PickUp_S", 1, 0, 2000, cmdtext);
	animCmd("aryder 14", "RYDER","Van_Stand", 1, 0, 2000, cmdtext);
	animCmd("aryder 15", "RYDER","Van_Stand_Crate", 1, 0, 2000, cmdtext);
	animCmd("aryder 16", "RYDER","Van_Throw", 1, 0, 2000, cmdtext);

	animHelper("asyga", "ASÜGA: /asüga [1-12]", cmdtext);			
	animCmd("asyga 1", "SCRATCHING","scdldlp", 1, 0, 2000, cmdtext);
	animCmd("asyga 2", "SCRATCHING","scdlulp", 1, 0, 2000, cmdtext);
	animCmd("asyga 3", "SCRATCHING","scdrdlp", 1, 0, 2000, cmdtext);
	animCmd("asyga 4", "SCRATCHING","scdrulp", 1, 0, 2000, cmdtext);
	animCmd("asyga 5", "SCRATCHING","sclng_l", 1, 0, 2000, cmdtext);
	animCmd("asyga 6", "SCRATCHING","sclng_r", 1, 0, 2000, cmdtext);
	animCmd("asyga 7", "SCRATCHING","scmid_l", 1, 0, 2000, cmdtext);
	animCmd("asyga 8", "SCRATCHING","scmid_r", 1, 0, 2000, cmdtext);
	animCmd("asyga 9", "SCRATCHING","scshrtl", 1, 0, 2000, cmdtext);
	animCmd("asyga 10", "SCRATCHING","scshrtr", 1, 0, 2000, cmdtext);
	animCmd("asyga 11", "SCRATCHING","sc_ltor", 1, 0, 2000, cmdtext);
	animCmd("asyga 12", "SCRATCHING","sc_rtol", 1, 0, 2000, cmdtext);

	animHelper("apood", "APOOD: /apood [1-25]", cmdtext);			
	animCmd("apood 1", "SHOP","ROB_2Idle", 1, 0, 2000, cmdtext);
	animCmd("apood 2", "SHOP","ROB_Loop", 1, 0, 0, cmdtext);
	animCmd("apood 3", "SHOP","ROB_Loop_Threat", 1, 0, 0, cmdtext);
	animCmd("apood 4", "SHOP","ROB_Shifty", 1, 0, 2000, cmdtext);
	animCmd("apood 5", "SHOP","ROB_StickUp_In", 1, 0, 2000, cmdtext);
	animCmd("apood 6", "SHOP","SHP_Duck", 1, 0, 2000, cmdtext);
	animCmd("apood 7", "SHOP","SHP_Duck_Aim", 1, 0, 2000, cmdtext);
	animCmd("apood 8", "SHOP","SHP_Duck_Fire", 1, 0, 2000, cmdtext);
	animCmd("apood 9", "SHOP","SHP_Gun_Aim", 1, 0, 2000, cmdtext);
	animCmd("apood 10", "SHOP","SHP_Gun_Duck", 1, 0, 2000, cmdtext);
	animCmd("apood 11", "SHOP","SHP_Gun_Fire", 1, 0, 2000, cmdtext);
	animCmd("apood 12", "SHOP","SHP_Gun_Grab", 1, 0, 2000, cmdtext);
	animCmd("apood 13", "SHOP","SHP_Gun_Threat", 1, 0, 2000, cmdtext);
	animCmd("apood 14", "SHOP","SHP_HandsUp_Scr", 1, 0, 2000, cmdtext);
	animCmd("apood 15", "SHOP","SHP_Jump_Glide", 1, 0, 2000, cmdtext);
	animCmd("apood 16", "SHOP","SHP_Jump_Land", 1, 0, 2000, cmdtext);
	animCmd("apood 17", "SHOP","SHP_Jump_Launch", 1, 0, 2000, cmdtext);
	animCmd("apood 18", "SHOP","SHP_Rob_GiveCash", 1, 0, 2000, cmdtext);
	animCmd("apood 19", "SHOP","SHP_Rob_HandsUp", 1, 0, 2000, cmdtext);
	animCmd("apood 20", "SHOP","SHP_Rob_React", 1, 0, 2000, cmdtext);
	animCmd("apood 21", "SHOP","SHP_Serve_End", 1, 0, 2000, cmdtext);
	animCmd("apood 22", "SHOP","SHP_Serve_Idle", 1, 0, 2000, cmdtext);
	animCmd("apood 23", "SHOP","SHP_Serve_Loop", 1, 0, 0, cmdtext);
	animCmd("apood 24", "SHOP","SHP_Serve_Start", 1, 0, 2000, cmdtext);
	animCmd("apood 25", "SHOP","Smoke_RYD", 1, 0, 2000, cmdtext);

	animHelper("asuits", "ASUITS: /asuits [1-8]", cmdtext);			
	animCmd("asuits 1", "SMOKING","F_smklean_loop", 1, 0, 0, cmdtext);
	animCmd("asuits 2", "SMOKING","M_smklean_loop", 1, 0, 0, cmdtext);
	animCmd("asuits 3", "SMOKING","M_smkstnd_loop", 1, 0, 0, cmdtext);
	animCmd("asuits 4", "SMOKING","M_smk_drag", 1, 0, 2000, cmdtext);
	animCmd("asuits 5", "SMOKING","M_smk_in", 1, 0, 2000, cmdtext);
	animCmd("asuits 6", "SMOKING","M_smk_loop", 1, 0, 0, cmdtext);
	animCmd("asuits 7", "SMOKING","M_smk_out", 1, 0, 2000, cmdtext);
	animCmd("asuits 8", "SMOKING","M_smk_tap", 1, 0, 2000, cmdtext);

	animHelper("astripp", "ASTRIPP: /astripp [1-20]", cmdtext);			
	animCmd("astripp 1", "STRIP","PLY_CASH", 1, 0, 2000, cmdtext);
	animCmd("astripp 2", "STRIP","PUN_CASH", 1, 0, 2000, cmdtext);
	animCmd("astripp 3", "STRIP","PUN_HOLLER", 1, 0, 2000, cmdtext);
	animCmd("astripp 4", "STRIP","PUN_LOOP", 1, 0, 0, cmdtext);
	animCmd("astripp 5", "STRIP","strip_A", 1, 0, 2000, cmdtext);
	animCmd("astripp 6", "STRIP","strip_B", 1, 0, 2000, cmdtext);
	animCmd("astripp 7", "STRIP","strip_C", 1, 0, 2000, cmdtext);
	animCmd("astripp 8", "STRIP","strip_D", 1, 0, 2000, cmdtext);
	animCmd("astripp 9", "STRIP","strip_E", 1, 0, 2000, cmdtext);
	animCmd("astripp 10", "STRIP","strip_F", 1, 0, 2000, cmdtext);
	animCmd("astripp 11", "STRIP","strip_G", 1, 0, 2000, cmdtext);
	animCmd("astripp 12", "STRIP","STR_A2B", 1, 0, 2000, cmdtext);
	animCmd("astripp 13", "STRIP","STR_B2A", 1, 0, 2000, cmdtext);
	animCmd("astripp 14", "STRIP","STR_B2C", 1, 0, 2000, cmdtext);
	animCmd("astripp 15", "STRIP","STR_C1", 1, 0, 2000, cmdtext);
	animCmd("astripp 16", "STRIP","STR_C2", 1, 0, 2000, cmdtext);
	animCmd("astripp 17", "STRIP","STR_C2B", 1, 0, 2000, cmdtext);
	animCmd("astripp 18", "STRIP","STR_Loop_A", 1, 0, 0, cmdtext);
	animCmd("astripp 19", "STRIP","STR_Loop_B", 1, 0, 0, cmdtext);
	animCmd("astripp 20", "STRIP","STR_Loop_C", 1, 0, 0, cmdtext);

	animHelper("ap2evita", "APÄEVITA: /apäevita [1-18]", cmdtext);			
	animCmd("ap2evita 1 ", "SUNBATHE","batherdown", 1, 0, 2000, cmdtext);
	animCmd("ap2evita 2", "SUNBATHE","batherup", 1, 0, 2000, cmdtext);
	animCmd("ap2evita 3", "SUNBATHE","Lay_Bac_in", 1, 0, 2000, cmdtext);
	animCmd("ap2evita 4", "SUNBATHE","Lay_Bac_out", 1, 0, 2000, cmdtext);
	animCmd("ap2evita 5", "SUNBATHE","ParkSit_M_IdleA", 1, 0, 2000, cmdtext);
	animCmd("ap2evita 6", "SUNBATHE","ParkSit_M_IdleB", 1, 0, 2000, cmdtext);
	animCmd("ap2evita 7", "SUNBATHE","ParkSit_M_IdleC", 1, 0, 2000, cmdtext);
	animCmd("ap2evita 8", "SUNBATHE","ParkSit_M_in", 1, 0, 2000, cmdtext);
	animCmd("ap2evita 9", "SUNBATHE","ParkSit_M_out", 1, 0, 2000, cmdtext);
	animCmd("ap2evita 10", "SUNBATHE","ParkSit_W_idleA", 1, 0, 2000, cmdtext);
	animCmd("ap2evita 11", "SUNBATHE","ParkSit_W_idleB", 1, 0, 2000, cmdtext);
	animCmd("ap2evita 12", "SUNBATHE","ParkSit_W_idleC", 1, 0, 2000, cmdtext);
	animCmd("ap2evita 13", "SUNBATHE","ParkSit_W_in", 1, 0, 2000, cmdtext);
	animCmd("ap2evita 14", "SUNBATHE","ParkSit_W_out", 1, 0, 2000, cmdtext);
	animCmd("ap2evita 15", "SUNBATHE","SBATHE_F_LieB2Sit", 1, 0, 2000, cmdtext);
	animCmd("ap2evita 16", "SUNBATHE","SBATHE_F_Out", 1, 0, 2000, cmdtext);
	animCmd("ap2evita 17", "SUNBATHE","SitnWait_in_W", 1, 0, 2000, cmdtext);
	animCmd("ap2evita 18", "SUNBATHE","SitnWait_out_W", 1, 0, 2000, cmdtext);

	animHelper("ament", "AMENT: /ament [1-23]", cmdtext);			
	animCmd("ament 1", "SWAT","gnstwall_injurd", 1, 0, 2000, cmdtext);
	animCmd("ament 2", "SWAT","JMP_Wall1m_180", 1, 0, 2000, cmdtext);
	animCmd("ament 3", "SWAT","Rail_fall", 1, 0, 2000, cmdtext);
	animCmd("ament 4", "SWAT","Rail_fall_crawl", 1, 0, 2000, cmdtext);
	animCmd("ament 5", "SWAT","swt_breach_01", 1, 0, 2000, cmdtext);
	animCmd("ament 6", "SWAT","swt_breach_02", 1, 0, 2000, cmdtext);
	animCmd("ament 7", "SWAT","swt_breach_03", 1, 0, 2000, cmdtext);
	animCmd("ament 8", "SWAT","swt_go", 1, 0, 2000, cmdtext);
	animCmd("ament 9", "SWAT","swt_lkt", 1, 0, 2000, cmdtext);
	animCmd("ament 10", "SWAT","swt_sty", 1, 0, 2000, cmdtext);
	animCmd("ament 11", "SWAT","swt_vent_01", 1, 0, 2000, cmdtext);
	animCmd("ament 12", "SWAT","swt_vent_02", 1, 0, 2000, cmdtext);
	animCmd("ament 13", "SWAT","swt_vnt_sht_die", 1, 0, 2000, cmdtext);
	animCmd("ament 14", "SWAT","swt_vnt_sht_in", 1, 0, 2000, cmdtext);
	animCmd("ament 15", "SWAT","swt_vnt_sht_loop", 1, 0, 0, cmdtext);
	animCmd("ament 16", "SWAT","swt_wllpk_L", 1, 0, 2000, cmdtext);
	animCmd("ament 17", "SWAT","swt_wllpk_L_back", 1, 0, 2000, cmdtext);
	animCmd("ament 18", "SWAT","swt_wllpk_R", 1, 0, 2000, cmdtext);
	animCmd("ament 19", "SWAT","swt_wllpk_R_back", 1, 0, 2000, cmdtext);
	animCmd("ament 20", "SWAT","swt_wllshoot_in_L", 1, 0, 2000, cmdtext);
	animCmd("ament 21", "SWAT","swt_wllshoot_in_R", 1, 0, 2000, cmdtext);
	animCmd("ament 22", "SWAT","swt_wllshoot_out_L", 1, 0, 2000, cmdtext);
	animCmd("ament 23", "SWAT","swt_wllshoot_out_R", 1, 0, 2000, cmdtext);

	animHelper("asweet", "ASWEET: /asweet [1-7]", cmdtext);			
	animCmd("asweet 1", "SWEET","ho_ass_slapped", 1, 0, 2000, cmdtext);
	animCmd("asweet 2", "SWEET","LaFin_Player", 1, 0, 2000, cmdtext);
	animCmd("asweet 3", "SWEET","LaFin_Sweet", 1, 0, 2000, cmdtext);
	animCmd("asweet 4", "SWEET","plyr_hndshldr_01", 1, 0, 2000, cmdtext);
	animCmd("asweet 5", "SWEET","sweet_ass_slap", 1, 0, 2000, cmdtext);
	animCmd("asweet 6", "SWEET","sweet_hndshldr_01", 1, 0, 2000, cmdtext);
	animCmd("asweet 7", "SWEET","Sweet_injuredloop", 1, 0, 0, cmdtext);

	animHelper("at2tuu", "ATÄTUU: /atätuu [1-57]", cmdtext);			
	animCmd("at2tuu 1", "TATTOOS","TAT_ArmL_In_O", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 2", "TATTOOS","TAT_ArmL_In_P", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 3", "TATTOOS","TAT_ArmL_In_T", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 4", "TATTOOS","TAT_ArmL_Out_O", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 5", "TATTOOS","TAT_ArmL_Out_P", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 6", "TATTOOS","TAT_ArmL_Out_T", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 7", "TATTOOS","TAT_ArmL_Pose_O", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 8", "TATTOOS","TAT_ArmL_Pose_P", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 9", "TATTOOS","TAT_ArmL_Pose_T", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 10", "TATTOOS","TAT_ArmR_In_O", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 11", "TATTOOS","TAT_ArmR_In_P", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 12", "TATTOOS","TAT_ArmR_In_T", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 13", "TATTOOS","TAT_ArmR_Out_O", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 14", "TATTOOS","TAT_ArmR_Out_P", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 15", "TATTOOS","TAT_ArmR_Out_T", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 16", "TATTOOS","TAT_ArmR_Pose_O", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 17", "TATTOOS","TAT_ArmR_Pose_P", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 18", "TATTOOS","TAT_ArmR_Pose_T", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 19", "TATTOOS","TAT_Back_In_O", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 20", "TATTOOS","TAT_Back_In_P", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 21", "TATTOOS","TAT_Back_In_T", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 22", "TATTOOS","TAT_Back_Out_O", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 23", "TATTOOS","TAT_Back_Out_P", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 24", "TATTOOS","TAT_Back_Out_T", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 25", "TATTOOS","TAT_Back_Pose_O", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 26", "TATTOOS","TAT_Back_Pose_P", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 27", "TATTOOS","TAT_Back_Pose_T", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 28", "TATTOOS","TAT_Back_Sit_In_P", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 29", "TATTOOS","TAT_Back_Sit_Loop_P", 1, 0, 0, cmdtext);
	animCmd("at2tuu 30", "TATTOOS","TAT_Back_Sit_Out_P", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 31", "TATTOOS","TAT_Bel_In_O", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 32", "TATTOOS","TAT_Bel_In_T", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 33", "TATTOOS","TAT_Bel_Out_O", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 34", "TATTOOS","TAT_Bel_Out_T", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 35", "TATTOOS","TAT_Bel_Pose_O", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 36", "TATTOOS","TAT_Bel_Pose_T", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 37", "TATTOOS","TAT_Che_In_O", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 38", "TATTOOS","TAT_Che_In_P", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 39", "TATTOOS","TAT_Che_In_T", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 40", "TATTOOS","TAT_Che_Out_O", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 41", "TATTOOS","TAT_Che_Out_P", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 42", "TATTOOS","TAT_Che_Out_T", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 43", "TATTOOS","TAT_Che_Pose_O", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 44", "TATTOOS","TAT_Che_Pose_P", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 45", "TATTOOS","TAT_Che_Pose_T", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 46", "TATTOOS","TAT_Drop_O", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 47", "TATTOOS","TAT_Idle_Loop_O", 1, 0, 0, cmdtext);
	animCmd("at2tuu 48", "TATTOOS","TAT_Idle_Loop_T", 1, 0, 0, cmdtext);
	animCmd("at2tuu 49", "TATTOOS","TAT_Sit_In_O", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 50", "TATTOOS","TAT_Sit_In_P", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 51", "TATTOOS","TAT_Sit_In_T", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 52", "TATTOOS","TAT_Sit_Loop_O", 1, 0, 0, cmdtext);
	animCmd("at2tuu 53", "TATTOOS","TAT_Sit_Loop_P", 1, 0, 0, cmdtext);
	animCmd("at2tuu 54", "TATTOOS","TAT_Sit_Loop_T", 1, 0, 0, cmdtext);
	animCmd("at2tuu 55", "TATTOOS","TAT_Sit_Out_O", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 56", "TATTOOS","TAT_Sit_Out_P", 1, 0, 2000, cmdtext);
	animCmd("at2tuu 57", "TATTOOS","TAT_Sit_Out_T", 1, 0, 2000, cmdtext);

	animHelper("aspank", "ASPANK: /aspank [1-8]", cmdtext);			
	animCmd("aspank 1", "SNM","SPANKING_IDLEW", 1, 0, 2000, cmdtext);
	animCmd("aspank 2", "SNM","SPANKING_IDLEP", 1, 0, 2000, cmdtext);
	animCmd("aspank 3", "SNM","SPANKINGW", 1, 0, 2000, cmdtext);
	animCmd("aspank 4", "SNM","SPANKINGP", 1, 0, 2000, cmdtext);
	animCmd("aspank 5", "SNM","SPANKEDW", 1, 0, 2000, cmdtext);
	animCmd("aspank 6", "SNM","SPANKEDP", 1, 0, 2000, cmdtext);
	animCmd("aspank 7", "SNM","SPANKING_ENDW", 1, 0, 2000, cmdtext);
	animCmd("aspank 8", "SNM","SPANKING_ENDP", 1, 0, 2000, cmdtext);

	animHelper("asuhuv6tt", "ASUHUVÕTT: /asuhuvõtt [1-12]", cmdtext);			
	animCmd("asuhuv6tt 1", "BLOWJOBZ","BJ_COUCH_START_P", 1, 0, 2000, cmdtext);
	animCmd("asuhuv6tt 2", "BLOWJOBZ","BJ_COUCH_START_W", 1, 0, 2000, cmdtext);
	animCmd("asuhuv6tt 3", "BLOWJOBZ","BJ_COUCH_LOOP_P", 1, 0, 0, cmdtext);
	animCmd("asuhuv6tt 4", "BLOWJOBZ","BJ_COUCH_LOOP_W", 1, 0, 0, cmdtext);
	animCmd("asuhuv6tt 5", "BLOWJOBZ","BJ_COUCH_END_P", 1, 0, 2000, cmdtext);
	animCmd("asuhuv6tt 6", "BLOWJOBZ","BJ_COUCH_END_W", 1, 0, 2000, cmdtext);
	animCmd("asuhuv6tt 7", "BLOWJOBZ","BJ_STAND_START_P", 1, 0, 2000, cmdtext);
	animCmd("asuhuv6tt 8", "BLOWJOBZ","BJ_STAND_START_W", 1, 0, 2000, cmdtext);
	animCmd("asuhuv6tt 9", "BLOWJOBZ","BJ_STAND_LOOP_P", 1, 0, 0, cmdtext);
	animCmd("asuhuv6tt 10", "BLOWJOBZ","BJ_STAND_LOOP_W", 1, 0, 0, cmdtext);
	animCmd("asuhuv6tt 11", "BLOWJOBZ","BJ_STAND_END_P", 1, 0, 2000, cmdtext);
	animCmd("asuhuv6tt 12", "BLOWJOBZ","BJ_STAND_END_W", 1, 0, 2000, cmdtext);	
	
	return -1;
}

stock stopAnims(playerid)
{
	ClearAnimations(playerid);
	TogglePlayerControllable(playerid, 0);
	TogglePlayerControllable(playerid, 1);
	return 1;
}