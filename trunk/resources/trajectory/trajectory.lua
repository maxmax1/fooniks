function floatadd( f1, f2 ) return f1 + f2 end
function floatsub( f1, f2 ) return f1 - f2 end
function floatmul( f1, f2 ) return f1 * f2 end
function floatdiv( f1, f2 ) return f1 / f2 end
function floatpower( f1, f2 ) return f1 ^ f2 end
function floatsqroot( f1, f2 ) return math.sqrt( f1, f2 ) end

function floatsin( f1, param ) return math.sin( math.rad( f1 ) ); end
function floatcos( f1, param ) return math.cos( math.rad( f1 ) ); end
function floattan( f1, param ) return math.tan( math.rad( f1 ) ); end

function sampasin( f1 ) return math.deg( math.asin( f1 ) ); end
function sampatan( f1 ) return math.deg( math.atan( f1 ) ); end

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

function GetXYInDirectionOfPosition( direction, x, y, dist )

	return x + (dist * floatsin(-1 * direction, degrees)), y + (dist * floatcos(-1.0 * direction, degrees));

end

function GetFlightData( base, velocity, angle, points, gravity )

	if( not gravity ) then gravity = 9.8; end
	
	local fData = { };
	
	local increment = floatdiv(GetFlightMaxTime(base, velocity, angle, gravity), points);
	local cTime = increment;
		
	for i = 1, points, 1 do
	
		local distance, height, x, y = GetFlightConditionsAtTime( 
		
			base, 
			velocity, 
			angle, 
			cTime, 
			gravity
		
		);
		
		fData[i] = { };
		fData[i]["FLIGHT_DISTANCE"] = distance;
		fData[i]["FLIGHT_HEIGHT"] = height;
		fData[i]["FLIGHT_VELOCITY"] = { };
		fData[i]["FLIGHT_VELOCITY"][1] = x;
		fData[i]["FLIGHT_VELOCITY"][2] = y;
		
		cTime = cTime + increment;
	
	end

	return fData, increment;

end

function GetFlightConditionsAtDistance( base, velocity, angle, distance, gravity )

	if( not gravity ) then gravity = 9.8; end

    local x, y = GetFlightInitialVelocity(velocity, angle);
    local ttime = floatdiv(distance, x);
    local height = floatadd(base, floatdiv(floatmul(distance, y), x) - floatmul(0.5, floatmul(gravity, floatdiv(floatpower(distance, 2.0), floatpower(x, 2.0)))));
    y = y - floatmul(gravity, ttime);
	
	return ttime, height, x, y;

end

function GetFlightConditionsAtTime( base, velocity, angle, ttime, gravity )

	if( not gravity ) then gravity = 9.8; end

    local distance = floatmul(floatmul(velocity, floatcos(angle, degrees)), ttime );
	
    local height = floatadd(base, floatsub(floatmul(floatmul(velocity, floatsin(angle, degrees)), ttime ), floatdiv(floatmul(gravity, floatpower( ttime, 2.0)), 2.0)));
    local x, y = GetFlightInitialVelocity(velocity, angle);
    y = y - floatmul(gravity, ttime);

	return distance, height, x, y;

end

function GetFlightInitialVelocity( velocity, angle )

    return floatmul(velocity, floatcos(angle, degrees)), floatmul(velocity, floatsin(angle, degrees));

end

function GetFlightMaxHeight( base, velocity, angle, gravity )

	if( not gravity ) then gravity = 9.8; end
	local x, y = GetFlightInitialVelocity( velocity, angle );    

	return floatadd(base, floatdiv(floatpower(y, 2.0), floatmul(2.0, gravity)));

end

function GetFlightMaxRange( base, velocity, angle, gravity )

	if( not gravity ) then gravity = 9.8; end
    local t = GetFlightMaxTime( base, velocity, angle, gravity );
    local x, y = GetFlightInitialVelocity( velocity, angle );    
    return floatmul(x, t);

end

function GetFlightMaxTime( base, velocity, angle, gravity )

	if( not gravity ) then gravity = 9.8; end

    local fTimes = { };
    local x, y = GetFlightInitialVelocity( velocity, angle );
				
    fTimes[1] = floatadd(floatdiv(y, gravity), floatsqroot(floatsub(floatdiv(floatpower(y, 2.0), floatpower(gravity, 2.0)), floatdiv(floatmul(base, 2.0), gravity))));
    fTimes[2] = floatsub(floatdiv(y, gravity), floatsqroot(floatsub(floatdiv(floatpower(y, 2.0), floatpower(gravity, 2.0)), floatdiv(floatmul(base, 2.0), gravity))));
	
    if( fTimes[1] >= fTimes[2] ) then return fTimes[1]; else return fTimes[2]; end

end

function GetRequiredAngle( range, velocity, gravity )

	if( not gravity ) then gravity = 9.8; end
	
    return floatdiv(sampasin(floatdiv(floatmul(range, gravity), floatpower(velocity, 2.0))), 2.0);

end

function GetRequiredConditions( range, peak, gravity )

	if( not gravity ) then gravity = 9.8; end
	
    velocity = floatsqroot(floatdiv(floatmul(range, gravity), floatsin(floatmul(2.0, sampatan(floatmul(4.0, floatdiv(peak, range)))), degrees)));
    angle = floatdiv(floatmul(sampatan(floatmul(4.0, floatdiv(peak, range))), 180.0), floatdiv(22.0, 7.0));

	return velocity, angle;

end

function GetRequiredVelocity( range, angle, gravity )

	if( not gravity ) then gravity = 9.8; end
    return floatsqroot(floatdiv(floatmul(range, gravity), floatsin(floatmul(2.0, angle), degrees)));

end

function GetVelocity( x, y )

	return math.sqrt( ( x ^ 2 ) + ( y ^ 2 ) );

end
