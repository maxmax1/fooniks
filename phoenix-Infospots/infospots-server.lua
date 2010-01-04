infoSpots = { };
enterExitDisabled = { };

function displayLoadedRes( res )	

	RegisterInteriors( );
	
	-- Add some default infospots.
	addInfoSpot( "PIGPEN", 2421.3535, -1220.4412, 26.4849, 0, 0, 0, 0, 50 );	
	addInfoSpot( "GROVEGYM", 2229.9192, -1721.2841, 13.5616, 0, 0, 0, 0, 52 );
	addInfoSpot( "LSPD", 1554.7446, -1675.6805, 16.1953, 0, 0, 0, 0, 41 );
	addInfoSpot( "CITYHALL", 1480.9208,-1771.6025,18.7958, 0, 0, 0, 0, 53 );
	addInfoSpot( "BANK1", 595.4461, -1249.9810, 18.2705, 0, 0, 0, 0, 54 );

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
            	
            		setElementData( element, "infoId", id );
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

function warpToInterior( thePlayer, theInt, noTele )

	if( not thePlayer or not isElement ( thePlayer )  ) then return -1; end
	
	local suc, foundInt = getIntByID( theInt );
	if( not suc ) then
	
		return 0;
	
	end
	
	if( noTele == nil ) then noTele = false; end 
	
	local sampInt = getElementData( foundInt, "sampInt" );
	setElementInterior( thePlayer, sampInt );
	
	if( noTele ~= true ) then
	
		local x = getElementData( foundInt, "posX" );
		local y = getElementData( foundInt, "posY" );
		local z = getElementData( foundInt, "posZ" );
		local rot = getElementData( foundInt, "rot" );
	
		setElementPosition( thePlayer, x, y, z-1 );
		setPedRotation( thePlayer, rot );	
		
	end	
	return theInt;

end


function checkForIntSpawn( thePlayer )
		
	if( not thePlayer or not isElement ( thePlayer )  ) then return false; end
	local theInfo = getElementData( thePlayer, "Character.interior" );	
	if( type( infoSpots[theInfo] ) ~= "table" ) then return false; end
		
	enterExitDisabled[thePlayer] = true;
		
	local ret = warpToInterior( thePlayer, infoSpots[theInfo]["toScriptinterior"], true );
		
	if( ret > 0 ) then
			
		setElementDimension( thePlayer, infoSpots[theInfo]["toDimension"] );
		setTimer( enableEnterExit, 2000, 1, thePlayer );
		return true;
	
	end		
	
	return false;		
	
end

function addInfoSpot( id, x, y, z, rot, fromInt, fromDimension, toDimension, toScriptinterior, ex, ey, ez, eint )

	if( infoSpots[id] ~= nil ) then
	
		return false;
	
	end
	
	infoSpots[id]  = { };
	
	infoSpots[id]["marker"] = createMarker( x, y, z, "arrow", 2.0, 255, 255, 0 );
	setElementInterior( infoSpots[id]["marker"], fromInt );
	setElementDimension( infoSpots[id]["marker"], fromDimension );
	setElementData( infoSpots[id]["marker"], "infoId", id );
	
	infoSpots[id]["infoText"] = infoText;
	infoSpots[id]["x"] = x;
	infoSpots[id]["y"] = y;
	infoSpots[id]["z"] = z;
	infoSpots[id]["rot"] = rot;
	infoSpots[id]["fromDimension"] = fromDimension;
	infoSpots[id]["fromInt"] = fromInt;
	infoSpots[id]["toScriptinterior"] = toScriptinterior;
	infoSpots[id]["toDimension"] = toDimension;
	
	if( toScriptinterior ~= nil ) then
	
		local found, foundInt = getIntByID( toScriptinterior );
		
		if( found ) then
		
			local intx = getElementData( foundInt, "posX" );
			local inty = getElementData( foundInt, "posY" );
			local intz = getElementData( foundInt, "posZ" );
			local introt = getElementData( foundInt, "rot" );
			local intSan = getElementData( foundInt, "sampInt" );
			
			addInfoSpot( id .. ".Exit", intx, inty, intz, introt, intSan, toDimension, fromDimension, nil, x, y, z, fromInt );
			
		end
		
	else
	
		infoSpots[id]["ex"] = ex;
		infoSpots[id]["ey"] = ey;
		infoSpots[id]["ez"] = ez;
		infoSpots[id]["eint"] = eint;
	
	end
	
	return true;

end

function enableEnterExit( thePlayer )

	enterExitDisabled[thePlayer] = false;

end

addEventHandler( "onPlayerMarkerHit", getRootElement( ),

	function ( markerHit, matchingDimension )
	
		if( enterExitDisabled[source] ~= true and matchingDimension ) then
		
			local id = getElementData( markerHit, "infoId" );
		
			if( id ~= false ) then
				
				enterExitDisabled[source] = true;
				
				if( infoSpots[id]["toScriptinterior"] ~= nil ) then
				
					local ret = warpToInterior( source, infoSpots[id]["toScriptinterior"] );
			
					if( ret > 0 ) then
				
						setElementDimension( source, infoSpots[id]["toDimension"] );
						setElementData( source, "Character.interior", id );
						setTimer( enableEnterExit, 2000, 1, source );
					
					end
					
				else
				
					setElementPosition( source, infoSpots[id]["ex"], infoSpots[id]["ey"], infoSpots[id]["ez"] );
					setElementDimension( source, infoSpots[id]["toDimension"] ); 
					setElementInterior( source, infoSpots[id]["eint"] ); 					
					
					setElementData( source, "Character.interior", "0" );
					setTimer( enableEnterExit, 2000, 1, source );
					
				end
			
			end
		
		end
	
	end

);