local comboBoxes = { };

local cOpen = false;

function _guiCreateComboBox( x, y, width, height, caption, relative, parent )

	local edit = guiCreateEdit( x, y, width, height, caption, relative, parent );
	comboBoxes[edit] = { };	
	
	comboBoxes[edit].btn = guiCreateStaticImage( x+width-height, y, height, height, "images/dropdown.png", relative, parent );
	
	local gH = 200;
	if( relative ) then gh = height * 6; end
	comboBoxes[edit].drop = guiCreateGridList( x, y, width, gH, relative, parent );
	
	guiEditSetReadOnly( edit, true );	
	guiBringToFront( edit );
	guiBringToFront( comboBoxes[edit].btn );
	guiSetProperty( edit, "ZOrderChangeEnabled", "false");
	--guiSetProperty( comboBoxes[edit].drop, "ZOrderChangeEnabled", "false");	
	guiGridListAddColumn( comboBoxes[edit].drop, "", 0.85 );
	guiSetVisible( comboBoxes[edit].drop, false );
	
	addEventHandler( "onClientGUIClick", comboBoxes[edit].btn,
	
		function ( button, state )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			if( source ~= comboBoxes[edit].btn ) then return false; end
			
			onClick( edit, source );
		
		end
	
	);	
	addEventHandler( "onClientGUIClick", comboBoxes[edit].drop,

		function ( button, state )

			if( button ~= "left" or state ~= "up" ) then return false; end
			if( source ~= comboBoxes[edit].drop ) then return false; end
			
			onClick( edit, source );

		end

	);	
	return edit;

end

function _guiComboBoxAddItem( comboBox, value )

	if( not comboBoxes[comboBox] ) then return false; end
	local row = guiGridListAddRow( comboBoxes[comboBox].drop );
	guiGridListSetItemText( comboBoxes[comboBox].drop, row, 1, value, false, false );
	return row;

end

function _guiComboBoxGetSelected( comboBox )

	if( not comboBoxes[comboBox] ) then return false; end
	return guiGridListGetSelectedItem( comboBoxes[comboBox].drop );

end

function _guiComboBoxSetSelected( comboBox, itemId )

	if( not comboBoxes[comboBox] ) then return false; end
	guiGridListSetSelectedItem( comboBoxes[comboBox].drop, itemId, 1 );
	local txt = guiGridListGetItemText( comboBoxes[comboBox].drop, itemId, 1 ); 
	guiSetText( comboBox, txt );
	onClick( comboBox );	
	return row;

end

function _guiComboBoxGetItemText( comboBox, itemId )

	if( not comboBoxes[comboBox] ) then return false; end
	return guiGridListGetItemText( comboBoxes[comboBox].drop, itemId, 1 );

end

function _guiComboBoxSetItemText( comboBox, itemId, value )

	if( not comboBoxes[comboBox] ) then return false; end
	guiGridListSetItemText( comboBoxes[comboBox].drop, itemId, 1, value, false, false );
	if( _guiComboBoxGetSelected( comboBox ) == itemId ) then guiSetText( comboBox, value ); end
	return true;

end

function _guiComboboxGetButton( comboBox )

	if( not comboBoxes[comboBox] ) then return false; end
	return comboBoxes[comboBox].btn;

end

if( not guiCreateComboBox ) then

	guiCreateComboBox = _guiCreateComboBox;
	guiComboBoxAddItem = _guiComboBoxAddItem;
	guiComboBoxSetSelected = _guiComboBoxSetSelected;
	guiComboBoxGetSelected = _guiComboBoxGetSelected;
	guiComboBoxGetItemText = _guiComboBoxGetItemText;
	guiComboBoxSetItemText = _guiComboBoxSetItemText;
	guiComboboxGetButton = _guiComboboxGetButton;

end

function onClick( theEdit, cElem )
	
	if( cOpen and cOpen ~= theEdit ) then
	
		guiSetVisible( comboBoxes[cOpen].drop, false );
		comboBoxes[cOpen].shown = false;
		cOpen = false;
	
	end
	
	if( cElem == comboBoxes[theEdit].btn and not comboBoxes[theEdit].shown ) then
	
		guiSetVisible( comboBoxes[theEdit].drop, true );
		guiBringToFront( comboBoxes[theEdit].drop );
		guiBringToFront( comboBoxes[theEdit].btn );

		comboBoxes[theEdit].shown = true;
		cOpen = theEdit;
	
	elseif( cElem == comboBoxes[theEdit].drop ) then
	
		local sel = _guiComboBoxGetSelected( theEdit );
		if( sel and sel > -1 ) then
		
			_guiComboBoxSetSelected( theEdit, sel );
		
		end
	
	elseif( comboBoxes[theEdit].shown ) then
	
		guiSetVisible( comboBoxes[theEdit].drop, false );
		comboBoxes[theEdit].shown = false;	
		cOpen = false;
	
	end

end

--[[
addEventHandler( "onClientClick", getRootElement( ),

	function ( button, state, aX, aY )
	
		if( button ~= "left" or state ~= "up" ) then return false; end
		
		if( cOpen ) then
		
			guiSetVisible( comboBoxes[cOpen].drop, false );
			comboBoxes[cOpen].shown = false;
			cOpen = false;
		
		end
	
	end

);]]--
