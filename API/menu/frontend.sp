public void MainMenu(ESPlayer user)
{
    Menu menu = new Menu(MainMenuHandler);

    char szTitle[255];
    Format(szTitle, sizeof(szTitle), "VIP System\nYour Rank: %s\nExpires: - (- days)\n ", user.Rank.DisplayName);
    menu.SetTitle(szTitle);

    menu.AddItem("0", "Manage Perks", GetRankFeaturesCount(user.Rank) > 0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
    menu.AddItem("1", "Manage Rank\n ");
    menu.AddItem("2", "General Information");
    menu.AddItem("3", "Available Ranks\n ");
    menu.AddItem("4", "Admin Settings", CheckCommandAccess(user.Index, NULL_STRING, ADMFLAG_ROOT, true) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
    menu.Display(user.Index, MENU_TIME_FOREVER);
}

public void ListRanks(ESPlayer user)
{
    Menu menu = new Menu(RanklistHandler);
    menu.SetTitle("VIP System\nYour Rank: %s\nExpires: - (- days)\n ", user.Rank.DisplayName);

    StringMapSnapshot Keys = ESVipRanks.Snapshot();
    char szBuffer[RANK_UNIQUE_LENGTH];

    for(int i = 0; i < Keys.Length; i++)
    {
        Keys.GetKey(i, szBuffer, sizeof(szBuffer));

        ESVipRank rank;
        ESVipRanks.GetArray(szBuffer, rank, sizeof(rank));

        if(!rank.Hide) menu.AddItem(rank.UniqueName, rank.DisplayName, rank.Enabled ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
    }

    if(menu.ItemCount == 0)
    {
        menu.AddItem("", "Rank configuration is empty!", ITEMDRAW_DISABLED);
    }

    menu.ExitBackButton = true;
    menu.Display(user.Index, MENU_TIME_FOREVER);
    delete Keys;
}

public void RankDetails(ESPlayer user, ESVipRank rank)
{
    Menu menu = new Menu(RankDetailsHandler);
    menu.SetTitle("VIP System\nYour Rank: %s\nExpires: - (- days)\n \nSelected Rank: %s\n ", user.Rank.DisplayName, rank.DisplayName);
    menu.AddItem("0", "Equip", strcmp(user.Rank.UniqueName, rank.UniqueName) == 0 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    menu.AddItem("1", "Features");
    menu.ExitBackButton = true;
    menu.Display(user.Index, MENU_TIME_FOREVER);
}

public void FeaturesMenu(ESPlayer user, ESVipRank rank)
{
    Menu menu = new Menu(FeaturesMenuHandler);
    menu.SetTitle("VIP System\nYour Rank: %s\nExpires: - (- days)\n \nSelected Rank: %s\n ", user.Rank.DisplayName, rank.DisplayName);

    if(rank.Features == null)
        return;

    StringMapSnapshot Keys = rank.Features.Snapshot();
    char szBuffer[FEATURE_UNIQUE_LENGTH];
    
    if(strcmp(user.Rank.UniqueName, rank.UniqueName) == 0)
    {
        for(int i = 0; i < Keys.Length; i++)
        {
            Keys.GetKey(i, szBuffer, sizeof(szBuffer));
            if(!API.IsValidFeature(szBuffer))
                continue;

            ESFeatureContext context;
            user.Features.GetArray(szBuffer, context, sizeof(context));
            menu.AddItem(context.Feature.UniqueName, context.Feature.DisplayName);
        }
    } else {
        char szTemp[RANK_NAME_LENGTH + 12];

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

public void FeatureDetails(ESPlayer user, ESFeatureContext context)
{
    Menu menu = new Menu(FeatureDetailsHandler);
    menu.SetTitle("VIP System\nYour Rank: %s\nExpires: - (- days)\n \nSelected Feature: %s\nDescription: %s\n ", user.Rank.DisplayName, context.Feature.DisplayName, strcmp(context.Feature.Description, NULL_STRING) == 0 ? "No description" : context.Feature.Description);
    menu.AddItem(context.Feature.UniqueName, user.GetFeatureState(context.Feature.UniqueName) == ENABLED ? "Disable" : "Enable");
    menu.ExitBackButton = true;
    menu.Display(user.Index, MENU_TIME_FOREVER);
}

public void AdminMenu(ESPlayer user)
{
    Menu menu = new Menu(AdminMenuHandler);
    menu.SetTitle("VIP System\nYour Rank: %s\nExpires: - (- days)\n \nAdmin Settings", user.Rank.DisplayName);
    menu.AddItem("0", "Manage User");
    menu.AddItem("1", "Delete User\n ");
    menu.AddItem("2", "Refresh Config");
    menu.ExitBackButton = true;
    menu.Display(user.Index, MENU_TIME_FOREVER);
}