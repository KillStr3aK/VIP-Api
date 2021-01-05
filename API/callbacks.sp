public Action Command_VIP(int client, int args)
{
    if(!IsValidClient(client))
        return Plugin_Handled;

    float gameTime = GetGameTime();
    if(ESPlayers[client].Cooldown < gameTime)
    {
        MainMenu(ESPlayers[client]);
        ESPlayers[client].Cooldown = gameTime + Variables[ConVar_Cooldown].FloatValue;
    } else {
        PrintToChat(client, "Don't spam!");
    }

    return Plugin_Handled;
}

public Action Command_Refresh(int client, int args)
{
    if(!IsValidClient(client))
        return Plugin_Handled;

    float gameTime = GetGameTime();
    if(ESPlayers[client].Cooldown < gameTime)
    {
        LoadRanks();
        ESPlayers[client].Cooldown = gameTime + Variables[ConVar_Cooldown].FloatValue;
        LogMsg(Warning, "%N has refreshed the configuration file!", client);
    } else {
        PrintToChat(client, "Don't spam!");
    }

    return Plugin_Handled;
}