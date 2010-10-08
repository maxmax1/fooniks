function AddSprayTag( model, posX, posY, posZ, rotX, rotY, rotZ )

	local obj = createObject ( model, posX, posY, posZ, rotX, rotY, rotZ )
	local elem = getResourceMapRootElement( getThisResource( ), "sprayTags.map" );
	setElementParent( obj, elem );

end

addEvent( "onClientSprayTagCompleted", true );
addEventHandler( "onClientSprayTagCompleted", getRootElement( ), AddSprayTag );