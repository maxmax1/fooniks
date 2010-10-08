-- TODO: Has player right to interact with vehicle...

local veh = nil
alarmedMasinh = {}
aknata = { [424]=true, [429]=true, [439]=true, [457]=true, [476]=true, [480]=true, [485]=true, [486]=true, [500]=true, [506]=true, [530]=true, [531]=true, [532]=true, [533]=true, [536]=true, [539]=true, [567]=true, [568]=true, [571]=true, [572]=true, [575]=true }

function cCarMenu()
	CarMenu = guiCreateWindow(787,445,96,164,"",false)
	guiWindowSetSizable(CarMenu,false)
	btnAlarm = guiCreateButton(0.0938,0.122,0.8125,0.122,"Alarm peale",true,CarMenu)
	btnLukk = guiCreateButton(0.0938,0.264,0.8125,0.122,"Lukusta",true,CarMenu)
	btnPagasnik = guiCreateButton(0.0938,0.406,0.8125,0.122,"Pagasnik",true,CarMenu)
	btnKindalaegas = guiCreateButton(0.0938,0.548,0.8125,0.122,"Kindalaegas",true,CarMenu)
	btnAken = guiCreateButton(0.0938,0.69,0.8125,0.122,"Aken alla",true,CarMenu)
	btnSulge = guiCreateButton(0.0938,0.832,0.8125,0.122,"Sulge",true,CarMenu)
end

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), 
	function ()
		cCarMenu()
		addEventHandler("onClientGUIClick", btnSulge, CarMenuSulge, false)
		addEventHandler("onClientGUIClick", btnAlarm, CarMenuAlarm, false)
		addEventHandler("onClientGUIClick", btnLukk, CarMenuLukk, false)
		addEventHandler("onClientGUIClick", btnPagasnik, CarMenuTulekul, false)
		addEventHandler("onClientGUIClick", btnKindalaegas, CarMenuTulekul, false)
		addEventHandler("onClientGUIClick", btnAken, CarMenuAken, false)
		guiSetVisible(CarMenu, false)
	end
)

bindKey ("mouse3", "down",
        function()
                showCursor( not isCursorShowing() )
        end)
		
bindKey ("m", "down",
        function()
                showCursor( not isCursorShowing() )
        end)
		
		
function carclick(button, state, ax, ay, wx, wy, wz, element)

	if getElementData(getLocalPlayer(), "clickMenu") then
		return false;
	end
	
	if button == "right" and element and getElementType(element) == "vehicle" and state=="down" and tostring(getVehicleType(element)) ~= "BMX" then
	
		local x, y, z = getElementPosition(getLocalPlayer())
		
		if getDistanceBetweenPoints3D(x, y, z, wx, wy, wz)<=30 then
		
			if tonumber(getElementData(element, "vAlarm")) == 1 then
				guiSetText(btnAlarm, "Alarm maha")
			else
				guiSetText(btnAlarm, "Alarm peale")
			end
			if isVehicleLocked(element) then
				guiSetText(btnLukk, "Ava")
			else
				guiSetText(btnLukk, "Lukusta")
			end
			
			if tonumber(getElementData(element, "vWindow")) == 0 then
				guiSetText(btnAken, "Ava Aken")
			else
				guiSetText(btnAken, "Sulge Aken")
			end
			
			guiSetVisible(CarMenu, true)
			guiSetPosition ( CarMenu, ax, ay, false )
			guiSetEnabled ( btnLukk, false )
			guiSetEnabled ( btnPagasnik, false )
			guiSetEnabled ( btnKindalaegas, false )
			guiSetEnabled ( btnAken, false )
			setElementData(getLocalPlayer(), "clickMenu", true)
			veh = element
			if getDistanceBetweenPoints3D(x, y,z, wx, wy, wz)<=2 then
				guiSetEnabled ( btnPagasnik, true )
			end
			if getDistanceBetweenPoints3D(x, y,z, wx, wy, wz)<=1 then
				guiSetEnabled ( btnLukk, true )
			end
			
			if isPedInVehicle ( getLocalPlayer() ) then
				guiSetEnabled ( btnLukk, true )
				guiSetEnabled ( btnKindalaegas, true )
				guiSetEnabled ( btnAken, true )
			end
			if tostring(getVehicleType(element)) == "Bike" or tostring(getVehicleType(element)) == "Quad" then
				guiSetVisible ( btnPagasnik, false )
				guiSetVisible ( btnLukk, false )
				guiSetVisible ( btnAken, false )
			elseif tostring(getVehicleType(element)) == "Boat" then
			guiSetVisible ( btnAken, false )
			guiSetVisible ( btnLukk, false )
			elseif aknata[getElementModel(element)] then
			guiSetVisible ( btnAken, false )
			else
				guiSetVisible ( btnPagasnik, true )
				guiSetVisible ( btnLukk, true )
				guiSetVisible ( btnAken, true )
				guiSetEnabled ( btnAken, true );
			end
		end
	end
end
addEventHandler("onClientClick", getRootElement(), carclick, true)

function CarMenuSulge(button, state)

	if button == "left" then
	
		guiSetVisible(CarMenu, false)
		showCursor(false)
		triggerServerEvent("kustuta", getRootElement())
		local veh = nil
		
	end
	
end

function CarMenuAlarm(button, state)
	if button == "left" then
		local x, y, z = getElementPosition(veh)
		if tonumber(getElementData(veh, "vAlarm")) == 0 then
			playSound3D("files/sounds/alarmkinni.wav", x, y, z, false)
			triggerServerEvent("alarmOn", getRootElement(), veh)
			CarMenuSulge(button, state)
		else
			playSound3D("files/sounds/alarmlahti.wav", x, y, z, false)
			triggerServerEvent("alarmOff", getRootElement(), veh)
			CarMenuSulge(button, state)
		end
	end
end

function CarMenuLukk(button, state)
	if button == "left" then
		triggerServerEvent("CarMenuLock", getRootElement(), veh)
		CarMenuSulge(button, state)
	end
end

function alarmactivated(masin, vx, vy, vz)
	alarmedMasinh[tonumber(getElementData(masin, "vehicleId"))] = playSound3D("files/sounds/alarmon.wav", vx, vy, vz, true)
	setSoundMaxDistance(alarmon, 20)
end
addEvent( "alarmactivated", true )
addEventHandler( "alarmactivated", getRootElement(), alarmactivated )

function stopalarm(masin)
	stopSound( alarmedMasinh[tonumber(getElementData(masin, "vehicleId"))] )
end
addEvent( "stopalarm", true )
addEventHandler( "stopalarm", getRootElement(), stopalarm )

function CarMenuTulekul(button, state)
	if button == "left" then
		CarMenuSulge(button, state)
		outputChatBox("Tulekul", source)
	end
end

function CarMenuAken(button, state)
	if button == "left" then
		triggerServerEvent("vehWindows", getRootElement(), veh)
		CarMenuSulge(button, state)
	end
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
--------------------------------------------