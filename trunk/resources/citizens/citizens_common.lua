
function positive ( num )
	if ( num < 0 ) then
		num = 0 - num
	end
	return num
end

function iif ( cond, arg1, arg2 )
	if ( cond ) then
		return arg1
	end
	return arg2
end

function getAreaFromPos ( x, y, z )
	x = x + 3000
	y = y + 3000
	if ( ( 0 < x and x < 6000 ) and ( 0 < y and y < 6000 ) ) then
		return math.floor ( y / AREA_HEIGHT ) * ( 6000 / AREA_HEIGHT ) + math.floor ( x / AREA_WIDTH )
	end
	return false
end

function getAreaFromNode ( nodeID )
	if ( nodeID ) then
		return math.floor ( nodeID / AREA_STEP )
	end
	return nil
end

function getNode ( nodeID )
	local areaID = getAreaFromNode ( nodeID )
	if ( areaID ) then
		return AREA_PATHS[areaID][nodeID]
	end
	return nil
end

-----------------------------

function pathsNodeFindClosest ( x, y, z )
	local areaID = getAreaFromPos ( x, y, z )
	local minDist, minNode
	local nodeX, nodeY, dist
	for id,node in pairs( AREA_PATHS[areaID] ) do
		nodeX, nodeY = node.x, node.y
		dist = (x - nodeX)*(x - nodeX) + (y - nodeY)*(y - nodeY)
		if not minDist or dist < minDist then
			minDist = dist
			minNode = node
		end
	end
	return minNode
end

function pathsNodeGetNeighbours ( nodeID )
	local areaID = getAreaFromNode ( nodeID )
	local sorted = {}
	for n, d in pairs ( AREA_PATHS[areaID][nodeID].neighbours or {} ) do
		sorted[n] = d
	end
	return sorted
end