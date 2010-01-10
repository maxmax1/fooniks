connection = nil;

function displayLoadedRes( res )	
	
	if( not connection ) then
	
		connection = mysql_connect( get( "#phoenix_Base.MYSQL_HOST" ), get( "#phoenix_Base.MYSQL_USER" ), get( "#phoenix_Base.MYSQL_PASS" ), get( "#phoenix_Base.MYSQL_DB" ) );
		
		if( not connection ) then
		
			outputDebugString( "phoenix_Housing: Ei saanud mysql ühendust kätte." );
			stopResource( res );
		
		else
		
			outputDebugString( "phoenix_Housing: Mysql serveriga ühendatud." );
			LoadHousing();			
			setTimer( SaveHousing, 110000, 0 );
		
		end	
		
	end
	
end

addEventHandler( "onResourceStart", getResourceRootElement( getThisResource( ) ), displayLoadedRes );

addEventHandler ( "onResourceStop", getResourceRootElement( getThisResource( ) ), 
    function ( resource )
	
		SaveHousing( );
	
	end
	
);

function checkMySQLConnection ( )

	if( mysql_ping( connection ) == false ) then
	
		outputDebugString( "Lost connection to the MySQL server, reconnecting ..." );
		mysql_close( connection );
		
		connection = mysql_connect( get( "#phoenix_Base.MYSQL_HOST" ), get( "#phoenix_Base.MYSQL_USER" ), get( "#phoenix_Base.MYSQL_PASS" ), get( "#phoenix_Base.MYSQL_DB" ) );
		
	end
  
end

function LoadHousing( )

	local query = "SELECT * FROM ph_Houses";
	local result = mysql_query( connection, query );
	
	if( result ) then
	
		local i = 1;
		
  		while true do
  		
    		local row = mysql_fetch_row( result );
    		if(not row) then break end
			
			-- TODO: By field name, so editing sql field order doesent mess everything up. :)
			
			local ret = addHouse( row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9], row[10], row[12], row[11], row[13], row[14], row[18], row[1], row[15], row[16], row[17], row[18] );
			
		end
		
  	end

end

function SaveHousing( )

	local houses = getElementsByType( "House" );
	
	for k,v in ipairs( houses ) do
	
		local myId = getElementData( v, "houseId" );	
		local price = getElementData( v, "price" );
		local owner = getElementData( v, "owner" );
		local rentable = getElementData( v, "rentable" );
		local rentcost = getElementData( v, "rentcost" );
		local renters = getElementData( v, "Renters" );
		local locked = getElementData( v, "locked" );
		local safeInf = getElementData( v, "Safe" );
		local hasSafe = getElementData( v, "HasSafe" );
		
		if( myId ~= false ) then
		
			local query = exports.phoenix_Base:MysqlUpdatebuild("ph_Houses");
				
			query = exports.phoenix_Base:MysqlSetField( query, "Price", price );
			query = exports.phoenix_Base:MysqlSetField( query, "Owner", owner );
			query = exports.phoenix_Base:MysqlSetField( query, "Rentable", rentable );
			query = exports.phoenix_Base:MysqlSetField( query, "RentCost", rentcost );
			query = exports.phoenix_Base:MysqlSetField( query, "Renters", renters );
			query = exports.phoenix_Base:MysqlSetField( query, "locked", locked );
			query = exports.phoenix_Base:MysqlSetField( query, "HasSafe", hasSafe );
			query = exports.phoenix_Base:MysqlSetField( query, "Safe", safeInf );
			
			query = exports.phoenix_Base:UpdateFinish( query, "id", myId );
		
			local result = mysql_query( connection, query );
			if( result ~= false and result ~= nil ) then mysql_free_result( result ); end
		
		end
	
	end

end

function addHouse( address, posX, posY, posZ, trashX, trashY, trashZ, trashAng, interior, price, owner, rentable, rentcost, locked, id, renters, Safe, HasSafe, isUpgrading )

	local myId = 0;

	if( id ~= nil ) then
	
		myId = tonumber( id );
		
	else
	
		-- insert
		local query = "INSET INTO ph_Houses(id, address, posX, posY, posZ, interior) VALUES(NULL, '" .. address .. "', '" .. posX .. "', '" .. posY .. "', '" .. posZ .. "', '" .. interior .. "')";
		local result = mysql_query( connection, query );
		if( result ~= false and result ~= nil ) then
		
			myId = mysql_insert_id();
			mysql_free_result( result );
			
		end
	
	end
	
	local element = createElement( "House" );

	interior = tonumber( interior );

	setElementData( element, "houseId", myId );
	setElementData( element, "Address", address );
	setElementData( element, "posX", posX );
	setElementData( element, "posY", posY );
	setElementData( element, "posZ", posZ );
	setElementData( element, "trashX", trashX );
	setElementData( element, "trashY", trashY );
	setElementData( element, "trashZ", trashZ );
	setElementData( element, "trashAng", trashAng );
	setElementData( element, "scriptInt", interior );		
	setElementData( element, "price", price );
	setElementData( element, "owner", owner );
	setElementData( element, "rentable", rentable );
	setElementData( element, "rentcost", rentcost );
	setElementData( element, "locked", locked );
	
	setElementData( element, "Renters", renters );
	setElementData( element, "Safe", Safe );
	setElementData( element, "HasSafe", HasSafe );	
	setElementData( element, "isUpgrading", isUpgrading );	
	
	exports.phoenix_Jobs:AddTrashCan( trashX, trashY, trashZ, trashAng );
	-- Houses start at dimension 10000. :)
	
	if( tonumber( owner ) == 0 ) then locked = 1; end
	
	if( exports.phoenix_Infospots:addInfoSpot( "House." .. myId, posX, posY, posZ, 0, 0, 0, 10000+myId, interior ) ~= false ) then
		
		if( tonumber( locked ) == 1 ) then
		
			exports.phoenix_Infospots:InfoSpotSetLocked( "House." .. myId, true );
		
		else
		
			exports.phoenix_Infospots:InfoSpotSetLocked( "House." .. myId, false );
		
		end
		
		-- InfoSpotSetMarkerChild( "House." .. myId, element );
		
	end	
	return element;
	
end

function getHousePriceFromZone( x, y, z )

	local zone = getZoneName( x, y, z );
	zone = string.gsub( zone, " ", "_" );	
	local zoneprice = get( "#House." .. zone ); -- Get price from settings..
	if( zoneprice == false ) then zoneprice = get( "#House.Default" ); end
	if( not zoneprice ) then zoneprice = 25000; end
	
	local Mod = get( "#priceMod" );
	if( not Mod ) then Mod = 1000; end
	
	zoneprice = tonumber( zoneprice ) + math.random( -Mod, Mod );
	
	return RealPrice( zone, zoneprice );

end

function RealPrice( zoneName, curPrice )
	
	-- TODO: Check how many for sale houses are in current zone, And change the price according to that.
	local tbl = getElementsByType( "House" );
	local free = 0;
	local all = 0;
	
	for k,v in ipairs( tbl ) do
	
		if( zoneName == getElementZoneName( v ) ) then
		
			if( tonumber( getElementData( v, "owner" ) ) == 0 ) then
			
				free = free + 1;
			
			end
			
			all = all + 1;
		
		end
	
	end
	
	local pre = 1;
	if( free ~= 0 and all ~= 0 ) then pre = free / all; end
	
	local priceMod = 1;
	if( pre > 0.5 ) then priceMod = -1; end
	local Mod = get( "#priceMod" );
	if( Mod == false ) then Mod = 1000; end	
	
	return curPrice + ( math.random( Mod )*pre*priceMod ), free, all;

end

addEvent( "onHouseReg", true );
addEventHandler( "onHouseReg", getRootElement(), 

	function ( houseInf )
	
		if( client ) then
		
			local acc = getPlayerAccount( client );
			
			if( acc ~= false and isGuestAccount( acc ) == false ) then
			
				local price, free, all = getHousePriceFromZone( houseInf[1], houseInf[2], houseInf[3] );
				local addr = getZoneName( houseInf[1], houseInf[2], houseInf[3] ) .. (all+1);
				
				addHouse( addr, houseInf[1], houseInf[2], houseInf[3], houseInf[4], houseInf[5], houseInf[6], houseInf[7], houseInf[8], price, 0, 0, 50, 0, nil, "", "{0,0},{0,0},{0,0},{0,0},{0,0}", "0", "0" );
			
			else
			
				outputChatBox( "Pead olema admin/mode/dev.", client );
			
			end
		
		end
	
	end
	
);

addEvent( "onPropertyPurchase", true );
addEventHandler( "onPropertyPurchase", getRootElement(),

	function ( houseElem )
	
		if( client ) then
		
			local charId = getElementData( client, "Character.id" );
			if( not charId ) then

				return false;

			end		
		
			local price = tonumber( getElementData( houseElem, "price" ) );
			takePlayerMoney( client, price );
			setElementData( houseElem, "owner", charId );
			setElementData( houseElem, "rentable", "0" );
			setElementData( houseElem, "Renters", "" );
		
		end
	
	end
	
);

addEvent( "onPropertyRent", true );
addEventHandler( "onPropertyRent", getRootElement(),

	function ( houseElem )
	
		if( client ) then
		
			local charId = getElementData( client, "Character.id" );
			if( not charId ) then

				return false;

			end		
		
			local rentPrice = tonumber( getElementData( houseElem, "rentcost" ) );
			takePlayerMoney( client, rentPrice );
			
			local str = getElementData( houseElem, "Renters" );
			
			if( #str < 1 ) then -- no renters
			
				str = charId;
			
			else
			
				str = str .. "," .. charId;
			
			end
			
			setElementData( houseElem, "Renters", str );
		
		end
	
	end
	
);

addEventHandler( "onPrePayDay", getRootElement( ), 

	function ( )
	
		local houses = getElementsByType( "House" );
		local renters = { };
	
		for k,v in ipairs( houses ) do
		
			local isUpgrading = tonumber( getElementData( v, "isUpgrading" ) );
			
			if( isUpgrading == 1 ) then
			
				setElementData( v, "isUpgrading", "0" );
				setElementData( v, "HasSafe", "1" );
			
			end
		
			local owner = tonumber( getElementData( v, "owner" ) );
			local rentcost = tonumber( getElementData( v, "rentcost" ) );
			local addr = getElementData( v, "Address" );
			
			if( owner ~= 0 ) then
			
				local str = getElementData( v, "Renters" );
			
				for word in string.gmatch( str, "%d+" ) do
				
					exports.phoenix_Base:PayDayTax( tonumber( word ), "Maja " .. addr .. " Rent", rentcost );
				
				end				
			
			end
		
		end
	
	end

);

function ChangeLocked( houseElem )

	if( client ) then
	
		local myId = tonumber( getElementData( houseElem, "houseId" ) );
		local locked = tonumber( getElementData( houseElem, "locked" ) );
	
		local lockStat = true;
		local lockStr = 1;
		if( locked == 1 ) then lockStat = false; lockStr = 0; end
		
		exports.phoenix_Infospots:InfoSpotSetLocked( "House." .. myId, lockStat );
		setElementData( houseElem, "locked", lockStr );
	
	end

end

addEvent( "onPropertyLockedChange", true );
addEventHandler( "onPropertyLockedChange", getRootElement(), ChangeLocked );

addEvent( "onPropertyUnRent", true );
addEventHandler( "onPropertyUnRent", getRootElement(),
	
	function ( houseElem, charId )
	
		if( client ) then
		
			if( not charId ) then
				
				charId = getElementData( client, "Character.id" );
				outputChatBox( "Lõpetasid rendilepingu...", client );
				
			else
			
				outputChatBox( "Lõpetasid rentnikuga lepingu...", client );
			
			end
			
			RemoveRenter( houseElem, charId );
		
		end
	
	end
	
);

addEvent( "onPropertySell", true );
addEventHandler( "onPropertySell", getRootElement(),
	
	function ( houseElem )
	
		if( client ) then
		
			local price = tonumber( getElementData( houseElem, "price" ) );
			givePlayerMoney( client, price );
			
			setElementData( houseElem, "owner", "0" );
			setElementData( houseElem, "rentable", "0" );
			setElementData( houseElem, "Renters", "" );
			setElementData( houseElem, "rentcost", "50" );
			
			setElementData( houseElem, "locked", "0" ); -- Set to unlocked, so it will be locked by ChangeLocked.			
			ChangeLocked( houseElem );
			
			outputChatBox( "Müüsid oma maja edukalt maha...", client );
		
		end
	
	end
	
);

addEvent( "onPropertyKickRenters", true );
addEventHandler( "onPropertyKickRenters", getRootElement(),
	
	function ( houseElem )
	
		if( client ) then
		
			setElementData( houseElem, "Renters", "" );			
			outputChatBox( "Lõpetasid rentnikega lepingud...", client );
		
		end
	
	end
	
);

function RemoveRenter( houseElem, renterId )

	renterId = tonumber( renterId );
	local tbl = { };	
	local str = getElementData( houseElem, "Renters" );
	
	for word in string.gmatch( str, "%d+" ) do
	
		if( tonumber( word ) ~= renterId ) then
		
			table.insert( tbl, tonumber( word ) );
		
		end
	
	end	
	
	str = table.concat( tbl, "," );
	setElementData( houseElem, "Renters", str );

end