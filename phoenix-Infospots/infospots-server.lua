infoSpots = { };

function displayLoadedRes( res )	

	RegisterInteriors( );
	
	-- Add some default infospots.
	addInfoSpot( "PIGPEN", "PIG PEN", 2421.3535, -1220.4412, 26.4849, 0, 50, 0 );

end

addEventHandler( "onResourceStart", getResourceRootElement( getThisResource( ) ), displayLoadedRes );

function RegisterInteriors( )

	local xmlFile =  xmlLoadFile ( "interiors.xml" );
	if ( xmlFile ~= false ) then
	
		outputDebugString( "phoenix-Infospots: Interiors database loaded." );
	
		local allInts = xmlNodeGetChildren( xmlFile );
		
		if( allInts ~= false ) then
		
			for i, node in ipairs(allInts) do
		
           		-- node
            	local id = xmlNodeGetAttribute( node, "id" );
            	
            	if( id ~= false and id ~= nil ) then
            	
            		
            		local element = createElement( "sInterior", id );
            	
            		setElementData( element, "name", xmlNodeGetAttribute( node, "name" ) );
            		setElementData( element, "sampInt", xmlNodeGetAttribute( node, "sampInt" ) );
            		setElementData( element, "posX", xmlNodeGetAttribute( node, "posX" ) );
            		setElementData( element, "posY", xmlNodeGetAttribute( node, "posY" ) );
            		setElementData( element, "posZ", xmlNodeGetAttribute( node, "posZ" ) );
            		setElementData( element, "rot", xmlNodeGetAttribute( node, "rot" ) );
            		
            		outputDebugString( "Registred Interior: " .. id .. type(id) );
            	
            	end
            
      		end
      		
      	else
      	
      		outputDebugString( "phoenix-Infospots: Bad Interiors Database syntax.", 1 );
      		      
       	end

		xmlUnloadFile ( xmlFile );
		
	else
	
		outputDebugString( "phoenix-Infospots: Interiors database failed to load.", 1 );
		
	end

end

function getIntByID( id )

	if( type( id ) == "number" ) then
	
		id = tostring( id);
	
	end
	
	if( type( id ) ~= "string" ) then
	
		return false;
	
	end

	local ints = getElementsByType( "sInterior" );
	
	for k, v in ipairs( ints ) do
	
    	local myId = getElementData( v, "id" );
    	
    	if( id == myId ) then
    	
    		return v;
    	
    	end
    	
    end
    
end

function warpToInterior( thePlayer, theInt )

	if( not thePlayer or not isElement ( thePlayer )  ) then return -1; end
	
	local foundInt = getIntByID( theInt );
	if( not foundInt ) then
	
		return 0;
	
	end
	
	local sampInt = getElementData( foundInt, "sampInt" );
	local x = getElementData( foundInt, "posX" );
	local y = getElementData( foundInt, "posY" );
	local z = getElementData( foundInt, "posZ" );
	local rot = getElementData( foundInt, "rot" );
	
	setElementInterior( thePlayer, sampInt );
	setElementPosition( thePlayer, x, y, z );
	setPedRotation( thePlayer, rot );	
	
	return theInt;

end

function addInfoSpot( id, infoText, x, y, z, fromDimension, toDimension, toScriptinterior, rot )

	if( infoSpots[id] ~= nil ) then
	
		return false;
	
	end
	
	infoSpots[id]  = { };
	
	infoSpots[id]["marker"] = createMarker( x, y, z, "arrow", 2.0, 255, 255, 0 );
	setElementDimension( infoSpots[id]["marker"], fromDimension );
	setElementData( infoSpots[id]["marker"], "infoId", id );
	
	infoSpots[id]["infoText"] = infoText;
	infoSpots[id]["x"] = x;
	infoSpots[id]["y"] = y;
	infoSpots[id]["z"] = z;
	infoSpots[id]["rot"] = rot;
	infoSpots[id]["fromDimension"] = fromDimension;
	infoSpots[id]["toScriptinterior"] = toScriptinterior;
	infoSpots[id]["toDimension"] = toDimension;
	
	return true;

end



addEventHandler( "onPlayerMarkerHit", getRootElement( ),

	function ( markerHit, matchingDimension )
	
		if( matchingDimension ) then
		
			local id = getElementData( markerHit, "infoId" );
		
			if( id ~= false ) then
			
				local ret = warpToInterior( source, infoSpots[id]["toScriptinterior"] );
			
				if( ret > 0 ) then
				
					setElementDimension( source, infoSpots[id]["toDimension"] );
					setElementData( source, "Character.interior", id );
					
				end
			
			end
		
		end
	
	end

);