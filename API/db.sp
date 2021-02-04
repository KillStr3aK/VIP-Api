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

    g_hDatabase.Query(DB_TableCreate, "CREATE TABLE IF NOT EXISTS `vip_api` ( \
        `ID` int(11) NOT NULL, \
        `playername` varchar(128) COLLATE " ... COLLATION ... " NOT NULL, \
        `steamid` varchar(20) COLLATE " ... COLLATION ... " NOT NULL, \
        `rank_unique` varchar(16) COLLATE " ... COLLATION ... " NOT NULL, \
        `insert_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, \
        `expire_date` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00', \
        `admin` varchar(128) COLLATE " ... COLLATION ... " NOT NULL DEFAULT 'SYSTEM', \
        PRIMARY KEY (`ID`), \
  	UNIQUE KEY `steamid` (`steamid`)  \
        ) ENGINE=InnoDB  DEFAULT CHARSET=" ... CHARSET ... " COLLATE=" ... COLLATION ... " AUTO_INCREMENT=1;");
    LogMsg(Debug, "Initialization session done! Version: %s", PLUGIN_VERSION);

    Api.SetValue("Loaded", true);
    PostCheckAll();

    Call_StartForward(APIForward[Forward_OnLoaded]);
    Call_Finish();
}

static stock void DB_TableCreate(Database hOwner, DBResultSet hResult, const char[] szError, any data)
{
	if (szError[0])
	{
		SetFailState("DB_TableCreate: %s", szError);
		return;
	}

	g_hDatabase.Query(DB_ErrorCheck, "SET NAMES '" ... CHARSET ... "'");
	g_hDatabase.Query(DB_ErrorCheck, "SET CHARSET '" ... CHARSET ... "'");

	g_hDatabase.SetCharset(CHARSET);
}

static stock void DB_ErrorCheck(Database hOwner, DBResultSet hResult, const char[] szError, any data)
{
	if (szError[0])
	{
		LogError("DB_ErrorCheck: %s", szError);
	}
}

public void GetPlayerRank(ESPlayer user)
{
    if(g_hDatabase == null)
    {
        SetDefaultRank(user);
        return;
    }

    char szSteamId[20];
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

    char szUnique[RANK_UNIQUE_LENGTH];
    if(results.FetchRow())
    {
        int columnIndex;
        results.FieldNameToNum("rank_unique", columnIndex);
        results.FetchString(columnIndex, szUnique, sizeof(szUnique));

        if(!API.SetRank(ESPlayers[index], szUnique))
        {
            LogMsg(Error, "Unable to SetRank(%s) for player %N (Rank does not exist, or failed to load)", szUnique, index);
            SetDefaultRank(ESPlayers[index]);
        }
    } else {
        SetDefaultRank(ESPlayers[index]);
    }

    ESPlayers[index].LoadFeatures();

    Call_StartForward(APIForward[Forward_ClientLoaded]);
    Call_PushCell(index);
    Call_PushString(ESPlayers[index].Rank.DisplayName);
    Call_PushString(ESPlayers[index].Rank.UniqueName);
    Call_Finish();
}

static stock void SetDefaultRank(ESPlayer user)
{
	char szUnique[RANK_UNIQUE_LENGTH];
	if(!Api.GetString("DefaultRank", szUnique, sizeof(szUnique)) || !API.SetRank(user, szUnique))
    {
        LogMsg(Error, "Unable to set default rank for player %N", user.Index);
    }
}

public void RemovePlayerRank(ESPlayer user)
{
    char szSteamId[20];
    GetClientAuthId(user.Index, AuthId_Steam2, szSteamId, sizeof(szSteamId));

	char szQuery[256];
	Format(szQuery, sizeof(szQuery), "DELETE FROM `vip_api` WHERE `steamid` = '%s';", szSteamId);
	g_hDatabase.Query(DB_RemoveRank, szQuery, user.Index);
}

public void DB_RemoveRank(Database hOwner, DBResultSet hResult, const char[] szError, int index)
{
	if (szError[0])
	{
		LogMsg(Error, "DB_RemoveRank: %s", szError);
		return;
	}

    OnClientDisconnect(index);
    OnClientPostAdminCheck(index);
}

public void GivePlayerRank(ESPlayer user, ESPlayer target, ESVipRank rank, ETime time, int amount)
{
    char szSteamId[20];
    GetClientAuthId(target.Index, AuthId_Steam2, szSteamId, sizeof(szSteamId));

    char szInterval[12];
    GetTimeString(time, szInterval, sizeof(szInterval));

    int length = strlen(szInterval);
    for(int i = 1; i < length; i++) //The first letter is always uppercase
    {
        //if(IsCharLower(szInterval[i]))
        szInterval[i] = CharToUpper(szInterval[i]);
    }

	char szQuery[256];
	Format(szQuery, sizeof(szQuery), "INSERT INTO `vip_api` (`ID`, `playername`, `steamid`, `rank_unique`, `insert_date`, `expire_date`, `admin`) VALUES (NULL, '%N', '%s', '%s', CURRENT_TIMESTAMP, DATE_ADD(NOW(), INTERVAL %i %s), '%N') ON DUPLICATE KEY UPDATE `rank_unique` = %s;", target.Index, szSteamId, rank.UniqueName, amount, szInterval, user.Index, rank.UniqueName);
	g_hDatabase.Query(DB_GiveRank, szQuery, target.Index);
}

public void DB_GiveRank(Database hOwner, DBResultSet hResult, const char[] szError, int index)
{
	if (szError[0])
	{
		LogMsg(Error, "DB_GiveRank: %s", szError);
		return;
	}

    OnClientDisconnect(index);
    OnClientPostAdminCheck(index);
}
