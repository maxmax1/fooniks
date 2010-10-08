local groups = { };

function displayLoadedRes( res )	

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

addEventHandler( "onResourceStart", getResourceRootElement( getResourceFromName( "phoenix_Base" ) ), displayLoadedRes );
addEventHandler( "onResourceStart", getResourceRootElement( getThisResource() ), function () if( getResourceState( getResourceFromName( "phoenix_Base" ) ) == "running" ) then displayLoadedRes( ); end end );

addEventHandler ( "onResourceStop", getResourceRootElement( getThisResource( ) ), 
    function ( resource )
	
		SaveGroups( );
	
	end
	
);

function LoadGroups( )

	local result = exports.phoenix_Base:SelectQuery( "SELECT * FROM ph_groups" );

	if( result ) then
	
		for k, v in ipairs( result ) do
			
			local lRank, ranks = LoadGroupRanks( v["id"] );
			local members, num = LoadGroupMembers( v["id"] );
			addGroup( v["name"], v["gCash"], v["type"], v["cRed"], v["cGreen"], v["cBlue"], ranks, lRank, members, num, v["safename"], v["id"] );
		
		end
	
	end

end

function LoadGroupRanks( gid )

	local tbl = { };
	local num = 0;
	local result = exports.phoenix_Base:SelectQuery( "SELECT * FROM ph_groupRanks WHERE groupId = '" .. gid .. "'" );
	
	if( result ) then
	
		for k, v in ipairs( result ) do
				
			local id = tonumber( row["rank"] );
			
			num = num + 1;
			tbl[id] = { };
			tbl[id]["sqlid"] = tonumber( row["id"] );
			tbl[id]["groupId"] = gid;
			tbl[id]["label"] = row["label"];		
			tbl[id]["isLeader"] = row["isLeader"];
		
		end
	
	end
	
	return num, tbl;

end

function LoadGroupMembers( gid )

	local tbl = { };
	local num = 0;
	local result = exports.phoenix_Base:SelectQuery( "SELECT id, name, groupRank FROM ph_characters WHERE groupId = '" .. gid .. "'" );
	
	if( result ) then
	
		for k, v in ipairs( result ) do
					
			local id = tonumber( row["id"] );
			
			tbl[id] = { };
			tbl[id]["groupId"] = gid;
			tbl[id]["name"] = row["name"];
			tbl[id]["rank"] = row["groupRank"];
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
		query = exports.phoenix_Base:DoUpdateFinish( query, "id", k );
		
		SaveRanks( k );
	
	end

end

function SaveRanks( gid )

	for k, v in pairs( groups[gid]["ranks"] ) do
	
		local query = exports.phoenix_Base:MysqlUpdatebuild( "ph_groupRanks");
		
		query = exports.phoenix_Base:MysqlSetField( query, "label", v["label"] );
		query = exports.phoenix_Base:MysqlSetField( query, "isLeader", v["isLeader"] );
		
		-- Finish query.
		query = exports.phoenix_Base:DoUpdateFinish( query, "id", v["sqlid"] );
	
	end
end


function addGroup( name, gCash, gType, red, green, blue, ranks, lRank, members, num, safename, sqlid )

	if( not sqlid ) then
	
		local query = "INSERT INTO `ph_groups` (`id`, `safename`, `type`, `name`, `cRed`, `cGreen`, `cBlue`) VALUES (NULL, '" .. safename .. "', '" .. gType .. "', '" .. name .. "', '" .. red .. "', '" .. green .. "', '" .. blue .. "');";
		sqlid = exports.phoenix_Base:DoSimpleQuery( query, true );
		if( not sqlid ) then return false; end
		
		query = "INSERT INTO ph_groupRanks(id, groupId, rank, label, isLeader) " ..
				"VALUES(NULL, '" .. sqlid .. "', '1', 'Liige', '0')";
		ranks[1] = { };
		ranks[1]["sqlid"] = exports.phoenix_Base:DoSimpleQuery( query, true );
		ranks[1]["groupId"] = sqlid;
		ranks[1]["label"] = "Liige";
		ranks[1]["isLeader"] = "0";
		
		query = "INSERT INTO ph_groupRanks(id, groupId, rank, label, isLeader) " ..
				"VALUES(NULL, '" .. sqlid .. "', '6', 'Liider', '1')";
		ranks[6] = { };
		ranks[6]["sqlid"] = exports.phoenix_Base:DoSimpleQuery( query, true );
		ranks[6]["groupId"] = sqlid;
		ranks[6]["label"] = "Liider";
		ranks[6]["isLeader"] = "1";
		lRank = 2;
	
	end
	
	sqlid = tonumber( sqlid );
	
	groups[sqlid] = { };
	groups[sqlid]["name"] = name;
	groups[sqlid]["safename"] = safename;
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
				exports.phoenix_Base:DoSimpleQuery( query );
			
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
				exports.phoenix_Base:DoSimpleQuery( query );
			
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
								exports.phoenix_Base:DoSimpleQuery( query );
								groups[sqlid]["ranks"][k2] = nil;
							
							elseif( not groups[sqlid]["ranks"][k2] ) then -- a new value :)
							
								groups[sqlid]["ranks"][k2] = { };
								groups[sqlid]["ranks"][k2] = v2;
								local query = "INSERT INTO ph_groupRanks(id, groupId, rank, label, isLeader) " ..
											  "VALUES(NULL, '" .. sqlid .. "', '" .. k2 .. "', '" .. v2["label"] .. "', '0')";
								groups[sqlid]["ranks"][k2]["sqlid"] = exports.phoenix_Base:DoSimpleQuery( query, true );
							
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

	if( not thePlayer or not isElement ( thePlayer )  ) then return false; end
	local charId = getElementData( thePlayer, "Character.id" );
	if( not charId ) then return false; end	
	
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