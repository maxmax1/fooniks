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

#define MAX_BARS 2

new progressBars = 0;
enum prgInf
{
	Text: backGround,
	Text: innerDraw[MAX_PLAYERS],
	Text: labelDraw[MAX_PLAYERS],
	Float: prgX,
	Float: prgY
};
new progressInf[MAX_BARS][prgInf];

forward CreateProgressbar(Float: x, Float: y, backGroundColor, gradColor, labelColor);
public CreateProgressbar(Float: x, Float: y, backGroundColor, gradColor, labelColor)
{
	progressInf[progressBars][prgX] = x;
	progressInf[progressBars][prgY] = y;
	progressInf[progressBars][backGround] = TextDrawCreate(x, y,"_");
	TextDrawUseBox(progressInf[progressBars][backGround], 1);
	TextDrawBoxColor(progressInf[progressBars][backGround], backGroundColor);
	TextDrawTextSize(progressInf[progressBars][backGround], (x+104.0), -10.000000);
	TextDrawAlignment(progressInf[progressBars][backGround], 0);
	TextDrawBackgroundColor(progressInf[progressBars][backGround], backGroundColor);
	TextDrawFont(progressInf[progressBars][backGround], 3);
	TextDrawLetterSize(progressInf[progressBars][backGround], 1.000000, 1.000000);
	TextDrawColor(progressInf[progressBars][backGround], 0xffffffff);
	TextDrawSetProportional(progressInf[progressBars][backGround], 1);
	TextDrawSetShadow(progressInf[progressBars][backGround], 1);
	TextDrawSetOutline(progressInf[progressBars][backGround], 1);
	
	for(new i; i < MAX_PLAYERS; i++)
	{
		progressInf[progressBars][innerDraw][i] = TextDrawCreate((x+2.0), (y+2.0),"_");
		TextDrawUseBox(progressInf[progressBars][innerDraw][i], 1);
		TextDrawBoxColor(progressInf[progressBars][innerDraw][i], gradColor);
		TextDrawTextSize(progressInf[progressBars][innerDraw][i], (x+102.0), 10.000000);
		TextDrawAlignment(progressInf[progressBars][innerDraw][i], 0);
		TextDrawBackgroundColor(progressInf[progressBars][innerDraw][i], gradColor);
		TextDrawFont(progressInf[progressBars][innerDraw][i], 1);
		TextDrawLetterSize(progressInf[progressBars][innerDraw][i], 0.60000, 0.60000);
		TextDrawColor(progressInf[progressBars][innerDraw][i], 0xffffffff);
		TextDrawSetProportional(progressInf[progressBars][innerDraw][i], 1);
		TextDrawSetShadow(progressInf[progressBars][innerDraw][i], 1);
		
		progressInf[progressBars][labelDraw][i] = TextDrawCreate((x+2.0), (y+2.0),"100 %");	
		TextDrawFont(progressInf[progressBars][labelDraw][i], 1);
		TextDrawLetterSize(progressInf[progressBars][labelDraw][i], 0.60000, 0.60000);
		TextDrawSetProportional(progressInf[progressBars][labelDraw][i], 1);
		TextDrawSetShadow(progressInf[progressBars][labelDraw][i], 1);	
		TextDrawColor(progressInf[progressBars][labelDraw][i], labelColor);		
	}
	progressBars++;
	return progressBars-1;
}

stock setProgressBar(draw, playerid, Float: precent)
{
	if(draw > (MAX_BARS-1)) return 1;
	
	new string[12];
	format(string, 12, "%.1f %%", precent);
	
	TextDrawHideForPlayer(playerid, progressInf[draw][innerDraw][playerid]);
	TextDrawSetString(progressInf[draw][labelDraw][playerid], string);
	TextDrawTextSize(progressInf[draw][innerDraw][playerid], (progressInf[draw][prgX]+2.0+precent), 10.000000);	
	TextDrawShowForPlayer(playerid, progressInf[draw][innerDraw][playerid]);	
	return 0;
}

stock ProccesBarShowForPlayer(barId, playerid)
{
	TextDrawShowForPlayer(playerid, progressInf[barId][backGround]);
	TextDrawShowForPlayer(playerid, progressInf[barId][labelDraw][playerid]);
	TextDrawShowForPlayer(playerid, progressInf[barId][innerDraw][playerid]);
}