enum struct ESPlayer
{
    int         Index;
    int         UserId;
    float       Cooldown;
    ESVipRank   Rank;
    StringMap   Features; /* Contains data with type of ESFeatureContext */
    StringMap   StateBag; /* Contains any data, used for cache */

    void Init(int client)
    {
        if(this.StateBag != null) delete this.StateBag;

        this.Index = client;
        this.UserId = GetClientUserId(client);
        this.Cooldown = 0.0;
        this.StateBag = new StringMap();
        this.Rank.Unset();
    }

    void LoadFeatures()
    {
        if(this.Features != null) delete this.Features;
        this.Features = new StringMap();

        StringMapSnapshot Keys = this.Rank.Features.Snapshot();
        this.Features.Clear();

        if(Keys.Length == 0)
        {
            delete Keys;
            return;
        }

        char szBuffer[FEATURE_UNIQUE_LENGTH];
        for(int i = 0; i < Keys.Length; i++)
        {
            Keys.GetKey(i, szBuffer, sizeof(szBuffer));

            ESFeature feature;
            if(g_smFeatures.GetArray(szBuffer, feature, sizeof(feature)))
            {
                ESFeatureContext context;
                ToggleState state = this.LoadFeatureState(feature);

                context.Init(feature, state);
                this.Features.SetArray(feature.UniqueName, context, sizeof(context));
            }
        }

        delete Keys;
    }

    ToggleState LoadFeatureState(ESFeature feature)
    {
        if(feature.Cookie == null)
            return NO_ACCESS;

        if(!this.Rank.HasFeature(feature.UniqueName))
            return NO_ACCESS;

        char szTemp[6];
        feature.Cookie.Get(this.Index, szTemp, sizeof(szTemp));
        return view_as<ToggleState>(StringToInt(szTemp));
    }

    void SaveFeatureState(ESFeature feature, ToggleState state)
    {
        if(feature.Cookie == null)
            return;

        char szTemp[6];
        IntToString(view_as<int>(state), szTemp, sizeof(szTemp));
        feature.Cookie.Set(this.Index, szTemp);
    }

    bool GetFeature(const char[] szFeatureName, ESFeatureContext ctx)
    {
        return this.Features.GetArray(szFeatureName, ctx, sizeof(ctx));
    }

    ToggleState GetFeatureState(const char[] szFeatureName)
    {
        ESFeatureContext ctx;
        if(!this.GetFeature(szFeatureName, ctx))
            return NO_ACCESS;

        return ctx.State;
    }

    void SetFeatureState(const char[] szFeatureName, ToggleState state, bool save = true)
    {
        ESFeatureContext ctx;
        if(!this.GetFeature(szFeatureName, ctx))
        {
            LogMsg(Error, "Unable to SetFeatureState(%s, %i)", szFeatureName, state);
            return;
        }

        ctx.State = state;
        if(save) this.SaveFeatureState(ctx.Feature, state);
        this.UpdateContext(szFeatureName, ctx);
    }

    void UpdateContext(const char[] szFeatureName, ESFeatureContext context)
    {
        if(!this.Features.SetArray(szFeatureName, context, sizeof(context)))
        {
            LogMsg(Error, "Unable to UpdateContext(%s)", szFeatureName);
        }
    }
}

ESPlayer ESPlayers[MAXPLAYERS + 1];