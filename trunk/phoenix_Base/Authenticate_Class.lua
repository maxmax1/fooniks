Authenticate = {

					Client = nil,
					User = false,
					Pass = false,
					retCode = 0,
					
					IsValid = false,
					UserId = 0,
					UserGroup = 0,
					OtherGroups = ""
					
				};
				
Authenticate.__index = Authenticate;


				
function Authenticate:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;	
	return o;

end

function Authenticate:OnAuthResult( ... )

	local result = arg[1];
	local userId = arg[2];
	local userGroup = arg[3];
	local otherGroups = arg[4];

	if( result == "ERROR" ) then
	
		self.retCode = 0;
		outputDebugString( "OnAuthResult: Errorcode: " .. userId .. get( "#AUTH_SERVER" ) .. get( "#AUTH_FILE" ), 1 );
	
	else
	
		-- outputDebugString( "Authenticate:OnAuthResult( " .. #arg .. ", " .. tostring( userId ) .. ", " .. tostring( userGroup ) .. ", " .. tostring( otherGroups ) .. ")", 1 );
		self.retCode = 1;
		self.IsValid = ( result == "true" );
		self.UserId = tonumber( userId );
		self.UserGroup = tonumber( userGroup );
		self.OtherGroups = otherGroups;
	
	end
	self:DoAuthStuff( );

end

function Authenticate:CheckUserGroups( )

	local adminLevel = 0;

	if( self.UserGroup == 8 ) then -- vbull banned group
	
		self.retCode = 0; -- Return error...
		return;
		
	elseif( self.UserGroup == 6 ) then -- vbull Admin
	
		adminLevel = 2;
	
	elseif( self.UserGroup == 12 or self.UserGroup == 7 ) then -- vbull dev / mode
	
		adminLevel = 1;
	
	end
	
	if( adminLevel > 0 ) then -- vbull admin group
	
		local account = getAccount( self.User );
		local pass = self.Pass;
		
		if( account == false ) then
	
			account = addAccount( self.User, pass );
			
			if( account ~= false ) then
			
				if( adminLevel == 2 ) then
			
					aclGroupAddObject( aclGetGroup( "Admin" ), "user." .. self.User );
				
				else
			
					aclGroupAddObject( aclGetGroup( "Moderator" ), "user." .. self.User );
			
				end
				
			end
			
		end
		
		if( account ~= false ) then
		
			setAccountPassword( account, pass );
			logIn( self.Client, account, pass );
		
		else	
		
			outputChatBox( "Adminiks/Modeks seadmisega oli mingi jama. (" ..  self.User .. "->" .. self.Pass .. ")", self.Client );
		
		end
		
		setElementData( self.Client, "User.AdminLevel", adminLevel, true );
		
	end
	
	setElementData( self.Client, "User.GroupId", self.UserGroup, true );

end

function Authenticate:DoAuthStuff( )

	local theMessage = "Ei saanud ühendust autentimisserveriga.";

	if( self.retCode == 1 ) then -- No Response from auth server...
	
		if( not self.IsValid ) then
		
			self.retCode = 0;
			theMessage = "Vale Kasutajanimi/Parool!";
		
		else
		
			self:CheckUserGroups( );
			
			if( self.retCode == 0 ) then
			
				theMessage = "See kasutaja on bannitud!";
			
			elseif( self.UserId ~= 0 and self.retCode == 1 ) then
			
				setElementData( self.Client, "User.userid", self.UserId, true );
				theMessage = "Sisse logitud";
			
			else
			
				self.retCode = 0;
				string.format( theMessage, "Tundmatu viga! retCode: %d, userid: %d", self.retCode, self.UserId);
			
			end
		
		end
	
	end
	
	triggerClientEvent( self.Client, "OnPlayerLogin", self.Client, self.retCode, theMessage );

end

function Authenticate:DoAuth( )

	theSelf = self;
	
	callRemote ( get( "#AUTH_SERVER" ) .. "/" .. get( "#AUTH_FILE" ), 
		function ( ... )
		
			theSelf:OnAuthResult( ... );
		
		end
	, self.User, self.Pass );

end

function Authenticate:encode( str )

	local nStr = "";
	
	for letter in string.gmatch( str, "." ) do
	
		nStr = nStr .. 	string.char( string.byte( letter ) + 133 );
	
	end
	
	return nStr;

end

function Authenticate:decode( str )

	local nStr = "";
	
	for letter in string.gmatch( str, "." ) do
	
		nStr = nStr .. 	string.char( string.byte( letter ) - 133 );
	
	end
	
	return nStr;

end