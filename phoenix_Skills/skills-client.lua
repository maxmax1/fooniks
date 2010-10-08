-- Some stuff...

local SELF_DEBUG = false;
local debugSkill = 0;
local debugXP = 0;
local debugLevel = 0;

local showing = false;
local moveX = 0;
drawText = "......";
drawImage = ":phoenix_Skills/images/levelup.png";

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

-- Local skill level data
local sLevels = { };

addEvent( "onSkillLevelData", true );
addEventHandler( "onSkillLevelData", getRootElement( ), 

	function ( data )
	
		for k, v in pairs( data ) do
		
			local tbl = { };
			for k2, v2 in pairs( v ) do
			
				tbl[k2] = v2;
			
			end
			sLevels[k] = tbl;
		
		end
	
	end

);

function GetSkillLevelData( skillId, levelId )

	if( sLevels[skillId] ) then
	
		return sLevels[skillId][levelId];
	
	end
	return false;

end

function showSkillDraw( text, image, isFullPath )

	if( showing ~= false ) then return false; end
	
	if( image and not isFullPath ) then
	
		drawImage = ":phoenix_Skills/images/" .. image .. ".png";
	
	elseif( image ) then
	
		drawImage = image;
	
	end
	
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
					dxDrawImage( posX+10, posY+9, 50, 50, drawImage );
					
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
				
				if( SELF_DEBUG ) then
				
					local txt = string.format( "Skill: %s, xp: %s, nextlevel at: %s",
						tostring( debugSkill ),
						tostring( debugXP ),
						tostring( debugLevel )
					);
					dxDrawText( txt, 0, sy-(sy*0.3), sx, sy, tocolor( 255, 255, 255, 255 ), 1, "default",  "center", "top" );
				
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

addEventHandler ( "onClientPlayerDamage", player, 

	function ( attacker, weapon, bodypart, loss )
	
		if( source ~= player and attacker == player and bodypart == 9 ) then -- Didnt shoot himself in the head.
		
			-- Give double points for HS
			triggerServerEvent( "onSkillWeaponShot", player, weapon, 50 );
		
		end
	
	end

);

addEvent( "onSkillDebugUpdate", true );
addEventHandler ( "onSkillDebugUpdate", getRootElement( ), 

	function ( skill, xp, level )
	
		debugSkill = skill;
		debugXP = xp;
		debugLevel = level;
	
	end

);

addCommandHandler( "skilldebug", 

	function ( )
	
		SELF_DEBUG = true;
		triggerServerEvent( "onSkillDebugRequest", player );
	
	end

, false, false );