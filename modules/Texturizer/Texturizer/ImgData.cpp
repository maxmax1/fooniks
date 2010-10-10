#include "ImgData.h"

TextureImage::TextureImage()
{
	fileName = "";
	errorCode = -1;
}
TextureImage::TextureImage(std::string fName)
{
	fileName = fName;
	errorCode = -1;
}

TextureImage::~TextureImage()
{
	fileData.clear();
}

void TextureImage::Init( )
{
	cFilter = FORMAT_DEFAULT;

	fOrder[FORMAT_DEFAULT] = new int [4];
	fOrder[FORMAT_DEFAULT][0] = ORDER_RED;
	fOrder[FORMAT_DEFAULT][1] = ORDER_GREEN;
	fOrder[FORMAT_DEFAULT][2] = ORDER_BLUE;
	fOrder[FORMAT_DEFAULT][3] = ORDER_ALPHA;

	fOrder[FORMAT_1555] = new int [4];
	fOrder[FORMAT_1555][0] = ORDER_RED;
	fOrder[FORMAT_1555][1] = ORDER_GREEN;
	fOrder[FORMAT_1555][2] = ORDER_BLUE;
	fOrder[FORMAT_1555][3] = ORDER_ALPHA;

	fOrder[FORMAT_565] = new int [4];
	fOrder[FORMAT_565][0] = ORDER_RED;
	fOrder[FORMAT_565][1] = ORDER_GREEN;
	fOrder[FORMAT_565][2] = ORDER_BLUE;
	fOrder[FORMAT_565][3] = ORDER_ALPHA;

	fOrder[FORMAT_4444] = new int [4];
	fOrder[FORMAT_4444][0] = ORDER_RED;
	fOrder[FORMAT_4444][1] = ORDER_GREEN;
	fOrder[FORMAT_4444][2] = ORDER_BLUE;
	fOrder[FORMAT_4444][3] = ORDER_ALPHA;

	fOrder[FORMAT_LUM8] = new int [4];
	fOrder[FORMAT_LUM8][0] = ORDER_RED;
	fOrder[FORMAT_LUM8][1] = ORDER_GREEN;
	fOrder[FORMAT_LUM8][2] = ORDER_BLUE;
	fOrder[FORMAT_LUM8][3] = ORDER_ALPHA;

	fOrder[FORMAT_8888] = new int [4];
	fOrder[FORMAT_8888][0] = ORDER_BLUE;
	fOrder[FORMAT_8888][1] = ORDER_GREEN;
	fOrder[FORMAT_8888][2] = ORDER_RED;
	fOrder[FORMAT_8888][3] = ORDER_ALPHA;

	fOrder[FORMAT_888] = new int [4];
	fOrder[FORMAT_888][0] = ORDER_BLUE;
	fOrder[FORMAT_888][1] = ORDER_GREEN;
	fOrder[FORMAT_888][2] = ORDER_RED;
	fOrder[FORMAT_888][3] = ORDER_ALPHA;

	fOrder[FORMAT_555] = new int [4];
	fOrder[FORMAT_555][0] = ORDER_RED;
	fOrder[FORMAT_555][1] = ORDER_GREEN;
	fOrder[FORMAT_555][2] = ORDER_BLUE;
	fOrder[FORMAT_555][3] = ORDER_ALPHA;
}

void TextureImage::LoadImageToData( uint32_t filter, bool mAlpha )
{
	cFilter = filter;

	std::fstream fs(fileName.c_str(), std::ios::in|std::ios::binary);
	if( fs.is_open() )
	{
		// get length of file:
		fs.seekg (0, std::ios::end);
		int length = fs.tellg();
		fs.seekg (0, std::ios::beg);

		// allocate memory:
		char * buffer = new char[length];

		// read data as a block:
		fs.read (buffer, length);
		fs.close();

		gdImagePtr im = gdImageCreateFromPngPtr(length, buffer);
		delete[] buffer;
		if( im == NULL )
		{
			errorCode = -3;
		}
		else
		{
			width = gdImageSX( im );
			height = gdImageSY( im );

			int len = width*height*4;

			for( int y = 0; y < height; y++)
			{
				for( int x = 0; x < width; x++)
				{
					int c = gdImageGetPixel( im, x, y );
					
					for( int i = 0; i < 3; i++ )
					{
						if(fOrder[cFilter][i] == ORDER_BLUE)		fileData.push_back( (unsigned char)gdImageBlue( im, c ) );
						else if(fOrder[cFilter][i] == ORDER_GREEN)	fileData.push_back( (unsigned char)gdImageGreen( im, c ) );
						else if(fOrder[cFilter][i] == ORDER_RED)	fileData.push_back( (unsigned char)gdImageRed( im, c ) );
						else if(fOrder[cFilter][i] == ORDER_ALPHA)	fileData.push_back( mAlpha?0xFF*(gdImageAlpha( im, c )/127):0xFF );
					}
				}
			}
			gdImageDestroy(im);
			errorCode = 0;
		}
	}
	else
	{
		errorCode = -2;
	}
}

void TextureImage::Compress( )
{
	u8 * pixels = new u8[width*height*4];

	for( int i = 0; i < fileData.size(); i++)
	{
		pixels[i] = fileData[i];
	}
	u8 * block = new u8[width*height/2];

	CompressImage( pixels, width, height, block, 0);

	fileData.clear();
	for( int i = 0; i < width*height/2; i++)
	{
		fileData.push_back(block[i]);
	}

	//squish::Compress
}

GdImgManager::GdImgManager( )
{

}

GdImgManager::~GdImgManager( )
{
	for( std::map<void *, gdImagePtr>::iterator i = mImages.begin(); i != mImages.end(); i++)
	{
		gdImageDestroy(&(*i->second));
	}
	mImages.clear();
}

void * GdImgManager::AddImage( lua_State * luaVM, int width, int height )
{
	void * ptr = lua_newuserdata(luaVM, 128);
	if( ptr != NULL )
	{
		gdImagePtr imgPtr = gdImageCreateTrueColor( width, height );
		if(imgPtr != NULL)
		{
			mImages[ptr] = imgPtr;
			return ptr;
		}
	}
	return NULL;
}

void * GdImgManager::AddImage( lua_State * luaVM, std::string rFilePath )
{
	void * ptr = lua_newuserdata(luaVM, 128);
	if( ptr != NULL )
	{
		FILE * in = fopen(rFilePath.c_str(), "rb");
		if( in != NULL )
		{
			gdImagePtr imgPtr = gdImageCreateFromPng( in );
			fclose(in);
			if(imgPtr != NULL)
			{
				mImages[ptr] = imgPtr;
				return ptr;
			}
		}
	}
	return NULL;
}

void GdImgManager::RemoveImage( void * userData )
{
	gdImagePtr im = GetImage(userData);
	if(im != NULL)
	{
		gdImageDestroy(im);
		mImages.erase( mImages.find( userData ) );
	}
}

gdImagePtr GdImgManager::GetImage( void * userData )
{
	std::map< void *, gdImagePtr >::iterator idx = mImages.find( userData );
	return (idx != mImages.end())?(idx->second):NULL;
}