max_characters = 3;

charWindow = nil;
tabPanel = nil;
charTab = nil;
levelLabel = nil;
charScrollPane = nil;
charList = {};
selectedChar = nil;
sx, sy = guiGetScreenSize( );

allCharacters = { };

function ShowCharacters( charTable, selected, isEnd )

	if( charWindow ~= nil ) then
	
		destroyElement( charWindow );
		charWindow = nil;
		
		if( isEnd == true ) then 
		
			showCursor( false );
			guiSetInputEnabled( false );			
			showPlayerHudComponent( "radar", true );
			showPlayerHudComponent( "money", true );
			return 1;
			
		end
	
	end
	
	showPlayerHudComponent( "radar", false );
	showPlayerHudComponent( "money", false );
	
	charWindow = guiCreateWindow( sx*0.1, sy*0.3, 256, 410, "Karakterid", false );
	guiWindowSetMovable( charWindow, false );
	guiWindowSetSizable( charWindow, false );
	
	tabPanel = guiCreateTabPanel( 0.0, 0.1, 1, 1, true, charWindow );
	
	charTab = guiCreateTab( "Karakterid", tabPanel );	
	
	charScrollPane = guiCreateScrollPane( 0.05, 0.05, 0.9, 0.8, true, charTab );
	guiScrollPaneSetScrollBars( charScrollPane, false, true );
	
	charSpawnButton = guiCreateButton( 0.1, 0.85, 0.35, 0.1, "Mine mängima", true, charTab );
	guiSetEnabled( charSpawnButton, false );
	
	charCreateButton = guiCreateButton( 0.55, 0.85, 0.35, 0.1, "Loo Uus", true, charTab );

	if( #charTable < max_characters ) then
	
		guiSetEnabled( charCreateButton, true );
		
	else
	
		guiSetEnabled( charCreateButton, false );
	
	end
	
	addEventHandler("onClientGUIClick", charCreateButton, 
		function ( )
		
			ShowCharacters( nil, nil, true );
			triggerEvent( "onStartCharacterCreation", getLocalPlayer() );
			
		end
	, false);	
	
	addEventHandler("onClientGUIClick", charSpawnButton, 
		function ( )
		
			if( selectedChar == nil ) then
			
				exports.phoenix_Chat:OocInfo("Sul pole veel karakterit.");
			
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
			
			local file = "files/images/gui-black.png";
			if( i == selected ) then file = "files/images/gui-white.png"; end
			
			charList[i][1] = guiCreateStaticImage( 0.1, y, 0.8, 0.2, file, true, charScrollPane );
			guiSetAlpha ( charList[i][1], 0.3 );
			
			if( i ~= selected ) then
			
				addEventHandler("onClientGUIClick", charList[i][1], 
			
					function ( button, state, aX, aY )
					
						if( button == "left" and state == "up" ) then
													
							-- Hack for guiparent bug.
							local windX, windY = guiGetPosition( charWindow, false );
							local tabX, tabY = guiGetPosition( tabPanel, false );
							local scrollX, scrollY = guiGetPosition( charScrollPane, false );
							
							local startX = windX + tabX + scrollX;
							local startY = windY + tabY + scrollY;
							
							local height, width = guiGetSize( charList[i][1], false );
							local sHeight, sWidth = guiGetSize( charScrollPane, false );
							
							local endX = startX + ( sWidth * 0.8 );
							local endY = startY + sHeight;
							
							if( aX >= startX and aX <= endX and aY >= startY and aY <= endY ) then
										
								ShowCharacters( charTable, i, false );
							
							end
							
						end
				
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
				
				selectedChar = charTable[i]["id"];
				guiSetEnabled( charSpawnButton, true );
			
			end			
				
			-- increment
			y = y + 0.25;
			
		end
		
	else
	
		exports.phoenix_Chat:OocInfo("Sul pole veel karakterit.");
	
	end

	guiSetVisible( charWindow, true );
	showCursor( true );
	guiSetInputEnabled( true );

end

addEvent( "onShowCharacters", true );
addEventHandler( "onShowCharacters", getRootElement( ), ShowCharacters );

addEvent( "onCharNamesSync", true );
addEventHandler( "onCharNamesSync", getRootElement( ), 

	function ( myTable )
	
		allCharacters = { };
		
		for key,val in pairs( myTable ) do
			
			allCharacters[key] = val;
		
		end
		
	end
);

addEventHandler( "onClientResourceStart", getResourceRootElement( getThisResource( ) ),

	function ( )

		triggerServerEvent( "onCharSyncRequest", getLocalPlayer( ) );
		
	end

);

function getCharacterName( sqlId )

	return allCharacters[tonumber(sqlId)];

end

-- CharInfo
local charInf = nil;
local charFields = { };

function AddCharField(all)

	charFields = {};

	for k, v in ipairs( all ) do
	
		local tbl = { };
		tbl["prettyName"] = v["prettyName"];
		tbl["valueName"] = v["valueName"];
	
		table.insert( charFields, tbl );
	
	end

end

addEvent( "onNewCharField", true );
addEventHandler( "onNewCharField", getRootElement(), AddCharField );

function ShowCharInfo( hide )

	if( charInf ) then
	
		destroyElement( charInf );
		
		if( hide ) then return false; end
	
	end
	
	local player = getLocalPlayer( );
	
	local charName = getElementData( player, "Character.name" );	
	
	charInf = guiCreateWindow( sx-306, 50, 256, 410, charName, false );
	local scroll = guiCreateScrollPane( 0.05, 0.1, 0.9, 0.7, true, charInf );
	
	local y = 50;
	
	for k,v in ipairs( charFields ) do
	
		local label = guiCreateLabel( 5, y, 95, 15, v["prettyName"] .. ": ", false, scroll );
		guiSetFont(label, "default-bold");
		
		local rVal = getElementData( player, v["valueName"] );
		guiCreateLabel( 100, y, 100, 15, rVal, false, scroll );
		
		guiCreateStaticImage( 5, y+15, 200, 2, "files/images/gui-white.png", false, scroll );
		y = y + 20;
	
	end
	
	guiScrollPaneSetScrollBars( scroll, false, true );
	
	local nextBtn = guiCreateButton( 0.1, 0.85, 0.8, 0.1, "Sulge", true, charInf );
		
	addEventHandler("onClientGUIClick", nextBtn, 
		function ( button, state )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			if( source ~= nextBtn ) then return false; end
			ShowCharInfo( true );
		
		end
	, false);

end

addEvent( "onShowPlayerInfo", true );
addEventHandler( "onShowPlayerInfo", getRootElement(), ShowCharInfo );