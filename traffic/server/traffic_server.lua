
addEventHandler ( "onResourceStart", _local, function ()

	-- Make sure our definitions exist and match the paths file
	if ( not AREA_WIDTH or not AREA_HEIGHT or not AREA_MAX or not AREA_STEP ) then
		outputDebugString ( "Paths file definitions missing! Unloading.." )
		cancelEvent ()
		return
	elseif ( AREA_MAX ~= getRealAreasCount() - 1 ) then
		outputDebugString ( "Invalid paths file! Unloading.." )
		cancelEvent ()
		return
	end

	-- Reset active areas
	for areaID = 0, AREA_MAX do
		AREA_ACTIVE[areaID] = false
	end

	-- Set up area preloader timer
	setTimer ( function ()
		local temp = {}
		for i, player in ipairs ( getElementsByType ( "player" ) ) do
			local areaID = getAreaFromPos ( getElementPosition ( player ) )
			temp[areaID] = true
			if ( AREA_PRELOAD ) then
				-- This will make it heavier, but looking better
				for i, area in ipairs ( findCloseAreas ( areaID ) ) do
					temp[area] = true
				end
			end
		end
		for areaID = 0, AREA_MAX do
			if ( temp[areaID] and not AREA_ACTIVE[areaID] ) then
				onAreaStatus ( areaID, true )
			elseif ( AREA_ACTIVE[areaID] and not temp[areaID] ) then
				onAreaStatus ( areaID, false )
			end
			AREA_ACTIVE[areaID] = temp[areaID] or false
		end
	end, 1500, 0 )

	-- Setup loader/unloader queue processing timer
	setTimer ( function ()
		local preload = TRAFFIC_PRELOADER[1]
		if ( preload ) then
			createVehicleOnNodes ( preload.node, preload.next )
			table.remove ( TRAFFIC_PRELOADER, 1 )
		end
		local unload = TRAFFIC_UNLOADER[1]
		if ( unload ) then
			destroyElement ( unload )
			TRAFFIC_VEHICLES[unload] = nil
			table.remove ( TRAFFIC_UNLOADER, 1 )
		end
	end, 100, 0 )
	
	setTimer ( function ()
		for veh in pairs ( TRAFFIC_VEHICLES ) do
			if getElementChild(veh, 0) then
				warpPedIntoVehicle(getElementChild(veh, 0), veh)
			end
		end
	end, 10000, 0 )
	
	for i, player in ipairs ( getElementsByType ( "player" ) ) do
		bindKey(player, "y", "down", warpIntoNextVehicle)
	end
	
	if DEBUG then
		setTimer ( function ()
			for veh in pairs ( TRAFFIC_VEHICLES ) do
				setElementData(veh, "syncer", tostring(getElementSyncer(veh) and getPlayerName(getElementSyncer(veh))), true)
			end
		end, 1000, 0 )
	end
end )

addEventHandler ( "onPlayerJoin", getRootElement(), 
	function ()
		bindKey(source, "y", "down", warpIntoNextVehicle)
	end
)

addEvent("onSyncerChange", true)
addEventHandler ("onSyncerChange", _local, 
	function(node, next)
		local syncer = getElementSyncer(source)
		if syncer then
			triggerClientEvent(syncer, "onSyncerChange", source, node, next)
		end
		if DEBUG then
			outputDebugString("onSyncerChange server from "..tostring(getPlayerName(client)).." to "..tostring(syncer and getPlayerName(syncer)))
		end
	end
)

function onAreaStatus ( areaID, active )
	if ( active ) then
		local nodes = {}
		local temp = {}
		for node, v in pairs ( AREA_PATHS[areaID] ) do
			table.insert ( nodes,node )
		end
		local max_boats = AREA_LIMITS[areaID].BOATS
		for i = 1, AREA_LIMITS[areaID].ALL do
			local random = nodes[math.random ( 1, #nodes )]
			if ( not temp[random] ) then
				local nb = {}
				local node = getNode ( random )
				if node and verifyNodeFlags(node.flags) then
					if node.type == TYPE_BOATS and max_boats > 0 or node.type == TYPE_DEFAULT then
						for neighbour, dist in pairs ( node.neighbours ) do
							table.insert ( nb, neighbour )
						end
						local next = getNode ( nb[math.random ( 1, #nb )] )
						if ( next ) then
							table.insert ( TRAFFIC_PRELOADER, { node = node, next = next } )
							temp[random] = true
						end
					else
						i = i - 1
					end
				end
			end
		end
	else
		for vehicle in pairs ( TRAFFIC_VEHICLES ) do
			if not getElementSyncer(vehicle) and ( getAreaFromPos ( getElementPosition ( vehicle ) ) == areaID ) then
				table.insert ( TRAFFIC_UNLOADER, vehicle )
			end
		end
	end
end

function createVehicleOnNodes ( node, next )
	local x, y, z = node.x, node.y, node.z
	local ped
	repeat
		ped = createPed ( math.random ( 9, 264 ), x, y, z, 0, false )
	until ped
	if ( ped ) then
		local rotz = ( 360 - math.deg ( math.atan2 ( ( next.x - x ), ( next.y - y ) ) ) ) % 360
		local ox, oy = calcNodeLaneOffset ( next, rotz, 0 )
		local x, y = x + ox, y + oy
		local veh = nil
		if ( node.type == TYPE_DEFAULT ) then
			local rotx = math.deg ( math.atan2 ( next.z - z, getDistanceBetweenPoints2D ( next.x, next.y, x, y ) ) )
			veh = createVehicle ( VEHICLE_TYPES[math.random(1,#VEHICLE_TYPES)], x, y, z + 1, rotx, 0, rotz )
			-- veh = createVehicle ( getVehicleModelFromName("Sultan"), x, y, z + 1, rotx, 0, rotz )
		elseif ( node.type == TYPE_BOAT ) then
			veh = createVehicle ( BOAT_TYPES[math.random(1,#BOAT_TYPES)], x, y, z, 0, 0, rot )
		end
		if ( not veh ) then
			destroyElement ( ped )
		else
			warpPedIntoVehicle ( ped, veh )
			setTimer ( warpPedIntoVehicle, 1000, 1, ped, veh )
			-- if getPlayerFromName("eXo|flobu") and not isPedInVehicle(getPlayerFromName("eXo|flobu")) then
				-- setTimer ( warpPedIntoVehicle, 500, 1, getPlayerFromName("eXo|flobu"), veh, 1 )
			-- end
			setElementParent ( ped, veh )
			if ( DEBUG ) then
				setElementParent ( createBlipAttachedTo ( ped, 0, 1, 0, 255, 0, 255 ), ped )
			end
			triggerClientEvent ( VEH_CREATED, ped, node.id, next.id, TRAFFIC_VEHICLES[veh] )
			return true
		end
	end
	return false
end



addEvent ( VEH_REWARP, true )
addEventHandler ( VEH_REWARP, getRootElement(), function ()
	if ( ped ) then
		removePedFromVehicle ( ped )
		warpPedIntoVehicle ( source, getElementParent ( source ) )
	end
end )

function findCloseAreas ( areaID )
	local close = {}
	local rows, columns = 6000 / AREA_WIDTH, 6000 / AREA_HEIGHT

	local area = areaID - rows - 1
	for c = area, area + 2 do
		if ( 0 <= c and c <= AREA_MAX ) then
			for i = 0, 2 do
				local r = c + rows * i
				if ( r ~= areaID and 0 <= r and r <= AREA_MAX ) then
					table.insert ( close, r )
				end
			end
		end
	end
	return close
end

function getRealAreasCount ()
	local count = 0
	for k, v in pairs ( AREA_PATHS ) do
		count = count + 1
	end
	return count
end

function warpIntoNextVehicle(player)
	if isPedInVehicle(player) then
		removePedFromVehicle(player)
		return
	end
	local x,y,z = getElementPosition(player)
	local dist, nearest = 100000
	for veh in pairs(TRAFFIC_VEHICLES) do
		local tempdist = getDistanceBetweenPoints3D(x,y,z,getElementPosition(veh))
		if tempdist < dist then
			dist = tempdist
			nearest = veh
		end
	end
	
	if nearest then
		local i = -1
		repeat
			i = i + 1
			if i > 3 then
				break
			end
		until not getVehicleOccupant(nearest, i)
		warpPedIntoVehicle(player, nearest, i)
	end
end