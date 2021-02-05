public void MainMenu(ESPlayer user)
{
    Menu menu = new Menu(MainMenuHandler);

    char szTitle[255];
    Format(szTitle, sizeof(szTitle), "VIP System\nYour Rank: %s\nExpires: - (- days)\n \nMain Menu", user.Rank.DisplayName);
    menu.SetTitle(szTitle);

    menu.AddItem("0", "Manage Perks\n ", GetRankFeaturesCount(user.Rank) > 0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
    menu.AddItem("1", "Manage Rank", ITEMDRAW_DISABLED);
    menu.AddItem("2", "General Information\n ");
    menu.AddItem("3", "Admin Settings", CheckCommandAccess(user.Index, NULL_STRING, ADMFLAG_ROOT, true) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
    menu.Display(user.Index, MENU_TIME_FOREVER);
}

public void ListRanks(ESPlayer user)
{
    Menu menu = new Menu(RanklistHandler);
    menu.SetTitle("VIP System\nYour Rank: %s\nExpires: - (- days)\n \nAvailable Ranks", user.Rank.DisplayName);

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
    menu.SetTitle("VIP System\nYour Rank: %s\nExpires: - (- days)\n \nRank Details\nSelected Rank: %s\n ", user.Rank.DisplayName, rank.DisplayName);
    menu.AddItem("0", "Equip", strcmp(user.Rank.UniqueName, rank.UniqueName) == 0 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    menu.AddItem("1", "Features");
    menu.ExitBackButton = true;
    menu.Display(user.Index, MENU_TIME_FOREVER);
}

public void FeaturesMenu(ESPlayer user, ESVipRank rank)
{
    Menu menu = new Menu(FeaturesMenuHandler);
    menu.SetTitle("VIP System\nYour Rank: %s\nExpires: - (- days)\n \nManage Perks\nSelected Rank: %s\n ", user.Rank.DisplayName, rank.DisplayName);

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
            if(!ESFeatures.GetArray(szTemp, feature, sizeof(feature)))
            {
                LogMsg(Error, "%s is an invalid feature!", szTemp);
                continue;
            }

            menu.AddItem(feature.UniqueName, feature.DisplayName, ITEMDRAW_DISABLED);
        }
    }

    if(menu.ItemCount == 0)
    {
        int invalidFeatures = 0;
        GetRankFeaturesCount(rank, invalidFeatures);

        if(invalidFeatures > 0) menu.AddItem("", "Some features failed to load", ITEMDRAW_DISABLED);
        else menu.AddItem("", "This rank has no features", ITEMDRAW_DISABLED);
    }

    menu.ExitBackButton = true;
    menu.Display(user.Index, MENU_TIME_FOREVER);
    delete Keys;
}

public void FeatureDetails(ESPlayer user, ESFeatureContext context)
{
    Menu menu = new Menu(FeatureDetailsHandler);
    menu.SetTitle("VIP System\nYour Rank: %s\nExpires: - (- days)\n \nFeature Details\nSelected Feature: %s\nDescription: %s\n ", user.Rank.DisplayName, context.Feature.DisplayName, strcmp(context.Feature.Description, NULL_STRING) == 0 ? "No description" : context.Feature.Description);
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

public void PlayerList(ESPlayer user)
{
    Menu menu = new Menu(PlayerListHandler);
    menu.SetTitle("VIP System\nYour Rank: %s\nExpires: - (- days)\n \nManager User", user.Rank.DisplayName);
    
    for(int i = 1; i < MaxClients; i++)
    {
        if(!IsValidClient(i))
            continue;

        static char szBuffer[MAX_NAME_LENGTH + 1];
        Format(szBuffer, sizeof(szBuffer), "%N", i);
        menu.AddItem(IntToStr(i), szBuffer);
    }

    menu.ExitBackButton = true;
    menu.Display(user.Index, MENU_TIME_FOREVER);
}

public void ManageUser(ESPlayer user, ESPlayer target)
{
    Menu menu = new Menu(ManageUserHandler);
    menu.SetTitle("VIP System\nYour Rank: %s\nExpires: - (- days)\n \nSelected Player: %N (%s)", user.Rank.DisplayName, target.Index, target.Rank.DisplayName);

    if(target.Rank.Default)
    {
        menu.AddItem("0", "Give Rank");
    } else {
        menu.AddItem("1", "Extend Rank");
        menu.AddItem("2", "Delete Rank");
    }

    menu.ExitBackButton = true;
    menu.Display(user.Index, MENU_TIME_FOREVER);
}

public void SelectTime(ESPlayer user)
{
    Menu menu = new Menu(SelectTimeHandler);
    menu.SetTitle("VIP System\nYour Rank: %s\nExpires: - (- days)\n \nSelect Time Format", user.Rank.DisplayName);

    for(int i = 0; i < Time_Count; i++)
    {
        static char szTemp[12];
        GetTimeString(view_as<ETime>(i), szTemp, sizeof(szTemp));
        menu.AddItem(IntToStr(i), szTemp);
    }

    menu.ExitBackButton = true;
    menu.Display(user.Index, MENU_TIME_FOREVER);
}

public void SelectTimeAmount(ESPlayer user, ETime time)
{
    Menu menu = new Menu(SelectTimeAmountHandler);
    menu.SetTitle("VIP System\nYour Rank: %s\nExpires: - (- days)\n \nSelect Time Amount", user.Rank.DisplayName);

    for(int i = 1; i < 30; i++)
    {
        static char szTemp[12];
        GetTimeString(time, szTemp, sizeof(szTemp));
        Format(szTemp, sizeof(szTemp), "%i %s(s)", i, szTemp);
        menu.AddItem(IntToStr(i), szTemp);
    }

    menu.ExitBackButton = true;
    menu.Display(user.Index, MENU_TIME_FOREVER);
}

public void VerifyMenu(ESPlayer user, ESPlayer target, ESVipRank rank, ETime time, int amount)
{
    Menu menu = new Menu(VerifyMenuHandler);
    menu.SetTitle("VIP System\nYour Rank: %s\nExpires: - (- days)\n \nProceed?", user.Rank.DisplayName);
    
    char szBuffer[128];
    Format(szBuffer, sizeof(szBuffer), "Selected Player: %N (%s)", target.Index, target.Rank.DisplayName);
    menu.AddItem("", szBuffer, ITEMDRAW_DISABLED);

    Format(szBuffer, sizeof(szBuffer), "Selected Rank: %s", rank.DisplayName);
    menu.AddItem("", szBuffer, ITEMDRAW_DISABLED);

    static char szTemp[12];
    GetTimeString(time, szTemp, sizeof(szTemp));
    Format(szBuffer, sizeof(szBuffer), "Time: %i %s(s)\n ", amount, szTemp);
    menu.AddItem("", szBuffer, ITEMDRAW_DISABLED);

    menu.AddItem("1", "Give Rank");
    menu.AddItem("0", "Cancel");
    menu.ExitBackButton = true;
    menu.Display(user.Index, MENU_TIME_FOREVER);
}

public void VerifyDeleteMenu(ESPlayer user, ESPlayer target)
{
    Menu menu = new Menu(VerifyDeleteMenuHandler);
    menu.SetTitle("VIP System\nYour Rank: %s\nExpires: - (- days)\n \nProceed?", user.Rank.DisplayName);
    
    char szBuffer[128];
    Format(szBuffer, sizeof(szBuffer), "Selected Player: %N (%s)\n ", target.Index, target.Rank.DisplayName);
    menu.AddItem("", szBuffer, ITEMDRAW_DISABLED);

    menu.AddItem("1", "Delete Rank");
    menu.AddItem("0", "Cancel");

    menu.ExitBackButton = true;
    menu.Display(user.Index, MENU_TIME_FOREVER);
}
