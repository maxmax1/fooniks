local gangTagObjects = {

	1490, -- dff: tag_01, txd: tags2_LAlae
	1524, -- dff: tag_front, txd: tags_LAfront
	1525, -- dff: tag_kilo, txd: tags_LAkilo
	1526, -- dff: tag_rifa, txd: tags_LArifa
	1527, -- dff: tag_rollin, txd: tags_LArollin
	1528, -- dff: tag_seville, txd: tags_LAseville
	1529, -- dff: tag_temple, txd: tags_LAtemple
	1530, -- dff: tag_vagos, txd: tags_LAvagos
	1531  -- dff: tag_azteca, txd: tags_LAazteca

};

addEventHandler( "onClientResourceStart", getResourceRootElement( getThisResource( ) ), 

	function ( )
	
		for k, v in ipairs( gangTagObjects ) do
		
			local txd = engineLoadTXD( "tags/tags_" .. v .. ".txd" );
			if( txd ) then
			
				engineImportTXD ( txd, v );
			
			end
		
		end
	
	end

);