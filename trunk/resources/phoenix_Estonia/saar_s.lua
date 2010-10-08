addEventHandler( "onResourceStart", getResourceRootElement( getThisResource( ) ),

	function ( )
	
		createObject( 3781, 835.565, -2051.563, 11.875 );
		createObject( 750, 835.56500244141, -2051.5629882813, 13.3671875 );

		
		setTimer( function ( ) triggerClientEvent( getRootElement( ), "onStatueFire", getRootElement( ) ); end, 3000, 0 );
		--[[
		local id = createTxdContainer( );
		outputDebugString( tostring( id ) );
		if( id ) then
		
			txdContainerAddImage( id, "test", "test.png" );
			outputDebugString( tostring( saveTxdContainer( id, "GFUGAY.txd" ) ) );
		
		end]]--
		
	
	end

);

addCommandHandler( "tmodel", 

	function (playerSource)
		
		setElementPosition(playerSource, 76.618, 213.974, 3.550 );
		outputChatBox( "Teleporteeritud..." );
	
	end
	
);