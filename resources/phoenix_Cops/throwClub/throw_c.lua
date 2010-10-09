local thePlayer = getLocalPlayer( );

function onBut( button, state )

	if( getPedWeapon( thePlayer ) == 3 ) then
	
	 --	triggerServerEvent( "onClubThrow", thePlayer, thePlayer );
				
		local x, y, z = getElementPosition( thePlayer );
		local tra = exports.trajectory:CreateTrajectory( 30, 15, 15 );
		
		local obj = createObject( 334, x, y, z );				
		local points = exports.trajectory:Build3D( tra, getPedRotation( thePlayer ), obj );
		destroyElement( obj );
		
		triggerServerEvent( "onClubThrow", thePlayer, thePlayer, points, x, y, z );
		
		outputDebugString( tostring( #tra ) );
	
	end

end
bindKey( "mouse2", "up", onBut );
--[[
addEventHandler( "onClientRender", getRootElement( ),

	function ( )
	
		for k, v in ipairs( points ) do
		
		
			local x1, y1 = getScreenFromWorldPosition(v[1], v[2], v[3] );
			local x2, y2 = getScreenFromWorldPosition( v[4], v[5], v[6] );
	
			if( x1 and y1 and x2 and y2 ) then
			
				dxDrawLine( x1, y1, x2, y2, tocolor( 255, 0 , 0 ), 4 ); 
			
			end
		
		end
	
	end

);]]--
