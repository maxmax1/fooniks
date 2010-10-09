/*********************************************************
*
*  Multi Theft Auto: San Andreas - Deathmatch
*
*  ml_base, External lua add-on module
*  
*  Copyright © 2003-2008 MTA.  All Rights Reserved.
*
*  Grand Theft Auto is © 2002-2003 Rockstar North
*
*  THE FOLLOWING SOURCES ARE PART OF THE MULTI THEFT
*  AUTO SOFTWARE DEVELOPMENT KIT AND ARE RELEASED AS
*  OPEN SOURCE FILES. THESE FILES MAY BE USED AS LONG
*  AS THE DEVELOPER AGREES TO THE LICENSE THAT IS
*  PROVIDED WITH THIS PACKAGE.
*
*********************************************************/

#include "ml_base.h"

ILuaModuleManager10 *pModuleManager = NULL;
TextureContainer *	mTextureContainer = NULL;
GdImgManager * mImgManager = NULL;

// Initialisation function (module entrypoint)
MTAEXPORT bool InitModule ( ILuaModuleManager10 *pManager, char *szModuleName, char *szAuthor, float *fVersion )
{
    pModuleManager = pManager;
	mTextureContainer = new TextureContainer;
	mImgManager = new GdImgManager;

    // Set the module info
    strncpy ( szModuleName, MODULE_NAME, MAX_INFO_LENGTH );
    strncpy ( szAuthor, MODULE_AUTHOR, MAX_INFO_LENGTH );
    (*fVersion) = MODULE_VERSION;

    return true;
}


MTAEXPORT void RegisterFunctions ( lua_State * luaVM )
{
    if ( pModuleManager && luaVM )
    {
		pModuleManager->RegisterFunction ( luaVM, "createTxdContainer", CFunctions::CreateTxdContainer );
		pModuleManager->RegisterFunction ( luaVM, "txdContainerAddImage", CFunctions::TxdContainerAddImage );
		pModuleManager->RegisterFunction ( luaVM, "saveTxdContainer", CFunctions::SaveTxdContainer );

		// GD Functions...
		pModuleManager->RegisterFunction ( luaVM, "imageCreateTrueColor", CFunctions::imgCreateTrueColor );
		pModuleManager->RegisterFunction ( luaVM, "imagePng", CFunctions::imgPng );

		pModuleManager->RegisterFunction ( luaVM, "imageColorAllocate", CFunctions::imgColorAllocate );
		pModuleManager->RegisterFunction ( luaVM, "imageColorAllocateAlpha", CFunctions::imgColorAllocateAlpha );

		pModuleManager->RegisterFunction ( luaVM, "imageTtfText", CFunctions::imgTtfText );
		pModuleManager->RegisterFunction ( luaVM, "imageTtfBBox", CFunctions::imgTtfBBox );
    }
}


MTAEXPORT bool DoPulse ( void )
{
    return true;
}

MTAEXPORT bool ShutdownModule ( void )
{
    delete mTextureContainer;
    return true;
}
