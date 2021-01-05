enum struct ESFeature
{
	char		DisplayName[FEATURE_NAME_LENGTH];
	char		UniqueName[FEATURE_UNIQUE_LENGTH];
	ModuleType	ModuleType;
	ValueType	ValueType;

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
	}
}