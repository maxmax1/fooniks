local modelId = 3522;

-- 

addEventHandler( "onClientResourceStart", getResourceRootElement( getThisResource( ) ),

	function ( )
	
		LoadAllModels( );
	
	end

);

addCommandHandler( "models", 

	function ( )
	
		LoadAllModels( );
	
	end

);	

function LoadAllModels( )

	LoadCustomModel( 3522, "lapp2" ); -- vgsn_flwbdcrb
	LoadCustomModel( 1675, "maja" ); -- wshxrefhse1

end

function LoadCustomModel( modelId, fileName )
	
	local txd = engineLoadTXD( fileName .. ".txd" );
	local col = engineLoadCOL( fileName .. ".col" );	
	local mdl = engineLoadDFF( fileName .. ".dff", 0 );
	
	if( txd ) then engineImportTXD ( txd, modelId ); end
	engineReplaceCOL( col, modelId );		
	engineReplaceModel( mdl, modelId );
	
	engineSetModelLODDistance( modelId, 1000 );	
	
	outputChatBox( "Model laetud, kui tekstuurid on valged kasuta /models, et need taaslaadida." );

end