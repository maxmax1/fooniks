--[[

SimCard ClientSide

variables:

	int simId
	int companyId
	int myNumber
	table contacts
	table smsLog

functions:

	UpdateContact( );
	UpdateSms( );
	ClearSms( );

events:

	onSimInfoInit(id, company, number); // Triggered from server once all info is set.
	
	onContactsUpdate(newTable);
	onSmsUpdate(newTable);
	
]]--

SimCard = {

	player = nil,
	
	Result = "Saadan...",
	gotResult = false,
	
	simId = -1,
	companyId = -1,
	myNumber = -1,
	
	contacts = { },
	smsLog = { },
	
	phone = nil,
	
	fastIndexes = { } -- An key => value table. Key is a contact number and Value is the index of it in contacts table.

};

function SimCard:new( o, thePhone )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	self.player = getLocalPlayer( );
	
	self.phone = thePhone;
	
	return o;

end

function SimCard:GetName( number )

	number = tonumber( number );
	if( self.fastIndexes[number] ) then
	
		return self.contacts[self.fastIndexes[number]].name;
	
	end
	
	return tostring( number );

end

function SimCard:AddContact( theName, theNumber )

	triggerServerEvent( "onNewContact", self.player, theName, theNumber );

end

function SimCard:CallSomeone( theNumber )

	triggerServerEvent( "onCallSomeone", self.player, theName, theNumber );

end

function SimCard:CallResult( theAction )

	triggerServerEvent( "onCallResult", self.player, theAction );

end

function SimCard:CallEnd( theAction )

	triggerServerEvent( "onCallCancel", self.player, theAction );

end

function SimCard:DeleteContact( theId )

	if( self.contacts[theId] ) then
	
		triggerServerEvent( "onDeleteContact", self.player, theId );
		self.contacts[theId] = nil;
	
	end

end

function SimCard:ClearSms( )

	self.smsLog = { };
	triggerServerEvent( "onClearSmsLog", self.player );
	self.phone:InitSmsMenu( );

end

function SimCard:SendSms( theId, theText )

	if( self.contacts[theId] ) then
	
		self.Result = "Saadan...";
		triggerServerEvent( "onSmsSend", self.player, theId, theText );
		self.phone:InitSmsMenu( );
	
	else
	
		outputChatBox( "Vigane konktakt!" );
	
	end

end

function SimCard:SmsRead( theId )

	if( self.smsLog[theId] ) then
	
		self.smsLog[theId].read = 1;
		triggerServerEvent( "onSingleSmsUpdate", self.player, theId );
		self.phone:InitSmsMenu( );
	
	end

end

function SimCard:DeleteSms( theId )

	self.smsLog[theId] = nil;
	triggerServerEvent( "onClearSingleSmsLog", self.player, theId );
	self.phone:InitSmsMenu( );

end

function SimCard:DoEvents( )

	addEvent( "onSimInfoInit", true );
	addEventHandler( "onSimInfoInit", self.player,
	
		function( var1, var2, var3 )
		
			self.simId = tonumber( var1 );
			self.companyId = tonumber( var2 );
			self.myNumber = tonumber( var3 );
		
		end 
	
	); 
	
	addEvent( "onContactsUpdate", true );
	addEventHandler( "onContactsUpdate", self.player,
	
		function( var1 )
		
			self.fastIndexes = { };
			
			for k, v in pairs( var1 ) do
			
				self.contacts[k] = v;
				self.fastIndexes[v.number] = k;
				self.phone:InitContactsMenu( );
			
			end
		
		end 
	
	); 
	
	addEvent( "onSmsUpdate", true );
	addEventHandler( "onSmsUpdate", self.player,
	
		function( var1 )
		
			for k, v in pairs( var1 ) do
			
				self.smsLog[k] = v;
				self.phone:InitSmsMenu( );
			
			end
		
		end 
	
	); 
	
	addEvent( "onSimStuffDone", true );
	addEventHandler( "onSimStuffDone", self.player,
	
		function( var1, var2 )
		
			self.Result = var1;
			
			if( not var2 ) then
			
				self.gotResult = true;
			
			end
			self.phone:InitSmsMenu( );
		
		end 
	
	);
	
	addEvent( "onSmsRecive", true );
	addEventHandler( "onSmsRecive", self.player,
	
		function( )
		
			self.phone:Vibrate( false );
			self.phone:InitSmsMenu( );
		
		end 
	
	);
	
	triggerServerEvent( "onSimInfoRequest", self.player ); -- Request info from server...
	
	addEvent( "onCallRecive", true );
	addEventHandler( "onCallRecive", self.player,
	
		function( theNumber )
		
			theNumber = tonumber( theNumber );
		
			self.savedName = self:GetName( theNumber );
		
			self.phone:Vibrate( true );
			self.phone:IncomingCall( self.savedName );
		
		end 
	
	);
	
	addEvent( "onCallConnected", true );
	addEventHandler( "onCallConnected", self.player,
	
		function( thePlayer, callInfo )
		
			self.phone:ConnectedCall( self.savedName, callInfo );
		
		end 
	
	);	
	
	-- NEXT UP: onCallConnected

end