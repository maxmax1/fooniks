local player = getLocalPlayer( );
local sx, sy = guiGetScreenSize( );

local windShowing = false;
local bizWind = nil;
local bizTabPanel = nil;
local closeBtn = nil;

local openclose = nil;
local sell = nil;

local enterWareHouseButton = nil;
local autoOne = nil;
local plusOne = nil;
local minOne = nil;

local infoTab = nil;
local bankTab = nil;
local serviceTab = nil;
local loadTab = nil;

local wareGrid = nil;

local bBank = 0;
local current = 0;
local iCh_1 = false;
local iChE_1 = false;

local myMoney = 0;
local cMoney = 0;
local iCh_2 = false;


function createBizMenu( name, hide )

	if( bizWind and isElement( bizWind ) ) then
	
		guiSetVisible( bizWind, false );
		windShowing = false;		
		if( hide ) then return; end
		
		if( bankTab ~= nil and isElement( bankTab ) ) then guiDeleteTab( bankTab, bizTabPanel ); bankTab = nil; end
		if( serviceTab ~= nil and isElement( serviceTab ) ) then guiDeleteTab( serviceTab, bizTabPanel ); serviceTab = nil; end
		if( loadTab ~= nil and isElement( loadTab ) ) then guiDeleteTab( loadTab, bizTabPanel ); loadTab = nil; end
		if( infoTab ~= nil and isElement( infoTab ) ) then guiDeleteTab( infoTab, bizTabPanel ); infoTab = nil; end
	
	else
	
		bizWind = guiCreateWindow( (sx-300)/2, (sy-250)/2, 300, 250, name .. " - FIRMA CP", false );
		bizTabPanel = guiCreateTabPanel( 0.05, 0.1, 0.9, 0.75, true, bizWind );
		closeBtn = guiCreateButton( 0.75, 0.86, 0.2, 0.15, "Sulge", true, bizWind ); 
		
		addEventHandler("onClientGUIClick", closeBtn, 
			function ( button, state )
			
				if( button ~= "left" or state ~= "up" ) then return false; end
				createBizMenu( name, true );
			
			end
		, false);
	
	end
	
	guiSetVisible( bizWind, false );
	windShowing = false;	

end

function showBizMenu( bElem, absX, absY )

	local owner = tonumber( getElementData( bElem, "bizOwner" ) );
	local pSqlId = tonumber( getElementData( player, "Character.id" ) );
	
	if( owner == 0 ) then
	
		infoTab = guiCreateTab( "Info", bizTabPanel );
		
		guiCreateLabel( 0.05, 0.1, 0.8, 0.1, "NIMI:", true, infoTab );
		guiCreateLabel( 0.05, 0.2, 0.8, 0.1, "OMANIK:", true, infoTab );
		guiCreateLabel( 0.05, 0.3, 0.8, 0.1, "VARA:", true, infoTab );
		guiCreateLabel( 0.05, 0.4, 0.8, 0.1, "TURUHIND:", true, infoTab );
		
		local name = string.upper( getElementData( bElem, "bizName" ) );
		bBank = tonumber( getElementData( bElem, "bizBank" ) );
		local oName = false;
		local price = bBank;
		local realVal; -- TODO: Add the price of products + servicespots.
		
		if( owner ~= 0 ) then
		
			oName = exports.phoenix_Characters:getCharacterName( owner );
		
		end
		
		if( not oName ) then oName = "RIIK"; end
		
		guiCreateLabel( 0.4, 0.1, 0.4, 0.1, name, true, infoTab );
		guiCreateLabel( 0.4, 0.2, 0.4, 0.1, oName, true, infoTab );
		guiCreateLabel( 0.4, 0.3, 0.4, 0.1, bBank .. " EEK", true, infoTab );
		guiCreateLabel( 0.4, 0.4, 0.4, 0.1, price .. " EEK", true, infoTab );
		
		if( owner == 0 ) then
		
			local buyButton = guiCreateButton( 0.75, 0.4, 0.15, 0.1, "OSTA", true, infoTab );
			addEventHandler("onClientGUIClick", buyButton, 
				function ( button, state )
				
					if( button ~= "left" or state ~= "up" ) then return false; end
					createBizMenu( "null", true );
					triggerServerEvent( "onBisnessPurchase", player, bElem, price );	
				
				end
			, false);		
		
		end
		
		guiSetVisible( bizWind, true );
		windShowing = true;
	
	elseif( owner == pSqlId ) then
		
		triggerServerEvent( "onBizCPInit", player, bElem );
	
	else
	
		exports.phoenix_Chat:OocInfo( "Pole õigusi!" );
	
	end

end

function OwnerWind( bElem, loadTbl, serviceTbl, myMoney )

	if( not bizWind or 
	    not bizTabPanel or
		not isElement( bizWind ) or 
		not isElement(bizTabPanel) or
		not bElem or
		not loadTbl or
		not serviceTbl or 
		not myMoney) then
	
		outputDebugString( "false" );
		return false;
	
	end

	local owner = tonumber( getElementData( bElem, "bizOwner" ) );
	
	if( infoTab ~= nil and isElement( infoTab ) ) then guiDeleteTab( infoTab, bizTabPanel ); infoTab = nil; end
	infoTab = guiCreateTab( "Info", bizTabPanel );
	
	guiCreateLabel( 0.05, 0.1, 0.8, 0.1, "NIMI:", true, infoTab );
	guiCreateLabel( 0.05, 0.2, 0.8, 0.1, "OMANIK:", true, infoTab );
	guiCreateLabel( 0.05, 0.3, 0.8, 0.1, "VARA:", true, infoTab );
	guiCreateLabel( 0.05, 0.4, 0.8, 0.1, "TURUHIND:", true, infoTab );
	guiCreateLabel( 0.05, 0.5, 0.8, 0.1, "STAATUS:", true, infoTab );
	guiCreateLabel( 0.05, 0.6, 0.8, 0.1, "OMAND:", true, infoTab );
	
	local name = string.upper( getElementData( bElem, "bizName" ) );
	bBank = tonumber( getElementData( bElem, "bizBank" ) );
	local oName = exports.phoenix_Characters:getCharacterName( owner );
	local price = bBank; -- TODO: Add the price of products + servicespots.
	
	local statusStr = "Suletud";
	local statusBtn = "Ava";
	local bizOpen = tonumber( getElementData( bElem, "bizOpen" ) );
	if( bizOpen == 1 ) then
	
		statusStr = "Avatud";
		statusBtn = "Sule";
	
	end
	
	local nameE = guiCreateEdit( 0.375, 0.1, 0.3, 0.125, name, true, infoTab );
	guiSetVisible( nameE, false );
	local nameL = guiCreateLabel( 0.4, 0.1, 0.4, 0.1, name, true, infoTab );		
	local edit = guiCreateButton( 0.7, 0.085, 0.2, 0.125, "Muuda", true, infoTab );
	
	local ok = guiCreateButton( 0.7, 0.1, 0.1, 0.125, "OK", true, infoTab );
	local canc = guiCreateButton( 0.805, 0.1, 0.1, 0.125, "X", true, infoTab );
	guiSetVisible( ok, false );
	guiSetVisible( canc, false );
	
	addEventHandler("onClientGUIClick", edit, 
		function ( button, state )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			guiSetVisible( nameE, true );
			guiSetVisible( ok, true );
			guiSetVisible( canc, true );
			guiSetInputEnabled( true );
			guiSetVisible( nameL, false );
			guiSetVisible( edit, false );
		
		end
	, false);		
	
	addEventHandler("onClientGUIClick", ok, 
		function ( button, state )	
			
			if( button ~= "left" or state ~= "up" ) then return false; end
			local oName = guiGetText( nameL );
			local newName = guiGetText( nameE );
			if( oName == newName ) then
			
				exports.phoenix_Chat:OocInfo( "Nimi on sama." );
			
			else
			
				guiSetText( nameL, newName );				
				triggerServerEvent( "onBisnessNameChange", player, bElem, newName );
			
			end
			
			guiSetVisible( nameE, false );
			guiSetVisible( ok, false );
			guiSetVisible( canc, false );
			guiSetInputEnabled( false );
			guiSetVisible( nameL, true );
			guiSetVisible( edit, true );
		
		end
	, false);
	
	addEventHandler("onClientGUIClick", canc, 
		function ( button, state )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
				
			guiSetVisible( nameE, false );
			guiSetVisible( ok, false );
			guiSetVisible( canc, false );
			guiSetInputEnabled( false );
			guiSetVisible( nameL, true );
			guiSetVisible( edit, true );
		
		end
	, false);
	
	guiCreateLabel( 0.4, 0.2, 0.4, 0.1, oName, true, infoTab );
	guiCreateLabel( 0.4, 0.3, 0.4, 0.1, bBank .. " EEK", true, infoTab );
	guiCreateLabel( 0.4, 0.4, 0.4, 0.1, price .. " EEK", true, infoTab );
	local statusL = guiCreateLabel( 0.4, 0.5, 0.4, 0.1, statusStr, true, infoTab );
	
	local check = guiCreateCheckBox( 0.4, 0.6, 0.3, 0.1, "JAH MYY", false, true, infoTab );
	
	addEventHandler("onClientGUIClick", check, 
		function ( button, state )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
		
			local state = guiCheckBoxGetSelected( check );
			if( sell ) then guiSetEnabled( sell, state ); end
			if( state ) then
			
				exports.helpmanager:showHelpPopup( false, "Ettevaatust, sellega annetad firma riigile. Kandi raha enne tehingut v2lja!" );
			
			end
		
		end
	, false);	
	
	bankTab = guiCreateTab( "Pank", bizTabPanel );
	
	guiCreateLabel( 0.05, 0.1, 0.8, 0.1, "ARVEL:", true, bankTab );
	guiCreateLabel( 0.05, 0.2, 0.8, 0.1, "Tee Sulaks:", true, bankTab );
	guiCreateLabel( 0.05, 0.5, 0.8, 0.1, "Pane Arvele:", true, bankTab );
	
	guiCreateLabel( 0.4, 0.1, 0.3, 0.1, tostring( bBank ), true, bankTab );
	
	current = 0;	
	local e_1 = guiCreateEdit( 0.05, 0.325, 0.2, 0.15, "0", true, bankTab ); 
	local s_1 = guiCreateScrollBar( 0.28, 0.325, 0.49, 0.15, true, true, bankTab );
	guiScrollBarSetScrollPosition( s_1, 0 );
	local b_1 = guiCreateButton( 0.8, 0.325, 0.15, 0.15, "OK", true, bankTab );
	
	addEventHandler( "onClientGUIChanged", e_1,
	
		function ()
		
			current = tonumber( guiGetText( e_1 ) );
			if( not current ) then
			
				current = 0;
			
			elseif( current < 0 ) then
			
				current = 0;
				guiSetText( e_1, current );
			
			elseif( current > bBank ) then
			
				current = bBank;
				guiSetText( e_1, current );
			
			end
			
			iCh_1 = true;
			local newVal = math.ceil( ( current / bBank ) * 100 );
			guiScrollBarSetScrollPosition( s_1, newVal );
			
		end
	
	);
	
	addEventHandler( "onClientGUIScroll", s_1,
	
		function ()
		
			if( iCh_1 ) then
			
				iCh_1 = false;
				
			else
			
				local val = math.ceil( ( guiScrollBarGetScrollPosition( s_1 ) / 100 ) * bBank );
				guiSetText( e_1, val );
			
			end
		
		end
	
	);
	
	addEventHandler("onClientGUIClick",  b_1, 
		function ( button, state )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			triggerServerEvent( "onBizBank", player, bElem, -1*(current) );
			createBizMenu( name, true );
		
		end
	, false);
	
	cMoney = 0;
	local e_2 = guiCreateEdit( 0.05, 0.625, 0.2, 0.15, "0", true, bankTab ); 
	local s_2 = guiCreateScrollBar( 0.28, 0.625, 0.49, 0.15, true, true, bankTab );
	guiScrollBarSetScrollPosition( s_2, 0 );
	local b_2 = guiCreateButton( 0.8, 0.625, 0.15, 0.15, "OK", true, bankTab );
	
	addEventHandler( "onClientGUIChanged", e_2,
	
		function ()
		
			cMoney = tonumber( guiGetText( e_2 ) );
			if( not cMoney ) then
			
				cMoney = 0;
			
			elseif( cMoney < 0 ) then
			
				cMoney = 0;
				guiSetText( e_2, cMoney );
			
			elseif( cMoney > myMoney ) then
			
				cMoney = myMoney;
				guiSetText( e_2, cMoney );
			
			end
			
			iCh_2 = true;
			local newVal = math.ceil( ( cMoney / myMoney ) * 100 );
			guiScrollBarSetScrollPosition( s_2, newVal );
			
		end
	
	);
	
	addEventHandler( "onClientGUIScroll", s_2,
	
		function ()
		
			if( iCh_2 ) then
			
				iCh_2 = false;
				
			else
		
				local val = math.ceil( ( guiScrollBarGetScrollPosition( s_2 ) / 100 ) * myMoney );
				guiSetText( e_2, val );
			
			end
		
		end
	
	);
	
	addEventHandler("onClientGUIClick",  b_2, 
		function ( button, state )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			triggerServerEvent( "onBizBank", player, bElem, cMoney );
			createBizMenu( name, true );
		
		end
	, false);	
	
	serviceTab = guiCreateTab( "Teenused", bizTabPanel );
	
	local services = guiCreateScrollPane( 0.1, 0.2, 0.9, 0.8, true, serviceTab );
	guiCreateLabel( 0.1, 0.05, 0.8, 0.1, "Nimi", true, serviceTab );
	guiCreateLabel( 0.7, 0.05, 0.8, 0.1, "Hind", true, serviceTab );
	guiCreateStaticImage( 0.05, 0.135, 0.9, 0.02, ":phoenix_Characters/files/images/gui-white.png", true, serviceTab );
	local srvE = {};
	local y = 0.1;
	
	for k, v in pairs( serviceTbl ) do
	
		guiCreateLabel( 0.05, y+0.005, 0.8, 0.1, v["name"], true, services );
		srvE[k] = guiCreateEdit( 0.375, y-0.005, 0.3, 0.125, tostring( v["cost"] ), true, services );
		local bt = guiCreateButton( 0.7, y-0.005, 0.2, 0.125, "Muuda", true, services );
		addEventHandler("onClientGUIClick",  bt, 
			function ( button, state )
			
				if( button ~= "left" or state ~= "up" ) then return false; end
				local txt = tonumber( guiGetText( srvE[k] ) );
				if( txt ) then
				
					serviceTbl[k]["cost"] = txt;
					triggerServerEvent( "onBizServiceEdit", player, bElem, k, serviceTbl[k] );
				
				else
				
					exports.phoenix_Chat:OocInfo( "Vigane sisestus!" );
				
				end
				
			
			end
		, false);
		
		y = y + 0.1;
	
	end
	
	loadTab = guiCreateTab( "Ladu", bizTabPanel );
	
	wareGrid = guiCreateGridList( 0, 0, 1, 1, true, loadTab );
	wcol1 = guiGridListAddColumn( wareGrid, "Nimi", 0.35 );
	wcol2 = guiGridListAddColumn( wareGrid, "Kogus", 0.15 );
	wcol3 = guiGridListAddColumn( wareGrid, "Maksimum", 0.175 );
	wcol4 = guiGridListAddColumn( wareGrid, "Ostan", 0.15 );
	wcol5 = guiGridListAddColumn( wareGrid, " ", 0.1 );
	for k, v in pairs( loadTbl ) do
	
		local r = guiGridListAddRow( wareGrid );
		guiGridListSetItemText( wareGrid, r, wcol1, k, false, false );
		guiGridListSetItemText( wareGrid, r, wcol2, tostring( v["has"] ), false, false );
		guiGridListSetItemText( wareGrid, r, wcol3, tostring( v["max"] ), false, false );
		guiGridListSetItemText( wareGrid, r, wcol4, tostring( v["wants"] ), false, false );
		local lbl = "manuaal";
		if( tonumber( v["autobuy"] ) == 1 ) then lbl = "auto"; end
		guiGridListSetItemText( wareGrid, r, wcol5, lbl, false, false );
	
	end
	
	addEventHandler( "onClientGUITabSwitched", bizTabPanel,
	
		function ( theElement )
		
			if( theElement == loadTab ) then
			
				enterWareHouseButton = guiCreateButton( 0.545, 0.86, 0.2, 0.15, "Lattu", true, bizWind ); 
				addEventHandler("onClientGUIClick", enterWareHouseButton, 
					function ( button, state )
					
						if( button == "left" and state == "up" ) then
						
							createBizMenu( "null", true );
							triggerServerEvent( "onPlayerEnterWarehouse", player, player, bElem );	
						
						end
					
					end
				, false);	

				autoOne = guiCreateButton( 0.230, 0.86, 0.1, 0.15, "...", true, bizWind );
				plusOne = guiCreateButton( 0.335, 0.86, 0.1, 0.15, "+", true, bizWind ); 
				guiSetEnabled( plusOne, false );
				minOne = guiCreateButton( 0.440, 0.86, 0.1, 0.15, "-", true, bizWind );
				guiSetEnabled( minOne, false );
				
				addEventHandler( "onClientGUIClick", autoOne, 
				
					function ( button, state )
					
						if( button == "left" and state == "up" ) then
						
							local r, c = guiGridListGetSelectedItem( wareGrid );
							RequestAutoProds( bElem, guiGridListGetItemText( wareGrid, r, wcol1 ), r );
						
						end
						
					end
					
				);
				
				addEventHandler( "onClientGUIClick", wareGrid, 
				
					function ( button, state )
					
						if( button == "left" and state == "up" ) then
						
							local r, c = guiGridListGetSelectedItem( wareGrid );
							if( r and c and r ~= -1 and c ~= -1 ) then
							
								ProdPlusMinCheck( wcol4, r );
							
							end
						
						end
						
					end
					
				);

				addEventHandler( "onClientGUIClick", plusOne, 
				
					function ( button, state )
					
						if( button == "left" and state == "up" ) then
						
							local r, c = guiGridListGetSelectedItem( wareGrid );
							RequestSomeProds( bElem, guiGridListGetItemText( wareGrid, r, wcol1 ), 1, wcol4, r );
						
						end
						
					end
					
				);
				
				addEventHandler( "onClientGUIClick", minOne, 
				
					function ( button, state )
					
						if( button == "left" and state == "up" ) then
						
							local r, c = guiGridListGetSelectedItem( wareGrid );
							RequestSomeProds( bElem, guiGridListGetItemText( wareGrid, r, wcol1 ), -1, wcol4, r );
						
						end
						
					end
					
				);
			
			else
			
				if( enterWareHouseButton ) then
				
					destroyElement( enterWareHouseButton );
					destroyElement( plusOne );
					destroyElement( minOne );
					destroyElement( autoOne );
					enterWareHouseButton = false;
					plusOne = false;
					minOne = false;
					autoOne = false;
				
				end
			
			end
		
			if( theElement == infoTab ) then
			
				openclose = guiCreateButton( 0.545, 0.86, 0.2, 0.15, statusBtn, true, bizWind );
	
				addEventHandler("onClientGUIClick", openclose, 
					function ( button, state )
					
						if( button ~= "left" or state ~= "up" ) then return false; end
					
						if( bizOpen == 0 ) then
						
							guiSetText( statusL, "Avatud" );
							guiSetText( openclose, "Sule" );
							bizOpen = 1;
						
						else
						
							guiSetText( statusL, "Suletud" );
							guiSetText( openclose, "Ava" );
							bizOpen = 0;
						
						end
						
						triggerServerEvent( "onBisnessOpenClose", player, bElem, bizOpen );
					
					end
				, false);
				
				sell = guiCreateButton( 0.340, 0.86, 0.2, 0.15, "MYY", true, bizWind );
				guiSetEnabled( sell, false );	
				addEventHandler("onClientGUIClick", sell, 
					function ( button, state )
					
						if( button ~= "left" or state ~= "up" ) then return false; end
						triggerServerEvent( "onBisnessSold", player, bElem );
						createBizMenu( name, true );
					
					end
				, false);					
			
			else
			
				if( openclose ) then destroyElement( openclose ); openclose = nil; end
				if( sell ) then destroyElement( sell ); sell = nil; end
			
			end
		
		end

	);
	
	guiSetSelectedTab( bizTabPanel, bankTab );
	guiSetSelectedTab( bizTabPanel, infoTab );

	guiSetVisible( bizWind, true );
	windShowing = true;		
	
end

function RequestSomeProds( bElem, prodName, editor, col, row )

	local oldval = tonumber( guiGridListGetItemText( wareGrid, row, col ) );
	if( not oldval ) then return false; end
	
	local newval = oldval + editor;
	guiGridListSetItemText( wareGrid, row, col, tostring( newval ), false, false );
	triggerServerEvent( "onBizProductstatusChange", player, bElem, prodName, editor );
	ProdPlusMinCheck( col, row );
	guiGridListSetSelectedItem( wareGrid, row, 1 );
	
end

function RequestAutoProds( bElem, prodName, row )

	local oldval = guiGridListGetItemText( wareGrid, row, wcol5 );
	local newI, newL;
	
	if( oldval == "auto" ) then
	
		newI = 0;
		newL = "manuaal";
	
	else
	
		newI = 1;
		newL = "auto";
	
	end	
	
	guiGridListSetItemText( wareGrid, row, wcol5, newL, false, false );
	triggerServerEvent( "onBizProductautoChange", player, bElem, prodName, newI );
	ProdPlusMinCheck( wcol4, row );
	guiGridListSetSelectedItem( wareGrid, row, 1 );
	
end

function ProdPlusMinCheck( col, row )

	local oldval = tonumber( guiGridListGetItemText( wareGrid, row, col ) );
	local maxi = tonumber( guiGridListGetItemText( wareGrid, row, col-1 ) );
	local has = tonumber( guiGridListGetItemText( wareGrid, row, col-2 ) );
	
	if( oldval+1 > maxi-has ) then
	
		guiSetEnabled( plusOne, false );
	
	else
	
		guiSetEnabled( plusOne, true );
	
	end
	
	if( oldval-1 < 0 ) then

		guiSetEnabled( minOne, false );
	
	else
	
		guiSetEnabled( minOne, true );
	
	end
	
	local automat = guiGridListGetItemText( wareGrid, row, wcol5 );
	if( automat == "auto" ) then
	
		guiSetText( autoOne, "M" );
	
	else
	
		guiSetText( autoOne, "A" );
	
	end

end

addEvent( "onBizCPDisplay", true );
addEventHandler( "onBizCPDisplay", getRootElement( ), OwnerWind );

function getBizByIndex( index )

	local biz = getElementsByType( "bizness" );
	index = tonumber( index );
	for k,v in ipairs( biz ) do
	
		local id = tonumber( getElementData( v, "sqlid" ) );
		if( id == index ) then return v; end
	
	end
	
	return false;

end

function BizMenu( element, infoId, button, state, screenX, screenY )

	if( button == "left" and state == "down" and windShowing == false ) then
	
		if( string.find( infoId, "Biz." ) ~= nil ) then
		
			local bizId = tonumber( findpattern( infoId, "%d+", 5 ) );
			if( bizId ~= nil and bizId ~= false ) then
		
				local parent = getBizByIndex( bizId );				
				if( parent ~= false ) then
				
					createBizMenu( getElementData( parent, "bizName" ) );
					return showBizMenu( parent, screenX, screenY );
				
				end
				
			end
			
		end
	
	end

end

addEventHandler( "onInfospotClicked", player, BizMenu, true);

function findpattern(text, pattern, start)

	return string.sub(text, string.find(text, pattern, start))
	
end