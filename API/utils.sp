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