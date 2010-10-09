#include "ModuleFilePaths.h"
#include "extra/CLuaArguments.h"

bool IsWantedCharacter ( unsigned char c )
{
    // 32..126 are visible characters
    return c >= 32 && c <= 126;
}

bool IsControlCode ( unsigned char c )
{
    return c < 32;
}


bool IsValidFilePath ( const char *szDir )
{
    if ( szDir == NULL ) return false;

    unsigned int uiLen = strlen ( szDir );
    unsigned char c, c_d;

    // iterate through the char array
    for ( unsigned int i = 0; i < uiLen; i++ ) {
        c = szDir[i];                                       // current character
        c_d = ( i < ( uiLen - 1 ) ) ? szDir[i+1] : 0;       // one character ahead, if any
        if ( !IsWantedCharacter ( c ) || c == ':' || ( c == '.' && c_d == '.' ) || ( c == '\\' && c_d == '\\' ) )
            return false;
    }
    return true;
}

void ReplaceOccurrencesInString ( std::string &s, const char *a, const char *b )
{
    int idx = 0;
    while( (idx=s.find_first_of(a, idx)) >= 0 )
        s.replace(idx, 1, b);
}

bool ParseResourcePathInput ( std::string strInput, std::string rName, std::string &strPath, std::string &strMetaPath )
{
    ReplaceOccurrencesInString ( strInput, "\\", "/" );
    if ( strInput[0] == ':' )
    {
        unsigned int iEnd = strInput.find_first_of("/");
        if ( iEnd )
        {
            std::string strResourceName = strInput.substr(1,iEnd-1);
			lua_State * pResource = pModuleManager->GetResourceFromName( strResourceName.c_str() );

            if ( pResource != NULL && strInput[iEnd+1] )
            {
                strMetaPath = strInput.substr(iEnd+1);
                if ( IsValidFilePath ( strMetaPath.c_str() ) )
                {
                    strPath = std::string("./mods/deathmatch/resources/") + strResourceName + std::string("/") + strMetaPath;
                    return true;
                }
            }
        }
    }
    else if ( IsValidFilePath ( strInput.c_str() ) )
    {
		strPath = std::string("./mods/deathmatch/resources/") + rName + std::string("/") + strInput;
        strMetaPath = strInput;
        return true;
    }
    return false;
}