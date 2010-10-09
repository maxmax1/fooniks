#ifndef __MODULEFILEPATHS_H
#define __MODULEFILEPATHS_H

#include <stdio.h>
#include "include/ILuaModuleManager.h"

extern ILuaModuleManager10 *pModuleManager;

bool ParseResourcePathInput ( std::string strInput, std::string rName, std::string &strPath, std::string &strMetaPath );

#endif // __MODULEFILEPATHS_H