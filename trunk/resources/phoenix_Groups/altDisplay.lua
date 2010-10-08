local rootElement = getRootElement( );
local sx, sy = guiGetScreenSize( );

local theText = "none";
local showAlt = false;
local altText = { };
local altBack = tocolor( 255, 255, 255, 150 );
local altTCl = tocolor( 0, 0, 0, 255 );

addEventHandler( "onClientRender", rootElement, 

	function ()
	
		if( showAlt and theText ) then
		
			local curX, curY, worldX, worldY, worldZ = getCursorPosition( );
			curX = curX * sx + 10;
			curY = curY * sy + 10;
			local h = 18;
			local w = dxGetTextWidth( theText ) + 6;			
			
			dxDrawRectangle( curX, curY, w, h, altBack, true );
			dxDrawLine( curX, curY, curX+w, curY, altTCl, 1, true );
			dxDrawLine( curX+w, curY, curX+w, curY+h, altTCl, 1, true );
			dxDrawLine( curX+w, curY+h, curX, curY+h, altTCl, 1, true );
			dxDrawLine( curX, curY+h, curX, curY, altTCl, 1, true );
			
			dxDrawText( theText, curX+3, curY+2, curX+3+w, curY+2+h, altTCl, 1, "default", "left", "top", false, false, true );
		
		end
	
	end

);

function hideText( )

	showAlt = false;
	theText = "none";

end

function AddAltdisplay( element, thetext )

	if( element and altText[element] and isElement( element ) ) then
	
		removeEventHandler( "onClientMouseEnter", element );
		removeEventHandler( "onClientMouseLeave", element, hideText );
	
	end
	
	if( thetext ) then
	
		addEventHandler( "onClientMouseEnter", element, 
			function ( )
			
				if( source ~= element ) then return false end
				theText = altText[source];
				showAlt = true;
			
			end
		);
		addEventHandler( "onClientMouseLeave", element, hideText );	
		altText[element] = thetext;
	end
end