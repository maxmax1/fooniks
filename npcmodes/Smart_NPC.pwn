#include <a_npc>
#include <foreach>
#include <sscanf_NPC>

#include <smart_npc>

public OnNPCModeInit()
{
	SetTimer("makeSmart", 3000, 0);
}

public OnClientMessage(color, text[])
{
	if(color == SMART_COLOR)
	{
		new fromPlayer, text2[128];
		if(sscanf(text, "ds", fromPlayer, text2) == 0)
		{
			if(!strcmp(text2, "autoMessage"))
			{
				AutoMessage(fromPlayer);
			}
			else
			{			
				AnwserCheck(fromPlayer, text2);
			}
		}
	}
}