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

class CFunctions;

#ifndef __CFUNCTIONS_H
#define __CFUNCTIONS_H

#include <stdio.h>

#include "include/ILuaModuleManager.h"
#include "TextureContainer.h"
#include "ImgData.h"

extern ILuaModuleManager10 *pModuleManager;
extern TextureContainer	   *mTextureContainer;
extern GdImgManager * mImgManager;

#include "ChunkInfo.hpp"
#include "TextureDictionary.hpp"

#include "ModuleFilePaths.h"

class CFunctions
{
public:

        static int      CreateTxdContainer          ( lua_State* luaVM );
        static int      TxdContainerAddImage        ( lua_State* luaVM );
        static int      SaveTxdContainer            ( lua_State* luaVM );

		// GD Functions...

		static int      imgCreateTrueColor          ( lua_State* luaVM );
		static int      imgCreateFromPng            ( lua_State* luaVM );

		static int      imgPng                      ( lua_State* luaVM );

		static int      imgColorAllocate            ( lua_State* luaVM );
		static int      imgColorAllocateAlpha       ( lua_State* luaVM );

		static int      imgTtfText					( lua_State* luaVM );
		static int      imgTtfBBox					( lua_State* luaVM );

		static int      imgFill						( lua_State* luaVM );

		static int      imgDestroy					( lua_State* luaVM );
};
#endif
