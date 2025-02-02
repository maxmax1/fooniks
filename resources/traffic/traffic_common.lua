
function enum ( args, prefix )
	for i, v in ipairs ( args ) do
		if ( prefix ) then _G[v] = prefix..i
		else _G[v] = i end
	end
end

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

beforeLeft, beforeRight = 0, 0

function calcNodeLaneOffset ( node, rot, randomizer )
	local left = node.leftlanes or beforeLeft
	local right = node.rightlanes or beforeRight
	if beforeLeft ~= left or beforeRight ~= right then
		-- outputChatBox("leftlanes: "..left.." rightlanes: "..right)
	end
	beforeLeft, beforeRight = left, right
	local x, y = math.cos ( math.rad ( rot ) ) * LANE_OFFSET, math.sin ( math.rad ( rot ) ) * LANE_OFFSET
	
	-- doesn't work as good, we don't know the lanes direction
	if ( left + right <= 1 ) then
		return 0, 0
	elseif ( left - right == 0 ) then
		return x, y
	elseif ( left == 2 or right == 2 ) then
		local lane = 0 --math.random(0,1)
		-- outputChatBox("2 lanes choose lane "..lane)
		if ( lane == 0 ) then
			return x, y
		else
			return -x, -y
		end
	end
	return 0, 0
end

function verifyNodeFlags ( flags )
	if ( not flags ) then
		return true
	end
	if ( not ALLOW_EMERGENCY and flags.emergency ) then
		return false
	end
	if ( not ALLOW_PARKINGS and flags.parking ) then
		return false
	end
	return true
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

function pathsNodeGetNeighbours ( nodeID, debug )
	local areaID = getAreaFromNode ( nodeID )
	if ( debug ) then outputChatBox ( "pathsNodeGetNeighbours > areaID: "..tostring ( areaID ).."("..tostring ( nodeID )..")" ) end
	local sorted = {}
	for n, d in pairs ( AREA_PATHS[areaID][nodeID].neighbours or {} ) do
		local node = AREA_PATHS[areaID][nodeID]
		if ( verifyNodeFlags ( node.flags ) ) then
			sorted[n] = d
		elseif ( debug ) then
			outputChatBox ( "pathsNodeGetNeighbours > invalid flags" )
		end
	end
	return sorted
end

function getMatrixOffsets(matrix, x, y, z)
	
	local offX = x * matrix[1][1] + y * matrix[2][1] + z * matrix[3][1] + matrix[4][1]
	local offY = x * matrix[1][2] + y * matrix[2][2] + z * matrix[3][2] + matrix[4][2]
	local offZ = x * matrix[1][3] + y * matrix[2][3] + z * matrix[3][3] + matrix[4][3]

	return offX, offY, offZ
end

function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end

function table.concatIndex(tab)
    local indexString = ""
    for index in pairs(tab) do
		indexString = index.." "
	end
    return indexString
end

function table.deepcopy(t)
	local known = {}
	local function _deepcopy(t)
		local result = {}
		for k,v in pairs(t) do
			if type(v) == 'table' then
				if not known[v] then
					known[v] = _deepcopy(v)
				end
				result[k] = known[v]
			else
				result[k] = v
			end
		end
		return result
	end
	return _deepcopy(t)
end

-- modifiers: v - verbose (all subtables), n - normal, s - silent (no output), dx - up to depth x, u - unnamed
function var_dump(...)
	-- default options
	local verbose = true
	local outputDirectly = true
	local noNames = false
	local indentation = "      "
	local depth = nil

	local name = nil
	local output = {}
	for k,v in ipairs(arg) do
		-- check for modifiers
		if type(v) == "string" and k < #arg and v:sub(1,1) == "-" then
			local modifiers = v:sub(2)
			if modifiers:find("v") ~= nil then
				verbose = true
			end
			if modifiers:find("s") ~= nil then
				outputDirectly = false
			end
			if modifiers:find("n") ~= nil then
				verbose = false
			end
			if modifiers:find("u") ~= nil then
				noNames = true
			end
			local s,e = modifiers:find("d%d+")
			if s ~= nil then
				depth = tonumber(string.sub(modifiers,s+1,e))
			end
		-- set name if appropriate
		elseif type(v) == "string" and k < #arg and name == nil and not noNames then
			name = v
		else
			if name ~= nil then
				name = ""..name..": "
			else
				name = ""
			end
 
			local o = ""
			if type(v) == "string" then
				table.insert(output,name..type(v).."("..v:len()..") \""..v.."\"")
			elseif type(v) == "userdata" then
				local elementType = "no valid MTA element"
				if isElement(v) then
					elementType = getElementType(v)
				end
				table.insert(output,name..type(v).."("..elementType..") \""..tostring(v).."\"")
			elseif type(v) == "table" then
				local count = 0
				for key,value in pairs(v) do
					count = count + 1
				end
				table.insert(output,name..type(v).."("..count..") \""..tostring(v).."\"")
				if verbose and count > 0 and (depth == nil or depth > 0) then
					table.insert(output," {")
					for key,value in pairs(v) do
						-- calls itself, so be careful when you change anything
						local newModifiers = "-s"
						if depth == nil then
							newModifiers = "-sv"
						elseif  depth > 1 then
							local newDepth = depth - 1
							newModifiers = "-svd"..newDepth
						end
						local keyString, keyTable = var_dump(newModifiers,key)
						local valueString, valueTable = var_dump(newModifiers,value)
 
						if #keyTable == 1 and #valueTable == 1 then
							table.insert(output,indentation.."["..keyString.."] => "..valueString)
						elseif #keyTable == 1 then
							table.insert(output,indentation.."["..keyString.."] =>")
							for k,v in ipairs(valueTable) do
								table.insert(output,indentation..v)
							end
						elseif #valueTable == 1 then
							for k,v in ipairs(keyTable) do
								if k == 1 then
									table.insert(output,indentation.."["..v)
								elseif k == #keyTable then
									table.insert(output,indentation..v.."]")
								else
									table.insert(output,indentation..v)
								end
							end
							table.insert(output,indentation.." => "..valueString)
						else
							for k,v in ipairs(keyTable) do
								if k == 1 then
									table.insert(output,indentation.."["..v)
								elseif k == #keyTable then
									table.insert(output,indentation..v.."]")
								else
									table.insert(output,indentation..v)
								end
							end
							for k,v in ipairs(valueTable) do
								if k == 1 then
									table.insert(output,indentation.." => "..v)
								else
									table.insert(output,indentation..v)
								end
							end
						end
					end
					table.insert(output," }")
				end
			else
				table.insert(output,name..type(v).." \""..tostring(v).."\"")
			end
			name = nil
		end
	end
	local string = ""
	for k,v in ipairs(output) do
		if outputDirectly then
			outputConsole(v)
			-- outputDebugString(v)
		end
		string = string..v
	end
	return string, output
end