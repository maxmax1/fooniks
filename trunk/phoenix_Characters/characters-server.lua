connection = nil;
charFields = nil;
characters = { };

function displayLoadedRes( res )	
	
	if( not connection ) then
	
		connection = mysql_connect( get( "#phoenix_Base.MYSQL_HOST" ), get( "#phoenix_Base.MYSQL_USER" ), get( "#phoenix_Base.MYSQL_PASS" ), get( "#phoenix_Base.MYSQL_DB" ) );
		
		if( not connection ) then
		
			outputDebugString( "Phoenix-Characters ei saanud mysql ühendust kätte." );
			stopResource( res );
		
		else
		
			getCharNames( );
			outputDebugString( "Phoenix-Characters: Mysql serveriga ühendatud." );
			setTimer( updatePlayers, 10000, 0 );
			setTimer( savePlayers, 45000, 0 );
		
		end	
		
	end
	
end

addEventHandler( "onResourceStart", getResourceRootElement( getThisResource( ) ), displayLoadedRes );

function getCharNames( triggerFor )

	if( triggerFor == nil ) then triggerFor = getRootElement( ); end

	characters = { };
	
	local query = "SELECT id, name FROM ph_characters";
	local result = mysql_query( connection, query );
	if( result ) then
	
 		while true do
  		
    		local row = mysql_fetch_row( result );
    		if(not row) then break end
		
			local sqlId = tonumber( row[1] );
			if( sqlId ~= nil and sqlId ~= false ) then
				characters[sqlId] = row[2];
			end		
		
		end
	
	end
	
	triggerClientEvent( triggerFor, "onCharNamesSync", triggerFor, characters );

end

addEvent( "onCharSyncRequest", true );
addEventHandler( "onCharSyncRequest", getRootElement( ), 

	function ()
	
		if( client ) then
		
			getCharNames( client );
		
		end
	
	end
	
);

function getCharacterName( sqlId )

	return characters[tonumber(sqlId)];

end

function checkMySQLConnection ( )

	if( mysql_ping( connection ) == false ) then
	
		outputDebugString( "Lost connection to the MySQL server, reconnecting ..." );
		mysql_close( connection );
		
		connection = mysql_connect( get( "#phoenix_Base.MYSQL_HOST" ), get( "#phoenix_Base.MYSQL_USER" ), get( "#phoenix_Base.MYSQL_PASS" ), get( "#phoenix_Base.MYSQL_DB" ) );
		
	end
  
end
	
function charactersRequest( thePlayer )

	if( not client and not thePlayer ) then
	
		outputDebugString( "charRequestFeil" );
		return false; 
	
	end
	if( not client ) then client = thePlayer; end
	
	local sqlId = getElementData( client, "User.userid" );
	if( not sqlId ) then
	
		kickPlayer( client, "VIGA: Sisselogimisel läks midagi sassi, proovi uusti. " );
		return false;
	
	end
	
	if( getElementData( client, "Character.id" ) ) then
	
		savePlayer( client, true );
	
	end
	
	spawnPlayer( client, 255.7190, -41.1370, 1002.0230, -90, 14, math.random(1000, 1250) );
	setElementInterior( client, 14 );
	setElementAlpha( client, 0 );
	fadeCamera( client, true );
	
	setCameraMatrix( client, 256.7190, -42.1370, 1003.0230, 255.7190, -41.1370, 1002.0230 );
	
	local charInf = GetUserCharactersAsTable( sqlId );
	triggerClientEvent( client, "onShowCharacters", client, charInf, 1, false );
	
	return true;

end

addEvent( "onCharactersRequest", true );
addEventHandler( "onCharactersRequest", getRootElement(), charactersRequest );

function GetUserCharactersAsTable( sqlId )

	local query = "SELECT id, name, sex, age, model, blurLevel FROM ph_characters WHERE userid = '" .. sqlId .. "'";
	local result = mysql_query( connection, query );
	
	local tabel = { };
	
	if( result ) then
	
		local i = 1;
		
  		while true do
  		
    		local row = mysql_fetch_row( result );
    		if(not row) then break end
  			
  			tabel[i] = { };
   			tabel[i]["id"] = row[1];
   			tabel[i]["name"] = row[2];
   			tabel[i]["sex"] = row[3];
   			tabel[i]["age"] = row[4];
   			tabel[i]["model"] = row[5];
   			tabel[i]["blurLevel"] = row[6];
   			i = i+1;
	  		
		end
		
	end

	return tabel;

end

function firstSpawnHandler( selectedChar )

	if ( not client ) then return 1; end
	
	local query = "SELECT * FROM ph_characters WHERE id = '" .. selectedChar .. "'";
	local result = mysql_query( connection, query );
	
	local wantInsert = false;
	if( charFields == nil ) then charFields = { }; wantInsert = true; end
		 
	if( result ) then
		 
		for result ,row in mysql_rows( result ) do
			
  			mysql_field_seek( result, 1 );
  			
  			local playerStuff = {};
  			
  			for k,v in ipairs( row ) do
  				
    			local field = mysql_fetch_field( result );
    				
    			if (v == mysql_null()) then v = ''; end
    				
      			playerStuff[field["name"]] = v;
      			setElementData( client, "Character." .. field["name"], v, true );
      			
      			if( wantInsert ) then
      			
      				table.insert( charFields, field["name"] );
      				
      			end
    				
	  		end
	  				
			setElementAlpha( client, 255 );
	  		
	  		if( tonumber( playerStuff["health"] ) < 5 ) then playerStuff["health"] = 15; end
	  		
	  		setElementInterior( client, tonumber( playerStuff["interior"] ) );	
  			setElementDimension( client, tonumber( playerStuff["dimension"] ) );
	  		
	  		setPedSkin( client, playerStuff["model"] );	  
			
	  		setElementPosition( client, playerStuff["posX"], playerStuff["posY"], playerStuff["posZ"] );
	  		setPedRotation( client, playerStuff["angle"] );
	  		setElementHealth( client, tonumber( playerStuff["health"] ) );
	  		setPlayerMoney( client, tonumber( playerStuff["money"] ) );
	  		setCameraTarget( client, client );
	  		setPlayerNametagText( client, playerStuff["name"] );
	  		
	  		triggerEvent( "onSkillsRequired", client, client );
	  		triggerEvent( "onPocketsRequired", client, client );
	  		
		end
		
	end

end

addEvent( "OnRequestFirstSpawn", true );
addEventHandler( "OnRequestFirstSpawn", getRootElement(), firstSpawnHandler );

addEventHandler ( "onPlayerQuit", getRootElement(), 

	function ( qType )
	
		savePlayer( thePlayer, false );
	
	end

);

function updatePlayer( thePlayer ) -- Updates player status for saving...

	if( not thePlayer ) then return false; end
	
	local x, y, z = getElementPosition( thePlayer );
	local rot = getPedRotation( thePlayer );
	local health = getElementHealth( thePlayer );
	local money = getPlayerMoney( thePlayer );
	local model = getElementModel( thePlayer );
	local blur = getPlayerBlurLevel( thePlayer );
	local interior = getElementInterior( thePlayer );
	local dimension = getElementDimension( thePlayer );
	
	setElementData( thePlayer, "Character.posX", x );
	setElementData( thePlayer, "Character.posY", y );
	setElementData( thePlayer, "Character.posZ", z );
	setElementData( thePlayer, "Character.angle", rot );
	setElementData( thePlayer, "Character.health", health );
	setElementData( thePlayer, "Character.money", money );
	setElementData( thePlayer, "Character.model", model );
	setElementData( thePlayer, "Character.blurLevel", blur );	
	
	setElementData( thePlayer, "Character.interior", interior );
	setElementData( thePlayer, "Character.dimension", dimension );	

end

function savePlayers( )

	local players = getElementsByType( "player" );
	
	for k,v in ipairs( players ) do
	
		savePlayer( v, true );
	
	end

end

function updatePlayers( )

	local players = getElementsByType( "player" );
	
	for k,v in ipairs( players ) do
	
		updatePlayer( v );
	
	end

end

function savePlayer( thePlayer, timed )

	checkMySQLConnection( );

	if( not charFields ) then return false; end
	
	if( not thePlayer or not isElement ( thePlayer ) ) then
	
		return false;
		
	end
	local charId = getElementData( thePlayer, "Character.id" );
	if( not charId ) then

		return false;
		
	end
	
	if( timed ) then updatePlayer( thePlayer ); end
	
	-- Start query building
	local query = exports.phoenix_Base:MysqlUpdatebuild( "ph_characters" );
	local added = false;
	
  	for k,v in ipairs( charFields ) do
  		
  		if( v ~= "id" and v ~= "userid" and v ~= "name" ) then
  	
  			local v2 = getElementData( thePlayer, "Character." .. v ); -- Get the current player data.  	
  			if( v2 ~= false ) then
  		
  				query = exports.phoenix_Base:MysqlSetField( query, v, v2 );
  				added = true;
  			
  			end
  			
  		end
  	
  	end
  				
	if( added ) then
	
		-- Finish query.
		query = exports.phoenix_Base:UpdateFinish( query, "id", charId);
		
		local result = mysql_query( connection, query );
		if( result ~= false and result ~= nil ) then mysql_free_result( result ); end
	
	end
	
	triggerEvent( "onSkillsSave", thePlayer, thePlayer ); -- Save Skills too. :)	
	triggerEvent( "onPocketsSave", thePlayer, thePlayer ); -- Save Pockets too. :)	
	return true;

end

addEvent( "onNewCharacterDone", true );
addEventHandler( "onNewCharacterDone", getRootElement( ),

	function ( newData )
	
		newData["story"] = mysql_escape_string( connection, newData["story"] );
	
		local userId = getElementData( client, "User.userid" );
		local query = "INSERT INTO ph_characters(id, userid, name, sex, age, model, ethnicity, backStory) " ..
					  "VALUES(NULL, '" .. userId .. "', '" .. newData["name"] .. "', '" .. newData["sex"] .. "', '" .. newData["age"] .. "', '" .. newData["skin"] .. "', '" .. newData["race"] .. "', '" .. newData["story"] .. "')";
		mysql_query( connection, query );
		outputConsole( query );
		
		if( result ~= false and result ~= nil ) then mysql_free_result( result ); end
		charactersRequest( client );
	
	end

);