--[[

class SprayTags

Variables:

	table allTags

Functions:

	void RegisterFromMeta( );
	void SaveToMeta( );
	void AddNew( fileName );

]]--

SprayTags = 
{
	allTags = { }
};


function SprayTags:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	return o;

end

function SprayTags:RegisterFromMeta( )

	local conf = xmlLoadFile( "meta.xml" );
	if( conf ) then
	
		local elems = xmlNodeGetChildren( conf );
		if( elems ) then
		
			for k, node in ipairs( elems ) do
			
				if( xmlNodeGetName( node ) == "file" ) then
				
					table.insert( self.allTags, xmlNodeGetAttribute( node, "src" ) );
				
				end
			
			end
		
		end
		
		xmlUnloadFile( conf );
	
	end

end

function SprayTags:SaveToMeta( )

	local conf = xmlLoadFile( "meta.xml" );
	if( conf ) then
	
		local elems = xmlNodeGetChildren( conf );
		if( elems ) then
		
			for k, node in ipairs( elems ) do
			
				if( xmlNodeGetName( node ) == "file" ) then
				
					xmlDestroyNode( node );
				
				end
			
			end
			
			for k, v in ipairs( self.allTags ) do
			
				local node = xmlCreateChild( conf, "file" );
				xmlNodeSetAttribute( node, "src", v );
				xmlNodeSetAttribute( node, "type", "client" );
			
			end
		
		end
		
		xmlSaveFile( conf );
		xmlUnloadFile( conf );
	
	end
	
	restartResource( getThisResource( ) );

end

myTags = SprayTags:new( );
myTags:RegisterFromMeta( );

function uploadFile( theFile, requestHeaders, files )

	--outputDebugString( "Test: " .. type( theFile ) .. ", " );
	str = "<ul>";
	
	for k, v in pairs( theFile ) do
	
		str = str .. "<li>" .. k .. " => " .. v .. "</li>";
	
	end	
	
	str = str .. "</ul><ul>";	--[[
	
	for k, v in pairs( requestHeaders ) do
	
		str = str .. k .. " => " .. v .. "<br>";
	
	end
	str = str .. "</ul><ul>";]]--	
	
	for k, v in pairs( files ) do
	
		str = str .. "<h7>" .. k .. "</h7>";
	
		for k2, v2 in pairs( v ) do
		
			if( k2 == "file" ) then
			
				local file = fileCreate( "asdasd" .. k .. ".gif" );
				fileWrite(file, v2);
				fileClose(file);
			
				-- str = str .. "<img src='" .. v2 .. "' />";
			
			else
		
				str = str .. "<li>|" .. k2 .. "| => |" .. v2 .. "|</li>";
			
			end
		
		end
	
	end	
	str = str .. "</ul>";	

	return str;

end