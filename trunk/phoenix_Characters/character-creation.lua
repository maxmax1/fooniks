local currentStep = 1;

local createWind = nil;

-- STEP 1
local nameEdit = nil;
local nameHelper = nil;
local sexSelect = nil;
local img = nil;

local nextBtn = nil;
local myHandler = nil;
local backImg = nil;
local myName = "";

local selRace = 1;
local race = {"Europiid", "Afrikaan", "Asiaat", "Latiino"};

local selAge = 1;
local age = {18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 58, 62, 66, 70, 74, 78, 82};

local skinList = {};
local curSkin = 0;
local fake = false;

-- Stuff
local player = getLocalPlayer();
local txtColor = tocolor( 0, 100, 255 );

local skinImg = {};

-- Data for new Char...
local newDat = {};

function AddSkin(group, skin, rac)

	if( not skinList[group] ) then skinList[group] = {}; end
	if( not skinList[group][rac] ) then skinList[group][rac] = {}; end
	table.insert( skinList[group][rac], skin );

end

skinList[1] = {}; -- Men
AddSkin(1, 7, 2);

AddSkin(1, 14, 2);
AddSkin(1, 15, 2);
AddSkin(1, 16, 2);
AddSkin(1, 17, 2);
AddSkin(1, 18, 2);
AddSkin(1, 19, 2);
AddSkin(1, 20, 2);
AddSkin(1, 21, 2);
AddSkin(1, 22, 2);
AddSkin(1, 23, 1);
AddSkin(1, 24, 2);
AddSkin(1, 25, 2);
AddSkin(1, 26, 1);
AddSkin(1, 27, 1);
AddSkin(1, 28, 2);
AddSkin(1, 29, 1);
AddSkin(1, 30, 1);
AddSkin(1, 32, 1);
AddSkin(1, 33, 1);
AddSkin(1, 34, 1);
AddSkin(1, 35, 2);
AddSkin(1, 36, 2);
AddSkin(1, 37, 1);
AddSkin(1, 43, 1);
AddSkin(1, 44, 1);
AddSkin(1, 45, 1);
AddSkin(1, 46, 1);
AddSkin(1, 47, 1);
AddSkin(1, 48, 2);
AddSkin(1, 49, 1);
AddSkin(1, 50, 2);
AddSkin(1, 51, 2);
AddSkin(1, 52, 1);
AddSkin(1, 57, 1);
AddSkin(1, 58, 1);
AddSkin(1, 59, 1);
AddSkin(1, 60, 1);
AddSkin(1, 61, 1);
AddSkin(1, 62, 1);
AddSkin(1, 66, 2);
AddSkin(1, 67, 2);
AddSkin(1, 68, 1);
AddSkin(1, 70, 1);
AddSkin(1, 71, 1);
AddSkin(1, 72, 1);
AddSkin(1, 73, 1);
AddSkin(1, 78, 1);
AddSkin(1, 79, 1);
AddSkin(1, 80, 2);
AddSkin(1, 81, 1);
AddSkin(1, 82, 2);
AddSkin(1, 83, 2);
AddSkin(1, 84, 2);
AddSkin(1, 94, 1);
AddSkin(1, 95, 1);
AddSkin(1, 96, 1);
AddSkin(1, 97, 1);
AddSkin(1, 98, 2);
AddSkin(1, 99, 1);
AddSkin(1, 100, 1);
AddSkin(1, 101, 1);
AddSkin(1, 102, 2);
AddSkin(1, 103, 2);
AddSkin(1, 104, 2);
AddSkin(1, 105, 2);
AddSkin(1, 106, 2);
AddSkin(1, 107, 2);
AddSkin(1, 108, 4);
AddSkin(1, 109, 4);
AddSkin(1, 110, 4);
AddSkin(1, 111, 1);
AddSkin(1, 112, 1);
AddSkin(1, 113, 1);
AddSkin(1, 114, 4);
AddSkin(1, 115, 4);
AddSkin(1, 116, 4);
AddSkin(1, 117, 1);
AddSkin(1, 118, 1);
AddSkin(1, 120, 1);
AddSkin(1, 121, 1);
AddSkin(1, 122, 1);
AddSkin(1, 123, 4);
AddSkin(1, 124, 4);
AddSkin(1, 125, 1);
AddSkin(1, 126, 1);
AddSkin(1, 127, 1);
AddSkin(1, 128, 2);
AddSkin(1, 132, 1);
AddSkin(1, 133, 1);
AddSkin(1, 134, 2);
AddSkin(1, 135, 1);
AddSkin(1, 136, 2);
AddSkin(1, 137, 2);
AddSkin(1, 142, 2);
AddSkin(1, 143, 2);
AddSkin(1, 144, 2);
AddSkin(1, 146, 1);
AddSkin(1, 147, 1);
AddSkin(1, 153, 1);
AddSkin(1, 154, 1);
AddSkin(1, 156, 2);
AddSkin(1, 158, 1);
AddSkin(1, 159, 1);
AddSkin(1, 160, 1);
AddSkin(1, 161, 1);
AddSkin(1, 162, 1);
AddSkin(1, 163, 2);
AddSkin(1, 164, 1);
AddSkin(1, 165, 1);
AddSkin(1, 166, 1);
AddSkin(1, 167, 1);
AddSkin(1, 168, 2);
AddSkin(1, 170, 1);
AddSkin(1, 170, 1);
AddSkin(1, 173, 4);
AddSkin(1, 174, 4);
AddSkin(1, 175, 4);
AddSkin(1, 176, 2);
AddSkin(1, 177, 1);
AddSkin(1, 179, 4);
AddSkin(1, 180, 2);
AddSkin(1, 181, 1);
AddSkin(1, 182, 2);
AddSkin(1, 183, 2);
AddSkin(1, 184, 2);
AddSkin(1, 185, 4);
AddSkin(1, 186, 3);
AddSkin(1, 187, 1);
AddSkin(1, 188, 1);
AddSkin(1, 189, 1);
AddSkin(1, 200, 1);
AddSkin(1, 202, 1);
AddSkin(1, 203, 1);
AddSkin(1, 204, 1);
AddSkin(1, 206, 1);
AddSkin(1, 209, 1);
AddSkin(1, 210, 1);
AddSkin(1, 212, 1);
AddSkin(1, 213, 1);
AddSkin(1, 217, 1);
AddSkin(1, 220, 2);
AddSkin(1, 221, 2);
AddSkin(1, 222, 2);
AddSkin(1, 223, 4);
AddSkin(1, 227, 1);
AddSkin(1, 228, 1);
AddSkin(1, 229, 1);
AddSkin(1, 230, 2);
AddSkin(1, 234, 1);
AddSkin(1, 235, 1);
AddSkin(1, 236, 1);
AddSkin(1, 239, 1);
AddSkin(1, 240, 1);
AddSkin(1, 241, 1);
AddSkin(1, 242, 1);
AddSkin(1, 247, 1);
AddSkin(1, 248, 1);
AddSkin(1, 249, 2);
AddSkin(1, 250, 1);
AddSkin(1, 252, 1);
AddSkin(1, 253, 2);
AddSkin(1, 254, 1);
AddSkin(1, 255, 1);
AddSkin(1, 258, 1);
AddSkin(1, 259, 1);
AddSkin(1, 260, 2);
AddSkin(1, 261, 2);
AddSkin(1, 262, 2);
AddSkin(1, 264, 1);
AddSkin(1, 274, 2);
AddSkin(1, 275, 2);
AddSkin(1, 276, 1);
AddSkin(1, 277, 1);
AddSkin(1, 278, 2);
AddSkin(1, 279, 1);
AddSkin(1, 280, 1);
AddSkin(1, 281, 1);
AddSkin(1, 282, 1);
AddSkin(1, 283, 1);
AddSkin(1, 284, 2);
AddSkin(1, 285, 1);
AddSkin(1, 286, 1);
AddSkin(1, 287, 1);
AddSkin(1, 288, 1);

skinList[2] = {}; -- Women

AddSkin(2, 9, 2);
AddSkin(2, 10, 2);
AddSkin(2, 11, 2);
AddSkin(2, 12, 1);
AddSkin(2, 13, 2);
AddSkin(2, 31, 1);
AddSkin(2, 39, 1);
AddSkin(2, 40, 2);
AddSkin(2, 41, 2);
AddSkin(2, 55, 4);
AddSkin(2, 56, 1);
AddSkin(2, 63, 2);
AddSkin(2, 64, 2);
AddSkin(2, 69, 2);
AddSkin(2, 75, 1);
AddSkin(2, 76, 2);
AddSkin(2, 77, 1);
AddSkin(2, 85, 1);
AddSkin(2, 87, 1);
AddSkin(2, 88, 1);
AddSkin(2, 89, 1);
AddSkin(2, 90, 1);
AddSkin(2, 92, 1);
AddSkin(2, 93, 2);
AddSkin(2, 129, 1);
AddSkin(2, 130, 1);
AddSkin(2, 131, 2);
AddSkin(2, 138, 1);
AddSkin(2, 139, 2);
AddSkin(2, 140, 1);
AddSkin(2, 145, 4);
AddSkin(2, 148, 2);
AddSkin(2, 150, 2);
AddSkin(2, 151, 1);
AddSkin(2, 152, 1);
AddSkin(2, 157, 1);
AddSkin(2, 178, 1);
AddSkin(2, 190, 4);
AddSkin(2, 191, 1);
AddSkin(2, 192, 1);
AddSkin(2, 193, 1);
AddSkin(2, 194, 1);
AddSkin(2, 195, 2);
AddSkin(2, 196, 1);
AddSkin(2, 197, 1);
AddSkin(2, 198, 1);
AddSkin(2, 199, 1);
AddSkin(2, 201, 1);
AddSkin(2, 205, 1);
AddSkin(2, 207, 4);
AddSkin(2, 211, 2);
AddSkin(2, 214, 2);
AddSkin(2, 215, 2);
AddSkin(2, 216, 2);
AddSkin(2, 218, 2);
AddSkin(2, 219, 2);
AddSkin(2, 224, 3);
AddSkin(2, 225, 3);
AddSkin(2, 226, 1);
AddSkin(2, 231, 1);
AddSkin(2, 232, 1);
AddSkin(2, 233, 2);
AddSkin(2, 237, 1);
AddSkin(2, 238, 1);
AddSkin(2, 243, 4);
AddSkin(2, 244, 2);
AddSkin(2, 245, 2);
AddSkin(2, 246, 1);
AddSkin(2, 251, 1);
AddSkin(2, 256, 2);
AddSkin(2, 257, 1);
AddSkin(2, 263, 3);

function string:split(delimiter)
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( self, delimiter, from  )
  while delim_from do
    table.insert( result, string.sub( self, from , delim_from-1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( self, delimiter, from  )
  end
  table.insert( result, string.sub( self, from  ) )
  return result
end

function CheckName( str )

	if( not string.find( str, "_" ) ) then return false, "Puudub '_'"; end
	
	local tbl = str:split("_");
	if(#tbl < 2) then
		return false, "Puudub perenimi.";
	elseif(#tbl > 2) then
		return false, "Sisesta ainult 1 _.";
	end
	
	if(#tbl[1] < 2) then return false, "Eesnimi liiga lyhike."; end
	if(#tbl[2] < 2) then return false, "Perenimi liiga lyhike."; end
	
	local word = string.match( tbl[1], "%a+" );
	if( #word ~= #tbl[1] ) then return false, "Ainult t2hed!";	end
	
	word = string.match( tbl[2], "%a+" );
	if( #word ~= #tbl[2] ) then return false, "Ainult t2hed!";	end
	
	local newFName = string.upper(string.sub(tbl[1], 1, 1)) .. string.lower(string.sub(tbl[1], 2));
	local newLName = string.upper(string.sub(tbl[2], 1, 1)) .. string.lower(string.sub(tbl[2], 2));
	
	return true, "Korras", newFName .. "_" .. newLName;

end

function RandomSkin()

	if( not sexSelect or not selRace ) then
	
		return 0;
	
	end
		
	local seed = math.random( 1, #skinList[sexSelect][selRace] );
	return skinList[sexSelect][selRace][seed];

end

function onChange()

	local skin = RandomSkin();
	local times = 0;
	while(skin == curSkin and times < 15) do
	
		skin = RandomSkin();
		times = times + 1;
	
	end
	
	if(skin ~= 0) then
	
		local ret, res = CheckName( guiGetText(nameEdit) );
		if( ret ) then
		
			guiSetEnabled( nextBtn, true );
		
		end
	
	end
	
	setElementModel( player, skin );
	curSkin = skin;

end

function MakeCool()

	myName = guiGetText( nameEdit );
	local ret, res, new = CheckName( myName );
	guiSetText( nameHelper, res );
	
	if( new ) then
	
		fake = true;
		myName = new;
		guiSetText( nameEdit, new );
	
	end
	
	if( ret ) then
	
		if( sexSelect ) then
		
			guiSetEnabled( nextBtn, true );
		
		end
	
		guiStaticImageLoadImage( img , "files/images/gui-green.png" );
	
	else
	
		guiSetEnabled( nextBtn, false );	
		guiStaticImageLoadImage( img , "files/images/gui-red.png" );
	
	end

end

function drawName()

	local rX, rY, rZ = getElementPosition( player );
	local pX, pY = getScreenFromWorldPosition( rX, rY, rZ );
	pY = pY - 100;
	dxDrawText( myName, pX-100, pY-100, pX+100, pY+100, txtColor, 1, "default", "center", "center"  );

end

function createWindow( )

	setElementAlpha( player, 255 );

	showPlayerHudComponent( "radar", false );
	exports.phoenix_Estonia:showFakeMoney( false );
	showCursor( true );
	guiSetInputEnabled( true );

	createWind = guiCreateWindow( sx-306, 50, 256, 410, "Loo Karakter - Samm " .. currentStep, false );
	
	if(currentStep == 1) then

		onChange();
		myHandler = addEventHandler( "onClientRender", getRootElement(), drawName );
	
		guiCreateLabel(0.1, 0.125, 0.5, 0.1, "Nimi: ", true, createWind );
		nameEdit = guiCreateEdit(0.1, 0.175, 0.8, 0.1, "", true, createWind );
		nameHelper = guiCreateLabel(0.0, 0.3, 0.5, 0.1, "Sisestage nimi.", true, createWind );
		guiSetProperty( nameHelper, "HorizontalAlignment", "Right" );
		
		addEventHandler("onClientGUIChanged", nameEdit, 
			function ( )
			
				if( fake ) then fake = false; return; end
				guiSetText( nameHelper, "kontrollin..." );
				setTimer(MakeCool, 100, 1);
			
			end
		, false);
		
		
		img = guiCreateStaticImage(0.1, 0.175, 0.8, 0.1, "files/images/gui-red.png", true, createWind );
		guiSetAlpha( img, 0.2 );
		guiSetProperty(  img, "MousePassThroughEnabled", "true");
		guiSetProperty(  img, "ZOrderChangeEnabled", "false");
		guiSetProperty(  nameEdit, "ZOrderChangeEnabled", "false");
		
		guiCreateLabel(0.1, 0.325, 0.5, 0.1, "Sugu: ", true, createWind );		
		local sexSelectM = guiCreateRadioButton(0.15, 0.35, 0.2, 0.1, "M", true, createWind );	
		local sexSelectN = guiCreateRadioButton(0.35, 0.35, 0.2, 0.1, "N", true, createWind );
		
		addEventHandler("onClientGUIClick", sexSelectM, 
			function ( )
			
				sexSelect = 1;
				onChange();
			
			end
		, false);
		
		addEventHandler("onClientGUIClick", sexSelectN, 
			function ( )
			
				sexSelect = 2;
				onChange();
			
			end
		, false);		
		
		guiCreateLabel(0.1, 0.425, 0.5, 0.1, "Rass: ", true, createWind );
		raceE = guiCreateEdit(0.2, 0.475, 0.6, 0.1, race[selRace], true, createWind );
		guiSetEnabled( raceE, false);
		
		local pRace = guiCreateButton( 0.1, 0.475, 0.075, 0.1, "<<", true, createWind );
		guiSetEnabled( pRace, false);	
		
		local nRace = guiCreateButton( 0.825, 0.475, 0.075, 0.1, ">>", true, createWind );
		
		addEventHandler("onClientGUIClick", pRace, 
			function ( )
				
				selRace = selRace - 1;				
				guiSetEnabled( nRace, true);
				
				if(selRace == 1) then
				
					guiSetEnabled( pRace, false);
				
				end
				
				guiSetText( raceE, race[selRace] );
				onChange();
				
			end
		, false);
		
		addEventHandler("onClientGUIClick", nRace, 
			function ( )
			
				selRace = selRace + 1;
				guiSetEnabled( pRace, true);	
				
				if(selRace == #race) then
				
					guiSetEnabled( nRace, false);
				
				end
				
				guiSetText( raceE, race[selRace] );
				onChange();
			
			end
		, false);		
		
		guiCreateLabel(0.1, 0.6, 0.5, 0.1, "Vanus: ", true, createWind );
		ageE = guiCreateEdit(0.2, 0.65, 0.6, 0.1, tostring(age[selAge]), true, createWind );
		guiSetEnabled( ageE, false);
		
		local pAge = guiCreateButton( 0.1, 0.65, 0.075, 0.1, "<<", true, createWind );
		guiSetEnabled( pAge, false);	
		
		local nAge = guiCreateButton( 0.825, 0.65, 0.075, 0.1, ">>", true, createWind );
		
		addEventHandler("onClientGUIClick", pAge, 
			function ( )
				
				selAge = selAge - 1;				
				guiSetEnabled( nAge, true);
				
				if(selAge == 1) then
				
					guiSetEnabled( pAge, false);
				
				end
				
				guiSetText( ageE, tostring(age[selAge]) );
				
			end
		, false);
		
		addEventHandler("onClientGUIClick", nAge, 
			function ( )
			
				selAge = selAge + 1;
				guiSetEnabled( pAge, true);	
				
				if(selAge == #age) then
				
					guiSetEnabled( nAge, false);
				
				end
				
				guiSetText( ageE, tostring(age[selAge]) );
			
			end
		, false);	
	
		nextBtn = guiCreateButton( 0.1, 0.85, 0.8, 0.1, "Edasi", true, createWind );
		guiSetEnabled( nextBtn, false );
		
		addEventHandler("onClientGUIClick", nextBtn, 
			function ( )
			
				newDat["name"] = myName;
				newDat["skin"] = getElementModel( player );
				newDat["age"] = age[selAge];
				newDat["race"] = selRace;
				newDat["sex"] = sexSelect;
			
				currentStep = currentStep + 1;
				destroyElement( createWind );
				
				createWindow( );
			
			end
		, false);		
		
	elseif(currentStep == 2) then
	
		-- TODO!
		
		-- ScrollPane, 3 pildiga reas...
		
		local back = guiCreateStaticImage( 0.05, 0.1, 0.9, 0.7, "files/images/gui-black.png", true, createWind );
		guiSetAlpha( back, 0.5 );
		local scroll = guiCreateScrollPane( 0.05, 0.1, 0.9, 0.7, true, createWind );
		guiScrollPaneSetScrollBars( scroll, false, true );
		
		-- Conf
		local padding = 5;	
		local width = (210*0.9)/3;	
		local height = width;
		
		-- Other
		local y = 10;	
		local inRow = 0;
		
		for k, v in ipairs( skinList[sexSelect][selRace] ) do
		
			if( v < 10 ) then
			
				v = "00" .. v; 
			
			elseif( v < 100 ) then
			
				v = "0" .. v;
				
			end
			
			local file = "/files/skins/" .. v .. ".png";
			
			local x = ((inRow+1)*padding) + inRow*width;
			
			if( v == newDat["skin"] ) then
			
				backImg = guiCreateStaticImage( x, y, width, height, "/files/images/gui-green.png", false, scroll );
				guiSetAlpha( backImg, 0.5 );
			
			end
			
			skinImg[k] = guiCreateStaticImage( x, y, width, height, file, false, scroll );
			addEventHandler("onClientGUIClick", skinImg[k], 
				function (  )
							
					if( source ) then
						
						local mX = guiGetProperty( source, "UnifiedXPosition" );
						local mY = guiGetProperty( source, "UnifiedYPosition" );
						guiSetProperty(backImg, "UnifiedXPosition", mX);
						guiSetProperty(backImg, "UnifiedYPosition", mY);
						
						setElementModel( player, v );
						newDat["skin"] = v;
						
					end
				
				end
			, false);	
			
			inRow = inRow + 1;			
			
			if( inRow == 3 ) then
			
				y = y + height+padding;
				inRow = 0;
				
			end
		
		end
		
		nextBtn = guiCreateButton( 0.1, 0.85, 0.8, 0.1, "Edasi", true, createWind );
		guiSetEnabled( nextBtn, true );
		
		addEventHandler("onClientGUIClick", nextBtn, 
			function ( )
			
				currentStep = currentStep + 1;
				destroyElement( createWind );
				
				createWindow( );
			
			end
		, false);	

	elseif( currentStep == 3 ) then
	
		guiCreateLabel( 0.05, 0.1, 0.8, 0.1, "Taustalugu: ", true, createWind );
		memo = guiCreateMemo( 0.05, 0.15, 0.9, 0.65, "", true, createWind );
		nextBtn = guiCreateButton( 0.1, 0.85, 0.8, 0.1, "Loo Karakter", true, createWind );
		guiSetEnabled( nextBtn, true );
		
		addEventHandler("onClientGUIClick", nextBtn, 
			function ( )
			
				newDat["story"] = guiGetText( memo );
				currentStep = currentStep + 1;
				destroyElement( createWind );
				
				removeEventHandler( "onClientRender", getRootElement(), drawName );
				
				triggerServerEvent( "onNewCharacterDone", player, newDat );
				
				currentStep = 0;
			
			end
		, false);		
		
	end
	
	--[[
		STEP 1:
		
			1) Nime Valik.
			2) Soo Valik.
			3) Rassi Valik.
			4) Vanuseklassi Valik
			-- HILJEM: 5) Keele Valik(vt. Ettepanek Keeled).
		
		STEP 2:
		
			6) Välimuse Valik.
			
		STEP 3:
		
			7) Taustaloo kirjutamine(valikuline pikkus).
			
		FINISH IT!
		
			8) Edasi järgneb õpetus.
	
	]]--

end
addEvent( "onStartCharacterCreation", true );
addEventHandler( "onStartCharacterCreation", getRootElement( ), createWindow );