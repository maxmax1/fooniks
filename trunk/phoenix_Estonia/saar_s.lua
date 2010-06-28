addEventHandler( "onResourceStart", getResourceRootElement( getThisResource( ) ),

	function ( )
	
		createObject( 3522, 76.618, 213.974, 1.550 );
		createObject( 1675, 76.618, 213.974, 2.550 );
		outputChatBox( "Objekt loodud" );
		outputChatBox( "Objekti juure telemiseks kasuta: /tmodel." );
	
	end

);

addCommandHandler( "tmodel", 

	function (playerSource)
		
		setElementPosition(playerSource, 76.618, 213.974, -1.550 );
		outputChatBox( "Teleporteeritud..." );
	
	end
	
);