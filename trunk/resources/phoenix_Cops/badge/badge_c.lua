PoliceBadge = {

	rootElement = nil,
	player = nil,
	
	sx,
	sy,
	
	scale = 1.0,
	
	isShowing = false,
	cAlpha = 0,
	alphaChange = 0,
	
	-- Settings
	ALPHA_THRESHOLD = 15,	
	
	white = tocolor( 255, 255, 255 ),
	alphaW = tocolor( 255, 255, 255, 0 ),
	alphaB = tocolor( 0, 0, 0, 0 ),
	
	badgePos = { },
	buttonPos = { },
	imagePos = { },
	
	fNamePos = { },
	lNamePos = { },
	rankPos = { },
	badgeNumPos = { },
	
	data = { }
	
};

function PoliceBadge:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	-- Init variables...
	
	self.rootElement = getRootElement( );
	self.player = getLocalPlayer( );
	
	self.sx, self.sy = guiGetScreenSize( );
	
	self:Calculate( );
	
	return o;

end


function PoliceBadge:Calculate( )

	-- if smaller screen than 800x600 then resize else no.
	if( self.sx < 800 ) then
	
		self.scale = self.sx / 800;
	
	else
	
		self.scale = 1.0;
	
	end
	
	-- Badge Pos
	self.badgePos[1] = ( self.sx - ( self.scale * 768 ) ) / 2;
	self.badgePos[2] = ( self.sy - ( self.scale * 512 ) ) / 2;
	self.badgePos[3] = self.scale * 768;
	self.badgePos[4] = self.scale * 512;
	
	-- Button Pos
	
	self.buttonPos[1] = self.badgePos[1] + ( self.scale * 600 );
	self.buttonPos[2] = self.badgePos[2] + ( self.scale * 38 );
	self.buttonPos[3] = self.scale * 68;
	self.buttonPos[4] = self.scale * 68;
	
	-- imagePos
	self.imagePos[1] = self.badgePos[1] + ( self.scale * 202 );
	self.imagePos[2] = self.badgePos[2] + ( self.scale * 178 );
	self.imagePos[3] = self.scale * 76;
	self.imagePos[4] = self.scale * 102;
	
	-- fNamePos
	
	self.fNamePos[1] = self.badgePos[1] + ( self.scale * 169 );
	self.fNamePos[2] = self.badgePos[2] + ( self.scale * 309 )-17;
	self.fNamePos[3] = self.scale * 139;
	self.fNamePos[4] = self.scale * 20;
	
	-- lNamePos
	
	self.lNamePos[1] = self.badgePos[1] + ( self.scale * 169 );
	self.lNamePos[2] = self.badgePos[2] + ( self.scale * 335 )-17;
	self.lNamePos[3] = self.scale * 139;
	self.lNamePos[4] = self.scale * 20;
	
	-- rankPos
	
	self.rankPos[1] = self.badgePos[1] + ( self.scale * 169 );
	self.rankPos[2] = self.badgePos[2] + ( self.scale * 362 )-17;
	self.rankPos[3] = self.scale * 139;
	self.rankPos[4] = self.scale * 20;
	
	-- badgeNumPos
	
	self.badgeNumPos[1] = self.badgePos[1] + ( self.scale * 169 );
	self.badgeNumPos[2] = self.badgePos[2] + ( self.scale * 389 )-17;
	self.badgeNumPos[3] = self.scale * 139;
	self.badgeNumPos[4] = self.scale * 20;

end

function PoliceBadge:IsMouseOver( mouseX, mouseY, eCords )

	return ( mouseX >= eCords[1] and mouseX <= eCords[1]+eCords[3] and mouseY >= eCords[2] and mouseY <= eCords[2]+eCords[4] );

end

function PoliceBadge:DoAlpha( )

	self.cAlpha = self.cAlpha + self.alphaChange;
	
	if( self.alphaChange > 0 ) then
	
		if( self.cAlpha >= 255 ) then
		
			self.alphaChange = 0;
			self.cAlpha = 255;
		
		end
	
	elseif( self.alphaChange < 0 ) then
		
		if( self.cAlpha <= 0 ) then
		
			self.alphaChange = 0;
			self.cAlpha = 0;
			self.isShowing = false;
		
		end	
	
	end
	
	self.alphaW = tocolor( 255, 255, 255, self.cAlpha );
	self.alphaB = tocolor( 0, 0, 0, self.cAlpha );

end

function PoliceBadge:Show( thePlayer )

	if( thePlayer ) then
	
		self:SetData( thePlayer );
	
	else
	
		if( self.isShowing ) then self:Hide(  ); end
	
	end

	self.isShowing = true;
	self.cAlpha = 0;
	self.alphaChange = 1 * self.ALPHA_THRESHOLD;

end

function PoliceBadge:Hide( )

	self.cAlpha = 255;
	self.alphaChange = -1 * self.ALPHA_THRESHOLD;

end

function PoliceBadge:DrawBadge( )

	dxDrawImage( self.badgePos[1], self.badgePos[2], self.badgePos[3], self.badgePos[4], "badge/badge.png", 0, 0, 0, self.alphaW, true );

end

function PoliceBadge:SetData( thePlayer )

	self.data.imgF = string.format(":phoenix_Characters/files/skins/%03d.png", getElementModel( thePlayer ) or 0 );
	
	local name = getPlayerNametagText( thePlayer );
	local last = nil--;string.find( name, "_", 1 );
	
	for i = string.len( name ), 1, -1 do
	
		local c = string.sub( name, i, i );
		if( c == "_" ) then
		
			last = i;
			break;
		
		end
	
	end
	
	if( last ) then
	
		self.data.fName = tostring( string.sub( name, 1, last-1 ) );
		self.data.lName = tostring( string.sub( name, last+1 ) );
	
	end
	
	

end

function PoliceBadge:DrawData( )

	-- Image
	dxDrawImage( self.imagePos[1], self.imagePos[2], self.imagePos[3], self.imagePos[4], self.data.imgF or ":phoenix_Characters/files/skins/00-1.png", 0, 0, 0, self.alphaW, true );
	
	-- First Name
	dxDrawText( self.data.fName or "John", self.fNamePos[1], self.fNamePos[2], self.fNamePos[1]+self.fNamePos[3], self.fNamePos[2]+self.fNamePos[4], self.alphaB, 1.1, "default", "center", "bottom", true, true, true );

	-- Last Name
	dxDrawText( self.data.lName or "Doe", self.lNamePos[1], self.lNamePos[2], self.lNamePos[1]+self.lNamePos[3], self.lNamePos[2]+self.lNamePos[4], self.alphaB, 1.1, "default", "center", "bottom", true, true, true );

	-- Rank
	dxDrawText( self.data.rank or "Ohvitser", self.rankPos[1], self.rankPos[2], self.rankPos[1]+self.rankPos[3], self.rankPos[2]+self.rankPos[4], self.alphaB, 1.1, "default", "center", "bottom", true, true, true );

	-- badgenum
	dxDrawText( self.data.badgenum or "0000000000", self.badgeNumPos[1], self.badgeNumPos[2], self.badgeNumPos[1]+self.badgeNumPos[3], self.badgeNumPos[2]+self.badgeNumPos[4], self.alphaB, 1.1, "default", "center", "bottom", true, true, true );

end

function PoliceBadge:DrawButton( )

	if( not isCursorShowing( ) ) then showCursor( true ); end

	local mX, mY = getCursorPosition( );
	mX = mX * self.sx;
	mY = mY * self.sy;
	local imgF = "badge/closeBut.png";
	if( self:IsMouseOver( mX, mY, self.buttonPos ) ) then
	
		imgF = "badge/closeBut_hover.png";
	
	end

	dxDrawImage( self.buttonPos[1], self.buttonPos[2], self.buttonPos[3], self.buttonPos[4], imgF, 0, 0, 0, self.alphaW, true );

end

function PoliceBadge:DoEvents( )

	addEventHandler( "onClientClick", self.rootElement,
	
		function ( button, state, aX, aY, wX, wY, wZ, clickElem )
		
			if( button ~= "left" or state ~= "down" ) then
			
				return false;
			
			end		
		
			if( self.isShowing ) then
			
				if( self:IsMouseOver( aX, aY, self.buttonPos ) ) then
				
					triggerServerEvent( "doNotWantBadge", self.player );
					self:Hide( );
				
				end
			
			end
		
		end
	
	);			

	addEventHandler( "onClientRender", self.rootElement, 
	
		function ( )
		
		
			if( self.isShowing ) then
			
				if( self.alphaChange ~= 0 ) then
				
					self:DoAlpha( );
				
				end
			
				self:DrawBadge( );
				self:DrawData( );
				self:DrawButton( );
			
			end
		
		end
	
	);
	
	addEvent( "onWantSeeBadge", true );
	addEventHandler( "onWantSeeBadge", self.rootElement, 
	
		function ( thePlayer  )
		
			theBadge:Show( thePlayer );
		
		end
	
	);

end

theBadge = PoliceBadge:new( );
theBadge:DoEvents( );

-- theBadge:Show( );