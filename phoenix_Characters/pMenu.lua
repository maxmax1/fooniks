--[[

	PlayerMenu server
	
		vars
		
			allMenuItems = { uniqueid => command } 
				
				-- command = { label => "Vägista", event => "", eType => "0 = server | 1 = client" }
		
		events
		
		functions
		
			Init -- Call to start system
			DoEvents -- Registres all events
			
			Sync( thePlayer );
			
			AddMenuItem( uniqueid, lbl, eve, eTyp );
			RemoveMenuItem( uniqueid );
		
		exported macros
		
			addMenuItem => AddMenuItem
			removeMenuItem => RemoveMenuItem
	
	PlayerMenu client
	
		vars
		
			allMenuItems = { uniqueid => command } 
				
				-- command = { label => "Vägista", event => "", eType => "0 = server | 1 = client" }
		
			isShowing = true | false
			
			rootElement = getRootElement( );
			thePlayer = getLocalPlayer( );			
			sx, sy = guiGetScreenSize( );
			
			scale = 1.0
		
		events
		
			onPmSync
		
		functions
		
			ShowPlayerMenu( thePlayer );
		

]]--

PlayerMenu = {

	rootElement = nil,
	player = nil,
	
	sx,
	sy,
	
	isShowing = false,
	
	scale = 1.0,
	
	allMenuItems = { },
	
};

function PlayerMenu:new( o )

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

function PlayerMenu:Calculate( )

	self.pad = 5 * self.scale;

	self.itemH = 17 * self.scale;
	
	self.position = { };
	self.position[1] = 0;
	self.position[2] = 0;
	self.position[3] = 75 * self.scale + ( 2 * self.pad );
	self.position[4] = ( 2 * self.pad ) + ( ( #self.allMenuItems + 1 ) * self.itemH );

end