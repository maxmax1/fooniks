-- JustDied
local label = false;
local yesBtn = false;
local noBtn = false;

-- Revive
local reviveBtn = false;
local cancelBtn = false;
local windShowing = false;

local player = getLocalPlayer( );
local rootElement = getRootElement( );
local sx, sy = guiGetScreenSize( );

addEvent( "onPlayerJustDied", true );
addEventHandler( "onPlayerJustDied", rootElement,

	function ()
	
		showCursor( true );					
		yesBtn = guiCreateButton( ( sx / 2 ) - 200, sy*0.75, 100, 25, "Suren", false );
		noBtn = guiCreateButton( ( sx / 2 ) + 100, sy*0.75, 100, 25, "Ootan Abi", false );
		
		addEventHandler( "onClientGUIClick", yesBtn, 
		
			function ()
			
				triggerEvent( "onMiniGameStart", player );
				destroyElement( yesBtn );
				destroyElement( noBtn );			
			
			end
		
		, false);
		
		addEventHandler( "onClientGUIClick", noBtn, 
		
			function ()
			
				exports.phoenix_Chat:OocInfo( "Saad ka kasutada /sure." );
				destroyElement( yesBtn );
				destroyElement( noBtn );
				toggleAllControls( true );	
			
			end
		
		, false);
	
	end
	
);

addCommandHandler( "sure", 

	function ( )
	
		local data = getElementData( player, "Character.JustDied" );
		if( data and ( data == 1 or data == "1" ) ) then
		
			triggerEvent( "onMiniGameStart", player );
		
		else
		
			exports.phoenix_Chat:OocInfo( "Sa pole teadvusetu." );
		
		end
	
	end
	
, false, false );

addCommandHandler( "tapa", 

	function ( )
	
		setElementHealth( player, 0 );
		exports.phoenix_Chat:EmoteMessage( "kasutas tapa käsku!", true );
	
	end
	
, false, false );

addEventHandler( "onClientClick", rootElement, 

	function ( button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement )
	
		if( button == "left" and windShowing == false ) then
		
			if( state == "down" ) then
			
				if( clickedElement ~= false and clickedElement ~= player and getElementType( clickedElement ) == "player" ) then
				
					local hasKit = exports.phoenix_Pockets:getSlotByItem( 16 );
					
					if( hasKit ) then
				
						local justDied = getElementData( clickedElement, "Character.JustDied" );
						
						if( justDied and ( justDied == 1 or justDied == "1" ) ) then
						
							windShowing = true;
							reviveBtn = guiCreateButton( absoluteX, absoluteY-25, 100, 20, "Anna Esmaabi" ); 
							cancelBtn = guiCreateButton( absoluteX, absoluteY+25, 100, 20, "Katkesta" ); 
							
							addEventHandler( "onClientGUIClick", cancelBtn, 
							
								function ()
								
									destroyElement( reviveBtn );
									destroyElement( cancelBtn );
								
								end
							
							, false);
							
							addEventHandler( "onClientGUIClick", reviveBtn, 
							
								function ()
								
									triggerServerEvent( "onPocketClear", player, player, hasKit );
									triggerServerEvent( "onPlayerRevive", clickedElement );
									
								
								end
							
							, false);
						
						end
					
					else
					
						exports.phoenix_Chat:OocInfo( player, "Sul ei ole esmaabipakikest." );
					
					end
				
				end
			
			end
		
		end
	
	end

, true);
-- JustDied
local label = false;
local yesBtn = false;
local noBtn = false;

-- Revive
local reviveBtn = false;
local cancelBtn = false;
local windShowing = false;

local player = getLocalPlayer( );
local rootElement = getRootElement( );
local sx, sy = guiGetScreenSize( );

addEvent( "onPlayerJustDied", true );
addEventHandler( "onPlayerJustDied", rootElement,

	function ()
	
		showCursor( true );					
		yesBtn = guiCreateButton( ( sx / 2 ) - 200, sy*0.75, 100, 25, "Suren", false );
		noBtn = guiCreateButton( ( sx / 2 ) + 100, sy*0.75, 100, 25, "Ootan Abi", false );
		
		addEventHandler( "onClientGUIClick", yesBtn, 
		
			function ()
			
				triggerEvent( "onMiniGameStart", player );
				destroyElement( yesBtn );
				destroyElement( noBtn );			
			
			end
		
		, false);
		
		addEventHandler( "onClientGUIClick", noBtn, 
		
			function ()
			
				exports.phoenix_Chat:OocInfo( "Saad ka kasutada /sure." );
				destroyElement( yesBtn );
				destroyElement( noBtn );
				toggleAllControls( true );	
			
			end
		
		, false);
	
	end
	
);

addCommandHandler( "sure", 

	function ( )
	
		local data = getElementData( player, "Character.JustDied" );
		if( data and ( data == 1 or data == "1" ) ) then
		
			triggerEvent( "onMiniGameStart", player );
		
		else
		
			exports.phoenix_Chat:OocInfo( "Sa pole teadvusetu." );
		
		end
	
	end
	
, false, false );

addCommandHandler( "tapa", 

	function ( )
	
		setElementHealth( player, 0 );
		exports.phoenix_Chat:EmoteMessage( "kasutas tapa käsku!", true );
	
	end
	
, false, false );

addEventHandler( "onClientClick", rootElement, 

	function ( button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement )
	
		if( button == "left" and windShowing == false ) then
		
			if( state == "down" ) then
			
				if( clickedElement ~= false and clickedElement ~= player and getElementType( clickedElement ) == "player" ) then
				
					local hasKit = exports.phoenix_Pockets:getSlotByItem( 16 );
					
					if( hasKit ) then
				
						local justDied = getElementData( clickedElement, "Character.JustDied" );
						
						if( justDied and ( justDied == 1 or justDied == "1" ) ) then
						
							windShowing = true;
							reviveBtn = guiCreateButton( absoluteX, absoluteY-25, 100, 20, "Anna Esmaabi" ); 
							cancelBtn = guiCreateButton( absoluteX, absoluteY+25, 100, 20, "Katkesta" ); 
							
							addEventHandler( "onClientGUIClick", cancelBtn, 
							
								function ()
								
									destroyElement( reviveBtn );
									destroyElement( cancelBtn );
								
								end
							
							, false);
							
							addEventHandler( "onClientGUIClick", reviveBtn, 
							
								function ()
								
									triggerServerEvent( "onPocketClear", player, player, hasKit );
									triggerServerEvent( "onPlayerRevive", clickedElement );
									
								
								end
							
							, false);
						
						end
					
					else
					
						exports.phoenix_Chat:OocInfo( player, "Sul ei ole esmaabipakikest." );
					
					end
				
				end
			
			end
		
		end
	
	end

, true);
-- JustDied
local label = false;
local yesBtn = false;
local noBtn = false;

-- Revive
local reviveBtn = false;
local cancelBtn = false;
local windShowing = false;

local player = getLocalPlayer( );
local rootElement = getRootElement( );
local sx, sy = guiGetScreenSize( );

addEvent( "onPlayerJustDied", true );
addEventHandler( "onPlayerJustDied", rootElement,

	function ()
	
		showCursor( true );					
		yesBtn = guiCreateButton( ( sx / 2 ) - 200, sy*0.75, 100, 25, "Suren", false );
		noBtn = guiCreateButton( ( sx / 2 ) + 100, sy*0.75, 100, 25, "Ootan Abi", false );
		
		addEventHandler( "onClientGUIClick", yesBtn, 
		
			function ()
			
				triggerEvent( "onMiniGameStart", player );
				destroyElement( yesBtn );
				destroyElement( noBtn );			
			
			end
		
		, false);
		
		addEventHandler( "onClientGUIClick", noBtn, 
		
			function ()
			
				exports.phoenix_Chat:OocInfo( "Saad ka kasutada /sure." );
				destroyElement( yesBtn );
				destroyElement( noBtn );
				toggleAllControls( true );	
			
			end
		
		, false);
	
	end
	
);

addCommandHandler( "sure", 

	function ( )
	
		local data = getElementData( player, "Character.JustDied" );
		if( data and ( data == 1 or data == "1" ) ) then
		
			triggerEvent( "onMiniGameStart", player );
		
		else
		
			exports.phoenix_Chat:OocInfo( "Sa pole teadvusetu." );
		
		end
	
	end
	
, false, false );

addCommandHandler( "tapa", 

	function ( )
	
		setElementHealth( player, 0 );
		exports.phoenix_Chat:EmoteMessage( "kasutas tapa käsku!", true );
	
	end
	
, false, false );

addEventHandler( "onClientClick", rootElement, 

	function ( button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement )
	
		if( button == "left" and windShowing == false ) then
		
			if( state == "down" ) then
			
				if( clickedElement ~= false and clickedElement ~= player and getElementType( clickedElement ) == "player" ) then
				
					local hasKit = exports.phoenix_Pockets:getSlotByItem( 16 );
					
					if( hasKit ) then
				
						local justDied = getElementData( clickedElement, "Character.JustDied" );
						
						if( justDied and ( justDied == 1 or justDied == "1" ) ) then
						
							windShowing = true;
							reviveBtn = guiCreateButton( absoluteX, absoluteY-25, 100, 20, "Anna Esmaabi" ); 
							cancelBtn = guiCreateButton( absoluteX, absoluteY+25, 100, 20, "Katkesta" ); 
							
							addEventHandler( "onClientGUIClick", cancelBtn, 
							
								function ()
								
									destroyElement( reviveBtn );
									destroyElement( cancelBtn );
								
								end
							
							, false);
							
							addEventHandler( "onClientGUIClick", reviveBtn, 
							
								function ()
								
									triggerServerEvent( "onPocketClear", player, player, hasKit );
									triggerServerEvent( "onPlayerRevive", clickedElement );
									
								
								end
							
							, false);
						
						end
					
					else
					
						exports.phoenix_Chat:OocInfo( player, "Sul ei ole esmaabipakikest." );
					
					end
				
				end
			
			end
		
		end
	
	end

, true);