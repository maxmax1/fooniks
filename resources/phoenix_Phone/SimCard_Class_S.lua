--[[

SimCards

	Variables:
	
		table allCards
	
	Functions:
	
		Load();
		Save();
	
	Events:
	
		onSimInfoRequest( );
		
		onSmsUpdate
		
		onNewContact
		
		onClearSmsLog
		onSingleSmsUpdate
		onClearSingleSmsLog
		onSmsSend

]]--

SimCards = { };
SimCards.__index = SimCards;

function SimCards.new( )

	local o = { };
	setmetatable( o, SimCards );
	
	o.allCards = { };
	o.allPlayers = { };
	o.fastNumbers = { };
	o.endCall = { };
	o.phoneCost = {
	
		{ name = "Smart", sms = 0.79, callMin = 0.75, theNumbers = { 4, 5 } },
		{ name = "Simpel", sms = 3, callMin = 2, theNumbers = { 3 } },
		{ name = "Diil"	, sms = 0.79, callMin = 1.5, theNumbers = { 3 } },
		{ name = "TeleYks"	, sms = 0.79, callMin = 0.79, theNumbers = { 6 } }
	
	};
	o.connectingCalls = { };-- theCalled => theCaller	
	o.allCalls = { };-- theCalled => theCaller	
	
	return o;

end

function SimCards:Load( )

	local results = exports.phoenix_Base:SelectQuery( "SELECT * FROM ph_simcard" );
	 
	for k, v in ipairs( results ) do
	
		local newSim = { };
		local newId = tonumber( v["id"] );
	
		newSim.inCall = false;
		newSim.cid = v["companyId"];
		newSim.number = tonumber( v["sNumber"] );
		newSim.contacts = { };
		newSim.sms = { };
		
		local myContacts = exports.phoenix_Base:SelectQuery( "SELECT * FROM ph_contacts WHERE sCard = '" .. newId .. "'" );
		for k2, v2 in ipairs( myContacts ) do
		
			local tbl = { };
			
			tbl.id = tonumber( v2["id"] );
			tbl.name = v2["cName"];
			tbl.number = tonumber( v2["cNumber"] );
			tbl.inSql = true;
			
			table.insert(newSim.contacts, tbl);
		
		end
		
		local mySmsLog = exports.phoenix_Base:SelectQuery( "SELECT * FROM ph_SmsLog WHERE sCard = '" .. newId .. "'" );
	
		for k2, v2 in ipairs( mySmsLog ) do
			
			local tbl = { };	
			
			tbl.id = tonumber( v2["id"] );
			tbl.number = tonumber( v2["sName"] );
			tbl.text = v2["sText"];
			tbl.read = tonumber( v2["sRead"] );
			tbl.inSql = true;
			
			table.insert(newSim.sms, tbl);
		
		end		
		self.allCards[newId] = newSim;
		self.fastNumbers[newSim.number] = newId;
	
	end

end

function SimCards:SaveSingle( theSim, theKey )

	for k, v in pairs( theSim.contacts ) do
	
		if( v.wantDelete ) then
		
			local query = "DELETE FROM ph_contacts WHERE id = '" .. v.id .. "' LIMIT 1";
			exports.phoenix_Base:DoSimpleQuery( query );
			theSim.contacts[k] = nil;
		
		elseif( v.inSql ) then -- Is already an item in mysql...
		
			local query = exports.phoenix_Base:MysqlUpdatebuild("ph_contacts");
			if( query ) then
			
				query = exports.phoenix_Base:MysqlSetField( query, "cName", v.name );
				query = exports.phoenix_Base:MysqlSetField( query, "cNumber", v.number );
				
				if( query ) then
				
					query = exports.phoenix_Base:DoUpdateFinish( query, "id", v.id );
				
				end
			
			end
		
		else
		
			local query = "INSERT INTO ph_contacts(id, sCard, cNumber, cName) VALUES(NULL, " ..
			"'" .. theKey .. "', " ..
			"'" .. v.number .. "', " ..
			"'" .. v.name .. "'" ..
			")";
			local newId = tonumber( exports.phoenix_Base:DoSimpleQuery( query, true ) );
			if( newId and newId > 0 ) then
			
				theSim.contacts[k].id = newId;
				theSim.contacts[k].inSql = true;
			
			end
		
		end
	
	end
	
	for k, v in pairs( theSim.sms ) do
	
		if( v.wantDelete ) then
		
			local query = "DELETE FROM ph_smslog WHERE id = '" .. v.id .. "' LIMIT 1";
			exports.phoenix_Base:DoSimpleQuery( query );
			theSim.sms[k] = nil;
		
		elseif( v.inSql ) then -- Is already an item in mysql...
		
			local query = exports.phoenix_Base:MysqlUpdatebuild("ph_smslog");
			if( query ) then
			
				query = exports.phoenix_Base:MysqlSetField( query, "sName", v.number );
				query = exports.phoenix_Base:MysqlSetField( query, "sText", v.text );
				query = exports.phoenix_Base:MysqlSetField( query, "sRead", v.read );
				
				if( query ) then
				
					query = exports.phoenix_Base:DoUpdateFinish( query, "id", v.id );
				
				end
			
			end
		
		else
		
			local query = "INSERT INTO ph_smslog(id, sCard, sName, sText, sRead) VALUES(NULL, " ..
			"'" .. theKey .. "', " ..
			"'" .. v.number .. "', " ..
			"'" .. v.text .. "', " ..
			"'" .. v.read .. "'" ..
			")";
			local newId = tonumber( exports.phoenix_Base:DoSimpleQuery( query, true ) );
			if( newId and newId > 0 ) then
			
				theSim.sms[k].id = newId;
				theSim.sms[k].inSql = true;
			
			end
		
		end
	
	end

end

function SimCards:Save( )
	
	for k, v in pairs( self.allCards ) do 

		self:SaveSingle( v, k );
	
	end

end

function SimCards:NewSimCard( comp )

	local company = 0;

	if( not self.phoneCost[comp] ) then
	
		comp = math.random( 1, self.phoneCost );
	
	end
	
	local num = 1;
	if( #self.phoneCost[comp].theNumbers > 1 )  then
	
		num = math.random( 1, #self.phoneCost[comp].theNumbers );
	
	end
	company = self.phoneCost[comp].theNumbers[num];
	
	local newNum = 50000000 + ( company * 1000000 ) + math.random( 10000 );
	
	while( self.fastNumbers[newNum] ) do
	
		newNum = 50000000 + ( company * 1000000 ) + math.random( 10000 );
	
	end

	local query = "INSERT INTO ph_simcard(id, companyId, sNumber) VALUES( NULL, '" ..
		comp .. "', '" ..
		newNum .. "' )";
	local newId = tonumber( exports.phoenix_Base:DoSimpleQuery( query, true ) );
	
	outputDebugString( query .. " - " .. tostring( newId ) );	
	if( newId ) then
	
		self.allCards[newId] = { };
		self.allCards[newId].cid = comp;
		self.allCards[newId].number = newNum;
		self.allCards[newId].contacts = { };
		self.allCards[newId].sms = { };
		self.fastNumbers[newNum] = newId;
	
	end
	return newId;

end

function SimCards:InitSim( thePlayer, theSim )

	theSim = tonumber( theSim );
	if( self.allCards[theSim] ) then
	
		self.allPlayers[theSim] = thePlayer;
		triggerClientEvent( thePlayer, "onSimInfoInit", thePlayer, theSim, self.allCards[theSim].cid, self.allCards[theSim].number);
	
	end	

end

function SimCards:ContactUpdate( thePlayer, theSim )

	theSim = tonumber( theSim );
	if( self.allCards[theSim] ) then
	
		triggerClientEvent( thePlayer, "onContactsUpdate", thePlayer, self.allCards[theSim].contacts);
	
	end

end

function SimCards:AddContact( thePlayer, theSim, theName, theNumber )

	theSim = tonumber( theSim );
	if( self.allCards[theSim] ) then
	
		local tbl = { };
		
		tbl.name = theName;
		tbl.number = theNumber;
		tbl.inSql = false;
		
		table.insert(self.allCards[theSim].contacts, tbl);
		
		self:SaveSingle( self.allCards[theSim], theSim ); -- Save to sql...
		self:ContactUpdate( thePlayer, theSim ); -- Update for client.
	
	end

end

function SimCards:DeleteContact( thePlayer, theSim, theContact )

	theSim = tonumber( theSim );
	if( self.allCards[theSim] ) then
	
		if( self.allCards[theSim].contacts[theContact] ) then
		
			self.allCards[theSim].contacts[theContact].wantDelete = true;		
			self:SaveSingle( self.allCards[theSim], theSim ); -- Force delete from sql...
			self:ContactUpdate( thePlayer, theSim ); -- Update for client.
		
		end
	
	end

end

function SimCards:ClearSingleSmsLog( thePlayer, theSim, smsId )

	theSim = tonumber( theSim );
	smsId = tonumber( smsId );
	
	if( self.allCards[theSim] ) then
	
		if( self.allCards[theSim].sms[smsId] ) then
		
			self.allCards[theSim].sms[smsId].wantDelete = true;
			self:SaveSingle( self.allCards[theSim], theSim );
			self:SmsUpdate( thePlayer, theSim );
		
		end
	
	end

end

function SimCards:SingleSmsUpdate( thePlayer, theSim, smsId )

	theSim = tonumber( theSim );
	smsId = tonumber( smsId );
	
	if( self.allCards[theSim] ) then
	
		if( self.allCards[theSim].sms[smsId] ) then
		
			self.allCards[theSim].sms[smsId].read = 1;
			self:SaveSingle( self.allCards[theSim], theSim );
			self:SmsUpdate( thePlayer, theSim );
		
		end
	
	end

end

function SimCards:ClearSmsLog( thePlayer, theSim )

	theSim = tonumber( theSim );
	if( self.allCards[theSim] ) then
	
		for k, v in pairs( self.allCards[theSim].sms ) do
		
			self.allCards[theSim].sms[k].wantDelete = true;
		
		end
		
		self:SaveSingle( self.allCards[theSim], theSim );
		self:SmsUpdate( thePlayer, theSim );
	
	end

end

function SimCards:SmsUpdate( thePlayer, theSim )

	theSim = tonumber( theSim );
	if( self.allCards[theSim] ) then
	
		triggerClientEvent( thePlayer, "onSmsUpdate", thePlayer, self.allCards[theSim].sms);
	
	end

end


function SimCards:InitCall( theCaller, theOther )

	if( theCaller == theOther or self.allCards[theCaller].inCall or self.allCards[theOther].inCall ) then
	
		triggerClientEvent( self.allPlayers[theCaller], "onSimStuffDone", self.allPlayers[theCaller], "Number Kinni!" );
	
	else
	
		self.connectingCalls[theOther] = theCaller;
	
		triggerClientEvent( self.allPlayers[theCaller], "onSimStuffDone", self.allPlayers[theCaller], "Kutsub...", true );
		triggerClientEvent( self.allPlayers[theOther], "onCallRecive", self.allPlayers[theOther], self.allCards[theCaller].number );
	
	end

end

function SimCards:CallResult( thePlayer, theSim, theResult )

	if( theResult ) then
		
		triggerClientEvent( self.connectingCalls[thePlayer], "onSimStuffDone", self.connectingCalls[thePlayer], "Keeldus!" );
	
	else
	
		self.endCall[self.connectingCalls[thePlayer]] = nil;
		self.endCall[thePlayer] = nil;
	
		local tbl = { };
		tbl.caller = self.connectingCalls[thePlayer];
		tbl.called = thePlayer;
		tbl.cTime = 0;
		tbl.cMin = 0;
		table.insert(self.allCalls, tbl);
	
		triggerClientEvent( self.connectingCalls[thePlayer], "onCallConnected", self.connectingCalls[thePlayer], tbl );
		triggerClientEvent( thePlayer, "onCallConnected", thePlayer, tbl );
	
	end
	
	self.connectingCalls[thePlayer] = nil;

end

function EndCall( theCall, reason )

	theCall = tonumber( theCall );
	if( self.allCalls[theCall] ) then
	
		if( self.allCalls[theCall].called and isElement( self.allCalls[theCall].called ) ) then
		
			triggerClientEvent( self.allCalls[theCall].called, "onCallEnd", self.allCalls[theCall], reason );
		
		end
		
		if( self.allCalls[theCall].caller and isElement( self.allCalls[theCall].caller ) ) then
		
			triggerClientEvent( self.allCalls[theCall].caller, "onCallEnd", self.allCalls[theCall], reason );
		
		end
		
		table.remove( self.allCalls, theCall );
	
	end

end

function SimCards:CallHandlers( )

	local del = { };

	if( not self.allCalls ) then self.allCalls = { }; end
	
	for k, v in ipairs( self.allCalls ) do
	
		if( not isElement( v.called ) or getElementType( v.called ) ~= "player" or not isElement( v.caller ) or getElementType( v.caller ) ~= "player" ) then
		
			table.insert( del, { k, "Kõne katkes!" } );
		
		elseif( self.endCall[v.called] ) then
		
			self.endCall[v.called] = nil;
			table.insert( del, { k, "Kõne lõpp!" } );
			
		elseif( self.endCall[v.caller] ) then
		
			self.endCall[v.caller] = nil;
			table.insert( del, { k, "Kõne lõpp!" } );
		
		else
		
			v.cTime = v.cTime + 1;
			self.allCalls[k].cTime = v.cTime;
			
			v.cMin = math.floor( ( v.cTime / 60 ) ) 
			
			if( v.cMin >  v.pTime ) then
			
				local times = v.cMin - v.pTime;				
				self.allCards[v.callerSim].credit = self.allCards[v.callerSim].credit - ( self.phoneCost[self.allCards[v.callerSim].cid].callMin * times );
				
				if( self.allCards[v.callerSim].credit < self.phoneCost[self.allCards[v.callerSim].cid].callMin ) then
				
					table.insert( del, { k, "Ettemaksu viga!" } );
				
				end
				v.pTime = v.cMin;
			
			end
		
		end
	
	end
	
	for k, v in ipairs( del ) do
	
		self:EndCall( v[1], v[2] );
	
	end

end

function SimCards:CallSomeone( thePlayer, theSim, theNumber )

	theSim = tonumber( theSim );
	local success = "Ühenduse viga!" .. theSim;
	
	if( self.allCards[theSim] ) then
	
		if( self.allCards[theSim].credit < self.phoneCost[self.allCards[theSim].cid].callMin ) then
		
			success = "Ettemaksu viga!";
		
		elseif( self.fastNumbers[theNumber] ) then
		
			if( self.allPlayers[self.fastNumbers[theNumber]] ) then
			
				success = "Ühendan...";
				triggerClientEvent( thePlayer, "onSimStuffDone", thePlayer, success, true );
				
				self:InitCall( theSim, self.fastNumbers[theNumber] );
				return 
			
			else
			
				success = "Number\n on \n levist väljas!";
			
			end
		
		else
		
			success = "Number ei eksisteeri!";
		
		end
	
	end
	triggerClientEvent( thePlayer, "onSimStuffDone", thePlayer, success );

end

function SimCards:SendSms( thePlayer, theSim, contactId, smsBody )

	theSim = tonumber( theSim );
	local success = "Ühenduse viga!" .. theSim;
	
	if( self.allCards[theSim] ) then
	
		if( self.allCards[theSim].credit < self.phoneCost[self.allCards[theSim].cid].sms ) then
		
			success = "Ettemaksu viga!";
		
		elseif( self.allCards[theSim].contacts[contactId] ) then
		
			if( self.fastNumbers[self.allCards[theSim].contacts[contactId].number] ) then
			
				local tbl = { };	
				
				tbl.id = nil;
				tbl.number = self.allCards[theSim].number;
				tbl.text = smsBody;
				tbl.read = 0;
				tbl.inSql = false;
				
				self.allCards[theSim].credit = self.allCards[theSim].credit - self.phoneCost[self.allCards[theSim].cid].sms;
				
				table.insert(self.allCards[self.fastNumbers[self.allCards[theSim].contacts[contactId].number]].sms, tbl);
				
				if( self.allPlayers[self.fastNumbers[self.allCards[theSim].contacts[contactId].number]] ) then
				
					triggerClientEvent( self.allPlayers[self.fastNumbers[self.allCards[theSim].contacts[contactId].number]], "onSmsRecive", self.allPlayers[self.fastNumbers[self.allCards[theSim].contacts[contactId].number]]);
					self:SaveSingle( self.allCards[self.fastNumbers[self.allCards[theSim].contacts[contactId].number]], self.fastNumbers[self.allCards[theSim].contacts[contactId].number] );
					self:SmsUpdate( self.allPlayers[self.fastNumbers[self.allCards[theSim].contacts[contactId].number]], self.fastNumbers[self.allCards[theSim].contacts[contactId].number] );
					success = "Saadetud!(1)";
				
				else
				
					self:SaveSingle( self.allCards[self.fastNumbers[self.allCards[theSim].contacts[contactId].number]], self.fastNumbers[self.allCards[theSim].contacts[contactId].number] );
					success = "Saadetud!(0)";
				
				end
			
			else
			
				success = "Number ei eksisteeri!";
			
			end
		
		else
		
			success = "Vigane konktakt!";
		
		end
	
	end
	
	triggerClientEvent( thePlayer, "onSimStuffDone", thePlayer, success );

end

function SimCards:DoEvents( )

	addEvent( "onSimInfoRequest", true );
	addEventHandler( "onSimInfoRequest", getRootElement( ),
	
		function( )
		
			if( client ) then
			
				local simId = tonumber( getElementData( client, "Character.simCard" ) );
				if( simId and simId > 0 ) then
				
					self:InitSim( client, simId );
					self:ContactUpdate( client, simId );
					self:SmsUpdate( client, simId );
				
				end
			
			end
		
		end 
	
	); 
	
	addEvent( "onClearSmsLog", true );
	addEventHandler( "onClearSmsLog", getRootElement( ),
	
		function( )
		
			if( client ) then
			
				local simId = tonumber( getElementData( client, "Character.simCard" ) );
				if( simId and simId > 0 ) then
				
					self:ClearSmsLog( client, simId );
				
				end
			
			end
		
		end 
	
	); 	
	
	addEvent( "onSingleSmsUpdate", true );
	addEventHandler( "onSingleSmsUpdate", getRootElement( ),
	
		function( smsId )
		
			if( client ) then
			
				local simId = tonumber( getElementData( client, "Character.simCard" ) );
				if( simId and simId > 0 ) then
				
					self:SingleSmsUpdate( client, simId, smsId );
				
				end
			
			end
		
		end 
	
	); 	
	
	addEvent( "onClearSingleSmsLog", true );
	addEventHandler( "onClearSingleSmsLog", getRootElement( ),
	
		function( smsId )
		
			if( client ) then
			
				local simId = tonumber( getElementData( client, "Character.simCard" ) );
				if( simId and simId > 0 ) then
				
					self:ClearSingleSmsLog( client, simId, smsId );
				
				end
			
			end
		
		end 
	
	); 	
	
	addEvent( "onSmsSend", true );
	addEventHandler( "onSmsSend", getRootElement( ),
	
		function( contactId, smsBody )
		
			if( client ) then
			
				local simId = tonumber( getElementData( client, "Character.simCard" ) );
				if( simId and simId > 0 ) then
				
					self:SendSms( client, simId, contactId, smsBody );
				
				end
			
			end
		
		end 
	
	); 
	
	addEvent( "onNewContact", true );
	addEventHandler( "onNewContact", getRootElement( ),
	
		function( theName, theNumber )
		
			if( client ) then
			
				local simId = tonumber( getElementData( client, "Character.simCard" ) );
				if( simId and simId > 0 ) then
				
					self:AddContact( client, simId, theName, theNumber );
				
				end
			
			end
		
		end 
	
	); 	
	
	addEvent( "onDeleteContact", true );
	addEventHandler( "onDeleteContact", getRootElement( ),
	
		function( theContact )
		
			if( client ) then
			
				local simId = tonumber( getElementData( client, "Character.simCard" ) );
				if( simId and simId > 0 ) then
				
					self:DeleteContact( client, simId, theContact );
				
				end
			
			end
		
		end 
	
	); 
	
	addEvent( "onCallResult", true );
	addEventHandler( "onCallResult", getRootElement( ),
	
		function( theResult )
		
			if( client ) then
			
				local simId = tonumber( getElementData( client, "Character.simCard" ) );
				if( simId and simId > 0 ) then
				
					self:CallResult( client, simId, theResult );
				
				end
			
			end
		
		end 
	
	);
	
	addEvent( "onCallCancel", true );
	addEventHandler( "onCallCancel", getRootElement( ),
	
		function( )
		
			if( client ) then
			
				self.endCall[client] = true;
			
			end
		
		end 
	
	);

end


--------------------------------------------------------------
--------------------------------------------------------------
--------------------------------------------------------------
--------------------------------------------------------------
--------------------------------------------------------------
