connection = nil;
skills = { };
otherIds = { };
pSkillLevel = { };
pXp = { };

function displayLoadedRes( res )	

	if( not connection ) then
	
		connection = mysql_connect( get( "#phoenix_Base.MYSQL_HOST" ), get( "#phoenix_Base.MYSQL_USER" ), get( "#phoenix_Base.MYSQL_PASS" ), get( "#phoenix_Base.MYSQL_DB" ) );
		
		if( not connection ) then
		
			outputDebugString( "Phoenix-Skills: Ei saanud mysql ühendust kätte." );
			stopResource( res );
		
		else
		
			outputDebugString( "Phoenix-Skills: Mysql serveriga ühendatud." );
			RegisterSkills( );
		
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

function RegisterSkills( )

	local xmlFile =  xmlLoadFile ( "skills.xml" );
	if ( xmlFile ~= false ) then
	
		outputDebugString( "phoenix-Skills: Skills database loaded." );
	
		local allSkills = xmlNodeGetChildren( xmlFile );
		
		if( allSkills ~= false ) then
		
			for i, node in ipairs(allSkills) do
		
           		-- node
            	local id = xmlNodeGetAttribute( node, "id" );
            	
            	if( id ~= false ) then
            	
            		
            		skills[id] = { };
            		pSkillLevel[id] = { };
            		pXp[id] = { };
            		
            		SkillSafe( id );
            		
            		skills[id]["nextLevel"] = tonumber( xmlNodeGetAttribute( node, "nextLevel" ) );
            		skills[id]["levelRatio"] = tonumber( xmlNodeGetAttribute( node, "nextLevel" ) );
            		skills[id]["type"] = xmlNodeGetAttribute( node, "type" );
            		skills[id]["name"] = xmlNodeGetAttribute( node, "name" );
            		skills[id]["setFunc"] = xmlNodeGetAttribute( node, "setFunc" );
            		skills[id]["setId"] = tonumber( xmlNodeGetAttribute( node, "setId" ) );
            		skills[id]["setMultiply"] = tonumber( xmlNodeGetAttribute( node, "setMultiply" ) );            		
            		skills[id]["otherIds"] = tonumber( xmlNodeGetAttribute( node, "otherIds" ) );
            		
            		otherIds[tonumber( skills[id]["otherIds"] )] = id;
            		
            		outputDebugString( "Registred Skill: " .. id );
            	
            	end
            
      		end
      		
      	else
      	
      		outputDebugString( "phoenix-Skills: Bad Database syntax.", 1 );
      		      
       	end

		xmlUnloadFile ( xmlFile );
		
	else
	
		outputDebugString( "phoenix-Skills: Skills database failed to load.", 1 );
		
	end

end

function SkillSafe( skillId )

	local query = "SHOW COLUMNS FROM ph_Skills LIKE '" .. skillId .. "'";
	local result = mysql_query( connection, query );
	
	if( result ~= false ) then
	
		if( mysql_num_rows( result ) > 0 ) then
		
			mysql_free_result( result );
			return true;
			
		end -- Field exists, nothing to do.
		
		mysql_free_result( result );
	
	end
	
	-- Add the new registred skill to database so players can use it. :)
	query = "ALTER TABLE `ph_Skills` ADD `" .. skillId .. "` INT NOT NULL DEFAULT '0'";
	result = mysql_query( connection, query );
	
	if( result ~= false ) then	
	
		mysql_free_result( result );
	
	end	
	
end

function LoadSkillsForPlayer( thePlayer )

	checkMySQLConnection( );

	if( not thePlayer or not isElement ( thePlayer )  ) then return false; end
	local charId = getElementData( thePlayer, "Character.id" );
	if( not charId ) then return false; end	
	
	local query = "SELECT * FROM ph_Skills WHERE cid = '" .. charId .. "'";
	local result = mysql_query( connection, query );
	
	if( result ~= false ) then
	
		if( mysql_num_rows( result ) > 0 ) then
			
			mysql_field_seek( result, 1 );
			
  			for k,v in ipairs( mysql_fetch_row( result ) ) do
  				
    			local field = mysql_fetch_field( result );
    			if (v == mysql_null()) then v = ''; end
    			
    			if( skills[field["name"]] ~= nil ) then
    			
    				pSkillLevel[field["name"]][thePlayer] = getLevel( field["name"], tonumber( v ) );
    				pXp[field["name"]][thePlayer] = tonumber ( v );
    				OnLevelUp( thePlayer, field["name"], false );
    			
    			end
    				
	  		end
		
		else
	
			mysql_free_result( result );
			query = "INSERT INTO ph_Skills(cid) VALUES('" .. charId .. "')";
			result = mysql_query( connection, query );
			
			if( result ~= false ) then
			
				mysql_free_result( result );
				setTimer( LoadSkillsForPlayer, 500, 1, thePlayer );
				
			end
		
		end
	
	end
	
	return true;

end

addEvent( "onSkillsRequired", true );
addEventHandler( "onSkillsRequired", getRootElement(), LoadSkillsForPlayer );

function SaveSkillsForPlayer( thePlayer )

	checkMySQLConnection( );

	if( not thePlayer or not isElement ( thePlayer )  ) then return false; end
	local charId = getElementData( thePlayer, "Character.id" );
	if( not charId ) then return false; end	
	
	-- Start query building
	local query = exports.phoenix_Base:MysqlUpdatebuild( "ph_Skills");
	local added = false;	
	
	for k,v in ipairs( skills ) do
	
		query = exports.phoenix_Base:MysqlSetField( query, k, pXp[k][thePlayer] );
  		added = true;
	
	end
	
	if( added ) then
	
		-- Finish query.
		query = exports.phoenix_Base:UpdateFinish( query, "cid", charId);
		
		local result = mysql_query( connection, query );
		if( result ~= false and result ~= nil ) then mysql_free_result( result ); end
	
	end
	
	return true;
end

addEvent( "onSkillsSave", true );
addEventHandler( "onSkillsSave", getRootElement(), SaveSkillsForPlayer );

function OnLevelUp( thePlayer, skillId, showMsg )

	if( not thePlayer or not isElement ( thePlayer )  ) then return false; end
	if( showMsg == nil ) then showMsg = false end
		
	
	if( showMsg == true ) then
	
		triggerClientEvent( thePlayer, "onShowSkillDraw", getRootElement( ), "Sinu " .. skills[skillId]["name"] .. " kerkis. (" .. pSkillLevel[skillId][thePlayer] .. ")" );
	
	end
	
	if(	skills[skillId]["setFunc"] ~= nil ) then
	
		setPedStat( thePlayer, skills[skillId]["setId"], pSkillLevel[skillId][thePlayer] * skills[skillId]["setMultiply"] );
	
	end
	
	return true;

end

function xpAdd( thePlayer, skillId, howMuch )

	if( not thePlayer or not isElement ( thePlayer )  ) then return false; end
	
	local level, neededXP;
	pSkillLevel[skillId][thePlayer], neededXP = getLevel( skillId, pXp[skillId][thePlayer] );
	
	pXp[skillId][thePlayer] = pXp[skillId][thePlayer] + howMuch;
	
	if( pXp[skillId][thePlayer] >= neededXP ) then
	
		pSkillLevel[skillId][thePlayer] = pSkillLevel[skillId][thePlayer] + 1;
		OnLevelUp( thePlayer, skillId, true );
		
	end
	
	return true;

end

function getPlayerLevel( thePlayer, skillId )

	return getLevel( skillId, pXp[skillId][thePlayer] );

end

function getLevel( skillId, numXp )

	local xpNeeded = 0;
	
	if( skills[skillId] == nil ) then
	
		outputDebugString( "phoenix-Skills: getLevel bad skillId.", 2 );
		return 0;
	
	end
	
	if(numXp < skills[skillId]["nextLevel"]) then
	
		return 1, skills[skillId]["nextLevel"];
		
	end
	
	local temp = skills[skillId]["nextLevel"];
	local xpNeeded = temp;
	
	for i = 2, 99, 1 do
	
		temp = temp * skills[skillId]["levelRatio"];
		
		if(numXp < temp * i and numXp > xpNeeded) then
		
			xpNeeded = temp * i;
			return i, xpNeeded;
			
		end
		
	end
	
	return 99, 99; 

end

addEvent( "onSkillWeaponShot", true );
addEventHandler( "onSkillWeaponShot", getRootElement(), 

	function ( weaponId )
	
		if( client and weaponId and otherIds[weaponId] ~= nil ) then
		
			xpAdd( client, otherIds[weaponId], 25 );
		
		end
	
	end

);