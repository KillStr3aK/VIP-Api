enum EConsoleVariables
{
    ConVar_Database = 0,
    ConVar_Ranks,
    ConVar_CommandVIP,
    ConVar_CommandRefreshCfg,
    ConVar_Cooldown,
    ConVar_AutoDelete,
    ConVar_Count
}

enum EForwards {
    Forward_OnUnloaded = 0,
    Forward_OnLoaded,
    Forward_ModuleAdded,
    Forward_ModuleRemoved,
    Forward_ClientLoaded,
    Forward_Count
}

enum ETime {
    Time_Minute = 0,
    Time_Hour,
    Time_Day,
    Time_Week,
    Time_Month,
    Time_Year,
    Time_Count
}