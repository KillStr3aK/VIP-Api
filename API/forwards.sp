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
}

public void OnClientPostAdminCheck(int client)
{
    if(IsValidClient(client))
    {
        ESPlayers[client].Init(client);
        GetPlayerRank(ESPlayers[client]);
    }
}

public void OnClientDisconnect(int client)
{
    if(IsValidClient(client))
    {
        ESPlayers[client].Rank.Unset();
        delete ESPlayers[client].StateBag;
        delete ESPlayers[client].Features;
    }
}

public void OnPluginEnd()
{
    LogMsg(Debug, "Started shutting down session..");
    
    LogMsg(Debug, "Shutting down session finished!");
}