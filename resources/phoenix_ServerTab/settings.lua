ClientSettings = {

	window = nil,
	sPane = nil,
	sButton = nil,
	qButton = nil,
	
	yPos = 0.05,
	
	sElements = { }

};

function ClientSettings:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	return o;

end

function ClientSettings:Init( )

	self.window = guiCreateWindow( 0.375, 0.2, 0.25, 0.6, "Seaded", true );
	
	self.sPane = guiCreateScrollPane( 0.05, 0.1, 0.9, 0.8, true, self.window );
	
	self.sButton = guiCreateButton( 0.575, 0.900, 0.2, 0.1, "Salvesta", true, self.window );
	self.qButton = guiCreateButton( 0.800, 0.900, 0.2, 0.1, "Katkesta", true, self.window );
	
	addEventHandler( "onClientGUIClick", self.sButton,
	
		function ( button, state )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			if( source ~= self.sButton ) then return false; end
			
			guiSetVisible( self.window, false );
			
			self:Save( );
			
			triggerEvent( "onClientCloseSettings", getLocalPlayer( ) );
		
		end
	
	);
	
	addEventHandler( "onClientGUIClick", self.qButton,
	
		function ( button, state )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			if( source ~= self.qButton ) then return false; end
			
			guiSetVisible( self.window, false );
			
			triggerEvent( "onClientCloseSettings", getLocalPlayer( ) );
		
		end
	
	);
	
	guiSetVisible( self.window, false );

end

function ClientSettings:Add( cookie, label, sType, aValues, func )

	local cValue = tonumber( exports.cookies:Cookie( cookie ) );
	local found = false;
		
	for k,v in ipairs( aValues.vals ) do
	
		if( cValue and k == cValue ) then found = true; break; end
	
	end
	if( not found ) then
	
		cValue = aValues.default;
	
	end
	
	self.sElements[cookie] = { };
	self.sElements[cookie].theType = sType;
	self.sElements[cookie].value = cValue;
	self.sElements[cookie].values = { };
	self.sElements[cookie].theFunc = func;
	
	self.sElements[cookie].label = guiCreateLabel( 0.05, self.yPos + 0.01, 0.4, 0.07, label, true, self.sPane );
	
	if( sType == "combobox" ) then
	
		self.sElements[cookie].element = guiCreateComboBox( 0.5, self.yPos, 0.4, 0.07, " ", true, self.sPane );
		for k, v in pairs( aValues.vals ) do
		
			self.sElements[cookie].values[k] = v.rval;
			
			local val = guiComboBoxAddItem( self.sElements[cookie].element, v.lbl );
			if( k == cValue ) then
			
				guiComboBoxSetSelected( self.sElements[cookie].element, val );
			
			end
		
		end
	
	end
	
	self.yPos = self.yPos + 0.1;

end

function ClientSettings:Show( hide )

	guiSetVisible( self.window, not hide );

end

function ClientSettings:Save( apply )

	for k, v in pairs( self.sElements ) do
	
		local nVal = false;
		if( v.theType == "combobox" ) then
		
			local row = guiComboBoxGetSelected( v.element );
			if( row and row ~= -1 ) then
			
				nVal = row + 1;
			
			end
		
		end
		
		if( nVal ) then
		
			if( not apply ) then exports.cookies:Cookie( k, nVal ); end
			if( v.theFunc ) then v.theFunc( v.values[nVal] ); end
			self.sElements[k].value = nVal;
		
		end
	
	end

end

cSettings = ClientSettings:new( );
cSettings:Init( );

local blur = { };
blur.vals = { };
blur.default = 3;

blur.vals[1] = { };
blur.vals[1].lbl = "Pole";
blur.vals[1].rval = 0;

blur.vals[2] = { };
blur.vals[2].lbl = "Natuke";
blur.vals[2].rval = 15;

blur.vals[3] = { };
blur.vals[3].lbl = "Keskmiselt";
blur.vals[3].rval = 36;

blur.vals[4] = { };
blur.vals[4].lbl = "Palju";
blur.vals[4].rval = 150;

cSettings:Add( "blurlevel", "Udu Tase", "combobox", blur, setBlurLevel );

local motd = { };
motd.vals = { };
motd.default = 2;

motd.vals[1] = { };
motd.vals[1].lbl = "Ei";
motd.vals[1].rval = 0;

motd.vals[2] = { };
motd.vals[2].lbl = "Jah";
motd.vals[2].rval = 1;

cSettings:Add( "showmotd", "Kuva abitekstid", "combobox", motd, false );

cSettings:Save( true ); -- Apply

-- cSettings:Show( );
ClientSettings = {

	window = nil,
	sPane = nil,
	sButton = nil,
	qButton = nil,
	
	yPos = 0.05,
	
	sElements = { }

};

function ClientSettings:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	return o;

end

function ClientSettings:Init( )

	self.window = guiCreateWindow( 0.375, 0.2, 0.25, 0.6, "Seaded", true );
	
	self.sPane = guiCreateScrollPane( 0.05, 0.1, 0.9, 0.8, true, self.window );
	
	self.sButton = guiCreateButton( 0.575, 0.900, 0.2, 0.1, "Salvesta", true, self.window );
	self.qButton = guiCreateButton( 0.800, 0.900, 0.2, 0.1, "Katkesta", true, self.window );
	
	addEventHandler( "onClientGUIClick", self.sButton,
	
		function ( button, state )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			if( source ~= self.sButton ) then return false; end
			
			guiSetVisible( self.window, false );
			
			self:Save( );
			
			triggerEvent( "onClientCloseSettings", getLocalPlayer( ) );
		
		end
	
	);
	
	addEventHandler( "onClientGUIClick", self.qButton,
	
		function ( button, state )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			if( source ~= self.qButton ) then return false; end
			
			guiSetVisible( self.window, false );
			
			triggerEvent( "onClientCloseSettings", getLocalPlayer( ) );
		
		end
	
	);
	
	guiSetVisible( self.window, false );

end

function ClientSettings:Add( cookie, label, sType, aValues, func )

	local cValue = tonumber( exports.cookies:Cookie( cookie ) );
	local found = false;
		
	for k,v in ipairs( aValues.vals ) do
	
		if( cValue and k == cValue ) then found = true; break; end
	
	end
	if( not found ) then
	
		cValue = aValues.default;
	
	end
	
	self.sElements[cookie] = { };
	self.sElements[cookie].theType = sType;
	self.sElements[cookie].value = cValue;
	self.sElements[cookie].values = { };
	self.sElements[cookie].theFunc = func;
	
	self.sElements[cookie].label = guiCreateLabel( 0.05, self.yPos + 0.01, 0.4, 0.07, label, true, self.sPane );
	
	if( sType == "combobox" ) then
	
		self.sElements[cookie].element = guiCreateComboBox( 0.5, self.yPos, 0.4, 0.07, " ", true, self.sPane );
		for k, v in pairs( aValues.vals ) do
		
			self.sElements[cookie].values[k] = v.rval;
			
			local val = guiComboBoxAddItem( self.sElements[cookie].element, v.lbl );
			if( k == cValue ) then
			
				guiComboBoxSetSelected( self.sElements[cookie].element, val );
			
			end
		
		end
	
	end
	
	self.yPos = self.yPos + 0.1;

end

function ClientSettings:Show( hide )

	guiSetVisible( self.window, not hide );

end

function ClientSettings:Save( apply )

	for k, v in pairs( self.sElements ) do
	
		local nVal = false;
		if( v.theType == "combobox" ) then
		
			local row = guiComboBoxGetSelected( v.element );
			if( row and row ~= -1 ) then
			
				nVal = row + 1;
			
			end
		
		end
		
		if( nVal ) then
		
			if( not apply ) then exports.cookies:Cookie( k, nVal ); end
			if( v.theFunc ) then v.theFunc( v.values[nVal] ); end
			self.sElements[k].value = nVal;
		
		end
	
	end

end

cSettings = ClientSettings:new( );
cSettings:Init( );

local blur = { };
blur.vals = { };
blur.default = 3;

blur.vals[1] = { };
blur.vals[1].lbl = "Pole";
blur.vals[1].rval = 0;

blur.vals[2] = { };
blur.vals[2].lbl = "Natuke";
blur.vals[2].rval = 15;

blur.vals[3] = { };
blur.vals[3].lbl = "Keskmiselt";
blur.vals[3].rval = 36;

blur.vals[4] = { };
blur.vals[4].lbl = "Palju";
blur.vals[4].rval = 150;

cSettings:Add( "blurlevel", "Udu Tase", "combobox", blur, setBlurLevel );

local motd = { };
motd.vals = { };
motd.default = 2;

motd.vals[1] = { };
motd.vals[1].lbl = "Ei";
motd.vals[1].rval = 0;

motd.vals[2] = { };
motd.vals[2].lbl = "Jah";
motd.vals[2].rval = 1;

cSettings:Add( "showmotd", "Kuva abitekstid", "combobox", motd, false );

cSettings:Save( true ); -- Apply

-- cSettings:Show( );