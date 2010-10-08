--[[


]]--

local COOKIE_TIME = 30000;

local cookieTable = { };
local cookieXml = { };

function Cookie( cName, cValue, cExpire )

	if( cName and cValue ) then -- Store a new one.
	
		if( not cookieTable[cName] ) then
		
			cookieTable[cName] = { };
		
		end
		
		if( cExpire ) then cExpire = GetTimestamp( ) + cExpire; end
		
		cookieTable[cName].val = cValue;
		cookieTable[cName].expire = cExpire;
		
		return cookieTable[cName].val;
	
	else -- Return it's value.
	
		if( not cookieTable[cName] ) then
		
			cookieTable[cName] = { };
			cookieTable[cName].val = "";
			cookieTable[cName].expire = false;
			return false;
		
		end
		return cookieTable[cName].val;
	
	end

end

function CookieTimer( )

	local cTime = GetTimestamp( );
	for k, v in pairs( cookieTable ) do
	
		if( v.expire and v.expire < cTime ) then
		
			cookieTable[k] = nil;
		
		end
	
	end

end

function LoadCookies( )

	cookieXml = xmlLoadFile("cookies.xml")
	if ( not cookieXml ) then
	
		cookieXml = xmlCreateFile( "cookies.xml", "cookies" );
		outputDebugString( "xmlCreateFile" );
	
	end
	
	local tempC = xmlNodeGetChildren( cookieXml );
	if( tempC ) then
	
		for k, v in ipairs( tempC ) do
		
			local name = xmlNodeGetAttribute( v, "name" );
			local expire = tonumber( xmlNodeGetAttribute( v, "expire" ) );
			local val = xmlNodeGetValue( v );
			
			if( name and val ) then
			
				Cookie( name, val, expire );
			
			end
		
		end
	
	end

end

function SaveCookies( )

	xmlDestroyNode( cookieXml );
	cookieXml = xmlCreateFile( "cookies.xml", "cookies" );
	for k, v in pairs( cookieTable ) do
	
		local node = xmlCreateChild( cookieXml, "cookie" );
		if( node ) then
		
			xmlNodeSetAttribute( node, "name", k );
			xmlNodeSetAttribute( node, "expire", tostring( v.expire ) );
			xmlNodeSetValue( node, tostring( v.val ) );
		
		end
	
	end
	
	xmlSaveFile( cookieXml );

end

addEventHandler("onClientResourceStart", getResourceRootElement( getThisResource( ) ), 

	function ()
	
		LoadCookies( );
		setTimer( CookieTimer, COOKIE_TIME, 0 );
	
	end

);
addEventHandler("onClientResourceStop", getResourceRootElement( getThisResource( ) ), 

	function ()
	
		SaveCookies( );
	
	end

);

-- 

function IsYearALeapYear(year)
    if ((year % 4 == 0 and year % 100 ~= 0) or year % 400 == 0) then
        return true
    else
        return false
    end
end

function GetTimestamp(year, month, day, hour, minute, second)
    local i
    local timestamp = 0
    local time = getRealTime()
    local monthDays = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    
    if (not year or year < 1970) then
        year = time.year + 1900
        month = time.month + 1
        day = time.monthday
        hour = time.hour
        minute = time.minute
        second = time.second
    else
        month = month or 1
        day = day or 1
        hour = hour or 0
        minute = minute or 0
        second = second or 0
    end
    
    for i=1970, year-1, 1 do
        timestamp = timestamp + 60*60*24*365
        if (IsYearALeapYear(i)) then
            timestamp = timestamp + 60*60*24
        end
    end
    
    if (IsYearALeapYear(year)) then
        monthDays[2] = monthDays[2] + 1
    end
    
    for i=1, month-1, 1 do
        timestamp = timestamp + 60*60*24*monthDays[i]
    end
    
    timestamp = timestamp + 60*60*24 * (day - 1) + 60*60 * hour + 60 * minute + second
    
    return timestamp
end

--