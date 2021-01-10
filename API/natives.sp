public APLRes AskPluginLoad2(Handle hPlugin, bool bLoad, char[] szError, int iMaxErr)
{
	RegPluginLibrary("VIP_API");

	CreateNative("VIP_GetVersion", Native_Version);
	CreateNative("VIP_IsLoaded", Native_IsLoaded);
	CreateNative("VIP_IsFeatureLoaded", Native_IsFeatureLoaded);

    CreateNative("VIP_RegisterModule", Native_RegisterModule);
	CreateNative("VIP_UnregisterModule", Native_UnregisterModule);

	CreateNative("VIP_GetFeatureState", Native_GetFeatureState);
	CreateNative("VIP_SetFeatureState", Native_SetFeatureState);

	APIForward[Forward_OnLoaded]		= new GlobalForward("VIP_OnLoaded",				ET_Ignore);
	APIForward[Forward_ModuleAdded]		= new GlobalForward("VIP_OnFeatureRegistered",	ET_Ignore, Param_String, Param_String, Param_String, Param_Cell);
	APIForward[Forward_ModuleRemoved]	= new GlobalForward("VIP_OnFeatureRemoved",		ET_Ignore, Param_String, Param_String, Param_String, Param_Cell);
	APIForward[Forward_ClientLoaded]	= new GlobalForward("VIP_OnClientLoaded",		ET_Ignore, Param_Cell,	 Param_String, Param_String);
	return APLRes_Success;
}

public int Native_Version(Handle plugin, int params)
{
	return PLUGIN_INT_VERSION;
}

public int Native_IsLoaded(Handle hPlugin, int iParams)
{
	return Api.IsLoaded();
}

public int Native_IsFeatureLoaded(Handle hPlugin, int iParams)
{
	char szUnique[RANK_UNIQUE_LENGTH];
	GetNativeString(1, szUnique, sizeof(szUnique));
	return API.IsValidFeature(szUnique);
}

public int Native_RegisterModule(Handle hPlugin, int iParams)
{
	ESFeature feature;
	feature.Plugin = hPlugin;
	GetNativeString(1, feature.DisplayName, sizeof(ESFeature::DisplayName));
	GetNativeString(2, feature.UniqueName, sizeof(ESFeature::UniqueName));
	GetNativeString(3, feature.Description, sizeof(ESFeature::Description));
	feature.ModuleType = GetNativeCell(4);
	feature.State = NOT_LOADED;
	feature.Cookie = new Cookie(feature.UniqueName, feature.Description, CookieAccess_Private);

	if(feature.ModuleType == SELECT)
	{
		return ThrowNativeError(0, "'SELECT' ModuleType is currently unsupported!");
	}

    if(!API.RegisterFeature(feature.UniqueName, feature))
	{
		return ThrowNativeError(0, "Couldn't register feature %s!", feature.UniqueName);
	}

	API.SetFeatureState(feature.UniqueName, LOADED);
	API.InitializePlayers();

	ModuleRegisteredCallback cb = view_as<ModuleRegisteredCallback>(GetNativeFunction(5));
	if(cb != INVALID_FUNCTION)
	{
		Call_StartFunction(hPlugin, cb);
		Call_Finish();
	}

	Call_StartForward(APIForward[Forward_ModuleAdded]);
    Call_PushString(feature.DisplayName);
	Call_PushString(feature.UniqueName);
	Call_PushString(feature.Description);
	Call_PushCell(feature.ModuleType);
    Call_Finish();
	return view_as<int>(LOADED);
}

public int Native_UnregisterModule(Handle hPlugin, int iParams)
{
	char szFeatureName[FEATURE_UNIQUE_LENGTH];
	GetNativeString(1, szFeatureName, sizeof(szFeatureName));
    if(!API.UnregisterFeature(szFeatureName))
	{
		return ThrowNativeError(0, "Couldn't unregister feature %s!", szFeatureName);
	}

	API.InitializePlayers();

	Call_StartForward(APIForward[Forward_ModuleRemoved]);
    Call_PushString(szFeatureName);
    Call_Finish();
	return 0;
}

public int Native_GetFeatureState(Handle hPlugin, int iParams)
{
	int client = GetNativeCell(1);

	if(!IsValidClient(client))
	{
		LogMsg(Error, "%i is van invalid client index!", client);
		return ThrowNativeError(0, "%i is van invalid client index!", client);
	}

	char szFeatureName[FEATURE_UNIQUE_LENGTH];
	GetNativeString(2, szFeatureName, sizeof(szFeatureName));
	return view_as<int>(ESPlayers[client].GetFeatureState(szFeatureName));
}

public int Native_SetFeatureState(Handle hPlugin, int iParams)
{
	int client = GetNativeCell(1);

	if(!IsValidClient(client))
	{
		LogMsg(Error, "%i is van invalid client index!", client);
		return ThrowNativeError(0, "%i is van invalid client index!", client);
	}

	char szFeatureName[FEATURE_UNIQUE_LENGTH];
	GetNativeString(2, szFeatureName, sizeof(szFeatureName));
	ESPlayers[client].SetFeatureState(szFeatureName, view_as<ToggleState>(GetNativeCell(3)));
	return 0;
}