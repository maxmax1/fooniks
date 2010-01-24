
function syncRingTone( ringtoneStr, timed )

	if( source ) then client = source; end 

	if( client ) then
	
		triggerClientEvent( getRootElement( ), "onRingtoneStart", getRootElement( ), client, ringtoneStr, timed );
	
	end

end

addEvent( "onSyncRingTone", true );
addEventHandler( "onSyncRingTone", getRootElement( ), syncRingTone );

function stopRingTone( )

	if( source ) then client = source; end 
	if( client ) then
	
		local x, y, z = getElementPosition( client );
		
		triggerClientEvent( getRootElement( ), "onRingtoneStop", getRootElement( ), client );
	
	end

end

addEvent( "onStopRingTone", true );
addEventHandler( "onStopRingTone", getRootElement( ), stopRingTone );