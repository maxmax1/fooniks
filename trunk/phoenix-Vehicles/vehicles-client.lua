function vehicleStarthandler( theVehicle )

	if( not theVehicle or not isElement( theVehicle ) ) then
	
		return false
	
	end
	
	local x, y, z = getElementPosition( theVehicle );
	local sound = playSound3D( "files/sounds/engine.wav", x, y, z, false ) ;
	setTimer( destroyElement, 3000, 1, sound );

end

addEvent( "onVehicleStart", true );
addEventHandler( "onVehicleStart", getRootElement( ), vehicleStarthandler );