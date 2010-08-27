local MAX_SPIKES = tonumber( get( "#MAX_SPIKES" ) );

--[[

SpikeStrips Class

variables:

	table allSpikes = { spikeElem }
	
		spikeElem = 
		{
			posX,
			posY,
			posZ,
			rotX,
			rotY,
			rotZ,
			spikeType,
			
			myObject,
			myColShapes,
			myBlip,
			myMarker,
		}
		
		spikeType = -- Lets hope all have the same rotation base...
		{
			1		1593	plc_stinger		plc_stinger -- Currently only one supported...
			2		2892	temp_stinger	temp_stinger
			3		2899	temp_stinger2	temp_stinger
		}
		
		fastColIndexes
		{
			colshape => index
		}

functions:

	Load( );
	Save( );

	Deploy( spikeElem, isInTable );
	
methods:

	BlipVisibility( );
	
]]--

SpikeStrips = {

	allSpikes = { },
	fastColIndexes = { }

};

function SpikeStrips:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	return o;

end

function SpikeStrips:Load( )

	local conf = xmlLoadFile( "spikeStrips/strips.xml" );
	if( conf ) then
	
		local elems = xmlNodeGetChildren( conf );
		if( elems ) then
		
			for k, node in ipairs( elems ) do
			
				if( xmlNodeGetName( node ) == "strip" ) then
				
					local attrs = xmlNodeGetAttributes( node );
					
					local tbl = { };
					tbl.posX = attrs["posX"];
					tbl.posY = attrs["posY"];
					tbl.posZ = attrs["posZ"];
					tbl.rotX = attrs["rotX"];
					tbl.rotY = attrs["rotY"];
					tbl.rotZ = attrs["rotZ"];
					
					tbl.spikeType = attrs["spikeType"];
					tbl.created = false;
					
					if( tbl.posX and tbl.posY and tbl.posZ and tbl.rotX and tbl.rotY and tbl.rotZ and tbl.spikeType ) then
					
						self:Deploy( tbl, false );
					
					else
					
						outputDebugString( "[SpikeStrips:Load] Wrong xmlNode attrs." );
					
					end
				
				else
				
					outputDebugString( "[SpikeStrips:Load] Bad xmlNode name: " .. xmlNodeGetName( node ) .. "." );
				
				end
			
			end
		
		end
		
		xmlUnloadFile( conf );
	
	end

end

function SpikeStrips:Save( )

	local conf = xmlCreateFile( "spikeStrips/strips.xml", "strips" );
	if( conf ) then
	
		for k, v in ipairs( self.allSpikes ) do
		
			local node = xmlCreateChild( conf, "strip" );
			xmlNodeSetAttribute( node, "posX", v.posX);
			xmlNodeSetAttribute( node, "posY", v.posY);
			xmlNodeSetAttribute( node, "posZ", v.posZ);
			xmlNodeSetAttribute( node, "rotX", v.rotX);
			xmlNodeSetAttribute( node, "rotY", v.rotY);
			xmlNodeSetAttribute( node, "rotZ", v.rotZ);
			xmlNodeSetAttribute( node, "spikeType", v.spikeType);
		
		end
	
		xmlSaveFile( conf );
		xmlUnloadFile( conf );
	
	end

end

function getPointFromDistanceRotation(x, y, dist, angle)
 
    local a = math.rad(90 - angle);
 
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
 
    return x+dx, y+dy;
 
end

function SpikeStrips:GetSouthWestCornerPos( objectId, x, y, rotz )

	if( objectId == 1593 ) then

		local distance = 0.91;
		local addonR = 180 + math.deg( math.atan( 0.115 / 0.9 ) );
		if( rotz >= addonR ) then rotz = rotz - ( addonR ); else rotz = rotz + ( addonR ); end	
		x, y = getPointFromDistanceRotation( x, y, distance, rotz );	
	
	end
	return x, y;

end

function SpikeStrips:CreateColArea( x, y, myZ, elemAng )
	
	local area = createColCircle( x, y, 1.8 );
	self.fastColIndexes[area] = #self.allSpikes+1;
	addEventHandler( "onColShapeHit", area, function ( elem, dim ) local theZ = myZ; if( getElementType( elem ) == "vehicle" and dim ) then self:ColShapeHit( elem, area, theZ ); end end );
	
	return area;

end

function SpikeStrips:ColShapeHit( theVehicle, theColShape, colZ )

	if( self.fastColIndexes[theColShape] ) then
	
		local vehX, vehY, vehZ = getElementPosition( theVehicle );
		colZ = tonumber( colZ );		
		if( ( vehZ > colZ and ( vehZ - colZ ) < 1 ) or ( vehZ < colZ and ( colZ - vehZ ) < 1 ) ) then
		
			setVehicleWheelStates( theVehicle, 1, 1, 1, 1 );
			
			destroyElement( self.allSpikes[self.fastColIndexes[theColShape]].myObject );
			destroyElement( self.allSpikes[self.fastColIndexes[theColShape]].myColShapes );
			destroyElement( self.allSpikes[self.fastColIndexes[theColShape]].myBlip );
			
			table.remove( self.allSpikes, self.fastColIndexes[theColShape] );
			self.fastColIndexes[theColShape] = nil;
			
			self:UpdateFastIndexes( );
		
		end
	
	end

end

function SpikeStrips:UpdateFastIndexes( )

	self.fastColIndexes = { };
	for k, v in ipairs( self.allSpikes ) do
	
		self.fastColIndexes[v.myColShapes] = k;
	
	end	

end

function SpikeStrips:ReloadForVehicle( thePlayer, theVehicle )

	local numStrips = tonumber( getElementData( theVehicle, "spikeStrips" ) );
	if( not numStrips ) then numStrips = 0; end
	
	if( numStrips < MAX_SPIKES ) then
	
		numStrips = numStrips + 1;
		setElementData( theVehicle, "spikeStrips", tostring( numStrips ) );	
		exports.phoenix_Chat:OocInfo( thePlayer, "Võtsid ühe naelariba juurde. Su masinas on nüüd " .. numStrips .. " naelariba." );
	
	else
	
		exports.phoenix_Chat:OocInfo( thePlayer, "Masinal on naelaribade kohad(" .. MAX_SPIKES .. ") täis!" );
	
	end

	getVehicleOccupant( theVehicle );

end

function SpikeStrips:Deploy( spikeElem )

	spikeElem.myObject = createObject( spikeElem.spikeType, spikeElem.posX, spikeElem.posY, spikeElem.posZ, spikeElem.rotX, spikeElem.rotY, spikeElem.rotZ );
	
	spikeElem.myBlip = createBlip( spikeElem.posX, spikeElem.posY, spikeElem.posZ, 0, 3, 150, 0, 255, 255, 0, 9999.0 );
	spikeElem.myColShapes = self:CreateColArea( spikeElem.posX, spikeElem.posY, spikeElem.posZ, spikeElem.rotZ );	
	
	self:BlipVisibility( spikeElem );
	
	spikeElem.created = true;
	
	table.insert( self.allSpikes, spikeElem );
	
end

function SpikeStrips:BlipVisibility( spikeElem )

	local cops = getPlayersInTeam( getCopTeam( ) );

	if( not spikeElem ) then
	
		for k, v in ipairs( self.allSpikes ) do
		
			setElementVisibleTo( v.myBlip, getRootElement( ), false );
			for k2, v2 in ipairs( cops ) do 
			
				setElementVisibleTo( v.myBlip, v2, true );
			
			end
		
		end
	
	else
	
		setElementVisibleTo( spikeElem.myBlip, getRootElement( ), false );
		for k2, v2 in ipairs( cops ) do 
		
			setElementVisibleTo( spikeElem.myBlip, v2, true );
		
		end		
	
	end

end

theStrips = SpikeStrips:new();
theStrips:Load( );

function SpikeTimer( )

	theStrips:BlipVisibility( );

end

setTimer( SpikeTimer, 30000, 0 );



addEvent( "onSpikeDrop", true );
addEventHandler( "onSpikeDrop", getRootElement( ),

	function ( newElem )
	
		theStrips:Deploy( newElem );
	
	end

);

addEventHandler( "onResourceStop", getResourceRootElement( ), 

	function ( )
	
		theStrips:Save( );
	
	end

);

local pickup = createPickup( 1560.828, -1694.256, 5.302, 3, 1242, 1000 );
local colCircle = createColCircle( 1560.828, -1694.256, 5 );
addEventHandler( "onColShapeHit", colCircle,

	function ( elem, matchingDim )
	
		if( matchingDim ) then
			
			if( getElementType( elem ) == "vehicle" and isCopVehicle( elem ) ) then		
			
				local thePlayer = getVehicleOccupant( elem );
				if( thePlayer ) then
				
					if( isACop( thePlayer ) ) then
					
						exports.phoenix_Chat:OocInfo( thePlayer, "Kasuta /laett, et masinasse veel üks teetõke laadida." );
					
					end
				
				end
			
			end
		
		end
	
	end

);

addCommandHandler( "laett",

	function ( thePlayer, theCmd )
	
		if( not isACop( thePlayer ) ) then
		
			exports.phoenix_Chat:OocInfo( thePlayer, "Pead olema politseinik!" );
			return false;
		
		end
		
		if( not isPedInVehicle( thePlayer ) ) then
		
			exports.phoenix_Chat:OocInfo( thePlayer, "Pead olema autos!" );
			return false;
		
		end
		
		local theVehicle = getPedOccupiedVehicle( thePlayer );
		local posX, posY, posZ = getElementPosition( theVehicle );
		
		if( getDistanceBetweenPoints3D( posX, posY, posZ, 1560.828, -1694.256, 5.302 ) > 5 ) then
		
			exports.phoenix_Chat:OocInfo( thePlayer, "Pead olema politsei garaasis!" );
			return false;
		
		end
			
		theStrips:ReloadForVehicle( thePlayer, theVehicle );
	
	end

, false, false );