local playersWithPhone = { };
local rootElement = getRootElement( );

function getBonesAngle( thePlayer, bone1, bone2 )

	local x1, y1, z1 = getPedBonePosition( thePlayer, bone1 ); -- A
	local x2, y2, z2 = getPedBonePosition( thePlayer, bone2 ); -- B
	
	local x = math.deg( math.acos( math.rad( x2 - x1 ) ) );
	local y = math.deg( math.acos( math.rad( y2 - y1 ) ) );
	local z = math.deg( math.acos( math.rad( z2 - z1 ) ) );
	
	return x, y, z;

end

function drawBone( thePlayer, bone1, bone2, col )

	local x1, y1, z1 = getPedBonePosition( thePlayer, bone1 ); -- A
	local x2, y2, z2 = getPedBonePosition( thePlayer, bone2 ); -- B
	
	x1, y1 = getScreenFromWorldPosition( x1, y1, z1 );
	x2, y2 = getScreenFromWorldPosition( x2, y2, z2 );
	
	dxDrawLine( x1, y1, x2, y2, col, 5.0, true );
	dxDrawText( "" .. bone1, x1, y1, 50, 50 );

end

function SetPlayerUsingPhone( thePlayer, stat )

	if( stat ) then

		if( getElementType( thePlayer ) ~= "player" ) then
		
			return false;
		
		end
		
		local tbl = { };
		tbl.player = thePlayer;
		tbl.object = createObject( 2967, 0, 0, 0 );
		setElementCollisionsEnabled( tbl.object, false );	
		table.insert( playersWithPhone, tbl );
		
		return true;
		
	else
	
		for k, v in ipairs( playersWithPhone ) do
		
			if( v.player == thePlayer ) then
			
				destroyElement( v.object );
				table.remove( playersWithPhone, k );			
				return true;
			
			end
		
		end
		
		return false;
	
	end

end

addEvent( "givePlayerPhone", true );
addEventHandler( "givePlayerPhone", getRootElement( ), SetPlayerUsingPhone );

addEventHandler( "onClientResourceStart", rootElement,  

	function ()
	
		addEventHandler("onClientPreRender", rootElement, 
		
			function ()	
			
				for k, v in ipairs( playersWithPhone ) do
				
					if( isElementStreamedIn( v.player ) ) then
					
						local rotationOffset = 0;
					
						local ang, ang2, ang3 = getBonesAngle( v.player, 35, 36 ); -- Bone 34 
						local x, y, z = getPedBonePosition(v.player, 35)
						local rx, ry, rz = getElementRotation(v.player)
						local xOffset = .05 * math.cos(math.rad(rz+90-90))
						local yOffset = .05 * math.sin(math.rad(rz+90-90))	
						
						setElementPosition( v.object, x+xOffset, y+yOffset, z-.05 );
						setElementRotation( v.object, ang+90, ang2+90, rz+180 );
					
					end
				
				end
			
			end
			
		);
		
	end
	
);
