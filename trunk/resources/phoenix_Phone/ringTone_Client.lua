local playerSound = { };

function RingToneStart( thePlayer, str, timed )

	if( playerSound[thePlayer] ) then
	
		RingToneStop( thePlayer );
	
	end

	local x, y, z = getElementPosition( thePlayer );
	playerSound[thePlayer] = playSound3D( str, x, y, z, true );
	
	if( timed ) then
	
		setTimer( RingToneStop, timed, 1, thePlayer ); 
	
	end

end

addEvent( "onRingtoneStart", true );
addEventHandler( "onRingtoneStart", getRootElement( ), RingToneStart );

function RingToneStop( thePlayer )

	stopSound( playerSound[thePlayer] );
	playerSound[thePlayer] = nil;

end

addEvent( "onRingtoneStop", true );
addEventHandler( "onRingtoneStop", getRootElement( ), RingToneStop );

addEventHandler( "onClientResourceStart", getRootElement(),  

	function ()
	

		addEventHandler("onClientRender", getRootElement(), 

			function ()	
			
					-- 
					local players = getElementsByType( "player" );
					
					for k,v in ipairs( players ) do 
												
						if( playerSound[v] ~= nil ) then
						
							local x, y, z = getElementPosition( v );				
							setElementPosition( playerSound[v], x, y, z );
						
						end
					
					end
			
			end
					
		);
	end
	
);