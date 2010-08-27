--[[
	@package RPG Vehicle lights
	@version $id police_flashers.lua 1 17-08-2009 18:23 GMT+1 Alexander de Jong $
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

-- Config variables
CMD_PFLASHERS = "vilkurid";
CMD_PFLASHERS_SPEED = "kvilkurid";
CMD_PFLASHERS_SPEED_GET = "kvilkurid";
KEY_PFLASHERS = "n";
POLICE_FLASHING_SPEED = 10; -- Frame count.
ALLOWED_POLICE_FLASHING_SPEED = {'10', '15', '20', '25'};

isPoliceFlasherOn = false;
isPoliceFalashing = false;
pVehicle = nil;
local frames = 1;

function startPoliceFlashers()
	if frames == POLICE_FLASHING_SPEED then
		if isPoliceFalashing == true then
			setVehicleLightState(pVehicle, 0, 1);
			setVehicleLightState(pVehicle, 1, 0);
			isPoliceFalashing = false;
		else
			setVehicleLightState(pVehicle, 0, 0);
			setVehicleLightState(pVehicle, 1, 1);
			isPoliceFalashing = true;
		end
		frames = 0;
	end
	
	frames = frames + 1;
end

function cmdPoliceFlashers()
	local player;
	player = getLocalPlayer();
	
	pVehicle = getPedOccupiedVehicle(player);
	
	if not pVehicle then
		outputChatBox("You need to be in a vehicle to use this function.", player);
		return;
	end
	
	local vehicleModel = tostring(getElementModel(pVehicle));
	
	if table.find(no_light_vehicle, vehicleModel) and table.find(two_wheels, vehicleModel) and not table.find(goverment, vehicleModel) then
		outputChatBox("These vehicles are not competable with this function.", player);
		return;
	end
	
	if getVehicleController(pVehicle) ~= player then
		outputChatBox("You need to be the driver of this vehicle.", player);
		return;
	end
	
	turnIndicatorOff(pVehicle)
	
	if isPoliceFlasherOn == true then
		removeEventHandler("onClientRender", getRootElement(), startPoliceFlashers);
		if getElementData(pVehicle, "vehicle.override.handheld") then
			setVehicleOverrideLights(pVehicle, 1);
			setElementData(pVehicle, "vehicle.override.handheld", false);
		end
		isPoliceFlasherOn = false;
	else
		if getVehicleOverrideLights(pVehicle) == 1 then
			setVehicleOverrideLights(pVehicle, 2);
			setElementData(pVehicle, "vehicle.override.handheld", true);
		end
		addEventHandler("onClientRender", getRootElement(), startPoliceFlashers);
		isPoliceFlasherOn = true;
	end
end

function cmdSetPoliceFlasherSpeed(cmd, speed)
	speed = speed or nil;
	
	local vehicle, player;
	player = getLocalPlayer();
	
	vehicle = getPedOccupiedVehicle(player);
	
	if not vehicle then
		return;
	end
	
	local vehicleModel = tostring(getElementModel(vehicle));
	
	
	if table.find(no_light_vehicle, vehicleModel) and table.find(two_wheels, vehicleModel) and not table.find(goverment, vehicleModel) then
		outputChatBox("These vehicles are not competable with this function.", player);
		return;
	end
	
	if getVehicleController(vehicle) ~= player then
		outputChatBox("You need to be the driver of this vehicle.", player);
		return;
	end
	
	if speed == nil then
		-- get the speed
		outputChatBox("Your current flasher speed " .. tostring(POLICE_FLASHING_SPEED), player);
		return;
	end
	
	if not table.find(ALLOWED_POLICE_FLASHING_SPEED, speed) then
		outputChatBox("This speed '" .. speed .. "' is not allowed", player);
		return;
	end
	
	POLICE_FLASHING_SPEED = tonumber(speed);
end

addCommandHandler(CMD_PFLASHERS_SPEED, cmdSetPoliceFlasherSpeed);
addCommandHandler(CMD_PFLASHERS_SPEED_GET, cmdSetPoliceFlasherSpeed);
addCommandHandler(CMD_PFLASHERS, cmdPoliceFlashers);

if( KEY_PFLASHERS ) then

	addEventHandler("onClientResourceStart", getResourceRootElement( getThisResource( ) ),
	
		function()
		
			if( BINDS_ENABLED ) then
			
				bindKey(KEY_PFLASHERS, "down", CMD_PFLASHERS);
			
			end
		
		end
	
	);

end