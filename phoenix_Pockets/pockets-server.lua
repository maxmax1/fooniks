connection = nil;

items = { };
pockets = { };
max_items = 0;

function displayLoadedRes( res )	

	if( not connection ) then
	
		connection = mysql_connect( get( "#phoenix_Base.MYSQL_HOST" ), get( "#phoenix_Base.MYSQL_USER" ), get( "#phoenix_Base.MYSQL_PASS" ), get( "#phoenix_Base.MYSQL_DB" ) );
		
		if( not connection ) then
		
			outputDebugString( "Phoenix-Pockets: Ei saanud mysql ühendust kätte." );
			stopResource( res );
		
		else
		
			outputDebugString( "Phoenix-Pockets: Mysql serveriga ühendatud." );
			local ret = RegisterItems( );
			max_items = tonumber( get( "#NUM_POCKETS" ) ) + ret;
			outputDebugString( "Max Items is: " .. max_items );
			PocketsSafe();
		
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

function PocketsSafe( )

	for i = 1, max_items, 1 do
	
		local added = false;
		local query = "SHOW COLUMNS FROM ph_Pockets LIKE 'Pocket_" .. i .. "'";
		local result = mysql_query( connection, query );
		
		if( result ~= false ) then
		
			if( mysql_num_rows( result ) > 0 ) then
		
				mysql_free_result( result );
				added = true;
			
			end
		
			mysql_free_result( result );
		
		end
		
		if( added ~= true ) then
		
			-- Add the more spots to database so players can use them. :)
			query = "ALTER TABLE `ph_Pockets` ADD `Pocket_" .. i .. "` VARCHAR( 32 ) NOT NULL DEFAULT '{0,0}'";
			result = mysql_query( connection, query );
			
			if( result ~= false and result ~= nil ) then	
			
				mysql_free_result( result );
			
			end	
		
		end
	
	end
	
end

function RegisterItems( )

	local ret = 0;
	local xmlFile =  xmlLoadFile ( "items.xml" );
	if ( xmlFile ~= false ) then
	
		outputDebugString( "phoenix-Pockets: Items database loaded." );
	
		local allItems = xmlNodeGetChildren( xmlFile );
		
		if( allItems ~= false ) then
		
			for i, node in ipairs( allItems ) do
		
            	local id = tonumber( xmlNodeGetAttribute( node, "id" ) );
            	
            	if( id ~= false ) then
            	
            		items[id] = { };
            		
            		items[id]["myType"] = xmlNodeGetAttribute( node, "type" );
            		
            		if( items[id]["myType"] == "WEAPON" ) then
            		
            			items[id]["wepId"] = tonumber( xmlNodeGetAttribute( node, "weaponId" ) );
            		
					elseif( items[id]["myType"] == "POCKET" ) then
					
						items[id]["extraSlots"] = tonumber( xmlNodeGetAttribute( node, "extraSlots" ) );
						
						if( extraSlots > ret ) then ret = extraSlots; end -- allows us to always be sure there are enough fields in the DB.
					
            		else
            		
            			items[id]["useEvent"] = xmlNodeGetAttribute( node, "useEvent" );
            			items[id]["eventType"] = xmlNodeGetAttribute( node, "eventType" );
            		
            		end
            		
            	 	items[id]["parent"] = tonumber( xmlNodeGetAttribute( node, "parent" ) );
            		items[id]["name"] = xmlNodeGetAttribute( node, "name" );
            		items[id]["canDrop"] = xmlNodeGetAttribute( node, "canDrop" );
            		
            		outputDebugString( "Registred Item: " .. id .. "->" .. items[id]["name"] );
            	
            	end
            
      		end
      		
      	else
      	
      		outputDebugString( "phoenix-Pockets: Bad Database syntax.", 1 );
      		      
       	end

		xmlUnloadFile ( xmlFile );
		
	else
	
		outputDebugString( "phoenix-Pockets: Pockets database failed to load.", 1 );
		
	end
	
	return ret;

end

function LoadPocketsForPlayer( thePlayer )

	checkMySQLConnection( );

	if( not thePlayer or not isElement ( thePlayer )  ) then return false; end
	local charId = getElementData( thePlayer, "Character.id" );
	if( not charId ) then return false; end	
	
	local query = "SELECT * FROM ph_Pockets WHERE cid = '" .. charId .. "'";
	local result = mysql_query( connection, query );
	
	pockets[thePlayer] = { };
	clearPockets( thePlayer );
	
	if( result ~= false ) then
	
		if( mysql_num_rows( result ) > 0 ) then
		
			mysql_field_seek( result, 1 );
			
  			for k,v in ipairs( mysql_fetch_row( result ) ) do
  				
    			local field = mysql_fetch_field( result );
    			if (v == mysql_null()) then v = ''; end
    			
				if( #field["name"] > 4 ) then -- We dont want the cid field, do we?
				
					local pocketId = tonumber( string.sub( field["name"], 8 ) ); -- escape Pocket_ in front of field name, and get the number only.
					
					if( pocketId ~= nil ) then
						
						-- v holds something like this: {1,2}
						local id, data = string.match(v, "%{(%d+),(%d+)%}");
						if( id ~= nil and data ~= nil ) then
						
							giveItem( thePlayer, id, data );
							
						end
					
					end
				
				end
    		
	  		end
		
		else
	
			mysql_free_result( result );
			query = "INSERT INTO ph_Pockets(cid) VALUES('" .. charId .. "')";
			result = mysql_query( connection, query );
			
			if( result ~= false ) then
			
				mysql_free_result( result );
				setTimer( LoadPocketsForPlayer, 600, 1, thePlayer );
				
			end
		
		end
	
	end
	
end

addEvent( "onPocketsRequired", true );
addEventHandler( "onPocketsRequired", getRootElement(), LoadPocketsForPlayer );

function SavePockets( thePlayer )

	checkMySQLConnection( );

	if( not thePlayer or not isElement ( thePlayer )  ) then return false; end
	local charId = getElementData( thePlayer, "Character.id" );
	if( not charId ) then return false; end	
	
	-- Start query building
	local query = exports.phoenix_Base:MysqlUpdatebuild( "ph_Pockets");	
	
	for i = 1, max_items, 1 do
	
		-- Set Fields
		query = exports.phoenix_Base:MysqlSetField( query, "Pocket_" .. i, "{" .. pockets[thePlayer][i]["pType"] .. "," .. pockets[thePlayer][i]["pData"] .. "}" );
	
	end
	
	-- Finish query.
	query = exports.phoenix_Base:UpdateFinish( query, "cid", charId);
	
	local result = mysql_query( connection, query );
	if( result ~= false ) then mysql_free_result( result ); end	

end

addEvent( "onPocketsSave", true );
addEventHandler( "onPocketsSave", getRootElement(), SavePockets );


function findFreeSlot( playerid, forItem )

	if( type( items[forItem] ) ~= "table" ) then
	
		return false;
	
	end

	if( items[forItem]["parent"] ~= -1 ) then
	
		forItem = items[forItem]["parent"];
		
	end
	
	if( items[forItem]["myType"] == "DATA1" or items[forItem]["myType"] == "WEAPON") then -- Where there can be only one add to that slot.

		local slot = getSlotByItem( playerid, forItem );
		if( slot ~= false ) then return slot; end
		
	end
	
	for i = 1, max_items, 1 do
	
		if(pockets[playerid][i]["pType"] == 0) then 
			return i;	
		end	
	
	end
	return false;
	
end

function getSlotByItem( playerid, item )

	for i = 1, max_items, 1 do
	
		if( tonumber( pockets[playerid][i]["pType"] ) == item ) then
			return i;
		end
		
	end
	
	return false;
	
end

function clearPockets( playerid )

	if( type( pockets[playerid] ) ~= "table" ) then
	
		pockets[playerid] = { };
	
	end

	for i = 1, max_items, 1 do
	
		if( type( pockets[playerid][i] ) ~= "table" ) then
		
			pockets[playerid][i] = { };
			
		end
	
		pockets[playerid][i]["pType"] = 0;
		pockets[playerid][i]["pData"] = 0;
		
	end
	
	sync( playerid );
	
end

function clearPocket( playerid, pocketId )

	pockets[playerid][pocketId]["pType"] = 0;
	pockets[playerid][pocketId]["pData"] = 0;
	sync( playerid );

end

function sync( thePlayer )

	local tbl = {};
	
	for i = 1, max_items, 1 do
	
		if( pockets[thePlayer][i]["pType"] ~= nil and pockets[thePlayer][i]["pType"] > 0 ) then
		
			if( type( items[pockets[thePlayer][i]["pType"]] ) == "table" ) then
			
				local tbl2 = {};
				tbl2['type'] = items[pockets[thePlayer][i]["pType"]]["name"];
				tbl2['data'] = pockets[thePlayer][i]["pData"];
				tbl2['id'] = i;
				table.insert( tbl, tbl2 );
			
			end
			
		end
		
	end
	
	triggerClientEvent( thePlayer, "SyncItem", getRootElement( ), tbl );

end

function getItemByWeapon( weaponid )

	for i = 1, max_items, 1 do
	
		if(items[i]["myType"] == "WEAPON" and items[i]["wepId"] == weaponid ) then
		
			if( items[i]["parent"] ~= -1 ) then
			
				return items[i]["parent"];
			
			else
			
				return i;
			
			end
		
		end
	
	end
	
	return false;
end

function giveItem( playerid, itemId, amount )

	itemId = tonumber( itemId );
	amount = tonumber( amount );

	if( itemId == nil or itemId == 0 ) then return amount; end
	if( type( items[itemId] ) ~= "table" ) then
	
		return false;
	
	end

	local freeSlot = findFreeSlot( playerid, itemId );
	
	if(freeSlot == false) then

		return false;
		
	end
	
	pockets[playerid][freeSlot]["pType"] = itemId;
	pockets[playerid][freeSlot]["pData"] = pockets[playerid][freeSlot]["pData"] + amount;	
	giveItemOtherStuff( playerid, itemId, amount );		
	sync( playerid );	
	return true;
	
end

function giveItemOtherStuff( playerid, itemid, amount )

	if( type( items[itemid] ) ~= "table" ) then return false; end
	
	if( items[itemid]["myType"] == "WEAPON" ) then
	
		giveWeapon( playerid, items[itemid]["wepId"], amount );
	
	end
	
	return true;
	
end

addEvent( "onUseItem", true );
addEventHandler( "onUseItem", getRootElement(), 
	
	function ( pocketid )
	
		if( client ) then
		
			local myItem = pockets[client][pocketid]["pType"];
		
			if( items[myItem]["myType"] == "WEAPON" ) then
			
				setPedWeaponSlot( client, getSlotFromWeapon( items[myItem]["wepId"] ) );
			
			elseif( items[myItem]["myType"] == "POCKET" ) then
			
				outputChatBox( "Seda ei saa kasutada." );
			
			else
			
				local ret = triggerEvent( items[myItem]["useEvent"], client, pocketid, pockets[client][pocketid]["pType"], pockets[client][pocketid]["pData"] );
				
			end
		
		end
	
	end

);

addEvent( "onDropItem", true );
addEventHandler( "onDropItem", getRootElement(), 
	
	function ( pocketid )
	
		if( client ) then
		
			local myItem = pockets[client][pocketid]["pType"];
		
			if( items[myItem]["myType"] == "WEAPON" ) then
			
				takeWeapon( client, items[myItem]["wepId"] );
			
			end
			
			local x, y, z = getElementPosition( client );
			local ang = getPedRotation( client );
			local int = getElementInterior( client );
			local dim = getElementDimension( client );
			
			exports.Phoenix_DropItems:addDropItem( items[myItem]["name"], pockets[client][pocketid]["pType"], pockets[client][pocketid]["pData"], x, y, z, ang, int, dim );
		
			pockets[client][pocketid]["pType"] = 0;
			pockets[client][pocketid]["pData"] = 0;
			sync( client );
			
		end
	
	end

);

addEvent( "onDestroyItem", true );
addEventHandler( "onDestroyItem", getRootElement(), 
	
	function ( pocketid )
	
		if( client ) then
		
			local myItem = pockets[client][pocketid]["pType"];
		
			if( items[myItem]["myType"] == "WEAPON" ) then
			
				takeWeapon( client, items[myItem]["wepId"] );
			
			end
			
			pockets[client][pocketid]["pType"] = 0;
			pockets[client][pocketid]["pData"] = 0;
			sync( client );
		
		end
	
	end

);