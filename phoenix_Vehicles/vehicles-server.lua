oSpeeds = { };
pSeatbelt = { };
engineStarting = { };

function displayLoadedRes( res )	

	LoadVehicles();

end

addEventHandler( "onResourceStart", getResourceRootElement( getResourceFromName( "phoenix_Base" ) ), displayLoadedRes );
addEventHandler( "onResourceStart", getResourceRootElement( getThisResource() ), function () if( getResourceState( getResourceFromName( "phoenix_Base" ) ) == "running" ) then displayLoadedRes( ); end end );

function LoadVehicles()	

	local result = exports.phoenix_Base:SelectQuery( "SELECT * FROM ph_vehicles" );
	local added = 0;
		 
	if( result ) then
		 
		for k, v in ipairs( result ) do
	  	
	  		local newveh = createVehicle( 
	  						v["vModel"], 
	  						v["vPosXd"],
	  						v["vPosYd"],
	  						v["vPosZd"],
	  						v["vAngXd"], 
	  						v["vAngYd"],
	  						v["vAngZd"],
	  						v["vVehNumber"]); 
							

							
	  						
	  		if( newveh ~= false ) then
	  		
	  			setElementData( newveh, "vehicleId", v["vehicleId"]);
	  			setElementData( newveh, "vType", v["vType"]);
	  			setElementData( newveh, "vOwner", v["vOwner"]);
	  			setElementData( newveh, "vValue", v["vValue"]);
	  			setElementData( newveh, "vDeaths", v["vDeaths"]);
				setElementData(newveh, "vAlarm", v["vAlarm"]);
				setElementData(newveh, "vWindow", v["vWindow"]);
				setElementHealth( newveh, v["vHealth"] );
				
				if( tonumber( v["vLocked"] ) == 1 ) then
					setVehicleLocked( newveh, true)
				else
					setVehicleLocked( newveh, false)
				end
				
				if( tonumber( v["vEngine"] ) == 1 ) then
					setVehicleEngineState( newveh, true)
				else
					setVehicleEngineState( newveh, false)
				end
	  			
				setVehicleDoorState( newveh, 0, v["vDoor0State"])
				setVehicleDoorState( newveh, 1, v["vDoor1State"]) 
				setVehicleDoorState( newveh, 2, v["vDoor2State"])   
				setVehicleDoorState( newveh, 3, v["vDoor3State"])
				setVehicleDoorState( newveh, 4, v["vDoor4State"])
				setVehicleDoorState( newveh, 5, v["vDoor5State"])
				
				setVehicleLightState( newveh, 0, v["vLight0State"])
				setVehicleLightState( newveh, 1, v["vLight1State"])
				setVehicleLightState( newveh, 2, v["vLight2State"])
				setVehicleLightState( newveh, 3, v["vLight3State"])
				
				setVehicleOverrideLights( newveh, v["vOverrideLights"])
				
				setVehiclePanelState( newveh, 0, v["vPanel0State"])
				setVehiclePanelState( newveh, 1, v["vPanel1State"])
				setVehiclePanelState( newveh, 2, v["vPanel2State"])
				setVehiclePanelState( newveh, 3, v["vPanel3State"])
				setVehiclePanelState( newveh, 4, v["vPanel4State"])
				setVehiclePanelState( newveh, 5, v["vPanel5State"])
				setVehiclePanelState( newveh, 6, v["vPanel6State"])
				
				setVehicleWheelStates( newveh, v["vWheel1State"], v["vWheel2State"], v["vWheel3State"], v["vWheel4State"])
				
				
	  			setVehicleColor( newveh, v["vColor1"], v["vColor2"], v["vColor3"], v["vColor4"] );
				
				setVehiclePaintjob( newveh, v["vPaintjob"] );
				
				InitSecurity( newveh, v["vSecurity"] );				
	  			
	  			added = added + 1;
	  		
	  		end
	  		
	  			
		end
		
	end
	
	if( added == 0 ) then
	
		outputDebugString( "phoenix_Vehicles ei suutnud ühtegi autot laadida." );
		
	else
	
		outputDebugString( "phoenix_Vehicles laadis " .. added .. " autot." );
		set("NUM_VEHICLES", tostring(added));
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
	query = exports.phoenix_Base:MysqlSetField( query, "vSecurity", SaveSecurity( v ) );

	
	-- Finish query.
	query = exports.phoenix_Base:DoUpdateFinish( query, "vehicleId", sqlId);	
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
    	
			exports.phoenix_Chat:OocInfo( thePlayer, "See sõiduk on müügis." );	
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

function toggleVehicleEngine ( player, cmd, wireStart )

	--if( keyState ~= "up" ) then return 1; end

	local theVehicle = getPedOccupiedVehicle( player );
	local theSeat = getPedOccupiedVehicleSeat ( player );
	if( not theVehicle or theSeat ~= 0 ) then
	
		exports.phoenix_Chat:OocInfo( player, "Sa pead olema masinas" );
		return 2;
		
	end
	
	local vType = getElementData( theVehicle, "vType" );
    if( not vType ) then
    	
    	setVehicleEngineState( theVehicle, true );
    	return 3;
    
    end

	local oldState = getVehicleEngineState ( theVehicle );	
	if( oldState ) then
	
		setVehicleEngineState ( theVehicle, false );
		return 4;
	
	end
    
    if( canPlayerStartVehicle( player, theVehicle ) == false ) then
    
    	
		if( wireStart and wireStart == "juhtmed" ) then
		
			if( getVehicleSecurity( theVehicle, "hotwire" ) ) then
			
				exports.phoenix_Chat:EmoteMessage( player, "üritab masinat juhtmetest käivitada kuid saab elektrit." );
				setElementHealth( player, getElementHealth( player ) - 3 );
			
			else
			
				triggerClientEvent( player, "onCarWireStart", player, theVehicle );
			
			end
		
		else
		
			exports.phoenix_Chat:OocInfo( player, "Sul pole selle masina võtmeid. Kasuta /mootor juhtmed, et masinat juhtmetest." );
		
		end
    
    else
	
		setVehicleEngineState( theVehicle, not oldState );
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

function toggleVehicleSeatBelt ( player, key, keyState )

	local theVehicle = getPedOccupiedVehicle( player );
	
	if( not theVehicle or not isElement ( theVehicle )  ) then
	
		exports.phoenix_Chat:OocInfo( player, "Sa pead olema masinas" );
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
		exports.phoenix_Chat:OocInfo( thePlayer, "(( Käsklused: /turvavöö, /mootor, /tuled))" );
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

function NeedWrenchOrKey( theVehicle )

	local vType = getVehicleType( theVehicle );
	local windOpen = getElementData( theVehicle, "vWindow" );

	local pState = getVehiclePanelState( theVehicle, 4 );
	
	if( not isVehicleLocked( theVehicle ) ) then
	
		return false;
	
	elseif( ( pState and pState > 2 ) ) then 
	
		return false;
	
	elseif( vehTypes[vType] and not vehTypes[vType][2] ) then -- vehicle type doesent need key
	
		return false;
	
	elseif( vehData[vModel] and not vehData[vModel][2] ) then -- vehicle has no roof || windows
	
		return false;
	
	elseif( windOpen and windOpen == 1 ) then

		return false;
	
	end
	
	return true;

end

function onStartEnter( thePlayer, theSeat, theJacked, theDoor )

	if( theSeat == 0 and not canPlayerStartVehicle( thePlayer, source ) ) then
	
		local vType = getVehicleType( source );
		if( vehTypes[vType] and not vehTypes[vType][1] ) then
		
			cancelEvent( );
			exports.phoenix_Chat:OocInfo( thePlayer, "Seda masinat ei saa varastada." );
		
		elseif( NeedWrenchOrKey( source ) ) then
		
			cancelEvent( );		
			exports.phoenix_Chat:OocInfo( thePlayer, "Kasuta nuppu \"e\", et masinat lahti muukida, samas saad ka aknad puruks lasta." );
		
		elseif( isVehicleLocked( source ) ) then
		
			setVehicleLocked( source, false );
			exports.phoenix_Chat:EmoteMessage( thePlayer, "avab ukse akna kaudu." );
		
		end
	
	end

end

addEventHandler ( "onVehicleStartEnter", getRootElement( ), onStartEnter );

addEvent( "onWireStarted", true );
addEventHandler( "onWireStarted", getRootElement( ),

	function ( )
	
		if( client ) then
		
			local theVehicle = getPedOccupiedVehicle( client );
			if( theVehicle ) then
			
				setVehicleEngineState( theVehicle, true );
			
			end
		
		end
	
	end

);

function ReloadVehicles( )

	-- saveStates
	-- delete
	-- load
	outputDebugString( "RELOAD PHOENIX VEHICLES!" );

end

function randomVehicleNumber( )

	local letters = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "o", "p", "q", "r", "s", "t", "u", "w", "x", "y", "z" };

	local num = tonumber( get( "NUM_VEHICLES" ) );
	num = num + 1;
	set( "NUM_VEHICLES", tostring( num ) );
	
	local lDif2to3 = 999 * ( #letters - 1 );
	local lDif1to2 = lDif2to3 * ( #letters - 1 );

	local level_1 = 0;
	if( num > lDif1to2 ) then level_1 = math.floor( num / lDif1to2 ); end
	num = clamp( num, 0, lDif1to2 );
	
	local level_2 = 0;
	if( num > lDif2to3 ) then level_2 = math.floor( num / lDif2to3 ); end	
	num = clamp( num, 0, lDif2to3 );
	
	local level_3 = 0;
	if( num > 999 ) then level_3 = math.floor( num / 999 ); end	
	num = clamp( num, 0, 999 );
	
	return sprintf("%s%s%s-%03d", letters[level_1], letters[level_2], letters[level_3], level_4);

end

function addVeh( thePlayer )

	local vehicle = getPedOccupiedVehicle( thePlayer );
	if( vehicle ) then
	
		local vModel = getElementModel( vehicle );
		local vX, vY, vZ = getElementPosition( vehicle );
		local vRX, vRY, vRZ = getElementRotation( vehicle );
	
		local query = string.format("INSERT INTO ph_vehicles(" ..
				"vehicleId, vModel, vType, vPosXd, vPosYd, vPosZd, vAngXd, vAngYd, vAngZd, vPosX, vPosY, vPosZ, vAngZ, vVehNumber )" ..
				" VALUES(NULL, '%d', '%d', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%s')",
				vModel, 2, vX, vY, vZ, vRX, vRY, vRZ, vX, vY, vZ, vRZ, randomVehicleNumber( ) );
		exports.phoenix_Base:DoSimpleQuery( query );
		ReloadVehicles( );
	
	end

end
addCommandHandler ( "lisaveh", addVeh, false, true ) --temporary
