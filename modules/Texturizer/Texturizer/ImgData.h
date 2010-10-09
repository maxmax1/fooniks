#ifndef __IMGDATA_H
#define __IMGDATA_H

#include <stdio.h> 

#include <iostream>
#include <fstream>

#include <gd.h>

#include <vector>
#include <map>

#include "extra/CLuaArguments.h"

//#include <squish.h>
//using namespace squish;

class TextureImage
{
private:

	std::string 
		fileName;

public:
	// Default constructor
	TextureImage();

	// Default destructor
	~TextureImage();

	/**
	 * TextureImage intializer overload which also sets the fileName.
	 * @param std::string fileName to load.
	 */
	TextureImage(std::string fName);

	void LoadImageToData( );
	void Compress( );

	int
		errorCode,
		width,
		height;

	std::vector<unsigned char>
		fileData;

};

class GdImgManager
{
private:
	std::map<void *, gdImagePtr> mImages;

public:
	GdImgManager( );
	~GdImgManager( );

	gdImagePtr GetImage( void * userData );

	void * AddImage( lua_State * luaVM, int width, int height );
	//void * AddImage( lua_State * luaVM, std::string rFilePath );

};

#endif // __IMGDATA_H