items = { };
pockets = { };
max_items = 0;

function displayLoadedRes( res )	

	local ret = RegisterItems( );
	max_items = tonumber( get( "#NUM_POCKETS" ) ) + ret;
	outputDebugString( "Max Items is: " .. max_items );
	PocketsSafe();

end

addEventHandler( "onResourceStart", getResourceRootElement( getResourceFromName( "phoenix_Base" ) ), displayLoadedRes );
addEventHandler( "onResourceStart", getResourceRootElement( getThisResource() ), function () if( getResourceState( getResourceFromName( "phoenix_Base" ) ) == "running" ) then displayLoadedRes( ); end end );

function PocketsSafe( )

	for i = 1, max_items, 1 do
	
		local added = false;
		local result = exports.phoenix_Base:SelectQuery( "SHOW COLUMNS FROM ph_Pockets LIKE 'Pocket_" .. i .. "'" );
		
		if( result and #result > 0  ) then
		
			added = true;
		
		end
		
		if( added ~= true ) then
		
			-- Add the more spots to database so players can use them. :)
			exports.phoenix_Base:DoSimpleQuery( "ALTER TABLE `ph_Pockets` ADD `Pocket_" .. i .. "` VARCHAR( 32 ) NOT NULL DEFAULT '{0,0}'" );
		
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
            		
            	
            	end
            
      		end
			
			outputDebugString( "phoenix-Pockets: Registred Items." );
      		
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

	if( not thePlayer or not isElement ( thePlayer )  ) then return false; end
	local charId = getElementData( thePlayer, "Character.id" );
	if( not charId ) then return false; end	
	
	local result = exports.phoenix_Base:SelectQuery( "SELECT * FROM ph_Pockets WHERE cid = '" .. charId .. "'" );
	
	pockets[thePlayer] = { };
	clearPockets( thePlayer );
	
	if( result ) then
	
		if( #result > 0 ) then
			
  			for k, v in ipairs( result ) do
			
				for k2, v2 in pairs( v ) do
  									
					if( #k2 > 4 ) then -- We dont want the cid field, do we?
					
						local pocketId = tonumber( string.sub( k2, 8 ) ); -- escape Pocket_ in front of field name, and get the number only.
						
						if( pocketId ~= nil ) then
							
							-- v2 holds something like this: {1,2}
							local id, data = string.match(v2, "%{(%d+),(%d+)%}");
							if( id ~= nil and data ~= nil ) then
							
								giveItem( thePlayer, id, data );
								
							end
						
						end
					
					end
				
				end
    		
	  		end
		
		else
		
			result = exports.phoenix_Base:DoSimpleQuery( "INSERT INTO ph_Pockets(cid) VALUES('" .. charId .. "')" );
			
			if( result ) then
			
				setTimer( LoadPocketsForPlayer, 600, 1, thePlayer );
			
			end
		
		end
	
	end
	
end

addEvent( "onPocketsRequired", true );
addEventHandler( "onPocketsRequired", getRootElement(), LoadPocketsForPlayer );

function SavePockets( thePlayer )

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
	query = exports.phoenix_Base:DoUpdateFinish( query, "cid", charId);

end

addEvent( "onPocketsSave", true );
addEventHandler( "onPocketsSave", getRootElement(), SavePockets );
addEventHandler( "onCharacterSave", getRootElement( ), SavePockets );


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

function getSlotData( thePlayer, slot )

	if( thePlayer and slot ) then
	
		if( pockets[thePlayer] and pockets[thePlayer][slot] ) then
		
			return pockets[thePlayer][slot]["pData"];
		
		end
	
	end

end

function setSlotData( thePlayer, slot, data )

	if( thePlayer and slot and data ) then
	
		if( pockets[thePlayer] and pockets[thePlayer][slot] ) then
		
			pockets[thePlayer][slot]["pData"] = data;
			sync( thePlayer )
			return pockets[thePlayer][slot]["pData"];
		
		end
	
	end

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

addEvent( "onPocketClear", true );
addEventHandler( "onPocketClear", getRootElement(), clearPocket );

function sync( thePlayer )

	local tbl = {};
	
	for i = 1, max_items, 1 do
	
		if( pockets[thePlayer][i]["pType"] ~= nil and pockets[thePlayer][i]["pType"] > 0 ) then
		
			if( type( items[pockets[thePlayer][i]["pType"]] ) == "table" ) then
			
				local tbl2 = {};
				tbl2['type'] = items[pockets[thePlayer][i]["pType"]]["name"];
				tbl2['data'] = pockets[thePlayer][i]["pData"];
				tbl2['id'] = i;
				tbl2['pType'] = pockets[thePlayer][i]["pType"];
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
			
			elseif( items[myItem]["useEvent"] ) then
			
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