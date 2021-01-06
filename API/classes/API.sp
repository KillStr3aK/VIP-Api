methodmap API < StringMap {
    public API()
    {
        StringMap StateBag = new StringMap();

        char szTime[128];
        FormatTime(szTime, sizeof(szTime), LOG_TIMEFORMAT, GetTime());
        BuildPath(Path_SM, g_szLogFile, sizeof(g_szLogFile), LOG_FILEFORMAT, szTime);
        LogMsg(Debug, "Started initializing session..");
        StateBag.SetValue("Loaded", false);
        return view_as<API>(StateBag);
    }

    public bool GetDefaultRank(ESVipRank esvr)
    {
        char szUnique[RANK_UNIQUE_LENGTH];
        if(!this.GetString("DefaultRank", szUnique, sizeof(szUnique)))
            return false;
        
        if(!ESVipRanks.GetArray(szUnique, esvr, sizeof(esvr)))
            return false;

        return true;
    }

    public bool IsLoaded()
    {
        bool bLoaded = false;
        this.GetValue("Loaded", bLoaded);
        return bLoaded;
    }

    public static bool GetRank(const char[] rankName, ESVipRank esvr)
    {
        return ESVipRanks.GetArray(rankName, esvr, sizeof(esvr));
    }

    public static bool SetRank(ESPlayer user, const char[] rankName)
    {
        return ESVipRanks.GetArray(rankName, user.Rank, sizeof(user.Rank));
    }

    public static int GetRankFeaturesCount(ESVipRank esvr, bool validOnly = true)
    {
        if(esvr.Features == null) return 0;

        StringMapSnapshot Keys = esvr.Features.Snapshot();
        if(Keys.Length == 0)
        {
            delete Keys;
            return 0;
        }

        int count = 0;
        for(int i = 0; i < Keys.Length; i++)
        {
            Keys.GetKey(i, szBuffer, sizeof(szBuffer));
            if(validOnly && !API.IsValidFeature(szBuffer))
                continue;

            ++count;
        }

        delete Keys;
        return count;
    }

    public static bool RegisterFeature(const char[] featureName, ESFeature feature)
    {
        if(g_smFeatures.SetArray(featureName, feature, sizeof(feature), false))
        {
            LogMsg(Info, "Registered a new module called %s", feature.DisplayName);
            return true;
        } else {
            LogMsg(Warning, "Module %s is already registered", feature.DisplayName);
            return false;
        }
    }

    public static bool SetFeatureState(const char[] featureName, ModuleState state)
    {
        ESFeature feature;
        if(g_smFeatures.GetArray(featureName, feature, sizeof(feature)))
        {
            feature.State = state;
            g_smFeatures.SetArray(featureName, feature, sizeof(feature));
            return true;
        }

        return false;
    }

    public static bool UnregisterFeature(const char[] featureName)
    {
        ESFeature feature;
        if(g_smFeatures.GetArray(featureName, feature, sizeof(feature)))
        {
            delete feature.Plugin;
            delete feature.Cookie;
            if(g_smFeatures.Remove(featureName))
            {
                LogMsg(Info, "Module %s has been unregistered!", feature.DisplayName);
                return true;
            }
        }

        LogMsg(Warning, "Tried to unregister %s but it was not registered!", featureName);
        return false;
    }

    public static bool IsValidFeature(const char[] featureName)
    {
        ESFeature feature;
        if(g_smFeatures.GetArray(featureName, feature, sizeof(feature)))
        {
            if(feature.Plugin == null) return false;
            if(strcmp(feature.UniqueName, NULL_STRING) == 0) return false;
            return feature.State == LOADED;
        }

        return false;
    }

    public static void InitializePlayers()
    {
        for(int i = 1; i <= MaxClients; i++)
        {
            if(!IsValidClient(i))
                continue;

            ESPlayers[i].LoadFeatures();
        }
    }
};

API Api = view_as<API>(NULL);