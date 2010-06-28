local player = getLocalPlayer( );
local rootElement = getRootElement( );
local sx, sy = guiGetScreenSize( );

local editWind = { };

function ShowEditbox( title, label, label2, internalId, editEvent, visualEdit, under, filter, syncFunc )

	if( editWind.wind ) then
	
		destroyElement( editWind.wind );
		editWind.wind = nil;
	
	end

	if( not editWind.wind ) then
	
		editWind.wind = guiCreateWindow( (sx-250)/2, (sy-150)/2, 250, 150, " ", false );
		editWind.label = guiCreateLabel( 0.05, 0.2, 0.9, 0.2, " ", true, editWind.wind );
		editWind.edit = guiCreateEdit( 0.05, 0.45, 0.9, 0.20, " ", true, editWind.wind );
		editWind.ok = guiCreateButton( 0.525, 0.75, 0.2, 0.2, "Ok", true, editWind.wind ); 
		editWind.cancel = guiCreateButton( 0.75, 0.75, 0.2, 0.2, "Katkesta", true, editWind.wind ); 
		
		editWind.check = guiCreateCheckBox( 0.05, 0.75, 0.4, 0.3, "kastike", false, true, editWind.wind );
		
		addEventHandler( "onClientGUIClick", editWind.ok, 
		
			function ( button, state, absoluteX, absoluteY )
			
				if( button ~= "left" or state ~= "up" ) then return false; end
				if( source ~= editWind.ok ) then return false; end
				
				local txt = guiGetText( editWind.edit );
				setElementData( visualEdit, "realVal", txt );
				
				local txt2 = "0";
				if( guiCheckBoxGetSelected( editWind.check ) ) then
				
					txt2 = "1";
				
				end
				setElementData( visualEdit, "checked", txt2 );
				
				if( filter ) then
				
					txt = filter( txt, visualEdit );
				
				end
				
				guiSetText( visualEdit, txt );
				
				if( under ) then
				
					local width = dxGetTextWidth( txt, 1, "default-bold" );
					guiSetSize( under, width+4, 1, false );
					
					guiSetVisible( under, ( txt2 == "1" ) );
				
				end
				
				if( type( editEvent ) == "string" ) then
				
					triggerServerEvent( editEvent, player, internalId, txt, txt2 );
				
				elseif( editEvent ) then
				
					editEvent( internalId, txt, txt2 );
				
				end
				syncFunc( );
				
				guiSetVisible( editWind.wind, false );
				
				SetGroupControlPanelStatus( true );
			
			end
		
		);

		addEventHandler( "onClientGUIClick", editWind.cancel, 
		
			function ( button, state, absoluteX, absoluteY )
			
				if( button ~= "left" or state ~= "up" ) then return false; end
				if( source ~= editWind.cancel ) then return false; end
				
				guiSetVisible( editWind.wind, false );
				--guiSetInputEnabled( false );
				
				SetGroupControlPanelStatus( true );
			
			end
		
		);
		
		guiSetProperty ( editWind.wind, "AlwaysOnTop", "true" );
		guiWindowSetSizable( editWind.wind, false );
	
	end

	if( #label > 40 ) then
	
		label = string.sub( label, 0, 39 ) .. string.gsub( string.sub( label, 40 ), " ", "\n", 1);
	
	end
	
	if( not label2 ) then
	
		guiSetVisible( editWind.check, false );
	
	else
	
		guiSetText( editWind.check, label2 );
	
	end
	
	SetGroupControlPanelStatus( false );
	
	guiSetText( editWind.wind, title );
	guiSetText( editWind.label, label );
	guiSetText( editWind.edit, getElementData( visualEdit, "realVal" ) );
	
	local stat = false;
	if( getElementData( visualEdit, "checked" ) == "1" ) then
	
		stat = true;
	
	end
	guiCheckBoxSetSelected( editWind.check, stat );
	
	if( getElementData( visualEdit, "checkDisabled" ) == "1" ) then
	
		guiSetEnabled( editWind.check, false );
	
	end
	
	editWind.internal = internalId;
	editWind.event = editEvent;
	
	guiSetVisible( editWind.wind, true );
	--guiSetInputEnabled( true );
	guiBringToFront( editWind.wind );
	
end


function registerMembEditor( btn, id, info, ranks )

	id = tonumber( id );
	
	addEventHandler( "onClientGUIClick", btn, 
	
		function ( button, state, absoluteX, absoluteY )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			if( source ~= btn ) then return false; end
		
			if( editWind.wind ) then
			
				destroyElement( editWind.wind );
				editWind.wind = nil;
			
			end
			
			if( not editWind.wind ) then
			
				editWind.wind = guiCreateWindow( (sx-250)/2, (sy-150)/2, 250, 150, " ", false );
				editWind.label = guiCreateLabel( 0.05, 0.2, 0.9, 0.2, "Vali soovitud auaste liikmele: \n   " .. info["name"], true, editWind.wind );
				editWind.ok = guiCreateButton( 0.525, 0.75, 0.2, 0.2, "Ok", true, editWind.wind ); 
				editWind.cancel = guiCreateButton( 0.75, 0.75, 0.2, 0.2, "Katkesta", true, editWind.wind ); 
				
				editWind.combo = guiCreateComboBox( 0.05, 0.45, 0.9, 0.15, "Kasutaja auaste...", true, editWind.wind );				
				
				if( ranks[tonumber( info["rank"] )]["isLeader"] == "1" and getPlayerName( player ) == info["name"] ) then
				
					guiSetEnabled( guiComboboxGetButton( editWind.combo ), false );
				
				end
				
				for k, v in pairs( ranks ) do
				
					local item = guiComboBoxAddItem( editWind.combo, v["label"] );
					if( tonumber( k ) == tonumber( info["rank"] ) ) then
					
						guiComboBoxSetSelected(  editWind.combo, item );
					
					end
				
				end
				
				addEventHandler( "onClientGUIClick", editWind.ok, 
				
					function ( button, state, absoluteX, absoluteY )
					
						if( button ~= "left" or state ~= "up" ) then return false; end
						if( source ~= editWind.ok ) then return false; end
						
						guiSetVisible( editWind.wind, false );
						
						local txt = guiComboBoxGetItemText( editWind.combo, guiComboBoxGetSelected( editWind.combo ) );
						triggerServerEvent( "onGroupMemberEdit", player, id, txt );
						
						SetGroupControlPanelStatus( true );
						
						createWindow( true );
					
					end
				
				);
				
				addEventHandler( "onClientGUIClick", editWind.cancel, 
				
					function ( button, state, absoluteX, absoluteY )
					
						if( button ~= "left" or state ~= "up" ) then return false; end
						if( source ~= editWind.cancel ) then return false; end
						
						guiSetVisible( editWind.wind, false );
						--guiSetInputEnabled( false );
						
						SetGroupControlPanelStatus( true );
					
					end
				
				);
				
				guiSetProperty ( editWind.wind, "AlwaysOnTop", "true" );
				guiWindowSetSizable( editWind.wind, false );			
				
			end		
		end
	
	);

end