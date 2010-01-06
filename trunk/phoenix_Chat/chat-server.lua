addEventHandler ( "onPlayerJoin", getRootElement(), 

	function ()
	
		unbindKey( source, "y" );
		bindKey( source, "o", "down", "chatbox", "o" );
		bindKey( source, "b", "down", "chatbox", "b" );
		bindKey( source, "y", "down", "chatbox", "c" );
	
	end

);

addEventHandler ( "onPlayerChat", getRootElement(), 

	function ( message, msgType )
	
		if( msgType == 1 ) then
		
			if ( not setChatMessage( source, true, "", "* ", "", 35, message, 218, 146, 229 ) ) then
		
				outputChatBox( "Sa pead olema oma karakteriga sisse logitud.", source );
		
			end
		
		elseif( msgType == 2 ) then
		
			if ( not setChatMessage( source, true, " sosistab: ", "* ", "", 10, message, 242, 255, 172  ) ) then
		
				outputChatBox( "Sa pead olema oma karakteriga sisse logitud.", source );
		
			end
		
		else
		
			if( string.sub( message, -1 ) == "!" ) then
						
				if( not setChatMessage( source, true, " karjub: ", "* ", "", 35, message, 215, 255, 0 ) ) then
				
					outputChatBox( "Sa pead olema oma karakteriga sisse logitud.", source );
				
				end
		
			elseif ( not setChatMessage( source, true, ": ", "", "", 35, message, 242, 255, 172 ) ) then
		
				outputChatBox( "Sa pead olema oma karakteriga sisse logitud.", source );
		
			end
		
		end
		
		
		cancelEvent( );
	
	end

);

addCommandHandler ( "ooc",
	
	function ( playerSource, commandName, ... )
	
		local arg = table.concat( {...}, " " );	
	
		if ( not setChatMessage( playerSource, false, " OOC: ", "(( ", " ))", -1, arg, 140, 248, 255 ) ) then
		
			outputChatBox( "Sa pead olema oma karakteriga sisse logitud.", playerSource );
		
		end
	
	end
	
, false, true);

addCommandHandler ( "o",
	
	function ( playerSource, commandName, ... )
	
		local arg = table.concat( {...}, " " );		
	
		if ( not setChatMessage( playerSource, false, " OOC: ", "(( ", " ))", -1, arg, 140, 248, 255 ) ) then
		
			outputChatBox( "Sa pead olema oma karakteriga sisse logitud.", playerSource );
		
		end
	
	end
	
, false, true);

addCommandHandler ( "b",
	
	function ( playerSource, commandName, ... )

		local arg = table.concat( {...}, " " );
	
		if ( not setChatMessage( playerSource, false, " OOC: ", "(( ", " ))", 25, arg, 242, 255, 172 ) ) then
		
			outputChatBox( "Sa pead olema oma karakteriga sisse logitud.", playerSource );
		
		end
	
	end
	
, false, true);

addCommandHandler ( "c",
	
	function ( playerSource, commandName, ... )
	
		local arg = table.concat( {...}, " " );	
	
		if ( not setChatMessage( playerSource, true, " sosistab: ", "* ", "", 10, arg, 242, 255, 172  ) ) then
		
			outputChatBox( "Sa pead olema oma karakteriga sisse logitud.", playerSource );
		
		end
	
	end
	
, false, true);

addCommandHandler ( "s",
	
	function ( playerSource, commandName, ... )
	
		local arg = table.concat( {...}, " " );			
	
		if ( not setChatMessage( playerSource, true, " hüüab: ", "* ", "", 35, arg, 215, 255, 0 ) ) then
		
			outputChatBox( "Sa pead olema oma karakteriga sisse logitud.", playerSource );
		
		end
	
	end
	
, false, true);

addCommandHandler ( "me",
	
	function ( playerSource, commandName, ... )
	
		local arg = table.concat( {...}, " " );		
	
		if ( not setChatMessage( playerSource, true, " ", "* ", " ", 35, arg, 218, 146, 229 ) ) then
		
			outputChatBox( "Sa pead olema oma karakteriga sisse logitud.", playerSource );
		
		end
	
	end
	
, false, true);

addCommandHandler ( "es",
	
	function ( playerSource, commandName, oName, ... )

		if ( oName == nil or ... == nil ) then
		
			outputChatBox( "KASUTUS: /es id/osanimest tekst.", playerSource );
			return false;
			
		end
	
		local targets = { };
		
		local players = getElementsByType ( "player" );
		
		for k, v in ipairs( players ) do
		
			if( type( oName ) == "number" ) then
			
				local id = getElementData( v, "User.userid" );
				if( id ~= false and tonumber( id ) ==  oName ) then
				
					local tbl = {};
					tbl[1] = v;
					tbl[2] = getPlayerName( v );
					table.insert( targets, tbl );
				
				end
			
			else
		
				local name = getPlayerName( v );
			
				if( name ~= false and name ~= nil ) then
			
					local targetmatch = string.match( string.lower( name ), string.lower( oName ) );
				
					if( targetmatch ~= nil ) then
				
						if( getElementData( v, "User.userid" ) ~= false ) then
					
							local tbl = {};
							tbl[1] = v;
							tbl[2] = name;
							table.insert( targets, tbl );
						
						end
					
					end
				
				end
				
			end
		
		end
		
		if( #targets == 0 ) then
		
			outputChatBox( "Ei leidnud Ã¼htki sellist sÃµna sisaldavat nime." );
			return false;
			
		elseif( #targets > 1 ) then
		
			outputChatBox( "Palun tÃ¤psustage nime.", playerSource );
			return false;
		
		end
		
		local arg2 = table.concat( {...}, " " );	
			
		outputChatBox( "-> " .. targets[1][2] .. ": " .. arg2, playerSource, 255, 252, 0 );
		outputChatBox( "<- " .. getPlayerName( playerSource ) .. ": " .. arg2, targets[1][1], 255, 252, 0 );
		return true;
	
	end
	
, false, true);

function setChatMessage( fromPlayer, isIC, action, prepend, endadd, range, str, r, g, b )

	if( not fromPlayer or isElement( fromPlayer ) == false ) then
	
		return false;
	
	end

	local myName = "";
	
	if( getElementData( fromPlayer, "Character.id" ) == false ) then return false; end

	if( not isIC ) then 

		myName = getPlayerName( fromPlayer );
		
	else
	
		myName = getPlayerNametagText( fromPlayer );
	
	end

	local sendstr = prepend .. myName .. action .. str .. endadd;
	local players;

	
	if( range ~= nil and range ~= false and range > 0 ) then
	
		local x, y, z = getElementPosition( fromPlayer );
		local chatSphere = createColSphere( x, y, z, range );
		players = getElementsWithinColShape( chatSphere, "player" );
		destroyElement( chatSphere );
	
	else
	
		players = getElementsByType( "player" );
		
	end
	
	for theKey,thePlayer in ipairs(players) do
	
		if( getElementData( thePlayer, "Character.id" ) ~= false ) then
		
			outputChatBox( sendstr, thePlayer, r, g, b );
			
		end
	   	
	end
	
	return true;

end