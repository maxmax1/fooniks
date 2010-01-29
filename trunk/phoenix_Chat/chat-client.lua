local showing = false;
local alpha = 0;
local fadeIn = 0;
local text = "...";
local ticks = false;

-- Some values needed everywhere...
local rootElement = getRootElement( );
local sx, sy = guiGetScreenSize( );

function OocInfo( theMessage )

	if( not showing ) then
	
		alpha = 0;
		fadeIn = 3;
		text = theMessage;
		showing = true;
	
	end

end

addEvent( "onOOCInfo", true );
addEventHandler( "onOOCInfo", rootElement,

	function ( txt )
	
		if( not showing ) then
		
			alpha = 0;
			fadeIn = 3;
			text = txt;
			showing = true;
		
		end
	
	end
	
);

addEventHandler( "onClientResourceStart", rootElement,  

	function ()
	
		addEventHandler("onClientRender", rootElement, 
		
			function ()
			
				if( showing ) then
			
					local col = tocolor( 255, 255, 0, alpha );
					dxDrawText( text, sx*0.2, sy-30, sx*0.8, sy, col, 1, "pricedown", "center", "cetner" );
					
					if( fadeIn ~= 0 ) then
					
						if( alpha + fadeIn >= 255 ) then
						
							fadeIn = 0;
							ticks = 0;
						
						elseif( alpha + fadeIn <= 0 ) then
						
							fadeIn = 0;
							showing = false;
						
						end
					
						alpha = alpha + fadeIn;
					
					end
					
					if( ticks ~= false ) then
							
						ticks = ticks + 1;
						
						if( ticks > 150 ) then
						
							fadeIn = -3;
							ticks = false;
						
						end

					end
				end
			
			end
			
		);
	
	end

);