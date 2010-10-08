AchievementDraw = {

	rootElement,
	thePlayer,
	
	sx, sy, scale,
	
	positions = { },
	imagepos = { },
	labelpos = { },
	textpos = { },
	coinspos = { },
	xppos = { },
	
	messageLoop = { },
		
	white = tocolor( 255, 255, 255, 255 ),
	labelColor = tocolor( 254, 201, 7, 255 ),
	textColor = tocolor( 255, 255, 255, 255 ),
	
	alpha = 255
};

function AchievementDraw:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	self.rootElement = getRootElement( );
	self.thePlayer = getLocalPlayer( );
	self.sx, self.sy = guiGetScreenSize( );
	
	self:Calculate( );
	
	return o;

end

function AchievementDraw:doEvents( )

	addEventHandler( "onClientRender", self.rootElement, 
	
		function ( )
		
			self:OnDraw( );
		
		end
		
	);
	
	setTimer( function ( ) self:OnTimer( ); end, 1000, 0 );
	
	addEvent( "onAchievementCompleted", true );	
	addEventHandler( "onAchievementCompleted", self.rootElement, 
	
		function ( theLabel, aData )
		
			local sTbl = { };
			sTbl.img = aData["img"];
			sTbl.label = theLabel;
			sTbl.text = aData["name"] .. " - " .. aData["desc"];
			sTbl.coins = aData["coins"];
			sTbl.xp = aData["xp"];

			self:PushMessage( sTbl );
		
		end
		
	);

end

function AchievementDraw:SetColors( )

	self.white = tocolor( 255, 255, 255, self.alpha );
	self.labelColor = tocolor( 254, 201, 7, self.alpha );
	self.textColor = tocolor( 255, 255, 255, self.alpha );

end

function AchievementDraw:Calculate( )

	self.scale = ( self.sx / 1366 ); -- 1366 x 768
	
	--
	self.positions[1] = self.sx - ( 300 * self.scale );
	self.positions[2] = self.sy - ( 125 * self.scale );
	self.positions[3] = ( 300 * self.scale );
	self.positions[4] = ( 125 * self.scale );
	
	--
	self.imagepos[1] = self.positions[1] + ( 12.5 * self.scale );
	self.imagepos[2] = self.positions[2] + ( 12.5 * self.scale );
	self.imagepos[3] = ( 100 * self.scale );
	self.imagepos[4] = ( 100 * self.scale );
	
	--
	self.labelpos[1] = self.positions[1] + ( 120 * self.scale );
	self.labelpos[2] = self.positions[2] + ( 12.5 * self.scale );
	self.labelpos[3] = self.labelpos[1] + ( 160 * self.scale );
	self.labelpos[4] = self.labelpos[2] + ( 20 * self.scale );
	
	--
	self.textpos[1] = self.positions[1] + ( 120 * self.scale );
	self.textpos[2] = self.positions[2] + ( 32.5 * self.scale );
	self.textpos[3] = self.textpos[1] + ( 160 * self.scale );
	self.textpos[4] = self.textpos[2] + ( 60 * self.scale );
	
	--
	self.coinspos[1] = self.positions[1] + ( 120 * self.scale );
	self.coinspos[2] = self.positions[2] + ( 96.5 * self.scale );
	self.coinspos[3] = 16 * self.scale;
	self.coinspos[4] = 16 * self.scale;
	self.coinspos[5] = self.coinspos[1] + self.coinspos[3] + ( 5 * self.scale );
	self.coinspos[6] = self.coinspos[2];
	self.coinspos[7] = self.coinspos[5] + ( 20 * self.scale );
	self.coinspos[8] = self.coinspos[6] + ( 60 );
	
	--
	self.xppos[1] = self.positions[1] + ( 205 * self.scale );
	self.xppos[2] = self.positions[2] + ( 96.5 * self.scale );
	self.xppos[3] = 16 * self.scale;
	self.xppos[4] = 16 * self.scale;
	self.xppos[5] = self.xppos[1] + self.xppos[3] + ( 5 * self.scale );
	self.xppos[6] = self.xppos[2];
	self.xppos[7] = self.xppos[5] + ( 20 * self.scale );
	self.xppos[8] = self.xppos[6] + ( 60 );
	
	-- Colors
	self:SetColors( );

end

function AchievementDraw:PushMessage( messageTable )

	table.insert( self.messageLoop, messageTable );

end

function AchievementDraw:RemoveMessage( theId )

	table.remove( self.messageLoop, theId );

end

function AchievementDraw:OnTimer( )

	if( #self.messageLoop > 0 ) then
	
		if( self.messageLoop[1].tstamp and getTickCount( ) - self.messageLoop[1].tstamp > 4000 ) then
		
			self.messageLoop[1].rem = true;
		
		end
	
	end

end

function AchievementDraw:OnDraw( )

	if( #self.messageLoop > 0 ) then
	
		if( not self.messageLoop[1].tstamp ) then
		
			if( self.Animation and not self.Animation.Complete ) then
			
				local alphachange = self.Animation:ShowTick( self.alpha / 255 );
				self.alpha = 255 * alphachange;
				self:SetColors( );
			
			else
			
				if( self.Animation ) then self.Animation.Complete = false; end
				self.messageLoop[1].tstamp = getTickCount( );
			
			end
		
		elseif( self.messageLoop[1].rem ) then
		
			if( self.Animation and not self.Animation.Complete ) then
			
				local alphachange = self.Animation:HideTick( self.alpha / 255 );
				self.alpha = 255 * alphachange;
				self:SetColors( );
			
			else
			
				if( self.Animation ) then self.Animation.Complete = false; end			
				self:RemoveMessage( 1 );
				return false;
			
			end
		
		end
		
		dxDrawImage( self.positions[1], self.positions[2], self.positions[3], self.positions[4], "levelUpBack.png", 0, 0, 0, self.white, true );

		dxDrawImage( self.imagepos[1], self.imagepos[2], self.imagepos[3], self.imagepos[4], self.messageLoop[1].img or "aimages/achievement.png", 0, 0, 0, self.white, true );
		
		dxDrawText( self.messageLoop[1].label or "Label", self.labelpos[1], self.labelpos[2], self.labelpos[3], self.labelpos[4], self.labelColor, 1.5 * self.scale, "default-bold", "left", "top", true, false, true );
		dxDrawText( self.messageLoop[1].text or "Dummy text", self.textpos[1], self.textpos[2], self.textpos[3], self.textpos[4], self.textColor, 1 * self.scale, "default", "left", "top", false, true, true );
		
		-- DrawXP and Coins
		
		dxDrawImage( self.coinspos[1], self.coinspos[2], self.coinspos[3], self.coinspos[4], "coins.png", 0, 0, 0, self.white, true );
		dxDrawImage( self.xppos[1], self.xppos[2], self.xppos[3], self.xppos[4], "xp.png", 0, 0, 0, self.white, true );
		
		dxDrawText( tostring( self.messageLoop[1].coins ) or "0", self.coinspos[5], self.coinspos[6], self.coinspos[7], self.coinspos[8], self.textColor, 1 * self.scale, "default", "left", "top", true, false, true );
		dxDrawText( tostring( self.messageLoop[1].xp ) or "0", self.xppos[5], self.xppos[6], self.xppos[7], self.xppos[8], self.textColor, 1 * self.scale, "default", "left", "top", true, false, true );
	
	end

end

AlphaAnimation = {

	cAlpha = 0.0,
	step = 0.05,
	
	Complete = false

};

function AlphaAnimation:new( start, o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	self.cAlpha = start;
	
	return o;

end

function AlphaAnimation:ShowTick( remAlpha )

	if( self.Complete ) then self.Complete = false; end
	self.cAlpha = self.cAlpha + self.step;
	
	if( self.cAlpha >= 1 ) then
	
		self.cAlpha = 1;
		self.Complete = true;
	
	end
	return self.cAlpha;

end

function AlphaAnimation:HideTick( remAlpha )

	if( self.Complete ) then self.Complete = false; end
	self.cAlpha = self.cAlpha - self.step;
	
	if( self.cAlpha <= 0 ) then
	
		self.cAlpha = 0;
		self.Complete = true;
	
	end	
	return self.cAlpha;

end

theDraw = AchievementDraw:new( );
theDraw:doEvents( );

theDraw:SetColors( );

local theAnim = AlphaAnimation:new( 0 );
theDraw.Animation = theAnim;
AchievementDraw = {

	rootElement,
	thePlayer,
	
	sx, sy, scale,
	
	positions = { },
	imagepos = { },
	labelpos = { },
	textpos = { },
	coinspos = { },
	xppos = { },
	
	messageLoop = { },
		
	white = tocolor( 255, 255, 255, 255 ),
	labelColor = tocolor( 254, 201, 7, 255 ),
	textColor = tocolor( 255, 255, 255, 255 ),
	
	alpha = 255
};

function AchievementDraw:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	self.rootElement = getRootElement( );
	self.thePlayer = getLocalPlayer( );
	self.sx, self.sy = guiGetScreenSize( );
	
	self:Calculate( );
	
	return o;

end

function AchievementDraw:doEvents( )

	addEventHandler( "onClientRender", self.rootElement, 
	
		function ( )
		
			self:OnDraw( );
		
		end
		
	);
	
	setTimer( function ( ) self:OnTimer( ); end, 1000, 0 );
	
	addEvent( "onAchievementCompleted", true );	
	addEventHandler( "onAchievementCompleted", self.rootElement, 
	
		function ( theLabel, aData )
		
			local sTbl = { };
			sTbl.img = aData["img"];
			sTbl.label = theLabel;
			sTbl.text = aData["name"] .. " - " .. aData["desc"];
			sTbl.coins = aData["coins"];
			sTbl.xp = aData["xp"];

			self:PushMessage( sTbl );
		
		end
		
	);

end

function AchievementDraw:SetColors( )

	self.white = tocolor( 255, 255, 255, self.alpha );
	self.labelColor = tocolor( 254, 201, 7, self.alpha );
	self.textColor = tocolor( 255, 255, 255, self.alpha );

end

function AchievementDraw:Calculate( )

	self.scale = ( self.sx / 1366 ); -- 1366 x 768
	
	--
	self.positions[1] = self.sx - ( 300 * self.scale );
	self.positions[2] = self.sy - ( 125 * self.scale );
	self.positions[3] = ( 300 * self.scale );
	self.positions[4] = ( 125 * self.scale );
	
	--
	self.imagepos[1] = self.positions[1] + ( 12.5 * self.scale );
	self.imagepos[2] = self.positions[2] + ( 12.5 * self.scale );
	self.imagepos[3] = ( 100 * self.scale );
	self.imagepos[4] = ( 100 * self.scale );
	
	--
	self.labelpos[1] = self.positions[1] + ( 120 * self.scale );
	self.labelpos[2] = self.positions[2] + ( 12.5 * self.scale );
	self.labelpos[3] = self.labelpos[1] + ( 160 * self.scale );
	self.labelpos[4] = self.labelpos[2] + ( 20 * self.scale );
	
	--
	self.textpos[1] = self.positions[1] + ( 120 * self.scale );
	self.textpos[2] = self.positions[2] + ( 32.5 * self.scale );
	self.textpos[3] = self.textpos[1] + ( 160 * self.scale );
	self.textpos[4] = self.textpos[2] + ( 60 * self.scale );
	
	--
	self.coinspos[1] = self.positions[1] + ( 120 * self.scale );
	self.coinspos[2] = self.positions[2] + ( 96.5 * self.scale );
	self.coinspos[3] = 16 * self.scale;
	self.coinspos[4] = 16 * self.scale;
	self.coinspos[5] = self.coinspos[1] + self.coinspos[3] + ( 5 * self.scale );
	self.coinspos[6] = self.coinspos[2];
	self.coinspos[7] = self.coinspos[5] + ( 20 * self.scale );
	self.coinspos[8] = self.coinspos[6] + ( 60 );
	
	--
	self.xppos[1] = self.positions[1] + ( 205 * self.scale );
	self.xppos[2] = self.positions[2] + ( 96.5 * self.scale );
	self.xppos[3] = 16 * self.scale;
	self.xppos[4] = 16 * self.scale;
	self.xppos[5] = self.xppos[1] + self.xppos[3] + ( 5 * self.scale );
	self.xppos[6] = self.xppos[2];
	self.xppos[7] = self.xppos[5] + ( 20 * self.scale );
	self.xppos[8] = self.xppos[6] + ( 60 );
	
	-- Colors
	self:SetColors( );

end

function AchievementDraw:PushMessage( messageTable )

	table.insert( self.messageLoop, messageTable );

end

function AchievementDraw:RemoveMessage( theId )

	table.remove( self.messageLoop, theId );

end

function AchievementDraw:OnTimer( )

	if( #self.messageLoop > 0 ) then
	
		if( self.messageLoop[1].tstamp and getTickCount( ) - self.messageLoop[1].tstamp > 4000 ) then
		
			self.messageLoop[1].rem = true;
		
		end
	
	end

end

function AchievementDraw:OnDraw( )

	if( #self.messageLoop > 0 ) then
	
		if( not self.messageLoop[1].tstamp ) then
		
			if( self.Animation and not self.Animation.Complete ) then
			
				local alphachange = self.Animation:ShowTick( self.alpha / 255 );
				self.alpha = 255 * alphachange;
				self:SetColors( );
			
			else
			
				if( self.Animation ) then self.Animation.Complete = false; end
				self.messageLoop[1].tstamp = getTickCount( );
			
			end
		
		elseif( self.messageLoop[1].rem ) then
		
			if( self.Animation and not self.Animation.Complete ) then
			
				local alphachange = self.Animation:HideTick( self.alpha / 255 );
				self.alpha = 255 * alphachange;
				self:SetColors( );
			
			else
			
				if( self.Animation ) then self.Animation.Complete = false; end			
				self:RemoveMessage( 1 );
				return false;
			
			end
		
		end
		
		dxDrawImage( self.positions[1], self.positions[2], self.positions[3], self.positions[4], "levelUpBack.png", 0, 0, 0, self.white, true );

		dxDrawImage( self.imagepos[1], self.imagepos[2], self.imagepos[3], self.imagepos[4], self.messageLoop[1].img or "aimages/achievement.png", 0, 0, 0, self.white, true );
		
		dxDrawText( self.messageLoop[1].label or "Label", self.labelpos[1], self.labelpos[2], self.labelpos[3], self.labelpos[4], self.labelColor, 1.5 * self.scale, "default-bold", "left", "top", true, false, true );
		dxDrawText( self.messageLoop[1].text or "Dummy text", self.textpos[1], self.textpos[2], self.textpos[3], self.textpos[4], self.textColor, 1 * self.scale, "default", "left", "top", false, true, true );
		
		-- DrawXP and Coins
		
		dxDrawImage( self.coinspos[1], self.coinspos[2], self.coinspos[3], self.coinspos[4], "coins.png", 0, 0, 0, self.white, true );
		dxDrawImage( self.xppos[1], self.xppos[2], self.xppos[3], self.xppos[4], "xp.png", 0, 0, 0, self.white, true );
		
		dxDrawText( tostring( self.messageLoop[1].coins ) or "0", self.coinspos[5], self.coinspos[6], self.coinspos[7], self.coinspos[8], self.textColor, 1 * self.scale, "default", "left", "top", true, false, true );
		dxDrawText( tostring( self.messageLoop[1].xp ) or "0", self.xppos[5], self.xppos[6], self.xppos[7], self.xppos[8], self.textColor, 1 * self.scale, "default", "left", "top", true, false, true );
	
	end

end

AlphaAnimation = {

	cAlpha = 0.0,
	step = 0.05,
	
	Complete = false

};

function AlphaAnimation:new( start, o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	self.cAlpha = start;
	
	return o;

end

function AlphaAnimation:ShowTick( remAlpha )

	if( self.Complete ) then self.Complete = false; end
	self.cAlpha = self.cAlpha + self.step;
	
	if( self.cAlpha >= 1 ) then
	
		self.cAlpha = 1;
		self.Complete = true;
	
	end
	return self.cAlpha;

end

function AlphaAnimation:HideTick( remAlpha )

	if( self.Complete ) then self.Complete = false; end
	self.cAlpha = self.cAlpha - self.step;
	
	if( self.cAlpha <= 0 ) then
	
		self.cAlpha = 0;
		self.Complete = true;
	
	end	
	return self.cAlpha;

end

theDraw = AchievementDraw:new( );
theDraw:doEvents( );

theDraw:SetColors( );

local theAnim = AlphaAnimation:new( 0 );
theDraw.Animation = theAnim;