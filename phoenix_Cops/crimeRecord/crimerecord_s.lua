CrimeRecord = {

	allCrimes = { }

};

function CrimeRecord:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	return o;

end

function CrimeRecord:Load( )

	local results = exports.phoenix_Base:SelectQuery( "SELECT * FROM ph_crimerecord" );
	 
	for k, v in ipairs( results ) do
	
		local sqlId = tonumber( v["charid"] );
	
		if( not self.allCrimes[sqlId] ) then self.allCrimes[sqlId] = { }; end
		
		local tbl = { };
		tbl.sqlid = tonumber( v["id"] );
		tbl.suid = tonumber( v["suid"] );
		tbl.type = tonumber( v["sutype"] );
		tbl.amount = tonumber( v["suAmount"] );
		tbl.descr = v["suDescr"];
		tbl.wantDelete = false;
		table.insert( self.allCrimes[sqlId], tbl );
	
	end
end

function CrimeRecord:Save( )

	for k, v in pairs( self.allCrimes ) do
	
		for k2, v2 in ipairs( v ) do
		
			if( v2.wantDelete ) then
			
				exports.phoenix_Base:DoSimpleQuery( "DELETE FROM `ph_crimerecord` WHERE `id` = '" .. v2.sqlid .. "'" );
			
			elseif( v2.sqlid and v2.sqlid > 0 ) then
			
				local query = exports.phoenix_Base:MysqlUpdatebuild("ph_crimerecord");
				if( query ) then
				
					query = exports.phoenix_Base:MysqlSetField( query, "suid", v.suid );
					query = exports.phoenix_Base:MysqlSetField( query, "sutype", v.type );
					query = exports.phoenix_Base:MysqlSetField( query, "suAmount", v.amount );
					query = exports.phoenix_Base:MysqlSetField( query, "suDescr", v.descr );
					
					if( query ) then
					
						query = exports.phoenix_Base:DoUpdateFinish( query, "id", v.sqlid );
					
					end
				
				end
			
			else
			
				local id = exports.phoenix_Base:DoSimpleQuery( "INSERT INTO `phoenix`.`ph_crimerecord` (`id`, `charid`, `suid`, `sutype`, `suAmount`, `suDescr`) VALUES (NULL, " ..
				"'0', " .. 
				"'0', " .. 
				"'0', " .. 
				"'0', " .. 
				"'asd')", true );
				self.allCrimes[k][k2].sqlid = id;
			
			end
		
		end
		
		for i = #v, 1, -1 do
		
			if( v[i].wantDelete ) then
			
				table.remove( self.allCrimes[k], i );
			
			end
		
		end
	
	end

end

function CrimeRecord:GetSuspects( theStr, start, limit )

	local tbl = { };
	for k, v in pairs( self.allCrimes ) do
	
		local match = false;
		local name = getCharacterName( tonumber( k ) );
		
		if( theStr ) then
		
			local i, j = string.find( theStr, name );
			if( not i ) then match = false; else match = true; end
		
		end
		if( match ) then
			table.insert( tbl, { ["id"] = tonumber( k ), ["name"] = name } );
		end
	
	end
	
	local tbl2 = { };
	for i = start,limit do
	
		table.insert( tbl2, tbl[i] );
	
	end
	return tbl;

end