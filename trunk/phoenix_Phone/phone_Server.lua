connection = nil;

function displayLoadedRes( res )	
	
	if( not connection ) then
	
		connection = mysql_connect( get( "#phoenix_Base.MYSQL_HOST" ), get( "#phoenix_Base.MYSQL_USER" ), get( "#phoenix_Base.MYSQL_PASS" ), get( "#phoenix_Base.MYSQL_DB" ) );
		
		if( not connection ) then
		
			outputDebugString( "phoenix_Phone ei saanud mysql ühendust kätte." );
			outputDebugString( mysql_error( ) );
			stopResource( res );
		
		else
		
			outputDebugString( "Mysql serveriga ühendatud." );
			LoadSimCards();
			setTimer( SaveSimCards, 240000, 0 );
		
		end	
		
	end
	
end

addEventHandler( "onResourceStart", getResourceRootElement( getThisResource( ) ), displayLoadedRes );

function checkMySQLConnection ( )

	if( mysql_ping( connection ) == false ) then
	
		outputDebugString( "Lost connection to the MySQL server, reconnecting ..." );
		mysql_close( connection );
		
		connection = mysql_connect( get( "#phoenix_Base.MYSQL_HOST" ), get( "#phoenix_Base.MYSQL_USER" ), get( "#phoenix_Base.MYSQL_PASS" ), get( "#phoenix_Base.MYSQL_DB" ) );
		
	end
  
end


function LoadSimCards( )

	local query = "SELECT * FROM ph_simcard";
	local result = mysql_query( connection, query );
		 
	if( result ) then
		 
		for result ,row in mysql_rows( result ) do
		
			local sqlId = row[1];
			local companyId = row[2];
			local sNumber = row[3];
			local contacts = { };
			local sms = { };
			
			local query2 = "SELECT cName, cNumber, id FROM ph_contacts WHERE sCard = '" .. sqlId .. "'";
			local result2 = mysql_query( connection, query2 );
			
			if( result2 ) then
				
				for k2, row2 in mysql_rows( result2 ) do
				
					local tbl = { };
					tbl["name"] = row2[1];
					tbl["number"] = row2[2];
					tbl["id"] = row2[3];
					table.insert( contacts, tbl );
				
				end
				
			end
			
			query2 = "SELECT sName, sText, id, sRead FROM ph_SmsLog WHERE sCard = '" .. sqlId .. "'";
			result2 = mysql_query( connection, query2 );
			
			if( result2 ) then		 
				
				for k2, row2 in mysql_rows( result2 ) do
				
					local tbl = { };
					tbl["name"] = row2[1];
					tbl["text"] = row2[2];
					tbl["id"] = row2[3];
					tbl["read"] = row2[4];
					table.insert( sms, tbl );
				
				end
				
			end
			
			AddSimCard( sNumber, companyId, contacts, sms, sqlId );
		
		end
		
	end
end

function SaveSimCards( )

	checkMySQLConnection( );

	local allsims = getElementsByType( "SimCard" );
	
	for k, v in ipairs( allsims ) do 

		saveSim( v );
		
	end

end

function saveSim( theSim )

	if( theSim ) then
	
		local myId = getElementData( theSim, "SqlId" );
		
		if( myId ~= false ) then
		
			for i = 1, 15, 1 do
				
				local name = getElementData( theSim, "Contact.Name." .. i );
				local nr = getElementData( theSim, "Contact.Nr." .. i );
				local sql = getElementData( theSim, "Contact.Id." .. i );
				
				if( name and nr and sql and tonumber( sql ) ~= 0 and name ~= "false" and nr ~= "false" ) then
								
					local query = exports.phoenix_Base:MysqlUpdatebuild("ph_contacts");		
					query = exports.phoenix_Base:MysqlSetField( query, "cName", name );
					query = exports.phoenix_Base:MysqlSetField( query, "cNumber", nr );
					query = exports.phoenix_Base:UpdateFinish( query, "id", sql );
					
					if( query ~= false) then
				
						local result = mysql_query( connection, query );
						if( result ~= false and result ~= nil ) then mysql_free_result( result ); end
					
					end
					
				elseif( name and nr and name ~= "false" and nr ~= "false" ) then
							
					local query = "INSERT INTO ph_contacts(id, cName, cNumber, sCard) VALUES( NULL, '" .. name .. "', '" .. nr .. "', '" .. myId .. "')";
					local result = mysql_query( connection, query );
					if( result ~= false and result ~= nil ) then
					
						mysql_free_result( result );
						local newId = mysql_insert_id( connection );
						setElementData( theSim, "Contact.Id." .. i, newId );
						
					end
				
				elseif( sql and name == "false" and nr == "false" ) then
				
					setElementData( theSim, "Contact.Id." .. i, "0" );
				
					local query = "DELETE FROM ph_contacts WHERE id = '" .. sql .. "'";
					local result = mysql_query( connection, query );
					if( result ~= false and result ~= nil ) then
					
						mysql_free_result( result );
						
					end
					
				end
				
				name = getElementData( theSim, "SMS.Name." .. i );
				local txt = getElementData( theSim, "SMS.Text." .. i );
				sql = getElementData( theSim, "SMS.Id." .. i );
				local readed = getElementData( theSim, "SMS.Read." .. i );

				if( name and txt and sql and tonumber( sql ) ~= 0 and name ~= "false" and txt ~= "false" ) then
								
					local query = exports.phoenix_Base:MysqlUpdatebuild("ph_smslog");		
					query = exports.phoenix_Base:MysqlSetField( query, "sName", name );
					query = exports.phoenix_Base:MysqlSetField( query, "sText", txt );
					query = exports.phoenix_Base:MysqlSetField( query, "sRead", readed );
					query = exports.phoenix_Base:UpdateFinish( query, "id", sql );
					
					if( query ~= false) then

						local result = mysql_query( connection, query );
						if( result ~= false and result ~= nil ) then mysql_free_result( result ); end
					
					end
					
				elseif( name and txt and name ~= "false" and txt ~= "false" ) then
							
					local query = "INSERT INTO p(id, sName, sText, sCard) VALUES( NULL, '" .. name .. "', '" .. txt .. "', '" .. myId .. "')";
					local result = mysql_query( connection, query );
					if( result ~= false and result ~= nil ) then
					
						mysql_free_result( result );
						local newId = mysql_insert_id( connection );
						setElementData( theSim, "SMS.Id." .. i, newId );
						
					end

				elseif( sql and name == "false" and txt == "false" ) then

					setElementData( theSim, "SMS.Id." .. i, "0" );

					local query = "DELETE FROM ph_smslog WHERE id = '" .. sql .. "'";
					local result = mysql_query( connection, query );
					if( result ~= false and result ~= nil ) then
					
						mysql_free_result( result );
						
					end
					
				end				
			
			end
		
		end
	
	end

end

addEvent( "onSimSave", true );
addEventHandler( "onSimSave", getRootElement( ), saveSim );

function generatePhoneNumber( comp )

	if( comp > 9 ) then comp = math.random( 0, 9 ); end
	return 50000000 + ( comp * 1000000 ) + math.random( 10000 );

end

function AddSimCard( number, companyId, contactsTable, smsTable, sqlId )

	if( not number ) then
	
		number = generatePhoneNumber( companyId );
	
	end

	local element = createElement( "SimCard" );
	
	setElementData( element, "Number", tostring( number ) );
	setElementData( element, "Company", companyId );
	
	if( not sqlId ) then
	
		local query = "INSERT INTO `ph_simcard` (`id`, `companyId`, `sNumber`) VALUES(NULL, '".. companyId .. "', '" .. number .. "')";
		local result = mysql_query( connection, query );
		
		if( result ~= false and result ~= nil ) then
		
			mysql_free_result( result );
			sqlId = mysql_insert_id( connection );
		
		end
	
	end
	
	setElementData( element, "SqlId", sqlId );
	
	for k, v in ipairs( contactsTable ) do
	
		setElementData( element, "Contact.Id." .. k, v["id"] );
		setElementData( element, "Contact.Name." .. k, v["name"] );
		setElementData( element, "Contact.Nr." .. k, v["number"] );
	
	end
	
	for k, v in ipairs( smsTable ) do
	
		setElementData( element, "SMS.Id." .. k, v["id"] );
		setElementData( element, "SMS.Name." .. k, v["name"] );
		setElementData( element, "SMS.Text." .. k, v["text"] );
		setElementData( element, "SMS.Read." .. k, v["read"] );
	
	end	
	
	return sqlId;

end

addEvent( "onUseSimcard", true );
addEventHandler( "onUseSimcard", getRootElement( ), 

	function ( pocketId, pType, pData )
	
		local hasPhone = exports.phoenix_Pockets:getSlotByItem( source, 14 );
		
		if( not hasPhone ) then 
		
			outputChatBox( "Sul pole telefoni kuhu seda SIM-Kaarti panna", source );
			
		else
		
			local inSim = tonumber( getElementData( source, "Character.simCard" ) );
			
			if( not inSim or inSim == 0 ) then
			
				setElementData( source, "Character.simCard", pData );
				exports.phoenix_Pockets:clearPocket( source, pocketId );
				outputChatBox( "Panid oma telefoni simkaardi." .. pocketId, source );			
			
			else
			
				outputChatBox( "Su telefonis on juba SIM-Kaart, võta eelmine enne välja...", source );
			
			end
		
		end
			
	end
	
);

addEvent( "onSimCardRemove", true );
addEventHandler( "onSimCardRemove", getRootElement( ), 

	function ( )
	
		if( client ) then
	
			local inSim = tonumber( getElementData( client, "Character.simCard" ) );
				
			if( inSim ~= nil and inSim ~= false and inSim > 0 ) then
			
				setElementData( client, "Character.simCard", "0" );
				if( exports.phoenix_Pockets:giveItem( client, 13, inSim ) ) then
				
					outputChatBox( "Võtsid oma telefonist simkaardi välja.", client );		
					triggerClientEvent( client, "onPhoneShow", client );
					
				else
				
					outputChatBox( "Simkaardi väljavõtmine ebaõnnestus.", client );
				
				end
			
			else
			
				outputChatBox( "Su telefonis on juba SIM-Kaart, võta eelmine enne välja...", client );
			
			end
		end			
	end
	
);

addCommandHandler( "myPhone", 

	function ( thePlayer, theCommand )
	
		local ret = AddSimCard( false, math.random( 0, 9 ), { }, { } );
		exports.phoenix_Pockets:giveItem( thePlayer, 13, ret );		
		exports.phoenix_Pockets:giveItem( thePlayer, 14, 1 );		
		
	end
	
,false, false );