LockPick = {

	rootElement,
	thePlayer,
		
	sx, sy,
	
	scale, 
	
	position = { },
	pinPos = { },
	tipPos = { },
	
	numPins = 1,
	pinAngs = { },
	
	pickAng = 0,
	
	pickLevel = 0

};

function onDraw( )

	theLock:onDraw( );

end

function LockPick:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	self.rootElement = getRootElement( );
	self.thePlayer = getLocalPlayer( );
	self.sx, self.sy = guiGetScreenSize( );
	
	self:Calculate( );
	
	return o;

end

function LockPick:Calculate( )

	self.scale = ( self.sx / 1366 );
	
	-- Position
	self.position[1] = self.sx - ( 367 * self.scale ) - ( 50 * self.scale );
	self.position[2] = self.sy - ( 116 * self.scale ) - ( 50 * self.scale );
	self.position[3] = ( 367 * self.scale );
	self.position[4] = ( 116 * self.scale );
	
	-- pinPos
	self.pinPos[1] = { self.position[1] + ( 324 * self.scale ), self.position[2] + ( 19 * self.scale ), ( 10 * self.scale ), ( 52 * self.scale ) };
	self.pinPos[2] = { self.position[1] + ( 294 * self.scale ), self.position[2] + ( 19 * self.scale ), ( 10 * self.scale ), ( 52 * self.scale ) };
	self.pinPos[3] = { self.position[1] + ( 264 * self.scale ), self.position[2] + ( 19 * self.scale ), ( 10 * self.scale ), ( 52 * self.scale ) };
	self.pinPos[4] = { self.position[1] + ( 234 * self.scale ), self.position[2] + ( 19 * self.scale ), ( 10 * self.scale ), ( 52 * self.scale ) };
	self.pinPos[5] = { self.position[1] + ( 204 * self.scale ), self.position[2] + ( 19 * self.scale ), ( 10 * self.scale ), ( 52 * self.scale ) };
	self.pinPos[6] = { self.position[1] + ( 174 * self.scale ), self.position[2] + ( 19 * self.scale ), ( 10 * self.scale ), ( 52 * self.scale ) };
	self.pinPos[7] = { self.position[1] + ( 144 * self.scale ), self.position[2] + ( 19 * self.scale ), ( 10 * self.scale ), ( 52 * self.scale ) };
	
	-- tipPos
	
	self.tipPos[1] = { 331, -71.5 };
	self.tipPos[2] = { 301, -71.5 };
	self.tipPos[3] = { 271, -71.5 };
	self.tipPos[4] = { 241, -71.5 };
	self.tipPos[5] = { 211, -71.5 };
	self.tipPos[6] = { 181, -71.5 };
	self.tipPos[7] = { 151, -71.5 };

end

function LockPick:GetTipPos( )

	local a = findRotation( 0, 0, self.tipPos[self.pickLevel+1][1], self.tipPos[self.pickLevel+1][2] );
	a =  math.rad(-1 * ( a + self.pickAng ) );
	local dist = getDistanceBetweenPoints2D( 0, 0, self.tipPos[self.pickLevel+1][1], self.tipPos[self.pickLevel+1][2] );
	return math.sin(a) * dist, math.cos(a) * dist;

end

function LockPick:onDraw( )

	dxDrawImage( self.position[1], self.position[2], self.position[3], self.position[4], "jacking/lock.png" );
	dxDrawImage( self.position[1] - ( self.pickLevel * ( self.scale * 30 ) ), self.position[2], self.position[3], self.position[4], "jacking/pick.png", self.pickAng );
	
	local tipX, tipY = self:GetTipPos( );
		
	for i = 1, self.numPins,1 do
	
		local offY = 0;
	
		if( i - 1 == self.pickLevel ) then
		
			offY = self.scale * ( ( -1 * tipY ) - 71.5 );
			
			offY = 15 * ( offY / 32 );
		
		end
		
		dxDrawImage( self.pinPos[i][1], self.pinPos[i][2] - offY, self.pinPos[i][3], self.pinPos[i][4], "jacking/pin.png" );
		if( i - 1 == self.pickLevel and self.pickAng == self.pinAngs[self.pickLevel + 1] ) then dxDrawRectangle( self.pinPos[i][1], self.pinPos[i][2] - offY, self.pinPos[i][3], self.pinPos[i][4], tocolor( 0, 255, 0, 100 ) ); end
	
	end

end

function LockPick:onTimer( )

	if( getKeyState( "w" ) ) then
	
		if( self.pickAng > -6 ) then self.pickAng = self.pickAng - 1; end
	
	else
	
		if( self.pickAng < 0 ) then self.pickAng = self.pickAng + 1; end
	
	end

end

function LockPick:OnWrenchUse( )

	self.useKey = true;
	
	if( self.pickAng == self.pinAngs[self.pickLevel + 1] ) then
	
		self:LevelUp( );
	
	else
	
		self:LevelDown( );
	
	end

end

function LockPick:LevelUp( )

	if( self.pickLevel + 2 > self.numPins ) then
	
		-- Done, lets unlock...
		triggerServerEvent( "onLockPickComplete", self.thePlayer, true, self.theVehicle );
		self:Hide( );
	
	else
	
		self.pickLevel = self.pickLevel + 1;
		self.pickAng = 0;
	
	end
	
	self.useKey = not self.useKey;

end

function LockPick:LevelDown( )

	if( self.pickLevel - 1 < 0 ) then
	
		-- Failed, lets end...
		triggerServerEvent( "onLockPickComplete", self.thePlayer, false, self.theVehicle );
		self:Hide( );
	
	else
	
		self.pickLevel = self.pickLevel - 1;
		self.pickAng = 0;
	
	end
	
	self.useKey = not self.useKey;	

end

function LockPick:Show( )

	if( self.Timer ) then return false; end
	
	self.pickAng = 0;
	self.pickLevel = 0;
	
	addEventHandler( "onClientRender", self.rootElement, onDraw );
	self.Timer = setTimer( function () self:onTimer( ); end, 100, 0 );

end

function LockPick:Hide( )

	removeEventHandler( "onClientRender", self.rootElement, onDraw );
	killTimer( self.Timer );
	self.Timer = nil;

end

function LockPick:SetPins( num )

	if( num < 1 ) then num = 1; elseif( num > 7 ) then num = 7; end
	self.numPins = num;
	
	for i = 1, self.numPins,1 do
	
		self.pinAngs[i] = math.random( -6, -1 );
	
	end

end

function findRotation(x1,y1,x2,y2)
 
  local t = -math.deg(math.atan2(x2-x1,y2-y1))
  if t < 0 then t = t + 360 end;
  return t;
 
end

function setElementToFaceElement( theElem1, theElem2, x1, y1, z1, x2, y2, z2 )

	if( not x1 ) then
	
		x1, y1, z1 = getElementPosition( theElem1 );
	
	end
	if( not x2 ) then
	
		x2, y2, z2 = getElementPosition( theElem2 );
	
	end
	
	local angle = findRotation( x1, y1, x2, y2 );
	
	setElementRotation( theElem1, 0, 0, angle );

end

function onWrenchStartUse( )

	if( theLock.Timer ) then
	
		theLock:OnWrenchUse( );
	
	else

		local thePlayer = getLocalPlayer( );
		local x, y, z = getElementPosition( thePlayer );
		local colShape = createColCircle( x, y, 5 );
		local elems = getElementsByType( "vehicle", getRootElement( ), true );
		
		local minDistance = 2;
		local closestElem = nil;
		for k, v in ipairs( elems ) do
		
			local vX, vY, vZ = getElementPosition( v );
			if( isLineOfSightClear( x, y, z, vX, vY, vZ, true, false ) ) then
				
				local dist = getDistanceBetweenPoints3D( x, y, z, vX, vY, vZ );
				if( not minDistance or minDistance > dist ) then minDistance = dist; closestElem = v; end
			
			end
		
		end
		
		if( closestElem ) then
		
			if( not isVehicleLocked( closestElem ) ) then
			
				exports.phoenix_Chat:OocInfo( "Auto pole lukus..." );
				return false;
			
			end
		
			local itemSlot = exports.phoenix_Pockets:getSlotByItem( 17 );
			if( not itemSlot ) then
			
				exports.phoenix_Chat:OocInfo( "Sul pole muukrauda!" );
				return false;
			
			end
		
			triggerServerEvent( "onLockPickStart", thePlayer, closestElem );
			
			local vehSecurityLevel = tonumber( getElementData( closestElem, "vLockLevel" ) ) or 1;
			theLock.theVehicle = closestElem;
			theLock:SetPins( vehSecurityLevel );
			theLock:Show( );
		
		end
	
	end

end

theLock = LockPick:new( );
bindKey( "e", "up", onWrenchStartUse );
