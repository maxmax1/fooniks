--[[

	THE CONF

]]--

local chatChannels = { };

chatChannels["c"] = { true, " sosistab: ", "* ", "", 5, 242, 255, 172 };

chatChannels["s"] = { true, " karjub: ", "* ", "", 35, 215, 255, 0 };

chatChannels["say"] = { true, " ütleb: ", "", "", 20, 242, 255, 172 };
chatChannels["ask"] = { true, " küsib: ", "", "", 20, 242, 255, 172 };

chatChannels["ooc"] = { false, " OOC: ", "(( ", " ))", -1, 140, 248, 255 };
chatChannels["o"] = chatChannels["ooc"];

chatChannels["b"] = { false, " OOC: ", "(( ", " ))", 25, 242, 255, 172 };

--[[

	THE CODE

]]--

function doBinds( thePlayer )

	if( thePlayer and isElement( thePlayer ) and getElementType( thePlayer ) == "player" ) then

		-- Unused

	end

end

addEventHandler ( "onPlayerJoin", getRootElement(), 

	function ()
	
		doBinds( source );
	
	end

);

addEventHandler("onResourceStart", getResourceRootElement( getThisResource( ) ), 

	function ()
		
		local players = getElementsByType( "player" );
	
		for k, v in ipairs( players ) do
		
			doBinds( v );
		
		end
	
	end

);

addEventHandler ( "onEmoteMessage", getRootElement( ), 

	function ( str, var )
	
		if( client ) then
		
			EmoteMessage( client, str, var );
		
		end
	
	end

);

function ChatUsingChannel( thePlayer, theChannel, ... )

	if( chatChannels[theChannel] ) then
	
		local arg = table.concat( {...}, " " );
		if ( not setChatMessage( thePlayer, chatChannels[theChannel][1], chatChannels[theChannel][2], chatChannels[theChannel][3], chatChannels[theChannel][4], chatChannels[theChannel][5], arg, chatChannels[theChannel][6], chatChannels[theChannel][7], chatChannels[theChannel][8]  ) ) then
	
			outputChatBox( "Sa pead olema oma karakteriga sisse logitud.", thePlayer );
	
		end
	
	end

end

addEventHandler ( "onPlayerChat", getRootElement(), 

	function ( message, msgType )
	
		if( msgType == 1 ) then
		
			EmoteMessage( source, message );
		
		elseif( msgType == 2 ) then
		
			ChatUsingChannel( source, "c", message );
		
		else
		
			if( string.sub( message, -1 ) == "!" ) then
			
				ChatUsingChannel( source, "s", message );
			
			elseif( string.sub( message, -1 ) == "?" ) then
			
				ChatUsingChannel( source, "ask", message );
			
			else
			
				ChatUsingChannel( source, "say", message );
			
			end
		
		end
		
		
		cancelEvent( );
	
	end

);

addCommandHandler( "ooc", 	ChatUsingChannel, false, true);
addCommandHandler( "o",   	ChatUsingChannel, false, true);
addCommandHandler( "b", 	ChatUsingChannel, false, true);

addCommandHandler( "c", 	ChatUsingChannel, false, true);

addCommandHandler( "s",		ChatUsingChannel, false, true);

addCommandHandler ( "me",	ChatUsingChannel, false, true);

function EmoteMessage( thePlayer, msg, isOOC )

	if( not isOOC ) then isOOC = false; end

	if ( not setChatMessage( thePlayer, not isOOC, " ", "* ", " ", 35, msg, 218, 146, 229 ) ) then
	
		outputChatBox( "Sa pead olema oma karakteriga sisse logitud.", thePlayer );
	
	end

end

addCommandHandler ( "es",
	
	function ( playerSource, commandName, oName, ... )

		if ( oName == nil or ... == nil ) then
		
			outputChatBox( "KASUTUS: /es id/osanimest tekst.", playerSource );
			return false;
			
		end
	
		local targets = { };
		
		local players = getElementsByType ( "player" );
		
		if( tonumber( oName ) ~= nil ) then
		
			oName = tonumber( oName );
		
		end
		
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
			
			if( type( oName ) == "number" ) then
			
				outputChatBox( "Ei leidnud sellise ID ga kasutajat." );
			
			else
		
				outputChatBox( "Ei leidnud ühtki sellist sõna sisaldavat nime." );
				
			end
			return false;
			
		elseif( #targets > 1 ) then
		
			outputChatBox( "Palun täpsustage nime.", playerSource );
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
	
	if( action == nil or action == "" ) then action = " "; end

	local myName = "";
	
	if( getElementData( fromPlayer, "Character.id" ) == false ) then return false; end

	if( not isIC ) then 

		myName = getPlayerName( fromPlayer );
		
	else
	
		myName = getPlayerNametagText( fromPlayer );
	
	end
	
	local myVeh = getPedOccupiedVehicle( fromPlayer );
	if( isIC == true and myVeh ~= false ) then
	
		local wind = getElementData( myVeh, "vWindow" );
	
		if( wind ~= false and tonumber( wind ) == 0 ) then -- windows closed. :)
		
			prepend = prepend .. "(Aken Kinni) ";
			range = -2;
		
		end
	
	end
	

	local sendstr = prepend .. myName .. action .. str .. endadd;
	local players = { };

	
	if( range ~= nil and range ~= false and range > 0 ) then
	
		local x, y, z = getElementPosition( fromPlayer );
		local chatSphere = createColSphere( x, y, z, range );
		players = getElementsWithinColShape( chatSphere, "player" );
		destroyElement( chatSphere );
	
	elseif( range == -2 ) then -- if in vehicle with closed windows...
	
		for i = 0, getVehicleMaxPassengers( myVeh ), 1 do
		
			local player = getVehicleOccupant( myVeh, i );
			if( player ~= false ) then table.insert( players, player ); end
		
		end
	
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

function OocInfo( thePlayer, theMessage )

	triggerClientEvent( thePlayer, "onOOCInfo", thePlayer, theMessage );	

end