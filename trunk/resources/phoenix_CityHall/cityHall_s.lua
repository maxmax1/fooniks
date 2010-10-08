addEvent( "onLegalLevelUpgrade", true );
addEventHandler( "onLegalLevelUpgrade", getRootElement( ), 

	function ( price )
	
		if( client ) then
		
			price = tonumber( price );
		
			if( getPlayerMoney( client ) < price ) then
			
				exports.phoenix_Chat:OocInfo( client, "Pole piisavalt raha!" );
			
			else
			
				exports.phoenix_Skills:xpSet( client, "LEGAL", price+1 );
				takePlayerMoney( client, price );
				triggerClientEvent( client, "onCityHallUpdate", client );
			
			end
		
		end
	
	end

);