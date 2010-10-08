
DEBUG = true

UPDATE_LAST = 0

_peds = {}

addEvent ( PED_CREATED, true )
addEventHandler ( PED_CREATED, _root, function ( node, next, randomizer )
	_peds[source] = {}
	local node = getNode ( node )
	_peds[source].node = node
	_peds[source].next = getNode ( next )
	_peds[source].randomizer = randomizer
	setElementPosition ( source, node.x, node.y, node.z + Z_OFFSET )
end )

addEventHandler ( "onClientRender", _root, function ()
	if ( UPDATE_LAST > getTickCount() ) then
		return
	end

	for i, ped in ipairs ( getElementsByType ( "ped", getResourceRootElement() ) ) do
		pedAction ( ped )
	end

	UPDATE_LAST = getTickCount() + UPDATE_DELAY
end )

function pedAction ( ped, isLocal )
	if ( not _peds[ped] or _peds[ped].skip ) then
		_peds[ped].skip = false;
		return
	end

	local node = _peds[ped].node
	local next = _peds[ped].next

	local x, y, z = getElementPosition ( ped )
	local nx, ny, nz = node.x, node.y, node.z

	local rot = ( 360 - math.deg ( math.atan2 ( ( ( nx - x ) ), ( ny - y ) ) ) ) % 360
	setPedRotation ( ped, rot )

	if ( _peds[ped].panic ) then
	
		setPedControlState( ped, "sprint", true );
	
	else
	
		setPedControlState( ped, "walk", true );
	
	end
	setPedControlState( ped, "forwards", true );

	if ( getDistanceBetweenPoints2D ( nx, ny, x, y ) <= 0.3 ) then
		local next = _peds[ped].next
		local node = _peds[ped].node
		local neighbours = pathsNodeGetNeighbours ( next.id )
		local rand = arrayGetRandom ( neighbours, _peds[ped].randomizer, node.id )
		_peds[ped].node = next
		_peds[ped].next = getNode ( rand )
	end
end

function arrayGetRandom ( array, randomizer, ignored )
	local temp = {}
	for k, v in pairs ( array ) do
		if ( k ~= ignored ) then
			table.insert ( temp, k )
		end
	end
	if ( #temp > 0 ) then
		return temp[randomizer % #temp + 1]
	else
		return ignored
	end
end

_setPedAnimation = setPedAnimation
function setPedAnimation ( ped, group, anim, loop, walk )
	local p_group, p_anim = getPedAnimation ( ped )
	if ( p_anim ~= anim ) then
		_setPedAnimation ( ped, group, anim, loop, walk )
	end
end

function pedStopPanic ( ped )
	if ( isElement ( ped ) ) then
		_peds[ped].panic = nil
		--_setPedAnimation ( ped, "ped", "WALK_civi" )
	end
end

addEventHandler ( "onClientPlayerWeaponFire", getRootElement(),
	function()
		local px, py, pz = getElementPosition ( source )
		for i, ped in ipairs ( getElementsByType ( "ped" ), getResourceRootElement() ) do
			local x, y, z = getElementPosition ( ped )
			if ( getDistanceBetweenPoints3D ( x, y, z, px, py, pz ) < PANIC_DIST ) then
				if ( _peds[ped] and not _peds[ped].panic ) then
					_peds[ped].panic = true
					setTimer ( pedStopPanic, PANIC_TIME, 1, ped )
				end
			end
		end
	end
)

addEventHandler ( "onClientPedDamage", getRootElement(),
	function (attacker)
		if ( _peds[source] and not _peds[source].panic ) then
			_peds[source].panic = true
			setTimer ( pedStopPanic, PANIC_TIME, 1, ped )
		end
	end
)

if ( DEBUG ) then
	addEventHandler ( "onClientRender", _root, function()
		local px, py, pz = getElementPosition ( _local )
		local sx, sy = guiGetScreenSize()
		local count = 0
		local count_synced = 0
		local count_local = 0
		for i, ped in ipairs ( getElementsByType ( "ped", getResourceRootElement() ) ) do
			local x, y, z = getElementPosition ( ped )
			local owner = getElementData ( ped, "responsible" )
			count = count + 1
			local dist = getDistanceBetweenPoints3D ( x, y, z, px, py, pz )
			if ( dist < SYNC_DIST ) then
				count_synced = count_synced + 1
				if ( isElementOnScreen ( ped ) ) then
					local dx, dy = getScreenFromWorldPosition ( x, y, z )
					if ( dx and dy ) then
						local syncs = "None"
						if ( owner and isElement ( owner ) ) then
							syncs = tostring ( getPlayerName ( owner ) )
						end
						dxDrawText ( "area: "..tostring(getAreaFromPos(getElementPosition(ped))).."\nhealth: "..tostring(getElementHealth(ped)).."\nrot: "..getPedRotation ( ped ).."\nnode: ".._peds[ped].node.id, dx, dy, dx, dy, tocolor ( 255, 255, 255, 255 ), 1, "default", "center" )
					end
				end
			end
			if ( owner == _local ) then
				count_local = count_local + 1
			end
		end
		local dx, dy = sx - 150, sy / 3
		dxDrawText ( "Count: "..count, dx, dy )
		dxDrawText ( "Synced: "..count_synced, dx, dy + 20 )
		dxDrawText ( "Synced by me: "..count_local, dx, dy + 40 )
		dxDrawText ( "Rotation: "..getPedRotation ( _local ), dx, dy + 60 )
		dxDrawText ( "Area ID: "..tostring(getAreaFromPos(getElementPosition(_local))), dx, dy + 80 )
	end )
end