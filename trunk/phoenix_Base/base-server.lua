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
			
		end	
		
	end
	
end

addEventHandler( "onResourceStart", getResourceRootElement( getThisResource( ) ), displayLoadedRes );

function checkMySQLConnection ( )

	if( mysql_ping( connection ) == false ) then
	
		outputDebugString( "Lost connection to the MySQL server, reconnecting ..." );
		mysql_close( connection );
		
		connection = mysql_connect( get( "#MYSQL_HOST" ), get( "#MYSQL_USER" ), get( "#MYSQL_PASS" ), get( "#MYSQL_DB" ) );
		
	end
  
end

function AuthPlayer( userName, passWord, rememberMe, preAuth )

	checkMySQLConnection( );

	if( not client ) then return false; end
	
	local eName = mysql_escape_string( connection, userName );
	local eWord = mysql_escape_string( connection, passWord );
	
	local query = "SELECT userid, usergroupid, salt FROM `user` WHERE username = '" .. eName .. "'";
	local result = mysql_query( connection, query );
	
	local ret = 1;
	local other = nil;
	local usrId = 0;
	local usrGroup = 0;
	local salt = "nil";
	
	if( result ) then
	
		if( mysql_num_rows( result ) > 0) then
		
				local row = mysql_fetch_row(result);
				if(row) then
				
					usrId = row[1];
					usrGroup = tonumber( row[2] );
					salt = row[3];
					ret = 0;
				
				end				
		
		end
		mysql_free_result( result );
		
	end
		
	local rPass;		
		
	if( ret == 0) then
	
		if( preAuth == true ) then
		
			rPass = eWord;
		
		else
		
			rPass = string.lower( md5( string.lower( md5( eWord ) ) .. salt ) );
		
		end
		
		if( rememberMe == true ) then
			
			other = rPass;
				
		end
			
		query = "SELECT userid FROM `user` WHERE userid = '" .. usrId .. "' AND '" .. rPass .. "' = password";
		result = mysql_query( connection, query );
		 
		if( result ) then
		 
		 	if( mysql_num_rows( result ) < 1) then
		
				ret = 2;
		
			end
		
		else
			
			ret = 2;
			
		end
	
	end
	
	if(usrId ~= 0 and ret == 0) then
	
		setElementData( client, "User.userid", usrId, true );
	
	end
	
	local adminLevel = 0;

	if( usrGroup == 8 ) then -- vbull banned group
	
		ret = 3; -- return an errorcode.
		
	elseif( usrGroup == 6 ) then -- vbull Admin
	
		adminLevel = 2;
	
	elseif( usrGroup == 12 or usrGroup == 7 ) then -- vbull dev / mode
	
		adminLevel = 1;
	
	end
	
	if( adminLevel > 0 and ret == 0 ) then -- vbull admin group
	
		local account = getAccount( userName );
		local pass = string.sub( rPass, -16 ); -- Turvalisem, passil on vist maks pikkus, -16 peaks aitama:) :/
		
		if( account == false ) then
	
			account = addAccount( userName, pass );
			
			if( account ~= false ) then
			
				if( adminLevel == 2 ) then
			
					aclGroupAddObject( aclGetGroup( "Admin" ), "user." .. userName );
				
				else
			
					aclGroupAddObject( aclGetGroup( "Moderator" ), "user." .. userName );
			
				end
				
			end
			
		end
		
		if( account ~= false ) then
		
			logIn( client, account, pass );
		
		else	
		
			outputChatBox( "Adminiks/Modeks seadmisega oli mingi jama. (" ..  userName .. "->" .. pass .. ")", client );
		
		end
		
		setElementData( client, "User.AdminLevel", usrGroup, true );
		
	end
	
	if( ret == 0 ) then
	
		setElementData( client, "User.GroupId", usrGroup, true );
	
	end
	
	triggerClientEvent( client, "OnPlayerLogin", client, ret, other );

end

addEvent( "OnAuthPlayer", true )
addEventHandler( "OnAuthPlayer", getRootElement( ), AuthPlayer )


function MysqlUpdatebuild( database )

	if( not database ) then return false end

	return "UPDATE " .. database .. " SET ";

end

function MysqlSetField( query, field, val )

	if( not query or not field or not val ) then return false end
	
	return query .. field .. " = '" .. val .. "', ";

end

function UpdateFinish( query, idfield, idval )
	
	if( not query or not idfield or not idval ) then return false end
	return string.sub(query, 1, -3) .. " WHERE " .. idfield .. " = '" .. idval .. "'";

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
