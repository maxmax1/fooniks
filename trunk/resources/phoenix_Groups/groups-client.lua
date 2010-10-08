function GetPlayerGroupId( thePlayer )

	local team = getPlayerTeam( thePlayer );
	if( team ) then
	
		local teamId = getElementData( team, "sqlid" );
		if( teamId ) then
		
			return tonumber( teamId );
		
		end
	
	end
	
	return 0;

end