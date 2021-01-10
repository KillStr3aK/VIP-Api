stock bool IsValidClient(int client)
{
	if(client <= 0) return false;
	if(client > MaxClients) return false;
	if(!IsClientConnected(client)) return false;
	if(IsFakeClient(client)) return false;
	if(IsClientSourceTV(client)) return false;
	return IsClientInGame(client);
}

stock void PostCheckAll()
{
	for(int i = 1; i < MaxClients; i++)
    {
        OnClientPostAdminCheck(i);
    }
}

stock void RegCmd(const char[] szCommand, ConCmd conCallback, const char[] szDesc = "", int iFlags = 0)
{
	RegConsoleCmd(szCommand, conCallback, szDesc, iFlags);
	LogMsg(Debug, "Registered command %s", szCommand);
}

stock char IntToStr(const int num)
{
	char szTemp[10];
	IntToString(num, szTemp, sizeof(szTemp));
	return szTemp;
}

stock void GetTimeString(ETime time, char[] output, int size)
{
	switch(time)
	{
		case Time_Minute: strcopy(output, size, "Minute");
		case Time_Hour: strcopy(output, size, "Hour");
		case Time_Day: strcopy(output, size, "Day");
		case Time_Week: strcopy(output, size, "Week");
		case Time_Month: strcopy(output, size, "Month");
		case Time_Year: strcopy(output, size, "Year");
	}
}