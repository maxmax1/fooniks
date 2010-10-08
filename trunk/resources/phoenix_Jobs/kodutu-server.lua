foundBottle = { 5, 10, 25 }
foundFood = {"pirni", "õuna", "kanakoiva"}

function onKodutuSuccess()
	if client then
	local midasai = math.random(1,3)
		
		if midasai == 1 then
			suvapudel = math.random ( 1, #foundBottle )
			outputChatBox("Leidsid prügikastist pudeli, millel on taaramärgistus " ..foundBottle[suvapudel].. "'le SAKile", client, 0, 255, 255)
		elseif midasai == 2 then
			suvatoit = math.random ( 1, #foundFood )
			setElementHealth(client, getElementHealth(client)+math.random(5,50))
			outputChatBox("Leidsid prügikastist " ..foundFood[suvatoit].. " ning sõid selle ära.", client, 0, 255, 255)
		elseif midasai == 3 then
			outputChatBox("Leidsid prügikastist kasutatud kondoomi ja pühkisid käed pükste külge", client, 0, 255, 255)
		end
	end
end
addEvent("onKodutuSuccess", true)
addEventHandler( "onKodutuSuccess", getRootElement(), onKodutuSuccess, true)