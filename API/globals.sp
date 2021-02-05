ConVar      Variables[ConVar_Count];
Database    g_hDatabase;

StringMap   ESFeatures; /* Contains data with type of ESFeature */

int         g_iLogLevel = view_as<int>(LOG_LEVEL);

char        g_szRanks[PLATFORM_MAX_PATH];
char        g_szLogFile[PLATFORM_MAX_PATH];
char        g_szDatabase[SECTION_LENGTH];

char        g_szCommandVIP[COMMAND_LENGTH];
char        g_szRefreshCommand[COMMAND_LENGTH];

GlobalForward APIForward[Forward_Count];