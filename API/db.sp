void InitializeDatabase()
{
    LogMsg(Info, "Connecting to database '%s'..", g_szDatabase);

    if(!SQL_CheckConfig(g_szDatabase))
    {
        LogMsg(Critical, "%s is not set in the databases.cfg!", g_szDatabase);
        SetFailState("%s is not set in the databases.cfg!", g_szDatabase);
        return;
    }

    Database.Connect(DatabaseCallback, g_szDatabase, 0);
}

public void DatabaseCallback(Database hDatabase, const char[] szError, any data)
{
	if (hDatabase == null || szError[0])
	{
        LogMsg(Critical, "Failed to connect to the database!\nError: %s", szError);
		SetFailState("Failed to connect to the database!\nError: %s", szError);
		return;
	}

	g_hDatabase = hDatabase;
	LogMsg(Info, "Successfully connected to the database!");
    LogMsg(Debug, "Initialization session done! Version: %s", PLUGIN_VERSION);
}