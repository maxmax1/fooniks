
thePhone = Phone:new( );
thePhone:Init( );

addCommandHandler( "telefon", 

	function ( )
	
		thePhone:Toggle( );
	
	end

, false, false);

addCommandHandler( "vibrate", 

	function ( )
	
		thePhone:Vibrate( );
	
	end

, false, false);