local player = getLocalPlayer( );

function SetMyPos( x, y, z )

	setElementPosition( player, x, y, z );	
	local newZ = getGroundPosition( x, y, z ) + math.abs( getElementDistanceFromCentreOfMassToBaseOfModel( player ) );
	setElementPosition( player, x, y, newZ );	

end

addEvent( "onInteriorPosRequest", true );
addEventHandler( "onInteriorPosRequest", getRootElement( ), SetMyPos );

function getIntByID( id )

	if( type( id ) == "number" ) then
	
		id = tostring( id);
	
	end
	
	if( type( id ) ~= "string" ) then
	
		return false, -1;
	
	end

	local ints = getElementsByType( "sInterior" );
	
	for k, v in ipairs( ints ) do
	
    	local myId = getElementData( v, "infoId" );
    	
    	if( id == tostring( myId ) ) then
    	
    		return true, v;
    	
    	end
    	
    end
    
    return false, -2;
    
end

addEvent( "onInfospotClicked", false );
addEventHandler( "onClientClick", getRootElement( ), 

	function ( button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement )
			
		if( clickedElement == false ) then
		
			local myX, myY, myZ = getElementPosition( player );
			local markers = getElementsByType( "marker" );
				
			for k,v in ipairs( markers ) do
			
				local markerX, markerY, markerZ  = getElementPosition( v );
				local dist1 = getDistanceBetweenPoints3D( myX, myY, myZ, markerX, markerY, markerZ );
				if( dist1 < 15 ) then	
				
					local freeView = processLineOfSight( myX, myY, myZ, markerX, markerY, markerZ );
					if( freeView == false ) then
						
						local msX, msY = getScreenFromWorldPosition( markerX, markerY, markerZ );						
						if( msX ~= false and msY ~= false ) then
								
							local dist = getDistanceBetweenPoints2D( absoluteX, absoluteY, msX, msY );
							if( dist < 60 ) then
						
								local id = getElementData( v, "infoId" );
								if( id ~= false ) then								
									triggerEvent( "onInfospotClicked", player, v, id, button, state, msX, msY );
								
								end
							end
						end
					end
				end
			end
		end
	
	end

, true);