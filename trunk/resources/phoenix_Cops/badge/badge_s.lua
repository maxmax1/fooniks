addEvent( "onBadgeShowRequest", false );
addEventHandler( "onBadgeShowRequest", getRootElement( ), 

	function ( fromPlayer, toPlayer, distance )
	
		exports.poffer:AddOffer( fromPlayer, toPlayer, distance, "%s soovib sulle n2idata oma ametim2rki. Kas sa aksepteerid?", "Sa pakud kodanikule %s oma ametim2rki n2ha. Kas soovid katkestada?", "onBadgeSync" );
	
	end

);

local storedPlayers = { };

addEvent( "onBadgeSync", false );
addEventHandler( "onBadgeSync", getRootElement( ), 

	function ( fromPlayer, toPlayer )
	
		triggerClientEvent( fromPlayer, "onWantSeeBadge", fromPlayer, fromPlayer );
		triggerClientEvent( toPlayer, "onWantSeeBadge", toPlayer, fromPlayer );
		
		storedPlayers[fromPlayer] = toPlayer;
		storedPlayers[toPlayer] = fromPlayer;
	
	end

);

addEvent( "doNotWantBadge", true );
addEventHandler( "doNotWantBadge", getRootElement( ), 

	function ( )
	
		if( client and storedPlayers[client] ) then
		
			triggerClientEvent( storedPlayers[client], "onWantSeeBadge", storedPlayers[client] );
			
			storedPlayers[storedPlayers[client]] = nil;
			storedPlayers[client] = nil;
		
		end
	
	end

);
addEvent( "onBadgeShowRequest", false );
addEventHandler( "onBadgeShowRequest", getRootElement( ), 

	function ( fromPlayer, toPlayer, distance )
	
		exports.poffer:AddOffer( fromPlayer, toPlayer, distance, "%s soovib sulle n2idata oma ametim2rki. Kas sa aksepteerid?", "Sa pakud kodanikule %s oma ametim2rki n2ha. Kas soovid katkestada?", "onBadgeSync" );
	
	end

);

local storedPlayers = { };

addEvent( "onBadgeSync", false );
addEventHandler( "onBadgeSync", getRootElement( ), 

	function ( fromPlayer, toPlayer )
	
		triggerClientEvent( fromPlayer, "onWantSeeBadge", fromPlayer, fromPlayer );
		triggerClientEvent( toPlayer, "onWantSeeBadge", toPlayer, fromPlayer );
		
		storedPlayers[fromPlayer] = toPlayer;
		storedPlayers[toPlayer] = fromPlayer;
	
	end

);

addEvent( "doNotWantBadge", true );
addEventHandler( "doNotWantBadge", getRootElement( ), 

	function ( )
	
		if( client and storedPlayers[client] ) then
		
			triggerClientEvent( storedPlayers[client], "onWantSeeBadge", storedPlayers[client] );
			
			storedPlayers[storedPlayers[client]] = nil;
			storedPlayers[client] = nil;
		
		end
	
	end

);
