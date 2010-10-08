 To3D = {
 
	thePoints = { }
 
 };

function To3D:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	return o;

end

function To3D:GetVelocity( x, y, z )

	if( not z ) then return math.sqrt( ( x ^ 2 ) + ( y ^ 2 ) ); else return math.sqrt( ( x ^ 2 ) + ( y ^ 2 ) + ( z ^ 2 ) ); end

end

function To3D:GetXYInDirectionOfPosition( direction, x, y, dist )

    local a = math.rad(-1 * direction)
    local dx = math.sin(a) * dist;
    local dy = math.cos(a) * dist;
    return x+dx, y+dy;

end

function To3D:Build( twoTable, throwAngle, baseElement )

	if( twoTable and type( twoTable ) == "table" and baseElement ) then
	
		local x, y, z = getElementPosition( baseElement );
		local angle = throwAngle;
		local range = getElementDistanceFromCentreOfMassToBaseOfModel( baseElement );
				
		local oldX = x;
		local oldY = y;
		local oldZ = z;	
		
		self.thePoints = { };
		local wantBreak = false;	
	
		for k, v in ipairs( twoTable ) do
		
			local tbl = { };
			tbl[1] = x;
			tbl[2] = y;
			tbl[3] = z;
			
			tbl[4], tbl[5] = self:GetXYInDirectionOfPosition( angle, x, y, v[1] );
			tbl[6] = z + v[2];
			
			-- Test the ground level...
			
			if( tbl[6]-range < getGroundPosition( tbl[4], tbl[5], tbl[6] + 2.0 ) ) then
			
				tbl[6] = getGroundPosition( tbl[4], tbl[5], tbl[6] + 2.0 ) + ( 2 * range );
				
				-- Now just break, later add a bounce effect...
				wantBreak = true;
			
			end
			
			local hit, hX, hY, hZ, hElem = processLineOfSight( oldX, oldY, oldZ, tbl[4], tbl[5], tbl[6], true, true, false, true, false, true );
			if( hit ) then
			
				tbl[4] = hX;
				tbl[5] = hY;
				tbl[6] = hZ;
				
				wantBreak = true;
			
			end
			
			oldX = tbl[4]; oldY = tbl[5]; oldZ = tbl[6];
			table.insert( self.thePoints, tbl );
			
			if( wantBreak ) then break; end
		
		end
		
		if( self.thePoints[#self.thePoints][6] + ( 3 * range ) > getGroundPosition( self.thePoints[#self.thePoints][4], self.thePoints[#self.thePoints][5], self.thePoints[#self.thePoints][6] + 2.0 ) ) then
		
			local tbl = { };
			tbl[1] = x;
			tbl[2] = y;
			tbl[3] = z;
			tbl[4] = self.thePoints[#self.thePoints][4];
			tbl[5] = self.thePoints[#self.thePoints][5];
			tbl[6] = getGroundPosition( self.thePoints[#self.thePoints][4], self.thePoints[#self.thePoints][5], self.thePoints[#self.thePoints][6] + 2.0 ) + ( 2 * range );
			table.insert( self.thePoints, tbl );
		
		end
	
	end
	
	return self.thePoints;

end

function table.copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

function Build3D( tbl, rot, elem )

	t3d = To3D:new( );
	t3d:Build( tbl, rot, elem );
	local ret = table.copy( t3d.thePoints );
	t3d = nil;	
	return ret;

end
 To3D = {
 
	thePoints = { }
 
 };

function To3D:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	return o;

end

function To3D:GetVelocity( x, y, z )

	if( not z ) then return math.sqrt( ( x ^ 2 ) + ( y ^ 2 ) ); else return math.sqrt( ( x ^ 2 ) + ( y ^ 2 ) + ( z ^ 2 ) ); end

end

function To3D:GetXYInDirectionOfPosition( direction, x, y, dist )

    local a = math.rad(-1 * direction)
    local dx = math.sin(a) * dist;
    local dy = math.cos(a) * dist;
    return x+dx, y+dy;

end

function To3D:Build( twoTable, throwAngle, baseElement )

	if( twoTable and type( twoTable ) == "table" and baseElement ) then
	
		local x, y, z = getElementPosition( baseElement );
		local angle = throwAngle;
		local range = getElementDistanceFromCentreOfMassToBaseOfModel( baseElement );
				
		local oldX = x;
		local oldY = y;
		local oldZ = z;	
		
		self.thePoints = { };
		local wantBreak = false;	
	
		for k, v in ipairs( twoTable ) do
		
			local tbl = { };
			tbl[1] = x;
			tbl[2] = y;
			tbl[3] = z;
			
			tbl[4], tbl[5] = self:GetXYInDirectionOfPosition( angle, x, y, v[1] );
			tbl[6] = z + v[2];
			
			-- Test the ground level...
			
			if( tbl[6]-range < getGroundPosition( tbl[4], tbl[5], tbl[6] + 2.0 ) ) then
			
				tbl[6] = getGroundPosition( tbl[4], tbl[5], tbl[6] + 2.0 ) + ( 2 * range );
				
				-- Now just break, later add a bounce effect...
				wantBreak = true;
			
			end
			
			local hit, hX, hY, hZ, hElem = processLineOfSight( oldX, oldY, oldZ, tbl[4], tbl[5], tbl[6], true, true, false, true, false, true );
			if( hit ) then
			
				tbl[4] = hX;
				tbl[5] = hY;
				tbl[6] = hZ;
				
				wantBreak = true;
			
			end
			
			oldX = tbl[4]; oldY = tbl[5]; oldZ = tbl[6];
			table.insert( self.thePoints, tbl );
			
			if( wantBreak ) then break; end
		
		end
		
		if( self.thePoints[#self.thePoints][6] + ( 3 * range ) > getGroundPosition( self.thePoints[#self.thePoints][4], self.thePoints[#self.thePoints][5], self.thePoints[#self.thePoints][6] + 2.0 ) ) then
		
			local tbl = { };
			tbl[1] = x;
			tbl[2] = y;
			tbl[3] = z;
			tbl[4] = self.thePoints[#self.thePoints][4];
			tbl[5] = self.thePoints[#self.thePoints][5];
			tbl[6] = getGroundPosition( self.thePoints[#self.thePoints][4], self.thePoints[#self.thePoints][5], self.thePoints[#self.thePoints][6] + 2.0 ) + ( 2 * range );
			table.insert( self.thePoints, tbl );
		
		end
	
	end
	
	return self.thePoints;

end

function table.copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

function Build3D( tbl, rot, elem )

	t3d = To3D:new( );
	t3d:Build( tbl, rot, elem );
	local ret = table.copy( t3d.thePoints );
	t3d = nil;	
	return ret;

end