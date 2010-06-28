-- TODO: Scroll in menus...

--[[

	Public Variables
 
	Private Variables

		int theStatus
			0 - Home - Done
			1 - Menu - Done
			2 - Ringing
			3 - In Call
			4 - New Contact - Done
			5 - Reserved
			6 - Read SMS - Done
			7 - Write SMS - Done
			8 - In Action( waiting for result from server ) - Done
			
			9 - In App
			
		int Moving
			0 - Not Moving,
			1 - Moving Up,
			2 - Going Down,
			3 - Vibrate
]]--

Phone = {
			rootElement = nil,
			player = nil,
			
			white = tocolor ( 255, 255, 255 ),
			black = tocolor ( 0, 0, 0 ),
			
			bindsDone = false,

			sx = 0,
			sy = 0,
			
			phonePosX = 0,
			phonePosY = 0,

			theStatus = 0,
			IsShowing = false,
			SmsIcon = false,
			
			Moving = 0,
			moveAmount = 0,
			
			Move = 30,
			
			imageWidth = 185,
			imageHeight = 300,
			
			screenOffX = 27,
			screenOffY = 39,
			screenWidth = 132,
			screenHeight = 126,

			ringTone = ":phoenix_Phone/ringtones/plain.mp3",
			smsTone = ":phoenix_Phone/ringtones/sms.mp3",
			
			imageSlide = 0,
			ringSlide = 0,
			
			-- Buttons
			button1 = { txt = "Ava" },
			button2 = { txt = "Menüü" },
			button3 = { txt = "Nimed" },
			btnCol = tocolor ( 0, 150, 255 ),
			btnTxt = tocolor ( 0, 0, 0 ),
			
			-- Time
			realH = 0,
			realM = 0,
			realTimer = nil,
			
			-- Menu
			lastMenu = { {1, 1} },
			
			MenuName = "Menüü",
			curMenuStyle = 0,
			SpecialId = 1,
			MenuLevel = 1,
			selItem = 1,
			theMenu = {},
			menuBackCol = tocolor ( 0, 100, 255 ),
			
			-- Input
			
			inputAcceptHandler = function ( ) end,
			handleInput = false,
			inputGui = nil,
			editTimer = nil,
			caratIndex = -1,
			SkippedRows = 0,
			
			-- TextArea
			
			txtOffset = 0,
			textAreaRealTxt = "",
			textAreaTxt = "",
		};

function Phone:new( o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	-- Init variables...
	
	self.rootElement = getRootElement( );
	self.player = getLocalPlayer( );
	
	self.imageSlide = self.imageHeight * 0.73;
	self.ringSlide = self.imageHeight * 0.60;
	
	self.sx, self.sy = guiGetScreenSize( );
	
	self.phonePosX = self.sx - 150 - self.imageWidth;
	self.phonePosY = self.sy;
	
	self.moveAmount = 0;	
	self.IsShowing = false;
	
	return o;

end

function Phone:BindsSafer( )

	if( self.inputGui and not isChatBoxInputActive( ) and not isConsoleActive( ) and not isMainMenuActive( ) and not isTransferBoxActive( ) ) then
	
		guiBringToFront( self.inputGui );
	
	elseif( not self.inputGui or not isElement( self.inputGui ) ) then
	
		if( isTimer( self.editTimer ) ) then
		
			killTimer( self.editTimer );
		
		end
	
	end

end

function Phone:HandleInput( )

	self.textAreaRealTxt = guiGetText( self.inputGui );
	
	if( #self.textAreaRealTxt > 0 ) then
	
		self.button2.txt = self.textInputLabel;
		self.button3.txt = "kustuta";
	
	else
	
		self.button2.txt = "Tagasi";
		self.button3.txt = false;
	
	end
	
	self:FormatText( );
	return true;

end

function Phone:StartInput( txt, maxlen, btnTxt )

	if( not self.inputGui ) then
	
		if( not txt ) then
		
			txt = "";
		
		end
		
		self.textInputLabel = btnTxt;
		if( not self.textInputLabel ) then self.textInputLabel = "Saada"; end
		
		self.textAreaRealTxt = txt;
		self:FormatText( );
		
		if( not maxlen ) then maxlen = 11; end
		self.inputGui = guiCreateEdit( 0, 0, 1, 1, txt, false );
		
		if( self.inputGui ) then
			
			guiEditSetMaxLength( self.inputGui, 128 );		
			guiSetInputEnabled( true );
			guiBringToFront( self.inputGui );
			guiGetVisible( self.inputGui, false );
			self.editTimer = setTimer( function ( ) self:BindsSafer( ); end, 300, 0 );
			addEventHandler( "onClientGUIChanged", self.inputGui, function ( ) self:HandleInput( ); end, false);
			
			addEventHandler( "onClientGUIAccepted", self.inputGui, function ( ) self:inputAcceptHandler( ); end );				
			
		end
	
	else
	
		if( isTimer( self.editTimer ) ) then
		
			killTimer( self.editTimer );
		
		end
		
		destroyElement( self.inputGui );
		self.inputGui = nil;
		guiSetInputEnabled( false );
	
	end	

end

function Phone:MenuMoveSelection( theMod )
	
	if( self.theMenu[self.MenuLevel] and self.theMenu[self.MenuLevel][self.selItem] ) then
	
		local newVal = self.selItem+theMod;
		if( newVal < 1 ) then
		
			newVal = #self.theMenu[self.MenuLevel];
		
		elseif( newVal > #self.theMenu[self.MenuLevel] ) then
		
			newVal = 1;
		
		end
		
		if( self.theMenu[self.MenuLevel][newVal] ) then
		
			self.selItem = newVal;
		
		end
	
	end

end

function Phone:TriggerButton( theButton )

	if( not self.IsShowing ) then
	
		return false;
	
	end
	
	if( theButton and type( theButton ) == "table" ) then
	
		if( theButton.tEvent ) then
		
		elseif( theButton.tFunc ) then
		
			theButton.tAction( );
		
		elseif( theButton.tStatus ) then
			
			self:SetStatus( theButton.tAction );
		
		end
	
	elseif( theButton == "left" and self.theStatus == 1 ) then
	
		if( self.MenuLevel ~= 0 ) then
		
			self:MenuMoveSelection( -1 );
		
		end
	
	elseif( theButton == "right" and self.theStatus == 1 ) then
	
		if( self.MenuLevel ~= 0 ) then
		
			self:MenuMoveSelection( 1 );
		
		end
		
	elseif( theButton == "left" ) then
	
		if( self.txtOffset >= 14 ) then
		
			self.txtOffset = self.txtOffset - 14;
			self:FormatText( );
		
		end
	
	elseif( theButton == "right" ) then
	
		if( self.txtOffset + 13 < #self.textAreaRealTxt ) then
			
			self.txtOffset = self.txtOffset + 14;
			self:FormatText( );
		
		end
	
	end

end

function Phone:HandleButtons( )

	local theFunc = bindKey;
	
	theFunc( "q", "up", function () self:TriggerButton( self.button1 ) end );
	theFunc( "w", "up", function () self:TriggerButton( self.button2 ) end );
	theFunc( "e", "up", function () self:TriggerButton( self.button3 ) end );
	
	theFunc( "a", "up", function () self:TriggerButton( "left" ) end );
	theFunc( "d", "up", function () self:TriggerButton( "right" ) end );

end

function Phone:MenuBack( )

	if( self.MenuLevel < 1 ) then
	
		return false;
	
	end
	
	-- First menu level...	
	if( self.MenuLevel == 1 ) then
	
		self.lastMenu = {};
		self.selItem = 0;	
		self:SetStatus( 0 );
	
	elseif( self.MenuLevel > 1 ) then
	
		self.MenuLevel = self.lastMenu[1].level;
		self.selItem = self.lastMenu[1].item;
		
		table.remove( self.lastMenu, 1 );
	
	end
	
	if( self.MenuLevel == 1 ) then
	
		self.button3.txt = "Välju";
		self.curMenuStyle = 0;
		self.MenuName = "Menüü";
	
	elseif( self.MenuLevel > 1 ) then
	
		self.button3.txt = "Tagasi";
		self.MenuName = self.theMenu[self.lastMenu[1].level][self.lastMenu[1].item].label;
	
	end	

end

function Phone:MenuSelect( )

	if( self.MenuLevel < 1 ) then
	
		return false;
	
	end

	if( self.theMenu[self.MenuLevel][self.selItem] ) then
		
		if( self.theMenu[self.MenuLevel][self.selItem].newMenu ) then
		
			if( self.theMenu[self.theMenu[self.MenuLevel][self.selItem].newMenu] ) then
			
				local tempT = { };
				tempT.level = self.MenuLevel;
				tempT.item = self.selItem;
				
				if( self.theMenu[self.MenuLevel][self.selItem].specialId ) then
				
					tempT.specialId = self.theMenu[self.MenuLevel][self.selItem].specialId;
				
				end					
				
				table.insert( self.lastMenu, 1, tempT );
				
				self.selItem = 1;
				self.MenuLevel = self.theMenu[self.lastMenu[1].level][self.lastMenu[1].item].newMenu;
				self.SpecialId = self.theMenu[self.lastMenu[1].level][self.lastMenu[1].item].specialId;
				
				if( self.theMenu[self.lastMenu[1].level][self.lastMenu[1].item].newStyle ) then
				
					self.curMenuStyle = self.theMenu[self.lastMenu[1].level][self.lastMenu[1].item].newStyle;
				
				end
			
			end
		
		elseif ( self.theMenu[self.MenuLevel][self.selItem].isAction ) then
		
			self.theMenu[self.MenuLevel][self.selItem].theAction( );
		
		end
	
	end
	
	if( self.MenuLevel > 1 ) then
	
		self.button3.txt = "Tagasi";
		self.MenuName = self.theMenu[self.lastMenu[1].level][self.lastMenu[1].item].label;
	
	elseif( self.MenuLevel == 1 ) then
	
		self.button3.txt = "Välju";
		self.curMenuStyle = 0;
		self.MenuName = "Menüü";
	
	end

end

function Phone:SmsFunc( )

	local num = self.mySim.contacts[self.SpecialId].number;

	self.textAreaLbl = "Saaja: " .. self.mySim:GetName( num );
	self.button2.txt = "Tagasi";
	self.button3.txt = false;
	self.inputAcceptHandler = function ( ) self:SendSms( ); end
	self:SetStatus( 7 );
	self:StartInput( "", 128 );

end

function Phone:DeleFunc( )

	self.mySim:DeleteContact( self.SpecialId );
	self:InitContactsMenu( );
	self:MenuBack( );

end

function Phone:ContactFunc( )

	self.textAreaLbl = "Nimi:";
	self.button2.txt = "Tagasi";
	self.button3.txt = false;
	self.inputAcceptHandler = function ( ) self:ContactFunc2( ); end
	self:SetStatus( 4 );
	self:StartInput( "", 16, "Edasi" );

end

function Phone:ContactFunc2( )

	self.textAreaRealTxt = guiGetText( self.inputGui );
	
	if( #self.textAreaRealTxt > 0 ) then
	
		self.SavedName = self.textAreaRealTxt;
		self.textAreaLbl = "Number:";
		self.button2.txt = "Tagasi";
		self.button3.txt = false;
		self.inputAcceptHandler = function ( ) self:AddContact( ); end
		self:SetStatus( 4 );
		self:StartInput( );
		self:StartInput( "", 12, "Salvesta" );
	
	else
	
		self:StartInput( );
		self:InitMenu( );
	
	end

end

function Phone:AddContact( )

	self.textAreaRealTxt = guiGetText( self.inputGui );
	
	if( not tonumber( self.textAreaRealTxt ) ) then
	
		outputChatBox( "Sisesta ainult numbreid! " );
	
	elseif( #self.textAreaRealTxt > 0 ) then
	
		self.mySim:AddContact( self.SavedName, tonumber( self.textAreaRealTxt ) );
		self:StartInput( );
		self:InitMenu( );		
	
	else
	
		self:StartInput( );
		self:InitMenu( );
	
	end

end

function Phone:InitMainMenu()

--[[
1 style 0
	1	Sõnumid => 2
	2	Kontaktid
	3	Seaded
	4	Rakendused
2 style 1
	1	Loe => 6
	2	Tühjenda Mälu 
3 style 1
	1	Kontakt 1 (etc) => 7
4 style 1
	1	Sim Kaardi Info
	2	Eemalda Sim Kaart
5 style 0
	1	Rakendus 1
	2	Rakendus 2
6
	1	SMS 1
	2	SMS 2
7
	1	Helista
	2	Saada Sõnum
	3	Kustuta
]]--

	self.theMenu[1] = { };
	
	-- Sõnumid
	self.theMenu[1][1] = { };
	self.theMenu[1][1].label = "Sõnumid";
	self.theMenu[1][1].icon = "images/icons/sms.png";
	self.theMenu[1][1].newMenu = 2;
	self.theMenu[1][1].newStyle = 1;
	
		-- Sõnumid...
		self.theMenu[2] = { };
		
		self.theMenu[2][1] = { };
		self.theMenu[2][1].label = "Loe";
		self.theMenu[2][1].newMenu = 6;
		self.theMenu[2][1].newStyle = 1;

		self.theMenu[2][2] = { };
		self.theMenu[2][2].label = "Tühjenda Mälu";
		self.theMenu[2][2].newMenu = false;
		self.theMenu[2][2].isAction = true;
		self.theMenu[2][2].theAction = function () self.mySim:ClearSms(); end;	
	
	-- Kontaktid
	self.theMenu[1][2] = { };
	self.theMenu[1][2].label = "Kontaktid";
	self.theMenu[1][2].icon = "images/icons/contacts.png";
	self.theMenu[1][2].newMenu = 3;
	self.theMenu[1][2].newStyle = 1;
	
	-- Seaded
	self.theMenu[1][3] = { };
	self.theMenu[1][3].label = "Seaded";
	self.theMenu[1][3].icon = "images/icons/tools.png";
	self.theMenu[1][3].newMenu = 4;
	
	-- Rakendused
	self.theMenu[1][4] = { };
	self.theMenu[1][4].label = "Rakendused";
	self.theMenu[1][4].icon = "images/icons/apps.png";
	self.theMenu[1][4].newMenu = 5;
	
	-- Kontakt
	self.theMenu[7] = { };
	
	self.theMenu[7][1] = { };
	self.theMenu[7][1].label = "Helista";
	self.theMenu[7][1].icon = false;
	self.theMenu[7][1].newMenu = false;
	
	self.theMenu[7][2] = { };
	self.theMenu[7][2].label = "Saada Sõnum";
	self.theMenu[7][2].icon = false;
	self.theMenu[7][2].newMenu = false;
	self.theMenu[7][2].isAction = true;
	self.theMenu[7][2].theAction = function ( ) self:SmsFunc( ); end;	
	
	self.theMenu[7][3] = { };
	self.theMenu[7][3].label = "Kustuta";
	self.theMenu[7][3].icon = false;
	self.theMenu[7][3].newMenu = false;
	self.theMenu[7][3].isAction = true;
	self.theMenu[7][3].theAction = function ( ) self:DeleFunc( ); end;	

end

function Phone:SendSms( )

	self.textAreaRealTxt = guiGetText( self.inputGui );
	
	if( #self.textAreaRealTxt > 0 ) then
	
		self.button1.txt = false;
		self.button2.txt = false;
		self.button3.txt = false;
		
		self.button1.tFunc = false;
		self.button2.tFunc = false;
		self.button3.tFunc = false;
		
		self.button1.tAction = false;
		self.button2.tAction = false;
		self.button3.tAction = false;
		
		self:SetStatus( 8 );
		self:StartInput( );
		self.mySim:SendSms( self.SpecialId, self.textAreaRealTxt );
	
	else
	
		self:StartInput( );
		self:InitMenu( );
	
	end

end

function Phone:InitContactsMenu( )

	self.theMenu[3] = nil;
	self.theMenu[3] = { };
	
	for k, v in pairs( self.mySim.contacts ) do
	
		local tempCon = { };
		tempCon.label = v.name;
		tempCon.newMenu = 7;		
		tempCon.specialId = k;
		tempCon.newStyle = 1;
		
		table.insert(self.theMenu[3], tempCon);
	
	end
	
	local tempCon = { };
	tempCon.label = "Lisa Uus";
	tempCon.newMenu = false;
	tempCon.isAction = true;
	tempCon.theAction = function ( ) self:ContactFunc( ); end;
	table.insert(self.theMenu[3], tempCon);		

end

function Phone:FormatText( )

	local i = self.txtOffset;
	if( not i ) then i = 1; end
	
	local tempT = string.sub( self.textAreaRealTxt, i );

	local txtLen = #tempT;
	if( not txtLen ) then txtLen = 0; end
	local str = "";
	
	i = 1;
	self.SkippedRows = 0;
	
	while i <= txtLen do
	
		str = str .. string.sub( tempT, i, i+13 ) .. " \n";

		if( i > 14 ) then -- Skip first go-around...
		
			self.SkippedRows = self.SkippedRows + 1;
		
		end
		i = i + 14;
		
		if( i > 60 ) then
		
			break;
		
		end
	
	end
	
	self.textAreaTxt = str;

end

function Phone:InitSmsMenu( )

	self.theMenu[6] = nil;
	self.theMenu[6] = { };
	
	local hasSome = false;
	local unRead = 0;
	
	for k, v in pairs( self.mySim.smsLog ) do
	
		local tempSms = { };
		tempSms.smsId = k;
		tempSms.label = self.mySim:GetName( v.number );
		tempSms.underline = ( v.read == 0 );
		tempSms.newMenu = false;
		
		tempSms.isAction = true;
		tempSms.theAction = 
		function ()
		
			self.button2.txt = "Kustuta";
			self.textAreaLbl = v.name;
			self.textAreaRealTxt = v.text;
			self:FormatText();
			self.mySim:SmsRead( k );
			self:SetStatus( 6 );
			
			self.button2.tAction = function ( ) self.mySim:DeleteSms( k ); self:InitMenu( ); end;
			self.button3.tAction = function ( ) self:InitMenu( ); end;
			
			--self:InitSmsMenu( );
		
		end;
		
		if( v.read ~= 1 ) then
		
			unRead = unRead + 1;
		
		end
		table.insert(self.theMenu[6], 1, tempSms);
		hasSome = true;
	
	end
	
	if( not hasSome ) then
	
		local tempSms = { };
		tempSms.label = "Pole...";
		tempSms.newMenu = false;
		table.insert(self.theMenu[6], tempSms);		
	
	end
	
	if( unRead > 0 ) then 
	
		self.SmsIcon = true;
	
	else
	
		self.SmsIcon = false;
	
	end

end

function Phone:InitMenu( )

	self:SetStatus( 1 );

	self.button2.txt = "Vali";
	self.button2.tFunc = true;
	self.button2.tAction = function ( ) self:MenuSelect( ); end;
	
	self.button3.txt = "Välju";
	self.button3.tFunc = true;
	self.button3.tAction = function ( ) self:MenuBack( ); end;
	
	--self:InitSmsMenu( );

end

function Phone:Init( )

	addEventHandler( "onClientResourceStart", self.rootElement,  

		function ()
		
			addEventHandler("onClientRender", self.rootElement, 
			
				function ( )
				
					self:OnDraw( );
				
				end
				
			);
		
		end

	);
	
	self.mySim = SimCard:new( nil, self );
	self.mySim:DoEvents( );
	
	self:InitContactsMenu( );
	self:InitSmsMenu( );
	
	self:SetStatus( 0 );
	self:InitMainMenu( );
	self:HandleButtons( );

end

function Phone:SetStatus( newStat )

	if( type( newStat ) == "number" ) then
	
		self.theStatus = newStat;
		
		if( newStat == 0 ) then
		
			self.button1.txt = false;
			
			self.button2.txt = "Menüü";
			self.button2.tFunc = true;
			self.button2.tAction = function () self.selItem = 1; self.MenuLevel = 1; self.curMenuStyle = 0; self:InitMenu( ); end;
			
			self.button3.txt = false;
			self.button3.tFunc = false;
			self.button3.tAction = nil;
			self.selItem = 0;
			self.MenuLevel = 0;
			self.curMenuStyle = 0;
		
		end
	
	end

end

function Phone:DrawPhone( )

	-- Draw the phone
	dxDrawImage( self.phonePosX, self.phonePosY, self.imageWidth, self.imageHeight, ":phoenix_Phone/images/mobla.png", 0, 0, 0, tocolor( 255, 255, 255 ), true  );

end

function Phone:DrawMenu( )

	local screenX = self.phonePosX + self.screenOffX;
	local screenY = self.phonePosY + self.screenOffY;

	if( self.curMenuStyle == 1 ) then
	
		dxDrawText(
			self.MenuName,
			screenX + 3,
			screenY + 15,
			screenX + self.screenWidth,
			screenY + 33,
			self.btnTxt,
			1,
			"default-bold",
			"left",
			"top",
			true,
			false,
			true
		);
		
		local currentX = screenX + 5;
		local currentY = screenY + 33;
		local elementW = self.screenWidth - 10;
		local elementH = 20;
		
		for k, v in ipairs( self.theMenu[self.MenuLevel] ) do
		
			if( k == self.selItem ) then
			
				dxDrawRectangle( currentX, currentY, elementW, elementH, self.menuBackCol, true );
			
			end
			
			dxDrawText( 
				v.label, 
				currentX+5, 
				currentY+2, 
				currentX+5+elementW, 
				currentY+2+elementH,
				self.btnTxt,
				1,
				"default-bold",
				"left",
				"top",
				true,
				false,
				true
			); 
			
			
			if( v.underline ) then
			
				local textW = dxGetTextWidth( v.label, 1, "default-bold" );
				local textH = dxGetFontHeight( 1, "default-bold" );
				dxDrawLine( currentX+3, currentY+3+textH, currentX+3+textW, currentY+3+textH, self.btnTxt, 1, true );
			
			end
			
			currentY = currentY + elementH + 3;
		
		end
	
	else
	
		dxDrawText(
			self.theMenu[self.MenuLevel][self.selItem].label,
			screenX + 3,
			screenY + 15,
			screenX + self.screenWidth,
			screenY + 33,
			self.btnTxt,
			1,
			"default-bold",
			"left",
			"top",
			true,
			false,
			true
		);

		local currentX = screenX + 5;
		local currentY = screenY + 33;
		local inCurrentRow = 0;
		local buttonImgSize = ( self.screenWidth - ( 5 * 4 ) ) / 3;
		
		for k, v in ipairs( self.theMenu[self.MenuLevel] ) do
		
			if( k == self.selItem ) then
			
				dxDrawRectangle( currentX-2, currentY-2, buttonImgSize+4, buttonImgSize+4, self.menuBackCol, true );
			
			end	
			dxDrawImage( currentX, currentY, buttonImgSize, buttonImgSize, v.icon, 0, 0, 0, tocolor( 255, 255, 255 ), true  );
			
			currentX = currentX + buttonImgSize + 5;
			inCurrentRow = inCurrentRow + 1;
			if( inCurrentRow > 2 ) then
			
				inCurrentRow = 0;
				currentX = screenX + 5;
				currentY = currentY + buttonImgSize + 5;
			
			end
		
		end
	end
end

function Phone:DrawConnection( baseX, baseY, height, width, amount )

	if( not amount or amount < 1 ) then amount = 0;
	elseif( amount > 5 ) then amount = 5; end
	
	local i = 0;
	local elemH = 0.6;
	local elemW = ( width - 10 ) / 5;
	
	for i=0,4,1 do
	
		local elemY = baseY + (height - ( height * elemH ) );
		if( i == 4 ) then elemY = elemY - 1; end 
		
		if( amount > 0 ) then
		
			dxDrawRectangle( baseX, elemY, elemW, height * elemH, self.menuBackCol, true );
		
		else
		
			dxDrawRectangle( baseX, elemY, elemW, height * elemH, self.white, true );
		
		end
	
		baseX = baseX + elemW + 2;
		elemH = elemH + 0.1;
		amount = amount - 1;
	
	end

end

function Phone:DrawTime( )

	local clockStr = string.format( "%02d:%02d", self.realH, self.realM );
		
	local baseX = self.phonePosX + self.screenOffX + self.screenWidth - ( self.screenWidth / 3 );
	local baseX2 = self.phonePosX + self.screenOffX + self.screenWidth - 2;
	local baseY = self.phonePosY + self.screenOffY + 2;
	
	if( self.SmsIcon ) then
	
		dxDrawImage( baseX - ( self.screenWidth / 3 ) - 9, baseY-1, 20, 20, ":phoenix_Phone/images/sms1.png", 0, 0, 0, tocolor( 255, 255, 255 ), true );
	
	end
	
	self:DrawConnection( self.phonePosX + self.screenOffX + 3, baseY + 3, 12, 30, 3 );
	
	dxDrawText( clockStr, baseX, baseY, baseX2, baseY+20, self.btnTxt, 1, "default-bold", "right", "top", true, false, true );

end

function Phone:DrawButtons( )

	local baseX = self.phonePosX + self.screenOffX;
	local baseY = self.phonePosY + self.screenHeight + 25;
	local baseW = ( self.screenWidth / 3 );
	local baseH = 15;
	
	-- Init button and store x1 and x2 positions...
	if( not self.button1.Calc or self.Moving == 3 ) then
	
		self.button1.Calc = true;
		self.button1.x1 = self.phonePosX + self.screenOffX + 2;
		self.button1.x2 = self.phonePosX + self.screenOffX + 2 + ( self.screenWidth * 0.35 );
		-- if( not self.button1.txt ) then self.button1.txt = "Ava"; end
	
	end
	
	if( not self.button2.Calc or self.Moving == 3 ) then
	
		self.button2.Calc = true;
		self.button2.x1 = self.phonePosX + self.screenOffX;
		self.button2.x2 = self.phonePosX + self.screenOffX + self.screenWidth;
		-- if( not self.button2.txt ) then self.button2.txt = "Menüü"; end
	
	end	
	
	if( not self.button3.Calc or self.Moving == 3 ) then
	
		self.button3.Calc = true;
		self.button3.x1 = self.phonePosX + self.screenOffX + self.screenWidth - baseW - 4;
		self.button3.x2 = self.phonePosX + self.screenOffX + self.screenWidth - 2;
		-- if( not self.button3.txt ) then self.button3.txt = "Nimed"; end
	
	end
	
	if( self.button1.txt ) then

		dxDrawText( self.button1.txt, self.button1.x1, baseY+3.5, self.button1.x2, baseY+baseH, self.btnTxt, 0.8, "default-bold", "left", "top", true, false, true );
	
	end
	
	if( self.button2.txt ) then

		dxDrawText( self.button2.txt, self.button2.x1, baseY+0.5, self.button2.x2, baseY+baseH, self.btnTxt, 1, "default-bold", "center", "top", true, false, true );
	
	end
	
	if( self.button3.txt ) then

		dxDrawText( self.button3.txt, self.button3.x1, baseY+3.5, self.button3.x2, baseY+baseH, self.btnTxt, 0.8, "default-bold", "right", "top", true, false, true );
	
	end

end

function Phone:OnShown( ) -- When phone is Shown

	--self:InitContactsMenu( );
	--self:InitSmsMenu( );

	toggleAllControls( false );
	self:PhoneRealTime( );
	self.realTimer = setTimer( function () self:PhoneRealTime( ) end, 3000, 0 );

end

function Phone:OnHidden( ) -- When phone is Hidden

	toggleAllControls( true );
	
	if( self.realTimer ) then
	
		killTimer( self.realTimer );
		self.realTimer = nil;
	
	end

end

function Phone:OnMove( )

	if( self.Moving == 1 or self.Moving == 2 ) then
		
		self.phonePosY = self.phonePosY + self.moveAmount;
		
		if( self.Moving == 1 and self.phonePosY <= self.sy - self.imageSlide ) then
		
			self.Moving = 0;
			self.moveAmount = 0;
			self.phonePosY = self.sy - self.imageSlide;
			self:OnShown( );
		
		elseif( self.Moving == 2 and self.phonePosY >= self.sy ) then
		
			self.Moving = 0;
			self.moveAmount = 0;
			self.phonePosY = self.sy;
			self:OnHidden( );
			self.IsShowing = false;
		
		end
	
	elseif( self.Moving == 3 ) then
	
		self.phonePosX = self.phonePosX + self.moveAmount;
		self.phonePosY = self.phonePosY - self.moveAmount;
		
		self.moveAmount = self.moveAmount * -1;
	
	end

end

function Phone:Toggle( fast )

	self:ShowHide( not self.IsShowing, fast );

end

function Phone:Vibrate( isCall )

	if( isCall ) then
	
		triggerServerEvent( "onSyncRingTone", player, ringTone );
	
	else
	
		triggerServerEvent( "onSyncRingTone", self.player, self.smsTone, 3000 );
	
	end
	
	if( not self.IsShowing ) then
	
		self:ShowHide( true, true );
		self.moveAmount = 1;
		self.Moving = 3;
	
	end

end

function Phone:ShowHide( show, fast )

	if( show ) then
	
		self.IsShowing = true;
		
		if( fast ) then
		
			self.phonePosX = self.sx - 150 - self.imageWidth;
			self.phonePosY = self.sy - self.imageSlide;
			self:OnShown( );
		
		else
		
			self.Moving = 1;
			self.moveAmount = -1 * self.Move;
		
		end
	
	else
	
		if( fast ) then
		
			self.phonePosX = self.sx - 150 - self.imageWidth;
			self.phonePosY = sy;
			self:OnHidden( );
			self.IsShowing = false;
		
		else
		
			self.Moving = 2;
			self.moveAmount = self.Move;
		
		end
	
	end

end

function Phone:IncomingCall( theName )

	self.textAreaLbl = "Helistab:";
	self.textAreaRealTxt = "\t" .. theName;
	self.FormatText( );
	self:SetStatus( 2 );
	
	self.button1.txt = "Vasta";
	self.button2.txt = false;
	self.button3.txt = "Keeldu";

end

function Phone:OnDraw( )

	if( self.IsShowing ) then
	
		if( self.Moving ~= 0 ) then
		
			self:OnMove();
		
		end
		
		-- Draw Screen background...
		
		if( self.theStatus == 0 or self.mySim.simId == -1 ) then
		
			dxDrawImage( self.phonePosX + self.screenOffX, self.phonePosY + self.screenOffY, self.screenWidth, self.screenHeight, ":phoenix_Phone/images/screenpic_2.png", 0, 0, 0, tocolor( 255, 255, 255 ), true );
		
		else
		
			dxDrawImage( self.phonePosX + self.screenOffX, self.phonePosY + self.screenOffY, self.screenWidth, self.screenHeight, ":phoenix_Phone/images/screenpic_1.png", 0, 0, 0, tocolor( 255, 255, 255 ), true );

			if( self.theStatus == 1 ) then
			
				self:DrawMenu( );
			
			elseif( self.theStatus == 2 or self.theStatus == 4 or self.theStatus == 6 or self.theStatus == 7 or self.theStatus == 8 ) then
			
				if( self.theStatus == 8 ) then
				
					self.textAreaLbl = "Töös:";
					self.textAreaRealTxt = self.mySim.Result;
					self:FormatText( );
					
					if( self.mySim.gotResult ) then
					
						self.mySim.gotResult = false;
						setTimer( function ( ) self:InitMenu( ); end, 1500, 1 );
					
					end
				
				end
			
				dxDrawRectangle(
					
					self.phonePosX + self.screenOffX + 5,
					self.phonePosY + self.screenOffY + 17,
					self.screenWidth - 10,
					self.screenHeight - 35,
					self.menuBackCol,
					true
				
				);
				
				if( self.textAreaLbl ) then
				
					dxDrawText( 
						self.textAreaLbl, 
						self.phonePosX + self.screenOffX + 10, 
						self.phonePosY + self.screenOffY + 20, 
						self.phonePosX + self.screenOffX + self.screenWidth - 20,
						self.phonePosY + self.screenOffY + 35,
						self.btnTxt,
						1,
						"default-bold",
						"left",
						"top",
						true,
						false,
						true
					); 	
				
				end
				
				local txt = self.textAreaTxt;
				
				if( self.inputGui ) then
				
					local cIndex = guiGetProperty( self.inputGui, "CaratIndex" );
					cIndex = cIndex + self.SkippedRows;
					txt = string.sub( txt, 1, cIndex ) .. "|" .. string.sub( txt, cIndex+1 );
				
				end		
				
				dxDrawText( 
					txt, 
					self.phonePosX + self.screenOffX + 10, 
					self.phonePosY + self.screenOffY + 35, 
					self.phonePosX + self.screenOffX + self.screenWidth - 20,
					self.phonePosY + self.screenOffY + 35 + self.screenHeight - 25,
					self.btnTxt,
					1,
					"default",
					"center",
					"top",
					true,
					false,
					true
				); 				
			
			end		
		end
		
		if( self.mySim.simId == -1 ) then
		
			dxDrawRectangle(
				
				self.phonePosX + self.screenOffX + 5,
				self.phonePosY + self.screenOffY + 17,
				self.screenWidth - 10,
				self.screenHeight - 35,
				self.menuBackCol,
				true
			
			);
			
			dxDrawText( 
				"Puudub SIM!\n Kas soovid avada\n taskud?", 
				self.phonePosX + self.screenOffX + 10, 
				self.phonePosY + self.screenOffY + 35, 
				self.phonePosX + self.screenOffX + self.screenWidth - 20,
				self.phonePosY + self.screenOffY + 35 + self.screenHeight - 25,
				self.btnTxt,
				1,
				"default-bold",
				"center",
				"top",
				true,
				false,
				true
			); 
		
			self.button1.txt = false;
			self.button1.tFunc = false;
			self.button1.tAction = nil;
			
			self.button2.txt = "Ava Taskud";
			self.button2.tFunc = false;
			self.button2.tAction = nil;
			
			self.button3.txt = false;
			self.button3.tFunc = false;
			self.button3.tAction = nil;
		
		end
		
		-- Draw Buttons
		self:DrawButtons( );
		
		-- Draw Time
		self:DrawTime( );
		
		-- Draw the Phone		
		self:DrawPhone( );
	
	end

end

function Phone:PhoneRealTime( )

	self.realH, self.realM = getTime( );

end