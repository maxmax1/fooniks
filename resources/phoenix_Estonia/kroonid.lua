-- Replace dollars with EEK.

local myMoney = 0;
local dMoney = 0;
local str = string.format( "%08d.-", myMoney );
local show = true;

local player = getLocalPlayer( );
local rootElement = getRootElement( );
local sx, sy = guiGetScreenSize( );
local posX = sx*0.775;
local posY = sx*0.125;
local posX2 = posX+200;
local posY2 = posY+35;
local color = tocolor( 65, 126, 50, 255 );
local black = tocolor( 0, 0, 0, 255 );

function showFakeMoney( status )

	show = status;

end

function preRenderFake( )

	if( dMoney ~= myMoney ) then
	
		local tempStr1 = string.format( "%08d", dMoney );
		local tempStr2 = string.format( "%08d", myMoney );
		
		local tbl1 = { };
		local tbl2 = { };
		
		for letter in string.gmatch( tempStr1, "%x" ) do
		
			table.insert( tbl1, letter );
		
		end	
		for letter in string.gmatch( tempStr2, "%x" ) do
		
			table.insert( tbl2, letter );
		
		end
		
		for k, v in ipairs( tbl1 ) do
		
			local v1 = tonumber( v );
			local v2 = tonumber( tbl2[k] );
			if( v1 < v2 ) then
			
				v1 = v1 + 1;
			
			elseif( v1 > v2 ) then
			
				v1 = v1 - 1;
			
			end
			
			tbl1[k] = v1;
		
		end
		
		dMoney = table.concat( tbl1 );
	
	end
	str = string.format( "%08d.-", dMoney );

end

function fakeMoney( )

	if( show ) then
		
		local px = posX;
		
		for letter in string.gmatch( str, "%x" ) do
		
			local width = dxGetTextWidth( letter, 1.2, "pricedown" );
			local posF = (17 - width) / 2;	
			
			dxDrawText( letter, px+posF-2, posY-2, px + 17-2, posY2-2, black, 1.2, "pricedown", "left", "top", true, false );			
			dxDrawText( letter, px+posF-2, posY+2, px + 17-2, posY2+2, black, 1.2, "pricedown", "left", "top", true, false );			
			dxDrawText( letter, px+posF+2, posY+2, px + 17+2, posY2+2, black, 1.2, "pricedown", "left", "top", true, false );			
			dxDrawText( letter, px+posF+2, posY-2, px + 17+2, posY2-2, black, 1.2, "pricedown", "left", "top", true, false );			
			
			px = px + 17;
		
		end	
		
		px = posX;
		
		for letter in string.gmatch( str, "%x" ) do
		
			local width = dxGetTextWidth( letter, 1.2, "pricedown" );
			local posF = (17 - width) / 2;	
			
			dxDrawText( letter, px+posF, posY, px + 17, posY2, color, 1.2, "pricedown", "left", "top", true, false );
			
			px = px + 17;
		
		end			
		
		
		dxDrawText( ".-", px-2, posY-2, posX2-2, posY2-2, black, 1.2, "pricedown", "left", "top", true, false );
		dxDrawText( ".-", px-2, posY+2, posX2-2, posY2+2, black, 1.2, "pricedown", "left", "top", true, false );
		dxDrawText( ".-", px+2, posY+2, posX2+2, posY2+2, black, 1.2, "pricedown", "left", "top", true, false );
		dxDrawText( ".-", px+2, posY-2, posX2+2, posY2-2, black, 1.2, "pricedown", "left", "top", true, false );
		dxDrawText( ".-", px, posY, posX2, posY2, color, 1.2, "pricedown", "left", "top", true, false );
	end

end

function InitEEK( )

	DoUpdate( );
	setTimer( DoUpdate, 300, 0 );
	showPlayerHudComponent( "money", false );
	addEventHandler( "onClientRender", rootElement, fakeMoney );
	addEventHandler( "onClientPreRender", rootElement, preRenderFake );

end

addEventHandler( "onClientResourceStart", getResourceRootElement( getThisResource( ) ), InitEEK );

function DoUpdate( )

	myMoney = getPlayerMoney( player );

end

function myPos( name, output )
	
	local x, y, z = getElementPosition( player );
	local int = getElementInterior( player );
	local dim = getElementDimension( player );
	
	if( output == "xml" ) then
	
	else	
	
		outputConsole( x .. ", " .. y .. ", " .. z .. ", " .. int .. ", " .. dim, player );
	
	end

end

addCommandHandler( "myPos", myPos, false );