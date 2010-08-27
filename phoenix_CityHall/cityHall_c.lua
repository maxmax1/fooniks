local theMarker = createMarker( 362.537, 173.639, 1007.083, "cylinder", 1.5, 255, 0, 0 );
setElementInterior( theMarker, 3 );

local theGui = MyTabPanel:new( "Linnavalitsus" );
theGui:Create( );

theGui:AddTab( "Info" );  -- id 1
theGui:AddTab( "Firmad" );  -- id 2
theGui:AddTab( "Juriidiline" );  -- id 3

guiCreateMemo( 0.025, 0.05, 0.95, 0.9, "Tere tulemast linnahalli!\n\tSiin saad teha erinevaid linnaga seotud asju. Näiteks luua oma firma või palgata omale parem advokaat. \n\n\tVali soovitud tegevus!", true, theGui.theTabs[1] );

guiCreateStaticImage( 0.05, 0.15, 0.5, 0.9, "court.png", true, theGui.theTabs[3] );

local labelStr = guiCreateLabel( 0.6, 0.1, 0.4, 0.1, "  ", true, theGui.theTabs[3] );
local priceStr = guiCreateLabel( 0.6, 0.2, 0.4, 0.1, "  ", true, theGui.theTabs[3] );

local buyLevel = guiCreateButton( 0.6, 0.4, 0.35, 0.1, "OSTA TASE", true, theGui.theTabs[3] );
local readRecord = guiCreateButton( 0.6, 0.55, 0.35, 0.1, "LOE TOIMIKUT", true, theGui.theTabs[3] );
local clearRecord = guiCreateButton( 0.6, 0.7, 0.35, 0.1, "PUHASTA TOIMIK", true, theGui.theTabs[3] );

guiSetEnabled( buyLevel, false );
guiSetEnabled( readRecord, false );
guiSetEnabled( clearRecord, false );

local thePlayer = getLocalPlayer( );
local theSendPrice = 0;

local npc = createPed( 172, 359.179, 173.485, 1008.4 );
setElementInterior( npc, 3 );
setPedRotation( npc, 270 );
setElementCollisionsEnabled( npc, false );
setPedAnimation( npc, "INT_OFFICE","OFF_Sit_Type_Loop" ); -- OFF_Sit_Watch

setTimer( 

	function ()
	
		local animTable = { "OFF_Sit_Crash", "OFF_Sit_Drink", "OFF_Sit_Watch" };
		setPedAnimation( npc, "INT_OFFICE", animTable[math.random( 1, #animTable)] ); 
		
		setTimer( setPedAnimation, 3000, 1, npc, "INT_OFFICE","OFF_Sit_Type_Loop" );
	
	end
	
, 15000, 0 );

theGui.hideFunc = function ( ) setPedAnimation( npc, "INT_OFFICE", "OFF_Sit_Type_Loop" ) end;

addEventHandler("onClientGUIClick", buyLevel, 
	function ( button, state )
	
		local mySelf = self;		
		if( button ~= "left" or state ~= "up" ) then return false; end
		if( source ~= buyLevel ) then return false; end
		triggerServerEvent( "onLegalLevelUpgrade", thePlayer, theSendPrice );
	
	end
, false);

function onShow( )

	setPedAnimation( npc, "INT_OFFICE", "OFF_Sit_Bored_Loop" ); 
	
	-- update labelStr
	local sLevel = tonumber( getElementData( thePlayer, "Skill.LEGAL" ) );
	if( not sLevel ) then sLevel = 0; end
	
	local txt = "Tase:   " .. tostring( sLevel );
	guiSetText( labelStr, txt );
	
	local thePrice = math.ceil( exports.phoenix_Skills:GetSkillLevelData( "LEGAL", sLevel ) );
	theSendPrice = thePrice;
	guiSetText( priceStr, "Hind:   " .. tostring( thePrice ) );

	theGui:Show( );
	
	if( getPlayerMoney( thePlayer ) < thePrice or sLevel > 98 ) then
	
		guiSetEnabled( buyLevel, false );
	
	else
	
		guiSetEnabled( buyLevel, true );
	
	end
	
	if( sLevel > 80 ) then
	
		guiSetEnabled( clearRecord, true );
		guiSetText( clearRecord, "PUHASTA TOIMIK" );
	
	else
	
		guiSetEnabled( clearRecord, false );
		guiSetText( clearRecord, "PUHASTA TOIMIK(Tase 80)" );
	
	end	
	
	if( sLevel > 10 ) then
	
		guiSetEnabled( readRecord, true );
		guiSetText( readRecord, "LOE TOIMIKUT" );
	
	else
	
		guiSetEnabled( readRecord, false );
		guiSetText( readRecord, "LOE TOIMIKUT(Tase 10)" );
	
	end

end

addEvent( "onCityHallUpdate", true );
addEventHandler( "onCityHallUpdate", getRootElement( ), onShow );

addEventHandler ( "onClientMarkerHit", theMarker, 

	function ( hitPlayer, matchingDim )
	
		if( hitPlayer == thePlayer and matchingDim ) then
		
			onShow( );
		
		end
	
	end

);

-- firmade teema(registreeri firma)
-- advokaadi leveli upgrademine()
-- esimesel tabil info