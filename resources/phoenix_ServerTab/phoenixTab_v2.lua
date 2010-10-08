-- Config

local fadeStep = 10;

local btn1 = "lctrl";
local btn2 = "tab";

local DEBUG = true;

-- Some Bools and etc, that are used on the tab.

local tabShowing = false;
local tabAlpha = 0;
local fadeStatus = 0;

-- Needed Stuff

local thePlayer = getLocalPlayer( );
local rootElement = getRootElement( );
local sx, sy = guiGetScreenSize( );

-- displayData

local charName = false;
local charAge = false;
local charLevel = false;
local charMoney = false;
local charJob = false;
local skinImg = false;

-- Buttons that show the tab.

local isBtn1 = false;
local isBtn2 = false;
local isBound = false;

-- Positions

local trapezoidPos = {  };

local charaImgPos = {  };
local charaTxtPos = {  };
local charaButPos = {  };

local imgFile = "back_1024x768.png";
local scale = ( sx / 1024 );

trapezoidPos[1] = 0;
trapezoidPos[2] = sy - ( 784 * scale );
trapezoidPos[3] = ( 1024 * scale );
trapezoidPos[4] = ( 784 * scale );

charaImgPos[1] = ( sx - ( 127.5 * scale ) ) / 2;
charaImgPos[2] = sy - ( 422 * scale );
charaImgPos[3] = ( 127.5 * scale );
charaImgPos[4] = ( 117 * scale );

charaTxtPos[1] = sy - ( 290 * scale );
charaTxtPos[2] = sy - ( 236 * scale );
charaTxtPos[3] = sy - ( 203 * scale );
charaTxtPos[4] = sy - ( 170 * scale );
charaTxtPos[5] = sy - ( 137 * scale );
charaTxtPos[6] = sx * 0.48;

charaButPos[1] = { };
charaButPos[1][1] = 363 * scale;
charaButPos[1][2] = sy - ( 65 * scale );
charaButPos[1][3] = 505 * scale;
charaButPos[1][4] = sy - ( 39 * scale );

charaButPos[2] = { };
charaButPos[2][1] = 522 * scale;
charaButPos[2][2] = sy - ( 65 * scale );
charaButPos[2][3] = 664 * scale;
charaButPos[2][4] = sy - ( 39 * scale );

-- The Script

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

function getData( )

	local charName = false;
	local charAge = false;
	local charLevel = false;
	local charMoney = false;
	local charJob = false;
	
	local skinId = getElementModel( thePlayer );
	if( skinId ) then
	
		skinImg = string.format( ":phoenix_Characters/files/skins/%03d.png", skinId );
	
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
	showPlayerHudComponent( "health", not tabShowing );
	showPlayerHudComponent( "money", not tabShowing );
	showPlayerHudComponent( "radar", not tabShowing );
	showPlayerHudComponent( "vehicle_name", not tabShowing );
	showPlayerHudComponent( "weapon", not tabShowing );
	showCursor( tabShowing );
	setPedFrozen( thePlayer, tabShowing );

end

function RealInput( )

	if( tabShowing ) then
	
		fadeStatus = -fadeStep;
	
	else
	
		getData( );
	
		tabShowing = true;
		fadeStatus = fadeStep;
		OnTabStatus( );
	
	end

end

function IsMouseOver( mouseX, mouseY, eCords )

	return ( mouseX >= eCords[1] and mouseX <= eCords[3] and mouseY >= eCords[2] and mouseY <= eCords[4] );

end

function onClick( button, state, aX, aY )

	if( not tabShowing or button ~= "left" or state ~= "down" ) then
	
		return false;
	
	end
		
	if( IsMouseOver( aX, aY, charaButPos[1] ) ) then
	
		triggerServerEvent( "onPlayerInfo", thePlayer, thePlayer ); 
		RealInput( );
	
	elseif( IsMouseOver( aX, aY, charaButPos[2] ) ) then
	
		triggerServerEvent( "onCharactersRequest", thePlayer, thePlayer ); 
		RealInput( );
	
	end	

end

addEventHandler( "onClientResourceStart", getResourceRootElement( getThisResource( ) ),  

	function ()
	
		addEventHandler( "onClientClick", rootElement, onClick );
	
		addEventHandler("onClientRender", rootElement, 
		
			function ()
			
				if( tabShowing ) then
				
					local backColor = tocolor( 0, 0, 0, 125 * ( tabAlpha / 255 ) );
					
					local trapezoidCol = tocolor( 255, 255, 255, 255 * ( tabAlpha / 255 ) );					
					local txtColor = tocolor( 255, 255, 255, 255 * ( tabAlpha / 255 ) );
					
					local nameCol = tocolor( 200, 200, 0, 255 * ( tabAlpha / 255 ) );
					
					local hover = tocolor( 255, 255, 255, 38 * ( tabAlpha / 255 ) );
					
					local curX, curY = getCursorPosition( );
					curX = sx * curX;
					curY = sy * curY;
					
					-- Fade Everything out.
					--dxDrawRectangle( 0, 0, sx, sy, backColor );
					
					-- Draw Bottom Trapezoid			
					
					dxDrawImage( trapezoidPos[1], trapezoidPos[2], trapezoidPos[3], trapezoidPos[4], imgFile, 0, 0, 0, trapezoidCol, true );
					
					-- Draw Center Text
					dxDrawText( "Mängimise jätkamiseks vajuta: " .. btn1 .. "+" .. btn2, 0, sy-80, sx, sy-3, txtColor, 1, "default-bold", "center", "bottom", true, true, true );
					
					-- Draw Active window
					
					if( cActive == "characters" ) then
					
					
					else
					
						dxDrawImage( trapezoidPos[1], trapezoidPos[2], trapezoidPos[3], trapezoidPos[4], "charaback.png", 0, 0, 0, trapezoidCol, true );
						
						if( IsMouseOver( curX, curY, charaButPos[1] ) ) then
						
							dxDrawRectangle( charaButPos[1][1], charaButPos[1][2], charaButPos[1][3]-charaButPos[1][1], charaButPos[1][4]-charaButPos[1][2], hover, true );
						
						elseif( IsMouseOver( curX, curY, charaButPos[2] ) ) then
						
							dxDrawRectangle( charaButPos[2][1], charaButPos[2][2], charaButPos[2][3]-charaButPos[2][1], charaButPos[2][4]-charaButPos[2][2], hover, true );
						
						end						
						
						dxDrawImage( charaImgPos[1], charaImgPos[2], charaImgPos[3], charaImgPos[4],  skinImg or ":phoenix_Characters/files/skins/00-1.png", 0, 0, 0, trapezoidCol, true );
						
						dxDrawText( charName or "John Doe", 0, charaTxtPos[1], sx, sy, nameCol, 2, "default-bold", "center", "top", false, false, true );
						
						dxDrawText( charAge or "18", charaTxtPos[6], charaTxtPos[2], sx, sy, txtColor, 1.3, "default-bold", "left", "top", false, false, true );
						dxDrawText( charLevel or "99", charaTxtPos[6], charaTxtPos[3], sx, sy, txtColor, 1.3, "default-bold", "left", "top", false, false, true );
						dxDrawText( charMoney or "0,0 .-", charaTxtPos[6], charaTxtPos[4], sx, sy, txtColor, 1.3, "default-bold", "left", "top", false, false, true );
						dxDrawText( charJob or "Pole", charaTxtPos[6], charaTxtPos[5], sx, sy, txtColor, 1.3, "default-bold", "left", "top", false, false, true );
					
					end
					
					-- Debug
					if( DEBUG ) then
					
						dxDrawText( 
						"imgF: " .. imgFile .. "\n " .. 
						"imgW: " .. trapezoidPos[3] .. "\n " .. 
						"imgH: " .. trapezoidPos[4] .. "\n " .. 
						" sx: " .. sx .. "\n sy: " .. sy
						
						, 0, 0, sx, sy-300, txtColor, 1, "default-bold", "center", "center", true, true, true );
					
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