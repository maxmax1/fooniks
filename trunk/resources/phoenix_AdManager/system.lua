local theObj = { 

	[13890] = "textures/lahillsads.txd"

};


function displayLoadedRes( res )	

	outputDebugString( "asdasd" );

	for k, v in pairs( theObj ) do
	
		local txd = engineLoadTXD( v, true );	
		 outputDebugString( tostring( txd ) .. " - " .. v );
		if( txd ) then outputDebugString("Txd"); outputDebugString( tostring( engineImportTXD ( txd, k ) ) ); end
	
		createObject( 13890, 230.858, -1478.569, 17.551 );
	
	end
	
end
addEventHandler( "onClientResourceStart", getResourceRootElement( getThisResource( ) ), displayLoadedRes );
local theObj = { 

	[13890] = "textures/lahillsads.txd"

};


function displayLoadedRes( res )	

	outputDebugString( "asdasd" );

	for k, v in pairs( theObj ) do
	
		local txd = engineLoadTXD( v, true );	
		 outputDebugString( tostring( txd ) .. " - " .. v );
		if( txd ) then outputDebugString("Txd"); outputDebugString( tostring( engineImportTXD ( txd, k ) ) ); end
	
		createObject( 13890, 230.858, -1478.569, 17.551 );
	
	end
	
end
addEventHandler( "onClientResourceStart", getResourceRootElement( getThisResource( ) ), displayLoadedRes );
local theObj = { 

	[13890] = "textures/lahillsads.txd"

};


function displayLoadedRes( res )	

	outputDebugString( "asdasd" );

	for k, v in pairs( theObj ) do
	
		local txd = engineLoadTXD( v, true );	
		 outputDebugString( tostring( txd ) .. " - " .. v );
		if( txd ) then outputDebugString("Txd"); outputDebugString( tostring( engineImportTXD ( txd, k ) ) ); end
	
		createObject( 13890, 230.858, -1478.569, 17.551 );
	
	end
	
end
addEventHandler( "onClientResourceStart", getResourceRootElement( getThisResource( ) ), displayLoadedRes );
