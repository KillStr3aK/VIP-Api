stock void LogMsg(const LogLevel logLevel = Debug, const char[] szMessage, any ...)
{
    if(view_as<int>(logLevel) < g_iLogLevel)
        return;

	static char szBuffer[512];
	VFormat(szBuffer, sizeof(szBuffer), szMessage, 3);
	LogToFile(g_szLogFile, szBuffer);
}