local BROWSER_NAME = "Phoenix Explorer";

Browser = {

	pName,
	pVersion,
	
	rUrl = "about/Blank",
	cPage = "about:Blank",
	
	mDomains = { },
	
	g_Elements = { },
	
	colors = { ["white"] = "white" },
	
	cache = { }

};

function Browser:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	return o;

end

function Browser:Window()
	
	self.g_Elements = {}
	self.g_Elements._placeHolders = {}
	
	local screenWidth, screenHeight = guiGetScreenSize()
	
	local wWidth = 0.6;
	if( screenWidth / screenHeight == 4 / 3 ) then wWidth = 0.8; end
	
	self.g_Elements["_root"] = guiCreateWindow( ( 1 - wWidth ) / 2, 0.2, wWidth, 0.6, self:GetTitle( ), true );
	guiWindowSetSizable( self.g_Elements["_root"], false );
	
	self.g_Elements["back"] = guiCreateButton( .013, .050, .048, .0550, "<<", true, self.g_Elements["_root"] );
	guiSetEnabled( self.g_Elements["back"], false );
	
	self.g_Elements["forward"] = guiCreateButton( .069, .050, .048, .0550, ">>", true, self.g_Elements["_root"] );
	guiSetEnabled( self.g_Elements["forward"], false );
	
	self.g_Elements["refresh"] = guiCreateButton( .125, .050, .048, .0550, "F5", true, self.g_Elements["_root"] );
	
	self.g_Elements["urlEdit"] = guiCreateEdit( .181, .053, .736, .0550, "", true, self.g_Elements["_root"] );
	guiEditSetMaxLength( self.g_Elements["urlEdit"], 130 );
	
	self.g_Elements["goButton"] = guiCreateButton( .925, .050, .060, .0550, "Mine", true, self.g_Elements["_root"] );
	
	self.g_Elements["bodyArea"] = guiCreateScrollPane( .013, 0.113, .973, 0.8, true, self.g_Elements["_root"] );
	
	self.g_Elements["fakeBack"] = guiCreateStaticImage( 0, 0, 1, 1, "img/white.png", true, self.g_Elements["bodyArea"] );
	
	self.g_Elements["close"] = guiCreateButton( .895, .926, .091, .0550, "Close", true, self.g_Elements["_root"] );
	
	addEventHandler( "onClientGUIClick", self.g_Elements["refresh"], 

		function ( button, state )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			if( source ~= self.g_Elements["refresh"] ) then return false; end
			
			self:ShowUrl( self.rUrl );
		
		end
	
	);
	
	addEventHandler( "onClientGUIAccepted", self.g_Elements["urlEdit"], 

		function ( theElem )
			
			self:ShowUrl( guiGetText( theElem ) );
		
		end
	
	);
	
	addEventHandler( "onClientGUIClick", self.g_Elements["goButton"], 

		function ( button, state )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			if( source ~= self.g_Elements["goButton"] ) then return false; end
			
			self:ShowUrl( guiGetText( self.g_Elements["urlEdit"] ) );
		
		end
	
	);
	
	addEventHandler( "onClientGUIClick", self.g_Elements["close"], 

		function ( button, state )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			if( source ~= self.g_Elements["close"] ) then return false; end
			
			self:Hide( );
		
		end
	
	);

end

function Browser:Init( txt, ver )

	self.pName = txt;
	self.pVersion = ver;
	
	self:Window();
	self:Hide( );

	--self:doEvents( );

end

function Browser:ClearCache( )

	for k, v in ipairs( self.cache ) do
	
		destroyElement( v );
	
	end
	self.cache = { };

end

function _guiLabelGetFontHeight( elem )

	local mFont = guiGetFont( elem );
	if( mFont == "sa-gothic" ) then return 60;
	elseif( mFont == "sa-header" ) then return 33;
	else return guiLabelGetFontHeight( elem ); end

end

function Browser:ShowUrl( theUrl )

	if( theUrl ) then
	
		self:ClearCache( );
	
		self.rUrl = theUrl;
		self.cPage = theUrl;
		guiSetText( self.g_Elements["urlEdit"], theUrl );
		guiSetText( self.g_Elements["_root"], self:GetTitle( ) );
		
		domain = gettok( theUrl, 1, string.byte("/") );

		if( string.find( theUrl, "%.%." ) ) then
		
			self:ShowUrl( "error/invalidurl.xml" );
		
		elseif( self.mDomains[domain] ) then
		
			-- has get params...
			local get = string.sub( theUrl, #domain + 2 );
			
			if( not string.find( get, "%.xml" ) ) then
			
				get = get .. ".xml";
			
			end
			
			get = string.gsub( get, "/", "" );
			get = string.gsub( get, "\\", "" );
			local fullPath = self.mDomains[domain] .. "/" .. get;
			
			if( string.find( fullPath, "%.%." ) ) then -- can never be to careful
			
				self:ShowUrl( "error/invalidurl.xml" );
			
			else
			
			
				local rootNode = xmlLoadFile( fullPath );
				if( not rootNode ) then
				
					self:ShowUrl( "error/404.xml" );
				
				else
				
					-- Start parse					
					local cTemp = xmlNodeGetChildren( rootNode );
					local children = { };
					for k,v in ipairs( cTemp ) do children[tostring(xmlNodeGetName( v ))] = v; end
					
					if( not children["head"] or not children["body"] ) then
					
						self:ShowUrl( "error/syntax.xml" );
					
					else
					
						local hTemp = xmlNodeGetChildren( children["head"] );
						local heads = { };
						for k,v in ipairs( hTemp ) do heads[tostring(xmlNodeGetName( v ))] = v; end
						if( heads["title"] ) then self.cPage = xmlNodeGetValue( heads["title"] ); guiSetText( self.g_Elements["_root"], self:GetTitle( ) ); end
						
						-- Now the fun part... Let's parse the body... :D
						
						local bAttr = xmlNodeGetAttributes( children["body"] );
						local bodys = xmlNodeGetChildren( children["body"] );
						local x = tonumber(bAttr["padding"]) or 0;
						local y = tonumber(bAttr["padding"]) or 0;
						local oH = 0;
						
						if( bAttr["background"] and self.colors[bAttr["background"]] ) then
						
							guiStaticImageLoadImage( self.g_Elements["fakeBack"], ":browser/img/" .. self.colors[bAttr["background"]] .. ".png" );
							guiSetVisible( self.g_Elements["fakeBack"], true );
						
						else
						
							guiStaticImageLoadImage( self.g_Elements["fakeBack"], ":browser/img/white.png" );
							guiSetVisible( self.g_Elements["fakeBack"], true );
						
						end
						
						for k, v in ipairs( bodys ) do
						
							-- outputDebugString( xmlNodeGetValue( v ) );
							local tag = xmlNodeGetName( v );
							local val = xmlNodeGetValue( v );
							local attr = xmlNodeGetAttributes( v );
							if( tag == "label" ) then
							
								local font = "default";
								if( attr["font"] ) then font = attr["font"]; end
								
								local elem = guiCreateLabel( x, y, 500, 500, val, false, self.g_Elements["bodyArea"] );
								guiSetFont( elem, font );
								
								local h = _guiLabelGetFontHeight( elem );
								local w = guiLabelGetTextExtent( elem );

								guiSetSize( elem, w, h, false );
								
								if( attr["color"] ) then
								
									local cols = split( attr["color"], string.byte( "," ) );
									for k, v in ipairs( cols ) do cols[k] = tonumber( v ) or 0; end
									guiLabelSetColor( elem, cols[1], cols[2], cols[3] );
								
								end
								
								table.insert( self.cache, elem );
								
								x = x + w;
								-- y = y + h;
								oH = h;
							
							elseif( tag == "br" ) then
							
								x = tonumber(bAttr["padding"]) or 0;
								y = y + oH;
							
							end
						
						end
					
					end
					
					
					xmlUnloadFile( rootNode );
				
				end
			
			end 
			
		
		else
		
			self:ShowUrl( "error/notfound.xml" );
		
		end
	
	end

end

function Browser:Show( )

	guiSetInputEnabled( true );
	showCursor( true );
	guiSetVisible( self.g_Elements["_root"], true );

end

function Browser:Hide( )

	guiSetInputEnabled( false );
	showCursor( false );
	guiSetVisible( self.g_Elements["_root"], false );

end

function Browser:GetTitle( )

	return string.format( "%s - %s %s", self.cPage, self.pName, self.pVersion );

end

theBrowser = Browser:new( );
theBrowser:Init( BROWSER_NAME, " 1" );
theBrowser.mDomains["about"] = ":browser/online/about";
theBrowser.mDomains["error"] = ":browser/online/error";

addCommandHandler( "browser", 

	function ( cmdN, url )
	
		theBrowser:Show( );
		theBrowser:ShowUrl( url );
	
	end

, false, false );
local BROWSER_NAME = "Phoenix Explorer";

Browser = {

	pName,
	pVersion,
	
	rUrl = "about/Blank",
	cPage = "about:Blank",
	
	mDomains = { },
	
	g_Elements = { },
	
	colors = { ["white"] = "white" },
	
	cache = { }

};

function Browser:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	return o;

end

function Browser:Window()
	
	self.g_Elements = {}
	self.g_Elements._placeHolders = {}
	
	local screenWidth, screenHeight = guiGetScreenSize()
	
	local wWidth = 0.6;
	if( screenWidth / screenHeight == 4 / 3 ) then wWidth = 0.8; end
	
	self.g_Elements["_root"] = guiCreateWindow( ( 1 - wWidth ) / 2, 0.2, wWidth, 0.6, self:GetTitle( ), true );
	guiWindowSetSizable( self.g_Elements["_root"], false );
	
	self.g_Elements["back"] = guiCreateButton( .013, .050, .048, .0550, "<<", true, self.g_Elements["_root"] );
	guiSetEnabled( self.g_Elements["back"], false );
	
	self.g_Elements["forward"] = guiCreateButton( .069, .050, .048, .0550, ">>", true, self.g_Elements["_root"] );
	guiSetEnabled( self.g_Elements["forward"], false );
	
	self.g_Elements["refresh"] = guiCreateButton( .125, .050, .048, .0550, "F5", true, self.g_Elements["_root"] );
	
	self.g_Elements["urlEdit"] = guiCreateEdit( .181, .053, .736, .0550, "", true, self.g_Elements["_root"] );
	guiEditSetMaxLength( self.g_Elements["urlEdit"], 130 );
	
	self.g_Elements["goButton"] = guiCreateButton( .925, .050, .060, .0550, "Mine", true, self.g_Elements["_root"] );
	
	self.g_Elements["bodyArea"] = guiCreateScrollPane( .013, 0.113, .973, 0.8, true, self.g_Elements["_root"] );
	
	self.g_Elements["fakeBack"] = guiCreateStaticImage( 0, 0, 1, 1, "img/white.png", true, self.g_Elements["bodyArea"] );
	
	self.g_Elements["close"] = guiCreateButton( .895, .926, .091, .0550, "Close", true, self.g_Elements["_root"] );
	
	addEventHandler( "onClientGUIClick", self.g_Elements["refresh"], 

		function ( button, state )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			if( source ~= self.g_Elements["refresh"] ) then return false; end
			
			self:ShowUrl( self.rUrl );
		
		end
	
	);
	
	addEventHandler( "onClientGUIAccepted", self.g_Elements["urlEdit"], 

		function ( theElem )
			
			self:ShowUrl( guiGetText( theElem ) );
		
		end
	
	);
	
	addEventHandler( "onClientGUIClick", self.g_Elements["goButton"], 

		function ( button, state )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			if( source ~= self.g_Elements["goButton"] ) then return false; end
			
			self:ShowUrl( guiGetText( self.g_Elements["urlEdit"] ) );
		
		end
	
	);
	
	addEventHandler( "onClientGUIClick", self.g_Elements["close"], 

		function ( button, state )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			if( source ~= self.g_Elements["close"] ) then return false; end
			
			self:Hide( );
		
		end
	
	);

end

function Browser:Init( txt, ver )

	self.pName = txt;
	self.pVersion = ver;
	
	self:Window();
	self:Hide( );

	--self:doEvents( );

end

function Browser:ClearCache( )

	for k, v in ipairs( self.cache ) do
	
		destroyElement( v );
	
	end
	self.cache = { };

end

function _guiLabelGetFontHeight( elem )

	local mFont = guiGetFont( elem );
	if( mFont == "sa-gothic" ) then return 60;
	elseif( mFont == "sa-header" ) then return 33;
	else return guiLabelGetFontHeight( elem ); end

end

function Browser:ShowUrl( theUrl )

	if( theUrl ) then
	
		self:ClearCache( );
	
		self.rUrl = theUrl;
		self.cPage = theUrl;
		guiSetText( self.g_Elements["urlEdit"], theUrl );
		guiSetText( self.g_Elements["_root"], self:GetTitle( ) );
		
		domain = gettok( theUrl, 1, string.byte("/") );

		if( string.find( theUrl, "%.%." ) ) then
		
			self:ShowUrl( "error/invalidurl.xml" );
		
		elseif( self.mDomains[domain] ) then
		
			-- has get params...
			local get = string.sub( theUrl, #domain + 2 );
			
			if( not string.find( get, "%.xml" ) ) then
			
				get = get .. ".xml";
			
			end
			
			get = string.gsub( get, "/", "" );
			get = string.gsub( get, "\\", "" );
			local fullPath = self.mDomains[domain] .. "/" .. get;
			
			if( string.find( fullPath, "%.%." ) ) then -- can never be to careful
			
				self:ShowUrl( "error/invalidurl.xml" );
			
			else
			
			
				local rootNode = xmlLoadFile( fullPath );
				if( not rootNode ) then
				
					self:ShowUrl( "error/404.xml" );
				
				else
				
					-- Start parse					
					local cTemp = xmlNodeGetChildren( rootNode );
					local children = { };
					for k,v in ipairs( cTemp ) do children[tostring(xmlNodeGetName( v ))] = v; end
					
					if( not children["head"] or not children["body"] ) then
					
						self:ShowUrl( "error/syntax.xml" );
					
					else
					
						local hTemp = xmlNodeGetChildren( children["head"] );
						local heads = { };
						for k,v in ipairs( hTemp ) do heads[tostring(xmlNodeGetName( v ))] = v; end
						if( heads["title"] ) then self.cPage = xmlNodeGetValue( heads["title"] ); guiSetText( self.g_Elements["_root"], self:GetTitle( ) ); end
						
						-- Now the fun part... Let's parse the body... :D
						
						local bAttr = xmlNodeGetAttributes( children["body"] );
						local bodys = xmlNodeGetChildren( children["body"] );
						local x = tonumber(bAttr["padding"]) or 0;
						local y = tonumber(bAttr["padding"]) or 0;
						local oH = 0;
						
						if( bAttr["background"] and self.colors[bAttr["background"]] ) then
						
							guiStaticImageLoadImage( self.g_Elements["fakeBack"], ":browser/img/" .. self.colors[bAttr["background"]] .. ".png" );
							guiSetVisible( self.g_Elements["fakeBack"], true );
						
						else
						
							guiStaticImageLoadImage( self.g_Elements["fakeBack"], ":browser/img/white.png" );
							guiSetVisible( self.g_Elements["fakeBack"], true );
						
						end
						
						for k, v in ipairs( bodys ) do
						
							-- outputDebugString( xmlNodeGetValue( v ) );
							local tag = xmlNodeGetName( v );
							local val = xmlNodeGetValue( v );
							local attr = xmlNodeGetAttributes( v );
							if( tag == "label" ) then
							
								local font = "default";
								if( attr["font"] ) then font = attr["font"]; end
								
								local elem = guiCreateLabel( x, y, 500, 500, val, false, self.g_Elements["bodyArea"] );
								guiSetFont( elem, font );
								
								local h = _guiLabelGetFontHeight( elem );
								local w = guiLabelGetTextExtent( elem );

								guiSetSize( elem, w, h, false );
								
								if( attr["color"] ) then
								
									local cols = split( attr["color"], string.byte( "," ) );
									for k, v in ipairs( cols ) do cols[k] = tonumber( v ) or 0; end
									guiLabelSetColor( elem, cols[1], cols[2], cols[3] );
								
								end
								
								table.insert( self.cache, elem );
								
								x = x + w;
								-- y = y + h;
								oH = h;
							
							elseif( tag == "br" ) then
							
								x = tonumber(bAttr["padding"]) or 0;
								y = y + oH;
							
							end
						
						end
					
					end
					
					
					xmlUnloadFile( rootNode );
				
				end
			
			end 
			
		
		else
		
			self:ShowUrl( "error/notfound.xml" );
		
		end
	
	end

end

function Browser:Show( )

	guiSetInputEnabled( true );
	showCursor( true );
	guiSetVisible( self.g_Elements["_root"], true );

end

function Browser:Hide( )

	guiSetInputEnabled( false );
	showCursor( false );
	guiSetVisible( self.g_Elements["_root"], false );

end

function Browser:GetTitle( )

	return string.format( "%s - %s %s", self.cPage, self.pName, self.pVersion );

end

theBrowser = Browser:new( );
theBrowser:Init( BROWSER_NAME, " 1" );
theBrowser.mDomains["about"] = ":browser/online/about";
theBrowser.mDomains["error"] = ":browser/online/error";

addCommandHandler( "browser", 

	function ( cmdN, url )
	
		theBrowser:Show( );
		theBrowser:ShowUrl( url );
	
	end

, false, false );