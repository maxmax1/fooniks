connection = nil;

function displayLoadedRes( res )	
	
	if( not connection ) then
	
		connection = mysql_connect( get( "#phoenix-Base.MYSQL_HOST" ), get( "#phoenix-Base.MYSQL_USER" ), get( "#phoenix-Base.MYSQL_PASS" ), get( "#phoenix-Base.MYSQL_DB" ) );
		
		if( not connection ) then
		
			outputDebugString( "Phoenix-Reports: ei saanud mysql ühendust kätte." );
			stopResource( res );
		
		else
		
			outputDebugString( "Phoenix-Reports: Mysql serveriga ühendatud." );
		
		end	
		
	end
	
end

addEventHandler( "onResourceStart", getResourceRootElement( getThisResource( ) ), displayLoadedRes );

function submitVTeata(head, kirj)

	if( client ) then
	
		local head2 = { head };
		local kirj2 = { kirj };
			
		local reporter = getElementData( client, "User.userid" );
			
		if( reporter ~= false ) then
			
			local insert = mysql_query ( connection, "INSERT INTO module_bugtracker (`name`, `status`, `project`, `description`, `reporter`) VALUES ('" ..table.concat(head2).. "', '0', '1', '" ..table.concat(kirj2).. "', '" ..tonumber(reporter).. "')")
				
			if( insert ) then
				
				outputChatBox("#33FF00T�name teie panuse eest projekti arendusel!", source, 255, 255, 255, true)
					
				mysql_free_result( insert );
					
				insert = mysql_query( connection, "UPDATE user SET ph_bugReports = ph_bugReports + 1 WHERE userid = '" .. reporter .. "'" );
				if( insert ) then mysql_free_result( insert ); end
					
			end
			
		else
			
			outputChatBox( "Pead olema sisse logitud.", source, 255, 0, 0 );
		
		end
			
	end
	
end
addEvent("submitVTeata",true)
addEventHandler("submitVTeata", getRootElement(), submitVTeata)

function submitMTeata(mkirj, teataja)

	if( client ) then
		
		local mkirj2 = { mkirj };
		
		local adminitele = getElementsByType("player");
		
		for k,v in ipairs( adminitele ) do
		
			local adminlvl = getElementData( v, "User.AdminLevel" );
			
			if adminlvl ~= false and adminlvl ~= nil and tonumber(adminlvl) >= 1 then
			
				outputChatBox("[TEATA] " ..teataja.. ": " ..table.concat(mkirj2), v, 173, 255, 47);
				outputChatBox("#33FF00Teie teade on edkualt administraatoritele edastatud!", source, 255, 255, 255, true);
				
			end
			
		end
		
	end
	
end
addEvent("submitMTeata",true)
addEventHandler("submitMTeata",getRootElement(),submitMTeata)