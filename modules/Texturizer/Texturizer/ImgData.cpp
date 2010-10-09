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

void TextureImage::LoadImageToData( )
{
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
					
					fileData.push_back( (unsigned char)gdImageBlue( im, c ) );
					fileData.push_back( (unsigned char)gdImageGreen( im, c ) );
					fileData.push_back( (unsigned char)gdImageRed( im, c ) );
					fileData.push_back( 0xFF );
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
	/*u8 * pixels = new u8[width*height*4];

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
	}*/

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

gdImagePtr GdImgManager::GetImage( void * userData )
{
	std::map< void *, gdImagePtr >::iterator idx = mImages.find( userData );
	return (idx != mImages.end())?(idx->second):NULL;
}