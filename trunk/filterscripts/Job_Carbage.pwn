#define FILTERSCRIPT

#define MY_NAME "Jann"
#define NPC_SCRIPT "Job_Carbage"

#include <a_samp>
#include <foreach>
#include <sscanf>
#include <zcmd>
#include <smart_npc_samp>

forward SetPlayerJob(playerid);
public SetPlayerJob(playerid)
{
	SendClientMessage(playerid, 0xAFAFAFAA, "Töötab");
}