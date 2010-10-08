local thePlayer = getLocalPlayer( );

addEventHandler( "onClientPlayerWeaponFire", thePlayer, 

	function ( weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElem )
	
		if( hitElem and getElementType( hitElem ) == "vehicle" ) then
		
			local vHealth = getElementHealth( hitElem );
			outputDebugString( tostring( vHealth ) );
			if( vHealth < 230 ) then
			
				triggerServerEvent( "onClientAchievementComplete", thePlayer, thePlayer, "demex" );
			
			end
		
		end
	
	end

);

addEventHandler( "OnClientPlayerStealthKill", thePlayer,

	function ( theVictim )
	
		triggerServerEvent( "onClientAchievementComplete", thePlayer, thePlayer, "sthkl" );
	
	end

);
local thePlayer = getLocalPlayer( );

addEventHandler( "onClientPlayerWeaponFire", thePlayer, 

	function ( weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElem )
	
		if( hitElem and getElementType( hitElem ) == "vehicle" ) then
		
			local vHealth = getElementHealth( hitElem );
			outputDebugString( tostring( vHealth ) );
			if( vHealth < 230 ) then
			
				triggerServerEvent( "onClientAchievementComplete", thePlayer, thePlayer, "demex" );
			
			end
		
		end
	
	end

);

addEventHandler( "OnClientPlayerStealthKill", thePlayer,

	function ( theVictim )
	
		triggerServerEvent( "onClientAchievementComplete", thePlayer, thePlayer, "sthkl" );
	
	end

);