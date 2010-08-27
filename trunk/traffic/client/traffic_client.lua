local sx, sy = guiGetScreenSize()

CURVE = 45							--45

CONTROLS = {"vehicle_left","vehicle_right","brake_reverse","accelerate","handbrake","horn"}

-- Process all peds
addEventHandler ( "onClientPreRender", _root, function ()
	-- Only in this resource and only streamed in
	for i, ped in ipairs ( getElementsByType ( "ped", getResourceRootElement(), true ) ) do
		if ( _peds[ped] ) then
			local veh = getElementParent(ped)
			local sync = isElementSyncer(veh)
			if _peds[ped].sync == sync then
				if _peds[ped].sync then
					pedProcessSyncer(ped)
				else
					pedProcess(ped)
				end
			elseif sync then
				if _peds[ped] then
					local node = pathsNodeFindClosest(getElementPosition(veh))
					local next = pedGetNextNode(ped, node, node)
					pedFormQueue(ped, next, node)
					pedProcessSyncer(ped)
				end
				if DEBUG then
					outputDebugString("syncerChange")
				end
			-- elseif not sync and #_peds[ped].queue > 1 then
				-- triggerServerEvent("onSyncerChange", veh, _peds[ped].queue[1].id, _peds[ped].queue[2].id)
				-- if DEBUG then
					-- outputDebugString("onSyncerChange client start")
				-- end
			end
			_peds[ped].sync = isElementSyncer(veh)
		end
	end
end )

addEvent ( "onSyncerChange", true )
addEventHandler ( "onSyncerChange", _root, 
	function (node, next)
		local ped = getVehicleController(source)
		if _peds[ped] then
			if DEBUG then
				outputDebugString("onSyncerChange client end: node = "..tostring(node).." next = "..tostring(next))
			end
			pedInitialize(ped, node, next)
			-- local node = pathsNodeFindClosest(getElementPosition(source))
			-- local next = pedGetNextNode(ped, node, node)
			-- pedFormQueue(ped, next, node)
			pedProcessSyncer(ped)
		end
	end 
)

addEventHandler ( "onClientPlayerQuit", _root, function ()
	for i, ped in ipairs ( getElementsByType ( "ped", getResourceRootElement(), true ) ) do
		if ( _peds[ped] ) then
			local veh = getElementParent(ped)
			if isElementSyncer(veh) then
				triggerServerEvent("onSyncerChange", veh, _peds[ped].queue[1].id, _peds[ped].queue[2].id)
				if DEBUG then
					outputDebugString("onSyncerChange client start on quit")
				end
			end
		end
	end
end )

addEvent ( VEH_CREATED, true )
addEventHandler ( VEH_CREATED, _root, function ( node, next )
	pedInitialize ( source, node, next )
end )

addEventHandler ( "onClientElementDestroy", getResourceRootElement(), function()
	if ( _peds[source] ) then
		_peds[source] = nil
	end
end )

function pedProcessSyncer ( ped )

	local vehicle = getElementParent ( ped )
	
	if ( not vehicle ) then
		return
	end

	if ( DEBUG ) then
		_peds[ped].processed = true
	end

	local next = pedGetTargetNode ( ped )
	if not next then return end
	local x, y, z = getElementPosition ( vehicle )
	local nx, ny, nz = next.x, next.y, next.z
	
	if DEBUG then
		dxDrawLine3D ( x, y, z, nx, ny, nz, tocolor ( 255, 0, 255, 255 ), 10 )
	end
	
	local controls = {}
	local limit = SPEED_LIMIT[_peds[ped].nodes[1].type]
	local rot = ( 360 - math.deg ( math.atan2 ( ( nx - x ), ( ny - y ) ) ) ) % 360
	local _, _, vrot = getElementRotation ( vehicle )
	local vrot = vrot or 0
	local trot = ( rot - vrot ) % 360
	if ( _peds[ped].panic ) then
		limit = limit + PANIC_SPEED
	end
	if _peds[ped].queue[1].flags and _peds[ped].queue[1].flags.highway then
		limit = limit + HIGHWAY_SPEED
	end
	local distance = getDistanceBetweenPoints3D(x, y, z, nx, ny, nz)
	-- _peds[ped].distance = math.floor(distance)
	local accuracy = distance < 7 and 20 or 6
	if ( trot > -accuracy and trot < accuracy ) then
		controls["vehicle_left"] = false
		controls["vehicle_right"] = false
	elseif ( trot <= 360 and trot >= 180 ) then
		limit = SPEED_TURNING[_peds[ped].nodes[1].type]
		controls["vehicle_left"] = false
		controls["vehicle_right"] = true
	elseif ( trot >= 0 and trot <= 180 ) then
		limit = SPEED_TURNING[_peds[ped].nodes[1].type]
		controls["vehicle_right"] = false
		controls["vehicle_left"] = true
	end
	if ( getVehicleSpeed ( vehicle ) > limit ) then
		controls["accelerate"] = false
		-- outputChatBox("limit: "..limit)
	else
		controls["brake_reverse"] = false
		controls["accelerate"] = true
	end
	
	local stop
	local horn = false
	
	local sightLength = math.sqrt(getVehicleSpeed(vehicle))*2
	sightLength = sightLength < 4 and 4 or sightLength
	
	if 1000 > getTickCount() - _peds[ped].stopStartTime then
		sightLength = _peds[ped].stopLength or sightLength
	end
	
	local matrix = getElementMatrix(vehicle)
	
	-- dxDrawLine3D( matrix[4][1], matrix[4][2], matrix[4][3], matrix[4][1] + matrix[1][1], matrix[4][2] + matrix[2][1], matrix[4][3] + matrix[3][1], tocolor ( 0, 255, 0), 3)
	-- dxDrawLine3D( matrix[4][1], matrix[4][2], matrix[4][3], matrix[4][1] + matrix[1][2], matrix[4][2] + matrix[2][2], matrix[4][3] + matrix[3][2], tocolor ( 0, 255, 0), 3)
	-- dxDrawLine3D( matrix[4][1], matrix[4][2], matrix[4][3], matrix[4][1] + matrix[1][3], matrix[4][2] + matrix[2][3], matrix[4][3] + matrix[3][3], tocolor ( 0, 255, 0), 3)
	
	local distanceToGround = getElementDistanceFromCentreOfMassToBaseOfModel(vehicle) - 0.25 
	local tx, ty, tz
	local process = {}
	local sideLineDistance = getVehicleType(vehicle) == "Bike" and 0.5 or 1.5
	for i=-sideLineDistance, sideLineDistance, 0.5 do
		x, y, z = getMatrixOffsets(matrix, i, 0, distanceToGround)
		tx, ty, tz = getMatrixOffsets(matrix, i, sightLength, distanceToGround)
		local _, _, _, _, elem = processLineOfSight( x, y, z, tx, ty, tz, true, true, true, true, true, true, true, true, vehicle )
		table.insert(process, elem)
		if DEBUG then
			dxDrawLine3D( x, y, z, tx, ty, tz, tocolor ( 255, 255, 255), 3)
		end
		x, y, z = getMatrixOffsets(matrix, i, 0, 0)
		tx, ty, tz = getMatrixOffsets(matrix, i, sightLength, 0)
		local _, _, _, _, elem = processLineOfSight( x, y, z, tx, ty, tz, true, true, true, true, true, true, true, true, vehicle )
		table.insert(process, elem)
		if DEBUG then
			dxDrawLine3D( x, y, z, tx, ty, tz, tocolor ( 255, 255, 255), 3)
		end
		x, y, z = getMatrixOffsets(matrix, i, 0, -distanceToGround)
		tx, ty, tz = getMatrixOffsets(matrix, i, sightLength, -distanceToGround)
		local _, _, _, _, elem = processLineOfSight( x, y, z, tx, ty, tz, true, true, true, true, true, true, true, true, vehicle )
		table.insert(process, elem)
		if DEBUG then
			dxDrawLine3D( x, y, z, tx, ty, tz, tocolor ( 255, 255, 255), 3)
		end
	end
	
	local hitElement
	for _,elem in ipairs(process) do
		if elem then
			hitElement = elem
			break
		end
	end
	
	if hitElement then
		stop = not _peds[ped].panic
		-- horn = true
		-- outputChatBox(tostring(seeElement).." "..getElementType(seeElement))
		if getElementType(hitElement) == "vehicle" then
			-- local occupant = getVehicleOccupant( seeElement, 0 )
			-- if _peds[occupant] then
				if next.leftlanes == 2 or next.rightlanes == 2 then
					lane = 0
					nextlanes = 5
					-- stop = false
				end
			-- end
		end
	else
		HORN_STARTTIME[ped] = getTickCount()
	end
	
	if ( stop ) then
		_peds[ped].stopStartTime = getTickCount()
		_peds[ped].stopLength = sightLength
		controls["accelerate"] = false
		controls["vehicle_left"] = false
		controls["vehicle_right"] = false
		if getVehicleSpeed( vehicle ) < 3 then
			controls["brake_reverse"] = false
		else
			controls["brake_reverse"] = true
		end
		controls["handbrake"] = true
		if horn then
			controls["horn"] = true
			if not HORN_STARTTIME[ped] then
				HORN_STARTTIME[ped] = getTickCount()
			end
			if HORN_TIME <= getTickCount() - HORN_STARTTIME[ped] then
				controls["horn"] = true
				HORN_STARTTIME[ped] = getTickCount()
			elseif HORN_TIME <= getTickCount() - HORN_STARTTIME[ped] + 500 then
				controls["horn"] = false
			end
		end
		if not HORN_STARTTIMELONG[ped] then
			HORN_STARTTIMELONG[ped] = getTickCount()
		end
		if 3*HORN_TIME <= getTickCount() - HORN_STARTTIMELONG[ped] then
			HORN_STARTTIMELONG[ped] = getTickCount()
		elseif 3*HORN_TIME <= getTickCount() - HORN_STARTTIMELONG[ped] + 1000 then
			-- outputChatBox("drive backwards")
			controls["handbrake"] = false
			controls["brake_reverse"] = true
		end
	else
		controls["brake_reverse"] = false
		controls["handbrake"] = false
		controls["horn"] = false
	end
	
	if #_peds[ped].queue >= 4 then
		local kommendeKurve = math.abs( math.deg(math.atan2(_peds[ped].queue[4].y - _peds[ped].queue[3].y, _peds[ped].queue[4].x - _peds[ped].queue[3].x)) - math.deg(math.atan2(_peds[ped].queue[3].y - _peds[ped].queue[2].y, _peds[ped].queue[3].x - _peds[ped].queue[2].x)) )
		local naechsteKurve = math.abs( math.deg(math.atan2(_peds[ped].queue[3].y - _peds[ped].queue[2].y, _peds[ped].queue[3].x - _peds[ped].queue[2].x)) - math.deg(math.atan2(_peds[ped].queue[2].y - _peds[ped].queue[1].y, _peds[ped].queue[2].x - _peds[ped].queue[1].x)) )
		if kommendeKurve > CURVE or naechsteKurve > CURVE then
			-- if kommendeKurve > KURVE then
				-- outputChatBox("kommendeKurve: "..tostring(kommendeKurve))
			-- end
			-- if naechsteKurve > KURVE then
				-- outputChatBox("naechsteKurve: "..tostring(naechsteKurve))
			-- end
			if ( getVehicleSpeed ( vehicle ) > 35 ) then
				controls["brake_reverse"] = true
				controls["accelerate"] = false
			elseif ( getVehicleSpeed ( vehicle ) > 20 ) then
				controls["brake_reverse"] = false
				controls["accelerate"] = false
			end
		end
	end
	
	sightLength = getVehicleType(vehicle) == "Bike" and 2 or 4
	sideLineDistance = getVehicleType(vehicle) == "Bike" and 0 or 1
	for i=-sideLineDistance, sideLineDistance, 0.5 do
		x, y, z = getMatrixOffsets(matrix, i, 0, 0)
		tx, ty, tz = getMatrixOffsets(matrix, i, sightLength, 0)
		local collideGTABuilding = processLineOfSight( x, y, z, tx, ty, tz, true, false, false, true, false, false, false, true, vehicle )
		if DEBUG then
			dxDrawLine3D( x, y, z, tx, ty, tz, tocolor ( 255, 0, 0), 3)
		end
		if collideGTABuilding then
			if getVehicleOccupant(vehicle,1) then
				dxDrawText ( "COLLIDE FRONT", sx - 200, sy/2 - 5, sx - 200, sy/2 - 5, tocolor(255,0,0), 2 )
			end
			_peds[ped].collideStartTimeFront = getTickCount()
			break
		end
	end
	if 750 >= getTickCount() - _peds[ped].collideStartTimeFront then
		controls["accelerate"] = false
		controls["brake_reverse"] = getVehicleSpeed ( vehicle ) < 10 and true or getVehicleSpeed ( vehicle ) > 15 and true or false
		controls["vehicle_left"] = controls["vehicle_right"]
		controls["vehicle_right"] = controls["vehicle_left"]
	end
	
	for i=-sideLineDistance, sideLineDistance, 0.5 do
		x, y, z = getMatrixOffsets(matrix, i, 0, 0)
		tx, ty, tz = getMatrixOffsets(matrix, i, -sightLength, 0)
		local collideGTABuilding = processLineOfSight( x, y, z, tx, ty, tz, true, false, false, true, false, false, false, true, vehicle )
		if DEBUG then
			dxDrawLine3D( x, y, z, tx, ty, tz, tocolor ( 255, 0, 0), 3)
		end
		if collideGTABuilding then
			if getVehicleOccupant(vehicle,1) then
				dxDrawText ( "COLLIDE BACK", sx - 200, sy/2 + 5, sx - 200, sy/2 + 5, tocolor(255,0,0), 2 )
			end
			_peds[ped].collideStartTimeBack = getTickCount()
			break
		end
	end
	if 750 >= getTickCount() - _peds[ped].collideStartTimeBack then
		controls["accelerate"] = getVehicleSpeed ( vehicle ) < 10 and true or getVehicleSpeed ( vehicle ) > 15 and true or false
		controls["brake_reverse"] = false
		controls["vehicle_left"] = controls["vehicle_right"]
		controls["vehicle_right"] = controls["vehicle_left"]
	end
	
	sightLength = sightLength/2
	sideLineDistance = sideLineDistance*2
	for i=-sideLineDistance, sideLineDistance, 1 do
		x, y, z = getMatrixOffsets(matrix, 0, i, 0)
		tx, ty, tz = getMatrixOffsets(matrix, sightLength, i, 0)
		local collideGTABuilding = processLineOfSight( x, y, z, tx, ty, tz, true, false, false, true, false, false, false, true, vehicle )
		if DEBUG then
			dxDrawLine3D( x, y, z, tx, ty, tz, tocolor ( 255, 0, 0), 3)
		end
		if collideGTABuilding then
			if getVehicleOccupant(vehicle,1) then
				dxDrawText ( "COLLIDE BACK", sx - 200, sy/2 + 5, sx - 200, sy/2 + 5, tocolor(255,0,0), 2 )
			end
			controls["vehicle_left"] = true
			controls["vehicle_right"] = false
			break
		end
	end
	
	for i=-sideLineDistance, sideLineDistance, 1 do
		x, y, z = getMatrixOffsets(matrix, 0, i, 0)
		tx, ty, tz = getMatrixOffsets(matrix, -sightLength, i, 0)
		local collideGTABuilding = processLineOfSight( x, y, z, tx, ty, tz, true, false, false, true, false, false, false, true, vehicle )
		if DEBUG then
			dxDrawLine3D( x, y, z, tx, ty, tz, tocolor ( 255, 0, 0), 3)
		end
		if collideGTABuilding then
			if getVehicleOccupant(vehicle,1) then
				dxDrawText ( "COLLIDE BACK", sx - 200, sy/2 + 5, sx - 200, sy/2 + 5, tocolor(255,0,0), 2 )
			end
			controls["vehicle_left"] = false
			controls["vehicle_right"] = true
			break
		end
	end
	
	for control, state in pairs(controls) do
		if _peds[ped].controls[control] ~= state then
			setPedControlState(ped, control, state)
			setElementData(vehicle, control, state)
		end
	end
	
	_peds[ped].controls = controls
end

function pedProcess(ped)
	for _,control in ipairs(CONTROLS) do
		setPedControlState(ped, control, getElementData(getElementParent(ped), control) )
	end
end

addEventHandler ( "onClientPlayerWeaponFire", _root, function()
	local px, py, pz = getElementPosition ( source )
	for i, ped in ipairs ( getElementsByType ( "ped", getResourceRootElement() ) ) do
		if ( _peds[ped] ) then
			local x, y, z = getElementPosition ( ped )
			if ( getDistanceBetweenPoints3D ( x, y, z, px, py, pz ) <= PANIC_DIST ) then
				if ( not _peds[ped].panic ) then
					_peds[ped].panic = true
					setTimer ( pedStopPanic, PANIC_TIME, 1, ped )
				end
			end
		end
	end
end )

function pedStopPanic ( ped )
	_peds[ped].panic = false
end

addEventHandler ( "onClientRender", _root, function()
	if DEBUG then
		local px, py, pz = getElementPosition ( _local )
		local sx, sy = guiGetScreenSize()
		local count = 0
		local count_synced, count_local = 0, 0
		for i, ped in ipairs ( getElementsByType ( "ped", getResourceRootElement() ) ) do
			if ( _peds[ped] ) then
				local veh = getElementParent ( ped )
				if ( getElementType ( veh ) == "vehicle" ) then
					local x, y, z = getElementPosition ( veh )
					local areaID = getAreaFromPos ( x, y, z )
					count = count + 1
					local dist = getDistanceBetweenPoints3D ( x, y, z, px, py, pz )
					if ( dist < SYNC_DIST ) then
						count_synced = count_synced + 1
						if ( isElementOnScreen ( ped ) ) then
							local dx, dy = getScreenFromWorldPosition ( x, y, z + 1 )
							if ( dx and dy ) then
								local next = _peds[ped].next
								local next_id = "None"
								if ( next ) then next_id = next.id end
								local node = _peds[ped].node
								local node_id = "None"
								if ( node ) then node_id = node.id end
								dxDrawText ( 
									"area: "..areaID..
									"\nzonename: "..tostring(getZoneName(x,y,z)).." ("..tostring(getZoneName(x,y,z,true))..")"..
									"\nspeed: "..math.floor(getVehicleSpeed(veh))..
									"\nqueue: "..tostring(#_peds[ped].queue)..
									"\ndistance: "..tostring ( _peds[ped].distance )..
									"\nangle: "..tostring(#_peds[ped].queue >= 3 and math.abs(math.abs(math.deg(math.atan2(_peds[ped].queue[3].y - _peds[ped].queue[2].y, _peds[ped].queue[3].x - _peds[ped].queue[2].x))) - math.abs(math.deg(math.atan2(_peds[ped].queue[2].y - _peds[ped].queue[1].y, _peds[ped].queue[2].x - _peds[ped].queue[1].x)))) )..
									"\nneighbours: "..tostring(_peds[ped].queue[1].id and table.size(pathsNodeGetNeighbours(_peds[ped].queue[1].id)))..
									"\nflags: "..tostring(_peds[ped].queue[1].flags and table.concatIndex(_peds[ped].queue[1].flags))..
									"\nprocessed: "..tostring (_peds[ped].processed)..
									"\nsyncer: "..tostring(getElementData(veh, "syncer"))..
									"\nyou sync: "..tostring(isElementSyncer(veh)),
									dx, dy, dx, dy, tocolor ( 255, 255, 255, 255 ), 1.5, "default", "center" )
							end
						end
					end
					if isElementSyncer(veh) then
						count_local = count_local + 1
					end
				end
			end
		end
		local areaID = getAreaFromPos ( px, py, pz )
		local dx, dy = sx - 150, sy / 3 * 2
		dxDrawText ( "Count: "..count, dx, dy )
		dxDrawText ( "Synced: "..count_synced, dx, dy + 20 )
		dxDrawText ( "Synced by me: "..count_local, dx, dy + 40 )
		dxDrawText ( "Area ID: "..areaID, dx, dy + 60 )

		-- areas grid

		if ( isPlayerMapVisible() ) then
			local start = sx / 2 - sy / 2
			local width = sy / ( 6000 / AREA_WIDTH )
			for i = 1, ( ( 6000 / AREA_HEIGHT ) - 1 ) do
				dxDrawLine ( start + i * width, 0, start + i * width, sy, tocolor ( 0, 0, 255, 200 ) )
				dxDrawLine ( start, i * width, start + sy, i * width, tocolor ( 0, 0, 255, 200 ) )
			end
		end
	end
end )
