enum struct ESVipRank
{
    char        DisplayName[RANK_NAME_LENGTH];
    char        UniqueName[RANK_UNIQUE_LENGTH];
    bool        Enabled;
    bool        Default;
    bool        Hide;
    StringMap   Features; /* Contains feature unique names */

    void Unset()
    {
        this.DisplayName    = "None";
        this.UniqueName     = "none";
        this.Enabled        = false;
        this.Default        = false;
        this.Features       = new StringMap();
    }

    bool HasFeature(const char[] featureName)
    {
        char szTemp[FEATURE_UNIQUE_LENGTH];
        return this.Features.GetString(featureName, szTemp, sizeof(szTemp));
    }
}

//ESVipRank ESVipRanks[MAX_VIP_RANKS]; "unlimited" number of ranks
StringMap ESVipRanks; /* Contains data with type of ESVipRank */