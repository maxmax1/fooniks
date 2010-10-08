addEventHandler( "onPlayerWasted", getRootElement( ),

	function()
		
		local x, y, z = getElementPosition( source );
		local rz = getPedRotation( source );
		
		exports.phoenix_Chat:OocInfo( source, "Kas aksepteerid surma või ootad abi?" );	
		spawnPlayer( source, x, y, z, rz, getElementModel( source ) );
		
		setElementHealth( source, 100 );
		toggleAllControls( source, false );		
		setPedAnimation( source, "CRACK", "crckdeth2", -1, true, true, false );
		setElementData( source, "Character.JustDied", "1" );
		triggerClientEvent( source, "onPlayerJustDied", source );
		
	end

);

addEvent( "onMinigameEnd", true );
addEventHandler( "onMinigameEnd", getRootElement( ), 

	function ( stats )
	
		setElementDimension( client, 0 );	
		setTimer( spawnPlayer, 1000, 1, client, 2041.352, -1410.098, 17.164, 180, getElementData( client, "Character.model" ) );
		setTimer( toggleAllControls, 999, 1, client, true );
		setTimer( setCameraTarget, 1001, 1, client, client );
		
		--[[
		
			stats
			
				int currentCombo
				int maxCombo
				int startTime ms
				int endTime ms
		
		]]--
	
	end
	
);

addEvent( "onPlayerRevive", true );
addEventHandler( "onPlayerRevive", getRootElement( ), 

	function ( )
	
		if( client ) then
		
			setElementHealth( client, 15 );
			toggleAllControls( client, true );			
			setPedAnimation( client );
			setElementData( client, "Character.JustDied", "0" );
			
		end
	
	end
	
);

addEvent( "onMedKitUse", true );
addEventHandler( "onMedKitUse", getRootElement( ),

	function ( pocketId, pType, pData )
	
		local check = getElementData( source, "UsedMedKit" );
		
		if( check ~= "1" ) then
		
			setElementData( source, "UsedMedKit", "1" );
			setTimer( setElementData, 10*60*1000, 1, source, "UsedMedKit", "0" );			
			local newH = getElementHealth( source );
			setElementHealth( source, newH );	
			exports.phoenix_Pockets:clearPocket( pocketId );
			exports.phoenix_Chat:EmoteMessage( source, "kasutab esmaabipakikest." );
		
		else
		
			exports.phoenix_Chat:OocInfo( source, "sa ei saa hetkel seda kasutada!" );
		
		end
		
	end
	
);
addEventHandler( "onPlayerWasted", getRootElement( ),

	function()
		
		local x, y, z = getElementPosition( source );
		local rz = getPedRotation( source );
		
		exports.phoenix_Chat:OocInfo( source, "Kas aksepteerid surma või ootad abi?" );	
		spawnPlayer( source, x, y, z, rz, getElementModel( source ) );
		
		setElementHealth( source, 100 );
		toggleAllControls( source, false );		
		setPedAnimation( source, "CRACK", "crckdeth2", -1, true, true, false );
		setElementData( source, "Character.JustDied", "1" );
		triggerClientEvent( source, "onPlayerJustDied", source );
		
	end

);

addEvent( "onMinigameEnd", true );
addEventHandler( "onMinigameEnd", getRootElement( ), 

	function ( stats )
	
		setElementDimension( client, 0 );	
		setTimer( spawnPlayer, 1000, 1, client, 2041.352, -1410.098, 17.164, 180, getElementData( client, "Character.model" ) );
		setTimer( toggleAllControls, 999, 1, client, true );
		setTimer( setCameraTarget, 1001, 1, client, client );
		
		--[[
		
			stats
			
				int currentCombo
				int maxCombo
				int startTime ms
				int endTime ms
		
		]]--
	
	end
	
);

addEvent( "onPlayerRevive", true );
addEventHandler( "onPlayerRevive", getRootElement( ), 

	function ( )
	
		if( client ) then
		
			setElementHealth( client, 15 );
			toggleAllControls( client, true );			
			setPedAnimation( client );
			setElementData( client, "Character.JustDied", "0" );
			
		end
	
	end
	
);

addEvent( "onMedKitUse", true );
addEventHandler( "onMedKitUse", getRootElement( ),

	function ( pocketId, pType, pData )
	
		local check = getElementData( source, "UsedMedKit" );
		
		if( check ~= "1" ) then
		
			setElementData( source, "UsedMedKit", "1" );
			setTimer( setElementData, 10*60*1000, 1, source, "UsedMedKit", "0" );			
			local newH = getElementHealth( source );
			setElementHealth( source, newH );	
			exports.phoenix_Pockets:clearPocket( pocketId );
			exports.phoenix_Chat:EmoteMessage( source, "kasutab esmaabipakikest." );
		
		else
		
			exports.phoenix_Chat:OocInfo( source, "sa ei saa hetkel seda kasutada!" );
		
		end
		
	end
	
);
addEventHandler( "onPlayerWasted", getRootElement( ),

	function()
		
		local x, y, z = getElementPosition( source );
		local rz = getPedRotation( source );
		
		exports.phoenix_Chat:OocInfo( source, "Kas aksepteerid surma või ootad abi?" );	
		spawnPlayer( source, x, y, z, rz, getElementModel( source ) );
		
		setElementHealth( source, 100 );
		toggleAllControls( source, false );		
		setPedAnimation( source, "CRACK", "crckdeth2", -1, true, true, false );
		setElementData( source, "Character.JustDied", "1" );
		triggerClientEvent( source, "onPlayerJustDied", source );
		
	end

);

addEvent( "onMinigameEnd", true );
addEventHandler( "onMinigameEnd", getRootElement( ), 

	function ( stats )
	
		setElementDimension( client, 0 );	
		setTimer( spawnPlayer, 1000, 1, client, 2041.352, -1410.098, 17.164, 180, getElementData( client, "Character.model" ) );
		setTimer( toggleAllControls, 999, 1, client, true );
		setTimer( setCameraTarget, 1001, 1, client, client );
		
		--[[
		
			stats
			
				int currentCombo
				int maxCombo
				int startTime ms
				int endTime ms
		
		]]--
	
	end
	
);

addEvent( "onPlayerRevive", true );
addEventHandler( "onPlayerRevive", getRootElement( ), 

	function ( )
	
		if( client ) then
		
			setElementHealth( client, 15 );
			toggleAllControls( client, true );			
			setPedAnimation( client );
			setElementData( client, "Character.JustDied", "0" );
			
		end
	
	end
	
);

addEvent( "onMedKitUse", true );
addEventHandler( "onMedKitUse", getRootElement( ),

	function ( pocketId, pType, pData )
	
		local check = getElementData( source, "UsedMedKit" );
		
		if( check ~= "1" ) then
		
			setElementData( source, "UsedMedKit", "1" );
			setTimer( setElementData, 10*60*1000, 1, source, "UsedMedKit", "0" );			
			local newH = getElementHealth( source );
			setElementHealth( source, newH );	
			exports.phoenix_Pockets:clearPocket( pocketId );
			exports.phoenix_Chat:EmoteMessage( source, "kasutab esmaabipakikest." );
		
		else
		
			exports.phoenix_Chat:OocInfo( source, "sa ei saa hetkel seda kasutada!" );
		
		end
		
	end
	
);