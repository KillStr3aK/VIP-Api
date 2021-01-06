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

static stock void DatabaseCallback(Database hDatabase, const char[] szError, any data)
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

    Api.SetValue("Loaded", true);
    PostCheckAll();

    Call_StartForward(APIForward[Forward_OnLoaded]);
    Call_Finish();
}

public void GetPlayerRank(const ESPlayer user)
{
    if(g_hDatabase == null)
    {
        if(!Api.GetDefaultRank(user.Rank))
        {
            LogMsg(Error, "Unable to set default rank for player %N", user.Index);
        }

        return;
    }

    char szSteamId[32];
    GetClientAuthId(user.Index, AuthId_Steam2, szSteamId, sizeof(szSteamId));

    char szQuery[256];
    Format(szQuery, sizeof(szQuery), "SELECT * FROM vip_api WHERE steamid = '%s'", szSteamId);
    g_hDatabase.Query(DB_LoadData, szQuery, user.Index);
}

static stock void DB_LoadData(Database db, DBResultSet results, const char[] error, int index)
{
    if(db == null || results == null)
    {
        LogMsg(Error, "DB_LoadData returned error: %s", error);
        return;
    }

    if(results.FetchRow())
    {
        int columnIndex;
        results.FieldNameToNum("rank_unique", columnIndex);

        char szUnique[RANK_UNIQUE_LENGTH];
        results.FetchString(columnIndex, szUnique, sizeof(szUnique));
        if(!API.SetRank(ESPlayers[index], szUnique))
        {
            LogMsg(Error, "Unable to SetRank(%s) for player %N (Rank does not exist, or failed to load)", szUnique, index);
            if(!Api.GetDefaultRank(ESPlayers[index].Rank))
            {
                LogMsg(Error, "Unable to set default rank for player %N", index);
            }
        }
    } else {
        if(!Api.GetDefaultRank(ESPlayers[index].Rank))
        {
            LogMsg(Error, "Unable to set default rank for player %N", index);
        }
    }

    ESPlayers[index].LoadFeatures();

    Call_StartForward(APIForward[Forward_ClientLoaded]);
    Call_PushCell(index);
    Call_PushString(ESPlayers[index].Rank.DisplayName);
    Call_PushString(ESPlayers[index].Rank.UniqueName);
    Call_Finish();
}