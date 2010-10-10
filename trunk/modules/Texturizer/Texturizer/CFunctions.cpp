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

#include "CFunctions.h"
#include "extra/CLuaArguments.h"

int CFunctions::CreateTxdContainer ( lua_State* luaVM )
{
	// bool/int createTxdContainer( void )
    if ( luaVM )
    {
		int i = mTextureContainer->AddContainer();
        if ( i != 0 )
		{
			
			lua_pushnumber( luaVM, i );
			return 1;
		}
		
		lua_pushboolean ( luaVM, false );
        return 1;
    }
    return 0;
}

int CFunctions::TxdContainerAddImage ( lua_State* luaVM )
{
	// bool txdContainerAddImage( int container, string name, string filePath[, bool compress, string alphaname] )
    if ( luaVM )
    {
        if ( lua_type ( luaVM, 1 ) == LUA_TNUMBER &&
            lua_type ( luaVM, 2 ) == LUA_TSTRING &&
            lua_type ( luaVM, 3 ) == LUA_TSTRING )
		{
			std::string mResource;
			if( pModuleManager->GetResourceName(luaVM, mResource) )
			{
				int contId = (int)lua_tonumber(luaVM, 1);
				const char* tName = lua_tostring(luaVM, 2);
				const char* fName = lua_tostring(luaVM, 3);
				bool compress = lua_type ( luaVM, 4 ) == LUA_TBOOLEAN?true:false;

				const char* alphaName;
				bool hasAlpha = false;
				if( lua_type ( luaVM, 5 ) == LUA_TSTRING )
				{
					alphaName = lua_tostring(luaVM, 5);
					hasAlpha = true;
				}

				if( mTextureContainer->HasMember( contId ) )
				{
					std::string 
						fNewPath,
						fMetaPath;

					if( ParseResourcePathInput( std::string(fName), mResource, fNewPath, fMetaPath ) )
					{
						uint32_t format = compress?(hasAlpha?FORMAT_1555:FORMAT_565):(hasAlpha?FORMAT_8888:FORMAT_888);

						TextureImage img(fNewPath);
						img.LoadImageToData(format, hasAlpha);

						if( img.errorCode != 0 )
						{
							pModuleManager->DebugPrintf( luaVM, "txdContainerAddImage: Image Error(%d).", img.errorCode );
							lua_pushboolean( luaVM, false );
						}
						else
						{
							if(compress) img.Compress();

							txd_texture_data_t tex;

							tex.id = 0x01;
							tex.marker = VERSION_GTASA;
							tex.version = 0x09;
							tex.filter_flags = 0x1101;
							
							memset(tex.texture_name, 0x0, 32 ); 
							memset(tex.alpha_name, 0x0, 32 ); 

							strcpy(tex.texture_name, tName);
							if(hasAlpha) strcpy(tex.alpha_name, alphaName);

							tex.alpha_flags = format;
							tex.direct3d_texture_format = compress?0x31545844:0x0; // DXT1
							tex.width = (uint16_t)img.width;
							tex.height = (uint16_t)img.height;
							tex.depth = 0x10;
							tex.mipmap_count = 1;
							tex.texcode_type = 0x04;
							tex.flags = compress?(hasAlpha?9:8):(hasAlpha?1:0);

							tex.palette = NULL;

							tex.data_size = img.fileData.size();
							tex.data = new uint8_t[img.fileData.size()];
							for(int i = 0; i < (int)img.fileData.size(); i++)
							{
								tex.data[i] = (uint8_t)img.fileData[i];
							}

							tex.chunk_size = 0;

							tex.chunk_size += ( 5 * sizeof(uint32_t) );
							tex.chunk_size += 64;
							tex.chunk_size += ( 2 * sizeof(uint16_t) );
							tex.chunk_size += ( 4 * sizeof(uint8_t) );
							tex.chunk_size += tex.depth==8?256*4:0;
							tex.chunk_size += tex.data_size;
							//tex.chunk_size += tex.mipmap_count;

							txd_extra_info_t extInf;
							extInf.id = CHUNK_EXTRA;
							extInf.marker = VERSION_GTASA;
							extInf.chunk_size = 0;
							extInf.data = 0;

							mTextureContainer->mContainers[contId]->addTexture( tex, extInf );
							lua_pushboolean( luaVM, true );
						}
						
						return 1;
					}
					else pModuleManager->DebugPrintf( luaVM, "Bad filepath in: txdContainerAddImage" );
				}
				else pModuleManager->DebugPrintf( luaVM, "Bad container id in: txdContainerAddImage" );
			}
			lua_pushboolean( luaVM, false );
		}
		else
		{
			pModuleManager->DebugPrintf( luaVM, "Incorrect parameters in: txdContainerAddImage" );
			lua_pushboolean( luaVM, false );
		}
        return 1;
    }
    return 0;
}

int CFunctions::SaveTxdContainer ( lua_State* luaVM )
{
	// bool saveTxdContainer( int container, string fName )
    if ( luaVM )
    {
        if ( lua_type ( luaVM, 1 ) == LUA_TNUMBER &&
            lua_type ( luaVM, 2 ) == LUA_TSTRING )
		{
			std::string mResource;
			if( pModuleManager->GetResourceName(luaVM, mResource) )
			{
				int contId = (int)lua_tonumber(luaVM, 1);
				const char* fName = lua_tostring(luaVM, 2);
				
				if( mTextureContainer->HasMember( contId ) )
				{
					std::string 
						fNewPath,
						fMetaPath;

					if( ParseResourcePathInput( std::string(fName), mResource, fNewPath, fMetaPath ) )
					{
						pModuleManager->DebugPrintf( luaVM, "saveTxdContainer: %s", fNewPath.c_str() );
						lua_pushboolean( luaVM, mTextureContainer->mContainers[contId]->Write(fNewPath.c_str()) );
						return 1;
					}
					else pModuleManager->DebugPrintf( luaVM, "Bad filepath in: saveTxdContainer" );
				}
				else pModuleManager->DebugPrintf( luaVM, "Bad container id in: saveTxdContainer" );
			}
			lua_pushboolean( luaVM, false );
		}
		else
		{
			pModuleManager->DebugPrintf( luaVM, "Incorrect parameters in: saveTxdContainer" );
			lua_pushboolean( luaVM, false );
		}
		return 1;
    }
    return 0;
}

int CFunctions::imgCreateTrueColor ( lua_State* luaVM )
{
	// bool/userdata imageCreateTrueColor( int w, int h )
    if ( luaVM )
    {
        if ( lua_type ( luaVM, 1 ) == LUA_TNUMBER &&
            lua_type ( luaVM, 2 ) == LUA_TNUMBER )
		{
			void * ret = mImgManager->AddImage( luaVM, (int)lua_tonumber(luaVM, 1), (int)lua_tonumber(luaVM, 2) );
			if( ret != NULL )
			{
				lua_pushlightuserdata( luaVM, ret );
				return 1;
			}
			lua_pushboolean( luaVM, false );
			return 1;
		}
		else
		{
			pModuleManager->DebugPrintf( luaVM, "Incorrect parameters in: imageCreateTrueColor" );
			lua_pushboolean( luaVM, false );
		}
		return 1;
    }
    return 0;
}

int CFunctions::imgCreateFromPng ( lua_State* luaVM )
{
	// bool/userdata imageCreateFromPng( string File )
    if ( luaVM )
    {
        if ( lua_type ( luaVM, 1 ) == LUA_TSTRING )
		{
			std::string mResource;
			if( pModuleManager->GetResourceName(luaVM, mResource) )
			{
				const char* fName = lua_tostring(luaVM, 1);
				std::string 
					fNewPath,
					fMetaPath;

				if( ParseResourcePathInput( std::string(fName), mResource, fNewPath, fMetaPath ) )
				{
					void * ret = mImgManager->AddImage( luaVM, fNewPath );
					if( ret != NULL )
					{
						lua_pushlightuserdata( luaVM, ret );
						return 1;
					}
				}
			}
			lua_pushboolean( luaVM, false );
			return 1;
		}
		else
		{
			pModuleManager->DebugPrintf( luaVM, "Incorrect parameters in: imageCreateFromPng" );
			lua_pushboolean( luaVM, false );
		}
		return 1;
    }
    return 0;
}

int CFunctions::imgPng ( lua_State* luaVM )
{
	// bool imagePng( userdata im, string fPath )
    if ( luaVM )
    {
        if ( lua_type ( luaVM, 1 ) == LUA_TLIGHTUSERDATA &&
            lua_type ( luaVM, 2 ) == LUA_TSTRING )
		{
			std::string mResource;
			if( pModuleManager->GetResourceName(luaVM, mResource) )
			{
				gdImagePtr im = mImgManager->GetImage( lua_touserdata( luaVM, 1 ) );
				if( im != NULL )
				{
					const char* fName = lua_tostring(luaVM, 2);
					std::string 
						fNewPath,
						fMetaPath;

					bool noDel = lua_toboolean(luaVM, 3)?true:false;

					if( ParseResourcePathInput( std::string(fName), mResource, fNewPath, fMetaPath ) )
					{
						std::fstream out(fNewPath.c_str(), std::fstream::out | std::fstream::binary );
						if( out.is_open() )
						{
							int sis = 0;
							char * result = (char *)gdImagePngPtr( im, &sis );

							out.write(result, sis);
							
							out.close();
							gdFree(result);

							if(!noDel) mImgManager->RemoveImage( lua_touserdata( luaVM, 1 ) );

							//printf( "%d", sis );

							lua_pushboolean( luaVM, true );
							return 1;
						}
						else
						{
							lua_pushboolean( luaVM, false );
							return 1;
						}
					}
					else
					{
						pModuleManager->DebugPrintf( luaVM, "Bad filepath in: imagePng" );
						lua_pushboolean( luaVM, false );
						return 1;
					}
				}
				else
				{
					lua_pushboolean( luaVM, false );
					return 1;
				}
			}
			lua_pushboolean( luaVM, false );
			return 1;
		}
		else
		{
			pModuleManager->DebugPrintf( luaVM, "Incorrect parameters in: imagePng" );
			lua_pushboolean( luaVM, false );
		}
		return 1;
    }
    return 0;
}

int CFunctions::imgColorAllocate ( lua_State* luaVM )
{
	// bool/int imageColorAllocate( userdata im, int red, int green, int blue)
    if ( luaVM )
    {
        if ( lua_type ( luaVM, 1 ) == LUA_TLIGHTUSERDATA &&
            lua_type ( luaVM, 2 ) == LUA_TNUMBER &&
            lua_type ( luaVM, 3 ) == LUA_TNUMBER &&
            lua_type ( luaVM, 4 ) == LUA_TNUMBER )
		{
			gdImagePtr im = mImgManager->GetImage( lua_touserdata( luaVM, 1 ) );
			if( im != NULL )
			{
				int ret = gdImageColorAllocate( im, (int)lua_tonumber(luaVM, 2), (int)lua_tonumber(luaVM, 3), (int)lua_tonumber(luaVM, 4) );
				if( ret != -1 ) lua_pushnumber( luaVM, ret );
				else            lua_pushboolean( luaVM, false );
			}
			else
			{
				lua_pushboolean( luaVM, false );
			}
			return 1;
		}
		else
		{
			pModuleManager->DebugPrintf( luaVM, "Incorrect parameters in: imageColorAllocate" );
			lua_pushboolean( luaVM, false );
		}
		return 1;
    }
    return 0;
}

int CFunctions::imgColorAllocateAlpha ( lua_State* luaVM )
{
	// bool/int imageColorAllocateAlpha( userdata im, int red, int green, int blue, int alpha)
    if ( luaVM )
    {
        if ( lua_type ( luaVM, 1 ) == LUA_TLIGHTUSERDATA &&
            lua_type ( luaVM, 2 ) == LUA_TNUMBER &&
            lua_type ( luaVM, 3 ) == LUA_TNUMBER &&
            lua_type ( luaVM, 4 ) == LUA_TNUMBER  &&
            lua_type ( luaVM, 5 ) == LUA_TNUMBER )
		{
			gdImagePtr im = mImgManager->GetImage( lua_touserdata( luaVM, 1 ) );
			if( im != NULL )
			{
				lua_pushnumber( luaVM, gdImageColorAllocateAlpha( im, (int)lua_tonumber(luaVM, 2), (int)lua_tonumber(luaVM, 3), (int)lua_tonumber(luaVM, 4), (int)lua_tonumber(luaVM, 5) ) );
			}
			else
			{
				lua_pushboolean( luaVM, false );
			}
			return 1;
		}
		else
		{
			pModuleManager->DebugPrintf( luaVM, "Incorrect parameters in: imageColorAllocate" );
			lua_pushboolean( luaVM, false );
		}
		return 1;
    }
    return 0;
}


int CFunctions::imgTtfText ( lua_State* luaVM )
{
	// bool/int imageTtfText( userdata im, int size, int angle, int x, int y, int color, string fontFile, string text)
    if ( luaVM )
    {
        if ( lua_type ( luaVM, 1 ) == LUA_TLIGHTUSERDATA &&
            lua_type ( luaVM, 2 ) == LUA_TNUMBER &&
            lua_type ( luaVM, 3 ) == LUA_TNUMBER &&
            lua_type ( luaVM, 4 ) == LUA_TNUMBER  &&
            lua_type ( luaVM, 5 ) == LUA_TNUMBER  &&
            lua_type ( luaVM, 6 ) == LUA_TNUMBER  &&
            lua_type ( luaVM, 7 ) == LUA_TSTRING  &&
            lua_type ( luaVM, 8 ) == LUA_TSTRING )
		{
			std::string mResource;
			if( pModuleManager->GetResourceName(luaVM, mResource) )
			{
				const char* fName = lua_tostring(luaVM, 7);
				std::string 
					fNewPath,
					fMetaPath;

				if( ParseResourcePathInput( std::string(fName), mResource, fNewPath, fMetaPath ) )
				{
					gdImagePtr im = mImgManager->GetImage( lua_touserdata( luaVM, 1 ) );
					if( im != NULL )
					{
						double size = lua_tonumber(luaVM, 2);
						double angle = lua_tonumber(luaVM, 3);
						int x = (int)lua_tonumber(luaVM, 4);
						int y = (int)lua_tonumber(luaVM, 5);
						int color = (int)lua_tonumber(luaVM, 6);
						const char* strTxt = lua_tostring(luaVM, 8);
						
						int rect[8] = {0, 0, 0, 0, 0, 0, 0, 0};
						char * err = gdImageStringFT( im, &rect[0], color, (char *)fNewPath.c_str(), size, angle, x, y, (char *)strTxt );

						if (err)
						{
							pModuleManager->DebugPrintf( luaVM, "Error with gdImageStringFT(%s) %s in: imageTtfText", err );
							return 1;
						}

						lua_createtable( luaVM, 0, 8 );
						
						for( int i = 0; i < 8; i++ )
						{
							lua_pushnumber( luaVM, i+1 );
							lua_pushnumber( luaVM, rect[i]);
							lua_settable( luaVM, -3 );
						}
						return 1;
					}
					else
					{
						lua_pushboolean( luaVM, false );
						return 1;
					}
				}
				else
				{
					pModuleManager->DebugPrintf( luaVM, "Bad filepath in: imageTtfText" );
					lua_pushboolean( luaVM, false );
					return 1;
				}
			}
			else
			{
				lua_pushboolean( luaVM, false );
				return 1;
			}
		}
		else
		{
			pModuleManager->DebugPrintf( luaVM, "Incorrect parameters in: imageTtfText" );
			lua_pushboolean( luaVM, false );
		}
		return 1;
    }
    return 0;
}

int CFunctions::imgTtfBBox ( lua_State* luaVM )
{
	// bool/int imageTtfBBox( int size, int angle, string fontFile, string text)
    if ( luaVM )
    {
        if ( lua_type ( luaVM, 1 ) == LUA_TNUMBER &&
            lua_type ( luaVM, 2 ) == LUA_TNUMBER &&
            lua_type ( luaVM, 3 ) == LUA_TSTRING  &&
            lua_type ( luaVM, 4 ) == LUA_TSTRING )
		{
			std::string mResource;
			if( pModuleManager->GetResourceName(luaVM, mResource) )
			{
				const char* fName = lua_tostring(luaVM, 3);
				std::string 
					fNewPath,
					fMetaPath;

				if( ParseResourcePathInput( std::string(fName), mResource, fNewPath, fMetaPath ) )
				{
					double size = lua_tonumber(luaVM, 1);
					double angle = lua_tonumber(luaVM, 2);
					const char* strTxt = lua_tostring(luaVM, 4);
					
					int rect[8] = {0, 0, 0, 0, 0, 0, 0, 0};
					char * err = gdImageStringFT( NULL, &rect[0], 0, (char *)fNewPath.c_str(), size, angle, 0, 0, (char *)strTxt );

					if (err)
					{
						pModuleManager->DebugPrintf( luaVM, "Error with gdImageStringFT(%s) in: imageTtfBBox", err );
						return 1;
					}

					lua_createtable( luaVM, 0, 8 );
					
					for( int i = 0; i < 8; i++ )
					{
						lua_pushnumber( luaVM, i+1 );
						lua_pushnumber( luaVM, rect[i]);
						lua_settable( luaVM, -3 );
					}
					return 1;
				}
				else
				{
					pModuleManager->DebugPrintf( luaVM, "Bad filepath in: imageTtfBBox" );
					lua_pushboolean( luaVM, false );
					return 1;
				}
			}
			else
			{
				lua_pushboolean( luaVM, false );
				return 1;
			}
		}
		else
		{
			pModuleManager->DebugPrintf( luaVM, "Incorrect parameters in: imageTtfBBox" );
			lua_pushboolean( luaVM, false );
		}
		return 1;
    }
    return 0;
}

int CFunctions::imgDestroy ( lua_State* luaVM )
{
	// bool/int imageDestroy( userdata im )
    if ( luaVM )
    {
        if ( lua_type ( luaVM, 1 ) == LUA_TLIGHTUSERDATA )
		{
			gdImagePtr im = mImgManager->GetImage( lua_touserdata( luaVM, 1 ) );
			if( im != NULL )
			{
				mImgManager->RemoveImage( lua_touserdata( luaVM, 1 ) );
				lua_pushboolean( luaVM, true );
			}
			else
			{
				lua_pushboolean( luaVM, false );
			}
			return 1;
		}
		else
		{
			pModuleManager->DebugPrintf( luaVM, "Incorrect parameters in: imageDestroy" );
		}
    }
	lua_pushboolean( luaVM, false );
    return 0;
}