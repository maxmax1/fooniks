loginWindow = nil;
loginBtn = nil;
usrName = nil;
passWord = nil;
remember = nil;

userRight = false;
passRight = false;

nameVal = "";
passVal = "";
isChecked = false;
preAuth = nil;

sx, sy = guiGetScreenSize( );

local sVersion = "0.0";
local sRev = "0";
local txtColor = tocolor( 255, 255, 255, 200 );

function showLogin( )

	if( not loginWindow) then
	
		checkForRemember( );
	
		loginWindow = guiCreateWindow( (sx-512)/2, (sy-410)/2, 512, 410, "Tere Tulemast", false );
		
		local tempLabel;
		
		tempLabel = guiCreateLabel( 0.15, 0.11, 0.7, 0.38, "See on F88niks, uus ajastu Eesti rollim2ngus.\nPalun logige sisse, et alustada m2ngimist.\nKui\n\n    *    Sa unustasid parooli\n    *    Sul ei ole kasutajat\n\nSiis mine aadressile:\n\thttp://estrp.com\n", true, loginWindow );
		guiSetFont( tempLabel, "clear-normal");
		
		tempLabel = guiCreateLabel( 0.15, 0.51, 0.2, 0.10, "Kasutajanimi:", true, loginWindow );
		guiSetFont( tempLabel, "clear-normal");
		tempLabel = guiCreateLabel( 0.15, 0.61, 0.2, 0.10, "Parool:", true, loginWindow );
		guiSetFont( tempLabel, "clear-normal");
		tempLabel = guiCreateLabel( 0.15, 0.71, 0.2, 0.10, "J2ta meelde:", true, loginWindow );
		guiSetFont( tempLabel, "clear-normal");
		
		usrName = guiCreateEdit( 0.55, 0.50, 0.3, 0.05, nameVal, true, loginWindow );
		passWord = guiCreateEdit( 0.55, 0.60, 0.3, 0.05, passVal, true, loginWindow );
		guiEditSetMasked( passWord, true );
		remember = guiCreateCheckBox( 0.55, 0.70, 0.2, 0.05, "jah", isChecked, true, loginWindow );
		
		loginBtn = guiCreateButton( 0.4, 0.85, 0.2, 0.05, "Logi Sisse", true, loginWindow );
		guiSetEnabled( loginBtn, ( userRight and passRight ) );
		
		guiSetVisible( loginWindow, true );
		showCursor( true );
		guiSetInputEnabled( true );
	
	end	

end

addEvent( "OnPlayerRequestLogin", true );
addEventHandler( "OnPlayerRequestLogin", getRootElement( ), showLogin );

addEvent( "OnPlayerLogin", true );
addEventHandler( "OnPlayerLogin", getRootElement( ),
	
	function ( ret, other )
	
		if( ret == 1 ) then
		
			outputChatBox( "Vale Kasutajanimi.", 255, 0, 0 );
			guiSetEnabled( loginBtn, false );
			userRight = false;
			
		elseif( ret == 2) then
		
			outputChatBox( "Vale Parool.", 255, 0, 0 );
			guiSetEnabled( loginBtn, false );
			passRight = false;
			
		elseif( ret == 3) then
		
			outputChatBox( "See kasutaja on blokeeritud.", 255, 0, 0 );
			guiSetEnabled( loginBtn, false );
			userRight = false;
			passRight = false;
		
		else
		
			if( other ~= nil ) then
			
				saveForRemember( guiGetText(usrName), other );
				
			else
			
				local xml = xmlLoadFile ( "rememberMe.xml" );
				if ( xml ~= false ) then
				
					xmlDestroyNode ( xml );
				
				end
			
			end
		
			guiSetVisible( loginWindow, false );
			showCursor( false );
			guiSetInputEnabled( false );
			triggerServerEvent( "onCharactersRequest", getLocalPlayer( ) );
		
		end
	
	end

);

function editChange( element ) 
	
	local str = guiGetText(element);
	
	local len = string.len(str);
	
	if(len < 1) then
		
 		if(element == usrName) then userRight = false; end
		if(element == passWord) then passRight = false; end
	
	else
	
		if(element == usrName) then userRight = true; end
		if(element == passWord) then passRight = true; end
	
	end
	
	preAuth = false;
	
	guiSetEnabled( loginBtn, ( userRight and passRight ) );
	   
end

function resourceHandler( )

	showLogin( );
	addEventHandler("onClientGUIClick", loginBtn, 
		function ( )
		
			guiSetEnabled( loginBtn, false );
			triggerServerEvent( "OnAuthPlayer", getLocalPlayer( ), guiGetText(usrName), guiGetText(passWord), guiCheckBoxGetSelected(remember), preAuth );
		
		end
	, false);
	addEventHandler( "onClientGUIChanged", usrName, editChange );
	addEventHandler( "onClientGUIChanged", passWord, editChange );
	
	local img = guiCreateStaticImage( 0.044, 0.88, 0.18, 0.1, "files/images/logo.png", true );
	
	local realtime = getRealTime( );
	setTime( realtime.hour, realtime.minute )
    setMinuteDuration( 60000 );

end

addEventHandler( "onClientResourceStart", getResourceRootElement( getThisResource( ) ), resourceHandler );

function saveForRemember( rememberUser, rememberPass )

	local xml = xmlCreateFile( "rememberMe.xml", "remember" );
	
	if ( xml ~= false ) then
	
		local child = xmlCreateChild (xml, "user" );
		if( child ~= false ) then xmlNodeSetAttribute( child, "rem", rememberUser ); end
		
		child = xmlCreateChild (xml, "pass" );
		if( child ~= false ) then xmlNodeSetAttribute( child, "rem", rememberPass ); end
		
		xmlSaveFile ( xml );
		xmlUnloadFile ( xml );
		
	end

end

function checkForRemember( )

	local xml = xmlLoadFile ( "rememberMe.xml" );
	if ( xml ~= false ) then
	
		local child = xmlFindChild (xml, "user", 0 );
		if( child ~= false ) then
		
			nameVal = xmlNodeGetAttribute( child, "rem" );
			userRight = true;
			
		end
		
		child = xmlFindChild( xml, "pass", 0 );
		if( child ~= false ) then
		
			passVal = xmlNodeGetAttribute( child, "rem" );
			passRight = true;
			isChecked = true;
			preAuth = true;
			
		end
	
		xmlUnloadFile ( xml );
	end

end

addEvent( "onScriptInfoRequest", true );
addEventHandler( "onScriptInfoRequest", getRootElement( ), 

	function ( ver, rev ) 
	
		sVersion = ver;
		sRev = rev;
	
	end
	
);

addEventHandler( "onClientResourceStart", getRootElement( ),  

	function ()
	
		triggerServerEvent( "onScriptInfoRequestS", getLocalPlayer( ) );	
		addEventHandler("onClientRender", getRootElement( ), 
		
			function ()
			
				dxDrawText( "Phoenix " .. sVersion .. " r" .. sRev, sx-150, sy-40, sx-3, sy-10, txtColor, 1, "default", "right", "bottom" );
			
			end
			
		);
		
	end
	
);