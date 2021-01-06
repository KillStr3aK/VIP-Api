enum struct ESFeature
{
	Handle		Plugin;
	char		DisplayName[FEATURE_NAME_LENGTH];
	char		UniqueName[FEATURE_UNIQUE_LENGTH];
	char		Description[FEATURE_STRING_LENGTH];
	ModuleType	ModuleType;
	Cookie		Cookie;
	ModuleState	State;	
	/*ValueType	ValueType;

	void GetValueTypeString(char[] szOutput, int iSize)
	{
		switch(ValueType)
		{
			case INT: strcopy(szOutput, sizeof(iSize), "INT");
			case BOOL: strcopy(szOutput, sizeof(iSize), "BOOL");
			case STRING: strcopy(szOutput, sizeof(iSize), "STRING");
			case FLOAT: strcopy(szOutput, sizeof(iSize), "FLOAT");
			default: strcopy(szOutput, sizeof(iSize), "NULL");
		}
	}*/
}