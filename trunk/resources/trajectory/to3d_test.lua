local points = { };

addCommandHandler( "to3d",

	function ( )
	
		local thePlayer = getLocalPlayer( );
		local x, y, z = getElementPosition( thePlayer );
		local tra = CreateTrajectory( 30, 30, 15 );
		
		local obj = createObject( 334, x, y, z );
		
		local t3d = To3D:new( );
		points = t3d:Build( tra, getPedRotation( thePlayer ), obj );
	
	end

);

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

);
local points = { };

addCommandHandler( "to3d",

	function ( )
	
		local thePlayer = getLocalPlayer( );
		local x, y, z = getElementPosition( thePlayer );
		local tra = CreateTrajectory( 30, 30, 15 );
		
		local obj = createObject( 334, x, y, z );
		
		local t3d = To3D:new( );
		points = t3d:Build( tra, getPedRotation( thePlayer ), obj );
	
	end

);

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

);
local points = { };

addCommandHandler( "to3d",

	function ( )
	
		local thePlayer = getLocalPlayer( );
		local x, y, z = getElementPosition( thePlayer );
		local tra = CreateTrajectory( 30, 30, 15 );
		
		local obj = createObject( 334, x, y, z );
		
		local t3d = To3D:new( );
		points = t3d:Build( tra, getPedRotation( thePlayer ), obj );
	
	end

);

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

);