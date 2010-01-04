connection = nil;

function displayLoadedRes( res )	

	if( not connection ) then
	
		connection = mysql_connect( get( "#MYSQL_HOST" ), get( "#MYSQL_USER" ), get( "#MYSQL_PASS" ), get( "#MYSQL_DB" ) );
		
		if( not connection ) then
		
			outputDebugString( "Ei õnnestunud mysql serveriga ühendada." );
			stopResource( res );
		
		else
		
			outputDebugString( "Mysql serveriga ühendatud." );
		
		end	
		
	end
	
end

addEventHandler( "onResourceStart", getResourceRootElement( getThisResource( ) ), displayLoadedRes );

function AuthPlayer( userName, passWord, rememberMe )

	if( not client ) then return false; end
	
	local eName = mysql_escape_string( connection, userName );
	local eWord = mysql_escape_string( connection, passWord );
	
	local query = "SELECT userid, usergroupid FROM `user` WHERE username = '" .. eName .. "'";
	local result = mysql_query( connection, query );
	
	local ret = 1;
	local usrId = 0;
	local usrGroup = 0;
	
	if( result ) then
	
		if( mysql_num_rows( result ) > 0) then
		
				local row = mysql_fetch_row(result);
				if(row) then
				
					usrId = row[1];
					usrGroup = tonumber( row[2] );
					ret = 0;
				
				end				
		
		end
		mysql_free_result( result );
		
	end
	
	if( ret == 0) then
	
		query = "SELECT userid FROM `user` WHERE userid = '" .. usrId .. "' AND MD5(CONCAT(MD5('" .. eWord .. "'), salt)) = password";
		result = mysql_query( connection, query );
		 
		if( result ) then
		 
		 	if( mysql_num_rows( result ) < 1) then
		
				ret = 2;
		
			end
		
		else
			
			ret = 2;
			
		end
	
	end
	
	if(usrId ~= 0 and ret == 0) then
	
		setElementData( client, "User.userid", usrId, true );
	
	end
	
	local adminLevel = 0;

	if( usrGroup == 8 ) then -- vbull banned group
	
		ret = 3; -- return an errorcode.
		
	elseif( usrGroup == 6 ) then -- vbull Admin
	
		adminLevel = 2;
	
	elseif( usrGroup == 12 or usrGroup == 7 ) then -- vbull dev / mode
	
		adminLevel = 1;
	
	end
	
	if( adminLevel > 0 and ret == 0 ) then -- vbull admin group
	
		local account = getAccount( userName );
		local pass = string.sub( md5( passWord ), -16 ); -- Turvalisem, passil on vist maks pikkus, -16 peaks aitama:) :/
		
		if( account == false ) then
	
			account = addAccount( userName, pass );
			
			if( account ~= false ) then
			
				if( adminLevel == 2 ) then
			
					aclGroupAddObject( aclGetGroup( "Admin" ), "user." .. userName );
				
				else
			
					aclGroupAddObject( aclGetGroup( "Moderator" ), "user." .. userName );
			
				end
				
			end
			
		end
		
		if( account ~= false ) then
		
			logIn( client, account, pass );
		
		else	
		
			outputChatBox( "Adminiks/Modeks seadmisega oli mingi jama. (" ..  userName .. "->" .. pass .. ")", client );
		
		end
		
		setElementData( client, "User.AdminLevel", usrGroup, true );
		
	end
	
	if( ret == 0 ) then
	
		setElementData( client, "User.GroupId", usrGroup, true );
	
	end
	
	triggerClientEvent( client, "OnPlayerLogin", getRootElement( ), ret );

end

addEvent( "OnAuthPlayer", true )
addEventHandler( "OnAuthPlayer", getRootElement( ), AuthPlayer )


function MysqlUpdatebuild( database )

	if( not database ) then return false end

	return "UPDATE " .. database .. " SET ";

end

function MysqlSetField( query, field, val )

	if( not query or not field or not val ) then return false end
	
	return query .. field .. " = '" .. val .. "', ";

end

function UpdateFinish( query, idfield, idval )
	
	if( not query or not idfield or not idval ) then return false end
	return string.sub(query, 1, -3) .. " WHERE " .. idfield .. " = '" .. idval .. "'";

end

function changeBlurLevel ( playerSource, command, blur )
    blur = tonumber(blur)
    if not blur or blur > 255 or blur < 0 then
        outputChatBox ( "Enter a value between 0 - 255.", playerSource )
    else
        setPlayerBlurLevel ( playerSource, blur )
        outputChatBox ( "Blur level set to: " .. blur, playerSource )
    end
end
 
addCommandHandler("blur", changeBlurLevel)