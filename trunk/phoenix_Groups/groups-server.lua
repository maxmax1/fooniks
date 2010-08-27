local connection = nil;

local groups = { };

function displayLoadedRes( res )	
	
	if( not connection ) then
	
		connection = mysql_connect( get( "#phoenix_Base.MYSQL_HOST" ), get( "#phoenix_Base.MYSQL_USER" ), get( "#phoenix_Base.MYSQL_PASS" ), get( "#phoenix_Base.MYSQL_DB" ) );
		
		if( not connection ) then
		
			outputDebugString( "phoenix_Groups: Ei saanud mysql ühendust kätte." );
			stopResource( res );
		
		else
		
			outputDebugString( "phoenix_Groups: Mysql serveriga ühendatud." );
			LoadGroups( );
			setTimer( SaveGroups, 110000, 0 );
			
			local players = getElementsByType( "player" );
			for k, v in ipairs( players ) do
			
				local data = exports.Phoenix_Characters:PlayerDataToTable( v );
				if( data ) then
				
					setTimer( InitPlayerGroups, 1000, 1, v, data );
				
				end
			
			end
		
		end	
		
	end
	
end

addEventHandler( "onResourceStart", getResourceRootElement( getThisResource( ) ), displayLoadedRes );

addEventHandler ( "onResourceStop", getResourceRootElement( getThisResource( ) ), 
    function ( resource )
	
		SaveGroups( );
	
	end
	
);

function LoadGroups( )

	local query = "SELECT * FROM ph_groups";
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
			
			local lRank, ranks = LoadGroupRanks( stuff["id"] );
			local members, num = LoadGroupMembers( stuff["id"] );
			addGroup( stuff["name"], stuff["gCash"], stuff["type"], stuff["red"], stuff["green"], stuff["blue"], ranks, lRank, members, num, stuff["id"] );
		
		end
	
	end

end

function LoadGroupRanks( gid )

	local tbl = { };
	local num = 0;
	local query = "SELECT * FROM ph_groupRanks WHERE groupId = '" .. gid .. "'";
	local result = mysql_query( connection, query );
	
	if( result ) then
	
		while true do
		
			local row = mysql_fetch_row( result );
    		if(not row) then break end
			
			local id = tonumber( row[3] );
			
			num = num + 1;
			tbl[id] = { };
			tbl[id]["sqlid"] = tonumber( row[1] );
			tbl[id]["groupId"] = gid;
			tbl[id]["label"] = row[4];		
			tbl[id]["isLeader"] = row[5];
		
		end
	
	end
	
	return num, tbl;

end

function LoadGroupMembers( gid )

	local tbl = { };
	local num = 0;
	local query = "SELECT id, name, groupRank FROM ph_characters WHERE groupId = '" .. gid .. "'";
	local result = mysql_query( connection, query );
	
	if( result ) then
	
		while true do
		
			local row = mysql_fetch_row( result );
    		if(not row) then break end
			
			local id = tonumber( row[1] );
			
			tbl[id] = { };
			tbl[id]["groupId"] = gid;
			tbl[id]["name"] = row[2];
			tbl[id]["rank"] = row[3];
			tbl[id]["online"] = 0;
			tbl[id]["element"] = nil;
			num = num + 1;
		
		end
	
	end
	
	return tbl, num;

end

function SaveGroups( )

	for k, v in pairs( groups ) do
	
		local query = exports.phoenix_Base:MysqlUpdatebuild( "ph_groups");
		
		query = exports.phoenix_Base:MysqlSetField( query, "name", v["name"] );
		
		-- Finish query.
		query = exports.phoenix_Base:UpdateFinish( query, "id", k );
		local result = mysql_query( connection, query );
		if( result ) then mysql_free_result( result ); end		
		
		SaveRanks( k );
	
	end

end

function SaveRanks( gid )

	for k, v in pairs( groups[gid]["ranks"] ) do
	
		local query = exports.phoenix_Base:MysqlUpdatebuild( "ph_groupRanks");
		
		query = exports.phoenix_Base:MysqlSetField( query, "label", v["label"] );
		query = exports.phoenix_Base:MysqlSetField( query, "isLeader", v["isLeader"] );
		
		-- Finish query.
		query = exports.phoenix_Base:UpdateFinish( query, "id", v["sqlid"] );
		local result = mysql_query( connection, query );
		if( result ) then mysql_free_result( result ); end	
	
	end
end


function addGroup( name, gCash, gType, red, green, blue, ranks, lRank, members, num, sqlid )

	if( not sqlid ) then
	
		local query = "INSERT INTO `ph_groups` (`id`, `type`, `name`, `cRed`, `cGreen`, `cBlue`) VALUES (NULL, '" .. gType .. "', '" .. name .. "', '" .. red .. "', '" .. green .. "', '" .. blue .. "');";
		mysql_query(query);
		sqlid = mysql_insert_id();
		if( not sqlid ) then return false; end
		
		query = "INSERT INTO ph_groupRanks(id, groupId, rank, label, isLeader) " ..
				"VALUES(NULL, '" .. sqlid .. "', '1', 'Liige', '0')";
		mysql_query( connection, query );
		ranks[1] = { };
		ranks[1]["sqlid"] = mysql_insert_id( connection );
		ranks[1]["groupId"] = sqlid;
		ranks[1]["label"] = "Liige";
		ranks[1]["isLeader"] = "0";
		
		query = "INSERT INTO ph_groupRanks(id, groupId, rank, label, isLeader) " ..
				"VALUES(NULL, '" .. sqlid .. "', '6', 'Liider', '1')";
		mysql_query( connection, query );
		ranks[6] = { };
		ranks[6]["sqlid"] = mysql_insert_id( connection );
		ranks[6]["groupId"] = sqlid;
		ranks[6]["label"] = "Liider";
		ranks[6]["isLeader"] = "1";
		lRank = 2;
	
	end
	
	sqlid = tonumber( sqlid );
	
	groups[sqlid] = { };
	groups[sqlid]["name"] = name;
	groups[sqlid]["sqlid"] = sqlid;
	groups[sqlid]["gCash"] = gCash;
	groups[sqlid]["ranks"] = ranks;
	groups[sqlid]["lRank"] = lRank;
	groups[sqlid]["members"] = members;
	groups[sqlid]["numMemb"] = num;
	groups[sqlid]["dataRev"] = 1;
	
	outputDebugString( "Added group ID: " .. sqlid );
	
	groups[sqlid]["team"] = createTeam( name, red, green, blue );
	setTeamFriendlyFire( groups[sqlid]["team"] , true );
	setElementData( groups[sqlid]["team"], "sqlid", sqlid );
	setElementData( groups[sqlid]["team"], "type", gType );
	setElementData( groups[sqlid]["team"], "dataRev", "1" );

end

function onGroupEdit( sqlid )

	if( groups[sqlid] ) then
	
		groups[sqlid]["dataRev"] = groups[sqlid]["dataRev"] + 1;
		setElementData( groups[sqlid]["team"], "dataRev", tostring( groups[sqlid]["dataRev"] ) );
	
	end
end

function InitPlayerGroups( thePlayer, playerData )

	local myid = tonumber( playerData["id"] );
	local sqlid = tonumber( playerData["groupId"] );
	local rank = tonumber( playerData["groupRank"] );

	if( sqlid and sqlid > 0 and groups[sqlid] ) then
	
		groups[sqlid]["members"][myid]["online"] = 1;
		groups[sqlid]["members"][myid]["element"] = thePlayer;
		
		setPlayerTeam( thePlayer, groups[sqlid]["team"] );
		
		if( not groups[sqlid]["ranks"][rank] ) then
		
			-- Set to first if there isnt one.
		
		elseif( groups[sqlid]["ranks"][rank]["isLeader"] == "1" ) then
		
			outputChatBox( "Oled grupeeringu liider.", thePlayer );
		
		end
	
	end

end
addEventHandler( "onCharacterSpawn", getRootElement( ), InitPlayerGroups );

addEvent( "onGroupDataInit", true );
addEventHandler( "onGroupDataInit", getRootElement( ),

	function ( )
	
		if( client ) then
		
			local team = getPlayerTeam( client );
			local sqlid = getElementData( team, "sqlid" );
			local rank = tonumber( getElementData( client, "Character.groupRank" ) );
			if( not groups[sqlid]["ranks"][rank] or groups[sqlid]["ranks"][rank]["isLeader"] ~= "1" ) then
			
				exports.Phoenix_Chat:OocInfo( client, "Sa pole liider." );
				return false;
			
			end
			
			triggerClientEvent( client, "onGroupDataLoaded", client, groups[sqlid] );
			
		end
	
	end
);

addEvent( "onGroupPlayerKick", true );
addEventHandler( "onGroupPlayerKick", getRootElement( ),

	function ( memberSql )
	
		if( client ) then
		
			local team = getPlayerTeam( client );
			local sqlid = getElementData( team, "sqlid" );
			internal = tonumber( memberSql );
			local noKick = true;
			
			if( groups[sqlid]["members"][memberSql] and groups[sqlid]["members"][memberSql]["online"] == 1 ) then
			
				local member = groups[sqlid]["members"][memberSql]["element"];
				if( member ) then
				
					setPlayerTeam( member, nil );				
					local str = "Sind visati grupeeringust välja %s poolt.";
					string.format( str, getPlayerName( client ) );
					outputChatBox( str, member );
					noKick = false;
				
				end			
			end
			
			if( noKick ) then
			
				local query = "UPDATE ph_Characters SET groupId = '0', groupRank = '0' WHERE id = '" .. memberSql .. "'";
				mysql_query( connection, query );
			
			end
			
			local memberName = groups[sqlid]["members"][memberSql]["name"];
			
			local str = "Viskasid %s oma grupeeringust välja.";
			string.format( str, memberName );
			outputChatBox( str, client );		
			
			groups[sqlid]["members"][memberSql] = nil;
			groups[sqlid]["numMemb"] = groups[sqlid]["numMemb"] - 1;
			onGroupEdit( sqlid );
		
		end
	
	end

);

addEvent( "onGroupMemberEdit", true );
addEventHandler( "onGroupMemberEdit", getRootElement( ),

	function ( memberSql, newRank )
	
		if( client ) then
		
			local team = getPlayerTeam( client );
			local sqlid = getElementData( team, "sqlid" );
			local rank = tonumber( getElementData( client, "Character.groupRank" ) );
			if( not groups[sqlid]["ranks"][rank] or groups[sqlid]["ranks"][rank]["isLeader"] ~= "1" ) then
			
				exports.Phoenix_Chat:OocInfo( client, "Sa pole liider." );
				return false;
			
			end
			
			memberSql = tonumber( memberSql );
			local noKick = true;
			
			if( groups[sqlid]["members"][memberSql] and groups[sqlid]["members"][memberSql]["online"] == 1 ) then
			
				local member = groups[sqlid]["members"][memberSql]["element"];
				if( member ) then
				
					setElementData( member, "Character.groupRank", tostring( newRank ) );
					local str = string.format( "%s muutis sinu auastet oma grupeeringus.", getPlayerName( client ) );
					outputChatBox( str, member );
					noKick = false;
				
				end			
			end
			
			if( noKick ) then
			
				local query = "UPDATE ph_Characters SET groupRank = '" .. newRank .. "' WHERE id = '" .. memberSql .. "'";
				mysql_query( connection, query );
			
			end
			
			local memberName = groups[sqlid]["members"][memberSql]["name"];
			
			local str = string.format( "Muutsid %s auastet oma grupeeringus.", memberName );
			outputChatBox( str, client );
			onGroupEdit( sqlid );
		
		end
	
	end
);

addEvent( "onGroupDataSave", true );
addEventHandler( "onGroupDataSave", getRootElement( ), 

	function ( team, revision, data )
	
		if( client and team and revision and data ) then
		
			local sqlid = tonumber( getElementData( team, "sqlid" ) );
			if( sqlid ) then
			
				if( revision ~= groups[sqlid]["dataRev"] ) then
				
					outputChatBox( "Nosave, dataRev is old!", client );
					-- TODO: Merge changes...
					return false;
				
				end
			
				for k, v in pairs( data ) do
				
					if( k == "ranks" ) then
					
						for k2, v2 in pairs( v ) do
						
							if( v2["status"] and v2["status"] == "deleted" ) then
							
								local query = "DELETE FROM  ph_groupRanks WHERE id = '" .. groups[sqlid]["ranks"][k2]["sqlid"] .. "'";
								mysql_query( connection, query );
								groups[sqlid]["ranks"][k2] = nil;
							
							elseif( not groups[sqlid]["ranks"][k2] ) then -- a new value :)
							
								groups[sqlid]["ranks"][k2] = { };
								groups[sqlid]["ranks"][k2] = v2;
								local query = "INSERT INTO ph_groupRanks(id, groupId, rank, label, isLeader) " ..
											  "VALUES(NULL, '" .. sqlid .. "', '" .. k2 .. "', '" .. v2["label"] .. "', '0')";
								mysql_query( connection, query );
								groups[sqlid]["ranks"][k2]["sqlid"] = mysql_insert_id( connection );	
							
							else
							
								groups[sqlid]["ranks"][k2] = v2;
							
							end
						
						end
					
					elseif( k == "members" ) then
					
					else
					
						groups[sqlid][k] = v;
					
					end
				
				end
				
				onGroupEdit( sqlid ); -- Increment revision...
			
			end
		
		end
	
	end

);

-- Groups exports


function GetPlayerGroupId( thePlayer )

	local team = getPlayerTeam( thePlayer );
	if( team ) then
	
		local teamId = getElementData( team, "sqlid" );
		if( teamId ) then
		
			return tonumber( teamId );
		
		end
	
	end
	
	return 0;

end

function GetGroupTeam( groupId )

	groupId = tonumber( groupId );
	if( groups[groupId] ) then
	
		return groups[groupId]["team"];
	
	end
	
	return false

end