-- Some Bools and etc, that are used on the tab.

local tabShowing = false;
local tabAlpha = 0;
local fadeStatus = 0;

local menuShowing = false;
local menuAllDrawn = false;
local menuBaseX = 0;
local menuBaseY = 0;

-- Buttons that show the tab.

local btn1 = "lctrl";
local btn2 = "tab";

local isBtn1 = false;
local isBtn2 = false;
local isBound = false;

-- Needed Stuff

local player = getLocalPlayer( );
local rootElement = getRootElement( );
local sx, sy = guiGetScreenSize( );

-- Config

local fadeStep = 10;

-- TabButtons
local btns = { };

local tbl = { };
tbl["name"] = "Sõbrad";
tbl["menu"] = 1;
table.insert( btns, tbl );

local tbl = { };
tbl["name"] = "Karakter";
tbl["menu"] = 2;
table.insert( btns, tbl );

-- Menus For Buttons

local Menus = { };

local tbl = { };
tbl[1] = { };
tbl[1]["name"] = "Tulekul";
table.insert( Menus, tbl );

local tbl = { };
tbl[1] = { };
tbl[1]["name"] = "Info";
tbl[1]["event"] = "onPlayerInfo";
tbl[2] = { };
tbl[2]["name"] = "Vaheta";
tbl[2]["event"] = "onCharactersRequest";
table.insert( Menus, tbl );

-- Code Start

function TabClick( button, state, aX, aY )
	
	if( button == "left" and state == "down" ) then
	
		if( aY >= sy-75 and aY <= sy-25 ) then
		
			local baseX = sx - 50 - ( #btns * 130 );
			if( aX > baseX and aX < sx - 50 ) then
			
				for k, v in ipairs( btns ) do
				
					if( aX >= baseX and aX <= baseX + 125 ) then
					
						if( v["menu"] ) then
						
							menuAllDrawn = false;
							menuShowing = v["menu"];
							menuBaseX = baseX;
							menuBaseY = ( sy - 100 );
						
						end					
						
						return true;
					
					end
					baseX = baseX + 130;
				
				end
			
			end
		
		end
		
		if( menuShowing ) then
		
			if( aX >= menuBaseX and aX <= menuBaseX + 115 ) then
			
				if( aY < sy - 100 and aY > menuBaseY ) then
				
					local bY = menuBaseY + 5;
					
					for k, v in ipairs( Menus[menuShowing] ) do
					
						if( aY >= bY and aY <= bY + 20 ) then
						
							if( v["event"] ) then
							
								triggerServerEvent( v["event"], player, player ); 
								fadeStatus = -fadeStep*2;
							
							end
							
							return true;
						
						end
						bY = bY + 25;
						
					end
				
				end
			
			end
		
			menuShowing = false;
			menuBaseX = 0;
			menuBaseY = 0;
		
		end
	
	end

end

function ChangeButtons( new1, new2 )

	if( isBound ) then

		unbindKey( btn1, "down", CheckForInput );
		unbindKey( btn2, "down", CheckForInput );

		unbindKey( btn1, "up", CheckForInput );
		unbindKey( btn2, "up", CheckForInput );
	
	end
	
	btn1 = new1;
	btn2 = new2;
	
	bindKey( btn1, "down", CheckForInput );
	bindKey( btn2, "down", CheckForInput );

	bindKey( btn1, "up", CheckForInput );
	bindKey( btn2, "up", CheckForInput );
	isBound = true;
	
	SaveBtns( );

end

function CheckForInput( key, state )

	if( key == btn1 ) then
	
		if( state == "down" and not isBtn1 ) then
		
			isBtn1 = true;
			
		elseif( state == "up" and isBtn1 ) then
		
			isBtn1 = false;
		
		end
	
	elseif( key == btn2 ) then
	
		if( state == "down" and not isBtn2 ) then
		
			isBtn2 = true;
			
		elseif( state == "up" and isBtn2 ) then
		
			isBtn2 = false;
		
		end
	
	end
	
	if( isBtn1 and isBtn2 ) then
	
		RealInput( );
		
		isBtn1 = not isBtn1;
		isBtn2 = not isBtn2;
	
	end

end

function OnTabStatus( )

	toggleAllControls( not tabShowing );
	showPlayerHudComponent( "ammo", not tabShowing );
	showPlayerHudComponent( "area_name", not tabShowing );
	showPlayerHudComponent( "armour", not tabShowing );
	showPlayerHudComponent( "breath", not tabShowing );
	showPlayerHudComponent( "clock", not tabShowing );
	showPlayerHudComponent( "health", not tabShowing );
	showPlayerHudComponent( "money", not tabShowing );
	showPlayerHudComponent( "radar", not tabShowing );
	showPlayerHudComponent( "vehicle_name", not tabShowing );
	showPlayerHudComponent( "weapon", not tabShowing );
	showCursor( tabShowing );
	setPedFrozen( player, tabShowing );
	
	if( tabShowing ) then
	
		addEventHandler( "onClientClick", rootElement, TabClick );
	
	else
	
		removeEventHandler( "onClientClick", rootElement, TabClick );
	
	end

end

function RealInput( )

	if( tabShowing ) then
	
		fadeStatus = -fadeStep;
	
	else
	
		tabShowing = true;
		fadeStatus = fadeStep;
		OnTabStatus( );
	
	end

end

addEventHandler( "onClientResourceStart", rootElement,  

	function ()
	
		addEventHandler("onClientRender", rootElement, 
		
			function ()
			
				if( tabShowing ) then	
									
					local backColor = tocolor( 0, 0, 0, 200 * ( tabAlpha / 255 ) );
					local bottomBarColor = tocolor( 0, 0, 0, 100 * ( tabAlpha / 255 ) );
					local menuBackColor = tocolor( 0, 50, 50, 255 * ( tabAlpha / 255 ) );
					local txtColor = tocolor( 255, 255, 255, 255 * ( tabAlpha / 255 ) );
					
					-- Fade Everything out.
					dxDrawRectangle( 0, 0, sx, sy, backColor );	
					
					if( menuShowing and Menus[menuShowing] ~= nil ) then
					
						if( menuAllDrawn ) then
						
							menuBaseY = ( sy - 100 ) - 15 - ( #Menus[menuShowing] * 25 );
						
						else
						
							menuBaseY = menuBaseY - 10;
							if( menuBaseY <= ( sy - 100 ) - 15 - ( #Menus[menuShowing] * 25 ) ) then
							
								menuAllDrawn = true;
								menuBaseY = ( sy - 100 ) - 15 - ( #Menus[menuShowing] * 25 );
							
							end
						
						end
						
						dxDrawRectangle( menuBaseX, menuBaseY, 125, (sy - 100) - menuBaseY, bottomBarColor );
						
						local bX = menuBaseX + 5;
						local bY = menuBaseY + 5;
						
						for k, v in ipairs( Menus[menuShowing] ) do
						
							if( bY < sy - 100 ) then
						
								local height = 20;
								if( bY + height >= sy - 100 ) then
								
									height = sy - 100 - bY;
								
								end
						
								dxDrawRectangle( bX, bY, 115, height, menuBackColor );
								dxDrawText( v["name"], bX, bY, bX + 115, bY + height, txtColor, 1, "default-bold", "center", "center" );
								bY = bY + 25;
							
							end
						
						end
					
					end
						
					-- Draw Bottom Tab
					dxDrawRectangle( 0, sy-100, sx, 100, bottomBarColor );
					
					local baseX = sx - 50 - ( #btns * 130 );
					
					for k, v in ipairs( btns ) do
					
						dxDrawRectangle( baseX, sy-75, 125, 50, tocolor( 0, 100, 100, 255 * ( tabAlpha / 255 ) ) );
					
						dxDrawText( v["name"], baseX, sy-75, baseX+125, sy-25, txtColor, 1, "pricedown", "center", "center" ); 
						baseX = baseX + 130;
					
					end					
					
					if( fadeStatus ~= 0 ) then
					
						tabAlpha = tabAlpha + fadeStatus;
						if( tabAlpha <= 0 ) then
						
							tabShowing = false;
							OnTabStatus( );
							tabAlpha = 0;
							fadeStatus = 0;
						
						elseif( tabAlpha >= 255 ) then
						
							tabAlpha = 255;
							fadeStatus = 0;
						
						end
					
					end					
				
				else
				
					local x = sx * 0.044;
					local y = sy * 0.88 - 10;
					local w = sx * 0.18;
					local h = sy * 0.1;					
					local txtColor = tocolor( 255, 255, 255, 255 );
					
					dxDrawText( "Vajuta: " .. btn1 .. " + " .. btn2, x, y, x+w, y+w, txtColor, 1, "default", "center", "center" );
				
				end
			
			end
			
		);
		
	end
	
);

function SaveBtns( )

	local xml = xmlLoadFile ( "phoenixTab.xml" );
	local child = false;
	
	if( xml ) then
	
		child = xmlFindChild( xml, "btn1", 0 );
		if( child ) then
		
			xmlNodeSetValue( child, btn1 );
		
		end
		
		child = xmlFindChild( xml, "btn2", 0 );
		if( child ) then
		
			xmlNodeSetValue( child, btn2 );
		
		end
	
	end
	
	xmlSaveFile( xml );
	xmlUnloadFile( xml );

end

function LoadBtns( )

	local t1 =  "lctrl";
	local t2 = "tab";
	local added = false;

	local xml = xmlLoadFile ( "phoenixTab.xml" );
	if ( xml ~= false ) then
			
		local child = xmlFindChild( xml, "btn1", 0 );
		if( child ~= false ) then
		
			t1 = xmlNodeGetValue( child );
			
			if( t1 ) then
			
				child = xmlFindChild( xml, "btn2", 0 );
				if( child ~= false ) then
				
					t2 = xmlNodeGetValue( child );
					added = true;
				
				end
			
			end
		
		end
	
	end
	
	if( not added ) then
	
		xml = xmlCreateFile( "phoenixTab.xml", "tab" );
		
		child = xmlCreateChild( xml, "btn1" );
		if( child ) then
		
			xmlNodeSetValue( child, t1 );
		
		end
		
		child = xmlCreateChild( xml, "btn2" );
		if( child ) then
		
			xmlNodeSetValue( child, t2 );
		
		end
		xmlSaveFile( xml );
		xmlUnloadFile( xml );
		
	end
	
	ChangeButtons( t1, t2 );

end


addEventHandler( "onClientResourceStart", getResourceRootElement( getThisResource( ) ), LoadBtns );
