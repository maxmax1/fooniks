-- OPILAUD: -1717.0095214844, 4668.2666015625, 149.54016113281
--[[ NPC:
			-1716.3243408203, 4668.6748046875, 148.48466491699
			-1716.322265625, 4667.3735351563, 148.48466491699
			-1716.3048095703, 4670.021484375, 148.48466491699
]]--

local neededScore = 100;

-- Am i playing.
local imInGame = false;
local paused = false;
local gameEnd = false;
local peds = { };

-- Current Game status.
local gamePoints = 0;
local gameTicks = 0;
local gameSpeed = 0;
local wrongPoint = false;
local truePoint = false;

local currentKey = "";
local currentPos = false;

-- Some values needed everywhere...
local player = getLocalPlayer( );
local rootElement = getRootElement( );
local sx, sy = guiGetScreenSize( );
local curImages = { };

-- gameStats
local gameStats = { };

addEventHandler( "onClientResourceStart", getResourceRootElement( ),  

	function ()
	
		addEventHandler("onClientRender", rootElement, 
		
			function ()
			
				if( imInGame == true ) then
					
					local opacity = "0";
				
					for k, v in ipairs( curImages ) do
						
						if( v["xpos"] >= ( sx / 2 ) - 95 and v["xpos"] <= ( sx / 2 ) + 50 ) then
						
							currentKey = v["key"];
							currentPos = k;
						
						elseif( currentKey == v["key"] and currentPos == k ) then
						
							inputFunc( "wrong", "down" );
							currentKey = false;
							currentPos = false;
						
						end
						
						if( not paused ) then
						
							v["xpos"] = v["xpos"] - gameSpeed;
							
						end
						local rem = false;
						
						local col = nil;
						
						if( currentPos == k ) then
						
							col = tocolor( 0, 255, 0, 150 );
						
						elseif( v["xpos"] >= ( sx / 2 ) + 50 and v["xpos"] <= ( sx / 2 ) + 150 ) then
						
							col = tocolor( 255, 255, 0, 150 );
							
						elseif( v["xpos"] <= ( sx / 2 ) - 95 ) then
						
							opacity = 150 * ( v["xpos"] / ( sx / 2 ) );						
							col = tocolor( 255, 0, 0, opacity );
							--
						
						end
						
						if( v["xpos"] <= ( sx / 2 ) - 300 ) then
						
							rem = true;
						
						end
						
						dxDrawImage( v["xpos"], sy - 190, 90, 90, ":phoenix_SpawnManager/files/images/arrow_" .. v["key"] .. ".png", 0, 0, 0, col );
						
						if( rem ) then
						
							table.remove( curImages, k );
						
						end
					
					end
					
					local baseX = ( sx * 0.85 ) - 100;
					local baseY = ( sy * 0.6 );
					
					dxDrawRectangle( baseX-1, baseY-1, 102, 22, tocolor( 0, 0, 255 ) );
					dxDrawRectangle( baseX, baseY, 100, 20, tocolor( 0, 75, 225 ) );
					
					-- Points
					
					local locPoints = ( gamePoints / neededScore ) * 100;
					dxDrawRectangle( baseX, baseY, locPoints, 20, tocolor( 0, 100, 200 ) );
					
					--dxDrawText( "Punkte: " .. opacity .. ", Kiirus: " .. gameSpeed .. ", stat:" .. tostring( wrongPoint ) .. ", stat2:" .. tostring( truePoint )
					--, 300, 300 );
					
					-- Draw the ring to the center of the screen.
					dxDrawImage( ( sx / 2 ) - 50, sy - 200, 100, 100, ":phoenix_SpawnManager/files/images/theRound.png" );
				
				elseif( gameEnd ) then
				
					dxDrawText( "Õnnitleme", sx/2-200, sy/2-20 , sx/2+200, sy/2+20, tocolor( 255, 200, 0 ), 3, "pricedown", "center", "center" );				
					gameTicks = gameTicks + 1;
					
					if( gameTicks > 60 ) then
					
						gameEnd = false;
						gameTicks = 0;
					
					end
				
				end
				
				if( isConsoleActive( ) or isMainMenuActive( ) ) then
				
					paused = true;
					
				elseif( paused ) then
				
					paused = false;
				
				end
			
			end
			
		);
		
	end
	
);

function setPaused( )

	paused = false;

end

function inputFunc( key, state )

	if( paused ) then return false end

	if( key == "arrow_u" and currentKey == "up" ) then
	
		gamePoints = gamePoints + 1;
		truePoint = true;
	
	elseif( key == "arrow_d" and currentKey == "down" ) then
	
		gamePoints = gamePoints + 1;
		truePoint = true;
	
	elseif( key == "arrow_r" and currentKey == "right" ) then
	
		gamePoints = gamePoints + 1;
		truePoint = true;
	
	elseif( key == "arrow_l" and currentKey == "left" ) then
	
		gamePoints = gamePoints + 1;
		truePoint = true;
	
	else
	
		if( gamePoints - 1 < 0 ) then
		
			gamePoints = 0;
			
		else
		
			gamePoints = gamePoints - 1;
			
		end
		
		wrongPoint = true;
	
	end
	
	if( currentPos and truePoint ) then
	
		table.remove( curImages, currentPos );
		currentPos = false;
	
	end
	
	local modifier = 0;
	if( wrongPoint ) then
	
		setPedAnimation( peds[1] );
		setPedAnimation( peds[2] );
		setPedAnimation( peds[3] );
	
		modifier = -1;
		wrongPoint = false;
		
		if( gameStats["currentCombo"] > gameStats["maxCombo"] ) then
		
			gameStats["maxCombo"] = gameStats["currentCombo"];
		
		end
		gameStats["currentCombo"] = 0;
		
	elseif( truePoint ) then
	
		setPedAnimation( peds[1], "FOOD", "SHP_Tray_Lift_Loop", -1, true, true, false );
		setPedAnimation( peds[2], "FOOD", "SHP_Tray_Lift_Loop", -1, true, true, false );
		setPedAnimation( peds[3], "FOOD", "SHP_Tray_Lift_Loop", -1, true, true, false );
	
		modifier = 1;
		truePoint = false;
		
		gameStats["currentCombo"] = gameStats["currentCombo"] + 1;
	
	end
	
	if( gameSpeed + modifier < 5 ) then
	
		gameSpeed = 5;
	
	elseif( gameSpeed + modifier > 15 ) then
	
		gameSpeed = 15;
	
	else
	
		gameSpeed = gameSpeed + modifier;
		
	end	
	
	if( gamePoints > neededScore-1 ) then
	
		EndGame( );
	
	end
	
end

function StartGame( )

	gameStats["startTime"] = getTickCount( );
	gameStats["currentCombo"] = 0;
	gameStats["maxCombo"] = 0;

	peds[1] = createPed( 70, -1716.3243408203, 4668.6748046875, 148.48466491699 );
	peds[2] = createPed( 274, -1716.322265625, 4667.3735351563, 148.48466491699 );
	peds[3] = createPed( 276, -1716.3048095703, 4670.021484375, 148.48466491699 );
	setPedRotation( peds[1], 90 );
	setPedRotation( peds[2], 90 );
	setPedRotation( peds[3], 90 );
	
	setPedAnimation( player, "CRACK", "crckdeth2", -1, true, true, false );
	setElementPosition( player, -1717.0095214844, 4668.2666015625, 149.54016113281, false );
	setPedRotation( player, 270 );
	
	setCameraMatrix( -1715.0095214844, 4667.2666015625, 150.94016113281, -1717.0095214844, 4668.2666015625, 149.54016113281 );

	gameSpeed = 5;	
	imInGame = true;
	paused = false;
	toggleAllControls( false );
	ShowHideOthers( false );
	addButton( );	
	
	bindKey( "arrow_u", "up", inputFunc );
	bindKey( "arrow_d", "up", inputFunc );
	bindKey( "arrow_r", "up", inputFunc );
	bindKey( "arrow_l", "up", inputFunc );
	
	setElementData( player, "Character.JustDied", "0" );

end

function ShowHideOthers( boolean )

	local val = 255;
	if( not boolean ) then val = 0; end

	local players = getElementsByType( "player" );
	for k,v in ipairs( players ) do
	
		if( v ~= player ) then
		
			setElementAlpha( v, val );
			
		end
	
	end

end

function EndGame( )

	gameStats["endTime"] = getTickCount( );
	gamePoints = 5;
	imInGame = false;
	gameEnd = true;
	showCursor( false );
	guiSetInputEnabled( false );
	ShowHideOthers( true );
	
	destroyElement( peds[1] );
	destroyElement( peds[2] );
	destroyElement( peds[3] );
	
	curImages = { };
	
	unbindKey( "arrow_u", "up", inputFunc );
	unbindKey( "arrow_d", "up", inputFunc );
	unbindKey( "arrow_r", "up", inputFunc );
	unbindKey( "arrow_l", "up", inputFunc );
	
	triggerServerEvent( "onMinigameEnd", player, gameStats );
	
	gameStats = { };

end

addEvent( "onMiniGameStart", true );
addEventHandler( "onMiniGameStart", getRootElement( ), StartGame );

addCommandHandler( "hack", 

	function ( temp, new )
	
		gamePoints = 99;
		
	end
	
);

function addButton( )
	
	if( not imInGame ) then return false end
	
	if( not paused ) then

		local tbl = { };
		tbl["xpos"] = sx - 100;
		tbl["key"] = "left";
		
		rand = math.random( 1, 4 );
		if( rand == 2 ) then
		
			tbl["key"] = "right";
		
		elseif( rand == 3 ) then
		
			tbl["key"] = "up";
		
		elseif( rand == 3 ) then
		
			tbl["key"] = "down";
		
		end
		
		table.insert( curImages, tbl );
	
	end
	
	setTimer( addButton, 1500 - ( 1000 * ( gameSpeed / 15 ) ) + ( math.random( -2, 2 ) * 100 ), 1 );

end
-- OPILAUD: -1717.0095214844, 4668.2666015625, 149.54016113281
--[[ NPC:
			-1716.3243408203, 4668.6748046875, 148.48466491699
			-1716.322265625, 4667.3735351563, 148.48466491699
			-1716.3048095703, 4670.021484375, 148.48466491699
]]--

local neededScore = 100;

-- Am i playing.
local imInGame = false;
local paused = false;
local gameEnd = false;
local peds = { };

-- Current Game status.
local gamePoints = 0;
local gameTicks = 0;
local gameSpeed = 0;
local wrongPoint = false;
local truePoint = false;

local currentKey = "";
local currentPos = false;

-- Some values needed everywhere...
local player = getLocalPlayer( );
local rootElement = getRootElement( );
local sx, sy = guiGetScreenSize( );
local curImages = { };

-- gameStats
local gameStats = { };

addEventHandler( "onClientResourceStart", getResourceRootElement( ),  

	function ()
	
		addEventHandler("onClientRender", rootElement, 
		
			function ()
			
				if( imInGame == true ) then
					
					local opacity = "0";
				
					for k, v in ipairs( curImages ) do
						
						if( v["xpos"] >= ( sx / 2 ) - 95 and v["xpos"] <= ( sx / 2 ) + 50 ) then
						
							currentKey = v["key"];
							currentPos = k;
						
						elseif( currentKey == v["key"] and currentPos == k ) then
						
							inputFunc( "wrong", "down" );
							currentKey = false;
							currentPos = false;
						
						end
						
						if( not paused ) then
						
							v["xpos"] = v["xpos"] - gameSpeed;
							
						end
						local rem = false;
						
						local col = nil;
						
						if( currentPos == k ) then
						
							col = tocolor( 0, 255, 0, 150 );
						
						elseif( v["xpos"] >= ( sx / 2 ) + 50 and v["xpos"] <= ( sx / 2 ) + 150 ) then
						
							col = tocolor( 255, 255, 0, 150 );
							
						elseif( v["xpos"] <= ( sx / 2 ) - 95 ) then
						
							opacity = 150 * ( v["xpos"] / ( sx / 2 ) );						
							col = tocolor( 255, 0, 0, opacity );
							--
						
						end
						
						if( v["xpos"] <= ( sx / 2 ) - 300 ) then
						
							rem = true;
						
						end
						
						dxDrawImage( v["xpos"], sy - 190, 90, 90, ":phoenix_SpawnManager/files/images/arrow_" .. v["key"] .. ".png", 0, 0, 0, col );
						
						if( rem ) then
						
							table.remove( curImages, k );
						
						end
					
					end
					
					local baseX = ( sx * 0.85 ) - 100;
					local baseY = ( sy * 0.6 );
					
					dxDrawRectangle( baseX-1, baseY-1, 102, 22, tocolor( 0, 0, 255 ) );
					dxDrawRectangle( baseX, baseY, 100, 20, tocolor( 0, 75, 225 ) );
					
					-- Points
					
					local locPoints = ( gamePoints / neededScore ) * 100;
					dxDrawRectangle( baseX, baseY, locPoints, 20, tocolor( 0, 100, 200 ) );
					
					--dxDrawText( "Punkte: " .. opacity .. ", Kiirus: " .. gameSpeed .. ", stat:" .. tostring( wrongPoint ) .. ", stat2:" .. tostring( truePoint )
					--, 300, 300 );
					
					-- Draw the ring to the center of the screen.
					dxDrawImage( ( sx / 2 ) - 50, sy - 200, 100, 100, ":phoenix_SpawnManager/files/images/theRound.png" );
				
				elseif( gameEnd ) then
				
					dxDrawText( "Õnnitleme", sx/2-200, sy/2-20 , sx/2+200, sy/2+20, tocolor( 255, 200, 0 ), 3, "pricedown", "center", "center" );				
					gameTicks = gameTicks + 1;
					
					if( gameTicks > 60 ) then
					
						gameEnd = false;
						gameTicks = 0;
					
					end
				
				end
				
				if( isConsoleActive( ) or isMainMenuActive( ) ) then
				
					paused = true;
					
				elseif( paused ) then
				
					paused = false;
				
				end
			
			end
			
		);
		
	end
	
);

function setPaused( )

	paused = false;

end

function inputFunc( key, state )

	if( paused ) then return false end

	if( key == "arrow_u" and currentKey == "up" ) then
	
		gamePoints = gamePoints + 1;
		truePoint = true;
	
	elseif( key == "arrow_d" and currentKey == "down" ) then
	
		gamePoints = gamePoints + 1;
		truePoint = true;
	
	elseif( key == "arrow_r" and currentKey == "right" ) then
	
		gamePoints = gamePoints + 1;
		truePoint = true;
	
	elseif( key == "arrow_l" and currentKey == "left" ) then
	
		gamePoints = gamePoints + 1;
		truePoint = true;
	
	else
	
		if( gamePoints - 1 < 0 ) then
		
			gamePoints = 0;
			
		else
		
			gamePoints = gamePoints - 1;
			
		end
		
		wrongPoint = true;
	
	end
	
	if( currentPos and truePoint ) then
	
		table.remove( curImages, currentPos );
		currentPos = false;
	
	end
	
	local modifier = 0;
	if( wrongPoint ) then
	
		setPedAnimation( peds[1] );
		setPedAnimation( peds[2] );
		setPedAnimation( peds[3] );
	
		modifier = -1;
		wrongPoint = false;
		
		if( gameStats["currentCombo"] > gameStats["maxCombo"] ) then
		
			gameStats["maxCombo"] = gameStats["currentCombo"];
		
		end
		gameStats["currentCombo"] = 0;
		
	elseif( truePoint ) then
	
		setPedAnimation( peds[1], "FOOD", "SHP_Tray_Lift_Loop", -1, true, true, false );
		setPedAnimation( peds[2], "FOOD", "SHP_Tray_Lift_Loop", -1, true, true, false );
		setPedAnimation( peds[3], "FOOD", "SHP_Tray_Lift_Loop", -1, true, true, false );
	
		modifier = 1;
		truePoint = false;
		
		gameStats["currentCombo"] = gameStats["currentCombo"] + 1;
	
	end
	
	if( gameSpeed + modifier < 5 ) then
	
		gameSpeed = 5;
	
	elseif( gameSpeed + modifier > 15 ) then
	
		gameSpeed = 15;
	
	else
	
		gameSpeed = gameSpeed + modifier;
		
	end	
	
	if( gamePoints > neededScore-1 ) then
	
		EndGame( );
	
	end
	
end

function StartGame( )

	gameStats["startTime"] = getTickCount( );
	gameStats["currentCombo"] = 0;
	gameStats["maxCombo"] = 0;

	peds[1] = createPed( 70, -1716.3243408203, 4668.6748046875, 148.48466491699 );
	peds[2] = createPed( 274, -1716.322265625, 4667.3735351563, 148.48466491699 );
	peds[3] = createPed( 276, -1716.3048095703, 4670.021484375, 148.48466491699 );
	setPedRotation( peds[1], 90 );
	setPedRotation( peds[2], 90 );
	setPedRotation( peds[3], 90 );
	
	setPedAnimation( player, "CRACK", "crckdeth2", -1, true, true, false );
	setElementPosition( player, -1717.0095214844, 4668.2666015625, 149.54016113281, false );
	setPedRotation( player, 270 );
	
	setCameraMatrix( -1715.0095214844, 4667.2666015625, 150.94016113281, -1717.0095214844, 4668.2666015625, 149.54016113281 );

	gameSpeed = 5;	
	imInGame = true;
	paused = false;
	toggleAllControls( false );
	ShowHideOthers( false );
	addButton( );	
	
	bindKey( "arrow_u", "up", inputFunc );
	bindKey( "arrow_d", "up", inputFunc );
	bindKey( "arrow_r", "up", inputFunc );
	bindKey( "arrow_l", "up", inputFunc );
	
	setElementData( player, "Character.JustDied", "0" );

end

function ShowHideOthers( boolean )

	local val = 255;
	if( not boolean ) then val = 0; end

	local players = getElementsByType( "player" );
	for k,v in ipairs( players ) do
	
		if( v ~= player ) then
		
			setElementAlpha( v, val );
			
		end
	
	end

end

function EndGame( )

	gameStats["endTime"] = getTickCount( );
	gamePoints = 5;
	imInGame = false;
	gameEnd = true;
	showCursor( false );
	guiSetInputEnabled( false );
	ShowHideOthers( true );
	
	destroyElement( peds[1] );
	destroyElement( peds[2] );
	destroyElement( peds[3] );
	
	curImages = { };
	
	unbindKey( "arrow_u", "up", inputFunc );
	unbindKey( "arrow_d", "up", inputFunc );
	unbindKey( "arrow_r", "up", inputFunc );
	unbindKey( "arrow_l", "up", inputFunc );
	
	triggerServerEvent( "onMinigameEnd", player, gameStats );
	
	gameStats = { };

end

addEvent( "onMiniGameStart", true );
addEventHandler( "onMiniGameStart", getRootElement( ), StartGame );

addCommandHandler( "hack", 

	function ( temp, new )
	
		gamePoints = 99;
		
	end
	
);

function addButton( )
	
	if( not imInGame ) then return false end
	
	if( not paused ) then

		local tbl = { };
		tbl["xpos"] = sx - 100;
		tbl["key"] = "left";
		
		rand = math.random( 1, 4 );
		if( rand == 2 ) then
		
			tbl["key"] = "right";
		
		elseif( rand == 3 ) then
		
			tbl["key"] = "up";
		
		elseif( rand == 3 ) then
		
			tbl["key"] = "down";
		
		end
		
		table.insert( curImages, tbl );
	
	end
	
	setTimer( addButton, 1500 - ( 1000 * ( gameSpeed / 15 ) ) + ( math.random( -2, 2 ) * 100 ), 1 );

end