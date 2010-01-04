charWindow = nil;
tabPanel = nil;
charTab = nil;
setTab = nil;
levelLabel = nil;
charScrollPane = nil;
charList = {};
selectedChar = nil;

function ShowCharacters( charTable, selected, isEnd )

	if( charWindow ~= nil ) then
	
		destroyElement( charWindow );
		
		if( isEnd == true ) then 
		
			showCursor( false );
			guiSetInputEnabled( false );
			return 1;
			
		end
	
	end
	
	charWindow = guiCreateWindow( 0.1, 0.3, 0.2, 0.4, "Karakterid", true );
	guiWindowSetMovable( charWindow, false );
	guiWindowSetSizable( charWindow, false );
	
	tabPanel = guiCreateTabPanel( 0.0, 0.1, 1, 1, true, charWindow );
	
	charTab = guiCreateTab( "Karakterid", tabPanel );	
	
	charScrollPane = guiCreateScrollPane( 0.05, 0.05, 0.9, 0.8, true, charTab );
	guiScrollPaneSetScrollBars( charScrollPane, false, true );
	
	charSpawnButton = guiCreateButton( 0.1, 0.85, 0.8, 0.1, "Mine mängima", true, charTab );
	guiSetEnabled( charSpawnButton, false );
	
	addEventHandler("onClientGUIClick", charSpawnButton, 
		function ( )
		
			if( selectedChar == nil ) then
			
				outputChatBox( "Sul pole karakterit." );
			
			else
			
				ShowCharacters( nil, nil, true );
				triggerServerEvent( "OnRequestFirstSpawn", getLocalPlayer( ), selectedChar );
			
			end
		end
	, false);
	
	if( charTable ~= nil and #charTable > 0) then
					
		-- id, name, sex, age, model
		
		local y = 0.3;
			
		for i = 1,#charTable,1 do
			
			charList[i] = { };
			
			local file = ":phoenix-Characters/files/images/gui-Black.png";
			if( i == selected ) then file = "files/images/gui-White.png"; end
			
			charList[i][1] = guiCreateStaticImage( 0.1, y, 0.9, 0.2, file, true, charScrollPane );
			guiSetAlpha ( charList[i][1], 0.3 );
			
			if( i ~= selected ) then
			
				addEventHandler("onClientGUIClick", charList[i][1], 
			
					function ( )
				
						ShowCharacters( charTable, i, false );
				
					end
				
				);
				
			end
			
			local sex = "M";
			if( charTable[i]["sex"] == 1 ) then sex = "N"; end
			
			charList[i][2] = guiCreateLabel(0.15, 0.1, 0.9, 0.3, "Nimi: " .. charTable[i]["name"], true, charList[i][1] );
			charList[i][3] = guiCreateLabel(0.15, 0.4, 0.9, 0.3, "Sugu: " .. sex, true, charList[i][1] );
			charList[i][4] = guiCreateLabel(0.15, 0.7, 0.9, 0.3, "Vanus: " .. charTable[i]["age"], true, charList[i][1] );
			
		
			
			if( i == selected ) then
			
				local thePlayer = getLocalPlayer( );
				setElementAlpha( thePlayer, 255 );
				setElementModel( thePlayer, charTable[i]["model"] );
				
				charTable[i]["blurLevel"] = tonumber( charTable[i]["blurLevel"] );
				
				if( charTable[i]["blurLevel"] == nil or charTable[i]["blurLevel"] < 0 or charTable[i]["blurLevel"] > 255 ) then
					
					charTable[i]["blurLevel"] = 36;
					
				end
				
				
				setBlurLevel( charTable[i]["blurLevel"] );
				selectedChar = charTable[i]["id"];
				guiSetEnabled( charSpawnButton, true );
			
			end			
				
			-- increment
			y = y + 0.25;
			
		end
		
	else
	
		outputChatBox( "Sul pole karakterit. " .. #charTable );
	
	end
	
	local lvl = math.ceil( 100 / ( 255 / getBlurLevel() ) );
	setTab = guiCreateTab( "Seaded", tabPanel );
	guiCreateLabel(0.15, 0.325, 0.5, 0.1, "MotionBlur Tase: ", true, setTab );
	levelLabel = guiCreateLabel(0.15, 0.4, 0.1, 0.1, tostring( lvl ), true, setTab );
	blurScroll = guiCreateScrollBar ( 0.25, 0.4, 0.7, 0.05, true, true, setTab );
	guiScrollBarSetScrollPosition( blurScroll, lvl );
	
	addEventHandler("onClientGUIScroll", blurScroll, 
	
		function ( Scrolled )
		
			guiSetText ( levelLabel, math.floor( guiScrollBarGetScrollPosition( blurScroll ) ) );
		
		end
	
	);
	
	local save = guiCreateButton( 0.1, 0.85, 0.8, 0.1, "Salvesta", true, setTab );	
	addEventHandler("onClientGUIClick", save, 
	
		function ( )
		
			local level = 100 / guiScrollBarGetScrollPosition( blurScroll ) * 255;
			setBlurLevel( level );
		
		end
		
	);	

	guiSetVisible( charWindow, true );
	showCursor( true );
	guiSetInputEnabled( true );

end

addEvent( "onShowCharacters", true );
addEventHandler( "onShowCharacters", getRootElement( ), ShowCharacters );