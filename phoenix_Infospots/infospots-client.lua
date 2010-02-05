--[[
local markers = { };

function checkFor3Dtext( )

	outputChatBox( "check" );
	local shape = createColSphere( x, y, z, 30.0 );
	local marks = getElementsWithinColShape( shape, "marker" );
	markers = { };
	
	for k, v in ipairs( marks ) do
	
		local txt = getElementData( v, "infoText" );
		
		if( txt ~= false ) then
		
			local tbl = { };
			tbl["text"] = txt;
			tbl["x"], tbl["y"], tbl["z"] = getElementPosition( v );		
			table.insert( markers, tbl );
		
		end
	
	end	

end

addEventHandler( "onClientResourceStart", rootElement,  

	function ()
	
		setTimer( checkFor3Dtext, 1000, 0 );
	
		addEventHandler("onClientRender", rootElement, 
		
			function ()	
			
				for k,v in ipairs( markers ) do
				
					local sx, sy = getScreenFromWorldPosition( v["x"], v["x"], v["z"] );
					
					if( sx ~= false and sy ~= false ) then
																
						dxDrawText ( v["text"], sx, sy, sx, sy, tocolor ( 0, 0, 0 ) );
					
					end
				
				end
			
			end
		
		);
	
	end

);]]--

function SetMyPos( x, y, z )

	local player = getLocalPlayer( );
	
	setElementPosition( player, x, y, z );	
	local newZ = getGroundPosition( x, y, z ) + math.abs( getElementDistanceFromCentreOfMassToBaseOfModel( player ) );
	setElementPosition( player, x, y, newZ );	

end

addEvent( "onInteriorPosRequest", true );
addEventHandler( "onInteriorPosRequest", getRootElement( ), SetMyPos );

function getIntByID( id )

	if( type( id ) == "number" ) then
	
		id = tostring( id);
	
	end
	
	if( type( id ) ~= "string" ) then
	
		return false, -1;
	
	end

	local ints = getElementsByType( "sInterior" );
	
	for k, v in ipairs( ints ) do
	
    	local myId = getElementData( v, "infoId" );
    	
    	if( id == tostring( myId ) ) then
    	
    		return true, v;
    	
    	end
    	
    end
    
    return false, -2;
    
end