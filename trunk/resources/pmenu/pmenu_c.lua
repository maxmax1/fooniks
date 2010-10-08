 ClientMenu = {
 
	rootElement = nil,
	thePlayer = nil,
	
	sx, sy,
	
	baseX, baseY, 
	
	menuItems = { },
	
	theName,
	
	-- sizes & positions
	
	total = { },
	topH = 0
 
 };
 
 function ClientMenu:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	self.rootElement = getRootElement( );
	self.thePlayer = getLocalPlayer( );
	self.sx, self.sy = guiGetScreenSize( );
	
	self:Calculate( 0, 0 );
	
	return o;

end

function ClientMenu:doEvents( )

	addEvent( "onClientPlayerMenuSync", true );
	addEventHandler( "onClientPlayerMenuSync", self.rootElement, function ( tbl ) self:onSync( tbl ); end );
	
	addEventHandler( "onClientClick", self.rootElement, 
	
		function ( button, state, aX, aY, worldX, worldY, worldZ, clickedElement  )
		
			if( not self.Visible ) then
			
				if( button ~= "right" or state ~= "up" or not clickedElement or not isElement( clickedElement ) ) then return false; end
				if( clickedElement == self.thePlayer or getElementType( clickedElement ) ~= "player" ) then return false; end
				self:Show( clickedElement, aX, aY );
			
			else
			
				-- clickedBtn or Hide
				if( not self:IsMouseOver( aX, aY, self.total ) ) then
				
					self:ShowDraw( true );
				
				else
				
					local baseY = self.total[2] + self.topH;
					local i = 0;
					
					for k, v in pairs( self.menuItems ) do
					
						if( i <= 13 ) then
					
							local col = self.elemBack;
							if( self:IsMouseOver( aX, aY, { self.total[1], baseY + ( i * self.elemH ), self.total[3], self.elemH } ) ) then
							
								triggerServerEvent( "onPlayerMenuExecute", self.thePlayer, self.cPlayer, k );
								self:ShowDraw( true );
								return true;
							
							end
						
						end
					
					end
				
				end
			
			end
		
		end
	
	);
	
	if( #self.menuItems == 0 ) then self:Sync( ); end
	
end

function ClientMenu:IsMouseOver( mouseX, mouseY, eCords )

	return ( mouseX >= eCords[1] and mouseX <= eCords[1]+eCords[3] and mouseY >= eCords[2] and mouseY <= eCords[2]+eCords[4] );

end

function ClientMenu:Show( thePlayer, aX, aY )

	self:Calculate( aX, aY );
	
	self.cPlayer = thePlayer;
	self.theName = getPlayerName( thePlayer );
	
	self:ShowDraw( );

end

function ClientMenu:ShowDraw( hide )

	if( not hide ) then
	
		addEventHandler( "onClientRender", self.rootElement, onDraw	);
	
	else
	
		removeEventHandler( "onClientRender", self.rootElement, onDraw );
	
	end
	self.Visible = ( not hide );

end

function ClientMenu:Calculate( aX, aY )

	self.scale = 1.0;
	
	--

	local calcH = 25 + ( 20 * #self.menuItems ); -- Top + elements ( cant exeede 300, so max is 13 ).
	if( calcH > 300 ) then calcH = 300; end
	
	self.total[1] = aX;
	self.total[2] = aY;
	self.total[3] = 150 * self.scale;
	self.total[4] = calcH * self.scale;
	
	if( self.total[1] + self.total[3] > self.sx ) then self.total[1] = self.sx - self.total[3]; end
	if( self.total[2] + self.total[4] > self.sy ) then self.total[2] = self.sy - self.total[4]; end
	
	self.topH = 25 * self.scale;	
	self.elemH = 20 * self.scale;
	
	-- Colors
	
	self.background = tocolor( 118, 135, 251 );
	self.topColor = tocolor( 200, 200, 0 );
	self.elemBack = tocolor( 218, 235, 251 );
	self.hoverBack = tocolor( 178, 195, 251 );
	self.elemColor = tocolor( 0, 0, 0 );

end

function ClientMenu:Sync( )

	triggerServerEvent( "onPlayerMenuSync", self.thePlayer );

end

function ClientMenu:onSync( tbl )

	for k, v in pairs( tbl ) do
	
		self.menuItems[k] = v;
	
	end

end

function ClientMenu:OnDraw( )

	if( self.Visible ) then
	
		dxDrawRectangle( self.total[1], self.total[2], self.total[3], self.topH, self.background, true ); -- top Pad
	
		dxDrawText( self.theName or "Mingi Jama", self.total[1], self.total[2], self.total[1] + self.total[3], self.total[2] + self.topH, self.topColor, 1.1 * self.scale, "default-bold", "center", "center", true, false, true );

		local baseY = self.total[2] + self.topH;
		local i = 0;

		local mX, mY = getCursorPosition( );
		mX = mX * self.sx;
		mY = mY * self.sy;		
		
		for k, v in pairs( self.menuItems ) do
		
			if( i <= 13 ) then
		
				local col = self.elemBack;
				if( self:IsMouseOver( mX, mY, { self.total[1], baseY + ( i * self.elemH ), self.total[3], self.elemH } ) ) then
				
					col = self.hoverBack;
				
				end
		
				dxDrawRectangle( self.total[1], baseY + ( i * self.elemH ), self.total[3], self.elemH, col, true );
				dxDrawText( v or "null", self.total[1], baseY + ( i * self.elemH ), self.total[1] + self.total[3], baseY + ( ( i + 1 ) * self.elemH ), self.elemColor, 1 * self.scale, "default", "center", "center", true, false, true );
				i = i + 1;
			
			end
		
		end
	
	end

end

theMenu = ClientMenu:new( );
theMenu:doEvents( );
theMenu:Sync( );

function onDraw( )

	theMenu:OnDraw( );

end
 ClientMenu = {
 
	rootElement = nil,
	thePlayer = nil,
	
	sx, sy,
	
	baseX, baseY, 
	
	menuItems = { },
	
	theName,
	
	-- sizes & positions
	
	total = { },
	topH = 0
 
 };
 
 function ClientMenu:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	self.rootElement = getRootElement( );
	self.thePlayer = getLocalPlayer( );
	self.sx, self.sy = guiGetScreenSize( );
	
	self:Calculate( 0, 0 );
	
	return o;

end

function ClientMenu:doEvents( )

	addEvent( "onClientPlayerMenuSync", true );
	addEventHandler( "onClientPlayerMenuSync", self.rootElement, function ( tbl ) self:onSync( tbl ); end );
	
	addEventHandler( "onClientClick", self.rootElement, 
	
		function ( button, state, aX, aY, worldX, worldY, worldZ, clickedElement  )
		
			if( not self.Visible ) then
			
				if( button ~= "right" or state ~= "up" or not clickedElement or not isElement( clickedElement ) ) then return false; end
				if( clickedElement == self.thePlayer or getElementType( clickedElement ) ~= "player" ) then return false; end
				self:Show( clickedElement, aX, aY );
			
			else
			
				-- clickedBtn or Hide
				if( not self:IsMouseOver( aX, aY, self.total ) ) then
				
					self:ShowDraw( true );
				
				else
				
					local baseY = self.total[2] + self.topH;
					local i = 0;
					
					for k, v in pairs( self.menuItems ) do
					
						if( i <= 13 ) then
					
							local col = self.elemBack;
							if( self:IsMouseOver( aX, aY, { self.total[1], baseY + ( i * self.elemH ), self.total[3], self.elemH } ) ) then
							
								triggerServerEvent( "onPlayerMenuExecute", self.thePlayer, self.cPlayer, k );
								self:ShowDraw( true );
								return true;
							
							end
						
						end
					
					end
				
				end
			
			end
		
		end
	
	);
	
	if( #self.menuItems == 0 ) then self:Sync( ); end
	
end

function ClientMenu:IsMouseOver( mouseX, mouseY, eCords )

	return ( mouseX >= eCords[1] and mouseX <= eCords[1]+eCords[3] and mouseY >= eCords[2] and mouseY <= eCords[2]+eCords[4] );

end

function ClientMenu:Show( thePlayer, aX, aY )

	self:Calculate( aX, aY );
	
	self.cPlayer = thePlayer;
	self.theName = getPlayerName( thePlayer );
	
	self:ShowDraw( );

end

function ClientMenu:ShowDraw( hide )

	if( not hide ) then
	
		addEventHandler( "onClientRender", self.rootElement, onDraw	);
	
	else
	
		removeEventHandler( "onClientRender", self.rootElement, onDraw );
	
	end
	self.Visible = ( not hide );

end

function ClientMenu:Calculate( aX, aY )

	self.scale = 1.0;
	
	--

	local calcH = 25 + ( 20 * #self.menuItems ); -- Top + elements ( cant exeede 300, so max is 13 ).
	if( calcH > 300 ) then calcH = 300; end
	
	self.total[1] = aX;
	self.total[2] = aY;
	self.total[3] = 150 * self.scale;
	self.total[4] = calcH * self.scale;
	
	if( self.total[1] + self.total[3] > self.sx ) then self.total[1] = self.sx - self.total[3]; end
	if( self.total[2] + self.total[4] > self.sy ) then self.total[2] = self.sy - self.total[4]; end
	
	self.topH = 25 * self.scale;	
	self.elemH = 20 * self.scale;
	
	-- Colors
	
	self.background = tocolor( 118, 135, 251 );
	self.topColor = tocolor( 200, 200, 0 );
	self.elemBack = tocolor( 218, 235, 251 );
	self.hoverBack = tocolor( 178, 195, 251 );
	self.elemColor = tocolor( 0, 0, 0 );

end

function ClientMenu:Sync( )

	triggerServerEvent( "onPlayerMenuSync", self.thePlayer );

end

function ClientMenu:onSync( tbl )

	for k, v in pairs( tbl ) do
	
		self.menuItems[k] = v;
	
	end

end

function ClientMenu:OnDraw( )

	if( self.Visible ) then
	
		dxDrawRectangle( self.total[1], self.total[2], self.total[3], self.topH, self.background, true ); -- top Pad
	
		dxDrawText( self.theName or "Mingi Jama", self.total[1], self.total[2], self.total[1] + self.total[3], self.total[2] + self.topH, self.topColor, 1.1 * self.scale, "default-bold", "center", "center", true, false, true );

		local baseY = self.total[2] + self.topH;
		local i = 0;

		local mX, mY = getCursorPosition( );
		mX = mX * self.sx;
		mY = mY * self.sy;		
		
		for k, v in pairs( self.menuItems ) do
		
			if( i <= 13 ) then
		
				local col = self.elemBack;
				if( self:IsMouseOver( mX, mY, { self.total[1], baseY + ( i * self.elemH ), self.total[3], self.elemH } ) ) then
				
					col = self.hoverBack;
				
				end
		
				dxDrawRectangle( self.total[1], baseY + ( i * self.elemH ), self.total[3], self.elemH, col, true );
				dxDrawText( v or "null", self.total[1], baseY + ( i * self.elemH ), self.total[1] + self.total[3], baseY + ( ( i + 1 ) * self.elemH ), self.elemColor, 1 * self.scale, "default", "center", "center", true, false, true );
				i = i + 1;
			
			end
		
		end
	
	end

end

theMenu = ClientMenu:new( );
theMenu:doEvents( );
theMenu:Sync( );

function onDraw( )

	theMenu:OnDraw( );

end
 ClientMenu = {
 
	rootElement = nil,
	thePlayer = nil,
	
	sx, sy,
	
	baseX, baseY, 
	
	menuItems = { },
	
	theName,
	
	-- sizes & positions
	
	total = { },
	topH = 0
 
 };
 
 function ClientMenu:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	self.rootElement = getRootElement( );
	self.thePlayer = getLocalPlayer( );
	self.sx, self.sy = guiGetScreenSize( );
	
	self:Calculate( 0, 0 );
	
	return o;

end

function ClientMenu:doEvents( )

	addEvent( "onClientPlayerMenuSync", true );
	addEventHandler( "onClientPlayerMenuSync", self.rootElement, function ( tbl ) self:onSync( tbl ); end );
	
	addEventHandler( "onClientClick", self.rootElement, 
	
		function ( button, state, aX, aY, worldX, worldY, worldZ, clickedElement  )
		
			if( not self.Visible ) then
			
				if( button ~= "right" or state ~= "up" or not clickedElement or not isElement( clickedElement ) ) then return false; end
				if( clickedElement == self.thePlayer or getElementType( clickedElement ) ~= "player" ) then return false; end
				self:Show( clickedElement, aX, aY );
			
			else
			
				-- clickedBtn or Hide
				if( not self:IsMouseOver( aX, aY, self.total ) ) then
				
					self:ShowDraw( true );
				
				else
				
					local baseY = self.total[2] + self.topH;
					local i = 0;
					
					for k, v in pairs( self.menuItems ) do
					
						if( i <= 13 ) then
					
							local col = self.elemBack;
							if( self:IsMouseOver( aX, aY, { self.total[1], baseY + ( i * self.elemH ), self.total[3], self.elemH } ) ) then
							
								triggerServerEvent( "onPlayerMenuExecute", self.thePlayer, self.cPlayer, k );
								self:ShowDraw( true );
								return true;
							
							end
						
						end
					
					end
				
				end
			
			end
		
		end
	
	);
	
	if( #self.menuItems == 0 ) then self:Sync( ); end
	
end

function ClientMenu:IsMouseOver( mouseX, mouseY, eCords )

	return ( mouseX >= eCords[1] and mouseX <= eCords[1]+eCords[3] and mouseY >= eCords[2] and mouseY <= eCords[2]+eCords[4] );

end

function ClientMenu:Show( thePlayer, aX, aY )

	self:Calculate( aX, aY );
	
	self.cPlayer = thePlayer;
	self.theName = getPlayerName( thePlayer );
	
	self:ShowDraw( );

end

function ClientMenu:ShowDraw( hide )

	if( not hide ) then
	
		addEventHandler( "onClientRender", self.rootElement, onDraw	);
	
	else
	
		removeEventHandler( "onClientRender", self.rootElement, onDraw );
	
	end
	self.Visible = ( not hide );

end

function ClientMenu:Calculate( aX, aY )

	self.scale = 1.0;
	
	--

	local calcH = 25 + ( 20 * #self.menuItems ); -- Top + elements ( cant exeede 300, so max is 13 ).
	if( calcH > 300 ) then calcH = 300; end
	
	self.total[1] = aX;
	self.total[2] = aY;
	self.total[3] = 150 * self.scale;
	self.total[4] = calcH * self.scale;
	
	if( self.total[1] + self.total[3] > self.sx ) then self.total[1] = self.sx - self.total[3]; end
	if( self.total[2] + self.total[4] > self.sy ) then self.total[2] = self.sy - self.total[4]; end
	
	self.topH = 25 * self.scale;	
	self.elemH = 20 * self.scale;
	
	-- Colors
	
	self.background = tocolor( 118, 135, 251 );
	self.topColor = tocolor( 200, 200, 0 );
	self.elemBack = tocolor( 218, 235, 251 );
	self.hoverBack = tocolor( 178, 195, 251 );
	self.elemColor = tocolor( 0, 0, 0 );

end

function ClientMenu:Sync( )

	triggerServerEvent( "onPlayerMenuSync", self.thePlayer );

end

function ClientMenu:onSync( tbl )

	for k, v in pairs( tbl ) do
	
		self.menuItems[k] = v;
	
	end

end

function ClientMenu:OnDraw( )

	if( self.Visible ) then
	
		dxDrawRectangle( self.total[1], self.total[2], self.total[3], self.topH, self.background, true ); -- top Pad
	
		dxDrawText( self.theName or "Mingi Jama", self.total[1], self.total[2], self.total[1] + self.total[3], self.total[2] + self.topH, self.topColor, 1.1 * self.scale, "default-bold", "center", "center", true, false, true );

		local baseY = self.total[2] + self.topH;
		local i = 0;

		local mX, mY = getCursorPosition( );
		mX = mX * self.sx;
		mY = mY * self.sy;		
		
		for k, v in pairs( self.menuItems ) do
		
			if( i <= 13 ) then
		
				local col = self.elemBack;
				if( self:IsMouseOver( mX, mY, { self.total[1], baseY + ( i * self.elemH ), self.total[3], self.elemH } ) ) then
				
					col = self.hoverBack;
				
				end
		
				dxDrawRectangle( self.total[1], baseY + ( i * self.elemH ), self.total[3], self.elemH, col, true );
				dxDrawText( v or "null", self.total[1], baseY + ( i * self.elemH ), self.total[1] + self.total[3], baseY + ( ( i + 1 ) * self.elemH ), self.elemColor, 1 * self.scale, "default", "center", "center", true, false, true );
				i = i + 1;
			
			end
		
		end
	
	end

end

theMenu = ClientMenu:new( );
theMenu:doEvents( );
theMenu:Sync( );

function onDraw( )

	theMenu:OnDraw( );

end