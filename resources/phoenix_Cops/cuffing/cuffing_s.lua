local cuffedPlayers = { };

addEvent( "onPoliceCuff", true );
addEventHandler( "onPoliceCuff", getRootElement( ), 

	function ( fromPlayer, toPlayer, distance )
	
		local fromStr = exports.phoenix_Skills:getPlayerLevel( fromPlayer, "POWER" );
		local toStr = exports.phoenix_Skills:getPlayerLevel( toPlayer, "POWER" );
		
		local levelDiff = -1;
		local lAbs = toStr - fromStr;
		if( fromStr > toStr ) then levelDiff = 1; lAbs = fromStr - toStr; end
		
		local neededRand = 51 + ( levelDiff * lAbs );
		
		local rand = math.random( 0, 101 );
		if( rand < neededRand ) then
		
			CuffPlayer( toPlayer, fromPlayer );
		
		end
	
	end

);

function allowWeapons( thePlayer, boolean )

	toggleControl( thePlayer, "fire", boolean );
	toggleControl( thePlayer, "next_weapon", boolean );
	toggleControl( thePlayer, "previous_weapon", boolean );
	toggleControl( thePlayer, "sprint", boolean );

end

function CuffPlayer( thePlayer, fromPlayer )

	if( cuffedPlayers[thePlayer] ) then
	
		cuffedPlayers[thePlayer] = nil;
		allowWeapons( thePlayer, true );
		exports.phoenix_Chat:EmoteMessage( fromPlayer, string.format( "vabastab %s käed.", getPlayerNametagText( thePlayer ) ), false );		
	
	else
	
		cuffedPlayers[thePlayer] = true;	
		allowWeapons( thePlayer, false );
		setPedWeaponSlot( thePleayer, 0 );
			
		exports.phoenix_Chat:EmoteMessage( fromPlayer, string.format( "paneb %s käed raudu.", getPlayerNametagText( thePlayer ) ), false );
	
	end

end

function FriskPlayer(  )

	

end
local cuffedPlayers = { };

addEvent( "onPoliceCuff", true );
addEventHandler( "onPoliceCuff", getRootElement( ), 

	function ( fromPlayer, toPlayer, distance )
	
		local fromStr = exports.phoenix_Skills:getPlayerLevel( fromPlayer, "POWER" );
		local toStr = exports.phoenix_Skills:getPlayerLevel( toPlayer, "POWER" );
		
		local levelDiff = -1;
		local lAbs = toStr - fromStr;
		if( fromStr > toStr ) then levelDiff = 1; lAbs = fromStr - toStr; end
		
		local neededRand = 51 + ( levelDiff * lAbs );
		
		local rand = math.random( 0, 101 );
		if( rand < neededRand ) then
		
			CuffPlayer( toPlayer, fromPlayer );
		
		end
	
	end

);

function allowWeapons( thePlayer, boolean )

	toggleControl( thePlayer, "fire", boolean );
	toggleControl( thePlayer, "next_weapon", boolean );
	toggleControl( thePlayer, "previous_weapon", boolean );
	toggleControl( thePlayer, "sprint", boolean );

end

function CuffPlayer( thePlayer, fromPlayer )

	if( cuffedPlayers[thePlayer] ) then
	
		cuffedPlayers[thePlayer] = nil;
		allowWeapons( thePlayer, true );
		exports.phoenix_Chat:EmoteMessage( fromPlayer, string.format( "vabastab %s käed.", getPlayerNametagText( thePlayer ) ), false );		
	
	else
	
		cuffedPlayers[thePlayer] = true;	
		allowWeapons( thePlayer, false );
		setPedWeaponSlot( thePleayer, 0 );
			
		exports.phoenix_Chat:EmoteMessage( fromPlayer, string.format( "paneb %s käed raudu.", getPlayerNametagText( thePlayer ) ), false );
	
	end

end

function FriskPlayer(  )

	

end
local cuffedPlayers = { };

addEvent( "onPoliceCuff", true );
addEventHandler( "onPoliceCuff", getRootElement( ), 

	function ( fromPlayer, toPlayer, distance )
	
		local fromStr = exports.phoenix_Skills:getPlayerLevel( fromPlayer, "POWER" );
		local toStr = exports.phoenix_Skills:getPlayerLevel( toPlayer, "POWER" );
		
		local levelDiff = -1;
		local lAbs = toStr - fromStr;
		if( fromStr > toStr ) then levelDiff = 1; lAbs = fromStr - toStr; end
		
		local neededRand = 51 + ( levelDiff * lAbs );
		
		local rand = math.random( 0, 101 );
		if( rand < neededRand ) then
		
			CuffPlayer( toPlayer, fromPlayer );
		
		end
	
	end

);

function allowWeapons( thePlayer, boolean )

	toggleControl( thePlayer, "fire", boolean );
	toggleControl( thePlayer, "next_weapon", boolean );
	toggleControl( thePlayer, "previous_weapon", boolean );
	toggleControl( thePlayer, "sprint", boolean );

end

function CuffPlayer( thePlayer, fromPlayer )

	if( cuffedPlayers[thePlayer] ) then
	
		cuffedPlayers[thePlayer] = nil;
		allowWeapons( thePlayer, true );
		exports.phoenix_Chat:EmoteMessage( fromPlayer, string.format( "vabastab %s käed.", getPlayerNametagText( thePlayer ) ), false );		
	
	else
	
		cuffedPlayers[thePlayer] = true;	
		allowWeapons( thePlayer, false );
		setPedWeaponSlot( thePleayer, 0 );
			
		exports.phoenix_Chat:EmoteMessage( fromPlayer, string.format( "paneb %s käed raudu.", getPlayerNametagText( thePlayer ) ), false );
	
	end

end

function FriskPlayer(  )

	

end