connection = nil;

function displayLoadedRes( res )	

	if( not connection ) then
	
		connection = mysql_connect( get( "#phoenix-Base.MYSQL_HOST" ), get( "#phoenix-Base.MYSQL_USER" ), get( "#phoenix-Base.MYSQL_PASS" ), get( "#phoenix-Base.MYSQL_DB" ) );
		
		if( not connection ) then
		
			outputDebugString( "Phoenix-Pockets: Ei saanud mysql ühendust kätte." );
			stopResource( res );
		
		else
		
			outputDebugString( "Phoenix-Pockets: Mysql serveriga ühendatud." );
			RegisterItems( );
		
		end	
		
	end

end

addEventHandler( "onResourceStart", getResourceRootElement( getThisResource( ) ), displayLoadedRes );

function RegisterSkills( )

	local xmlFile =  xmlLoadFile ( "items.xml" );
	if ( xmlFile ~= false ) then
	
		outputDebugString( "phoenix-Pockets: Skills database loaded." );
	
		local items = xmlNodeGetChildren( xmlFile );
		
		if( items ~= false ) then
		
			for i, node in ipairs( items ) do
		
           		-- node
            	local id = tonumber( xmlNodeGetAttribute( node, "id" ) );
            	
            	if( id ~= false ) then
            	
            		local myType = xmlNodeGetAttribute( node, "type" );
            		
            		if( myType == "WEAPON" ) then
            		
            			local wepId = tonumber( xmlNodeGetAttribute( node, "weaponId" ) );
            		
            		else
            		
            			local useEvent = xmlNodeGetAttribute( node, "useEvent" );
            		
            		end
            		
            	 	local parent = tonumber( xmlNodeGetAttribute( node, "parent" ) );
            		local name = xmlNodeGetAttribute( node, "name" );
            		local canDrop = xmlNodeGetAttribute( node, "canDrop" );
            		
            		outputDebugString( "Registred Item: " .. id .. "->" .. name );
            	
            	end
            
      		end
      		
      	else
      	
      		outputDebugString( "phoenix-Pockets: Bad Database syntax.", 1 );
      		      
       	end

		xmlUnloadFile ( xmlFile );
		
	else
	
		outputDebugString( "phoenix-Pockets: Pockets database failed to load.", 1 );
		
	end

end