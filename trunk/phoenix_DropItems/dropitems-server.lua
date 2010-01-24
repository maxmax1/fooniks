connection = nil;

function displayLoadedRes( res )	
	
	if( not connection ) then
	
		connection = mysql_connect( get( "#phoenix_Base.MYSQL_HOST" ), get( "#phoenix_Base.MYSQL_USER" ), get( "#phoenix_Base.MYSQL_PASS" ), get( "#phoenix_Base.MYSQL_DB" ) );
		
		if( not connection ) then
		
			outputDebugString( "phoenix_DropItems ei saanud mysql ühendust kätte." );
			stopResource( res );
		
		else
		
			outputDebugString( "Mysql serveriga ühendatud." );
			LoadDropitems();
			setTimer( SaveDropItems, 120000, 0 );--120000, 0 );
		
		end	
		
	end
	
end

addEventHandler( "onResourceStart", getResourceRootElement( getThisResource( ) ), displayLoadedRes );

function checkMySQLConnection ( )

	if( mysql_ping( connection ) == false ) then
	
		outputDebugString( "Lost connection to the MySQL server, reconnecting ..." );
		mysql_close( connection );
		
		connection = mysql_connect( get( "#phoenix_Base.MYSQL_HOST" ), get( "#phoenix_Base.MYSQL_USER" ), get( "#phoenix_Base.MYSQL_PASS" ), get( "#phoenix_Base.MYSQL_DB" ) );
		
	end
  
end


function LoadDropitems( )

	local query = "SELECT * FROM ph_dropitems";
	local result = mysql_query( connection, query );
	local added = 0;
		 
	if( result ) then
		 
		for result ,row in mysql_rows( result ) do
		
			-- id 	dropName 	dropType 	dropAmount 	dropX 	dropY 	dropZ 	dropAng 	dropInt 	dropDimension
			addDropItem( row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9], row[10], row[1] );
		
		end
		
	end

end

function SaveDropItems( )

	checkMySQLConnection( );

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
				
				query = exports.phoenix_Base:UpdateFinish( query, "id", myId );
		
				if( query ~= false) then
				
					local result = mysql_query( connection, query );
					if( result ~= false and result ~= nil ) then mysql_free_result( result ); end
					
				end
				
			end
			
		else
		
			local query = "INSERT INTO `ph_dropitems` (`id`, `dropName`, `dropType`, `dropAmount`, `dropX`, `dropY`, `dropZ`, `dropAng`, `dropInt`, `dropDimension`) VALUES (NULL, '" .. name .. "', '" .. myType .. "', '" .. myData .. "', '" .. x .. "', '" .. y .. "', '" .. z .. "', '" .. ang .. "', '" .. int .. "', '" .. dim .. "')";
			local result = mysql_query( connection, query );
			if( result ~= false and result ~= nil ) then
			
				setElementData( v, "dropId", mysql_insert_id( connection ) );
				mysql_free_result( result );
				
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
		local result = mysql_query( connection, query );
		if( result ~= false and result ~= nil ) then mysql_free_result( result ); end
	
	end

end


addEvent( "pickupDropItem", true );
addEventHandler( "pickupDropItem", getRootElement(), 

	function ( element )
	
		if( client ) then
		
			local myType = getElementData( element, "dropType" );
			local myData = getElementData( element, "dropAmount" );
			
			if( myType and myData and exports.Phoenix_Pockets:giveItem( client, myType, myData ) == 0 ) then
			
				removeDropFromSql( element );
				destroyElement( element );
			
			end
		
		end
	
	end

);

