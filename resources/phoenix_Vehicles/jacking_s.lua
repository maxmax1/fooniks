LOCK_XP = 300;

function findRotation(x1,y1,x2,y2)
 
  local t = -math.deg(math.atan2(x2-x1,y2-y1))
  if t < 0 then t = t + 360 end;
  return t;
 
end

function setElementToFaceElement( theElem1, theElem2, x1, y1, z1, x2, y2, z2 )

	if( not x1 ) then
	
		x1, y1, z1 = getElementPosition( theElem1 );
	
	end
	if( not x2 ) then
	
		x2, y2, z2 = getElementPosition( theElem2 );
	
	end
	
	local angle = findRotation( x1, y1, x2, y2 );
	
	setElementRotation( theElem1, 0, 0, angle );

end

addEvent( "onLockPickStart", true );
addEventHandler( "onLockPickStart", getRootElement( ),

	function ( theVehicle )
	
		if( client and theVehicle ) then
		
			setElementToFaceElement( client, theVehicle );
			setPedAnimation( client, "ROB_BANK", "CAT_Safe_Rob" );
			
			local alarm = getElementData( theVehicle, "vAlarm" );
			if( alarm == 1 and not getElementData( theVehicle, "vAlarmed" ) ) then
			
				setTimer( trigger, 500, 1, theVehicle );
				setTimer( alarmuntrigger, 10000, 1, theVehicle );
			
			end
		
		end
	
	end

);

addEvent( "onLockPickComplete", true );
addEventHandler( "onLockPickComplete", getRootElement( ),

	function ( done, theVehicle )
	
		if( client and theVehicle ) then
		
			setPedAnimation( client );
		
			if( done ) then
			
				setVehicleLocked( theVehicle, false );
				
				local vehSecurityLevel = getLockLevel( theVehicle );
				exports.phoenix_Skills:xpAdd( client, "LOCKPICK", LOCK_XP * vehSecurityLevel ); 
				
				exports.phoenix_Chat:EmoteMessage( client, "muugib ukse lahti.", false );
			
			else
			
				exports.phoenix_Chat:OocInfo( client, "ebaonnestus" );
			
				local level = exports.phoenix_Skills:getPlayerLevel( client, "LOCKPICK" ) or 1;
				level = tonumber( level );
				local rand = math.random( 3, 100 - level );
				
				local itemSlot = exports.phoenix_Pockets:getSlotByItem( client, 17 );
				if( itemSlot ) then
				
					local itemdata = exports.phoenix_Pockets:getSlotData( client, itemSlot ) or 1000;
					itemdata = tonumber( itemdata ) - rand;
					if( itemdata < 1 ) then
					
						exports.phoenix_Pockets:clearPocket( client, itemSlot )
					
					else
					
						exports.phoenix_Pockets:setSlotData( client, itemSlot, itemdata );
					
					end
					
				
				end
			
			end
		
		end
	
	end

);
