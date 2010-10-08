local copId = 0;

addEvent( "onCopClientInit", true );
addEventHandler( "onCopClientInit", getLocalPlayer( ),

	function ( newId )
	
		copId = tonumber( newId );
	
	end

);

triggerServerEvent( "onCopClientInfoReq", getLocalPlayer( ) );

function isCopVehicle( theVehicle )

	local vType = getElementData( theVehicle, "vType" );    
    local vOwner = getElementData( theVehicle, "vOwner" );
    
    if( not vType ) then vType = 0; else vType = tonumber(vType); end
    if( not vOwner ) then vOwner = 0; else vOwner = tonumber(vOwner); end 
	
	if( vType == 0 and vOwner ~= 0 ) then
	
		if( vOwner == copId ) then
		
			return true;
		
		end
	
	end
	
	return false;

end

function isACop( thePlayer )

	return ( exports.phoenix_Groups:GetPlayerGroupId( thePlayer ) == copId );

end