
addEventHandler( "onPlayerWasted", getRootElement( ),
	function()
		setTimer( spawnPlayer, 2000, 1, source, 2420.3459, -1229.879, 24.7299, 180, getElementData( thePlayer, "Character.model" ) );
	end
)