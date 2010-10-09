--[[

	Public Variables
	
		int Moving
			0 - Not Moving,
			1 - Moving Up,
			2 - Going Down,
			3 - Vibrate
]]--

PhoenixTab = {

	rootElement = nil,
	player = nil,
	
	sx,
	sy,
	
	white = tocolor( 255, 255, 255 ),
	alphaW = tocolor( 255, 255, 255, 0 ),
	alphaY = tocolor(  200, 200, 0, 0 ),
	
	scale = 1.0,
	
	isShowing = false,
	cAlpha = 0,
	alphaChange = 0,
	
	bIsOpen = true,
	
	-- Settings
	ALPHA_THRESHOLD = 15,
	
	buttons = { },
	charImg = { },
	charTxt = { },
	
	allElems = { }

};

function PhoenixTab:new( o )

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

function PhoenixTab:Calculate( )

	-- Calculate scale...
	self.scale = ( self.sx / 1024 );

	-- Calculate position and size of our background images.
	self.totalPos = { };
	
	self.totalPos[1] = 0; -- posX
	self.totalPos[2] = self.sy - ( 768 * self.scale ); -- posY
	self.totalPos[3] = 1024 * self.scale; -- width
	self.totalPos[4] = 768  * self.scale; -- height
	
	-- Calculate sizes for our buttons.
	local butW = 100 * self.scale;
	local butH = 150 * self.scale;
	
	-- Calculate position of characters button.
	self.buttons[1] = { };
	self.buttons[1].pos = { };
	self.buttons[1].file = "karakterid";
	
	self.buttons[1].pos[1] = 87 * self.scale;
	self.buttons[1].pos[2] = self.sy - butH;
	self.buttons[1].pos[3] = butW;
	self.buttons[1].pos[4] = butH;
	
	-- Calculate position of characters button.
	self.buttons[2] = { };
	self.buttons[2].pos = { };
	self.buttons[2].file = "s6brad";
	
	self.buttons[2].pos[1] = 189 * self.scale;
	self.buttons[2].pos[2] = self.sy - butH;
	self.buttons[2].pos[3] = butW;
	self.buttons[2].pos[4] = butH;
	
	-- Calculate position of help button.
	self.buttons[3] = { };
	self.buttons[3].pos = { };
	self.buttons[3].file = "abi";
	self.buttons[3].func = function ( ) exports.tutomanager:ShowTutorial( false ); end;
	
	self.buttons[3].pos[1] = 705 * self.scale;
	self.buttons[3].pos[2] = self.sy - butH;
	self.buttons[3].pos[3] = butW;
	self.buttons[3].pos[4] = butH;
	
	-- Calculate position of messages button.
	self.buttons[4] = { };
	self.buttons[4].pos = { };
	self.buttons[4].file = "s6numid";
	
	self.buttons[4].pos[1] = 791 * self.scale;
	self.buttons[4].pos[2] = self.sy - butH;
	self.buttons[4].pos[3] = butW;
	self.buttons[4].pos[4] = butH;
	
	-- Calculate position of settings button.
	self.buttons[5] = { };
	self.buttons[5].pos = { };
	self.buttons[5].file = "seaded";
	self.buttons[5].func = function () cSettings:Show( ); end;
	
	self.buttons[5].pos[1] = 876 * self.scale;
	self.buttons[5].pos[2] = self.sy - butH;
	self.buttons[5].pos[3] = butW;
	self.buttons[5].pos[4] = butH;
	
	-- Calculate positions for character info text
	self.charTxt[1] = self.sy - ( 290 * self.scale );
	self.charTxt[2] = self.sy - ( 236 * self.scale );
	self.charTxt[3] = self.sy - ( 203 * self.scale );
	self.charTxt[4] = self.sy - ( 168 * self.scale );
	self.charTxt[5] = self.sy - ( 135 * self.scale );
	self.charTxt[6] = self.sx * 0.48;
	
	-- Calculate positions for character image
	
	self.charImg[1] = ( self.sx - ( 82.5 * self.scale ) ) / 2;
	self.charImg[2] = self.sy - ( 376 * self.scale );
	self.charImg[3] = ( 82.5 * self.scale );
	self.charImg[4] = ( 76 * self.scale );	
	
	-- Calculate positions of all drawn gui elements for hiding click.
	
	-- bottom trapezoid.
	self.allElems[1] = { };
	self.allElems[1][1] = 60 * self.scale;
	self.allElems[1][2] = self.sy - ( 50 * self.scale );
	self.allElems[1][3] = 933 * self.scale;
	self.allElems[1][4] = ( 50 * self.scale );
	
	-- charData
	self.allElems[2] = { };
	self.allElems[2][1] = 340 * self.scale;
	self.allElems[2][2] = self.sy - ( 304 * self.scale );
	self.allElems[2][3] = 349 * self.scale;
	self.allElems[2][4] = ( 277 * self.scale );
	
	-- charImg
	self.allElems[3] = { };
	self.allElems[3][1] = 453 * self.scale;
	self.allElems[3][2] = self.sy - ( 390 * self.scale );
	self.allElems[3][3] = 120 * self.scale;
	self.allElems[3][4] = ( 98 * self.scale );
	
	-- changeChars
	
	self.changeChars = { };
	self.changeChars[1] = 522 * self.scale;
	self.changeChars[2] = self.sy - ( 65 * self.scale );
	self.changeChars[3] = ( 143 * self.scale );
	self.changeChars[4] = ( 27 * self.scale );	

end

function PhoenixTab:IsMouseOver( mouseX, mouseY, eCords )

	return ( mouseX and mouseY and mouseX >= eCords[1] and mouseX <= eCords[1]+eCords[3] and mouseY >= eCords[2] and mouseY <= eCords[2]+eCords[4] );

end

function PhoenixTab:DoAlpha( )

	self.cAlpha = self.cAlpha + self.alphaChange;
	
	if( self.alphaChange > 0 ) then
	
		if( self.cAlpha >= 255 ) then
		
			self.alphaChange = 0;
			self.cAlpha = 255;
			self:OnShow( );
		
		end
	
	elseif( self.alphaChange < 0 ) then
		
		if( self.cAlpha <= 0 ) then
		
			self.alphaChange = 0;
			self.cAlpha = 0;
			self.isShowing = false;
		
		end	
	
	end
	
	self.alphaW = tocolor( 255, 255, 255, self.cAlpha );
	self.alphaHW = tocolor( 255, 255, 255, 25 * ( self.cAlpha / 255 ) );
	self.alphaY = tocolor( 200, 200, 0, self.cAlpha );

end

function PhoenixTab:DrawBack( )

	local backImg = "images/bottom_closed.png";
	if( self.bIsOpen ) then
	
		backImg = "images/bottom_open.png";
	
	end
	dxDrawImage( self.totalPos[1], self.totalPos[2], self.totalPos[3], self.totalPos[4], backImg, 0, 0, 0, self.alphaW, true );

end

function PhoenixTab:DrawTop( )

	local topImg = "images/top_closed.png";
	if( self.bIsOpen ) then
	
		topImg = "images/top_open.png";
	
	end
	dxDrawImage( self.totalPos[1], self.totalPos[2], self.totalPos[3], self.totalPos[4], topImg, 0, 0, 0, self.alphaW, true );
	
	if( self.bIsOpen ) then -- draw character data
	
		dxDrawText( self.charName or "John Doe", 0, self.charTxt[1], self.sx, self.sy, self.alphaY, 2, "default-bold", "center", "top", false, false, true );
		
		dxDrawText( self.charAge or "16", self.charTxt[6], self.charTxt[2], self.sx, self.sy, self.alphaW, 1.3, "default-bold", "left", "top", false, false, true );
		dxDrawText( self.charLevel or "99", self.charTxt[6], self.charTxt[3], self.sx, self.sy, self.alphaW, 1.3, "default-bold", "left", "top", false, false, true );
		dxDrawText( self.charMoney or "0,0 .-", self.charTxt[6], self.charTxt[4], self.sx, self.sy, self.alphaW, 1.3, "default-bold", "left", "top", false, false, true );
		dxDrawText( self.charJob or "Pole", self.charTxt[6], self.charTxt[5], self.sx, self.sy, self.alphaW, 1.3, "default-bold", "left", "top", false, false, true );
		
		dxDrawImage( self.charImg[1], self.charImg[2], self.charImg[3], self.charImg[4], string.format(":phoenix_Characters/files/skins/%03d.png", self.skinImg or 0 ), 0, 0, 0, self.alphaW, true );
	
	end

end

function PhoenixTab:DrawButtons( )

	local mX, mY = getCursorPosition( );
	
	if( mX and mY ) then
	
		mX = mX * self.sx;
		mY = mY * self.sy;
	
	end
	local noHov = false;

	for k, v in ipairs( self.buttons ) do
	
		local hov = "";
		if( not noHov and self:IsMouseOver( mX, mY, v.pos ) ) then
		
			noHov = true;
			hov = "_hover";
			self.buttons[k].hover = true;
		
		else
		
			self.buttons[k].hover = false;
		
		end
		local imgS = "images/" .. v.file .. hov .. ".png";
		dxDrawImage( v.pos[1], v.pos[2], v.pos[3], v.pos[4], imgS, 0, 0, 0, self.alphaW, true );
	
	end
	
	if( self.bIsOpen and self:IsMouseOver( mX, mY, self.changeChars ) ) then
	
		dxDrawRectangle( self.changeChars[1], self.changeChars[2], self.changeChars[3], self.changeChars[4], self.alphaHW, true );
	
	end

end

function PhoenixTab:DoEvents( )

	addEventHandler( "onClientClick", self.rootElement,
	
		function ( button, state, aX, aY )
		
			if( button ~= "left" or state ~= "down" ) then
			
				return false;
			
			end		
		
			if( self.isShowing ) then
			
				for k, v in ipairs( self.buttons ) do
				
					if( v.hover ) then
				
						if( v.event ) then
						
						elseif( v.func ) then
						
							v.func( );
						
						else
						
							return false;
						
						end
						
						--[[self.buttons[k].hover = false;
						self.bIsOpen = false;]]--
						self.cAlpha = 255;
						self.alphaChange = -1 * self.ALPHA_THRESHOLD;
						return false;
					
					end
				
				end
				
				if( self.bIsOpen and self:IsMouseOver( aX, aY, self.changeChars ) ) then
				
					triggerServerEvent( "onCharactersRequest", self.player, self.player ); 
					
					self.cAlpha = 255;
					self.alphaChange = -3 * self.ALPHA_THRESHOLD;
				
				end	
				
				if( self.bIsOpen ) then
				
					for k, v in ipairs( self.allElems ) do
					
						if( self:IsMouseOver( aX, aY, v ) ) then
						
							return false;
						
						end
					
					end
				
					self.cAlpha = 255;
					self.alphaChange = -1 * self.ALPHA_THRESHOLD;
				
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
			
				self:DrawBack( );
				self:DrawTop( );
				self:DrawButtons( );
				
				-- Draw Center Text
				dxDrawText( "Mängimise jätkamiseks kliki tühjale ekraaniosale", 0, self.sy - 80, self.sx, self.sy - 3, self.alphaW, 0.9, "default-bold", "center", "bottom", true, true, true );
					
			
			elseif( isCursorShowing( ) and not self.inCharSelection ) then
			
				local mx, my, wx, wy, wz = getCursorPosition( );
				if( my > 0.95 ) then
				
					self.bIsOpen = true;
					self.isShowing = true;
					self.cAlpha = 0;
					self.alphaChange = 1 * self.ALPHA_THRESHOLD;
				
				end
			
			end
		
		end
	
	);

end

function commas (num)
  assert (type (num) == "number" or
          type (num) == "string")
  
  local result = ""

  -- split number into 3 parts, eg. -1234.545e22
  -- sign = + or -
  -- before = 1234
  -- after = .545e22

  local sign, before, after =
    string.match (tostring (num), "^([%+%-]?)(%d*)(%.?.*)$")

  -- pull out batches of 3 digits from the end, put a comma before them

  while string.len (before) > 3 do
    result = "," .. string.sub (before, -3, -1) .. result
    before = string.sub (before, 1, -4)  -- remove last 3 digits
  end -- while

  -- we want the original sign, any left-over digits, the comma part,
  -- and the stuff after the decimal point, if any
  return sign .. before .. result .. after

end -- function commas

function PhoenixTab:OnShow( )

	self.inCharSelection = ( getElementData( self.player, "isInCharSelection" ) );
	outputDebugString( tostring( self.inCharSelection ) );
	
	-- Update char data...
	self.charName = getPlayerNametagText( self.player );
	self.charAge = getElementData( self.player, "Character.age" );
	
	self.charLevel = getElementData( self.player, "Skill.MYCHAR" );
	if( not self.charLevel ) then self.charLevel = "0"; end	
	self.charLevel = tostring( self.charLevel );
	
	local money = getPlayerMoney( self.player );
	if( not money ) then money = 0; end
	
	self.charMoney = commas( tostring( money ) ) .. " .-";
	
	self.skinImg = getElementModel( self.player );

end

function PhoenixTab:cacheFiles( )

	local oW = tocolor( 0, 0, 0, 0 );
	local tbl = { "images/bottom_open.png", "images/bottom_closed.png", "images/top_closed.png", "images/top_open.png", "images/karakterid.png", "images/s6brad.png", "images/abi.png", "images/s6numid.png", "images/seaded.png", "images/karakterid_hover.png", "images/s6brad_hover.png", "images/abi_hover.png", "images/s6numid_hover.png", "images/seaded_hover.png" };
	for k,v in ipairs( tbl ) do dxDrawImage( 0, 0, 0, 0, v, 0, 0, 0, oW ); end

end

theTab = PhoenixTab:new( );
theTab:cacheFiles( );
theTab:DoEvents( );

function onTimer( )

	theTab.inCharSelection = getElementData( theTab.player, "isInCharSelection" );

end
setTimer( onTimer, 3000, 0 );