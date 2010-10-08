local clubTable = { };
local index = 0;
local CLUB_OBJECT =  334; -- night stick 334

function ThrowClub( thePlayer, thePoints, x, y, z )

	index = index + 1;

	setPedAnimation( thePlayer, "DILDO", "DILDO_1", 200, false, false, true, false );	
	
	clubTable[index] = { };
	clubTable[index].obj = createObject( CLUB_OBJECT, x, y, z );
	clubTable[index].points = thePoints;
	clubTable[index].count = 0;
	clubTable[index].timer = 100;
	clubTable[index].ped = thePlayer;
	
	takeWeapon( thePlayer, 3 );
		
	setTimer( doTick, 200, 1, index );

end

addEvent( "onClubThrow", true );
addEventHandler( "onClubThrow", getRootElement( ), ThrowClub );

addCommandHandler( "club", ThrowClub );

function doTick( idx )

	if( clubTable[idx] ) then
	
		if( clubTable[idx].count == 0 ) then
		
			local x, y, z = getElementPosition( clubTable[idx].ped );
			setElementPosition( clubTable[idx].ped, x, y, z );
			setPedAnimation( clubTable[idx].ped );
		
		end
	
		clubTable[idx].count = clubTable[idx].count + 1;
		
		if( clubTable[idx].points[clubTable[idx].count] ) then
				
			moveObject( clubTable[idx].obj, clubTable[idx].timer, clubTable[idx].points[clubTable[idx].count][4], clubTable[idx].points[clubTable[idx].count][5], clubTable[idx].points[clubTable[idx].count][6] );
			setTimer( clubTick, clubTable[idx].timer, 1, idx );
		
		else
		
			local x, y, z = getElementPosition( clubTable[idx].obj );
		
			clubTable[idx].pickup = createPickup( x, y, z + .5, 2, 3 );
			destroyElement( clubTable[idx].obj );
		
		end
	
	end

end

function clubTick( idx )

	if( clubTable[idx] ) then
	
		doTick( idx );
	
	end

end

local clubTable = { };
local index = 0;
local CLUB_OBJECT =  334; -- night stick 334

function ThrowClub( thePlayer, thePoints, x, y, z )

	index = index + 1;

	setPedAnimation( thePlayer, "DILDO", "DILDO_1", 200, false, false, true, false );	
	
	clubTable[index] = { };
	clubTable[index].obj = createObject( CLUB_OBJECT, x, y, z );
	clubTable[index].points = thePoints;
	clubTable[index].count = 0;
	clubTable[index].timer = 100;
	clubTable[index].ped = thePlayer;
	
	takeWeapon( thePlayer, 3 );
		
	setTimer( doTick, 200, 1, index );

end

addEvent( "onClubThrow", true );
addEventHandler( "onClubThrow", getRootElement( ), ThrowClub );

addCommandHandler( "club", ThrowClub );

function doTick( idx )

	if( clubTable[idx] ) then
	
		if( clubTable[idx].count == 0 ) then
		
			local x, y, z = getElementPosition( clubTable[idx].ped );
			setElementPosition( clubTable[idx].ped, x, y, z );
			setPedAnimation( clubTable[idx].ped );
		
		end
	
		clubTable[idx].count = clubTable[idx].count + 1;
		
		if( clubTable[idx].points[clubTable[idx].count] ) then
				
			moveObject( clubTable[idx].obj, clubTable[idx].timer, clubTable[idx].points[clubTable[idx].count][4], clubTable[idx].points[clubTable[idx].count][5], clubTable[idx].points[clubTable[idx].count][6] );
			setTimer( clubTick, clubTable[idx].timer, 1, idx );
		
		else
		
			local x, y, z = getElementPosition( clubTable[idx].obj );
		
			clubTable[idx].pickup = createPickup( x, y, z + .5, 2, 3 );
			destroyElement( clubTable[idx].obj );
		
		end
	
	end

end

function clubTick( idx )

	if( clubTable[idx] ) then
	
		doTick( idx );
	
	end

end

