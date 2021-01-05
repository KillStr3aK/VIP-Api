/* Plugin Header Directives */
#define PLUGIN_VERSION  "1.0-d"

/* Database Directives */
#define CHARSET         "utf8mb4"
#define COLLATION       "utf8mb4_unicode_ci"
#define SECTION_LENGTH  32

/* Debug Directives */
#define DEBUG_MODE      1

/* Log Directives */
#define LOG_TIMEFORMAT  "%Y-%m-%d_%H-%M"
#define LOG_FILEFORMAT  "logs/VIP/system_%s.log" /* Insufficient permission may cause errors */

#if DEBUG_MODE 1
    #define LOG_LEVEL   Debug
#else
    #define LOG_LEVEL   Warning
#endif

/* Other Directives */
#define COMMAND_LENGTH 16

/* Pragma Directives */
#pragma tabsize 0;
#pragma newdecls required;
#pragma semicolon 1;