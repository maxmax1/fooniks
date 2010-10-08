ClientOffer = {
 
	rootElement = nil,
	thePlayer = nil,
	
	sx, sy,

	timeLeft = 5,
	
	boxPos = { },
	butPos = { },
	tPos = { },
	
	clickedYes = false

};

function ClientOffer:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	self.rootElement = getRootElement( );
	self.thePlayer = getLocalPlayer( );
	self.sx, self.sy = guiGetScreenSize( );
	
	self:Calculate( );
	
	return o;

end

function ClientOffer:OnTimer( )

	if( self.timeLeft == 0 or not self.Visible ) then return false; end

	self.timeLeft = self.timeLeft - 1;
	if( self.timeLeft <= 0 ) then
	
		self.timeLeft = 0;
		self:Hide( );
	
	end

end

function ClientOffer:Calculate( )

	self.scale = ( self.sx / 1366 ); -- 1366 x 768
	
	---------------------

	self.boxPos[1] = ( self.sx - ( 200 * self.scale ) - ( 25 * self.scale ) );
	self.boxPos[2] = ( self.sy - ( 200 * self.scale ) ) / 2;
	self.boxPos[3] = ( 200 * self.scale );
	self.boxPos[4] = ( 200 * self.scale );
	
	self.butPos[1] = self.boxPos[1];
	self.butPos[2] = self.boxPos[2] + self.boxPos[4] + ( 5 * self.scale );
	self.butPos[3] = ( ( self.boxPos[3] - ( 10 * self.scale ) ) / 2 );
	self.butPos[4] = ( 30 * self.scale );
	self.butPos[5] = self.boxPos[1] + self.boxPos[3] - self.butPos[3];
	
	self.tPos[1] = self.boxPos[1];
	self.tPos[2] = self.butPos[2] + self.butPos[4] + ( 5 * self.scale );
	self.tPos[3] = ( 200 * self.scale );
	self.tPos[4] = ( 30 * self.scale );
	
	-- Colors
	
	self.black = tocolor( 0, 0, 0 );
	self.boxColor = tocolor( 255, 255, 255 );

end

function ClientOffer:ShowDraw( hide )

	if( not hide and not self.Visible ) then
	
		addEventHandler( "onClientRender", self.rootElement, function ( ) if( self.Visible ) then self:OnDraw( ); end end );
	
	elseif( self.Visible ) then
	
		removeEventHandler( "onClientRender", self.rootElement, function ( ) if( self.Visible ) then self:OnDraw( ); end end );
	
	end
	self.Visible = ( not hide );

end

function ClientOffer:OnDraw( )

	dxDrawRectangle( self.boxPos[1], self.boxPos[2], self.boxPos[3], self.boxPos[4], self.black, true );
	dxDrawRectangle( self.boxPos[1] + 1, self.boxPos[2] + 1, self.boxPos[3] - 2, self.boxPos[4] - 2, self.boxColor, true );
	dxDrawText( self.offer or "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", self.boxPos[1], self.boxPos[2], self.boxPos[1] + self.boxPos[3], self.boxPos[2] + self.boxPos[4], self.black, 1, "default-bold", "center", "center", true, true, true );
	
	dxDrawRectangle( self.butPos[1], self.butPos[2], self.butPos[3], self.butPos[4], self.black, true );
	dxDrawRectangle( self.butPos[1] + 1, self.butPos[2] + 1, self.butPos[3] - 2, self.butPos[4] - 2, self.boxColor, true );
	dxDrawText( "Ei", self.butPos[1], self.butPos[2], self.butPos[1] + self.butPos[3], self.butPos[2] + self.butPos[4], self.black, 1.0, "default-bold", "center", "center", true, true, true );
	
	dxDrawRectangle( self.butPos[5], self.butPos[2], self.butPos[3], self.butPos[4], self.black, true );
	dxDrawRectangle( self.butPos[5] + 1, self.butPos[2] + 1, self.butPos[3] - 2, self.butPos[4] - 2, self.boxColor, true );
	dxDrawText( "Jah", self.butPos[5], self.butPos[2], self.butPos[5] + self.butPos[3], self.butPos[2] + self.butPos[4], self.black, 1.0, "default-bold", "center", "center", true, true, true );
	
	dxDrawRectangle( self.tPos[1], self.tPos[2], self.tPos[3], self.tPos[4], self.black, true );
	dxDrawRectangle( self.tPos[1] + 1, self.tPos[2] + 1, self.tPos[3] - 2, self.tPos[4] - 2, self.boxColor, true );
	dxDrawText( string.format( "Aega jäänud %d sekundit.", self.timeLeft ), self.tPos[1], self.tPos[2], self.tPos[1] + self.tPos[3], self.tPos[2] + self.tPos[4], self.black, 1.0, "default-bold", "center", "center", true, true, true );

end

function ClientOffer:Show( theOffer )

	self.timeLeft = 10;
	self.offer = theOffer;
	self.clickedYes = false;
	
	self:ShowDraw( );
	
	setTimer( function () self:OnTimer( ); end, 1000, self.timeLeft + 1 );

end

function ClientOffer:Hide( )

	self:ShowDraw( true );
	triggerServerEvent( "onOfferResponse", self.thePlayer, self.clickedYes );

end

function ClientOffer:IsMouseOver( mouseX, mouseY, eCords )

	return ( mouseX >= eCords[1] and mouseX <= eCords[1]+eCords[3] and mouseY >= eCords[2] and mouseY <= eCords[2]+eCords[4] );

end


function ClientOffer:doEvents( )

	addEventHandler( "onClientClick", self.rootElement, 
	
		function ( button, state, aX, aY, worldX, worldY, worldZ, clickedElement  )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			if( self.Visible ) then
			
				-- clickedBtn or Hide
				if( self:IsMouseOver( aX, aY, self.butPos ) ) then -- Clicked no
				
					self:Hide( );
				
				elseif( self:IsMouseOver( aX, aY, { self.butPos[5], self.butPos[2], self.butPos[3], self.butPos[4],  } ) ) then -- Clicked yes
				
					self.clickedYes = true;
					self:Hide( );
				
				end
			
			end
		
		end
	
	);
	
	addEvent( "setClientOffer", true );
	addEventHandler( "setClientOffer", self.rootElement, 
	
		function ( offerStr  )
		
			self:Show( offerStr );
		
		end
	
	);
	
	addEvent( "unsetClientOffer", true );
	addEventHandler( "unsetClientOffer", self.rootElement, 
	
		function (  )
		
			self:ShowDraw( true );
		
		end
	
	);

end

cOffer = ClientOffer:new( );
cOffer:doEvents( );
ClientOffer = {
 
	rootElement = nil,
	thePlayer = nil,
	
	sx, sy,

	timeLeft = 5,
	
	boxPos = { },
	butPos = { },
	tPos = { },
	
	clickedYes = false

};

function ClientOffer:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	self.rootElement = getRootElement( );
	self.thePlayer = getLocalPlayer( );
	self.sx, self.sy = guiGetScreenSize( );
	
	self:Calculate( );
	
	return o;

end

function ClientOffer:OnTimer( )

	if( self.timeLeft == 0 or not self.Visible ) then return false; end

	self.timeLeft = self.timeLeft - 1;
	if( self.timeLeft <= 0 ) then
	
		self.timeLeft = 0;
		self:Hide( );
	
	end

end

function ClientOffer:Calculate( )

	self.scale = ( self.sx / 1366 ); -- 1366 x 768
	
	---------------------

	self.boxPos[1] = ( self.sx - ( 200 * self.scale ) - ( 25 * self.scale ) );
	self.boxPos[2] = ( self.sy - ( 200 * self.scale ) ) / 2;
	self.boxPos[3] = ( 200 * self.scale );
	self.boxPos[4] = ( 200 * self.scale );
	
	self.butPos[1] = self.boxPos[1];
	self.butPos[2] = self.boxPos[2] + self.boxPos[4] + ( 5 * self.scale );
	self.butPos[3] = ( ( self.boxPos[3] - ( 10 * self.scale ) ) / 2 );
	self.butPos[4] = ( 30 * self.scale );
	self.butPos[5] = self.boxPos[1] + self.boxPos[3] - self.butPos[3];
	
	self.tPos[1] = self.boxPos[1];
	self.tPos[2] = self.butPos[2] + self.butPos[4] + ( 5 * self.scale );
	self.tPos[3] = ( 200 * self.scale );
	self.tPos[4] = ( 30 * self.scale );
	
	-- Colors
	
	self.black = tocolor( 0, 0, 0 );
	self.boxColor = tocolor( 255, 255, 255 );

end

function ClientOffer:ShowDraw( hide )

	if( not hide and not self.Visible ) then
	
		addEventHandler( "onClientRender", self.rootElement, function ( ) if( self.Visible ) then self:OnDraw( ); end end );
	
	elseif( self.Visible ) then
	
		removeEventHandler( "onClientRender", self.rootElement, function ( ) if( self.Visible ) then self:OnDraw( ); end end );
	
	end
	self.Visible = ( not hide );

end

function ClientOffer:OnDraw( )

	dxDrawRectangle( self.boxPos[1], self.boxPos[2], self.boxPos[3], self.boxPos[4], self.black, true );
	dxDrawRectangle( self.boxPos[1] + 1, self.boxPos[2] + 1, self.boxPos[3] - 2, self.boxPos[4] - 2, self.boxColor, true );
	dxDrawText( self.offer or "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", self.boxPos[1], self.boxPos[2], self.boxPos[1] + self.boxPos[3], self.boxPos[2] + self.boxPos[4], self.black, 1, "default-bold", "center", "center", true, true, true );
	
	dxDrawRectangle( self.butPos[1], self.butPos[2], self.butPos[3], self.butPos[4], self.black, true );
	dxDrawRectangle( self.butPos[1] + 1, self.butPos[2] + 1, self.butPos[3] - 2, self.butPos[4] - 2, self.boxColor, true );
	dxDrawText( "Ei", self.butPos[1], self.butPos[2], self.butPos[1] + self.butPos[3], self.butPos[2] + self.butPos[4], self.black, 1.0, "default-bold", "center", "center", true, true, true );
	
	dxDrawRectangle( self.butPos[5], self.butPos[2], self.butPos[3], self.butPos[4], self.black, true );
	dxDrawRectangle( self.butPos[5] + 1, self.butPos[2] + 1, self.butPos[3] - 2, self.butPos[4] - 2, self.boxColor, true );
	dxDrawText( "Jah", self.butPos[5], self.butPos[2], self.butPos[5] + self.butPos[3], self.butPos[2] + self.butPos[4], self.black, 1.0, "default-bold", "center", "center", true, true, true );
	
	dxDrawRectangle( self.tPos[1], self.tPos[2], self.tPos[3], self.tPos[4], self.black, true );
	dxDrawRectangle( self.tPos[1] + 1, self.tPos[2] + 1, self.tPos[3] - 2, self.tPos[4] - 2, self.boxColor, true );
	dxDrawText( string.format( "Aega jäänud %d sekundit.", self.timeLeft ), self.tPos[1], self.tPos[2], self.tPos[1] + self.tPos[3], self.tPos[2] + self.tPos[4], self.black, 1.0, "default-bold", "center", "center", true, true, true );

end

function ClientOffer:Show( theOffer )

	self.timeLeft = 10;
	self.offer = theOffer;
	self.clickedYes = false;
	
	self:ShowDraw( );
	
	setTimer( function () self:OnTimer( ); end, 1000, self.timeLeft + 1 );

end

function ClientOffer:Hide( )

	self:ShowDraw( true );
	triggerServerEvent( "onOfferResponse", self.thePlayer, self.clickedYes );

end

function ClientOffer:IsMouseOver( mouseX, mouseY, eCords )

	return ( mouseX >= eCords[1] and mouseX <= eCords[1]+eCords[3] and mouseY >= eCords[2] and mouseY <= eCords[2]+eCords[4] );

end


function ClientOffer:doEvents( )

	addEventHandler( "onClientClick", self.rootElement, 
	
		function ( button, state, aX, aY, worldX, worldY, worldZ, clickedElement  )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			if( self.Visible ) then
			
				-- clickedBtn or Hide
				if( self:IsMouseOver( aX, aY, self.butPos ) ) then -- Clicked no
				
					self:Hide( );
				
				elseif( self:IsMouseOver( aX, aY, { self.butPos[5], self.butPos[2], self.butPos[3], self.butPos[4],  } ) ) then -- Clicked yes
				
					self.clickedYes = true;
					self:Hide( );
				
				end
			
			end
		
		end
	
	);
	
	addEvent( "setClientOffer", true );
	addEventHandler( "setClientOffer", self.rootElement, 
	
		function ( offerStr  )
		
			self:Show( offerStr );
		
		end
	
	);
	
	addEvent( "unsetClientOffer", true );
	addEventHandler( "unsetClientOffer", self.rootElement, 
	
		function (  )
		
			self:ShowDraw( true );
		
		end
	
	);

end

cOffer = ClientOffer:new( );
cOffer:doEvents( );
ClientOffer = {
 
	rootElement = nil,
	thePlayer = nil,
	
	sx, sy,

	timeLeft = 5,
	
	boxPos = { },
	butPos = { },
	tPos = { },
	
	clickedYes = false

};

function ClientOffer:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	self.rootElement = getRootElement( );
	self.thePlayer = getLocalPlayer( );
	self.sx, self.sy = guiGetScreenSize( );
	
	self:Calculate( );
	
	return o;

end

function ClientOffer:OnTimer( )

	if( self.timeLeft == 0 or not self.Visible ) then return false; end

	self.timeLeft = self.timeLeft - 1;
	if( self.timeLeft <= 0 ) then
	
		self.timeLeft = 0;
		self:Hide( );
	
	end

end

function ClientOffer:Calculate( )

	self.scale = ( self.sx / 1366 ); -- 1366 x 768
	
	---------------------

	self.boxPos[1] = ( self.sx - ( 200 * self.scale ) - ( 25 * self.scale ) );
	self.boxPos[2] = ( self.sy - ( 200 * self.scale ) ) / 2;
	self.boxPos[3] = ( 200 * self.scale );
	self.boxPos[4] = ( 200 * self.scale );
	
	self.butPos[1] = self.boxPos[1];
	self.butPos[2] = self.boxPos[2] + self.boxPos[4] + ( 5 * self.scale );
	self.butPos[3] = ( ( self.boxPos[3] - ( 10 * self.scale ) ) / 2 );
	self.butPos[4] = ( 30 * self.scale );
	self.butPos[5] = self.boxPos[1] + self.boxPos[3] - self.butPos[3];
	
	self.tPos[1] = self.boxPos[1];
	self.tPos[2] = self.butPos[2] + self.butPos[4] + ( 5 * self.scale );
	self.tPos[3] = ( 200 * self.scale );
	self.tPos[4] = ( 30 * self.scale );
	
	-- Colors
	
	self.black = tocolor( 0, 0, 0 );
	self.boxColor = tocolor( 255, 255, 255 );

end

function ClientOffer:ShowDraw( hide )

	if( not hide and not self.Visible ) then
	
		addEventHandler( "onClientRender", self.rootElement, function ( ) if( self.Visible ) then self:OnDraw( ); end end );
	
	elseif( self.Visible ) then
	
		removeEventHandler( "onClientRender", self.rootElement, function ( ) if( self.Visible ) then self:OnDraw( ); end end );
	
	end
	self.Visible = ( not hide );

end

function ClientOffer:OnDraw( )

	dxDrawRectangle( self.boxPos[1], self.boxPos[2], self.boxPos[3], self.boxPos[4], self.black, true );
	dxDrawRectangle( self.boxPos[1] + 1, self.boxPos[2] + 1, self.boxPos[3] - 2, self.boxPos[4] - 2, self.boxColor, true );
	dxDrawText( self.offer or "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", self.boxPos[1], self.boxPos[2], self.boxPos[1] + self.boxPos[3], self.boxPos[2] + self.boxPos[4], self.black, 1, "default-bold", "center", "center", true, true, true );
	
	dxDrawRectangle( self.butPos[1], self.butPos[2], self.butPos[3], self.butPos[4], self.black, true );
	dxDrawRectangle( self.butPos[1] + 1, self.butPos[2] + 1, self.butPos[3] - 2, self.butPos[4] - 2, self.boxColor, true );
	dxDrawText( "Ei", self.butPos[1], self.butPos[2], self.butPos[1] + self.butPos[3], self.butPos[2] + self.butPos[4], self.black, 1.0, "default-bold", "center", "center", true, true, true );
	
	dxDrawRectangle( self.butPos[5], self.butPos[2], self.butPos[3], self.butPos[4], self.black, true );
	dxDrawRectangle( self.butPos[5] + 1, self.butPos[2] + 1, self.butPos[3] - 2, self.butPos[4] - 2, self.boxColor, true );
	dxDrawText( "Jah", self.butPos[5], self.butPos[2], self.butPos[5] + self.butPos[3], self.butPos[2] + self.butPos[4], self.black, 1.0, "default-bold", "center", "center", true, true, true );
	
	dxDrawRectangle( self.tPos[1], self.tPos[2], self.tPos[3], self.tPos[4], self.black, true );
	dxDrawRectangle( self.tPos[1] + 1, self.tPos[2] + 1, self.tPos[3] - 2, self.tPos[4] - 2, self.boxColor, true );
	dxDrawText( string.format( "Aega jäänud %d sekundit.", self.timeLeft ), self.tPos[1], self.tPos[2], self.tPos[1] + self.tPos[3], self.tPos[2] + self.tPos[4], self.black, 1.0, "default-bold", "center", "center", true, true, true );

end

function ClientOffer:Show( theOffer )

	self.timeLeft = 10;
	self.offer = theOffer;
	self.clickedYes = false;
	
	self:ShowDraw( );
	
	setTimer( function () self:OnTimer( ); end, 1000, self.timeLeft + 1 );

end

function ClientOffer:Hide( )

	self:ShowDraw( true );
	triggerServerEvent( "onOfferResponse", self.thePlayer, self.clickedYes );

end

function ClientOffer:IsMouseOver( mouseX, mouseY, eCords )

	return ( mouseX >= eCords[1] and mouseX <= eCords[1]+eCords[3] and mouseY >= eCords[2] and mouseY <= eCords[2]+eCords[4] );

end


function ClientOffer:doEvents( )

	addEventHandler( "onClientClick", self.rootElement, 
	
		function ( button, state, aX, aY, worldX, worldY, worldZ, clickedElement  )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			if( self.Visible ) then
			
				-- clickedBtn or Hide
				if( self:IsMouseOver( aX, aY, self.butPos ) ) then -- Clicked no
				
					self:Hide( );
				
				elseif( self:IsMouseOver( aX, aY, { self.butPos[5], self.butPos[2], self.butPos[3], self.butPos[4],  } ) ) then -- Clicked yes
				
					self.clickedYes = true;
					self:Hide( );
				
				end
			
			end
		
		end
	
	);
	
	addEvent( "setClientOffer", true );
	addEventHandler( "setClientOffer", self.rootElement, 
	
		function ( offerStr  )
		
			self:Show( offerStr );
		
		end
	
	);
	
	addEvent( "unsetClientOffer", true );
	addEventHandler( "unsetClientOffer", self.rootElement, 
	
		function (  )
		
			self:ShowDraw( true );
		
		end
	
	);

end

cOffer = ClientOffer:new( );
cOffer:doEvents( );