typedef RanksMenu = function void (ESPlayer user, ESVipRank rank);

public int MainMenuHandler(Menu menu, MenuAction menuAction, int param1, int param2)
{
    switch(menuAction)
    {
        case MenuAction_Select:
        {
            char szInfo[10];
            menu.GetItem(param2, szInfo, sizeof(szInfo));

            switch(StringToInt(szInfo))
            {
                case 0: FeaturesMenu(ESPlayers[param1], ESPlayers[param1].Rank);
                case 1: MainMenu(ESPlayers[param1]);
                case 2: MainMenu(ESPlayers[param1]);
                case 3: ListRanks(ESPlayers[param1]);
                case 4: AdminMenu(ESPlayers[param1]);
            }
        }

        case MenuAction_End: delete menu;
    }
}

public int RanklistHandler(Menu menu, MenuAction menuAction, int param1, int param2)
{
    switch(menuAction)
    {
        case MenuAction_Select:
        {
            char szInfo[RANK_UNIQUE_LENGTH];
            menu.GetItem(param2, szInfo, sizeof(szInfo));

            ESVipRank rank;
            if(API.GetRank(szInfo, rank))
            {
                ESPlayers[param1].StateBag.SetString("CachedRank", rank.UniqueName);
                RankDetails(ESPlayers[param1], rank);
            } else {
                LogMsg(Error, "Unable to get the details of %s", szInfo);
                PrintToChat(param1, "Something happened..");
            }
        }
        
        case MenuAction_Cancel:
        {
            if(param2 == MenuCancel_ExitBack)
            {
                MainMenu(ESPlayers[param1]);
            }
        }

        case MenuAction_End: delete menu;
    }
}

public int RankDetailsHandler(Menu menu, MenuAction menuAction, int param1, int param2)
{
    switch(menuAction)
    {
        case MenuAction_Select:
        {
            char szInfo[RANK_UNIQUE_LENGTH];
            menu.GetItem(param2, szInfo, sizeof(szInfo));

            char szUnique[RANK_UNIQUE_LENGTH];
            ESPlayers[param1].StateBag.GetString("CachedRank", szUnique, sizeof(szUnique));
            
            switch(StringToInt(szInfo))
            {
                case 0:
                {
                    if(API.SetRank(ESPlayers[param1], szUnique))
                    {
                        MainMenu(ESPlayers[param1]);
                        ESPlayers[param1].LoadFeatures();
                    } else {
                        LogMsg(Error, "Unable to set %N's rank to %s", param1, szUnique);
                        PrintToChat(param1, "Something happened..");
                    }
                }

                case 1: CallbackMenu(ESPlayers[param1], FeaturesMenu);
            }
        }

        case MenuAction_Cancel:
        {
            if(param2 == MenuCancel_ExitBack)
            {
                ListRanks(ESPlayers[param1]);
            }
        }

        case MenuAction_End: delete menu;
    }
}

public int FeaturesMenuHandler(Menu menu, MenuAction menuAction, int param1, int param2)
{
    switch(menuAction)
    {
        case MenuAction_Select:
        {
            char szInfo[FEATURE_UNIQUE_LENGTH];
            menu.GetItem(param2, szInfo, sizeof(szInfo));

            ESFeatureContext context;
            ESPlayers[param1].GetFeature(szInfo, context);
            FeatureDetails(ESPlayers[param1], context);
        }

        case MenuAction_Cancel:
        {
            if(param2 == MenuCancel_ExitBack)
            {
                CallbackMenu(ESPlayers[param1], RankDetails);
            }
        }

        case MenuAction_End: delete menu;
    }
}

public int FeatureDetailsHandler(Menu menu, MenuAction menuAction, int param1, int param2)
{
    switch(menuAction)
    {
        case MenuAction_Select:
        {
            char szInfo[FEATURE_UNIQUE_LENGTH];
            menu.GetItem(param2, szInfo, sizeof(szInfo));
            ESPlayers[param1].SetFeatureState(szInfo, ESPlayers[param1].GetFeatureState(szInfo) == ENABLED ? DISABLED : ENABLED);
            
            ESFeatureContext context;
            ESPlayers[param1].GetFeature(szInfo, context);
            FeatureDetails(ESPlayers[param1], context);
        }

        case MenuAction_Cancel:
        {
            if(param2 == MenuCancel_ExitBack)
            {
                CallbackMenu(ESPlayers[param1], RankDetails);
            }
        }

        case MenuAction_End: delete menu;
    }
}

public int AdminMenuHandler(Menu menu, MenuAction menuAction, int param1, int param2)
{
    switch(menuAction)
    {
        case MenuAction_Select:
        {
            char szInfo[10];
            menu.GetItem(param2, szInfo, sizeof(szInfo));

            switch(StringToInt(szInfo))
            {
                case 0: /*ManageUser*/AdminMenu(ESPlayers[param1]);
                case 1: /*DeleteUser*/AdminMenu(ESPlayers[param1]);
                case 2:
                {
                    ClientCommand(param1, "sm_refreshvip");
                    AdminMenu(ESPlayers[param1]);
                }
            }
        }

        case MenuAction_Cancel:
        {
            if(param2 == MenuCancel_ExitBack)
            {
                MainMenu(ESPlayers[param1]);
            }
        }

        case MenuAction_End: delete menu;
    }
}

static void CallbackMenu(ESPlayer user, RanksMenu menu)
{
    char szUnique[RANK_UNIQUE_LENGTH];
    user.StateBag.GetString("CachedRank", szUnique, sizeof(szUnique));
    
    ESVipRank rank;
    if(API.GetRank(szUnique, rank))
    {
        Call_StartFunction(INVALID_HANDLE, menu);
        Call_PushArray(user, sizeof(user));
        Call_PushArray(rank, sizeof(rank));
        Call_Finish();
    } else {
        LogMsg(Error, "Unable to call the callback function [%s (%s)]", rank.DisplayName, rank.UniqueName);
        PrintToChat(user.Index, "Something happened..");
    }
}

stock int GetRankFeaturesCount(ESVipRank esvr, bool validOnly = true)
{
	if(esvr.Features == null) return 0;

    StringMapSnapshot Keys = esvr.Features.Snapshot();
    if(Keys.Length == 0)
    {
        delete Keys;
        return 0;
    }

    int count = 0;
    char szBuffer[FEATURE_UNIQUE_LENGTH];
        
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