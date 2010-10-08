charFields = { };
characters = { };

local allFields = { };

addEvent( "onCharacterSave", true );

function displayLoadedRes( res )	

	loadCharfields( );
	getCharNames( );
	outputDebugString( "Phoenix-Characters: Mysql serveriga ühendatud." );
	setTimer( updatePlayers, 10000, 0 );
	setTimer( savePlayers, 45000, 0 );
	
end

addEventHandler( "onResourceStart", getResourceRootElement( getResourceFromName( "phoenix_Base" ) ), displayLoadedRes );
addEventHandler( "onResourceStart", getResourceRootElement( getThisResource() ), function () if( getResourceState( getResourceFromName( "phoenix_Base" ) ) == "running" ) then displayLoadedRes( ); end end );

function loadCharfields( )

	local xmlFile =  xmlLoadFile ( "charfields.xml" );
	if ( xmlFile ~= false ) then
	
		local children = xmlNodeGetChildren( xmlFile );
		if( children ) then
		
			for k, v in ipairs( children ) do
			
				charFields[xmlNodeGetName( v )] = xmlNodeGetValue( v );
			
			end
		
		end
		xmlUnloadFile( xmlFile );
	
	end

end

function SaveCharfields( )

	local xmlFile =  xmlLoadFile ( "charfields.xml" );
	if ( xmlFile ~= false ) then
	
		xmlDestroyNode( xmlFile );
		xmlFile = xmlCreateFile( "charfields.xml", "fields" );
		
		for k, v in pairs( charFields ) do
		
			local node = xmlCreateChild( xmlFile, k );
			xmlNodeSetValue( node, v );
		
		end
		
		xmlSaveFile( xmlFile );
		xmlUnloadFile( xmlFile );
	
	end
end

function getCharNames( triggerFor )

	if( triggerFor == nil ) then triggerFor = getRootElement( ); end

	characters = { };
	
	local query = "SELECT id, name FROM ph_characters";
	local result = exports.phoenix_Base:SelectQuery( query );
	if( result ) then
	
 		for k, v in ipairs( result ) do
  		
			local sqlId = tonumber( v["id"] );
			if( sqlId ~= nil and sqlId ~= false ) then
				characters[sqlId] = v["name"];
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

function charactersRequest( thePlayer )

	if( not client and not thePlayer ) then
	
		outputDebugString( "charRequestFeil" );
		return false; 
	
	end
	if( not client ) then client = thePlayer; end
	
	local sqlId = getElementData( client, "User.userid" );
	if( not sqlId ) then
	
		kickPlayer( client, "VIGA: Sisselogimisel läks midagi sassi, proovi uuesti. " );
		return false;
	
	end
	
	if( getElementData( client, "Character.id" ) ) then
	
		savePlayer( client, true );
	
	end
	
	spawnPlayer( client, 255.7190, -41.1370, 1002.0230, -90, 14, math.random(1000, 1250) );
	setElementInterior( client, 14 );
	setElementAlpha( client, 0 );
	fadeCamera( client, true );
	
	setElementData( client, "isInCharSelection", "1" );
	
	--setCameraMatrix( client, 256.7190, -42.1370, 1003.2230, 255.7190, -41.1370, 1002.0230 );
	triggerClientEvent( client, "rotateAroundPlayer", client, true, client, 1, 2 );
	
	local charInf = GetUserCharactersAsTable( sqlId );
	triggerClientEvent( client, "onShowCharacters", client, charInf, 1, false );
	
	return true;

end

addEvent( "onCharactersRequest", true );
addEventHandler( "onCharactersRequest", getRootElement(), charactersRequest );

function GetUserCharactersAsTable( sqlId )

	local query = "SELECT id, name, sex, age, model FROM ph_characters WHERE userid = '" .. sqlId .. "'";
	local result = exports.phoenix_Base:SelectQuery( query );
	
	local tabel = { };
	
	if( result ) then
	
		local i = 1;
		
  		for k, v in ipairs( result ) do
  					
  			tabel[i] = { };
   			tabel[i]["id"] = v["id"];
   			tabel[i]["name"] = v["name"];
   			tabel[i]["sex"] = v["sex"];
   			tabel[i]["age"] = v["age"];
   			tabel[i]["model"] = v["model"];
   			i = i+1;
	  		
		end
		
	end

	return tabel;

end

function firstSpawnHandler( selectedChar )

	if ( not client ) then return 1; end
	
	local query = "SELECT * FROM ph_characters WHERE id = '" .. selectedChar .. "'";
	local result = exports.phoenix_Base:SelectQuery( query );
	
	local someChange = false;
	
	if( result ) then
		 
		for k, v in ipairs( result ) do
			
  			
  			for k2, v2 in ipairs( v ) do
  				
      			setElementData( client, "Character." .. k2, v2, true );
      			
      			if( not charFields[k2] ) then
      			
					charFields[k2] = "1"; -- Do not sync unless explitly set!
					someChange = true;
      				
      			end
    				
	  		end
	  				
			setElementAlpha( client, 255 );
	  		
	  		if( tonumber( v["health"] ) < 5 ) then v["health"] = 15; end
	  		
	  		setElementInterior( client, tonumber( v["interior"] ) );	
  			setElementDimension( client, tonumber( v["dimension"] ) );
	  		
	  		setPedSkin( client, v["model"] );	  
			
	  		setElementPosition( client, v["posX"], v["posY"], v["posZ"] );
	  		setPedRotation( client, v["angle"] );
	  		setElementHealth( client, tonumber( v["health"] ) );
	  		setPlayerMoney( client, tonumber( v["money"] ) );
			triggerClientEvent( client, "rotateAroundPlayer", client );
	  		setCameraTarget( client, client );
	  		setPlayerNametagText( client, v["name"] );
			
			removeElementData( client, "isInCharSelection" );
	  		
	  		triggerEvent( "onSkillsRequired", client, client );
			exports.phoenix_Skills:LoadSkillsForPlayer( client );			
			exports.phoenix_Skills:LoadAchForPlayer( client );			
			
	  		triggerEvent( "onPocketsRequired", client, client );
			
			triggerClientEvent( client, "onNewCharField", client, allFields );
			
			triggerEvent( "onCharacterSpawn", client, client, v );
	  		
		end
		
	end
	
	if( someChange ) then
	
		SaveCharfields( );
	
	end

end

addEvent( "OnRequestFirstSpawn", true );
addEvent( "onCharacterSpawn", true );
addEventHandler( "OnRequestFirstSpawn", getRootElement(), firstSpawnHandler );

addEventHandler ( "onPlayerQuit", getRootElement(), 

	function ( qType )
	
		savePlayer( thePlayer, false );
	
	end

);

function updatePlayer( thePlayer ) -- Updates player status for saving...

	if( not thePlayer ) then return false; end
	
	local isInCharSel = getElementData( thePlayer, "isInCharSelection" );
	if( isInCharSel ) then
	
		return false;
	
	end
	
	local x, y, z = getElementPosition( thePlayer );
	local rot = getPedRotation( thePlayer );
	local health = getElementHealth( thePlayer );
	local money = getPlayerMoney( thePlayer );
	local model = getElementModel( thePlayer );
	local interior = getElementInterior( thePlayer );
	local dimension = getElementDimension( thePlayer );
	
	setElementData( thePlayer, "Character.posX", x );
	setElementData( thePlayer, "Character.posY", y );
	setElementData( thePlayer, "Character.posZ", z );
	setElementData( thePlayer, "Character.angle", rot );
	setElementData( thePlayer, "Character.health", health );
	setElementData( thePlayer, "Character.money", money );
	setElementData( thePlayer, "Character.model", model );
	
	setElementData( thePlayer, "Character.interior", interior );
	setElementData( thePlayer, "Character.dimension", dimension );	

end

function PlayerDataToTable( thePlayer )

	local charId = getElementData( thePlayer, "Character.id" );
	if( not charId ) then
	
		return false;
	
	end

	local tbl = { };
	for k, v in pairs( charFields ) do
  	
		local v2 = getElementData( thePlayer, "Character." .. k );
		if( v2 ~= false ) then
		
			tbl[k] = v2;
		
		end
  	
  	end
	
	return tbl;

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

	outputDebugString( "Saving Player" );
	
	if( not charFields ) then return false; end	
	if( not thePlayer or not isElement ( thePlayer ) ) then
	
		return false;
		
	end
	local charId = getElementData( thePlayer, "Character.id" );
	if( not charId ) then

		return false;
		
	end
	
	if( timed ) then updatePlayer( thePlayer ); end
	
	--outputDebugString( "Saving Player" );
	
	-- Start query building
	local query = exports.phoenix_Base:MysqlUpdatebuild( "ph_characters" );
	local added = false;
	
  	for k, v in pairs( charFields ) do
  		
  		if( k ~= "id" and k ~= "userid" and k ~= "name" ) then
  	
  			local v2 = getElementData( thePlayer, "Character." .. k ); -- Get the current player data.  	
  			if( v2 ~= false ) then
  		
  				query = exports.phoenix_Base:MysqlSetField( query, k, v2 );
  				added = true;
  			
  			end
  			
  		end
  	
  	end
  				
	if( added ) then
	
		-- Finish query.
		local result = exports.phoenix_Base:DoUpdateFinish( query, "id", charId);
		if( not result ) then
		
			outputDebugString( "Updated Player: (" .. tostring( result ) .. ")" );
			outputDebugString( tostring( query ) );
		
		end
	
	end
	
	outputDebugString( "Saved Player" );	
	triggerEvent( "onCharacterSave", thePlayer, thePlayer ); -- Let other scripts know it's time to save.
	return true;

end

addEvent( "onNewCharacterDone", true );
addEventHandler( "onNewCharacterDone", getRootElement( ),

	function ( newData )
	
		newData["story"] = mysql_escape_string( connection, newData["story"] );
	
		local userId = getElementData( client, "User.userid" );
		local query = "INSERT INTO ph_characters(id, userid, name, sex, age, model, ethnicity, backStory) " ..
					  "VALUES(NULL, '" .. userId .. "', '" .. newData["name"] .. "', '" .. newData["sex"] .. "', '" .. newData["age"] .. "', '" .. newData["skin"] .. "', '" .. newData["race"] .. "', '" .. newData["story"] .. "')";
		exports.phoenix_Base:SimpleQuery(query);
		outputConsole( query );
		
		charactersRequest( client );
	
	end

);

addEvent( "onPlayerInfo", true );
addEventHandler( "onPlayerInfo", getRootElement( ),

	function ( )
	
		if( client ) then
		
			triggerClientEvent( client, "onShowPlayerInfo", client );
		
		end
	
	end

);

function AddCharField( p, t )

	local tbl = { };
	tbl["prettyName"] = p;
	tbl["valueName"] = t;
	table.insert( allFields, tbl );
	
	-- Sync
	triggerClientEvent( getRootElement(), "onNewCharField", getRootElement(), allFields );

end

AddCharField("Nimi", "Character.name");
AddCharField("Sugu", "Character.sex");
AddCharField("Vanus", "Character.age");
AddCharField("Rass", "Character.ethnicity");