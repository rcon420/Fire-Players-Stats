// Forvards
static Handle	g_hGlobalForvard_OnFPSStatsLoaded,
				g_hGlobalForvard_OnFPSDatabaseConnected,
				g_hGlobalForvard_OnFPSDatabaseLostConnection,
				g_hGlobalForvard_OnFPSClientLoaded,
				g_hGlobalForvard_OnFPSPointsChangePre,
				g_hGlobalForvard_OnFPSPointsChange,
				g_hGlobalForvard_OnFPSPlayerPosition;
#if USE_RANKS == 1
	static Handle	g_hGlobalForvard_OnFPSLevelChange;
#endif

void CreateGlobalForwards()
{
	g_hGlobalForvard_OnFPSStatsLoaded				= CreateGlobalForward("FPS_OnFPSStatsLoaded",			ET_Ignore);
	g_hGlobalForvard_OnFPSDatabaseConnected			= CreateGlobalForward("FPS_OnDatabaseConnected",		ET_Ignore,	Param_Cell);
	g_hGlobalForvard_OnFPSDatabaseLostConnection	= CreateGlobalForward("FPS_OnDatabaseLostConnection",	ET_Ignore);
	g_hGlobalForvard_OnFPSClientLoaded				= CreateGlobalForward("FPS_OnClientLoaded",				ET_Ignore,	Param_Cell, Param_Cell);
	g_hGlobalForvard_OnFPSPointsChangePre			= CreateGlobalForward("FPS_OnPointsChangePre",			ET_Hook,	Param_Cell, Param_Cell, Param_Cell, Param_FloatByRef, Param_FloatByRef);
	g_hGlobalForvard_OnFPSPointsChange				= CreateGlobalForward("FPS_OnPointsChange",				ET_Ignore,	Param_Cell, Param_Cell, Param_Float, Param_Float);
	g_hGlobalForvard_OnFPSPlayerPosition			= CreateGlobalForward("FPS_PlayerPosition",				ET_Ignore,	Param_Cell, Param_Cell, Param_Cell);

	#if USE_RANKS == 1
		g_hGlobalForvard_OnFPSLevelChange			= CreateGlobalForward("FPS_OnLevelChange",				ET_Ignore,	Param_Cell, Param_Cell, Param_Cell);
	#endif
}

void CallForward_OnFPSStatsLoaded()
{
	Call_StartForward(g_hGlobalForvard_OnFPSStatsLoaded);
	Call_Finish();
}

void CallForward_OnFPSDatabaseConnected()
{
	Call_StartForward(g_hGlobalForvard_OnFPSDatabaseConnected);
	Call_PushCell(g_hDatabase ? CloneHandle(g_hDatabase, GetMyHandle()) : null);
	Call_Finish();
}

void CallForward_OnFPSDatabaseLostConnection()
{
	Call_StartForward(g_hGlobalForvard_OnFPSDatabaseLostConnection);
	Call_Finish();
}

void CallForward_OnFPSClientLoaded(int iClient, float fPoints)
{
	Call_StartForward(g_hGlobalForvard_OnFPSClientLoaded);
	Call_PushCell(iClient);
	Call_PushCell(fPoints);
	Call_Finish();
}

Action CallForward_OnFPSPointsChangePre(int iAttacker, int iVictim, bool bHeadshot, float& fAddPointsAttacker, float& fAddPointsVictim)
{
	Action Result = Plugin_Continue;
	Call_StartForward(g_hGlobalForvard_OnFPSPointsChangePre);
	Call_PushCell(iAttacker);
	Call_PushCell(iVictim);
	Call_PushCell(bHeadshot);
	Call_PushFloatRef(fAddPointsAttacker);
	Call_PushFloatRef(fAddPointsVictim);
	Call_Finish(Result);
	return Result;
}

void CallForward_OnFPSPointsChange(int iAttacker, int iVictim, float fPointsAttacker, float fPointsVictim)
{
	Call_StartForward(g_hGlobalForvard_OnFPSPointsChange);
	Call_PushCell(iAttacker);
	Call_PushCell(iVictim);
	Call_PushFloat(fPointsAttacker);
	Call_PushFloat(fPointsVictim);
	Call_Finish();
}

#if USE_RANKS == 1
	void CallForward_OnFPSLevelChange(int iClient, int iOldLevel, int iNewLevel)
	{
		Call_StartForward(g_hGlobalForvard_OnFPSLevelChange);
		Call_PushCell(iClient);
		Call_PushCell(iOldLevel);
		Call_PushCell(iNewLevel);
		Call_Finish();
	}
#endif

void CallForward_OnFPSPlayerPosition(int iClient, int iPosition, int iPlayersCount)
{
	Call_StartForward(g_hGlobalForvard_OnFPSPlayerPosition);
	Call_PushCell(iClient);
	Call_PushCell(iPosition);
	Call_PushCell(iPlayersCount);
	Call_Finish();
}

// Natives
public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] szError, int iErr_max)
{
	if(GetEngineVersion() != Engine_CSGO)
	{
		return APLRes_Failure;
	}

	g_bLateLoad = bLate;
	CreateNative("FPS_StatsLoad",				Native_FPSStatsLoad);
	CreateNative("FPS_GetDatabase",				Native_FPSGetDatabase);
	CreateNative("FPS_ClientLoaded",			Native_FPSClientLoad);
	CreateNative("FPS_ClientReloadData",		Native_FPSClientReloadData);
	CreateNative("FPS_DisableStatisPerRound",	Native_FPSDisableStatisPerRound);
	CreateNative("FPS_GetPlayedTime",			Native_FPSGetPlayedTime);
	CreateNative("FPS_GetPoints",				Native_FPSGetPoints);
	CreateNative("FPS_GetSessionData",			Native_FPSGetSessionData);
	CreateNative("FPS_IsCalibration",			Native_FPSIsCalibration);

	#if USE_RANKS == 1
		CreateNative("FPS_GetLevel",				Native_FPSGetLevel);
		CreateNative("FPS_GetRanks",				Native_FPSGetRanks);
		CreateNative("FPS_GetMaxRanks",				Native_FPSGetMaxRanks);
	#endif

	RegPluginLibrary("FirePlayersStats");
	
	return APLRes_Success;
}

// bool FPS_StatsLoad();
public int Native_FPSStatsLoad(Handle hPlugin, int iNumParams)
{
	return g_bStatsLoaded;
}

// Database FPS_GetDatabase();
public int Native_FPSGetDatabase(Handle hPlugin, int iNumParams)
{
	return g_hDatabase ? view_as<int>(CloneHandle(g_hDatabase, hPlugin)) : 0;
}

// bool FPS_ClientLoaded(int iClient);
public int Native_FPSClientLoad(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	return (iClient > 0 && iClient <= MaxClients && g_bStatsLoad[iClient]);
}

// void FPS_ClientReloadData(int iClient);
public int Native_FPSClientReloadData(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	if (iClient > 0 && iClient <= MaxClients && g_bStatsLoad[iClient])
	{
		FPS_Debug("Native_FPSClientReloadData >> LoadStats: %N", iClient)
		OnClientDisconnect(iClient);
		LoadPlayerData(iClient);
	}
}

// void FPS_DisableStatisPerRound();
public int Native_FPSDisableStatisPerRound(Handle hPlugin, int iNumParams)
{
	g_bStatsActive = false;
}

// int FPS_GetPlayedTime(int iClient, bool bSession = false);
public int Native_FPSGetPlayedTime(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	if (iClient > 0 && iClient <= MaxClients && g_bStatsLoad[iClient])
	{
		return (GetTime() - g_iPlayerSessionData[iClient][PLAYTIME]) + (GetNativeCell(2) ? 0 : g_iPlayerData[iClient][PLAYTIME]);
	}
	return 0;
}

// float FPS_GetPoints(int iClient, bool bSession = false);
public int Native_FPSGetPoints(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	return view_as<int>(iClient > 0 && iClient <= MaxClients && g_bStatsLoad[iClient] ? (!GetNativeCell(1) ? g_fPlayerPoints[iClient] : (g_fPlayerPoints[iClient] - g_fPlayerSessionPoints[iClient])) : DEFAULT_POINTS);
}

#if USE_RANKS == 1
	// int FPS_GetLevel(int iClient);
	public int Native_FPSGetLevel(Handle hPlugin, int iNumParams)
	{
		int iClient = GetNativeCell(1);
		if (iClient > 0 && iClient <= MaxClients && g_bStatsLoad[iClient])
		{
			return g_iPlayerRanks[iClient];
		}
		return 0;
	}

	// void FPS_GetRanks(int iClient, char[] szBufferRank, int iMaxLength);
	public int Native_FPSGetRanks(Handle hPlugin, int iNumParams)
	{
		int iClient = GetNativeCell(1);
		if (iClient > 0 && iClient <= MaxClients && g_bStatsLoad[iClient])
		{
			SetNativeString(2, g_sRankName[iClient], GetNativeCell(3), true);
		}
	}

	// int FPS_GetMaxRanks();
	public int Native_FPSGetMaxRanks(Handle hPlugin, int iNumParams)
	{
		return g_iRanksCount;
	}
#endif

// int FPS_GetSessionData(int iClient, int iData);
public int Native_FPSGetSessionData(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1),
		iData = GetNativeCell(2);
	return iClient > 0 && iClient <= MaxClients && iData > -1 && iData != 3 && iData < sizeof(g_iPlayerSessionData[]) && g_bStatsLoad[iClient] ? g_iPlayerSessionData[iClient][iData] : 0;
}

// bool FPS_IsCalibration(int iClient);
public int Native_FPSIsCalibration(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	return (iClient > 0 && iClient <= MaxClients && g_bStatsLoad[iClient] && FPS_GetPlayedTime(iClient, false) < g_iCalibrationFixTime);
}
