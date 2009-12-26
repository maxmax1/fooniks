#define HOLDING(%0) \
	((newkeys & (%0)) == (%0))
#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#define RELEASED(%0) \
	(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))

// author: Alex "Y_Less" Cole, External Credit #6
#define SendFormattedText(%1,%2,%3,%4) do{new sendfstring[128];format(sendfstring,128,(%3),%4);SendClientMessage((%1), (%2) ,sendfstring);}while(FALSE)
#define SendFormattedTextToAll(%1,%2,%3) do{new sendfstring[128];format(sendfstring,128,(%2),%3);SendClientMessageToAll((%1),sendfstring);}while(FALSE)

#define DistanceCheck(%0,%1,%2,%3,%4,%5) \
((((%0) - (%3)) * ((%0) - (%3))) + (((%1) - (%4)) * ((%1) - (%4))) + (((%2) - (%5)) * ((%2) - (%5)))) // Y_Less's macro

stock TextDrawFix(text[])
{
	new fixed[260];
	format(fixed, 256, "%s", text);
	
	for( new i; i < 256; i++ )
	{
		switch( fixed[i] )
		{
			case 'ü','Ü': fixed[i] = '¬';
			case 'õ','Õ': fixed[i] = '§';
			case 'ö','Ö': fixed[i] = '¨';
			case 'ä','Ä': fixed[i] = 'š';
		}
	}
	return fixed;
}

stock IsNumeric(string[])
{
	new	stringPos, ch = string[stringPos];
	
	if (ch == '-')
	{
		ch = string[++stringPos];
	}
	
	do
	{
		ch = string[stringPos];
		stringPos++;
		
		if ('0' <= ch <= '9')
		{
			continue;
		}
		else
		{
			return false;
		}
	}
	while (stringPos < strlen(string));
	return true;
}

			
forward TextDrawSetStringEx(Text: textID, txt[]);
public TextDrawSetStringEx(Text: textID, txt[])
{
	TextDrawSetString(textID, TextDrawFix(txt));
	return 1;
}

