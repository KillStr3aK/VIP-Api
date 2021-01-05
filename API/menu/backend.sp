typedef RanksMenu = function void(ESPlayer user, ESVipRank rank);

public int MainMenuHandler(Menu menu, MenuAction menuAction, int param1, int param2)
{
    if(menuAction == MenuAction_Select)
    {
        char szInfo[10];
        menu.GetItem(param2, szInfo, sizeof(szInfo));
        
        if(strcmp(szInfo, "ranks") == 0)
        {
            ListRanks(ESPlayers[param1]);
        }
    } else if(menuAction == MenuAction_End)
    {
        delete menu;
    }
}

public int RanklistHandler(Menu menu, MenuAction menuAction, int param1, int param2)
{
    if(menuAction == MenuAction_Select)
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
    } else if(menuAction == MenuAction_Cancel)
    {
        if(param2 == MenuCancel_ExitBack)
        {
            MainMenu(ESPlayers[param1]);
        }
    } else if(menuAction == MenuAction_End)
    {
        delete menu;
    }
}

public int RankDetailsHandler(Menu menu, MenuAction menuAction, int param1, int param2)
{
    if(menuAction == MenuAction_Select)
    {
        char szInfo[RANK_UNIQUE_LENGTH];
        menu.GetItem(param2, szInfo, sizeof(szInfo));

        char szUnique[RANK_UNIQUE_LENGTH];
        ESPlayers[param1].StateBag.GetString("CachedRank", szUnique, sizeof(szUnique));
        
        if(strcmp(szInfo, "equip") == 0)
        {
            if(API.SetRank(ESPlayers[param1], szUnique))
            {
                MainMenu(ESPlayers[param1]);
                ESPlayers[param1].LoadFeatures();
            } else {
                LogMsg(Error, "Unable to set %N's rank to %s", param1, szUnique);
                PrintToChat(param1, "Something happened..");
            }
        } else {
            CallbackMenu(ESPlayers[param1], FeaturesMenu);
        }
    } else if(menuAction == MenuAction_Cancel)
    {
        if(param2 == MenuCancel_ExitBack)
        {
            ListRanks(ESPlayers[param1]);
        }
    } else if(menuAction == MenuAction_End)
    {
        delete menu;
    }
}

public int FeaturesMenuHandler(Menu menu, MenuAction menuAction, int param1, int param2)
{
    if(menuAction == MenuAction_Select)
    {
        char szInfo[RANK_UNIQUE_LENGTH];
        menu.GetItem(param2, szInfo, sizeof(szInfo));
        ESPlayers[param1].SetFeatureState(szInfo, ESPlayers[param1].GetFeatureState(szInfo) == ENABLED ? DISABLED : ENABLED);
        CallbackMenu(ESPlayers[param1], FeaturesMenu);
    } else if(menuAction == MenuAction_Cancel)
    {
        if(param2 == MenuCancel_ExitBack)
        {
            CallbackMenu(ESPlayers[param1], RankDetails);
        }
    } else if(menuAction == MenuAction_End)
    {
        delete menu;
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

/*
else if(menuAction == MenuAction_Cancel)
{
    if(param2 == MenuCancel_ExitBack)
    {
        //openPreviousMenu();
    }
}
*/