addEventHandler( "onResourceStart", getResourceRootElement( getThisResource( ) ),

	function ( )
	
		createObject( 3781, 835.565, -2051.563, 11.875 );
	
	end

);

addCommandHandler( "tmodel", 

	function (playerSource)
		
		setElementPosition(playerSource, 76.618, 213.974, 3.550 );
		outputChatBox( "Teleporteeritud..." );
	
	end
	
);