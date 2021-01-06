#include <sourcemod>
#include <clientprefs>

#include <vip_api>

#include "API\directives.sp"
#include "API\header.sp"

#include "API\enums.sp"
#include "API\globals.sp"
#include "API\logs.sp"
#include "API\utils.sp"

#include "API\classes\ESFeature.sp"
#include "API\classes\ESFeatureContext.sp"
#include "API\classes\ESVipRank.sp"
#include "API\classes\ESPlayer.sp"
#include "API\classes\API.sp"

#include "API\db.sp"
#include "API\config.sp"
#include "API\forwards.sp"
#include "API\natives.sp"
#include "API\callbacks.sp"

#include "API\menu\backend.sp"
#include "API\menu\frontend.sp"

public void OnPluginStart()
{
    g_smFeatures = new StringMap();
    ESVipRanks = new StringMap();
    Api = new API();

    LoadPhrases();
    CreateVariables();
}