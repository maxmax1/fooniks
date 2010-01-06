local masin = nil

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
		cancelEvent()
		text = "katsub linki, aga uksed on lukus"
		exports.phoenix_Chat:setChatMessage( thePlayer, true, " ", "*", "*", 10, text, 219, 219, 112 )
	end
end	
addEventHandler ( "onVehicleStartExit", getRootElement(), vehexit )

function vehenter(enteringPlayer, seat, jacked, door)
	local lukus = isVehicleLocked(source)
	local alarm = getElementData(source, "vAlarm")
	if lukus and alarm == 0 then
	
		text = "üritab ust avada, kuid see on lukus"
		exports.phoenix_Chat:setChatMessage( enteringPlayer, true, " ", "*", "*", 10, text, 219, 219, 112 )
		
	elseif alarm == 1 then
	
		local vx, vy, vz = getElementPosition(source)
		triggerClientEvent ( "alarmactivated", getRootElement(), vx, vy, vz)
		setVehicleOverrideLights ( source, 2 )
		masin = source
		setTimer(alarmtuli, 500, 59, masin)
		text = "üritab ust avada ja käivitab masinal alarmi"
		exports.phoenix_Chat:setChatMessage( enteringPlayer, true, " ", "*", "*", 10, text, 219, 219, 112 )
		
	end
end
addEventHandler ( "onVehicleStartEnter", getRootElement(), vehenter )

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
			text = "avab masina võtmega"
			
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