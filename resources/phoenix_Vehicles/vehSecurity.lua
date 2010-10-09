local vehSecurity = {

	["hotwire"] = "hw",
	
	["lock1"] = "l1",
	["lock2"] = "l2",
	["lock3"] = "l3",
	["lock4"] = "l4",
	["lock5"] = "l5",
	["lock6"] = "l6",
	["lock7"] = "l7"
	
};

local sVehSecurity = { };
for k, v in pairs( vehSecurity ) do

  sVehSecurity[v] = k;
 
end

local securityData = { };

function tokenize( theStr, delim, separator )
	
	local tbl = { };
	local i = delim - 1;
	while( true ) do
	
		i = i + 1;
		local str = gettok( theStr, i, string.byte(separator) );
		if( not str ) then break; end
		tbl[str] = 1;
	
	end

	return tbl;

end

function InitSecurity( theVehicle, theData )
	
	if( theVehicle and isElement( theVehicle ) and getElementType( theVehicle ) == "vehicle" ) then
	
		securityData[theVehicle] = tokenize( theData, 1, "," );
		
		for k, v in pairs( securityData[theVehicle] ) do
		
			if( not sVehSecurity[k] ) then 
			
				securityData[theVehicle][k] = nil;
			
			end
		
		end
		
		setElementData( theVehicle, "vLockLevel", true, getLockLevel( theVehicle ) );
		
	end

end

function SaveSecurity( theVehicle )

	local str = "";
	if( theVehicle and isElement( theVehicle ) and getElementType( theVehicle ) == "vehicle" ) then
	
		for k, v in pairs( securityData[theVehicle] ) do
		
			if( str ~= "" ) then str = str .. ","; end
			str = str .. k;
		
		end
	
	end
	return str;

end

function getVehicleSecurity( theVehicle, theSecurity )

	if( theVehicle and isElement( theVehicle ) and getElementType( theVehicle ) == "vehicle" and securityData[theVehicle] ) then
	
		local theKey = vehSecurity[theSecurity] or theSecurity;
	
		if( theKey ) then
		
			return ( securityData[theVehicle][theKey] == 1 );
		
		end
	
	end
	return false;

end

function setVehicleSecurity( theVehicle, theSecurity, unset )

	if( theVehicle and isElement( theVehicle ) and getElementType( theVehicle ) == "vehicle" and securityData[theVehicle] ) then
	
		local theKey = vehSecurity[theSecurity] or theSecurity;
	
		if( theKey ) then
		
			if( not unset ) then
			
				securityData[theVehicle][theKey] = 1;
			
			else
			
				securityData[theVehicle][theKey] = nil;
			
			end
			
			setElementData( theVehicle, "vLockLevel", true, getLockLevel( theVehicle ) );
		
		end
	
	end

end


function getLockLevel( theVehicle )

	for k = 7, 1, -1 do
	
		if( getVehicleSecurity( theVehicle, "lock" .. k ) ) then return k; end
	
	end
	
	return 1;

end
local vehSecurity = {

	["hotwire"] = "hw",
	
	["lock1"] = "l1",
	["lock2"] = "l2",
	["lock3"] = "l3",
	["lock4"] = "l4",
	["lock5"] = "l5",
	["lock6"] = "l6",
	["lock7"] = "l7"
	
};

local sVehSecurity = { };
for k, v in pairs( vehSecurity ) do

  sVehSecurity[v] = k;
 
end

local securityData = { };

function tokenize( theStr, delim, separator )
	
	local tbl = { };
	local i = delim - 1;
	while( true ) do
	
		i = i + 1;
		local str = gettok( theStr, i, string.byte(separator) );
		if( not str ) then break; end
		tbl[str] = 1;
	
	end

	return tbl;

end

function InitSecurity( theVehicle, theData )
	
	if( theVehicle and isElement( theVehicle ) and getElementType( theVehicle ) == "vehicle" ) then
	
		securityData[theVehicle] = tokenize( theData, 1, "," );
		
		for k, v in pairs( securityData[theVehicle] ) do
		
			if( not sVehSecurity[k] ) then 
			
				securityData[theVehicle][k] = nil;
			
			end
		
		end
		
		setElementData( theVehicle, "vLockLevel", true, getLockLevel( theVehicle ) );
		
	end

end

function SaveSecurity( theVehicle )

	local str = "";
	if( theVehicle and isElement( theVehicle ) and getElementType( theVehicle ) == "vehicle" ) then
	
		for k, v in pairs( securityData[theVehicle] ) do
		
			if( str ~= "" ) then str = str .. ","; end
			str = str .. k;
		
		end
	
	end
	return str;

end

function getVehicleSecurity( theVehicle, theSecurity )

	if( theVehicle and isElement( theVehicle ) and getElementType( theVehicle ) == "vehicle" and securityData[theVehicle] ) then
	
		local theKey = vehSecurity[theSecurity] or theSecurity;
	
		if( theKey ) then
		
			return ( securityData[theVehicle][theKey] == 1 );
		
		end
	
	end
	return false;

end

function setVehicleSecurity( theVehicle, theSecurity, unset )

	if( theVehicle and isElement( theVehicle ) and getElementType( theVehicle ) == "vehicle" and securityData[theVehicle] ) then
	
		local theKey = vehSecurity[theSecurity] or theSecurity;
	
		if( theKey ) then
		
			if( not unset ) then
			
				securityData[theVehicle][theKey] = 1;
			
			else
			
				securityData[theVehicle][theKey] = nil;
			
			end
			
			setElementData( theVehicle, "vLockLevel", true, getLockLevel( theVehicle ) );
		
		end
	
	end

end


function getLockLevel( theVehicle )

	for k = 7, 1, -1 do
	
		if( getVehicleSecurity( theVehicle, "lock" .. k ) ) then return k; end
	
	end
	
	return 1;

end