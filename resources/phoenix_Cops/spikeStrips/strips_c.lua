local thePlayer = getLocalPlayer( );

function getPointFromDistanceRotation(x, y, dist, angle)
 
    local a = math.rad(90 - angle);
 
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
 
    return x+dx, y+dy;
 
end

function DropFromCar( theVehicle )

	local vehX, vehY, vehZ = getElementPosition( theVehicle ); -- Get theVehicle 's position.
	local rotX, rotY, rotZ = getElementRotation( theVehicle ); -- Get theVehicle 's rotation. 
	rotZ = 360 - rotZ; -- Modify the vehicles rot so it will be in the same coordinate space. ( The vehicle rot is different, as sb talked in forums )
	
	local rotMZ, rotEZ;
	if( rotZ >= 180 ) then rotMZ = rotZ - ( 180 ); else rotMZ = rotZ + ( 180 ); end	-- Opposite angle of vehicle
	
	local x, y = getPointFromDistanceRotation( vehX, vehY, 5, rotMZ ); -- Get the position behind my veh.
		
	local tempElem = { }; -- new temp Table for storing values to send them to serverside creation script.
	
	tempElem.posX = x;
	tempElem.posY = y;
	tempElem.posZ = getGroundPosition( x, y, vehZ + 3 )+0.222; -- Get the ground position behind theVehicle and add the objects height from base of model.
	tempElem.rotX = 0;
	tempElem.rotY = 0;	
	tempElem.rotZ = rotZ/2; -- This is where i need some magic to make it work...
	
	-- outputDebugString( "DropFromCar: " .. tempElem.posZ ); -- Output debug...
	
	tempElem.spikeType = 1593; -- Spike objectId.
	tempElem.created = false;	
	
	triggerServerEvent( "onSpikeDrop", thePlayer, tempElem ); 

end

addCommandHandler( "tt",

	function ( )
	
		if( isPedInVehicle( thePlayer ) ) then
		
			local theVehicle = getPedOccupiedVehicle( thePlayer );
			local numStrips = getElementData( theVehicle, "spikeStrips" );
			
			if( numStrips and tonumber( numStrips ) > 0 ) then
		
				DropFromCar( theVehicle );
				numStrips = numStrips - 1;
				setElementData( theVehicle, "spikeStrips", tostring( numStrips ) );
			
			else
			
				exports.phoenix_Chat:OocInfo( "Masinal on naelaribad otsas." );
			
			end
		
		else
		
			exports.phoenix_Chat:OocInfo( "Pead olema autos" );
		
		end
	
	end

);