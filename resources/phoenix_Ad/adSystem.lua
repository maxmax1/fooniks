AdBoards = {

	xmlFile = nil,
	
	adBoards = { },
	qMarkers = { },
	
	textures = { }

};

-- 

function AdBoards:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	return o;

end

function AdBoards:Load( )

	self.xmlFile =  xmlLoadFile ( "adboards.xml" );
	if ( self.xmlFile ~= false ) then
	
		local allElements = xmlNodeGetChildren( self.xmlFile );
		
		for k, v in ipairs( allElements ) do
		
			if( xmlNodeGetName( v ) == "adboard" ) then
			
				local attr = xmlNodeGetAttributes( v );
				local child = xmlNodeGetChildren( v );
				local children = { };
				for k2, v2 in ipairs( child ) do children[xmlNodeGetName(v2)] = v2; end
				
				if( attr["objectid"] and attr["posX"] and attr["posY"] and attr["posZ"] and children["img"] and children["txd"] ) then
				
					local id = tonumber( attr["objectid"] );
					self.adBoards[id] =  { };
					
					self.adBoards[id]["posX"] = tonumber( attr["posX"] );
					self.adBoards[id]["posY"] = tonumber( attr["posY"] );
					self.adBoards[id]["posZ"] = tonumber( attr["posZ"] );
					
					local imgA = xmlNodeGetAttributes( children["img"] );
					
					self.adBoards[id]["img"] = xmlNodeGetValue( children["img"] );
					self.adBoards[id]["w"] = tonumber( imgA["w"] ) or 32;
					self.adBoards[id]["h"] = tonumber( imgA["h"] ) or 32;
					self.adBoards[id]["txdN"] = xmlNodeGetValue( children["txd"] );
					
					self.adBoards[id]["marker"] = createMarker( self.adBoards[id]["posX"], self.adBoards[id]["posY"], self.adBoards[id]["posZ"], "arrow", 1.0, 34, 60, 230 );
					self.qMarkers[self.adBoards[id]["marker"]] = id;
					
					addEventHandler( "onMarkerHit", self.adBoards[id]["marker"], function ( hElem, mDim ) if( hElem and mDim ) then self:MarkerHit( hElem, source ); end end );
				
				end
			
			end
		
		end
		
		xmlUnloadFile ( self.xmlFile );
	
	end
	
	self.xmlFile =  xmlLoadFile ( "textures.xml" );
	if ( self.xmlFile ~= false ) then
	
		local allElements = xmlNodeGetChildren( self.xmlFile );
		
		for k, v in ipairs( allElements ) do
		
			if( xmlNodeGetName( v ) == "texture" ) then
			
				local attr = xmlNodeGetAttributes( v );
				local child = xmlNodeGetChildren( v );
				
				if( attr["id"] and attr["file"] ) then
				
					local id = tonumber( attr["id"] );
					self.textures[id] =  { };
					self.textures[id].file = attr["file"];
					
					self.textures[id].children = { };
					for k2, v2 in ipairs( child ) do
					
						if( xmlNodeGetName( v2 ) == "img" ) then
						
							local iName = xmlNodeGetAttribute( v2, "innername" );
							local iImg = xmlNodeGetValue( v2 );

							if( iName and iImg ) then
							
								table.insert( self.textures[id].children, { ["iName"] = iName, ["img"] = iImg } );
							
							end
						
						end
					
					end
					
				
				end
			
			end
		
		end
		
		xmlUnloadFile ( self.xmlFile );
	
	end

end

function AdBoards:MarkerHit( thePlayer, source )
	
	local theAd = self.qMarkers[source];
	if( thePlayer and self.adBoards[theAd] ) then
	
		triggerClientEvent( thePlayer, "onAdBoardDraw", thePlayer, theAd );
	
	end

end

function AdBoards:SetText( adBoardId, col, theTexts ) 

	-- TODO: Make clientside editor and serverside creator to provide same picture. That will help us create a better editor.
	-- col1 changes the png background...
	if( self.adBoards[adBoardId] ) then
	
		local im = imageCreateTrueColor( tonumber(self.adBoards[adBoardId]["w"]), tonumber(self.adBoards[adBoardId]["h"]) );
		if( im ) then
		
			-- if( not col2 ) then col2 = { 255, 255, 255 }; end
		
			local bg = imageColorAllocate( im, col[1] or 255, col[2] or 255, col[3] or 255 );
			--local col = imageColorAllocate( im, col2[1] or 255, col2[2] or 255, col2[3] or 255 );
			
			if( bg ) then
			
				imageFill( im, 3, 3, bg );
				
				for k, v in ipairs( theTexts ) do
				
					local rTbl = imageTtfBBox( 10, 0, "arial.ttf", v["text"] );
					local mCol = imageColorAllocate( im, v["col"][1] or 255, v["col"][2] or 255, v["col"][3] or 255 );
					
					if( rTbl and mCol ) then
						
						imageTtfText( im, 10, 0, 
								tonumber(  v["pos"][1] ),
								tonumber( v["pos"][2] ) + rTbl[4]-rTbl[8],
								mCol,
								"arial.ttf",
								v["text"]
						);
					
					end
				
				end
					
				imagePng( im, self.adBoards[adBoardId]["img"] );

				local res, eStr = self:RefreshTxd( adBoardId );
				if( res ~= 0 ) then
				
					return -6, eStr;
				
				end
					
				-- Refresh the manager so textures will be reloaded...
				local res = getResourceFromName( "phoenix_AdManager" );
				if( res ) then
				
					--restartResource( res );
					stopResource( res );
					setTimer( startResource, 1000, 1, res );
					return 0;
				
				end					
			
				return -5;
			
			end
		
			return -3;
		
		end
	
		return -2;
	
	end
	return -1;

end

function AdBoards:RefreshTxd( objectId )

	if( self.textures[objectId] ) then
	
		local txd = createTxdContainer( );
		if( txd ) then
		
			outputDebugString( tostring( #self.textures[objectId].children ) );
			for k, v in ipairs( self.textures[objectId].children ) do
			
				txdContainerAddImage( txd, v["iName"], v["img"], true );
			
			end
			
			saveTxdContainer( txd, self.textures[objectId].file );
			return 0;
		
		end
		
		return -2, "Ei suutnud luua texture containerit.";
	
	end
	
	return -1, "Vigane texture id.";

end

theAds = AdBoards:new( );
theAds:Load( );

setTimer( 

	function ( )
	
		theAds:SetText( 13890, {255, 0, 0}, { { ["type"] = "TextElement", ["text"] = "TextElement", ["col"] = { 255, 255, 255 }, ["pos"] = { 5, 5 } }, { ["type"] = "TextElement", ["text"] = "TextElement", ["col"] = { 255, 255, 255 }, ["pos"] = { 5, 25 } } } );
	
	end

, 1000, 1 );

addEvent( "onAdBoardDrawn", true );
addEventHandler( "onAdBoardDrawn", getRootElement( ), 

	function ( theAd, col, texts )
	
		outputDebugString( theAd .. " - " .. tostring( theAds:SetText( theAd, col, texts ) ) );
	
	end

);