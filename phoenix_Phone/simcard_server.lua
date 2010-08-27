theSims = SimCards:new( );
theSims:Load( );
theSims:DoEvents( );

setTimer( function () theSims:CallHandlers( ) end, 1000, 0 );

addCommandHandler( "giveSim", 

	function ( thePlayer )
	
		local newS = theSims:NewSimCard( 3 );
		outputDebugString( tostring( newS ) );
		
		if( newS ) then
		
			exports.phoenix_Pockets:giveItem( thePlayer, 13, newS );
		
		end
	
	end

, false, false);

addEvent( "onUseSimcard", true );
addEventHandler( "onUseSimcard", getRootElement( ), 

	function ( pocketId, pType, pData )
	
		if( not source ) then return false; end
	
		local hasPhone = exports.phoenix_Pockets:getSlotByItem( source, 14 );
		
		if( not hasPhone ) then 
		
			outputChatBox( "Sul pole telefoni kuhu seda SIM-Kaarti panna", source );
			
		else
		
			local inSim = tonumber( getElementData( source, "Character.simCard" ) );
			
			if( not inSim or inSim == 0 ) then
			
				theSims:InitSim( source, pData );
			
				setElementData( source, "Character.simCard", pData );
				exports.phoenix_Pockets:clearPocket( source, pocketId );
				outputChatBox( "Panid oma telefoni simkaardi. ", source );			
			
			else
			
				outputChatBox( "Su telefonis on juba SIM-Kaart, võta eelmine enne välja...", source );
			
			end
		
		end
			
	end
	
);