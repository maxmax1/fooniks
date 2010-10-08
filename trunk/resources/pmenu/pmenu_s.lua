PlayerMenu = {

	menuItems = { },
	
	xmlFile = false

};

function PlayerMenu:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	-- Init variables...
	
	self:LoadConfig( );
	
	return o;

end

function PlayerMenu:LoadConfig( )

	self.xmlFile =  xmlLoadFile ( "menu.xml" );
	if ( self.xmlFile ~= false ) then
	
		local allElements = xmlNodeGetChildren( self.xmlFile );
		
		for k, v in ipairs( allElements ) do
		
			local attr = xmlNodeGetAttributes( v );
			
			if( attr["loadstring"] and attr["aType"] and attr["maxdist"] and xmlNodeGetValue( v ) ) then
			
				table.insert( self.menuItems, { ["loadstring"] = attr["loadstring"], ["aType"] = attr["aType"], ["aStr"] = attr["aStr"], ["maxdist"] = tonumber( attr["maxdist"] ), ["label"] = xmlNodeGetValue( v ) } );
			
			end
		
		end
		
		xmlUnloadFile( self.xmlFile );
	
	else
	
		outputDebugString( "PlayerMenu database failed to load.", 1 );
	
	end

end

function PlayerMenu:ParseString( str )

	local results;
	
	local cmdFunc, errorMsg = loadstring( "return " .. str );
	
	if( errorMsg ) then
	
		outputDebugString( errorMsg );
		cmdFunc, errorMsg = loadstring( str );
	
	end
	if( errorMsg ) then
	
		outputDebugString( errorMsg );
		return false;
	
	end

	results = { pcall( cmdFunc ) }
	if not results[1] then

		return false;
	
	end
	
	return results[2];

end

function PlayerMenu:ParseToTable( thePlayer )

	if( not self:isValidPlayer( thePlayer ) ) then return false; end

	local tbl = { };
	for k, v in ipairs( self.menuItems ) do
	
		local fullStr = "return function ( thePlayer ) return " .. v["loadstring"] .. " end";
		local cmdFull, errMsg = loadstring( fullStr );
		if( errMsg ) then
		
		else
		
			local result = cmdFull( );
			if( result ) then
			
				tbl[k] = v["label"];
			
			end
		
		end
	
	end
	
	return tbl;

end

function PlayerMenu:Sync( thePlayer )

	if( not self:isValidPlayer( thePlayer ) ) then return false; end

	local tbl = self:ParseToTable( thePlayer );
	triggerClientEvent( thePlayer, "onClientPlayerMenuSync", thePlayer, tbl );
	return true;

end

function PlayerMenu:isValidPlayer( thePlayer )

	if( not thePlayer or not isElement ( thePlayer )  ) then return false; end
	local charId = getElementData( thePlayer, "Character.id" );
	if( not charId ) then return false; end	
	return charId;

end

function PlayerMenu:Execute( thePlayer, toPlayer, menuItem )

	if( not self:isValidPlayer( thePlayer ) ) then return false; end
	menuItem = tonumber( menuItem );
	if( self.menuItems[menuItem] ) then
	
		local x1, y1, z1 = getElementPosition( thePlayer );
		local x2, y2, z2 = getElementPosition( toPlayer );
		
		if( self.menuItems[menuItem]["maxdist"] and self.menuItems[menuItem]["maxdist"] < getDistanceBetweenPoints3D( x1, y1, z1, x2, y2, z2 ) ) then
		
			exports.phoenix_Chat:OocInfo( thePlayer, "Sa oled liiga kaugel." );
			return false;
		
		end
		
		if( self.menuItems[menuItem]["aType"] == "sevent" or self.menuItems[menuItem]["aType"] == "event" ) then
		
			triggerEvent( self.menuItems[menuItem]["aStr"], getRootElement( ), thePlayer, toPlayer, self.menuItems[menuItem]["maxdist"] ); 
		
		else
		
			outputDebugString( "Bad aType: " .. self.menuItems[menuItem]["aType"] );
		
		end
	
	end

end

function PlayerMenu:doEvents( )

	addEvent( "onPlayerMenuSync", true );
	addEventHandler( "onPlayerMenuSync", getRootElement( ), 
	
		function ( )
		
			if( client ) then
			
				self:Sync( client );
			
			end
		
		end
	
	);

	addEvent( "onPlayerMenuExecute", true );
	addEventHandler( "onPlayerMenuExecute", getRootElement( ), 
	
		function ( oPlayer, selItem )
		
			if( client and oPlayer and selItem ) then
			
				self:Execute( client, oPlayer, selItem );
			
			end
		
		end
	
	);

end

-- onPlayerMenuSync( thePlayer );				- Server side handler for client side syncing requests.
-- onClientPlayerMenuSync( menuTable );			- Client side handler for syncing process.

-- onPlayerMenuExecute( thePlayer, buttonId );	- When client clicks a button(etc) in his menu.

-- onPlayerLogin, onPlayerLogout, onPlayerGroupChange( create this for groups), onCharacterSpawn( may need creating ) -- all need an eventhandler which triggers an update for client..

theMenu = PlayerMenu:new( );
theMenu:doEvents( );
PlayerMenu = {

	menuItems = { },
	
	xmlFile = false

};

function PlayerMenu:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	-- Init variables...
	
	self:LoadConfig( );
	
	return o;

end

function PlayerMenu:LoadConfig( )

	self.xmlFile =  xmlLoadFile ( "menu.xml" );
	if ( self.xmlFile ~= false ) then
	
		local allElements = xmlNodeGetChildren( self.xmlFile );
		
		for k, v in ipairs( allElements ) do
		
			local attr = xmlNodeGetAttributes( v );
			
			if( attr["loadstring"] and attr["aType"] and attr["maxdist"] and xmlNodeGetValue( v ) ) then
			
				table.insert( self.menuItems, { ["loadstring"] = attr["loadstring"], ["aType"] = attr["aType"], ["aStr"] = attr["aStr"], ["maxdist"] = tonumber( attr["maxdist"] ), ["label"] = xmlNodeGetValue( v ) } );
			
			end
		
		end
		
		xmlUnloadFile( self.xmlFile );
	
	else
	
		outputDebugString( "PlayerMenu database failed to load.", 1 );
	
	end

end

function PlayerMenu:ParseString( str )

	local results;
	
	local cmdFunc, errorMsg = loadstring( "return " .. str );
	
	if( errorMsg ) then
	
		outputDebugString( errorMsg );
		cmdFunc, errorMsg = loadstring( str );
	
	end
	if( errorMsg ) then
	
		outputDebugString( errorMsg );
		return false;
	
	end

	results = { pcall( cmdFunc ) }
	if not results[1] then

		return false;
	
	end
	
	return results[2];

end

function PlayerMenu:ParseToTable( thePlayer )

	if( not self:isValidPlayer( thePlayer ) ) then return false; end

	local tbl = { };
	for k, v in ipairs( self.menuItems ) do
	
		local fullStr = "return function ( thePlayer ) return " .. v["loadstring"] .. " end";
		local cmdFull, errMsg = loadstring( fullStr );
		if( errMsg ) then
		
		else
		
			local result = cmdFull( );
			if( result ) then
			
				tbl[k] = v["label"];
			
			end
		
		end
	
	end
	
	return tbl;

end

function PlayerMenu:Sync( thePlayer )

	if( not self:isValidPlayer( thePlayer ) ) then return false; end

	local tbl = self:ParseToTable( thePlayer );
	triggerClientEvent( thePlayer, "onClientPlayerMenuSync", thePlayer, tbl );
	return true;

end

function PlayerMenu:isValidPlayer( thePlayer )

	if( not thePlayer or not isElement ( thePlayer )  ) then return false; end
	local charId = getElementData( thePlayer, "Character.id" );
	if( not charId ) then return false; end	
	return charId;

end

function PlayerMenu:Execute( thePlayer, toPlayer, menuItem )

	if( not self:isValidPlayer( thePlayer ) ) then return false; end
	menuItem = tonumber( menuItem );
	if( self.menuItems[menuItem] ) then
	
		local x1, y1, z1 = getElementPosition( thePlayer );
		local x2, y2, z2 = getElementPosition( toPlayer );
		
		if( self.menuItems[menuItem]["maxdist"] and self.menuItems[menuItem]["maxdist"] < getDistanceBetweenPoints3D( x1, y1, z1, x2, y2, z2 ) ) then
		
			exports.phoenix_Chat:OocInfo( thePlayer, "Sa oled liiga kaugel." );
			return false;
		
		end
		
		if( self.menuItems[menuItem]["aType"] == "sevent" or self.menuItems[menuItem]["aType"] == "event" ) then
		
			triggerEvent( self.menuItems[menuItem]["aStr"], getRootElement( ), thePlayer, toPlayer, self.menuItems[menuItem]["maxdist"] ); 
		
		else
		
			outputDebugString( "Bad aType: " .. self.menuItems[menuItem]["aType"] );
		
		end
	
	end

end

function PlayerMenu:doEvents( )

	addEvent( "onPlayerMenuSync", true );
	addEventHandler( "onPlayerMenuSync", getRootElement( ), 
	
		function ( )
		
			if( client ) then
			
				self:Sync( client );
			
			end
		
		end
	
	);

	addEvent( "onPlayerMenuExecute", true );
	addEventHandler( "onPlayerMenuExecute", getRootElement( ), 
	
		function ( oPlayer, selItem )
		
			if( client and oPlayer and selItem ) then
			
				self:Execute( client, oPlayer, selItem );
			
			end
		
		end
	
	);

end

-- onPlayerMenuSync( thePlayer );				- Server side handler for client side syncing requests.
-- onClientPlayerMenuSync( menuTable );			- Client side handler for syncing process.

-- onPlayerMenuExecute( thePlayer, buttonId );	- When client clicks a button(etc) in his menu.

-- onPlayerLogin, onPlayerLogout, onPlayerGroupChange( create this for groups), onCharacterSpawn( may need creating ) -- all need an eventhandler which triggers an update for client..

theMenu = PlayerMenu:new( );
theMenu:doEvents( );