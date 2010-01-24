-- When the call is connected, then both players should have endcall buttons and a thingie that shows current calltime on screen...
-- an eventhandler to onplayerquit for both players so the call will end when a player quits, not when a player attempts to talk with the other one.
-- Phone credit.

local callStatus = { }; -- 0 - nocall, 1 - imcalling, 2 - phoneringing, 3 - connected
local onCall = { };
local myTimer = { };

function getSimByID( id )

	id = tonumber( id );
	local sims = getElementsByType( "SimCard" );
	
	for k,v in ipairs( sims ) do
	
		local tid = tonumber( getElementData( v, "SqlId" ) );
		if( tid == id ) then return v; end
	
	end
	return false;
	
end

function getPlayerSimElement( thePlayer )

	local inSim = tonumber( getElementData( thePlayer, "Character.simCard" ) );
	if( inSim ~= nil and inSim ~= false and inSim > 0 ) then
		
		local simId = getSimByID( inSim );
		if( simId ) then
		
			return simId;
		end
		
	end

	return false;

end

function getElementNumber( theElement )

	local simId = getPlayerSimElement( theElement );
	
	if( simId ) then
		local nr = getElementData( simId, "Number" );	
		if( nr ) then
		
			return nr;
			
		end
	end
	
	return false;

end

function getElementFromNumber( theNumber )

	theNumber = tostring( theNumber );
	local players = getElementsByType( "player" );
	
	for k, v in ipairs( players ) do
	
		local nr = getElementNumber( v );
		if( nr and nr == theNumber ) then
		
			return v;
			
		end
	
	end

	return false;

end

function StartCall( thePlayer, toNumber )

	if( callStatus[thePlayer] and callStatus[thePlayer] ~= 0 ) then
	
		outputChatBox( "Sa räägid juba telefoniga." .. callStatus[thePlayer], thePlayer );
		return false;
	
	end
	
	callStatus[thePlayer] = 1;	
	local toPlayer = getElementFromNumber( toNumber );
	if( not toPlayer ) then
	
		myTimer[thePlayer] = setTimer( EndCall, 1000, 1, thePlayer, "numbrit ei eksisteeri" );
		return 1;
	
	elseif( callStatus[toPlayer] and callStatus[toPlayer] ~= 0 ) then
	
		myTimer[thePlayer] = setTimer( EndCall, 1000, 1, thePlayer, "number kinni" );
		return 1;
	
	end
	
	onCall[thePlayer] = toPlayer;
	onCall[toPlayer] = thePlayer;
	
	callStatus[toPlayer] = 2;
	
	-- TODO: replace with getNameFromNumber
	triggerClientEvent( toPlayer, "onPhoneRingReq", toPlayer, "Helistab: ", getPlayerNametagText( thePlayer ), false );
	
end

addEvent( "onCallStart", true );
addEventHandler( "onCallStart", getRootElement( ), StartCall );

function ConnectCall( thePlayer )

	if( onCall[thePlayer] and callStatus[thePlayer] and ( callStatus[thePlayer] == 1 or callStatus[thePlayer] == 2 ) ) then
	
		callStatus[thePlayer] = 3;
		callStatus[onCall[thePlayer]] = 3;
		
		local myNumber = 
		
		triggerClientEvent( thePlayer, "onCallConnected", thePlayer, getElementNumber( thePlayer ) );
		triggerClientEvent( onCall[thePlayer], "onCallConnected", onCall[thePlayer], getElementNumber( onCall[thePlayer] ) );
	
	end

end

addEvent( "callAccepted", true );
addEventHandler( "callAccepted", getRootElement( ), ConnectCall );

function CallMessage( thePlayer, theCommand, ... )

	if( onCall[thePlayer] ~= nil and onCall[thePlayer] ~= false and callStatus[thePlayer] ~= nil and callStatus[thePlayer] == 3 ) then
	
		if( getElementType( onCall[thePlayer] ) == "player" ) then
		
			local arg = table.concat( {...}, " " );	
			outputChatBox( "TELEFON " .. getPlayerNametagText( thePlayer ) .. ": " .. arg, onCall[thePlayer] );
			exports.phoenix_Chat:setChatMessage( thePlayer, true, ": ", "(TELEFON) ", "", 5, arg, 240, 220, 130 );
		
		else
		
			EndCall( thePlayer, "Kõne katkes..." );
		
		end
		
	elseif( callStatus[thePlayer] == 0 ) then
	
		outputChatBox( "Sa ei räägi telefoniga...", thePlayer );
	
	end

end

addCommandHandler( "h", CallMessage, false, false );

function EndCall( thePlayer, message, otherTo )

	if( callStatus[thePlayer] == 2 ) then
	
		triggerEvent( "onStopRingTone", thePlayer );
	
	end

	if( otherTo ) then
	
		EndCall( onCall[thePlayer], message, false );
	
	end
	
	if( isTimer( myTimer[thePlayer] ) ) then
	
		killTimer( myTimer[thePlayer] );
	
	end
	
	onCall[thePlayer] = false;
	callStatus[thePlayer] = 0;	

	triggerClientEvent( thePlayer, "onPhoneRingReq", thePlayer, message, false, false, true, true );

end

addEvent( "endTheCall", true );
addEventHandler( "endTheCall", getRootElement( ), EndCall );

function getNameFromNumber( theElement, number )

	local inSim = tonumber( getElementData( theElement, "Character.simCard" ) );
	if( inSim ~= nil and inSim ~= false and inSim > 0 ) then
		
		local simId = getSimByID( inSim );
		if( simId ) then

			for i = 1, 15, 1 do
			
				local nr = getElementData( simId, "Contact.Nr." .. i );
				if( nr == number ) then
				
					return getElementData( simId, "Contact.Name." .. i );
				
				end
			
			end
			
		end
		
	end
	
	return false;

end

function SendSMS( fromPlayer, toNumber, text )

	local toPlayer = getElementFromNumber( toNumber );
	if( not toPlayer ) then
	
		triggerClientEvent( fromPlayer, "onSmsRequest", fromPlayer, fromPlayer, false, true );
		return 1;
		
	end
	
	local simId = getPlayerSimElement( toPlayer );
	local slot = FindFreeSmsSlot( simId );
	
	if( slot ) then
	
		local nName = getNameFromNumber( toPlayer, toNumber );
		if( nName ) then toNumber = nName; end
	
		setElementData( simId, "SMS.Name." .. slot, toNumber );
		setElementData( simId, "SMS.Text." .. slot, text );
		setElementData( simId, "SMS.Read." .. slot, "0" );
		
		saveSim( simId );
		
		triggerClientEvent( fromPlayer, "onSmsRequest", fromPlayer, fromPlayer, true, true );
		triggerClientEvent( toPlayer, "onSmsRequest", toPlayer, toPlayer, true, false );
		
		return 1;
	
	end
	
	triggerClientEvent( fromPlayer, "onSmsRequest", fromPlayer, fromPlayer, false, true );
	return 1;

end

addEvent( "onSmsSend", true );
addEventHandler( "onSmsSend", getRootElement( ), SendSMS );

function FindFreeSmsSlot( theSim )

	for i = 1, 15, 1 do
	
		local check = getElementData( theSim, "SMS.Name." .. i );
		local check2 = getElementData( theSim, "SMS.Text." .. i );
		if( check == false and check2 == false or check == "false" and check2 == "false" ) then
		
			return i;
		
		end
		
	end	
		
	return false;
	
end