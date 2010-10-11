local theObj = { 

	[13890] = "textures/lahillsads.txd"

};


function displayLoadedRes( res )	

	outputDebugString( "asdasd" );

	for k, v in pairs( theObj ) do
	
		local txd = engineLoadTXD( v, true );
		if( txd ) then engineImportTXD ( txd, k ); end
	
		createObject( 13890, 230.858, -1478.569, 17.551 );
		
		engineSetModelLODDistance( k, 300 ); -- Makes it refresh better, also improves the players ability to see them...
	
	end
	
end
addEventHandler( "onClientResourceStart", getResourceRootElement( getThisResource( ) ), displayLoadedRes );