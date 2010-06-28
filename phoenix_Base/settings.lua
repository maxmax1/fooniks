-- Some values and etc.

local settingsWind = { };
local settingElements = { };

-- Needed Stuff

local player = getLocalPlayer( );
local rootElement = getRootElement( );
local sx, sy = guiGetScreenSize( );

--

function testFunc()

	return true;

end

function LoadSettingElements( )

	settingElements = { };
	
		-- MOTD
		settingElements[1] = { };
		settingElements[1]["label"] = "Kuva MOTD";
		settingElements[1]["type"] = "checkbox";
		settingElements[1]["getFunc"] = testFunc;
		
		-- Blurlevel
		settingElements[2] = { };
		settingElements[2]["label"] = "Blur Tase";
		settingElements[2]["type"] = "combobox";
		settingElements[2]["values"] = {"Palju", "Normaalne", "V2he", "Pole"};
		settingElements[2]["getFunc"] = getMyBlur;
		settingElements[2]["setFunc"] = setMyBlur;
		
		

end

function CreateSettingsWindow( )

	LoadSettingElements( );

	-- Main window.

	settingsWind.wind = guiCreateWindow( sx-306, 50, 256, 410, "Seaded", false );
	settingsWind.scroll = guiCreateScrollPane( 0.05, 0.1, 0.9, 0.7, true, settingsWind.wind );
	
	settingsWind.closeBtn = guiCreateButton( 0.7, 0.9, 0.25, 0.075, "Katkesta", true, settingsWind.wind );		
	addEventHandler("onClientGUIClick", settingsWind.closeBtn, 
		function ( button, state )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			if( source ~= settingsWind.closeBtn ) then return false; end
			guiSetVisible( settingsWind.wind, false );
		
		end
	, false);	
	
	settingsWind.okBtn = guiCreateButton( 0.4, 0.9, 0.25, 0.075, "Salvesta", true, settingsWind.wind );		
	addEventHandler("onClientGUIClick", settingsWind.okBtn, 
		function ( button, state )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			if( source ~= settingsWind.okBtn ) then return false; end
			
			-- Save
			
			guiSetVisible( settingsWind.wind, false );
		
		end
	, false);
	
	-- Settings...
	
	settingsWind.settings = {};
	local y = 50;
	
	for k, v in ipairs( settingElements ) do
	
		local tbl = { };
		tbl.label = guiCreateLabel( 5, y, 95, 15, v["label"] .. ": ", false, settingsWind.scroll );
		
		if( v["type" ] == "edit" ) then
		
			tbl.edit = guiCreateEdit( 100, y, 100, 20, " ", false, settingsWind.scroll );
			
		elseif( v["type" ] == "checkbox" ) then
		
			tbl.check = guiCreateCheckBox( 100, y, 100, 20, "Jah", false, false, settingsWind.scroll );
		
		elseif( v["type" ] == "combobox" ) then
		
			tbl.combo = guiCreateComboBox( 100, y, 100, 20, "valik...", false, settingsWind.scroll );
			tbl.comboVal = { };
			for k2, v2 in ipairs( v["values"] ) do
			
				tbl.comboVal[k2] = guiComboBoxAddItem( tbl.combo, v2 );
			
			end
		
		end
		
		settingsWind.settings[k] = tbl;
		y = y + 25;
	
	end
	
	-- Done, hide wind.	
	guiSetVisible( settingsWind.wind, false );

end

addEventHandler( "onClientResourceStart", rootElement, CreateSettingsWindow );

function ShowSettingsWindow( )

	-- Set the values.
	
	for k, v in pairs( settingsWind.settings ) do
	
		-- ei callita:O?????
		if( v.edit ) then
		
			guiSetText( v.edit, settingElements[k]["getFunc"] );
		
		elseif( v.check ) then
		
			guiCheckBoxSetSelected( v.check, settingElements[k]["getFunc"] );
		
		elseif( v.combo ) then
		
			guiComboBoxSetSelected( v.combo, settingElements[k]["getFunc"] );
		
		end
	
	end
	
	-- 
	guiSetVisible( settingsWind.wind, true );

end

addEvent( "onSettingsDisplay", true );
addEventHandler( "onSettingsDisplay", player, ShowSettingsWindow );

-- privates

function getMyBlur()

	local level = getBlurLevel( );
	if( level == 0 ) then
	
		return 4;
	
	elseif( level <= 15 ) then
	
		return 3;
	
	elseif( level <= 36 ) then
	
		return 2;
	
	else
	
		return 1;
	
	end
end

function setMyBlur( value )

	local levels = { 150, 36, 15, 0 };
	local number = levels[value];
	if( not number ) then number = 0; end
	return setBlurLevel( number );

end