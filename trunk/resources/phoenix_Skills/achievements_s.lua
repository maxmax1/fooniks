--[[

	Achievements
	
		Stored in an xml file in the following format:
		
			root
			
				achievementelem ( uniqueid(5 chars), name, coins, xp, image )
		
		For each character stored in db:
		
		charid, all
		
			all => uniq10uniq21
			
			So each elem takes 6 chars.
			
			1200 chars => 200 achievements
		
		Methods ToStore and FromStore provide conversion between database format and usable format.
		
	Class Info
	
		LoadConfig( );
		
		doEvents( );
		
		LoadPlayer( thePlayer );
		SavePlayer( thePlayer );
		
		ToStore( achTable );
		FromStore( str );
		
		SetAchievementComplete( thePlayer, uniqueid );
		
		exported macro doneAchivement
		
	Events
	
		onAchievementCompleted
		
		hook to this to display unlocked achivement message
		
]]--

DATATABLE_NAME = "ph_achievements";
DATAFIELD_SIZE = 1200;

LEN_UNIQUE_ID = 5;

MAX_ACHIEVEMENTS = math.floor( DATAFIELD_SIZE / ( LEN_UNIQUE_ID + 1 ) );

Achievements = {

	xmlFile = nil,
	
	allAchievements = { },
	
	playerTable = { }

};

function Achievements:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	return o;

end

function Achievements:LoadConfig( )

	self.xmlFile =  xmlLoadFile ( "achievements.xml" );
	if ( self.xmlFile ~= false ) then
	
		local allElements = xmlNodeGetChildren( self.xmlFile );
		
		for k, v in ipairs( allElements ) do
		
			local uid = xmlNodeGetAttribute( v, "uniqueid" );
			local name = xmlNodeGetAttribute( v, "name" );
			local desc = xmlNodeGetAttribute( v, "desc" );
			local img = xmlNodeGetAttribute( v, "img" );
			local coins = tonumber( xmlNodeGetAttribute( v, "coins" ) ) or 0;
			local xp = tonumber( xmlNodeGetAttribute( v, "xp" ) ) or 0;
			
			if( uid and name and desc and img and coins and xp ) then
			
				while( string.len( uid ) < LEN_UNIQUE_ID ) do
				
					uid = uid .. "0";
				
				end
				if( string.len( uid ) > LEN_UNIQUE_ID ) then
				
					uid = string.sub( uid, 1, LEN_UNIQUE_ID + 1 );
				
				end
				
				self.allAchievements[uid] = { };
				self.allAchievements[uid]["name"] = name;
				self.allAchievements[uid]["desc"] = desc;
				self.allAchievements[uid]["img"] = img;
				self.allAchievements[uid]["coins"] = coins;
				self.allAchievements[uid]["xp"] = xp;
			
			end
		
		end
		
		xmlUnloadFile ( self.xmlFile );
	
	else
	
		outputDebugString( "Achievements database failed to load.", 1 );
	
	end

end

function Achievements:doEvents( )

	addEvent( "onAchievementCompleted", false );
	
	addEventHandler( "onAchievementCompleted", getRootElement( ),
	
		function ( thePlayer, uniqueid )
		
			if( thePlayer and self.allAchievements[uniqueid] ) then
		
				triggerClientEvent( "onAchievementCompleted", thePlayer, "Saavutus Tehtud!", self.allAchievements[uniqueid] );
				exports.phoenix_Skills:xpAdd( thePlayer, "MYCHAR", self.allAchievements[uniqueid]["xp"] );
				
				-- TODO: Add Coins...
			
			end
		
		end
	
	);
	
	addEventHandler( "onCharacterSave", getRootElement( ),
	
		function ( thePlayer )
		
			self:SavePlayer( thePlayer );
		
		end
	
	);
	
	addEvent( "onClientAchievementComplete", true );
	addEventHandler( "onClientAchievementComplete", getRootElement( ),
	
		function ( thePlayer, uniqueid )
		
			self:SetAchievementComplete( thePlayer, uniqueid );
		
		end
	
	);

end

function Achievements:ToStore( achTable )

	local str = "";
	for k, v in pairs( achTable ) do
	
		local val = 0;
		if( v ) then val = 1; end
		str = str .. k .. val;
	
	end
	
	return str;

end

function Achievements:FromStore( str )

	local tbl = { };
	local _len = string.len( str );
	
	for i = 1,6,_len do
	
		local key = string.sub( str, i, i + 4 );
		local val = tonumber( string.sub( str, i + 5, i + 6 ) );
		
		if( key and val and ( val == 0 or val == 1 )  ) then
		
			tbl[key] = ( val == 1 );
		
		end
	
	end
	
	return tbl;

end

function Achievements:FirstInit( charId )

	exports.phoenix_Base:DoSimpleQuery( string.format( "INSERT INTO %s(charid) VALUES( '%d' )", DATATABLE_NAME, charId ) );

end

function Achievements:LoadPlayer( thePlayer )

	if( not thePlayer or not isElement ( thePlayer )  ) then return false; end
	local charId = getElementData( thePlayer, "Character.id" );
	if( not charId ) then return false; end	
	
	local result = exports.phoenix_Base:SelectQuery( string.format( "SELECT * FROM %s WHERE charid = '%d'", DATATABLE_NAME, charId ) );
	
	if( not result ) then
	
		return false;
	
	elseif( not result[1] or not result[1]["achievements"] ) then
	
		self:FirstInit( charId );
		result[1]["achievements"] = "";
	
	end
	
	self.playerTable[thePlayer] = self:FromStore( tostring( result[1]["achievements"] ) );
	
	return true;

end

function Achievements:SavePlayer( thePlayer )

	if( not thePlayer or not isElement ( thePlayer )  ) then return false; end
	local charId = getElementData( thePlayer, "Character.id" );
	if( not charId ) then return false; end	
	
	local query = exports.phoenix_Base:MysqlUpdatebuild( DATATABLE_NAME );
	
	if( query ) then
	
		query = exports.phoenix_Base:MysqlSetField( query, "achievements", self:ToStore( self.playerTable[thePlayer] ) );
	
		if( query ) then
		
			return exports.phoenix_Base:DoUpdateFinish( query, "charid", charId );
		
		end
	
	end
	
	return true;

end

function Achievements:SetAchievementComplete( thePlayer, uniqueid )

	if( not thePlayer or not isElement ( thePlayer )  ) then return false; end -- Invalid thePlayer pointer
	
	local charId = getElementData( thePlayer, "Character.id" );
	if( not charId ) then return false; end	-- thePlayer has no character
	
	if( not self.allAchievements[uniqueid] ) then return false; end -- Invalid uniqueid
	if( self.playerTable[thePlayer][uniqueid] ) then return false; end -- Already Complete
	
	self.playerTable[thePlayer][uniqueid] = true;
	
	triggerEvent( "onAchievementCompleted", getRootElement( ), thePlayer, uniqueid );
	
	self:SavePlayer( thePlayer );
	
	return true;

end

function displayLoadedRes( res )	

	theAch = Achievements:new( );
	theAch:LoadConfig( );
	theAch:doEvents( );
	
	if( getResourceLastStartTime( getResourceFromName( "phoenix_Characters" ) ) > 30 ) then
		
		local players = getElementsByType( "player" );
		for k, v in ipairs( players ) do
		
			theAch:LoadPlayer( v );
		
		end

	end

end

addEventHandler( "onResourceStart", getResourceRootElement( getResourceFromName( "phoenix_Base" ) ), displayLoadedRes );
addEventHandler( "onResourceStart", getResourceRootElement( getThisResource() ), function () if( getResourceState( getResourceFromName( "phoenix_Base" ) ) == "running" ) then displayLoadedRes( ); end end );

function doneAchivement( thePlayer, uniqueid ) return theAch:SetAchievementComplete( thePlayer, uniqueid ); end
function LoadAchForPlayer( thePlayer ) theAch:LoadPlayer( thePlayer ); end
--[[

	Achievements
	
		Stored in an xml file in the following format:
		
			root
			
				achievementelem ( uniqueid(5 chars), name, coins, xp, image )
		
		For each character stored in db:
		
		charid, all
		
			all => uniq10uniq21
			
			So each elem takes 6 chars.
			
			1200 chars => 200 achievements
		
		Methods ToStore and FromStore provide conversion between database format and usable format.
		
	Class Info
	
		LoadConfig( );
		
		doEvents( );
		
		LoadPlayer( thePlayer );
		SavePlayer( thePlayer );
		
		ToStore( achTable );
		FromStore( str );
		
		SetAchievementComplete( thePlayer, uniqueid );
		
		exported macro doneAchivement
		
	Events
	
		onAchievementCompleted
		
		hook to this to display unlocked achivement message
		
]]--

DATATABLE_NAME = "ph_achievements";
DATAFIELD_SIZE = 1200;

LEN_UNIQUE_ID = 5;

MAX_ACHIEVEMENTS = math.floor( DATAFIELD_SIZE / ( LEN_UNIQUE_ID + 1 ) );

Achievements = {

	xmlFile = nil,
	
	allAchievements = { },
	
	playerTable = { }

};

function Achievements:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	return o;

end

function Achievements:LoadConfig( )

	self.xmlFile =  xmlLoadFile ( "achievements.xml" );
	if ( self.xmlFile ~= false ) then
	
		local allElements = xmlNodeGetChildren( self.xmlFile );
		
		for k, v in ipairs( allElements ) do
		
			local uid = xmlNodeGetAttribute( v, "uniqueid" );
			local name = xmlNodeGetAttribute( v, "name" );
			local desc = xmlNodeGetAttribute( v, "desc" );
			local img = xmlNodeGetAttribute( v, "img" );
			local coins = tonumber( xmlNodeGetAttribute( v, "coins" ) ) or 0;
			local xp = tonumber( xmlNodeGetAttribute( v, "xp" ) ) or 0;
			
			if( uid and name and desc and img and coins and xp ) then
			
				while( string.len( uid ) < LEN_UNIQUE_ID ) do
				
					uid = uid .. "0";
				
				end
				if( string.len( uid ) > LEN_UNIQUE_ID ) then
				
					uid = string.sub( uid, 1, LEN_UNIQUE_ID + 1 );
				
				end
				
				self.allAchievements[uid] = { };
				self.allAchievements[uid]["name"] = name;
				self.allAchievements[uid]["desc"] = desc;
				self.allAchievements[uid]["img"] = img;
				self.allAchievements[uid]["coins"] = coins;
				self.allAchievements[uid]["xp"] = xp;
			
			end
		
		end
		
		xmlUnloadFile ( self.xmlFile );
	
	else
	
		outputDebugString( "Achievements database failed to load.", 1 );
	
	end

end

function Achievements:doEvents( )

	addEvent( "onAchievementCompleted", false );
	
	addEventHandler( "onAchievementCompleted", getRootElement( ),
	
		function ( thePlayer, uniqueid )
		
			if( thePlayer and self.allAchievements[uniqueid] ) then
		
				triggerClientEvent( "onAchievementCompleted", thePlayer, "Saavutus Tehtud!", self.allAchievements[uniqueid] );
				exports.phoenix_Skills:xpAdd( thePlayer, "MYCHAR", self.allAchievements[uniqueid]["xp"] );
				
				-- TODO: Add Coins...
			
			end
		
		end
	
	);
	
	addEventHandler( "onCharacterSave", getRootElement( ),
	
		function ( thePlayer )
		
			self:SavePlayer( thePlayer );
		
		end
	
	);
	
	addEvent( "onClientAchievementComplete", true );
	addEventHandler( "onClientAchievementComplete", getRootElement( ),
	
		function ( thePlayer, uniqueid )
		
			self:SetAchievementComplete( thePlayer, uniqueid );
		
		end
	
	);

end

function Achievements:ToStore( achTable )

	local str = "";
	for k, v in pairs( achTable ) do
	
		local val = 0;
		if( v ) then val = 1; end
		str = str .. k .. val;
	
	end
	
	return str;

end

function Achievements:FromStore( str )

	local tbl = { };
	local _len = string.len( str );
	
	for i = 1,6,_len do
	
		local key = string.sub( str, i, i + 4 );
		local val = tonumber( string.sub( str, i + 5, i + 6 ) );
		
		if( key and val and ( val == 0 or val == 1 )  ) then
		
			tbl[key] = ( val == 1 );
		
		end
	
	end
	
	return tbl;

end

function Achievements:FirstInit( charId )

	exports.phoenix_Base:DoSimpleQuery( string.format( "INSERT INTO %s(charid) VALUES( '%d' )", DATATABLE_NAME, charId ) );

end

function Achievements:LoadPlayer( thePlayer )

	if( not thePlayer or not isElement ( thePlayer )  ) then return false; end
	local charId = getElementData( thePlayer, "Character.id" );
	if( not charId ) then return false; end	
	
	local result = exports.phoenix_Base:SelectQuery( string.format( "SELECT * FROM %s WHERE charid = '%d'", DATATABLE_NAME, charId ) );
	
	if( not result ) then
	
		return false;
	
	elseif( not result[1] or not result[1]["achievements"] ) then
	
		self:FirstInit( charId );
		result[1]["achievements"] = "";
	
	end
	
	self.playerTable[thePlayer] = self:FromStore( tostring( result[1]["achievements"] ) );
	
	return true;

end

function Achievements:SavePlayer( thePlayer )

	if( not thePlayer or not isElement ( thePlayer )  ) then return false; end
	local charId = getElementData( thePlayer, "Character.id" );
	if( not charId ) then return false; end	
	
	local query = exports.phoenix_Base:MysqlUpdatebuild( DATATABLE_NAME );
	
	if( query ) then
	
		query = exports.phoenix_Base:MysqlSetField( query, "achievements", self:ToStore( self.playerTable[thePlayer] ) );
	
		if( query ) then
		
			return exports.phoenix_Base:DoUpdateFinish( query, "charid", charId );
		
		end
	
	end
	
	return true;

end

function Achievements:SetAchievementComplete( thePlayer, uniqueid )

	if( not thePlayer or not isElement ( thePlayer )  ) then return false; end -- Invalid thePlayer pointer
	
	local charId = getElementData( thePlayer, "Character.id" );
	if( not charId ) then return false; end	-- thePlayer has no character
	
	if( not self.allAchievements[uniqueid] ) then return false; end -- Invalid uniqueid
	if( self.playerTable[thePlayer][uniqueid] ) then return false; end -- Already Complete
	
	self.playerTable[thePlayer][uniqueid] = true;
	
	triggerEvent( "onAchievementCompleted", getRootElement( ), thePlayer, uniqueid );
	
	self:SavePlayer( thePlayer );
	
	return true;

end

function displayLoadedRes( res )	

	theAch = Achievements:new( );
	theAch:LoadConfig( );
	theAch:doEvents( );
	
	if( getResourceLastStartTime( getResourceFromName( "phoenix_Characters" ) ) > 30 ) then
		
		local players = getElementsByType( "player" );
		for k, v in ipairs( players ) do
		
			theAch:LoadPlayer( v );
		
		end

	end

end

addEventHandler( "onResourceStart", getResourceRootElement( getResourceFromName( "phoenix_Base" ) ), displayLoadedRes );
addEventHandler( "onResourceStart", getResourceRootElement( getThisResource() ), function () if( getResourceState( getResourceFromName( "phoenix_Base" ) ) == "running" ) then displayLoadedRes( ); end end );

function doneAchivement( thePlayer, uniqueid ) return theAch:SetAchievementComplete( thePlayer, uniqueid ); end
function LoadAchForPlayer( thePlayer ) theAch:LoadPlayer( thePlayer ); end
--[[

	Achievements
	
		Stored in an xml file in the following format:
		
			root
			
				achievementelem ( uniqueid(5 chars), name, coins, xp, image )
		
		For each character stored in db:
		
		charid, all
		
			all => uniq10uniq21
			
			So each elem takes 6 chars.
			
			1200 chars => 200 achievements
		
		Methods ToStore and FromStore provide conversion between database format and usable format.
		
	Class Info
	
		LoadConfig( );
		
		doEvents( );
		
		LoadPlayer( thePlayer );
		SavePlayer( thePlayer );
		
		ToStore( achTable );
		FromStore( str );
		
		SetAchievementComplete( thePlayer, uniqueid );
		
		exported macro doneAchivement
		
	Events
	
		onAchievementCompleted
		
		hook to this to display unlocked achivement message
		
]]--

DATATABLE_NAME = "ph_achievements";
DATAFIELD_SIZE = 1200;

LEN_UNIQUE_ID = 5;

MAX_ACHIEVEMENTS = math.floor( DATAFIELD_SIZE / ( LEN_UNIQUE_ID + 1 ) );

Achievements = {

	xmlFile = nil,
	
	allAchievements = { },
	
	playerTable = { }

};

function Achievements:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	return o;

end

function Achievements:LoadConfig( )

	self.xmlFile =  xmlLoadFile ( "achievements.xml" );
	if ( self.xmlFile ~= false ) then
	
		local allElements = xmlNodeGetChildren( self.xmlFile );
		
		for k, v in ipairs( allElements ) do
		
			local uid = xmlNodeGetAttribute( v, "uniqueid" );
			local name = xmlNodeGetAttribute( v, "name" );
			local desc = xmlNodeGetAttribute( v, "desc" );
			local img = xmlNodeGetAttribute( v, "img" );
			local coins = tonumber( xmlNodeGetAttribute( v, "coins" ) ) or 0;
			local xp = tonumber( xmlNodeGetAttribute( v, "xp" ) ) or 0;
			
			if( uid and name and desc and img and coins and xp ) then
			
				while( string.len( uid ) < LEN_UNIQUE_ID ) do
				
					uid = uid .. "0";
				
				end
				if( string.len( uid ) > LEN_UNIQUE_ID ) then
				
					uid = string.sub( uid, 1, LEN_UNIQUE_ID + 1 );
				
				end
				
				self.allAchievements[uid] = { };
				self.allAchievements[uid]["name"] = name;
				self.allAchievements[uid]["desc"] = desc;
				self.allAchievements[uid]["img"] = img;
				self.allAchievements[uid]["coins"] = coins;
				self.allAchievements[uid]["xp"] = xp;
			
			end
		
		end
		
		xmlUnloadFile ( self.xmlFile );
	
	else
	
		outputDebugString( "Achievements database failed to load.", 1 );
	
	end

end

function Achievements:doEvents( )

	addEvent( "onAchievementCompleted", false );
	
	addEventHandler( "onAchievementCompleted", getRootElement( ),
	
		function ( thePlayer, uniqueid )
		
			if( thePlayer and self.allAchievements[uniqueid] ) then
		
				triggerClientEvent( "onAchievementCompleted", thePlayer, "Saavutus Tehtud!", self.allAchievements[uniqueid] );
				exports.phoenix_Skills:xpAdd( thePlayer, "MYCHAR", self.allAchievements[uniqueid]["xp"] );
				
				-- TODO: Add Coins...
			
			end
		
		end
	
	);
	
	addEventHandler( "onCharacterSave", getRootElement( ),
	
		function ( thePlayer )
		
			self:SavePlayer( thePlayer );
		
		end
	
	);
	
	addEvent( "onClientAchievementComplete", true );
	addEventHandler( "onClientAchievementComplete", getRootElement( ),
	
		function ( thePlayer, uniqueid )
		
			self:SetAchievementComplete( thePlayer, uniqueid );
		
		end
	
	);

end

function Achievements:ToStore( achTable )

	local str = "";
	for k, v in pairs( achTable ) do
	
		local val = 0;
		if( v ) then val = 1; end
		str = str .. k .. val;
	
	end
	
	return str;

end

function Achievements:FromStore( str )

	local tbl = { };
	local _len = string.len( str );
	
	for i = 1,6,_len do
	
		local key = string.sub( str, i, i + 4 );
		local val = tonumber( string.sub( str, i + 5, i + 6 ) );
		
		if( key and val and ( val == 0 or val == 1 )  ) then
		
			tbl[key] = ( val == 1 );
		
		end
	
	end
	
	return tbl;

end

function Achievements:FirstInit( charId )

	exports.phoenix_Base:DoSimpleQuery( string.format( "INSERT INTO %s(charid) VALUES( '%d' )", DATATABLE_NAME, charId ) );

end

function Achievements:LoadPlayer( thePlayer )

	if( not thePlayer or not isElement ( thePlayer )  ) then return false; end
	local charId = getElementData( thePlayer, "Character.id" );
	if( not charId ) then return false; end	
	
	local result = exports.phoenix_Base:SelectQuery( string.format( "SELECT * FROM %s WHERE charid = '%d'", DATATABLE_NAME, charId ) );
	
	if( not result ) then
	
		return false;
	
	elseif( not result[1] or not result[1]["achievements"] ) then
	
		self:FirstInit( charId );
		result[1]["achievements"] = "";
	
	end
	
	self.playerTable[thePlayer] = self:FromStore( tostring( result[1]["achievements"] ) );
	
	return true;

end

function Achievements:SavePlayer( thePlayer )

	if( not thePlayer or not isElement ( thePlayer )  ) then return false; end
	local charId = getElementData( thePlayer, "Character.id" );
	if( not charId ) then return false; end	
	
	local query = exports.phoenix_Base:MysqlUpdatebuild( DATATABLE_NAME );
	
	if( query ) then
	
		query = exports.phoenix_Base:MysqlSetField( query, "achievements", self:ToStore( self.playerTable[thePlayer] ) );
	
		if( query ) then
		
			return exports.phoenix_Base:DoUpdateFinish( query, "charid", charId );
		
		end
	
	end
	
	return true;

end

function Achievements:SetAchievementComplete( thePlayer, uniqueid )

	if( not thePlayer or not isElement ( thePlayer )  ) then return false; end -- Invalid thePlayer pointer
	
	local charId = getElementData( thePlayer, "Character.id" );
	if( not charId ) then return false; end	-- thePlayer has no character
	
	if( not self.allAchievements[uniqueid] ) then return false; end -- Invalid uniqueid
	if( self.playerTable[thePlayer][uniqueid] ) then return false; end -- Already Complete
	
	self.playerTable[thePlayer][uniqueid] = true;
	
	triggerEvent( "onAchievementCompleted", getRootElement( ), thePlayer, uniqueid );
	
	self:SavePlayer( thePlayer );
	
	return true;

end

function displayLoadedRes( res )	

	theAch = Achievements:new( );
	theAch:LoadConfig( );
	theAch:doEvents( );
	
	if( getResourceLastStartTime( getResourceFromName( "phoenix_Characters" ) ) > 30 ) then
		
		local players = getElementsByType( "player" );
		for k, v in ipairs( players ) do
		
			theAch:LoadPlayer( v );
		
		end

	end

end

addEventHandler( "onResourceStart", getResourceRootElement( getResourceFromName( "phoenix_Base" ) ), displayLoadedRes );
addEventHandler( "onResourceStart", getResourceRootElement( getThisResource() ), function () if( getResourceState( getResourceFromName( "phoenix_Base" ) ) == "running" ) then displayLoadedRes( ); end end );

function doneAchivement( thePlayer, uniqueid ) return theAch:SetAchievementComplete( thePlayer, uniqueid ); end
function LoadAchForPlayer( thePlayer ) theAch:LoadPlayer( thePlayer ); end