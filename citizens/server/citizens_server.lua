
SYNC_TIME = 500

_peds = {}

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
		local preload = CITIZENS_PRELOADER[1]
		if ( preload ) then
			createPedOnNodes ( preload.node, preload.next )
			table.remove ( CITIZENS_PRELOADER, 1 )
		end
		local unload = CITIZENS_UNLOADER[1]
		if ( unload ) then
			-- outputDebugString("DESTROY "..tostring(getElementType(unload)).." "..tostring(unload).." "..tostring(
			destroyElement(unload)
			-- ))
			CITIZENS_PEDS[unload] = nil
			table.remove ( CITIZENS_UNLOADER, 1 )
		end
	end, 100, 0 )

	-- Setup junk removing timer
	setTimer ( function ()
		for ped, randomizer in pairs ( CITIZENS_PEDS ) do
			-- outputDebugString("CHECKHEALTH "..tostring(getElementType(ped)).." "..tostring(ped).." health: "..tostring(getElementHealth(ped)))
			if ( getElementHealth ( ped ) <= 0 ) then
				table.insert ( CITIZENS_UNLOADER, ped )
			end
		end
	end, 10000, 0 )

end )

function onAreaStatus ( areaID, active )
	if ( active ) then
		local nodes = {}
		local temp = {}
		for node, v in pairs ( AREA_PATHS[areaID] ) do
			table.insert ( nodes,node )
		end
		if ( #nodes == 0 ) then
			return
		end
		for i = 1, AREA_LIMITS[areaID].ALL do
			local random = nodes[math.random ( 1, #nodes )]
			if ( not temp[random] ) then
				local nb = {}
				local node = getNode ( random )
				if ( node ) then
					for neighbour, dist in pairs ( node.neighbours ) do
						table.insert ( nb, neighbour )
					end
					local next = getNode ( nb[math.random ( 1, #nb )] )
					if ( next ) then
						table.insert ( CITIZENS_PRELOADER, { node = node, next = next } )
						temp[random] = true
					end
				end
			end
		end
	else
		for ped, randomizer in pairs ( CITIZENS_PEDS ) do
			-- outputDebugString("NOTACTIVE "..tostring(areaID).." "..tostring(ped).." "..tostring(getElementType(ped)).." "..tostring(getElementPosition(ped)))
			if ( getAreaFromPos ( getElementPosition ( ped ) ) == areaID ) then
				table.insert ( CITIZENS_UNLOADER, ped )
			end
		end
	end
end

function createPedOnNodes ( node, next )
	local x, y, z = node.x, node.y, node.z
	local ped = createPed ( x, y, z + 1 )
	if ( ped ) then
		if ( DEBUG ) then
			setElementParent ( createBlipAttachedTo ( ped, 0, 1, 255, 0, 0, 255 ), ped )
		end
		triggerClientEvent ( PED_CREATED, ped, node.id, next.id, CITIZENS_PEDS[ped] )
		return true
	end
	return false
end

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