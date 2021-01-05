public APLRes AskPluginLoad2(Handle hPlugin, bool bLoad, char[] szError, int iMaxErr)
{
	RegPluginLibrary("VIP_API");

    CreateNative("VIP_RegisterModule", Native_RegisterModule);
	CreateNative("VIP_UnregisterModule", Native_UnregisterModule);

	CreateNative("VIP_GetFeatureState", Native_GetFeatureState);
	CreateNative("VIP_SetFeatureState", Native_SetFeatureState);

	CreateNative("VIP_SetFeatureValue", Native_SetFeatureValue);
	//CreateNative("VIP_SetFeatureValueString", Native_SetFeatureValueString);

	CreateNative("VIP_GetFeatureValue", Native_GetFeatureValue);
	//CreateNative("VIP_GetFeatureValueString", Native_GetFeatureValueString);
	return APLRes_Success;
}

public int Native_RegisterModule(Handle hPlugin, int iParams)
{
	ESFeature feature;
	GetNativeString(1, feature.DisplayName, sizeof(ESFeature::DisplayName));
	GetNativeString(2, feature.UniqueName, sizeof(ESFeature::UniqueName));
	feature.ModuleType = GetNativeCell(3);

	if(feature.ModuleType == SELECT)
	{
		return ThrowNativeError(0, "SELECT ModuleType is currently unsupported!");
	}

	feature.ValueType = GetNativeCell(4);

    if(!API.RegisterFeature(feature.UniqueName, feature))
	{
		return ThrowNativeError(0, "Couldn't register feature!");
	}

	API.InitializePlayers();
	return view_as<int>(LOADED);
}

public int Native_UnregisterModule(Handle hPlugin, int iParams)
{
	char szFeatureName[FEATURE_UNIQUE_LENGTH];
	GetNativeString(1, szFeatureName, sizeof(szFeatureName));
    API.UnregisterFeature(szFeatureName);
	API.InitializePlayers();
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

public int Native_SetFeatureValue(Handle hPlugin, int iParams)
{
	int client = GetNativeCell(1);

	if(!IsValidClient(client))
	{
		LogMsg(Error, "%i is van invalid client index!", client);
		return ThrowNativeError(0, "%i is van invalid client index!", client);
	}

	char szFeatureName[FEATURE_UNIQUE_LENGTH];
	GetNativeString(2, szFeatureName, sizeof(szFeatureName));
	ESPlayers[client].SetFeatureValue(szFeatureName, GetNativeCell(2));
	return 0;
}

public int Native_GetFeatureValue(Handle hPlugin, int iParams)
{
	int client = GetNativeCell(1);

	if(!IsValidClient(client))
	{
		LogMsg(Error, "%i is van invalid client index!", client);
		return ThrowNativeError(0, "%i is van invalid client index!", client);
	}

	char szFeatureName[FEATURE_UNIQUE_LENGTH];
	GetNativeString(2, szFeatureName, sizeof(szFeatureName));
	return view_as<int>(ESPlayers[client].GetFeatureValue(szFeatureName));
}

public int Native_SetFeatureValueString(Handle hPlugin, int iParams)
{
	int client = GetNativeCell(1);

	if(!IsValidClient(client))
	{
		LogMsg(Error, "%i is van invalid client index!", client);
		return ThrowNativeError(0, "%i is van invalid client index!", client);
	}

	char szFeatureName[FEATURE_UNIQUE_LENGTH];
	GetNativeString(2, szFeatureName, sizeof(szFeatureName));

	char szBuffer[FEATURE_UNIQUE_LENGTH];
	GetNativeString(3, szBuffer, sizeof(szBuffer));
	ESPlayers[client].SetFeatureValueString(szFeatureName, szBuffer);
	return 0;
}

public int Native_GetFeatureValueString(Handle hPlugin, int iParams)
{
	int client = GetNativeCell(1);

	if(!IsValidClient(client))
	{
		LogMsg(Error, "%i is van invalid client index!", client);
		return ThrowNativeError(0, "%i is van invalid client index!", client);
	}

	char szFeatureName[FEATURE_UNIQUE_LENGTH];
	GetNativeString(2, szFeatureName, sizeof(szFeatureName));

	char szBuffer[FEATURE_UNIQUE_LENGTH];
	GetNativeString(3, szBuffer, sizeof(szBuffer));
	ESPlayers[client].GetFeatureValueString(szFeatureName, szBuffer, GetNativeCell(4));
	return 0;
}