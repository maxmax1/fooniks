TabPanel = nil;
TabViga = nil;
vEditPealkiri = nil;
vTeata = nil;
TabMuu = nil;
mMemoKirjeldus = nil;
mTeata = nil;

function cTeata()

	local x, y = guiGetScreenSize( );
	TabPanel = guiCreateTabPanel( (x/2)-200, (y/2)-200, 400, 400, false);
	
	TabViga = guiCreateTab("Veast", TabPanel);
	vEditPealkiri = guiCreateEdit(0.18, 0.07, 0.765, 0.067, "", true, TabViga);
	vLabelPealkiri = guiCreateLabel(0.05, 0.08, 0.1225, 0.0531, "Pealkiri:", true, TabViga);
	vLabelKirjeldus = guiCreateLabel(0.05, 0.25, 0.1175, 0.0587, "Kirjeldus:", true, TabViga);
	vMemoKirjeldus = guiCreateMemo(0.05, 0.3, 0.9, 0.433, "", true, TabViga);
	vLabelMp1 = guiCreateLabel(0.05, 0.8, 0.6275, 0.0503, "* Kirjeldage mida tegite vea ilmnemisel", true, TabViga);
	vLabelMp2 = guiCreateLabel(0.05, 0.85, 0.54, 0.0419, "* Iga viga eraldi postitusse", true, TabViga);
	vLabelMp3 = guiCreateLabel(0.05, 0.75, 0.4875, 0.0531, "* Pealkiri peab kirjeldama vea sisu", true, TabViga);
	vTeata = guiCreateButton(0.67, 0.7877, 0.275, 0.1508, "TEATA/SULGE", true, TabViga);
	
	TabMuu = guiCreateTab("Muu", TabPanel);
	mLabelKirjeldus = guiCreateLabel(0.05, 0.06, 0.255, 0.095, "Kirjeldus:", true, TabMuu);
	mMemoKirjeldus = guiCreateMemo(0.0475, 0.1229, 0.9, 0.5559, "", true, TabMuu);
	mSulge = guiCreateButton(0.05, 0.75, 0.4175, 0.176, "SULGE", true, TabMuu);
	mTeata = guiCreateButton(0.57, 0.75, 0.3775, 0.1788, "TEATA", true, TabMuu);
	
	guiEditSetMaxLength( mMemoKirjeldus, 30 );
	
end

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), 
	function ( )
	
		cTeata( );
		addEventHandler("onClientGUIClick", vTeata, vteata, false);
		addEventHandler("onClientGUIClick", mSulge, msulge, false);
		addEventHandler("onClientGUIClick", mTeata, mteata, false);
		guiSetVisible(TabPanel, false);
		
	end
)

bindKey("F2", "down",

        function( )
        
                showCursor( not isCursorShowing() );
				guiSetVisible(TabPanel, not guiGetVisible(TabPanel));
				guiSetText( mMemoKirjeldus, "" );
				guiSetText ( vEditPealkiri, "" );
				guiSetText ( vMemoKirjeldus, "" );
        end
        
);

function vteata( )

	local head = guiGetText( vEditPealkiri );
	local kirj = guiGetText( vMemoKirjeldus );
	
	guiSetText ( vEditPealkiri, "" );
	guiSetText ( vMemoKirjeldus, "" );
	
	if #head >= 5 and #kirj >= 15 then
	
		triggerServerEvent("submitVTeata", getRootElement(), head, kirj);
		
	else
	
		outputChatBox( "Pealkiri peab olema vähemalt 5 ja sisu 15 tähemärki." );
		
	end
	
	guiSetVisible(TabPanel, false);
	guiSetInputEnabled( false );
	showCursor( false );	
	
end

function msulge()

	guiSetText( mMemoKirjeldus, "" );
	guiSetVisible(TabPanel, false);
	guiSetInputEnabled( false );
	showCursor( false );
	
end

function mteata()
	
	local mkirj = guiGetText( mMemoKirjeldus )
	local teataja = getPlayerName(getLocalPlayer())
	
	guiSetText ( mMemoKirjeldus, "" )
	guiSetVisible(TabPanel, false)
	guiSetInputEnabled( false )
	showCursor( false )	
	
	if #mkirj >= 5 then
	
		triggerServerEvent("submitMTeata", getRootElement(), mkirj, teataja) 
		
	else
	
		outputChatBox( "Teade peab olema vähemalt 5 tähemärki." );
		
	end
	
end

function inputChange()
	if guiGetVisible(TabPanel) then
		if source == vMemoKirjeldus or source == vEditPealkiri or  source == mMemoKirjeldus then
			guiSetInputEnabled( true )
		else
			guiSetInputEnabled( false )
		end
	end
end
addEventHandler( "onClientGUIMouseUp", getRootElement( ), inputChange)