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

/*
*    This File: phoenix_Money.inc
*    Purpose: Serverside ANTI moneyhack.
*/

#if !defined _phoenix_included
	#error "Phoenix ERROR #1, You need phoenix base for this gamemode to run!"
	#endinput
#endif

#if defined _phoenix_Money_included
  #endinput
#endif
#define _phoenix_Money_included
#pragma library phoenix_Money

new PlayerMoney[MAX_PLAYERS];

stock serverMoneyFix(playerid)
{
	new sampMoney = GetPlayerMoney(playerid);
	if(sampMoney < PlayerMoney[playerid])
	{
		PlayerMoney[playerid] = sampMoney;
		MoneyUpdate(playerid);
	}
}

forward GivePlayerMoneyNew(playerid, money);
forward ResetPlayerMoneyNew(playerid);
forward MoneyUpdate(playerid);

public GivePlayerMoneyNew(playerid, money)
{
	if(PlayerMoney[playerid]+money > PlayerMoney[playerid])
	{
		PlayerPlaySound(playerid, 1149, 0.0, 0.0, 0.0);
	}
	PlayerMoney[playerid] += money;
	MoneyUpdate(playerid);
}

public ResetPlayerMoneyNew(playerid)
{
	PlayerMoney[playerid] = 0;
	MoneyUpdate(playerid);
}

public MoneyUpdate(playerid)
{
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, PlayerMoney[playerid]);
}
