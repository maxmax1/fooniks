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
	Float: innerPrecent[MAX_PLAYERS],
	Float: prgX,
	Float: prgY,
	Float: prgW,
	Float: prgB,
};
new progressInf[MAX_BARS][prgInf];

forward CreateProgressbar(Float: x, Float: y, Float: width, Float: height, Float: border, backGroundColor, gradColor, labelColor);
public CreateProgressbar(Float: x, Float: y, Float: width, Float: height, Float: border, backGroundColor, gradColor, labelColor)
{
	progressInf[progressBars][prgX] = x;
	progressInf[progressBars][prgY] = y;
	progressInf[progressBars][prgW] = width;
	progressInf[progressBars][prgB] = border;
	progressInf[progressBars][backGround] = TextDrawCreate(x, y,"_");
	TextDrawUseBox(progressInf[progressBars][backGround], 1);
	TextDrawBoxColor(progressInf[progressBars][backGround], backGroundColor);
	TextDrawTextSize(progressInf[progressBars][backGround], (x+width+(2*border)), (y+7+(2*border)));
	TextDrawAlignment(progressInf[progressBars][backGround], 0);
	TextDrawBackgroundColor(progressInf[progressBars][backGround], backGroundColor);
	TextDrawFont(progressInf[progressBars][backGround], 3);
	TextDrawLetterSize(progressInf[progressBars][backGround], height+0.45, height+0.45);
	TextDrawColor(progressInf[progressBars][backGround], 0xffffffff);
	TextDrawSetProportional(progressInf[progressBars][backGround], 1);
	TextDrawSetShadow(progressInf[progressBars][backGround], 1);
	TextDrawSetOutline(progressInf[progressBars][backGround], 1);
	
	for(new i; i < MAX_PLAYERS; i++)
	{
		progressInf[progressBars][innerDraw][i] = TextDrawCreate((x+border), (y+border),"_");
		TextDrawUseBox(progressInf[progressBars][innerDraw][i], 1);
		TextDrawBoxColor(progressInf[progressBars][innerDraw][i], gradColor);
		TextDrawTextSize(progressInf[progressBars][innerDraw][i], (x+width+border), (y+border));
		TextDrawAlignment(progressInf[progressBars][innerDraw][i], 0);
		TextDrawBackgroundColor(progressInf[progressBars][innerDraw][i], gradColor);
		TextDrawFont(progressInf[progressBars][innerDraw][i], 1);
		TextDrawLetterSize(progressInf[progressBars][innerDraw][i], height, height);
		TextDrawColor(progressInf[progressBars][innerDraw][i], 0xffffffff);
		TextDrawSetProportional(progressInf[progressBars][innerDraw][i], 1);
		TextDrawSetShadow(progressInf[progressBars][innerDraw][i], 1);	
		progressInf[progressBars][innerPrecent][i] = 100.0;	
	}
	progressBars++;
	return progressBars-1;
}

stock setProgressBar(draw, playerid, Float: precent)
{
	if(draw > (MAX_BARS-1)) return 1;
	
	if(precent < 0.0) precent = 0.0;
	if(precent > 100.0) precent = 100.0;
	
	new Float: rPrec = progressInf[draw][prgX] + progressInf[draw][prgW] / 100 * precent;
	
	TextDrawHideForPlayer(playerid, progressInf[draw][innerDraw][playerid]);
	TextDrawTextSize(progressInf[draw][innerDraw][playerid], (rPrec), 10.000000);	
	TextDrawShowForPlayer(playerid, progressInf[draw][innerDraw][playerid]);	
	
	progressInf[progressBars][innerPrecent][playerid] = precent;
	return 0;
}

stock ProccesBarShowForPlayer(barId, playerid)
{
	TextDrawShowForPlayer(playerid, progressInf[barId][backGround]);
	TextDrawShowForPlayer(playerid, progressInf[barId][innerDraw][playerid]);
}