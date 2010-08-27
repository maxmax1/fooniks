local reloadAmount = tonumber( exports.cookies:Cookie( "cModelRemember" ) ) or 3;
local reloadTimes = 0;

-- 

addEventHandler( "onClientResourceStart", getResourceRootElement( getThisResource( ) ),

	function ( )
	
		setTimer( LoadAllModels, 100, reloadAmount );
	
	end

);

addCommandHandler( "models", 

	function ( )
	
		LoadAllModels( );
	
	end

);	

function LoadAllModels( )

	LoadCustomModel( 3781, "models/office_floors" ); -- vgsn_flwbdcrb
	--LoadCustomModel( 1675, "maja" ); -- wshxrefhse1
	
	reloadTimes = reloadTimes + 1;
	exports.cookies:Cookie( "cModelRemember", reloadTimes );
	
	outputChatBox( "Model laetud, kui tekstuurid on valged kasuta /models, et need taaslaadida." );

end

function LoadCustomModel( modelId, fileName, text )
	
	--local txdFile = text or fileName;
	
	local txd = engineLoadTXD( fileName .. ".txd", true );
	local col = engineLoadCOL( fileName .. ".col" );	
	local mdl = engineLoadDFF( fileName .. ".dff", 0 );
	
	if( txd ) then engineImportTXD ( txd, modelId ); end
	if( col ) then engineReplaceCOL( col, modelId ); end
	engineReplaceModel( mdl, modelId );
	
	engineSetModelLODDistance( modelId, 1000 );	

end