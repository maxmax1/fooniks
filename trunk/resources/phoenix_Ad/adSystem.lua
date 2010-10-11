AdBoards = {

	xmlFile = nil,
	
	adBoards = { },
	Bought = { },
	
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
				
				if( attr["id"] and attr["objectid"] and attr["posX"] and attr["posY"] and attr["posZ"] and children["img"] and children["txd"] and children["cameras"] ) then
				
					local id = tonumber( attr["id"] );
					self.adBoards[id] =  { };
					
					self.adBoards[id]["objectid"] = tonumber( attr["objectid"] );
					
					self.adBoards[id]["posX"] = tonumber( attr["posX"] );
					self.adBoards[id]["posY"] = tonumber( attr["posY"] );
					self.adBoards[id]["posZ"] = tonumber( attr["posZ"] );
					
					local imgA = xmlNodeGetAttributes( children["img"] );
					
					self.adBoards[id]["img"] = xmlNodeGetValue( children["img"] );
					self.adBoards[id]["w"] = tonumber( imgA["w"] ) or 32;
					self.adBoards[id]["h"] = tonumber( imgA["h"] ) or 32;
					self.adBoards[id]["txdN"] = xmlNodeGetValue( children["txd"] );
					
					self.adBoards[id]["cameras"] = { };
					local cameras = xmlNodeGetChildren( children["cameras"] );
					for k2, v2 in ipairs( cameras ) do
					
						table.insert( self.adBoards[id]["cameras"], xmlNodeGetAttributes( v2 ) );
					
					end
				
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
	
	self.xmlFile =  xmlLoadFile ( "ads.xml" );
	if ( self.xmlFile ~= false ) then
	
		local allElements = xmlNodeGetChildren( self.xmlFile );
		
		for k, v in ipairs( allElements ) do
		
			if( xmlNodeGetName( v ) == "single" ) then
			
				local attr = xmlNodeGetAttributes( v );
				
				if( attr["creator"] and attr["text"] and attr["ticksLeft"] and attr["aid"] ) then
				
					local id = tonumber( attr["aid"] );
					self.Bought[id] = { ["text"] = attr["text"], ["creator"] = attr["creator"], ["ticksLeft"] = attr["ticksLeft"] };
				
				end
			
			end
		
		end
		
		xmlUnloadFile ( self.xmlFile );
	
	end
	
	self.adTime = tonumber( get( "#AD_TIME" ) ) or 30; -- 15 min
	self.adPrice = tonumber( get( "#AD_PRICE" ) ) or 50;

end

function AdBoards:DoTick( )

	for k, v in pairs( self.Bought ) do
	
		self.Bought[k]["ticksLeft"] = self.Bought[k]["ticksLeft"] - 1;
		if( self.Bought[k]["ticksLeft"] < 0 ) then
		
			self.Bought[k] = nil;
		
		end
	
	end
	
	self:SyncBought( );

end

function AdBoards:SyncBought( theElem )

	if( not theElem ) then theElem = getRootElement( ); end
	
	local tempTbl = { };
	local conf = xmlCreateFile( "ads.xml", "adstable" );
	if( conf ) then
	
		for k, v in pairs( self.Bought ) do
		
			tempTbl[k] = true; -- save some bits.
		
			local node = xmlCreateChild( conf, "single" );
			xmlNodeSetAttribute( node, "aid", k );
			xmlNodeSetAttribute( node, "creator", v["creator"] );
			xmlNodeSetAttribute( node, "text", v["text"] );
			xmlNodeSetAttribute( node, "ticksLeft", v["ticksLeft"] );
		
		end
	
		--xmlSaveFile( conf );
		xmlUnloadFile( conf );
	
	end
	
	triggerClientEvent( theElem, "onAdSync", theElem, tempTbl );

end

function AdBoards:MarkerHit( thePlayer )

	triggerClientEvent( thePlayer, "onAdBoardRequest", thePlayer );

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

				local res, eStr = self:RefreshTxd( self.adBoards[adBoardId]["objectid"] );
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
	
		theAds.marker = createMarker( 1685.170, -1343.282, 18.035, "arrow", 1.0, 34, 60, 230 );
		addEventHandler( "onMarkerHit", theAds.marker, function ( hElem, mDim ) if( hElem and mDim ) then theAds:MarkerHit( hElem ); end end );

	end

, 1000, 1 );

setTimer( 

	function ( )
	
		theAds:DoTick( )

	end

, 30000, 0 );

addEvent( "onAdBoardDrawn", true );
addEventHandler( "onAdBoardDrawn", getRootElement( ), 

	function ( theAd, col, texts )
	
		if( client ) then
		
			local money = getPlayerMoney( client );
			
			if( theAds.Bought[theAd] ) then
			
				exports.phoenix_Chat:OocInfo( client, "See reklaam ei ole myygis." );
			
			elseif( money >= theAds.adPrice ) then
			
				takePlayerMoney( client, theAds.adPrice );
				
				-- TODO: Increment the adComp money or give money to the city.
				
				theAds:SetText( theAd, col, texts );
				theAds.Bought[theAd] =  { ["creator"] = getPlayerNametagText( client ), ["ticksLeft"] = theAds.adTime };
				theAds:SyncBought( );
			
			else
			
				exports.phoenix_Chat:OocInfo( client, "Pole piisavalt raha." );
			
			end
		
		end
	
	end

);

addEvent( "onAdSyncRequest", true );
addEventHandler( "onAdSyncRequest", getRootElement( ),

	function ( )
	
		theAds:SyncBought( client );
	
	end

);