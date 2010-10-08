local localPlayer = getLocalPlayer()
local rootElement = getRootElement()

local POPUP_TIMEOUT = 15000 --ms
local FADE_DELTA = .03 --alpha per frame
local MAX_ALPHA = .9

local popupQueue = { };
local isShown = false;

local function fadeIn(wnd)
	local function raiseAlpha()
		local newAlpha = guiGetAlpha(wnd) + FADE_DELTA
		if newAlpha <= MAX_ALPHA then
			guiSetAlpha(wnd, newAlpha)
		else
			removeEventHandler("onClientRender", rootElement, raiseAlpha)
		end
	end
	addEventHandler("onClientRender", rootElement, raiseAlpha)
end

local function fadeOut(wnd, realText)
	local function lowerAlpha()
		local newAlpha = guiGetAlpha(wnd) - FADE_DELTA
		if newAlpha >= 0 then
			guiSetAlpha(wnd, newAlpha)
		else
			removeEventHandler("onClientRender", rootElement, lowerAlpha)
			destroyElement(wnd)
			
			table.remove(popupQueue, 1)
			if #popupQueue > 0 then
				showHelpPopup( popupQueue[1] );
			else
				isShown = false;
			end
		end
	end
	addEventHandler("onClientRender", rootElement, lowerAlpha)
end

function showHelpPopup( realText )

	if( tonumber( exports.cookies:Cookie( "showmotd" ) ) == 0 ) then
	
		return false;
	
	end
	
	local screenX, screenY = guiGetScreenSize( )
	local wndPopup = guiCreateWindow( 0, screenY - 20, screenX, 0, '', false ) --350
	local text = "";
	
	if( type( realText ) == "table" ) then
	
		if( #realText > 1 ) then
		
			local t = POPUP_TIMEOUT / #realText;
			for k = 2, #realText, 1 do
			
				setTimer( guiSetText, t, 1, wndPopup, realText[k] );
			
			end
		
		end
		text = realText[1];
	
	else
	
		text = tostring( realText );
	
	end
		
	guiSetText( wndPopup, text )
	guiSetAlpha( wndPopup, 0 )
	guiWindowSetMovable( wndPopup, false )
	guiWindowSetSizable( wndPopup, false )
	
	fadeIn( wndPopup )
	setTimer( fadeOut, POPUP_TIMEOUT, 1, wndPopup, realText );
	isShown = true;

end

function addHelpPopup( str )

	table.insert( popupQueue, str );
	if( not isShown ) then showHelpPopup( popupQueue[1] ); end

end

addEvent( "onMotdShow", true );
addEventHandler( "onMotdShow", rootElement, addHelpPopup );