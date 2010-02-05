 connection = nil;

function displayLoadedRes( res )	
	
	if( not connection ) then
	
		connection = mysql_connect( get( "#phoenix_Base.MYSQL_HOST" ), get( "#phoenix_Base.MYSQL_USER" ), get( "#phoenix_Base.MYSQL_PASS" ), get( "#phoenix_Base.MYSQL_DB" ) );
		
		if( not connection ) then
		
			outputDebugString( "phoenix_Business: Ei saanud mysql ühendust kätte." );
			stopResource( res );
		
		else
		
			outputDebugString( "phoenix_Business: Mysql serveriga ühendatud." );
			LoadBizzes();			
			setTimer( SaveHousing, 110000, 0 );
		
		end	
		
	end
	
end

addEventHandler( "onResourceStart", getResourceRootElement( getThisResource( ) ), displayLoadedRes );

addEventHandler ( "onResourceStop", getResourceRootElement( getThisResource( ) ), 
    function ( resource )
	
		SaveBizzes( );
	
	end
	
);

function checkMySQLConnection( )

	if( mysql_ping( connection ) == false ) then
	
		outputDebugString( "Lost connection to the MySQL server, reconnecting ..." );
		mysql_close( connection );
		
		connection = mysql_connect( get( "#phoenix_Base.MYSQL_HOST" ), get( "#phoenix_Base.MYSQL_USER" ), get( "#phoenix_Base.MYSQL_PASS" ), get( "#phoenix_Base.MYSQL_DB" ) );
		
	end
  
end

function LoadBizzes( )

	local query = "SELECT * FROM ph_Buisness";
	local result = mysql_query( connection, query );

	if( result ) then
	
		for result, row in mysql_rows( result ) do
			
  			mysql_field_seek( result, 1 );
  			
  			local stuff = {};
			
			for k,v in ipairs( row ) do
  				
    			local field = mysql_fetch_field( result );
    			if (v == mysql_null()) then v = ''; end
      			stuff[field["name"]] = v;
    		
	  		end
		
			local officeTbl = { };
			officeTbl["posX"] = stuff["oPosX"];
			officeTbl["posY"] = stuff["oPosY"];
			officeTbl["posZ"] = stuff["oPosZ"];
			
			stuff["oPlace"] = tonumber( stuff["oPlace"] );
			if( stuff["oPlace"] and stuff["oPlace"] ~= 0 ) then
			
				officeTbl["int"] = exports.Phoenix_Housing:getHouseSanInt( stuff["oPlace"] );
				officeTbl["dim"] = 10000 + stuff["oPlace"];
				
			else
			
				officeTbl["int"] = 0;
				officeTbl["dim"] = 0;
			
			end
			
			local loadbayTbl = { };
			loadbayTbl["posX"] = stuff["lPosX"];
			loadbayTbl["posY"] = stuff["lPosY"];
			loadbayTbl["posZ"] = stuff["lPosZ"];			
			
			local serviceTbl = LoadBizServiceSpots( stuff["id"] );			
			local prodTbl = false;
			
			addBuisness( stuff["bizName"], stuff["bizType"], stuff["bizBank"], officeTbl, serviceTbl, loadbayTbl, prodTbl, stuff["id"] );
		
		end
	
	end

end

function LoadBizServiceSpots( id )

	local tbl = { };
	local query = "SELECT * FROM ph_Buisness_Services WHERE bid = '" .. id .. "'";
	local result = mysql_query( connection, query );
	
	if( result ) then
	
		while true do
		
			local row = mysql_fetch_row( result );
    		if(not row) then break end
			
			local tbl2 = { };
			tbl2["posX"] = row[2];
			tbl2["posY"] = row[3];
			tbl2["posZ"] = row[4];
			tbl2["int"] = row[5];
			tbl2["dim"] = row[6];
			tbl2["type"] = row[7];
			
			table.insert( tbl, tbl2 );
		
		end
	
	end
	
	return tbl;

end