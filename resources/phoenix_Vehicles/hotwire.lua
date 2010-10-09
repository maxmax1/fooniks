local thePlayer = nil;
local theVehicle = nil;

local rootElement = getRootElement( );
local guiLoadBar = nil;
local theTimer = nil;

function InitHotwire( )

	thePlayer = getLocalPlayer( );
	
	guiLoadBar = guiCreateProgressBar( 0.45, .7, .1, .1, true );
	guiProgressBarSetProgress( guiLoadBar, 0.0 );
	
	guiSetVisible( guiLoadBar, false );

end

addEventHandler( "onClientResourceStart", getResourceRootElement( getThisResource( ) ), InitHotwire );

function hideLoadBar( )

	if( theTimer and isTimer( theTimer ) ) then
	
		killTimer( theTimer );
	
	end
	
	guiSetVisible( guiLoadBar, false );

end

function hotWireFunc( )

	if( not isPedInVehicle( thePlayer ) or getPedOccupiedVehicle( thePlayer ) ~= theVehicle ) then
	
		hideLoadBar( );
		return false;
	
	end
	
	local progress = guiProgressBarGetProgress( guiLoadBar ) + 5;
		
	guiProgressBarSetProgress( guiLoadBar, progress );
	if( progress >= 100 ) then
	
		hideLoadBar( );
		triggerServerEvent( "onWireStarted", thePlayer );
	
	end

end

function showLoadBar( theVeh )

	theVehicle = theVeh;
	hideLoadBar( );

	guiSetVisible( guiLoadBar, true );
	guiProgressBarSetProgress( guiLoadBar, 0.0 );
	
	theTimer = setTimer( hotWireFunc, 300, 0 );

end
addEvent( "onCarWireStart", true );
addEventHandler( "onCarWireStart", rootElement, showLoadBar );

addEventHandler( "onClientElementDataChange", getVehicle, function ( var ) outputDebugString( tostring( var ) ) end );
local thePlayer = nil;
local theVehicle = nil;

local rootElement = getRootElement( );
local guiLoadBar = nil;
local theTimer = nil;

function InitHotwire( )

	thePlayer = getLocalPlayer( );
	
	guiLoadBar = guiCreateProgressBar( 0.45, .7, .1, .1, true );
	guiProgressBarSetProgress( guiLoadBar, 0.0 );
	
	guiSetVisible( guiLoadBar, false );

end

addEventHandler( "onClientResourceStart", getResourceRootElement( getThisResource( ) ), InitHotwire );

function hideLoadBar( )

	if( theTimer and isTimer( theTimer ) ) then
	
		killTimer( theTimer );
	
	end
	
	guiSetVisible( guiLoadBar, false );

end

function hotWireFunc( )

	if( not isPedInVehicle( thePlayer ) or getPedOccupiedVehicle( thePlayer ) ~= theVehicle ) then
	
		hideLoadBar( );
		return false;
	
	end
	
	local progress = guiProgressBarGetProgress( guiLoadBar ) + 5;
		
	guiProgressBarSetProgress( guiLoadBar, progress );
	if( progress >= 100 ) then
	
		hideLoadBar( );
		triggerServerEvent( "onWireStarted", thePlayer );
	
	end

end

function showLoadBar( theVeh )

	theVehicle = theVeh;
	hideLoadBar( );

	guiSetVisible( guiLoadBar, true );
	guiProgressBarSetProgress( guiLoadBar, 0.0 );
	
	theTimer = setTimer( hotWireFunc, 300, 0 );

end
addEvent( "onCarWireStart", true );
addEventHandler( "onCarWireStart", rootElement, showLoadBar );

addEventHandler( "onClientElementDataChange", getVehicle, function ( var ) outputDebugString( tostring( var ) ) end );
local thePlayer = nil;
local theVehicle = nil;

local rootElement = getRootElement( );
local guiLoadBar = nil;
local theTimer = nil;

function InitHotwire( )

	thePlayer = getLocalPlayer( );
	
	guiLoadBar = guiCreateProgressBar( 0.45, .7, .1, .1, true );
	guiProgressBarSetProgress( guiLoadBar, 0.0 );
	
	guiSetVisible( guiLoadBar, false );

end

addEventHandler( "onClientResourceStart", getResourceRootElement( getThisResource( ) ), InitHotwire );

function hideLoadBar( )

	if( theTimer and isTimer( theTimer ) ) then
	
		killTimer( theTimer );
	
	end
	
	guiSetVisible( guiLoadBar, false );

end

function hotWireFunc( )

	if( not isPedInVehicle( thePlayer ) or getPedOccupiedVehicle( thePlayer ) ~= theVehicle ) then
	
		hideLoadBar( );
		return false;
	
	end
	
	local progress = guiProgressBarGetProgress( guiLoadBar ) + 5;
		
	guiProgressBarSetProgress( guiLoadBar, progress );
	if( progress >= 100 ) then
	
		hideLoadBar( );
		triggerServerEvent( "onWireStarted", thePlayer );
	
	end

end

function showLoadBar( theVeh )

	theVehicle = theVeh;
	hideLoadBar( );

	guiSetVisible( guiLoadBar, true );
	guiProgressBarSetProgress( guiLoadBar, 0.0 );
	
	theTimer = setTimer( hotWireFunc, 300, 0 );

end
addEvent( "onCarWireStart", true );
addEventHandler( "onCarWireStart", rootElement, showLoadBar );

addEventHandler( "onClientElementDataChange", getVehicle, function ( var ) outputDebugString( tostring( var ) ) end );