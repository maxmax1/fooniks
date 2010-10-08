--[[
	@package RPG Vehicle lights
	@version $id lights.lua 1 11-08-2009 23:47 GMT+1 Alexander de Jong $
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

CMD_TOGGLE_LIGHTS = "tuled";
KEY_TOGGLE_LIGHTS = "l";

function cmdToggleLights()
	local vehicle, player;
	player = getLocalPlayer();
	
	vehicle = getPedOccupiedVehicle(player);
	
	if not vehicle then
		return;
	end
	
	local vehicleModel = tostring(getElementModel(vehicle));
	
	if table.find(no_light_vehicle, vehicleModel) then
		outputChatBox("These vehicles are not competable with this function.", player);
		return;
	end
	
	if getVehicleController(vehicle) ~= player then
		outputChatBox("You need to be the driver of this vehicle.", player);
		return;
	end
	
	local blinkerL, blinkerR, isOn = GetIndicatorStatus( );
	if( blinkerL or blinkerR ) then
	
		stopIndicators( vehicle );
		setVehicleOverrideLights(vehicle, 1);
	
	end
	
	if( GetFlash( ) ) then
	
		StopFlash( vehicle );
		setVehicleOverrideLights(vehicle, 1);
	
	end
	
	if getVehicleOverrideLights(vehicle) == 1 then
		setVehicleOverrideLights(vehicle, 2);
	else
		setVehicleOverrideLights(vehicle, 1);
	end
end

addCommandHandler(CMD_TOGGLE_LIGHTS, cmdToggleLights);

addEventHandler("onClientResourceStart", getResourceRootElement( getThisResource( ) ),

	function( )
	
		if( BINDS_ENABLED ) then
		
			bindKey(KEY_TOGGLE_LIGHTS, "down", CMD_TOGGLE_LIGHTS);
		
		end
	
	end

);