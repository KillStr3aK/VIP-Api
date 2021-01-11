void CreateVariables()
{
    LogMsg(Debug, "Creating variables..");
    Variables[ConVar_Database] = CreateConVar("vip_api_database", "vip_api", "databases.cfg section name.");
    Variables[ConVar_Ranks] = CreateConVar("vip_ranks_file", "configs/vip_ranks.cfg", "Relative path to the ranks configuration file.");
    Variables[ConVar_CommandVIP] = CreateConVar("vip_command", "sm_vip", "Command to open the main menu.");
    Variables[ConVar_CommandRefreshCfg] = CreateConVar("vip_refresh_command", "sm_refreshvip", "Command to refresh the configuration file.");
    Variables[ConVar_Cooldown] = CreateConVar("vip_cooldown", "1.0", "Cooldown between actions.");
    Variables[ConVar_AutoDelete] = CreateConVar("vip_auto_delete", "1", "Automatically delete epxired ranks");
    AutoExecConfig(true, "VIP_API", "sourcemod");
    LogMsg(Debug, "Done!");
}

void LoadRanks()
{
    LogMsg(Debug, "Loading ranks..");
	KeyValues keyValues = new KeyValues("VipRanks");

    char szFilePath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, szFilePath, sizeof(szFilePath), g_szRanks);

    if(!keyValues.ImportFromFile(szFilePath))
    {
        LogMsg(Critical, "Ranks configuration file is missing! (%s)", szFilePath);
        delete keyValues;
        return;
    }

    if(!keyValues.GotoFirstSubKey(true))
    {
        LogMsg(Critical, "Ranks configuration file is empty! (%s)", szFilePath);
        delete keyValues;
        return;
    }

    ESVipRanks.Clear();
    bool foundDefault = false;

    do {
        ESVipRank vipRank;

        char szUnique[RANK_UNIQUE_LENGTH];
        keyValues.GetString("Unique", szUnique, sizeof(szUnique));

        if(ESVipRanks.GetArray(szUnique, vipRank, sizeof(vipRank)))
        {
            LogMsg(Error, "More than one rank has the '%s' Unique name!", szUnique);
            continue;
        }

        keyValues.GetSectionName(vipRank.DisplayName, sizeof(ESVipRank::DisplayName));
        strcopy(vipRank.UniqueName, sizeof(ESVipRank::UniqueName), szUnique);

        vipRank.Enabled = view_as<bool>(keyValues.GetNum("Enabled", 1));
        vipRank.Default = view_as<bool>(keyValues.GetNum("Default", 0));
        vipRank.Hide = view_as<bool>(keyValues.GetNum("Hide", 0));

        if(vipRank.Default)
        {
            if(foundDefault)
            {
                LogMsg(Critical, "Only one rank can be marked as default! (%s)", vipRank.UniqueName);
                SetFailState("Only one rank can be marked as default! (%s)", vipRank.UniqueName);
                delete keyValues;
                return;
            } else {
                foundDefault = true;
                Api.SetString("DefaultRank", vipRank.UniqueName);
            }
        }

        vipRank.Features = new StringMap();
        
        LogMsg(Debug, "Found rank %s [%s]", vipRank.DisplayName, vipRank.Enabled ? "Enabled" : "Disabled");

        if(keyValues.JumpToKey("Features", false))
        {
            if(keyValues.GotoFirstSubKey(false))
            {
                do {
                    char szBuffer[32];
                    keyValues.GetString(NULL_STRING, szBuffer, sizeof(szBuffer));

                    vipRank.Features.SetString(szBuffer, szBuffer);
                    LogMsg(Debug, "[%s] Enabled feature: %s", vipRank.DisplayName, szBuffer);
                } while(keyValues.GotoNextKey(false));

                keyValues.GoBack();
            } else {
                LogMsg(Debug, "%s has no features!", vipRank.DisplayName);
            }

            keyValues.GoBack();
        } else {
            LogMsg(Debug, "%s has no features!", vipRank.DisplayName);
        }

        ESVipRanks.SetArray(vipRank.UniqueName, vipRank, sizeof(vipRank));
    } while(keyValues.GotoNextKey(true));

    delete keyValues;
    PostCheckAll();
    LogMsg(Debug, "Done!");
}

void LoadPhrases()
{
    LogMsg(Debug, "Loading phrases..");
	LoadTranslations("common.phrases");
	LoadTranslations("core.phrases");
    LogMsg(Debug, "Done!");
}