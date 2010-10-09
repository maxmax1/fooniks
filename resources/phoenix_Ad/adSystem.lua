AdBoards = {

	xmlFile = nil,
	
	adBoards = { },
	qMarkers = { },

};

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
				
				if( attr["objectid"] and attr["posX"] and attr["posY"] and attr["posZ"] and children["img"] and children["txd"] and children["textpos"] ) then
				
					local id = tonumber( attr["objectid"] );
					self.adBoards[id] =  { };
					
					self.adBoards[id]["posX"] = tonumber( attr["posX"] );
					self.adBoards[id]["posY"] = tonumber( attr["posY"] );
					self.adBoards[id]["posZ"] = tonumber( attr["posZ"] );
					
					local imgA = xmlNodeGetAttributes( children["img"] );
					
					self.adBoards[id]["img"] = xmlNodeGetValue( children["img"] );
					self.adBoards[id]["w"] = tonumber( imgA["w"] ) or 32;
					self.adBoards[id]["h"] = tonumber( imgA["h"] ) or 32;
					self.adBoards[id]["txdF"] = xmlNodeGetValue( children["txd"] );
					self.adBoards[id]["txdN"] = xmlNodeGetAttribute( children["txd"], "innerName" );
					self.adBoards[id]["textPos"] = xmlNodeGetAttributes( children["textpos"] );
					
					self.adBoards[id]["marker"] = createMarker( self.adBoards[id]["posX"], self.adBoards[id]["posY"], self.adBoards[id]["posZ"], "arrow", 1.0, 34, 60, 230 );
					self.qMarkers[self.adBoards[id]["marker"]] = id;
					
					addEventHandler( "onMarkerHit", self.adBoards[id]["marker"], function ( hElem, mDim ) if( hElem and mDim ) then self:MarkerHit( hElem, source ); end end );
				
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

function AdBoards:SetText( adBoardId, theText, col1, col2 )

	if( self.adBoards[adBoardId] ) then
	
		local im = imageCreateTrueColor( tonumber(self.adBoards[adBoardId]["w"]), tonumber(self.adBoards[adBoardId]["h"]) );
		if( im ) then
		
			-- if( not col2 ) then col2 = { 255, 255, 255 }; end
		
			local col = imageColorAllocate( im, col2[1] or 255, col2[2] or 255, col2[3] or 255 );
			if( col ) then
			
				local rTbl = imageTtfBBox( 10, 0, "arial.ttf", theText );
				
				if( rTbl ) then
									
					imageTtfText( im, 10, 0, 
							tonumber(  self.adBoards[adBoardId]["textPos"]["x"] ) or 5,
							tonumber(  self.adBoards[adBoardId]["textPos"]["y"] ) + rTbl[4]-rTbl[8] or 5 + rTbl[4]-rTbl[8],
							col,
							"arial.ttf",
							theText
					);
					imagePng( im, self.adBoards[adBoardId]["img"] );

					local txd = createTxdContainer( );
					if( txd ) then
					
						txdContainerAddImage( txd, self.adBoards[adBoardId]["txdN"], self.adBoards[adBoardId]["img"] );
						saveTxdContainer( txd, self.adBoards[adBoardId]["txdF"] );
						
						-- Refresh the manager so textures will be reloaded...
						local res = getResourceFromName( "phoenix_AdManager" );
						if( res ) then
						
							restartResource( res );
							return 0;
						
						end
					
						return -6;
					
					end
				
					return -5;
				
				end
				
				return -4;
			
			end
		
			return -3;
		
		end
	
		return -2;
	
	end
	return -1;

end

theAds = AdBoards:new( );
theAds:Load( );
setTimer( function () outputDebugString( tostring( theAds:SetText( 13890, "TESTING..." ) ) ); end, 2000, 1 );

addEvent( "onAdBoardDrawn", true );
addEventHandler( "onAdBoardDrawn", getRootElement( ), 

	function ( theAd, theTxt, c1, c2 )
	
		outputDebugString( tostring( theAds:SetText( theAd, theTxt, c1, c2 ) ) );
	
	end

);
AdBoards = {

	xmlFile = nil,
	
	adBoards = { },
	qMarkers = { },

};

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
				
				if( attr["objectid"] and attr["posX"] and attr["posY"] and attr["posZ"] and children["img"] and children["txd"] and children["textpos"] ) then
				
					local id = tonumber( attr["objectid"] );
					self.adBoards[id] =  { };
					
					self.adBoards[id]["posX"] = tonumber( attr["posX"] );
					self.adBoards[id]["posY"] = tonumber( attr["posY"] );
					self.adBoards[id]["posZ"] = tonumber( attr["posZ"] );
					
					local imgA = xmlNodeGetAttributes( children["img"] );
					
					self.adBoards[id]["img"] = xmlNodeGetValue( children["img"] );
					self.adBoards[id]["w"] = tonumber( imgA["w"] ) or 32;
					self.adBoards[id]["h"] = tonumber( imgA["h"] ) or 32;
					self.adBoards[id]["txdF"] = xmlNodeGetValue( children["txd"] );
					self.adBoards[id]["txdN"] = xmlNodeGetAttribute( children["txd"], "innerName" );
					self.adBoards[id]["textPos"] = xmlNodeGetAttributes( children["textpos"] );
					
					self.adBoards[id]["marker"] = createMarker( self.adBoards[id]["posX"], self.adBoards[id]["posY"], self.adBoards[id]["posZ"], "arrow", 1.0, 34, 60, 230 );
					self.qMarkers[self.adBoards[id]["marker"]] = id;
					
					addEventHandler( "onMarkerHit", self.adBoards[id]["marker"], function ( hElem, mDim ) if( hElem and mDim ) then self:MarkerHit( hElem, source ); end end );
				
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

function AdBoards:SetText( adBoardId, theText, col1, col2 )

	if( self.adBoards[adBoardId] ) then
	
		local im = imageCreateTrueColor( tonumber(self.adBoards[adBoardId]["w"]), tonumber(self.adBoards[adBoardId]["h"]) );
		if( im ) then
		
			-- if( not col2 ) then col2 = { 255, 255, 255 }; end
		
			local col = imageColorAllocate( im, col2[1] or 255, col2[2] or 255, col2[3] or 255 );
			if( col ) then
			
				local rTbl = imageTtfBBox( 10, 0, "arial.ttf", theText );
				
				if( rTbl ) then
									
					imageTtfText( im, 10, 0, 
							tonumber(  self.adBoards[adBoardId]["textPos"]["x"] ) or 5,
							tonumber(  self.adBoards[adBoardId]["textPos"]["y"] ) + rTbl[4]-rTbl[8] or 5 + rTbl[4]-rTbl[8],
							col,
							"arial.ttf",
							theText
					);
					imagePng( im, self.adBoards[adBoardId]["img"] );

					local txd = createTxdContainer( );
					if( txd ) then
					
						txdContainerAddImage( txd, self.adBoards[adBoardId]["txdN"], self.adBoards[adBoardId]["img"] );
						saveTxdContainer( txd, self.adBoards[adBoardId]["txdF"] );
						
						-- Refresh the manager so textures will be reloaded...
						local res = getResourceFromName( "phoenix_AdManager" );
						if( res ) then
						
							restartResource( res );
							return 0;
						
						end
					
						return -6;
					
					end
				
					return -5;
				
				end
				
				return -4;
			
			end
		
			return -3;
		
		end
	
		return -2;
	
	end
	return -1;

end

theAds = AdBoards:new( );
theAds:Load( );
setTimer( function () outputDebugString( tostring( theAds:SetText( 13890, "TESTING..." ) ) ); end, 2000, 1 );

addEvent( "onAdBoardDrawn", true );
addEventHandler( "onAdBoardDrawn", getRootElement( ), 

	function ( theAd, theTxt, c1, c2 )
	
		outputDebugString( tostring( theAds:SetText( theAd, theTxt, c1, c2 ) ) );
	
	end

);