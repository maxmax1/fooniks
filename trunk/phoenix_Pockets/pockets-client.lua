-- Trademenüü on eraldi asi tuleb onPlayerClickPlayer abiga. :)

local pockGridList;
local useBtn;
local dropBtn;
local destroyBtn;
local gridColumn = { };
local items = { };

function createPocketsGUI( )

	pockGridList = guiCreateGridList( 0.3, 0.3, 0.4, 0.4, true );
	guiGridListSetSelectionMode( pockGridList, 0 );
	
	gridColumn[1] = guiGridListAddColumn( pockGridList, "#", 0.1 );
	gridColumn[2] = guiGridListAddColumn( pockGridList, "Ese", 0.5 );
	gridColumn[3] = guiGridListAddColumn( pockGridList, "Data", 0.3 );
	
	useBtn = guiCreateButton( 0.3, 0.725, 0.125, 0.05, "Kasuta", true ); -- 0.3 - 0.425
	dropBtn = guiCreateButton( 0.4375, 0.725, 0.125, 0.05, "Viska maha", true ); -- 0.4375 - 0.5625
	destroyBtn = guiCreateButton( 0.575, 0.725, 0.125, 0.05, "Purusta", true ); -- 0.575 - 0.7
	
	guiSetEnabled( useBtn, false );
	guiSetEnabled( dropBtn, false );
	guiSetEnabled( destroyBtn, false );
	
	addEventHandler("onClientGUIClick", useBtn, 
		function ( )
		
			local row, column = guiGridListGetSelectedItem( pockGridList );
			
			if( row < 0 ) then
			
				outputChatBox( "Pead nimekirjast midagi valima." );
				
			else
			
				local id = tonumber( guiGridListGetItemText( pockGridList, row, gridColumn[1] ) );
				triggerServerEvent( "onUseItem", getLocalPlayer( ), id );		
			
			end
		
		end
	, false);
	
	addEventHandler("onClientGUIClick", dropBtn, 
		function ( )
		
			local row, column = guiGridListGetSelectedItem( pockGridList );
			
			if( row < 0 ) then
			
				outputChatBox( "Pead nimekirjast midagi valima." );
				
			else
			
				local id = tonumber( guiGridListGetItemText( pockGridList, row, gridColumn[1] ) );
				triggerServerEvent( "onDropItem", getLocalPlayer( ), id );		
			
			end
		
		end
	, false);
	
	addEventHandler("onClientGUIClick", destroyBtn, 
		function ( )
		
			local row, column = guiGridListGetSelectedItem( pockGridList );
			
			if( row < 0 ) then
			
				outputChatBox( "Pead nimekirjast midagi valima." );
				
			else
			
				local id = tonumber( guiGridListGetItemText( pockGridList, row, gridColumn[1] ) );
				triggerServerEvent( "onDestroyItem", getLocalPlayer( ), id );		
			
			end
		
		end
	, false);
	
	guiSetVisible( pockGridList, false );	
	guiSetVisible( useBtn, false );	
	guiSetVisible( dropBtn, false );	
	guiSetVisible( destroyBtn, false );	
	
	showCursor( false );

end

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), 

	function ()
	
		createPocketsGUI( );
	
	end
	
);

addEvent( "SyncItem", true );
addEventHandler("SyncItem", getResourceRootElement( getThisResource( ) ), 

	function ( serverPockets )
	
		items = { };
		
		for k, v in ipairs( serverPockets ) do
		
			items[k] = { };
			items[k]['type'] = v['type'];
			items[k]['data'] = v['data'];
			items[k]['id'] = v['id'];
			items[k]['pType'] = v['pType'];
		
		end
		
		BuildPockets( );
	
	end
	
);

function getSlotByItem( item )

	for k, v in ipairs( items ) do
	
		if( tonumber( items[k]['pType'] ) == item ) then
		
			return v['id'];
		
		end
		
	end
	
	return false;
	
end

function BuildPockets( )

	guiGridListClear( pockGridList );
	
	for k, v in ipairs( items ) do
	
		local row = guiGridListAddRow( pockGridList );
		guiGridListSetItemText( pockGridList, row, gridColumn[1], tostring( v['id'] ), false, false );
		guiGridListSetItemText( pockGridList, row, gridColumn[2], v['type'], false, false );
		guiGridListSetItemText( pockGridList, row, gridColumn[3], tostring( v['data'] ), false, true );	
	
	end
	
	guiSetEnabled( useBtn, true );
	guiSetEnabled( dropBtn, true );
	guiSetEnabled( destroyBtn, true );	
	
end

addCommandHandler( "taskud", 

	function()
	
		if( guiGetVisible( pockGridList ) == false ) then
	
			BuildPockets( );
	
			guiSetVisible( pockGridList, true );	
			guiSetVisible( useBtn, true );	
			guiSetVisible( dropBtn, true );	
			guiSetVisible( destroyBtn, true );	
			
			if( isCursorShowing( ) == false ) then
			
				showCursor( true );
			
			end
		
		else
		
			guiSetVisible( pockGridList, false );	
			guiSetVisible( useBtn, false );	
			guiSetVisible( dropBtn, false );	
			guiSetVisible( destroyBtn, false );	
			
			if( isCursorShowing( ) == true ) then
			
				showCursor( false );
			
			end
		
		end
		
	end
	
, false, false );