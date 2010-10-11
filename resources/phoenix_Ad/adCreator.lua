-- TODO: Element Like tekst adding( drag an TextLabel from builder and when it's clicked you can edit it's properties.
-- Bigger window, better layout.
-- Server will get the background color.

AdCreator = {

	Shown = false,
	
	gui = { },
	widgets = { },
	
	Back = { 0, 0, 0 },
	Txt = { 255, 255, 255 },
	
	Text = "SISESTA TEKST",
	Index = -1,
	
	imgH = 128,
	imgW = 256,
	
	rootElement = nil,
	thePlayer = nil,
	
	DragElem = nil,
	selElem = nil,
	
	textElements = { },

};

function AdCreator:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	self.rootElement = getRootElement( );
	self.thePlayer = getLocalPlayer( );
	
	self.sx, self.sy = guiGetScreenSize( );
	
	return o;

end

function AdCreator:build_Form()
	
	self.gui = {}
	
	local screenWidth, screenHeight = guiGetScreenSize()
	local windowWidth, windowHeight = 800, 630
	local left = screenWidth/2 - windowWidth/2
	local top = screenHeight/2 - windowHeight/2
	self.gui["_root"] = guiCreateWindow(left, top, windowWidth, windowHeight, "Loo Reklaam", false )
	
	guiWindowSetSizable(self.gui["_root"], false)
	--[[
	self.gui["label_3"] = guiCreateLabel( .0275, .4984, .465, .0507, "Taust: ", true, self.gui["_root"])
	guiLabelSetHorizontalAlign(self.gui["label_3"], "left", false)
	guiLabelSetVerticalAlign(self.gui["label_3"], "center")

	self.gui["bgR"] =  guiCreateScrollBar(0.2275, .4884, 0.2275, 0.0761, true, true, self.gui["_root"])
	guiScrollBarSetScrollPosition( self.gui["bgR"], 0 )
	
	self.gui["bgG"] =  guiCreateScrollBar(0.47, .4884, 0.2275, 0.0761, true, true, self.gui["_root"])
	guiScrollBarSetScrollPosition( self.gui["bgG"], 0 )
	
	self.gui["bgB"] =  guiCreateScrollBar(0.7125, .4884, 0.2275, 0.0761, true, true, self.gui["_root"])
	guiScrollBarSetScrollPosition( self.gui["bgB"], 0 )	
	
	self.gui["label_2"] = guiCreateLabel( .0275, .5984, .465, .0507, "Tekst:", true, self.gui["_root"])
	guiLabelSetHorizontalAlign(self.gui["label_2"], "left", false)
	guiLabelSetVerticalAlign(self.gui["label_2"], "center")
	
	self.gui["txtR"] =  guiCreateScrollBar(0.2275, .5884, 0.2275, 0.0761, true, true, self.gui["_root"])
	guiScrollBarSetScrollPosition( self.gui["txtR"], 100 )
	
	self.gui["txtG"] =  guiCreateScrollBar(0.47, .5884, 0.2275, 0.0761, true, true, self.gui["_root"])
	guiScrollBarSetScrollPosition( self.gui["txtG"], 100 )
	
	self.gui["txtB"] =  guiCreateScrollBar(0.7125, .5884, 0.2275, 0.0761, true, true, self.gui["_root"])
	guiScrollBarSetScrollPosition( self.gui["txtB"], 100 )
	
	addEventHandler( "onClientGUIScroll", self.gui["bgR"], function ( scrollElem ) self:UpdateColor( scrollElem, self.Back, 1 ); end );
	addEventHandler( "onClientGUIScroll", self.gui["bgG"], function ( scrollElem ) self:UpdateColor( scrollElem, self.Back, 2 ); end );
	addEventHandler( "onClientGUIScroll", self.gui["bgB"], function ( scrollElem ) self:UpdateColor( scrollElem, self.Back, 3 ); end );
	
	addEventHandler( "onClientGUIScroll", self.gui["txtR"], function ( scrollElem ) self:UpdateColor( scrollElem, self.Txt, 1 ); end );
	addEventHandler( "onClientGUIScroll", self.gui["txtG"], function ( scrollElem ) self:UpdateColor( scrollElem, self.Txt, 2 ); end );
	addEventHandler( "onClientGUIScroll", self.gui["txtB"], function ( scrollElem ) self:UpdateColor( scrollElem, self.Txt, 3 ); end );
			]]--
			
	self.gui["theText"] = guiCreateEdit( 0.015, .61, .55, .04, "SISESTA TEKST", true, self.gui["_root"]);	
	guiSetVisible( self.gui["theText"], false );
	addEventHandler( "onClientGUIChanged", self.gui["theText"], function ( elem ) if( self.selElem ) then self.textElements[self.selElem]["text"] = guiGetText( self.gui["theText"] ); end end );
	
	self.gui["bgR"] =  guiCreateScrollBar(0.16375, .549, 0.11375, 0.03805, true, true, self.gui["_root"])
	guiScrollBarSetScrollPosition( self.gui["bgR"], 0 );
	
	self.gui["bgG"] =  guiCreateScrollBar(0.2850, .549, 0.11375, 0.03805, true, true, self.gui["_root"])
	guiScrollBarSetScrollPosition( self.gui["bgG"], 0 );
	
	self.gui["bgB"] =  guiCreateScrollBar(0.40625, .549, 0.11375, 0.03805, true, true, self.gui["_root"])
	guiScrollBarSetScrollPosition( self.gui["bgB"], 0 );
	
	addEventHandler( "onClientGUIScroll", self.gui["bgR"], function ( scrollElem ) self:UpdateColor( scrollElem, 1 ); end );
	addEventHandler( "onClientGUIScroll", self.gui["bgG"], function ( scrollElem ) self:UpdateColor( scrollElem, 2 ); end );
	addEventHandler( "onClientGUIScroll", self.gui["bgB"], function ( scrollElem ) self:UpdateColor( scrollElem, 3 ); end );
	
	self.gui["grid"] = guiCreateGridList( .64, .52, .35, .35, true, self.gui["_root"] );
	guiGridListAddColumn( self.gui["grid"], "#", 0.2 );
	guiGridListAddColumn( self.gui["grid"], "Nimi", 0.7 );
	
	self.gui["acceptB"] = guiCreateButton( .7625, .93695, .09375, .03805, "OK", true, self.gui["_root"])
	
	self.gui["cancelB"] = guiCreateButton( .88125, .93695, .09375, .03805, "KATKESTA", true, self.gui["_root"])
	
	addEventHandler( "onClientGUIClick", self.gui["grid"], 

		function ( button, state )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			if( source ~= self.gui["grid"] ) then return false; end
			
			local selItem = guiGridListGetSelectedItem( self.gui["grid"] );
			if( selItem and selItem ~= -1 and ( not self.selElem or self.selElem-1 ~= selItem ) ) then
			
				self:UpdateSelection( selItem );
			
			elseif( selItem == -1 ) then
			
				self:UpdateSelection( nil );
			
			end
		
		end
	
	);	
	
	addEventHandler( "onClientGUIClick", self.gui["cancelB"], 

		function ( button, state )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			if( source ~= self.gui["cancelB"] ) then return false; end
			
			self:ShowHide( false );
		
		end
	
	);	
	addEventHandler( "onClientGUIClick", self.gui["acceptB"], 

		function ( button, state )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			if( source ~= self.gui["acceptB"] ) then return false; end
			
			-- TriggerServerEvent...	
			local theElements = { };
			local rScale = 1 / self.scale;
			for k, v in ipairs( self.textElements ) do
			
				table.insert( theElements, { ["type"] = v["type"], ["text"] = v["text"], ["col"] = { v["col"][1], v["col"][2], v["col"][3] }, ["pos"] = { v["pos"][1] * rScale, v["pos"][2] * rScale } } );
			
			end
			triggerServerEvent( "onAdBoardDrawn", self.thePlayer, self.Index, self.Back, theElements );
			
			self:ShowHide( false );
		
		end
	
	);	
	
	guiSetVisible( self.gui["_root"], false );
	
end

function AdCreator:UpdateColor( theElem, theKey )

	if( not self.selElem ) then
	
		self.Back[theKey] = 255 * ( guiScrollBarGetScrollPosition( theElem ) / 100 );
	
	else
	
		self.textElements[self.selElem]["col"][theKey] = 255 * ( guiScrollBarGetScrollPosition( theElem ) / 100 );
	
	end

end

function AdCreator:ShowHide( show )

	if( show and not self.Shown ) then
	
		addEventHandler( "onClientClick", theCreator.rootElement, onMyClick );
		addEventHandler( "onClientRender", self.rootElement, onDraw );
		self.Shown = true;
		guiSetVisible( self.gui["_root"], true );
		
		showCursor( true, false );
		toggleAllControls( false );
		setPedFrozen( self.thePlayer, true );
	
	elseif( not show and self.Shown ) then
	
		removeEventHandler( "onClientClick", self.rootElement, onMyClick );
		removeEventHandler( "onClientRender", self.rootElement, onDraw );
		self.Shown = false;
		guiSetVisible( self.gui["_root"], false );
		
		showCursor( false, false );
		toggleAllControls( true );
		setPedFrozen( self.thePlayer, false );
		
		triggerEvent( "resetAdShop", self.thePlayer );
	
	end

end

function AdCreator:IsMouseOver( mouseX, mouseY, eCords )

	return ( mouseX and mouseY and mouseX >= eCords[1] and mouseX <= eCords[1]+eCords[3] and mouseY >= eCords[2] and mouseY <= eCords[2]+eCords[4] );

end

function AdCreator:OnClick( aX, aY, state )

	--outputDebugString( "OnClick" );
	
	if( state == "up" ) then
	
		if( self.DragElem ) then
		
			self.DragElem = nil;
		
		elseif( self:IsMouseOver( aX, aY, self.widgets[1] ) ) then
		
			self:AddTextWidget( );
		
		end
	
	elseif( self:IsMouseOver( aX, aY, { self.imgPos[1], self.imgPos[2], self.imgPos[3] - self.imgPos[1], self.imgPos[4] - self.imgPos[2] } ) ) then
	
		for k, v in ipairs( self.textElements ) do
		
			local mX = self.imgPos[1] + v["pos"][1];
			local mY = self.imgPos[2] + v["pos"][2];
			
			local mW = mX + dxGetTextWidth( v["text"], self.scale, "arial" );
			local mH = mY + dxGetFontHeight( self.scale, "arial" );
			if( mW > self.imgPos[3] ) then mW = self.imgPos[3]; end
			if( mH > self.imgPos[4] ) then mH = self.imgPos[4]; end
			
			if( self:IsMouseOver( aX, aY, { mX, mY, mW - mX, mH - mY } ) ) then
			
				self.DragElem = k;
				self:UpdateSelection( k-1 );
				return true;
			
			end
		
		end
		
		self:UpdateSelection( nil );
	
	end

end

function AdCreator:OnDraw( )

	if( self.Shown ) then
	
		local x, y = guiGetPosition( self.gui["_root"], false );
		local w1, h1 = guiGetSize( self.gui["_root"], false );
		
		x = x + 5;
		y = y + 45;
		w = w1 - 300;
		
		self.scale = w / self.imgW;
		
		h = self.imgH * self.scale;
		
		-- Draw Widgets board.
		dxDrawRectangle( x + w + 5, y, 280, h, tocolor( 0, 0, 0, 170 ), true );
		--dxDrawRectangle( x + w + 5, y + h + 5, 280, h, tocolor( 0, 0, 0, 170 ), true );
		
		dxDrawText( "Lisa Element", x + w + 10, y + 5, x + w1, y + 75, tocolor( 255, 255, 255 ), 1.0, "default-bold", "left", "top", true, true, true );
		dxDrawText( "Hetke Elemendid", x + w + 10, y + h + 10, x + w1, y + h + 75, tocolor( 255, 255, 255 ), 1.0, "default-bold", "left", "top", true, true, true );
		
		local elemN = "Element: Taust\n\n\nVärv:";
		if( self.selElem and self.textElements[self.selElem] ) then elemN = "Element: " .. self.textElements[self.selElem]["type"] .. "\n\n\nVärv:"; end
		dxDrawText( elemN, x + 10, y + h + 10, x + w1, y + h + 75, tocolor( 255, 255, 255 ), 1.0, "default-bold", "left", "top", true, true, true );
		
		-- Draw widgets
		self.widgets[1] = { x + w + 10, y + 35, 32, 32, "textW.png" };
		
		for k, v in ipairs( self.widgets ) do
		
			dxDrawImage( self.widgets[1][1], self.widgets[1][2], self.widgets[1][3], self.widgets[1][4], self.widgets[1][5], 0, 0, 0, tocolor( 255, 255, 255 ), true );
		
		end
		
		-- Draw img background...
		local bCol = tocolor( self.Back[1], self.Back[2], self.Back[3] );
		dxDrawRectangle( x, y, w, h, bCol, true );
		
		-- Draw text widgets...
		
		self.imgPos = { x, y, x+w, y+h };
		local cX, cY = getCursorPosition( );
		
		if( cX and cY ) then
		
			cX = cX * self.sx;
			cY = cY * self.sy;
		
		end
		
		
		for k, v in ipairs( self.textElements ) do
		
			if( self.DragElem and k == self.DragElem ) then
			
				if( cX < self.imgPos[1] or cY < self.imgPos[2] ) then
				
					setCursorPosition( self.imgPos[1], self.imgPos[2] );
					cX = self.imgPos[1];
					cY = self.imgPos[2];
				
				elseif( cX > self.imgPos[3] or cY > self.imgPos[4] ) then
				
					self.textElements[k]["rem"] = true;
				
				end
				
				self.textElements[k]["pos"][1] = cX - x;
				self.textElements[k]["pos"][2] = cY - y;
			
			end
			
			local tCol = tocolor( v["col"][1], v["col"][2], v["col"][3] );
			
			local mX = self.imgPos[1] + v["pos"][1];
			local mY = self.imgPos[2] + v["pos"][2];
			
			local mW = mX + dxGetTextWidth( v["text"], self.scale, "arial" );
			local mH = mY + dxGetFontHeight( self.scale, "arial" );
			if( mW > self.imgPos[3] ) then mW = self.imgPos[3]; end
			if( mH > self.imgPos[4] ) then mH = self.imgPos[4]; end
			
			local borderAlpha = 0;
			if( k == self.selElem ) then borderAlpha = 255; end
			
			dxDrawTextWithBorder( v["text"] or "Sisesta text...", mX, mY, mW, mH, tCol, self.scale, "arial", true, tocolor( 255, 255, 255, borderAlpha ) );
		
		end
		
		local remSome = false;
		for k = #self.textElements,1,-1 do
		
			if( self.textElements[k]["rem"] ) then self.DragElem = nil; table.remove( self.textElements, k ); remSome = true; end
		
		end
		
		if( remSome ) then
		
			self:UpdateElems( );
			self:UpdateSelection( nil );
		
		end
	
	end

end

function dxDrawTextWithBorder( text, left, top, right, bottom, color, scale, font, postGui, bCol )

	dxDrawLine( left, top, right, top, bCol, 1, postGui );
	dxDrawLine( right, top, right, bottom, bCol, 1, postGui );
	dxDrawLine( right, bottom, left, bottom, bCol, 1, postGui );
	dxDrawLine( left, bottom, left, top, bCol, 1, postGui );
	
	dxDrawText( text, left, top, right, bottom, color, scale, font, "left", "top", true, false, postGui );

end

function AdCreator:AddTextWidget( )

	table.insert( self.textElements, { ["type"] = "TextElement", ["text"] = "TextElement", ["col"] = { 255, 255, 255 }, ["pos"] = { 5, 5 } } );
	self:UpdateElems( );

end

function AdCreator:UpdateElems( )

	guiGridListClear( self.gui["grid"] );
	for k, v in ipairs( self.textElements ) do
	
		local row = guiGridListAddRow( self.gui["grid"] );
		guiGridListSetItemText( self.gui["grid"], row, 1, tostring( k ), false, true );
		guiGridListSetItemText( self.gui["grid"], row, 2, v["type"], false, false );
	
	end

end

function AdCreator:UpdateSelection( itemId )

	local col = 1;
	if( not itemId ) then col = 0; end
	
	guiGridListSetSelectedItem( self.gui["grid"], itemId or 0, col );
	if( itemId ) then self.selElem = itemId+1; else self.selElem = nil; end
	
	--outputDebugString( "UpdateSelection: " .. tostring( itemId ) );
	
	-- Update the properties tab...
	if( not self.selElem ) then
	
		guiSetVisible( self.gui["theText"], false );
		
		guiScrollBarSetScrollPosition( self.gui["bgR"], ( self.Back[1] / 255 ) * 100 );
		guiScrollBarSetScrollPosition( self.gui["bgG"], ( self.Back[2] / 255 ) * 100 );
		guiScrollBarSetScrollPosition( self.gui["bgB"], ( self.Back[3] / 255 ) * 100 );
	
	else
	
		guiSetVisible( self.gui["theText"], true );
		guiSetText( self.gui["theText"], self.textElements[self.selElem]["text"] );
		
		guiScrollBarSetScrollPosition( self.gui["bgR"], ( self.textElements[self.selElem]["col"][1] / 255 ) * 100 );
		guiScrollBarSetScrollPosition( self.gui["bgG"], ( self.textElements[self.selElem]["col"][2] / 255 ) * 100 );
		guiScrollBarSetScrollPosition( self.gui["bgB"], ( self.textElements[self.selElem]["col"][3] / 255 ) * 100 );
	
	end

end

theCreator = AdCreator:new();
theCreator:build_Form();

function onDraw( )

	theCreator:OnDraw( );

end

function onMyClick( button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedWorld )

	if( button ~= "left" ) then return false; end
	theCreator:OnClick( absoluteX, absoluteY, state );

end

addEvent( "onAdBoardDraw", true );
addEventHandler( "onAdBoardDraw", getRootElement( ),

	function ( theAd, theW, theH )
	
		if( not theCreator.Shown and theAd and theW and theH ) then
		
			theCreator.Index = theAd;
			theCreator.imgH = tonumber( theH ) or 64;
			theCreator.imgW = tonumber( theW ) or 128;
			theCreator:ShowHide( true );
		
		end
	
	end

);

-- WTF is up with the onclientclick