AdShop = {

	xmlFile = nil,
	
	adBoards = { },
	bought = { },
	
	camId = 1,
	
	selElem = nil

};

-- 

function AdShop:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	self.rootElement = getRootElement( );
	self.thePlayer = getLocalPlayer( );
	
	self.sx, self.sy = guiGetScreenSize( );
	
	return o;

end

function AdShop:Load( )

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

end

function AdShop:build_Form( )

	self.gui = guiCreateGridList( self.sx - 350, self.sy - 465, 300, 400, false );
	
	self.okBut = guiCreateButton( self.sx - 350, self.sy - 60, 100, 25, "OSTA", false );
	self.caBut = guiCreateButton( self.sx - 150, self.sy - 60, 100, 25, "KATKESTA", false );
	
	guiGridListAddColumn( self.gui, "Vali:#", 0.9 );
	
	guiSetVisible( self.gui, false );
	guiSetVisible( self.okBut, false );
	guiSetVisible( self.caBut, false );
	
	guiSetEnabled( self.okBut, false );
	
	addEventHandler( "onClientGUIClick", self.okBut, 

		function ( button, state )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			if( source ~= self.okBut ) then return false; end
			
			local idx = tonumber( guiGridListGetItemData( self.gui, self.selElem, 1 ) );
			if( not idx ) then return false; end
			
			-- Trigger Event.
			triggerEvent( "onAdBoardDraw", self.thePlayer, idx, self.adBoards[idx]["w"], self.adBoards[idx]["h"] );
			
			self:Show( false );
		
		end
	
	);	
	
	addEventHandler( "onClientGUIClick", self.caBut, 

		function ( button, state )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			if( source ~= self.caBut ) then return false; end
			
			self:Show( false );
			self.active = false;
		
		end
	
	);		
	
	addEventHandler( "onClientGUIClick", self.gui, 

		function ( button, state )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			if( source ~= self.gui ) then return false; end
			
			local selItem = guiGridListGetSelectedItem( self.gui );
			if( selItem and ( not self.selElem or self.selElem ~= selItem ) ) then
			
				self.selElem = selItem;
				self:OnSelectionChange( );
			
			end
		
		end
	
	);		

end

function AdShop:Update( )

	guiGridListClear( self.gui );
	for k, v in pairs( self.adBoards ) do
	
		if( not self.bought[k] ) then
		
			local row = guiGridListAddRow( self.gui );
			guiGridListSetItemText( self.gui, row, 1, "ReklaamiTsoon " .. tostring(k), false, false );
			guiGridListSetItemData( self.gui, row, 1, tostring(k) );
		
		end
	
	end

end

function AdShop:OnSelectionChange( )

	local sel = "noKey";
	if( self.selElem and self.selElem ~= -1 ) then
	
		sel = tonumber( guiGridListGetItemData( self.gui, self.selElem, 1 ) );
		guiSetEnabled( self.okBut, true );
	
	else
	
		guiSetEnabled( self.okBut, false );
	
	end
	self:UpdateCamera( );

end

function AdShop:UpdateCamera( )

	local sel = "noKey";
	if( self.selElem and self.selElem ~= -1 ) then sel = tonumber( guiGridListGetItemData( self.gui, self.selElem, 1 ) ); end
	
	if( not self.adBoards[sel] ) then return false; end
	
	if( not self.adBoards[sel]["cameras"][self.camId] ) then self.camId = 1; end
	if( not self.adBoards[sel]["cameras"][self.camId] ) then return false; end -- doublecheck
	
	self:SetCamera( self.adBoards[sel]["cameras"][self.camId]["posX"], self.adBoards[sel]["cameras"][self.camId]["posY"], self.adBoards[sel]["cameras"][self.camId]["posZ"], self.adBoards[sel]["cameras"][self.camId]["lookX"], self.adBoards[sel]["cameras"][self.camId]["lookY"], self.adBoards[sel]["cameras"][self.camId]["lookZ"] );
	
	self.camId = self.camId + 1;
	return true;

end

function godmode(attacker, weapon, bodypart)
    cancelEvent()
end

function AdShop:Show( show )

	if( show ) then
	
		self.active = true;
		self:StorePos( force );
	
		if( self.timer and isTimer( self.timer ) ) then killTimer( self.timer ); end
		self.timer = setTimer( function ( ) self:UpdateCamera( ); end, 5000, 0 );
		
		guiSetVisible( self.gui, true );
		guiSetVisible( self.okBut, true );
		guiSetVisible( self.caBut, true );
		
		showCursor( true, false );
		toggleAllControls( false );
		--setPedFrozen( self.thePlayer, true );
	
	else
	
		if( self.timer and isTimer( self.timer ) ) then killTimer( self.timer ); self.timer = nil; end
		
		guiSetVisible( self.gui, false );
		guiSetVisible( self.okBut, false );
		guiSetVisible( self.caBut, false );
		self:ResetCamera( );
		showCursor( false, false );
		toggleAllControls( true );
		--setPedFrozen( self.thePlayer, false );
	
	end

end

function AdShop:SetCamera( x, y, z, lx, ly, lz, roll, fov )

	self:StorePos( );

	if( not self.unDead ) then self.unDead = true; addEventHandler( "onClientPlayerDamage", self.thePlayer, godmode ); end
	
	setElementAlpha( self.thePlayer, 0 );
	setElementPosition( self.thePlayer, lx, ly, lz );	
	setCameraMatrix( x, y, z, lx, ly, lz, roll, fov );

end

function AdShop:ResetCamera( )
	
	setElementAlpha( self.thePlayer, 255 );
	setElementPosition( self.thePlayer, self.pX, self.pY, self.pZ );
	
	if( self.unDead ) then self.unDead = false; removeEventHandler( "onClientPlayerDamage", self.thePlayer, godmode ); end	
	
	setCameraTarget( self.thePlayer );
	
	self.pX = false;

end

function AdShop:StorePos( force )

	if( not self.pX or force ) then
	
		self.pX, self.pY, self.pZ = getElementPosition( self.thePlayer );
	
	end

end

theShop = AdShop:new( );


function onStart( )

	theShop:Load( );
	theShop:build_Form( );
	theShop:Update( );
	
	triggerServerEvent( "onAdSyncRequest", theShop.thePlayer );
	
	--theShop:Show( true );

end
addEventHandler( "onClientResourceStart", getResourceRootElement( getThisResource( ) ), onStart );

addEvent( "onAdBoardRequest", true );
addEventHandler( "onAdBoardRequest", getRootElement( ), 

	function ( )
	
		if( not theShop.active ) then theShop:Show( true ); end
	
	end

);

addEvent( "resetAdShop", true );
addEventHandler( "resetAdShop", getRootElement( ), 

	function ( )
	
		theShop.active = false;
	
	end

);

addEvent( "onAdSync", true );
addEventHandler( "onAdSync", getRootElement( ), 

	function ( nBought )
	
		theShop.bought = nBought;
		theShop:Update( );
	
	end

);