connection = nil;
inHourJump = false;

tax = { };
income = { };

function displayLoadedRes( res )	

	if( not connection ) then
	
		connection = mysql_connect( get( "#MYSQL_HOST" ), get( "#MYSQL_USER" ), get( "#MYSQL_PASS" ), get( "#MYSQL_DB" ) );
		
		if( not connection ) then
		
			outputDebugString( "Ei õnnestunud mysql serveriga ühendada." );
			stopResource( res );
		
		else
		
			outputDebugString( "Mysql serveriga ühendatud." );
			call(getResourceFromName("scoreboard"), "addScoreboardColumn", "User.userid", getRootElement( ), 1);
			
			createObject(3059, 2522.0554199219, -1272.9189453125, 35.640998840332, 0.000000, 0.000000, 0.000000) 
			
			setTimer( checkMySQLConnection, 60000, 0 );   
			setTimer( timeSync, 1000, 0 );
			
			setGameType( "Roleplay" );
			setMapName( "Los Santos" );
			setMapName( "Los Santos" );
			
			AddMotdString( { "Seadeid saad muuta servertabi alt.", "Servertabi saad lahti liigutades hiire ekraani allaossa." } );
			AddMotdString( { "Karakterit saad vahetada servertabi alt.", "Servertabi saad lahti liigutades hiire ekraani allaossa." } );
			AddMotdString( { "Neid sonumeid saad keelata seadete alt.", "Servertabi saad lahti liigutades hiire ekraani allaossa." } );
			
		end	
		
	end
	
end

addEventHandler( "onResourceStart", getResourceRootElement( getThisResource( ) ), displayLoadedRes );

function checkMySQLConnection ( )

	if( not connection or mysql_ping( connection ) == false ) then
	
		outputDebugString( "Lost connection to the MySQL server, reconnecting ..." );
		mysql_close( connection );
		
		connection = mysql_connect( get( "#MYSQL_HOST" ), get( "#MYSQL_USER" ), get( "#MYSQL_PASS" ), get( "#MYSQL_DB" ) );
		
	end
  
end

function AuthPlayer( userName, passWord, rememberMe )

	if( not client ) then return false; end
	
	local eName = mysql_escape_string( connection, userName );
	local eWord = mysql_escape_string( connection, passWord );
	
	local theAuth = Authenticate:new( );
	theAuth.Client = client;
	theAuth.User = eName;
	theAuth.Pass = eWord;	
	theAuth:DoAuth( );

end

addEvent( "OnAuthPlayer", true )
addEventHandler( "OnAuthPlayer", getRootElement( ), AuthPlayer )


function MysqlUpdatebuild( theTable )

	if( not theTable ) then return false end

	return "UPDATE " .. theTable .. " SET ";

end

function MysqlSetField( query, field, val )

	if( not query or not field or not val ) then return false end
	
	return query .. field .. " = '" .. val .. "', ";

end

function UpdateFinish( query, idfield, idval )
	
	if( not query or not idfield or not idval ) then return false end
	return string.sub(query, 1, -3) .. " WHERE " .. idfield .. " = '" .. idval .. "'";

end

function DoSimpleQuery( query, wantId )

	if( not query ) then return false end
	checkMySQLConnection ( );

	local theResult = mysql_query( connection, query );

	if( theResult == nil  ) then
	
		outputDebugString( mysql_error( connection ), 1 );
		outputDebugString( query, 3 );
		return false;
	
	end

	if( wantId == true ) then
	
		local id = mysql_insert_id( connection );
		return id;
	
	end

	--
	return true;

end

function DoUpdateFinish( query, idfield, idval )
	
	local rQuery = UpdateFinish( query, idfield, idval );
	if( rQuery ) then
	
		local theResult = DoSimpleQuery( rQuery );
		if( theResult ) then
		
			return true;
		
		else
		
			outputDebugString( mysql_error( connection ), 1 );
			outputDebugString( rQuery, 3 );
		
		end
	end	
	return false;

end

function SelectQuery( theQuery )

	local result = mysql_query( connection, theQuery );
	local allMyRows = { };
		 
	if( result ) then
		 
		for result ,row in mysql_rows( result ) do
			
			local allMyFields = { };
  			mysql_field_seek( result, 1 );
			
  			for k,v in ipairs( row ) do
  			
    			local field = mysql_fetch_field( result );    			
    			if (v == mysql_null()) then v = ''; end				
      			allMyFields[field["name"]] = v;
    		
	  		end
			table.insert( allMyRows, allMyFields );
		
		end
	else
	
		outputDebugString( mysql_error( connection ), 1 );
		outputDebugString( theQuery, 3 );
	
	end
	return allMyRows;

end

function timeSync( )

	local rTime = getRealTime( );
	
	if( rTime.minute == 0 and not inHourJump ) then
	
		inHourJump = true;
		
		triggerEvent( "onPrePayDay", getRootElement() );
		
	elseif( rTime.minute ~= 0 and inHourJump ) then
	
		inHourJump = false;
		
		payDay();
	
	end

end

function payDay( )

	local players = getElementsByType( "player" );

	for k, v in ipairs( players ) do
	
		local charId = getElementData( v, "Character.id" );
		
		if( charId ~= false ) then
		
			-- TODO: Replace with GUI..
		
			outputChatBox( "Palgapäev", v );
			
			local come = 0;
			local cost = 0;
			
			outputChatBox( "Tulud: ", v );
			
			if( type( income[v] ) == "table" ) then
			
				for k2,v2 in ipairs( income[v] ) do
				
					outputChatBox( "    * " .. v2["desc"] .. " +" .. v2["amount"], v );
					come = come + v2["amount"];
				
				end
				
			end
			
			outputChatBox( "Kulud: ", v );
			
			if( type( tax[v] ) == "table" ) then
			
				for k2,v2 in ipairs( tax[v] ) do
				
					outputChatBox( "    * " .. v2["desc"] .. " +" .. v2["cost"], v );
					cost = cost + v2["cost"];
				
				end
				
			end
			
			outputChatBox( "kokku: " .. come-cost, v );
		
		end
	
	end

end

function PayDayIncome( player, desc, amount )

	if( type( player ) == "number" ) then
	
		player = getPlayerBySqlID( player );
		
	end
	
	if( getElementType( player ) ~= "player" ) then return false; end
	
	if( type( income[player] ) ~= "table" ) then income[player] = { }; end
	
	local tbl = { };
	tbl["desc"] = desc;
	tbl["amount"] = amount;
	table.insert( income[player], tbl );

end

function PayDayTax( player, desc, cost )

	if( type( player ) == "number" ) then
	
		player = getPlayerBySqlID( player );
		
	end
	
	if( getElementType( player ) ~= "player" ) then return false; end
	
	if( type( tax[player] ) ~= "table" ) then tax[player] = { }; end
	
	local tbl = { };
	tbl["desc"] = desc;
	tbl["cost"] = cost;
	table.insert( tax[player], tbl );

end

addEvent( "onScriptInfoRequestS", true );
addEventHandler( "onScriptInfoRequestS", getRootElement( ), 

	function ()
	
		triggerClientEvent( client, "onScriptInfoRequest", client, get( "#VERSION" ), get( "#REVISION" ) );
	
	end
	
);

addEvent( "onSettingsRequest", true );
addEventHandler( "onSettingsRequest", getRootElement( ), 

	function ()
	
		if( client ) then
		
			triggerClientEvent( client, "onSettingsDisplay", client );
		
		end
	
	end
	
);

