local player = getLocalPlayer( );

local houseWind = nil;
local houseTabPanel = nil;
local infoTab = nil;
local picturesTab = nil;
local ownerTab = nil;
local currentImage = 1;
local windShowing = false;

sx, sy = guiGetScreenSize( );

function createHouseMenu( addr )

	houseWind = guiCreateWindow( (sx-300)/2, (sy-250)/2, 300, 250, addr, false );
	houseTabPanel = guiCreateTabPanel( 0.05, 0.1, 0.9, 0.9, true, houseWind );	
	guiSetVisible( houseWind, false );
	windShowing = false;

end

function createHouseTabs( price, addonsTbl, okStr, interiorId, numImages )

	if( infoTab ~= nil ) then guiDeleteTab( infoTab ); end
	if( picturesTab ~= nil ) then guiDeleteTab( picturesTab ); end
	if( ownerTab ~= nil ) then guiDeleteTab( ownerTab ); end
	
	infoTab = guiCreateTab( "Info", houseTabPanel );
	
	local priceLabel = guiCreateLabel( 0.1, 0.1, 0.8, 0.1, "Hind: " .. price, true, infoTab );
	
	local acceptBtn = guiCreateButton( 0.2, 0.8, 0.2, 0.1, okStr, true, infoTab );
	local cancelBtn = guiCreateButton( 0.6, 0.8, 0.2, 0.1, "Katkesta", true, infoTab );
	
	local addonsList = guiCreateGridList( 0.1, 0.2, 0.8, 0.5, true, infoTab );
	local column = guiGridListAddColumn( addonsList, "Lisa", 0.95 );
	
	for k,v in ipairs( addonsTbl ) do
	
		guiGridListSetItemText( addonsList, guiGridListAddRow( addonsList ), column, v, false, false );
	
	end
	
	addEventHandler("onClientGUIClick", cancelBtn, 
		function ( )
		
			destroyElement( houseWind );
			windShowing = false;
		
		end
	, false);
	
	picturesTab = guiCreateTab( "Pildid", houseTabPanel );
	
	if( numImages > 0 ) then
	
		currentImage = 1;
		local img = guiCreateStaticImage( 0.1, 0.1, 0.8, 0.7, "images/" .. interiorId .. "_1.jpg", true, picturesTab );		
		local backBtn = guiCreateButton( 0.1, 0.85, 0.2, 0.1, "<<", true, picturesTab );
		local forwardBtn = guiCreateButton( 0.7, 0.85, 0.2, 0.1, ">>", true, picturesTab );
		
		addEventHandler("onClientGUIClick", backBtn, 
			
			function (  )
		
				if( currentImage > 1 ) then
				
					currentImage = currentImage - 1;
					guiStaticImageLoadImage( img, "images/" .. interiorId .. "_" .. currentImage .. ".jpg" );
				
				end
		
			end
			
		, false);	
		
		addEventHandler("onClientGUIClick", forwardBtn, 
			
			function (  )
			
				if( currentImage+1 <= numImages ) then
				
					currentImage = currentImage + 1;
					guiStaticImageLoadImage( img, "images/" .. interiorId .. "_" .. currentImage .. ".jpg" );
				
				end
		
			end
			
		, false);	
	
	else
	
		guiCreateLabel( 0.1, 0.1, 0.8, 0.8, "Pole...", true, picturesTab );
		
	end
	
	guiSetVisible( houseWind, true );
	windShowing = true;
	
	return acceptBtn;

end

function CreateOwnerTabs( house, tabName, sellStr )

	ownerTab = guiCreateTab( tabName, houseTabPanel );
	
	local locked = tonumber( getElementData( house, "locked" ) );
	local lockStr = "Lukku";
	if( locked == 1 ) then lockStr = "Lahti"; end
			
	local lockBtn = guiCreateButton( 0.2, 0.4, 0.2, 0.1, lockStr, true, ownerTab );
	local cancelBtn = guiCreateButton( 0.6, 0.4, 0.2, 0.1, "Sulge", true, ownerTab );
			
	local check = guiCreateCheckBox( 0.2, 0.8, 0.15, 0.1, "Jah", false, true, ownerTab );
	local unRent = guiCreateButton( 0.4, 0.8, 0.4, 0.1, "Kaktesta Leping", true, ownerTab );
	guiSetEnabled( unRent, false );
	
	addEventHandler("onClientGUIClick", check, 
		function ( )
		
			guiSetEnabled( unRent, guiCheckBoxGetSelected( check ) );
		
		end
	, false);	
	
	
	addEventHandler("onClientGUIClick", lockBtn, 
		function ( )
		
			destroyElement( houseWind );
			windShowing = false;
			triggerServerEvent( "onPropertyLockedChange", getLocalPlayer( ), house );
		
		end
	, false);		
	
	addEventHandler("onClientGUIClick", cancelBtn, 
		function ( )
		
			destroyElement( houseWind );
			windShowing = false;
		
		end
	, false);	

	guiSetVisible( houseWind, true );
	windShowing = true;				
	
	return unRent;

end

function showHouseMenu( hElement, absX, absY )

	local owner = tonumber( getElementData( hElement, "owner" ) );
	local myId = tonumber( getElementData( player, "Character.id" ) );
	local interiorId = tonumber( getElementData( hElement, "scriptInt" ) );
	
	if( owner ~= nil and owner ~= false ) then
		
		local houseAddons = { };
		
		local safe = getElementData( hElement, "HasSafe" );
		if( not safe ) then safe = "0"; end
		
		houseAddons[1] = "Seif: " .. safe;	
		
		local found, intElem = exports.phoenix_Infospots:getIntByID( interiorId );		
		local numImages = 0;
		
		if( found ) then
		
			houseAddons[2] = "Tube: " .. getElementData( intElem, "rooms" );
			houseAddons[3] = "WC: " .. getElementData( intElem, "bathrooms" );
			numImages = tonumber( getElementData( intElem, "images" ) );
		
		end
	
		local price = tonumber( getElementData( hElement, "price" ) );
	
		if( owner == 0 ) then
		
			local btn = createHouseTabs( price, houseAddons, "Osta", interiorId, numImages );	

			addEventHandler("onClientGUIClick", btn, 
				function ( )
				
					destroyElement( houseWind );
					windShowing = false;
					
					if( getPlayerMoney( player ) < price ) then
					
						outputChatBox( "Sul pole piisavalt raha" );
					
					else
					
						triggerServerEvent( "onPropertyPurchase", getLocalPlayer( ), hElement );	
					
					end
				
				end
			, false);			
		
		elseif( IsRenting( hElement, myId ) ) then
		
			local unRent = CreateOwnerTabs( hElement, "Rentnik", "Katkesta Leping" );
			
			addEventHandler("onClientGUIClick", unRent, 
				function ( )
				
					destroyElement( houseWind );
					windShowing = false;
					
					triggerServerEvent( "onPropertyUnRent", getLocalPlayer( ), hElement );
				
				end
			, false);
		
		elseif( owner ~= myId ) then
		
			local rentable = tonumber( getElementData( hElement, "rentable" ) );
			local rentPrice = tonumber( getElementData( hElement, "rentcost" ) );			
		
			if( rentable == 1 ) then
		
				local btn = createHouseTabs( rentPrice, houseAddons, "Rendi", interiorId, numImages );
				
				addEventHandler("onClientGUIClick", btn, 
					function ( )
					
						destroyElement( houseWind );
						windShowing = false;
						
						if( getPlayerMoney( player ) < rentPrice ) then
						
							outputChatBox( "Sul pole piisavalt raha" );
						
						else
						
							triggerServerEvent( "onPropertyRent", getLocalPlayer( ), hElement );	
						
						end
					
					end
				, false);	
			
			else
			
				outputChatBox( "Seda maja ei saa rentida..." );
			
			end
		
		else
		
			local sell = CreateOwnerTabs( hElement, "Omanik", "Katkesta Leping" );
			
			addEventHandler("onClientGUIClick", sell, 
				function ( )
				
					destroyElement( houseWind );
					windShowing = false;					
					triggerServerEvent( "onPropertySell", getLocalPlayer( ), hElement );
				
				end
			, false);
			
			local rentersTab = guiCreateTab( "Rentnikud", houseTabPanel );
			
			local rentList = guiCreateGridList( 0.05, 0.1, 0.9, 0.5, true, rentersTab );
			local column1 = guiGridListAddColumn( rentList, "#", 0.2 );
			local column2 = guiGridListAddColumn( rentList, "Nimi", 0.7 );
			
			local str = getElementData( hElement, "Renters" );	
			for word in string.gmatch( str, "%d+" ) do
			
				word = tonumber( word );
				if( word ~= 0 ) then
			
					local row = guiGridListAddRow( rentList );
					guiGridListSetItemText( rentList, row, column1, tostring( word ), false, false );
					local name = exports.phoenix_Characters:getCharacterName( word );
					guiGridListSetItemText( rentList, row, column2, tostring( name ), false, false );
					
				end			
			end
			
			local kickLabel = guiCreateLabel( 0.1, 0.65, 0.35, 0.1, "Katkesta Leping:", true, rentersTab );
			local kickOne = guiCreateButton( 0.45, 0.65, 0.2, 0.1, "Valitud", true, rentersTab );
			local kickAll = guiCreateButton( 0.7, 0.65, 0.2, 0.1, "Koik", true, rentersTab );
			
			local rentable = tonumber( getElementData( hElement, "rentable" ) );
			local rentcost = tonumber( getElementData( hElement, "rentcost" ) );
			local rentStatus = "Luba";
			if( rentable == 1 ) then rentStatus = "Keela"; end		
			
			guiCreateLabel( 0.1, 0.8, 0.24, 0.1, "Rentimine:", true, rentersTab );
			local renting = guiCreateButton( 0.35, 0.8, 0.2, 0.1, rentStatus, true, rentersTab );
			local edit = guiCreateEdit( 0.65, 0.8, 0.25, 0.1, tostring( rentcost ), true, rentersTab );
			
			addEventHandler( "onClientGUIAccepted", edit,
			
				function( theElement ) 
				
					local new = tonumber( guiGetText( theElement ) );
					if( not new ) then
					
						outputChatBox( "Pead sisestama numbrilise v��rtuse...", getLocalPlayer( ) );
					
					else
					
						if( new < 1 or new > 3000 ) then
						
							outputChatBox( "Hind peab j��ma vahemikku 1 - 3000. " );
							
						else
						
							setElementData( hElement, "rentcost", new );
						
						end
					
					end
					
					destroyElement( houseWind );
					windShowing = false;
					
				end
			
			);

			addEventHandler("onClientGUIClick", renting, 
				function ( )
					
					local lockStr = "0";
					if( rentable == 0 ) then lockStr = "1"; end
					setElementData( hElement, "rentable", lockStr );
					destroyElement( houseWind );
					windShowing = false;
				
				end
			, false);
			
			addEventHandler("onClientGUIClick", kickOne, 
				function ( )
				
					local srow, column = guiGridListGetSelectedItem( rentList );
			
					if( srow < 0 ) then
					
						outputChatBox( "Pead nimekirjast kellegi valima." );
						
					else
				
						
						local sel = tonumber( guiGridListGetItemText( rentList, srow, column1 ) );
						triggerServerEvent( "onPropertyUnRent", getLocalPlayer( ), hElement, sel );
						
						destroyElement( houseWind );
						windShowing = false;
					
					end
				
				end
			, false);
			
			addEventHandler("onClientGUIClick", kickAll, 
				function ( )
				
					destroyElement( houseWind );
					windShowing = false;
					
					triggerServerEvent( "onPropertyKickRenters", getLocalPlayer( ), hElement );
				
				end
			, false);
			
			local upgradeTab = guiCreateTab( "Uuendused", houseTabPanel );
			
			local upList = guiCreateGridList( 0.05, 0.1, 0.9, 0.65, true, upgradeTab );
			local upColumn1 = guiGridListAddColumn( upList, "Nimi", 0.7 );
			local upColumn2 = guiGridListAddColumn( upList, "Staatus", 0.2 );
			
			local canUp = true;
			local isUpgrading = tonumber( getElementData( hElement, "isUpgrading" ) );
			if( isUpgrading ~= 0 ) then canUp = false; end
			
			local buyUp = guiCreateButton( 0.6, 0.8, 0.3, 0.1, "Osta", true, upgradeTab );			
			guiSetEnabled( buyUp, canUp );
			
			addEventHandler("onClientGUIClick", buyUp, 
				function ( )
				
					local srow, column = guiGridListGetSelectedItem( upList );
			
					if( srow < 0 ) then
					
						outputChatBox( "Pead nimekirjast midagi valima." );
						
					elseif( srow == 0 ) then
				
						setElementData( hElement, "isUpgrading", "1" );							
						destroyElement( houseWind );
						windShowing = false;
					
					end
				
				end
			, false);			
			
			local upRow = guiGridListAddRow( upList );
			local stat = "Ei";
			
			if( getElementData( hElement, "HasSafe" ) == "1" ) then
				
				stat = "Jah";
				
			elseif( isUpgrading == 1 ) then
			
				stat = "Ehitusel";
			
			end				
			guiGridListSetItemText( upList, upRow, upColumn1, "Seif", false, false );
			guiGridListSetItemText( upList, upRow, upColumn2, stat, false, false );
		
		end
	
	end

end

function IsRenting( hElement, playerId )

	playerId = tonumber( playerId );
	local str = getElementData( hElement, "Renters" );
	
	if( string.find( str, "," ) ~= nil ) then
	
		for word in string.gmatch(str, "%d+") do
		
			local nr = tonumber( word );
			if( nr ~= nil and nr ~= false and nr == playerId ) then
				
				return true;
				
			end
		
		end
	
	else
	
		local nr = tonumber( str );
		if( nr ~= nil and nr ~= false and nr == playerId ) then
			
			return true;
		
		end
	
	end
	
	return false;

end

function getHouseByIndex( index )

	local houses = getElementsByType( "House" );
	
	for k,v in ipairs( houses ) do
	
		local id = tonumber( getElementData( v, "houseId" ) );
		if( id == tonumber( index ) ) then return v; end
	
	end
	
	return false;

end

function findpattern(text, pattern, start)

	return string.sub(text, string.find(text, pattern, start))
	
end

function houseMenu( screenX, screenY )
	
	local myX, myY, myZ = getElementPosition( getLocalPlayer( ) );
	local markers = getElementsByType( "marker" );
		
	for k,v in ipairs( markers ) do
	
		local markerX, markerY, markerZ  = getElementPosition( v );
		local dist1 = getDistanceBetweenPoints3D( myX, myY, myZ, markerX, markerY, markerZ );
		
		if( dist1 < 30 ) then
		
			local freeView = processLineOfSight ( myX, myY, myZ, markerX, markerY, markerZ );
			
			if( freeView == false ) then
				
				local msX, msY = getScreenFromWorldPosition( markerX, markerY, markerZ );
				
				if( msX ~= false and msY ~= false ) then
						
					local dist = getDistanceBetweenPoints2D( screenX, screenY, msX, msY );
					outputChatBox( dist );
					if( dist < 60 ) then
				
						local id = getElementData( v, "infoId" );

						if( id ~= false ) then				
							
							if( string.find( id, "House." ) ~= nil ) then
								
								local houseId = tonumber( findpattern( id, "%d+", 7 ) );
								
								if( houseId ~= nil and houseId ~= false ) then
							
									local parent = getHouseByIndex( houseId );
									
									if( parent ~= false ) then
									
										createHouseMenu( getElementData( parent, "Address" ) );
										return showHouseMenu( parent, screenX, screenY );
									
									end
									
								end
								
							end
						
						end		
					end
				end
			end
		end
	end
end


addEventHandler( "onClientClick", getRootElement(), 

	function ( button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement )
	
		if( button == "left" and windShowing == false ) then
		
			if( state == "down" ) then
			
				if( clickedElement == false ) then
				
					houseMenu( absoluteX, absoluteY )
				
				end
			
			end
		
		end
	
	end

, true);

local adPosX = nil;
local adPosY = nil;
local adPosZ = nil;
local trashX = nil;
local trashY = nil;
local trashZ = nil;

addCommandHandler( "uks", 
	function ( commandName )
	
		adPosX, adPosY, adPosZ = getElementPosition( player );
		adPosZ = adPosZ + 1;
	
	end
);
addCommandHandler( "kastike", 
	function ( commandName )
	
		trashX, trashY, trashZ = getElementPosition( player );
	
	end
);
addCommandHandler( "maja", 
	function ( commandName )
	
		if( adPosX and adPosY and adPosZ and trashX and trashY and trashZ ) then
			
			local tbl = { };
			tbl[1] = adPosX;
			tbl[2] = adPosY;
			tbl[3] = adPosZ;
			tbl[4] = trashX;
			tbl[5] = trashY;
			tbl[6] = trashZ;
			tbl[7] = 0;
			tbl[8] = math.random( 16, 22 );
			
			triggerServerEvent( "onHouseReg", player, tbl );
			
			adPosX = nil;
			adPosY = nil;
			adPosZ = nil;
			trashX = nil;
			trashY = nil;
			trashZ = nil;			
		
		end
	
	end
);