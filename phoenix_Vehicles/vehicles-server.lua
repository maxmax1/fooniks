connection = nil;
oSpeeds = { };
pSeatbelt = { };
engineStarting = { };

function displayLoadedRes( res )	
	
	if( not connection ) then
	
		connection = mysql_connect( get( "#phoenix_Base.MYSQL_HOST" ), get( "#phoenix_Base.MYSQL_USER" ), get( "#phoenix_Base.MYSQL_PASS" ), get( "#phoenix_Base.MYSQL_DB" ) );
		
		if( not connection ) then
		
			outputDebugString( "phoenix_Vehicles ei saanud mysql Ã¼hendust kÃ¤tte." );
			stopResource( res );
		
		else
		
			outputDebugString( "Mysql serveriga Ã¼hendatud." );
			LoadVehicles();
		
		end	
		
	end
	
end

addEventHandler( "onResourceStart", getResourceRootElement( getThisResource( ) ), displayLoadedRes );

function LoadVehicles()	
	
	local query = "SELECT * FROM ph_vehicles";
	local result = mysql_query( connection, query );
	local added = 0;
		 
	if( result ) then
		 
		for result ,row in mysql_rows( result ) do
			
  			mysql_field_seek( result, 1 );
  			
  			local vehicleStuff = {};
  			
  			for k,v in ipairs( row ) do
  				
    			local field = mysql_fetch_field( result );
    				
    			if (v == mysql_null()) then v = ''; end
    				
      			vehicleStuff[field["name"]] = v;
    				
	  		end
	  		
	  		local newveh = createVehicle( 
	  						vehicleStuff["vModel"], 
	  						vehicleStuff["vPosXd"],
	  						vehicleStuff["vPosYd"],
	  						vehicleStuff["vPosZd"],
	  						vehicleStuff["vAngXd"], 
	  						vehicleStuff["vAngYd"],
	  						vehicleStuff["vAngZd"],
	  						vehicleStuff["vVehNumber"]); 
							

							
	  						
	  		if( newveh ~= false ) then
	  		
	  			setElementData( newveh, "vehicleId", vehicleStuff["vehicleId"]);
	  			setElementData( newveh, "vType", vehicleStuff["vType"]);
	  			setElementData( newveh, "vOwner", vehicleStuff["vOwner"]);
	  			setElementData( newveh, "vValue", vehicleStuff["vValue"]);
	  			setElementData( newveh, "vDeaths", vehicleStuff["vDeaths"]);
				setElementData(newveh, "vAlarm", vehicleStuff["vAlarm"]);
				setElementData(newveh, "vWindow", vehicleStuff["vWindow"]);
				setElementHealth( newveh, vehicleStuff["vHealth"] );
				
				if vehicleStuff["vLocked"] == 1 then
					setVehicleLocked( newveh, true)
				else
					setVehicleLocked( newveh, false)
				end
				
				if vehicleStuff["vEngine"] == 1 then
					setVehicleEngineState( newveh, true)
				else
					setVehicleEngineState( newveh, false)
				end
	  			
				setVehicleDoorState( newveh, 0, vehicleStuff["vDoor0State"])
				setVehicleDoorState( newveh, 1, vehicleStuff["vDoor1State"]) 
				setVehicleDoorState( newveh, 2, vehicleStuff["vDoor2State"])   
				setVehicleDoorState( newveh, 3, vehicleStuff["vDoor3State"])
				setVehicleDoorState( newveh, 4, vehicleStuff["vDoor4State"])
				setVehicleDoorState( newveh, 5, vehicleStuff["vDoor5State"])
				
				setVehicleLightState( newveh, 0, vehicleStuff["vLight0State"])
				setVehicleLightState( newveh, 1, vehicleStuff["vLight1State"])
				setVehicleLightState( newveh, 2, vehicleStuff["vLight2State"])
				setVehicleLightState( newveh, 3, vehicleStuff["vLight3State"])
				
				setVehicleOverrideLights( newveh, vehicleStuff["vOverrideLights"])
				
				setVehiclePanelState( newveh, 0, vehicleStuff["vPanel0State"])
				setVehiclePanelState( newveh, 1, vehicleStuff["vPanel1State"])
				setVehiclePanelState( newveh, 2, vehicleStuff["vPanel2State"])
				setVehiclePanelState( newveh, 3, vehicleStuff["vPanel3State"])
				setVehiclePanelState( newveh, 4, vehicleStuff["vPanel4State"])
				setVehiclePanelState( newveh, 5, vehicleStuff["vPanel5State"])
				setVehiclePanelState( newveh, 6, vehicleStuff["vPanel6State"])
				
				setVehicleWheelStates( newveh, vehicleStuff["vWheel1State"], vehicleStuff["vWheel2State"], vehicleStuff["vWheel3State"], vehicleStuff["vWheel4State"])
				
				
	  			setVehicleColor( newveh, vehicleStuff["vColor1"], vehicleStuff["vColor2"], vehicleStuff["vColor3"], vehicleStuff["vColor4"] );
				
				setVehiclePaintjob( newveh, vehicleStuff["vPaintjob"])
				
	  			
	  			added = added + 1;
	  		
	  		end
	  		
	  			
		end
		
	end
	
	if( added == 0 ) then
	
		outputDebugString( "phoenix_Vehicles ei suutnud ühtegi autot laadida." );
		
	else
	
		outputDebugString( "phoenix_Vehicles laadis " .. added .. " autot." );
		setTimer( UpdateVehicleVelForCrash, 3000, 0 );
	
	end

end

function ResourceStop ()

    SaveVehicles();
    
end
addEventHandler ( "onResourceStop", getResourceRootElement ( getThisResource () ), ResourceStop, true )

function SaveVehicles()

	local arr = getElementsByType( "vehicle" );
	
	for k,v in ipairs(arr) do
	
		UpdateVehicle( v );
	
	end
	
end

function UpdateVehicle( v )

	local sqlId = getElementData( v, "vehicleId" );
	if( sqlId == false) then return false; end
	
	local col1, col2, col3, col4 = getVehicleColor ( v );
		
	-- Start query building
	local query = exports.phoenix_Base:MysqlUpdatebuild( "ph_Vehicles");
	
	-- Set Fields
	query = exports.phoenix_Base:MysqlSetField( query, "vHealth", getElementHealth( v ) );
	query = exports.phoenix_Base:MysqlSetField( query, "vColor1", col1 );
	query = exports.phoenix_Base:MysqlSetField( query, "vColor2", col2 );
	query = exports.phoenix_Base:MysqlSetField( query, "vColor3", col3 );
	query = exports.phoenix_Base:MysqlSetField( query, "vColor4", col4 );
	query = exports.phoenix_Base:MysqlSetField( query, "vOwner", getElementData( v, "vOwner" ) );
	query = exports.phoenix_Base:MysqlSetField( query, "vValue", getElementData( v, "vValue" ) );
	query = exports.phoenix_Base:MysqlSetField( query, "vDeaths", getElementData( v, "vDeaths" ) );
	query = exports.phoenix_Base:MysqlSetField( query, "vOverrideLights", getVehicleOverrideLights( v ) );
	query = exports.phoenix_Base:MysqlSetField( query, "vAlarm", getElementData( v, "vAlarm" ) );
	
	if isVehicleLocked( v ) then
		query = exports.phoenix_Base:MysqlSetField( query, "vLocked", 1 );
	else
		query = exports.phoenix_Base:MysqlSetField( query, "vLocked", 0 );
	end
	
	if getVehicleEngineState( v ) then
		query = exports.phoenix_Base:MysqlSetField( query, "vEngine", 1 );
	else
		query = exports.phoenix_Base:MysqlSetField( query, "vEngine", 0 );
	end

	for i = 0, 5 do
		query = exports.phoenix_Base:MysqlSetField( query, "vDoor"..i.."State", getVehicleDoorState( v, i ) );
	end	
	
	for i = 0, 3 do
		query = exports.phoenix_Base:MysqlSetField( query, "vLight"..i.."State", getVehicleLightState( v, i ) );
	end	
	
	for i = 0, 6 do
		query = exports.phoenix_Base:MysqlSetField( query, "vPanel"..i.."State", getVehiclePanelState( v, i ) );
	end	
	
	local wheelState1, wheelState2, wheelState3, wheelState4 = getVehicleWheelStates ( v )
	query = exports.phoenix_Base:MysqlSetField( query, "vWheel1State", wheelState1 );
	query = exports.phoenix_Base:MysqlSetField( query, "vWheel2State", wheelState2 );
	query = exports.phoenix_Base:MysqlSetField( query, "vWheel3State", wheelState3 );
	query = exports.phoenix_Base:MysqlSetField( query, "vWheel4State", wheelState4 );
	
	query = exports.phoenix_Base:MysqlSetField( query, "vWindow", getElementData( v, "vWindow" ) );
	
	query = exports.phoenix_Base:MysqlSetField( query, "vPaintjob", getVehiclePaintjob( v ) );

	
	-- Finish query.
	query = exports.phoenix_Base:UpdateFinish( query, "vehicleId", sqlId);
	
	local result = mysql_query( connection, query );
	if( result ~= false ) then mysql_free_result( result ); end
	
	return true;

end

function onVehicleRespawn ( exploded )

	if ( not exploded ) then return false; end
	
	local deaths = getElementData( v, "vDeaths" );
	
	if( deaths ~= false ) then
	
		deaths = deaths + 1;
		setElementData( newveh, "vDeaths", deaths);
	
	end

end
addEventHandler ( "onVehicleRespawn", getRootElement(), onVehicleRespawn )

function displayVehicleLoss(loss)
	
	local id = getElementData( source, "vehicleId" );
    if( not id ) then return false end
	
	local nextSeat = 0;
	local maxSeats = getVehicleMaxPassengers( source );
	local thePlayer = getVehicleOccupant(source, nextSeat);
	
	if( thePlayer ~= false ) then 
	
    	setVehicleTurnVelocity( source, 0, 0, 0.005 );
    	
    end   
	
	while ( thePlayer ~= false ) do
		
    	
    	if( loss > 50 and pSeatbelt[thePlayer] ~= nil and pSeatbelt[thePlayer] == true ) then
    	
    		removePedFromVehicle( thePlayer );
    		setTimer( setElementVelocity, 300, 1, thePlayer, oSpeeds[source][1], oSpeeds[source][2],oSpeeds[source][3] );
			
		end
    	
    	
    	nextSeat = nextSeat + 1;
    	if(nextSeat >= maxSeats) then break end
    	thePlayer = getVehicleOccupant(source, nextSeat);
    
    end
    
end
 
addEventHandler("onVehicleDamage", getRootElement(), displayVehicleLoss)

function UpdateVehicleVelForCrash(  )

	for k, v in ipairs( getElementsByType( "vehicle" ) ) do

		if( getVehicleOccupant( v ) ~= false ) then
	
			if( oSpeeds[v] == nil ) then
			
				oSpeeds[v] = { };
				
			end
	
			oSpeeds[v][1], oSpeeds[v][2],oSpeeds[v][3] = getElementVelocity( v );
	
		end

	
	end

end

function canPlayerStartVehicle( thePlayer, theVehicle )
    
	local vType = getElementData( theVehicle, "vType" );    
    local vOwner = getElementData( theVehicle, "vOwner" );
    
    if( not vType ) then vType = 0; else vType = tonumber(vType); end
    if( not vOwner ) then vOwner = 0; else vOwner = tonumber(vOwner); end 
    
    local pGroup = 0;
    local pJob = getElementData( thePlayer, "Character.playerJob" );
    local pId = getElementData( thePlayer, "Character.id" );
    local pAdmin = getElementData( thePlayer, "Character.adminLevel" );

    if( vType == 0 ) then -- Group Vehicle
    
    	if( vOwner == 0 ) then
    	
    		return true; 
    		
    	elseif( vOwner ~= pGroup ) then
    	
    		return false;
    		
    	end
    
    elseif( vType == 1 ) then -- Job Vehicle
    
    	if( vOwner == 0 ) then
    	
    		return true; 
    		
    	elseif( vOwner ~= pJob ) then
    	
    		return false;
    		
    	end
    
    elseif( vType == 2 ) then -- Buyable Vehicle
    
    	if( vOwner == 0 ) then -- OnSale
    	
    		outputChatBox( thePlayer, "See sõiduk on müügis." );
    		return false;
    		
    	elseif( vOwner > 0 and vOwner ~= pId) then
    	
    		return false;
    		
    	else
    	
    		return true;
    	
    	end
    
    else
    
	    if( not pAdmin or pAdmin < 1 ) then return false; 
	    else return true;  end
    
    end
    
    return false;
    
end

function toggleVehicleEngine ( player, key, keyState )

	--if( keyState ~= "up" ) then return 1; end

	local theVehicle = getPedOccupiedVehicle( player );
	local theSeat = getPedOccupiedVehicleSeat ( player );
	if( not theVehicle or theSeat ~= 0 ) then
	
		outputChatBox( "Sa pead olema masinas", player );
		return 2;
		
	end
	
	local vType = getElementData( theVehicle, "vType" );
    if( not vType ) then
    	
    	setVehicleEngineState( theVehicle, true );
    	return 3;
    
    end
    
    if( canPlayerStartVehicle( player, theVehicle ) == false ) then
    
    	outputChatBox( "Sul pole selle masina võtmeid", player );
    
    else
	
		local oldState = getVehicleEngineState ( theVehicle );

		if( oldState == false ) then
		
			-- setTimer( setVehicleEngineState, 1000, 1, theVehicle );
			setVehicleEngineState( theVehicle, true ); -- Ajutine, hiljem vÃµtaks mootori kÃ¤ivitamine aega.
		
		else
		
			setVehicleEngineState( theVehicle, false );
		
		end
		
		return 0;
		
	end
    
end
addCommandHandler ( "mootor", toggleVehicleEngine, false, true ) --temporary

--[[
function engineStartEnd( thePlayer, theVehicle )

	engineStarting[theVehicle] = false;
	setPedFrozen( thePlayer, false );
	setVehicleEngineState( theVehicle, true );

end
]]--

function toggleVehicleLights ( player, key, keyState )

	local theVehicle = getPedOccupiedVehicle( player );
	local theSeat = getPedOccupiedVehicleSeat ( player );
	if( not theVehicle or theSeat > 1 ) then
	
		outputChatBox( "Sa pead olema masinas / masina esiistmel.", player );
		return 2;
		
	end
	
	local newState = getVehicleOverrideLights( theVehicle );
	
	if( newState == 1 ) then -- lights off
	
		newState = 2;
		
	else
	
		newState = 1;
	
	end
	
	setVehicleOverrideLights( theVehicle, newState );
    
end
addCommandHandler ( "tuled", toggleVehicleLights, false, true ) --temporary

function toggleVehicleSeatBelt ( player, key, keyState )

	local theVehicle = getPedOccupiedVehicle( player );
	
	if( not theVehicle or not isElement ( theVehicle )  ) then
	
		outputChatBox( "Sa pead olema masinas", player );
		return 2;
		
	end
	
	pSeatbelt[player] = not pSeatbelt[player];
	
	local action = "avab turvavöö.";
	if( pSeatbelt[player] == true ) then
	
		action = "paneb turvavöö peale.";
		
	end	
	executeCommandHandler ( "me", player, action );
    
end
addCommandHandler ( "turvavöö", toggleVehicleSeatBelt, false, true ) --temporary

--[[function onDriverExit( thePlayer )

	if(not thePlayer or not isElement ( thePlayer ) ) then return false end
	unbindKey( thePlayer, "g", "up", toggleVehicleEngine );
	unbindKey( thePlayer, "l", "up", toggleVehicleLights );

end]]

addEventHandler ( "onVehicleEnter", getRootElement(),

	function ( thePlayer, seat, jacked )
		outputChatBox( "(( Käsklused: /turvavöö, /mootor, /tuled))", thePlayer );
		if( seat == 0) then
				
			
		--	setVehicleEngineState( source, false ); -- Someday remove this.
		--	setVehicleOverrideLights( source, 1 ); -- Someday remove this.
			
		--	bindKey( thePlayer, "g", "up", toggleVehicleEngine );
		--	bindKey( thePlayer, "l", "up", toggleVehicleLights );
			
		end
		
		pSeatbelt[thePlayer] = false;
--		bindKey( thePlayer, "h", "up", toggleVehicleSeatBelt );
	
	end

);

--[[addEventHandler ( "onVehicleExit", getRootElement(),

	function ( thePlayer, seat, jacked )
	
		unbindKey( thePlayer, "h", "up", toggleVehicleSeatBelt );
	
	end

);
]]

	


