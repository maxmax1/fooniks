addEventHandler ( "onPlayerJoin", getRootElement(), 

	function ()
	
		bindKey(source, "o", "down", "chatbox", "o");
		bindKey(source, "v", "down", "chatbox", "s");
		bindKey(source, "b", "down", "chatbox", "b");
		bindKey(source, "n", "down", "chatbox", "c");
	
	end

);

addEventHandler ( "onPlayerChat", getRootElement(), 

	function ( message, msgType )
	
		if( msgType == 1 ) then
		
			if ( not setChatMessage( source, "", "* ", "", 35, message, 218, 146, 229 ) ) then
		
				outputChatBox( "Sa pead olema oma karakteriga sisse logitud.", source );
		
			end
		
		else
		
			
		
			if( string.sub( message, -1 ) == "!" ) then
			
				if( not setChatMessage( source, " hüüab: ", "* ", "", 35, arg, 215, 255, 0 ) ) then
				
					outputChatBox( "Sa pead olema oma karakteriga sisse logitud.", source );
				
				end
		
			elseif ( not setChatMessage( source, ": ", "", "", 35, message, 242, 255, 172 ) ) then
		
				outputChatBox( "Sa pead olema oma karakteriga sisse logitud.", source );
		
			end
		
		end
		
		
		cancelEvent( );
	
	end

);

addCommandHandler ( "ooc",
	
	function ( playerSource, commandName, ... )
	
		local arg = table.concat( {...}, " " );	
	
		if ( not setChatMessage( playerSource, " OOC: ", "(( ", " ))", -1, arg, 140, 248, 255 ) ) then
		
			outputChatBox( "Sa pead olema oma karakteriga sisse logitud.", playerSource );
		
		end
	
	end
	
, false, true);

addCommandHandler ( "o",
	
	function ( playerSource, commandName, ... )
	
		local arg = table.concat( {...}, " " );		
	
		if ( not setChatMessage( playerSource, " OOC: ", "(( ", " ))", -1, arg, 140, 248, 255 ) ) then
		
			outputChatBox( "Sa pead olema oma karakteriga sisse logitud.", playerSource );
		
		end
	
	end
	
, false, true);

addCommandHandler ( "b",
	
	function ( playerSource, commandName, ... )

		local arg = table.concat( {...}, " " );
	
		if ( not setChatMessage( playerSource, " OOC: ", "(( ", " ))", 25, arg, 242, 255, 172 ) ) then
		
			outputChatBox( "Sa pead olema oma karakteriga sisse logitud.", playerSource );
		
		end
	
	end
	
, false, true);

addCommandHandler ( "c",
	
	function ( playerSource, commandName, ... )
	
		local arg = table.concat( {...}, " " );	
	
		if ( not setChatMessage( playerSource, " sosistab: ", "* ", "", 10, arg, 242, 255, 172  ) ) then
		
			outputChatBox( "Sa pead olema oma karakteriga sisse logitud.", playerSource );
		
		end
	
	end
	
, false, true);

addCommandHandler ( "s",
	
	function ( playerSource, commandName, ... )
	
		local arg = table.concat( {...}, " " );			
	
		if ( not setChatMessage( playerSource, " hüüab: ", "* ", "", 35, arg, 215, 255, 0 ) ) then
		
			outputChatBox( "Sa pead olema oma karakteriga sisse logitud.", playerSource );
		
		end
	
	end
	
, false, true);

addCommandHandler ( "me",
	
	function ( playerSource, commandName, ... )
	
		local arg = table.concat( {...}, " " );		
	
		if ( not setChatMessage( playerSource, " ", "* ", " ", 35, arg, 218, 146, 229 ) ) then
		
			outputChatBox( "Sa pead olema oma karakteriga sisse logitud.", playerSource );
		
		end
	
	end
	
, false, true);

addCommandHandler ( "es",
	
	function ( playerSource, commandName, arg, ... )

		if ( not arg or arg == nil ) then
		
			outputChatBox( "KASUTUS: /es osanimest tekst", playerSource );
			
		end
	
		local targets = { };
		
		-- if ( numbe
		
		local players = getElementsByType ( "player" );
		
		for k, v in ipairs( players ) do
		
			local name = getPlayerName( v );
			
			if( name ~= false and name ~= nil ) then
			
				local targetmatch = string.match( string.lower( name ), string.lower( arg ) );
				
				if( targetmatch ~= nil ) then
				
					if( getElementData( v, "Character.id" ) ~= false ) then
					
						local tbl = {};
						tbl[1] = v;
						tbl[2] = name;
						table.insert( targets, tbl );
						
					end
					
				end
				
			end
		
		end
		
		if( #targets == 0 ) then
		
			outputChatBox( "KASUTUS: /es osanimest text", playerSource );
			return 1;
			
		elseif( #targets > 1) then
		
			outputChatBox( "Palun täpsustage nime.", playerSource );
			return 1;
		
		end
		
		local arg2 = table.concat( {...}, " " );	
			
		outputChatBox( "-> " .. targets[1][2] .. ": " .. arg2, playerSource, 255, 252, 0 );
		outputChatBox( "<- " .. getPlayerName( playerSource ) .. ": " .. arg2, targets[1][1], 255, 252, 0 );
		return true;
	
	end
	
, false, true);

function setChatMessage( fromPlayer, action, prepend, endadd, range, str, r, g, b )

	if( getElementData( fromPlayer, "Character.id" ) == false ) then return false; end

	local sendstr = prepend .. getPlayerName( fromPlayer ) .. action .. str .. endadd;
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