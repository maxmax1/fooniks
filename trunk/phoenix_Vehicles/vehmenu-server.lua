local masin = nil
alarmedMasin = {}

function alarmOn(veh)
	if client then
		setElementData(veh, "vAlarm", 1)
		setVehicleOverrideLights( veh, 2 )
		setTimer(vilgatus, 100, 3, veh)
		setVehicleLocked( veh, true)
		text = "paneb masina puldiga signalisatsiooni alla"
		exports.phoenix_Chat:setChatMessage( client, true, " ", "*", "*", 10, text, 219, 219, 112 )
	end
end
addEvent("alarmOn", true)
addEventHandler("alarmOn", getRootElement(), alarmOn)

function alarmOff(veh)
	if client then
		setVehicleOverrideLights ( veh, 2 )
		setElementData(veh, "vAlarm", 0)
		setTimer(vilgatus, 230, 1, veh)
		setVehicleLocked( veh, false)
			if getElementData(veh, "vAlarmed") then
				alarmuntrigger(masin)
			end
		text = "lülitab masina signalisatsiooni alt välja"
		exports.phoenix_Chat:setChatMessage( client, true, " ", "*", "*", 10, text, 219, 219, 112 )
	end
end
addEvent("alarmOff",true)
addEventHandler("alarmOff",getRootElement(),alarmOff)

function kustuta()
	if client then
		removeElementData(client, "clickMenu")
	end
end
addEvent("kustuta",true)
addEventHandler("kustuta",getRootElement(),kustuta)

function vilgatus(veh)
    if ( getVehicleOverrideLights ( veh ) ~= 2 ) then
        setVehicleOverrideLights ( veh, 2 )
    else
        setVehicleOverrideLights ( veh, 1 )
    end
end
		
function vehexit(thePlayer, seat, jacker)
	if isVehicleLocked( source ) then
		if getVehicleType(source) ~= "Bike" and getVehicleType(source) ~= "Quad" then
			cancelEvent()
			text = "katsub linki, aga uksed on lukus"
			exports.phoenix_Chat:setChatMessage( thePlayer, true, " ", "*", "*", 10, text, 219, 219, 112 )
		end
	end
end	
addEventHandler ( "onVehicleStartExit", getRootElement(), vehexit )

function vehenter(enteringPlayer, seat, jacked, door)
	local lukus = isVehicleLocked(source)
	local alarm = getElementData(source, "vAlarm")
	if lukus and alarm == 0 then
	
		text = "üritab ust avada, kuid see on lukus"
		exports.phoenix_Chat:setChatMessage( enteringPlayer, true, " ", "*", "*", 10, text, 219, 219, 112 )
		
	elseif alarm == 1 and not getElementData(source, "vAlarmed") then
		masin = source
		local trigger = setTimer(trigger, 500, 1, masin)
		local untrigger = setTimer(alarmuntrigger, 10000, 1, masin)
		setElementData(masin, "vAlarmed", true)
		text = "üritab ust avada ja käivitab masinal alarmi"
		exports.phoenix_Chat:setChatMessage( enteringPlayer, true, " ", "*", "*", 10, text, 219, 219, 112 )
		
	end
end
addEventHandler ( "onVehicleStartEnter", getRootElement(), vehenter )

function trigger(masin)
	alarmedMasin[tonumber(getElementData(masin, "vehicleId"))] = setTimer(alarmtuli, 500, 0, masin)
	local vx, vy, vz = getElementPosition(masin)
	triggerClientEvent ( "alarmactivated", getRootElement(), masin, vx, vy, vz)
end

function alarmuntrigger(masin)
	killTimer(alarmedMasin[tonumber(getElementData(masin, "vehicleId"))])
	setVehicleOverrideLights ( masin, 1 )
	triggerClientEvent ( "stopalarm", getRootElement(), masin)
	removeElementData(masin, "vAlarmed")
end

function alarmtuli(masin)
    
	if ( getVehicleOverrideLights ( masin ) ~= 2 ) then
		
		setVehicleOverrideLights ( masin, 2 )
		
    else
        
		setVehicleOverrideLights ( masin, 1 )
		
    end
end
		
function CarMenuLock(veh)
	if client then
	
		local lukus = isVehicleLocked(veh)
		local masinas = isPedInVehicle(client)
		local text = '';
		
		if lukus and masinas then
		
			setVehicleLocked(veh, false)
			text = "avab masina nupust"
			
		elseif lukus and masinas == false then
		
			setVehicleLocked(veh, false)
			text = "avab masina võtmefga"
			
		elseif lukus == false and masinas then
		
			setVehicleLocked(veh, true)
			text = "lukustab masina nupust"
			
		elseif lukus == false and masinas == false then
		
			setVehicleLocked(veh, true)
			text = "lukustab masina võtmega"
		end
		
		exports.phoenix_Chat:setChatMessage( client, true, " ", "*", "*", 10, text, 219, 219, 112 )
		
	end
end
addEvent("CarMenuLock",true)
addEventHandler("CarMenuLock",getRootElement(),CarMenuLock)

function vehWindows(veh)
	if client then
		if tonumber(getElementData(veh, "vWindow")) == 1 then
			setElementData(veh, "vWindow", 0)
			text = "kerib akna alla"
		else
			setElementData(veh, "vWindow", 1)
			text = "kerib akna üles"
		end
	
		exports.phoenix_Chat:setChatMessage( client, true, " ", "*", "*", 10, text, 219, 219, 112 )
	end
end
addEvent("vehWindows",true)
addEventHandler("vehWindows",getRootElement(),vehWindows)

function cwhisper(message, messageType)
	if messageType == 0 and isPedInVehicle(source) then
	local masin = getPedOccupiedVehicle(source)
		if getElementData(masin, "vWindow") == 0 then
			outputChatBox("(Aken kinni) " ..getPlayerName(source).. ": " ..message, getVehicleOccupant(masin), 219, 219, 112)
		end
	end
end
addEventHandler( "onPlayerChat", getRootElement(), cwhisper )

