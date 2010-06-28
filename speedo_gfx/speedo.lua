g_root = getRootElement()
g_rootElement = getResourceRootElement( getThisResource() )
g_Player = getLocalPlayer()

c_EnableScaling = true
-- --> These values will be scaled with screen size
-- Offsets from the lower right screen corner
c_XOffset = 10
c_YOffset = 30

c_ImageW = 281
c_ImageH = 200

c_NeedleSpdW =  200;
c_NeedleSpdH =  200;
c_NeedleSpdOffX =  81;
c_NeedleSpdOffY =  0;

c_NeedleFuelW =  140;
c_NeedleFuelH =  140;
c_NeedleFuelOffX =  0;
c_NeedleFuelOffY =  55;

-- <--

fuelTime = 3000; -- 3 sek 

-- All other values are fixed
c_FireTimeMs = 5000
c_BarAlpha = 120
c_BarFlashInterval = 300

g_tFireStart = nil

engOff = false;

needleS_offset = 81;

local vehSpeed = 0;
local fuelTimer = nil;

function drawNeedle()
    if not isPedInVehicle(g_Player) then
        -- Fallback for player exiting car without onClientVehicleStartExit event
        --   (e.g. falling off a bike)
        hideSpeedometer()
        return;
    end
	
    vehSpeed = getVehicleSpeed()
    vehFuel = getVehicleFuel()
    
	-- Draw rotated needle image
    -- Image is scaled exactly 1 degree per kmh of speed, so we can use vehSpeed directly
    
	local white = tocolor( 255, 255, 255 );
	dxDrawImage(g_NeedleSpdX, g_NeedleSpdY, g_NeedleSpdW, g_NeedleSpdH, "needleS.png", vehSpeed, 0, 0, white, true)
    dxDrawImage(g_NeedleFuelX, g_NeedleFuelY, g_NeedleFuelW, g_NeedleFuelH, "needleF.png", vehFuel*127, 0, 0, white, true)

	local blinkerL, blinkerR, isOn = exports.rpg_vehicle_lights:GetIndicatorStatus( );
	
	if( isOn ) then
	
		if( blinkerL ) then
		
			dxDrawImage( g_NeedleSpdX, g_NeedleSpdY, g_NeedleSpdW, g_NeedleSpdH, "blinker_l_on.png", 0, 0, 0, white, true );
		
		elseif( blinkerR ) then
		
			dxDrawImage( g_NeedleSpdX, g_NeedleSpdY, g_NeedleSpdW, g_NeedleSpdH, "blinker_r_on.png", 0, 0, 0, white, true );
		
		end
	end
end


function showSpeedometer()
	syncFuel( );
	fuelTimer = setTimer( syncFuel, fuelTime, 0 );
    guiSetVisible( disc, true)
    guiSetVisible( gage, true)
    addEventHandler("onClientRender", g_root, drawNeedle)
end
function hideSpeedometer()
	if( fuelTimer ) then killTimer( fuelTimer ); fuelTimer = nil; end
    guiSetVisible( disc, false)
    guiSetVisible( gage, false)
	removeEventHandler("onClientRender", g_root, drawNeedle)
end

function getVehicleSpeed()
    if isPedInVehicle(g_Player) then
        local vx, vy, vz = getElementVelocity(getPedOccupiedVehicle(g_Player))
        return math.sqrt(vx^2 + vy^2 + vz^2) * 161
    end
    return 0
end

function getVehicleFuel()
    if isPedInVehicle(g_Player) then
	
		local myVeh = getPedOccupiedVehicle(g_Player);
		
		local rFuel = tonumber( getElementData( myVeh, "Vehicle.RFuel" ) );
		if( not rFuel ) then rFuel = 100; end
		
		local mFuel = tonumber( getElementData( myVeh, "Vehicle.MFuel" ) );
		if( not mFuel ) then mFuel = 100; end
		local retFuel = rFuel /  mFuel;
		
		if( not getVehicleEngineState( myVeh ) ) then
		
			if( not engOff ) then -- First call
			
				displayFuel = retFuel;
			
			end
			engOff = 0;
			fGageMod = 0.1;
			
			displayFuel = displayFuel - 0.1;
			if( displayFuel < 0 ) then displayFuel = 0; end
			return displayFuel;
		
		end
		
		if( engOff  ) then
		
			engOff = engOff + fGageMod;
			
			if( engOff > 1 and fGageMod > 0 ) then
			
				engOff = 1;
				fGageMod = -0.1;
			
			elseif( engOff < retFuel and fGageMod < 0 ) then
			
				engOff = false;
				return retFuel;
			
			end
			
			return engOff;
		
		end
		
        return retFuel;
    end
    return 0
end

function syncFuel( )
    if isPedInVehicle(g_Player) then
		local myVeh = getPedOccupiedVehicle(g_Player);
		if( not getVehicleEngineState( myVeh ) ) then return false; end
	
		local rFuel = tonumber( getElementData( myVeh, "Vehicle.RFuel" ) );
		if( not rFuel ) then rFuel = 100; end
		
		local mFuel = tonumber( getElementData( myVeh, "Vehicle.MFuel" ) );
		if( not mFuel ) then mFuel = 100; end
		
		rFuel = rFuel - ( vehSpeed / 260 );
		if( rFuel <= 0 ) then
		
			setVehicleEngineState( myVeh, false );
			rFuel = 0;
			
		elseif( rFuel <= 1 ) then -- machine starts whining at 1 l
		
			if( math.random( 0, 2 ) == 1 ) then
			
				setVehicleEngineState( myVeh, false );
				
			elseif( getVehicleEngineState( myVeh ) == false ) then
			
				setVehicleEngineState( myVeh, true );
			
			end
		
		end
		
		setElementData( myVeh, "Vehicle.RFuel", tostring(rFuel) );
		setElementData( myVeh, "Vehicle.MFuel", tostring(mFuel) );
	
	end
end

addEventHandler("onClientVehicleEnter", g_root,
	function(thePlayer)
		if thePlayer == g_Player then
			showSpeedometer()
		end
	end
)

addEventHandler("onClientVehicleStartExit", g_root,
	function(thePlayer)
		if thePlayer == g_Player then
			hideSpeedometer()
		end
	end
)

function round(num)
    return math.floor(num + 0.5)
end

function initGui()
    if disc then
        destroyElement(disc)
    end
    g_screenWidth, g_screenHeight = guiGetScreenSize()
    local scale
    if c_EnableScaling then
        scale = (g_screenWidth/1152 + g_screenHeight/864)/2
    else
        scale = 1
    end
	
    g_XOffset = round(c_XOffset*scale)
    g_YOffset = round(c_YOffset*scale)
    g_ImageW = round(c_ImageW*scale)
    g_NeedleFW = round(c_ImageW-200*scale)
    g_NeedleSW = round(c_ImageW-81*scale)
	g_NeedleSO = round(81*scale);
    g_ImageH = round(c_ImageH*scale)
	disc = guiCreateStaticImage(g_screenWidth - g_ImageW - g_XOffset, g_screenHeight - g_ImageH - g_YOffset, g_ImageW, g_ImageH, "newDisc.png", false)

	x, y = guiGetPosition(disc, false)
	
	g_NeedleSpdW = round(c_NeedleSpdW*scale);
	g_NeedleSpdH = round(c_NeedleSpdH*scale);
	g_NeedleSpdX = x + (c_NeedleSpdOffX*scale);
	g_NeedleSpdY = y + (c_NeedleSpdOffY*scale);
	
	g_NeedleFuelW = round(c_NeedleFuelW*scale);
	g_NeedleFuelH = round(c_NeedleFuelH*scale);
	g_NeedleFuelX = x + (c_NeedleFuelOffX*scale);
	g_NeedleFuelY = y + (c_NeedleFuelOffY*scale);
	
end

addEventHandler("onClientResourceStart", g_rootElement,
	function ()
        initGui()
        guiSetVisible(disc, false)
        guiSetVisible(gage, false)
        setTimer(function()
            local w, h = guiGetScreenSize()
            if (w ~= g_screenWidth) or (h ~= g_screenHeight) then
                initGui()
            end
        end, 500, 0)
		if isPedInVehicle(g_Player) then
			showSpeedometer()
		end
	end
);