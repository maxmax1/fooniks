local Open = false;
local serviceWind = nil;
local TabPanel = nil;
local TabPanel = nil;

local player = getLocalPlayer( );
local sx, sy = guiGetScreenSize( );

local buying = 0;
local buyBtn = nil;

function createWindow( title )

	serviceWind = guiCreateWindow( (sx-300)/2, (sy-250)/2, 300, 250, title, false );
	TabPanel = guiCreateTabPanel( 0.05, 0.1, 0.9, 0.75, true, serviceWind );
	local closeBtn = guiCreateButton( 0.75, 0.86, 0.2, 0.15, "Sulge", true, serviceWind ); 
	
	addEventHandler("onClientGUIClick", closeBtn, 
		function ( button, state )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			destroyElement( serviceWind );
			Open = false;
		
		end
	, false);	

end

addEvent( "onPlayerServiceRequest", true );
addEventHandler( "onPlayerServiceRequest", getRootElement(),

	function ( bizName, serviceElem, serviceName, serviceType, available, cost, canBuy )
	
		-- TODO: Different Types of menus...
		local serviceId = tonumber( getElementData( serviceElem, "serviceType" ) );
		
		createWindow( bizName .. " - " .. serviceName );
		local someTab = guiCreateTab( "Teenus", TabPanel );
		guiCreateLabel( 0.1, 0.1, 0.4, 0.1, "Teenus:", true, someTab );	
		guiCreateLabel( 0.1, 0.2, 0.4, 0.1, "Saadaval:", true, someTab );
		
		guiCreateLabel( 0.4, 0.1, 0.4, 0.1, serviceName, true, someTab );	
	
		if( serviceType == "single" ) then
		
			guiCreateLabel( 0.1, 0.3, 0.4, 0.1, "Hind:", true, someTab );
			
			local lbl1 = guiCreateLabel( 0.4, 0.2, 0.4, 0.1, available .. " ", true, someTab );
			local lbl2 = guiCreateLabel( 0.4, 0.3, 0.4, 0.1, cost .. " EEK", true, someTab );
			
			if( available > 0 ) then
			
				buyBtn = guiCreateButton( 0.525, 0.86, 0.2, 0.15, "Osta", true, serviceWind ); 
				addEventHandler("onClientGUIClick", buyBtn, 
					function ( button, state )
					
						if( button ~= "left" or state ~= "up" ) then return false; end				
						triggerServerEvent( "onPlayerServicePurchase", player, serviceElem, cost );
						destroyElement( serviceWind );
						Open = false;
					
					end
				, false);			
				
				guiLabelSetColor( lbl1, 0, 255, 0 );
			
			else
			
				guiLabelSetColor( lbl1, 255, 0, 0 );
			
			end
			
			if( canBuy ) then
			
				guiLabelSetColor( lbl2, 0, 255, 0 );
			
			else
			
				guiLabelSetColor( lbl2, 255, 0, 0 );
			
			end
		elseif( serviceType == "slider" ) then
		
			local aStr = "Jah";
			if( available == 0 ) then aStr = "Ei"; end
			
			local lbl1 = guiCreateLabel( 0.4, 0.2, 0.4, 0.1, aStr, true, someTab );
			guiCreateLabel( 0.1, 0.3, 0.4, 0.1, "Ostan:", true, someTab );
			guiCreateLabel( 0.1, 0.4, 0.4, 0.1, "Hind:", true, someTab );
			
			buying = 0;
			
			local lbl1 = guiCreateLabel( 0.4, 0.3, 0.4, 0.1, buying .. " L", true, someTab );
			local lbl2 = guiCreateLabel( 0.4, 0.4, 0.4, 0.1, cost*buying .. " EEK", true, someTab );
			
			local slider = guiCreateScrollBar( 0.1, 0.5, 0.8, 0.1, true, true, someTab );
			local maximum = 0;
			
			if( serviceId == 2 ) then -- bensiin
			
				if(isPedInVehicle( player ) ) then
				
					local myVeh = getPedOccupiedVehicle( player );
					local rFuel = tonumber( getElementData( myVeh, "Vehicle.RFuel" ) );
					if( not rFuel ) then rFuel = 100; end
					
					local mFuel = tonumber( getElementData( myVeh, "Vehicle.MFuel" ) );
					if( not mFuel ) then mFuel = 100; end
					maximum = mFuel-rFuel;
					
				else
				
					available = 0;
					exports.phoenix_Chat:OocInfo( "Pead olema masinas." );
				
				end
			
			end
			
			addEventHandler( "onClientGUIScroll", slider,

				function ()
				
					local val = math.floor( ( guiScrollBarGetScrollPosition( slider ) / 100 ) * maximum );
					buying = val;
					
					guiSetText( lbl1, buying .. " L" );
					guiSetText( lbl2, buying*cost .. " EEK" );
					
					if( val > 0 ) then
					
						guiSetEnabled( buyBtn, true );
						
					else
					
						guiSetEnabled( buyBtn, false );
					
					end
				
				end
			
			);
			
			if( available > 0 ) then
				buyBtn = guiCreateButton( 0.525, 0.86, 0.2, 0.15, "Osta", true, serviceWind );
				guiSetEnabled( buyBtn, false );
				addEventHandler("onClientGUIClick", buyBtn, 
					function ( button, state )
					
						if( button ~= "left" or state ~= "up" ) then return false; end				
						triggerServerEvent( "onPlayerServicePurchase", player, serviceElem, cost, buying );
						destroyElement( serviceWind );
						Open = false;
					
					end
				, false);
			end		
		end
	end
	
);

--[[

configisse erinevad servicetüübid kus määratakse ära mis pakke ja kui palju teenus vajab.

onPlayerServiceRequest kontrollib kas vastava service jaoks jätkub firmal pakke, kui ei siis
kuvatakse aken kus osta nupp disabled ja saadaval kogus on 0(punasega). Kui aga jätkub siis saadab
serverile eventi mis kontrollib kas kliendil on piisavalt raha, kui ei kuvab errori, kui jah siis täidab teenuse
ja annab kliendile märku, võtab talt raha ning lisab firma arvele, ning eemaldab firmalt vastava koguse pakke.


]]--