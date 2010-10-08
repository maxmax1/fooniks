AdCreator = {

	Shown = false,
	
	gui = { },
	
	Back = { 0, 0, 0 },
	Txt = { 255, 255, 255 },
	
	Text = "SISESTA TEKST",
	Index = -1,
	
	rootElement = nil,
	thePlayer = nil

};

function AdCreator:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	self.rootElement = getRootElement( );
	self.thePlayer = getLocalPlayer( );
	
	return o;

end

function AdCreator:build_Form()
	
	self.gui = {}
	
	local screenWidth, screenHeight = guiGetScreenSize()
	local windowWidth, windowHeight = 400, 315
	local left = screenWidth/2 - windowWidth/2
	local top = screenHeight/2 - windowHeight/2
	self.gui["_root"] = guiCreateWindow(left, top, windowWidth, windowHeight, "Loo Reklaam", false )
	
	guiWindowSetSizable(self.gui["_root"], false)
	
	self.gui["label"] = guiCreateLabel( .0275, .0825, .945, .0507, "Loo Reklaam", true, self.gui["_root"])
	guiLabelSetHorizontalAlign(self.gui["label"], "left", false)
	guiLabelSetVerticalAlign(self.gui["label"], "center")
	
	-- self.gui["scrollArea"] = guiCreateScrollPane( .0275, .1523, .945, .3269, true, self.gui["_root"])
	
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
	
	self.gui["theText"] = guiCreateMemo( .0275, .6984, .9450, .1700, "SISESTA TEKST", true, self.gui["_root"]);	
	addEventHandler( "onClientGUIChanged", self.gui["theText"], function ( elem ) self.Text = guiGetText( elem ) or "MINGI JAMA!"; end );
		
	self.gui["acceptB"] = guiCreateButton( .5825, .8888, .1875, .0761, "OK", true, self.gui["_root"])
	
	self.gui["cancelB"] = guiCreateButton( .785, .8888, .1875, .0761, "KATKESTA", true, self.gui["_root"])
	
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
			
			-- TriggerServerEvent and take money...
			triggerServerEvent( "onAdBoardDrawn", self.thePlayer, self.Index, self.Text, self.Back, self.Txt );
			
			self:ShowHide( false );
		
		end
	
	);	
	
	guiSetVisible( self.gui["_root"], false );
	
end

function AdCreator:UpdateColor( theElem, theTbl, theKey )

	theTbl[theKey] = 255 * ( guiScrollBarGetScrollPosition( theElem ) / 100 );

end

function AdCreator:ShowHide( show )

	if( show and not self.Shown ) then
	
		addEventHandler( "onClientRender", self.rootElement, onDraw );
		self.Shown = true;
		guiSetVisible( self.gui["_root"], true );
		guiSetInputEnabled( true );
	
	elseif( not show and self.Shown ) then
	
		removeEventHandler( "onClientRender", self.rootElement, onDraw );
		self.Shown = false;
		guiSetVisible( self.gui["_root"], false );
		guiSetInputEnabled( false );
	
	end

end

function AdCreator:OnDraw( )

	if( self.Shown ) then
	
		local x, y = guiGetPosition( self.gui["_root"], false );
		local w, h = guiGetSize( self.gui["_root"], false );
		
		h = h * 0.3;
		x = x + 5;
		y = y + 45;
		w = w - 10;
		
		local bCol = tocolor( self.Back[1], self.Back[2], self.Back[3] );
		local tCol = tocolor( self.Txt[1], self.Txt[2], self.Txt[3] );
		
		dxDrawRectangle( x, y, w, h, bCol, true );
		dxDrawText( self.Text, x+5, y+5, x+w-10, y+h-10, tCol, 1.0, "arial", "left", "top", true, true, true );
	
	end

end

function onDraw( )

	theCreator:OnDraw( );

end

theCreator = AdCreator:new();
theCreator:build_Form();

addEvent( "onAdBoardDraw", true );
addEventHandler( "onAdBoardDraw", getRootElement( ),

	function ( theAd )
	
		if( not theCreator.Shown ) then
		
			theCreator.Index = theAd;
			theCreator:ShowHide( true );
		
		end
	
	end

);
