public void OnConfigsExecuted()
{
    LogMsg(Debug, "Loading variables..");
    Variables[ConVar_Database].GetString(g_szDatabase, sizeof(g_szDatabase));
    Variables[ConVar_Ranks].GetString(g_szRanks, sizeof(g_szRanks));
    Variables[ConVar_CommandVIP].GetString(g_szCommandVIP, sizeof(g_szCommandVIP));
    Variables[ConVar_CommandRefreshCfg].GetString(g_szRefreshCommand, sizeof(g_szRefreshCommand));
    LogMsg(Debug, "Done!");

    RegCmd(g_szCommandVIP, Command_VIP);
    RegCmd(g_szRefreshCommand, Command_Refresh);

    LoadRanks();
    InitializeDatabase();
    PostCheckAll();
}

public void OnClientPostAdminCheck(int client)
{
    if(IsValidClient(client))
    {
        ESPlayers[client].Init(client);
        Api.GetDefaultRank(ESPlayers[client].Rank);
    }
}

public void OnClientDisconnect(int client)
{
    if(IsValidClient(client))
        delete ESPlayers[client].Features;
}

public void OnAllPluginsLoaded()
{
}

public void OnPluginEnd()
{
    LogMsg(Debug, "Started shutting down session..");
    delete g_smFeatures;
    delete ESVipRanks;
    LogMsg(Debug, "Shutting down session finished!");
}