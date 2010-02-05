infoSpots = { };
onSpot = { };
enterExitDisabled = { };

function displayLoadedRes( res )	

	RegisterInteriors( );
	
	-- Add some default infospots.
	addInfoSpot( "PIGPEN", 2421.3535, -1220.4412, 25.99, 0, 0, 0, 0, 50 );	
	addInfoSpot( "GROVEGYM", 2229.9192, -1721.2841, 14.2616, 0, 0, 0, 0, 52 );
	addInfoSpot( "LSPD", 1554.7446, -1675.6805, 16.195, 0, 0, 0, 0, 41 );
	addInfoSpot( "CITYHALL", 1480.9208,-1771.6025,19.3958, 0, 0, 0, 0, 53 );
	addInfoSpot( "BANK1", 595.4461, -1249.9810, 19.0705, 0, 0, 0, 0, 54 );
	addInfoSpot( "HAIGLA", 1172.971, -1323.282, 15.398, 0, 0, 0, 0, 55 );

end

addEventHandler( "onResourceStart", getResourceRootElement( getThisResource( ) ), displayLoadedRes );

addEventHandler( "onPlayerJoin", getRootElement( ), 

	function ()
	
		bindKey( source, "f", "down", EnterExit );
	
	end

);

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
					
					local child = xmlFindChild( node, "description", 0 );
            		setElementData( element, "description", xmlNodeGetValue( child ) );
					
					child = xmlFindChild( node, "rooms", 0 );
            		setElementData( element, "rooms", xmlNodeGetValue( child ) );
					
					child = xmlFindChild( node, "bathrooms", 0 );
            		setElementData( element, "bathrooms", xmlNodeGetValue( child ) );
					
					child = xmlFindChild( node, "images", 0 );
            		setElementData( element, "images", xmlNodeGetValue( child ) );
					
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
	
		setElementPosition( thePlayer, x, y, z );
		--triggerClientEvent( thePlayer, "onInteriorPosRequest", thePlayer, x, y, z );
		setPedRotation( thePlayer, rot );	
		
	end	
	return theInt;

end

addCommandHandler( "inti" ,

	function ( player, cmd, theInt )
	
		enterExitDisabled[player] = true;
		setTimer( enableEnterExit, 5000, 1, player );
		warpToInterior( player, theInt );
	
	end
	
);

function addInfoSpot( id, x, y, z, rot, fromInt, fromDimension, toDimension, toScriptinterior, ex, ey, ez, eint )

	if( infoSpots[id] ~= nil ) then
	
		return false;
	
	end
	
	z = z + 0.7;
	
	infoSpots[id]  = { };
	
	infoSpots[id]["marker"] = createMarker( x, y, z, "arrow", 1.0, 255, 255, 0 );
	setElementInterior( infoSpots[id]["marker"], fromInt );
	setElementDimension( infoSpots[id]["marker"], fromDimension );
	setElementData( infoSpots[id]["marker"], "infoId", id );
	
	z = z - 0.7;
	infoSpots[id]["infoText"] = infoText;
	infoSpots[id]["x"] = x;
	infoSpots[id]["y"] = y;
	infoSpots[id]["z"] = z;
	infoSpots[id]["rot"] = rot;
	infoSpots[id]["fromDimension"] = fromDimension;
	infoSpots[id]["fromInt"] = fromInt;
	infoSpots[id]["toScriptinterior"] = toScriptinterior;
	infoSpots[id]["toDimension"] = toDimension;
	infoSpots[id]["locked"] = false;
	
	if( toScriptinterior ) then
	
		local found, foundInt = getIntByID( toScriptinterior );
		
		if( found ) then
		
			local intx = getElementData( foundInt, "posX" );
			local inty = getElementData( foundInt, "posY" );
			local intz = getElementData( foundInt, "posZ" );
			local introt = getElementData( foundInt, "rot" );
			local intSan = getElementData( foundInt, "sampInt" );
			
			addInfoSpot( id .. ".Exit", intx, inty, intz, introt, intSan, toDimension, fromDimension, nil, x, y, z, fromInt );
		
		else
		
			setMarkerColor( infoSpots[id]["marker"], 0, 0, 255, 255 );
			return false;
		
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

function InfoSpotSetManual( id, status )

	if( string.find( id, ".Exit" ) ~= nil ) then
	
		local realId = string.sub( id, -5 );
		
		infoSpots[realId]["manual"] = status;
		infoSpots[id]["manual"] = status;
		
	else
	
		infoSpots[id]["manual"] = status;
		infoSpots[id .. ".Exit"]["manual"] = status;
	
	end
	
end

function InfoSpotSetLocked( id, status )

	if( string.find( id, ".Exit" ) ~= nil ) then
	
		local realId = string.sub( id, -5 );
		
		infoSpots[realId]["locked"] = status;
		infoSpots[id]["locked"] = status;
		
		if( status == true ) then
		
			setMarkerColor( infoSpots[realId]["marker"], 255, 0, 0, 255 );
			setMarkerColor( infoSpots[id]["marker"], 255, 0, 0, 255 );
			
		else
		
			setMarkerColor( infoSpots[realId]["marker"], 0, 255, 0, 255 );
			setMarkerColor( infoSpots[id]["marker"], 0, 255, 0, 255 );
		
		end			
	
	else
	
		infoSpots[id]["locked"] = status;
		infoSpots[id .. ".Exit"]["locked"] = status;
		
		if( status == true ) then
		
			setMarkerColor( infoSpots[id .. ".Exit"]["marker"], 255, 0, 0, 255 );
			setMarkerColor( infoSpots[id]["marker"], 255, 0, 0, 255 );
			
		else
		
			setMarkerColor( infoSpots[id .. ".Exit"]["marker"], 0, 255, 0, 255 );
			setMarkerColor( infoSpots[id]["marker"], 0, 255, 0, 255 );
		
		end			
		
	end

end

function InfoSpotGetLocked( id )

	if( string.find( id, ".Exit" ) ~= nil ) then
	
		local realId = string.sub( id, -5 );
		return infoSpots[realId]["locked"];
	
	else
	
		return infoSpots[id]["locked"];
		
	end

end

function InfoSpotSetMarkerChild( id, parent )

	local realId;

	if( string.find( id, ".Exit" ) ~= nil ) then
	
		realId = string.sub( id, -5 );
		
		setElementParent( parent, infoSpots[realId]["marker"] );
		setElementParent( parent, infoSpots[id]["marker"] );
		
	else
	
		setElementParent( parent, infoSpots[id]["marker"] );
		setElementParent( parent, infoSpots[id .. ".Exit"]["marker"] );
		
	end

end

addEventHandler( "onPlayerMarkerLeave", getRootElement( ), 

	function ( markerLeft, matchingDimension )
	
		if( matchingDimension and onSpot[source] ) then
		
			local id = getElementData( markerLeft, "infoId" );
		
			if( id ~= false ) then
			
				onSpot[source] = nil;
			
			end
		
		end
	
	end

);

addEventHandler( "onPlayerMarkerHit", getRootElement( ),

	function ( markerHit, matchingDimension )
	
		if( enterExitDisabled[source] ~= true and matchingDimension ) then
		
			local id = getElementData( markerHit, "infoId" );
		
			if( id ~= false ) then
			
				local veh = getPedOccupiedVehicle( source );
			
				if( veh ~= false ) then
					
					local vType = getVehicleType( veh ) ;
					if( vType ~= "Bike" or vType ~= "BMX" ) then
					
						return false;
						
					end
				
				end
				
				if( infoSpots[id]["locked"] == true ) then
				
					exports.phoenix_Chat:OocInfo( source, "See uks on lukus. Vajuta ukse peale hiirega." );
					return false;
					
				elseif( infoSpots[id]["manual"] == true ) then
				
					exports.phoenix_Chat:OocInfo( source, "Vajuta F, et siseneda." );
					onSpot[source] = id;
					return false;
				
				end
				
				doEnter( source, id );
			
			end
		
		end
	
	end

);

function EnterExit( thePlayer, key, state )

	if( onSpot[thePlayer] ) then
	
		doEnter( thePlayer, onSpot[thePlayer] );
		onSpot[thePlayer] = nil;
	
	end

end

function doEnter( thePlayer, id )

	enterExitDisabled[thePlayer] = true;
	if( infoSpots[id]["toScriptinterior"] ~= nil ) then
	
		local ret = warpToInterior( thePlayer, infoSpots[id]["toScriptinterior"] );

		if( ret > 0 ) then
	
			setElementDimension( thePlayer, infoSpots[id]["toDimension"] );
			setElementData( thePlayer, "Character.interior", infoSpots[id]["toScriptinterior"] );
			setTimer( enableEnterExit, 2000, 1, thePlayer );
		
		end
		
	else
	
		--triggerClientEvent( thePlayer, "onInteriorPosRequest", thePlayer, infoSpots[id]["ex"], infoSpots[id]["ey"], infoSpots[id]["ez"] );
		setElementPosition( thePlayer, infoSpots[id]["ex"], infoSpots[id]["ey"], infoSpots[id]["ez"] );
		setElementDimension( thePlayer, infoSpots[id]["toDimension"] ); 
		setElementInterior( thePlayer, infoSpots[id]["eint"] ); 					
		
		setElementData( thePlayer, "Character.interior", "0" );
		setTimer( enableEnterExit, 2000, 1, thePlayer );
		
	end

end