-- TODO: Hiljem, briefcase resource stiilis kohvri liigutamine.

local pickUpLabel;
local pickUpBtn;
local cancelBtn;
local windShowing = false;

function createPickUpMenu( )

	pickUpLabel = guiCreateLabel( 100, 100, 100, 200, "Nimi: -\nData: -", false );
	pickUpBtn = guiCreateButton( 100, 140, 75, 30, "Võta üles", false );
	cancelBtn = guiCreateButton( 100, 180, 75, 30, "Katkesta", false);
	
	guiSetVisible( pickUpLabel, false );
	guiSetVisible( pickUpBtn, false );
	guiSetVisible( cancelBtn, false );
	
end

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), 

	function ()
	
		createPickUpMenu( );
	
	end
	
);

function showPickupMenu( element, x, y )

	local name = getElementData( element, "dropName" );
	local dropAmount = getElementData( element, "dropAmount" );
	
	guiSetPosition( pickUpLabel, x, y, false );
	guiSetPosition( pickUpBtn, x, y+40, false );
	guiSetPosition( cancelBtn, x, y+80, false );
	
	guiSetText( pickUpLabel, "Nimi: " .. name .. "\nData: " .. dropAmount );
	
	guiSetVisible( pickUpLabel, true );
	guiSetVisible( pickUpBtn, true );
	guiSetVisible( cancelBtn, true );
	
	windShowing = element;
	
	addEventHandler("onClientGUIClick", pickUpBtn, 
	
		function ()
		
			triggerServerEvent( "pickupDropItem", getRootElement(), windShowing );
		
			guiSetVisible( pickUpLabel, false );
			guiSetVisible( pickUpBtn, false );
			guiSetVisible( cancelBtn, false );
			windShowing = false;
		
		end
	
	, false);
	
	addEventHandler("onClientGUIClick", cancelBtn, 
	
		function ()
		
			guiSetVisible( pickUpLabel, false );
			guiSetVisible( pickUpBtn, false );
			guiSetVisible( cancelBtn, false );
			windShowing = false;
		
		end
	
	, false);
	
end

addEventHandler( "onClientClick", getRootElement(), 

	function ( button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement )
	
		if( button == "left" and windShowing == false ) then
		
			if( state == "down" ) then
			
				if( clickedElement ~= false and getElementType( clickedElement ) == "object" ) then
				
					local parent = getElementParent( clickedElement );
					
					if( parent ~= nil and parent ~= false ) then
										
						if( getElementData( parent, "dropName" ) ~= false ) then
						
							showPickupMenu( parent, absoluteX, absoluteY );
							
						end
					
					end
				
				end
			
			end
		
		end
	
	end

, true);