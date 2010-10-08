local strings = { };
local next = 1;

function AddMotdString( str )

	table.insert( strings, str );

end

function ShowMotd( )

	if( strings[next] ) then
	
		--exports.helpmanager:showHelpPopup( false, strings[next] );
		triggerClientEvent( "onMotdShow", getRootElement( ), strings[next] );
	
	end

	if( next + 1 >= #strings ) then
	
		next = 1;
	
	else
	
		next = next + 1;
	
	end

end

local motdTime = tonumber( get( "MotdTime" ) );
if( not motdTime ) then

	motdTime = 30000;

end

setTimer( ShowMotd, motdTime, 0 );

local motdTime = tonumber( get( "MotdTime" ) );
if( not motdTime ) then

	motdTime = 30000;

end

setTimer( ShowMotd, motdTime, 0 );