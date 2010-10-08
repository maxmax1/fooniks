MyTabPanel = 
{
	thePlayer = getLocalPlayer( ),
	
	theWind = nil,
	thePanel = nil,
	closeButton = nil,
	
	theTitle = "MyTabPanel",
	theSize = { x = 0.6, y = 0.5 },
	
	theTabs = {  },
	
	hideFunc = false
};

function MyTabPanel:new( title, size, o )

	o = o or { };
	setmetatable( o, self );
	self.__index = self;
	
	o.theTitle = title or "MyTabPanel";
	o.theSize = size or { x = 0.6, y = 0.5 };
	
	return o;

end

function MyTabPanel:Create( )

	self.theWind = guiCreateWindow( ( 1 - self.theSize.x ) / 2, ( 1 - self.theSize.y ) / 2, self.theSize.x, self.theSize.y, self.theTitle, true );
	
	self.thePanel = guiCreateTabPanel( 0.025, 0.1, 0.95, 0.75, true, self.theWind );
	
	self.closeButton = guiCreateButton( 0.775, 0.86, 0.2, 0.15, "Sulge", true, self.theWind ); 
	addEventHandler("onClientGUIClick", self.closeButton, 
		function ( button, state )
		
			local mySelf = self;		
			if( button ~= "left" or state ~= "up" ) then return false; end
			if( source ~= mySelf.closeButton ) then return false; end
			mySelf:Hide( );
		
		end
	, false);
	
	guiSetVisible( self.theWind, false );

end

function MyTabPanel:Show( )

	guiSetVisible( self.theWind, true );

end

function MyTabPanel:Hide( )

	if( self.hideFunc ) then self.hideFunc(); end
	guiSetVisible( self.theWind, false );

end

function MyTabPanel:AddTab( title )

	table.insert( self.theTabs, guiCreateTab( title, self.thePanel ) );
	return #self.theTabs;

end