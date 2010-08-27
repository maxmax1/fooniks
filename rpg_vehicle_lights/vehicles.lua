--[[
	@package RPG Vehicle lights
	@version $id vehicles.lua 1 11-08-2009 22:13 GMT+1 Alexander de Jong $
	@license GNU General Public License v3
	@copyright Dexora, web solutions (c) 2009
	
	This file is part of RPG Vehicle lights.

	RPG Vehicle lights is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	RPG Vehicle lights is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with RPG Vehicle lights.  If not, see <http://www.gnu.org/licenses/>.
]]

-- We ain't going to include every vehicle, only the vehicles that are needed.
two_wheels = {
	'581', '509', '481', '462', '521', 
	'463', '510', '522', '461', '448',
	'468', '586', '523'
}

goverment = {
	'416', '433', '427', '490', '528', 
	'407', '544', '470', '598', '596', 
	'597', '599', '432', '601', '428'
}

no_light_vehicle = {
	'537', '538', '569', '590', '441', 
	'464', '501', '465', '564', '594', 
	'606', '607', '610', '590', '569', 
	'611', '584', '608', '435', '450', 
	'591', '538', '537', '449', '472', 
	'473', '493', '595', '484', '430', 
	'453', '452', '446', '454', '592', 
	'553', '577', '488', '511', '497', 
	'548', '563', '512', '476', '593', 
	'425', '519', '520', '460', '417',
	'469', '487', '513'
}

BINDS_ENABLED = false;

function table.find(t, s)
	for k, v in pairs(t) do
		--outputChatBox("k: " .. tostring(k) .. " v: " .. tostring(v));
		if k == s or v == s then
			--outputChatBox("true: k: " .. tostring(k) .. " v: " .. tostring(v));
			return true;
		end
	end
	
	--outputChatBox("false");
	return false;
end