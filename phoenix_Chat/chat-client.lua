local showing = false;
local alpha = 0;
local fadeIn = 0;
local text = "...";

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

function StartHide( )

	fadeIn = -3;

end

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
							setTimer( StartHide, 3000, 1 );
						
						elseif( alpha + fadeIn <= 0 ) then
						
							fadeIn = 0;
							showing = false;
						
						end
					
						alpha = alpha + fadeIn;
					
					end
				
				end
			
			end
			
		);
	
	end

);