--[[
	@package RPG Vehicle lights
	@version $id indicators.lua 1 11-08-2009 22:13 GMT+1 Alexander de Jong $
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

-- First of all some configurations.
KEY_LEFT_INDICATOR = ","; -- Keyboard: <
KEY_RIGHT_INDICATOR = "."; -- Keyboard: >

CMD_LEFT_INDICATOR = "ic_left";
CMD_RIGHT_INDICATOR = "ic_right";

-- Some variables.
indicatorInfo = nil; -- Will be a table later
isLeftOn = false;
isRightOn = false;
local frameCount = 1;

-- Allright now the indicators, they will be handled in the event onClientRender
function flashLeft()
	if getVehicleOverrideLights(indicatorInfo['vehicle']) == 1 then
		setVehicleOverrideLights(indicatorInfo['vehicle'], 2);
		setVehicleLightState(indicatorInfo['vehicle'], 1, 1);
		setVehicleLightState(indicatorInfo['vehicle'], 2, 1);
		setElementData(indicatorInfo['vehicle'], "vehicle.override.handheld", true);
	end
	
	if indicatorInfo['flashed'] == true then
		setVehicleLightState(indicatorInfo['vehicle'], 0, 1);
		setVehicleLightState(indicatorInfo['vehicle'], 3, 1);
		indicatorInfo['flashed'] = false;
	else
		setVehicleLightState(indicatorInfo['vehicle'], 0, 0);
		setVehicleLightState(indicatorInfo['vehicle'], 3, 0);
		indicatorInfo['flashed'] = true;
	end
end

function flashRight()
	if getVehicleOverrideLights(indicatorInfo['vehicle']) == 1 then
		setVehicleOverrideLights(indicatorInfo['vehicle'], 2);
		setVehicleLightState(indicatorInfo['vehicle'], 0, 1);
		setVehicleLightState(indicatorInfo['vehicle'], 3, 1);
		setElementData(indicatorInfo['vehicle'], "vehicle.override.handheld", true);
	end
	
    if indicatorInfo['flashed'] == true then
		setVehicleLightState(indicatorInfo['vehicle'], 1, 1);
		setVehicleLightState(indicatorInfo['vehicle'], 2, 1);
		indicatorInfo['flashed'] = false;
	else
		setVehicleLightState(indicatorInfo['vehicle'], 1, 0);
		setVehicleLightState(indicatorInfo['vehicle'], 2, 0);
		indicatorInfo['flashed'] = true;
	end
end

-- Now we will make the onClientRender func
function startIndicator()
	if frameCount == 20 then
		if indicatorInfo['left'] == true then
			flashLeft();
		else
			flashRight();
		end
		
		frameCount = 0;
	end
	
	frameCount = frameCount + 1;
end

function stopIndicators( vehicle )

	turnIndicatorOff( vehicle );
	isLeftOn = false;
	isRightOn = false;

end

function turnIndicatorOff(vehicle)
	removeEventHandler("onClientRender", getRootElement(), startIndicator);
	if getElementData(vehicle, "vehicle.override.handheld") == true then
		setVehicleOverrideLights(vehicle, 1);
		setElementData(vehicle, "vehicle.override.handheld", false);
	end
	
	setVehicleLightState(vehicle, 0, 0);
	setVehicleLightState(vehicle, 1, 0);
	setVehicleLightState(vehicle, 2, 0);
	setVehicleLightState(vehicle, 3, 0);
end

-- Now we will make the command func
function cmdIndicator(cmd)
	cmd = cmd or nil;
	local vehicle, player;
	player = getLocalPlayer();
	vehicle = getPedOccupiedVehicle(player);
	
	local vehicleModel = tostring(getElementModel(vehicle));
	
	if table.find(no_light_vehicle, vehicleModel) and table.find(two_wheels, vehicleModel) then
		outputChatBox("These vehicles are not competable with this function.", player);
		return;
	end
	
	if not vehicle then
		return;
	end
	
	if getVehicleController(vehicle) ~= player then
		outputChatBox("You need to be the driver of this vehicle.", player);
		return;
	end

	setVehicleOverrideLights(vehicle, 1);
	
	if cmd == CMD_LEFT_INDICATOR then
		if isLeftOn == true then
			-- Turn it off.
			isLeftOn = false;
			turnIndicatorOff(vehicle);
			
			return;
		end
	
		if isRightOn == true then
			-- Turn it off.
			isRightOn = false;
			turnIndicatorOff(vehicle);
		end
		
		indicatorInfo = {
			flashed = false,
			vehicle = vehicle,
			left = true,
		}
		
		isLeftOn = true;
		
		addEventHandler("onClientRender", getRootElement(), startIndicator);
	else
		if isRightOn == true then
			-- Turn it off.
			isRightOn = false;
			turnIndicatorOff(vehicle);
			
			return;
		end
		
		if isLeftOn == true then
			-- Turn it off.
			isLeftOn = false;
			turnIndicatorOff(vehicle);
		end
		
		indicatorInfo = {
			flashed = false,
			vehicle = vehicle,
			left = false,
		}
		
		isRightOn = true;
		
		addEventHandler("onClientRender", getRootElement(), startIndicator);
	end
end

addCommandHandler(CMD_LEFT_INDICATOR, cmdIndicator);
addCommandHandler(CMD_RIGHT_INDICATOR, cmdIndicator);

addEventHandler("onClientVehicleEnter", getRootElement(), function()
	setVehicleOverrideLights(source, 1);
end);

addEventHandler("onClientResourceStart", getResourceRootElement( getThisResource( ) ),

	function()
	
		if( BINDS_ENABLED ) then
		
			bindKey(KEY_LEFT_INDICATOR, "down", CMD_LEFT_INDICATOR);
			bindKey(KEY_RIGHT_INDICATOR, "down", CMD_RIGHT_INDICATOR);
		
		end
	
	end
);

function GetIndicatorStatus( )

	local flashed;
	if( not indicatorInfo ) then
		flashed = false;
	else
		flashed = indicatorInfo['flashed'];
	end
	return isLeftOn, isRightOn, flashed;

end