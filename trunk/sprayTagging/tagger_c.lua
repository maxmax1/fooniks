local thePlayer = getLocalPlayer( );
local sx, sy = guiGetScreenSize( );

local tempSpray = nil;
local inSpray = false;
local lastSprayTime = 0;
local sprayTimer = 0;


function getXYInFrontOfPlayer( player, distance, behind )

	local x, y, z = getElementPosition( player )
	local rot = getPedRotation( player )
	
	if( behind ) then
	
		if( rot >= behind ) then rot = rot - behind; else rot = rot + behind; end
	
	end
	
	x = x + math.sin( math.rad( -rot ) ) * distance
	y = y + math.cos( math.rad( -rot ) ) * distance
	
	return x, y, z, rot

end

function findRotation(x1,y1,x2,y2)
 
  local t = -math.deg(math.atan2(x2-x1,y2-y1))
  if t < 0 then t = t + 360 end;
  return t;
 
end

function SprayImageDisplay( )

	if( tempSpray ) then
	
		local progressW = 196 * ( ( tempSpray.alpha - 150 ) / 100 );	
		dxDrawRectangle( (sx - 200) / 2, sy - 75, 200, 25, tocolor( 255, 255, 255 ), true ); 
		dxDrawRectangle( (sx - 200) / 2 + 2, sy - 75 + 2, progressW, 21, tocolor( 0, 0, 200 ), true ); 
	
	end

end

addEventHandler( "onClientResourceStart", getResourceRootElement( ),  

	function ()
	
		addEventHandler("onClientRender", getRootElement( ), SprayImageDisplay );
	
	end

);

--

function RoundAngle( ang )

	if( ang < 45 ) then
	
		return 0;
	
	elseif( ang < 135 ) then
	
		return 90;
	
	elseif( ang < 225 ) then
	
		return 180;
	
	elseif( ang < 315 ) then
	
		return 270;
	
	else
	
		return 360;
	
	end

end

function StartSpray( )

	local posX, posY, posZ = getElementPosition( thePlayer );
	
	local x2, y2, z2, rot = getXYInFrontOfPlayer( thePlayer, 2 );
		
	local hasWall, wallX, wallY, wallZ, elem = processLineOfSight( posX, posY, posZ, x2, y2, posZ , true, false, false, false, false, false, false, false );
	
	if( hasWall ) then
	
		local x3, y3, z3 = getXYInFrontOfPlayer( thePlayer, 2, 45 );
		local x4, y4, z4 = getXYInFrontOfPlayer( thePlayer, 2, -45 );
		
		local wallRot = false;

		local process1, prc1X, prc1Y = processLineOfSight( posX, posY, posZ, x3, y3, posZ , true, false, false, false, false, false, false, false );
		local process2, prc2X, prc2Y = processLineOfSight( posX, posY, posZ, x4, y4, posZ , true, false, false, false, false, false, false, false );
		
		if( process1 and process2 ) then
		
			wallRot = findRotation( prc1X, prc1Y, prc2X, prc2Y );
		
		else
		
			return false;
		
		end
		
		inSpray = true;
		
		tempSpray = { };
		
		local dist = getDistanceBetweenPoints3D( posX, posY, posZ, wallX, wallY, wallZ );
		wallX, wallY, wallZ = getXYInFrontOfPlayer( thePlayer, dist-0.05 );
		
		--if( rot < 270 ) then rot = rot + 270; else rot = rot - 270; end
		
		tempSpray.posX = wallX;
		tempSpray.posY = wallY;
		tempSpray.posZ = wallZ+0.3;
		tempSpray.rotZ = wallRot;
		tempSpray.width = 214;
		tempSpray.height = 115;		
		tempSpray.model = 1490;
		
		local specialSpray = getElementData( thePlayer, "specialSpray" );
		if( specialSpray and tonumber( specialSpray ) ) then
		
			tempSpray.model = specialSpray;
		
		end
		
		tempSpray.alpha = 150;
		
		tempSpray.object = createObject( 
		
			tempSpray.model, 
			tempSpray.posX, tempSpray.posY, tempSpray.posZ,
			0, 0, tempSpray.rotZ
		
		);
	
	end

end

addEventHandler( "onClientPlayerWeaponFire", thePlayer, 

	function ( weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement )
		
		if( weapon == 41 ) then
		
			if( not inSpray ) then
			
				StartSpray( );				
				sprayTimer = setTimer( SprayCantimer, 300, 0 );
		
			else
			
				lastSprayTime = getTickCount( );
				tempSpray.alpha = tempSpray.alpha + 3;
				setElementAlpha( tempSpray.object, tempSpray.alpha );
				
				if( tempSpray.alpha > 255 ) then
				
					tempSpray.alpha = 255;
				
					cancelEvent( true );
					
					local newX, newY, newZ = getXYInFrontOfPlayer( thePlayer, 2, 180 );
					setElementPosition( thePlayer, newX, newY, newZ );
					
					triggerServerEvent( "onClientSprayTagCompleted", thePlayer, 
						tempSpray.model,
						tempSpray.posX,
						tempSpray.posY,
						tempSpray.posZ,
						0,
						0,
						tempSpray.rotZ
					);
				
					setTimer( destroyElement, 2000, 1, tempSpray.object );
					tempSpray = nil;
					inSpray = false;
					if( sprayTimer and isTimer( sprayTimer ) ) then killTimer( sprayTimer ); end
					
					-- triggerServerEvent onPlayerTagCompleted
					-- GangAreas Script using.
					
					-- Take area using onPlayerTagCompleted
					
					-- Tag upload using http files patch
					-- Tag upload rights 
				
				end
		
			end
		
		end	
	
	end

);

function SprayCantimer( )

	if( inSpray ) then
	
		if( getTickCount( ) - lastSprayTime > 300 ) then
		
			destroyElement( tempSpray.object );
			tempSpray = nil;
			inSpray = false;
			if( sprayTimer and isTimer( sprayTimer ) ) then killTimer( sprayTimer ); end
		
		end
	
	end

end

--[[

Question to devs... What could be the pitfalls in using CD3DMGEng Render3DSprite? Cause i have managed to create dxDrawImage3D using it. 

http://tinypic.com/r/2nbf3ug/6, http://tinypic.com/r/2eq8f3m/6, http://tinypic.com/r/339udc5/6

]]--