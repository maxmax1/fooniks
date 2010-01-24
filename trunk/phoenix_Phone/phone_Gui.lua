-- 0, hidden, 1 - moving up, 2 up, 3 - going down, 4 - ringing, 5 - New Contact, 6 - Edit Contact, 7 - Read SMS, 8 - onCall, 9 - write SMS
local phoneStatus = 0;

local phoneMoving = 0;

local imageWidth = 185;
local imageHeight = 300;

local screenOffX = 27;
local screenOffY = 39;

local screenWidth = 132;
local screenHeight = 126;

local ringTone = ":phoenix_Phone/ringtones/plain.mp3";
local smsTone = ":phoenix_Phone/ringtones/sms.mp3";

-- Do not change...
local imageSlide = imageHeight * 0.73;
local ringSlide = imageHeight * 0.60;

local sx, sy = guiGetScreenSize( );
local phonePosY = sy;

local rootElement = getRootElement( );
local player = getLocalPlayer( );

local cMenu = 1;
local cItem = 1;
local callerName = "NULL";
local callerStatus = "NULL";
local imCaller = false;
local myTimer = false;
local myTimer2 = false;

local btn1Str = "sulge";
local btn2Str = "edasi";

local cName = "";
local cContact = 0;
local addLabel = "Number:";

local fromMenu = { };

local phoneMenu = { };

local canEdit = false;

local textOff = 0;
local mySim = false;

local cIndex = 0;
local insertText = "";
local lastText = "";
local editBox = nil;

local showSmsIcon = nil;
local iconticks = 0;

local realH = 0;
local realM = 0;

function AddMenu( id )

	phoneMenu[id] = { };
	return id;

end

function AddMenuItem( menu, name, toMenu, triggerFunc, cStatusChange, otherId )

	local tbl = { };
	tbl["name"] = name;
	tbl["toMenu"] = toMenu;
	tbl["triggerFunc"] = triggerFunc;
	tbl["cStatusChange"] = cStatusChange;
	tbl["otherId"] = otherId;
	table.insert( phoneMenu[menu], tbl );

end

function BuildMenu( )
	
	local inSim = getElementData( player, "Character.simCard" );
	
	if( inSim ~= nil and inSim ~= false ) then
	
		mySim = getSimByID( inSim );
		
		if( mySim ) then
	
			local menu = AddMenu( 1 );
			AddMenuItem( menu, "Kontaktid", 2, nil );
			AddMenuItem( menu, "SMS", 3, nil );
			AddMenuItem( menu, "Seaded", 4, nil );

			menu = AddMenu( 2 );
	
			local numContacts = 0;
			for i = 1, 15, 1 do
				
				local name = getElementData( mySim, "Contact.Name." .. i );
				if( name ~= false and name ~= "false" ) then
					
					AddMenuItem( menu, name, 6, nil, nil, i );
					numContacts = numContacts + 1;
					
				end
			
			end
			
			if( numContacts < 15 ) then
			
				AddMenuItem( menu, "Lisa Uus", nil, nil, 5 );
			
			end
		
			menu = AddMenu( 3 );
			AddMenuItem( menu, "Loe", 7, nil , nil , nil );
			AddMenuItem( menu, "Tühjenda Mälu", nil, nil );

			menu = AddMenu( 4 );
			AddMenuItem( menu, "Sim Kaardi Info", 5, nil );
			AddMenuItem( menu, "Eemalda Sim Kaart", nil, "onSimCardRemove" );
			
			local number = getElementData( mySim, "Number" );
			local comp = getElementData( mySim, "Company" );
			
			menu = AddMenu( 5 );
			AddMenuItem( menu, "Number: " .. number, nil, nil );
			AddMenuItem( menu, "FirmaNimi: " .. comp, nil, nil );
			
			menu = AddMenu( 6 );
			AddMenuItem( menu, "Helista", nil, nil );
			AddMenuItem( menu, "SMS", nil, nil, 9 );
			AddMenuItem( menu, "Muuda", nil, nil, 6 );
			AddMenuItem( menu, "Kustuta", nil, nil, nil, true );
			
			menu = AddMenu( 7 );
			local numSMS = 0;
			local unRead = 0;
			
			for i = 1, 15, 1 do
				
				local name = getElementData( mySim, "SMS.Name." .. i );
				if( name ~= false and name ~= "false" ) then
					
					local readed = getElementData( mySim, "SMS.Read." .. i );
					
					if( readed and ( readed ~= "1" and readed ~= 1 ) ) then
					
						name = name .. " - Uus";
						unRead = unRead + 1;
					
					end
					
					AddMenuItem( menu, name, nil, nil, 7, i );
					numSMS = numSMS + 1;
					
				end
			
			end	
			
			if( unRead > 0 ) then
			
				showSmsIcon = true;
				
			else
			
				showSmsIcon = nil;
			
			end
			
			if( numSMS < 1 ) then
			
				AddMenuItem( menu, "Pole...", nil, nil, nil, nil );
			
			end
			
			menu = AddMenu( 8 );
			AddMenuItem( menu, "Kustuta", nil, nil, nil, true );
			
			return true;
			
		end
		
	end
	
	local menu = AddMenu( 1 );	
	AddMenuItem( menu, "Sisestage SIM kaart", nil, nil );
	return false;

end

function SmsIconStatus( stat )

	showSmsIcon = stat;

end

addEventHandler( "onClientResourceStart", rootElement,  

	function ()
	
		BuildMenu( );
		setTimer( PhoneRealTime, 3000, 0 );
		
		addEventHandler("onClientRender", rootElement, 
		
			function ()
			
				local xPos = sx - 150 - imageWidth;
			
				if( phoneStatus ~= 0 ) then
				
					if( phoneMoving ~= 0 or phoneStatus == 4 ) then
					
						phonePosY = phonePosY + phoneMoving;
						
						if( phoneStatus == 1 ) then -- sliding up
						
							if( phonePosY <= sy - imageSlide ) then
							
								phonePosY = sy - imageSlide;							
								phoneMoving = 0;
								phoneStatus = 2;
								cItem = 1;
								toggleAllControls( false );
							
							end
						
						elseif( phoneStatus == 3 ) then -- going down
						
							if( phonePosY >= sy ) then 
							
								phonePosY = sy;
								phoneMoving = 0;
								phoneStatus = 0;
								toggleAllControls( true );
								
							end
						
						elseif( phoneStatus == 4 ) then
													
							if( phonePosY <= sy - ringSlide ) then
							
								phoneMoving = 0;
							
							end
							
							phonePosY = phonePosY + math.random(-1, 1);
							
							if( not imCaller ) then
							
								xPos = xPos + math.random(-1, 1);							
							
							end
							
						end
						
					end
					
					-- Screen background...
					dxDrawImage( xPos + screenOffX, phonePosY + screenOffY, screenWidth, screenHeight, ":phoenix_Phone/images/screenpic_1.png" );
					
					if( phoneStatus == 2 ) then
						
						local baseX = sx - 150 - imageWidth + screenOffX + 5;
						local baseY = phonePosY + screenOffY + 15;
						local baseW = screenWidth - 10;
						local baseH = 20;
						
						local hidden = 0;
						
						if( cItem > 4 ) then 
						
							hidden = cItem - 4;
							baseY = baseY - ( 20 * (cItem - 4 - hidden) );
							
						end
												
						for k,v in ipairs( phoneMenu[cMenu] ) do
						
							if( hidden < 1 ) then
							
								local col;
							
								if( cItem ~= k ) then 
								
									col = tocolor ( 0, 100, 255 );
								
								else
								
									col = tocolor ( 0, 150, 255 );
								
								end
							
								dxDrawRectangle( baseX, baseY, baseW, baseH, col );	
								dxDrawText( v["name"], baseX+10, baseY+3, nil, nil, tocolor( 0, 0, 0 ) );
								
								baseY = baseY + 25;
							
							else
							
								hidden = hidden - 1;
							
							end
						
						end
						
					elseif( phoneStatus == 4 ) then
					
						local baseX = sx - 150 - imageWidth + screenOffX + 5;
						local baseY = phonePosY + screenOffY + 10;
						local baseW = screenWidth - 10;
						local baseH = 100;		
					
						dxDrawRectangle( baseX, baseY, baseW, baseH, tocolor ( 0, 150, 255 ) );	
						dxDrawText( callerStatus, baseX+5, baseY+3, baseX+baseW, baseY+baseH, tocolor( 0, 0, 0 ), 1, "default-bold", "left", "top", false, true );
						dxDrawText( callerName, baseX+15, baseY+20, baseX+baseW, baseY+baseH, tocolor( 0, 0, 0 ), 1, "default", "left", "top", true, true );
						
					elseif( phoneStatus == 5 or phoneStatus == 6 ) then
					
						local baseX = sx - 150 - imageWidth + screenOffX + 5;
						local baseY = phonePosY + screenOffY + 10;
						local baseW = screenWidth - 10;
						local baseH = 40;	
					
						dxDrawRectangle( baseX, baseY, baseW, baseH, tocolor ( 0, 150, 255 ) );	
						dxDrawText( addLabel, baseX+5, baseY+3, baseX+10+baseW, nil, tocolor( 0, 0, 0 ), 1, "default-bold", "left", "top", false, true );
						
						if( editBox ) then
						
							cIndex = guiGetProperty( editBox, "CaratIndex" );							
							
						end
						local txt = string.sub( insertText, 1, cIndex ) .. "|" .. string.sub( insertText, cIndex+1 );
						dxDrawText( txt, baseX+15, baseY+20, baseX+10+baseW, nil, tocolor( 0, 0, 0 ), 1, "default-bold", "left", "top", false, true );
						
					elseif( phoneStatus == 7 ) then
					
						local baseX = sx - 150 - imageWidth + screenOffX + 5;
						local baseY = phonePosY + screenOffY + 10;
						local baseW = screenWidth - 10;
						local baseH = 100;	
					
						if( addLabel == false or addLabel == "false" ) then
						
							addLabel = getElementData( mySim, "SMS.Name." .. cContact );
							insertText = getElementData( mySim, "SMS.Text." .. cContact );
						
						end
						
						local rText = insertText;
						local skipLines = math.floor( textOff / -5 );
						
						local tempT = textOff;
						
						if( skipLines > 0 ) then
						
							local modifier = 15;
							rText = string.sub( insertText, skipLines*modifier );
							tempT = tempT + ( skipLines*5 );
						
						end
					
						dxDrawRectangle( baseX, baseY, baseW, baseH, tocolor ( 0, 150, 255 ) );	
						dxDrawText( addLabel, baseX+5, baseY+3, baseX+baseW, baseY+baseH, tocolor( 0, 0, 0 ), 1, "default-bold", "left", "top", false, true );
						dxDrawText( rText, baseX+15, baseY+20+tempT, baseX+baseW, baseY+baseH, tocolor( 0, 0, 0 ), 1, "default", "left", "top", true, true );
						
					elseif( phoneStatus == 8 ) then
					
						local baseX = sx - 150 - imageWidth + screenOffX + 5;
						local baseY = phonePosY + screenOffY + 10;
						local baseW = screenWidth - 10;
						local baseH = 100;		
					
						local seconds = callerName % 60;
						local minutes = ( callerName - seconds ) / 60;
						local timeStr = string.format( "%02d:%02d", minutes, seconds );
					
						dxDrawRectangle( baseX, baseY, baseW, baseH, tocolor ( 0, 150, 255 ) );	
						dxDrawText( callerStatus, baseX+5, baseY+3, baseX+baseW, baseY+baseH, tocolor( 0, 0, 0 ), 1, "default-bold", "left", "top", false, true );
						dxDrawText( timeStr, baseX+15, baseY+20, baseX+baseW, baseY+baseH, tocolor( 0, 0, 0 ), 1, "default", "left", "top", true, true );
					
					elseif( phoneStatus == 9 ) then
					
						local baseX = sx - 150 - imageWidth + screenOffX + 5;
						local baseY = phonePosY + screenOffY + 10;
						local baseW = screenWidth - 10;
						local baseH = 100;	
					
						if( addLabel == false or addLabel == "false" ) then
						
							addLabel = getElementData( mySim, "Contact.Name." .. cContact );
						
						end
						
						local rText = insertText;
						local startAt = 1;
												
						if( editBox ) then
						
							cIndex = tonumber( guiGetProperty( editBox, "CaratIndex" ) );
							
						end
						
						if( cIndex > 64 ) then
						
							startAt = cIndex - 64;
						
						end
						
						local txt = string.sub( rText, startAt, cIndex ) .. "|" .. string.sub( rText, cIndex+1 );
					
						dxDrawRectangle( baseX, baseY, baseW, baseH, tocolor ( 0, 150, 255 ) );	
						dxDrawText( addLabel, baseX+5, baseY+3, baseX+baseW, baseY+baseH, tocolor( 0, 0, 0 ), 1, "default-bold", "left", "top", false, true );
						dxDrawText( txt, baseX+15, baseY+20, baseX+baseW, baseY+baseH, tocolor( 0, 0, 0 ), 1, "default", "left", "top", true, true );
						
					
					end	
					
					-- Draw buttons:
					local baseX = sx - 155 - imageWidth + screenOffX;
					local baseY = phonePosY + screenHeight + 25;
					local baseW = ( screenWidth / 2 ) - 1;
					local baseH = 15;	
					
					dxDrawRectangle( baseX, baseY, baseW, baseH, tocolor ( 0, 150, 255 ) );	
					dxDrawText( btn1Str, baseX+7.5, baseY+0.5, baseX+5+baseW, baseY+baseH, tocolor( 0, 0, 0 ), 1, "default-bold", "left", "top", true, false );
					
					dxDrawRectangle( baseX+baseW+8, baseY, baseW, baseH, tocolor ( 0, 150, 255 ) );	
					dxDrawText( btn2Str, baseX+baseW-50, baseY+0.5, baseX+69+baseW, baseY+baseH, tocolor( 0, 0, 0 ), 1, "default-bold", "right", "top", true, false );
					
					if( showSmsIcon ) then
					
						dxDrawImage( xPos + 100, phonePosY + 43, 14.5, 10, ":phoenix_Phone/images/sms.png" );
						
						iconticks = iconticks + 1;
						
						if( iconticks > 5 ) then
							
							showSmsIcon = false;
							setTimer( SmsIconStatus, 700, 1, true );
							iconticks = 0;
							
						end
						
					end
					
					local clockStr = string.format( "%02d:%02d", realH, realM );
					
					dxDrawText( clockStr, xPos + 120, phonePosY + 40 );
					
					-- Phone background...
					dxDrawImage( xPos, phonePosY, imageWidth, imageHeight, ":phoenix_Phone/images/mobla.png" );
					
				
				end
			
			end
			
		);
		
	end
	
);

function menuUp( )

	if( phoneStatus == 2 ) then

		if( cItem > 1 ) then cItem = cItem - 1; end
		
	elseif( phoneStatus == 7 ) then
	
		if( textOff < 0 ) then
		
			textOff = textOff + 3;
			
		end
	
	end
end

function menuDwn( )

	if( phoneStatus == 2 ) then

		if( cItem < #phoneMenu[cMenu] ) then cItem = cItem + 1; end
		
	elseif( phoneStatus == 7 ) then
		
		if( textOff > -30 ) then
		
			textOff = textOff - 3;
			
		end
	
	end

end

function Entry( element )
	
	insertText = guiGetText( element );
	
	if( #insertText > 0 ) then
	
		btn1Str = "kustuta";
	
	else
	
		btn1Str = "tagasi";
	
	end
	return true;

end

function BindsSafer( )


	if( editBox and not isChatBoxInputActive( ) and not isConsoleActive( ) and not isMainMenuActive( ) and not isTransferBoxActive( ) ) then
	
		guiBringToFront( editBox );
	
	elseif( not editBox ) then
	
		if( isTimer( myTimer2 ) ) then
		
			killTimer( myTimer2 );
		
		end
	
	end

end

function BindsChange( txt, maxlen )

	if( not editBox ) then
	
		if( not txt ) then
		
			txt = "";
		else
		
			insertText = txt;
		
		end
		
		if( not maxlen ) then maxlen = 11; end
	
		editBox = guiCreateEdit( 0, 0, 1, 1, txt, false );
		
		if( editBox ) then
			
			guiEditSetMaxLength( editBox, maxlen );		
			guiSetInputEnabled( true );
			guiBringToFront( editBox );
			guiGetVisible( editBox, false );
			myTimer2 = setTimer( BindsSafer, 300, 0 );
			addEventHandler( "onClientGUIChanged", editBox, Entry, false);
			
		end
		
		addEventHandler( "onClientGUIAccepted", editBox, 
		
			function ( )
			
				if( #insertText > 0 ) then
				
					menuEnter( );
				
				else
				
					menuBack( );
				
				end
			
			end
			
		);		
	
	else
	
		if( isTimer( myTimer2 ) ) then
		
			killTimer( myTimer2 );
		
		end
		
		destroyElement( editBox );
		editBox = nil;
		guiSetInputEnabled( false );
	
	end

end

function menuEnter( )

	if( phoneStatus == 4 )  then
	
		if( not imCaller ) then
		
			triggerServerEvent( "callAccepted", player, player );
		
		end
	
	elseif( phoneStatus == 5 or phoneStatus == 6 )  then
	
		if( addLabel == "Muuda NR:" ) then
				
			addLabel = "Muuda Nimi:";
			lastText = insertText;
			insertText = "";
			
			BindsChange( );
			BindsChange( getElementData( mySim, "Contact.Name." .. cContact ) );
		
		elseif( addLabel == "Muuda Nimi:" ) then
							
			EditContact( mySim, cContact, insertText, lastText );
			lastText = "";
			insertText = "";
			addLabel = "Number:";						
			BuildMenu( );
			
			phoneStatus = 2;
			
			btn1Str = "tagasi";
			btn2Str = "edasi";	
			
			BindsChange( );	
		
		elseif( addLabel == "Number:" ) then
						
			addLabel = "Nimi:";
			lastText = insertText;
			insertText = "";
			
			BindsChange( );	
			BindsChange( );	
			
		else
			
			AddContact( mySim, insertText, lastText );
			lastText = "";
			insertText = "";
			addLabel = "Number:";
			phoneStatus = 2;
			
			btn1Str = "tagasi";
			btn2Str = "edasi";
			
			BuildMenu( );
			BindsChange( );	
		
		end
		
		return false;
		
	elseif( phoneStatus == 7 ) then
	
		phoneStatus = 2;
		cMenu = 8;
		cItem = 1;
		btn1Str = "tagasi";
		btn2Str = "edasi";
		
		return true;
	
	elseif( phoneStatus == 9 ) then
	
		-- TODO: Send THIS SHIT!
		triggerServerEvent( "onSmsSend", player, player, getElementData( mySim, "Contact.Nr." .. cContact ), insertText );
		insertText = "Saadan...";
		
		BindsChange(  );
		cMenu = 1;
		cItem = 1;
		btn1Str = "tagasi";
		btn2Str = "edasi";
		return 1;
	
	end

	if( phoneMenu[cMenu][cItem]["cStatusChange"] ~= nil ) then
		
		if( phoneMenu[cMenu][cItem]["cStatusChange"] == 5 or phoneMenu[cMenu][cItem]["cStatusChange"] == 6 ) then
		
			if( phoneMenu[cMenu][cItem]["cStatusChange"] == 5 ) then
		
				addLabel = "Number:";
				BindsChange( );	
				
			else
			
				addLabel = "Muuda NR:";
				BindsChange( getElementData( mySim, "Contact.Nr." .. cContact ) );
			
			end
		
			
			btn1Str = "tagasi";
			btn2Str = "salvesta";
			canEdit = true;
			
		elseif( phoneMenu[cMenu][cItem]["cStatusChange"] == 7 ) then
		
			addLabel = getElementData( mySim, "SMS.Name." .. cContact );
			insertText = getElementData( mySim, "SMS.Text." .. cContact );
			textOff = 0;
			btn1Str = "tagasi";
			btn2Str = "valikud";
			
			local readed = getElementData( mySim, "SMS.Read." .. cContact );
			if( readed and ( readed ~= "1" and readed ~= 1 ) ) then
			
				setElementData( mySim, "SMS.Read." .. cContact, "1" );
			
			end
			
			canEdit = false;		
		
		elseif( phoneMenu[cMenu][cItem]["cStatusChange"] == 9 ) then
		
			addLabel = getElementData( mySim, "Contact.Name." .. cContact );
			BindsChange( "", 128 );
		
		end
		
		phoneStatus = phoneMenu[cMenu][cItem]["cStatusChange"];
	
	end
	
	if( phoneMenu[cMenu][cItem]["otherId"] == true ) then
	
		if( cMenu == 8 ) then
			
			RemoveSMS( mySim, tonumber( cContact ) );			
			BuildMenu( );
			
			phoneStatus = 2;
			menuBack( );
		
		else
		
			RemoveContact( mySim, tonumber( cContact ) );			
			BuildMenu( );
			menuBack( );
		
		end
	
	elseif( phoneMenu[cMenu][cItem]["otherId"] ~= nil ) then
	
		cContact = phoneMenu[cMenu][cItem]["otherId"];
	
	end
	
	if( phoneMenu[cMenu][cItem]["name"] == "Helista" ) then
		
		PhoneRinging( "Helistan: ", getElementData( mySim, "Contact.Name." .. cContact ), true );
		triggerServerEvent( "onCallStart", player, player, getElementData( mySim, "Contact.Nr." .. cContact ) );
	
	end	

	if( phoneMenu[cMenu][cItem]["toMenu"] ~= nil ) then
	
		local tbl = { };
		tbl["menu"] = cMenu;
		tbl["pos"] = cItem;	
		table.insert( fromMenu, 1, tbl );
		
		cMenu = phoneMenu[cMenu][cItem]["toMenu"];
		cItem = 1;
		
		if( cMenu ~= 1 ) then btn1Str = "tagasi"; end
	
	elseif( phoneMenu[cMenu][cItem]["triggerFunc"] ~= nil ) then
	
		local ret = triggerServerEvent( phoneMenu[cMenu][cItem]["triggerFunc"], player );
	
	end	
	
end

function menuBack( )

	if( phoneStatus == 4 )  then
	
		if( not imCaller ) then
		
			triggerServerEvent( "endTheCall", player, player, "keeldus", true );	
		
		else
		
			triggerServerEvent( "endTheCall", player, player, "katkestati", true );
			
		end
	
	elseif( phoneStatus == 5 or phoneStatus == 6 )  then
	
		if( canEdit ~= true or #insertText < 1 ) then
		
			btn1Str = "tagasi";
			btn2Str = "edasi";
			
			phoneStatus = 2;
			
			-- unbind both...
			BindsChange( );
			return false;
			
		end
	
		insertText = string.sub( insertText, 1, -2 );
		
		if( #insertText > 0 ) then
		
			btn1Str = "kustuta";
		
		else
		
			btn1Str = "tagasi";
		
		end	
		return true;
	
	elseif( phoneStatus == 7) then	
	
		phoneStatus = 2;
	
	elseif( phoneStatus == 8 ) then	
	
		triggerServerEvent( "endTheCall", player, player, "katkestati", true );
	
	elseif( phoneStatus == 9 ) then
	
		BindsChange(  );
		btn1Str = "tagasi";
		btn2Str = "edasi";
		phoneStatus = 2;
	
	end
	
	if( cMenu == 1 ) then
	
		PhoneShow( );
		return true;
	
	end

	if( fromMenu[1] ~= nil ) then
	
		cMenu = fromMenu[1]["menu"];
		cItem = fromMenu[1]["pos"];
		table.remove( fromMenu, 1 );
		
		if( cMenu == 1 ) then btn1Str = "sulge"; end
	
	end

end

function PhoneStatusChange( status, moving )

	phoneStatus = status;
	
	if( status == 3 and moving > 0 ) then
	
		btn1Str = "sulge";
		btn2Str = "edasi";
		
		unbindKey( "arrow_u", "up", menuUp );
		unbindKey( "arrow_d", "up", menuDwn );
		unbindKey( "arrow_r", "up", menuEnter );
		unbindKey( "arrow_l", "up", menuBack );
		triggerEvent( "givePlayerPhone", player, player, false );
	
	end
	
	if( moving ) then phoneMoving = moving; end

end

function PhoneRinging( status, caller, isCaller, cancel, fifth )

	if( phoneStatus ~= 4 and not fifth ) then
		
		if( phoneStatus == 0 ) then 
		
			phoneMoving = -30;
			
		end
		
		callerStatus = status;
		callerName = caller;
		imCaller = isCaller;

		phoneStatus = 4;
		
		if( not imCaller ) then
		
			triggerServerEvent( "onSyncRingTone", player, ringTone );
			
			btn1Str = "keeldu";
			btn2Str = "vasta";
			
			bindKey( "arrow_r", "up", menuEnter );
			bindKey( "arrow_l", "up", menuBack );
			
		else
		
			btn1Str = "katkesta";
			btn2Str = "...";
			
		end
	
	elseif( cancel ~= nil ) then
	
		unbindKey( "arrow_r", "up", menuEnter );
		unbindKey( "arrow_l", "up", menuBack );
		
		if( not imCaller ) then		
		
			triggerServerEvent( "onStopRingTone", player );
		
		end
	
		callerStatus = status;
	
		setTimer( PhoneStatusChange, 1000, 1, 3, 30 );
	
		btn1Str = "...";
		btn2Str = "...";
		
		fromMenu = { };
		cMenu = 1;
		cItem = 1;
		BuildMenu( );
		unbindKey( "arrow_u", "up", menuUp );
		unbindKey( "arrow_d", "up", menuDwn );
		unbindKey( "arrow_r", "up", menuEnter );
		unbindKey( "arrow_l", "up", menuBack );
	
	else
	
		phoneStatus = 3;
		phoneMoving = 30;
	
	end

end

addEvent( "onPhoneRingReq", true );
addEventHandler( "onPhoneRingReq", rootElement, PhoneRinging );

function PhoneShow( )

	local inSim = getElementData( player, "Character.simCard" );
	if( not inSim or inSim == 0 ) then return false; end

	if( phoneStatus == 0 ) then
		
		BuildMenu( );
		cMenu = 1;
		cItem = 1;
		phoneStatus = 1;
		phoneMoving = -30;
		
		bindKey( "arrow_u", "up", menuUp );
		bindKey( "arrow_d", "up", menuDwn );
		bindKey( "arrow_r", "up", menuEnter );
		bindKey( "arrow_l", "up", menuBack );
		
		triggerEvent( "givePlayerPhone", player, player, true );
	
	elseif( phoneStatus == 2 ) then
	
		phoneStatus = 3;
		phoneMoving = 30;
		
		unbindKey( "arrow_u", "up", menuUp );
		unbindKey( "arrow_d", "up", menuDwn );
		unbindKey( "arrow_r", "up", menuEnter );
		unbindKey( "arrow_l", "up", menuBack );
		triggerEvent( "givePlayerPhone", player, player, false );
	
	end

end

addEvent( "onPhoneShow", true );
addEventHandler( "onPhoneShow", rootElement, PhoneShow );
addCommandHandler( "telefon", PhoneShow );

function getSimByID( id )

	id = tonumber( id );
	local sims = getElementsByType( "SimCard" );
	
	for k,v in ipairs( sims ) do
	
		local tid = tonumber( getElementData( v, "SqlId" ) );
		if( tid == id ) then return v; end
	
	end
	return false;
	
end

function AddContact( element, name, number )

	for i = 1, 15, 1 do
	
		local check = getElementData( element, "Contact.Name." .. i );
		local check2 = getElementData( element, "Contact.Nr." .. i );
		if( check == false and check2 == false or check == "false" and check2 == "false" ) then
		
			setElementData( element, "Contact.Name." .. i, name );
			setElementData( element, "Contact.Nr." .. i, number );			
			setTimer( triggerServerEvent, 5000, 1, "onSimSave", rootElement, element );
			
			BuildMenu( );
			return true;
		
		end
		
	end		
	
	return false;
	
end

function getNameFromNumber( number )

	for i = 1, 15, 1 do
	
		local nr = getElementData( mySim, "Contact.Nr." .. i );
		if( nr == number ) then
		
			return getElementData( mySim, "Contact.Name." .. i );
		
		end
	
	end
	
	return false;

end

function RemoveContact( element, id )

	setElementData( element, "Contact.Name." .. id, "false" );
	setElementData( element, "Contact.Nr." .. id, "false" );
	
	setTimer( triggerServerEvent, 5000, 1, "onSimSave", rootElement, element );
	
end

function RemoveSMS( element, id )

	setElementData( element, "SMS.Name." .. id, "false" );
	setElementData( element, "SMS.Text." .. id, "false" );
	
	setTimer( triggerServerEvent, 5000, 1, "onSimSave", rootElement, element );
	
end

function EditContact( element, id, name, number )

	setElementData( element, "Contact.Name." .. id, name );
	setElementData( element, "Contact.Nr." .. id, number );
	
	setTimer( triggerServerEvent, 5000, 1, "onSimSave", rootElement, element );
	
end

addEvent( "onCallConnected", true );
addEventHandler( "onCallConnected", rootElement, 

	function ( number )
		
		if( not imCaller ) then
		
			triggerServerEvent( "onStopRingTone", player, player );
		
		else
					
			unbindKey( "arrow_u", "up", menuUp );
			unbindKey( "arrow_d", "up", menuDwn );		
			toggleAllControls( true );
		
		end
		
		local nameTest = getNameFromNumber( number );
		if( nameTest ) then
		
			number = nameTest;
		
		end
		
		btn1Str = "katkesta";
		btn2Str = "...";
		phoneStatus = 8;
		phoneMoving = 0;
		
		callerName = 0;
		callerStatus = number .. "...";
		
		myTimer = setTimer( callTime, 1000, 0 );
	
	end
	
);

addEvent( "onCallClear", true );
addEventHandler( "onCallClear", rootElement, 

	function ( )
	
		if( isTimer( myTimer ) ) then
		
			killTimer( myTimer );
			PhoneShow( );
		
		end
	
	end
	
);

function callTime( )

	if( not callerName or type( callerName ) ~= "number" ) then callerName = 0; end

	callerName = callerName + 1;

end

addEvent( "onSmsRequest", true );
addEventHandler( "onSmsRequest", rootElement, 

	function ( thePlayer, status, imSender )
	
		if( thePlayer ) then
		
			if( status ) then
			
				if( imSender ) then
				
					insertText = "õnnestus";
					
					setTimer( PhoneStatusChange, 1000, 1, 3, 30 );
				
				else
				
					triggerServerEvent( "onSyncRingTone", player, smsTone, 3000 );
					BuildMenu( );
				
				end
			
			else
			
				if( imSender ) then
				
					insertText = "ebaõnnestus";
					setTimer( PhoneStatusChange, 1000, 1, 3, 30 );
				
				end
			
			end
		
		end
	
	end
	
);

function PhoneRealTime( )

	realH, realM = getTime( );

end