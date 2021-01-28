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
                case 3: AdminMenu(ESPlayers[param1]);
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
                SelectTime(ESPlayers[param1]);
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

            ESPlayers[param1].StateBag.SetString("CachedRank", ESPlayers[param1].Rank.UniqueName);

            ESFeatureContext context;
            ESPlayers[param1].GetFeature(szInfo, context);
            FeatureDetails(ESPlayers[param1], context);
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
                CallbackMenu(ESPlayers[param1], FeaturesMenu);
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
                case 0: /*ManageUser*/PlayerList(ESPlayers[param1]);
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

public int PlayerListHandler(Menu menu, MenuAction menuAction, int param1, int param2)
{
    switch(menuAction)
    {
        case MenuAction_Select:
        {
            char szInfo[10];
            menu.GetItem(param2, szInfo, sizeof(szInfo));

            int target = StringToInt(szInfo);
            if(IsValidClient(target))
            {
                ESPlayers[param1].StateBag.SetValue("CachedTarget", target);
                ManageUser(ESPlayers[param1], ESPlayers[target]);
            } else {
                PlayerList(ESPlayers[param1]);
                PrintToChat(param1, "The selected player is no longer available.");
            }
        }

        case MenuAction_Cancel:
        {
            if(param2 == MenuCancel_ExitBack)
            {
                AdminMenu(ESPlayers[param1]);
            }
        }

        case MenuAction_End: delete menu;
    }
}

public int ManageUserHandler(Menu menu, MenuAction menuAction, int param1, int param2)
{
    switch(menuAction)
    {
        case MenuAction_Select:
        {
            char szInfo[10];
            menu.GetItem(param2, szInfo, sizeof(szInfo));

            switch(StringToInt(szInfo))
            {
                case 0: ListRanks(ESPlayers[param1]);
                case 1: /*ExtendRank*/AdminMenu(ESPlayers[param1]);
                case 2:
                {
                    int target = -1;
                    ESPlayers[param1].StateBag.GetValue("CachedTarget", target);
                    
                    if(IsValidClient(target)) VerifyDeleteMenu(ESPlayers[param1], ESPlayers[target]);
                    else {
                        PlayerList(ESPlayers[param1]);
                        PrintToChat(param1, "The selected player is no longer available.");
                    }
                }
            }
        }

        case MenuAction_Cancel:
        {
            if(param2 == MenuCancel_ExitBack)
            {
                PlayerList(ESPlayers[param1]);
            }
        }

        case MenuAction_End: delete menu;
    }
}

public int SelectTimeHandler(Menu menu, MenuAction menuAction, int param1, int param2)
{
    switch(menuAction)
    {
        case MenuAction_Select:
        {
            char szInfo[10];
            menu.GetItem(param2, szInfo, sizeof(szInfo));

            ETime timeFormat = view_as<ETime>(StringToInt(szInfo));
            ESPlayers[param1].StateBag.SetValue("CachedTime", timeFormat);
            SelectTimeAmount(ESPlayers[param1], timeFormat);
        }

        case MenuAction_Cancel:
        {
            if(param2 == MenuCancel_ExitBack)
            {
                int target = -1;
                ESPlayers[param1].StateBag.GetValue("CachedTarget", target);

                if(IsValidClient(target)) ManageUser(ESPlayers[param1], ESPlayers[target]);
                else {
                    PlayerList(ESPlayers[param1]);
                    PrintToChat(param1, "The selected player is no longer available.");
                }
            }
        }

        case MenuAction_End: delete menu;
    }
}

public int SelectTimeAmountHandler(Menu menu, MenuAction menuAction, int param1, int param2)
{
    switch(menuAction)
    {
        case MenuAction_Select:
        {
            char szInfo[10];
            menu.GetItem(param2, szInfo, sizeof(szInfo));

            int amount = StringToInt(szInfo);
            ESPlayers[param1].StateBag.SetValue("CachedAmount", amount);

            int target = -1;
            ESPlayers[param1].StateBag.GetValue("CachedTarget", target);
            if(IsValidClient(target))
            {
                char szUnique[RANK_UNIQUE_LENGTH];
                ESPlayers[param1].StateBag.GetString("CachedRank", szUnique, sizeof(szUnique));
                
                ESVipRank rank;
                if(API.GetRank(szUnique, rank))
                {
                    ETime timeFormat;
                    ESPlayers[param1].StateBag.GetValue("CachedTime", timeFormat);

                    VerifyMenu(ESPlayers[param1], ESPlayers[target], rank, timeFormat, amount);
                } else {
                    MainMenu(ESPlayers[param1]);
                    PrintToChat(param1, "Something happened..");
                    LogMsg(Error, "Unable to SelectTimeAmountHandler.API::GetRank()");
                }
            } else {
                PlayerList(ESPlayers[param1]);
                PrintToChat(param1, "The selected player is no longer available.");
            }
        }

        case MenuAction_Cancel:
        {
            if(param2 == MenuCancel_ExitBack)
            {
                int target = -1;
                ESPlayers[param1].StateBag.GetValue("CachedTarget", target);

                if(IsValidClient(target)) SelectTime(ESPlayers[param1]);
                else {
                    PlayerList(ESPlayers[param1]);
                    PrintToChat(param1, "The selected player is no longer available.");
                }
            }
        }

        case MenuAction_End: delete menu;
    }
}

public int VerifyMenuHandler(Menu menu, MenuAction menuAction, int param1, int param2)
{
    switch(menuAction)
    {
        case MenuAction_Select:
        {
            int target = -1;
            ESPlayers[param1].StateBag.GetValue("CachedTarget", target);

            if(IsValidClient(target))
            {
                char szInfo[10];
                menu.GetItem(param2, szInfo, sizeof(szInfo));
                switch(StringToInt(szInfo))
                {
                    case 0: ManageUser(ESPlayers[param1], ESPlayers[target]);
                    case 1:
                    {
                        char szUnique[RANK_UNIQUE_LENGTH];
                        ESPlayers[param1].StateBag.GetString("CachedRank", szUnique, sizeof(szUnique));
                        
                        ESVipRank rank;
                        if(API.GetRank(szUnique, rank))
                        {
                            ETime timeFormat;
                            ESPlayers[param1].StateBag.GetValue("CachedTime", timeFormat);

                            int amount;
                            ESPlayers[param1].StateBag.GetValue("CachedAmount", amount);

                            GivePlayerRank(ESPlayers[param1], ESPlayers[target], rank, timeFormat, amount);
                            MainMenu(ESPlayers[param1]);
                        } else {
                            MainMenu(ESPlayers[param1]);
                            PrintToChat(param1, "Something happened..");
                            LogMsg(Error, "Unable to VerifyMenuHandler.API::GetRank()");
                        }
                    }
                }
            } else {
                PlayerList(ESPlayers[param1]);
                PrintToChat(param1, "The selected player is no longer available.");
            }
        }

        case MenuAction_Cancel:
        {
            if(param2 == MenuCancel_ExitBack)
            {
                int target = -1;
                ESPlayers[param1].StateBag.GetValue("CachedTarget", target);

                if(IsValidClient(target))
                {
                    ETime timeFormat;
                    ESPlayers[param1].StateBag.GetValue("CachedTime", timeFormat);
                    SelectTimeAmount(ESPlayers[param1], timeFormat);
                } else {
                    PlayerList(ESPlayers[param1]);
                    PrintToChat(param1, "The selected player is no longer available.");
                }
            }
        }

        case MenuAction_End: delete menu;
    }
}

public int VerifyDeleteMenuHandler(Menu menu, MenuAction menuAction, int param1, int param2)
{
    switch(menuAction)
    {
        case MenuAction_Select:
        {
            int target = -1;
            ESPlayers[param1].StateBag.GetValue("CachedTarget", target);

            if(IsValidClient(target))
            {
                char szInfo[10];
                menu.GetItem(param2, szInfo, sizeof(szInfo));
                switch(StringToInt(szInfo))
                {
                    case 0: ManageUser(ESPlayers[param1], ESPlayers[target]);
                    case 1: {
                        RemovePlayerRank(ESPlayers[target]);
                        MainMenu(ESPlayers[param1]);
                    }
                }
            } else {
                PlayerList(ESPlayers[param1]);
                PrintToChat(param1, "The selected player is no longer available.");
            }
        }

        case MenuAction_Cancel:
        {
            if(param2 == MenuCancel_ExitBack)
            {
                int target = -1;
                ESPlayers[param1].StateBag.GetValue("CachedTarget", target);

                if(IsValidClient(target)) ManageUser(ESPlayers[param1], ESPlayers[target]);
                else {
                    PlayerList(ESPlayers[param1]);
                    PrintToChat(param1, "The selected player is no longer available.");
                }
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

stock int GetRankFeaturesCount(ESVipRank esvr, int& invalid = 0, bool validOnly = true)
{
	if(esvr.Features == null) return 0;

    StringMapSnapshot Keys = esvr.Features.Snapshot();
    if(Keys.Length == 0)
    {
        delete Keys;
        return 0;
    }

    int count = 0;
    invalid = 0;
    char szBuffer[FEATURE_UNIQUE_LENGTH];
        
    for(int i = 0; i < Keys.Length; i++)
    {
        Keys.GetKey(i, szBuffer, sizeof(szBuffer));
        if(validOnly && !API.IsValidFeature(szBuffer))
        {
            ++invalid;
            continue;
        }

        ++count;
    }

    delete Keys;
    return count;
}