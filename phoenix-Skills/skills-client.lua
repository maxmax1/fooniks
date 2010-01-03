rootElement = getRootElement( );
x,y = guiGetScreenSize( );

drawpos = 0;
drawshowing = false;
drawmoving = 0;
drawText = "......";
drawWidth = 200;
ticksShown = 0;

textOffx = 20;
textOffy = 10;

function showSkillDraw( text )

	if( drawshowing ~= false ) then return false; end
	
	drawshowing = true;
	drawmoving = -1; -- make it appear
	drawText = text;
	drawpos = y + drawmoving;
	
	return true;

end

addEvent( "onShowSkillDraw", true );
addEventHandler( "onShowSkillDraw", getRootElement( ), showSkillDraw );


addEventHandler( "onClientResourceStart", rootElement,  

	function ()
	
		addEventHandler("onClientRender", rootElement, 
		
			function ()
			
				if( drawshowing ) then
				
					dxDrawRectangle( x - drawWidth, drawpos, drawWidth, y - drawpos, tocolor ( 0, 0, 0, 150 ) );
					dxDrawText ( drawText,  x - drawWidth + textOffx, drawpos + textOffy, drawWidth - textOffx, y - drawpos - textOffy );
				
					if( drawmoving ~= 0 ) then
					
						drawpos = drawpos + drawmoving;
						
						if( drawmoving < 0 ) then
						
							if( drawpos <= y - 50 ) then
							
								drawmoving = 0;
							
							end
						
						else
						
							if( drawpos >= y ) then 
							
								drawmoving = 0;
								drawshowing = false;
								
							end
						
						end
						
					else
					
						ticksShown = ticksShown+1;
						
						if( ticksShown > 500 ) then
						
							drawmoving = 1;
							ticksShown = 0;
						
						end
						
					end
				
				end
			
			end
		
		);
	
	end

);

addEventHandler ( "onClientPlayerWeaponFire", getLocalPlayer( ), 

	function ( weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement )
	
		if( hitElement ~= false and hitElement ~= nil and getElementType( hitElement ) ~= false ) then
		
			triggerServerEvent( "onSkillWeaponShot", getLocalPlayer( ), weapon );
		
		end
	
	end

);