--[[

<tutorials>

	<tuto title="" uniqueid="" specialcmd="testtuto">

		<page number="1" name="">
			Lorem ipsum...
		</page>
		
		<page number="2" name="">
			... dolor sit amed. 
		</page>

	</tuto>

</tutorials>

]]--

local POPUP_TIMEOUT = 15000;
local FADE_DELTA = .03;
local MAX_ALPHA = .9;

local allTuts = { };
local tutRes = { };
local tutWind = { };
local tutMsgs = { };

local tutCmds = { };

local readXml = nil;
local rootElement = getRootElement( );

local white = tocolor( 255, 255, 255 );

addEvent( "onClientTutorialStart" );
addEvent( "onClientTutorialEnd" );
addEvent( "onClientCloseTutoGui" );

function LoadTutorialsForResource( resource )
	
	local resName = getResourceName( resource );
	
	if( resName ) then
	
		if tutRes[resName] then
		
			return false
		
		end
		
		local xmlNode = getResourceConfig( ":" .. resName .. "/tutorials.xml" );
		if ( xmlNode ) then
		
			local tutorials = xmlNodeGetChildren( xmlNode );
			local foundTutos = { };
			
			for k, v in ipairs( tutorials ) do
			
				if( xmlNodeGetName( v ) == "tuto" ) then
			
					local title = xmlNodeGetAttribute( v, "title" );
					local uniqueid = xmlNodeGetAttribute( v, "uniqueid" );
					local specialcmd = xmlNodeGetAttribute( v, "specialcmd" );
					local pages = xmlNodeGetChildren( v );
					
					if( title and uniqueid and specialcmd and pages and not allTuts[uniqueid] ) then
					
						local tut = { };
						
						tut.title = title;
						tut.pages = { };
					
						for k2, v2 in ipairs( pages ) do
						
							local tbl = { };
							tbl.text = xmlNodeGetValue( v2 );
							tbl.name = xmlNodeGetAttribute( v2, "name" );
							
							if ( tbl.text ) then
							
								table.insert( tut.pages, tbl );
							
							end
						
						end
						
						if( #tut.pages > 0 ) then
						
							allTuts[uniqueid] = tut;
							tutCmds[specialcmd] = uniqueid;
							tutRes[resName] = true;
							if( not IsTutorialRead( uniqueid ) ) then
							
								table.insert( tutMsgs, { name = title, id = uniqueid, cmd = specialcmd } );
								if ( #tutMsgs == 1 ) then
								
									ShowPopup( #tutMsgs );
								
								end
							end
						
						else
						
							outputDebugString( "Tutorailil " .. title .. " puudub esileht.", 2 );
						
						end
					
					end
				
				end
			
			end
		
		end
	
	end

end

function IsTutorialRead( tutoid )

	local xmlContents = xmlNodeGetValue( readXml );
	
	if( xmlContents ) then
	
		local readTutos = split( xmlContents, string.byte( ',' ) );

		for k, v in ipairs(readTutos) do
		
			if ( v == tutoid ) then
			
				return true;
			
			end
		
		end
	
	end
	
	return false;

end

function SetTutorialRead( tutoid )

	if( not IsTutorialRead( tutoid ) ) then
	
		local xmlContents = xmlNodeGetValue( readXml );
		xmlNodeSetValue( readXml, xmlContents .. tutoid .. "," );
		xmlSaveFile( readXml );
	
	end

end

function SetPage( pageN )

	if( pageN > tutWind.npages ) then
	
		tutWind.page = tutWind.npages;
	
	elseif( pageN < 1 ) then
	
		tutWind.page = 1;
	
	else
	
		tutWind.page = pageN;
	
	end

	tutWind.realHeading = allTuts[tutWind.tuto].pages[tutWind.page].name;
	tutWind.realTxt = allTuts[tutWind.tuto].pages[tutWind.page].text;
	
	-- is last page
	if( tutWind.npages - tutWind.page == 0 ) then
	
		guiSetText( tutWind.next, "Tehtud >>" );
	
	else
	
		guiSetText( tutWind.next, "Edasi >>" );
		guiSetEnabled( tutWind.cancel, true );
	
	end
	if( tutWind.page == 1 ) then
	
		guiSetEnabled( tutWind.back, false );
	
	else
	
		guiSetEnabled( tutWind.back, true );
	
	end

end

function DrawText( )

	if( guiGetVisible( tutWind.window ) and tutWind.realHeading ) then
	
		local totalPosX, totalPosY = guiGetPosition( tutWind.window, false );
		local totalW, totalH = guiGetSize( tutWind.window, false );
		
		local posX = totalPosX + ( totalW * 0.05 );
		local posY = totalPosY +  ( totalH * 0.1 );
		dxDrawText( tutWind.realHeading, posX, posY, posX + ( totalW * 0.9 ), posY + ( totalH * 0.2 ), white, 3, "default-bold", "left", "top", false, true, true );

		posY = totalPosY +  ( totalH * 0.2 );	
		dxDrawText( tutWind.realTxt or " ", posX, posY, posX + ( totalW * 0.9 ), posY + ( totalH * 0.6 ), white, 1, "default", "left", "top", false, true, true );
	
	end

end

addEventHandler( "onClientRender", rootElement, DrawText );

function ShowTutorial( tuto )

	if( tuto and allTuts[tuto] ) then
	
		guiSetVisible( tutWind.back, true );
		guiSetVisible( tutWind.next, true );
		guiSetVisible( tutWind.grid, false );
		
		guiSetText( tutWind.next, "Edasi  >>" );
		guiSetText( tutWind.cancel, "Katkesta" );
	
		guiSetText( tutWind.window, allTuts[tuto].title .. " - Tutorial" );
		
		tutWind.tuto = tuto;
		tutWind.npages = #allTuts[tuto].pages;
		
		SetPage( 1 );
		
		guiSetVisible( tutWind.window, true );
		guiBringToFront( tutWind.window );
		showCursor( true );
		
		triggerEvent( "onClientTutorialStart", getLocalPlayer( ), tuto );
	
	elseif( not tuto ) then
	
		guiGridListClear( tutWind.grid );
		
		for k, v in pairs( allTuts ) do
		
			local row = guiGridListAddRow( tutWind.grid );
			local label = "Ei";
			if( IsTutorialRead( k ) ) then label = "Jah"; end 
			
			guiGridListSetItemText( tutWind.grid, row, 1, tostring( v.title ), false, false );
			guiGridListSetItemText( tutWind.grid, row, 2, label, false, false );
			guiGridListSetItemData( tutWind.grid, row, 1, k );
		
		end
	
		tutWind.realHeading = "Kõik Õpetused";
		tutWind.realTxt = false;
	
		guiSetVisible( tutWind.back, false );
		guiSetVisible( tutWind.next, true );
		guiSetVisible( tutWind.grid, true );
		
		guiSetText( tutWind.next, "Loe" );
		guiSetText( tutWind.cancel, "Sulge" );
		
		guiSetVisible( tutWind.window, true );
		guiBringToFront( tutWind.window );
		showCursor( true );
	
	end

end

function NextPage( )

	if( not guiGetVisible( tutWind.grid ) ) then

		if( tutWind.page+1 <= tutWind.npages ) then -- next
		
			SetPage( tutWind.page+1 );
		
		else -- finish
		
			-- Save a cookie which states that client has already seen it.
			SetTutorialRead( tutWind.tuto );
			
			-- Hide window...
			guiSetVisible( tutWind.window, false );
			
			-- Trigger Event
			triggerEvent( "onClientTutorialEnd", getLocalPlayer( ), tutWind.tuto );
			
			showCursor( false );
		
		end
	
	else
	
		local selected = guiGridListGetSelectedItem( tutWind.grid );
		if( selected and selected ~= -1 ) then
		
			local id = guiGridListGetItemData( tutWind.grid, selected, 1 );
			ShowTutorial( id );
		
		end
	
	end

end

function PreviousPage( )

	if( tutWind.page-1 > 0 ) then -- back
	
		SetPage( tutWind.page-1 );
	
	end	

end

addEventHandler("onClientResourceStart", getResourceRootElement( getThisResource( ) ), 

	function ()
	
		tutWind.window = guiCreateWindow( 0.2, 0.2, 0.6, 0.6, "Tutorial", true );
		
		tutWind.back = guiCreateButton( 0.425, 0.900, 0.175, 0.1, "<< Tagasi", true, tutWind.window );
		tutWind.next = guiCreateButton( 0.625, 0.900, 0.175, 0.1, "Edasi  >>", true, tutWind.window );
		tutWind.cancel = guiCreateButton( 0.825, 0.900, 0.175, 0.1, "Kaktesta", true, tutWind.window );
		
		tutWind.grid = guiCreateGridList( 0, 0.215, 1, 0.625, true, tutWind.window );
		guiGridListAddColumn( tutWind.grid, "Nimi", 0.8 );
		guiGridListAddColumn( tutWind.grid, "Loetud", 0.1 );
		
		addEventHandler( "onClientGUIClick", tutWind.back,
		
			function ( button, state )
			
				if( button ~= "left" or state ~= "up" ) then return false; end
				if( source ~= tutWind.back ) then return false; end
				
				PreviousPage( );
			
			end
		
		);
		
		addEventHandler( "onClientGUIClick", tutWind.next,
		
			function ( button, state )
			
				if( button ~= "left" or state ~= "up" ) then return false; end
				if( source ~= tutWind.next ) then return false; end
				
				NextPage( );
			
			end
		
		);
		
		addEventHandler( "onClientGUIClick", tutWind.cancel,
		
			function ( button, state )
			
				if( button ~= "left" or state ~= "up" ) then return false; end
				if( source ~= tutWind.cancel ) then return false; end
				
				guiSetVisible( tutWind.window, false );				
				triggerEvent( "onClientCloseTutoGui", getLocalPlayer( ) );
			
			end
		
		);
		
		guiSetVisible( tutWind.window, false );
		
		readXml = xmlLoadFile("read.xml")
		if ( not readXml ) then
		
			readXml = xmlCreateFile( "read.xml", "read" );
		
		end	
		
		for k, v in ipairs( getElementsByType( "resource" ) ) do
		
			local resource = getResourceFromName( getElementID( v ) );
			if resource then
			
				LoadTutorialsForResource( resource );
			
			end
		
		end	
	
	end

);

local function fadeIn(wnd)
	local function raiseAlpha()
		local newAlpha = guiGetAlpha(wnd) + FADE_DELTA
		if newAlpha <= MAX_ALPHA then
			guiSetAlpha(wnd, newAlpha)
		else
			removeEventHandler("onClientRender", rootElement, raiseAlpha)
		end
	end
	addEventHandler("onClientRender", rootElement, raiseAlpha)
end

local function fadeOut(wnd)
	local function lowerAlpha()
		local newAlpha = guiGetAlpha(wnd) - FADE_DELTA
		if newAlpha >= 0 then
			guiSetAlpha(wnd, newAlpha)
		else
			removeEventHandler("onClientRender", rootElement, lowerAlpha)
			destroyElement(wnd)
			table.remove(tutMsgs, 1)
			if #tutMsgs > 0 then
				ShowPopup(1)
			end			
		end
	end
	addEventHandler("onClientRender", rootElement, lowerAlpha)
end

function ShowPopup( id )

	local text = 
	"Uus tutorial " .. tutMsgs[id].name .. "! "..
	"Kasuta /tutorial " .. tutMsgs[id].cmd .. ", et seda lugeda.";

	local screenX, screenY = guiGetScreenSize( );
	local wndPopup = guiCreateWindow( 0, screenY - 20, screenX, 0, text, false );
	
	guiSetAlpha( wndPopup, 0 );
	guiWindowSetMovable( wndPopup, false );
	guiWindowSetSizable( wndPopup, false );
	
	fadeIn( wndPopup );
	setTimer( fadeOut, POPUP_TIMEOUT, 1, wndPopup, realText );

end

--

addCommandHandler( "tutorial", 

	function ( cmdN, tutoId )
	
		if( tutoId and tutoId ~= 0 ) then
		
			if( tutCmds[tutoId] ) then
			
				ShowTutorial( tutCmds[tutoId] );
				return true;
			
			end
		
		end
		
		exports.phoenix_Chat:OocInfo( "Sellist tutoriali pole! Kasuta /tutorials." );
	
	end

, false, false ); 

addCommandHandler( "tutorials", 

	function ( cmdN )
	
		ShowTutorial( );
	
	end

, false, false ); 