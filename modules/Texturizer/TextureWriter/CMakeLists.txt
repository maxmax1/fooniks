SET( txdw_SRCS pstdint.h ChunkInfo.hpp TextureDictionary.hpp TextureDictionary.cpp TextureInfo.hpp TextureInfo.cpp)

ADD_LIBRARY( TextureWriter STATIC ${txdw_SRCS} )