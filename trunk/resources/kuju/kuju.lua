addEventHandler( "onResourceStart", getResourceRootElement( getThisResource( ) ),

	function ( )
	
		local ret = imageCreateTrueColor( 512, 512 );		
		outputDebugString( type(ret) .. " - " .. tostring( ret ) );
		if( ret ) then
		
			outputDebugString( tostring( imageColorAllocate( ret, 244, 100, 3 ) ) );
			outputDebugString( tostring( imageColorAllocateAlpha( ret, 244, 100, 3, 33 ) ) );
			outputDebugString( tostring( imagePng( ret, "test.png" ) ) );
		
		end
	
	end

);
