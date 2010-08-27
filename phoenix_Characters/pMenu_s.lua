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
		
		events
		
			onPmSync
		
		functions
		
			ShowPlayerMenu( thePlayer );
		

]]--

PlayerMenu = {

	allMenuItems = { }

};

function PlayerMenu:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	return o;

end

function PlayerMenu:Init( )

	self:DoEvents( );

end

function PlayerMenu:DoEvents( )


end

function PlayerMenu:Sync( theElement )

	if( not theElement ) then theElement = getRootElement( ); end

	triggerClientEvent( theElement, "onPmSync", theElement, self.allMenuItems );

end

function PlayerMenu:AddMenuItem( uniqueid, lbl, eve, eTyp )

	if( uniqueid and lbl and eve and eTyp ) then
	
		if( not self:allMenuItems[uniqueid] ) then
		
			eTyp = tostring( eTyp );
			if( eTyp == "1" or eTyp == "client" ) then
			
				eTyp = 1;
			
			else
			
				eTyp = 0;
				
			end
		
			self:allMenuItems[uniqueid] = { };
			self:allMenuItems[uniqueid].label = lbl;
			self:allMenuItems[uniqueid].event = eve;
			self:allMenuItems[uniqueid].eType = eTyp;
			self:Sync( );
		
		end
	
	else
	
		outputDebugString( "PlayerMenu:AddMenuItem: Bad command table.", 2 );
	
	end

end

function PlayerMenu:RemoveMenuItem( uniqueid )

	if( self:allMenuItems[uniqueid] ) then
	
		self:allMenuItems[uniqueid] = nil;
		self:Sync( );
	
	end

end