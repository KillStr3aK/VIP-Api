public void MainMenu(ESPlayer user)
{
    Menu menu = new Menu(MainMenuHandler);

    char szTitle[255];
    Format(szTitle, sizeof(szTitle), "VIP System\nYour Permission: %s\nExpires: - (- days)\n", user.Rank.DisplayName);
    menu.SetTitle(szTitle);

    menu.AddItem("0", "Manage Features", API.GetRankFeaturesCount(user.Rank) > 0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
    menu.AddItem("1", "Manage Permission\n");
    menu.AddItem("2", "General Information");
    menu.AddItem("3", "Available Perks");
    menu.Display(user.Index, MENU_TIME_FOREVER);
}

public void ListRanks(ESPlayer user)
{
    Menu menu = new Menu(RanklistHandler);
    menu.SetTitle("Ranks");

    StringMapSnapshot Keys = ESVipRanks.Snapshot();
    if(Keys.Length == 0)
    {
        delete Keys;
        return;
    }

    char szBuffer[RANK_UNIQUE_LENGTH];
    for(int i = 0; i < Keys.Length; i++)
    {
        Keys.GetKey(i, szBuffer, sizeof(szBuffer));

        ESVipRank rank;
        ESVipRanks.GetArray(szBuffer, rank, sizeof(rank));

        if(!rank.Hide) menu.AddItem(rank.UniqueName, rank.DisplayName, rank.Enabled ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
    }

    menu.ExitBackButton = true;
    menu.Display(user.Index, MENU_TIME_FOREVER);
    delete Keys;
}

public void RankDetails(ESPlayer user, ESVipRank rank)
{
    Menu menu = new Menu(RankDetailsHandler);
    menu.SetTitle("Details\nRank: %s", rank.DisplayName);
    menu.AddItem("equip", "Equip", strcmp(user.Rank.UniqueName, rank.UniqueName) == 0 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    menu.AddItem("features", "Features");
    menu.ExitBackButton = true;
    menu.Display(user.Index, MENU_TIME_FOREVER);
}

public void FeaturesMenu(ESPlayer user, ESVipRank rank)
{
    Menu menu = new Menu(FeaturesMenuHandler);
    menu.SetTitle("Features\nRank: %s", rank.DisplayName);

    if(rank.Features == null)
        return;

    StringMapSnapshot Keys = rank.Features.Snapshot();
    if(Keys.Length == 0)
    {
        delete Keys;
        return;
    }

    char szBuffer[RANK_UNIQUE_LENGTH];
    char szTemp[RANK_NAME_LENGTH + 12];
    
    if(strcmp(user.Rank.UniqueName, rank.UniqueName) == 0)
    {
        for(int i = 0; i < Keys.Length; i++)
        {
            Keys.GetKey(i, szBuffer, sizeof(szBuffer));
            if(!API.IsValidFeature(szBuffer))
                continue;

            ESFeatureContext context;
            user.Features.GetArray(szBuffer, context, sizeof(context));
            
            Format(szTemp, sizeof(szTemp), "%s [%s]", context.Feature.DisplayName, user.GetFeatureState(context.Feature.UniqueName) == ENABLED ? "ON" : "OFF");
            menu.AddItem(context.Feature.UniqueName, szTemp);
        }
    } else {
        for(int i = 0; i < Keys.Length; i++)
        {
            Keys.GetKey(i, szBuffer, sizeof(szBuffer));
            rank.Features.GetString(szBuffer, szTemp, sizeof(szTemp));

            ESFeature feature;
            if(!g_smFeatures.GetArray(szTemp, feature, sizeof(feature)))
            {
                LogMsg(Error, "%s is an invalid feature!", szTemp);
                continue;
            }

            menu.AddItem(feature.UniqueName, feature.DisplayName, ITEMDRAW_DISABLED);
        }
    }

    if(menu.ItemCount == 0)
    {
        menu.AddItem("", "This rank has no features", ITEMDRAW_DISABLED);
    }

    menu.ExitBackButton = true;
    menu.Display(user.Index, MENU_TIME_FOREVER);
    delete Keys;
}