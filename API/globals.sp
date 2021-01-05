enum ConsoleVariables
{
    ConVar_Database = 0,
    ConVar_Ranks,
    ConVar_CommandVIP,
    ConVar_CommandRefreshCfg,
    ConVar_Cooldown,
    ConVar_Count
}

ConVar      Variables[ConVar_Count];
Database    g_hDatabase;

StringMap   g_smFeatures; /* Contains data with type of ESFeature */

int         g_iLogLevel = view_as<int>(LOG_LEVEL);

char        g_szRanks[PLATFORM_MAX_PATH];
char        g_szLogFile[PLATFORM_MAX_PATH];
char        g_szDatabase[SECTION_LENGTH];

char        g_szCommandVIP[COMMAND_LENGTH];
char        g_szRefreshCommand[COMMAND_LENGTH];