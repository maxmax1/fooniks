PlayerOffer = {

	pTable = { },
	
	offers = { },
	
	cIndex = 1

};

function PlayerOffer:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	return o;

end

function PlayerOffer:Cancel( offerId, thePlayer )

	if( self.offers[offerId] ) then
	
		if( self.offers[offerId].fromPlayer == thePlayer ) then
		
			triggerClientEvent( self.offers[offerId].toPlayer, "unsetClientOffer", self.offers[offerId].toPlayer );
			
			if( self.offers[offerId].fromPlayer ) 	then self.pTable[self.offers[offerId].fromPlayer] = nil; end
			if( self.offers[offerId].toPlayer ) 	then self.pTable[self.offers[offerId].toPlayer] = nil; end
			
			self.offers[offerId].fromPlayer = nil;
			self.offers[offerId].toPlayer = nil;
			
			self.offers[offerId] = nil;
		
		else
		
			triggerClientEvent( self.offers[offerId].fromPlayer, "unsetClientOffer", self.offers[offerId].fromPlayer );
			
			if( self.offers[offerId].fromPlayer ) 	then self.pTable[self.offers[offerId].fromPlayer] = nil; end
			if( self.offers[offerId].toPlayer ) 	then self.pTable[self.offers[offerId].toPlayer] = nil; end
			
			self.offers[offerId].fromPlayer = nil;
			self.offers[offerId].toPlayer = nil;
			
			self.offers[offerId] = nil;
		
		end
	
	end

end

function PlayerOffer:Add( from, to, maxdistance, toStr, fromStr, retEvent )

	self.offers[cIndex] = { };
	self.offers[cIndex].fromPlayer = from;
	self.offers[cIndex].toPlayer = to;
	self.offers[cIndex].distance = tonumber( maxdistance );
	self.offers[cIndex].event = retEvent;
	
	self.pTable[from] = cIndex;
	self.pTable[to] = cIndex;
	
	cIndex = cIndex + 1; 
	
	triggerClientEvent( from, "setClientOffer", from, fromStr );
	triggerClientEvent( to, "setClientOffer", to, toStr );

end

function PlayerOffer:Trigger( offerId )

	if( self.offers[offerId] ) then
	
		if( self.offers[offerId].fromPlayer and self.offers[offerId].toPlayer ) then
		
			local x1, y1, z1 = getElementPosition( self.offers[offerId].fromPlayer );
			local x2, y2, z2 = getElementPosition( self.offers[offerId].toPlayer );
			
			if( self.offers[offerId].distance and self.offers[offerId].distance < getDistanceBetweenPoints3D( x1, y1, z1, x2, y2, z2 ) ) then
			
				exports.phoenix_Chat:OocInfo( self.offers[offerId].fromPlayer, "Sa oled liiga kaugel." );
				exports.phoenix_Chat:OocInfo( self.offers[offerId].toPlayer, "Sa oled pakkujast liiga kaugel." );
				return false;
			
			end
			
			triggerServerEvent( self.offers[offerId].event, getRootElement( ), self.offers[offerId].fromPlayer, self.offers[offerId].toPlayer );
			
			return true;
		
		end
	
	end	

end

function PlayerOffer:doEvents( )

	addEvent( "onOfferResponse", true );
	addEventHandler( "onOfferResponse", getRootElement( ),
	
		function ( accepted )
		
			if( client ) then
			
				-- self:HandleResponce( );
				if( self.pTable[client] and self.offers[self.pTable[client]] ) then
				
					if( self.offers[self.pTable[client]].fromPlayer and self.offers[self.pTable[client]].fromPlayer == client ) then
					
						-- Responce by sender. Cancel everything if wanted to cancel...
						if( not accepted ) then
						
							return true;
						
						else
						
							return self:Cancel( self.pTable[client], client );
						
						end
					
					elseif( self.offers[self.pTable[client]].toPlayer and self.offers[self.pTable[client]].toPlayer == client ) then
					
						if( accepted ) then
						
							self:Trigger( self.pTable[client] ); -- needs to check maxdistance...
						
						end
						
						return self:Cancel( self.pTable[client], client );
					
					end
				
				end
			
			end
		
		end
	
	);

end
