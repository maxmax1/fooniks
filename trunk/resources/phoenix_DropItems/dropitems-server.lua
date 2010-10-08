function displayLoadedRes( res )	

	LoadDropitems();
	setTimer( SaveDropItems, 120000, 0 );--120000, 0 );

end

addEventHandler( "onResourceStart", getResourceRootElement( getResourceFromName( "phoenix_Base" ) ), displayLoadedRes );
addEventHandler( "onResourceStart", getResourceRootElement( getThisResource() ), function () if( getResourceState( getResourceFromName( "phoenix_Base" ) ) == "running" ) then displayLoadedRes( ); end end );

function LoadDropitems( )

	local result = exports.phoenix_Base:SelectQuery( "SELECT * FROM ph_dropitems" );
		 
	if( result ) then
		 
		for k, v in ipairs( result ) do
		
			-- id 	dropName 	dropType 	dropAmount 	dropX 	dropY 	dropZ 	dropAng 	dropInt 	dropDim
			addDropItem( v["dropName"], v["dropType"], v["dropAmount"], v["dropX"], v["dropY"], v["dropZ"], v["dropAng"], v["dropInt"], v["dropDim"], v["id"] );
		
		end
		
	end

end

function SaveDropItems( )

	local alldrops = getElementsByType( "DropItems" );
	
	for k, v in ipairs( alldrops ) do 

		local myId = getElementData( v, "dropId" );
		local name = getElementData( v, "dropName" );
		local myType = getElementData( v, "dropType" );
		local myData = getElementData( v, "dropAmount" );
		local dropX = getElementData( v, "dropX" );
		local dropY = getElementData( v, "dropY" );
		local dropZ = getElementData( v, "dropZ" );
		local ang = getElementData( v, "dropAng" );	
		local int = getElementData( v, "dropInt" );	
		local dim = getElementData( v, "dropDim" );	
		
		if( myId ~= nil and myId ~= false ) then				
			
			if( name ~= false and myType ~= false and myData ~= false and dropX ~= false and dropY ~= false and dropZ ~= false and ang ~= false ) then 
			
				local query = exports.phoenix_Base:MysqlUpdatebuild("ph_dropitems");
				
				query = exports.phoenix_Base:MysqlSetField( query, "dropName", name );
				query = exports.phoenix_Base:MysqlSetField( query, "dropType", myType );
				query = exports.phoenix_Base:MysqlSetField( query, "dropAmount", myData );
				query = exports.phoenix_Base:MysqlSetField( query, "dropX", dropX );
				query = exports.phoenix_Base:MysqlSetField( query, "dropY", dropY );
				query = exports.phoenix_Base:MysqlSetField( query, "dropZ", dropZ );
				query = exports.phoenix_Base:MysqlSetField( query, "dropAng", ang );
				query = exports.phoenix_Base:MysqlSetField( query, "dropInt", int );
				query = exports.phoenix_Base:MysqlSetField( query, "dropDim", dim );
				
				query = exports.phoenix_Base:DoUpdateFinish( query, "id", myId );
				
			end
			
		else
		
			local query = "INSERT INTO `ph_dropitems` (`id`, `dropName`, `dropType`, `dropAmount`, `dropX`, `dropY`, `dropZ`, `dropAng`, `dropInt`, `dropDim`) VALUES (NULL, '" .. name .. "', '" .. myType .. "', '" .. myData .. "', '" .. dropX .. "', '" .. dropY .. "', '" .. dropY .. "', '" .. ang .. "', '" .. int .. "', '" .. dim .. "')";
			local result = exports.phoenix_Base:DoSimpleQuery( query, true );
			if( result ) then
			
				setElementData( v, "dropId", result );
				
			end
		
		end

	end

end

function addDropItem( name, iType, data, x, y, z, ang, int, dim, id )

	local element = createElement( "DropItems" );
	
	if( element ~= false ) then
	
		if( id ~= nil ) then
		
			setElementData( element, "dropId", id );
		
		end
	
		setElementData( element, "dropType", iType );
		setElementData( element, "dropName", name);
		setElementData( element, "dropAmount", data );
		setElementData( element, "dropX", x );
		setElementData( element, "dropY", y );
		setElementData( element, "dropZ", z );
		setElementData( element, "dropAng", ang );
		setElementData( element, "dropInt", int );
		setElementData( element, "dropDim", dim );
		
		x = tonumber( x );
		y = tonumber( y );
		z = tonumber( z );
		ang = tonumber( ang );
		int = tonumber( int );
		dim = tonumber( dim );		
		
		local obj = createObject( 1210, x, y, z );
		setElementParent( obj, element );
		setElementInterior( element, int );
		setElementDimension( element, dim );
		
	end

end

addEvent( "createDrop", true );
addEventHandler( "createDrop", getRootElement(), addDropItem );

function removeDropFromSql( element )

	local myId = getElementData( element, "dropId" );
	
	if( myId ~= false ) then
	
		local query = "DELETE FROM ph_dropitems WHERE id = '" .. myId  .. "' LIMIT 1";
		local result = exports.phoenix_Base:DoSimpleQuery( query );
	
	end

end


addEvent( "pickupDropItem", true );
addEventHandler( "pickupDropItem", getRootElement(), 

	function ( element )
	
		if( element and client ) then
		
			local myType = getElementData( element, "dropType" );
			local myData = getElementData( element, "dropAmount" );
			
			if( myType and myData and exports.Phoenix_Pockets:giveItem( client, myType, myData ) == true ) then
			
				removeDropFromSql( element );
				destroyElement( element );
			
			end
		
		end
	
	end

);

