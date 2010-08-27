local copId = tonumber( get( "#COPS_GROUPID" ) );

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

function getCopTeam( )

	return exports.phoenix_Groups:GetGroupTeam( copId );

end

addEvent( "onCopClientInfoReq", true );
addEventHandler( "onCopClientInfoReq", getRootElement( ),

	function ( )
	
		if( client ) then
		
			triggerClientEvent( client, "onCopClientInit", client, copId );
		
		end
	
	end

);