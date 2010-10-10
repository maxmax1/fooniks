cmake_minimum_required (VERSION 2.6 FATAL_ERROR)

project (Texturizer)

# The version number.
set (Texturizer_VERSION_MAJOR 1)
set (Texturizer_VERSION_MINOR 0)

if (TXD_VERSION_MAJOR)
set (Texturizer_VERSION_MAJOR ${TXD_VERSION_MAJOR})
endif (TXD_VERSION_MAJOR)

if (TXD_VERSION_MINOR)
set (Texturizer_VERSION_MINOR ${TXD_VERSION_MINOR})
endif (TXD_VERSION_MINOR)

message(STATUS "Version Set To: ${Texturizer_VERSION_MAJOR}.${Texturizer_VERSION_MINOR}")

configure_file (
  "${PROJECT_SOURCE_DIR}/AppVersion.h.in"
  "${PROJECT_BINARY_DIR}/AppVersion.h"
  )

include_directories("${PROJECT_BINARY_DIR}")

find_package(GD REQUIRED)
include_directories(${GD_INCLUDE_DIR})
set(LIBS ${LIBS} ${GD_LIBRARIES})

find_package(SQUISH)
include_directories(${SQUISH_INCLUDE_DIR})
set(LIBS ${LIBS} ${SQUISH_LIBRARIES})

message(STATUS "Found gd: ${GD_INCLUDE_DIR}")
message(STATUS "Found squish: ${SQUISH_INCLUDE_DIR}")
 
add_subdirectory (TextureWriter)
add_subdirectory (Texturizer)