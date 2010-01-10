local x,y = guiGetScreenSize()
local width = 0
local korjatud = nil
local pooleli = nil
local tx, ty, tz
local kast = nil
kodutu = {[77]=true, [78]=true, [79]=true, [95]=true, [134]=true, [135]=true, [137]=true, [200]=true, [212]=true, [213]=true, [230]=true, [239]=true} --78

function sobramisHudMore()
	if (width+1 ~= 100) then
		dxDrawLine ( x/2-50, y/1.1, x/2-50+(width+1), y/1.1, tocolor ( 0, 255, 0, 255 ), 7 )
		width = width + 1
	elseif (width+1 == 100) then
		triggerServerEvent("onKodutuSuccess", getRootElement())
		removeEventHandler("onClientRender",getRootElement(), sobramisHudMore)
		width = 0
		korjatud = true
		setPedAnimation(getLocalPlayer())
end
end

function sobramisHudLess()
	if (width-1 >= 1) then
		dxDrawLine ( x/2-50, y/1.1, x/2-50+(width-1), y/1.1, tocolor ( 0, 255, 0, 255 ), 7 )
		width = width - 1
	elseif (width-1 == 0) then
		removeEventHandler("onClientRender",getRootElement(), sobramisHudLess)
		width = 0
		pooleli = nil
end
end


function trashMouseDown()
	if pooleli then
		removeEventHandler("onClientRender",getRootElement(), sobramisHudLess)
	end
	
	addEventHandler("onClientRender",getRootElement(), sobramisHudMore)
	setPedAnimation(getLocalPlayer(), "ON_LOOKERS", "point_loop")
end


function trashMouseUp()
	if not korjatud then
		removeEventHandler("onClientRender",getRootElement(), sobramisHudMore)
		addEventHandler("onClientRender",getRootElement(), sobramisHudLess)
		pooleli = true
	end
	korjatud = nil
	setPedAnimation(getLocalPlayer())
end

function target(element)
	if kodutu[getElementModel(source)] then
	
		local ontrash = string.find(getElementID( element ), "trashBin")
		tx, ty, tz = getElementPosition(element)
			if ontrash then
				kast = element
				outputChatBox("(( Prügikastis sobramiseks hoia all paremat hiirenuppu! ))", 0, 255, 255 )
				bindKey("mouse2", "up", trashMouseUp)
				bindKey("mouse2", "down", trashMouseDown)
				addEventHandler("onClientRender",getRootElement(), unbind)
			end
	end
end
addEventHandler ( "onClientPlayerTarget", getRootElement(), target)

function unbind()
local px, py, pz = getElementPosition(getLocalPlayer())
	if getDistanceBetweenPoints3D(tx, ty, tz, px, py, pz) >= 3 then
		unbindKey("mouse2", "up", trashMouseUp)
		unbindKey("mouse2", "down", trashMouseDown)
		kast = nil
		removeEventHandler("onClientRender",getRootElement(), unbind)
	end
end