#ifndef TEXTURECONTAINER_H_
#define TEXTURECONTAINER_H_

#include <map>

#include "ChunkInfo.hpp"
#include "TextureDictionary.hpp"

class TextureContainer
{
public:
	TextureContainer( );
	~TextureContainer( );
	
	int AddContainer( );

	bool HasMember( int index );

	std::map< int, TextureDictionary *> mContainers;

private:
	int mIndex;
};

#endif