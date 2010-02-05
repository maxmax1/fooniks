-- Some stuff...

local showing = false;
local moveX = 0;
drawText = "......";

-- Some values needed everywhere...
local player = getLocalPlayer( );
local rootElement = getRootElement( );
local sx, sy = guiGetScreenSize( );

local posY = sy*0.3;
local posX = sx;

drawWidth = 200;
ticksShown = 0;

textOffx = 20;
textOffy = 10;

function showSkillDraw( text )

	if( showing ~= false ) then return false; end
	
	showing = true;
	moveX = -15; -- make it appear
	drawText = text;
	posX = sx;
	
	return true;

end

addEvent( "onShowSkillDraw", true );
addEventHandler( "onShowSkillDraw", getRootElement( ), showSkillDraw );

function StartHide( )

	moveX = 15;

end

addEventHandler( "onClientResourceStart", rootElement,  

	function ()
	
		addEventHandler("onClientRender", rootElement, 
		
			function ()
			
				if( showing ) then	
				
					posX = posX + moveX;
				
					dxDrawRectangle( posX, posY, sx-posX, 75, tocolor( 0, 0, 0, 200 ) );
					dxDrawImage( posX+10, posY+9, 50, 50, ":phoenix_Skills/images/levelup.png" );
					
					dxDrawText( drawText, posX+65, posY+9 );
					
					if( moveX ~= 0 ) then
						
						if( posX < sx - 125 ) then
						
							moveX = 0;
							setTimer( StartHide, 3000, 1 );
							
						elseif( posX >= sx ) then
						
							moveX = 0;
							showing = false;
						
						end
					
					end
				
				end
			
			end
			
		);
		
	end
	
);

addEventHandler ( "onClientPlayerWeaponFire", player, 

	function ( weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement )
	
		if( hitElement ~= false and hitElement ~= nil and getElementType( hitElement ) ~= false ) then
		
			triggerServerEvent( "onSkillWeaponShot", player, weapon );
		
		end
	
	end

);