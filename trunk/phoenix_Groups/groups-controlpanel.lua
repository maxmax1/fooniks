--[[ TODO: 

	* Invite someone.
	
	-- LATERZ: (Add to goals for next version)
	
	* Seamless entry + delete + reorder ( without closing window ).
	* GroupControl for admins.
		
		* Add Rank - TEHTUD
		* Del Rank - TEHTUD
		* Edit Rank - TEHTUD
		* Reorder Ranks - TEHTUD
		* Kick Member
		* Edit Member
		* Save all
]]--

local player = getLocalPlayer( );
local rootElement = getRootElement( );
local sx, sy = guiGetScreenSize( );

local groupCP = { };

-- For dataRev

local storedGroup = nil;
local storedGroupData = { };
local dataRev = 0;

local editedGroupData = { }; -- Filled when some edits are made, so we dont have to send everything at once.

--

function doSave( )

	if( dataRev < 0 ) then -- If there is a change.
	
		local rev = tonumber( getElementData( storedGroup, "dataRev" ) );	
		triggerServerEvent( "onGroupDataSave", player, storedGroup, dataRev*-1, editedGroupData );
		if( rev == dataRev*-1 ) then
		
			dataRev = rev + 1;
			outputDebugString( "Groups: doSave: dataRev UPD: " .. dataRev );
		
		end	
	
	end

end

--

function createWindow( hide )

	if( groupCP.window and isElement( groupCP.window ) ) then
	
		if( hide ) then doSave( ); end
		
		destroyElement( groupCP.window );
		groupCP.window = nil;
		showCursor( false );
		guiSetInputEnabled( false );
		if( hide ) then return; end
	
	end
	
	groupCP.window = guiCreateWindow( (sx-400)/2, (sy-350)/2, 400, 350, "", false );
	guiWindowSetMovable( groupCP.window, false );
	guiWindowSetSizable( groupCP.window, false );
	guiSetProperty( groupCP.window, "TitlebarEnabled", "False" );
	
	groupCP.closeBtn = guiCreateButton( 0.75, 0.86, 0.2, 0.15, "Sulge", true, groupCP.window ); 
	guiSetVisible( groupCP.closeBtn, true );
	
	addEventHandler("onClientGUIClick", groupCP.closeBtn, 
		function ( button, state )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			createWindow( true );
		
		end
	, false);
	
	guiSetVisible( groupCP.window, false );

end

function SetGroupControlPanelStatus( theStatus )

	guiSetEnabled( groupCP.window, theStatus );

	if( theStatus ) then
	
		guiBringToFront( groupCP.window );
	
	end

end

addCommandHandler( "liider",

	function ()
	
		createWindow( );
		createWindow( ); -- TODO: Replace this hack...
		
		local team = getPlayerTeam( player );
		if( team and team == storedGroup and dataRev == tonumber( getElementData( team, "dataRev" ) ) ) then
		
			outputDebugString( "Groups: /liider: showStored" ); 
			editedGroupData = { };
			ShowInfo( storedGroupData );
		
		elseif( team ) then
		
			outputDebugString( "Groups: /liider: triggerEvent" ); 
			triggerServerEvent( "onGroupDataInit", player );
		
		end
	end

, false, false );

function onDataLoaded( gInf )

	storedGroupData = gInf;
	storedGroup = gInf["team"];
	dataRev = gInf["dataRev"];	
	ShowInfo( storedGroupData );

end

addEvent( "onGroupDataLoaded", true );
addEventHandler( "onGroupDataLoaded", rootElement, onDataLoaded );

function ShowInfo( gInfo )

	-- Layout
	
	guiCreateStaticImage( 0.025, 0.10, 0.95, 0.005, ":phoenix_Characters/files/images/gui-white.png", true, groupCP.window );
	guiCreateStaticImage( 0.025, 0.84, 0.95, 0.005, ":phoenix_Characters/files/images/gui-white.png", true, groupCP.window );
	
	groupCP.title = guiCreateLabel( 0.025, 0.020, 0.4, 0.2, gInfo["name"], true, groupCP.window );
	guiSetFont( groupCP.title, "sa-header" );
	
	groupCP.infoL = guiCreateLabel( 0.05, 0.125, 0.4, 0.2, "Info", true, groupCP.window );
	guiSetFont( groupCP.infoL, "default-bold-small" );	
	
	groupCP.membersL = guiCreateLabel( 0.52, 0.125, 0.4, 0.2, "Liikmed", true, groupCP.window );
	guiSetFont( groupCP.membersL, "default-bold-small" );	
	
	groupCP.rankL = guiCreateLabel( 0.05, 0.390, 0.4, 0.2, "Auastmed", true, groupCP.window );
	guiSetFont( groupCP.rankL, "default-bold-small" );	
	
	guiCreateStaticImage( 0.04, 0.175, 0.44, 0.005, ":phoenix_Characters/files/images/gui-white.png", true, groupCP.window );
	guiCreateStaticImage( 0.04, 0.450, 0.44, 0.005, ":phoenix_Characters/files/images/gui-white.png", true, groupCP.window );
	guiCreateStaticImage( 0.51, 0.175, 0.44, 0.005, ":phoenix_Characters/files/images/gui-white.png", true, groupCP.window );
	
	-- Info
	
		guiCreateLabel( 0.075, 0.195, 0.4 , 0.2, "Raha: " .. gInfo["gCash"] .. " EEK", true, groupCP.window );
		guiCreateLabel( 0.075, 0.255, 0.4 , 0.2, "Liikmeid: " .. gInfo["numMemb"], true, groupCP.window );
		guiCreateLabel( 0.075, 0.315, 0.4 , 0.2, "Auastmeid: " .. gInfo["lRank"], true, groupCP.window );
	
	-- Ranks
	
	if( groupCP.rankScroll and isElement( groupCP.rankScroll ) ) then
	
		destroyElement( groupCP.rankScroll );
		groupCP.rankScroll = nil;
		groupCP.ranksAdded = false;
	
	end
	groupCP.rankScroll = guiCreateScrollPane( 0.040, 0.470, 0.435, 0.36, true, groupCP.window );
	guiScrollPaneSetScrollBars( groupCP.rankScroll, false, true );
	
	groupCP.ranks = { };
	
	local y = 8;
	
	-- Add One Rank
	
		local parentImg = guiCreateStaticImage( 5, y, 120, 24, ":phoenix_Characters/files/images/gui-lblue.png", false, groupCP.rankScroll );
		guiSetProperty( parentImg, "ZOrderChangeEnabled", "false");			
		
		local tbl = { };
		
		tbl.lblN = guiCreateLabel( 9, y+4.5, 25, 21, "Lisa:", false, groupCP.rankScroll );
		guiSetFont( tbl.lblN, "default-bold-small" );	
		
		groupCP.addRankE = guiCreateEdit( 37.5, y+1.5, 80, 21, "", false, groupCP.rankScroll );

		-- Add Btn
		
		tbl.add = guiCreateStaticImage( 128, y, 24, 24, "images/add.png", false, groupCP.rankScroll );	
		guiSetEnabled( tbl.add, false );
		guiSetAlpha( tbl.add, 0.5 );
		
		addEventHandler( "onClientGUIClick", tbl.add,
		
			function ( button, state )
			
				if( button ~= "left" or state ~= "up" ) then return false; end
				if( source ~= tbl.add ) then return false; end
				
				local txt = guiGetText( groupCP.addRankE );
				onGroupRankAdd( txt );
				BuildRanks( storedGroupData["ranks"], storedGroupData["lRank"] );
			
			end
		
		);		
		
		addEventHandler( "onClientGUIChanged", groupCP.addRankE,
		
			function ()
			
				local txt = guiGetText( groupCP.addRankE );
				if( txt and #txt > 2 ) then
				
					guiSetEnabled( tbl.add, true );
					guiSetAlpha( tbl.add, 1 );
				
				else
				
					guiSetEnabled( tbl.add, false );
					guiSetAlpha( tbl.add, 0.5 );				
				
				end
			
			end
		
		);
		
		y = 32 + y;
		
	-- Add One End
	
	groupCP.ranksStartY = y;
	
	BuildRanks(	gInfo["ranks"], gInfo["lRank"] );
	
	-- Members
	
	if( groupCP.membScroll and isElement( groupCP.membScroll ) ) then
	
		destroyElement( groupCP.membScroll );
		groupCP.membScroll = nil;
	
	end
	groupCP.membScroll = guiCreateScrollPane( 0.5125, 0.2, 0.4375, 0.68, true, groupCP.window );
	guiScrollPaneSetScrollBars( groupCP.membScroll, false, true );	
	
	groupCP.members = { };
	
	local y = 8;
	for k, v in pairs( gInfo["members"] ) do
	
		guiCreateStaticImage( 0, y, 98, 24, ":phoenix_Characters/files/images/gui-lblue.png", false, groupCP.membScroll );
	
		local tbl = { };
	
		local realString = v["name"];
		
		tbl.lbl = guiCreateLabel( 4, y+4.5, 100, 24, realString, false, groupCP.membScroll );
		guiSetFont( tbl.lbl, "default-bold-small" );
		
		if( #realString > 11 ) then
		
			realString = string.sub( realString, 1, 11 ) .. "...";
			guiSetText( tbl.lbl, realString );
			AddAltdisplay( tbl.lbl, v["name"] );
		
		end		
		
		if( v["online"] == 1 ) then -- fake underline
		
			local width = dxGetTextWidth( realString, 1, "default-bold" );
			local smx, smy = guiGetPosition( tbl.lbl, false );
			
			guiCreateStaticImage( smx-2, smy+14, width+4, 1, ":phoenix_Characters/files/images/gui-white.png", false, groupCP.membScroll );
		
		end

		-- Edit Btn
		tbl.edit = guiCreateStaticImage( 100, y, 24, 24, "images/edit.png", false, groupCP.membScroll );
		registerMembEditor( tbl.edit, k, v, gInfo["ranks"] );
		
		-- Delete Btn
		tbl.del = guiCreateStaticImage( 127, y, 24, 24, "images/delete.png", false, groupCP.membScroll );	
		if( gInfo["ranks"][tonumber(v["rank"])]["isLeader"] == "1" or getElementData( player, "Character.name" ) == v["name"] ) then
		
			guiSetEnabled( tbl.del, false );
			guiSetAlpha( tbl.del, 0.5 );
		
		end
		
		addEventHandler( "onClientGUIClick", tbl.del,
		
			function ( button, state )
			
				if( button ~= "left" or state ~= "up" ) then return false; end
				if( source ~= tbl.del ) then return false; end
				
				triggerServerEvent( "onGroupPlayerKick", player, k );
				createWindow( true );
			
			end
		
		);		
		
		table.insert( groupCP.members, tbl );
		
		y = 32 + y;
	
	end	
	
	guiSetVisible( groupCP.window, true );
	showCursor( true );
	guiSetInputEnabled( true );

end


function BuildRanks( rankInf, numRanks, editedType, iId )

	local timing = getTickCount( );

	if( groupCP.ranksAdded ) then
	
		if( editedType == 1 ) then
		
			local removed = false;
			local oldY = 0;
			for k, v in ipairs( groupCP.ranks ) do
			
				if( k == iId ) then
				
					for k2, v2 in pairs( v ) do
					
						oldY = v.posY;
						if( isElement( v2 ) ) then destroyElement( v2 ); end
					
					end
					removed = true;
					groupCP.ranks[k] = nil;
				
				elseif( removed ) then
				
					guiSetPosition( v.down, -2, oldY+10, false );
					guiSetPosition( v.up, 9, oldY, false );
					guiSetPosition( v.img, 25, oldY, false );
					guiSetPosition( v.lblN, 27, oldY+4.5, false );
					guiSetPosition( v.lbl, 36, oldY+4.5, false );
					guiSetPosition( v.ul, 34, oldY+4.5+13, false );
					guiSetPosition( v.edit, 105, oldY, false );
					guiSetPosition( v.del, 105, oldY, false );
				
					oldY = v.posY;
				
				end
			
			end
			
			return true;
		
		else
		
			-- v.internalId
			--[[
			
				buildranksile param editedType
				buildranksile param internalId
				
				editedType = 1 -- deletion
					deleb internalId listist ning liigutab teisi üles kui on
					
				editedType = 2 -- insertion
					lisab internalId posile listi ning liigutab teisi üles/alla kui on
					
			]]--
			for k, v in ipairs( groupCP.ranks ) do
			
				for k2, v2 in pairs( v ) do
				
					if( isElement( v2 ) ) then destroyElement( v2 ); end
				
				end
			
			end
			groupCP.ranks = { };
		
		end
		
		groupCP.ranksAdded = false;
	
	end
	
	outputDebugString( "Groups: T1: " .. getTickCount( ) - timing );
	
	timing = getTickCount( );
	
	local y = groupCP.ranksStartY;
	groupCP.numMembers = 0;
	groupCP.numLeaders = 0;
	for k, v in pairs( rankInf ) do -- count
	
		if( v["isLeader"] == "1" ) then
		
			groupCP.numLeaders = groupCP.numLeaders + 1;
		
		else
		
			groupCP.numMembers = groupCP.numMembers + 1;
		
		end
	
	end	
	
	local id = 1;
	
	for k, v in pairs( rankInf ) do -- Show all ranks
	
		local tbl = { };	
	
		tbl.internalId = k;
		tbl.posY = y;
		tbl.down = guiCreateStaticImage( -2, y+10, 16, 16, "images/down.png", false, groupCP.rankScroll );
		tbl.up = guiCreateStaticImage( 9, y, 16, 16, "images/up.png", false, groupCP.rankScroll );
		
		if( id == 1 ) then
		
			guiSetEnabled( tbl.up, false );
			guiSetAlpha( tbl.up, 0.5 );
		
		elseif( id == numRanks ) then
		
			guiSetEnabled( tbl.down, false );
			guiSetAlpha( tbl.down, 0.5 );
		
		end
		
		addEventHandler( "onClientGUIClick", tbl.down,
		
			function ( button, state )
			
				if( button ~= "left" or state ~= "up" ) then return false; end
				if( source ~= tbl.down ) then return false; end
				
				onGroupRankReorder( k, 1 );				
				BuildRanks( storedGroupData["ranks"], storedGroupData["lRank"] );
			
			end
		
		);
		
		addEventHandler( "onClientGUIClick", tbl.up,
		
			function ( button, state )
			
				if( button ~= "left" or state ~= "up" ) then return false; end
				if( source ~= tbl.up ) then return false; end
				onGroupRankReorder( k, -1 );				
				BuildRanks( storedGroupData["ranks"], storedGroupData["lRank"] );
			
			end
		
		);
		
		tbl.img = guiCreateStaticImage( 25, y, 79, 24, ":phoenix_Characters/files/images/gui-lblue.png", false, groupCP.rankScroll );
		guiSetProperty( tbl.img, "ZOrderChangeEnabled", "false");		
		
		tbl.lblN = guiCreateLabel( 27, y+4.5, 16, 21, "" .. k, false, groupCP.rankScroll );
		guiSetFont( tbl.lblN, "default-bold-small" );	
		
		tbl.lbl = guiCreateLabel( 36, y+4.5, 75, 21, v["label"], false, groupCP.rankScroll );
		guiSetFont( tbl.lbl, "default-bold-small" );
		
		local realString = RankTextFilter( v["label"], tbl.lbl );
		if( realString ~= v["label"] ) then
		
			guiSetText( tbl.lbl, realString );
		
		end
		
		setElementData( tbl.lbl, "realVal", v["label"] );
		setElementData( tbl.lbl, "checked", v["isLeader"] );
		
		local width = dxGetTextWidth( realString, 1, "default-bold" );
		local smx, smy = guiGetPosition( tbl.lbl, false );
		tbl.ul = guiCreateStaticImage( smx-2, smy+13, width+4, 1, ":phoenix_Characters/files/images/gui-white.png", false, groupCP.rankScroll );
		
		
		if( v["isLeader"] ~= "1" ) then
		
			guiSetVisible( tbl.ul, false );
			setElementData( tbl.lbl, "checkDisabled", "0" );
		
		elseif( groupCP.numLeaders < 2 ) then
		
			setElementData( tbl.lbl, "checkDisabled", "1" );
		
		end

		-- Edit Btn
		tbl.edit = guiCreateStaticImage( 105, y, 24, 24, "images/edit.png", false, groupCP.rankScroll );
		registerRankEditor( tbl.edit, k, v, tbl.lbl, tbl.ul, RankTextFilter );			
		
		
		-- Delete Btn
		tbl.del = guiCreateStaticImage( 128, y, 24, 24, "images/delete.png", false, groupCP.rankScroll );	
		
		if( v["isLeader"] ~= "1" and groupCP.numMembers > 1 ) then
		
			addEventHandler( "onClientGUIClick", tbl.del,
			
				function ( button, state )
				
					if( button ~= "left" or state ~= "up" ) then return false; end
					if( source ~= tbl.del ) then return false; end
					
					onGroupRankDelete( k );
					BuildRanks( storedGroupData["ranks"], storedGroupData["lRank"], 1, k );
				
				end
			
			);	
		
		else
		
			guiSetAlpha( tbl.del, 0.5 );
		
		end
		
		table.insert( groupCP.ranks, tbl );
		
		y = 32 + y;		
		id = id + 1;
	
	end		

	groupCP.ranksAdded = true;
	outputDebugString( "Groups: T2: " .. getTickCount( ) - timing );

end

function CountRanks( )

	groupCP.numMembers = 0;
	groupCP.numLeaders = 0;

	for k, v in ipairs( groupCP.ranks ) do
	
		local isLeader = guiGetVisible( v.ul );
		if( isLeader ) then
		
			groupCP.numLeaders = groupCP.numLeaders + 1;
			
		else
		
			groupCP.numMembers = groupCP.numMembers + 1;
		
		end
	
	end
	
	for k, v in ipairs( groupCP.ranks ) do
	
		local isLeader = guiGetVisible( v.ul );
		if( isLeader and groupCP.numLeaders > 1 ) then
		
			setElementData( v.lbl, "checkDisabled", "0" );
		
		elseif( isLeader ) then
		
			setElementData( v.lbl, "checkDisabled", "1" );
		
		end
	
	end	

end

function registerRankEditor( btn, id, info, edit, under, filter )

	id = tonumber( id );
	
	addEventHandler( "onClientGUIClick", btn, 
	
		function ( button, state, absoluteX, absoluteY )
		
			if( button ~= "left" or state ~= "up" ) then return false; end
			if( source ~= btn ) then return false; end
			
			ShowEditbox( "Muuda Auastet", "Sisesta nimi mida soovid antud auastmele panna.", "Juhi Oigused", id, onRankNameEdit, edit, under, filter, CountRanks );
		
		end
	
	);

end

function RankTextFilter( text, label )

	local realString = text;
	if( #realString > 8 ) then
	
		realString = string.sub( realString, 1, 8 ) .. "...";
	
	end
	
	if( realString ~= text ) then
	
		AddAltdisplay( label, text );
	
	else
	
		AddAltdisplay( label ); -- Remove if added...
	
	end
	
	return realString;

end

function onRankNameEdit( internal, newVal, check )

	internal = tonumber( internal );			
	storedGroupData["ranks"][internal]["label"] = newVal;
	storedGroupData["ranks"][internal]["isLeader"] = check;	
	if( not editedGroupData["ranks"] ) then editedGroupData["ranks"] = { }; end
	editedGroupData["ranks"][internal] = storedGroupData["ranks"][internal];
	
	if( dataRev > 0 ) then dataRev = -1 * dataRev; end -- Set dataRev to edited one.

end

function onGroupRankAdd( name )

	for k = 1, 100 do 
	
		if( not storedGroupData["ranks"][k] ) then
		
			storedGroupData["ranks"][k] = { };
			storedGroupData["ranks"][k]["label"] = name;
			storedGroupData["ranks"][k]["groupId"] = storedGroupData["sqlid"];
			storedGroupData["ranks"][k]["isLeader"] = "0";
			storedGroupData["ranks"][k]["status"] = "added";
			
			storedGroupData["lRank"] = storedGroupData["lRank"] + 1;
			
			if( not editedGroupData["ranks"] ) then editedGroupData["ranks"] = { }; end
			editedGroupData["ranks"][k] = storedGroupData["ranks"][k];				
			editedGroupData["lRank"] = storedGroupData["lRank"];
			
			if( dataRev > 0 ) then dataRev = -1 * dataRev; end -- Set dataRev to edited one.
			
			guiSetText( groupCP.addRankE, "" );
			break;
		
		end			
	end

end

function onGroupRankDelete( internal )

	internal = tonumber( internal );
	
	if( not editedGroupData["ranks"] ) then editedGroupData["ranks"] = { }; end
	if( not editedGroupData["ranks"][internal] ) then editedGroupData["ranks"][internal] = { }; end
	editedGroupData["ranks"][internal]["sqlid"] = storedGroupData["ranks"][internal]["sqlid"];
	editedGroupData["ranks"][internal]["status"] = "deleted";
	
	if( storedGroupData["ranks"][internal]["status"] == "added" ) then
	
		editedGroupData["ranks"][internal] = nil;
	
	end
	
	storedGroupData["ranks"][internal] = nil;
	
	storedGroupData["lRank"] = storedGroupData["lRank"] - 1;			
	editedGroupData["lRank"] = storedGroupData["lRank"];
	
	if( dataRev > 0 ) then dataRev = -1 * dataRev; end -- Set dataRev to edited one.

end

function onGroupRankReorder( internal, dest )

	internal = tonumber( internal );
	if( not editedGroupData["ranks"] ) then editedGroupData["ranks"] = { }; end
	
	local tbl1 = storedGroupData["ranks"][internal];
	
	local exp2 = 1;
	if( dest > 0 ) then
	
		exp2 = storedGroupData["lRank"];
	
	end
	
	for k = internal+dest, exp2, dest do 
	
		if( storedGroupData["ranks"][k] ) then
		
			local tbl2 = storedGroupData["ranks"][k];
			
			storedGroupData["ranks"][k] = tbl1;
			editedGroupData["ranks"][k] = tbl1;
			storedGroupData["ranks"][internal] = tbl2;
			editedGroupData["ranks"][internal] = tbl2;
			
			break;
		
		end
	
	end
	
	if( dataRev > 0 ) then dataRev = -1 * dataRev; end -- Set dataRev to edited one.

end