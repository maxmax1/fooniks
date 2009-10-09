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

#define animCmd(%0,%1,%2,%3,%4,%5,%6) if(!strcmp(DcmdFix( (%6)[1], strlen((%6)[1]) ),#%0,true)) return  ApplyAnimation(playerid,%1,%2,1.0,%3,%4,%4,0,%5)

stock animCmdHandler(playerid, cmdtext[])
{
	animCmd("istu", "Attractors", "Stepsit_loop", 1, 0, 0, cmdtext);
	animCmd("pysti", "Attractors", "Stepsit_out", 0, 0, 0, cmdtext);
	animCmd("aken", "AIRPORT", "thrw_barl_thrw", 1, 0, 2000, cmdtext);
	
	
	return -1;
}