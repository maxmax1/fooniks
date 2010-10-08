local box = nil;
local orange = nil;

addCommandHandler( "comboBox", 

	function ()
	
		box = guiCreateComboBox( 50, 50, 200, 150, "Pick your favorite GTA: MP", false );
		outputChatBox( tostring( box ) .. " == " .. type( box ) );
	
	end
	
);

addCommandHandler( "comboBox2", 

	function ()
	
		guiComboBoxAddItem( box, "MTA: Blue" );
		orange = guiComboBoxAddItem( box, "MTA: Orange" );
		outputChatBox( tostring( orange ) .. " == " .. type( orange ) );
		
		addEventHandler("onClientGUIClick", box,
			function ( element ) 
				outputChatBox("The box now reads: " .. guiComboBoxGetSelected( element ) );
			end
		);
	
	end
	
);

addCommandHandler( "comboBox3", 

	function ()
	
		local ret = guiComboBoxGetSelected( box );
		outputChatBox( tostring( ret ) .. " == " .. type( ret ) );
		outputChatBox( tostring( guiComboBoxGetItemText( box, ret ) ) );
	
	end
	
);

addCommandHandler( "comboBox4", 

	function ()
	
		local ret = guiComboBoxClear( box );
	
	end
	
);

addCommandHandler( "comboBox5", 

	function ()
	
		local ret = guiComboBoxSetSelected( box, orange );
		outputChatBox( tostring( ret ) .. " == " .. type( ret ) );
	
	end
	
);

addCommandHandler( "comboBox6", 

	function ()
	
		local ret = guiComboBoxGetSelected( box );
		outputChatBox( tostring( ret ) .. " == " .. type( ret ) );
		guiComboBoxSetItemText( box, ret, "eRP" );
	
	end
	
);


addCommandHandler( "comboBox7", 

	function ()
	
		guiComboBoxRemoveItem( box, orange );
	
	end
	
);

