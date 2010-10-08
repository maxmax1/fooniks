Trajectory = {

	thePoints = { },
	
	g = 9.81,
	
	theAngle,
	theSpeed,
	
	theRange,

};

function Trajectory:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	return o;

end


function Trajectory:GetTrajectoryData( )

	self.theRange = ( ( self.theSpeed ^ 2 ) * math.sin( math.rad( 2 * self.theAngle ) ) ) / self.g;
	self.theTime = ( 2 * ( self.theSpeed * math.sin( math.rad( self.theAngle ) ) ) ) / self.g;
	self.thePeak = ( ( self.theSpeed * math.sin( math.rad( self.theAngle ) ) ) ^ 2 ) / ( 2 * self.g );

end

function Trajectory:Calculate( points )

	if( not self.theTime ) then self:GetTrajectoryData( ); end
	
	self.thePoints = { };

	local increment = self.theTime / points;
	for t = increment, self.theTime, increment do
	
		local vx = ( self.theSpeed * math.cos( math.rad( self.theAngle ) ) );
		local vy = ( self.theSpeed * math.sin( math.rad( self.theAngle ) ) ) - ( self.g * t );
		
		local x = ( self.theSpeed * math.cos( math.rad( self.theAngle ) ) ) * t;
		local y = ( ( self.theSpeed * math.sin( math.rad( self.theAngle ) ) ) * t ) - ( 0.5 * self.g * ( t ^ 2 ) );
		
		table.insert( self.thePoints, { x, y, vx, vy } );
	
	end
	
	return self.thePoints;

end


--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

function CreateTrajectory( baseAngle, speed, nPoints )

	if( not baseAngle or not speed ) then return false; end
	if( not nPoints ) then nPoints = 10; end
	
	local trajectory = Trajectory:new( );
	trajectory.theAngle = baseAngle;
	trajectory.theSpeed = speed;
	trajectory:Calculate( nPoints );
	
	local ret = table.copy( trajectory.thePoints );
	
	trajectory = nil;
	
	return ret;

end
Trajectory = {

	thePoints = { },
	
	g = 9.81,
	
	theAngle,
	theSpeed,
	
	theRange,

};

function Trajectory:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	return o;

end


function Trajectory:GetTrajectoryData( )

	self.theRange = ( ( self.theSpeed ^ 2 ) * math.sin( math.rad( 2 * self.theAngle ) ) ) / self.g;
	self.theTime = ( 2 * ( self.theSpeed * math.sin( math.rad( self.theAngle ) ) ) ) / self.g;
	self.thePeak = ( ( self.theSpeed * math.sin( math.rad( self.theAngle ) ) ) ^ 2 ) / ( 2 * self.g );

end

function Trajectory:Calculate( points )

	if( not self.theTime ) then self:GetTrajectoryData( ); end
	
	self.thePoints = { };

	local increment = self.theTime / points;
	for t = increment, self.theTime, increment do
	
		local vx = ( self.theSpeed * math.cos( math.rad( self.theAngle ) ) );
		local vy = ( self.theSpeed * math.sin( math.rad( self.theAngle ) ) ) - ( self.g * t );
		
		local x = ( self.theSpeed * math.cos( math.rad( self.theAngle ) ) ) * t;
		local y = ( ( self.theSpeed * math.sin( math.rad( self.theAngle ) ) ) * t ) - ( 0.5 * self.g * ( t ^ 2 ) );
		
		table.insert( self.thePoints, { x, y, vx, vy } );
	
	end
	
	return self.thePoints;

end


--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

function CreateTrajectory( baseAngle, speed, nPoints )

	if( not baseAngle or not speed ) then return false; end
	if( not nPoints ) then nPoints = 10; end
	
	local trajectory = Trajectory:new( );
	trajectory.theAngle = baseAngle;
	trajectory.theSpeed = speed;
	trajectory:Calculate( nPoints );
	
	local ret = table.copy( trajectory.thePoints );
	
	trajectory = nil;
	
	return ret;

end