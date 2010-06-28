--[[
	@package RPG Vehicle lights
	@version $id flashers.lua 1 11-08-2009 23:56 GMT+1 Alexander de Jong $
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
 
-- config variables
CMD_FLASHERS = "ohutuled";
KEY_FLASHERS = "rshift";

-- Some variables
isFlashing = false;
isFlashOn = false;
theVehicle = nil;
local frames = 1;

function startFlashers()
	if frames == 20 then
		if isFlashOn == true then
			setVehicleLightState(theVehicle, 0, 1);
			setVehicleLightState(theVehicle, 1, 1);
			setVehicleLightState(theVehicle, 2, 1);
			setVehicleLightState(theVehicle, 3, 1);
			isFlashOn = false;
		else
			setVehicleLightState(theVehicle, 0, 0);
			setVehicleLightState(theVehicle, 1, 0);
			setVehicleLightState(theVehicle, 2, 0);
			setVehicleLightState(theVehicle, 3, 0);
			isFlashOn = true;
		end
		frames = 0;
	end
	
	frames = frames + 1;
end

function cmdFlashers()
	local vehicle, player;
	player = getLocalPlayer();
	
	vehicle = getPedOccupiedVehicle(player);
	
	if not vehicle then
		outputChatBox("You need to be in a vehicle to use this function.", player);
		return;
	end
	
	local vehicleModel = tostring(getElementModel(vehicle));
	
	if table.find(no_light_vehicle, vehicleModel) and table.find(two_wheels, vehicleModel) then
		outputChatBox("These vehicles are not competable with this function.", player);
		return;
	end
	
	if getVehicleController(vehicle) ~= player then
		outputChatBox("You need to be the driver of this vehicle.", player);
		return;
	end
	
	theVehicle = vehicle;
	
	turnIndicatorOff(vehicle)
	
	if isFlashing == true then
		removeEventHandler("onClientRender", getRootElement(), startFlashers);
		if getElementData(vehicle, "vehicle.override.handheld") then
			setVehicleOverrideLights(vehicle, 1);
			setElementData(vehicle, "vehicle.override.handheld", false);
		end
		isFlashing = false;
	else
		if getVehicleOverrideLights(vehicle) == 1 then
			setVehicleOverrideLights(vehicle, 2);
			setElementData(vehicle, "vehicle.override.handheld", true);
		end
		addEventHandler("onClientRender", getRootElement(), startFlashers);
		isFlashing = true;
	end
end

addCommandHandler(CMD_FLASHERS, cmdFlashers);

if( KEY_FLASHERS ) then

	addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), function()
		bindKey(KEY_FLASHERS, "down", CMD_FLASHERS);
	end);
	
end

function GetFlash( )

	return isFlashing;

end

function StopFlash( vehicle )

	removeEventHandler("onClientRender", getRootElement(), startFlashers);
	if getElementData(vehicle, "vehicle.override.handheld") then
		setVehicleOverrideLights(vehicle, 1);
		setElementData(vehicle, "vehicle.override.handheld", false);
	end
	isFlashing = false;

end